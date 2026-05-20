# Contributing to OpenCode Config Guardrails

## What This Repo Is For

This repository provides **production-grade OpenCode configuration guardrails** — reusable agents, skills, workflows, checklists, and routing rules that any OpenCode user can adopt. It is a shared resource for the community, not a personal dotfiles store.

## What Belongs in This Repo

- **Reusable guardrails** — pre-commit checks, pre-push checks, sensitive data scanning patterns
- **Agent definitions** — organization agents, execution agents, validation agents
- **Skills** — decision frameworks, code review, architecture lifecycle, incident response
- **Workflows** — session start, branch lifecycle, PR lifecycle, memory lifecycle, changelog automation
- **Checklists** — open-source safety, architecture decisions, memory capture guidelines
- **Routing rules** — request classification, workflow selection
- **Setup scripts and templates** — installation tooling, systemd service templates
- **Documentation** — README, contributing guide, PR template, CODEOWNERS

## What Does NOT Belong

- **Personal paths** — no `/home/*/` paths, no `~/.config/` references, no absolute machine paths
- **Machine-specific config** — no hostnames, no IP addresses, no local URLs
- **Secrets or credentials** — no API keys, no tokens, no passwords, no `.env` files with real values
- **Personal preferences** — no editor themes, no personal aliases, no machine-specific tool versions
- **Dotfiles management** — this is not a chezmoi or home-manager repo

If a change only makes sense on your machine, it does not belong here.

## Open-Source Safety Rules

Every contribution is scanned before merge. Your PR will be rejected if it contains:

| Rule | Examples |
|------|----------|
| No personal paths | `/home/aadil/`, `C:\Users\`, `/Users/john/` |
| No config directory references | `~/.config/`, `%APPDATA%/` |
| No hostnames or IPs | `myserver.local`, `192.168.1.100` |
| No tokens or keys | `sk-...`, `ghp_...`, `xoxb-...` |
| No real secrets in examples | Use `your-api-key-here` placeholders |

## How to Contribute

### 1. Fork and Branch

```bash
git clone https://github.com/YOUR_USERNAME/opencode-config.git
cd opencode-config
git checkout -b feature/your-feature-name
```

Branch naming convention:
- `feature/...` — new features, agents, skills, workflows
- `fix/...` — bug fixes
- `docs/...` — documentation changes
- `chore/...` — maintenance, tooling, CI

### 2. Make Your Changes

Follow existing patterns and conventions. Reference the [directory structure](README.md#directory-structure) in the README for where things belong.

### 3. Verify Locally

Before submitting, run through the [PR checklist](#pr-checklist) below.

### 4. Open a Pull Request

1. Push your branch to your fork
2. Open a PR against the `main` branch
3. Fill out the [PR template](.github/PULL_REQUEST_TEMPLATE.md) completely
4. Mark as **Draft** until ready for review
5. Request review from [code owners](.github/CODEOWNERS)

## PR Requirements

Every PR **must** pass these checks before it can be merged:

### Pre-Commit Guard
- Review your full diff — understand every line you are changing
- Run the sensitive data scan — no secrets, tokens, or personal paths
- Stage all changes with `git add -A`

### Pre-Push Guard
- Open PR as **Draft** first
- Review the diff in the PR view
- Mark as **Ready for Review** only after self-review
- Request review from code owners

### Sensitive Data Scan
All files are checked against these patterns before merge:
- API keys, tokens, secrets (regex patterns for common formats)
- Personal filesystem paths
- Machine-specific identifiers (hostnames, MAC addresses)
- Environment variables with real values

See [.github/PULL_REQUEST_TEMPLATE.md](.github/PULL_REQUEST_TEMPLATE.md) for the full checklist and [.github/CODEOWNERS](.github/CODEOWNERS) for review requirements.

## PR Checklist

Before submitting, verify:

- [ ] No sensitive data (API keys, tokens, secrets, passwords)
- [ ] No personal paths (`/home/*/`, `~/.config/`, absolute paths)
- [ ] No machine-specific config (hostnames, IPs, local URLs)
- [ ] Documentation updated (if behavior changed)
- [ ] CHANGELOG.md updated (if significant change)
- [ ] Pre-commit guard passed (diff reviewed, sensitive scan clean)
- [ ] Pre-push guard passed (PR reviewed as draft first)
- [ ] Answers "Why does this belong in an open-source config repo?"

## Code of Conduct

Be respectful, be constructive, and remember this is a shared resource. This repo exists to make OpenCode safer and more powerful for everyone.
