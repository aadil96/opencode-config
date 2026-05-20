# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-05-20

### Added
- `.opencode/` directory structure with guards, workflows, checklists, routing, and references
- Pre-commit mandatory guardrail (status → diff → scan → staged review)
- Pre-push mandatory guardrail (PR draft → review diff → mark ready)
- Sensitive data scanning patterns for secrets, tokens, and personal paths
- Session start workflow with memory augmentation
- Branch lifecycle workflow
- PR lifecycle workflow
- Memory intelligence layer with confidence-based capture (high/medium/low) and consolidation
- Memory expiration and supersession policy
- Changelog auto-update workflow with significance evaluator
- Open-source safety checklist and architecture decision checklist
- Memory capture guidelines with confidence thresholds and tagging conventions
- Request classification and workflow selection routing
- Open-source contributing guidelines (CONTRIBUTING.md)
- PR template with open-source safety checklist
- CODEOWNERS file for mandatory review
- Setup script (`scripts/setup.sh`) with backup and ask-before-overwrite
- Systemd service template for AgentMemory background operation
- CHANGELOG.md with Keep a Changelog format
