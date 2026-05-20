# Implementation Plan — OpenCode Config Guardrails

## Goal
Create `.opencode/` directory with project-specific runtime context — kept out of git via `.gitignore`. AgentMemory is an organizational intelligence layer that augments decision making. Add setup script, README, and systemd template for open-source distribution.

## Context & Decisions

| Decision | Rationale | Source |
|----------|-----------|--------|
| `.opencode/` not `.github/` or root | OpenCode-specific guardrails belong in `.opencode/`; keeps root clean | User request |
| Keep out of git via `.gitignore` | Contains personal workflow preferences, machine-specific settings, should not leak into open-source repo | User request |
| Do NOT override `opencode.jsonc` | User explicitly said not to override; `.opencode/` supplements, not replaces | User request |
| Separate concerns into subdirectories | `guards/`, `workflows/`, `checklists/`, `references/` for clarity | Standard practice |
| AgentMemory augments decisions | Memory is an intelligence layer, not a passive store; capture broadly, consolidate over time | User request |
| Confidence-based capture | High confidence: architecture/workflows/patterns. Medium: lessons/bugs. Low: temporary observations. Consolidation filters noise. | User decision |
| Custom setup script (no chezmoi) | Other users won't have managed dotfiles; keep it simple and dependency-light | User decision |
| Target existing OpenCode users only | Assume opencode is installed; README links to opencode.ai for installation | User decision |
| Ask before overwrite + mandatory backup | Prompt on conflicts, but always backup existing config first | User decision |
| Two-layer architecture: OS org at `~/.config/opencode/`, project context at `<repo>/.opencode/` | Global org manages agents/skills/workflows/routing/governance. Project layer holds identity, stack, local workflows, memory. No duplication of org policies. | User decision |
| Memory expiration + supersession | Low confidence decays if unused. New decisions supersede old ones with historical preservation. Prevents memory pollution and conflicting knowledge. | User decision |

---

## Phase 1: Create `.opencode/` directory and files

- [ ] **1.2** Create `.opencode/AGENTS.md` — project-level instruction file
  - Session startup: workflow → project context → memory augmentation → action
  - Never commit to main without explicit instruction
  - Pre-commit mandatory steps (status → diff → scan → add -A → cached diff → commit)
  - Pre-push mandatory steps (PR draft → review diff → mark ready)
  - Open-source rules: no secrets, no personal paths, no machine-specific config
  - Right and duty to push back on requests that don't make sense
  - AgentMemory augments decisions — query context before acting, capture after deciding
  - This is project context only — global org policies live in `~/.config/opencode/`
  - Reference to all sub-files
- [ ] 1.3 Create `.opencode/guards/pre-commit.md`
- [ ] 1.4 Create `.opencode/guards/pre-push.md`
- [ ] 1.5 Create `.opencode/guards/sensitive-scan.md`
- [ ] 1.6 Create `.opencode/workflows/session-start.md`
  - Flow: workflow → project context → memory augmentation → action
  - Memory recall augments context, does not drive action directly
- [ ] 1.7 Create `.opencode/workflows/branch-lifecycle.md`
- [ ] 1.8 Create `.opencode/workflows/pr-lifecycle.md`
- [ ] 1.9 Create `.opencode/workflows/memory-lifecycle.md` — INTELLIGENCE LAYER
  - Session start: workflow → project context → memory augmentation → action
  - During work: confidence-based auto-capture:
    - High confidence: architecture decisions, workflows, stable patterns
    - Medium confidence: lessons, bug patterns
    - Low confidence: temporary observations
  - Session end: consolidate (episodic → semantic → procedural) → reflect → filter noise
  - Memory expiration/decay policy:
    - Low confidence: archive/remove after defined inactivity period if never reused
    - Medium confidence: consolidate when repeated patterns emerge
    - High confidence: retain until explicitly superseded
  - Supersession rules:
    - New decisions can supersede previous decisions
    - When newer decisions conflict with older ones: mark previous as superseded, preserve historical record, use newest active decision
    - Example: 2026 "Use Jenkins" → superseded by 2027 "Use GitHub Actions"
  - Periodic cleanup: diagnose, deduplicate, archive stale sessions
- [ ] 1.10 Create `.opencode/workflows/changelog-update.md`
  - Session end → summarize work → evaluate significance → update changelog if threshold met
  - Changelog evaluator inputs: git diff, commit messages, changed files, workflow changes, agent changes, breaking changes, setup/install changes
  - Always update: new feature, workflow added, agent behavior change, architectural decision, breaking change, security change, setup/install change
  - Usually update: meaningful bug fixes, performance improvements, major prompt refinement
  - Never update: typo fixes, formatting, comments, temporary experiments, internal refactors with no user impact
  - Workflow: Work completed → QA validates → Reviewer summarizes diff → Changelog evaluator (uses concrete inputs) → Meaningful? Yes → update CHANGELOG.md / No → skip
  - Keep separate histories: CHANGELOG.md (public meaningful changes) vs memory/decision-history.md (internal operational learning)
