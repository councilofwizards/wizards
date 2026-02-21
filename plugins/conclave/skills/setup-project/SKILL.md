---
name: setup-project
description: >
  Bootstrap a project for use with the conclave plugin. Detects tech stack,
  scaffolds the docs/ directory structure, generates CLAUDE.md, creates a
  starter roadmap, and guides the user to next steps.
argument-hint: "[--force | --dry-run]"
type: single-agent
---

# Setup Project

You are a single agent running a deterministic setup pipeline. There is no team to spawn, no skeptic gate, and no checkpoint protocol. Execute the 6 steps below in order and complete the setup in one pass.

## Setup

Read the project root to understand current state before doing anything else:

1. Check whether `CLAUDE.md` exists in the project root.
2. Check whether `docs/` exists and which subdirectories are present (`roadmap/`, `specs/`, `progress/`, `architecture/`, `stack-hints/`, `research/`, `ideas/`, `templates/artifacts/`).
3. Check whether `docs/roadmap/_index.md` exists.
4. Check whether the template files exist: `docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md`.
5. List any files already in `docs/stack-hints/`.

Build an internal state map from what you find:
```
claude_md_exists: bool
docs_dir_exists: bool
subdirs_present: [list of existing subdirs]
roadmap_index_exists: bool
stack_hints_present: [list of existing hint files]
templates_present: [list of existing templates]
```

This state map drives all conditional logic in the pipeline. Every write operation checks it before proceeding.

## Determine Mode

Based on `$ARGUMENTS`:

- **Empty/no args**: Full setup with auto-detection. Respect all idempotency rules — never overwrite existing files (except CLAUDE.md which always prompts).
- **`--force`**: Overwrite existing scaffolding files (directories, `.gitkeep`, template files, `docs/roadmap/_index.md`). CLAUDE.md still requires explicit user confirmation even with `--force` — never silently overwrite it.
- **`--dry-run`**: Show what would be created without writing any files. Output a list of all files and directories that would be created, prefixed with `[would create]`. Do not write anything to disk.

## Execution Pipeline

### Step 1: Detect Existing State

You already did this in the Setup section. Confirm your state map is complete before proceeding to Step 2. If any reads failed due to permission errors, report the error and stop — do not proceed with partial state.

### Step 2: Detect Tech Stack

Scan the project root for dependency manifests. Use the Stack Detection Table below to identify the tech stack.

**Framework-level detection is required.** Detect the framework, not just the language. "Laravel" not "PHP". "Next.js" not "Node.js". The detected stack identifier drives stack hint lookup and CLAUDE.md content.

**If no manifest found:** Inform the user that no dependency manifest was detected. Proceed with stack identifier `unknown` and use the Default categories from the Roadmap Categories Table. Ask the user to specify their stack so you can include accurate information in CLAUDE.md.

**If multiple manifests found:** Detect all, list them to the user, and ask which is the primary stack. Use the user's answer for all subsequent steps. Keep this to a single inline question — do not turn it into a multi-turn conversation.

**Output of this step:** A stack identifier string (e.g., `laravel`, `nextjs`, `rails`, `django`, `go`, `rust`) used in Steps 3, 4, and 5.

### Step 3: Scaffold docs/ Directory Structure

Create the standard directory structure used by all conclave skills.

**Directories to create (if missing, or if `--force`):**
```
docs/
docs/roadmap/
docs/specs/
docs/progress/
docs/architecture/
docs/stack-hints/
docs/research/
docs/ideas/
docs/templates/artifacts/
```

For each directory that is newly created and empty, add a `.gitkeep` file so git tracks it. Do not add `.gitkeep` retroactively to directories that already exist and contain files.

**Template files to create (if missing, or if `--force`):**

Create `docs/specs/_template.md` with the content from the Embedded Templates section below.
Create `docs/progress/_template.md` with the content from the Embedded Templates section below.
Create `docs/architecture/_template.md` with the content from the Embedded Templates section below.

**Stack hints:**

