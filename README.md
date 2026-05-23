# OpenCode Config — Multi-Agent Orchestration & Production Guardrails

Production-grade configuration for [OpenCode](https://opencode.ai) — multi-agent orchestration, a skills library, TypeScript plugins, and project templates for building and shipping software safely.

## What It Is

OpenCode Config transforms OpenCode from a single-agent coding assistant into a **production-grade orchestration system**. It provides:

- **Multi-agent organization** — specialized agents for strategy, architecture, development, operations, quality, security, and finance
- **23 production skills** — battle-tested workflows for architecture decisions, code review, deployment, incident response, and more
- **TypeScript plugins** — background agents, notifications, workspace management, and git worktree integration
- **Project templates** — ready-made archetypes for SaaS platforms, CLI tools, backend services, frontend apps, libraries, and infrastructure

## Prerequisites

| Tool | Required | Notes |
|------|----------|-------|
| **[OpenCode](https://opencode.ai)** | Yes | Must be installed and working |
| **[AgentMemory](https://github.com/rohitg00/agentmemory)** | Recommended | Persistent memory layer with knowledge graph — requires an LLM API key |

This repo does **not** install OpenCode. It assumes you already have it.

## What's Inside

### Agents

**Organization Agents** — strategic and operational roles that plan, review, and govern:

| Agent | Role |
|-------|------|
| `ceo` | Strategy, prioritization, and cross-functional coordination |
| `cto` | Architecture decisions, technology selection, and technical strategy |
| `devops` | Infrastructure, CI/CD, deployment pipelines, and observability |
| `finance` | Cost analysis, optimization, and build-vs-buy decisions |
| `pm` | Feature lifecycle, planning, and milestone tracking |
| `qa` | Test strategy, bug triage, and quality gates |
| `security` | Threat modeling, security review, and policy enforcement |

**Execution Agents** — hands-on implementation roles:

| Agent | Role |
|-------|------|
| `coder` | Implementation, refactoring, and bug fixes |
| `researcher` | External research, API discovery, and documentation |
| `reviewer` | Code review against quality standards |
| `scribe` | Documentation, changelogs, and human-facing prose |

### Skills (21 Total)

Production-ready workflows that agents invoke for structured decision-making and execution:

| Skill | Purpose |
|-------|---------|
| `architecture-principles` | System architecture principles and technology selection criteria |
| `architecture-lifecycle` | RFCs and ADRs for systematic architecture decisions |
| `chezmoi-expert` | Expert chezmoi dotfiles management with templates and secrets |
| `bug-lifecycle` | Triage, fix, and verify bugs through a structured process |
| `code-philosophy` | The 5 Laws of Elegant Defense — backend code quality standards |
| `code-review` | Comprehensive review methodology with severity classification |
| `continuous-improvement` | Pattern analysis and process improvement recommendations |
| `cost-optimization` | Cost analysis, optimization, and build-vs-buy framework |
| `decision-framework` | Lightweight decision-making for evaluating trade-offs |
| `decision-history` | Capture decisions with rationale, tradeoffs, and consequences |
| `deployment-lifecycle` | Staged rollout and rollback for safe releases |
| `feature-lifecycle` | Structured process for implementing new features |
| `frontend-philosophy` | The 5 Pillars of Intentional UI — frontend quality standards |
| `incident-lifecycle` | Production incident response with minimal impact |
| `org-audit` | Record organization routing effectiveness and agent selection accuracy |
| `org-governance` | Shared governance, separation of duties, and interaction patterns |
| `org-routing` | Agent routing — when to consult each organization role |
| `plan-protocol` | Guidelines for creating and managing implementation plans |
| `plan-review` | Criteria for reviewing plans against quality standards |
| `postmortem` | Analyze completed work for successes, failures, and root causes |
| `security-policies` | Security policies, threat modeling, and dependency review |

### Plugins

TypeScript plugins that extend OpenCode's runtime capabilities:

| Plugin | Purpose |
|--------|---------|
| `background-agents` | Run agents asynchronously for long-running tasks |
| `notify` | Desktop and terminal notifications for agent events |
| `workspace` | Multi-project workspace management and context switching |
| `worktree` | Git worktree integration for parallel branch workflows |

### Templates

**Project Archetypes** — scaffolding for common project types:

- `saas-platform` — multi-tenant SaaS with auth, billing, and API
- `cli-tool` — command-line application with argument parsing
- `backend-service` — REST/GraphQL service with database integration
- `frontend-app` — SPA with routing, state management, and UI kit
- `library` — reusable package with build, test, and publish setup
- `infrastructure` — IaC for cloud resources and deployment pipelines

**Component Templates** — reusable patterns for common building blocks.

**Workflow Templates** — pre-configured agent chains for recurring tasks.

### Commands

Slash commands available in OpenCode sessions:

| Command | Purpose |
|---------|---------|
| `/review` | Trigger a structured code review |

### Profiles

Configuration profiles for different contexts:

- **Default** — full orchestration with all agents, skills, and plugins
- **Workspace** — project-specific overrides for agent permissions, tools, and context

### Tools

MCP tools for agent operations:

- **Delegation** — parallel background work with async result retrieval
- **Memory** — long-term context storage, search, and consolidation
- **Web Search** — real-time information retrieval

## Setup

```bash
git clone https://github.com/aadil96/opencode-config.git
cd opencode-config
./scripts/setup.sh
```

### What the Setup Script Does

1. **Checks prerequisites** — verifies OpenCode is installed and AgentMemory is available
2. **Backs up existing config** — copies `~/.config/opencode/` to `~/.config/opencode.bak.<timestamp>/`
3. **Installs everything** — agents, skills, plugins, templates, commands, and profiles
4. **Asks before overwriting** — prompts on conflicts, never silently replaces your config
5. **Offers AgentMemory systemd setup** — optional background service for the memory layer

The script is **idempotent** — safe to run multiple times.

## AgentMemory Setup

The memory layer works best with AgentMemory running as a background service. A systemd service template is provided and the setup script can install it automatically.

AgentMemory requires an LLM API key for graph extraction and consolidation. Set one of these environment variables:

| Provider | Environment Variable |
|----------|---------------------|
| OpenAI | `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Google | `GOOGLE_API_KEY` |
| Ollama | `OLLAMA_BASE_URL` |

See [AgentMemory LLM Providers](https://github.com/rohitg00/agentmemory#llm-providers) for the full list.

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding agents, skills, plugins, and templates.

## License

MIT — see [LICENSE](LICENSE).
