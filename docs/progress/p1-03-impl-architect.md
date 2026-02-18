---
feature: "p1-03-stack-generalization"
role: "impl-architect"
status: "plan-pending-review"
created: "2026-02-14"
---

# P1-03: Stack Generalization — Implementation Plan

## Summary

This plan removes all Laravel/PHP-specific references from the 3 SKILL.md files and replaces them with framework-agnostic equivalents. It also adds:

1. **Stack detection** step in each SKILL.md Setup section
2. **Stack hints** directory (`docs/stack-hints/`) with a sample `laravel.md` file
3. Updated **Shared Principle #4** in all 3 files
4. Framework-agnostic **spawn prompt** text for Architect, DBA, and Backend Engineer

**Total edits: 14** across 3 existing files + **1 new file** (`docs/stack-hints/laravel.md`) + **1 directory** (`docs/stack-hints/`).

---

## All Laravel-Specific References Found

Via grep for `Laravel|Eloquent|Form Request|artisan|"Laravel Way"`:

| File | Line | Reference |
|---|---|---|
| plan-product/SKILL.md | 97 | Shared Principle #4: `(the "Laravel Way" for backend)` |
| plan-product/SKILL.md | 207 | Architect prompt: `Prefer the "Laravel Way"` |
| plan-product/SKILL.md | 248 | DBA prompt: `Follow Laravel migration conventions` |
| build-product/SKILL.md | 61 | Backend Eng tasks: `Laravel Way` |
| build-product/SKILL.md | 116 | Shared Principle #4: `(the "Laravel Way" for backend)` |
| build-product/SKILL.md | 266 | Backend Eng prompt: `prefer the "Laravel Way."` |
| build-product/SKILL.md | 275 | Backend Eng prompt: `Use Laravel conventions: Eloquent, Form Requests...` |
| build-product/SKILL.md | 279-283 | Backend Eng implementation standards: Laravel-specific patterns |
| build-product/SKILL.md | 295 | Backend Eng test strategy: `Form Request validation rules` |
| build-product/SKILL.md | 297 | Backend Eng test strategy: `complex query scopes` |
| review-quality/SKILL.md | 112 | Shared Principle #4: `(the "Laravel Way" for backend)` |

---

## File 1: plugins/conclave/skills/plan-product/SKILL.md (4 edits)

### Edit A: Add stack detection to Setup + add stack-hints directory

**old_string:**
```
   - `docs/architecture/`
2. Read `docs/roadmap/` to understand current state
3. Read `docs/progress/` for latest implementation status
4. Read `docs/specs/` for existing specs
```

**new_string:**
```
   - `docs/architecture/`
   - `docs/stack-hints/`
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to understand current state
4. Read `docs/progress/` for latest implementation status
5. Read `docs/specs/` for existing specs
```

### Edit B: Update Shared Principle #4

**old_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations (the "Laravel Way" for backend). Every line of code is a liability.
```

**new_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
```

### Edit C: Update Architect spawn prompt

**old_string:**
```
- Prefer the "Laravel Way" — use framework conventions and built-in tools over custom solutions
```

**new_string:**
```
- Follow the project's framework conventions — use framework-provided tools over custom solutions
```

### Edit D: Update DBA spawn prompt

**old_string:**
```
- Follow Laravel migration conventions
```

**new_string:**
```
- Follow the project's database migration conventions and tooling patterns
```

---

## File 2: plugins/conclave/skills/build-product/SKILL.md (8 edits)

### Edit E: Add stack detection to Setup + add stack-hints directory

**old_string:**
```
   - `docs/architecture/`
2. Read `docs/roadmap/` to find the next "ready for implementation" item
3. Read the target spec from `docs/specs/[feature-name]/`
4. Read `docs/progress/` for any in-progress work to resume
5. Read `docs/architecture/` for relevant ADRs
```

**new_string:**
```
   - `docs/architecture/`
   - `docs/stack-hints/`
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to find the next "ready for implementation" item
4. Read the target spec from `docs/specs/[feature-name]/`
5. Read `docs/progress/` for any in-progress work to resume
6. Read `docs/architecture/` for relevant ADRs
```

### Edit F: Update Shared Principle #4

**old_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations (the "Laravel Way" for backend). Every line of code is a liability.
```

**new_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
```

### Edit G: Update Backend Engineer tasks line

**old_string:**
```
- **Tasks**: Implement server-side code. TDD. Laravel Way. Negotiate API contracts with frontend-eng.
```

**new_string:**
```
- **Tasks**: Implement server-side code. TDD. Follow framework conventions. Negotiate API contracts with frontend-eng.
```

### Edit H: Update Backend Engineer prompt opening

**old_string:**
```
migrations, API endpoints. You follow TDD strictly and prefer the "Laravel Way."
```

**new_string:**
```
migrations, API endpoints. You follow TDD strictly and prefer the project's framework conventions.
```

### Edit I: Update Backend Engineer critical rules (Laravel conventions)

**old_string:**
```
- Use Laravel conventions: Eloquent, Form Requests, Resources, Policies, Gates,
  Jobs, Events, Notifications. Don't build what the framework provides.
```

**new_string:**
```
- Use the project's framework conventions for models, validation, serialization,
  authorization, background jobs, and events. Don't build what the framework provides.
```

### Edit J: Update Backend Engineer implementation standards

