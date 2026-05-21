#!/bin/bash

# 1. Start Python HTTP server internally on 8080 (HAProxy will route health checks here)
python3 -m http.server 8080 --directory /tmp &

# 2. Inject Render's dynamic $PORT into the HAProxy config and start it
RENDER_PORT=${PORT:-10000}
echo "Configuring HAProxy to listen on Render port: $RENDER_PORT"
sed "s/RENDER_PORT/$RENDER_PORT/g" /tailscale.d/haproxy.cfg.template > /tmp/haproxy.cfg

# Start HAProxy in the background
haproxy -f /tmp/haproxy.cfg &

# 3. Start Tailscale daemon (using your working configuration)
tailscaled --tun=userspace-networking --verbose=1 &
sleep 5

# Up with exit node configuration
tailscale up \
  --auth-key="${TAILSCALE_AUTHKEY}" \
  --hostname="${TAILSCALE_HOSTNAME}" \
  --advertise-exit-node \
  --ssh \
  --accept-dns=true

# Keep container alive with periodic status updates
while true; do
  echo "$(date): Tailscale status - $(tailscale status --json | jq -r '.Self.Online')"
  
  # Touch a file to keep the internal web server serving fresh content
  echo "Last updated: $(date) | SNI Proxy Active" > /tmp/index.html
  
  sleep 60
done
