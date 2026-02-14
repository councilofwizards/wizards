---
title: "Content Deduplication"
status: "not_started"
priority: "P2"
category: "core-framework"
effort: "medium"
impact: "medium"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Content Deduplication

## Problem

The Shared Principles (~50 lines) and Communication Protocol (~50 lines) are duplicated verbatim in all three SKILL.md files — approximately 126 redundant lines total. This duplication wastes tokens on every skill invocation. With 5 Opus agents reading the same skill file, the cost compounds.

The duplication was intentional (each skill must be self-contained for portability), but it creates a maintenance burden: any change to a shared principle must be applied to all three files identically.

## Proposed Solution

1. **Extract shared content to CLAUDE.md or a shared reference file**: Move Shared Principles and Communication Protocol to a project-level file (e.g., `CLAUDE.md` or `plugins/agent-teams/shared/principles.md`) that agents inherit via Claude Code's context mechanism.
2. **Replace in-skill duplication with a reference**: Each SKILL.md includes a brief note pointing to the shared file, with a fallback summary for portability.
3. **Validate consistency**: If full extraction isn't feasible (portability constraint), add a CI check (see P2-04) that verifies the duplicated sections are identical across all three skills.

## Architectural Considerations

- Claude Code's plugin system may not support shared file injection. If not, option 3 (validated duplication) is the pragmatic fallback.
- CLAUDE.md is loaded into every conversation — it would give agents the shared principles without per-skill duplication.
- Must not break the self-contained skill contract. If a skill can't function without reading a separate file, that's a regression.

## Success Criteria

- Shared content exists in exactly one authoritative location.
- A change to a shared principle requires editing one file, not three.
- No increase in per-invocation token cost (ideally a reduction).
