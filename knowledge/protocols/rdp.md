---
type: Audit Playbook
title: RDP audit playbook
description: Tools and steps for auditing a Windows Remote Desktop service.
tags: [rdp, windows, port-3389]
timestamp: 2026-07-20T00:00:00Z
---

Port: 3389, or any service identified as ms-wbt-server/rdp.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script rdp-enum-encryption,rdp-vuln-ms12-020,rdp-ntlm-info`.
2. Check for BlueKeep (CVE-2019-0708).
3. Check for MS12-020.
4. Check NLA (Network Level Authentication) status.
5. If authorized: `hydra -L <users> -P <pass> -t 4 -f rdp://<target>` with common credentials.
