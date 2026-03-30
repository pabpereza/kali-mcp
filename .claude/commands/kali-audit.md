Perform a full security audit on the target: $ARGUMENTS

You are the **orchestrator**. Your job is to discover services and then launch specialized sub-agents in parallel for each discovered port/service.

## Phase 0: Session Management (orchestrator does this FIRST)

Before any scanning, set up the session workspace:

1. Check if a session directory already exists for this target:
   ```bash
   ls -td sessions/*/ 2>/dev/null | head -1
   ```
2. If a session exists and its `session.md` shows status `IN PROGRESS`, use that session directory.
3. If no session exists, create one:
   - Sanitize the target name (replace `/`, `:`, `.` with `_`)
   - Generate timestamp with `date +%Y%m%d_%H%M`
   - Create the directory: `mkdir -p sessions/<sanitized_target>_<timestamp>/assets`
   - Create `session.md` with target, date, type (Audit), status (IN PROGRESS)
   - Create `targets.md` with the target list
4. Store the session directory path as `SESSION_DIR` for all subsequent operations.

**All sub-agents MUST receive the `SESSION_DIR` path in their prompts.**

## Authorization Policy

Actions are classified in two tiers:

- **PASSIVE (no authorization needed)**: Port scanning, version detection, banner grabbing, directory enumeration, vulnerability identification via scripts, SSL/TLS analysis, information gathering. Sub-agents can run these freely.
- **INTRUSIVE (requires user authorization)**: Brute force attacks (hydra, john), SQL injection exploitation (sqlmap), Metasploit module execution, any action that sends payloads, attempts authentication, or could affect service availability.

Before Phase 2, after showing the port summary, use `AskUserQuestion` to ask the user:
**"Which audit depth do you want for this engagement?"** with these options:
1. **Passive only** — Reconnaissance and vulnerability identification only. No brute force, no exploitation, no SQLmap.
2. **Passive + Credential testing** — Adds brute force with small wordlists against discovered login services.
3. **Full audit** — Includes SQL injection testing, exploit verification, and all intrusive checks.

Then inject the chosen authorization level into every sub-agent prompt as:
```
AUTHORIZATION LEVEL: <chosen_level>
- If PASSIVE ONLY: Do NOT run hydra_attack, sqlmap_scan, metasploit_run, or any tool that attempts authentication or sends exploit payloads. Skip those steps and note them as "Skipped - requires intrusive authorization".
- If PASSIVE + CREDENTIAL TESTING: You MAY run hydra_attack with small wordlists. Do NOT run sqlmap_scan or metasploit_run.
- If FULL AUDIT: You MAY run all tools including hydra_attack, sqlmap_scan, and metasploit_run.
```

## Phase 1: Discovery (you do this yourself)

1. Run `nmap_scan` against the target with version detection (`-sV`), OS detection, and default scripts (`-sC`). Scan common ports unless the user specifies otherwise.
2. Parse the nmap results carefully. Build a list of every open port with its service name and version.
3. Print a summary table of discovered ports and services.
4. Ask the user for the authorization level (see Authorization Policy above).

## Phase 2: Parallel Sub-Agent Dispatch

Based on the discovered ports, launch **one sub-agent per port/service** using the `Agent` tool. Launch ALL sub-agents in a single message so they run in parallel. Use `subagent_type: "general-purpose"` for all of them.

Use the service classification below to build each sub-agent's prompt. Every sub-agent prompt MUST include:
- The target IP/hostname
- The specific port number
- The service name and version detected
- The detailed instructions from the matching category below
- **SESSION OUTPUT instruction**: `When you finish, use the Write tool to save your COMPLETE output (all commands run, raw output, and findings) to: sessions/<SESSION_DIR>/assets/audit_<service>_port<PORT>.md`

### Service Categories and Sub-Agent Prompts:

