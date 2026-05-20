---
name: org-routing
description: >-
  Decision routing for the build orchestrator. Defines when to consult each
  organization role based on task characteristics. Use this skill before
  delegating implementation work.
---

# Organization Routing

Load this skill when you receive a new request to determine which organization
roles should be consulted before delegating implementation.

## When to Consult Each Role

| Role | Trigger | Question to Answer |
|------|---------|-------------------|
| CEO | Strategic initiative, major scope change, fundamental priority conflict | "Is this within scope? What priority?" |
| CTO | Architecture change, stack selection, scalability | "Is this technically sound?" |
| PM | Requirements unclear, needs refinement | "What exactly should be built?" |
| Finance | Infrastructure cost, build-vs-buy, licensing | "Is this cost-effective?" |
| Security | Auth design, secrets, external dependencies, PII | "Is this secure?" |
| QA | Validation gates, test strategy, regression risk | "Is this ready for release?" |
| DevOps | Deployment, release process, observability | "Can this be deployed safely?" |

> **Note:** CEO is only consulted during strategic events, not normal feature flow.

## Decision Flow

```
Request received
  │
  ├── Is scope/priority unclear? ──► Consult CEO
  ├── Is architecture affected? ──► Consult CTO
  ├── Are requirements unclear? ──► Consult PM
  ├── Does it cost money? ──► Consult Finance
  ├── Does it handle secrets/auth? ──► Consult Security
  ├── Is it a release/merge? ──► Consult QA
  └── Does it affect deployment? ──► Consult DevOps
```

## Consultation Order

1. **CEO first** if strategic clarity is needed (new major feature, scope change)
2. **PM second** if requirements need refinement
3. **CTO/Finance** in parallel if both technical and cost
4. **Security/QA/DevOps** before final delivery (gates)

## Rules

- Do NOT consult a role unless its trigger condition is met
- Consult roles in parallel when they're independent
- Skip roles whose domain is not relevant
- Cross-org coordination is YOUR job — org agents don't call each other

## Routing Examples

| Scenario | Consult | Rationale |
|----------|---------|-----------|
| New initiative | ceo → pm → cto | Strategic first, then requirements, then architecture |
| Requirements unclear | pm | Refinement needed, no other roles affected |
| Architecture change | cto | Technical decision only |
| Authentication | security + cto | Security + architecture, consult in parallel |
| Infrastructure cost | finance | Cost decision only |
| Deployment | devops + qa | Platform change + quality gate, sequential |
| Code bugfix (no org impact) | (none) | Route directly to execution agents |

## Routing Sequence

1. Determine which organization roles are relevant based on trigger conditions
2. Order by hierarchy: strategic (CEO → PM) → technical (CTO) → gates (Security → QA → DevOps)
3. Finance slots in wherever cost is relevant
4. Consult independent roles in parallel to save steps
5. Always consult gates (Security, QA, DevOps) before final delivery
