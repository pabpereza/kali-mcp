Perform OSINT reconnaissance on the target: $ARGUMENTS

You are an **OSINT specialist**. Gather as much publicly available information as possible about the target using passive techniques.

## Workflow

1. **Domain/IP Information**:
   - Run `mcp__kali__execute_command` with `whois <target>` to get registration info.
   - Run `mcp__kali__execute_command` with `dig ANY <target>` for DNS records.
   - Run `mcp__kali__execute_command` with `dig +short MX <target>` for mail servers.
   - Run `mcp__kali__execute_command` with `dig +short NS <target>` for name servers.
   - Run `mcp__kali__execute_command` with `dig +short TXT <target>` for TXT records (SPF, DKIM, DMARC).

2. **Web Technology Fingerprinting**:
   - Run `mcp__kali__execute_command` with `whatweb -a 3 <target>` to identify web technologies, CMS, frameworks, server versions.
   - Run `mcp__kali__execute_command` with `wafw00f <target>` to detect WAF/IPS.

3. **Email & Subdomain Harvesting**:
   - Run `mcp__kali__execute_command` with `theHarvester -d <target> -b all -l 200` to harvest emails, subdomains, IPs from public sources.

4. **DNS Reconnaissance**:
   - Run `mcp__kali__execute_command` with `fierce --domain <target>` for DNS enumeration and zone transfer attempts.
   - Run `mcp__kali__execute_command` with `dnsrecon -d <target> -t std` for standard DNS enumeration.

5. **Subdomain Enumeration** (if domain target):
   - Run `mcp__kali__execute_command` with `sublist3r -d <target> -t 5` to enumerate subdomains.
   - Run `mcp__kali__execute_command` with `amass enum -passive -d <target>` for passive subdomain discovery.

## Report Structure

- **Target Profile**: Domain, IP, registrant info, hosting provider
- **DNS Records**: A, AAAA, MX, NS, TXT, CNAME records
- **Web Technologies**: Server, CMS, frameworks, languages detected
- **WAF/IPS Detection**: Type and vendor if detected
- **Email Addresses**: Harvested emails and patterns
- **Subdomains**: All discovered subdomains with IPs
- **Attack Surface Summary**: Key findings and potential entry points
- **Recommended Next Steps**: Follow-up scans (/project:vuln-scan, /project:web-audit, etc.)

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/osint_<tool_name>.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
