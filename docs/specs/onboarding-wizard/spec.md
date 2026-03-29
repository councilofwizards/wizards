---
title: "Onboarding Wizard (/setup-project)"
status: "approved"
priority: "P3"
category: "developer-experience"
approved_by: "product-skeptic"
created: "2026-02-19"
updated: "2026-02-19"
---

# Onboarding Wizard (`/setup-project`) Specification

## Summary

A single-agent utility skill that bootstraps a project for use with the conclave
plugin. It detects the project's tech stack, scaffolds the `docs/` directory
structure, generates a project-specific `CLAUDE.md`, creates a starter roadmap
index, and guides the user to their next steps. Designed to take a new user from
plugin install to their first `/plan-product` invocation in under 5 minutes.

## Problem

New users must read the README, understand the three skills, set environment
variables, and manually create the `docs/` directory structure with the correct
subdirectories, template files, and roadmap index before they can use the
conclave plugin. The learning curve is steeper than necessary for a tool meant
to simplify development. There is no guided path from installation to first use.

Evidence:

- The README lists 7 steps before a user can run their first skill
- All three existing skills (`plan-product`, `build-product`, `review-quality`)
  duplicate the same directory-creation logic in their Setup sections
- No `CLAUDE.md` exists in the repository to guide agent behavior with
  project-specific conventions

## Solution

### Architecture

This is a **single-agent utility skill** — the simplest architecture in the
conclave framework. Unlike the existing multi-agent skills, `/setup-project`
runs as a single agent executing a deterministic sequential pipeline. There is
no team orchestration, no skeptic review, and no checkpoint protocol.

Rationale (see ADR-003 for full decision record):

- No subjective output requiring adversarial review
- No parallel work streams — steps are sequential
- No research phase — stack detection is a filesystem scan
- Cost-efficient — single agent vs. 4-5 Opus agents

### Execution Pipeline

The skill executes 6 steps in order:

#### Step 1: Detect Existing State

Before any writes, inventory what already exists to drive idempotency.

**Reads:**

- `CLAUDE.md` in project root
- `docs/` directory and subdirectories
- `docs/roadmap/_index.md`
- `docs/stack-hints/` contents
- Template files (`docs/specs/_template.md`, `docs/progress/_template.md`,
  `docs/architecture/_template.md`)

**Output:** Internal state map tracking which artifacts exist vs. are missing.

#### Step 2: Detect Tech Stack

Scan the project root for dependency manifests:

| File                                               | Stack Detected                                                                                     |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `package.json`                                     | Node.js (check deps for `next`, `react`, `vue`, `angular`, `svelte`, `express`, `fastify`, `nest`) |
| `composer.json`                                    | PHP (check for `laravel/framework`, `symfony/`)                                                    |
| `Gemfile`                                          | Ruby (check for `rails`)                                                                           |
| `go.mod`                                           | Go                                                                                                 |
| `requirements.txt` / `pyproject.toml` / `setup.py` | Python (check for `django`, `flask`, `fastapi`)                                                    |
| `Cargo.toml`                                       | Rust                                                                                               |
| `pom.xml` / `build.gradle`                         | Java/Kotlin                                                                                        |
| `mix.exs`                                          | Elixir (check for Phoenix)                                                                         |
| `pubspec.yaml`                                     | Dart/Flutter                                                                                       |
| `Package.swift`                                    | Swift                                                                                              |

**If no manifest found:** Inform user, proceed with "unknown" stack and default
categories. Ask user to specify their stack.

**If multiple manifests found:** Detect all, list them, ask user to confirm
primary stack.

**Framework-level detection:** Detect the framework, not just the language
(e.g., "Laravel" not "PHP", "Next.js" not "Node.js"). This drives stack-specific
content generation.

#### Step 3: Scaffold `docs/` Directory Structure

Create the standard directory structure used by all conclave skills (if
missing):

```
docs/
docs/roadmap/
docs/specs/
docs/progress/
docs/architecture/
docs/stack-hints/
```

