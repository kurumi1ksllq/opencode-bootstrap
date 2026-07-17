#!/usr/bin/env bash
# OpenCode Bootstrap - macOS/Linux Dependency Installer
# Run: bash install-deps.sh

set -euo pipefail
CONFIG_DIR="${HOME}/.config/opencode"

echo "=== OpenCode Bootstrap Installer ==="

# ---- Phase 1: Check prerequisites ----
echo -e "\n[1/5] Checking prerequisites..."

command -v node >/dev/null 2>&1 || { echo "ERROR: Node.js not found"; exit 1; }
echo "  Node.js: $(node --version)"

if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo "ERROR: Python not found"; exit 1
fi
echo "  Python: $($PYTHON --version)"

if command -v git >/dev/null 2>&1; then
    echo "  Git: $(git --version)"
else
    echo "  WARNING: Git not found"
fi

# ---- Phase 2: Install system deps ----
echo -e "\n[2/5] Installing MCP dependencies..."

echo "  Installing mem0 Python packages..."
$PYTHON -m pip install mcp mem0ai --quiet
echo "  mem0: OK"

echo "  Installing codegraph..."
npm install -g @opencode-ai/codegraph 2>/dev/null && echo "  codegraph: OK" || echo "  codegraph: will use npx"

# ---- Phase 3: Create directories ----
echo -e "\n[3/5] Creating directory structure..."
mkdir -p "$CONFIG_DIR"/skills/{agent-skills,engineering,in-progress,misc,personal,productivity}
mkdir -p "$CONFIG_DIR"/{agents,commands}
echo "  Directories created"

# ---- Phase 4: Install plugin deps ----
echo -e "\n[4/5] Installing plugin dependencies..."
cd "$CONFIG_DIR"
[ ! -f package.json ] && npm init -y >/dev/null
npm install @opencode-ai/plugin --quiet
npm install superpowers@github:obra/superpowers --quiet
echo "  OK"

# ---- Phase 5: Done ----
echo -e "\n[5/5] Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Copy config files to $CONFIG_DIR"
echo "  2. Copy skill directories"
echo "  3. Restart OpenCode"
echo ""
echo "Environment variables to set:"
echo "  LLM_BASE_URL    Your LLM provider endpoint"
echo "  LLM_API_KEY     Your LLM provider API key"
echo "  GITHUB_TOKEN    GitHub personal access token (for MCP)"
echo ""
