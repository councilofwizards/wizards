---
type: "compact-reference"
feature: "state-persistence"
source_roadmap: "docs/roadmap/P1-02-state-persistence.md"
compacted: "2026-04-05"
---

# State Persistence & Checkpoints — Engineering Reference

## What Was Built

Checkpoint Protocol sections added to all 3 original SKILL.md files. Agents write YAML-frontmatter checkpoints at key
milestones; skills scan `docs/progress/` for incomplete checkpoints on re-invocation to resume interrupted sessions.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — Checkpoint Protocol section; resume logic in Determine Mode
- `plugins/conclave/skills/build-product/SKILL.md` — Checkpoint Protocol section; resume logic in Determine Mode
- `plugins/conclave/skills/review-quality/SKILL.md` — Checkpoint Protocol section

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — Checkpoint Protocol section, resume logic in Determine Mode,
  checkpoint triggers in spawn prompts
- `plugins/conclave/skills/build-product/SKILL.md` — Checkpoint Protocol section, resume logic in Determine Mode,
  checkpoint triggers in spawn prompts
- `plugins/conclave/skills/review-quality/SKILL.md` — Checkpoint Protocol section, checkpoint triggers in spawn prompts

## Dependencies

- **Depends on**: P1-01 (concurrent-write-safety — role-scoped filenames prevent checkpoint conflicts)
- **Depended on by**: P2-03 (progress-observability — status mode reads checkpoint files)

## Configuration

Checkpoint format: YAML frontmatter with fields `feature`, `team`, `agent`, `phase`, `status`, `last_action`,
`updated` + free-form progress notes body.

## Validation

`bash scripts/validate.sh` — E1 check in `scripts/validators/progress-checkpoint.sh` validates all checkpoint files in
`docs/progress/` against the 7 required frontmatter fields.
