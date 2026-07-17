#!/usr/bin/env bash
# OpenCode Bootstrap - 一键安装脚本
#
# 一行命令安装（无需克隆）：
#   macOS / Linux:
#     curl -fsSL https://raw.githubusercontent.com/kurumi1ksllq/opencode-bootstrap/master/scripts/install.sh | bash
#
# 从本地克隆运行：
#   bash scripts/install.sh

set -euo pipefail

CONFIG_DIR="${HOME}/.config/opencode"
GITHUB_REPO="https://github.com/kurumi1ksllq/opencode-bootstrap.git"

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo ""; echo -e "${CYAN}━━━ $1 ━━━${NC}"; }

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║     OpenCode Bootstrap Installer      ║"
echo "║  一键部署 OpenCode AI 开发环境        ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# ── Phase 0: Locate or fetch source ──
step "0/6: 定位安装源"

find_repo_root() {
    # cwd is repo root
    if [ -d "./payload" ]; then
        pwd
        return 0
    fi
    # running from scripts/ dir
    local script_path="${BASH_SOURCE[0]:-}"
    if [ -n "$script_path" ] && [ "$script_path" != "/dev/stdin" ]; then
        local script_dir
        script_dir="$(cd "$(dirname "$script_path")" 2>/dev/null && pwd)"
        if [ -n "$script_dir" ] && [ -d "$script_dir/../payload" ]; then
            cd "$script_dir/.." && pwd
            return 0
        fi
    fi
    return 1
}

REPO_ROOT=""
if find_repo_root >/dev/null 2>&1; then
    REPO_ROOT=$(find_repo_root)
    ok "本地克隆: $REPO_ROOT"
else
    info "从 GitHub 下载..."
    TEMP_DIR=$(mktemp -d)
    if command -v git &>/dev/null; then
        git clone --depth 1 "$GITHUB_REPO" "$TEMP_DIR" 2>/dev/null || {
            err "Git clone 失败。请安装 git 或手动下载。"
            exit 1
        }
    else
        curl -fsSL "https://github.com/kurumi1ksllq/opencode-bootstrap/archive/master.tar.gz" | tar -xz -C "$TEMP_DIR" --strip-components=1 2>/dev/null || {
            err "下载失败。请检查网络连接。"
            exit 1
        }
    fi
    REPO_ROOT="$TEMP_DIR"
    ok "已下载到 $TEMP_DIR"
fi

PAYLOAD_DIR="$REPO_ROOT/payload"
SKILL_FILE="$REPO_ROOT/SKILL.md"

# ── Phase 1: Check prerequisites ──
step "1/6: 检查前置依赖"

command -v node &>/dev/null || { err "Node.js >= 18 未安装"; exit 1; }
ok "Node.js $(node --version)"

PYTHON=""
for cmd in python3 python; do
    if command -v "$cmd" &>/dev/null; then
        PYTHON="$cmd"
        break
    fi
done
[ -z "$PYTHON" ] && { err "Python >= 3.10 未安装"; exit 1; }
ok "$($PYTHON --version)"

if command -v git &>/dev/null; then
    ok "Git: $(git --version)"
else
    warn "Git 未安装（技能需手动部署）"
fi

# ── Phase 2: Install system deps ──
step "2/6: 安装系统依赖"

info "安装 mem0 Python 包..."
if $PYTHON -m pip install mcp mem0ai --quiet 2>/dev/null; then
    ok "mem0 安装成功"
else
    warn "mem0 安装失败，可稍后手动安装: pip install mcp mem0ai"
fi

info "安装 codegraph..."
if npm install -g @opencode-ai/codegraph 2>/dev/null; then
    ok "codegraph 安装成功"
else
    warn "codegraph 全局安装失败，OpenCode 将使用 npx"
fi

# ── Phase 3: Create directories ──
step "3/6: 创建目录结构"

mkdir -p "$CONFIG_DIR"/skills/{agent-skills,engineering,in-progress,misc,personal,productivity}
mkdir -p "$CONFIG_DIR"/{agents,commands}
ok "目录已创建: $CONFIG_DIR"

# ── Phase 4: Deploy config files ──
step "4/6: 部署配置文件"

