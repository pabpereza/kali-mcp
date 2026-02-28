Perform a WordPress security audit on the target: $ARGUMENTS

## Authorization Check

Before starting, use `AskUserQuestion` to ask the user:
**"Which WordPress audit depth do you want?"** with options:
1. **Passive scan** — WPScan enumeration (plugins, themes, users, versions) + directory discovery. No brute force.
2. **Full audit with brute force** — Includes wp-login.php credential testing with hydra. May trigger account lockouts.

## Workflow

1. **WordPress Detection**: Verify WordPress by checking /wp-admin, /wp-login.php, /wp-content/.
2. **WPScan Full Audit**: Run wpscan_analyze to enumerate:
   - WordPress version and known CVEs
   - Installed plugins and versions
   - Installed themes and versions
   - User enumeration
3. **Directory Enumeration**: Run gobuster_scan to find additional exposed paths.
4. **Brute Force** (FULL AUDIT only): If authorized, run hydra_attack against wp-login.php. If passive, skip and note "Skipped - requires full audit authorization".

Report:
- **WordPress Version**: Version and associated CVEs
- **Plugins**: Table with name, version, status (vulnerable/outdated/ok)
- **Themes**: Table with name, version, status
- **Users Found**: Enumerated usernames
- **Vulnerabilities**: Categorized by severity
- **Hardening Recommendations**: WordPress-specific security improvements
