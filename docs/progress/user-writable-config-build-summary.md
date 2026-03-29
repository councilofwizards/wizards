---
feature: "user-writable-config"
team: "build-product"
agent: "team-lead"
phase: "complete"
status: "complete"
completed: "2026-03-27"
---

# P2-13: User-Writable Configuration Convention — Build Summary

## Summary

Implemented P2-13 by editing 3 SKILL.md files to establish `.claude/conclave/`
as the standard user-writable directory for project-specific plugin
configuration. All 3 stages completed successfully: implementation planning
(approved first pass), build (3 SKILL.md edits, validators pass), quality review
(approved first pass, all 10 success criteria met).

## Changes

### plugins/conclave/skills/wizard-guide/SKILL.md

- Added "Project Configuration" section after Common Workflows documenting the
  `.claude/conclave/` convention, three subdirectories, active consumers table,
  and .gitignore note

### plugins/conclave/skills/setup-project/SKILL.md

- Added 4 state map entries for conclave directory detection
- Added Step 3.5: scaffold
  `.claude/conclave/{templates,eval-examples,guidance}/` with README.md files
  and .gitignore entry
- Added Step 6 summary checklist lines for conclave scaffolding
- Added "Embedded Configuration READMEs" section with verbatim README.md content
  for all 3 subdirectories

### plugins/conclave/skills/build-implementation/SKILL.md

- Added Setup step 10: defensive guidance reader for
  `.claude/conclave/guidance/*.md`
- Added Spawn the Team Step 4: conditional guidance injection into teammate
  prompts with mandatory framing

## Files Modified

- `plugins/conclave/skills/wizard-guide/SKILL.md`
- `plugins/conclave/skills/setup-project/SKILL.md`
- `plugins/conclave/skills/build-implementation/SKILL.md`
- `docs/roadmap/_index.md` — P2-13 status: 🟢 → 🔵 → ✅
- `docs/roadmap/P2-13-user-writable-config.md` — status: ready → complete

## Verification

- Plan Skeptic (Voss Grimthorn) approved implementation plan — first pass
- Quality Skeptic (Mira Flintridge) approved implementation — first pass, all 10
  success criteria met
- Conclave validators pass (pre-existing php-tomes failures are unrelated)
- No shared content changes, no sync script needed
- Backward compatible: projects without `.claude/conclave/` experience zero
  behavior change
