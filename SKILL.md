---
name: opencode-bootstrap
description: Self-extracting OpenCode configuration pack. Deploys MCP servers (mem0, codegraph, context7, github), custom agents (oracle, momus), commands (tokenscope), and 40+ AI skills in one shot. Use when setting up a new OpenCode environment from a shared configuration, or when user says "bootstrap", "deploy config", "setup opencode from scratch".
---

# OpenCode Bootstrap

This skill deploys a complete OpenCode AI framework configuration to `~/.config/opencode/`.

## What gets installed

| Category         | Items                                                                                          |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| **MCP Servers**  | mem0 (memory), codegraph (code intelligence), context7 (docs), github (GitHub API)             |
| **Plugins**      | DCP, oh-my-openagent, tokenscope, firecrawl, superpowers                                       |
| **Agents**       | oracle (adviser), momus (reviewer)                                                             |
| **Commands**     | tokenscope                                                                                     |
| **Skills**       | 40+ across 6 categories (agent-skills, engineering, in-progress, misc, personal, productivity) |
| **Instructions** | AGENTS.md (global guidelines), opencode.json, oh-my-openagent.json, dcp.jsonc                  |

## Prerequisites

- [ ] **Node.js** >= 18 — `node --version`
- [ ] **npm** — `npm --version`
- **Windows**: Python >= 3.10 — `python --version` (for mem0 MCP)
- **macOS/Linux**: Python >= 3.10 — `python3 --version` (for mem0 MCP)
- [ ] **Git** — `git --version` (for skill files)

---

## Execution Plan

### Phase 1: Install system-level dependencies

**mem0 MCP (Python):**

```bash
pip install mcp mem0ai
# or: pip install "mcp[cli]" mem0ai
```

**codegraph MCP (Node.js):**

```bash
npm install -g @opencode-ai/codegraph
```

### Phase 2: Create directory structure

Create these directories:

```
~/.config/opencode/
├── skills/
│   ├── agent-skills/
│   ├── engineering/
│   ├── in-progress/
│   ├── misc/
│   ├── personal/
│   └── productivity/
├── agents/
└── commands/
```

### Phase 3: Write configuration files

Create `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "@tarquinen/opencode-dcp@latest",
    "oh-my-openagent@latest",
    "@ramtinj95/opencode-tokenscope",
    "opencode-firecrawl",
    "superpowers@git+https://github.com/obra/superpowers.git"
  ],
  "provider": {
    "llm-gateway": {
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "${LLM_BASE_URL}",
        "apiKey": "${LLM_API_KEY}"
      },
      "models": {
        "default-model": {
          "name": "Default Model"
        }
      }
    }
  },
  "instructions": ["AGENTS.md"],
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"]
    }
  },
  "mcp": {
    "mem0": {
      "type": "local",
      "command": ["python", "mem0_mcp.py"],
      "enabled": true,
      "timeout": 30000
    },
    "github": {
      "type": "remote",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      },
      "enabled": true
    },
    "codegraph": {
      "type": "local",
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true,
      "timeout": 10000
    },
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true,
      "timeout": 15000
    }
  }
}
```

Create `~/.config/opencode/oh-my-openagent.json`:

```json
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json",
  "agents": {
    "sisyphus": { "model": "${MODEL_ID}" },
    "prometheus": { "model": "${MODEL_ID}" },
    "oracle": { "model": "${MODEL_ID}" },
    "metis": { "model": "${MODEL_ID}" },
    "ultrabrain": { "model": "${MODEL_ID}" },
    "momus": { "model": "${MODEL_ID}" },
    "hephaestus": { "model": "${MODEL_ID}" },
    "atlas": { "model": "${MODEL_ID}" },
    "sisyphus-junior": { "model": "${MODEL_ID}" },
    "librarian": { "model": "${MODEL_ID}" },
    "explore": { "model": "${MODEL_ID}" },
    "multimodal-looker": { "disable": true }
  },
  "categories": {
    "ultrabrain": { "model": "${MODEL_ID}" },
    "deep": { "model": "${MODEL_ID}" },
    "visual-engineering": { "model": "${MODEL_ID}" },
    "artistry": { "model": "${MODEL_ID}" },
    "unspecified-high": { "model": "${MODEL_ID}" },
    "unspecified-low": { "model": "${MODEL_ID}" },
    "quick": { "model": "${MODEL_ID}" },
    "writing": { "model": "${MODEL_ID}" }
  }
}
```