**Files to create (if missing):**

- `.gitkeep` in each empty directory
- `docs/specs/_template.md` — standard spec template
- `docs/progress/_template.md` — standard progress/checkpoint template
- `docs/architecture/_template.md` — standard ADR template

**Template sourcing:** Templates are embedded directly in the SKILL.md as fenced
code blocks. This keeps the skill self-contained with no external file
dependencies.

**Idempotency:** Only create directories and files that do not already exist.
Never overwrite. Report what was created vs. skipped.

#### Step 4: Generate `CLAUDE.md`

Write a project-specific `CLAUDE.md` to the project root.

**If `CLAUDE.md` already exists:** DO NOT overwrite. Instead:

1. Read the existing content
2. Inform the user it already exists
3. Suggest additions as a bulleted list
4. Only modify if the user explicitly approves

**Generated content structure:**

```markdown
# Project Conventions

## Tech Stack

- {Detected stack summary}

## Development Guidelines

- {Stack-specific conventions, if stack hint content is available}
- {General conventions: testing, code style, etc.}

## Project Structure

- `docs/roadmap/` — Product roadmap items (one file per item)
- `docs/specs/` — Feature specifications
- `docs/progress/` — Agent progress checkpoints
- `docs/architecture/` — Architecture Decision Records (ADRs)
- `docs/stack-hints/` — Framework-specific guidance for agents

## Workflow

- Use `/plan-product` to plan features and create specs
- Use `/build-product` to implement features from approved specs
- Use `/review-quality` for security audits, performance analysis, and
  deployment readiness
```

#### Step 5: Generate `docs/roadmap/_index.md`

Create a starter roadmap index tailored to the project.

**If `docs/roadmap/_index.md` already exists:** Skip entirely. Do not modify
existing roadmaps.

**Category tailoring by project type (inferred from stack detection):**

| Project Type    | Suggested Categories                                                                          |
| --------------- | --------------------------------------------------------------------------------------------- |
| Web app (SaaS)  | `core-features`, `user-experience`, `infrastructure`, `developer-experience`, `documentation` |
| API service     | `endpoints`, `data-model`, `authentication`, `performance`, `documentation`                   |
| CLI tool        | `commands`, `configuration`, `output-formatting`, `developer-experience`, `documentation`     |
| Library/package | `api-surface`, `internals`, `compatibility`, `developer-experience`, `documentation`          |
| Mobile app      | `screens`, `navigation`, `data-sync`, `platform-specific`, `documentation`                    |
| Default         | `core-features`, `quality-reliability`, `developer-experience`, `documentation`               |

**Generated content:** Standard roadmap index format (per ADR-001) with
project-specific categories, prioritization framework, status legend, and empty
backlog section.

#### Step 6: Print Summary and Next Steps

Output a clear summary of what was created and guide the user forward:

```
## Setup Complete

### What was created:
- [x] docs/ directory structure (5 directories)
- [x] CLAUDE.md with {stack} conventions
- [x] docs/roadmap/_index.md with project categories
- [x] Template files (spec, progress, architecture)
- [ ] CLAUDE.md (already existed, suggestions printed above)

### Detected Stack: {stack}

### Next Steps:
1. Review the generated CLAUDE.md and adjust to your preferences
2. Run `/plan-product` to start planning your first feature
3. (Optional) Add a stack hint file at docs/stack-hints/{stack}.md for deeper framework guidance
```

### Arguments

| Argument    | Effect                                                                                          |
| ----------- | ----------------------------------------------------------------------------------------------- |
| (empty)     | Full setup with auto-detection                                                                  |
| `--force`   | Overwrite existing files (bypass idempotency checks). Still prompts for CLAUDE.md confirmation. |
| `--dry-run` | Show what would be created without writing any files                                            |

### Stack Hints

The skill creates the `docs/stack-hints/` directory but does NOT auto-generate
stack hint files for most stacks. Only `laravel.md` currently exists as a
bundled hint. The skill should:

