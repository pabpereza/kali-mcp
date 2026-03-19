FROM kalilinux/kali-rolling

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mcp-kali-server \
    nmap \
    gobuster \
    dirb \
    nikto \
    perl \
    libnet-ssleay-perl \
    sqlmap \
    hydra \
    john \
    wpscan \
    enum4linux \
    curl \
    wget \
    net-tools \
    iputils-ping \
    nodejs \
    npm

RUN npm install -g supergateway

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /tmp/workspace
WORKDIR /tmp/workspace

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -sf http://localhost:5000/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
