---
title: "Architecture & Contribution Guide"
status: "not_started"
priority: "P3"
category: "documentation"
effort: "small"
impact: "low"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Architecture & Contribution Guide

## Problem

The project has a README with installation and usage instructions, but lacks documentation for contributors. Someone wanting to add a new skill, modify agent prompts, or contribute a stack hint has no guide to follow.

## Proposed Solution

1. **Architecture overview document**: Explain the plugin structure, skill format, agent team patterns, and quality gate design.
2. **Contributing guide**: Step-by-step instructions for common contributions:
   - Adding a new skill
   - Adding a stack hint
   - Modifying agent prompts (with warnings about what not to change)
   - Adding a custom agent role (once P3-01 is implemented)
3. **Skill authoring template**: A starter SKILL.md template with all required sections and placeholder content.

## Architectural Considerations

- Documentation should live in `docs/` not in the plugin directory (it's project-level, not skill-level).
- The skill template must stay synchronized with the actual skill format — a validation test (P2-04) can enforce this.

## Success Criteria

- A contributor can create a new skill from the template without reading the full codebase.
