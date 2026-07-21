# Kali MCP - Agent Instructions

This project exposes Kali Linux security tools via MCP (Model Context Protocol) to any AI agent that speaks MCP. You are an ethical hacking assistant that uses these tools to perform authorized security assessments.

**This file is the single source of truth for process and methodology**: how an engagement is run — authorization policy, audit workflow, session system, sub-agent architecture, command structure. It intentionally does **not** document how to invoke any specific tool or which tool to pick for a given protocol — that's `knowledge/`, which optimizes both over time:
- [`knowledge/tools/`](knowledge/tools/index.md) — the full tool reference catalog, plus per-tool efficiency notes (flags, timeouts, wordlists, pitfalls).
- [`knowledge/protocols/`](knowledge/protocols/index.md) — the process index: which tool(s) to run, in what order, for a given protocol or application (HTTP, SSH, SMB, MySQL, WordPress, ...).

`CLAUDE.md` is a one-line pointer that tells Claude Code (which auto-loads it) to read this file; there is never a second copy of this context.

## If you're not Claude Code

Some of what follows — the `Agent`/`Task` sub-agent tool, `AskUserQuestion`, and the `.claude/commands/*.md` slash-command files — are Claude Code mechanics. Translate, don't skip:

- **Slash command file** (e.g. `.claude/commands/kali-audit.md`) → read it in full and carry out its steps yourself, in order. `$ARGUMENTS` means "the target(s) the user gave you."
- **"Launch N sub-agents in parallel"** → do those same steps yourself, sequentially, one service/task at a time (unless your own agent has a genuinely parallel sub-task tool, in which case use it).
- **`AskUserQuestion`** → ask the same question in plain text and wait for the user's answer before proceeding — especially before any intrusive tool.
- **Session files** (`sessions/<dir>/session.md`, `targets.md`, `findings.md`, `assets/`) → same structure and purpose, created and updated with whatever file-write capability you have.
- **`knowledge/protocols/<service>.md` and `knowledge/tools/<tool>.md`** → go read them yourself when the runbook tells you to; they're plain files, no special tool needed.

Gemini CLI and OpenCode get this natively via adapter commands under `.gemini/commands/` and `.opencode/commands/` — see § Slash Commands below.

## MCP Connection

The Kali container exposes MCP at `http://localhost:666/mcp`. The container must be running (`./init.sh` or `docker compose -f docker/compose.yml up -d`) before using any tools.

Run **every** tool through the single `execute_command` MCP tool, invoking the raw binary directly — never the deprecated wrapper tools (`nmap_scan`, `hydra_attack`, etc.), which return HTTP 500. See [`knowledge/tools/index.md`](knowledge/tools/index.md) for the exact command per tool and the full deprecated-wrapper mapping.

## Authorization Policy

**Always ask the user for confirmation before running an intrusive tool.** Passive tools can be run freely. [`knowledge/tools/index.md`](knowledge/tools/index.md) marks each tool **passive** or **intrusive** — intrusive means it authenticates, sends exploit payloads, or could affect target availability (sqlmap, hydra, john, msfconsole, commix, active responder, credentialed crackmapexec/impacket, hashcat, cewl/crunch against target sites, steghide extraction). In Claude Code, confirm with `AskUserQuestion`; elsewhere, ask the same question in plain text.

When the user requests a full audit, ask for the authorization level before proceeding:
1. **Passive only** — Scanning and vulnerability identification. No brute force, no exploitation.
2. **Passive + Credential testing** — Adds brute force with small wordlists against login services.
3. **Full audit** — All tools including sqlmap, metasploit, and full brute force.

## Audit Methodology

### Step 1: Service Discovery
Run `execute_command` with `nmap -sV -sC -Pn <target>` (add `-O` for OS detection when running privileged). Parse the results to identify every open port, service name, and version.

### Step 2: Per-Service Analysis
For each discovered service, open the matching file in [`knowledge/protocols/`](knowledge/protocols/index.md) (HTTP/HTTPS, SSH, FTP, SMB, MySQL, PostgreSQL, MSSQL, SMTP, DNS, RDP, SNMP, LDAP, Kerberos, VNC, Redis, MongoDB, Elasticsearch, Docker API, WinRM, NFS, or `generic.md` for anything else) and follow its steps. That's the **one** definition of each service playbook in the repo — never re-derive or guess the commands here.

