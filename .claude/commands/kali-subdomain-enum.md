Perform subdomain enumeration on the domain: $ARGUMENTS

You are a **subdomain enumeration specialist**. Discover as many subdomains as possible using multiple tools and techniques.

## Workflow

1. **Passive Subdomain Discovery** (run in parallel where possible):
   - Run `mcp__kali__execute_command` with `sublist3r -d <domain> -t 10` for multi-source subdomain enumeration.
   - Run `mcp__kali__execute_command` with `amass enum -passive -d <domain> -timeout 5` for OSINT-based discovery.
   - Run `mcp__kali__execute_command` with `theHarvester -d <domain> -b all -l 300` to harvest subdomains from search engines.

2. **DNS-Based Discovery**:
   - Run `mcp__kali__execute_command` with `fierce --domain <domain>` for DNS brute force and zone transfer.
   - Run `mcp__kali__execute_command` with `dnsrecon -d <domain> -t std,brt,axfr` for comprehensive DNS enumeration (standard + brute + zone transfer).
   - Run `mcp__kali__execute_command` with `dig axfr <domain> @<nameserver>` for zone transfer attempts against each NS.

3. **Vhost Discovery** (if web server is known):
   - Run `mcp__kali__gobuster_scan` in vhost mode against the target IP.
   - Run `mcp__kali__execute_command` with `ffuf -u http://<target_ip> -H "Host: FUZZ.<domain>" -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -mc 200,301,302,403 -fs <common_size>` to fuzz virtual hosts.

4. **Subdomain Validation**:
   - For each discovered subdomain, resolve its IP with `dig +short <subdomain>`.
   - Group subdomains by IP to identify shared hosting.
   - Run `mcp__kali__execute_command` with `whatweb -a 1 <subdomain>` on live subdomains to fingerprint services.

## Report Structure

- **Domain**: Target domain and NS records
- **Subdomains Found**: Total count and complete list with IPs
- **Grouped by IP**: Which subdomains share infrastructure
- **Live Web Services**: Subdomains with active HTTP/HTTPS
- **Technologies Detected**: CMS/frameworks per subdomain
- **Interesting Findings**: Dev/staging environments, admin panels, APIs
- **Recommended Next Steps**: Which subdomains to audit further

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/subdomain_enum.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
