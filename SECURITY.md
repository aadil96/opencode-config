# Security Policy

## Reporting a Vulnerability

This repository provides OpenCode configuration guardrails. If you discover a security vulnerability:

1. **Do NOT** open a public GitHub issue
2. Send details to the maintainer via a private channel
3. Include steps to reproduce and potential impact

## What We Consider a Vulnerability

- Hardcoded secrets, tokens, or credentials in configuration files
- Scripts that handle sensitive data unsafely (e.g., API keys visible in terminal)
- Agent permission models that allow privilege escalation
- Supply chain risks in dependencies
- Any mechanism that could leak secrets from debug logs or error messages

## Expectations

- You will receive an acknowledgment within 48 hours
- We will investigate and provide a timeline for a fix
- We will coordinate disclosure once a fix is released

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | ✅ Active development |

## Security Best Practices for This Config

- API keys are stored in `~/.config/agentmemory/.env` with `chmod 600`
- Agents follow least-privilege permissions
- Sensitive data is sanitized before writing to debug logs
- Always review diffs before committing (see PR template)
