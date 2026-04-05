---
type: "compact-reference"
feature: "user-writable-config"
source_roadmap: "docs/roadmap/P2-13-user-writable-config.md"
compacted: "2026-04-05"
---

# User-Writable Configuration Convention — Engineering Reference

## What Was Built

`.claude/conclave/` established as the standard user-writable directory for project-specific plugin configuration.
setup-project scaffolds the skeleton on init. wizard-guide documents the convention. build-implementation reads guidance
files at runtime.

## Entrypoints

- `plugins/conclave/skills/setup-project/SKILL.md` — Step 3.5 scaffolds `.claude/conclave/`
- `plugins/conclave/skills/wizard-guide/SKILL.md` — "Project Configuration" section
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 10 (guidance reader), Spawn Step 4 (guidance
  injection)

## Files Modified/Created

- `plugins/conclave/skills/setup-project/SKILL.md` — Step 3.5 scaffolds
  `.claude/conclave/{templates,eval-examples,guidance}/` with README.md files + .gitignore entry; 4 state map entries;
  Step 6 summary checklist; embedded README content section
- `plugins/conclave/skills/wizard-guide/SKILL.md` — "Project Configuration" section: convention docs, subdirectories,
  active consumers table, .gitignore note
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 10 (defensive guidance reader), Spawn Step 4
  (conditional guidance injection)

## Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-11 (sprint contracts — custom template overrides via `.claude/conclave/templates/`)

## Configuration

Directory structure:

```
.claude/conclave/
  templates/       # Custom artifact template overrides (P2-11 consumer)
  eval-examples/   # Skeptic calibration examples per skill (P3-29 consumer)
  guidance/        # Project-specific agent guidance files
```

`.claude/conclave/` should be in `.gitignore` (scaffolded by setup-project).

## Validation

No dedicated validator. Backward compatible: projects without `.claude/conclave/` experience zero behavior change (all
reads are defensive with graceful degradation).
