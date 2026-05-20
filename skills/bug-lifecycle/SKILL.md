---
name: bug-lifecycle
description: >-
  Systematic process for triaging, fixing, and verifying bugs. Use when a bug
  report is received or a defect is identified.
---

# Bug Lifecycle

## Purpose
Resolve defects systematically from report through verified fix, ensuring root cause is understood and the fix does not introduce regressions.

## Trigger Conditions
- Bug report submitted (via any channel)
- Defect identified during testing
- Regression discovered in production
- Security vulnerability reported

## Participants
| Role | Responsibility |
|------|---------------|
| PM | Triage, severity assignment, priority |
| Coder | Investigation, fix implementation |
| Reviewer | Fix review |
| QA | Reproduction, fix verification, regression testing |
| Security | Vulnerability triage (security bugs only) |
| DevOps | Hotfix deployment (production-critical only) |

## Entry Conditions
- [ ] Bug described with clear steps to reproduce
- [ ] Expected vs actual behavior documented
- [ ] Environment/version identified
- [ ] Severity labeled (P0-P3)

## Exit Conditions
- [ ] Root cause identified and documented
- [ ] Fix implemented and reviewed
- [ ] QA verified fix and ran regression suite
- [ ] Fix deployed (per severity-appropriate process)
- [ ] Bug tracker updated with resolution

## Process Steps
1. **Triage** — PM classifies severity, assigns owner, sets priority
2. **Reproduce** — Coder/QA confirms reproduction in target environment
3. **Investigate** — Coder identifies root cause using systematic debugging
4. **Fix** — Coder implements minimal targeted fix
5. **Review** — Reviewer audits fix for correctness and regression risk
6. **Validate** — QA verifies fix, runs regression tests
7. **Deploy** — Deployed per deployment-lifecycle (accelerated for P0/P1)
8. **Verify** — Monitoring confirms fix resolved the issue

## Validation Gates
| Gate | Check | Owner |
|------|-------|-------|
| Triage complete | Severity, priority, and owner assigned | PM |
| Reproduced | Bug confirmed on target version | Coder/QA |
| Root cause identified | Investigation documented before fix attempted | Coder |
| Fix reviewed | No regressions introduced, minimal scope | Reviewer |
| QA validated | Fix confirmed, regression suite green | QA |
| Production verified | Monitoring shows issue resolved | DevOps |

## Failure Handling
| Failure Mode | Action |
|-------------|--------|
| Cannot reproduce | Add logging/metrics, monitor, re-classify if needed |
| Fix introduces regression | Rollback fix, re-open bug with additional context |
| Root cause unclear | Escalate to CTO for deeper investigation |
| Cannot fix cleanly | Document as known issue, escalate to PM for prioritization |
| Hotfix breaks | Immediate rollback, full incident-lifecycle escalation |

## Escalation Path
- **P0 (critical)** — Immediate incident per incident-lifecycle, CEO notified
- **P1 (high)** — CTO escalation if fix not identified within SLA
- **Security vulnerability** — Handled per security-policies, Security owns triage
- **Stuck investigation** — CTO assigns additional resources or alternative approach
