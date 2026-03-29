---
title: "run-task Persona Archetypes Specification"
status: "approved"
priority: "P3"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# run-task Persona Archetypes Specification

## Summary

Create 4 new persona files for run-task's generic archetypes (Engineer, Researcher, Writer, Skeptic), add a Writer
Template to run-task SKILL.md, and update all spawn templates to reference specific persona file paths. This brings
run-task into full G2 compliance and closes the last persona system gap.

## Problem

run-task is the only multi-agent skill where the persona system breaks down. Its 3 existing spawn templates (Engineer,
Researcher, Skeptic) use a deferred assignment placeholder ("read the persona file assigned by the Team Lead") with no
actual persona files to assign. A 4th archetype (Writer) is missing entirely. The G2 validator recognizes the deferred
pattern as valid (per P3-08 spec), but this means run-task agents have no grounded identity — they're the only Conclave
agents without fictional names, titles, or defined communication styles.

## Solution

### Step 1: Name Conflict Audit

Before creating any persona files:

1. Compile all `fictional_name` values from the 45+ existing persona files in `plugins/conclave/shared/personas/`
2. Choose 4 new names that do not appear in this list
3. Verify no collision with names in `drafter.md`, `story-writer.md`, or other writing-adjacent personas for the Writer
   archetype

### Step 2: Create 4 Persona Files

Create in `plugins/conclave/shared/personas/`:

| File                     | Archetype  | Model  | Notes                                               |
| ------------------------ | ---------- | ------ | --------------------------------------------------- |
| `run-task-engineer.md`   | Engineer   | sonnet | Generic — flexible across any implementation domain |
| `run-task-researcher.md` | Researcher | sonnet | Generic — flexible across any research domain       |
| `run-task-writer.md`     | Writer     | sonnet | Generic — flexible across any writing domain        |
| `run-task-skeptic.md`    | Skeptic    | opus   | Follows skeptic communication convention            |

Each file contains:

- **Frontmatter**: `name`, `id`, `model`, `archetype`, `fictional_name` (unique), `title` (fantasy-world),
  `skill: run-task`, `team: Ad-Hoc Task Team`
- **Body sections**: Identity, Communication Style, Role, Critical Rules, Responsibilities

The archetypes must be broadly applicable — run-task handles any ad-hoc task, so personas should evoke their archetype
broadly (e.g., "a Maker" not "a Backend Engineer").

### Step 3: Add Writer Template to run-task SKILL.md

run-task currently has 3 spawn templates. Add a 4th Writer Template following the same structure:

- H3 heading: `### Writer Template`
- Fenced code block containing the persona read instruction and role prompt
- Same customizable task-specific section pattern as the other templates

### Step 4: Update All 4 Spawn Templates for G2 Compliance

Replace the deferred assignment placeholder in each template:

**Before**:
`First, read the persona file assigned by the Team Lead for your complete role definition and cross-references.`

**After**:
`First, read plugins/conclave/shared/personas/run-task-{archetype}.md for your complete role definition and cross-references.`

Add the canonical identity line: `You are {fictional_name}, {title} — the {Archetype} on the Ad-Hoc Task Team.`

### Step 5: Update Team Lead Orchestration

Update the Team Lead's orchestration section to reference the 4 archetype personas by name when spawning agents, rather
than the current generic assignment pattern.

## Constraints

1. New fictional names must not collide with any existing persona `fictional_name`
2. Persona files follow the same structure as all existing persona files
3. Writer archetype must be as generically applicable as Engineer and Researcher
4. All validators including G2 must pass after implementation
5. Persona references are inside fenced code blocks — B-series sync is not affected

## Out of Scope

- Creating personas for skills other than run-task
- Modifying existing persona files
- Changing archetype model assignments (Engineer/Researcher/Writer: sonnet, Skeptic: opus)
- Modifying run-task's dynamic team composition logic beyond adding the Writer template

## Files to Modify

| File                                                      | Change                                                          |
| --------------------------------------------------------- | --------------------------------------------------------------- |
| `plugins/conclave/shared/personas/run-task-engineer.md`   | New — Engineer archetype persona                                |
| `plugins/conclave/shared/personas/run-task-researcher.md` | New — Researcher archetype persona                              |
| `plugins/conclave/shared/personas/run-task-writer.md`     | New — Writer archetype persona                                  |
| `plugins/conclave/shared/personas/run-task-skeptic.md`    | New — Skeptic archetype persona                                 |
| `plugins/conclave/skills/run-task/SKILL.md`               | Add Writer Template + update all 4 templates with persona paths |

## Success Criteria

1. 4 new persona files exist with unique fictional names (no collisions)
2. All 4 files have required frontmatter fields and body sections
3. run-task SKILL.md has 4 spawn templates (Engineer, Researcher, Writer, Skeptic) all referencing specific persona
   files
4. G2 validator passes for run-task (all spawn prompts have valid persona references with matching fictional names)
5. All validators pass after implementation
6. Name conflict audit documented (list of checked names) in progress file or commit message
