---
type: Tool Playbook
title: gobuster — directory enumeration
description: Concurrency and wordlist defaults that balance speed against false-positive/rate-limit rate.
tags: [web, directory-enum]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- `-t 30 -q` is a reliable default concurrency — fast without tripping rate
  limits on most WAF-protected targets.
- `raft-medium-directories.txt` (SecLists) gives a better hit rate per unit
  time than `common.txt` on CMS-style targets; start there before going
  bigger.

# Pitfalls

- Higher thread counts (`-t 50`+) against a WAF-fronted target often produce
  a wall of 403/429 responses instead of faster results — drop concurrency
  rather than raise it when that happens.
- `dirb` can be notably slower than `gobuster` against the same target;
  prefer `gobuster` for time-bounded directory enumeration and treat `dirb`
  as a secondary confirmation pass only.