- Create the directory structure
- If the detected stack has a bundled hint file, copy it to `docs/stack-hints/`
- If no bundled hint exists, inform the user they can create their own and
  explain the format
- Never promise hints for stacks that don't have bundled files

## Constraints

1. **Single-agent only.** No team spawning, no skeptic gate, no checkpoint
   protocol.
2. **Never overwrite existing files.** File-existence-based idempotency is
   non-negotiable (exception: `--force` flag).
3. **CLAUDE.md is never silently overwritten.** Even with `--force`, the user
   must confirm CLAUDE.md modifications.
4. **No code generation.** The skill creates documentation and scaffolding only
   — not application code.
5. **No git operations.** The skill does not commit, push, or create branches.
6. **No dependency installation.** The skill does not run package managers.
7. **No modification of existing roadmap items.** Create-only for the roadmap
   index.
8. **Templates are embedded in SKILL.md.** No external file dependencies for
   template content.

## Prerequisites

### Validator Adaptation (Required Before Implementation)

The CI validator at `scripts/validators/skill-structure.sh` requires ALL
SKILL.md files to have multi-agent sections (Setup, Spawn the Team,
Orchestration Flow, Failure Recovery, etc.). A single-agent skill would fail
validation.

**Resolution:** Adapt the validator to support a `type: single-agent`
frontmatter field. When present, the validator should:

- Skip checks for multi-agent sections (Spawn the Team, Orchestration Flow,
  Failure Recovery, Checkpoint Protocol)
- Still validate: YAML frontmatter (`name`, `description`, `argument-hint`),
  Setup section, Determine Mode section
- This is a prerequisite task that must be completed before the setup-project
  SKILL.md can be merged

## Out of Scope

- Custom agent role definitions (covered by P3-01)
- Interactive multi-step wizard prompting (auto-detection preferred)
- Stack hint generation for new frameworks (only bundled hints are used)
- Roadmap item creation (only the index structure is created)
- Modification or augmentation of existing documentation
- Plugin installation or environment variable configuration

## Files to Modify

| File                                    | Change                                                                                       |
| --------------------------------------- | -------------------------------------------------------------------------------------------- |
| `skills/setup-project/SKILL.md`         | **Create** — New single-agent skill definition                                               |
| `scripts/validators/skill-structure.sh` | **Modify** — Add `type: single-agent` frontmatter support to skip multi-agent section checks |
| `.claude-plugin/plugin.json`            | **Modify** — Register the new skill                                                          |

## Success Criteria

1. A new user can go from plugin install to first `/plan-product` invocation in
   under 5 minutes using `/setup-project`.
2. Running `/setup-project` on a fresh project creates the complete `docs/`
   directory structure with all 5 subdirectories and 3 template files.
3. Running `/setup-project` generates a `CLAUDE.md` with detected stack
   information and workflow guidance.
4. Running `/setup-project` generates a `docs/roadmap/_index.md` with
   project-type-appropriate categories.
5. Running `/setup-project` twice produces identical filesystem state — no
   duplicates, no overwrites, no errors.
6. Running `/setup-project` on a project with an existing `CLAUDE.md` does not
   overwrite it; instead, it suggests additions and asks the user before
   modifying.
7. Running `/setup-project --dry-run` produces console output describing what
   would be created without writing any files.
8. Running `/setup-project --force` overwrites existing scaffolding files
   (except CLAUDE.md, which still requires confirmation).
9. The skill correctly detects at least the following stacks: Node.js,
   PHP/Laravel, Ruby/Rails, Python/Django, Go, Rust, Java.
10. The CI validator passes for both single-agent and multi-agent SKILL.md files
    after the validator adaptation.

## Architecture References

- [ADR-003: Single-Agent Skill with File-Existence Idempotency](../../architecture/ADR-003-onboarding-wizard-single-agent.md)
- [System Design: Onboarding Wizard](../../architecture/onboarding-wizard-system-design.md)
- [Data Model Evaluation](../../architecture/onboarding-wizard-data-model.md)
