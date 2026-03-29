---
title: "Artifact Continuity Badges Specification"
status: "approved"
priority: "P3"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Artifact Continuity Badges Specification

## Summary

Replace terse artifact-detection skip messages in plan-product and build-product
SKILL.md files with Conclave-themed flavor text that acknowledges the found
artifact, names its file path, and announces the next pipeline stage. Cosmetic
text-only changes to 2 files, no structural or validator modifications.

## Problem

Pipeline skills skip completed stages with functional but tonally flat messages
like "Skip if research-findings FOUND for this topic." These are correct but
break immersion with the fantasy world established by agent personas, the
Conclave lore in wizard-guide, and the narrative engagement protocol in the
Communication Protocol.

## Solution

### plan-product Skip Messages (5 skip points)

Replace the skip instruction line in each stage's orchestration section with a
two-sentence themed message. Each message must:

1. Acknowledge the existing artifact using Conclave-world language (e.g., "The
   Archives of the Conclave," "The Cartographer's maps," "The Chronicler's
   records")
2. Name the artifact file path (so the user knows exactly what was found)
3. Announce the transition to the next stage

**Stage 1 (Research)**: Replace "Skip if research-findings FOUND for this
topic." with themed text referencing `docs/research/{topic}-research.md` and
announcing transition to ideation.

**Stage 2 (Ideation)**: Replace "Skip if product-ideas FOUND for this topic."
with themed text referencing `docs/ideas/{topic}-ideas.md` and announcing
transition to roadmap.

**Stage 3 (Roadmap)**: Replace "Skip if roadmap items already exist for this
topic." with themed text referencing `docs/roadmap/` items and announcing
transition to stories.

**Stage 4 (Stories)**: Replace "Skip if user-stories FOUND for this feature."
with themed text referencing `docs/specs/{feature}/stories.md` and announcing
transition to spec.

**Stage 5 (Spec)**: Replace "Skip if technical-spec FOUND for this feature."
with themed text referencing `docs/specs/{feature}/spec.md` and announcing
pipeline completion.

**Complexity routing**: The Simple-tier skip message ("Complexity: Simple —
Stages 1-2 skipped") should also adopt themed language, but must retain the
"Simple" tier label and stage numbers for functional clarity.

### build-product Skip Messages (2 skip points)

Same pattern as plan-product:

**Stage 1 (Planning)**: Replace "Skip if implementation-plan FOUND with status
'approved'." with themed text referencing
`docs/specs/{feature}/implementation-plan.md` and announcing transition to
build.

**Stage 2 (Build)**: Replace "Skip if build progress checkpoints show status
'complete'." with themed text referencing progress checkpoints and announcing
transition to quality review.

### Tone Guidelines

- Use the same Conclave register across both skills: archives, records,
  chronicles, vaults
- Match the narrative engagement guidelines in the Communication Protocol
  (dramatic structure, character continuity)
- Two-sentence maximum per skip message — information density over lore density
- The artifact path must appear in every message (functional requirement, not
  optional flavor)

## Constraints

1. Changes are prose-only within existing SKILL.md sections — no structural
   modifications
2. Shared content markers are not affected (skip messages are in skill-specific
   Orchestration Flow sections)
3. `bash scripts/validate.sh` must pass after all changes
4. Skip messages must contain the artifact path — this is functional
   information, not decoration

## Out of Scope

- Theming non-skip messages (stage starts, completions, cost summaries, error
  messages)
- Modifying agent personas or spawn prompts
- Theming skip messages in granular skills (they don't have artifact-detection
  skip logic)
- Any validator changes
- Changes to any files outside `plugins/conclave/skills/plan-product/SKILL.md`
  and `plugins/conclave/skills/build-product/SKILL.md`

## Files to Modify

| File                                             | Change                                                                           |
| ------------------------------------------------ | -------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Replace 5 skip instruction lines + 1 complexity routing message with themed text |
| `plugins/conclave/skills/build-product/SKILL.md` | Replace 2 skip instruction lines with themed text                                |

## Success Criteria

1. All 5 skip messages in plan-product use Conclave-themed language with
   artifact path and next-stage announcement
2. All 2 skip messages in build-product use Conclave-themed language consistent
   with plan-product's tone
3. The complexity routing message retains the "Simple" tier label and stage
   numbers alongside themed language
4. `bash scripts/validate.sh` produces no new failures after changes
5. Each skip message is at most two sentences and includes the artifact file
   path
