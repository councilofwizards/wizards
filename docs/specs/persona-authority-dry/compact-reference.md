---
type: "compact-reference"
feature: "persona-authority-dry"
source_roadmap: "docs/roadmap/P3-32-persona-authority-dry-refactor.md"
compacted: "2026-04-05"
---

# Persona Authority DRY — Engineering Reference

## What Was Built

P-series validator for persona file integrity + thin spawn prompt migration for 5 skills (audit-slop PoC + review-pr,
harden-security, squash-bugs, refine-code). Spawn prompts shrank from ~100 lines to ~15 lines per agent by removing
agent-intrinsic content that already lives in authoritative persona files.

## Entrypoints

- `scripts/validators/persona-references.sh` — P1 (reference integrity) + P2 (schema completeness)
- `scripts/validate.sh` — registers persona-references.sh
- `plugins/conclave/shared/personas/` — authoritative persona files (source of truth for agent identity, methodology,
  output format, critical rules)
- `plugins/conclave/skills/create-conclave-team/SKILL.md` — Scribe template generates thin spawn prompts by default
- `docs/progress/persona-authority-dry-migration-metrics.md` — before/after line count tracking per skill

## Files Modified/Created

- `scripts/validators/persona-references.sh` — **Created**: P1 checks `First, read {path}` directives resolve to
  existing files; P2 checks required sections per archetype matrix
- `scripts/validate.sh` — **Modified**: registered persona-references.sh
- `plugins/conclave/shared/personas/doubt-augur.md` through `charter-augur.md` (10 files) — **Modified**: added
  `<!-- non-overridable -->` after `## Critical Rules`; content diff + migration of spawn-prompt-only content
- `plugins/conclave/skills/audit-slop/SKILL.md` — **Modified**: PoC — 9 verbose spawn prompts → thin format (~976 → ~135
  spawn lines)
- `plugins/conclave/skills/review-pr/SKILL.md` — **Modified**: migration #2
- `plugins/conclave/skills/harden-security/SKILL.md` — **Modified**: migration #3
- `plugins/conclave/skills/squash-bugs/SKILL.md` — **Modified**: migration #4
- `plugins/conclave/skills/refine-code/SKILL.md` — **Modified**: migration #5
- `plugins/conclave/skills/create-conclave-team/SKILL.md` — **Modified**: Scribe SPAWN PROMPT TEMPLATE updated to thin
  format; PERSONA FILE GENERATION instruction block added
- `CLAUDE.md` — **Modified**: `### Override Convention` + `### Persona File Schema` added under Skill Architecture

## Dependencies

- **Depends on**: None (independent; persona files pre-existed; no validator changes needed before PoC)
- **Depended on by**: New skills created by `create-conclave-team` (Scribe generates thin prompts)

## Configuration

### Thin Spawn Prompt Format (required structure)

```
Line 1: First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.
Line 3: You are {Fantasy Name}, {Title} — the {Role} on the {Team Name}.
Line 4: When communicating with the user, introduce yourself by your name and title.
Lines 6+: TEAMMATES / SCOPE / PHASE ASSIGNMENT / FILES TO READ / COMMUNICATION / WRITE SAFETY
Optional: SKILL-SPECIFIC OVERRIDES (omit entirely if no overrides)
Target: ≤20 lines (not counting overrides)
```

### Override Convention

- `SKILL-SPECIFIC OVERRIDES:` section at end of spawn prompt supersedes persona file content
- Overridable: Responsibilities, Output Format, Write Safety, Files to Read
- Non-overridable: Critical Rules (marked `<!-- non-overridable -->` in persona files)
- Override types: `ADD:` (new section) or `REPLACE:` (replaces named section)

### P2 Archetype Matrix (required sections by archetype)

| Section                      | assessor | skeptic | domain-expert | team-lead | lead | evaluator |
| ---------------------------- | -------- | ------- | ------------- | --------- | ---- | --------- |
| Identity                     | req      | req     | req           | req       | req  | req       |
| Role                         | req      | req     | req           | req       | req  | req       |
| Critical Rules               | req      | req     | req           | req       | req  | req       |
| Responsibilities/Methodology | req      | req     | req           | req       | opt  | req       |
| Output Format                | req      | req     | req           | req       | opt  | req       |
| Write Safety                 | req      | req     | req           | req       | req  | req       |
| Cross-References             | req      | req     | req           | req       | req  | req       |

## Validation

```bash
bash scripts/validate.sh
# P1: all spawn prompt persona file references must resolve
# P2: all persona files must have required sections for their archetype

# Verify migration line count reduction:
wc -l plugins/conclave/skills/audit-slop/SKILL.md
# Target: ≤984 lines (pre-migration: 1639)

# Mixed-state check (some migrated, some not must pass all validators):
bash scripts/validate.sh  # must exit 0 throughout rollout
```
