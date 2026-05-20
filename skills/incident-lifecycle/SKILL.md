---
name: incident-lifecycle
description: >-
  Respond to and resolve production incidents with minimal impact. Use when a
  production alert fires, a user reports an outage, or monitoring detects an
  anomaly.
---

# Incident Lifecycle

## Purpose
Detect, respond to, and resolve production incidents with minimal user impact, followed by root cause analysis and prevention.

## Trigger Conditions
- Production alert fires (PagerDuty, monitoring, etc.)
- User-reported outage or degradation
- Monitoring anomaly detected
- Security breach detected
- P0 bug report received

## Participants
| Role | Responsibility |
|------|---------------|
| DevOps | Initial triage, on-call response, communication |
| Coder | Technical investigation, fix implementation |
| Security | Security incident lead (security incidents only) |
| CTO | Escalation point, resource allocation |
| PM | Stakeholder communication (user-facing incidents) |
| CEO | Crisis communication (P0 only) |

## Entry Conditions
- [ ] Incident detected and acknowledged
- [ ] Severity classified (P0/P1/P2)
- [ ] Communication channel established
- [ ] Initial responder assigned

## Exit Conditions
- [ ] Service restored (fix or mitigation)
- [ ] Root cause identified
- [ ] Fix or permanent mitigation deployed
- [ ] Postmortem completed
- [ ] Prevention items tracked

## Process Steps
1. **Detect** — Alert fires or report received, automated detection confirms
2. **Acknowledge** — On-call acknowledges within SLA, incident channel created
3. **Triage** — Classify severity, assess impact, declare incident if P0/P1
4. **Respond** — Mitigate: rollback, feature flag, scale up, or deploy fix
5. **Resolve** — Verify service healthy, confirm mitigation successful
6. **Document** — Timeline, actions taken, root cause analysis
7. **Prevent** — Blameless postmortem, action items, track in backlog

## Validation Gates
| Gate | Check | Owner |
|------|-------|-------|
| Acknowledged | Incident acknowledged within SLA | DevOps (on-call) |
| Mitigation effective | Service health restored, key metric green | DevOps |
| Root cause documented | RCA approved, no speculation | Coder |
| Postmortem complete | Action items created, blameless review held | CTO |
| Prevention tracked | Items in backlog with owners | PM |

## Failure Handling
| Failure Mode | Action |
|-------------|--------|
| Mitigation fails | Escalate severity, involve CTO for resource allocation |
| RCA inconclusive | Add monitoring, schedule deeper investigation post-incident |
| Postmortem action items stale | PM tracks, CTO reviews at regular cadence |
| Repeat incident | Escalate to architecture review for systemic fix |
| Communication break | Designate incident commander for future incidents |

## Escalation Path
- **P0 (customer-facing outage)** — CEO notified, crisis communication activated
- **P1 (severe degradation)** — CTO escalation if unresolved within SLA
- **Security incident** — Security leads response, legal notified if data involved
- **Resource shortage** — CTO allocates additional team members
