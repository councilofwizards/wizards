---
title: "Persona File Authority — DRY Spawn Prompts"
status: not_started
priority: P3
category: engineering
effort: large
impact: high
dependencies:
  - None (can start independently, but proof-of-concept on audit-slop first)
created: 2026-04-04
updated: 2026-04-04
---

# P3-32: Persona File Authority — DRY Spawn Prompts

## Summary

Move agent-intrinsic content (identity, methodologies, output formats, critical rules, write safety patterns) from
inline SKILL.md spawn prompts into persona files at `plugins/conclave/shared/personas/`. Spawn prompts become thin
invocation-context injectors: teammate roster, scope, skill-specific mandate boundaries, and overrides.

## Motivation

Current SKILL.md files embed full spawn prompts (80-120 lines per agent) inline. Across 25 skills this creates massive
duplication. audit-slop is 1,640 lines — ~900 of which are spawn prompts. Maintenance cost scales linearly with skill
count. A methodology change requires editing every skill that uses a similar pattern.

The shared principles and communication protocol already follow an authoritative-source pattern (shared/ files synced to
skills). Persona files are the natural next step.

## Design

### Boundary Definition

- **Persona file (agent-intrinsic)**: identity, personality, communication style, methodologies with procedure steps and
  output formats, generic critical rules, output format templates, write safety patterns, cross-references
- **Spawn prompt (invocation-specific)**: teammate roster with run-ID suffixes, scope/topic, skill-specific mandate
  boundaries, phase assignments, paths to read, override instructions

### Override Convention

Spawn prompts may include a `SKILL-SPECIFIC OVERRIDES:` section that explicitly supersedes persona file content.
Override takes precedence over persona file when they conflict.

### Expected Reduction

Spawn prompts shrink from ~100 lines to ~10-15 lines per agent. For a 9-agent skill like audit-slop: ~900 lines → ~135
lines. Across the full skill inventory, estimated 40-60% total line reduction.

## Implementation Plan

1. **Proof of concept on audit-slop**: refactor one skill to use thin spawn prompts + authoritative persona files
2. **Define the override convention** and document in CLAUDE.md
3. **Update validators** to follow persona file references when checking methodology presence and output format
4. **Roll out** to all multi-agent skills incrementally
5. **Update Forge pipeline** so the Scribe generates thin spawn prompts by default

## Risks

- **Context injection reliability**: if an agent fails to read the persona file, they operate blind. Mitigation: persona
  file read is already the first line of every spawn prompt; agents that fail to read files fail on everything anyway.
- **Override complexity**: inheritance-like semantics can produce surprising behavior. Mitigation: overrides are
  explicit and limited to a named section; persona files are complete without overrides.
- **Auditability**: reviewing a skill requires reading multiple files. Mitigation: persona files are stable; the spawn
  prompt's override section is the only variable part.

## Success Criteria

1. audit-slop PoC passes all validators with thin spawn prompts
2. Line count reduction measured and documented
3. At least 5 skills migrated with no behavioral regression
4. Override convention documented in CLAUDE.md