Create `~/.config/opencode/dcp.jsonc`:

```json
{
  "$schema": "https://raw.githubusercontent.com/Opencode-DCP/opencode-dynamic-context-pruning/master/dcp.schema.json"
}
```

Create `~/.config/opencode/AGENTS.md`:

```markdown
# 全局工作指南

> 此文件为全局 AGENTS.md，对所有项目生效。
> 项目级 AGENTS.md 放在项目根目录，只对该项目生效。

---

## 关于我

- **角色**：全栈开发者
- **主要语言**：TypeScript / Python
- **编辑器**：OpenCode
- **操作系统**：Windows / macOS / Linux

---

## 开发哲学

### 开发方式：按场景区分

| 场景                                | 方式                 | 说明                                               |
| ----------------------------------- | -------------------- | -------------------------------------------------- |
| 核心逻辑 / 领域层 / API 接口 / 算法 | **TDD（测试先行）**  | 先写测试定义行为，再实现，最后重构                 |
| UI/UX / 探索性开发 / 不确定需求     | **原型先行，再重构** | 先快速出原型验证方向，确认效果后再重构成可维护代码 |

### 架构原则：模块化

- 整体架构必须是**模块化**的，每个模块可以独立拆分、升级、重组
- 模块之间通过接口通信，避免代码强耦合
- 新模块的引入不能破坏现有模块的独立性
- 模块内部可以复杂，模块之间的依赖必须清晰、可控

---

## 工作习惯

### 开发流程

1. 先理解上下文，再动手改代码
2. 复杂任务先出方案，确认后再执行
3. 改完代码必须验证（`lsp_diagnostics`、跑测试）
4. 不引入不必要的依赖
5. 按场景选择开发方式（TDD / 原型 → 重构）

### 代码质量

- 类型安全优先 — 不滥用 `any` / `as` 强转
- 错误处理不能吞异常（禁止空 `catch`）
- 复杂度控制 — 能用简单方案不用复杂的
- 保持一致性 — 新代码匹配项目现有风格
- 模块边界清晰，耦合度低

### 沟通风格

- 说重点，不要铺垫
- 有问题直接指出，附带理由
- 有更好的方案必须提反对意见

---

## 常用命令

| 用途     | 命令                         |
| -------- | ---------------------------- |
| 类型检查 | `npx tsc --noEmit`           |
| 测试     | `npm test` 或 `pytest`       |
| 格式化   | Prettier（已配置 formatter） |

---

## 技术栈偏好

- **前端**：React / Next.js / TypeScript
- **后端**：Node.js / Python
- **数据库**：PostgreSQL / SQLite
- **测试**：Vitest / pytest

---

## 记忆系统（Mem0）

使用 mem0 的 `recall` 和 `remember` 工具管理对话记忆：

- 每次用户提问时，**先调用 `recall` 搜索相关记忆**，再回答问题
- 不要等用户说"搜一下"才搜，主动做
- 对话结束时，调用 `remember` 保存这次对话的关键信息
- 如果用户明确说"记住..."，立即调用 `remember`
- 如果用户问"我之前说过..."、"我记得..."，先调用 `recall`

---

## 注意事项

- 公共配置路径：`C:\Users\<user>\.config\opencode\` (Windows) / `~/.config/opencode/` (macOS/Linux)
- 复杂的架构决策先咨询 Oracle 再动手
- 不熟悉的库先查文档（Context7 / librarian）
- 模块化架构决策优先 — 任何可能破坏模块独立性的改动先提出反对
```

### Phase 4: Write agent and command definitions

Create `~/.config/opencode/agents/oracle.md` with this exact content:

```yaml
---
description: 深度推理顾问。复杂决策、架构设计、Bug 分析、多方案对比
mode: subagent
---
```

````markdown
你是 Oracle，深度推理顾问。

## 推理流程

### 第一步：确认问题

先在脑子里过一遍：

- 用户真正想要解决的是什么问题？
- 涉及哪些系统/模块？
- 有没有隐藏的约束（性能、兼容性、后续扩展）？
  把问题重述给用户确认："我理解的问题是…，对吗？"

### 第二步：探索方案

想 2-3 个不同路线，考虑：

