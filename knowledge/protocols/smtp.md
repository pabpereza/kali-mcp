---
type: Audit Playbook
title: SMTP audit playbook
description: Tools and steps for auditing an SMTP mail service.
tags: [smtp, mail, port-25, port-465, port-587]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 25, 465, 587, or any service identified as smtp.

# Tools used

[nmap](../tools/nmap.md) NSE scripts.

# Steps

1. `nmap -Pn <target> --script smtp-commands,smtp-enum-users,smtp-open-relay,smtp-vuln-cve2010-4344,smtp-vuln-cve2011-1720`.
2. Check for open relay configuration.
3. Attempt user enumeration via VRFY/EXPN/RCPT TO.
4. Check SMTP version for known CVEs.
