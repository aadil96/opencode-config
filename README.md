# OpenCode Config Guardrails

Production-grade configuration guardrails for [OpenCode](https://opencode.ai).

## Who This Is For

Existing OpenCode users who want a hardened, production-ready configuration with mandatory guardrails, agent routing, workflow enforcement, and a memory intelligence layer. If you already have OpenCode installed and want to add safety checks and structure to your workflow, this is for you.

## Prerequisites

| Tool | Required | Notes |
|------|----------|-------|
| **[OpenCode](https://opencode.ai)** | Yes | Must be installed and working |
| **AgentMemory** | Recommended | Background memory MCP server for the intelligence layer |

This repo does **not** install OpenCode for you. It assumes you already have it.

## What It Does

- **Enforces mandatory pre-commit guardrails** — status check, diff review, sensitive data scan before every commit
- **Enforces mandatory pre-push guardrails** — PR draft workflow, review diff, mark ready before every push
- **Scans for sensitive data** — detects API keys, tokens, secrets, and personal paths before they leak
- **Routes agent requests** — classifies incoming requests and selects the right workflow + agent chain
- **Enforces workflows** — session start, branch lifecycle, PR lifecycle, memory lifecycle
- **Provides project context layer** — `.opencode/` directory with identity, stack, and local workflows
- **Adds memory intelligence layer** — confidence-based capture, consolidation, expiration, and supersession

## What It Does NOT Do

- Install OpenCode — you need to install that yourself
- Override your existing `opencode.jsonc` without asking — the setup script backs up and prompts before overwriting
- Replace your personal dotfiles manager — this supplements, not replaces, chezmoi/home-manager
- Run on its own — this is configuration, not a standalone tool

## Setup

```bash
git clone https://github.com/aadil96/opencode-config.git
cd opencode-config
./scripts/setup.sh
```

### What the Setup Script Does

1. **Checks prerequisites** — verifies OpenCode is installed and AgentMemory is available
2. **Backs up existing config** — copies `~/.config/opencode/` to `~/.config/opencode.bak.<timestamp>/`
3. **Copies new files** — installs agents, skills, workflows, guardrails, and templates
4. **Asks before overwriting** — prompts on conflicts, never silently replaces your config
5. **Offers AgentMemory systemd setup** — optional background service for the memory layer

The script is **idempotent** — safe to run multiple times.

## Directory Structure

```
├── .opencode/              # Project-level runtime context (kept out of git)
│   ├── guards/             # Pre-commit, pre-push, and sensitive-scan guardrails
│   ├── workflows/          # Session, branch, PR, memory, and changelog workflows
│   ├── checklists/         # Open-source safety, architecture, memory capture
│   ├── routing/            # Request classification and workflow selection
│   └── references/         # Tools, skills, agents, plugins reference docs
├── agents/                 # Organization agents (ceo, cto, pm, qa, security, devops, finance)
├── agent/                  # Execution agents (coder, researcher, reviewer, scribe)
├── skills/                 # Skills library (decision frameworks, code review, architecture, etc.)
├── command/                # Slash commands
├── templates/              # Workflow templates and project archetypes
├── scripts/                # Setup and installation scripts
├── .github/                # PR template and CODEOWNERS
├── CONTRIBUTING.md         # Contributing guidelines
├── CHANGELOG.md            # Project changelog
└── README.md               # This file
```

### The `.opencode/` Directory

This directory contains **project-level runtime context** — guardrails, workflows, and local configuration that enforce safe development practices. It is excluded from git via `.gitignore` because it contains personal workflow preferences and machine-specific settings.

| Subdirectory | Purpose |
|-------------|---------|
| `guards/` | Mandatory pre-commit and pre-push checks, sensitive data scanning |
| `workflows/` | Session start, branch lifecycle, PR lifecycle, memory lifecycle, changelog automation |
| `checklists/` | Open-source safety rules, architecture decisions, memory capture guidelines |
| `routing/` | Request classification and workflow selection rules |
| `references/` | Quick-reference docs for tools, skills, agents, and plugins |

## AgentMemory Setup

The memory intelligence layer works best with AgentMemory running as a background service. A systemd service template is provided at `templates/agentmemory.service.tmpl`.

After running `./scripts/setup.sh`, you can enable the service to keep AgentMemory running in the background for persistent memory across sessions.

> **Note:** The setup script auto-detects your agentmemory binary path (mise shims, npm global, or npx fallback). If you use a custom installation path, edit the `ExecStart` line in `~/.config/systemd/user/agentmemory.service` manually.

## LLM Configuration

AgentMemory requires an LLM API key for graph extraction and consolidation. Set one of the following environment variables in your shell rc file or via direnv:

| Provider | Environment Variable | Docs |
|----------|---------------------|------|
| OpenAI | `OPENAI_API_KEY` | [OpenAI docs](https://platform.openai.com/docs) |
| Anthropic | `ANTHROPIC_API_KEY` | [Anthropic docs](https://docs.anthropic.com) |
| Google | `GOOGLE_API_KEY` | [Google AI docs](https://ai.google.dev) |
| Ollama | `OLLAMA_BASE_URL` | [Ollama docs](https://ollama.ai) |

See [AgentMemory LLM Providers](https://github.com/rohitg00/agentmemory#llm-providers) for the full list of supported providers.

## Conflict Handling

If you already have configuration in `~/.config/opencode/`, the setup script will:

1. **Always back up** your existing config to a timestamped backup directory
2. **Ask before overwriting** any file that already exists
3. **Skip files** you choose not to overwrite
4. **Never delete** your existing config — backups are always preserved

You can always restore from backup:
```bash
rm -rf ~/.config/opencode/
mv ~/.config/opencode.bak.<timestamp>/ ~/.config/opencode/
```

## License

MIT — see [LICENSE](LICENSE).
