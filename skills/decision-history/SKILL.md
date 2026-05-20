---
name: decision-history
description: >-
  Use when making architectural, strategic, or build-vs-buy decisions that
  would benefit future agents. Captures decisions with rationale, tradeoffs,
  and consequences.
---

# Decision History

## Purpose
Record significant decisions with full context so future agents can understand why choices were made. Decision records persist in agentmemory for retrieval during similar future decisions.

## What to Capture

### Store in agentmemory
- **Architectural decisions** — technology choices, system design decisions, infrastructure selections
- **Strategic decisions** — priority shifts, scope changes, market positioning
- **Build-vs-buy decisions** — make vs. purchase evaluations
- **Significant tradeoffs** — decisions where multiple valid options existed with meaningful tradeoffs

### Do NOT store
- Temporary debugging output
- Implementation details
- Generated code
- One-off mistakes
- Transient session discussion
- Raw logs
- Routine operational choices (e.g., which branch to merge)

**Rationale:** Memory should hold durable decisions with future relevance. Routine choices add noise.

## When to Capture
| Trigger | Timing | Write Owner |
|---------|--------|-------------|
| Architecture decision made | Immediately upon decision | CTO |
| Strategic decision made | Within 1 hour | CEO |
| Build-vs-buy decision made | Immediately upon decision | CTO / Finance |
| Significant tradeoff accepted | When tradeoff is consciously chosen | CTO / PM |

## Output Schema

### Architecture decisions (CTO)
```
content: "Chose PostgreSQL over DynamoDB because relational queries outweighed horizontal scaling benefits"
type: "architecture"
concepts: "decision-history,database,postgres,dynamodb,tradeoff"
```

### Strategic decisions (CEO)
```
content: "Prioritized data platform over mobile app to unblock Q3 revenue goals"
type: "fact"
concepts: "decision-history,strategy,priority,revenue"
```

### Build-vs-buy decisions (Finance)
```
content: "Selected Datadog over self-hosted Grafana stack — break-even at 18 months"
type: "fact"
concepts: "decision-history,cost,observability,build-vs-buy"
```

### Requirement / scope decisions (PM)
```
content: "Scoped V1 to 3 core features; deferred SSO and audit logging to V2"
type: "fact"
concepts: "decision-history,scope,requirements,ssr,v1-boundary"
```

**Schema rules:**
- First concept is always `"decision-history"`
- Second concept is the domain (e.g., `"database"`, `"strategy"`, `"cost"`, `"scope"`)
- Remaining concepts are free-form tags
- Architectural decisions use `type: "architecture"`
- Non-technical decisions use `type: "fact"`

## Confidence Thresholds

**Only save if both conditions are met:**
- `importance` >= **medium**
- `future_reuse_probability` >= **medium**

If either condition is low, document in a ticket or PR description instead.

## Retrieval Guidance

| Agent | When | Query | Max Results |
|-------|------|-------|-------------|
| CEO | Before strategic initiative | `query="decision-history strategic decisions scope"` | 3-5 |
| CTO | Before architecture change | `query="decision-history architecture database stack"` | 3-5 |
| PM | Before scope/requirement change | `query="decision-history scope requirements tradeoffs"` | 3-5 |
| Finance | Before build-vs-buy evaluation | `query="decision-history cost build-vs-buy"` | 3-5 |

### Retrieval Rules
- Always set `limit` to 3–5 (never request bulk dumps)
- Apply a relevance threshold: skip results not directly related to current context
- **Summarize before injection** — never inject raw memory output into prompts
- Format as: "Previous relevant decisions: [summarized list of N entries]"

## Write Ownership

| Agent | Can Write | Type | Scope |
|-------|-----------|------|-------|
| CEO | ✅ Yes | `fact` | Strategic decisions |
| CTO | ✅ Yes | `architecture` | Architecture decisions |
| PM | ✅ Yes | `fact` | Requirement and scope decisions |
| Finance | ✅ Yes | `fact` | Build-vs-buy decisions |
| Orchestrator | ❌ No (read-only) | — | — |
| Security | ❌ No (read-only) | — | — |
| QA | ❌ No (read-only) | — | — |
| DevOps | ❌ No (read-only) | — | — |
| Coder | ❌ No (read-only) | — | — |
| Researcher | ❌ No (read-only) | — | — |
| Reviewer | ❌ No (read-only) | — | — |

## Integration

This skill works with:
- **decision-framework** — Use decision-framework for the decision process, then capture the outcome here
- **architecture-lifecycle** — ADRs are captured via this skill after approval
- **continuous-improvement** — Decision patterns and quality are evaluated during quarterly reviews
- **agentmemory** — Persistence layer for decision records
- **org-routing** — Routing decisions can be informed by past decision history
- **org-governance** — All agents follow shared governance rules

## Rules

1. Capture decisions when made, not retroactively at project end
2. Include the rejected alternatives and why they were rejected
3. Record conditions that would invalidate the decision
4. Use the correct `type` field: `architecture` for technical, `fact` for strategic/scope/cost
5. Do NOT rewrite organization policy automatically — recommendations only
6. Humans approve all organizational changes
