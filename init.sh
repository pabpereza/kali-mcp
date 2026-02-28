#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/docker"

echo "[*] Building and starting Kali MCP container..."
docker compose -f "$DOCKER_DIR/compose.yml" up -d --build

echo "[*] Waiting for MCP server to be ready..."
until curl -sf http://localhost:666/mcp > /dev/null 2>&1; do
    sleep 1
done

echo "[+] Kali MCP is running at http://localhost:666/mcp"
echo ""
echo "    Open your AI agent in this directory to start:"
echo "      claude       # Claude Code"
echo "      gemini       # Gemini CLI"
echo "      opencode     # OpenCode"