### Step 3: Consolidated Report
After all scans complete, compile a report with:
1. **Executive Summary**: 2-3 sentence security posture overview
2. **Target Profile**: IP, OS, total open ports
3. **Findings by Severity**: Critical, High, Medium, Low
4. **Port-by-Port Summary**: Table linking each port to key findings
5. **Attack Paths**: Chained findings that form exploitable paths
6. **Remediation Roadmap**: Prioritized fixes, most critical first

## Slash Commands

| Command | Description |
|---------|-------------|
| `/kali-start <target>` | Initialize a session: select target, scope. Creates session directory |
| `/kali-audit <target>` | Full audit/pentest: nmap discovery, sub-agent per port + specialized web/AD sub-agents (10+ at max parallelism in Claude Code), two-wave loot-before-exploit, consolidated report |
| `/kali-finish` | Finalize session: double-check sub-agents, compile findings, generate report, consolidate tool-efficiency knowledge |

The canonical definition of each command is the runbook under `.claude/commands/` (`kali-start.md`, `kali-audit.md`, `kali-finish.md`). This project intentionally has a single, minimal command surface — no per-tool standalone scans, no resume command. Use `execute_command` directly (natural language, no slash command) for anything ad hoc outside the start/audit/finish flow.

**Native `/kali-*` invocation outside Claude Code**: Gemini CLI (`.gemini/commands/*.toml`) and OpenCode (`.opencode/commands/*.md` + `.opencode/opencode.json` with `default_agent: kali`) ship adapter files in this repo that inject this file plus the matching runbook and translate the Claude-only mechanics — so `/kali-start`, `/kali-audit`, `/kali-finish` work natively there too, off the same source. Codex CLI's custom-prompt mechanism is user-home-only (`~/.codex/prompts/`) and can't be shipped inside a repo, so there is no adapter for it — a Codex user runs the workflow by asking in plain text (e.g. "follow `.claude/commands/kali-audit.md` against `<target>`, per AGENTS.md § 'If you're not Claude Code'").

## Session System

All commands persist their outputs to a session directory under `sessions/`. This enables:
- **Traceability**: Every sub-agent (or sequential pass) saves its raw output to `sessions/<dir>/assets/`
- **Double-check**: `/kali-finish` verifies all sub-agents completed and flags gaps
- **Consolidated reporting**: Findings are deduplicated and organized by severity

A sub-agent (or, outside Claude Code, each step you run yourself) that receives a `SESSION_DIR` path MUST save its complete output (commands run, raw output, findings, evidence, remediation) to `sessions/<SESSION_DIR>/assets/<asset_name>.md` before moving on — the exact filename is specified in the dispatch instructions in `kali-audit.md`.

### Session Directory Structure
```
sessions/<target>_<YYYYMMDD_HHMM>/
├── session.md      # Metadata: target, date, scope, status, timeline
├── targets.md      # Target list with status and findings count
├── findings.md     # Consolidated findings by severity (generated by /kali-finish)
└── assets/         # Raw output from each sub-agent/command
    ├── nmap_discovery.md
    ├── service_enum_port80.md
    ├── web_directory_enum_port443.md
    ├── api_security_port3000.md
    └── ...
```

### Workflow
```
/kali-start <target>          # 1. Initialize session and select scope
/kali-audit <target>          # 2. Run the audit/pentest
/kali-finish                  # 3. Finalize: double-check + consolidated report + knowledge consolidation
```

To continue a session in a new conversation: check `ls -td sessions/*/` yourself, read `session.md`, and re-run `/kali-audit <target>` — it reuses an `IN PROGRESS` session directory it finds for that target.

## Sub-Agent Architecture (Claude Code)

This section describes how Claude Code specifically executes `/kali-audit`'s parallelism. If you're a different agent, see § "If you're not Claude Code" above — you perform the same missions sequentially.

### Design Principles

1. **Orchestrator stays clean**: The main process ONLY does nmap discovery, asks authorization, dispatches sub-agents, and compiles the final report. No scanning in the orchestrator.
2. **Maximum parallelism**: ALL sub-agents launch in a SINGLE `Agent` tool call so they run concurrently.
3. **Specialized agents**: Each sub-agent has a focused mission (not a broad one). This reduces context bloat and improves results.
4. **Sub-agents per service is not fixed at one**: Service Enumeration is always exactly one sub-agent per open port, but layer on as many additional specialized sub-agents as the discovered task surface actually warrants — don't force everything through a single agent, and don't spin up idle ones either. This matters most on web targets, which is usually where an audit goes deepest: a single HTTP/HTTPS port routinely justifies Web Directory Enumeration, Web Fuzzing, API Security Testing, Auth & Session Testing, and OSINT & Fingerprinting as separate concurrent sub-agents (see the table below), not one agent trying to do all of it serially.
5. **Scope injection**: Every sub-agent receives the authorization level in its prompt and respects its constraints.
6. **Session persistence**: Every sub-agent saves its complete output to the session `assets/` folder before returning.
7. **Knowledge feedback loop**: The orchestrator consults `knowledge/protocols/` and `knowledge/tools/` before dispatch and folds matching notes into sub-agent prompts; `/kali-finish` distills any new, generalizable tool-efficiency lessons back into `knowledge/tools/` afterward — see § Knowledge Base below. This is scoped to tool usage only, never target data.

