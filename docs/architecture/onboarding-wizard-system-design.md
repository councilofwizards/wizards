---
title: "Onboarding Wizard System Design"
status: "approved"
created: "2026-02-19"
updated: "2026-02-19"
---

# Onboarding Wizard (`/setup-project`) System Design

## Overview

A single-agent skill that bootstraps a project for use with the conclave plugin. It detects the project's tech stack,
scaffolds the `docs/` directory structure, generates a project-specific `CLAUDE.md`, creates a starter roadmap, and
guides the user to the next steps. Designed to take a new user from plugin install to their first `/plan-product`
invocation in under 5 minutes.

## Architecture Classification

This is a **single-agent utility skill** — the simplest architecture in the conclave framework. Unlike `plan-product`,
`build-product`, and `review-quality`, which spawn multi-agent teams with skeptic gates, `/setup-project` runs as a
single agent executing a deterministic pipeline. There is no team orchestration, no skeptic review, and no checkpoint
protocol. The skill runs to completion in one pass.

Rationale: See ADR-003 for the full decision record on single-agent vs. multi-agent.

## Component Structure

```
/setup-project SKILL.md
        |
        v
  ┌─────────────────────────────────────┐
  │          Execution Pipeline          │
  │                                      │
  │  1. Detect existing state            │
  │  2. Detect tech stack                │
  │  3. Scaffold docs/ structure         │
  │  4. Generate CLAUDE.md               │
  │  5. Generate roadmap/_index.md       │
  │  6. Print summary & next steps       │
  └─────────────────────────────────────┘
        |
        v
  Output artifacts (files on disk)
```

There are no external service dependencies, no database, no network calls. The skill reads the filesystem and writes to
the filesystem.

## Step-by-Step Execution

### Step 1: Detect Existing State

Before any writes, inventory what already exists. This is the foundation of idempotency.

**Reads:**

- `CLAUDE.md` in project root — exists? has content?
- `docs/` directory — exists? which subdirectories exist?
- `docs/roadmap/_index.md` — exists?
- `docs/stack-hints/` — any existing hint files?
- `docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md` — exist?

**Output:** An internal state map:

```
{
  claude_md_exists: bool,
  docs_dir_exists: bool,
  subdirs_present: [list of existing subdirs],
  roadmap_index_exists: bool,
  stack_hints_present: [list of existing hint files],
  templates_present: [list of existing templates]
}
```

This state map drives conditional logic in all subsequent steps. Every write operation checks this map before
proceeding.

### Step 2: Detect Tech Stack

Scan the project root for dependency manifests to identify the primary tech stack.

**Detection table:**

| File                                                 | Stack Detected                                                                                                         |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `package.json`                                       | Node.js (further: check for `next`, `react`, `vue`, `angular`, `svelte`, `express`, `fastify`, `nest` in dependencies) |
| `composer.json`                                      | PHP (further: check for `laravel/framework`, `symfony/` in require)                                                    |
| `Gemfile`                                            | Ruby (further: check for `rails` gem)                                                                                  |
| `go.mod`                                             | Go                                                                                                                     |
| `requirements.txt` or `pyproject.toml` or `setup.py` | Python (further: check for `django`, `flask`, `fastapi`)                                                               |
| `Cargo.toml`                                         | Rust                                                                                                                   |
| `pom.xml` or `build.gradle`                          | Java/Kotlin                                                                                                            |
| `mix.exs`                                            | Elixir (further: check for Phoenix)                                                                                    |
| `pubspec.yaml`                                       | Dart/Flutter                                                                                                           |
| `Package.swift`                                      | Swift                                                                                                                  |

**Priority:** If multiple manifests exist, the skill should detect all of them and identify the primary stack (the one
with the most configuration/code). Report findings to the user and ask for confirmation if ambiguous. This confirmation
should be a brief inline question (e.g., "Detected both Node.js and Python. Which is primary?"), not a multi-turn
conversation — keep the pipeline deterministic.

**Framework-level detection:** Beyond just the language, detect the framework (e.g., "Laravel" not just "PHP", "Next.js"
not just "Node.js"). This matters because stack hints are framework-specific.

**Output:** A stack identifier (e.g., `laravel`, `nextjs`, `rails`, `django`) used to:

