---
feature: "plugin-organization"
status: "complete"
completed: "2026-03-27"
---

# P2-08: Plugin Organization — Internal Taxonomy & Infrastructure — Progress

## Summary

Added machine-readable category and tag metadata to all 17 SKILL.md files, wrote
ADR-005 documenting the plugin split readiness framework with an automated
validator gate, parameterized the shared content infrastructure to support
configurable paths, and added progressive disclosure to wizard-guide with
role-based skill filtering.

## Changes

### Sub-task 1: Category Metadata + Skill Discovery Tags

- Added `category` (required) and `tags` (optional) YAML frontmatter fields to
  all 17 SKILL.md files
- Categories: engineering (7), planning (4), business (3), utility (3)
- Restructured `plugin.json` to include a `skills` array with `name` and
  `category` per skill
- Updated A1 validator to require `category` and validate against allowed values
- Added Category Taxonomy table to CLAUDE.md alongside existing shared-content
  classification

### Sub-task 2: ADR-005 + Automated Gate

- Wrote ADR-005-split-readiness.md documenting threshold (7 business skills),
  prerequisites, and trigger conditions
- Created G-series validator `split-readiness.sh` that emits advisory WARN at
  threshold
- Added to `validate.sh` runner

### Sub-task 3: Parameterized Shared Content Infrastructure

- Changed `SHARED_DIR` in sync script and B-series validator to use
  `CONCLAVE_SHARED_DIR` env var with fallback
- Added existence validation for custom paths; empty string treated as unset

### Sub-task 4: Progressive Disclosure in wizard-guide

- Added role selection prompt (Technical Founder / Engineering Team / Business &
  Operations)
- Category-based filtering: each role sees relevant skill subsets
- Default behavior preserved: no selection shows all skills

## Files Modified

- `plugins/conclave/skills/*/SKILL.md` (17 files) — Added category and tags
  frontmatter
- `plugins/conclave/.claude-plugin/plugin.json` — Restructured with skills array
- `scripts/validators/skill-structure.sh` — Category required field + value
  validation
- `scripts/sync-shared-content.sh` — SHARED_DIR parameterized
- `scripts/validators/skill-shared-content.sh` — SHARED_DIR parameterized
- `scripts/validate.sh` — Added split-readiness validator
- `plugins/conclave/skills/wizard-guide/SKILL.md` — Role selection + progressive
  disclosure
- `CLAUDE.md` — Category Taxonomy table
- `docs/roadmap/P2-08-plugin-organization.md` — Status → complete
- `docs/roadmap/_index.md` — Status → ✅

## Files Created

- `docs/architecture/ADR-005-split-readiness.md` — Split readiness ADR
- `scripts/validators/split-readiness.sh` — G1 business skill count gate
- `docs/specs/plugin-organization/sprint-contract.md` — Signed sprint contract

## Verification

- Sprint contract: 13/13 ACs verified by Quality Skeptic (Mira Flintridge)
- All conclave validators pass with zero new failures
- G1/split-readiness: PASS (3 business skills, below threshold)
- CONCLAVE_SHARED_DIR edge cases tested: non-existent path errors, empty string
  uses default
