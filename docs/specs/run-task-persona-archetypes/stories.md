---
type: "user-stories"
feature: "run-task-persona-archetypes"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-24-run-task-persona-archetypes.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-24 run-task Persona Archetypes

## Epic Summary

`run-task` is the only multi-agent skill where the persona system is incomplete. Its 3 existing spawn templates
(Engineer, Researcher, Skeptic) use a deferred assignment placeholder, and a 4th archetype (Writer) is missing entirely.
This epic creates 4 new persona files, adds a Writer Template to run-task, audits existing fictional names to avoid
collisions, and updates all spawn templates to reference specific file paths — bringing run-task into full G2
compliance.

## Stories

### Story 1: Name Conflict Audit and Persona File Creation for 4 Archetypes

- **As a** contributor adding persona files for run-task archetypes
- **I want** to audit existing fictional names before assigning new ones, then create 4 persona files with distinct
  identities
- **So that** no two personas share a name and each archetype has a grounded identity consistent with the fantasy-world
  theme
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given all 45+ existing persona files, when the name audit runs, then all existing `fictional_name` values are
     compiled and the 4 new names must not appear in this list.
  2. Given the audit is complete, when the 4 files are created, then each contains required frontmatter fields: `name`,
     `id`, `model` (sonnet for Engineer/Researcher/Writer, opus for Skeptic), `archetype`, `fictional_name`, `title`,
     and body sections (Identity, Communication Style, Role, Critical Rules).
  3. Given the 4 files are created, when grepping for the new names across all persona files, then no collisions are
     found.
  4. Given the Skeptic persona is created, then its Communication Style follows the skeptic convention: direct
     challenges in agent-to-agent, adversarial-but-fair in user-facing.
- **Edge Cases**:
  - Generic archetypes: personas must be flexible enough for any task domain — not specialized like `backend-eng.md`.
  - Writer vs. existing writer-adjacent personas: verify no collision with `drafter.md`, `story-writer.md`, etc.
- **Notes**: File IDs: `run-task-engineer.md`, `run-task-researcher.md`, `run-task-writer.md`, `run-task-skeptic.md` in
  `plugins/conclave/shared/personas/`. Skill field: `run-task`, team: `Ad-Hoc Task Team`.

### Story 2: run-task SKILL.md Updates — Add Writer Template + G2 Compliance

- **As a** plugin maintainer running validators
- **I want** run-task's spawn templates to reference specific persona file paths and include a Writer archetype
- **So that** run-task achieves full G2 compliance with all 4 archetypes covered
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given the 4 persona files exist, when I read each spawn template in run-task SKILL.md, then the deferred assignment
     placeholder is replaced with the specific path:
     `First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.`
  2. Given each template references a persona file, then it follows the canonical pattern:
     `You are {fictional_name}, {title} — the {archetype} on the Ad-Hoc Task Team.`
  3. Given run-task currently has 3 templates (Engineer, Researcher, Skeptic), when P3-24 is complete, then a 4th Writer
     Template spawn prompt is added following the same structure as the other 3, referencing `run-task-writer.md`.
  4. Given all edits are complete, when I run `bash scripts/validate.sh`, then G2 passes for run-task — all 4 spawn
     prompts have valid persona references.
  5. Given I run `bash scripts/validate.sh`, then all validators pass.
- **Edge Cases**:
  - Persona reference placement: must be a fixed preamble before the customizable task-specific section.
  - B-series sync: persona references are inside fenced code blocks (spawn prompts), not shared content — no sync
    needed.
- **Notes**: Stories 1 and 2 should be implemented together in the same PR.

## Non-Functional Requirements

- 4 new persona files + edits to run-task SKILL.md.
- All validators including G2 must pass after implementation.
- New persona files follow existing persona file structure.
- Name conflict audit is a hard gate, not advisory.

## Out of Scope

- Creating personas for skills other than run-task.
- Modifying existing persona files.
- Changing archetype model assignments.
