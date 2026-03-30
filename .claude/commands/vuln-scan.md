Perform a comprehensive vulnerability scan on the target: $ARGUMENTS

This is a **passive vulnerability identification** skill. It uses nmap scripts and nikto to detect vulnerabilities without exploiting them.

## Workflow

1. **Service Discovery**: Run nmap_scan with version detection (-sV) and default scripts (-sC).
2. **Vulnerability Scripts**: Run nmap_scan with `--script vuln` against discovered open ports.
3. **Nuclei Template Scanning**: For web services, run `execute_command` with `nuclei -u <url> -severity critical,high,medium -c 25` for CVE and misconfiguration detection.
4. **Web Vulnerabilities**: If web services detected, run nikto_scan.
5. **SMB Vulnerabilities**: If SMB detected, run enum4linux_scan, nmap_scan with `--script smb-vuln-*`, and `execute_command` with `crackmapexec smb <target>` for additional enumeration.
6. **SSL/TLS Analysis**: If HTTPS found, run nmap_scan with `--script ssl-enum-ciphers,ssl-heartbleed,ssl-poodle`.
7. **Exploit Research**: For each service/version, run `execute_command` with `searchsploit <service> <version>` to find known exploits in ExploitDB.
8. **WAF Detection**: For web services, run `execute_command` with `wafw00f <url>` to detect security controls.

Vulnerability report:
- **Executive Summary**: Brief security posture overview
- **Vulnerability Table**: CVE ID, description, severity, affected service/port
- **Critical Findings**: Detailed description of critical/high severity items
- **Remediation Plan**: Prioritized fix recommendations
- **Risk Rating**: Overall assessment (Critical/High/Medium/Low)

Note: This skill identifies but does NOT exploit vulnerabilities. For exploitation testing, use `/project:exploit` (requires explicit authorization).

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all scan outputs to `sessions/<SESSION_DIR>/assets/vulnscan_<tool_name>.md`
4. Write the vulnerability report to `sessions/<SESSION_DIR>/findings.md`
5. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
