# Security Review Workflow

**Owner:** Security
**Participants:** CTO, Coder

## Entry Conditions
- Feature or change involves auth, secrets, data access, external dependencies, or PII
- Security flag raised during architecture review or code review

## Exit Conditions
- Threat model documented
- Security risks assessed with mitigation plan
- Security sign-off provided or blocking issues filed

## Flow

1. **Triage** — Security assesses scope: what data, what access, what external systems
2. **Threat model** — Identify threats, attack vectors, and trust boundaries
3. **Mitigation review** — Evaluate proposed mitigations; recommend changes if needed
4. **Sign-off** — Provide security sign-off or file blocking issues with severity

## Gate Checklist

- [ ] Threat model completed (Security)
- [ ] Risks assessed with clear severity ratings (Security)
- [ ] Mitigations reviewed and accepted (Security)
- [ ] Sign-off provided or blocking issues filed (Security)
