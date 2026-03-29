---
feature: "unearth-specification"
team: "conclave-forge"
agent: "scribe"
phase: "design"
status: "complete"
last_action: "Assembled complete SKILL.md for unearth-specification; all A-series and B-series validators pass"
updated: "2026-03-29T01:10:00Z"
---

# Scribe Checkpoint — Unearth Specification: SKILL.md Assembly

## Assembly Summary

**Skill written**: `plugins/conclave/skills/unearth-specification/SKILL.md`

**Sources consumed**:
- `docs/progress/unearth-specification-architect.md` — blueprint (phase decomposition, agent roster, output structure)
- `docs/progress/unearth-specification-armorer.md` — methodology manifests (4 methods per agent)
- `docs/progress/unearth-specification-lorekeeper.md` — theme design (personas, vocabulary, narrative arc)

**Validator results** (A-series + B-series):
- A1/frontmatter: PASS (23 files)
- A2/required-sections: PASS (23 files)
- A3/spawn-definitions: PASS (23 files)
- A4/shared-markers: PASS (23 files)
- B1/principles-drift: PASS (23 files)
- B2/protocol-drift: PASS (23 files)
- B3/authoritative-source: PASS (23 files)

## Structural Decisions

**Communication protocol skeptic row**: Used `The Assayer` as display name (normalizes to SKEPTIC_NAME in B2 validator).
`Assayer` alone (no "The") is not in the B2 normalizer list — using `The Assayer` ensures the row normalizes correctly.

**Lightweight mode**: Logic Excavator (Mott Loreseam) is the only non-skeptic Opus agent, downgraded to Sonnet under
`--light`. The Assayer remains Opus always.

**Fork-join in Phase 2**: All three excavators (logic, schema, boundary) are explicitly spawned simultaneously.
The instructions use "simultaneously" and "do NOT wait" to make the parallel intent unambiguous.

**Chronicler write isolation**: Explicit "NEVER read source code" constraint added to both the Orchestration Flow
and the Chronicler's spawn prompt. Gap flagging to Dig Master is required before proceeding.

**Checkpoint phases**: `survey | excavate | chronicle | complete` — matches the three pipeline phases plus terminal
state, consistent with other multi-phase skills.

**Output directory**: `docs/specifications/{project-name}/` — separate from `docs/progress/` to distinguish output
artifacts from agent progress checkpoints.

## SCAFFOLD Comments Placed

1. Checkpoint frequency — before `### When to Checkpoint`
2. Logic Excavator default Opus model — after `## Lightweight Mode`
3. Skeptic always Opus — before `### Esk Truthsieve (Assayer)` in Spawn the Team
4. Max iterations before escalation — in `## Critical Rules`

## Progress Notes

- [01:00] Read reference files: craft-laravel SKILL.md, squash-bugs SKILL.md, three deliverable files
- [01:02] Confirmed structural template from craft-laravel (most structurally similar: fork-join, Opus skeptic)
- [01:04] Assembled complete SKILL.md (~700 lines) in single Write operation
- [01:06] B2 protocol-drift failure: `Assayer` not in normalizer list; fixed to `The Assayer` + corrected spacing
- [01:08] All 7 A/B validators passing; skill file complete and compliant
