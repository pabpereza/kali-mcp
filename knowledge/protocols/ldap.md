---
type: Audit Playbook
title: LDAP audit playbook
description: Tools and steps for auditing an LDAP directory service.
tags: [ldap, active-directory, port-389, port-636]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 389, 636, or any service identified as ldap.

# Tools used

[nmap](../tools/nmap.md) NSE scripts.

# Steps

1. `nmap -Pn <target> --script ldap-rootdse,ldap-search,ldap-brute`.
2. Check for anonymous bind access.
3. Enumerate base DN and directory structure if accessible.
4. Check for LDAPS (secure) vs. plain LDAP.
