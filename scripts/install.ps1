# OpenCode Bootstrap - 一键安装脚本 (Windows)
#
# 一行命令安装（无需克隆）：
#   powershell -c "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kurumi1ksllq/opencode-bootstrap/master/scripts/install.ps1'))"
#
# 从本地克隆运行：
#   powershell -ExecutionPolicy Bypass -File scripts\install.ps1

param(
    [switch]$Interactive
)

$ErrorActionPreference = "Stop"
$ConfigDir = "$env:USERPROFILE\.config\opencode"
$GitHubRepo = "https://github.com/kurumi1ksllq/opencode-bootstrap.git"

function Write-Info  { Write-Host "[INFO]  $args" -ForegroundColor Cyan }
function Write-Ok    { Write-Host "[OK]    $args" -ForegroundColor Green }
function Write-Warn  { Write-Host "[WARN]  $args" -ForegroundColor Yellow }
function Write-Err   { Write-Host "[ERROR] $args" -ForegroundColor Red }

Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     OpenCode Bootstrap Installer      ║" -ForegroundColor Cyan
Write-Host "║  一键部署 OpenCode AI 开发环境        ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan

# ── Phase 0: Locate or fetch source ──
Write-Host "`n━━━ 0/6: 定位安装源 ━━━" -ForegroundColor Cyan

function Get-RepoRoot {
    # Running from scripts\ dir
    if ($PSScriptRoot) {
        $candidate = Resolve-Path "$PSScriptRoot\.."
        if (Test-Path "$candidate\payload") {
            return $candidate
        }
    }
    # Running from repo root
    if (Test-Path ".\payload") {
        return (Get-Location).Path
    }
    return $null
}

$RepoRoot = Get-RepoRoot
if ($RepoRoot) {
    Write-Ok "本地克隆: $RepoRoot"
} else {
    Write-Info "从 GitHub 下载..."
    $TempDir = Join-Path $env:TEMP "opencode-bootstrap-$(Get-Random)"
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

    # Try git first, fallback to ZIP download
    $gitAvail = Get-Command git -ErrorAction SilentlyContinue
    if ($gitAvail) {
        git clone --depth 1 $GitHubRepo $TempDir 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $RepoRoot = $TempDir
        }
    }

    if (-not $RepoRoot) {
        Write-Info "使用 ZIP 下载..."
        $zipUrl = "https://github.com/kurumi1ksllq/opencode-bootstrap/archive/master.zip"
        $zipFile = Join-Path $env:TEMP "opencode-bootstrap.zip"
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($zipUrl, $zipFile)
            Expand-Archive -Path $zipFile -DestinationPath $TempDir -Force
            $RepoRoot = Join-Path $TempDir "opencode-bootstrap-master"
        } catch {
            Write-Err "下载失败: $_"
            exit 1
        } finally {
            if ($webClient) { $webClient.Dispose() }
        }
    }

    Write-Ok "已下载到 $RepoRoot"
}

$PayloadDir = Join-Path $RepoRoot "payload"
$SkillFile = Join-Path $RepoRoot "SKILL.md"

# ── Phase 1: Check prerequisites ──
Write-Host "`n━━━ 1/6: 检查前置依赖 ━━━" -ForegroundColor Cyan

$nodeVer = node --version 2>$null
if (-not $nodeVer) { Write-Err "Node.js >= 18 未安装"; exit 1 }
Write-Ok "Node.js $nodeVer"

$pythonVer = python --version 2>&1
if (-not $pythonVer) { Write-Err "Python >= 3.10 未安装"; exit 1 }
Write-Ok "$pythonVer"

$gitVer = git --version 2>&1
if ($gitVer) { Write-Ok "Git: $gitVer" } else { Write-Warn "Git 未安装" }

# ── Phase 2: Install system deps ──
Write-Host "`n━━━ 2/6: 安装系统依赖 ━━━" -ForegroundColor Cyan

Write-Info "安装 mem0 Python 包..."
try {
    python -m pip install mcp mem0ai --quiet 2>&1 | Out-Null
    Write-Ok "mem0 安装成功"
} catch {
    Write-Warn "mem0 安装失败，可稍后手动安装: pip install mcp mem0ai"
}

Write-Info "安装 codegraph..."
try {
    npm install -g @opencode-ai/codegraph 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "codegraph 安装成功"
    } else {
        Write-Warn "codegraph 全局安装失败，将使用 npx"
    }
} catch {
    Write-Warn "codegraph 安装失败，将使用 npx"
}

# ── Phase 3: Create directories ──
Write-Host "`n━━━ 3/6: 创建目录结构 ━━━" -ForegroundColor Cyan

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
Write-Ok "目录已创建: $ConfigDir"

# ── Phase 4: Deploy config files ──
Write-Host "`n━━━ 4/6: 部署配置文件 ━━━" -ForegroundColor Cyan

