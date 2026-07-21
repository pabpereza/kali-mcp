---
type: Tool Playbook
title: arjun — hidden HTTP parameter discovery
description: Discover hidden GET and POST parameters by analyzing response differences.
tags: [web, parameter-discovery]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- Default mode (`arjun -u <url>`) is fast and effective for GET parameter
  discovery on stable, non-redirecting endpoints.
- Reducing threads (`-t 3`) helps when the target appears to rate-limit
  under concurrent probing.

# Pitfalls

- JSON mode (`-m JSON`) can crash with an `AttributeError: 'dict' object has
  no attribute 'status_code'` (observed in arjun 2.2.7). This is a tool bug,
  not target behavior. If JSON mode crashes, fall back to manual parameter
  probing with `curl`/`ffuf` against the known JSON body shape.
- Endpoints that always redirect (e.g., 302 to `/login`) may be skipped with
  `due to errors` — target the final destination URL directly instead.
