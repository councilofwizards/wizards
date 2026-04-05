---
title: "User-Writable Configuration Convention"
status: complete
priority: P2
category: core-framework
completed: "2026-03-27"
---

# P2-13: User-Writable Configuration Convention

## Summary

Established `.claude/conclave/` as the standard user-writable directory for project-specific plugin configuration.
setup-project now scaffolds the directory structure on init. wizard-guide documents the convention. build-implementation
reads project guidance files from `.claude/conclave/guidance/` at runtime.

## What Was Built

- `.claude/conclave/` directory convention with three subdirectories: `templates/`, `eval-examples/`, `guidance/`
- `plugins/conclave/skills/setup-project/SKILL.md` — Step 3.5 scaffolds `.claude/conclave/` skeleton with README.md
  files and .gitignore entry; 4 state map entries for conclave directory detection
- `plugins/conclave/skills/wizard-guide/SKILL.md` — "Project Configuration" section after Common Workflows documenting
  the convention, subdirectories, active consumers, .gitignore note
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 10 (defensive guidance reader for
  `.claude/conclave/guidance/*.md`); Spawn Step 4 (conditional guidance injection into teammate prompts)

## Key Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-11 (custom template overrides read from `.claude/conclave/templates/`)
