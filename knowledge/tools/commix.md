---
type: Tool Playbook
title: commix — command injection testing
description: OS command injection detection and exploitation via template and heuristic techniques.
tags: [web, command-injection, intrusive]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- `--batch` avoids interactive prompts, which is required for non-TTY MCP
  invocations.
- `--ignore-stdin` is required when running via MCP (or any non-interactive
  environment) because commix auto-enables `STDIN_PARSING` when `sys.stdin`
  is not a TTY, causing a silent no-op exit with zero targets. This flag is
  undocumented in `--help` but present in `menu.py`.
- `--level=1 --technique=CT` (classic + time-based) completes reliably and
  fast; `--level=3` can hit transient timeouts under concurrent scan load.

# Pitfalls

- Without `--ignore-stdin`, commix exits immediately after printing
  `Using 'stdin' for parsing targets list.` and does nothing — exit code 0,
  so the failure is invisible unless you read the output.
- Transient `[critical] Unable to connect to the target URL (Reason: timed out)`
  errors mid-scan are often client-side/network hiccups under load, not
  target-side effects. Re-test the target with plain `curl` immediately after
  to confirm; if the target is responsive, re-run with lower `--level` rather
  than treating the timeout as a finding.
