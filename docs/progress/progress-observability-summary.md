---
feature: "progress-observability"
status: "complete"
completed: "2026-02-18"
---

# P2-03: Progress Observability -- Progress

## Summary

Added a `status` argument mode to all three skills (plan-product, build-product, review-quality) that reads checkpoint
files from `docs/progress/` and generates a consolidated status report without spawning agent teams. Formalized
end-of-session summary conventions across all skills. Added a Category E checkpoint file validator to the automated
testing pipeline.

## Changes

### Status Mode (3 SKILL.md files)

- Added `"status"` as the first bullet in each skill's Determine Mode section, before checkpoint scanning
- Updated `argument-hint` frontmatter in all three skills to include `status`
- Status mode reads checkpoint files with the matching `team` field, parses YAML frontmatter, and outputs a formatted
  status report. No agents are spawned.

### End-of-Session Summary (3 SKILL.md files)

- plan-product: Added step 8 to Orchestration Flow requiring session summary using `_template.md` format
- build-product: Expanded existing step 7 wording to include template-based convention and interruption handling
- review-quality: Added step 9 to Orchestration Flow (after existing step 8 cost summary)

### Checkpoint Validator (1 new script + 1 pipeline edit)

- Created `scripts/validators/progress-checkpoint.sh` (Category E) following the established validator pattern
- Validates 7 required checkpoint fields: feature, team, agent, phase, status, last_action, updated
- Validates `team` against allowed values and `status` against allowed values
- Integrated into `scripts/validate.sh` pipeline

## Files Modified

- `plugins/conclave/skills/plan-product/SKILL.md` -- argument-hint, status mode, session summary step
- `plugins/conclave/skills/build-product/SKILL.md` -- argument-hint, status mode, session summary step
- `plugins/conclave/skills/review-quality/SKILL.md` -- argument-hint, status mode, session summary step
- `scripts/validate.sh` -- added `run_validator "progress-checkpoint.sh"`

## Files Created

- `scripts/validators/progress-checkpoint.sh` -- Category E checkpoint file frontmatter validator

## Verification

- Quality Skeptic approved both PRE-IMPLEMENTATION (plan review) and POST-IMPLEMENTATION (code review) gates
- All 12 success criteria from the spec verified
- Validation pipeline passes: 11 passed, 0 failed (including new E1 validator on 26 checkpoint files)
- Malformed checkpoint file detection verified (missing status field produces [FAIL])
- Backward compatibility confirmed with all existing checkpoint files
