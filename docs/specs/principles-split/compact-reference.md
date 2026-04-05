---
type: "compact-reference"
feature: "principles-split"
source_roadmap: "docs/roadmap/P2-07-universal-principles.md"
compacted: "2026-04-05"
---

# Role-Based Principles Split — Engineering Reference

## What Was Built

Split `plugins/conclave/shared/principles.md` into universal-principles and engineering-principles blocks. Updated all
14 multi-agent SKILL.md files, the sync script (skill classification arrays), and the A4/B1/B3 validators.

## Entrypoints

- `plugins/conclave/shared/principles.md` — authoritative source (two named blocks)
- `scripts/sync-shared-content.sh` — syncs principles to all multi-agent SKILL.md files (ENGINEERING_SKILLS /
  NON_ENGINEERING_SKILLS arrays)
- `scripts/validators/skill-shared-content.sh` — B1/B3 dual-block drift detection
- `scripts/validators/skill-structure.sh` — A4 checks `universal-principles` marker

## Files Modified/Created

- `plugins/conclave/shared/principles.md` — Split into `universal-principles` (items 1-3, 9-12) and
  `engineering-principles` (items 4-8) blocks
- `plugins/conclave/skills/*/SKILL.md` (14 multi-agent files) — Updated with new `universal-principles` /
  `engineering-principles` markers
- `scripts/sync-shared-content.sh` — ENGINEERING_SKILLS/NON_ENGINEERING_SKILLS arrays, `is_engineering_skill` /
  `is_known_skill` helpers, dual-block injection, unknown-skill WARN
- `scripts/validators/skill-shared-content.sh` — B1 dual-block awareness, B3 retired-marker check
- `scripts/validators/skill-structure.sh` — A4 updated to check `universal-principles` instead of `principles`
- `CLAUDE.md` — Skill Classification section with canonical table

## Dependencies

- **Depends on**: P2-05 (content-deduplication — shared/ architecture and marker convention)
- **Depended on by**: P2-08 (plugin-organization — declared as prerequisite)

## Configuration

`CONCLAVE_SHARED_DIR` env var (set by P2-08) controls the shared/ path for sync script. Skill classification controlled
by ENGINEERING_SKILLS/NON_ENGINEERING_SKILLS arrays in `sync-shared-content.sh` and `skill-shared-content.sh`.

## Validation

`bash scripts/validate.sh` — B1 (principles drift), B3 (authoritative source), A4 (universal-principles marker).
