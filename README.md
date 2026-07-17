# OpenCode Bootstrap 🚀

**一键部署完整的 OpenCode AI 开发环境** — MCP 服务器、自定义 Agent、40+ 技能、插件系统，全部自动安装。

> 把这个 skill 丢给 AI，说一句 **"部署 opencode bootstrap"**，全自动搞定。

---

## 目录

- [一键部署](#一键部署)
- [手动安装](#手动安装)
- [包含什么](#包含什么)
- [配置说明](#配置说明)
- [前置依赖](#前置依赖)
- [项目结构](#项目结构)
- [常见问题](#常见问题)

---

## 一键部署

```bash
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cp -r opencode-bootstrap ~/.agents/skills/
```

打开 OpenCode，对 AI 说：

> **"部署 opencode bootstrap"**

AI 会自动帮你完成全部流程：

```
clone 仓库 → 安装系统依赖 → 询问 API 配置 → 写入配置文件
→ 部署 agents / commands → 复制 40+ 技能文件 → 安装 npm 插件
→ 提示重启 OpenCode
```

重启后，整个环境立即可用。

---

## 手动安装

如果想自己动手，不通过 AI 执行：

### 1. 克隆仓库

```bash
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cd opencode-bootstrap
```

### 2. 安装系统依赖

**Windows（PowerShell）：**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-deps.ps1
```

**macOS / Linux：**

```bash
bash scripts/install-deps.sh
```

手动安装的话，需要装这些：

```bash
pip install mcp mem0ai                          # mem0 记忆 MCP
npm install -g @opencode-ai/codegraph           # codegraph 代码智能
```

### 3. 复制配置文件

**Windows（PowerShell）：**

```powershell
$configDir = "$env:USERPROFILE\.config\opencode"
mkdir -Force $configDir\skills\agent-skills
mkdir -Force $configDir\skills\engineering
mkdir -Force $configDir\skills\in-progress
mkdir -Force $configDir\skills\misc
mkdir -Force $configDir\skills\personal
mkdir -Force $configDir\skills\productivity
mkdir -Force $configDir\agents
mkdir -Force $configDir\commands

Copy-Item payload\opencode.json, payload\AGENTS.md, payload\oh-my-openagent.json, payload\dcp.jsonc $configDir\
Copy-Item -Recurse payload\agents, payload\commands, payload\mem0_mcp.py $configDir\
Copy-Item -Recurse payload\skills\* $configDir\skills\
```

**macOS / Linux：**

```bash
mkdir -p ~/.config/opencode/skills/{agent-skills,engineering,in-progress,misc,personal,productivity}
mkdir -p ~/.config/opencode/{agents,commands}

cp payload/opencode.json payload/AGENTS.md payload/oh-my-openagent.json payload/dcp.jsonc ~/.config/opencode/
cp -r payload/agents payload/commands payload/mem0_mcp.py ~/.config/opencode/
cp -r payload/skills/* ~/.config/opencode/skills/
```

> **重要：** 复制前先编辑 `opencode.json`，把 `${VAR}` 占位符替换为实际值（见 [配置说明](#配置说明)）。

### 4. 安装插件

```bash
cd ~/.config/opencode
npm init -y
npm install @opencode-ai/plugin
npm install superpowers@github:obra/superpowers
```

### 5. 重启 OpenCode

重启后即可使用全部功能。可在 OpenCode 中验证：

- 输入 `/oracle` — 应该能看到 Oracle agent 的提示
- 输入 `/tokenscope` — 应该能查看 token 统计

---

## 包含什么

### MCP 服务器

| 名称          | 类型 | 用途                                       |
| ------------- | ---- | ------------------------------------------ |
| **mem0**      | 本地 | 对话记忆系统，记住用户的偏好和上下文       |
| **codegraph** | 本地 | 代码智能索引，实现代码结构搜索和跨文件导航 |
| **context7**  | 本地 | 实时文档查询，确保 AI 使用最新 API 文档    |
| **github**    | 远程 | GitHub API 集成，管理仓库、Issue、PR       |

### 插件

| 名称                | 用途                                  |
| ------------------- | ------------------------------------- |
| **DCP**             | 对话压缩插件，管理上下文窗口          |
| **oh-my-openagent** | 自定义 Agent 框架，支持灵活的角色配置 |
| **tokenscope**      | Token 消耗统计和可视化                |
| **firecrawl**       | 网页内容抓取                          |
| **superpowers**     | Obra 的 Superpowers 增强框架          |

### Agent

| 名称       | 用途                                       |
| ---------- | ------------------------------------------ |
| **Oracle** | 只读高 IQ 顾问，用于复杂架构决策和深度调试 |
| **Momus**  | 代码审查专家，评估计划质量和实现完整性     |

### 命令

| 名称           | 用途                                          |
| -------------- | --------------------------------------------- |
| **tokenscope** | 按成员分类展示当前会话的 token 消耗和费用明细 |

### 技能 (40+)

| 分类             | 数量 | 覆盖领域                                        |
| ---------------- | ---- | ----------------------------------------------- |
| **agent-skills** | 23   | API 设计、调试、TDD、安全、性能优化、代码评审等 |
| **engineering**  | 8    | 原型设计、架构改进、Issue 管理、PRD 编写等      |
| **in-progress**  | 4    | 写作辅助（碎片整理、文章塑形、叙事构建）        |
| **misc**         | 6    | 音频整理、Git 安全、练习脚手架、token 统计等    |
| **personal**     | 2    | Obsidian 笔记、文章编辑                         |
| **productivity** | 2    | 极简交流模式、技能编写工具                      |

---

## 配置说明

`payload/opencode.json` 使用 `${VAR}` 占位符来标记需要用户填写的值。部署时必须逐一替换。

| 占位符         | 说明                                                              |
| -------------- | ----------------------------------------------------------------- |
| `CONFIG_DIR`   | OpenCode 配置目录路径（默认 `~/.config/opencode`）                |
| `LLM_BASE_URL` | LLM 提供商 API 地址（如 `http://220.205.16.48:20005/v1`）         |
| `LLM_API_KEY`  | LLM API 密钥                                                      |
| `MODEL_ID`     | 模型标识符（如 `deepseek-v4-flash`）                              |
| `MODEL_NAME`   | 模型显示名称（如 `DeepSeek V4 Flash`）                            |
| `GITHUB_TOKEN` | GitHub Copilot Token（用于 MCP 远程访问）                         |
| `GO_API_KEY`   | GO / OpenRouter API 密钥（mem0 使用）                             |
| `PYTHON_PATH`  | Python 可执行文件路径（如 `D:\ProgramData\miniconda\python.exe`） |

`oh-my-openagent.json` 中同样有 `${MODEL_ID}` 占位符，替换为相同的模型 ID 即可。

---

## 前置依赖

- **Node.js** >= 18
- **Python** >= 3.10
- **Git**
- **npm**（随 Node.js 安装）

---

## 项目结构

```
opencode-bootstrap/
├── SKILL.md                        # 核心：AI 执行的部署指令
│
├── scripts/
│   ├── install-deps.ps1            # Windows 依赖安装脚本
│   └── install-deps.sh             # Unix 依赖安装脚本
│
├── payload/                        # 部署到 ~/.config/opencode/ 的所有文件
│   ├── opencode.json               # OpenCode 核心配置（${VAR} 占位符）
│   ├── AGENTS.md                   # 全局工作指南
│   ├── oh-my-openagent.json        # 自定义 Agent 模型配置
│   ├── dcp.jsonc                   # DCP 插件配置
│   ├── mem0_mcp.py                 # mem0 记忆 MCP 服务器（Python）
│   ├── agents/
│   │   ├── oracle.md               # Oracle 顾问 Agent
│   │   └── momus.md                # Momus 评审 Agent
│   ├── commands/
│   │   └── tokenscope.md           # Token 统计命令
│   └── skills/                     # 40+ AI 技能
│       ├── agent-skills/           # 23 个通用开发技能
│       ├── engineering/            # 8 个工程技能
│       ├── in-progress/            # 4 个写作技能
│       ├── misc/                   # 6 个辅助工具
│       ├── personal/               # 2 个个人工具
│       └── productivity/           # 2 个效率技能
│
├── .gitignore
└── README.md
```

---

## 常见问题

### Q: 部署后 OpenCode 报错说找不到 MCP 服务器？

检查 `opencode.json` 中的 Python 路径是否正确。如果你用了 conda / virtualenv，确保 `PYTHON_PATH` 指向的是环境里的 Python 可执行文件。

### Q: 如何重新部署？

把 bootstrap skill 复制到 `~/.agents/skills/` 后，对 AI 再说一次 **"部署 opencode bootstrap"** 即可。

### Q: 支持哪些平台？

- **Windows** — 使用 PowerShell 脚本安装
- **macOS / Linux** — 使用 Shell 脚本安装
- 所有配置文件和技能跨平台兼容

### Q: 占位符替换很麻烦，有没有跳过的方法？

目前所有 secrets 必须手动填写。这是为了安全 — secrets 不应该硬编码在仓库里。

---

> **Self-extracting OpenCode configuration pack.**  
> Deploys MCP servers, custom agents, commands, and 40+ AI skills in one shot.
