---
title: "run-task Persona Archetypes"
status: "ready"
priority: "P3"
category: "core-framework"
effort: "medium"
impact: "medium"
dependencies: ["persona-system-activation"]
created: "2026-03-10"
updated: "2026-03-10"
---

# run-task Persona Archetypes

## Problem

run-task is the only skill where the persona system breaks down entirely. It dynamically composes agents from 4 generic archetypes (Engineer, Researcher, Writer, Skeptic) with no persona file assignments. Spawned agents are generic templates, not Conclave characters.

## Proposed Solution

1. Create 4 new persona files for run-task's generic archetypes with fictional names and the standard Identity/Communication Style sections
2. Update run-task SKILL.md spawn templates to reference these persona files
3. Pre-implementation: audit all 45+ existing persona names to ensure no conflicts with new names

## Dependencies

- Logically follows P2-09 (Persona System Activation) — spawn prompt persona injection pattern established there should be applied to run-task
- New persona names must not conflict with existing 45+ persona files (name uniqueness constraint)

## Success Criteria

- 4 new persona files created in `plugins/conclave/shared/personas/`
- run-task spawn templates reference persona files and include fictional names
- No naming conflicts with existing personas
- All validators pass after changes
