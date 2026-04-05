---
title: "Cost Guardrails"
status: complete
priority: P2
category: developer-experience
completed: "2026-02-14"
---

# P2-01: Cost Guardrails

## Summary

Added `--light` flag support to plan-product, build-product, and review-quality SKILL.md files to reduce Opus agent
usage for cost-sensitive invocations. Every skill invocation now writes a cost summary file to `docs/progress/`. The
Skeptic is never downgraded.

## What Was Built

- Lightweight Mode section in all 3 SKILL.md files (`--light` prefix parsing, conditional agent/model changes)
- Cost summary step as final orchestration step in all 3 skills
  (`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`)
- Updated `argument-hint` frontmatter in all 3 SKILL.md files to include `[--light]`
- README.md Lightweight Mode subsection with per-skill savings table

## Key Dependencies

- **Depends on**: nothing
- **Depended on by**: nothing (cross-cutting — used alongside any skill)
