# Claude Code — Kali MCP

Read `AGENTS.md` for the full project context: available MCP tools, authorization policy, audit methodology, and per-service playbooks. Everything in AGENTS.md applies here. This file only covers Claude-specific features.

## Slash Commands

### Orchestrators (launch parallel sub-agents)
| Command | Description |
|---------|-------------|
| `/project:audit <target>` | Full audit: nmap discovery, sub-agent per port, consolidated report |
| `/project:pentest <target>` | Full pentest with max parallelism: 7+ specialized sub-agents per web target |
| `/project:network-discovery <range>` | Host discovery, sub-agent per live host |

### Standalone
| Command | Description |
|---------|-------------|
| `/project:recon <target>` | Passive recon (nmap + gobuster + nikto) |
| `/project:vuln-scan <target>` | Vulnerability identification with nmap scripts |
| `/project:web-audit <url>` | Web application audit |
| `/project:wp-audit <url>` | WordPress audit |
| `/project:brute <target> <service>` | Brute force with hydra/john |
| `/project:exploit <target> <vuln>` | Exploit a specific vulnerability |

## Sub-Agent Architecture

### Design Principles

1. **Orchestrator stays clean**: The main process ONLY does nmap discovery, asks authorization, dispatches sub-agents, and compiles the final report. No scanning in the orchestrator.
2. **Maximum parallelism**: ALL sub-agents launch in a SINGLE `Agent` tool call so they run concurrently.
3. **Specialized agents**: Each sub-agent has a focused mission (not a broad one). This reduces context bloat and improves results.
4. **Scope injection**: Every sub-agent receives the authorization level in its prompt and respects its constraints.

### Sub-Agent Types for `/project:pentest`

For a web application target, the orchestrator launches up to **7 parallel sub-agents**:

| Sub-Agent | Mission | Scope Required |
|-----------|---------|----------------|
| Service Enumeration | Per-port service audit (nmap scripts, service-specific checks) | Passive |
| Web Directory Enumeration | Discover hidden endpoints, files, directories | Passive |
| API Security Testing | Test API endpoints, IDOR, auth bypass, info disclosure | Passive |
| Auth & Session Testing | SQLi on login, JWT analysis, credential testing | Passive |
| Vulnerability Scanning | nmap vuln scripts, nikto, CVE identification | Passive |
| Credential Brute Force | hydra, default creds, password spray | Credential+ |
| SQL Injection Exploitation | sqlmap, DB dump, data exfiltration | Full only |
| Sensitive File Discovery | FTP bypass, null byte, path traversal, key/log exposure | Full only |

### Sub-Agent Types for `/project:audit`

One sub-agent per discovered port/service, using the service playbooks from AGENTS.md.

### Sub-Agent Types for `/project:network-discovery`

One sub-agent per discovered live host.

## Authorization via AskUserQuestion

For intrusive tools (hydra_attack, sqlmap_scan, john_crack, metasploit_run), use `AskUserQuestion` to get explicit user confirmation before execution. Never run intrusive tools without asking first.

Three authorization levels:
1. **Passive only** — Scanning and vulnerability identification
2. **Passive + Credential testing** — Adds brute force
3. **Full pentest/audit** — All tools including sqlmap, metasploit
