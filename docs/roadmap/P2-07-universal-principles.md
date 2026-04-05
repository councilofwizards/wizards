---
title: "Role-Based Principles Split"
status: complete
priority: P2
category: core-framework
completed: "2026-03-27"
---

# P2-07: Role-Based Principles Split

## Summary

Split `plugins/conclave/shared/principles.md` into universal-principles (items 1-3, 9-12, all skills) and
engineering-principles (items 4-8: TDD, mocks, SOLID, contracts — engineering skills only). Updated all 14 multi-agent
SKILL.md files with new placeholder markers, the sync script with skill classification arrays, and the B/A-series
validators for dual-block awareness.

## What Was Built

- `plugins/conclave/shared/principles.md` split into two named blocks with new marker names
- All 14 multi-agent SKILL.md files updated with `universal-principles` / `engineering-principles` markers
- `scripts/sync-shared-content.sh` — ENGINEERING_SKILLS and NON_ENGINEERING_SKILLS arrays, `is_engineering_skill`
  helper, dual-block injection, unknown-skill WARN
- `scripts/validators/skill-shared-content.sh` — B1 dual-block awareness, B3 retired-marker check
- `scripts/validators/skill-structure.sh` — A4 updated to check `universal-principles`
- `CLAUDE.md` — Skill Classification section with canonical table

## Key Dependencies

- **Depends on**: P2-05 (content-deduplication — shared/ architecture and marker convention)
- **Depended on by**: P2-08 (plugin-organization — depends on this being done first)
