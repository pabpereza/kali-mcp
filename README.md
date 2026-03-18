# Kali MCP

An ethical hacking toolkit that connects AI agents to Kali Linux security tools via [MCP (Model Context Protocol)](https://modelcontextprotocol.io/).

Compatible with any AI agent that supports MCP: Claude Code, Gemini CLI, OpenCode, Cursor, Copilot, Codex, Aider, Windsurf, goose, and others.

```
> Audit host 192.168.1.50

 Scanning target with nmap...

 PORT    SERVICE       VERSION
 22/tcp  ssh           OpenSSH 8.9
 80/tcp  http          Apache 2.4.54
 443/tcp https         nginx 1.18
 445/tcp microsoft-ds  Samba 4.15

 Analyzing 4 services...
   [SSH :22]   -> version analysis, weak algos, CVEs
   [HTTP :80]  -> nikto, gobuster, dirb, wpscan
   [HTTPS:443] -> nikto, gobuster, ssl audit
   [SMB :445]  -> enum4linux, smb-vuln scripts

 Consolidated report ready.
```

## Prerequisites

- **Docker** and **Docker Compose** (v2+)
- An AI agent with MCP support (see [Compatibility](#compatibility))
- A terminal with `curl` (used by `init.sh` to health-check the container)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/pabpereza/kali-mcp.git
cd kali-mcp
```

### 2. Start the Kali MCP container

```bash
./init.sh
```

This script will:
1. Build the Docker image (Kali Linux with all security tools pre-installed).
2. Start the container via Docker Compose.
3. Wait until the MCP server is healthy and accepting connections on `http://localhost:666/mcp`.

> On first run, the image build may take several minutes as it installs Kali packages.

### 3. Launch your AI agent

Open your AI agent **from the project directory** so it auto-detects the `.mcp.json` configuration:

```bash
claude          # Claude Code
gemini          # Gemini CLI
opencode        # OpenCode
```

That's it. The agent will read its instruction file (`AGENTS.md` or `CLAUDE.md`), connect to the MCP endpoint, and you can start issuing commands in natural language:

```
> Scan ports on 10.10.10.5 with version detection
> Find hidden directories on http://target.com
> Run wpscan against http://blog.target.com
> Check if FTP on 10.10.10.5 allows anonymous login
```

### 4. Stopping the container

```bash
docker compose -f docker/compose.yml down
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  AI Agent (Claude / Gemini / OpenCode / ...)        │
│                                                     │
│  Reads AGENTS.md (or CLAUDE.md) for instructions    │
│  Uses MCP tools to execute security actions         │
│                                                     │
│  [Claude Code: parallel sub-agents per port]        │
└──────────────────────┬──────────────────────────────┘
                       │ MCP (HTTP) localhost:666
┌──────────────────────┼──────────────────────────────┐
│  Docker: kali-mcp    │                              │
│                      ▼                              │
│  ┌─────────────────────────────────────┐            │
│  │ supergateway :8000                  │            │
│  │ Streamable HTTP  <->  MCP stdio    │            │
│  └──────────────┬──────────────────────┘            │
│                 │                                   │
│  ┌──────────────▼──────────────────────┐            │
│  │ kali-server-mcp :5000 (Flask API)   │            │
│  │                                     │            │
│  │  nmap · gobuster · dirb · nikto     │            │
│  │  sqlmap · hydra · john · wpscan     │            │
│  │  enum4linux · metasploit            │            │
│  └─────────────────────────────────────┘            │
└─────────────────────────────────────────────────────┘
```

The container runs two processes:

1. **kali-server-mcp** — A Flask API (port 5000, internal) that wraps Kali security tools and exposes them as MCP-compatible operations.
2. **supergateway** — A bridge (port 8000, mapped to host port 666) that converts the internal stdio-based MCP protocol to Streamable HTTP, so any external agent can connect over the network.

## Repository Structure

```
kali-mcp/
├── init.sh                  # Bootstrap script: build, start, and wait for readiness
├── .mcp.json                # MCP server configuration (auto-detected by agents)
├── AGENTS.md                # Agent instructions: tools, auth policy, methodology, service playbooks
├── CLAUDE.md                # Claude Code-specific: references AGENTS.md + sub-agent architecture
├── docker/
│   ├── Dockerfile           # Kali Linux image with all security tools
│   ├── compose.yml          # Docker Compose service definition
│   └── entrypoint.sh        # Container entrypoint: starts Flask API + supergateway
└── .claude/
    └── commands/            # Slash commands (Claude Code only)
        ├── audit.md         # /audit — Full audit with parallel sub-agents
        ├── pentest.md       # /pentest — Full pentest in 5 phases
        ├── network-discovery.md  # /network-discovery — Host discovery per range
        ├── recon.md         # /recon — Passive reconnaissance
        ├── vuln-scan.md     # /vuln-scan — Vulnerability identification
        ├── web-audit.md     # /web-audit — Web application audit
        ├── wp-audit.md      # /wp-audit — WordPress audit
        ├── brute.md         # /brute — Brute force with hydra/john
        └── exploit.md       # /exploit — Exploit a specific vulnerability
```

### Key Files

| File | Who reads it | Purpose |
|------|-------------|---------|
| `AGENTS.md` | All agents (Gemini CLI, OpenCode, Cursor, Copilot, etc.) | Tools reference, authorization policy, audit methodology, per-service playbooks |
| `CLAUDE.md` | Claude Code | References AGENTS.md + defines slash commands and sub-agent architecture |
| `.claude/commands/*.md` | Claude Code | Slash command definitions for orchestrated workflows |
| `.mcp.json` | All agents | MCP server endpoint configuration |

## Compatibility

The project uses `AGENTS.md` as the instruction file — the open standard supported by most AI agents. Additionally, `CLAUDE.md` provides Claude Code-exclusive features like parallel sub-agents.

| Agent | Instruction file | MCP support | Parallel sub-agents |
|-------|-----------------|-------------|---------------------|
| **Claude Code** | `CLAUDE.md` + `AGENTS.md` (via reference) | Native (`.mcp.json`) | Yes (Agent tool) |
| **Gemini CLI** | `AGENTS.md` | Native | No |
| **OpenCode** | `AGENTS.md` | Native | No |
| **Cursor** | `AGENTS.md` | Native | No |
| **GitHub Copilot** | `AGENTS.md` | Native | No |
| **Codex (OpenAI)** | `AGENTS.md` | Native | No |
| **Aider** | `AGENTS.md` | Native | No |
| **Windsurf** | `AGENTS.md` | Native | No |
| **goose** | `AGENTS.md` | Native | No |

> **Note on sub-agents**: The parallel audit architecture (one agent per port/service) is a Claude Code-exclusive feature via its Agent tool. Other agents execute audits sequentially following the same methodology defined in `AGENTS.md`. The end result is equivalent; Claude Code simply does it faster by parallelizing.

### Manual MCP configuration

The `.mcp.json` file in the project root is the standard configuration:

```json
{
  "mcpServers": {
    "kali": {
      "type": "http",
      "url": "http://localhost:666/mcp"
    }
  }
}
```

Most agents auto-detect this file. If your agent requires manual configuration, point it to `http://localhost:666/mcp`.

## Available Tools

| Tool | Function | Intrusive |
|------|----------|-----------|
| `nmap_scan` | Port scanning, version/OS detection, NSE scripts | No |
| `gobuster_scan` | Directory, DNS, and vhost enumeration | No |
| `dirb_scan` | Web content discovery | No |
| `nikto_scan` | Web server vulnerability scanning | No |
| `wpscan_analyze` | WordPress vulnerability scanning | No |
| `enum4linux_scan` | Windows/Samba enumeration | No |
| `sqlmap_scan` | SQL injection detection and exploitation | **Yes** |
| `hydra_attack` | Password brute force | **Yes** |
| `john_crack` | Password hash cracking | **Yes** |
| `metasploit_run` | Metasploit module execution | **Yes** |
| `execute_command` | Arbitrary command on the Kali container | Depends |

## Claude Code Slash Commands

These commands are exclusive to Claude Code and leverage the parallel sub-agent architecture:

### Orchestrators (launch parallel sub-agents)

| Command | Description |
|---------|-------------|
| `/audit <target>` | Full audit: discover ports, launch one agent per service, consolidated report |
| `/pentest <target>` | Full pentest in 5 phases with scope-based authorization |
| `/network-discovery <range>` | Discover hosts on the network, launch one agent per host |

### Standalone

| Command | Description |
|---------|-------------|
| `/recon <target>` | Passive reconnaissance (nmap + gobuster + nikto) |
| `/vuln-scan <target>` | Vulnerability identification with nmap scripts |
| `/web-audit <url>` | Web application audit |
| `/wp-audit <url>` | WordPress audit |
| `/brute <target> <service>` | Brute force with hydra/john |
| `/exploit <target> <vuln>` | Exploit a specific vulnerability |

## Authorization Policy

Intrusive tools (sqlmap, hydra, john, metasploit) **always require user confirmation** before execution. This is enforced in both `AGENTS.md` and `CLAUDE.md`.

When requesting a full audit, the agent asks for the engagement scope:

1. **Passive only** — Reconnaissance and vulnerability identification
2. **Passive + Credential testing** — Adds brute force with small wordlists
3. **Full audit** — Includes sqlmap, metasploit, and all intrusive tests

## Audit Workflow (Claude Code with sub-agents)

```
/audit 10.10.10.5
        |
        v
   Phase 1: nmap -sV -sC -O
        |
        v
   Displays ports and services
        |
        v
   Asks for authorization level
        |
        v
   Phase 2: Launches sub-agents in parallel
        |
        |-- Agent HTTP :80   -> nikto + gobuster + dirb + wpscan + sqlmap*
        |-- Agent SSH :22    -> ssh scripts + hydra*
        |-- Agent SMB :445   -> enum4linux + smb-vuln scripts
        |-- Agent MySQL :3306 -> mysql scripts + hydra*
        |-- Agent FTP :21    -> ftp scripts + hydra*
        '-- ... (1 agent per port)
        |
        v                        (* depending on authorization)
   Phase 3: Consolidated report
        |
        |-- Executive summary
        |-- Findings by severity (Critical/High/Medium/Low)
        |-- Port-by-port summary
        |-- Chained attack paths
        '-- Prioritized remediation roadmap
```

> With other agents (Gemini CLI, OpenCode, etc.) the workflow is identical but sequential: the agent audits each service one after another following the same methodology from `AGENTS.md`.

## Supported Services

Each service has an audit playbook defined in `AGENTS.md`:

| Service | Ports | Tools |
|---------|-------|-------|
| HTTP/HTTPS | 80, 443, 8080, 8443 | nikto, gobuster, dirb, wpscan, sqlmap |
| SSH | 22 | nmap ssh-scripts, hydra |
| FTP | 21 | nmap ftp-scripts, hydra |
| SMB/NetBIOS | 139, 445 | enum4linux, nmap smb-scripts |
| MySQL | 3306 | nmap mysql-scripts, hydra |
| PostgreSQL | 5432 | nmap pgsql-scripts, hydra |
| MSSQL | 1433 | nmap ms-sql-scripts, hydra |
| SMTP | 25, 465, 587 | nmap smtp-scripts |
| DNS | 53 | nmap dns-scripts, dig |
| RDP | 3389 | nmap rdp-scripts, hydra |
| SNMP | 161 | nmap snmp-scripts |
| LDAP | 389, 636 | nmap ldap-scripts |
| Generic | any other | nmap --script safe, banner grab |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `init.sh` hangs at "Waiting for MCP server" | Check Docker is running: `docker ps`. Inspect logs: `docker logs kali-mcp`. |
| Agent can't connect to MCP | Verify the container is up: `curl http://localhost:666/mcp`. Restart with `./init.sh`. |
| Port 666 already in use | Change the host port in `docker/compose.yml` (`"<new-port>:8000"`) and update `.mcp.json` accordingly. |
| Image build fails | Ensure you have internet access. Kali repos may be temporarily unavailable — retry after a few minutes. |
| Tools timeout on large scans | Some scans (full nmap, sqlmap) can take minutes. The container does not have resource limits by default — add them in `compose.yml` if needed. |

## Disclaimer

> **WARNING**: This toolkit is intended **exclusively** for authorized security testing. Misuse of these tools may violate local, national, and international laws.

**You must ensure that:**

- You have **explicit written authorization** from the system owner before testing any target.
- You are operating within the **agreed scope** of the engagement.
- You understand that intrusive tools (sqlmap, hydra, metasploit) **can disrupt services**, corrupt data, or trigger security alerts.

**Acceptable use cases:**

- Penetration testing engagements with a signed agreement
- CTF (Capture The Flag) competitions
- Lab environments (HackTheBox, TryHackMe, VulnHub, personal labs)
- Defensive security research

**The authors of this project assume no liability for damages caused by misuse of this toolkit. You are solely responsible for your actions.**

## License

This project is provided as-is for educational and authorized security testing purposes. See individual tool licenses (nmap, sqlmap, metasploit, etc.) for their respective terms.
