# OpenCode Bootstrap

就把这个 skill 丢给 AI，说一句 **"部署 opencode bootstrap"**，它就全自动搞定。

## 一句话使用

```bash
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cp -r opencode-bootstrap ~/.agents/skills/
```

然后打开 OpenCode，对 AI 说：

> **"部署 opencode bootstrap"**

AI 会自动执行：clone 仓库 → 装 MCP 依赖（mem0/codegraph）→ 写配置文件 → 部署 agents/commands → 复制 40+ skills → 装插件 → 提示你填 API key。重启 OpenCode，完事。

## 包含什么

```
opencode-bootstrap/
├── SKILL.md                    # AI 执行的指令（核心）
├── scripts/
│   ├── install-deps.ps1        # Windows 依赖安装脚本
│   └── install-deps.sh         # Unix 依赖安装脚本
├── payload/                    # 部署的文件（共 77 个）
│   ├── opencode.json           # 核心配置（secrets 用 ${VAR} 占位）
│   ├── AGENTS.md               # 全局工作指南
│   ├── oh-my-openagent.json    # Agent 模型配置
│   ├── dcp.jsonc               # DCP 插件配置
│   ├── mem0_mcp.py             # mem0 记忆 MCP 服务器
│   ├── agents/
│   │   ├── oracle.md           # 深度推理顾问
│   │   └── momus.md            # 代码审查官
│   ├── commands/
│   │   └── tokenscope.md       # Token 统计命令
│   └── skills/                 # 40+ AI 技能
│       ├── agent-skills/       # 22 个通用技能
│       ├── engineering/        # 8 个工程技能
│       ├── in-progress/        # 4 个写作技能
│       ├── misc/               # 6 个辅助工具
│       ├── personal/           # 2 个个人工具
│       └── productivity/       # 2 个效率技能
└── README.md
```

## 分步手动安装

如果想手动操作而不是让 AI 做：

```bash
# 1. 克隆
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cd opencode-bootstrap

# 2. 装依赖
# Windows:
powershell -ExecutionPolicy Bypass -File scripts/install-deps.ps1
# macOS/Linux:
bash scripts/install-deps.sh

# 3. 复制所有配置
mkdir -p ~/.config/opencode/skills/{agent-skills,engineering,in-progress,misc,personal,productivity}
cp payload/opencode.json payload/AGENTS.md payload/oh-my-openagent.json payload/dcp.jsonc ~/.config/opencode/
cp -r payload/agents payload/commands payload/mem0_mcp.py ~/.config/opencode/
cp -r payload/skills/* ~/.config/opencode/skills/

# 4. 装插件
cd ~/.config/opencode && npm init -y && npm install @opencode-ai/plugin
```

## 前置依赖

- Node.js >= 18
- Python >= 3.10
- Git
- npm
