---
title: "Persona System ADR (ADR-005)"
status: "not_started"
priority: "P3"
category: "documentation"
effort: "small"
impact: "medium"
dependencies: ["persona-system-activation"]
created: "2026-03-10"
updated: "2026-03-10"
---

# Persona System ADR (ADR-005)

## Problem

The persona system is the largest undocumented architectural decision in the project. 45+ personas with fictional identities, the cross-reference structure, the dual communication style (terse agent-to-agent, personality-forward agent-to-user), and the fantasy theme rationale have no ADR.

## Proposed Solution

Write ADR-005 documenting:
- Why 45+ personas with fictional identities
- The cross-reference structure between persona files and SKILL.md spawn prompts
- The dual communication style design
- The fantasy theme rationale and naming conventions
- The persona file format and required fields

## Dependencies

- **Depends on P2-09** (Persona System Activation): ADR should document the completed system, not the broken pre-activation state
- Soft dependency on P3-08 (Persona Validator): ADR should mention the validator as part of architectural enforcement

## Success Criteria

- ADR-005 written following existing ADR template at `docs/architecture/_template.md`
- Documents decisions, rationale, and consequences per ADR format
- References persona files, spawn prompt patterns, and communication protocol
