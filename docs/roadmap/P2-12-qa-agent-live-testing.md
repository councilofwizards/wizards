---
title: "QA Agent for Live Testing"
status: complete
priority: P2
category: quality-reliability
completed: "2026-03-27"
---

# P2-12: QA Agent for Live Testing

## Summary

Added a dedicated QA agent (Maren Greystone, Inspector of Carried Paths) to build-implementation and build-product that
writes and executes Playwright/e2e tests against the running application. The QA agent runs after the Quality Skeptic
approves code quality and before final Lead sign-off — a distinct role evaluating runtime behavior, not code diffs.

## What Was Built

- `plugins/conclave/shared/personas/qa-agent.md` — Maren Greystone persona with role separation table, checkpoint
  triggers, output format, write safety
- `plugins/conclave/skills/build-implementation/SKILL.md` — QA Agent spawn definition (opus), full spawn prompt, QA GATE
  step (step 6, after Quality Skeptic), qa-testing checkpoint phase, --light mode note, 2 critical rules, QA deadlock to
  failure recovery
- `plugins/conclave/skills/build-product/SKILL.md` — same changes mirrored; qa-verdict added to Artifact Detection table

## Key Dependencies

- **Depends on**: P2-11 (soft — QA reads sprint contract acceptance criteria when available)
- **Depended on by**: nothing
