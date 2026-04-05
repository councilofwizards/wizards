---
type: "compact-reference"
feature: "sprint-contracts"
source_roadmap: "docs/roadmap/P2-11-sprint-contracts.md"
compacted: "2026-04-05"
---

# Sprint Contracts / Definition of Done — Engineering Reference

## What Was Built

Sprint contract artifact template + Contract Negotiation GATE added to plan-implementation. Quality Skeptic in
build-implementation and build-product now evaluates against contract acceptance criteria. F-series validator updated.

## Entrypoints

- `docs/templates/artifacts/sprint-contract.md` — artifact template
- `plugins/conclave/skills/plan-implementation/SKILL.md` — Step 3 Contract Negotiation GATE (new orchestration step)
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 5 (contract read), Spawn Step 5 (contract
  injection), Quality Skeptic Sprint Contract Evaluation block
- `plugins/conclave/skills/build-product/SKILL.md` — Stage 1 step 3 (contract negotiation), Stage 2 contract injection,
  Artifact Detection table sprint-contract row

## Files Modified/Created

- `docs/templates/artifacts/sprint-contract.md` — Created: YAML frontmatter (feature, acceptance-criteria[],
  out-of-scope[], performance-targets, signed-by)
- `scripts/validators/artifact-templates.sh` — sprint-contract entry added to expected_templates
- `plugins/conclave/skills/plan-implementation/SKILL.md` — Setup step 2 extended; new Orchestration step 3 (Contract
  Negotiation GATE); step 8 frontmatter link
- `plugins/conclave/skills/build-implementation/SKILL.md` — Setup step 5, Spawn Step 5, Quality Skeptic prompt extension
- `plugins/conclave/skills/build-product/SKILL.md` — Setup step 2 extension, Artifact Detection table row, Stage 1 step
  3, Stage 2 contract injection, Quality Skeptic extension

## Dependencies

- **Depends on**: P2-06 (artifact-format-templates — artifact template convention), P2-13 (user-writable-config — custom
  overrides via `.claude/conclave/templates/`)
- **Depended on by**: P2-12 (QA agent reads sprint contract acceptance criteria)

## Configuration

Custom sprint contract template override: `.claude/conclave/templates/sprint-contract.md` (read before built-in
template). Graceful degradation if absent.

## Validation

`bash scripts/validate.sh` — F1 checks that `docs/templates/artifacts/sprint-contract.md` exists with correct `type`
field.