Check whether a bundled hint file exists for the detected stack. Currently, only `laravel.md` is bundled. If the detected stack matches a bundled hint and `docs/stack-hints/{stack}.md` does not already exist, copy the bundled hint content to `docs/stack-hints/{stack}.md`.

If no bundled hint exists for the detected stack, inform the user:
> No bundled stack hint exists for `{stack}`. You can create one at `docs/stack-hints/{stack}.md`. Stack hint files contain framework-specific conventions that are injected into agent prompts by `plan-product`, `build-product`, and `review-quality`. See an existing hint file for the format.

**Idempotency:** In normal mode, only create what does not already exist. In `--force` mode, overwrite scaffolding files and templates (but not CLAUDE.md — see Step 4). In `--dry-run` mode, print `[would create]` for each item without writing.

Report what was created vs. skipped in the Step 6 summary.

### Step 4: Generate CLAUDE.md

Write a project-specific `CLAUDE.md` to the project root.

**If `CLAUDE.md` already exists (in any mode including `--force`):**
1. Read the existing content.
2. Inform the user that `CLAUDE.md` already exists and show a preview of what you would generate.
3. Output a bulleted list of recommended additions based on the detected stack.
4. Ask the user explicitly: "Would you like me to append these suggestions to your existing CLAUDE.md? (yes/no)"
5. Only modify the file if the user answers yes.

**If `CLAUDE.md` does not exist:** Write it using the CLAUDE.md Template section below, substituting `{stack}` with the detected stack identifier and incorporating any relevant content from `docs/stack-hints/{stack}.md` if it exists.

Do not duplicate the full stack hint file — extract the most important conventions and summarize them in the Development Guidelines section.

### Step 5: Generate docs/roadmap/_index.md

Create a starter roadmap index tailored to the detected project type.

**If `docs/roadmap/_index.md` already exists:** Skip this step entirely. Do not modify existing roadmaps, even with `--force`.

**If it does not exist:** Generate it using the categories from the Roadmap Categories Table below, matched to the project type inferred from the detected stack:

- `laravel`, `rails`, `django`, `fastapi`, `flask`, `express`, `nestjs`, `phoenix` → Web app (SaaS) categories
- `fastify` → API service categories (lean API framework)
- `nextjs`, `react`, `vue`, `angular`, `svelte` → Web app (SaaS) categories (frontend frameworks typically build SaaS apps)
- `flutter`, `swift` → Mobile app categories
- `go`, `rust`, `java`, `kotlin` → API service categories (compiled languages commonly used for services)
- `unknown` or ambiguous → Default categories

If the project type is ambiguous, use the Default categories and note this in the summary.

**Generated content structure:**

```markdown
# Roadmap

This index tracks all roadmap items. Individual item files in this directory are the source of truth — this index is a navigational aid only.

## Categories

| Category | Description |
|----------|-------------|
| `{category-1}` | {description} |
| `{category-2}` | {description} |
...

## Prioritization Framework

- **P1** — Critical. Blocking other work or causing active harm.
- **P2** — High. Significant user impact. Should be in the next cycle.
- **P3** — Medium. Valuable but not urgent.
- **P4** — Low. Nice-to-have. Address when capacity allows.

## Status Legend

- Not started
- In progress (spec)
- Ready for implementation
- In progress (implementation)
- Complete
- Blocked

## Current Backlog

No items yet. Run `/plan-product` to add your first roadmap item.
```

### Step 6: Print Summary and Next Steps

Output a clear summary of everything that was done:

```
## Setup Complete

### What was created:
- [x] docs/ directory structure (N directories)
- [x] CLAUDE.md with {stack} conventions       ← only if created
- [ ] CLAUDE.md (already existed, see suggestions above)  ← only if skipped
- [x] docs/roadmap/_index.md                   ← only if created
- [ ] docs/roadmap/_index.md (already existed, skipped)   ← only if skipped
- [x] Template files (spec, progress, architecture)
- [x] docs/stack-hints/{stack}.md (bundled hint copied)   ← only if applicable

### Detected Stack: {stack}

### Next Steps:
1. Review the generated CLAUDE.md and adjust conventions to match your project
2. Run `/plan-product` to start planning your first feature
3. (Optional) Add or refine the stack hint at docs/stack-hints/{stack}.md for deeper framework guidance
```

