---
title: "Stack Generalization"
status: "not_started"
priority: "P1"
category: "core-framework"
effort: "medium"
impact: "high"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Stack Generalization

## Problem

The skill spawn prompts currently hard-code Laravel/PHP assumptions (e.g., "Laravel Way", "Eloquent models", "PHP artisan"). This limits the plugin to Laravel projects. Users working with other stacks (Next.js, Django, Rails, Go, etc.) must manually edit SKILL.md files to remove Laravel references — a poor developer experience that also risks breaking the carefully tuned prompts.

## Proposed Solution

1. **Stack-agnostic default prompts**: Replace Laravel-specific instructions with generic equivalents (e.g., "follow the framework's conventions" instead of "follow the Laravel Way").
2. **Stack detection**: At skill startup, read the project's package.json, composer.json, Gemfile, go.mod, etc. to auto-detect the tech stack.
3. **Stack-specific addenda**: Provide optional stack hint files (e.g., `docs/stack-hints/laravel.md`) that the skill prepends to spawn prompts when the relevant stack is detected.

## Scope

This item covers two layers of Laravel-specific content:

1. **Spawn prompts**: Role-specific instructions that reference Laravel concepts (Eloquent, Form Requests, Resources, Policies, Gates, migrations, artisan).
2. **Shared Principle #4**: Currently reads "Prefer framework-provided tools over custom implementations (the 'Laravel Way' for backend)." This must be updated to generic language (e.g., "follow the framework's conventions") since it's duplicated in all three SKILL.md files.

Both layers must be addressed — updating spawn prompts alone while leaving "the Laravel Way" in the shared principles would be an incomplete fix.

## Architectural Considerations

- The auto-detection logic runs once at skill startup (in the "Setup" phase) with minimal cost.
- Stack hints are additive — they supplement the default prompts, not replace them.
- Shared Principle #4 must be updated in all three SKILL.md files to use framework-agnostic language.
- Must not increase SKILL.md size significantly — keep stack hints in separate files.

## Success Criteria

- A non-Laravel project can use all three skills without editing any SKILL.md files.
- Laravel projects continue to get Laravel-specific guidance via stack hints.
