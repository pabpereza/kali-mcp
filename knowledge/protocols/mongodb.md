---
type: Audit Playbook
title: MongoDB audit playbook
description: Tools and steps for auditing a MongoDB service.
tags: [mongodb, database, port-27017]
timestamp: 2026-07-20T00:00:00Z
---

Port: 27017.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, netcat.

# Steps

1. `nmap --script mongodb-info,mongodb-databases -p 27017 <target>`.
2. Test unauthenticated access: `echo "show dbs" | nc <target> 27017`.
