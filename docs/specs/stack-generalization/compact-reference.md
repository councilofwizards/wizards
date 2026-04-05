---
type: "compact-reference"
feature: "stack-generalization"
source_roadmap: "docs/roadmap/P1-03-stack-generalization.md"
compacted: "2026-04-05"
---

# Stack Generalization — Engineering Reference

## What Was Built

Removed Laravel/PHP hardcodes from 3 SKILL.md files. Added stack detection step to Setup sections that reads dependency
manifests (package.json, composer.json, etc.) and conditionally loads `docs/stack-hints/` files. Preserved Laravel
guidance as a stack hint file.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — stack detection step in Setup
- `plugins/conclave/skills/build-product/SKILL.md` — stack detection step in Setup
- `plugins/conclave/skills/review-quality/SKILL.md` — stack detection step in Setup
- `docs/stack-hints/laravel.md` — Laravel-specific guidance (addendum, not base behavior)

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — Stack detection in Setup; framework-agnostic Shared Principle #4
- `plugins/conclave/skills/build-product/SKILL.md` — Stack detection in Setup; framework-agnostic spawn prompts and
  principles
- `plugins/conclave/skills/review-quality/SKILL.md` — Stack detection in Setup; framework-agnostic principles
- `docs/stack-hints/laravel.md` — Created: Laravel-specific guidance preserved as optional stack addendum

## Dependencies

- **Depends on**: nothing
- **Depended on by**: nothing (foundational — all skills inherit agnostic defaults)

## Configuration

Stack hints live in `docs/stack-hints/`. Add `{framework}.md` to provide stack-specific guidance automatically loaded
when the stack is detected.

## Validation

No dedicated validator. Verified by reading SKILL.md Setup sections and confirming no Laravel-specific hardcodes.