- 方案之间的核心区别
- 各自代价（复杂度、性能、可维护性）
- 隐藏风险（哪些情况会翻车）

### 第三步：输出格式

\```

## 问题理解

[你对此问题的理解，确保和用户在同一页]

## 可选方案

### 方案 A：[名称]

**思路：** [一两句核心思路]
**优点：** [列表]
**缺点：** [列表]
**适用场景：** [什么情况下选这个]

## 我的推荐

[说清楚理由；或指出需要什么额外信息才能判断]
\```

## 原则

- 这不是考试，不需要每次都给唯一正确答案
- 对不熟悉的领域直接说出来，不要硬答
- 考虑"不做的代价"
````

Create `~/.config/opencode/agents/momus.md` with this exact content:

```yaml
---
description: 代码审查和方案批评。质量把关、风险识别
mode: subagent
---
```

````markdown
你是 Momus，质量审查官。按以下优先级逐一检查：

1. **逻辑正确性** — 方案站得住吗？边界条件？竞态？
2. **安全隐患** — 输入验证？注入风险？权限检查？
3. **错误处理** — 失败路径？错误信息会不会暴露内部细节？
4. **类型安全** — 有没有 `any`、`as` 强转、未定义访问？
5. **一致性** — 是否符合当前项目的代码风格和架构模式？
6. **过度设计** — 是不是用抽象工厂解构了本可以用 if-else 解决的问题？

输出格式：

\```

## 审查结果：[✅ 通过 / ⚠️ 有条件通过 / ❌ 阻塞]

### 阻塞问题（必须修）

🔴 [问题简述] — 为什么/怎么修

### 建议改进（推荐修）

🟡 [问题简述] — 为什么/怎么修

### 风格备注（可选）

🔵 [建议]
\```
````

Create `~/.config/opencode/commands/tokenscope.md`:

```markdown
---
description: Analyze token usage across the current session with detailed breakdowns by category
---

Call the tokenscope tool directly without delegating to other agents.
Leave sessionID unset unless the user explicitly asked to analyze a different session.
Then cat the token-usage-output.txt. DONT DO ANYTHING ELSE WITH THE OUTPUT.
```

### Phase 5: Write MCP server scripts

Create `~/.config/opencode/mem0_mcp.py`:

```python
"""
Mem0 MCP Server - 让 OpenCode 自动记忆和检索对话
"""
import os, json, sys
os.environ["TRANSFORMERS_OFFLINE"] = "1"
os.environ["HF_HUB_OFFLINE"] = "1"
import warnings
warnings.filterwarnings("ignore")

from mcp.server import Server, NotificationOptions
from mcp.server.models import InitializationOptions
import mcp.server.stdio
from mcp.types import Tool
from mem0 import Memory

LOCAL_MODEL_PATH = os.path.expanduser("~/.cache/bge-local")
GO_API_KEY = os.environ.get("OPENAI_API_KEY", "sk-placeholder")
# 如果你使用 openai-compatible 的 embedding API，修改上面这行

MEM0_CONFIG = {
    "version": "v2.0",
    "llm": {
        "provider": "openai",
        "config": {
            "model": os.environ.get("MEM0_LLM_MODEL", "gpt-4o-mini"),
            "openai_base_url": os.environ.get("OPENAI_BASE_URL", ""),
            "api_key": GO_API_KEY,
        }
    },
    "embedder": {
        "provider": "huggingface",
        "config": {
            "model": LOCAL_MODEL_PATH,
        }
    },
    "vector_store": {
        "provider": "chroma",
        "config": {
            "path": os.path.expanduser("~/.cache/mem0_data"),
            "collection_name": "chat_memories",
        }
    },
}

