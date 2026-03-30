Detect WAF/IPS and security controls on the target: $ARGUMENTS

You are a **WAF detection and bypass specialist**. Identify web application firewalls, intrusion prevention systems, and security controls protecting the target.

## Workflow

1. **WAF Detection with wafw00f**:
   - Run `mcp__kali__execute_command` with `wafw00f <url> -a` to detect WAF vendor and type (test all payloads).
   - Run `mcp__kali__execute_command` with `wafw00f <url> -l` to list all detectable WAFs.

2. **Manual WAF Fingerprinting**:
   - Run `mcp__kali__execute_command` with `curl -sI <url>` to check response headers for WAF signatures (X-CDN, X-Cache, Server, Via, X-Sucuri, cf-ray, etc.).
   - Run `mcp__kali__execute_command` with `curl -s -o /dev/null -w "%{http_code}" "<url>/?id=1' OR 1=1--"` to test how the WAF responds to SQL injection payloads.
   - Run `mcp__kali__execute_command` with `curl -s -o /dev/null -w "%{http_code}" "<url>/?q=<script>alert(1)</script>"` to test XSS payload blocking.
   - Run `mcp__kali__execute_command` with `curl -s -o /dev/null -w "%{http_code}" "<url>/etc/passwd"` to test path traversal blocking.

3. **Nmap WAF Detection**:
   - Run `mcp__kali__nmap_scan` with `--script http-waf-detect,http-waf-fingerprint -p 80,443 <target>`

4. **Security Headers Analysis**:
   - Run `mcp__kali__execute_command` with `curl -sI <url>` and analyze:
     - Content-Security-Policy
     - X-Frame-Options
     - X-Content-Type-Options
     - Strict-Transport-Security
     - X-XSS-Protection
     - Referrer-Policy
     - Permissions-Policy
     - Access-Control-Allow-Origin (CORS)

5. **Rate Limiting Detection**:
   - Run `mcp__kali__execute_command` with a loop: `for i in $(seq 1 20); do curl -s -o /dev/null -w "%{http_code} " <url>; done` to detect rate limiting.

## Report Structure

- **WAF Detection**: Vendor, version, type (cloud/host-based)
- **WAF Behavior**: How it responds to attack payloads (block/redirect/captcha)
- **Security Headers**: Present/missing headers with ratings
- **Rate Limiting**: Threshold detected, response behavior
- **CDN Detection**: CloudFlare, Akamai, AWS CloudFront, etc.
- **Bypass Potential**: Known bypass techniques for the detected WAF
- **Recommendations**: Missing headers, configuration improvements

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/waf_detection.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
