---
title: "Onboarding Wizard Skill"
status: complete
priority: P3
category: developer-experience
completed: "2026-02-19"
---

# P3-02: Onboarding Wizard Skill

## Summary

Implemented `/setup-project`, a single-agent utility skill that bootstraps projects for the conclave plugin. It detects
the tech stack, scaffolds the `docs/` directory structure, generates a project-specific `CLAUDE.md` and starter roadmap
index, and guides users through next steps. Also introduced the `type: single-agent` validator code path so single-agent
SKILL.md files pass CI.

## What Was Built

- `plugins/conclave/skills/setup-project/SKILL.md` — new single-agent skill (6-step pipeline: state detection, stack
  detection, docs scaffolding, CLAUDE.md generation, roadmap index generation, summary output)
- `scripts/validators/skill-structure.sh` — added `type: single-agent` code path (skips multi-agent section checks)
- `scripts/validators/skill-shared-content.sh` — excluded single-agent skills from shared content drift checks
- Supports `--force` (overwrite scaffolding) and `--dry-run` (no writes) flags
- Idempotent by default — never overwrites existing files without confirmation

## Key Dependencies

- **Required by**: ADR-003 (single-agent skill pattern), A2 validator code path
- **Depends on**: None (independent; validator adaptation was a prerequisite)
- **Architecture**: `docs/architecture/ADR-003-onboarding-wizard-single-agent.md`, `onboarding-wizard-system-design.md`,
  `onboarding-wizard-data-model.md`
