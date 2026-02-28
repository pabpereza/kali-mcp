# Kali MCP

Toolkit de hacking etico que conecta agentes de IA con herramientas de seguridad de Kali Linux mediante MCP (Model Context Protocol).

Compatible con cualquier agente de IA que soporte MCP: Claude Code, Gemini CLI, OpenCode, Cursor, Copilot, Codex, Aider, Windsurf, goose, y otros.

```
> Audita el host 192.168.1.50

 Scanning target with nmap...

 PORT    SERVICE       VERSION
 22/tcp  ssh           OpenSSH 8.9
 80/tcp  http          Apache 2.4.54
 443/tcp https         nginx 1.18
 445/tcp microsoft-ds  Samba 4.15

 Analyzing 4 services...
   [SSH :22]   -> version analysis, weak algos, CVEs
   [HTTP :80]  -> nikto, gobuster, dirb, wpscan
   [HTTPS:443] -> nikto, gobuster, ssl audit
   [SMB :445]  -> enum4linux, smb-vuln scripts

 Consolidated report ready.
```

## Requisitos

- Docker y Docker Compose
- Un agente de IA con soporte MCP (ver [Compatibilidad](#compatibilidad))

## Inicio rapido

```bash
# 1. Clonar el repositorio
git clone <repo-url> && cd kali-mcp

# 2. Levantar el contenedor
./init.sh

# 3. Abrir tu agente de IA en el directorio del proyecto
claude          # Claude Code
gemini          # Gemini CLI
opencode        # OpenCode
```

El script `init.sh` construye la imagen, levanta el contenedor y espera a que el servidor MCP este listo. El agente detectara la configuracion MCP en `.mcp.json` automaticamente.

## Compatibilidad

El proyecto usa `AGENTS.md` como fichero de instrucciones, el estandar abierto soportado por la mayoria de agentes de IA. Adicionalmente, incluye `CLAUDE.md` para funcionalidades exclusivas de Claude Code.

| Agente | Fichero de instrucciones | Soporte MCP | Sub-agentes paralelos |
|--------|--------------------------|-------------|----------------------|
| **Claude Code** | `CLAUDE.md` + `AGENTS.md` (via referencia) | Nativo (`.mcp.json`) | Si (Agent tool) |
| **Gemini CLI** | `AGENTS.md` | Nativo | No |
| **OpenCode** | `AGENTS.md` | Nativo | No |
| **Cursor** | `AGENTS.md` | Nativo | No |
| **GitHub Copilot** | `AGENTS.md` | Nativo | No |
| **Codex (OpenAI)** | `AGENTS.md` | Nativo | No |
| **Aider** | `AGENTS.md` | Nativo | No |
| **Windsurf** | `AGENTS.md` | Nativo | No |
| **goose** | `AGENTS.md` | Nativo | No |

> **Nota sobre sub-agentes**: La arquitectura de auditorias paralelas (un agente por puerto/servicio) es una funcionalidad exclusiva de Claude Code mediante su Agent tool. El resto de agentes ejecutan las auditorias de forma secuencial siguiendo la misma metodologia definida en `AGENTS.md`. El resultado final es equivalente; Claude Code simplemente lo hace mas rapido al paralelizar.

### Configuracion MCP por agente

El fichero `.mcp.json` en la raiz del proyecto es el estandar:

```json
{
  "mcpServers": {
    "kali": {
      "type": "http",
      "url": "http://localhost:666/mcp"
    }
  }
}
```

La mayoria de agentes lo detectan automaticamente. Si tu agente requiere configuracion manual, apunta al endpoint MCP en `http://localhost:666/mcp`.

## Arquitectura

```
┌─────────────────────────────────────────────────────┐
│  Agente de IA (Claude / Gemini / OpenCode / ...)    │
│                                                     │
│  Lee AGENTS.md (o CLAUDE.md) para instrucciones     │
│  Usa herramientas MCP para ejecutar acciones        │
│                                                     │
│  [Claude Code: sub-agentes paralelos por puerto]    │
└──────────────────────┬──────────────────────────────┘
                       │ MCP (HTTP) localhost:666
┌──────────────────────┼──────────────────────────────┐
│  Docker: kali-mcp    │                              │
│                      ▼                              │
│  ┌─────────────────────────────────────┐            │
│  │ supergateway :8000                  │            │
│  │ Streamable HTTP  <->  MCP stdio    │            │
│  └──────────────┬──────────────────────┘            │
│                 │                                   │
│  ┌──────────────▼──────────────────────┐            │
│  │ kali-server-mcp :5000 (Flask API)   │            │
│  │                                     │            │
│  │  nmap · gobuster · dirb · nikto     │            │
│  │  sqlmap · hydra · john · wpscan     │            │
│  │  enum4linux · metasploit            │            │
│  └─────────────────────────────────────┘            │
└─────────────────────────────────────────────────────┘
```

## Herramientas disponibles

Puedes invocar las herramientas directamente en lenguaje natural:

```
> Escanea los puertos de 10.10.10.5 con deteccion de version
> Busca directorios ocultos en http://target.com
> Lanza wpscan contra http://blog.target.com
> Comprueba si el FTP en 10.10.10.5 permite login anonimo
```

| Herramienta | Funcion | Intrusiva |
|-------------|---------|-----------|
| `nmap_scan` | Escaneo de puertos, deteccion de version/OS, scripts NSE | No |
| `gobuster_scan` | Enumeracion de directorios, DNS y vhosts | No |
| `dirb_scan` | Descubrimiento de contenido web | No |
| `nikto_scan` | Escaneo de vulnerabilidades en servidores web | No |
| `wpscan_analyze` | Escaneo de vulnerabilidades en WordPress | No |
| `enum4linux_scan` | Enumeracion de Windows/Samba | No |
| `sqlmap_scan` | Deteccion y explotacion de inyeccion SQL | **Si** |
| `hydra_attack` | Fuerza bruta de contrasenas | **Si** |
| `john_crack` | Cracking de hashes | **Si** |
| `metasploit_run` | Ejecucion de modulos de Metasploit | **Si** |
| `execute_command` | Comando arbitrario en el contenedor Kali | Depende |

## Comandos de Claude Code (slash commands)

Estos comandos son exclusivos de Claude Code y aprovechan la arquitectura de sub-agentes paralelos:

### Orquestadores (lanzan sub-agentes en paralelo)

| Comando | Descripcion |
|---------|-------------|
| `/project:audit <target>` | Auditoria completa: descubre puertos, lanza un agente por servicio, consolida informe |
| `/project:pentest <target>` | Pentest completo en 5 fases con autorizacion por alcance |
| `/project:network-discovery <rango>` | Descubre hosts en la red y lanza un agente por host |

### Autonomos

| Comando | Descripcion |
|---------|-------------|
| `/project:recon <target>` | Reconocimiento pasivo (nmap + gobuster + nikto) |
| `/project:vuln-scan <target>` | Identificacion de vulnerabilidades con nmap scripts |
| `/project:web-audit <url>` | Auditoria de aplicacion web |
| `/project:wp-audit <url>` | Auditoria especifica de WordPress |
| `/project:brute <target> <servicio>` | Fuerza bruta con hydra/john |
| `/project:exploit <target> <vuln>` | Explotacion de una vulnerabilidad concreta |

## Politica de autorizacion

Las herramientas intrusivas (sqlmap, hydra, john, metasploit) **siempre requieren confirmacion del usuario** antes de ejecutarse. Esto esta definido tanto en `AGENTS.md` como en `CLAUDE.md`.

Al solicitar una auditoria completa, el agente pregunta el nivel de profundidad:

1. **Solo pasivo** — Reconocimiento y deteccion de vulnerabilidades
2. **Pasivo + credenciales** — Anade fuerza bruta con wordlists pequenas
3. **Auditoria completa** — Incluye sqlmap, metasploit y todas las pruebas intrusivas

## Flujo de auditoria (Claude Code con sub-agentes)

```
/project:audit 10.10.10.5
        |
        v
   Phase 1: nmap -sV -sC -O
        |
        v
   Muestra puertos y servicios
        |
        v
   Pregunta nivel de autorizacion
        |
        v
   Phase 2: Lanza sub-agentes en paralelo
        |
        |-- Agent HTTP :80   -> nikto + gobuster + dirb + wpscan + sqlmap*
        |-- Agent SSH :22    -> ssh scripts + hydra*
        |-- Agent SMB :445   -> enum4linux + smb-vuln scripts
        |-- Agent MySQL :3306 -> mysql scripts + hydra*
        |-- Agent FTP :21    -> ftp scripts + hydra*
        '-- ... (1 agente por puerto)
        |
        v                        (* segun autorizacion)
   Phase 3: Informe consolidado
        |
        |-- Resumen ejecutivo
        |-- Hallazgos por severidad (Critical/High/Medium/Low)
        |-- Resumen puerto por puerto
        |-- Rutas de ataque encadenadas
        '-- Plan de remediacion priorizado
```

> Con otros agentes (Gemini CLI, OpenCode, etc.) el flujo es identico pero secuencial: el agente ejecuta cada servicio uno tras otro siguiendo la misma metodologia de `AGENTS.md`.

## Servicios soportados

Cada servicio tiene un playbook de auditoria definido en `AGENTS.md`:

| Servicio | Puertos | Herramientas |
|----------|---------|--------------|
| HTTP/HTTPS | 80, 443, 8080, 8443 | nikto, gobuster, dirb, wpscan, sqlmap |
| SSH | 22 | nmap ssh-scripts, hydra |
| FTP | 21 | nmap ftp-scripts, hydra |
| SMB/NetBIOS | 139, 445 | enum4linux, nmap smb-scripts |
| MySQL | 3306 | nmap mysql-scripts, hydra |
| PostgreSQL | 5432 | nmap pgsql-scripts, hydra |
| MSSQL | 1433 | nmap ms-sql-scripts, hydra |
| SMTP | 25, 465, 587 | nmap smtp-scripts |
| DNS | 53 | nmap dns-scripts, dig |
| RDP | 3389 | nmap rdp-scripts, hydra |
| SNMP | 161 | nmap snmp-scripts |
| LDAP | 389, 636 | nmap ldap-scripts |
| Generico | cualquier otro | nmap --script safe, banner grab |

## Uso etico

Este toolkit esta disenado exclusivamente para:
- Pentesting autorizado con acuerdo escrito
- Competiciones CTF (Capture The Flag)
- Entornos de laboratorio y practica (HackTheBox, TryHackMe, VulnHub)
- Investigacion de seguridad defensiva

No utilices estas herramientas contra sistemas sin autorizacion explicita.

## Estructura del proyecto

```
kali-mcp/
├── init.sh                 # Levanta el contenedor y espera a que este listo
├── AGENTS.md               # Instrucciones para agentes de IA (estandar abierto)
├── CLAUDE.md               # Instrucciones adicionales para Claude Code (sub-agentes)
├── .mcp.json               # Configuracion MCP (detectada por los agentes)
├── docker/                 # Ficheros del contenedor
│   ├── Dockerfile          # Imagen Kali con herramientas de seguridad
│   ├── compose.yml         # Docker Compose
│   └── entrypoint.sh       # Inicia kali-server-mcp + supergateway
└── .claude/
    └── commands/           # Slash commands (solo Claude Code)
        ├── audit.md        # Orquestador principal con sub-agentes
        ├── pentest.md      # Pentest completo en 5 fases
        ├── network-discovery.md
        ├── recon.md
        ├── vuln-scan.md
        ├── web-audit.md
        ├── wp-audit.md
        ├── brute.md
        └── exploit.md
```

### Que lee cada agente

| Fichero | Quien lo lee | Contenido |
|---------|-------------|-----------|
| `AGENTS.md` | Gemini CLI, OpenCode, Cursor, Copilot, Codex, Aider, Windsurf, goose | Herramientas, politica de autorizacion, metodologia de auditoria, playbooks por servicio |
| `CLAUDE.md` | Claude Code | Referencia a AGENTS.md + slash commands + arquitectura de sub-agentes |
| `.claude/commands/*.md` | Claude Code | Definicion de los slash commands |
| `.mcp.json` | Todos | Configuracion del servidor MCP |
