# OpenCode Bootstrap 🚀

**一键部署完整的 OpenCode AI 开发环境** — MCP 服务器、自定义 Agent、40+ 技能、插件系统，全部自动安装。

> 跟 AI 说一句 **"帮我部署 opencode bootstrap"**，全自动搞定。

---

## 目录

- [一行命令安装](#一行命令安装)
- [AI 自动部署](#ai-自动部署)
- [手动安装](#手动安装)
- [包含什么](#包含什么)
- [配置说明](#配置说明)
- [前置依赖](#前置依赖)
- [项目结构](#项目结构)
- [常见问题](#常见问题)

---

## 一行命令安装

**一行命令搞定，无需克隆、无需手动复制。**

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/kurumi1ksllq/opencode-bootstrap/master/scripts/install.sh | bash
```

### Windows（PowerShell）

```powershell
powershell -c "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kurumi1ksllq/opencode-bootstrap/master/scripts/install.ps1'))"
```

脚本会自动完成：

```
下载安装包 → 检查 Node.js/Python/Git → 安装 mem0/codegraph
→ 创建目录结构 → 部署 40+ 技能和配置文件 → 安装 npm 插件
→ 提示编辑占位符 → 完成
```

> **注意：** 安装完成后需要编辑 `~/.config/opencode/opencode.json`，把 `${VAR}` 占位符替换为你的 API 密钥（见 [配置说明](#配置说明)）。交互式终端下脚本会提示直接填写。

---

## AI 自动部署

打开 OpenCode，对 AI 说这一句话：

> **"帮我部署 opencode bootstrap，仓库 https://github.com/kurumi1ksllq/opencode-bootstrap.git"**

AI 会自动完成：

1. 克隆仓库，读取 SKILL.md 中的部署指令
2. 安装系统依赖（mem0、codegraph）
3. 创建目录结构，部署 40+ 技能和配置文件
4. 逐一询问 API 配置并替换 `${VAR}` 占位符
5. 安装 npm 插件
6. 复制 bootstrap skill 到 `~/.agents/skills/`
7. 验证部署结果

**全程无需手动操作。** 不需要先 clone，不需要先复制文件，一句话就够了。

---

## 手动安装

如果想自己动手，不通过 AI 执行：

### 1. 克隆仓库

```bash
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cd opencode-bootstrap
```

### 2. 一键安装脚本

**Windows（PowerShell）：**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

**macOS / Linux：**

```bash
bash scripts/install.sh
```

这个脚本会完成依赖安装、文件部署、npm 插件安装全部步骤。

### 3. 编辑配置文件

```bash
# 编辑 opencode.json，替换所有 ${VAR} 占位符
notepad ~/.config/opencode/opencode.json

# 可选：编辑 agent 配置
notepad ~/.config/opencode/oh-my-openagent.json
```

> **重要：** 复制前先编辑 `opencode.json`，把 `${VAR}` 占位符替换为实际值（见 [配置说明](#配置说明)）。

### 4. 重启 OpenCode

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
│   ├── install.ps1                 # Windows 一键安装脚本（支持 curl pipe）
│   ├── install.sh                  # Unix 一键安装脚本（支持 curl pipe）
│   ├── install-deps.ps1            # Windows 系统依赖安装（被 install.ps1 调用）
│   └── install-deps.sh             # Unix 系统依赖安装（被 install.sh 调用）
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

重新执行一行命令即可，脚本会覆盖安装已有文件：

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/kurumi1ksllq/opencode-bootstrap/master/scripts/install.sh | bash
```

或者对 AI 再说一次 **"帮我部署 opencode bootstrap"**。

### Q: 支持哪些平台？

- **Windows** — 使用 PowerShell 脚本安装
- **macOS / Linux** — 使用 Shell 脚本安装
- 所有配置文件和技能跨平台兼容

### Q: 占位符替换很麻烦，有没有跳过的方法？

目前所有 secrets 必须手动填写。这是为了安全 — secrets 不应该硬编码在仓库里。

---

> **Self-extracting OpenCode configuration pack.**  
> Deploys MCP servers, custom agents, commands, and 40+ AI skills in one shot.
