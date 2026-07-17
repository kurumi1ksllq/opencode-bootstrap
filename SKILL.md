---
name: opencode-bootstrap
description: COMPLETELY SELF-CONTAINED opencode environment bootstrapper. No prerequisites, no manual steps. Installs all MCP servers, plugin system (including superpowers), custom agents, commands, config files, and 40+ AI skills from a single repo. Use when setting up OpenCode from scratch, or when user says "bootstrap", "deploy config", "setup opencode", "init my environment", "install superpowers".
---

# OpenCode Bootstrap

这个技能会把一套完整的 OpenCode AI 框架部署到 `~/.config/opencode/`。部署完成后，用户只需重启 OpenCode 就可以全部就绪。

## 会安装什么

- **MCP 服务器**：mem0（记忆）、codegraph（代码智能）、context7（文档）、github（API）
- **插件**：DCP、oh-my-openagent、tokenscope、firecrawl、superpowers（通过 `"plugin"` 数组自动安装）
- **配置**：opencode.json、AGENTS.md、oh-my-openagent.json、dcp.jsonc
- **Agent**：oracle（顾问）、momus（评审）
- **命令**：tokenscope
- **技能**：40+ 个，覆盖 6 个分类（约 70 个文件）

---

## 执行计划

Create a `todowrite` with these items, execute them in order:

- [ ] Phase 1: Clone this repo
- [ ] Phase 2: Install system dependencies (MCP servers)
- [ ] Phase 3: Create directory structure
- [ ] Phase 4: Write configuration files
- [ ] Phase 5: Write agent and command definitions
- [ ] Phase 6: Write MCP server script
- [ ] Phase 7: Deploy skill files
- [ ] Phase 8: Install plugin npm dependencies
- [ ] Phase 9: Symlink or copy to .agents/skills/
- [ ] Phase 10: Set environment variables & verify

---

### Phase 1：克隆仓库

在用户的家目录下，克隆仓库并进入：

```bash
cd
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git /tmp/opencode-bootstrap
cd /tmp/opencode-bootstrap
```

### Phase 2：安装系统依赖

运行对应的安装脚本来安装 Python 和 npm 包：

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-deps.ps1
```

**macOS/Linux:**

```bash
bash scripts/install-deps.sh
```

如果脚本执行失败，手动安装：

```bash
pip install mcp mem0ai          # mem0 MCP 服务器
npm install -g @opencode-ai/codegraph   # codegraph MCP 服务器（兜底：用 npx）
```

### Phase 3：创建目录结构

```bash
# Windows
$configDir = "$env:USERPROFILE\.config\opencode"
mkdir -Force $configDir\skills\agent-skills
mkdir -Force $configDir\skills\engineering
mkdir -Force $configDir\skills\in-progress
mkdir -Force $configDir\skills\misc
mkdir -Force $configDir\skills\personal
mkdir -Force $configDir\skills\productivity
mkdir -Force $configDir\agents
mkdir -Force $configDir\commands

# macOS/Linux
# mkdir -p ~/.config/opencode/skills/{agent-skills,engineering,in-progress,misc,personal,productivity}
# mkdir -p ~/.config/opencode/{agents,commands}
```

### Phase 4：写入配置文件

把 `payload/opencode.json`、`payload/AGENTS.md`、`payload/oh-my-openagent.json`、`payload/dcp.jsonc` 复制到 `~/.config/opencode/`。

**重要**：AI 必须先读取 opencode.json，把所有 `${VAR}` 占位符替换为用户的实际值，然后再复制。逐一询问用户以下变量：

| 占位符         | 询问问题                                                                         |
| -------------- | -------------------------------------------------------------------------------- |
| `CONFIG_DIR`   | "你的 OpenCode 配置目录是哪个？（默认：~/.config/opencode）"                     |
| `LLM_BASE_URL` | "你的 LLM 提供商地址是什么？（例如 http://220.205.16.48:20005/v1）"              |
| `LLM_API_KEY`  | "你的 LLM API 密钥是什么？"                                                      |
| `MODEL_ID`     | "你想用哪个模型？（例如 deepseek-v4-flash）"                                     |
| `MODEL_NAME`   | "模型显示名称是什么？（例如 DeepSeek V4 Flash）"                                 |
| `GITHUB_TOKEN` | "你的 GitHub Copilot token 是什么？（用于 MCP 访问）"                            |
| `GO_API_KEY`   | "你的 GO（OpenRouter/OpenCode）API 密钥是什么？（mem0 使用）"                    |
| `PYTHON_PATH`  | "你的 Python 可执行文件路径是什么？（例如 D:\ProgramData\miniconda\python.exe）" |

对于 `oh-my-openagent.json`，把 `${MODEL_ID}` 替换为用户选择的模型名。

用 `edit` 工具在 payload 文件中替换占位符，然后再复制到目标位置。

### Phase 5：写入 Agent 和命令定义

复制 Agent 定义文件：

- `payload/agents/oracle.md` → `~/.config/opencode/agents/oracle.md`
- `payload/agents/momus.md` → `~/.config/opencode/agents/momus.md`
- `payload/commands/tokenscope.md` → `~/.config/opencode/commands/tokenscope.md`

### Phase 6：写入 MCP 服务器脚本

复制 `payload/mem0_mcp.py` → `~/.config/opencode/mem0_mcp.py`

### Phase 7：部署技能文件

把 `payload/skills/` 下的所有技能目录复制到 `~/.config/opencode/skills/` — 保持完整的目录结构不变。`payload/skills/` 下每个子目录都包含一个 `SKILL.md`，有些还附带参考文件或脚本。

```bash
# Windows
Copy-Item -Recurse -Path "payload/skills\*" -Destination "~/.config/opencode/skills\" -Force

# macOS/Linux
# cp -r payload/skills/* ~/.config/opencode/skills/
```

### Phase 8：安装插件 npm 依赖

```bash
cd ~/.config/opencode
npm init -y
npm install @opencode-ai/plugin
npm install superpowers@github:obra/superpowers
# 重启 OpenCode 后插件会自动安装
```

### Phase 9：复制到 .agents/skills/

把 bootstrap 技能复制到 `.agents/skills/`，以便后续会话中仍然可用：

```bash
# Windows
$agentSkillsDir = "$env:USERPROFILE\.agents\skills\opencode-bootstrap"
if (-not (Test-Path $agentSkillsDir)) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.agents\skills" -Force | Out-Null
    Copy-Item -Recurse -Path "$pwd" -Destination "$agentSkillsDir" -Force
}

# macOS/Linux
# mkdir -p ~/.agents/skills
# cp -r /tmp/opencode-bootstrap ~/.agents/skills/
```

### Phase 10: 设置环境变量并验证

告知用户：

1. 重启 OpenCode
2. 确认 MCP 服务器连接成功（mem0、codegraph、context7、github）
3. 测试 `/oracle` 和 `/momus` agent 是否正常工作
4. 测试 `/tokenscope` 命令是否可用

如果遇到问题，检查 `~/.config/opencode/opencode.json` 中的变量值是否正确。

---

## 部署完成后

用户现在可以使用全部 40+ 技能。bootstrap 技能本身也已安装 — 如果需要重新部署，只需要再说一次"bootstrap"即可。

所有东西都在这一个仓库里，不需要第二个仓库。
