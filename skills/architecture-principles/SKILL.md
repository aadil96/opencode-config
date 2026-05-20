---
name: architecture-principles
description: >-
  System architecture principles and technology selection criteria. Use when
  evaluating architectural approaches, choosing technologies, or reviewing
  system design.
---

# Architecture Principles

## Core Principles

### 1. Separation of Concerns
- Each component has one clear responsibility
- Boundaries defined by change frequency and reason
- Interfaces are contracts, not implementation details

### 2. Dependency Management
- Dependencies point inward (domain core depends on nothing)
- Abstract stable concepts, depend on unstable ones
- Prefer composition over inheritance

### 3. Loose Coupling, High Cohesion
- Components communicate through well-defined interfaces
- Related behavior stays together; unrelated behavior stays apart
- Change in one component should not cascade

### 4. Appropriate Complexity
- Solve today's problems, not next year's
- Premature abstraction is as harmful as premature optimization
- Every abstraction layer has a cost — justify it

## Technology Selection Criteria

When choosing a technology, evaluate:

| Criterion | Question |
|-----------|---------|
| Problem fit | Does it solve the actual problem? |
| Ecosystem | Is there community, docs, tooling? |
| Maintenance | Is it actively maintained? |
| Learning curve | Can the team use it effectively? |
| Integration | Does it work with existing stack? |
| Cost | What's the total cost (time, money, ops)? |

## Adherence Checklist

- [ ] Components have clear, single responsibilities
- [ ] Dependencies point in the right direction
- [ ] Interfaces are clean and stable
- [ ] Complexity is justified by actual need
- [ ] Technology choices are evaluated against criteria