For `--dry-run` mode, prefix the header with `## Dry Run — No files were written` and list all items as `[would create]` or `[would skip]`.

## Stack Detection Table

| Manifest File | Stack Identifier | Detection Notes |
|---------------|-----------------|-----------------|
| `package.json` | Check `dependencies`/`devDependencies` for framework: `next` → `nextjs`, `react` → `react`, `vue` → `vue`, `@angular/core` → `angular`, `svelte` → `svelte`, `express` → `express`, `fastify` → `fastify`, `@nestjs/core` → `nestjs`. If none match → `nodejs` |
| `composer.json` | Check `require` for: `laravel/framework` → `laravel`, `symfony/` prefix → `symfony`. If none match → `php` |
| `Gemfile` | Check for `rails` gem → `rails`. If not found → `ruby` |
| `go.mod` | `go` |
| `requirements.txt` or `pyproject.toml` or `setup.py` | Check contents for: `django` → `django`, `flask` → `flask`, `fastapi` → `fastapi`. If none match → `python` |
| `Cargo.toml` | `rust` |
| `pom.xml` or `build.gradle` | Check for Kotlin source files → `kotlin`. Default → `java` |
| `mix.exs` | Check for `phoenix` dep → `phoenix`. Default → `elixir` |
| `pubspec.yaml` | `flutter` |
| `Package.swift` | `swift` |

## Roadmap Categories Table

| Project Type | Stack Identifiers | Categories |
|-------------|-------------------|-----------|
| Web app (SaaS) | `nextjs`, `react`, `vue`, `angular`, `svelte`, `laravel`, `rails`, `django`, `flask`, `fastapi`, `express`, `nestjs`, `symfony`, `phoenix` | `core-features`, `user-experience`, `infrastructure`, `developer-experience`, `documentation` |
| API service | `fastify`, `go`, `rust`, `java`, `kotlin`, `python`, `nodejs`, `elixir` | `endpoints`, `data-model`, `authentication`, `performance`, `documentation` |
| Mobile app | `flutter`, `swift` | `screens`, `navigation`, `data-sync`, `platform-specific`, `documentation` |
| Default | `unknown` or ambiguous | `core-features`, `quality-reliability`, `developer-experience`, `documentation` |

## CLAUDE.md Template

When generating CLAUDE.md, use this structure:

```markdown
# Project Conventions

## Tech Stack
- {Detected stack name and version if detectable}

## Development Guidelines
- {Stack-specific conventions from stack hints, if available — summarize key points, do not duplicate the full hint file}
- Follow framework conventions over custom solutions
- Write tests for all new features

## Project Structure
- `docs/roadmap/` — Product roadmap items (one file per item)
- `docs/specs/` — Feature specifications
- `docs/progress/` — Agent progress checkpoints
- `docs/architecture/` — Architecture Decision Records (ADRs)
- `docs/stack-hints/` — Framework-specific guidance for agents
- `docs/research/` — Market research and analysis artifacts
- `docs/ideas/` — Product ideation artifacts
- `docs/templates/artifacts/` — Artifact schema templates for skill pipelines

## Workflow
- Use `/plan-product` to plan features and create specs
- Use `/build-product` to implement features from approved specs
- Use `/review-quality` for security audits, performance analysis, and deployment readiness
```

## Embedded Templates

Use these verbatim when creating template files in Step 3.

### docs/specs/_template.md

````markdown
---
title: ""
status: "draft"                  # draft | ready_for_review | approved | ready_for_implementation
priority: ""                     # P1 | P2 | P3
category: ""                     # core-framework | new-skills | developer-experience | quality-reliability | documentation
approved_by: ""                  # agent or role that approved
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
---

# {Title} Specification

## Summary

<!-- 1-3 sentences. A reader who stops here should understand WHAT this does and WHY. -->

## Problem

<!-- What's broken, missing, or suboptimal? Include evidence — references to code, user reports, or agent behavior. -->

## Solution

