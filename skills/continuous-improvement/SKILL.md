---
name: continuous-improvement
description: >-
  Use when analyzing recurring patterns, detecting repeated mistakes and
  workflow friction, and recommending process improvements during quarterly
  reviews or when a pattern of repeated issues is detected.
---

# Continuous Improvement

## Purpose
Close the learning loop: analyze patterns across postmortems, decision history, and org-audit records to identify systemic improvements. This skill drives the quarterly review cycle and ensures the organization learns over time.

## What to Capture

### Store in agentmemory
- **Approved process improvements only** — changes that have been reviewed and approved by humans
- **Recurring patterns** — behaviors or outcomes observed across multiple sessions
- **Friction points** — repeated sources of delay, confusion, or rework

### Do NOT store
- Unapproved observations or suggestions
- Transient impressions from a single session
- Generated code or implementation artifacts
- Raw logs or debugging output

**Rationale:** Only approved, vetted improvements enter permanent memory. Unapproved observations live in working context only.

## When to Capture
| Trigger | Timing | Write Owner |
|---------|--------|-------------|
| Quarterly organization review | Every quarter | Orchestrator (post-human-approval) |
| Pattern threshold reached (3+ occurrences) | On detection | Orchestrator |
| Process improvement approved | Immediately upon approval | Orchestrator |

## Quarterly Review Cycle

Every quarter (or when triggered by the orchestrator):

### Step 1: Delegate and Gather
Request domain owners to retrieve relevant records from their domain memory:
- QA retrieves quality postmortems: `agentmemory_memory_recall(query="postmortem", limit=5)`
- DevOps retrieves incident postmortems: `agentmemory_memory_recall(query="postmortem", limit=5)`
- CTO retrieves architecture decisions: `agentmemory_memory_recall(query="decision-history", limit=5)`
- PM retrieves scope decisions: `agentmemory_memory_recall(query="decision-history", limit=5)`
- QA and DevOps retrieve routing patterns: `agentmemory_memory_recall(query="org-audit", limit=5)`
- CTO retrieves process patterns: `agentmemory_memory_recall(query="org-audit", limit=5)`

> **Note:** The quarterly review is a special batch operation. The standard 3-5 retrieval limit applies for individual agent queries, but during the review the orchestrator may gather up to 5 per category for comprehensive analysis.

### Step 2: Analyze
Identify across retrieved records:
- **Recurring patterns** — themes appearing in 3+ records
- **Repeated mistakes** — similar root causes in multiple postmortems
- **Workflow friction** — routing inefficiencies from multiple org-audits
- **Decision quality** — were past decisions validated by outcomes?

### Step 3: Recommend
Propose improvements with:
- What to change
- Expected benefit
- Risk of not changing
- Which org skill/agent definition is affected

### Step 4: Review
Present recommendations to human for approval. Do not implement until approved.

### Step 5: Cleanup (Memory Hygiene)
Identify and recommend for cleanup:
- **Stale memory** — records with `status: superseded` older than 6 months
- **Duplicate memory** — records with substantially similar content
- **Low-value memory** — records that would not meet current importance/reuse thresholds
- **Action:** Recommend deletion to human, do not delete autonomously

## Output Schema

```
content: "Quarterly review 2026-Q2 findings: Pattern detected: 3 postmortems with database connection pool exhaustion. Root cause: Missing connection timeout configuration in new services. Friction: DevOps consulted for frontend-only features."
type: "workflow"
concepts: "continuous-improvement,process,workflow,optimization,database,routing"
```

**Schema rules:**
- First concept is always `"continuous-improvement"`
- Second concept is the domain (e.g., `"process"`, `"workflow"`, `"optimization"`)
- Remaining concepts are free-form tags
- Always use `type: "workflow"`

## Confidence Thresholds

**Only save if both conditions are met:**
- `importance` >= **medium**
- `future_reuse_probability` >= **medium**
- AND humans have approved the recommendation

Proposed improvements that are not yet approved should stay in working context until the review cycle completes.

## Retrieval Guidance

| Agent | When | Query | Max Results |
|-------|------|-------|-------------|
| CTO | Before architecture process change | `query="continuous-improvement architecture process"` | 3-5 |
| PM | Before workflow change | `query="continuous-improvement workflow friction"` | 3-5 |

### Retrieval Rules
- Agents must set `limit` to 3–5 (never request bulk dumps)
- Apply a relevance threshold: skip results not directly related to current improvement context
- **Summarize before injection** — never inject raw memory output into prompts
- Format as: "Previously approved improvements: [summarized list of N entries]"

## Write Ownership

| Agent | Can Write | Scope |
|-------|-----------|-------|
| Orchestrator | ✅ Yes | After human approval |
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
- **postmortem** — Analyzes postmortem patterns for root cause trends
- **decision-history** — Evaluates decision quality over time
- **org-audit** — Identifies routing and delegation patterns
- **agentmemory** — Persistence layer for all records
- **org-routing** — Improvement recommendations may affect routing rules
- **org-governance** — Governance changes must flow through this skill

## Rules

1. Never rewrite organization policy automatically — recommendations only
2. Humans approve all organizational changes
3. Base recommendations on evidence from 3+ occurrences (not single instances)
4. Distinguish between proposed, approved, implemented, and rejected improvements
5. Quarterly cleanup removes stale, duplicate, and low-value memory
6. Improvements must reference the evidence that supports them
