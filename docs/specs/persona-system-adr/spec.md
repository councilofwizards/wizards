---
title: "Persona System ADR Specification"
status: "approved"
priority: "P3"
category: "documentation"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Persona System ADR Specification

## Summary

Write ADR-006 documenting the persona system architecture: why 45+ persona files with fictional identities exist, the
required file format, the cross-reference structure between persona files and spawn prompts, the dual communication
style convention, and the fantasy-world theme rationale. Single markdown file, no code changes.

## Problem

The persona system is the largest undocumented architectural decision. It spans 45+ persona files, 14 multi-agent
skills, a G2 validator, and a dual communication protocol — but none of the rationale, constraints, or design decisions
are recorded in an ADR. Contributors encountering the system must reverse-engineer intent from files and CLAUDE.md
fragments.

## Solution

### ADR-006 at `docs/architecture/ADR-006-persona-system.md`

**Status**: Accepted (P2-09 complete, system in production)

**Context section** should cover:

- Agent identity problem: without personas, agents default to generic "assistant mode" — terse, impersonal,
  interchangeable
- The fantasy-world theme as a solution for identity consistency and user engagement
- The dual communication style need: agents coordinating internally don't need flavor, but users deserve immersive
  interaction

**Decision section** should cover:

- Persona files as the single source of truth for agent identity (not inline in spawn prompts)
- Required frontmatter fields: `id`, `fictional_name`, `title`, `model`, `archetype`, `skill`, `team`
- Cross-reference pattern: spawn prompts contain `read plugins/conclave/shared/personas/{id}.md` + fictional name
- G2 validator (`skill-persona-refs.sh`) enforces referential integrity (mention P3-08)
- Single-agent skills excluded (no spawn prompts)
- Known gap: run-task uses generic archetypes without persona files (P3-24 addresses this)

**Alternatives Considered**:

- No personas — embed identity in spawn prompts directly. Rejected: duplication, drift, no single source of truth.
- Generic role names without fantasy theme. Rejected: reduces user engagement, agents blend together, no character
  continuity across sessions.

**Consequences**:

- Positive: consistent agent identity, immersive user experience, single source of truth, automated enforcement via G2
- Negative: 45+ files to maintain, naming conventions to enforce, new contributor onboarding overhead

### Length and Tone

400-600 words. Substantive rationale, not just a catalog. References `plugins/conclave/shared/personas/` as the
authoritative location without listing individual files.

## Constraints

1. Single markdown file — no code or validator changes
2. Follows ADR-001 through ADR-005 format and frontmatter conventions
3. Status is "accepted" (not "proposed") since the system is already in production
4. Must not conflict with CLAUDE.md documentation of the persona system

## Out of Scope

- Creating or modifying persona files
- Documenting individual persona name choices
- G2 validator implementation details (belongs to P3-08)
- Changing any aspect of the persona system

## Files to Modify

| File                                          | Change                   |
| --------------------------------------------- | ------------------------ |
| `docs/architecture/ADR-006-persona-system.md` | New — persona system ADR |

## Success Criteria

1. ADR-006 exists and follows the standard ADR template
2. Documents: persona file rationale, required format, cross-reference pattern, dual communication style, fantasy theme
   decision
3. Acknowledges run-task exception (P3-24) and single-agent exclusion
4. References G2 validator as enforcement mechanism
5. `bash scripts/validate.sh` passes after creation
