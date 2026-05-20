---
name: architecture-lifecycle
description: >-
  Make and track architecture decisions systematically through RFCs and ADRs.
  Use when evaluating architectural approaches, choosing technologies, or
  designing system changes.
---

# Architecture Lifecycle

## Purpose
Make architecture decisions transparently through a structured RFC process, documenting rationale and enabling informed trade-off discussions.

## Trigger Conditions
- New feature with significant architecture impact
- Technology choice or replacement decision
- Architecture debt identified
- Scalability or performance concern
- Security architecture review
- Cross-cutting concern requiring design standardization

## Participants
| Role | Responsibility |
|------|---------------|
| CTO | RFC approval, architecture authority, final decision |
| Coder | Research, RFC authoring, prototyping |
| Reviewer | RFC review, technical feedback |
| PM | Impact assessment, timeline implications |
| Security | Security architecture review (auth/encryption/data) |
| Finance | Cost analysis (infrastructure/licensing) |

## Entry Conditions
- [ ] Problem statement clearly defined
- [ ] Context and constraints documented
- [ ] Stakeholders identified
- [ ] Decision deadline known (if applicable)

## Exit Conditions
- [ ] Decision documented and approved
- [ ] ADR recorded in decision log
- [ ] Implementation guidance communicated to team
- [ ] Re-evaluation criteria defined

## Process Steps
1. **Identify** — Recognize architecture decision need from trigger conditions
2. **Research** — Coder/Researcher investigates options, gathers data, prototypes if needed
3. **Propose** — Author RFC with problem, options, trade-offs, recommendation
4. **Review** — CTO + stakeholders review RFC, provide feedback
5. **Decide** — CTO makes final decision (approve, reject, or modify)
6. **Document** — Record ADR with rationale, alternatives considered, invalidation conditions
7. **Communicate** — Share decision with affected teams, update relevant docs

## Validation Gates
| Gate | Check | Owner |
|------|-------|-------|
| Research complete | Options evaluated, data gathered, trade-offs identified | Coder |
| RFC reviewed | Feedback incorporated, stakeholders consulted | CTO |
| Decision approved | CTO sign-off on final decision | CTO |
| ADR recorded | Decision, rationale, alternatives, invalidation conditions documented | Coder |
| Cost reviewed | Financial impact assessed (if applicable) | Finance |
| Security reviewed | Threat model updated (if applicable) | Security |

## Failure Handling
| Failure Mode | Action |
|-------------|--------|
| Research inconclusive | Expand scope, consult external expertise, run spike |
| RFC lacks consensus | Schedule facilitated discussion, identify unresolved trade-offs |
| Decision deferred | Set hard deadline, escalate to CTO for resolution |
| Decision later invalidated | Record invalidation in ADR, open new RFC |
| Implementation reveals flaw | Return to RFC phase with new data |

## Escalation Path
- **Disagreement on direction** — CTO makes final call
- **Cost concern** — Finance evaluates, CEO involved if strategic impact
- **Cross-team impact** — PM coordinates alignment across stakeholders
- **Time-sensitive decision** — CTO sets accelerated timeline for RFC
