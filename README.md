# opencode-config

My global [opencode.ai](https://opencode.ai) configuration: agents, skills, plugins, MCP servers, and commands.

## Prerequisites

These external tools are needed for the full configuration to work:

| Tool | Purpose | Install |
|------|---------|---------|
| **bun** | Runtime for opencode plugins | `npm install -g bun` |
| **agentmemory** | Persistent memory MCP server | `npm install -g @agentmemory/agentmemory` — then run `agentmemory` in the background. Requires the **iii** engine ([download](https://github.com/iii-hq/iii/releases)). [Docs](https://github.com/rohitg00/agentmemory) |
| **OCX** _(optional)_ | Opencode extension manager for kdco plugins | `npm install -g ocx`, then `ocx registry add https://registry.kdco.dev --name kdco` and `ocx add kdco/workspace`. [Docs](https://github.com/kdcokenny/ocx) |

> **Note:** The core config works without OCX/kdco plugins — they are optional enhancements. AgentMemory is the only required external service for the MCP memory integration.

### Bootstrap with mise

A `mise.toml` is provided for convenience. Run `mise install` to bootstrap node, bun, ocx, and agentmemory in one command. The **iii** engine still needs manual installation (see link above).

> **mise users:** If you installed agentmemory via `mise.toml`, you can change the MCP command in `opencode.jsonc` to `["mise", "exec", "--", "agentmemory-mcp"]` for faster startup (avoids npx overhead).

## Install

```bash
git clone https://github.com/aadil96/opencode-config.git ~/.config/opencode
cd ~/.config/opencode && bun install
```

Or via chezmoi `.chezmoiexternal.toml`:

```toml
[".config/opencode"]
    type = "git-repo"
    url = "https://github.com/aadil96/opencode-config.git"
    refreshPeriod = "168h"
```

## What's inside

- **`agent/`** — execution agents (coder, researcher, reviewer, scribe) with scoped permissions
- **`agents/`** — organization agents (ceo, cto, devops, finance, pm, qa, security) for the `build` orchestrator pattern
- **`skills/`** — 20+ skills covering planning, code review, architecture, governance, incident response
- **`command/`** — slash commands
- **`plugin/`** — TypeScript plugins (worktree, notify, workspace, background-agents)
- **`tools/opencode-init`** — project scaffolding script
- **`templates/`** — project archetype templates

## Required environment variables

Some MCP servers expect env vars at runtime:
- `LINEAR_API_KEY` — for the Linear MCP server

Set these in your shell rc file or via direnv.

## License

MIT — see `LICENSE`.
