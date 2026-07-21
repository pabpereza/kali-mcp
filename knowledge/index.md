---
okf_version: "0.1"
---
# Kali MCP — Knowledge Base

How to use this toolkit well: which tool to reach for, and how to run it
efficiently. This bundle follows the
[Open Knowledge Format](https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf)
(markdown + YAML frontmatter). Process and methodology (authorization
policy, audit workflow, session system) live in `AGENTS.md`, not here.

This is **not** a vulnerability, CVE, or target database. No IP, hostname,
credential, or client-identifying detail belongs here — that data lives only
in `sessions/` (gitignored). See `AGENTS.md` § Knowledge Base for how
sub-agents consult and update this bundle.

# Bundles

* [tools/](tools/index.md) - How to run each tool: full command reference, plus accumulated efficiency notes (flags, timeouts, wordlists, pitfalls)
* [protocols/](protocols/index.md) - Which tool(s) to run for a given protocol or application (SSH, SMB, HTTP/WordPress, MySQL, ...)