**HTTP/HTTPS** (ports 80, 443, 8080, 8443, 8000, 3000, or any service identified as http/https):
```
Audit the web service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nikto_scan against http(s)://<TARGET>:<PORT> to find web server vulnerabilities.
2. Run gobuster_scan in dir mode against http(s)://<TARGET>:<PORT> to enumerate directories and files.
3. Run dirb_scan against http(s)://<TARGET>:<PORT> for additional content discovery.
4. Check for common files: robots.txt, sitemap.xml, .git/, .env, wp-login.php, /admin, /api.
5. If WordPress is detected (wp-content, wp-admin, wp-login.php in any results), run wpscan_analyze.
6. For any discovered pages with URL parameters, run sqlmap_scan to test for SQL injection.
7. Check for SSL/TLS issues if HTTPS using: nmap_scan with --script ssl-enum-ciphers,ssl-heartbleed.
Provide a structured report with all findings, vulnerabilities categorized by severity, and remediation advice.
```

**SSH** (port 22 or any service identified as ssh):
```
Audit the SSH service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos.
2. Check for weak algorithms (CBC ciphers, SHA1 MACs, weak key exchange).
3. Check the SSH version for known CVEs (e.g., OpenSSH < 8.x vulnerabilities).
4. Attempt default credential check with hydra_attack using username "root" and a small common password list. Use password_file /usr/share/wordlists/nmap.lst or similar small list.
5. Check for username enumeration vulnerabilities (CVE-2018-15473 for OpenSSH < 7.7).
Provide a report with: version analysis, weak algorithms found, credential test results, CVEs applicable, and hardening recommendations.
```

**FTP** (port 21 or any service identified as ftp):
```
Audit the FTP service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script ftp-anon,ftp-bounce,ftp-syst,ftp-vsftpd-backdoor,ftp-proftpd-backdoor.
2. Check for anonymous login access.
3. Check the FTP version for known CVEs and backdoors.
4. If anonymous access is available, list accessible files using execute_command with: curl -s ftp://<TARGET>/
5. Attempt common credential brute force with hydra_attack using small common username/password lists.
Provide a report with: anonymous access status, version vulnerabilities, accessible files, credential test results, and recommendations.
```

**SMB/NetBIOS** (ports 139, 445 or any service identified as smb/microsoft-ds/netbios):
```
Audit the SMB service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run enum4linux_scan against <TARGET> for full SMB enumeration (shares, users, groups, policies).
2. Run nmap_scan with scripts: --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-security-mode,smb-vuln-ms17-010,smb-vuln-ms08-067.
3. Check for null session access.
4. Check for EternalBlue (MS17-010) and other critical SMB vulnerabilities.
5. List accessible shares and their permissions.
Provide a report with: shares found, users enumerated, null session status, vulnerabilities (especially MS17-010), and remediation steps.
```

**MySQL** (port 3306 or any service identified as mysql):
```
Audit the MySQL service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script mysql-info,mysql-enum,mysql-empty-password,mysql-vuln-cve2012-2122.
2. Check for empty/default root password.
3. Check MySQL version for known CVEs.
4. Attempt common credential test with hydra_attack for mysql service with common usernames (root, admin, mysql).
5. If access is gained, enumerate databases using execute_command.
Provide a report with: version info, authentication weaknesses, CVEs found, credential test results, and hardening recommendations.
```

**PostgreSQL** (port 5432 or any service identified as postgresql):
```
Audit the PostgreSQL service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script pgsql-brute.
2. Check PostgreSQL version for known CVEs.
3. Attempt default credential test with hydra_attack for postgres service (users: postgres, admin).
4. Check if the service accepts connections without SSL.
Provide a report with: version analysis, authentication test results, CVEs, and security recommendations.
```

**MSSQL** (port 1433 or any service identified as ms-sql):
```
Audit the MSSQL service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script ms-sql-info,ms-sql-empty-password,ms-sql-ntlm-info,ms-sql-brute.
2. Check for default SA account with empty/common passwords.
3. Check MSSQL version for known CVEs.
4. Attempt credential test with hydra_attack for mssql service.
Provide a report with: version info, authentication weaknesses, CVEs, and hardening steps.
```

