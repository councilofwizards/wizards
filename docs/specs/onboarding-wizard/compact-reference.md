---
type: "compact-reference"
feature: "onboarding-wizard"
source_roadmap: "docs/roadmap/P3-02-onboarding-wizard.md"
compacted: "2026-04-05"
---

# Onboarding Wizard — Engineering Reference

## What Was Built

Single-agent `/setup-project` skill that bootstraps projects for the conclave plugin in 6 sequential steps. Introduced
the `type: single-agent` validator code path.

## Entrypoints

- `plugins/conclave/skills/setup-project/SKILL.md` — skill definition (single-agent, no spawn prompts)
- `scripts/validators/skill-structure.sh` — A1/A2 validator with single-agent code path

## Files Modified/Created

- `plugins/conclave/skills/setup-project/SKILL.md` — **Created**: single-agent skill, 6-step pipeline
- `scripts/validators/skill-structure.sh` — **Modified**: added `type: single-agent` frontmatter check; single-agent
  path requires only `## Setup` + `## Determine Mode`; skips Spawn the Team, Orchestration Flow, Failure Recovery,
  Checkpoint Protocol checks
- `scripts/validators/skill-shared-content.sh` — **Modified**: single-agent skills excluded from B1/B2/B3 shared content
  drift checks

## Dependencies

- **Depends on**: ADR-003 (defines single-agent pattern rationale)
- **Depended on by**: Any future single-agent skill (uses the same validator code path); A2 validator single-agent
  branch

## Configuration

- Skill arguments: `--force` (overwrite scaffolding, still prompts for CLAUDE.md), `--dry-run` (no writes)
- CLAUDE.md modification requires explicit user confirmation even with `--force`
- Stack hints bundled: `docs/stack-hints/laravel.md` only; other stacks get directory only

## Validation

```bash
bash scripts/validate.sh
# A1/A2: single-agent SKILL.md requires type: single-agent in frontmatter,
#         Setup + Determine Mode sections only
# B-series: single-agent skills are skipped entirely
```
