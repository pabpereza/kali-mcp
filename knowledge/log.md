# Knowledge Base Update Log

## 2026-07-20
* **Initialization**: Seeded the bundle with baseline tool-efficiency notes already implicit in `AGENTS.md` (bounded intrusive runs, two-pass nmap discovery, scan timeouts). Future entries are consolidated automatically by `/kali-finish` from real engagements.
* **Restructure**: Moved the full tool catalog and per-service command playbooks out of `AGENTS.md` (which now covers process/methodology only) into this bundle: `tools/index.md` gained the complete tool reference catalog, and a new `protocols/` sub-bundle (20 files) became the process index for "which tool for which protocol/application."
* **Session 10.129.49.235 — knowledge consolidation**:
  * `nmap.md`: added pitfall about `--script vuln` transiently reporting ports as `filtered` on silent-drop hosts; re-run with `-sT -sV` to confirm.
  * `nuclei.md`: added pitfall about "unresponsive permanently (i/o timeout)" under load causing false-negative 0-match results; recommend `-c 5` to `-c 10` for slow targets.
  * `gobuster.md`: added note that `dirb` can be notably slower than `gobuster`; prefer gobuster for time-bounded enumeration.
  * New `commix.md`: `--ignore-stdin` required for non-TTY MCP invocations (undocumented flag); `--level=1 --technique=CT` more reliable than level-3 under concurrent load.
  * New `arjun.md`: JSON mode crashes with `AttributeError` in v2.2.7; fall back to manual probing. Redirecting endpoints may be skipped.
  * `tools/index.md`: linked `commix` and `arjun` to their new note files.
