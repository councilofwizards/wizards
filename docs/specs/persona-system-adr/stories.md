---
type: "user-stories"
feature: "persona-system-adr"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-23-persona-system-adr.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-23 Persona System ADR (ADR-006)

## Epic Summary

The persona system is the largest undocumented architectural decision in the
project: 45+ persona files with fictional identities, a dual communication style
convention, a fantasy-world theme, a specific file format, and a G2 validator
enforcing referential integrity — none of it recorded in an ADR. ADR-006 closes
that gap.

## Stories

### Story 1: Write ADR-006 Documenting the Persona System Architecture

- **As a** contributor encountering persona files for the first time
- **I want** an ADR explaining why 45+ persona files exist, their required
  format, and the architectural decisions behind the fantasy theme and dual
  communication style
- **So that** I can understand the rationale and make consistent decisions when
  adding new personas
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I read `docs/architecture/ADR-006-persona-system.md`, then I can
     answer: why persona files exist (vs. embedding identity in prompts), what
     fields are required, and why agents use different communication styles with
     users vs. teammates.
  2. Given the ADR covers the fantasy-world theme, then it explains the
     rationale (immersive framing, identity consistency, reduced "assistant
     mode" drift) and the decision to use fantasy personas over generic role
     names.
  3. Given the ADR covers dual communication style, then it names both modes and
     explains why the distinction exists.
  4. Given the ADR covers cross-references, then it explains: spawn prompt read
     instructions, fictional name matching, and G2 validator enforcement.
  5. Given the ADR follows the standard format, then its frontmatter contains:
     title, status: accepted, created, updated, superseded_by.
  6. Given I run `bash scripts/validate.sh`, then all validators pass.
- **Edge Cases**:
  - run-task exception: ADR must acknowledge run-task's generic archetypes as a
    known gap (P3-24).
  - Single-agent exclusion: ADR must note single-agent skills are excluded from
    persona requirements.
  - Scope: documents the decision, does not list all 45+ persona files.
- **Notes**: ~400-600 words. Path:
  `docs/architecture/ADR-006-persona-system.md`. Status: accepted (system
  already in production).

## Non-Functional Requirements

- Single markdown file. No code or validator changes.
- Follows ADR template (Status/Context/Decision/Alternatives/Consequences).

## Out of Scope

- Creating or modifying persona files.
- Documenting individual persona name choices.
- Covering G2 validator implementation details.
