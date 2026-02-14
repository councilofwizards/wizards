---
title: "State Persistence & Checkpoints"
status: "not_started"
priority: "P1"
category: "core-framework"
effort: "large"
impact: "high"
dependencies: ["concurrent-write-safety"]
created: "2026-02-14"
updated: "2026-02-14"
---

# State Persistence & Checkpoints

## Problem

When an agent's context window fills up or a session is interrupted, all in-progress work is lost. The skills reference a recovery procedure ("summarize current state to `docs/progress/`"), but there's no structured checkpoint format. Recovery depends on agents voluntarily saving state before they lose context — which is unreliable.

## Proposed Solution

1. **Structured checkpoint format**: Define a YAML-frontmatter checkpoint file that agents write at key milestones (task claimed, plan drafted, review requested, review approved).
2. **Checkpoint convention in SKILL.md**: Add explicit instructions to spawn prompts requiring agents to write checkpoints after each significant state change.
3. **Resume protocol**: When `/build-product` or `/plan-product` is invoked with no arguments, scan `docs/progress/` for incomplete checkpoints and resume from the last known state.

## Checkpoint File Format

```yaml
---
feature: "feature-name"
team: "plan-product"
agent: "architect"
phase: "design"           # research | design | review | implementation | testing
status: "in_progress"     # in_progress | blocked | awaiting_review | complete
last_action: "Submitted ADR to skeptic for review"
updated: "2026-02-14T10:30:00Z"
---

## Progress Notes

- [10:00] Started architecture design for feature X
- [10:15] Drafted ADR-002
- [10:30] Sent to product-skeptic for review
```

## Architectural Considerations

- Checkpoints must not create concurrent write conflicts (solved by P1-01).
- The resume protocol adds complexity to the "Determine Mode" section of each skill.
- Checkpoint writes should be lightweight — agents should not spend significant context on state management.

## Success Criteria

- A session interrupted mid-work can be resumed by re-invoking the same skill.
- The resumed session picks up from the last checkpoint, not from scratch.
