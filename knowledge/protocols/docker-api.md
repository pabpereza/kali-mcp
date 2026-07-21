---
type: Audit Playbook
title: Docker API audit playbook
description: Tools and steps for auditing an exposed Docker Engine API.
tags: [docker, container, port-2375, port-2376]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 2375, 2376.

# Tools used

curl.

# Steps

1. `curl -s http://<target>:2375/version` for Docker version.
2. `curl -s http://<target>:2375/containers/json` to list containers.
3. Check for unauthenticated Docker API access — this is a **critical** vulnerability if present (effectively root on the host).
