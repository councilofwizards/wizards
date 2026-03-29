---
title: "Custom Agent Roles Specification"
status: "approved"
priority: "P3"
category: "new-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Custom Agent Roles Specification

## Summary

Enable project owners to define custom agent roles in `docs/agents/` that skills
discover at startup and compose into teams alongside built-in roles. Starter
templates at `docs/templates/agents/` provide copy-and-adapt starting points.
The Skeptic role remains mandatory and non-customizable — custom roles
supplement, never replace, the quality gate.

## Problem

All multi-agent skills currently hardcode their team composition in SKILL.md
files. Projects with specialized domain needs (data engineering, ML, mobile)
cannot add expertise to agent teams without editing plugin-owned skill files.
This creates a fork-or-live-without-it situation — project owners either modify
SKILL.md files (breaking sync/validation) or accept generic teams that lack
their domain context. The persona system at `plugins/conclave/shared/personas/`
proves the role-definition pattern works, but it's plugin-internal and not
extensible by users.

## Solution

### 1. Role Definition Schema

Custom role files live at `docs/agents/{role-id}.md` with this structure:

```markdown
---
id: "data-engineer"
name: "Data Engineer"
model: "sonnet"
archetype: "domain-expert" # domain-expert | reviewer | coordinator
description: "Pipeline and data infrastructure specialist"
---

## Role

{Agent's responsibilities and domain expertise}

## Critical Rules

- {Non-negotiable behavior 1}
- {Non-negotiable behavior 2}
- Follow all Shared Principles and the Communication Protocol. Checkpoint
  progress in your role-scoped progress file. Send updates to the lead on task
  start, completion, and blockers.

## Tasks

- {Default task type 1}
- {Default task type 2}
```

**Required frontmatter fields**: `id` (lowercase-kebab slug), `name` (display
name), `model` (`sonnet` | `opus`), `archetype` (`domain-expert` | `reviewer` |
`coordinator`), `description` (one-line summary).

**Archetype semantics**:

- `domain-expert`: Execution agent — spawned alongside built-in agents for
  domain-specific work
- `reviewer`: Additional reviewer — performs preliminary review before the
  built-in Skeptic gate; does NOT replace the Skeptic
- `coordinator`: Sub-coordinator — reports to the lead, coordinates a subset of
  work

**Reviewer archetype contract**: Role files with `archetype: reviewer` MUST
include at least one Critical Rule about explicitly approving or rejecting
submitted work.

### 2. Role Discovery at Skill Startup

A new setup step is added **within the existing `## Setup` section** of all
multi-agent SKILL.md files (not a new top-level section — A2 validator
compatibility preserved):

```
N. **Discover custom roles (optional).** If `docs/agents/` exists and is a directory, read all `*.md` files,
   parse their YAML frontmatter, and build an in-session role registry. Apply the defensive reading contract:
   - Directory absent → proceed silently, empty registry
   - Directory exists but empty → proceed silently, empty registry
   - Directory is a file (not a directory) → log warning: "docs/agents/ is not a directory; custom role loading skipped"
   - File with missing required frontmatter → log warning naming the file and missing fields, skip that role
   - File with invalid `model` value → log warning specifying the invalid value, skip that role
   - Empty file → log warning: "docs/agents/{filename} is empty; skipped"
```

Discovery is read-only and deterministic. The registry is an in-memory construct
for the session. Single-agent skills (setup-project, wizard-guide) skip this
step entirely.

### 3. Team Composition with Custom Roles

In the `## Spawn the Team` section, after Step 2 (TaskCreate), the lead consults
the role registry:

**Step 2.5: Compose custom roles**

- Custom roles with `archetype: domain-expert` are eligible as additional
  execution agents
- Custom roles with `archetype: reviewer` are eligible as additional pre-Skeptic
  reviewers
- Custom roles with `archetype: coordinator` are eligible as sub-coordinators
  for specific stages
- The lead assigns tasks to custom roles based on their `## Tasks` section and
  the current work scope

**Spawn prompt assembly for custom roles**:

1. Stack hints guidance block (if loaded in Setup)
2. User project guidance block (if loaded in Setup)
3. The role's `## Role` section as primary task description
4. The team's Shared Principles block (verbatim from SKILL.md)
5. The team's Communication Protocol block (verbatim from SKILL.md)
6. Write Safety rules for the current skill (role-scoped:
   `docs/progress/{feature}-{role-id}.md`)

Custom role spawn entries use the Agent tool with `team_name` and include `Name`
(from `id`) and `Model` (from `model`) to satisfy the A3 validator.

### 4. Skeptic Non-Customizability Guard

The Skeptic invariant is enforced during team composition:

- **Id collision**: If a custom role declares an `id` matching a built-in
  Skeptic id (e.g., `ops-skeptic`, `plan-skeptic`), the custom role's id is
  prefixed with `custom-` (e.g., `custom-ops-skeptic`). A warning is logged. The
  built-in Skeptic spawns unchanged.
- **Skeptic-suffixed ids**: Custom roles with `id` ending in `-skeptic` are
  treated as additional reviewers, not replacements. A notice is logged: "Custom
  role `{id}` has Skeptic archetype. It will be spawned as an additional
  reviewer. The built-in Skeptic is not replaced."
