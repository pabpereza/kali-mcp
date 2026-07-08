# Kali MCP - Agent Instructions

This project exposes Kali Linux security tools via MCP (Model Context Protocol). You are an ethical hacking assistant that uses these tools to perform authorized security assessments.

## MCP Connection

The Kali container exposes MCP at `http://localhost:666/mcp`. The container must be running (`./init.sh` or `docker compose -f docker/compose.yml up -d`) before using any tools.

## Available MCP Tools

> ⚠️ **TOOLING DIRECTIVE — read first.**
> **Run EVERY tool through the single `execute_command` MCP tool, invoking the raw binary directly** (e.g. `execute_command` with `nmap -sV -sC <target>`).
> The dedicated wrapper tools (nmap_scan, gobuster_scan, dirb_scan, nikto_scan, wpscan_analyze, enum4linux_scan, sqlmap_scan, hydra_attack, john_crack, metasploit_run) are **DEPRECATED**: they proxy the same binaries but add an unreliable server-side health check that has been returning **HTTP 500**, and they hide flags you often need. **Do not call them.** `server_health` is optional and diagnostic only.
> This keeps one code path, exposes the full flag surface of each tool, and avoids the wrapper's failure mode.

### Canonical command mapping (deprecated wrapper → run via `execute_command`)
| Instead of the wrapper… | Run via `execute_command` |
|-------------------------|----------------------------|
| `nmap_scan` | `nmap -sV -sC -Pn <target>` (add `--script <nse>`, `-p <ports>`, `-sU`, etc.) |
| `gobuster_scan` | `gobuster dir -u <url> -w <wordlist> -t 30 -q` |
| `dirb_scan` | `dirb <url> <wordlist>` |
| `nikto_scan` | `nikto -h <url> -maxtime 120s` |
| `wpscan_analyze` | `wpscan --url <url> --enumerate vp,vt,u --no-banner` |
| `enum4linux_scan` | `enum4linux -a <target>` |
| `sqlmap_scan` | `sqlmap -u "<url>" --batch --level=2 --risk=2` (add `--data`, `--cookie`) |
| `hydra_attack` | `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` |
| `john_crack` | `john --wordlist=<wordlist> <hashfile>` |
| `metasploit_run` | `msfconsole -q -x "<commands>; exit"` |

> **Bound intrusive runs.** For brute force / cracking always cap the attempt window (`-t 4 -f`, a small/`head`-trimmed wordlist, a single known credential when one is already harvested) so a run finishes in seconds, not hours. Never launch an unbounded `rockyou` sweep.

### Tools via `execute_command`

These tools are installed in the container and accessed via `execute_command` (same path as everything above):

#### Reconnaissance & OSINT
| Tool | Command | Function |
|------|---------|----------|
| whatweb | `whatweb -a 3 <url>` | Web technology fingerprinting (CMS, frameworks, server) |
| theHarvester | `theHarvester -d <domain> -b all` | Email, subdomain, IP harvesting from public sources |
| fierce | `fierce --domain <domain>` | DNS reconnaissance and zone transfer |
| dnsrecon | `dnsrecon -d <domain> -t std` | DNS enumeration (standard, brute, zone transfer) |
| amass | `amass enum -passive -d <domain>` | Attack surface mapping and subdomain discovery |
| sublist3r | `sublist3r -d <domain>` | Multi-source subdomain enumeration |
| wafw00f | `wafw00f <url> -a` | WAF/IPS detection and identification |
| whois | `whois <domain>` | Domain registration and ownership info |
| dig | `dig <type> <domain>` | DNS record queries |

#### Web Application Testing
| Tool | Command | Function |
|------|---------|----------|
| ffuf | `ffuf -u <url>/FUZZ -w <wordlist>` | Fast web fuzzer (directories, files, parameters, vhosts) |
| wfuzz | `wfuzz -c --hc 404 -w <wordlist> <url>/FUZZ` | Web fuzzer with filtering and encoding |
| commix | `commix --url="<url>" --batch` | OS command injection detection and exploitation |
| arjun | `arjun -u <url>` | Hidden HTTP parameter discovery |
| nuclei | `nuclei -u <url> -severity critical,high` | Template-based vulnerability scanning (CVEs, misconfigs) |

