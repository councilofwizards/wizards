---
title: "Sprint Contracts / Definition of Done"
status: complete
priority: P2
category: core-framework
effort: Medium
impact: High
dependencies:
  - P2-06 (complete)
  - P2-13
created: 2026-03-27
updated: 2026-03-27
---

# P2-11: Sprint Contracts / Definition of Done

## Summary

Add a pre-execution "Sprint Contract" step to the implementation pipeline where the Lead and Skeptic negotiate specific,
measurable acceptance criteria for a feature before any code is written. The Skeptic then evaluates against the
contract, not just general principles.

## Motivation

Anthropic's harness design paper identifies vague acceptance criteria as the primary driver of poor evaluator
performance. Currently, Skeptics review against general principles (INVEST, completeness, testability). A Sprint
Contract makes each evaluation specific, measurable, and reproducible — directly improving the reliability of every
quality gate.

The best practices document reinforces this: "high-level specs leave too much ambiguity, which causes the generator to
build the wrong thing and the evaluator to grade it against unclear criteria."

## Scope

- New artifact template: `docs/templates/artifacts/sprint-contract.md` with YAML frontmatter (`feature`,
  `acceptance-criteria[]`, `out-of-scope[]`, `performance-targets`, `signed-by`)
- New step in `plan-implementation` SKILL.md: Lead and Skeptic negotiate and sign off on contract before finalizing plan
- `build-implementation` Skeptic evaluates against contract terms (pass/fail per criterion)
- `build-product` Stage 2 incorporates the contract negotiation step

## Success Criteria

1. Sprint contract artifact template exists with defined schema
2. plan-implementation produces a signed contract before implementation begins
3. build-implementation Skeptic explicitly evaluates against contract criteria
4. Custom template overrides readable from `.claude/conclave/templates/` (per P2-13 convention)
5. All validators pass after changes
