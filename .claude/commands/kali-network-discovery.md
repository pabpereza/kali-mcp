Perform network discovery and host enumeration on the target range: $ARGUMENTS

The argument should be a network range (e.g., 192.168.1.0/24) or a single host.

This is a **passive discovery** skill. It does NOT perform brute force or exploitation.

## Session Management

Before any scanning, set up the session workspace:

1. Check if a session directory already exists:
   ```bash
   ls -td sessions/*/ 2>/dev/null | head -1
   ```
2. If a session exists and its `session.md` shows status `IN PROGRESS`, use that session directory.
3. If no session exists, create one:
   - Sanitize the target range (replace `/`, `:`, `.` with `_`)
   - Generate timestamp with `date +%Y%m%d_%H%M`
   - Create the directory: `mkdir -p sessions/<sanitized_target>_<timestamp>/assets`
   - Create `session.md` with target range, date, type (Network Discovery), status (IN PROGRESS)
   - Create `targets.md` with the target range
4. Store the session directory path as `SESSION_DIR`.

**All sub-agents MUST receive the `SESSION_DIR` path and save their outputs to `sessions/<SESSION_DIR>/assets/`.**

## Workflow

1. **Host Discovery**: Run nmap_scan with ping scan (-sn) to discover live hosts.
2. **Quick Port Scan**: For each live host, run a quick scan of top 100 ports using nmap_scan.
3. **OS Fingerprinting**: Run nmap_scan with OS detection (-O) against hosts with open ports.
4. **Service Enumeration**: For interesting hosts, run nmap_scan with version detection (-sV).
5. **Network Mapping**: Summarize topology and identify segments.

Use the Agent tool to launch parallel sub-agents for step 2-4 when multiple hosts are discovered, one agent per host.

Present results as a network map:
- **Live Hosts**: Table with IP, hostname, OS guess, open ports
- **Network Segments**: Identified subnets
- **Key Assets**: Servers, network devices, high-value targets
- **Attack Surface Summary**: Total exposed services
- **Recommended Targets**: Prioritized list for further testing with `/project:audit`

## Session Persistence

After presenting results:
1. Save the host discovery nmap output to `sessions/<SESSION_DIR>/assets/nmap_host_discovery.md`.
2. Save each per-host sub-agent output to `sessions/<SESSION_DIR>/assets/host_<IP_sanitized>.md`.
3. Write the network map summary to `sessions/<SESSION_DIR>/findings.md`.
4. Update `sessions/<SESSION_DIR>/session.md` with timeline and sub-agent list.
5. Print a summary of saved assets.
