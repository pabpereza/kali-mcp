---
type: Audit Playbook
title: NFS audit playbook
description: Tools and steps for auditing an NFS service.
tags: [nfs, port-2049]
timestamp: 2026-07-20T00:00:00Z
---

Port: 2049.

# Tools used

[nmap](../tools/nmap.md) NSE scripts, showmount.

# Steps

1. `nmap -Pn <target> --script nfs-ls,nfs-showmount,nfs-statfs -p 2049`.
2. `showmount -e <target>` to list exports.
