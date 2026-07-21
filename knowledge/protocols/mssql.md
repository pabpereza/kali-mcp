---
type: Audit Playbook
title: MSSQL audit playbook
description: Tools and steps for auditing a Microsoft SQL Server service.
tags: [mssql, database, port-1433]
timestamp: 2026-07-20T00:00:00Z
---

Port: 1433, or any service identified as ms-sql.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, [hydra](../tools/hydra.md) (ask first).

# Steps

1. `nmap -Pn <target> --script ms-sql-info,ms-sql-empty-password,ms-sql-ntlm-info,ms-sql-brute`.
2. Check for a default SA account with empty/common passwords.
3. Check MSSQL version for known CVEs.
4. If authorized: `hydra -L <users> -P <pass> -t 4 -f mssql://<target>`.
