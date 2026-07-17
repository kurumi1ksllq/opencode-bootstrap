---
name: opencode-bootstrap
description: COMPLETELY SELF-CONTAINED opencode environment bootstrapper. No prerequisites, no manual steps. Installs all MCP servers, plugin system (including superpowers), custom agents, commands, config files, and 40+ AI skills from a single repo. Use when setting up OpenCode from scratch, or when user says "bootstrap", "deploy config", "setup opencode", "init my environment", "install superpowers".
---

# OpenCode Bootstrap

This skill deploys a complete OpenCode AI framework to `~/.config/opencode/`. After setup, the user just restarts OpenCode and everything is ready.

## What gets installed

- **MCP Servers**: mem0 (memory), codegraph (code intelligence), context7 (docs), github (API)
- **Plugins**: DCP, oh-my-openagent, tokenscope, firecrawl, superpowers (auto-installed via `"plugin"` array)
- **Config**: opencode.json, AGENTS.md, oh-my-openagent.json, dcp.jsonc
- **Agents**: oracle (adviser), momus (reviewer)
- **Commands**: tokenscope
- **Skills**: 40+ across 6 categories (~70 files)

---

## Execution Plan

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

### Phase 1: Clone this repo

While in the user's home directory, clone the repo and enter it:

```bash
cd
git clone https://github.com/kurumi1ksllq/opencode-bootstrap.git /tmp/opencode-bootstrap
cd /tmp/opencode-bootstrap
```

### Phase 2: Install system dependencies

Run the appropriate install script to install Python and npm packages:

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/install-deps.ps1
```

**macOS/Linux:**

```bash
bash scripts/install-deps.sh
```

If a script fails, install manually:

```bash
pip install mcp mem0ai          # mem0 MCP
npm install -g @opencode-ai/codegraph   # codegraph MCP (fallback: use npx)
```

### Phase 3: Create directory structure

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

### Phase 4: Write configuration files

Copy `payload/opencode.json`, `payload/AGENTS.md`, `payload/oh-my-openagent.json`, `payload/dcp.jsonc` to `~/.config/opencode/`.

**IMPORTANT**: For opencode.json, the AI must first read the file and replace all `${VAR}` placeholder values with the user's actual values before copying. Ask the user for any missing environment variables:

| Placeholder    | What to ask                                                                      |
| -------------- | -------------------------------------------------------------------------------- |
| `CONFIG_DIR`   | "What's your OpenCode config directory? (default: ~/.config/opencode)"           |
| `LLM_BASE_URL` | "What's your LLM provider endpoint? (e.g. http://220.205.16.48:20005/v1)"        |
| `LLM_API_KEY`  | "What's your LLM API key?"                                                       |
| `MODEL_ID`     | "What's your default model ID? (e.g. deepseek-v4-flash)"                         |
| `MODEL_NAME`   | "What's the display name for your model? (e.g. DeepSeek V4 Flash)"               |
| `GITHUB_TOKEN` | "What's your GitHub Copilot token for MCP access?"                               |
| `GO_API_KEY`   | "What's your GO (OpenRouter/OpenCode) API key for mem0?"                         |
| `PYTHON_PATH`  | "What's your Python executable path? (e.g. D:\ProgramData\miniconda\python.exe)" |

For `oh-my-openagent.json`, replace `${MODEL_ID}` with the model name the user chooses.

Use the `edit` tool to replace placeholders in the payload file, then copy it to the target location.

### Phase 5: Write agent and command definitions

Copy `payload/agents/oracle.md` → `~/.config/opencode/agents/oracle.md`
Copy `payload/agents/momus.md` → `~/.config/opencode/agents/momus.md`
Copy `payload/commands/tokenscope.md` → `~/.config/opencode/commands/tokenscope.md`

### Phase 6: Write MCP server script

Copy `payload/mem0_mcp.py` → `~/.config/opencode/mem0_mcp.py`

### Phase 7: Deploy skill files

Copy ALL skill directories from `payload/skills/` to `~/.config/opencode/skills/` — preserving the entire directory structure. Each subdirectory under `payload/skills/` contains a SKILL.md and optionally reference files/scripts.

```bash
# Windows
Copy-Item -Recurse -Path "payload/skills\*" -Destination "~/.config/opencode/skills\" -Force

# macOS/Linux
# cp -r payload/skills/* ~/.config/opencode/skills/
```

### Phase 8: Install plugin npm dependencies

```bash
cd ~/.config/opencode
npm init -y
npm install @opencode-ai/plugin
npm install superpowers@github:obra/superpowers
# Plugins will auto-install on OpenCode restart
```

### Phase 9: Symlink or copy to .agents/skills/

So the bootstrap skill remains discoverable in future sessions:

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

### Phase 10: Set environment variables & verify

Tell the user:

1. Restart OpenCode
2. Verify MCP servers connect (mem0, codegraph, context7, github)
3. Test `/oracle` and `/momus` agents work
4. Test `/tokenscope` command works

If any issues, check `~/.config/opencode/opencode.json` for correct values.

---

## After setup

The user can now use all 40+ skills. The bootstrap skill itself is also available — if they ever need to redeploy, just say "bootstrap" again.

Everything is in this single repo. No need for a second repo.
