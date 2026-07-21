---
type: Audit Playbook
title: DNS audit playbook
description: Tools and steps for auditing a DNS service.
tags: [dns, port-53]
timestamp: 2026-07-20T00:00:00Z
---

Port: 53, or any service identified as dns/domain.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, dig.

# Steps

1. `nmap -Pn <target> --script dns-zone-transfer,dns-recursion,dns-cache-snoop,dns-nsid`.
2. Attempt zone transfer: `dig axfr @<target> <domain>` (if domain is known).
3. Check if recursion is enabled (open resolver).
4. Check DNS server version for known CVEs.
