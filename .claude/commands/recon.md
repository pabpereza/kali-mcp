Perform full reconnaissance on the target: $ARGUMENTS

This is a **passive reconnaissance** skill. It does NOT perform brute force, exploitation, or any action that could affect service availability.

Follow this workflow step by step:

1. **Port Scan**: Run nmap_scan with version detection (-sV) and default scripts (-sC) on the target.
2. **Service Analysis**: Analyze the nmap results. Build a table of every open port with service name and version.
3. **Web Technology Fingerprinting**: Run `execute_command` with `whatweb -a 3 <target>` to identify web technologies, CMS, frameworks.
4. **WAF Detection**: Run `execute_command` with `wafw00f <target>` to detect WAF/IPS.
5. **Web Discovery**: If HTTP/HTTPS services are found, run gobuster_scan and `execute_command` with `ffuf -u <url>/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -t 40` for fast directory fuzzing.
6. **Web Server Scan**: For each web service, run nikto_scan to identify misconfigurations and known vulnerabilities.
7. **Nuclei Scan**: Run `execute_command` with `nuclei -u <url> -severity critical,high -c 20` for template-based vulnerability detection.
8. **SMB Enumeration**: If SMB/NetBIOS ports are found (139, 445), run enum4linux_scan and `execute_command` with `crackmapexec smb <target> --shares`.
9. **SSL/TLS Check**: For HTTPS services, run nmap_scan with --script ssl-enum-ciphers,ssl-heartbleed.
10. **Exploit Research**: For each service/version found, run `execute_command` with `searchsploit <service> <version>` to check for known exploits.

After completing all scans, provide a structured summary with:
- **Target overview**: IP, hostname, OS detection if available
- **Open ports and services**: Table with port, service, version
- **Potential attack vectors**: Prioritized list of findings ranked by severity
- **Recommended next steps**: Suggested follow-up actions for each finding

To run a deeper audit with brute force and exploitation, use `/project:audit` instead.

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all scan outputs to `sessions/<SESSION_DIR>/assets/recon_<tool_name>.md`
4. Write the structured summary to `sessions/<SESSION_DIR>/findings.md`
5. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
