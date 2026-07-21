---
description: Finalize the current Kali MCP session (report + knowledge consolidation).
agent: kali
---

Finalize the current penetration testing session and generate the consolidated report.

You are the **session finalizer**: review worker outputs, double-check completeness (including any active child sessions from parallel workers), produce the final report, and fold any reusable tool-efficiency lessons back into `knowledge/`.

## Step 1: Locate the Session

Run `ls -td sessions/*/ 2>/dev/null | head -1` to find the most recent session.
If none exists: tell the user **"No active session found. Use `/kali-start <target>` to initialize one first."** and stop.

Read `sessions/<dir>/session.md` and `targets.md` for context.

## Step 2: Check for Active Worker Child Sessions

If any `kali-worker` subagents were dispatched in parallel, they may have created child sessions that are still running. Check for active child sessions and wait for them to complete before proceeding. If workers are still running, tell the user: **"Some parallel workers are still active. Waiting for them to finish..."**

## Step 3: Inventory & Double-Check

Glob all files under `sessions/<dir>/assets/**/*`, read every asset file, and build a quality table:

| Worker | Asset File | Status | Quality | Notes |
|--------|-----------|--------|---------|-------|
| ... | Complete/Partial/Missing | Good/Fair/Poor | ... |

Check each for: actual scan output (not just errors), the expected tools were really run, findings carry severity, evidence is present.

## Step 4: Gaps

List missing/failed workers, untested discovered services, and approved-but-unexecuted scope items. If any exist, ask the user: **"Gaps detected. How should we proceed?"**
1. **Re-run missing scans** — dispatch `kali-worker` for the gaps, wait, then continue.
2. **Proceed with partial results** — finalize now, noting gaps.
3. **Cancel** — don't finalize yet.

Wait for the user's answer before proceeding.

## Step 5: Compile Findings

Read all asset files, deduplicate, and write `sessions/<dir>/findings.md`:

```markdown
# Consolidated Findings

**Session**: <target> | <date> | <scope>
**Total findings**: <count>

## Critical / High / Medium / Low / Informational
| # | Finding | Service | Port | Evidence | Remediation |

## Attack Paths
## Gaps & Limitations
```

## Step 6: Update Session File

Edit `session.md`: status → `COMPLETED`, executive summary (3-5 sentences), full worker list, final timeline entry, and:
```
## Statistics
- Critical/High/Medium/Low: <n> each, Total: <n>
- Assets generated: <n>, Workers dispatched: <n>, Gaps detected: <n>
```

## Step 7: Knowledge Consolidation (tool efficiency only)

`knowledge/` is a small OKF bundle about running this toolkit's tools *efficiently* — it is **not** a place for target data. Scan the session's asset files for genuinely reusable operational lessons: a flag/timeout/concurrency setting that made a real difference, a wordlist that clearly outperformed the default, a tool that stalled or produced noise until tuned. Skip this step entirely if nothing new and generalizable came up — most sessions won't add anything here.

For each lesson found:
1. Strip everything target-specific (no IP, hostname, credential, or client detail — only *tool + flag/setting + why*).
2. If `knowledge/tools/<tool>.md` exists, edit it to add/refine a bullet under `# What works well` or `# Pitfalls`. If it doesn't exist yet, write a new one following the OKF frontmatter used by the existing files in `knowledge/tools/` (`type: Tool Playbook`, `title`, `description`, `tags`, `timestamp`), and add it to `knowledge/tools/index.md`.
3. Append one line to `knowledge/log.md` under today's date describing what changed.

## Step 8: Present Final Report

Show: Executive Summary, Risk Matrix, Top 5 Critical findings (if any), Attack Paths, Gaps, Remediation Roadmap, and:

```
SESSION FINALIZED
━━━━━━━━━━━━━━━━━
sessions/<dir>/
  - session.md    — metadata and summary
  - targets.md    — target list and status
  - findings.md   — consolidated findings by severity
  - assets/       — raw worker output (<n> files)

knowledge/: <n> tool-efficiency notes updated (or "no new lessons this session")
```
