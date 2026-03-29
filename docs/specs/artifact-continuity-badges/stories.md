---
type: "user-stories"
feature: "artifact-continuity-badges"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-09-artifact-continuity-badges.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-09 Artifact Continuity Badges

## Epic Summary

Pipeline skills silently skip completed stages with terse functional text. These
messages are correct but tonally inconsistent with the fantasy world established
by agent personas. This epic replaces stage-skip messages in plan-product and
build-product with Conclave-themed flavor text that acknowledges the artifact,
names its location, and announces the next stage — maintaining information
density while reinforcing the world.

## Stories

### Story 1: Conclave-Themed Skip Messages in plan-product

- **As a** user re-running `/plan-product` on a topic with existing artifacts
- **I want** stage-skip notifications to use Conclave-themed language that names
  the artifact found and the next stage entering
- **So that** the pipeline's continuation feels like a deliberate act within the
  world rather than a generic system status message
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given plan-product detects a FOUND research-findings artifact, when Stage 1
     is skipped, then the skip message references the Conclave's records, names
     the artifact path, and announces the next stage.
  2. Given plan-product detects a FOUND product-ideas artifact, when Stage 2 is
     skipped, then the skip message uses thematic language consistent with Story
     1's pattern.
  3. Given plan-product detects FOUND artifacts for Stages 3, 4, and 5, when
     each stage is skipped, then each skip message follows the same pattern:
     flavor acknowledgment + artifact location + next destination.
  4. Given complexity routing fires ("Complexity: Simple — Stages 1-2 skipped"),
     when that message is emitted, then it adopts themed language without losing
     the routing rationale — tier label and stage numbers must still be present.
  5. Given I run `bash scripts/validate.sh` after the edits, then all validators
     pass with no new failures.
- **Edge Cases**:
  - All stages skipped: themed skip messages must be concise enough that a
    full-skip run doesn't produce a wall of lore.
  - Artifact path templating: skip messages must use the actual resolved topic
    value, not a literal placeholder.
- **Notes**: Skip lines live in the `### Stage N:` sections of the Orchestration
  Flow. Two-sentence maximum per skip message.

### Story 2: Conclave-Themed Skip Messages in build-product

- **As a** user re-running `/build-product` on a feature with existing artifacts
- **I want** stage-skip notifications to use Conclave-themed language consistent
  with plan-product's treatment
- **So that** both pipeline skills share the same world tone when reporting
  artifact continuity
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given build-product detects a FOUND approved implementation plan, when
     Stage 1 is skipped, then the skip message uses thematic language matching
     plan-product's pattern.
  2. Given build-product detects completed build checkpoints, when Stage 2 is
     skipped, then the skip message acknowledges the completed work and names
     the transition to Stage 3.
  3. Given I run `bash scripts/validate.sh` after the edits, then all validators
     pass with no new failures.
- **Edge Cases**:
  - Partial build completion: themed text applies only when the stage is fully
    skipped.
  - Tone consistency: same Conclave register as plan-product.
- **Notes**: Implement both skills in the same pass to ensure consistency.

## Non-Functional Requirements

- Changes are content-only — no validator logic, no structural edits.
- Themed skip messages must not exceed two sentences with artifact path and
  next-stage name.
- `bash scripts/validate.sh` must pass after all changes.
- Flavor language must be consistent across both skills.

## Out of Scope

- Theming non-skip messages (stage start, completion, cost summaries).
- Modifying agent persona names or spawn prompts.
- Theming skip messages in granular skills.
- Any validator changes.
- Any changes outside plan-product and build-product SKILL.md files.
