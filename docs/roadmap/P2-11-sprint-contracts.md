---
title: "Sprint Contracts / Definition of Done"
status: complete
priority: P2
category: core-framework
completed: "2026-03-27"
---

# P2-11: Sprint Contracts / Definition of Done

## Summary

Added a pre-execution Contract Negotiation GATE to plan-implementation and build-product where the Lead and Skeptic
negotiate specific acceptance criteria before any code is written. The Quality Skeptic in build-implementation now
evaluates pass/fail against the signed sprint contract rather than only general principles.

## What Was Built

- `docs/templates/artifacts/sprint-contract.md` — artifact template with YAML frontmatter (feature,
  acceptance-criteria[], out-of-scope[], performance-targets, signed-by)
- `scripts/validators/artifact-templates.sh` — sprint-contract added to F-series expected templates
- `plugins/conclave/skills/plan-implementation/SKILL.md` — Setup step 2 reads contract template + custom override; new
  Orchestration Flow step 3 (Contract Negotiation GATE)
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 5 reads signed contract; conditional contract
  injection into Quality Skeptic spawn; Skeptic prompt extended with Sprint Contract Evaluation block
- `plugins/conclave/skills/build-product/SKILL.md` — Contract Negotiation before plan review (Stage 1); contract
  injection + edge case handling (Stage 2); Artifact Detection table sprint-contract row

## Key Dependencies

- **Depends on**: P2-06 (artifact templates), P2-13 (user-writable config — custom template overrides via
  `.claude/conclave/templates/`)
- **Depended on by**: P2-12 (QA agent reads sprint contract acceptance criteria)
