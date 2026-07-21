---
type: Tool Playbook
title: nuclei — severity and concurrency
description: Keeping template-based scanning fast and high-signal.
tags: [web, vulnerability-scanning]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- Filter to `-severity critical,high,medium` first — low/info templates
  dominate runtime and mostly surface noise for a pentest report.
- `-c 25` concurrency is a good default; raising it rarely shortens wall
  time once the target starts rate-limiting responses.

# Pitfalls

- Under concurrent load, nuclei may mark a target as "unresponsive permanently
  (i/o timeout)" and skip the remaining templates, yielding a false-negative
  0-match result. If the target is slow or rate-limiting, drop concurrency to
  `-c 5` or `-c 10` and increase `-timeout` for more reliable coverage.
