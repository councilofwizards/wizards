---
title: "Progress Observability"
status: "not_started"
priority: "P2"
category: "quality-reliability"
effort: "medium"
impact: "medium"
dependencies: ["state-persistence"]
created: "2026-02-14"
updated: "2026-02-14"
---

# Progress Observability

## Problem

During a skill invocation, the user has limited visibility into what agents are doing. With `CLAUDE_CODE_SPAWN_BACKEND=tmux`, they can watch individual agent panes, but there's no consolidated view of team progress — which tasks are done, which are blocked, who is waiting on whom.

## Proposed Solution

1. **Structured progress files**: Agents write status updates to `docs/progress/` using a consistent format (see P1-02 checkpoint format).
2. **Status summary command**: Add a `/plan-product status` or `/build-product review` argument that reads all progress files and generates a consolidated status report without spawning a full team.
3. **End-of-session summary**: Each skill writes a session summary to `docs/progress/{feature}-summary.md` when the team completes or is interrupted.

## Architectural Considerations

- The status command should be cheap — it reads files and summarizes, no agent spawning needed.
- Progress files must follow the concurrent-write-safe convention from P1-01.
- The summary format should be human-readable but also parseable by future automation.

## Success Criteria

- A user can check the status of an in-progress feature without interrupting the running team.
- End-of-session summaries provide enough context to resume or hand off work.
