---
type: Audit Playbook
title: Generic/unrecognized service audit playbook
description: Fallback steps for a service that doesn't match any other protocol file.
tags: [generic, fallback]
timestamp: 2026-07-20T00:00:00Z
---

# Tools used

[nmap](../tools/nmap.md), searchsploit.

# Steps

1. `nmap -Pn <target> -sV --script safe` for version detection and safe scripts.
2. `searchsploit <service> <version>` to check for known exploits.
3. Attempt banner grabbing (`nc -nv <target> <port>` or `curl`).

If this service turns out to be common enough to see again, add a dedicated
file here instead of relying on this fallback next time.
