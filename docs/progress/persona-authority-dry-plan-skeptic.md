---
type: "review"
feature: "persona-authority-dry"
reviewer: "plan-skeptic (Voss Grimthorn)"
status: "completed"
verdict: "APPROVED"
review_round: 2
created: "2026-04-04"
updated: "2026-04-04"
---

# Plan Review: Persona File Authority — DRY Spawn Prompts (P3-32)

Reviewer: Voss Grimthorn, Keeper of the War Table

---

## Round 2 Re-Review

All 3 blocking issues, 3 non-blocking issues, and 2 sprint contract gaps from Round 1 have been addressed.

---

## SPRINT CONTRACT REVIEW

**Verdict: APPROVED (12 criteria)**

| #   | Criterion                                                                       | Pass/Fail Evaluable | Specific | Maps to Spec |
| --- | ------------------------------------------------------------------------------- | ------------------- | -------- | ------------ |
| 1   | Validator exits clean (`validate.sh` exits 0)                                   | YES                 | YES      | SC-1, SC-8   |
| 2   | audit-slop line reduction ≤60% (≤984 lines)                                     | YES                 | YES      | SC-2         |
| 3   | Persona file schema completeness (P2)                                           | YES                 | YES      | SC-3         |
| 4   | At least 5 skills migrated, all validators passing                              | YES                 | YES      | SC-5         |
| 5   | Override convention documented in CLAUDE.md                                     | YES                 | YES      | SC-6         |
| 6   | Forge generates thin prompts (satisfies 9+10, includes PERSONA FILE GENERATION) | YES                 | YES      | SC-7         |
| 7   | Mixed-state validity                                                            | YES                 | YES      | SC-8         |
| 8   | Migration metrics recorded                                                      | YES                 | YES      | Spec §5      |
| 9   | Thin spawn prompts ≤20 lines (excl. SKILL-SPECIFIC OVERRIDES)                   | YES                 | YES      | Story 2 AC1  |
| 10  | Persona file read directive is line 1                                           | YES                 | YES      | Story 2 AC2  |
| 11  | Behavioral regression — paths, gates, output format                             | YES                 | YES      | SC-4         |
| 12  | Reversibility — git revert passes all validators                                | YES                 | YES      | SC-10        |

**Notes**:

- Criterion 6 now cross-references criteria 9 and 10 — properly testable.
- Criteria 11 and 12 fill the behavioral regression and reversibility gaps from Round 1.
- Spec SC-9 (40-60% aggregate across all 22 skills) correctly excluded — only 5 skills in sprint scope.

No missing criteria. Contract is complete.

---

## PLAN REVIEW: persona-authority-dry

**Verdict: APPROVED**

### Round 1 Blocking Issue Resolution

**Issue 1 (P2 archetype matrix)**: RESOLVED. Matrix now covers all 6 actual archetypes: `assessor`, `skeptic`,
`domain-expert`, `team-lead`, `lead`, `evaluator`. The `coordinator` archetype is handled as a `team-lead` alias if
encountered — defensive without dead code. The distinction between `team-lead` (all sections required, 12 files) and
`lead` (Responsibilities/Output optional, 1 file) is sound — team-leads carry methodology in their persona files while
chief-augur's orchestration lives in the SKILL.md.

**Issue 2 (File Changes table)**: RESOLVED. Files #3-12 now explicitly include "Content diff: compare spawn prompt
content against persona file, migrate any spawn-prompt-only content." File #13 has prerequisite note. File #14 requires
per-agent content diff. The traceability to Story 1 AC5 is present.

**Issue 3 (Dependency Group D)**: RESOLVED. CLAUDE.md (#19) moved to Group C.5 (sequential after PoC validation, before
migrations). DAG and Parallel Execution Groups are now internally consistent. Migrations #14-17 correctly depend on #19.

### Round 1 Non-Blocking Issue Resolution

**Issue 4 (poc-results name mismatch)**: RESOLVED. File Change #20 now explicitly states it serves both Story 5 AC6 and
Story 6, with rationale for using a single metrics file.

**Issue 5 (review-pr lead exclusion)**: RESOLVED. File #14 description now reads "9 spawned-teammate verbose spawn
prompts (lead excluded)." Migration metrics schema shows "9 (spawned teammates only; lead excluded)." Notes for
Engineers includes lead exclusion guidance.

**Issue 6 (heading normalization)**: RESOLVED. P2 validator accepts EITHER `## Responsibilities` OR `## Methodology`.
Verified: 40 files use Methodology, 56 use Responsibilities (overlap where files have both). Notes for Engineers
documents this. No rename needed.

### Observations (non-blocking, for the record)

1. **P2 validator's `evaluator` archetype has all sections required.** This is correct for qa-agent.md (the sole
   evaluator), but if future evaluator-archetype persona files have different needs, the matrix may need revisiting. Not
   a concern for this sprint.

2. **Content diff procedure relies on engineer judgment** to categorize spawn prompt sections. For audit-slop (near-100%
   duplication), this is low risk. For review-pr and other skills where persona files may be thinner, the diff is the
   riskiest step. The plan's test strategy (PoC behavioral test, per-migration validation) mitigates this adequately.

3. **The plan scopes 5 specific migrations** (audit-slop, review-pr, harden-security, squash-bugs, refine-code). For
   migrations #15-17 (harden-security, squash-bugs, refine-code), the File Changes descriptions are terse ("Thin all
   spawn prompts"). Engineers should apply the same content-diff-before-thinning discipline documented for #13 and #14.
   The Notes for Engineers section covers this.

---

## Round 1 Review (historical record)

### Original Verdict: REJECTED (3 blocking, 3 non-blocking)

| #     | Type         | Issue                                                   | Resolution                                           |
| ----- | ------------ | ------------------------------------------------------- | ---------------------------------------------------- |
| 1     | BLOCKING     | P2 archetype matrix missing `team-lead` and `evaluator` | Fixed: 6-archetype matrix with heading normalization |
| 2     | BLOCKING     | File Changes table omitted content migration work       | Fixed: #3-12 expanded, #13-14 prerequisites noted    |
| 3     | BLOCKING     | Group D parallelism contradicted dependency text        | Fixed: CLAUDE.md moved to Group C.5                  |
| 4     | Non-blocking | Story 5 AC6 file name mismatch                          | Fixed: single metrics file with rationale            |
| 5     | Non-blocking | review-pr lead agent exclusion unclear                  | Fixed: agent count clarified                         |
| 6     | Non-blocking | Responsibilities vs Methodology heading                 | Fixed: P2 accepts both headings                      |
| SC-6  | CONTRACT     | Criterion 6 underspecified                              | Fixed: cross-references criteria 9+10                |
| SC-11 | CONTRACT     | Missing behavioral regression criterion                 | Fixed: criterion 11 added                            |
| SC-12 | CONTRACT     | Missing reversibility criterion                         | Fixed: criterion 12 added                            |