<!-- The proposed change. Structure with subsections as needed. For SKILL.md changes, show before/after diffs. For new systems, describe components and their interactions. -->

## Constraints

<!-- Non-negotiable rules, boundaries, or invariants. Numbered list. -->

## Out of Scope

<!-- What this spec explicitly does NOT cover. Prevents scope creep during implementation. -->

## Files to Modify

<!-- Table or list of files changed, with brief description of each change. -->

| File | Change |
|------|--------|

## Success Criteria

<!-- Numbered, testable statements. Each criterion should be verifiable by a human or automated test. -->
````

### docs/progress/_template.md

````markdown
---
feature: ""
status: "complete"               # in_progress | complete
completed: ""                    # YYYY-MM-DD (when status is complete)
---

# {Priority}: {Title} -- Progress

## Summary

<!-- 1-3 sentences describing what was done and why. -->

## Changes

<!-- Subsections for each logical group of changes, if the work is complex enough to warrant them. For simple features, a single paragraph is sufficient. -->

## Files Modified

<!-- List of files changed, with brief description of each change. -->

- `path/to/file.md` -- Description of change

## Files Created

<!-- Only include this section if new files were created. Omit entirely if not applicable. -->

- `path/to/new-file.md` -- Description

## Verification

<!-- How was quality confirmed? Reference Skeptic approvals, test results, success criteria checks. -->
````

### docs/architecture/_template.md

````markdown
---
title: ""
status: "proposed"               # proposed | accepted | deprecated | superseded
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
superseded_by: ""                # ADR number, if applicable
---

# ADR-{NNN}: {Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-NNN}

## Context

<!-- What forces are at play? What problem does this address? What constraints exist? -->

## Decision

<!-- What was decided and why. Include enough detail for someone unfamiliar with the discussion to understand the rationale. Use subsections if the decision has multiple parts. -->

## Alternatives Considered

<!-- What else was evaluated? Why was each rejected? Brief — 2-3 sentences per alternative. -->

### {Alternative 1 name}

{Description and reason for rejection.}

## Consequences

<!-- What are the results of this decision? List positives and negatives explicitly. -->

- **Positive**: ...
- **Negative**: ...
````

## Constraints

These constraints are non-negotiable. Violating any of them is a bug, not a design choice.

1. **Single-agent only.** Do not spawn subagents, teams, or parallel tasks. This skill runs as one agent completing one sequential pipeline.
2. **Never overwrite existing files.** In normal mode, file-existence-based idempotency is absolute. Only create what does not already exist.
3. **CLAUDE.md is never silently overwritten.** Even with `--force`, the user must explicitly confirm before CLAUDE.md is modified. No exceptions.
4. **No code generation.** Create documentation and scaffolding only. Do not write application code, configuration files, or scripts.
5. **No git operations.** Do not run `git add`, `git commit`, `git push`, or any other git command.
6. **No dependency installation.** Do not run `npm install`, `composer install`, `bundle install`, or any package manager.
7. **No modification of existing roadmap items.** The roadmap index may be created if missing, but existing roadmap files must not be touched.
8. **Templates are embedded.** All template content comes from the Embedded Templates section above. Do not read templates from disk during execution — they may not exist yet.

## Error Handling

| Error Scenario | Behavior |
|----------------|----------|
| No dependency manifest found | Inform user, proceed with stack `unknown`, use Default roadmap categories. Ask user to specify stack. |
| Multiple manifests (ambiguous stack) | List all detected stacks. Ask user to confirm primary. Proceed with user's choice. |
| Directory write fails (permissions error) | Report the error with the exact path that failed. Stop the pipeline. Do not continue with partial state. |
| Existing CLAUDE.md is very large | Read it, but do not attempt to merge. Only suggest additions as a separate block in console output. |
| `docs/roadmap/_index.md` already exists | Skip Step 5 entirely. Report as skipped in summary. Never modify existing roadmaps. |
| Template file already exists (normal mode) | Skip silently. Report as skipped in Step 6 summary. |
| Template file already exists (`--force` mode) | Overwrite with embedded template content. Report as overwritten in Step 6 summary. |
