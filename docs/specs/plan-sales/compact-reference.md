---
type: "compact-reference"
feature: "plan-sales"
source_roadmap: "docs/roadmap/P3-10-plan-sales.md"
compacted: "2026-04-05"
---

# Plan Sales — Engineering Reference

## What Was Built

`/plan-sales` skill using the Collaborative Analysis pattern: 3 parallel analysis agents produce Domain Briefs,
cross-reference peers' findings, then the Team Lead synthesizes and dual-skeptic validates.

## Entrypoints

- `plugins/conclave/skills/plan-sales/SKILL.md` — Collaborative Analysis skill definition
- `docs/sales-plans/_user-data.md` — user-provided market data (created on first run if missing)

## Files Modified/Created

- `plugins/conclave/skills/plan-sales/SKILL.md` — **Created**: 5-phase Collaborative Analysis skill (Phase 1: parallel
  research, Phase 2: cross-referencing, Phase 3: synthesis, Phase 4: dual-skeptic review, Phase 5: finalize)
- `scripts/validators/skill-shared-content.sh` — **Modified**: added `strategy-skeptic`/`Strategy Skeptic` to
  `normalize_skeptic_names()` (2 new sed expressions)

## Dependencies

- **Depends on**: `docs/architecture/plan-sales-system-design.md`,
  `docs/architecture/business-skill-design-guidelines.md`
- **Depended on by**: P2-08 (Plugin Organization) — 2nd business skill (2/2 prerequisite)

## Configuration

- Arguments: `(empty)` (resume or new), `status`, `--light` (Sonnet for analysis agents; skeptics stay Opus)
- User data: `docs/sales-plans/_user-data.md` (market data, pricing, constraints)
- Output: `docs/sales-plans/{date}-sales-strategy.md`
- Progress: `docs/progress/plan-sales-summary.md`, `docs/progress/plan-sales-{date}-cost-summary.md`

## Validation

```bash
bash scripts/validate.sh
# B2: normalize_skeptic_names() must include strategy-skeptic
```
