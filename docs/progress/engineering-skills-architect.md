---
feature: "P3-engineering-skills"
team: "product-planning"
agent: "software-architect"
phase: "complete"
status: "complete"
last_action: "Wrote 5 technical specifications for engineering skills"
updated: "2026-03-27"
---

## Progress Notes

- Wrote spec for P3-01 Custom Agent Roles →
  docs/specs/custom-agent-roles/spec.md
- Wrote spec for P3-04 Incident Triage → docs/specs/triage-incident/spec.md
- Wrote spec for P3-05 Tech Debt Review → docs/specs/review-debt/spec.md
- Wrote spec for P3-06 API Design → docs/specs/design-api/spec.md
- Wrote spec for P3-07 Migration Planning → docs/specs/plan-migration/spec.md

## Spec Summary

| Feature                  | Agents                                                                                   | New Skeptic Pair                        | New Artifact Template | Files to Modify                                       |
| ------------------------ | ---------------------------------------------------------------------------------------- | --------------------------------------- | --------------------- | ----------------------------------------------------- |
| P3-01 Custom Agent Roles | N/A (modifies all 14 multi-agent skills)                                                 | N/A                                     | N/A                   | 17 (14 SKILL.md + 3 templates)                        |
| P3-04 Incident Triage    | 3 (severity-assessor, rca-analyst, triage-skeptic)                                       | triage-skeptic / Triage Skeptic         | No                    | 7 (1 SKILL.md + 2 scripts + 4 personas)               |
| P3-05 Tech Debt Review   | 2 (debt-analyst, debt-skeptic)                                                           | debt-skeptic / Debt Skeptic             | No                    | 6 (1 SKILL.md + 2 scripts + 3 personas)               |
| P3-06 API Design         | 4 (api-consistency-reviewer, breaking-change-analyzer, dx-evaluator, api-design-skeptic) | api-design-skeptic / API Design Skeptic | No                    | 8 (1 SKILL.md + 2 scripts + 5 personas)               |
| P3-07 Migration Planning | 4 (scope-mapper, migration-phaser, risk-assessor, migration-skeptic)                     | migration-skeptic / Migration Skeptic   | Yes (migration-plan)  | 10 (1 SKILL.md + 3 scripts + 1 template + 5 personas) |

## Cross-Cutting Patterns

- All 4 new skills: engineering classification in both sync + validation scripts
- All 4 new skills: new skeptic name pairs in B2 normalizer (8 new sed entries
  total)
- All 4 new skills: new persona files for each agent
- Only plan-migration requires a new artifact template (registered in F-series
  validator)
- Only custom-agent-roles modifies existing SKILL.md files (all 14 multi-agent
  skills)
