---
title: "Configurable Skeptic Iteration Limits"
status: complete
priority: P3
category: core-framework
effort: Small
impact: Medium
dependencies: []
created: 2026-03-27
updated: 2026-03-27
---

# P3-26: Configurable Skeptic Iteration Limits

## Summary

Add a `--max-iterations N` flag to multi-agent skills that controls the skeptic rejection cap before escalation to the
user. Default remains 3 (current behavior). Allows more iterations for subjective outputs (research, ideation) where 5+
rounds may be needed.

## Motivation

Anthropic's harness design paper describes 5-15 iteration cycles between generator and evaluator for subjective tasks
like frontend design. The current hard cap of 3 rejections before escalation is appropriate for implementation tasks
(tests either pass or fail) but may be conservative for research, ideation, and story writing where refinement is more
iterative.

## Scope

- `--max-iterations N` flag parsed at skill entry
- Default: 3 (unchanged current behavior)
- Update skeptic loop exit instructions across 14 multi-agent SKILL.md files
- Document recommended defaults per skill type in wizard-guide
