Perform a comprehensive vulnerability scan on the target: $ARGUMENTS

This is a **passive vulnerability identification** skill. It uses nmap scripts and nikto to detect vulnerabilities without exploiting them.

## Workflow

1. **Service Discovery**: Run nmap_scan with version detection (-sV) and default scripts (-sC).
2. **Vulnerability Scripts**: Run nmap_scan with `--script vuln` against discovered open ports.
3. **Web Vulnerabilities**: If web services detected, run nikto_scan.
4. **SMB Vulnerabilities**: If SMB detected, run enum4linux_scan and nmap_scan with `--script smb-vuln-*`.
5. **SSL/TLS Analysis**: If HTTPS found, run nmap_scan with `--script ssl-enum-ciphers,ssl-heartbleed,ssl-poodle`.

Vulnerability report:
- **Executive Summary**: Brief security posture overview
- **Vulnerability Table**: CVE ID, description, severity, affected service/port
- **Critical Findings**: Detailed description of critical/high severity items
- **Remediation Plan**: Prioritized fix recommendations
- **Risk Rating**: Overall assessment (Critical/High/Medium/Low)

Note: This skill identifies but does NOT exploit vulnerabilities. For exploitation testing, use `/project:exploit` (requires explicit authorization).
