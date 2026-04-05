---
title: "Persona System Activation"
status: complete
priority: P2
category: core-framework
completed: "2026-03-10"
---

# P2-09: Persona System Activation

## Summary

Injected fictional persona names and self-introduction instructions into 33 spawn prompts across 11 SKILL.md files so
agents identify themselves by character during execution. Added a sign-off convention to the shared communication
protocol and changed the `product-skeptic` placeholder to a generic `{skill-skeptic}` substitution pattern. Fixed a bash
parameter expansion bug in the sync script discovered during implementation.

## What Was Built

- 33 spawn prompt persona injections across 11 SKILL.md files (name + title + intro instruction per agent)
- `plugins/conclave/shared/communication-protocol.md` — sign-off convention + `{skill-skeptic}` placeholder
- `scripts/sync-shared-content.sh` — AUTH constants, hardened `extract_skeptic_names` against `{braces}` parameter
  expansion bug
- `scripts/validators/skill-shared-content.sh` — `{skill-skeptic}`/`{Skill Skeptic}` normalizer patterns added

## Key Dependencies

- **Depends on**: shared content infrastructure (P2-05 markers + sync script)
- **Depended on by**: nothing
