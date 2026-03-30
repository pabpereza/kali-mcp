Perform a web application security audit on the target: $ARGUMENTS

## Authorization Check

Before starting, use `AskUserQuestion` to ask the user:
**"Which checks do you want to include in the web audit?"** with options:
1. **Passive only** — Nikto, directory enumeration (gobuster/dirb), WPScan detection. No SQL injection testing.
2. **Full audit** — Includes sqlmap SQL injection testing on discovered parameters. This sends payloads that may affect the application.

## Workflow

1. **Web Server Fingerprinting**: Run nikto_scan against the target URL.
2. **Directory Enumeration**: Run gobuster_scan in dir mode to discover hidden directories and files.
3. **Content Discovery**: Run dirb_scan for additional content discovery.
4. **WordPress Detection**: If WordPress is detected, run wpscan_analyze.
5. **SQL Injection Testing** (FULL AUDIT only): For discovered pages with URL parameters, run sqlmap_scan. If authorization is passive, skip and note "Skipped - requires full audit authorization".

Report:
- **Target**: URL, web server, technologies detected
- **Discovered paths**: Table of directories/files with HTTP status codes
- **Vulnerabilities found**: Categorized by severity (Critical, High, Medium, Low, Info)
- **SQL Injection results**: Findings or "Skipped"
- **Recommendations**: Remediation steps for each vulnerability

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all scan outputs to `sessions/<SESSION_DIR>/assets/webaudit_<tool_name>.md`
4. Write the web audit report to `sessions/<SESSION_DIR>/findings.md`
5. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
