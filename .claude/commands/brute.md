Perform a brute force attack against the target service: $ARGUMENTS

Format: `<target> <service> [options]`
Examples:
- `192.168.1.10 ssh` - SSH brute force with default wordlists
- `192.168.1.10 ftp -u admin` - FTP brute force for user admin
- `192.168.1.10 http-post-form "/login:user=^USER^&pass=^PASS^:Invalid"` - HTTP form brute force

## Authorization Check (MANDATORY)

This skill performs **intrusive actions** that send authentication attempts and may trigger lockouts or affect service availability.

Before executing, use `AskUserQuestion` to ask the user:
**"Brute force attacks send many authentication attempts and may lock accounts or trigger IDS alerts. Confirm you have authorization to proceed?"** with options:
1. **Yes, proceed** — I have explicit authorization to test this target.
2. **Yes, but use small wordlist only** — Limit to top 50 common passwords to minimize impact.
3. **Cancel** — Do not proceed.

If the user selects "Cancel", stop immediately and suggest using `/project:recon` for passive analysis instead.

## Workflow

1. **Parse arguments**: Extract target, service, and options.
2. **Wordlist selection**: Use `/usr/share/wordlists/rockyou.txt` for passwords unless the user chose small wordlist (then use `/usr/share/wordlists/nmap.lst` or top 50).
3. **Run Hydra**: Execute hydra_attack with the appropriate parameters.
4. **Hash cracking** (if hash files provided): Use john_crack with appropriate format.

Report:
- **Target**: IP/hostname and service tested
- **Valid credentials found**: Table with username and password
- **Statistics**: Attempts made, time elapsed
- **Recommendations**: Password policy improvements
