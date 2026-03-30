Resume a previous penetration testing session: $ARGUMENTS

You are the **session manager**. Your job is to load a previous session and allow the user to continue or extend the work.

## Step 1: List Available Sessions

Use the `Bash` tool to list all sessions:
```bash
ls -td sessions/*/ 2>/dev/null
```

If no sessions exist, inform the user:
**"No sessions found. Use `/project:start <target>` to create one."**
Then stop.

## Step 2: Session Selection

If `$ARGUMENTS` is provided, try to match it against existing session directories (partial match on target name is fine).

If no argument or multiple matches, use `AskUserQuestion` to present the available sessions. For each session, read its `session.md` to show:
- Target(s)
- Date
- Type (Pentest/Audit/Recon)
- Status (IN PROGRESS / COMPLETED)
- Number of assets generated

Present as a numbered list:
```
Available sessions:
1. [IN PROGRESS] 192.168.1.10 — Pentest — 2026-03-28 14:30 — 5 assets
2. [COMPLETED]   10.0.0.0/24  — Network Discovery — 2026-03-27 09:15 — 12 assets
3. [IN PROGRESS] example.com  — Web Audit — 2026-03-26 16:00 — 3 assets
```

## Step 3: Load Session Context

Once a session is selected, read ALL files in the session directory:
1. `session.md` — Session metadata, timeline, and sub-agents dispatched
2. `targets.md` — Target list and current status
3. `findings.md` — Consolidated findings (if exists)
4. All files in `assets/` — Raw sub-agent outputs

## Step 4: Present Session Summary

Display the current state of the session:

```
SESSION RESUMED
━━━━━━━━━━━━━━━
Target(s):    <targets>
Type:         <engagement type>
Scope:        <authorization scope>
Status:       <status>
Directory:    sessions/<dir>/
Assets:       <count> files
Findings:     <count> (Critical: X, High: X, Medium: X, Low: X)

Sub-agents completed:
  - <list of completed sub-agents from assets>

Gaps detected:
  - <list of expected but missing sub-agents or incomplete scans>
```

## Step 5: Suggest Next Actions

Based on the session state, suggest what the user can do:

**If IN PROGRESS with gaps:**
```
Suggested next steps:
  1. Re-run missing scans for gaps detected above
  2. Run additional scans: /project:vuln-scan <target>, /project:web-audit <target>
  3. Finalize: /project:finish
```

**If COMPLETED:**
```
This session is already finalized. You can:
  1. Run additional scans that will append to this session
  2. Start a new session: /project:start <target>
  3. Review findings in sessions/<dir>/findings.md
```

## Step 6: Set Active Session

Mark this session as the active session for the current conversation. All subsequent commands should save their outputs to this session's `assets/` folder.

If the session was COMPLETED and the user wants to continue, update `session.md`:
- Change status back to `IN PROGRESS`
- Add timeline entry: `[<time>] Session resumed`
