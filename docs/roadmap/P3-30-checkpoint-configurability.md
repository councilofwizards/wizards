---
title: "Checkpoint Frequency Configurability"
status: complete
priority: P3
category: developer-experience
completed: "2026-03-27"
---

# P3-30: Checkpoint Frequency Configurability

## Summary

Added `--checkpoint-frequency [every-step|milestones-only|final-only]` flag to all 14 multi-agent skills. The
`## When to Checkpoint` section in each skill was replaced with a conditional format listing what triggers checkpoints
under each mode. Default behavior (`every-step`) is unchanged. Implemented as Group D of the harness-improvements batch
alongside P3-31.

## What Was Built

- `--checkpoint-frequency` flag added to `### Flag Parsing` subsection in all 14 multi-agent SKILL.md files
- `### When to Checkpoint` section replaced with conditional format (every-step / milestones-only / final-only) in all
  14 skills
- SCAFFOLD comment added above each `### When to Checkpoint` section documenting the context-anxiety assumption

## Key Dependencies

- **Depends on**: P1-02 (checkpoint protocol complete), harness-improvements batch
- **Implemented alongside**: P3-31 (same Group D batch pass; both touch all 14 skills)
- **Files modified**: All 14 multi-agent SKILL.md files
