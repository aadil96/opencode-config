---
name: deployment-lifecycle
description: >-
  Deliver releases to production safely with staged rollout and rollback
  capability. Use when deploying to any environment.
---

# Deployment Lifecycle

## Purpose
Deliver software releases to production with minimal risk through controlled, observable rollout with clear rollback criteria.

## Trigger Conditions
- Release candidate approved by QA
- Hotfix needed for production issue
- Scheduled release window approaching
- Infrastructure change required

## Participants
| Role | Responsibility |
|------|---------------|
| DevOps | Deployment execution, monitoring, rollback |
| Coder | Release support, on-call during deployment |
| QA | Release candidate validation |
| CTO | Rollback authorization (if criteria exceeded) |
| SRE-Reviewer | Infrastructure readiness review |
| Security | Security scan of release artifacts |

## Entry Conditions
- [ ] Release candidate built and versioned
- [ ] QA signed off on release candidate
- [ ] Changelog/Release notes prepared
- [ ] Rollback plan documented
- [ ] Monitoring dashboards confirmed operational
- [ ] On-call notified

## Exit Conditions
- [ ] Release deployed to all targets
- [ ] Monitoring green for observation period
- [ ] No rollback triggered during rollout
- [ ] Release communicated to stakeholders

## Process Steps
1. **Prepare** — DevOps validates artifacts, confirms environments ready, checks runbooks
2. **Verify readiness** — Pre-flight checks: health endpoints, dependency availability, capacity
3. **Stage deploy** — Deploy to canary/percentage, monitor for observation period
4. **Monitor** — Watch error rates, latency, resource usage, business metrics
5. **Expand** — Increase rollout percentage or promote to full
6. **Complete** — Mark release complete, archive artifacts, update status
7. **Verify** — Post-deployment smoke tests and sustained monitoring

## Validation Gates
| Gate | Check | Owner |
|------|-------|-------|
| RC approved | QA sign-off on release artifact | QA |
| Pre-flight passed | Health checks, dependencies, capacity | DevOps |
| Canary healthy | No error spike in observation window | DevOps |
| Rollback criteria defined | Thresholds documented before deploy | DevOps |
| Post-deploy verified | Smoke tests pass in production | QA |

## Failure Handling
| Failure Mode | Action |
|-------------|--------|
| Pre-flight fails | Halt deploy, diagnose, fix, re-enter at prepare |
| Canary shows errors | Automatic rollback, investigate root cause |
| Partial rollout fails | Roll back to previous version |
| Post-deploy regression | Create bug, assess if rollback needed |
| Monitoring anomaly | Hold expansion, investigate before proceeding |

## Escalation Path
- **Rollback threshold breached** — Automatic rollback, CTO notified
- **Failed deployment** — DevOps + Coder diagnose, CTO decides retry or abort
- **Environment issue** — DevOps escalates to infrastructure team
- **Security concern** — Security halts deployment, assesses risk
