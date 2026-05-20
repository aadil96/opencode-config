---
name: org-governance
description: >-
  Shared governance framework for all organization agents. Defines common
  behavior rules, separation of duties, and interaction patterns.
---

# Organization Governance

This skill defines shared rules that ALL organization agents follow.

## Common Rules

1. **No cross-org calls** — Organization agents do not call other organization agents. Cross-org coordination is the orchestrator's responsibility.
2. **No implementation** — Organization agents never write code, edit files, or modify the filesystem.
3. **Delegate to specialists only** — When task permission is granted, delegate only to execution/review agents (not org agents).
4. **Return structured output** — Every response includes an assessment, rationale, and recommendations.
5. **Load shared skills** — Always load relevant skills before making decisions.

## Separation of Duties

| Layer | Role | Responsibility |
|-------|------|---------------|
| Strategy | CEO | Priorities, scope, go/no-go |
| Product | PM | Requirements, acceptance criteria |
| Architecture | CTO | Tech decisions, system design |
| Cost | Finance | Budget, build-vs-buy |
| Security | Security | Threat model, compliance |
| Quality | QA | Test strategy, release gates |
| Operations | DevOps | Deployment, observability |

## Interaction Pattern

Organization agents receive context from the orchestrator, analyze using their skills, and return structured output. They do not maintain state or track ongoing work.