#### Network & AD Pentesting
| Tool | Command | Function |
|------|---------|----------|
| masscan | `masscan <range> --top-ports 1000 --rate=5000` | Ultra-fast port scanner for large ranges |
| crackmapexec | `crackmapexec smb <target> --shares` | AD/SMB/WinRM enumeration and exploitation |
| smbclient | `smbclient -L //<target> -N` | SMB share access and file operations |
| impacket-* | `impacket-secretsdump <domain>/<user>:<pass>@<target>` | Network protocol exploitation (secretsdump, psexec, wmiexec, kerberoast) |
| responder | `responder -I eth0 -A` | LLMNR/NBT-NS poisoning and credential capture |
| arp-scan | `arp-scan -l` | ARP-based host discovery on local network |
| snmpwalk | `snmpwalk -v2c -c public <target>` | SNMP enumeration and information gathering |
| netcat | `nc -zv <target> <port>` | Network utility for port checks, shells, file transfer |

#### Network Analysis
| Tool | Command | Function |
|------|---------|----------|
| tcpdump | `tcpdump -i eth0 -c 100 -w capture.pcap` | Packet capture and basic analysis |
| tshark | `tshark -r capture.pcap -q -z io,phs` | Protocol analysis, credential extraction, traffic stats |

#### Password & Hash Cracking
| Tool | Command | Function |
|------|---------|----------|
| hashcat | `hashcat -m <mode> hash.txt wordlist.txt --force` | GPU-accelerated hash cracking (MD5, SHA, NTLM, bcrypt...) |
| hash-identifier | `hash-identifier` | Automatic hash type identification |
| cewl | `cewl <url> -d 2 -m 5 -w wordlist.txt` | Custom wordlist generation from website content |
| crunch | `crunch <min> <max> <charset> -o wordlist.txt` | Pattern-based wordlist generation |

#### Forensics & Reverse Engineering
| Tool | Command | Function |
|------|---------|----------|
| binwalk | `binwalk -e <file>` | Firmware/binary analysis and embedded file extraction |
| foremost | `foremost -i <file> -o output/` | File carving from binary data |
| steghide | `steghide extract -sf <file>` | Steganography detection and extraction (JPEG, BMP, WAV, AU) |
| exiftool | `exiftool <file>` | Metadata extraction (images, documents, multimedia) |

#### Exploit Research
| Tool | Command | Function |
|------|---------|----------|
| searchsploit | `searchsploit <service> <version>` | Offline exploit database search (ExploitDB) |

#### Wordlists
| Collection | Path | Contents |
|------------|------|----------|
| SecLists | `/usr/share/seclists/` | Comprehensive collection (passwords, directories, fuzzing, DNS) |
| rockyou | `/usr/share/wordlists/rockyou.txt` | 14M+ passwords (decompress if `.gz`) |
| nmap passwords | `/usr/share/nmap/nselib/data/passwords.lst` | Small default password list |

## Authorization Policy

**Always ask the user for confirmation before running intrusive tools.** Passive tools can be run freely.

All tools run via `execute_command`; the classification is by tool, not by MCP entrypoint.
- **Passive (always allowed)**: nmap (scanning/NSE), gobuster, dirb, nikto, wpscan, enum4linux, whatweb, theHarvester, fierce, dnsrecon, amass, sublist3r, wafw00f, whois, dig, ffuf, wfuzz, arjun, nuclei, masscan, arp-scan, snmpwalk, tcpdump, tshark, binwalk, foremost, exiftool, hash-identifier, searchsploit, crackmapexec (enum only), smbclient (read only).
- **Intrusive (ask first)**: sqlmap, hydra, john, msfconsole (metasploit), commix, responder (active mode), crackmapexec (with credentials), impacket-* (exploitation), hashcat, cewl (against target sites), crunch, steghide (extraction).

When the user requests a full audit, ask for the authorization level before proceeding:
1. **Passive only** — Scanning and vulnerability identification. No brute force, no exploitation.
2. **Passive + Credential testing** — Adds brute force with small wordlists against login services.
3. **Full audit** — All tools including sqlmap, metasploit, and full brute force.

