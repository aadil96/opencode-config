# Architecture Review Workflow

**Owner:** CTO
**Participants:** Security, Finance

## Entry Conditions
- Architecture decision required (stack change, new service, design change)
- Options identified, documented, and evaluated with initial rationale

## Exit Conditions
- Architecture decision documented as ADR
- Risks identified with mitigation plan
- Recommendation with clear rationale and tradeoff analysis

## Flow

1. **CTO** — Review architecture proposal, evaluate soundness against principles
2. **Security** — Assess risks (required for auth, data flow, network changes, or compliance)
3. **Finance** — Evaluate costs (required for new infrastructure, paid services, or licensing)
4. **Documentation** — Record decision, rationale, tradeoffs, and invalidation triggers

## Gate Checklist

- [ ] Architecture evaluated for soundness (CTO)
- [ ] Security risks assessed and mitigated (Security if applicable)
- [ ] Costs evaluated and within budget (Finance if applicable)
- [ ] Decision documented as ADR (CTO)
