# OpenCode Bootstrap - Windows Dependency Installer
# Run: powershell -ExecutionPolicy Bypass -File install-deps.ps1

$ErrorActionPreference = "Stop"
$ConfigDir = "$env:USERPROFILE\.config\opencode"

Write-Host "=== OpenCode Bootstrap Installer (Windows) ===" -ForegroundColor Cyan

# ---- Phase 1: Check prerequisites ----
Write-Host "`n[1/5] Checking prerequisites..." -ForegroundColor Yellow

$nodeVer = node --version 2>$null
if (-not $nodeVer) { Write-Host "ERROR: Node.js not found. Install from https://nodejs.org" -ForegroundColor Red; exit 1 }
Write-Host "  Node.js: $nodeVer" -ForegroundColor Green

$pythonVer = python --version 2>&1
if (-not $pythonVer) { Write-Host "ERROR: Python not found. Install from https://python.org" -ForegroundColor Red; exit 1 }
Write-Host "  Python: $pythonVer" -ForegroundColor Green

$gitVer = git --version 2>&1
if (-not $gitVer) { Write-Host "WARNING: Git not found. Skills will need manual install." -ForegroundColor Yellow }
else { Write-Host "  Git: $gitVer" -ForegroundColor Green }

# ---- Phase 2: Install system deps ----
Write-Host "`n[2/5] Installing MCP dependencies..." -ForegroundColor Yellow

Write-Host "  Installing mem0 Python packages..." -ForegroundColor Gray
python -m pip install mcp mem0ai --quiet
Write-Host "  mem0: OK" -ForegroundColor Green

Write-Host "  Installing codegraph..." -ForegroundColor Gray
npm install -g @opencode-ai/codegraph 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  codegraph: could not install globally, will use npx" -ForegroundColor Yellow
} else {
    Write-Host "  codegraph: OK" -ForegroundColor Green
}

# ---- Phase 3: Create directories ----
Write-Host "`n[3/5] Creating directory structure..." -ForegroundColor Yellow

$dirs = @(
    "$ConfigDir",
    "$ConfigDir\skills\agent-skills",
    "$ConfigDir\skills\engineering",
    "$ConfigDir\skills\in-progress",
    "$ConfigDir\skills\misc",
    "$ConfigDir\skills\personal",
    "$ConfigDir\skills\productivity",
    "$ConfigDir\agents",
    "$ConfigDir\commands"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
}
Write-Host "  Directories created" -ForegroundColor Green

# ---- Phase 4: Install plugin npm deps ----
Write-Host "`n[4/5] Installing plugin dependencies..." -ForegroundColor Yellow

Push-Location $ConfigDir
if (-not (Test-Path "package.json")) {
    npm init -y | Out-Null
}
npm install @opencode-ai/plugin --quiet
npm install superpowers@github:obra/superpowers --quiet
Pop-Location
Write-Host "  npm dependencies installed" -ForegroundColor Green

# ---- Phase 5: Final instructions ----
Write-Host "`n[5/5] Setup complete!" -ForegroundColor Green
Write-Host @"

Next steps:
  1. Copy opencode.json, AGENTS.md, oh-my-openagent.json, dcp.jsonc to $ConfigDir
  2. Copy the payload files to their subdirectories
  3. Restart OpenCode

Environment variables to set:
  LLM_BASE_URL    - Your LLM provider endpoint
  LLM_API_KEY     - Your LLM provider API key
  GITHUB_TOKEN    - Your GitHub personal access token (for MCP)

"@ -ForegroundColor Cyan