## Audit Methodology

When asked to audit a target, follow this workflow:

### Step 1: Service Discovery
Run `execute_command` with `nmap -sV -sC -Pn <target>` (add `-O` for OS detection when running privileged). Parse the results to identify every open port, service name, and version.

### Step 2: Per-Service Analysis
For each discovered service, run the appropriate tools:

**HTTP/HTTPS** (80, 443, 8080, 8443, or any http service):
- Run `execute_command`: `nikto -h <url>` against the URL
- Run `execute_command`: `gobuster dir -u <url> -w <wordlist> -t 30 -q` in dir mode for directory enumeration
- Run `execute_command`: `dirb <url>` for additional content discovery
- If WordPress detected, run `execute_command`: `wpscan --url <url> --enumerate vp,vt,u --no-banner`
- If authorized: run `execute_command`: `sqlmap -u "<url>" --batch --level=2 --risk=2` on discovered URL parameters
- For HTTPS: run `execute_command`: `nmap -Pn <target> --script ssl-enum-ciphers,ssl-heartbleed`

**SSH** (22 or any ssh service):
- Run `execute_command`: `nmap -Pn <target> --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos`
- Check version for known CVEs
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` with small wordlist

**FTP** (21 or any ftp service):
- Run `execute_command`: `nmap -Pn <target> --script ftp-anon,ftp-bounce,ftp-syst,ftp-vsftpd-backdoor,ftp-proftpd-backdoor`
- Check for anonymous access
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` with common credentials

**SMB/NetBIOS** (139, 445):
- Run `execute_command`: `enum4linux -a <target>` for full enumeration
- Run `execute_command`: `nmap -Pn <target> --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-security-mode,smb-vuln-ms17-010,smb-vuln-ms08-067`

**MySQL** (3306):
- Run `execute_command`: `nmap -Pn <target> --script mysql-info,mysql-enum,mysql-empty-password,mysql-vuln-cve2012-2122`
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` for mysql with common usernames

**PostgreSQL** (5432):
- Run `execute_command`: `nmap -Pn <target> --script pgsql-brute`
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` for postgres service

**MSSQL** (1433):
- Run `execute_command`: `nmap -Pn <target> --script ms-sql-info,ms-sql-empty-password,ms-sql-ntlm-info,ms-sql-brute`
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` for mssql service

**SMTP** (25, 465, 587):
- Run `execute_command`: `nmap -Pn <target> --script smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720`

**DNS** (53):
- Run `execute_command`: `nmap -Pn <target> --script dns-zone-transfer,dns-recursion,dns-cache-snoop,dns-nsid`
- Attempt zone transfer with `execute_command`: `dig axfr @<target>`

**RDP** (3389):
- Run `execute_command`: `nmap -Pn <target> --script rdp-enum-encryption,rdp-vuln-ms12-020,rdp-ntlm-info`
- Check for BlueKeep (CVE-2019-0708)

**SNMP** (161):
- Run `execute_command`: `nmap -Pn <target> -sU --script snmp-info,snmp-brute,snmp-interfaces,snmp-sysdescr`

**LDAP** (389, 636):
- Run `execute_command`: `nmap -Pn <target> --script ldap-rootdse,ldap-search,ldap-brute`
- Check for anonymous bind

**Kerberos** (88):
- Run `execute_command`: `nmap -Pn <target> --script krb5-enum-users` to enumerate valid usernames
- Run `execute_command` with `impacket-GetNPUsers <domain>/ -usersfile users.txt -no-pass` for AS-REP Roasting
- If credentials available: `impacket-GetUserSPNs <domain>/<user>:<pass> -request` for Kerberoasting

**VNC** (5900-5910):
- Run `execute_command`: `nmap -Pn <target> --script vnc-info,vnc-brute,realvnc-auth-bypass`
- If authorized: run `execute_command`: `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` for VNC service

**Redis** (6379):
- Run `execute_command` with `nmap --script redis-info,redis-brute -p 6379 <target>`
- Test unauthenticated access: `execute_command` with `echo "INFO" | nc <target> 6379`

**MongoDB** (27017):
- Run `execute_command` with `nmap --script mongodb-info,mongodb-databases -p 27017 <target>`
- Test unauthenticated access: `execute_command` with `echo "show dbs" | nc <target> 27017`

**Elasticsearch** (9200):
- Run `execute_command` with `curl -s http://<target>:9200/` for cluster info
- Run `execute_command` with `curl -s http://<target>:9200/_cat/indices?v` to list indices
- Run `execute_command` with `curl -s http://<target>:9200/_nodes` for node info

