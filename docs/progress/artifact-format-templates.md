---
feature: "artifact-format-templates"
status: "complete"
completed: "2026-02-14"
---

# P2-06: Artifact Format Templates -- Progress

## Summary

Created 3 template files that standardize the format of specs, progress summaries, and ADRs. Added a template read step to each SKILL.md Setup section so agents load templates before producing artifacts. Templates are reference documents, not enforced schemas.

## Changes

### Template Files
- **Spec template** (`docs/specs/_template.md`): Sections — Summary, Problem, Solution, Constraints, Out of Scope, Files to Modify, Success Criteria. YAML frontmatter with title, status, priority, category, approved_by, created, updated.
- **Progress summary template** (`docs/progress/_template.md`): Sections — Summary, Changes, Files Modified, Files Created (optional), Verification. YAML frontmatter with feature, status, completed.
- **ADR template** (`docs/architecture/_template.md`): Sections — Status, Context, Decision, Alternatives Considered, Consequences. YAML frontmatter with title, status, created, updated, superseded_by.

### SKILL.md Setup Additions
- Each skill got a new Step 2 reading relevant templates with "if they exist" guard
- plan-product reads all 3 templates (produces specs, ADRs, progress)
- build-product reads 2 templates (consumes specs, produces progress)
- review-quality reads 1 template (writes findings/progress)

## Files Created

- `docs/specs/_template.md` -- Spec template
- `docs/progress/_template.md` -- Progress summary template
- `docs/architecture/_template.md` -- ADR template

## Files Modified

- `plugins/conclave/skills/plan-product/SKILL.md` -- Added Step 2 (template read), renumbered Steps 2-5 to 3-6
- `plugins/conclave/skills/build-product/SKILL.md` -- Added Step 2 (template read), renumbered Steps 2-6 to 3-7
- `plugins/conclave/skills/review-quality/SKILL.md` -- Added Step 2 (template read), renumbered Steps 2-6 to 3-7

## Verification

- Pre-implementation plan reviewed and approved by Quality Skeptic (Gate 1)
- Post-implementation files reviewed and approved by Quality Skeptic (Gate 2)
- All 7 success criteria verified
