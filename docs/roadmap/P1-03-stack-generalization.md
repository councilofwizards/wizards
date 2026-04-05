---
title: "Stack Generalization"
status: complete
priority: P1
category: core-framework
completed: "2026-02-14"
---

# P1-03: Stack Generalization

## Summary

Removed all hard-coded Laravel/PHP references from the 3 original SKILL.md files, replacing them with framework-agnostic
language. Added stack detection to each Setup section that reads dependency manifests and conditionally loads
`docs/stack-hints/` files. Laravel-specific guidance was preserved as `docs/stack-hints/laravel.md`.

## What Was Built

- Stack detection step added to Setup sections in plan-product, build-product, review-quality SKILL.md files
- Shared Principle #4 updated to framework-agnostic language ("follow the framework's conventions")
- `docs/stack-hints/laravel.md` — Laravel-specific guidance preserved as an addendum file

## Key Dependencies

- **Depends on**: nothing
- **Depended on by**: nothing (foundation change — all later skills inherit agnostic defaults)
