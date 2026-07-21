---
type: Tool Playbook
title: Tool reference catalog
description: Every tool in the Kali container — canonical invocation and function, organized by category.
tags: [catalog]
timestamp: 2026-07-20T00:00:00Z
---

Full command reference for every tool in the container. Tools with a linked
name have their own file with accumulated efficiency notes (flags, timeouts,
wordlists, pitfalls) — read that file too before running them. A tool
without a link has no notes yet; if you learn something reusable about it,
`/kali-finish` creates the file per the convention in the linked files.

# Tooling directive

Run **every** tool through the single `execute_command` MCP tool, invoking
the raw binary directly (e.g. `execute_command` with `nmap -sV -sC
<target>`). The dedicated wrapper tools below are **deprecated** — they
proxy the same binaries but return HTTP 500 from an unreliable
server-side health check, and hide flags you often need. Do not call them.

| Instead of the wrapper… | Run via `execute_command` |
|--------------------------|----------------------------|
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

**Bound intrusive runs.** For brute force / cracking always cap the attempt
window (`-t 4 -f`, a small/`head`-trimmed wordlist, a single known
credential when one is already harvested) so a run finishes in seconds, not
hours. Never launch an unbounded `rockyou` sweep.

[nmap](nmap.md) — `nmap -sV -sC -Pn <target>` (add `--script <nse>`, `-p
<ports>`, `-sU`, `-O`, etc.) — is the single most-used tool here and underlies
almost every protocol playbook in `../protocols/`; see its file for the
two-pass discovery strategy.

# Reconnaissance & OSINT
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

# Web Application Testing
| Tool | Command | Function |
|------|---------|----------|
| [nikto](nikto.md) | `nikto -h <url> -maxtime 120s` | Web server vulnerability scanning |
| [gobuster](gobuster.md) | `gobuster dir -u <url> -w <wordlist> -t 30 -q` | Directory, DNS, and vhost enumeration |
| dirb | `dirb <url> <wordlist>` | Web content discovery |
| wpscan | `wpscan --url <url> --enumerate vp,vt,u --no-banner` | WordPress vulnerability scanning |
| sqlmap | `sqlmap -u "<url>" --batch --level=2 --risk=2` | SQL injection detection and exploitation (**intrusive**) |
| ffuf | `ffuf -u <url>/FUZZ -w <wordlist>` | Fast web fuzzer (directories, files, parameters, vhosts) |
| wfuzz | `wfuzz -c --hc 404 -w <wordlist> <url>/FUZZ` | Web fuzzer with filtering and encoding |
| [commix](commix.md) | `commix --url="<url>" --batch` | OS command injection detection and exploitation (**intrusive**) |
| [arjun](arjun.md) | `arjun -u <url>` | Hidden HTTP parameter discovery |
| [nuclei](nuclei.md) | `nuclei -u <url> -severity critical,high` | Template-based vulnerability scanning (CVEs, misconfigs) |

# Network & AD Pentesting
| Tool | Command | Function |
|------|---------|----------|
| masscan | `masscan <range> --top-ports 1000 --rate=5000` | Ultra-fast port scanner for large ranges |
| enum4linux | `enum4linux -a <target>` | Windows/Samba enumeration |
| crackmapexec | `crackmapexec smb <target> --shares` | AD/SMB/WinRM enumeration and exploitation |
| smbclient | `smbclient -L //<target> -N` | SMB share access and file operations |
| impacket-* | `impacket-secretsdump <domain>/<user>:<pass>@<target>` | Network protocol exploitation suite (secretsdump, psexec, wmiexec, kerberoast, GetNPUsers, GetUserSPNs) (**intrusive**) |
| responder | `responder -I eth0 -A` | LLMNR/NBT-NS poisoning and credential capture (**intrusive**, active mode) |
| arp-scan | `arp-scan -l` | ARP-based host discovery on local network |
| snmpwalk | `snmpwalk -v2c -c public <target>` | SNMP enumeration and information gathering |
| netcat | `nc -zv <target> <port>` | Network utility for port checks, shells, file transfer |

# Network Analysis
| Tool | Command | Function |
|------|---------|----------|
| tcpdump | `tcpdump -i eth0 -c 100 -w capture.pcap` | Packet capture and basic analysis |
| tshark | `tshark -r capture.pcap -q -z io,phs` | Protocol analysis, credential extraction, traffic stats |

# Password & Hash Cracking
| Tool | Command | Function |
|------|---------|----------|
| [hydra](hydra.md) | `hydra -L <users> -P <pass> -t 4 -f <service>://<target>` | Password brute force (**intrusive**) |
| john | `john --wordlist=<wordlist> <hashfile>` | Password hash cracking (**intrusive**) |
| hashcat | `hashcat -m <mode> hash.txt wordlist.txt --force` | GPU-accelerated hash cracking (MD5, SHA, NTLM, bcrypt...) (**intrusive**) |
| hash-identifier | `hash-identifier` | Automatic hash type identification |
| cewl | `cewl <url> -d 2 -m 5 -w wordlist.txt` | Custom wordlist generation from website content (**intrusive** against target sites) |
| crunch | `crunch <min> <max> <charset> -o wordlist.txt` | Pattern-based wordlist generation |

# Forensics & Reverse Engineering
| Tool | Command | Function |
|------|---------|----------|
| binwalk | `binwalk -e <file>` | Firmware/binary analysis and embedded file extraction |
| foremost | `foremost -i <file> -o output/` | File carving from binary data |
| steghide | `steghide extract -sf <file>` | Steganography detection and extraction (JPEG, BMP, WAV, AU) (**intrusive**, extraction) |
| exiftool | `exiftool <file>` | Metadata extraction (images, documents, multimedia) |

# Exploit Research & Exploitation
| Tool | Command | Function |
|------|---------|----------|
| searchsploit | `searchsploit <service> <version>` | Offline exploit database search (ExploitDB) |
| msfconsole | `msfconsole -q -x "<commands>; exit"` | Metasploit module execution (**intrusive**) |

# Wordlists
| Collection | Path | Contents |
|------------|------|----------|
| SecLists | `/usr/share/seclists/` | Comprehensive collection (passwords, directories, fuzzing, DNS) |
| rockyou | `/usr/share/wordlists/rockyou.txt` | 14M+ passwords (decompress if `.gz`) |
| nmap passwords | `/usr/share/nmap/nselib/data/passwords.lst` | Small default password list |

# See also

[../protocols/index.md](../protocols/index.md) — which of these tools to
use, in what order, for a given protocol or application.
