---
title: "Design Assumptions Documentation"
status: complete
priority: P3
category: documentation
effort: Small
impact: Low-Medium
dependencies:
  - P3-03 (soft — contribution guide provides context)
created: 2026-03-27
updated: 2026-03-27
---

# P3-31: Design Assumptions Documentation

## Summary

Add inline `<!-- SCAFFOLD: ... -->` comments to SKILL.md files documenting what each design choice compensates for in terms of model limitations, and when it could safely be removed or simplified.

## Motivation

Anthropic's harness design paper emphasizes that every harness component encodes assumptions about model capabilities, and these assumptions go stale as models improve. Documenting these assumptions makes it possible to systematically test whether scaffolding is still needed when a new model ships.

## Scope

- Audit existing SKILL.md files for design choices that compensate for model limitations
- Add `<!-- SCAFFOLD: [description]. Test without on [model class]. -->` comments
- Examples:
  - `<!-- SCAFFOLD: Stage decomposition compensates for context anxiety on long runs. Test without on Opus-class models. -->`
  - `<!-- SCAFFOLD: 3-rejection cap prevents infinite loops from inconsistent evaluation. May be relaxable with improved evaluator calibration (P3-29). -->`
  - `<!-- SCAFFOLD: Checkpoint after every action guards against context exhaustion. Test milestone-only frequency on 1M+ context models. -->`

## Success Criteria

1. All multi-agent SKILL.md files have at least one SCAFFOLD comment where applicable
2. Comments include both what the scaffold does and when to test removal
