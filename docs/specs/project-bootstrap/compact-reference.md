---
type: "compact-reference"
feature: "project-bootstrap"
source_roadmap: "docs/roadmap/P1-00-project-bootstrap.md"
compacted: "2026-04-05"
---

# Project Bootstrap & Initialization — Engineering Reference

## What Was Built

Added a directory-creation bootstrap step (Step 1) to the Setup sections of the 3 original SKILL.md files, ensuring
`docs/roadmap/`, `docs/specs/`, `docs/progress/`, and `docs/architecture/` exist before any agent reads from them. Empty
directories get `.gitkeep` files.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — Step 1 of Setup section
- `plugins/conclave/skills/build-product/SKILL.md` — Step 1 of Setup section
- `plugins/conclave/skills/review-quality/SKILL.md` — Step 1 of Setup section

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — New Step 1 (directory creation); renumbered steps 2-4
- `plugins/conclave/skills/build-product/SKILL.md` — New Step 1 (directory creation); renumbered steps 2-5
- `plugins/conclave/skills/review-quality/SKILL.md` — New Step 1 (directory creation); renumbered steps 2-5

## Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-06 (artifact-format-templates — requires dirs to exist for template seeding)

## Configuration

None — hardcoded directory list (`docs/roadmap/`, `docs/specs/`, `docs/progress/`, `docs/architecture/`).

## Validation

No dedicated validator. Verified by running any skill on a fresh checkout and confirming the directories are created.
