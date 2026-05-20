# opencode-config

My global [opencode.ai](https://opencode.ai) configuration: agents, skills, plugins, MCP servers, and commands.

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
