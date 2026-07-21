---
type: Audit Playbook
title: HTTP/HTTPS audit playbook
description: Tools and steps for auditing a web service, including WordPress detection.
tags: [http, https, web, port-80, port-443, port-8080, port-8443]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 80, 443, 8080, 8443, or any service identified as http/https.

# Tools used

[nikto](../tools/index.md), [gobuster](../tools/gobuster.md), dirb, wpscan (if WordPress), sqlmap (if authorized), nmap (SSL scripts).

# Steps

1. `nikto -h <url>` against the URL.
2. `gobuster dir -u <url> -w <wordlist> -t 30 -q` for directory enumeration.
3. `dirb <url>` for additional content discovery.
4. Check for common files: `robots.txt`, `sitemap.xml`, `.git/`, `.env`, `wp-login.php`, `/admin`, `/api`.
5. If WordPress detected (`wp-content`, `wp-admin`, `wp-login.php` in any result): `wpscan --url <url> --enumerate vp,vt,u --no-banner`.
6. For any discovered URL parameters, if authorized: `sqlmap -u "<url>" --batch --level=2 --risk=2`.
7. For HTTPS: `nmap -Pn <target> --script ssl-enum-ciphers,ssl-heartbleed`.
