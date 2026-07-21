---
type: Tool Playbook
title: nmap — discovery strategy
description: Two-pass discovery (fast top-ports, background full-range) so sub-agent dispatch never waits on a full port scan.
tags: [discovery, port-scanning]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- Run a fast blocking pass first: `-sV -sC -Pn --top-ports 1000 -T4`. That's
  enough to start sub-agent dispatch within seconds on most targets.
- Kick off `-p- -T4 -Pn` (full 65535-port range) in the background in
  parallel; fold any extra ports found into the target list once it returns
  instead of waiting for it before dispatching anything.
- `-Pn` by default — many hosts drop ICMP and a plain ping-scan misses them.

# Pitfalls

- Waiting for a full `-p-` scan before dispatching any sub-agent wastes
  minutes per engagement for no benefit on targets with only well-known
  ports open.
- `--script vuln` against hosts that silently drop probes to closed/filtered
  ports can transiently report an open port as `filtered`; re-run with
  `-sT -sV --script vuln --max-retries 3` to confirm state before trusting
  the `filtered` result.
