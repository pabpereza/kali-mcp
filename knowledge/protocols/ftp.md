---
type: Audit Playbook
title: FTP audit playbook
description: Tools and steps for auditing an FTP service.
tags: [ftp, port-21]
timestamp: 2026-07-20T00:00:00Z
---

Port: 21, or any service identified as ftp.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, curl, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script ftp-anon,ftp-bounce,ftp-syst,ftp-vsftpd-backdoor,ftp-proftpd-backdoor`.
2. Check for anonymous login access.
3. Check the FTP version for known CVEs and backdoors.
4. If anonymous access is available, list files: `curl -s ftp://<target>/`.
5. If authorized: `hydra -L <users> -P <pass> -t 4 -f ftp://<target>` with common credentials.
