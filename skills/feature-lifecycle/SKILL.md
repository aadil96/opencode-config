---
name: feature-lifecycle
description: >-
  Turn feature requests into delivered functionality through a structured
  lifecycle. Use when implementing new features or capabilities.
---

# Feature Lifecycle

## Purpose
Turn a feature request into delivered, verified functionality through a repeatable process from requirements to deployment.

## Trigger Conditions
- New feature request received
- Feature identified during roadmap planning
- Enhancement to existing functionality that changes behavior
- New capability scoped by CEO or PM

## Participants
| Role | Responsibility |
|------|---------------|
| PM | Requirements definition, acceptance criteria, priority |
| CTO | Architecture review, technical feasibility |
| Coder | Implementation |
| Reviewer | Code review |
| QA | Test strategy, quality validation |
| DevOps | Deployment planning |
| Security | Security review (if auth/data sensitive) |

## Entry Conditions
- [ ] Feature request documented and approved
- [ ] Priority assigned by PM/CEO
- [ ] Stakeholders identified
- [ ] Dependencies evaluated (no blocking external blockers)

## Exit Conditions
- [ ] Feature implemented and code reviewed
- [ ] QA validated against acceptance criteria
- [ ] Deployed to production
- [ ] Monitoring confirms healthy behavior
- [ ] Documentation updated

## Process Steps
1. **Refine** — PM converts feature request to requirements with acceptance criteria
2. **Design** — Coder/CTO produces architecture sketch or RFC for non-trivial features
3. **Implement** — Coder implements per requirements using standard development workflow
4. **Review** — Reviewer audits implementation against acceptance criteria and code standards
5. **Validate** — QA runs acceptance tests, regression tests, and edge case validation
6. **Deploy** — DevOps stages rollout per deployment-lifecycle
7. **Verify** — Post-deployment monitoring confirms feature works as expected

## Validation Gates
| Gate | Check | Owner |
|------|-------|-------|
| Requirements approved | Acceptance criteria defined and signed off | PM |
| Design approved | Architecture review passed (if needed) | CTO |
| Code review passed | No Critical/Major issues open | Reviewer |
| QA passed | All acceptance tests pass, no regressions | QA |
| Security cleared | Threat model reviewed (if needed) | Security |
| Deployment healthy | Monitoring OK, no error spikes | DevOps |

## Failure Handling
| Failure Mode | Action |
|-------------|--------|
| Requirements incomplete | Return to PM for refinement |
| Architecture concerns | Escalate to CTO before implementation proceeds |
| Review fails | Coder addresses findings, re-review required |
| QA fails | Bug filed, feature blocked until resolved |
| Deployment fails | Rollback, diagnose, retry per deployment-lifecycle |
| Production issue | Incident created per incident-lifecycle |

## Escalation Path
- **Technical blockers** → CTO resolves architecture/implementation disputes
- **Scope creep** → PM re-evaluates priority against original requirements
- **Cross-team dependencies** → PM coordinates with dependent teams
- **Priority conflict** → CEO provides go/no-go decision
