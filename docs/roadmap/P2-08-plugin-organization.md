---
title: "Plugin Organization — Internal Taxonomy & Infrastructure"
status: complete
priority: P2
category: core-framework
completed: "2026-03-27"
---

# P2-08: Plugin Organization — Internal Taxonomy & Infrastructure

## Summary

Added `category` and `tags` frontmatter to all 17 SKILL.md files and restructured plugin.json with a skills array.
Created ADR-005 documenting the plugin split readiness framework and a G-series automated gate validator. Parameterized
`SHARED_DIR` in the sync script and B-series validator. Added role-based progressive disclosure to wizard-guide.

## What Was Built

- `category` (required) and `tags` (optional) frontmatter fields in all 17 SKILL.md files
- `plugins/conclave/.claude-plugin/plugin.json` — restructured with skills array (name + category per skill)
- `scripts/validators/skill-structure.sh` — A1 updated to require `category` and validate values
- `docs/architecture/ADR-005-split-readiness.md` — threshold (7 business skills), prerequisites, trigger conditions
- `scripts/validators/split-readiness.sh` — G1 advisory WARN when business skill count reaches threshold
- `scripts/validate.sh` — G-series validator added
- Sync script and B-series validator — `CONCLAVE_SHARED_DIR` env var with fallback replaces hardcoded path
- `plugins/conclave/skills/wizard-guide/SKILL.md` — role selection prompt (Technical Founder / Engineering Team /
  Business & Operations)
- `CLAUDE.md` — Category Taxonomy table

## Key Dependencies

- **Depends on**: P2-07 (universal-shared-principles)
- **Depended on by**: nothing
