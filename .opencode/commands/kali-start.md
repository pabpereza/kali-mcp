---
description: Initialize a Kali MCP pentest session (target + scope).
agent: kali
---

Initialize a penetration testing session for target: $ARGUMENTS

You are the **session manager**. Set up the session workspace before any scanning begins.

## Step 1: Collect Session Parameters

Parse the target(s) from `$ARGUMENTS` if present (comma-separated for multiple). Then ask the user any questions not already answered by `$ARGUMENTS`:

1. **Target(s)** (only if not in `$ARGUMENTS`): "Enter the target(s) for this engagement (IP, hostname, URL, or CIDR range):"
2. **Authorization scope**: "Select the authorization scope for this engagement:"
   - **Passive only** — scanning and vulnerability identification, no brute force, no exploitation.
   - **Passive + Credential testing** — adds brute force with small wordlists.
   - **Full pentest** — all phases including exploitation. May cause service disruption.

Wait for the user's answer before proceeding.

There is a single engagement type — `/kali-audit` — so no need to ask about it.

## Step 2: Create the Session

1. Sanitize the target name (replace `/`, `:`, `.` with `_`), timestamp with `date +%Y%m%d_%H%M`.
2. `mkdir -p sessions/<sanitized_target>_<timestamp>/assets`
3. Write `sessions/<dir>/session.md`:
   ```markdown
   # Pentest Session

   - **Target(s)**: <target list>
   - **Date**: <current date/time>
   - **Scope**: <authorization scope>
   - **Status**: IN PROGRESS

   ## Timeline
   - [<time>] Session initialized

   ## Sub-Agents Dispatched
   _None yet._

   ## Summary
   _In progress. Run `/kali-finish` when done._
   ```
4. Write `sessions/<dir>/targets.md`:
   ```markdown
   # Targets

   | Target | Status | Findings |
   |--------|--------|----------|
   | <target> | Pending | — |

   ## Scope
   **Authorization level**: <scope>
   ```
5. Write an empty `sessions/<dir>/assets/.gitkeep` so the directory is tracked.

## Step 3: Present Summary

```
SESSION INITIALIZED
━━━━━━━━━━━━━━━━━━
Target(s): <targets>
Scope:     <authorization scope>
Directory: sessions/<dir>/

Next: /kali-audit <target>
Then: /kali-finish   — finalize, report, and consolidate tool-efficiency lessons
```

Remember `SESSION_DIR` for the rest of the conversation — every subsequent scan command writes into this session's `assets/`.
