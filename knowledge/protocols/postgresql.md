---
type: Audit Playbook
title: PostgreSQL audit playbook
description: Tools and steps for auditing a PostgreSQL service.
tags: [postgresql, database, port-5432]
timestamp: 2026-07-20T00:00:00Z
---

Port: 5432, or any service identified as postgresql.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script pgsql-brute`.
2. Check PostgreSQL version for known CVEs.
3. Check if the service accepts connections without SSL.
4. If authorized: `hydra -L <users> -P <pass> -t 4 -f postgres://<target>` with users postgres, admin.
