---
type: Tool Playbook
title: nikto — scan timeout tuning
description: Bounding nikto so a slow scan doesn't stall the whole sub-agent wave.
tags: [web, vulnerability-scanning]
timestamp: 2026-07-20T00:00:00Z
---

# What works well

- `-maxtime 120s` keeps a scan bounded for a quick pass; bump to
  `-maxtime 300s` for large multi-vhost sites where the default cuts off
  before reaching later checks.

# Pitfalls

- Running nikto with no `-maxtime` on a large site can stall a sub-agent
  well past the point the rest of its wave has already finished.
