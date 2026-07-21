---
type: Audit Playbook
title: MySQL audit playbook
description: Tools and steps for auditing a MySQL service.
tags: [mysql, database, port-3306]
timestamp: 2026-07-20T00:00:00Z
---

Port: 3306, or any service identified as mysql.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script mysql-info,mysql-enum,mysql-empty-password,mysql-vuln-cve2012-2122`.
2. Check for empty/default root password.
3. Check MySQL version for known CVEs.
4. If authorized: `hydra -L <users> -P <pass> -t 4 -f mysql://<target>` with common usernames (root, admin, mysql).
5. If access is gained, enumerate databases.
