---
title: "Project Bootstrap & Initialization"
status: "complete"
priority: "P1"
category: "core-framework"
effort: "small"
impact: "high"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Project Bootstrap & Initialization

## Problem

All three skills assume `docs/roadmap/`, `docs/specs/`, `docs/progress/`, and `docs/architecture/` exist. On a fresh install, none of these directories exist. The first invocation of any skill will either fail or produce disoriented agents that can't find the artifacts they're told to read.

The Researcher flagged this as the single highest-impact gap (G1, CRITICAL). The DBA independently assessed it as P0. Both were approved by the Product Skeptic.

## Proposed Solution

**Minimum viable fix (this item)**: Add a Setup check to each SKILL.md that creates missing directories before any agent work begins. This is 4-6 lines per skill in the existing "Setup" section:

```markdown
## Setup

1. Verify docs/ directory structure exists. If any are missing, create them:
   - docs/roadmap/
   - docs/specs/
   - docs/progress/
   - docs/architecture/
2. Read docs/roadmap/ to understand current state
...
```

This is not an interactive wizard — it's a defensive check that ensures the skill can function on first use.

**Richer version (P3-02 Onboarding Wizard)**: A separate `/setup-project` skill that provides stack detection, CLAUDE.md generation, and guided configuration. That remains a P3 enhancement on top of this foundational fix.

## Architectural Considerations

- Zero dependencies — this can be implemented immediately.
- The fix is purely additive (new lines in existing Setup sections). No structural changes.
- Must be idempotent — creating directories that already exist is a no-op.
- Each SKILL.md is self-contained, so the check must be added to all three skills independently.

## Success Criteria

- A user who installs the plugin and immediately runs `/plan-product` on a project with no `docs/` directory gets a working experience.
- The directories are created silently without disrupting the skill's normal flow.