- [ ] 1.11 Create `.opencode/checklists/open-source.md`
- [ ] 1.12 Create `.opencode/checklists/architecture.md`
- [ ] 1.13 Create `.opencode/checklists/memory-capture.md`
  - Confidence-based capture:
    - High confidence: architecture decisions, workflows, stable patterns
    - Medium confidence: lessons, bug patterns
    - Low confidence: temporary observations
  - Capture broadly, consolidate and filter over time
  - Tagging conventions, confidence thresholds, periodic cleanup
- [ ] 1.14 Create `.opencode/routing/classify-request.md`
  - Purpose: Classify incoming user requests and return workflow + agent chain
  - Flow: User request → Classify request → Select workflow → Generate agent chain → Execute
  - Examples:
    - Feature request → feature-development → PM → CTO → Security → Build → QA → DevOps
    - Bug report → bug-fix → PM → Build → QA
    - Production issue → incident-response → DevOps → Security → QA
    - Architecture question → architecture-review → CTO → Security → QA
  - Workflow selection directly produces execution ownership
- [ ] 1.15 Create `.opencode/routing/workflow-selection.md`
  - Maps classified requests to workflow files
  - Defines agent chain generation rules
  - References global org workflows in `~/.config/opencode/`
- [ ] 1.16 Create `.opencode/checklists/routing.md`
- [ ] 1.17 Create `.opencode/references/tools.md`
  - Include all AgentMemory tools
- [ ] 1.18 Create `.opencode/references/skills.md`
- [ ] 1.19 Create `.opencode/references/agents.md`
- [ ] 1.20 Create `.opencode/references/plugins.md`

## Phase 2: Update `.gitignore`

- [ ] 2.1 Add `.opencode/` to `.gitignore` with comment explaining why

## Phase 3: Create supporting open-source files

- [ ] 3.1 Create `CONTRIBUTING.md`
- [ ] 3.2 Create `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] 3.3 Create `.github/CODEOWNERS`
- [ ] 3.4 Create `CHANGELOG.md` — initial file with Keep a Changelog format
- [ ] 3.5 Update `README.md` — comprehensive documentation:
  - **Who this is for**: Existing OpenCode users who want production-grade config
  - **Prerequisites**: OpenCode installed, agentmemory available
  - **What it does**: Adds guardrails, agents, skills, workflows, project context, memory intelligence layer
  - **What it does NOT do**: Install OpenCode, override existing config without asking
  - **Setup instructions**: Run `./scripts/setup.sh`
  - **Conflict handling**: Backs up existing config, asks before overwriting
  - **AgentMemory setup**: Systemd service template for background operation

## Phase 4: Setup script and systemd template

- [ ] 4.1 Create `scripts/setup.sh`
  - Check prerequisites: opencode installed, agentmemory available
  - Backup existing `~/.config/opencode/` to `~/.config/opencode.bak.<timestamp>/`
  - Copy new files (skip existing, ask before overwriting conflicts)
  - Offer to set up agentmemory systemd service
  - Idempotent — safe to run multiple times
- [ ] 4.2 Create `templates/agentmemory.service.tmpl`
  - Systemd service template with placeholders:
    - `{{USER}}` — current username
    - `{{HOME}}` — home directory path
    - `{{NODE_PATH}}` — node/npx path
  - Instructions in README for replacing placeholders
  - Enable and start service

## Phase 5: Fix current `mise.toml` situation

- [ ] 5.1 Verify PR #3 branch state and whether it's merged
- [ ] 5.2 If merged, create new PR to remove `mise.toml` entirely
- [ ] 5.3 If not merged, amend to remove `mise.toml`

---

## Notes

- 2026-05-20: User identified multiple workflow failures: no branch awareness, partial commits, no diff review, no sensitive data scan, blind execution. All guardrails address these.
- 2026-05-20: `mise.toml` identified as inappropriate for this repo — reviewed by CTO analysis delegation.
- 2026-05-20: `.opencode/` must stay out of git — it's personal workflow enforcement, not open-source content.
- 2026-05-20: User requested CHANGELOG.md with auto-update after each session.
- 2026-05-20: AgentMemory is an organizational intelligence layer — confidence-based capture (high/medium/low) with consolidation filtering.
- 2026-05-20: Two-layer architecture: global org at `~/.config/opencode/` (agents/skills/workflows/routing/governance), project context at `<repo>/.opencode/` (identity/stack/local workflows/memory).
- 2026-05-20: User decided on custom setup script (no chezmoi), existing users only, ask-before-overwrite with mandatory backup.
