Perform network sniffing and traffic analysis: $ARGUMENTS

You are a **network traffic analyst**. Capture and analyze network traffic to identify security issues, cleartext credentials, and protocol anomalies.

## Authorization Check

Before starting, use `AskUserQuestion` to ask:
**"Network sniffing captures traffic on the container's network interface. Confirm authorization:"** with options:
1. **Yes, capture and analyze traffic** — Proceed with packet capture.
2. **Analyze existing PCAP file** — Analyze a previously captured file (provide path).
3. **Cancel** — Do not proceed.

## Phase 1: Interface Discovery

1. Run `mcp__kali__execute_command` with `ip addr show` to list available interfaces.
2. Run `mcp__kali__execute_command` with `ip route` to identify the default gateway and network.

## Phase 2: Traffic Capture

1. **Quick Capture** (30 seconds by default):
   - Run `mcp__kali__execute_command` with `timeout 30 tcpdump -i eth0 -c 1000 -w /tmp/workspace/capture.pcap -nn` to capture up to 1000 packets.

2. **Targeted Capture** (if specific target provided):
   - Run `mcp__kali__execute_command` with `timeout 30 tcpdump -i eth0 host <target> -c 500 -w /tmp/workspace/capture_target.pcap -nn`

3. **Protocol-Specific Captures**:
   - HTTP traffic: `timeout 30 tcpdump -i eth0 port 80 -c 200 -A -nn`
   - DNS traffic: `timeout 30 tcpdump -i eth0 port 53 -c 100 -nn -v`
   - FTP/Telnet (cleartext): `timeout 30 tcpdump -i eth0 'port 21 or port 23' -c 100 -A -nn`

## Phase 3: Traffic Analysis with tshark

1. **Protocol Distribution**:
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -q -z io,phs` for protocol hierarchy.

2. **Conversation Analysis**:
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -q -z conv,ip` for IP conversations.
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -q -z conv,tcp` for TCP conversations.

3. **Credential Extraction**:
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -Y "http.authbasic" -T fields -e http.authbasic` for HTTP Basic Auth.
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -Y "ftp.request.command == USER || ftp.request.command == PASS" -T fields -e ftp.request.command -e ftp.request.arg` for FTP credentials.
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -Y "http.request.method == POST" -T fields -e http.host -e http.request.uri -e http.file_data` for POST data.

4. **DNS Analysis**:
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name -e dns.a | sort -u` for DNS queries and responses.

5. **Anomaly Detection**:
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -q -z endpoints,tcp` to find unusual endpoints.
   - Run `mcp__kali__execute_command` with `tshark -r /tmp/workspace/capture.pcap -Y "tcp.analysis.retransmission" -q -z io,stat,1` for retransmissions.

## Report Structure

- **Capture Summary**: Duration, packets captured, interfaces
- **Protocol Distribution**: Breakdown by protocol
- **Top Talkers**: Most active IP pairs
- **Cleartext Credentials**: Any captured usernames/passwords
- **DNS Activity**: Queried domains, any suspicious lookups
- **HTTP Traffic**: Requested URLs, POST data, auth headers
- **Anomalies**: Unusual traffic patterns, port scans detected
- **Security Findings**: Unencrypted protocols, credential exposure, etc.
- **Recommendations**: Encryption, network segmentation, etc.

## Session Persistence

After presenting results, save outputs to the active session (if one exists, or create one):
1. Check for active session: `ls -td sessions/*/ 2>/dev/null | head -1`
2. If no session, create: `mkdir -p sessions/<target_sanitized>_<timestamp>/assets`
3. Save all outputs to `sessions/<SESSION_DIR>/assets/network_sniff.md`
4. Update `sessions/<SESSION_DIR>/session.md` with timeline entries.
