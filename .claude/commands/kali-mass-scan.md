Perform fast mass port scanning on the target range: $ARGUMENTS

You are a **mass scanning specialist**. Quickly discover open ports across large IP ranges using high-speed scanning techniques, then hand off to deeper analysis.

## Authorization Check

Before starting, use `AskUserQuestion` to ask:
**"Mass scanning generates significant network traffic and may trigger IDS/IPS alerts. Confirm authorization:"** with options:
1. **Yes, proceed with mass scan** — Full speed scanning authorized.
2. **Yes, but limit rate** — Scan at reduced speed (1000 packets/sec max).
3. **Cancel** — Do not proceed.

## Phase 1: Fast Port Discovery with masscan

1. **Top Ports Scan**:
   - Run `mcp__kali__execute_command` with `masscan <target_range> --top-ports 1000 --rate=5000 -oL /tmp/workspace/masscan_results.txt` for fast top-ports scan.
   - If rate-limited scope: use `--rate=1000` instead.

2. **Full Port Scan** (if target is single host or small range):
   - Run `mcp__kali__execute_command` with `masscan <target> -p 1-65535 --rate=5000 -oL /tmp/workspace/masscan_full.txt`

3. **UDP Top Ports**:
   - Run `mcp__kali__execute_command` with `masscan <target_range> -pU:53,67,68,69,123,161,162,500,514,520,1900,4500,5353 --rate=1000 -oL /tmp/workspace/masscan_udp.txt`

## Phase 2: Result Parsing

1. **Parse masscan output**:
   - Run `mcp__kali__execute_command` with `cat /tmp/workspace/masscan_results.txt | grep '^open' | sort -t ' ' -k 4,4 -k 3,3n` to organize by IP and port.
   - Build a table: IP → open ports.

2. **Unique Hosts**:
   - Run `mcp__kali__execute_command` with `cat /tmp/workspace/masscan_results.txt | grep '^open' | awk '{print $4}' | sort -u` to list unique hosts.

## Phase 3: Service Verification with nmap

For each discovered host (or top hosts if range is large):
1. Run `mcp__kali__nmap_scan` with `-sV -sC -p <discovered_ports> <host>` to verify services and get versions.
2. Only scan the ports that masscan found open (targeted, not full scan).

## Phase 4: ARP Scan (local network)

If the target is a local network range:
1. Run `mcp__kali__execute_command` with `arp-scan -l` or `arp-scan <range>` to discover live hosts via ARP.
2. Cross-reference with masscan results.

## Report Structure

- **Scan Parameters**: Target range, rate, ports scanned
- **Discovery Summary**: Total hosts found, total open ports
- **Host Inventory**: Table with IP, hostname (if resolved), open ports, OS guess
- **Port Statistics**: Most common open ports across the range
- **Service Map**: Grouped by service type (web servers, SSH, databases, etc.)
- **High-Value Targets**: Hosts with many open ports or critical services
- **Recommended Next Steps**: Which hosts to audit with /project:audit or /project:pentest

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/mass_scan.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
