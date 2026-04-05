---
feature: "persona-authority-dry"
team: "build-product"
rating: 3
date: "2026-04-05"
skeptic-gate-count: 5
rejection-count: 3
max-iterations-used: 3
---

# Post-Mortem: P3-32 Persona File Authority — DRY Spawn Prompts

## Rating: 3/5

## What went well

- Plan Skeptic caught 3 real blocking issues (archetype matrix gaps, missing content migration scope, dependency
  contradiction) on first review — saved significant rework
- Security audit was clean — validator code followed defensive patterns throughout
- Content diff procedure worked as designed — no agent behavior lost in migration
- P-series validator is solid infrastructure for future migrations

## What could improve

- Sprint contract criterion 9 (≤20 lines) was unrealistic — required amendment to ≤25 mid-pipeline. Better upfront
  calibration of the thin prompt template against real skills would have avoided the QA rejection cycle
- QA rejection → contract amendment → re-evaluation → second rejection (1 prompt at 26 lines) → fix → final approval was
  3 rounds for what was ultimately a 1-line fix. The contract target should have been validated against actual prompt
  measurements before signing
- 37% line reduction across 5 skills is below the 40-60% spec target floor. The per-skill reductions vary significantly
  (43% for audit-slop down to 30% for squash-bugs) — skills with shorter original spawn prompts yield lower percentage
  reductions
- Pre-existing P1 failures in 3 out-of-scope skills required unplanned persona file creation work

## Key metrics

- Pipeline stages: 3 (all passed)
- Agents spawned: 7 (impl-architect, plan-skeptic, backend-eng, quality-skeptic, qa-agent, security-auditor; no
  frontend-eng needed)
- Plan revision cycles: 1
- QA rejection cycles: 2 (criterion 9)
- Contract amendments: 1
- Lines eliminated: 2,298 across 5 skills
- New persona files: 38