1. Look up matching `docs/stack-hints/{stack}.md` from the plugin's bundled hints
2. Tailor the generated `CLAUDE.md` content
3. Set categories in the roadmap index

### Step 3: Scaffold `docs/` Directory Structure

Create the standard directory structure used by all conclave skills.

**Directories to create (if missing):**

```
docs/
docs/roadmap/
docs/specs/
docs/progress/
docs/architecture/
docs/stack-hints/
```

**Files to create (if missing):**

- `.gitkeep` in each empty directory (to ensure git tracks them)
- `docs/specs/_template.md` — standard spec template
- `docs/progress/_template.md` — standard progress/checkpoint template
- `docs/architecture/_template.md` — standard ADR template

**Idempotency rule:** Only create directories and files that do not already exist. Never overwrite existing files. If a
directory already exists with content, skip it silently. Report what was created vs. what was skipped in the summary
output.

**Template content source:** Templates should be embedded directly in the SKILL.md as fenced code blocks. This keeps the
skill self-contained (consistent with the self-containment property established in ADR-002) and avoids dependencies on
plugin file layout. The templates are small (each under 50 lines), so the SKILL.md size impact is acceptable.

### Step 4: Generate `CLAUDE.md`

Write a project-specific `CLAUDE.md` to the project root. This is the most complex generation step because the content
must be tailored to the detected stack.

**Idempotency rule:** If `CLAUDE.md` already exists, DO NOT overwrite it. Instead:

1. Read the existing content
2. Inform the user that `CLAUDE.md` already exists
3. Suggest additions by outputting them to the console (as a bulleted list of recommended additions), not by writing a
   diff file
4. Ask the user if they want to append the suggested content

**Generated content structure:**

```markdown
# Project Conventions

## Tech Stack

- {Detected stack summary}

## Development Guidelines

- {Stack-specific conventions from stack hints, if available}
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
- Use `/review-quality` for security audits, performance analysis, and deployment readiness
```

**Stack-specific sections:** If a matching stack hint file exists (either bundled with the plugin or already in
`docs/stack-hints/`), incorporate its key guidelines into the CLAUDE.md. Do not duplicate the full hint file — extract
the most important conventions.

### Step 5: Generate `docs/roadmap/_index.md`

Create a starter roadmap index tailored to the project.

**Idempotency rule:** If `docs/roadmap/_index.md` already exists, skip this step entirely. The existing roadmap should
not be touched.

**Generated content:** Based on the roadmap index format established in ADR-001, generate an `_index.md` with:

1. The standard header explaining that individual item files are the source of truth
2. A categories table tailored to the project type (e.g., a SaaS project gets different categories than a CLI tool or
   library)
3. The standard prioritization framework
4. The status legend
5. An empty "Current Backlog" section ready for the user's first `/plan-product` run

**Category tailoring by project type:**

| Project Type    | Suggested Categories                                                                          |
| --------------- | --------------------------------------------------------------------------------------------- |
| Web app (SaaS)  | `core-features`, `user-experience`, `infrastructure`, `developer-experience`, `documentation` |
| API service     | `endpoints`, `data-model`, `authentication`, `performance`, `documentation`                   |
| CLI tool        | `commands`, `configuration`, `output-formatting`, `developer-experience`, `documentation`     |
| Library/package | `api-surface`, `internals`, `compatibility`, `developer-experience`, `documentation`          |
| Mobile app      | `screens`, `navigation`, `data-sync`, `platform-specific`, `documentation`                    |
| Default         | `core-features`, `quality-reliability`, `developer-experience`, `documentation`               |

The project type is inferred from the tech stack detection. If ambiguous, use the default categories and note this in
the output.

### Step 6: Print Summary and Next Steps

Output a clear summary of everything that was done and guide the user to their next action.

**Summary format:**

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

## Interface Definitions

### Skill Input

The skill accepts optional arguments via `$ARGUMENTS`:

| Argument    | Effect                                                                                          |
| ----------- | ----------------------------------------------------------------------------------------------- |
| (empty)     | Full setup with auto-detection                                                                  |
| `--force`   | Overwrite existing files (bypass idempotency checks). Still prompts for CLAUDE.md confirmation. |
| `--dry-run` | Show what would be created without writing any files                                            |

### Skill Output

The skill produces:

