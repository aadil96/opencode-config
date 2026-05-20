---
name: org-audit
description: >-
  Use when recording organization routing effectiveness and agent selection
  accuracy after completing work that involved multiple organization agents
  or complex routing decisions.
---

# Organization Audit

## Purpose
Track how effectively organization agents are selected and routed. Org-audit records help optimize routing decisions over time by identifying unnecessary consultations and missed involvement.

## What to Capture

### Store in agentmemory
- **Routing failures** — agents consulted unnecessarily, agents missed despite relevance
- **Recurring delegation inefficiencies** — patterns of suboptimal routing
- **Effectiveness patterns** — routing configurations that worked well

### Do NOT store
- One-off routing mistakes without pattern potential
- Transient session discussion about routing
- Generated code or implementation artifacts
- Normal successful routing (no signal for improvement)

**Rationale:** Only patterns worth optimizing deserve memory. Normal successful routing is the expected baseline.

## When to Capture
| Trigger | Timing | Write Owner |
|---------|--------|-------------|
| Work completed with org agent involvement | End of session | Orchestrator |
| Routing failure detected | Immediately on detection | Orchestrator |
| Pattern of inefficiency identified (3+ occurrences) | On identification | Orchestrator |

## Output Schema

```
content: "Security agent invoked unnecessarily for non-auth feature"
type: "pattern"
concepts: "org-audit,routing,security,optimization"
```

**Schema rules:**
- First concept is always `"org-audit"`
- Second concept is the domain (e.g., `"routing"`, `"delegation"`, `"efficiency"`)
- Remaining concepts are free-form tags
- Always use `type: "pattern"`

## Confidence Thresholds

**Only save if both conditions are met:**
- `importance` >= **medium**
- `future_reuse_probability` >= **medium**

If either condition is low, skip persistence.

## Retrieval Guidance

| Agent | When | Query | Max Results |
|-------|------|-------|-------------|
| QA | During release audit | `query="org-audit routing failures quality"` | 3-5 |
| DevOps | During deployment review | `query="org-audit routing deployment"` | 3-5 |
| CTO | During architecture process review | `query="org-audit routing architecture oversight"` | 3-5 |

### Retrieval Rules
- Agents must set `limit` to 3–5 (never request bulk dumps)
- Apply a relevance threshold: skip results not directly related to current routing context
- **Summarize before injection** — never inject raw memory output into prompts
- Format as: "Routing patterns from past sessions: [summarized list of N entries]"

## Write Ownership

| Agent | Can Write | Scope |
|-------|-----------|-------|
| Orchestrator | ✅ Yes | All org-audit records |
| CEO | ❌ No (read-only) | — |
| CTO | ❌ No (read-only) | — |
| PM | ❌ No (read-only) | — |
| Finance | ❌ No (read-only) | — |
| Security | ❌ No (read-only) | — |
| QA | ❌ No (read-only) | — |
| DevOps | ❌ No (read-only) | — |
| Coder | ❌ No (read-only) | — |
| Researcher | ❌ No (read-only) | — |
| Reviewer | ❌ No (read-only) | — |

## Integration

This skill works with:
- **org-routing** — Routing decisions are the subject of org-audit
- **org-governance** — Governance rules inform routing expectations
- **continuous-improvement** — Audit patterns feed into process improvement recommendations
- **agentmemory** — Persistence layer for audit records

## Rules

1. Audit captures process effectiveness, not individual agent performance
2. Identify systemic patterns, not single-instance anomalies
3. Optimization recommendations must be actionable (what to change, not just what's wrong)
4. Do NOT rewrite organization policy automatically — recommendations only
5. Humans approve all organizational changes