- **Prompt isolation**: The built-in Skeptic's spawn prompt is never modified by
  custom role loading.
- **Gate preservation**: The Orchestration Flow's Skeptic gate step is always
  present and executed, regardless of custom roles.
- **Communication routing**: The Communication Protocol's Skeptic routing row is
  included verbatim in all custom role prompts — custom roles route to the
  built-in Skeptic.

### 5. Starter Role Templates

Three templates at `docs/templates/agents/`:

| Template             | Id                | Model    | Archetype       |
| -------------------- | ----------------- | -------- | --------------- |
| `data-engineer.md`   | `data-engineer`   | `sonnet` | `domain-expert` |
| `ml-engineer.md`     | `ml-engineer`     | `sonnet` | `domain-expert` |
| `mobile-engineer.md` | `mobile-engineer` | `sonnet` | `domain-expert` |

Each template has:

- Valid YAML frontmatter matching the Story 1 schema
- Filled `## Role` section with domain-specific responsibilities
- At least 3 `## Critical Rules` entries (including the shared-principles
  compliance rule)
- At least 3 `## Tasks` entries

Templates are documentation-class files in the plugin repo. They are NOT
artifact templates and must NOT be checked by the F-series validator.

### 6. SKILL.md Modifications

All 14 multi-agent SKILL.md files receive the discovery setup step. The
modification is within the existing `## Setup` section (no new top-level
sections). Changes are identical across skills except for the step number.

**Affected skills**: research-market, ideate-product, manage-roadmap,
write-stories, write-spec, plan-implementation, build-implementation,
review-quality, run-task, draft-investor-update, plan-sales, plan-hiring,
plan-product, build-product.

### 7. F-Series Validator Exclusion

The F-series validator (`scripts/validators/artifact-templates.sh`) currently
checks `docs/templates/artifacts/`. It must not accidentally pick up
`docs/templates/agents/` files. Confirm the validator's glob pattern is scoped
to `docs/templates/artifacts/` only. If it uses a broader glob, add an
exclusion.

## Constraints

1. The Skeptic role is non-negotiable — no custom role configuration may weaken,
   remove, or bypass it
2. Custom role loading is opt-in via file presence — projects with no
   `docs/agents/` experience zero behavior change
3. Discovery is added within the existing `## Setup` section, not as a new
   top-level section (A2 validator compatibility)
4. Custom role spawn entries must include `Name` and `Model` fields (A3
   validator)
5. All 12/12 validators must pass after all changes
6. Shared content markers are untouched — sync script compatibility preserved
7. Single-agent skills skip role discovery entirely
8. Custom role file content is user-authored — spawn prompt framing must clearly
   label it to prevent prompt confusion

## Out of Scope

- Dynamic role hot-loading mid-session (roles are loaded once at setup)
- Role inheritance or composition (custom roles are standalone definitions)
- Role access control (all roles in `docs/agents/` are available to all skills)
- UI or interactive tooling for role authoring
- Automatic sync of custom roles to `plugins/conclave/shared/personas/`
- Changes to built-in Skeptic persona files
- New validators (no G-series persona validators — separate P3-08 item)
- `run-task` dynamic archetype integration (separate roadmap item)

## Files to Modify

| File                                                     | Change                                             |
| -------------------------------------------------------- | -------------------------------------------------- |
| `docs/templates/agents/data-engineer.md`                 | Create — starter template for Data Engineer role   |
| `docs/templates/agents/ml-engineer.md`                   | Create — starter template for ML Engineer role     |
| `docs/templates/agents/mobile-engineer.md`               | Create — starter template for Mobile Engineer role |
| `plugins/conclave/skills/research-market/SKILL.md`       | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/ideate-product/SKILL.md`        | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/manage-roadmap/SKILL.md`        | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/write-stories/SKILL.md`         | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/write-spec/SKILL.md`            | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/plan-implementation/SKILL.md`   | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/build-implementation/SKILL.md`  | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/review-quality/SKILL.md`        | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/run-task/SKILL.md`              | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/plan-sales/SKILL.md`            | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/plan-hiring/SKILL.md`           | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/plan-product/SKILL.md`          | Add role discovery setup step within `## Setup`    |
| `plugins/conclave/skills/build-product/SKILL.md`         | Add role discovery setup step within `## Setup`    |

## Success Criteria

1. `docs/templates/agents/data-engineer.md`, `ml-engineer.md`, and
   `mobile-engineer.md` exist with valid frontmatter matching the role schema
2. Copying a template to `docs/agents/` without modification loads it
   successfully during any skill's setup
3. All 14 multi-agent SKILL.md files contain the role discovery setup step
   within their `## Setup` section
4. A custom role with `archetype: domain-expert` is spawned as an additional
   agent with the correct prompt assembly (role section + principles +
   protocol + write safety)
5. A custom role with `id` ending in `-skeptic` triggers a notice log and spawns
   as an additional reviewer without replacing the built-in Skeptic
6. A custom role with an `id` matching a built-in Skeptic id is prefixed with
   `custom-` and the built-in Skeptic spawns unchanged
7. Projects with no `docs/agents/` directory experience zero behavior change
   across all skills
8. The F-series validator does not flag `docs/templates/agents/` files as
   artifact templates
9. `bash scripts/validate.sh` reports 12/12 PASS after all changes