1. **Files on disk** — the scaffolded directory structure, CLAUDE.md, roadmap index, templates
2. **Console output** — the summary and next steps (Step 6)

### Output Artifacts

| Artifact              | Path                                                      | Created When                                                                                                      |
| --------------------- | --------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| CLAUDE.md             | `./CLAUDE.md`                                             | Does not exist (or `--force`)                                                                                     |
| Roadmap index         | `docs/roadmap/_index.md`                                  | Does not exist (or `--force`)                                                                                     |
| Spec template         | `docs/specs/_template.md`                                 | Does not exist                                                                                                    |
| Progress template     | `docs/progress/_template.md`                              | Does not exist                                                                                                    |
| Architecture template | `docs/architecture/_template.md`                          | Does not exist                                                                                                    |
| Directory structure   | `docs/{roadmap,specs,progress,architecture,stack-hints}/` | Directories do not exist                                                                                          |
| Gitkeep files         | `docs/{subdir}/.gitkeep`                                  | Directory is newly created AND empty (not added retroactively to existing directories that already contain files) |

## Integration Points

### With Existing Skills

`/setup-project` creates the exact directory structure and artifacts that `plan-product`, `build-product`, and
`review-quality` expect in their Setup phases. Specifically:

- **plan-product Setup (lines 17-27):** Expects `docs/roadmap/`, `docs/specs/`, `docs/progress/`, `docs/architecture/`,
  `docs/stack-hints/`, and template files. `/setup-project` creates all of these.
- **build-product Setup (lines 17-28):** Same directory expectations plus reads `docs/specs/_template.md` and
  `docs/progress/_template.md`. `/setup-project` creates these templates.
- **review-quality Setup (lines 16-27):** Same directory expectations. `/setup-project` creates them.

### With Plugin System

- The skill lives at `skills/setup-project/SKILL.md` in the plugin directory
- It is registered in `plugin.json` alongside the existing 3 skills
- It follows the same YAML frontmatter + markdown body format as existing skills

### With Stack Hints

- `/setup-project` reads stack hint files from the plugin's bundled hints (if any)
- It may also copy/suggest stack-specific hints into the project's `docs/stack-hints/` directory
- Other skills then pick up these hints during their Setup phases

## Idempotency Strategy

The skill uses **file-existence-based idempotency**. Before every write, it checks if the target already exists:

| Target                   | If Exists                                            | If Missing |
| ------------------------ | ---------------------------------------------------- | ---------- |
| Directory                | Skip silently                                        | Create     |
| `.gitkeep`               | Skip silently                                        | Create     |
| Template file            | Skip silently                                        | Create     |
| `CLAUDE.md`              | Inform user, suggest additions, ask before modifying | Create     |
| `docs/roadmap/_index.md` | Skip entirely                                        | Create     |

This approach is chosen over alternatives like a "setup complete" marker file because:

1. It requires no additional state tracking
2. It is self-healing — if a user deletes a single artifact, re-running the skill recreates just that artifact
3. It is transparent — the user can see exactly what exists and what will be created

See ADR-003 for the full decision record.

## Error Handling

| Error Scenario                      | Behavior                                                                                           |
| ----------------------------------- | -------------------------------------------------------------------------------------------------- |
| No dependency manifest found        | Inform user, proceed with "unknown" stack and default categories. Ask user to specify their stack. |
| Multiple manifests (ambiguous)      | Detect all, list them, ask user to confirm primary stack. Proceed with user's choice.              |
| Directory write fails (permissions) | Report error, suggest running with appropriate permissions. Do not continue with partial state.    |
| Existing CLAUDE.md is very large    | Read it, but do not attempt to merge. Only suggest additions as a separate block.                  |

## Non-Goals

These are explicitly out of scope for this skill:

1. **No team spawning.** This is a single-agent skill.
2. **No skeptic review.** Setup output is deterministic and low-risk.
3. **No checkpoint protocol.** The skill completes in one pass.
4. **No code generation.** The skill creates documentation and scaffolding, not application code.
5. **No dependency installation.** The skill does not run `npm install`, `composer install`, etc.
6. **No git operations.** The skill does not commit, push, or create branches.
7. **No modification of existing roadmap items.** It creates the index structure but does not add or modify roadmap item
   files.
