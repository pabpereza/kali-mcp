---
type: Audit Playbook
title: SNMP audit playbook
description: Tools and steps for auditing an SNMP service.
tags: [snmp, port-161]
timestamp: 2026-07-20T00:00:00Z
---

Port: 161, or any service identified as snmp.

# Tools used

[nmap](../tools/nmap.md) NSE scripts (UDP).

# Steps

1. `nmap -Pn <target> -sU --script snmp-info,snmp-brute,snmp-interfaces,snmp-sysdescr`.
2. Test default community strings: public, private, community.
3. Enumerate system information via SNMP if accessible.
