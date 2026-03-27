---
title: "Skill Composability"
status: "closed"
priority: "P2"
category: "new-skills"
effort: "large"
impact: "medium"
dependencies: ["state-persistence"]
created: "2026-02-14"
updated: "2026-03-27"
---

# Skill Composability (CLOSED)

## Status: Closed (2026-03-27)

Superseded by ADR-004 (two-tier architecture, itself superseded) and the current single-tier skill architecture. The artifact detection system in plan-product and build-product already provides implicit chaining — skills detect each other's artifacts via frontmatter and skip completed stages. Explicit workflow composition adds complexity without demonstrated user need.

## Problem

The three skills (`/plan-product`, `/build-product`, `/review-quality`) are fully self-contained but operate in isolation. A common workflow is plan → build → review, but each step requires manual invocation. There's no way to chain skills or define multi-step workflows.

## Proposed Solution

1. **Workflow skill**: A new `/run-workflow` skill that orchestrates a sequence of existing skills (e.g., plan → build → review for a single feature).
2. **Handoff protocol**: Define a structured handoff format that one skill writes and the next skill reads. The existing `docs/specs/` and `docs/progress/` directories already serve this purpose — formalize the contract.
3. **Workflow definitions**: Simple YAML files in `docs/workflows/` that define step sequences with conditions.

## Architectural Considerations

- This depends on state persistence (P1-02) — skills need reliable checkpoints to know what the previous step produced.
- The workflow skill must respect quality gates — it cannot skip Skeptic approval steps.
- Error handling: if a mid-workflow skill fails, the workflow should pause (not retry blindly).
- Complexity risk: keep workflows simple (linear sequences). Conditional branching is a future concern.

## Success Criteria

- A user can define a plan-build-review pipeline that runs with a single command.
- Each step's quality gate is preserved.
