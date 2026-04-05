---
type: "compact-reference"
feature: "cost-guardrails"
source_roadmap: "docs/roadmap/P2-01-cost-guardrails.md"
compacted: "2026-04-05"
---

# Cost Guardrails — Engineering Reference

## What Was Built

`--light` flag support and cost summary steps added to plan-product, build-product, and review-quality SKILL.md files.
README updated with lightweight mode documentation.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — Lightweight Mode section + cost summary step
- `plugins/conclave/skills/build-product/SKILL.md` — Lightweight Mode section + cost summary step
- `plugins/conclave/skills/review-quality/SKILL.md` — Lightweight Mode section (no-op) + cost summary step

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — Lightweight Mode section, cost summary step, `argument-hint` updated
  to include `[--light]`
- `plugins/conclave/skills/build-product/SKILL.md` — same
- `plugins/conclave/skills/review-quality/SKILL.md` — same (lightweight mode is accepted but no-op for this skill)
- `README.md` — Lightweight Mode subsection added inside Cost Considerations

## Dependencies

- **Depends on**: nothing
- **Depended on by**: nothing

## Configuration

`--light` is a `$ARGUMENTS` prefix modifier: strip flag, set mode, continue normal argument parsing.

Cost summary file naming: `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

## Validation

No dedicated validator. Verify via `argument-hint` field in SKILL.md frontmatter and Lightweight Mode section presence.