Copy-Item "$PayloadDir\opencode.json"        $ConfigDir\ -Force
Copy-Item "$PayloadDir\AGENTS.md"           $ConfigDir\ -Force
Copy-Item "$PayloadDir\oh-my-openagent.json" $ConfigDir\ -Force
Copy-Item "$PayloadDir\dcp.jsonc"           $ConfigDir\ -Force
Copy-Item "$PayloadDir\mem0_mcp.py"         $ConfigDir\ -Force
Copy-Item "$PayloadDir\agents\*"            $ConfigDir\agents\ -Recurse -Force
Copy-Item "$PayloadDir\commands\*"          $ConfigDir\commands\ -Recurse -Force
Copy-Item "$PayloadDir\skills\*"            $ConfigDir\skills\ -Recurse -Force
Write-Ok "配置文件已部署"

# Copy SKILL.md for AI-driven deployment
$SkillsDir = "$env:USERPROFILE\.agents\skills\opencode-bootstrap"
if (-not (Test-Path $SkillsDir)) {
    try {
        New-Item -ItemType Directory -Path "$env:USERPROFILE\.agents\skills" -Force | Out-Null
        Copy-Item -Path $RepoRoot -Destination $SkillsDir -Recurse -Force
        Write-Ok "SKILL.md 已安装（可在 AI 中使用"部署 opencode bootstrap"）"
    } catch {
        Write-Warn "SKILL.md 复制失败"
    }
}

# ── Phase 5: Install npm plugins ──
Write-Host "`n━━━ 5/6: 安装 npm 插件 ━━━" -ForegroundColor Cyan

Push-Location $ConfigDir
if (-not (Test-Path "package.json")) {
    npm init -y | Out-Null
}

Write-Info "安装 @opencode-ai/plugin..."
try {
    npm install @opencode-ai/plugin --quiet 2>&1 | Out-Null
    Write-Ok "@opencode-ai/plugin"
} catch {
    Write-Warn "安装失败，可稍后手动安装"
}

Write-Info "安装 superpowers..."
try {
    npm install superpowers@github:obra/superpowers --quiet 2>&1 | Out-Null
    Write-Ok "superpowers"
} catch {
    Write-Warn "安装失败，可稍后手动安装"
}
Pop-Location

# ── Phase 6: Configure placeholders ──
Write-Host "`n━━━ 6/6: 配置占位符 ━━━" -ForegroundColor Cyan

if ($Interactive -or $Host.UI.RawUI.KeyAvailable) {
    Write-Info "是否要配置关键参数？(y/N)"
    $answer = Read-Host
    if ($answer -match '^[Yy]') {
        Write-Host "`n请输入以下配置（直接回车跳过，留空则保持 `${VAR} 占位符）：" -ForegroundColor Yellow

        $llmUrl = Read-Host "  LLM_BASE_URL (e.g. http://localhost:11434/v1)"
        $llmKey = Read-Host "  LLM_API_KEY"
        $modelId = Read-Host "  MODEL_ID (e.g. deepseek-v4-flash)"
        $modelName = Read-Host "  MODEL_NAME (e.g. DeepSeek V4 Flash)"
        $githubToken = Read-Host "  GITHUB_TOKEN"
        $pythonPath = Read-Host "  PYTHON_PATH"

        # Read opencode.json, apply substitutions, write back
        $configPath = "$ConfigDir\opencode.json"
        $config = Get-Content $configPath -Raw
        if ($llmUrl)     { $config = $config -replace '\${LLM_BASE_URL}', $llmUrl }
        if ($llmKey)     { $config = $config -replace '\${LLM_API_KEY}', $llmKey }
        if ($modelId)    { $config = $config -replace '\${MODEL_ID}', $modelId }
        if ($modelName)  { $config = $config -replace '\${MODEL_NAME}', $modelName }
        if ($githubToken){ $config = $config -replace '\${GITHUB_TOKEN}', $githubToken }
        if ($pythonPath) { $config = $config -replace '\${PYTHON_PATH}', $pythonPath }
        Set-Content -Path $configPath -Value $config

        # Also update oh-my-openagent.json if modelId provided
        if ($modelId) {
            $agentConfig = Get-Content "$ConfigDir\oh-my-openagent.json" -Raw
            $agentConfig = $agentConfig -replace '\${MODEL_ID}', $modelId
            Set-Content "$ConfigDir\oh-my-openagent.json" -Value $agentConfig
        }

        Write-Ok "配置已更新"
    }
} else {
    Write-Info "非交互式终端，跳过配置。请手动编辑: $ConfigDir\opencode.json"
}

# ── Done ──
Write-Host "`n╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║      安装完成！Installation Complete! ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host "`n最后步骤：" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. 编辑配置文件，替换 `${VAR} 占位符："
Write-Host "     $ConfigDir\opencode.json"
Write-Host "     $ConfigDir\oh-my-openagent.json"
Write-Host ""
Write-Host "  2. 重启 OpenCode"
Write-Host ""
Write-Host "  3. 验证安装："
Write-Host "     /oracle      - 应看到 Oracle agent 提示"
Write-Host "     /tokenscope  - 应显示 token 统计"
Write-Host ""
Write-Host "需要重新安装？再次执行本脚本即可。" -ForegroundColor Yellow
Write-Host ""
