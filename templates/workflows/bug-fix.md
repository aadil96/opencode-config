# Bug Fix Workflow

**Owner:** Coder
**Participants:** Security, QA, DevOps

## Entry Conditions
- Bug report received with reproduction steps and environment details
- Severity assessed (critical, high, medium, low)

## Exit Conditions
- Root cause identified and documented
- Fix implemented, reviewed, and merged
- Validation confirms bug resolved (with regression test)
- Fix deployed to affected environments

## Flow

1. **Reproduce** — Coder confirms the bug with exact reproduction steps
2. **Root cause** — Coder analyzes underlying cause; document findings
3. **Security assessment** — If the bug involves auth, data, access control, or PII
4. **Implementation** — Write the fix with a test covering the regression
5. **Validation** — Code review via reviewer; QA validates fix and runs regression suite
6. **Deployment** — Deploy via DevOps (accelerated for critical/security bugs)

## Gate Checklist

- [ ] Bug reproduced and documented (Coder)
- [ ] Root cause identified and documented (Coder)
- [ ] Security reviewed if applicable (Security)
- [ ] Fix reviewed (reviewer)
- [ ] Regression test added and passing (QA)
- [ ] Deployed and verified (DevOps)
