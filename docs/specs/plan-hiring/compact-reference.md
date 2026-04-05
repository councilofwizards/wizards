---
type: "compact-reference"
feature: "plan-hiring"
source_roadmap: "docs/roadmap/P3-14-plan-hiring.md"
compacted: "2026-04-05"
---

# Plan Hiring — Engineering Reference

## What Was Built

`/plan-hiring` skill using the Structured Debate pattern: neutral Researcher, two debate agents (Growth Advocate vs
Resource Optimizer) with 3-message cross-examination rounds, lead synthesis, and dual-skeptic review (Bias Skeptic + Fit
Skeptic).

## Entrypoints

- `plugins/conclave/skills/plan-hiring/SKILL.md` — Structured Debate skill definition
- `docs/hiring-plans/_user-data.md` — user-provided team/budget/roles data (created on first run if missing)

## Files Modified/Created

- `plugins/conclave/skills/plan-hiring/SKILL.md` — **Created**: 6-phase Structured Debate skill (Phase 1: research,
  Phase 2: case building, Phase 3: cross-examination, Phase 4: synthesis, Phase 5: dual-skeptic review, Phase 6:
  finalize)
- `scripts/validators/skill-shared-content.sh` — **Modified**: added `bias-skeptic`/`Bias Skeptic` and
  `fit-skeptic`/`Fit Skeptic` to `normalize_skeptic_names()` (4 new sed expressions)

## Dependencies

- **Depends on**: `docs/architecture/plan-hiring-system-design.md`,
  `docs/architecture/business-skill-design-guidelines.md`, P3-10 lessons
- **Depended on by**: P2-07 threshold progress (7/8 skills)

## Configuration

- Arguments: `(empty)` (resume or new), `status`, `--light` (Sonnet for debate agents; Researcher + Skeptics stay Opus)
- User data: `docs/hiring-plans/_user-data.md` (current team, budget, roles under consideration)
- Output: `docs/hiring-plans/{date}-hiring-plan.md`
- Agent names: "Resource Optimizer" (not "Sustainability Advocate") — enforced by Constraint 10

## Validation

```bash
bash scripts/validate.sh
# B2: normalize_skeptic_names() must include bias-skeptic and fit-skeptic
```
