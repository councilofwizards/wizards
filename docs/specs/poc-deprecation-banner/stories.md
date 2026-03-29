---
type: "user-stories"
feature: "poc-deprecation-banner"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-25-poc-deprecation-banner.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-25 PoC Deprecation Banner

## Epic Summary

`tier1-test` is a Phase 0 PoC skill that appears in skill discovery alongside production skills with no warning that
it's internal test scaffolding. This epic adds a `status: internal` frontmatter field and a visible banner. Note:
`tier2-test` was removed; only `tier1-test` is in scope.

## Stories

### Story 1: Add Internal Status Field and Deprecation Banner to tier1-test

- **As a** user browsing available skills or reading `tier1-test/SKILL.md`
- **I want** a clear banner indicating this skill is internal test scaffolding
- **So that** I do not invoke it expecting production behavior
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I read `plugins/conclave/skills/tier1-test/SKILL.md`, then frontmatter contains `status: internal`.
  2. Given I read the body, then a banner appears before any other content: "INTERNAL SKILL: This is internal test
     scaffolding used for PoC validation. It is not intended for end-user invocation and produces no meaningful output."
  3. Given `status: internal` is added, when I run `bash scripts/validate.sh`, then A1 passes — `status` is not a
     required field and A1 does not validate optional field values.
  4. Given only `tier1-test` is modified, then no changes reference `tier2-test` (removed).
  5. Given I run `bash scripts/validate.sh`, then all validators pass.
- **Edge Cases**:
  - A1 validator: does not enumerate allowed values for optional fields. Adding `status: internal` is additive. If a
    future validator checks status values, `internal` should be allowed.
  - Description field: existing description remains accurate; banner supplements, not replaces.
  - Skill discovery: `status: internal` has no filtering effect today; it's a documentation signal.
- **Notes**: Two-line edit: one frontmatter field, one banner paragraph. No sync needed (single-agent skill excluded
  from B-series).

## Non-Functional Requirements

- Single file edit only.
- All validators pass after edit.

## Out of Scope

- Removing tier1-test from the codebase.
- Adding discovery filtering logic for `status: internal`.
- Modifying any validator to enforce status field values.
- Any changes to tier2-test (removed).
