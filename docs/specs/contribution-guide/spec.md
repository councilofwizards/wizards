---
title: "Architecture & Contribution Guide Specification"
status: "approved"
priority: "P3"
category: "documentation"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Architecture & Contribution Guide Specification

## Summary

Create three documentation artifacts — an architecture overview, a contributing
guide, and a skill authoring template — that enable first-time contributors to
make correct, validator-passing contributions to the wizards plugin without
reading existing skill files or the full codebase. Optionally add a
template-format synchronization guard (~30 lines of shell) that warns when the
skill template drifts from validator expectations.

## Problem

The wizards plugin has 17 skills, 12+ validators, shared content sync
infrastructure, and a category taxonomy — but zero contributor documentation. A
developer wanting to add a new skill must reverse-engineer the format from
existing SKILL.md files, guess at frontmatter requirements, and discover the
shared content sync workflow through trial and error. This friction slows
contributions and increases the chance of invalid submissions.

## Solution

### 1. Architecture Overview (`docs/architecture/overview.md`)

A narrative document (400-700 words) explaining:

- **Plugin structure**: marketplace → plugin → skills directory layout, role of
  `plugin.json`
- **Skill format**: YAML frontmatter fields (name, description, argument-hint,
  category, tags, optional tier/type), required sections for multi-agent vs.
  single-agent skills
- **Skill categories**: The 4-category taxonomy (engineering, planning,
  business, utility) with a note that CLAUDE.md is the authoritative source
- **Agent team patterns**: How skills spawn Agent Teams via TeamCreate + Agent
  with team_name; the 4 patterns (Hub-and-Spoke, Pipeline, Collaborative
  Analysis, Single-Agent)
- **Shared content**: What lives in `plugins/conclave/shared/`, the marker
  system, sync script, and that single-agent skills are excluded
- **Quality gates**: What `bash scripts/validate.sh` does, the A-G validator
  series with one-line descriptions, and the rule that all validators must pass
  before committing
- **ADR index**: Links to ADR-001 through ADR-005 with one-line summaries (do
  not re-explain decisions)

The document complements CLAUDE.md (conventions reference) — it is a narrative
"how the system works" explanation, not a rules list. Direct readers to
CLAUDE.md for authoritative validation rules and project conventions.

### 2. Contributing Guide (`docs/contributing.md`)

Step-by-step instructions for four contribution paths:

**Path A: Add a new skill**

1. Copy the skill authoring template from `docs/templates/skills/SKILL.md`
2. Create a new directory: `plugins/conclave/skills/{skill-name}/SKILL.md`
3. Fill in frontmatter: name (must match directory), description, argument-hint,
   category (one of: engineering, business, planning, utility), tags
4. Classify as engineering or non-engineering (determines which shared content
   blocks are injected; default to engineering if uncertain)
5. Add the skill to the classification arrays in both
   `scripts/sync-shared-content.sh` and
   `scripts/validators/skill-shared-content.sh`
6. Run `bash scripts/sync-shared-content.sh` to inject shared content blocks
7. Run `bash scripts/validate.sh` to verify all checks pass
8. Add the skill to `plugins/conclave/.claude-plugin/plugin.json` skills array

**Path B: Add a stack hint**

1. Create `docs/stack-hints/{stack-name}.md` (plain markdown, no frontmatter
   required)
2. Document framework-specific conventions, patterns, and gotchas that agents
   should follow
3. Skills with stack detection (setup-project, plan-product, build-product,
   etc.) will automatically prepend the hint to agent prompts when the stack is
   detected

**Path C: Modify agent prompts**

1. Determine if the content is shared or skill-specific:
   - Content between `<!-- BEGIN SHARED -->` and `<!-- END SHARED -->` markers:
     edit ONLY in `plugins/conclave/shared/`, then run
     `bash scripts/sync-shared-content.sh`
   - All other content: edit directly in the skill's SKILL.md
2. Never edit shared content blocks directly in SKILL.md — the sync script will
   overwrite your changes
3. Run `bash scripts/validate.sh` after changes — B-series validators detect
   shared content drift

**Path D: Add a custom agent role** _(placeholder — depends on P3-01)_ This
contribution path is not yet available. See the P3-01 (Custom Agent Roles) spec
when implemented. This section will be fleshed out after P3-01 lands.

**Common notes** (apply to all paths):

- The G-series validator emits an advisory WARN when business skill count
  reaches 7 (see ADR-005). This is informational, not a blocker.
- Cross-link to `docs/architecture/overview.md` for architectural context behind
  these steps.

### 3. Skill Authoring Template (`docs/templates/skills/SKILL.md`)

A structurally valid multi-agent SKILL.md template containing:

**Frontmatter:**

