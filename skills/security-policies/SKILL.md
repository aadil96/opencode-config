---
name: security-policies
description: >-
  Security policies and threat modeling framework. Use when evaluating
  security risks, designing auth systems, or reviewing dependency security.
---

# Security Policies

## Threat Modeling (STRIDE)

| Category | What to Check |
|----------|---------------|
| Spoofing | Authentication strength, session management |
| Tampering | Data integrity, input validation |
| Repudiation | Logging, audit trails |
| Information Disclosure | Encryption, secrets management |
| Denial of Service | Rate limiting, resource exhaustion |
| Elevation of Privilege | Authorization checks, principle of least privilege |

## Security Checklist

### Authentication & Authorization
- [ ] Authentication required for sensitive operations
- [ ] Principle of least privilege applied
- [ ] Session management is secure
- [ ] API keys and tokens are not hardcoded

### Data Security
- [ ] Data encrypted at rest and in transit
- [ ] Secrets never in logs, error messages, or version control
- [ ] PII handled according to regulations
- [ ] Input validated and sanitized

### Dependency Security
- [ ] Dependencies from trusted sources only
- [ ] Known vulnerabilities checked (npm audit, etc.)
- [ ] Lock files committed to prevent supply chain attacks
- [ ] Minimal dependency footprint

### Compliance
- [ ] Regulatory requirements identified
- [ ] Data retention policies defined
- [ ] Audit trails for sensitive operations

## Adherence Checklist

- [ ] STRIDE threat modeling completed
- [ ] Auth and secrets follow best practices
- [ ] Dependencies are secure and minimal
- [ ] Compliance requirements identified