memory = Memory.from_config(MEM0_CONFIG)
server = Server("mem0")

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="recall",
            description="搜索对话记忆，查找用户之前说过的事实、偏好、习惯、项目信息等。每次用户提问时都应该先用这个工具搜索相关记忆。",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "搜索关键词，用中文描述你要找的内容"},
                    "user_id": {"type": "string", "description": "用户ID，默认 current"},
                    "top_k": {"type": "number", "description": "返回几条结果，默认5"}
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="remember",
            description="保存一条新记忆。每次对话结束后，把用户的关键信息（偏好、习惯、事实、决定）存起来。",
            inputSchema={
                "type": "object",
                "properties": {
                    "text": {"type": "string", "description": "要记住的内容"},
                    "user_id": {"type": "string", "description": "用户ID"}
                },
                "required": ["text"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "recall":
        results = memory.search(
            arguments["query"],
            filters={"user_id": arguments.get("user_id", "current")},
            top_k=arguments.get("top_k", 5)
        )
        memories = [r["memory"] for r in results["results"]]
        return [{"type": "text", "text": json.dumps(memories, ensure_ascii=False)}]
    elif name == "remember":
        memory.add(arguments["text"], user_id=arguments.get("user_id", "current"))
        return [{"type": "text", "text": "ok"}]
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, InitializationOptions(
            server_name="mem0", server_version="1.0.0",
            capabilities=server.get_capabilities(
                notification_options=NotificationOptions(), experimental_capabilities={},
            ),
        ))

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

### Phase 6: Deploy skill files

The 40+ skill files are too numerous to embed inline. Do this:

**Option A — Copy from existing install (recommended):**
If you already have these skills on another machine, copy them over:

```bash
# From the machine that has the skills
tar czf opencode-skills.tar.gz -C ~/.config/opencode/skills .
# Transfer and extract on the new machine
tar xzf opencode-skills.tar.gz -C ~/.config/opencode/skills/
```

**Option B — Clone from git repo:**

```bash
git clone https://github.com/kurumi1ksllq/opencode-skills.git /tmp/opencode-skills
cp -r /tmp/opencode-skills/* ~/.config/opencode/skills/
```

**Option C — Manual creation:**
If no source is available, create each skill directory individually. The skills needed are:

```
agent-skills/     → api-and-interface-design, browser-testing-with-devtools, ci-cd-and-automation,
                    code-review-and-quality, code-simplification, context-engineering,
                    debugging-and-error-recovery, deprecation-and-migration, documentation-and-adrs,
                    doubt-driven-development, frontend-ui-engineering, git-workflow-and-versioning,
                    idea-refine, incremental-implementation, interview-me,
                    observability-and-instrumentation, performance-optimization,
                    planning-and-task-breakdown, security-and-hardening, shipping-and-launch,
                    source-driven-development, spec-driven-development, using-agent-skills

engineering/      → grill-with-docs, improve-codebase-architecture, prototype,
                    setup-matt-pocock-skills, to-issues, to-prd, triage, zoom-out

in-progress/     → handoff, writing-beats, writing-fragments, writing-shape

misc/            → git-guardrails-claude-code, migrate-to-shoehorn, organize-tracks,
                    scaffold-exercises, setup-pre-commit, token-usage

personal/        → edit-article, obsidian-vault

productivity/    → caveman, write-a-skill
```

Each skill needs a `SKILL.md` file in its directory. The skill files contain specialized instructions for the AI agent. If no repo is available, ask the user to provide the original skill files.

### Phase 7: Install plugin npm dependencies

```bash
cd ~/.config/opencode
npm init -y
npm install @opencode-ai/plugin
# Plugins in opencode.json will auto-install on OpenCode restart
```

### Phase 8: Set environment variables

The user must set these environment variables (or update opencode.json directly):

| Variable       | Purpose                    | Example                         |
| -------------- | -------------------------- | ------------------------------- |
| `LLM_BASE_URL` | LLM provider endpoint      | `https://api.openai.com/v1`     |
| `LLM_API_KEY`  | LLM provider API key       | `sk-...`                        |
| `GITHUB_TOKEN` | GitHub API token (for MCP) | `ghp_...`                       |
| `MODEL_ID`     | Default model ID           | `gpt-4o` or `deepseek-v4-flash` |

Alternatively, edit `opencode.json` directly to hardcode these values.

### Phase 9: Verify

After restarting OpenCode, verify:

- [ ] `opencode` starts without config errors
- [ ] MCP servers connect: mem0, codegraph, context7, github
- [ ] Agent commands work: `/oracle`, `/momus`
- [ ] Command works: `/tokenscope`
- [ ] Skills load: AI should recognize available skills

---

## Sharing

To distribute this config to others:

1. Push the skill directory to a GitHub repo
2. Others clone it and copy to their `~/.agents/skills/` or `~/.config/opencode/skills/` directory
3. When they tell their AI "deploy opencode bootstrap", the AI executes this skill

Or just share the SKILL.md file — AI can follow the instructions from any context.
