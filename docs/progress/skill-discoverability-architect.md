---
feature: "P2-10 Skill Discoverability Improvements"
status: "complete"
completed: "2026-03-27"
---

# P2-10: Skill Discoverability Improvements — Architect Progress

## Summary

Designed the full specification for P2-10. This is a content-only change:
Markdown edits to two SKILL.md files (`wizard-guide` and `setup-project`). No
validator logic changes, no shared-content sync required (both files are
`type: single-agent` and excluded from B-series checks).

## Spec Written

Output: `docs/specs/skill-discoverability/spec.md`

## Key Decisions

### Persona Spotlight: 5 Chosen Personas

Selected for cross-skill structural stability (archetypes that persist
regardless of skill-specific name variations):

| Persona          | Title                  | Archetype         | Skill(s)             |
| ---------------- | ---------------------- | ----------------- | -------------------- |
| Eldara Voss      | Archmage of Divination | Research Lead     | research-market      |
| Seren Mapwright  | Siege Engineer         | Planner/Architect | plan-implementation  |
| Vance Hammerfall | Forge Master           | Build Lead        | build-implementation |
| Mira Flintridge  | Master Inspector       | Quality Skeptic   | build-implementation |
| Bram Copperfield | Foundry Smith          | Builder           | build-implementation |

Rationale: Covers all three pipeline phases (research → plan → build). Mira
Flintridge as the Skeptic archetype is critical — the Skeptic role is the
non-negotiable quality gate in every multi-agent skill, so a new user should see
it prominently. Vance + Bram + Mira together show how the forge metaphor makes
the build pipeline feel cohesive rather than arbitrary.

### Tier Label Fix

The current wizard-guide still uses "Tier 1" / "Tier 2" language. ADR-004
removed the two-tier architecture. The spec includes a fix: remove tier labels
from the overview, rename to "Granular Skills", "Pipeline Skills", "Business
Skills", and "Utility Skills". This cleanup is bundled into the same edit pass
(Story 1 AC#4).

### Story 5 (Pushy Descriptions): Deferred

Story 5 requires modifying SKILL.md frontmatter for individual skills
(draft-investor-update, plan-sales, plan-hiring). These files are explicitly out
of scope per the feature's non-functional requirements. Story 5 is noted in the
spec as out of scope and should be tracked as a standalone P3 item if
prioritized.

### Lore Preamble: 107 words

Written to be evocative but not cryptic — a user who skips it loses flavor, not
information. Ends with a call-to-action sentence ("Invoke a skill. The Council
assembles.") that anchors the fantasy framing without hiding what the tool does.

### Determine Mode: list/explain Behavior

Preamble and persona spotlight are suppressed in `list` mode and `explain` mode.
In `recommend` mode, preamble is omitted but the recommendation itself may
reference personas by name. This matches Story 3 AC#4 and Story 4 AC#4.

## Files Modified

None — this is an architect output. The spec is written to
`docs/specs/skill-discoverability/spec.md`.

## Verification

Spec addresses all 5 stories and their acceptance criteria. Success criteria are
numbered and testable. Before/after diffs are included for all SKILL.md changes.
Validator compliance confirmed: both target files are `type: single-agent`,
exempted from B-series checks.
