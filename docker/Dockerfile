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
    wordlists \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure rockyou.txt is present and decompressed at the canonical path.
# The `wordlists` package ships it gzipped; several tools/prompts expect the
# plaintext file at /usr/share/wordlists/rockyou.txt.
RUN if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then \
        gunzip -k /usr/share/wordlists/rockyou.txt.gz; \
    fi && \
    if [ ! -f /usr/share/wordlists/rockyou.txt ] && \
       [ -f /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz ]; then \
        tar -xzf /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz \
            -C /usr/share/wordlists/; \
    fi

# Refresh offline exploit/vuln databases at build time so runs don't depend on
# whatever the apt snapshot shipped.
RUN searchsploit -u || true && \
    nuclei -update-templates || true

RUN npm install -g supergateway

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir -p /tmp/workspace
WORKDIR /tmp/workspace

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -sf http://localhost:5000/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