```yaml
---
name: { skill-name }
description: >
  {One to three sentences describing what this skill does.}
argument-hint: "[--light] [status | <topic> | (empty for default)]"
# tier: 1              # Optional — include only if skill is part of the original tier system
# type: single-agent   # Optional — include only for single-agent skills (changes required sections)
category: { engineering | business | planning | utility }
tags: [{ tag1 }, { tag2 }]
---
```

**Required sections** (all must be present for A2 validation):

- `## Setup` — with placeholder steps
- `## Write Safety` — with standard file-scoping conventions
- `## Checkpoint Protocol` — with standard checkpoint format
- `## Determine Mode` — with placeholder mode logic
- `## Lightweight Mode` — with standard model reduction pattern
- `## Spawn the Team` — with one placeholder spawn entry containing `**Name**`
  and `**Model**` fields (satisfies A3)
- `## Orchestration Flow` — with placeholder stage structure
- `## Quality Gate` or `## Critical Rules` — at least one required (satisfies A2
  "at least one of" check)
- `## Failure Recovery` — with standard recovery patterns
- `## Teammate Spawn Prompts` or `## Teammates to Spawn` — at least one required
  (satisfies A2 "at least one of" check)

**Shared content markers** (empty blocks — populated by sync script):

```
<!-- BEGIN SHARED: universal-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
## Shared Principles
<!-- END SHARED: universal-principles -->

<!-- BEGIN SHARED: engineering-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
## Engineering Principles
<!-- END SHARED: engineering-principles -->

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plugins/conclave/shared/communication-protocol.md. Keep in sync across all skills. -->
## Communication Protocol
<!-- END SHARED: communication-protocol -->
```

**SCAFFOLD comment example:**

```
<!-- SCAFFOLD: [description of what this scaffolding does] | ASSUMPTION: [model-capability assumption] | TEST REMOVAL: [condition for testing removal] -->
```

**Post-creation instructions** (as a comment at the top of the template):

```
<!-- After copying this template:
  1. Rename the directory to your skill name: plugins/conclave/skills/{your-skill}/SKILL.md
  2. Fill in all {placeholder} values in the frontmatter
  3. Add your skill to the classification arrays in sync-shared-content.sh and skill-shared-content.sh
  4. Run: bash scripts/sync-shared-content.sh (populates shared content blocks)
  5. Run: bash scripts/validate.sh (all checks should pass)
  6. Add your skill to plugins/conclave/.claude-plugin/plugin.json
-->
```

### 4. Template-Format Synchronization Guard _(could-have)_

Add an advisory check (~30 lines) to an existing validator (or as a new F-series
extension) that:

1. Reads the template at `docs/templates/skills/SKILL.md`
2. Checks that it contains the same required section headings that A2 enforces
   for multi-agent skills
3. Emits `[WARN]` (not `[FAIL]`) for any missing section, naming the section
4. Always exits 0 — advisory only, never blocks CI

The check uses the same section heading patterns as A2 to avoid regex
divergence. SCAFFOLD comments in the template must not trigger false positives —
the check should match `^## ` at line start, same as A2.

## Constraints

1. All deliverables are markdown files except the optional Story 4 validator
   addition (~30 lines shell)
2. `bash scripts/validate.sh` must pass after all changes (no new failures)
3. The architecture overview must not contradict CLAUDE.md — CLAUDE.md is
   authoritative for conventions and validation rules
4. The skill authoring template must be structurally valid: placing it in
   `plugins/conclave/skills/{name}/SKILL.md` and running validators must produce
   zero A-series failures
5. The contributing guide's "custom agent roles" path is a placeholder stub
   until P3-01 is implemented

## Out of Scope

- Implementing custom agent roles (P3-01)
- Activating the persona system for contributors
- Automated testing infrastructure for the template (P2-04)
- Updating existing skill files to conform to any new documentation conventions
- Public-facing README changes
- Generating or publishing documentation beyond the `docs/` directory

## Files to Modify

| File                             | Change                                                       |
| -------------------------------- | ------------------------------------------------------------ |
| `docs/architecture/overview.md`  | New — architecture overview document                         |
| `docs/contributing.md`           | New — contributing guide with 4 contribution paths           |
| `docs/templates/skills/SKILL.md` | New — skill authoring template                               |
| Existing validator (optional)    | ~30 lines — template-format sync guard (Story 4, could-have) |

## Success Criteria

1. A contributor can copy `docs/templates/skills/SKILL.md`, fill in
   placeholders, run the sync script, and pass all A-series and B-series
   validators without additional guidance
2. `docs/architecture/overview.md` exists and covers: plugin structure, skill
   format, categories, agent teams, shared content, quality gates, and ADR index
3. `docs/contributing.md` exists with step-by-step instructions for all four
   contribution paths
4. The architecture overview's category table matches CLAUDE.md's authoritative
   taxonomy
5. `bash scripts/validate.sh` produces no new failures after all changes
6. The skill template includes all required frontmatter fields, all required
   sections for multi-agent skills, shared content markers, and a SCAFFOLD
   comment example