**SMTP** (port 25, 465, 587 or any service identified as smtp):
```
Audit the SMTP service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720.
2. Check for open relay configuration.
3. Attempt user enumeration via VRFY/EXPN/RCPT TO.
4. Check SMTP version for known CVEs.
Provide a report with: supported commands, open relay status, enumerated users, CVEs, and recommendations.
```

**DNS** (port 53 or any service identified as dns/domain):
```
Audit the DNS service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script dns-zone-transfer,dns-recursion,dns-cache-snoop,dns-nsid.
2. Attempt zone transfer using execute_command: dig axfr @<TARGET> <domain> (if domain is known).
3. Check if recursion is enabled (open resolver).
4. Check DNS version for known CVEs.
Provide a report with: zone transfer results, recursion status, version info, and security recommendations.
```

**RDP** (port 3389 or any service identified as ms-wbt-server/rdp):
```
Audit the RDP service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script rdp-enum-encryption,rdp-vuln-ms12-020,rdp-ntlm-info.
2. Check for BlueKeep (CVE-2019-0708) vulnerability.
3. Check for MS12-020 vulnerability.
4. Check NLA (Network Level Authentication) status.
5. Attempt credential test with hydra_attack for rdp service with common credentials.
Provide a report with: encryption level, NLA status, vulnerabilities found (especially BlueKeep), and hardening steps.
```

**SNMP** (port 161 or any service identified as snmp):
```
Audit the SNMP service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> (UDP scan -sU) with scripts: --script snmp-info,snmp-brute,snmp-interfaces,snmp-processes,snmp-sysdescr.
2. Test default community strings (public, private, community).
3. Enumerate system information via SNMP if accessible.
Provide a report with: community strings found, system info exposed, and security recommendations.
```

**LDAP** (port 389, 636 or any service identified as ldap):
```
Audit the LDAP service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with scripts: --script ldap-rootdse,ldap-search,ldap-brute.
2. Check for anonymous bind access.
3. Enumerate base DN and directory structure if accessible.
4. Check for LDAPS (secure) vs plain LDAP.
Provide a report with: anonymous access status, directory info exposed, protocol security, and recommendations.
```

**Generic/Unknown Service** (any port not matching above categories):
```
Audit the service on <TARGET>:<PORT> (<SERVICE_VERSION>).
Use the Kali MCP tools to perform these steps:
1. Run nmap_scan against <TARGET> port <PORT> with version detection (-sV) and all safe scripts (--script safe).
2. Research the service version for known CVEs using execute_command with searchsploit if available.
3. Attempt banner grabbing using execute_command: nc -nv <TARGET> <PORT> or curl.
Provide a report with: service details, version analysis, any vulnerabilities found, and recommendations.
```

## Phase 3: Consolidation (you do this yourself, after all sub-agents finish)

Once ALL sub-agents have returned their results, compile a **final consolidated report**:

1. **Executive Summary**: 2-3 sentence overview of the target's security posture.
2. **Target Profile**: IP, OS, total open ports.
3. **Findings by Severity**:
   - CRITICAL: Exploitable vulnerabilities with available exploits
   - HIGH: Significant vulnerabilities or severe misconfigurations
   - MEDIUM: Moderate issues that should be addressed
   - LOW: Minor issues and informational findings
4. **Port-by-Port Summary**: Table linking each port to key findings from its sub-agent.
5. **Attack Paths**: If multiple findings can be chained together, describe the attack path.
6. **Remediation Roadmap**: Prioritized list of fixes, most critical first.

## Phase 4: Session Persistence (you do this after the report)

1. Save the nmap discovery output to `sessions/<SESSION_DIR>/assets/nmap_discovery.md`.
2. Write the final consolidated report to `sessions/<SESSION_DIR>/findings.md`.
3. Update `sessions/<SESSION_DIR>/targets.md` with findings count per target.
4. Update `sessions/<SESSION_DIR>/session.md`:
   - Add each sub-agent dispatched to the "Sub-Agents Dispatched" section
   - Add timeline entries for each phase completed
   - Keep status as `IN PROGRESS` (use `/project:finish` to finalize)
5. Print a summary of saved assets.
