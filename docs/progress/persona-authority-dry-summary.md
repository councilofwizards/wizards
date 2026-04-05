---
feature: "persona-authority-dry"
status: "complete"
completed: "2026-04-05"
---

# P3-32: Persona File Authority — DRY Spawn Prompts — Progress

## Summary

Refactored 5 multi-agent SKILL.md files to use thin spawn prompts (~15-25 lines) referencing authoritative persona files
instead of duplicating agent-intrinsic content inline. Created a new P-series bash validator for persona file reference
integrity and schema completeness. Expanded persona file inventory to 95 files covering all 6 archetypes.

## Changes

### New Validator (P-series)

- Created `scripts/validators/persona-references.sh` with P1 (reference integrity: 86 references across 20 skills) and
  P2 (schema completeness: 95 persona files validated against archetype-section matrix)
- Registered in `scripts/validate.sh`

### Persona File Expansion

- Added `<!-- non-overridable -->` annotations to Critical Rules in 10 augur persona files
- Created 38 new persona files for agents across review-pr, harden-security, squash-bugs, refine-code, craft-laravel,
  create-conclave-team, unearth-specification, and plan-product
- Total persona file inventory: 95 files covering 6 archetypes (assessor, skeptic, domain-expert, team-lead, lead,
  evaluator)

### SKILL.md Migrations (5 skills, 33 agents)

- audit-slop: 1,639 → 929 lines (43% reduction, 9 agents)
- review-pr: 1,592 → 942 lines (41% reduction, 9 agents)
- harden-security: 936 → 628 lines (33% reduction)
- squash-bugs: 996 → 693 lines (30% reduction)
- refine-code: 980 → 653 lines (33% reduction)
- **Total: 6,143 → 3,845 lines (2,298 lines eliminated, 37% reduction)**

### Documentation

- Added Override Convention section to CLAUDE.md with additive/replacement examples
- Added Persona File Schema reference to CLAUDE.md
- Added P-series validator documentation to CLAUDE.md
- Updated create-conclave-team Scribe template to generate thin spawn prompts and persona files

### Sprint Contract

- 12 acceptance criteria: 10 PASS, 2 DEFERRED (behavioral regression and reversibility require runtime verification)
- Amendment 1: criterion 9 relaxed from ≤20 to ≤25 lines (safety-critical invocation context requires 3-5 extra lines)

## Files Modified

- `scripts/validators/persona-references.sh` — new P-series validator
- `scripts/validate.sh` — validator registration
- `plugins/conclave/shared/personas/*.md` — 10 annotated, 38 created
- `plugins/conclave/skills/audit-slop/SKILL.md` — PoC migration
- `plugins/conclave/skills/review-pr/SKILL.md` — migration
- `plugins/conclave/skills/harden-security/SKILL.md` — migration
- `plugins/conclave/skills/squash-bugs/SKILL.md` — migration
- `plugins/conclave/skills/refine-code/SKILL.md` — migration
- `plugins/conclave/skills/create-conclave-team/SKILL.md` — Scribe template update
- `CLAUDE.md` — Override Convention + Persona File Schema docs

## Files Created

- `scripts/validators/persona-references.sh` — P1 + P2 validator
- `docs/specs/persona-authority-dry/implementation-plan.md` — approved plan
- `docs/specs/persona-authority-dry/sprint-contract.md` — signed contract (12 criteria)
- `docs/progress/persona-authority-dry-migration-metrics.md` — before/after line counts
- 38 new persona files in `plugins/conclave/shared/personas/`

## Verification

- **Plan Skeptic (Voss Grimthorn)**: APPROVED after 1 revision cycle (3 blocking issues fixed)
- **Quality Skeptic (Mira Flintridge)**: APPROVED at pre-implementation gate, post-implementation gate, and Stage 3
  final
- **QA Agent (Maren Greystone)**: APPROVED (10/12 testable criteria pass, 2 inconclusive/deferred)
- **Security Auditor (Shade Valkyr)**: CLEAN (zero findings across 10 audit vectors)
- **Validators**: P1 PASS (86 references), P2 PASS (95 files), A-series unchanged
