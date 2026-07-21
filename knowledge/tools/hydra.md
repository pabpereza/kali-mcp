---
type: Tool Playbook
title: hydra — bounded brute force
description: Keeping hydra runs fast and safe instead of unbounded sweeps.
tags: [credential-testing, brute-force]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- `-t 4 -f` (4 threads, stop at first valid hit) keeps a run to seconds or
  minutes instead of hours, and avoids account lockouts on the target.
- If a credential was already harvested by a recon sub-agent, skip hydra
  entirely and just confirm it — brute force is a last resort, not a first
  step (see the loot-before-exploit ordering in `kali-audit.md`).

# Pitfalls

- An unbounded `rockyou.txt` sweep against a single service can run for
  hours and trigger lockouts/alerting. Always use a small or `head`-trimmed
  wordlist, or a single known credential, so the run is bounded.
- High thread counts (`-t 16`+) against rate-limited services produce false
  negatives (dropped attempts read back as failed auth) more often than they
  save time.
