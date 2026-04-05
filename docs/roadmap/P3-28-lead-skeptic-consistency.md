---
title: "Lead-as-Skeptic Consistency Fix"
status: complete
priority: P3
category: quality-reliability
completed: "2026-03-27"
---

# P3-28: Lead-as-Skeptic Consistency Fix

## Summary

Added `--full` flag to plan-product that activates dedicated product-skeptic agents for Stages 1-3 (research, ideation,
roadmap review), bringing them into consistency with Stages 4-5. Default behavior (Lead-as-Skeptic for early stages) is
unchanged. Implemented as Group A of the harness-improvements batch alongside P3-27.

## What Was Built

- `--full` flag added to `plan-product/SKILL.md` Flag Parsing subsection
- `### Full Skeptic Mode (--full)` subsection added to plan-product Orchestration Flow
- Conditional skeptic gate blocks added to Stages 1-3 (if `--full` → product-skeptic gate, else → Lead-as-Skeptic)
- Product Skeptic spawn definition updated to cover Stages 1-5 when `--full` is active
- SCAFFOLD comment added above Lead-as-Skeptic Stage 1-3 blocks documenting the assumption

## Key Dependencies

- **Depends on**: P2-09 (complete), part of harness-improvements batch
- **Implemented alongside**: P3-27 (must batch — both modify plan-product SKILL.md)
- **Files modified**: `plan-product/SKILL.md` only
