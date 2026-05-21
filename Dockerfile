FROM debian:bullseye-slim

# Set environment defaults
ENV TAILSCALE_HOSTNAME="Render-server-surya"
ENV TAILSCALE_ADDITIONAL_ARGS=""

# Install required tools including Python and HAProxy
RUN apt-get update && apt-get install -y \
    nano \
    ca-certificates \
    curl \
    wget \
    python3 \
    jq \
    haproxy \
    && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create necessary directories
RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale /tmp /etc/haproxy

WORKDIR /tailscale.d
COPY start.sh /tailscale.d/start.sh
RUN chmod +x /tailscale.d/start.sh

CMD ["./start.sh"]
