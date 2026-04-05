---
type: "compact-reference"
feature: "qa-agent"
source_roadmap: "docs/roadmap/P2-12-qa-agent-live-testing.md"
compacted: "2026-04-05"
---

# QA Agent for Live Testing — Engineering Reference

## What Was Built

Dedicated QA agent persona (Maren Greystone) created. QA Agent spawn definition + full spawn prompt + QA GATE step added
to build-implementation and build-product. QA runs after Quality Skeptic approves code quality and before final Lead
sign-off.

## Entrypoints

- `plugins/conclave/shared/personas/qa-agent.md` — Maren Greystone persona definition
- `plugins/conclave/skills/build-implementation/SKILL.md` — QA Agent spawn def + prompt; step 6 QA GATE
- `plugins/conclave/skills/build-product/SKILL.md` — QA Agent spawn def + prompt; Stage 2 step 7 QA GATE; qa-verdict in
  Artifact Detection

## Files Modified/Created

- `plugins/conclave/shared/personas/qa-agent.md` — Created: Maren Greystone, Inspector of Carried Paths; role separation
  table, checkpoint triggers, output format, write safety
- `plugins/conclave/skills/build-implementation/SKILL.md` — qa-testing checkpoint phase, `--light` mode note, Spawn Step
  5 contract injection update, QA Agent spawn def (opus), step 6 QA GATE, 2 critical rules, QA deadlock in failure
  recovery, full spawn prompt
- `plugins/conclave/skills/build-product/SKILL.md` — same additions mirrored; qa-verdict in Artifact Detection table

## Dependencies

- **Depends on**: P2-11 (soft — QA reads sprint contract acceptance criteria when available)
- **Depended on by**: nothing

## Configuration

QA Agent is always Opus (not downgraded in `--light` mode). QA evaluates runtime behavior (Playwright/e2e tests), not
code diffs.

## Validation

`bash scripts/validate.sh` — A3 (spawn definitions — qa-agent entry validated). Verify persona file:
`plugins/conclave/shared/personas/qa-agent.md`.
