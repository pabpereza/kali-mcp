Perform network discovery and host enumeration on the target range: $ARGUMENTS

The argument should be a network range (e.g., 192.168.1.0/24) or a single host.

This is a **passive discovery** skill. It does NOT perform brute force or exploitation.

## Workflow

1. **Host Discovery**: Run nmap_scan with ping scan (-sn) to discover live hosts.
2. **Quick Port Scan**: For each live host, run a quick scan of top 100 ports using nmap_scan.
3. **OS Fingerprinting**: Run nmap_scan with OS detection (-O) against hosts with open ports.
4. **Service Enumeration**: For interesting hosts, run nmap_scan with version detection (-sV).
5. **Network Mapping**: Summarize topology and identify segments.

Use the Agent tool to launch parallel sub-agents for step 2-4 when multiple hosts are discovered, one agent per host.

Present results as a network map:
- **Live Hosts**: Table with IP, hostname, OS guess, open ports
- **Network Segments**: Identified subnets
- **Key Assets**: Servers, network devices, high-value targets
- **Attack Surface Summary**: Total exposed services
- **Recommended Targets**: Prioritized list for further testing with `/project:audit`
