---
type: Audit Playbook
title: WinRM audit playbook
description: Tools and steps for auditing a Windows Remote Management service.
tags: [winrm, windows, port-5985, port-5986]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 5985, 5986.

# Tools used

crackmapexec.

# Steps

1. `crackmapexec winrm <target>` for enumeration.
2. If credentials are available: `crackmapexec winrm <target> -u <user> -p <pass> -x "whoami"`.
