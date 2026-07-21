---
type: Audit Playbook
title: Elasticsearch audit playbook
description: Tools and steps for auditing an Elasticsearch service.
tags: [elasticsearch, database, port-9200]
timestamp: 2026-07-20T00:00:00Z
---

Port: 9200.

# Tools used

curl.

# Steps

1. `curl -s http://<target>:9200/` for cluster info.
2. `curl -s http://<target>:9200/_cat/indices?v` to list indices.
3. `curl -s http://<target>:9200/_nodes` for node info.
