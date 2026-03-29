---
title: "Evaluator Tuning Mechanism"
status: complete
priority: P3
category: quality-reliability
effort: Medium
impact: Medium
dependencies:
  - P2-11
  - P2-12
  - P2-13
  - P3-28
created: 2026-03-27
updated: 2026-03-27
---

# P3-29: Evaluator Tuning Mechanism

## Summary

Establish a few-shot calibration system for skeptic prompts: store graded examples of passing and failing outputs in
`.claude/conclave/eval-examples/`, and add a post-mortem quality rating step to pipeline completion. Over time,
calibration examples and quality ratings inform skeptic prompt refinement.

## Motivation

Anthropic's harness design paper found that evaluator tuning required multiple refinement cycles. Out-of-the-box Claude
is a poor QA agent — it identifies issues then talks itself out of flagging them. The best practices document recommends
storing calibration examples separately from SKILL.md to keep skills lean while making evaluator rubrics precise and
adjustable.

## Scope

- Calibration examples stored in `.claude/conclave/eval-examples/{skill-name}/` (user-writable, per P2-11 convention)
- Skeptic spawn prompts read calibration examples if they exist
- Post-mortem step appended to build-product and plan-product completion: user rates output quality
- Quality ratings logged to `docs/progress/quality-log.md`
- Periodic recalibration workflow documented

## Implementation Note

Best implemented after P2-11, P2-12, and P3-28 produce richer evaluation data to calibrate against.
