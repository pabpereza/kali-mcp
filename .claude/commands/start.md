Initialize a penetration testing session for target: $ARGUMENTS

You are the **session manager**. Your job is to set up the session workspace before any scanning begins.

## Step 1: Target Configuration

If `$ARGUMENTS` is empty, use `AskUserQuestion` to ask:
**"Enter the target(s) for this engagement (IP, hostname, URL, or CIDR range):"**

Parse the target(s) from the arguments. Multiple targets can be comma-separated.

## Step 2: Engagement Type

Use `AskUserQuestion` to ask:
**"Select the type of engagement:"** with options:
1. **Full Pentest** — Complete penetration test with maximum parallelism (7+ sub-agents). Use `/project:pentest`.
2. **Security Audit** — Per-service audit with sub-agent per port. Use `/project:audit`.
3. **Reconnaissance Only** — Passive recon with no exploitation. Use `/project:recon`.
4. **Network Discovery** — Host enumeration across a network range. Use `/project:network-discovery`.
5. **Web Application Audit** — Focused web application security testing. Use `/project:web-audit`.

## Step 3: Authorization Scope

Use `AskUserQuestion` to ask:
**"Select the authorization scope for this engagement:"** with options:
1. **Passive only** — Scanning and vulnerability identification. No brute force, no exploitation.
2. **Passive + Credential testing** — Adds brute force with small wordlists against login services.
3. **Full pentest** — All phases including exploitation. May cause service disruption.

## Step 4: Create Session Directory

1. Sanitize the target name: replace `/`, `:`, `.` with `_`, remove special characters.
2. Generate timestamp: `YYYYMMDD_HHMM` format.
3. Create the session directory structure:

```
sessions/<sanitized_target>_<timestamp>/
├── session.md
├── targets.md
└── assets/
```

Use the `Bash` tool to create the directory:
```bash
mkdir -p sessions/<sanitized_target>_<timestamp>/assets
```

## Step 5: Initialize Session Files

### session.md
Use the `Write` tool to create `sessions/<dir>/session.md`:
```markdown
# Pentest Session

- **Target(s)**: <target list>
- **Date**: <current date and time>
- **Type**: <engagement type>
- **Scope**: <authorization scope>
- **Status**: IN PROGRESS

## Timeline
- [<time>] Session initialized

## Sub-Agents Dispatched
_None yet — waiting for scan commands._

## Summary
_Session in progress. Run `/project:finish` when done to generate the final report._
```

### targets.md
Use the `Write` tool to create `sessions/<dir>/targets.md`:
```markdown
# Targets

| Target | Type | Status | Findings |
|--------|------|--------|----------|
| <target> | <type> | Pending | — |

## Scope
**Authorization level**: <scope>

## Notes
_Add any engagement-specific notes here._
```

## Step 6: Create a placeholder asset
Use the `Write` tool to create `sessions/<dir>/assets/.gitkeep` (empty file) to ensure the assets directory is tracked.

## Step 7: Present Session Summary

Display to the user:

```
SESSION INITIALIZED
━━━━━━━━━━━━━━━━━━
Target(s): <targets>
Type:      <engagement type>
Scope:     <authorization scope>
Directory: sessions/<dir>/

Next steps:
  /project:pentest <target>    — Full pentest with sub-agents
  /project:audit <target>      — Per-service audit
  /project:recon <target>      — Passive reconnaissance
  /project:finish              — Finalize and generate report
```

IMPORTANT: Remember the session directory path. All subsequent commands in this conversation should save their outputs to this session's `assets/` folder.
