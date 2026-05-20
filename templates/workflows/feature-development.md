# Feature Development Workflow

**Owner:** PM
**Participants:** CTO, Security, QA, DevOps

## Entry Conditions
- Feature request documented with clear description
- Requirements defined and reviewed

## Exit Conditions
- Implementation completed and code reviewed
- All acceptance criteria met
- Tests pass and coverage adequate
- Security reviewed (if applicable)
- Deployment planned with rollback

## Flow

1. **PM** — Refine requirements, define acceptance criteria, validate user value
2. **CTO** — Review architecture, evaluate tech stack fit, flag technical risks
3. **Security** — Assess risks (auth, secrets, external deps, or PII)
4. **Implementation** — Delegate to execution agents (coder, researcher, reviewer, scribe)
5. **QA** — Validate against acceptance criteria, run test strategy, check quality gates
6. **DevOps** — Plan deployment, prepare rollout, verify release readiness

## Gate Checklist

- [ ] Requirements are clear and documented (PM)
- [ ] Architecture is sound and reviewed (CTO)
- [ ] Security reviewed if applicable (Security)
- [ ] Code reviewed and approved (reviewer)
- [ ] All tests pass, coverage adequate (QA)
- [ ] Deployment plan ready with rollback strategy (DevOps)