**old_string:**
```
IMPLEMENTATION STANDARDS:
- Controllers are thin. Business logic lives in Services or Actions.
- Form Requests handle validation. Controllers don't validate.
- API Resources handle response shaping. Controllers return Resources.
- Use dependency injection. Never use static facades in business logic.
- Database transactions for multi-step writes.
- Consistent error response format: {message, errors, status_code}
```

**new_string:**
```
IMPLEMENTATION STANDARDS:
- Route handlers/controllers are thin. Business logic lives in service layers or dedicated modules.
- Use the framework's validation layer. Route handlers don't validate directly.
- Use the framework's response serialization. Route handlers return structured responses.
- Use dependency injection. Avoid global state and service locators in business logic.
- Database transactions for multi-step writes.
- Consistent error response format: {message, errors, status_code}
```

### Edit K: Update Backend Engineer test strategy (Form Request line)

**old_string:**
```
- Unit tests for Form Request validation rules
```

**new_string:**
```
- Unit tests for validation rules
```

### Edit L: Update Backend Engineer test strategy (query scopes line)

**old_string:**
```
- Feature tests ONLY for: auth/authorization flows, complex query scopes, migration verification
```

**new_string:**
```
- Feature tests ONLY for: auth/authorization flows, complex query logic, migration verification
```

---

## File 3: plugins/conclave/skills/review-quality/SKILL.md (2 edits)

### Edit M: Add stack detection to Setup + add stack-hints directory

**old_string:**
```
   - `docs/architecture/`
2. Read `docs/roadmap/` to understand what features are in play
3. Read `docs/specs/` for the target feature's spec and API contracts
4. Read `docs/progress/` for implementation status and known issues
5. Read `docs/architecture/` for relevant ADRs and system design
```

**new_string:**
```
   - `docs/architecture/`
   - `docs/stack-hints/`
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to understand what features are in play
4. Read `docs/specs/` for the target feature's spec and API contracts
5. Read `docs/progress/` for implementation status and known issues
6. Read `docs/architecture/` for relevant ADRs and system design
```

### Edit N: Update Shared Principle #4

**old_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations (the "Laravel Way" for backend). Every line of code is a liability.
```

**new_string:**
```
4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
```

---

## New File: docs/stack-hints/laravel.md

This file preserves all the Laravel-specific guidance removed from the SKILL.md files. It is automatically prepended to spawn prompts when the project's `composer.json` contains `laravel/framework`.

**Content:**

```markdown
# Laravel Stack Hints

These hints are automatically prepended to agent spawn prompts when a Laravel project is detected (via `composer.json` containing `laravel/framework`).

## General Principles

- Follow the "Laravel Way" — prefer Eloquent, Blade, built-in helpers, and conventions over custom solutions.
- Use `artisan` commands for scaffolding (`make:model`, `make:controller`, `make:request`, etc.).

## Backend Engineer Hints

- **Models**: Use Eloquent models with relationships, scopes, accessors, and mutators.
- **Validation**: Use Form Request classes for validation. Controllers don't validate.
- **Serialization**: Use API Resources for response shaping. Controllers return Resources.
- **Authorization**: Use Policies and Gates for authorization logic.
- **Background work**: Use Jobs, Events, Notifications, and Listeners for async processing.
- **Facades**: Avoid static facade calls in business logic — use dependency injection instead.
- **Testing**: Use Laravel's built-in testing helpers. Feature tests for auth/authorization flows, complex query scopes, migration verification.

## DBA Hints

- Follow Laravel migration conventions (`Schema::create`, `$table->timestamps()`, etc.).
- Use Eloquent relationships to define the data model in code.
- Soft deletes via `SoftDeletes` trait where audit trails are needed.

## Architect Hints

- Prefer Laravel's built-in service container, middleware, and event system.
- Use service providers for binding interfaces to implementations.
- Follow the standard Laravel directory structure unless there's a compelling reason to deviate.
```

---

## Design Decisions

1. **Stack hints are additive, not replacements**: The default SKILL.md prompts are framework-agnostic. Stack hints supplement them with framework-specific guidance. This means a project with no stack hints still works — agents just follow generic best practices.
2. **Detection by dependency manifest**: Reading `package.json`, `composer.json`, etc. is a cheap, reliable heuristic that runs once at startup. No external tools needed.
3. **One hint file per stack**: `docs/stack-hints/{stack}.md` keeps stack-specific content out of SKILL.md files entirely. Users can create their own (e.g., `nextjs.md`, `django.md`) or customize the provided `laravel.md`.
4. **Preserved Laravel guidance**: Every Laravel-specific instruction removed from SKILL.md files is preserved in `docs/stack-hints/laravel.md`. Laravel projects lose nothing.
5. **Generic implementation standards**: The Backend Engineer's implementation standards now use framework-agnostic language ("route handlers/controllers", "framework's validation layer", "framework's response serialization") that maps naturally to any web framework.

## Interaction with P1-01

This plan and P1-01 (Concurrent Write Safety) both modify the 3 SKILL.md files but touch different sections. P1-03 edits Setup steps, Shared Principle #4, and framework-specific spawn prompt text. P1-01 edits Write Safety sections, Orchestration Flow, Failure Recovery, and WRITE SAFETY blocks in spawn prompts. They can be implemented in either order — the implementing engineer should re-read files before applying edits to account for any renumbering.

The one overlap: P1-03 renumbers Setup steps (adds step 2 for stack detection). If P1-01 is applied first and references `4. Read docs/specs/...` or `5. Read docs/architecture/...` in old_string, those step numbers will have shifted to 5 and 6 respectively. The engineer should adjust accordingly.
