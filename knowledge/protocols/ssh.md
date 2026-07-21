---
type: Audit Playbook
title: SSH audit playbook
description: Tools and steps for auditing an SSH service.
tags: [ssh, port-22]
timestamp: 2026-07-20T00:00:00Z
---

Port: 22, or any service identified as ssh.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos`.
2. Check for weak algorithms (CBC ciphers, SHA1 MACs, weak key exchange).
3. Check the SSH version for known CVEs (e.g. regreSSHion CVE-2024-6387, OpenSSH < 8.x).
4. Check for username enumeration (CVE-2018-15473, OpenSSH < 7.7).
5. If authorized: `hydra -L <users> -P <pass> -t 4 -f ssh://<target>` with a small wordlist, username "root" first.
