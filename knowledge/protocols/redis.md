---
type: Audit Playbook
title: Redis audit playbook
description: Tools and steps for auditing a Redis service.
tags: [redis, database, port-6379]
timestamp: 2026-07-20T00:00:00Z
---

Port: 6379.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, netcat.

# Steps

1. `nmap --script redis-info,redis-brute -p 6379 <target>`.
2. Test unauthenticated access: `echo "INFO" | nc <target> 6379`.
