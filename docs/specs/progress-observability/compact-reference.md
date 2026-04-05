---
type: "compact-reference"
feature: "progress-observability"
source_roadmap: "docs/roadmap/P2-03-progress-observability.md"
compacted: "2026-04-05"
---

# Progress Observability — Engineering Reference

## What Was Built

`status` argument mode added to 3 SKILL.md files (reads checkpoint files, outputs consolidated report, no agents
spawned). End-of-session summary steps formalized. E1 checkpoint validator created and integrated into
`scripts/validate.sh`.

## Entrypoints

- `scripts/validators/progress-checkpoint.sh` — E1 validator
- `plugins/conclave/skills/plan-product/SKILL.md` — `status` mode in Determine Mode
- `plugins/conclave/skills/build-product/SKILL.md` — `status` mode in Determine Mode
- `plugins/conclave/skills/review-quality/SKILL.md` — `status` mode in Determine Mode

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — argument-hint, status mode, session summary step (step 8 in
  Orchestration Flow)
- `plugins/conclave/skills/build-product/SKILL.md` — argument-hint, status mode, session summary step
- `plugins/conclave/skills/review-quality/SKILL.md` — argument-hint, status mode, session summary step (step 9)
- `scripts/validate.sh` — `run_validator "progress-checkpoint.sh"` added
- `scripts/validators/progress-checkpoint.sh` — Created: E1 check, validates 7 required checkpoint fields + enum values

## Dependencies

- **Depends on**: P1-02 (state-persistence — checkpoint format), P2-04 (automated-testing — validator pipeline)
- **Depended on by**: nothing

## Configuration

Status mode triggered by `status` as `$ARGUMENTS`. Checkpoint files must include: `feature`, `team`, `agent`, `phase`,
`status`, `last_action`, `updated`.

## Validation

`bash scripts/validate.sh` — E1 check validates all checkpoint files in `docs/progress/`.
