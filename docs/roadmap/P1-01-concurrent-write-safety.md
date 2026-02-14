---
title: "Concurrent Write Safety"
status: "not_started"
priority: "P1"
category: "core-framework"
effort: "medium"
impact: "high"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Concurrent Write Safety

## Problem

During `/plan-product`, the Researcher and Architect run in parallel. During `/build-product`, Backend and Frontend engineers run in parallel. If two agents write to the same file (e.g., a shared progress log or roadmap index), one agent's changes are silently lost.

This is a data integrity risk inherent to the multi-agent architecture.

## Proposed Solution

1. **File-per-concern partitioning**: Each agent writes only to files scoped to their role. Progress files become `docs/progress/{feature}-{role}.md` instead of `docs/progress/{feature}.md`.
2. **Naming conventions in skill prompts**: Update SKILL.md files to instruct agents to use role-scoped filenames.
3. **Lead-only aggregation**: Only the team lead writes to shared files (like `_index.md`) and only after parallel work completes.

## Architectural Considerations

- No external locking mechanism needed — file partitioning avoids the problem entirely.
- Requires updating spawn prompts in all three SKILL.md files.
- Must document the convention so future skills follow the same pattern.

## Success Criteria

- No file content is lost when two agents write concurrently during any skill invocation.
- Each agent's output is preserved in a dedicated, role-scoped file.