cp "$PAYLOAD_DIR/opencode.json"       "$CONFIG_DIR/"
cp "$PAYLOAD_DIR/AGENTS.md"          "$CONFIG_DIR/"
cp "$PAYLOAD_DIR/oh-my-openagent.json" "$CONFIG_DIR/"
cp "$PAYLOAD_DIR/dcp.jsonc"          "$CONFIG_DIR/"
cp "$PAYLOAD_DIR/mem0_mcp.py"        "$CONFIG_DIR/"
cp -r "$PAYLOAD_DIR/agents/"*        "$CONFIG_DIR/agents/"
cp -r "$PAYLOAD_DIR/commands/"*      "$CONFIG_DIR/commands/"
cp -r "$PAYLOAD_DIR/skills/"*        "$CONFIG_DIR/skills/"
ok "配置文件已部署"

# Copy SKILL.md for AI-driven deployment
SKILLS_DIR="${HOME}/.agents/skills"
if [ ! -d "$SKILLS_DIR/opencode-bootstrap" ]; then
    mkdir -p "$SKILLS_DIR"
    cp -r "$REPO_ROOT" "$SKILLS_DIR/opencode-bootstrap" 2>/dev/null && ok "SKILL.md 已安装（可在 AI 中使用"部署 opencode bootstrap"）" || warn "SKILL.md 复制失败"
fi

# ── Phase 5: Install npm plugins ──
step "5/6: 安装 npm 插件"

cd "$CONFIG_DIR"
if [ ! -f package.json ]; then
    npm init -y >/dev/null 2>&1
fi

info "安装 @opencode-ai/plugin..."
npm install @opencode-ai/plugin --quiet 2>/dev/null && ok "@opencode-ai/plugin" || warn "安装失败，可稍后手动安装"

info "安装 superpowers..."
npm install superpowers@github:obra/superpowers --quiet 2>/dev/null && ok "superpowers" || warn "安装失败，可稍后手动安装"

# ── Phase 6: Configure placeholders ──
step "6/6: 配置占位符"

if [ -t 0 ]; then
    # Interactive terminal - prompt for key values
    echo "检测到交互式终端。是否要配置关键参数？(y/N)"
    read -r configure_now
    if [[ "$configure_now" =~ ^[Yy]$ ]]; then
        echo ""
        echo "请输入以下配置（直接回车跳过，留空则保持 \${VAR} 占位符）："

        read -rp "  LLM_BASE_URL (e.g. http://localhost:11434/v1): " llm_url
        read -rp "  LLM_API_KEY: " llm_key
        read -rp "  MODEL_ID (e.g. deepseek-v4-flash): " model_id
        read -rp "  MODEL_NAME (e.g. DeepSeek V4 Flash): " model_name
        read -rp "  GITHUB_TOKEN: " github_token
        read -rp "  PYTHON_PATH (e.g. /usr/bin/python3): " python_path

        # Apply substitutions
        [ -n "$llm_url" ] && sed -i "s|\${LLM_BASE_URL}|$llm_url|g" "$CONFIG_DIR/opencode.json"
        [ -n "$llm_key" ] && sed -i "s|\${LLM_API_KEY}|$llm_key|g" "$CONFIG_DIR/opencode.json"
        [ -n "$model_id" ] && sed -i "s|\${MODEL_ID}|$model_id|g" "$CONFIG_DIR/opencode.json" && \
            sed -i "s|\${MODEL_ID}|$model_id|g" "$CONFIG_DIR/oh-my-openagent.json"
        [ -n "$model_name" ] && sed -i "s|\${MODEL_NAME}|$model_name|g" "$CONFIG_DIR/opencode.json"
        [ -n "$github_token" ] && sed -i "s|\${GITHUB_TOKEN}|$github_token|g" "$CONFIG_DIR/opencode.json"
        [ -n "$python_path" ] && sed -i "s|\${PYTHON_PATH}|$python_path|g" "$CONFIG_DIR/opencode.json"

        ok "配置已更新"
    fi
else
    info "非交互式终端，跳过配置。请手动编辑: $CONFIG_DIR/opencode.json"
fi

# ── Done ──
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      安装完成！Installation Complete! ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}最后步骤：${NC}"
echo ""
echo "  1. 编辑配置文件，替换 \${VAR} 占位符："
echo "     $CONFIG_DIR/opencode.json"
echo "     $CONFIG_DIR/oh-my-openagent.json"
echo ""
echo "  2. 重启 OpenCode"
echo ""
echo "  3. 验证安装："
echo "     /oracle      - 应看到 Oracle agent 提示"
echo "     /tokenscope  - 应显示 token 统计"
echo ""
echo -e "${YELLOW}需要重新安装？再次执行本脚本即可。${NC}"
echo ""
