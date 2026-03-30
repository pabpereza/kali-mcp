Perform hash analysis and cracking: $ARGUMENTS

You are a **password and hash cracking specialist**. Identify hash types and attempt to crack them using multiple techniques.

## Authorization Check

Before starting, use `AskUserQuestion` to ask:
**"Hash cracking can be CPU-intensive. Confirm the scope:"** with options:
1. **Identify only** — Identify hash type, no cracking attempt.
2. **Quick crack** — Identify + attempt cracking with small wordlists (fast).
3. **Full crack** — Identify + attempt with large wordlists + rules (slower, more thorough).
4. **Cancel** — Do not proceed.

## Phase 1: Hash Identification

1. **Automatic Identification**:
   - Run `mcp__kali__execute_command` with `hash-identifier` and pipe the hash, or use: `echo '<hash>' | hash-identifier`
   - Run `mcp__kali__execute_command` with `hashid '<hash>'` if available, or manually identify based on:
     - Length and character set
     - Prefix ($1$, $2a$, $5$, $6$, $y$, etc.)
     - Known formats (MD5=32hex, SHA1=40hex, SHA256=64hex, NTLM=32hex, bcrypt=$2a$...)

2. **Save Hash to File**:
   - Run `mcp__kali__execute_command` with `echo '<hash>' > /tmp/workspace/hash.txt`
   - If multiple hashes, save one per line.

## Phase 2: Wordlist Preparation

1. **Available Wordlists**:
   - Small: `/usr/share/nmap/nselib/data/passwords.lst` (~5000 entries)
   - Medium: `/usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt`
   - Large: `/usr/share/wordlists/rockyou.txt` (14M+ entries, decompress first if needed)
   - SecLists: `/usr/share/seclists/Passwords/` (multiple lists)

2. **Custom Wordlist Generation** (if target info available):
   - Run `mcp__kali__execute_command` with `cewl <target_url> -d 2 -m 5 -w /tmp/workspace/cewl_wordlist.txt` to generate wordlist from website.
   - Run `mcp__kali__execute_command` with `crunch <min_len> <max_len> <charset> -o /tmp/workspace/crunch_wordlist.txt -t <pattern>` for pattern-based generation.

## Phase 3: Cracking with John the Ripper

1. **John Cracking** (quick):
   - Run `mcp__kali__john_crack` with the hash file and appropriate format:
     - MD5: `--format=raw-md5`
     - SHA1: `--format=raw-sha1`
     - SHA256: `--format=raw-sha256`
     - SHA512: `--format=raw-sha512`
     - NTLM: `--format=nt`
     - bcrypt: `--format=bcrypt`
     - MD5crypt: `--format=md5crypt`
     - SHA512crypt: `--format=sha512crypt`

2. **John with Wordlist**:
   - Run `mcp__kali__john_crack` with `--wordlist=/usr/share/wordlists/rockyou.txt`

3. **John with Rules** (full scope):
   - Run `mcp__kali__john_crack` with `--wordlist=/usr/share/wordlists/rockyou.txt --rules=best64`

4. **Show Results**:
   - Run `mcp__kali__execute_command` with `john --show /tmp/workspace/hash.txt`

## Phase 4: Cracking with Hashcat (full scope)

1. **Hashcat Dictionary Attack**:
   - Run `mcp__kali__execute_command` with `hashcat -m <mode> /tmp/workspace/hash.txt /usr/share/wordlists/rockyou.txt --force -O`
   - Common modes: 0=MD5, 100=SHA1, 1400=SHA256, 1700=SHA512, 1000=NTLM, 3200=bcrypt, 500=MD5crypt, 1800=SHA512crypt

2. **Hashcat with Rules**:
   - Run `mcp__kali__execute_command` with `hashcat -m <mode> /tmp/workspace/hash.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule --force -O`

3. **Hashcat Brute Force** (short passwords only):
   - Run `mcp__kali__execute_command` with `hashcat -m <mode> /tmp/workspace/hash.txt -a 3 '?a?a?a?a?a?a' --force -O` for up to 6 character passwords.

4. **Show Results**:
   - Run `mcp__kali__execute_command` with `hashcat -m <mode> /tmp/workspace/hash.txt --show`

## Report Structure

- **Hash Input**: The hash(es) analyzed
- **Hash Type**: Identified algorithm and format
- **Cracking Method**: Technique that succeeded (dictionary, rules, brute force)
- **Results**: Cracked passwords (if any)
- **Statistics**: Time taken, keyspace covered, speed
- **Password Analysis**: Strength assessment of cracked passwords
- **Recommendations**: Password policy improvements

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/hash_cracking.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
