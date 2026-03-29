---
title: "Persona Reference Validator"
status: "ready"
priority: "P3"
category: "quality-reliability"
effort: "medium"
impact: "medium"
dependencies: ["persona-system-activation"]
created: "2026-03-10"
updated: "2026-03-10"
---

# Persona Reference Validator

## Problem

After persona names are injected into spawn prompts (P2-09), there is no
automated guard against regression. A future edit could remove or misspell a
fictional name, break a persona file reference, or add a spawn prompt without
persona grounding — and no validator would catch it.

## Proposed Solution

New G-series validator script (`scripts/validators/skill-persona-refs.sh`) that
checks:

1. Every spawn prompt in multi-agent SKILL.md files contains a persona file read
   instruction (`read plugins/conclave/shared/personas/{id}.md`)
2. The referenced persona file exists on disk
3. Spawn prompts contain a fictional name string matching the persona file's
   `fictional_name` frontmatter field

## Dependencies

- **HARD dependency on P2-09** (Persona System Activation): The validator checks
  for fictional names in spawn prompts. If P2-09 is not implemented first, every
  CI run will fail. Sequence is non-negotiable.
- Extends P2-04 (Automated Testing Pipeline, complete) infrastructure pattern

## Success Criteria

- G-series validator passes on all 12 multi-agent SKILL.md files
- Validator catches: missing persona references, non-existent persona files,
  mismatched fictional names
- Integrated into `scripts/validate.sh` runner
