# Upstream issue draft — `mcp-kali-server` wrapper tools return HTTP 500

Ready-to-file bug report for the upstream project that provides `mcp-kali-server`
(the package installed in `docker/Dockerfile`). Confirm the exact repository URL,
then file this (or let me post it once you point me at the repo).

---

**Title:** Tool wrappers (`nmap_scan`, `nikto_scan`, `hydra_attack`, …) return `500 INTERNAL SERVER ERROR`

**Environment**
- Image: `kalilinux/kali-rolling`
- Package: `mcp-kali-server` (apt)
- API: Flask on `127.0.0.1:5000`, exposed as MCP via `supergateway` on `:8000`
- Container has `NET_RAW` + `NET_ADMIN`; target reachable; binaries present
  (`which nmap nikto gobuster dirb` all resolve under `/usr/bin`).

**Symptom**
Every dedicated tool wrapper fails:

```
POST http://localhost:5000/api/tools/nmap
-> {"error":"Request failed: 500 Server Error: INTERNAL SERVER ERROR", "success": false}
```

The same is observed for `/api/tools/{nikto,gobuster,dirb,...}`. Meanwhile
`execute_command` works perfectly and can invoke the exact same binaries directly:

```
execute_command: nmap -sV -sC -Pn <target>   # succeeds
```

`server_health` returns `status: healthy` but reports
`all_essential_tools_available: false` with `nmap/nikto/gobuster/dirb: false`,
even though those binaries exist and run. This strongly suggests the wrappers
gate execution on a tool-availability/health check that is producing a false
negative (and then 500-ing) rather than on whether the binary actually runs.

**Impact**
All specialized wrappers are unusable; consumers must route everything through
`execute_command`. This loses the wrappers' argument validation and any
structured output they were meant to provide.

**Expected**
- The health/availability check should detect installed tools correctly (e.g.
  resolve via `$PATH`/`shutil.which`), OR
- Wrapper endpoints should not hard-fail (500) on a soft health signal — degrade
  gracefully and attempt to run the tool, returning the real tool error if any.

**Suggested fix**
- Fix tool detection to use `shutil.which(<tool>)` / `PATH` lookup instead of
  whatever heuristic currently returns `false`.
- Decouple `HEALTHCHECK` reporting from request handling so a health-signal
  miss can't turn a valid request into a 500.

**Workaround**
Route all tools through `execute_command` invoking the raw binary. (This repo has
standardized on that approach; see the TOOLING DIRECTIVE in `AGENTS.md`.)
