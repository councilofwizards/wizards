---
feature: "stack-generalization"
status: "complete"
completed: "2026-02-14"
---

# P1-03: Stack Generalization — Progress

## Summary

Removed all hard-coded Laravel/PHP references from SKILL.md files. Replaced with framework-agnostic language. Added stack detection step to Setup sections that reads dependency manifests and loads stack-specific hint files from `docs/stack-hints/`.

## Files Modified

- `plugins/conclave/skills/plan-product/SKILL.md` — Stack detection in Setup, framework-agnostic Shared Principle #4
- `plugins/conclave/skills/build-product/SKILL.md` — Stack detection in Setup, framework-agnostic spawn prompts and principles
- `plugins/conclave/skills/review-quality/SKILL.md` — Stack detection in Setup, framework-agnostic principles

## Files Created

- `docs/stack-hints/laravel.md` — Laravel-specific guidance preserved as a stack hint file

## Verification

- Pre-implementation plan reviewed and approved by Quality Skeptic
- Post-implementation code reviewed and approved by Quality Skeptic
