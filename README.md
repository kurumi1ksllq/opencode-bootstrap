# OpenCode Bootstrap

把整套 OpenCode AI 框架配置（MCP、skills、agents、commands）打包成一个自举 skill。别人只需要把 skill 丢给 AI，AI 就会自动部署到 `~/.config/opencode/`。

## 快速使用

```bash
# 克隆到本地
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git
cp -r opencode-bootstrap ~/.agents/skills/

# 启动 OpenCode，对 AI 说：
# "部署 opencode bootstrap"
```

AI 会自动完成：MCP 安装 → 配置写入 → agents/commands 部署 → 依赖安装。

## 包含什么

| 分类         | 内容                                                                             |
| ------------ | -------------------------------------------------------------------------------- |
| **MCP**      | mem0 (记忆), codegraph (代码索引), context7 (文档), github (API)                 |
| **Plugins**  | DCP, oh-my-openagent, tokenscope, firecrawl, superpowers                         |
| **Agents**   | oracle (顾问), momus (审查)                                                      |
| **Commands** | tokenscope                                                                       |
| **Skills**   | 40+ 技能（agent-skills, engineering, in-progress, misc, personal, productivity） |
| **Config**   | opencode.json, AGENTS.md, oh-my-openagent.json, dcp.jsonc                        |

## 结构

```
opencode-bootstrap/
├── SKILL.md                    # 主自举指令（AI 读这个执行）
├── scripts/
│   ├── install-deps.ps1        # Windows 依赖安装脚本
│   └── install-deps.sh         # Unix 依赖安装脚本
└── README.md
```

## 部署后需要设置的环境变量

| 变量           | 用途                    |
| -------------- | ----------------------- |
| `LLM_BASE_URL` | LLM 提供商地址          |
| `LLM_API_KEY`  | LLM API 密钥            |
| `GITHUB_TOKEN` | GitHub 令牌（用于 MCP） |
| `MODEL_ID`     | 默认模型 ID             |
