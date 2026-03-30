Finalize the current penetration testing session and generate the consolidated report.

You are the **session finalizer**. Your job is to review all sub-agent outputs, perform double-checks, and produce the final session report.

## Step 1: Locate Active Session

Use the `Bash` tool to find the most recent session:
```bash
ls -td sessions/*/ 2>/dev/null | head -1
```

If no session directory exists, inform the user:
**"No active session found. Use `/project:start <target>` to initialize one first."**
Then stop.

Read `sessions/<dir>/session.md` and `sessions/<dir>/targets.md` to understand the session context.

## Step 2: Inventory Assets

Use the `Glob` tool to list all files in `sessions/<dir>/assets/`:
```
sessions/<dir>/assets/**/*
```

Read each asset file. Build a list of:
- Which sub-agents produced output
- Which sub-agents are expected but missing (based on the engagement type in session.md)

## Step 3: Double-Check Sub-Agent Results

For each asset file, verify:
1. **Completeness**: Does the output contain actual scan results (not just errors or empty responses)?
2. **Tool execution**: Were the expected tools actually run (look for nmap output, nikto output, etc.)?
3. **Findings documented**: Are vulnerabilities listed with severity ratings?
4. **Evidence present**: Are there command outputs or screenshots as evidence?

Build a quality report:

| Sub-Agent | Asset File | Status | Quality | Notes |
|-----------|-----------|--------|---------|-------|
| ... | ... | Complete/Partial/Missing | Good/Fair/Poor | ... |

## Step 4: Identify Gaps

List any gaps found:
- Sub-agents that were expected but didn't produce output
- Scans that failed or returned errors
- Services discovered but not tested
- Authorization scope items that were approved but not executed

If critical gaps exist, use `AskUserQuestion` to ask:
**"The following gaps were detected in the session. How should we proceed?"** with options:
1. **Re-run missing scans** — Launch sub-agents for the gaps identified.
2. **Proceed with partial results** — Generate the final report with available data, noting gaps.
3. **Cancel** — Don't finalize yet.

If "Re-run missing scans": Launch the appropriate sub-agents for the missing items, wait for them, then continue to Step 5.

## Step 5: Compile Findings

Read ALL asset files and extract every finding. Deduplicate and organize by severity.

Use the `Write` tool to create `sessions/<dir>/findings.md`:

```markdown
# Consolidated Findings

**Session**: <target> | <date> | <scope>
**Total findings**: <count>

## Critical
| # | Finding | Service | Port | Evidence | Remediation |
|---|---------|---------|------|----------|-------------|
| ... |

## High
| # | Finding | Service | Port | Evidence | Remediation |
|---|---------|---------|------|----------|-------------|
| ... |

## Medium
| # | Finding | Service | Port | Evidence | Remediation |
|---|---------|---------|------|----------|-------------|
| ... |

## Low / Informational
| # | Finding | Service | Port | Evidence | Remediation |
|---|---------|---------|------|----------|-------------|
| ... |

## Attack Paths
_Describe any chain of vulnerabilities that could be combined for greater impact._

## Gaps & Limitations
_List any areas not covered or scans that failed._
```

## Step 6: Update Session File

Use the `Edit` tool to update `sessions/<dir>/session.md`:

- Change **Status** to `COMPLETED`
- Fill in the **Summary** section with an executive summary (3-5 sentences)
- Update **Sub-Agents Dispatched** with the full list from the asset inventory
- Add final timeline entry: `[<time>] Session finalized`
- Add statistics:
  ```
  ## Statistics
  - Critical: <n>
  - High: <n>
  - Medium: <n>
  - Low/Info: <n>
  - Total: <n>
  - Assets generated: <n>
  - Sub-agents run: <n>
  - Gaps detected: <n>
  ```

## Step 7: Present Final Report

Display the complete findings report to the user, formatted for readability. Include:

1. **Executive Summary** (3-5 sentences)
2. **Risk Matrix** (Critical/High/Medium/Low counts)
3. **Top 5 Critical Findings** (if any)
4. **Attack Paths** identified
5. **Gaps & Limitations**
6. **Remediation Roadmap** (prioritized action items)
7. **Session artifacts**: List all files in the session directory

End with:
```
SESSION FINALIZED
━━━━━━━━━━━━━━━━━
All results saved to: sessions/<dir>/
  - session.md    — Session metadata and summary
  - targets.md    — Target list and status
  - findings.md   — Consolidated findings by severity
  - assets/       — Raw output from each sub-agent (<n> files)
```
