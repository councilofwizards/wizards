---
type: "compact-reference"
feature: "artifact-format-templates"
source_roadmap: "docs/roadmap/P2-06-format-templates.md"
compacted: "2026-04-05"
---

# Artifact Format Templates — Engineering Reference

## What Was Built

Three static template files that standardize spec, progress summary, and ADR formats. Template read step (Step 2, "if
they exist" guard) added to each SKILL.md Setup section.

## Entrypoints

- `docs/specs/_template.md` — spec format reference
- `docs/progress/_template.md` — progress summary format reference
- `docs/architecture/_template.md` — ADR format reference

## Files Modified/Created

- `docs/specs/_template.md` — Created: YAML frontmatter + Summary/Problem/Solution/Constraints/Out of Scope/Files to
  Modify/Success Criteria sections
- `docs/progress/_template.md` — Created: YAML frontmatter + Summary/Changes/Files Modified/Files Created/Verification
  sections
- `docs/architecture/_template.md` — Created: YAML frontmatter + Status/Context/Decision/Alternatives
  Considered/Consequences sections
- `plugins/conclave/skills/plan-product/SKILL.md` — New Step 2 reads all 3 templates; Steps 2-5 renumbered to 3-6
- `plugins/conclave/skills/build-product/SKILL.md` — New Step 2 reads spec + progress templates; Steps 2-6 renumbered to
  3-7
- `plugins/conclave/skills/review-quality/SKILL.md` — New Step 2 reads progress template; Steps 2-6 renumbered to 3-7

## Dependencies

- **Depends on**: P1-00 (project-bootstrap — docs/ directories must exist)
- **Depended on by**: P2-03 (session summaries reference progress template), P2-11 (artifact templates validator
  extended)

## Configuration

Templates are optional reference documents — the "if they exist" guard means skills proceed normally without them.

## Validation

`bash scripts/validate.sh` — F-series in `scripts/validators/artifact-templates.sh` checks for template file existence
and required frontmatter fields.