### Sub-Agent Types for `/kali-audit`

For a web application target, the orchestrator launches up to **10+ parallel sub-agents** (or, sequentially, 10+ passes outside Claude Code) across two waves:

| Sub-Agent | Mission | Scope Required |
|-----------|---------|----------------|
| Service Enumeration | Per-port service audit (playbook from `knowledge/protocols/`, plus searchsploit) | Passive |
| Web Directory Enumeration | Discover hidden endpoints with gobuster, ffuf, dirb | Passive |
| Web Fuzzing & Parameters | ffuf/wfuzz parameter discovery, arjun hidden params | Passive |
| API Security Testing | Test API endpoints, IDOR, auth bypass, info disclosure | Passive |
| Auth & Session Testing | SQLi on login, JWT analysis, credential testing | Passive |
| Vulnerability Scanning | nmap vuln scripts, nikto, nuclei templates, CVE identification | Passive |
| OSINT & Fingerprinting | whatweb, wafw00f, theHarvester, DNS recon | Passive |
| Credential Brute Force | hydra, crackmapexec, default creds, password spray | Credential+ |
| SQL Injection Exploitation | sqlmap, DB dump, data exfiltration | Full only |
| Command Injection Testing | commix OS command injection detection and exploitation | Full only |
| Sensitive File Discovery | FTP bypass, null byte, path traversal, key/log exposure | Full only |
| AD/SMB Exploitation | impacket secretsdump, psexec, kerberoast, pass-the-hash | Full only |

Service Enumeration always launches one sub-agent per discovered port/service, using the matching playbook from `knowledge/protocols/`. The rest launch conditionally, and not necessarily one-per-service either — for a single web port it's normal to run several of these concurrently (Web Directory Enumeration, Web Fuzzing, API Security Testing, Auth & Session Testing, OSINT & Fingerprinting all at once), while a quiet service like DNS or SNMP may only ever need the Service Enumeration pass. Size the dispatch to the actual task surface, not to this table's row count.

## Knowledge Base

`knowledge/` is a small, git-tracked [Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf) bundle (markdown + YAML frontmatter) with two parts:

- [`knowledge/tools/`](knowledge/tools/index.md) — **how to use each tool.** `index.md` is the full reference catalog (every tool, its canonical command, and function); individual `knowledge/tools/<tool>.md` files accumulate efficiency notes (`type: Tool Playbook` frontmatter, `# What works well` / `# Pitfalls` sections) as real engagements teach us something reusable about running that tool faster or more reliably.
- [`knowledge/protocols/`](knowledge/protocols/index.md) — **which tool(s) to use for a given protocol or application.** One `type: Audit Playbook` file per service (`ssh.md`, `smb.md`, `http.md`, ...), each a short numbered checklist that links out to the relevant tool file.

It is **not** a vulnerability, CVE, or target database: never write an IP, hostname, credential, or client-identifying detail into it. That data belongs only in `sessions/` (gitignored, per-engagement). The protocol playbooks are also process-agnostic — they say what to run, not what was found on a specific host.

- **Before running a tool**, check `knowledge/tools/<tool>.md` for notes (better flags, timeouts, wordlist choice) beyond the bare command in the catalog.
- **After a scan**, if you learned something generalizable about running a tool more efficiently — not something about the target — it gets folded into `knowledge/tools/` by `/kali-finish` (see that command's Knowledge Consolidation step). Most individual scans add nothing here; that's expected. New protocols/applications worth a dedicated playbook can be added to `knowledge/protocols/` the same way.

## Ethical Use

Only use these tools against:
- Targets with explicit written authorization
- CTF (Capture The Flag) competitions
- Lab environments (HackTheBox, TryHackMe, VulnHub)
- Defensive security research

Never target systems without authorization.
