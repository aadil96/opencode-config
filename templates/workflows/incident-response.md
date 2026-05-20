# Incident Response Workflow

**Owner:** DevOps
**Participants:** DevOps, Security, CTO

## Entry Conditions
- Incident detected via alert, monitoring, or user report
- Initial severity classification made

## Exit Conditions
- Incident mitigated (resolved or contained)
- Root cause identified and documented
- Postmortem completed with action items
- Follow-up work tracked

## Flow

1. **Detect** — Identify the issue via monitoring, alerts, user reports, or automated checks
2. **Triage** — Classify severity and impact, notify stakeholders, decide response priority
3. **Mitigate** — Apply fix, rollback, or containment measure to restore service
4. **Postmortem** — Document timeline, root cause, impact, resolution, and prevention plan

## Gate Checklist

- [ ] Incident detected and confirmed (DevOps)
- [ ] Severity and impact assessed; stakeholders notified (DevOps)
- [ ] Mitigation applied and verified (DevOps)
- [ ] Postmortem completed with action items and owners (CTO)
- [ ] Action items tracked and prioritized (PM)
