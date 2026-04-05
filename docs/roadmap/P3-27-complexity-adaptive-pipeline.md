---
title: "Complexity-Adaptive Pipeline"
status: complete
priority: P3
category: core-framework
completed: "2026-03-27"
---

# P3-27: Complexity-Adaptive Pipeline

## Summary

Added a complexity classifier at plan-product and build-product entry points that routes tasks to three pipeline depths:
Simple (skip to build-implementation), Standard (normal pipeline), Complex (full pipeline + additional checkpoints).
Implemented as Group A of the harness-improvements batch alongside P3-28.

## What Was Built

- `### Flag Parsing` and `### Complexity Classification` subsections added to `## Determine Mode` in
  `plan-product/SKILL.md` and `build-product/SKILL.md`
- `### Complexity Routing` added to Orchestration Flow preamble in both pipeline skills
- Artifact detection report format updated to include `Complexity:` field
- `--complexity` flag support (simple/standard/complex override)

## Key Dependencies

- **Depends on**: Part of harness-improvements batch — see `docs/specs/harness-improvements/`
- **Implemented alongside**: P3-28 (must batch — both modify plan-product Orchestration Flow)
- **Files modified**: `plan-product/SKILL.md`, `build-product/SKILL.md`
