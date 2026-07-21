---
type: Audit Playbook
title: VNC audit playbook
description: Tools and steps for auditing a VNC remote-access service.
tags: [vnc, port-5900]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 5900-5910.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script vnc-info,vnc-brute,realvnc-auth-bypass`.
2. If authorized: `hydra -L <users> -P <pass> -t 4 -f vnc://<target>`.
