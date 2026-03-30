FROM kalilinux/kali-rolling

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # --- MCP Server & Runtime ---
    mcp-kali-server \
    nodejs \
    npm \
    # --- Core Utilities ---
    curl \
    wget \
    net-tools \
    iputils-ping \
    perl \
    libnet-ssleay-perl \
    dnsutils \
    whois \
    # --- Port Scanning & Network Discovery ---
    nmap \
    masscan \
    arp-scan \
    netcat-traditional \
    # --- OSINT & Reconnaissance ---
    whatweb \
    theharvester \
    fierce \
    dnsrecon \
    amass \
    sublist3r \
    wafw00f \
    # --- Web Application Testing ---
    gobuster \
    dirb \
    nikto \
    ffuf \
    wfuzz \
    commix \
    arjun \
    nuclei \
    wpscan \
    # --- Network & AD Pentesting ---
    enum4linux \
    crackmapexec \
    smbclient \
    impacket-scripts \
    responder \
    snmp \
    tcpdump \
    tshark \
    # --- Exploitation ---
    sqlmap \
    hydra \
    exploitdb \
    # --- Password & Hash Cracking ---
    john \
    hashcat \
    hash-identifier \
    cewl \
    crunch \
    # --- Forensics & Reverse Engineering ---
    binwalk \
    foremost \
    steghide \
    libimage-exiftool-perl \
    # --- Wordlists ---
    seclists \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm install -g supergateway

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /tmp/workspace
WORKDIR /tmp/workspace

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -sf http://localhost:5000/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
