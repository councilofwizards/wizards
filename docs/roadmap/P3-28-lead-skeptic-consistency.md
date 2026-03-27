---
title: "Lead-as-Skeptic Consistency Fix"
status: not_started
priority: P3
category: quality-reliability
effort: Medium
impact: Medium
dependencies:
  - P2-09 (complete)
created: 2026-03-27
updated: 2026-03-27
---

# P3-28: Lead-as-Skeptic Consistency Fix

## Summary

Add dedicated skeptic agents to plan-product Stages 1-3 (research, ideation, roadmap), gated behind a `--full` flag. Currently these stages use Lead-as-Skeptic while Stages 4-5 use a dedicated product-skeptic. The paper confirms dedicated evaluators always outperform self-evaluation.

## Motivation

Anthropic's harness design paper's core finding is that separating generation from evaluation is more tractable than making generators self-critical. Having the Lead both orchestrate and evaluate in Stages 1-3 is the self-evaluation problem the paper warns against.

## Scope

- New skeptic spawn definitions for plan-product Stages 1-3
- `--full` flag activates dedicated skeptics; default behavior unchanged
- Skeptic personas needed for research, ideation, and roadmap review roles

> **Batching note**: Modifies plan-product SKILL.md alongside P3-27 (Complexity-Adaptive Pipeline). Recommend implementing together.
