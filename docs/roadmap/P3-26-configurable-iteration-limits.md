---
title: "Configurable Skeptic Iteration Limits"
status: complete
priority: P3
category: core-framework
completed: "2026-03-27"
---

# P3-26: Configurable Skeptic Iteration Limits

## Summary

Added `--max-iterations N` flag to all 14 multi-agent skills, replacing hard-coded `3 rejections` skeptic deadlock rules
with a configurable ceiling (default: 3). Also added skeptic deadlock rules to 3 skills that lacked them
(research-market, ideate-product, manage-roadmap). Implemented as part of the harness-improvements batch (P3-26 through
P3-31).

## What Was Built

- `--max-iterations N` flag parsing in `## Determine Mode` of all 14 multi-agent SKILL.md files
- Deadlock rule text updated from hard-coded `3 times` → `N times (default 3, set via --max-iterations)` in Failure
  Recovery sections
- Added missing deadlock rule to research-market, ideate-product, manage-roadmap
- `## Common Flags` section added to `wizard-guide/SKILL.md`

## Key Dependencies

- **Depends on**: Part of harness-improvements batch — see `docs/specs/harness-improvements/`
- **Implemented alongside**: P3-27, P3-28, P3-30, P3-31 (Group B in implementation order)
- **Depended on by**: P3-29 (Evaluator Tuning) uses iteration data to calibrate examples
