---
type: "compact-reference"
feature: "persona-system-activation"
source_roadmap: "docs/roadmap/P2-09-persona-system-activation.md"
compacted: "2026-04-05"
---

# Persona System Activation — Engineering Reference

## What Was Built

Injected fictional persona names + self-introduction instructions into 33 spawn prompts across 11 SKILL.md files. Added
sign-off convention and `{skill-skeptic}` placeholder to the shared communication protocol. Fixed a bash parameter
expansion bug in the sync script.

## Entrypoints

- `plugins/conclave/shared/communication-protocol.md` — authoritative source for sign-off convention + `{skill-skeptic}`
  placeholder
- `scripts/sync-shared-content.sh` — `extract_skeptic_names` function (hardened against `{braces}` expansion bug)
- `scripts/validators/skill-shared-content.sh` — normalizer patterns for `{skill-skeptic}` variants

## Files Modified/Created

- `plugins/conclave/shared/communication-protocol.md` — sign-off convention + `{skill-skeptic}` placeholder
- `scripts/sync-shared-content.sh` — AUTH constants, hardened `extract_skeptic_names`
- `scripts/validators/skill-shared-content.sh` — `{skill-skeptic}` / `{Skill Skeptic}` normalizer patterns
- 11 SKILL.md files — 33 spawn prompts updated with fictional name, title, and self-introduction instruction

## Dependencies

- **Depends on**: P2-05 (content-deduplication — shared/ architecture + sync script)
- **Depended on by**: nothing

## Configuration

Persona names and titles are hardcoded in each spawn prompt. The `{skill-skeptic}` placeholder in the shared protocol is
substituted at sync time by `extract_skeptic_names`.

## Validation

`bash scripts/validate.sh` — B2 (protocol drift with `{skill-skeptic}` normalization), B3 (authoritative source). Grep
verification: `grep -r "by your name" plugins/conclave/skills/*/SKILL.md` to confirm intro instructions.
