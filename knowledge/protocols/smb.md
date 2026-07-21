---
type: Audit Playbook
title: SMB/NetBIOS audit playbook
description: Tools and steps for auditing SMB/NetBIOS/Windows file-sharing services.
tags: [smb, netbios, microsoft-ds, port-139, port-445]
timestamp: 2026-07-20T00:00:00Z
---

Ports: 139, 445, or any service identified as smb/microsoft-ds/netbios.

# Tools used

enum4linux, [nmap](../tools/nmap.md) NSE scripts, smbclient, crackmapexec.

# Steps

1. `enum4linux -a <target>` for full enumeration (shares, users, groups, policies).
2. `nmap -Pn <target> --script smb-enum-shares,smb-enum-users,smb-os-discovery,smb-security-mode,smb-vuln-ms17-010,smb-vuln-ms08-067`.
3. Check for null session access.
4. Check for EternalBlue (MS17-010) and other critical SMB vulnerabilities.
5. `smbclient -L //<target> -N` and list accessible shares and their permissions.
6. If credentialed: `crackmapexec smb <target> --shares --users --groups --pass-pol`.
