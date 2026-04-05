---
type: "compact-reference"
feature: "plugin-organization"
source_roadmap: "docs/roadmap/P2-08-plugin-organization.md"
compacted: "2026-04-05"
---

# Plugin Organization — Internal Taxonomy & Infrastructure — Engineering Reference

## What Was Built

Added `category`/`tags` frontmatter to 17 SKILL.md files, restructured plugin.json, wrote ADR-005, created G1
split-readiness validator, parameterized `SHARED_DIR` in sync script and B-series validator, added role-based
progressive disclosure to wizard-guide.

## Entrypoints

- `plugins/conclave/.claude-plugin/plugin.json` — skills array with name + category per skill
- `scripts/validators/split-readiness.sh` — G1 advisory WARN at 7 business skills threshold
- `scripts/sync-shared-content.sh` — `CONCLAVE_SHARED_DIR` env var replaces hardcoded path
- `scripts/validators/skill-shared-content.sh` — `CONCLAVE_SHARED_DIR` parameterized
- `plugins/conclave/skills/wizard-guide/SKILL.md` — role selection prompt

## Files Modified/Created

- `plugins/conclave/skills/*/SKILL.md` (17 files) — `category` and `tags` frontmatter added
- `plugins/conclave/.claude-plugin/plugin.json` — restructured with skills array
- `scripts/validators/skill-structure.sh` — A1 requires `category` and validates against allowed values
- `scripts/sync-shared-content.sh` — `CONCLAVE_SHARED_DIR` env var with fallback
- `scripts/validators/skill-shared-content.sh` — `CONCLAVE_SHARED_DIR` env var with fallback
- `scripts/validate.sh` — G-series validator added
- `plugins/conclave/skills/wizard-guide/SKILL.md` — role selection prompt + category-based filtering
- `CLAUDE.md` — Category Taxonomy table
- `docs/architecture/ADR-005-split-readiness.md` — Created
- `scripts/validators/split-readiness.sh` — Created
- `docs/specs/plugin-organization/sprint-contract.md` — Created (signed sprint contract)

## Dependencies

- **Depends on**: P2-07 (universal-shared-principles — declared prerequisite)
- **Depended on by**: nothing

## Configuration

`CONCLAVE_SHARED_DIR` env var — custom shared content path for sync and B-series validator. Defaults to
`plugins/conclave/shared/` if unset.

## Validation

`bash scripts/validate.sh` — A1 (category field), G1 (split-readiness business skill count).