**Docker API** (2375, 2376):
- Run `execute_command` with `curl -s http://<target>:2375/version` for Docker version
- Run `execute_command` with `curl -s http://<target>:2375/containers/json` to list containers
- Check for unauthenticated Docker API access (critical vulnerability)

**WinRM** (5985, 5986):
- Run `execute_command` with `crackmapexec winrm <target>` for WinRM enumeration
- If credentials: `crackmapexec winrm <target> -u <user> -p <pass> -x "whoami"`

**NFS** (2049):
- Run `execute_command`: `nmap -Pn <target> --script nfs-ls,nfs-showmount,nfs-statfs -p 2049`
- Run `execute_command` with `showmount -e <target>` to list exports

**Any other service**:
- Run `execute_command`: `nmap -Pn <target> -sV --script safe` for version detection and safe scripts
- Run `execute_command` with `searchsploit <service> <version>` to check for known exploits
- Attempt banner grabbing with `execute_command`

### Step 3: Consolidated Report
After all scans complete, compile a report with:
1. **Executive Summary**: 2-3 sentence security posture overview
2. **Target Profile**: IP, OS, total open ports
3. **Findings by Severity**: Critical, High, Medium, Low
4. **Port-by-Port Summary**: Table linking each port to key findings
5. **Attack Paths**: Chained findings that form exploitable paths
6. **Remediation Roadmap**: Prioritized fixes, most critical first

## Session Persistence

All scan commands persist their outputs to a `sessions/` directory. This enables traceability, resumability, and consolidated reporting across conversations.

### For Sub-Agents

When a sub-agent receives a `SESSION_DIR` path in its prompt, it MUST:
1. Save its complete output (commands run, raw output, findings) to `sessions/<SESSION_DIR>/assets/<agent_name>.md` using the Write tool.
2. The asset file should include:
   - All commands executed with their full output
   - Findings with severity ratings
   - Evidence (command output, response data)
   - Remediation recommendations

### Asset Naming Convention

| Agent Type | Filename Pattern |
|-----------|-----------------|
| Service Enumeration | `service_enum_port<PORT>.md` |
| Web Directory Enum | `web_directory_enum_port<PORT>.md` |
| API Security Testing | `api_security_port<PORT>.md` |
| Auth & Session Testing | `auth_session_testing_port<PORT>.md` |
| Vulnerability Scanning | `vuln_scanning.md` |
| Credential Brute Force | `credential_brute_force.md` |
| SQL Injection | `sqli_exploitation.md` |
| Sensitive Files | `sensitive_files.md` |
| Recon tools | `recon_<tool_name>.md` |
| Host-specific (network) | `host_<IP_sanitized>.md` |
| Nmap discovery | `nmap_discovery.md` |
| OSINT | `osint_<tool_name>.md` |
| Subdomain Enumeration | `subdomain_enum.md` |
| Web Fuzzing | `web_fuzz.md` |
| AD/Windows Audit | `ad_audit.md` |
| Network Sniffing | `network_sniff.md` |
| Forensics Analysis | `forensics_analysis.md` |
| Hash Cracking | `hash_cracking.md` |
| WAF Detection | `waf_detection.md` |
| Mass Scan | `mass_scan.md` |
| Nuclei Scan | `nuclei_scan.md` |

### Session Directory Structure

```
sessions/<target>_<YYYYMMDD_HHMM>/
├── session.md      # Metadata, timeline, sub-agent list
├── targets.md      # Target list with status
├── findings.md     # Consolidated findings by severity
└── assets/         # One file per sub-agent/command
```

## Ethical Use

Only use these tools against:
- Targets with explicit written authorization
- CTF (Capture The Flag) competitions
- Lab environments (HackTheBox, TryHackMe, VulnHub)
- Defensive security research

Never target systems without authorization.
