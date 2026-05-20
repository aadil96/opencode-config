---
name: postmortem
description: >-
  Use when analyzing completed work to identify successes, failures,
  unexpected complexity, and root causes after incident resolution,
  project completion, or milestone delivery.
---

# Postmortem

## Purpose
Systematically analyze completed work to capture lessons learned and prevent recurrence. Postmortems feed into agentmemory for future retrieval by organization agents.

## What to Capture

### Store in agentmemory
- **Production failures** — outages, degradations, data corruption
- **Recurring issues** — problems that appear across multiple incidents or projects
- **Major lessons learned** — insights that fundamentally change approach

### Do NOT store
- Temporary debugging output
- Implementation details of individual fixes
- One-off mistakes without recurrence potential
- Transient session discussion
- Generated code
- Raw logs

**Rationale:** Only high-signal information deserves permanent memory. Storing low-value data causes memory pollution and reduces retrieval quality.

## When to Capture
| Trigger | Timing | Write Owner |
|---------|--------|-------------|
| Incident resolved | Within 24 hours of resolution | DevOps (incidents), Security (security incidents), QA (quality failures) |
| Repeated failure pattern detected | On detection of 3rd occurrence | QA |

## Output Schema

Save to agentmemory using `agentmemory_memory_save` with these fields:

```
content: "Health checks failed because startup time exceeded readiness timeout"
type: "bug"
concepts: "postmortem,kubernetes,healthcheck,readiness"
```

- First concept is always `"postmortem"`
- Second concept is the domain (e.g., `"kubernetes"`, `"database"`, `"security"`)
- Remaining concepts are free-form tags

## Confidence Thresholds

**Only save if both conditions are met:**
- `importance` >= **medium**
- `future_reuse_probability` >= **medium**

If either condition is low, document in a ticket instead of persisting to memory.

## Retrieval Guidance

| Agent | When | Query | Max Results |
|-------|------|-------|-------------|
| Security | During security assessment | `query="postmortem security findings vulnerabilities"` | 3-5 |
| QA | Before release validation | `query="postmortem failures regressions testing"` | 3-5 |
| DevOps | During deployment planning | `query="postmortem incidents deployment infrastructure"` | 3-5 |
| CTO | During architecture review | `query="postmortem systemic failures architecture"` | 3-5 |

### Retrieval Rules
- Always set `limit` to 3–5 (never request bulk dumps)
- Apply a relevance threshold: skip results not directly related to current context
- **Summarize before injection** — never inject raw memory output into prompts
- Format as: "Past postmortems found: [summarized list of N relevant entries]"

## Write Ownership

| Agent | Can Write | Scope |
|-------|-----------|-------|
| DevOps | ✅ Yes | Incidents and deployment lessons |
| Security | ✅ Yes | Security lessons |
| QA | ✅ Yes | Quality failures |
| Orchestrator | ❌ No (read-only) | — |
| CEO | ❌ No (read-only) | — |
| CTO | ❌ No (read-only) | — |
| PM | ❌ No (read-only) | — |
| Finance | ❌ No (read-only) | — |
| Coder | ❌ No (read-only) | — |
| Researcher | ❌ No (read-only) | — |
| Reviewer | ❌ No (read-only) | — |

## Integration

This skill works with:
- **incident-lifecycle** — Postmortem is the final step of the incident lifecycle
- **continuous-improvement** — Postmortem patterns are analyzed during quarterly reviews
- **agentmemory** — Persistence layer for postmortem records
- **org-governance** — All agents follow shared governance rules

## Rules

1. Postmortems are blameless — focus on system failures, not individual mistakes
2. Always identify root cause, not just proximate cause
3. Propose actionable improvements, not observations
4. Do NOT rewrite organization policy automatically — recommendations only
5. Humans approve all organizational changes
