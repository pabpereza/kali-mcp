FROM kalilinux/kali-rolling

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mcp-kali-server \
    nmap \
    gobuster \
    dirb \
    nikto \
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
    npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g supergateway

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]
