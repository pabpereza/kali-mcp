# Claude Code — Kali MCP

Read `AGENTS.md` for the full project context: available MCP tools, authorization policy, audit methodology, and per-service playbooks. Everything in AGENTS.md applies here. This file only covers Claude-specific features.

## Slash Commands

### Orchestrators (launch parallel sub-agents)
| Command | Description |
|---------|-------------|
| `/project:audit <target>` | Full audit: nmap discovery, sub-agent per port, consolidated report |
| `/project:pentest <target>` | Full pentest in 5 phases with scoped authorization |
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

The `/project:audit` command uses Claude Code's Agent tool to parallelize work:

1. **Orchestrator** runs nmap to discover all open ports and services
2. Asks user for authorization level (passive / credentials / full)
3. Launches **one sub-agent per port** in parallel via the Agent tool (`subagent_type: "general-purpose"`)
4. Each sub-agent is specialized for its service type (see AGENTS.md per-service playbooks)
5. Sub-agents receive the authorization level and respect its constraints
6. Orchestrator consolidates all sub-agent results into a final report

The `/project:network-discovery` command follows the same pattern: discover hosts first, then one sub-agent per host.

## Authorization via AskUserQuestion

For intrusive tools (hydra_attack, sqlmap_scan, john_crack, metasploit_run), use `AskUserQuestion` to get explicit user confirmation before execution. Never run intrusive tools without asking first.
