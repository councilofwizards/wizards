---
type: "user-stories"
feature: "persona-reference-validator"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-08-persona-reference-validator.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-08 Persona Reference Validator

## Epic Summary

P2-09 injected fictional persona names into every spawn prompt across 14 multi-agent skills, but nothing guards against
regression. A future edit could silently remove a read instruction, reference a non-existent persona file, or drop a
fictional name — and `validate.sh` would keep reporting green. This epic adds a G2 validator
(`scripts/validators/skill-persona-refs.sh`) that enforces three invariants on every spawn prompt: the persona read
instruction is present, the referenced file exists, and the fictional name in the prompt matches the persona file's
`fictional_name` frontmatter field.

## Stories

### Story 1: Spawn Prompt Persona Read Instruction and File Existence Check

- **As a** plugin maintainer who edits SKILL.md files
- **I want** the validator to confirm every spawn prompt contains a persona file read instruction pointing to a file
  that exists on disk
- **So that** a missing or mistyped persona path is caught before it reaches main and silently degrades agent behavior
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given a multi-agent SKILL.md whose spawn prompt contains `read plugins/conclave/shared/personas/story-writer.md`,
     when I run `bash scripts/validate.sh`, then the validator reports a pass for that agent.
  2. Given a spawn prompt with no `plugins/conclave/shared/personas/` read instruction, when I run
     `bash scripts/validate.sh`, then the validator emits a FAIL naming the skill and agent, and `validate.sh` exits
     non-zero.
  3. Given a spawn prompt with a read instruction pointing to a non-existent persona file, when I run
     `bash scripts/validate.sh`, then the validator emits a FAIL naming the missing file path, and exits non-zero.
  4. Given all 14 multi-agent skills pass, when I run `bash scripts/validate.sh`, then the G2 section reports counts
     matching the number of spawn prompts checked.
  5. Given a skill with `type: single-agent` in frontmatter, when the validator runs, then it skips that skill entirely.
- **Edge Cases**:
  - Multiple spawn prompts per skill: pipeline skills define agents across multiple stages. The validator must walk all
    spawn prompt blocks, not just the first.
  - Lead self-read: the Team Lead reads its own persona file in `## Setup`, not in a spawn prompt block. The validator
    checks spawn prompts only.
  - Read instruction wording variation: match the path string `plugins/conclave/shared/personas/`, not the surrounding
    prose.
- **Notes**: Spawn prompts live inside fenced code blocks within the `## Teammate Spawn Prompts` section.

### Story 2: Fictional Name Cross-Reference Validation

- **As a** plugin maintainer who renames a persona or changes a `fictional_name` field
- **I want** the validator to verify the fictional name in each spawn prompt matches the `fictional_name` field in the
  referenced persona file
- **So that** a stale name in a spawn prompt is caught rather than silently presenting the wrong identity
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given a spawn prompt referencing a persona file and containing the matching `fictional_name` string, when I run
     `bash scripts/validate.sh`, then the validator reports a pass.
  2. Given a spawn prompt containing a name that does not match the referenced persona file's `fictional_name`, when I
     run `bash scripts/validate.sh`, then the validator emits a FAIL showing expected vs. found, and exits non-zero.
  3. Given a persona file with no `fictional_name` field, when the validator runs, then it emits a WARN (not FAIL) and
     skips the name check for that entry.
  4. Given a persona file that does not exist (already caught by Story 1), when the validator reaches the name check,
     then it skips the name check (no double failure).
  5. Given a `fictional_name` containing special characters, when the validator searches for it, then it performs a
     literal string match (not regex).
- **Edge Cases**:
  - Name substring collision: match the full `fictional_name` string, not substrings.
  - Multi-word names: all current names are two words — match the full string.
- **Notes**: Parse `fictional_name` from YAML frontmatter via simple grep/sed — no full YAML parser needed.

### Story 3: validate.sh Integration and Actionable Error Reporting

- **As a** contributor running `bash scripts/validate.sh` before a commit
- **I want** the persona reference validator to run as part of the standard suite with clear error messages
- **So that** I know exactly which SKILL.md and which spawn prompt to fix when a check fails
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given all 14 multi-agent skills pass G2 checks, when `validate.sh` finishes, then it prints a summary pass line and
     exits 0.
  2. Given one or more failures, when `validate.sh` runs, then it exits non-zero.
  3. Given a G2 failure message, when I read it, then it contains: the validator tag (G2/persona-refs), the skill name,
     the agent role name, and the specific failure type.
  4. Given a clean repo with no edits, when G2 runs, then it reports all passes with zero failures.
  5. Given `skill-persona-refs.sh` is called with a `REPO_ROOT` argument, when it runs in isolation, then it produces
     the same output as when called via `validate.sh`.
- **Edge Cases**:
  - Multiple failures: all failures printed before exit — no early exit on first failure.
  - REPO_ROOT portability: no hardcoded absolute paths.
  - New skills without spawn prompts: skip or WARN, don't crash.
  - validate.sh ordering: G2 runs after existing validators.

## Non-Functional Requirements

- Portable bash (`#!/usr/bin/env bash`, `set -euo pipefail`)
- Read-only — must not modify any files
- Runtime under 5 seconds for the full 14-skill suite
- Error messages use paths relative to REPO_ROOT
- `bash scripts/validate.sh` exits 0 on a clean repo after integration

## Out of Scope

- Validating the Team Lead's own persona read instruction in `## Setup`
- Enforcing that persona file `id` frontmatter matches the filename
- Linting persona file content beyond extracting `fictional_name`
- Auto-fixing missing persona refs or name mismatches
- Updating any SKILL.md files — P2-09 is complete, all 14 skills already pass
