---
title: "Role-Based Principles Split — Build Engineering Progress"
type: "progress-checkpoint"
feature: "Role-Based Principles Split"
agent: "Bram Copperfield (Foundry Smith)"
status: "complete"
created: "2026-03-27"
updated: "2026-03-27"
source_roadmap_item: "docs/roadmap/P2-07-universal-principles.md"
source_spec: "docs/specs/principles-split/spec.md"
---

# Role-Based Principles Split — Build Engineering Progress

## Status: Complete

## Steps Completed

- [x] Step 1: Split `plugins/conclave/shared/principles.md` into two sub-blocks (`universal-principles` items 1-3,9-12
      and `engineering-principles` items 4-8)
- [x] Step 2: Updated all 14 multi-agent SKILL.md files with new placeholder markers (7 non-engineering: universal only;
      7 engineering: both)
- [x] Step 3: Updated `scripts/sync-shared-content.sh` (ENGINEERING_SKILLS/NON_ENGINEERING_SKILLS arrays,
      is_engineering_skill/is_known_skill helpers, dual-block injection, old-marker WARN, unknown-skill WARN)
- [x] Step 4: Updated `scripts/validators/skill-shared-content.sh` (B1 dual-block awareness, B3 retired-marker check)
      and `skill-structure.sh` (A4 now checks `universal-principles`)
- [x] Step 5: Ran `bash scripts/sync-shared-content.sh` — 14 synced, 14 skipped
- [x] Step 6: Verified no new regressions introduced. Pre-existing 4/211 state maintained (php-tomes failures
      pre-existed). Sync confirmed idempotent.
- [x] Step 7: Updated `CLAUDE.md` with Skill Classification section and canonical table

## Key Decisions

- A4 validator updated to check for `universal-principles` instead of `principles` (php-tomes failures were
  pre-existing, not new regressions)
- Sync idempotency confirmed: md5 hashes byte-identical after two consecutive sync runs
- B3 PASSES (all 28 files checked)
