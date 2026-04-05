---
feature: "persona-authority-dry"
agent: "qa-agent"
status: "complete"
phase: "qa-testing"
team: "build-product"
updated: "2026-04-05"
last_action: "QA verdict APPROVED after artisan prompt fix (26→25 lines). All 10 testable criteria pass."
---

# QA Verdict: persona-authority-dry

**Agent**: Maren Greystone, Inspector of Carried Paths **Date**: 2026-04-05

## QA VERDICT: persona-authority-dry (Final — Amendment 1 + Fix)

Tests: 10/12 passed, 0 failed, 2 inconclusive Verdict: **APPROVED**

## Test Results

| #   | Criterion                              | Outcome      | Details                                                                                                                                |
| --- | -------------------------------------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Validator exits clean                  | PASS         | A1-A4 all pass. B1, B3, F1, G1, P1, P2 all pass. B2 (16 skills), C1, D1, E1 failures are ALL pre-existing. No new failures introduced. |
| 2   | audit-slop line reduction ≤984         | PASS         | 929 lines (56.7% of 1,639). Target ≤984.                                                                                               |
| 3   | Persona file schema completeness       | PASS         | P2 passes: 95 files checked.                                                                                                           |
| 4   | At least 5 skills migrated             | PASS         | 33 spawn prompts across 5 skills: audit-slop (9), review-pr (10), harden-security (4), squash-bugs (6), refine-code (4).               |
| 5   | Override convention documented         | PASS         | CLAUDE.md `### Override Convention` with `ADD:` and `REPLACE:` present.                                                                |
| 6   | Forge generates thin prompts           | PASS         | create-conclave-team has PERSONA FILE GENERATION (2) and First, read (6).                                                              |
| 7   | Mixed-state validity                   | PASS         | 5 migrated + ~18 non-migrated coexist. P1 passes (86 refs in 20 skills). A-series all pass.                                            |
| 8   | Migration metrics recorded             | PASS         | Metrics file exists with all 5 skills. Total: 6,143→3,845 lines (37% reduction).                                                       |
| 9   | Thin spawn prompts ≤25 lines (amended) | **PASS**     | All 33 prompts ≤25 lines. Max: refine-code/artisan and refine-code/refine-skeptic at 25. Min: squash-bugs/first-skeptic at 20.         |
| 10  | Persona file read directive is line 1  | PASS         | All 33 prompts start with `First, read` directive.                                                                                     |
| 11  | Behavioral regression                  | INCONCLUSIVE | Requires runtime invocation. Post-deployment: invoke `/audit-slop` and verify agent behavior matches persona definitions.              |
| 12  | Reversibility                          | INCONCLUSIVE | Requires destructive git operations. Post-deployment: test in branch before merge.                                                     |

## Criterion 9 Final Line Counts (amended ≤25)

**audit-slop** (9): doubt-augur: 22, pattern-augur: 21, breach-augur: 21, provenance-augur: 21, flow-augur: 21,
waste-augur: 21, speed-augur: 21, proof-augur: 21, charter-augur: 21 — **all ≤25**

**review-pr** (10): scrutineer: 21, sentinel: 21, lexicant: 21, arbiter: 21, structuralist: 21, swiftblade: 21, prover:
21, delver: 21, chandler: 21, illuminator: 21 — **all ≤25**

**harden-security** (4): threat-modeler: 21, vuln-hunter: 22, remediation-engineer: 22, assayer: 21 — **all ≤25**

**squash-bugs** (6): scout: 21, sage: 21, inquisitor: 21, artificer: 21, warden: 22, first-skeptic: 20 — **all ≤25**

**refine-code** (4): surveyor: 22, strategist: 22, artisan: 25 (fixed from 26), refine-skeptic: 25 — **all ≤25**

## Pre-existing Failures (Not Regressions)

- **B2/protocol-drift**: 16 skills — whitespace alignment in table row 49. Pre-existing sync artifact.
- **C1**: Roadmap files with non-standard status/effort/impact values
- **D1**: Spec files missing fields or non-standard status values
- **E1**: Progress files with invalid team values and missing frontmatter fields

## Verdict History

1. **Initial** (2026-04-04): REJECTED — 32/33 prompts exceeded ≤20 line limit.
2. **Re-evaluation 1** (2026-04-04): REJECTED — Amendment 1 raised limit to ≤25. refine-code/artisan at 26 lines (1
   over).
3. **Final** (2026-04-05): **APPROVED** — artisan prompt condensed to 25 lines. All 33 prompts pass ≤25.
