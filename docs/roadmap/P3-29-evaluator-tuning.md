---
title: "Evaluator Tuning Mechanism"
status: complete
priority: P3
category: quality-reliability
completed: "2026-03-27"
---

# P3-29: Evaluator Tuning Mechanism

## Summary

Added a few-shot calibration system for skeptic prompts. Calibration examples stored in
`.claude/conclave/eval-examples/{skill-name}/` are read at Setup and injected into skeptic spawn prompts. A post-mortem
quality rating step appended to pipeline completion logs ratings to `docs/progress/quality-log.md`. Implemented as Group
C of the harness-improvements batch.

## What Was Built

- Eval examples Setup step added to `build-implementation/SKILL.md` and `plan-implementation/SKILL.md` (defensive read
  from `.claude/conclave/eval-examples/`)
- Post-mortem rating step added to Pipeline Completion in `build-implementation`, `plan-implementation`, `plan-product`,
  `build-product`
- `### Evaluator Calibration` instruction added inside skeptic spawn prompt code blocks (quality-skeptic, plan-skeptic,
  product-skeptic)
- User-writable calibration example directory: `.claude/conclave/eval-examples/{skill-name}/`
- Quality ratings logged to `docs/progress/quality-log.md`

## Key Dependencies

- **Depends on**: P2-11 (Sprint Contracts), P2-12, P2-13 (user-writable config convention), P3-28
- **Files modified**: `build-implementation/SKILL.md`, `plan-implementation/SKILL.md`, `plan-product/SKILL.md`,
  `build-product/SKILL.md`
