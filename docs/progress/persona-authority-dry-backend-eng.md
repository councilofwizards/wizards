---
feature: "persona-authority-dry"
team: "build-product"
agent: "backend-eng"
phase: "implementation"
status: "in_progress"
last_action:
  "P1+P2 fully green. Fixed run-task placeholder guard in validator. Created product-skeptic.md persona. 95 persona
  files, 86 P1 references, all pass."
updated: "2026-04-04"
---

## Progress Notes

- [Group A] Created scripts/validators/persona-references.sh (P1 + P2 validators)
- [Group A] Added <!-- non-overridable --> to ## Critical Rules in all 10 augur persona files (#3-12)
- [Group A] Created docs/progress/persona-authority-dry-migration-metrics.md with pre-migration baselines
- [Group B] Registered persona-references.sh in scripts/validate.sh
- [Validation] P2 PASS: 80 persona files checked (24 new files created for Group D migrations)
- [Validation] P1 PRE-EXISTING FAILURES: craft-laravel, create-conclave-team, unearth-specification still have "First,
  read..." directives with missing persona files — not in this PR's scope
- [Validation] B2/E1/C1/D1 pre-existing failures confirmed — not regressions from this work
- [Group C] PoC: audit-slop 1639 → 929 lines (43%). All 9 spawn prompts thinned.
- [Group C.5] CLAUDE.md: Added Override Convention + Persona File Schema subsections + P-series doc
- [Group D] review-pr: 1592 → 942 (41%), harden-security: 936 → 628 (33%), squash-bugs: 996 → 693 (30%), refine-code:
  980 → 653 (33%). 24 new persona files created.
- [Group E] create-conclave-team Scribe template updated to thin format + PERSONA FILE GENERATION block
- [Total] 6143 → 3845 lines (37% reduction, 33 agents across 5 skills)
- [QA] Fixed P1 validator: added space-in-path guard to skip run-task's generic placeholder directive
- [QA] Created plugins/conclave/shared/personas/product-skeptic.md (plan-product stage gate skeptic)
- [QA] P1 PASS: 86 references in 20 skills — all resolve. P2 PASS: 95 persona files validated.
