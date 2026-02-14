---
title: "Cost Guardrails"
status: "not_started"
priority: "P2"
category: "developer-experience"
effort: "medium"
impact: "medium"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Cost Guardrails

## Problem

Each skill invocation spawns 2-5 agents, all consuming tokens in parallel. A `/plan-product` run with 5 Opus agents can be expensive. Users have no visibility into cost accumulation and no ability to set limits. The 3-rejection escalation rule (Skeptic rejects same deliverable 3 times → escalate to human) is the only current cost control.

## Proposed Solution

1. **Agent count awareness**: Document expected agent counts and model tiers per skill in the README and in each skill's setup phase.
2. **Lightweight mode**: Add a `--light` argument to skills that uses fewer agents or cheaper models (e.g., Sonnet instead of Opus for the Researcher role).
3. **Progress visibility**: Skills write a brief cost summary to `docs/progress/` at the end of each invocation (agents spawned, approximate turn count).

## Architectural Considerations

- Claude Code does not expose token counts to skills, so exact cost tracking isn't possible. Proxy metrics (agent count, turn count) are the best available signal.
- Lightweight mode requires conditional agent spawning logic in SKILL.md files.
- Must not compromise the Skeptic pattern — the Skeptic is always Opus, even in lightweight mode.

## Success Criteria

- Users can choose a reduced-cost mode for exploratory/draft work.
- Each skill invocation leaves a record of resource usage.
