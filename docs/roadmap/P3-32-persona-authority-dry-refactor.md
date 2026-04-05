---
title: "Persona File Authority — DRY Spawn Prompts"
status: complete
priority: P3
category: engineering
completed: "2026-04-04"
---

# P3-32: Persona File Authority — DRY Spawn Prompts

## Summary

Refactored multi-agent SKILL.md files to use thin spawn prompts (~15 lines) that reference authoritative persona files
instead of duplicating agent content inline. Introduced a new P-series validator for persona file reference integrity
and schema completeness. Migrated audit-slop (PoC) plus review-pr, harden-security, squash-bugs, and refine-code.
Updated Forge/Scribe to generate thin spawn prompts by default.

## What Was Built

- `scripts/validators/persona-references.sh` — new P-series validator (P1: reference integrity, P2: schema completeness
  by archetype)
- `scripts/validate.sh` — registered persona-references.sh
- `plugins/conclave/shared/personas/*.md` (10 augur files) — added `<!-- non-overridable -->` to Critical Rules; content
  diff + migration
- `plugins/conclave/skills/audit-slop/SKILL.md` — PoC: 9 verbose spawn prompts → thin format (~976 → ~135 spawn lines)
- `plugins/conclave/skills/review-pr/SKILL.md`, `harden-security/SKILL.md`, `squash-bugs/SKILL.md`,
  `refine-code/SKILL.md` — migrations 2-5
- `plugins/conclave/skills/create-conclave-team/SKILL.md` — Scribe template updated to thin spawn prompt format +
  persona file generation instruction
- `CLAUDE.md` — added Override Convention and Persona File Schema docs under Skill Architecture
- `docs/progress/persona-authority-dry-migration-metrics.md` — before/after line count tracking

## Key Dependencies

- **Depends on**: None (independent; PoC on audit-slop first)
- **Persona files**: `plugins/conclave/shared/personas/` (doubt-augur.md through charter-augur.md)
- **Validation**: `bash scripts/validate.sh` (P1 + P2 checks pass after each migration)
