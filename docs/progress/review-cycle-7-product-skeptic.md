---
feature: "review-cycle-7"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Submitted RC7 review verdict"
updated: "2026-02-19"
---

# Review Cycle 7 — Product Skeptic Review

## REVIEW: Researcher and Architect Findings for RC7

**Verdict: APPROVED**

Both reports are evidence-based, accurate on the major claims, and provide actionable recommendations. I verified every
material claim against source files. Two corrections and four notes follow.

---

## Corrections Required

### 1. Researcher: P2-08 "3/3" count is internally inconsistent

The researcher's Section 3 says: "Prerequisite: 2+ business skills built and validated. MET (2/2 in RC6, now 3/3 with
plan-hiring)."

The researcher's OWN Section 6 says: "Structured Debate: IMPLEMENTED, NOT YET VALIDATED."

These contradict each other. Plan-hiring is NOT validated — the researcher correctly identifies this in Section 6.
Counting it as meeting the "built and validated" prerequisite in Section 3 is sloppy. The P2-08 prerequisite (2+
validated) is still met because draft-investor-update and plan-sales were already validated — plan-hiring doesn't change
the status. The conclusion is correct but the evidence chain is inconsistent.

**Fix**: Section 3 should say "MET (2/2 validated in RC6; plan-hiring adds a 3rd built but not yet validated)." Do not
count unvalidated skills toward a "built and validated" threshold.

### 2. Architect: P3-14 framing is backwards

The architect's verdict says "READY for build-product team with minor notes." But the build-product team has ALREADY
BUILT P3-14. The SKILL.md exists at 1560 lines, the validator was updated, and progress files from impl-architect,
backend-eng, frontend-eng, and quality-skeptic all exist. The architect acknowledges this in the body ("has already been
drafted at 1560 lines") but the top-line verdict contradicts it.

**Fix**: The verdict should say "IMPLEMENTED (uncommitted); needs validation and commit" — not "ready for build team."
The work is done; the remaining task is verification, not construction.

---

## Verified Claims

All of the following were confirmed against source files:

| Claim                                                      | Source     | Verified Against                                                    | Result                                                                                                              |
| ---------------------------------------------------------- | ---------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 7 SKILL.md files on disk                                   | Researcher | `Glob plugins/conclave/skills/*/SKILL.md`                           | **Correct** — 7 files                                                                                               |
| plan-hiring SKILL.md is 1560 lines                         | Both       | `wc -l` on file                                                     | **Correct** — exactly 1560                                                                                          |
| 6 multi-agent skills have shared content markers           | Researcher | `Grep BEGIN SHARED: principles`                                     | **Correct** — 6 files (plan-product, build-product, review-quality, draft-investor-update, plan-sales, plan-hiring) |
| setup-project is single-agent, excluded from shared checks | Both       | `type: single-agent` in frontmatter                                 | **Correct**                                                                                                         |
| P2-07 roadmap file is stale                                | Researcher | `P2-07-universal-principles.md` says "4 multi-agent skills"         | **Correct** — actual is 6                                                                                           |
| Validator has bias-skeptic/fit-skeptic expressions         | Both       | Lines 65-68 of `skill-shared-content.sh`                            | **Correct** — 4 new expressions present                                                                             |
| P3-14 shows as ready (not complete) in roadmap             | Researcher | `_index.md` line 92                                                 | **Correct** — shows `ready`                                                                                         |
| Quality-skeptic pre-impl gate approved                     | Researcher | `plan-hiring-quality-skeptic.md`                                    | **Correct** — APPROVED after fix                                                                                    |
| No post-impl review checkpoint                             | Researcher | Same file — no post-impl section                                    | **Correct**                                                                                                         |
| Backend-eng checkpoint still in_progress                   | Researcher | `plan-hiring-backend-eng.md` — phase "design", status "in_progress" | **Correct** — poor checkpoint hygiene                                                                               |

---

## P2-08 Divergence: Adjudication

**Researcher**: Spec P2-08 now. All deferral conditions met. **Architect**: Defer to skill #8. Shared content management
is the binding constraint.

**My verdict: The architect is right on timing. The researcher is right on urgency.**

The architect correctly identifies that plugin boundaries depend on the P2-07 extraction mechanism. If you spec P2-08
without knowing how shared content extraction works (P2-07), you're designing plugin boundaries with incomplete
information. The shared content coupling is THE constraint — the architect nails this.

However, the researcher is right that we're one skill away from the trigger and need to be ready. Sitting on our hands
until skill #8 arrives and then scrambling to design both P2-07 and P2-08 simultaneously is the wrong move.

**Resolution**: Pre-plan P2-07 extraction mechanism FIRST (decide: includes, references, or build-time injection). Once
the P2-07 mechanism is designed, THEN spec P2-08 with that knowledge. Both can happen before skill #8 is built, but
P2-07 must lead. The researcher's recommended action #3 (spec P2-08) and #4 (pre-plan P2-07) have the wrong ordering —
#4 should come first.

---

## Notes

### 1. Checkpoint hygiene is poor

The backend-eng checkpoint says "in_progress" with phase "design" and last_action "Writing plan-hiring SKILL.md -
starting." The SKILL.md is 1560 lines — the work is clearly done. The quality-skeptic checkpoint has no post-impl review
section. This suggests the build-product team completed the work but didn't clean up their checkpoints. This isn't a
researcher/architect failing, but it SHOULD be flagged as a process issue: the progress-checkpoint validator should
catch stale in_progress checkpoints.

### 2. Structured Debate validation is genuinely important

The researcher draws a clear line between IMPLEMENTED and VALIDATED. This is correct and the architect didn't make this
distinction. I want to reinforce: Structured Debate is NOT validated. The SKILL.md exists but /plan-hiring has never
been run. Claims about "3 patterns" must carry the asterisk that only 2 are execution-validated. This distinction
matters for P2-08 speccing — plugin boundaries informed by 2 validated + 1 unvalidated pattern are less reliable than 3
validated.

### 3. SKILL.md size growth is a real concern

The architect flags plan-hiring at 76KB / 1560 lines. This is 3.5x the engineering skill average (~22KB). Every agent
spawn in the hiring skill loads this into context. The cross-examination format definitions repeat similar structure per
agent role. The architect correctly notes this isn't a blocker but is "worth noting." I agree — when the next business
skill is specced, the spec should include a SKILL.md size budget or demonstrate that format template redundancy has been
reduced.

### 4. Recommended action sequence needs reordering

The researcher recommends:

1. Verify and commit P3-14
2. Validate Structured Debate pattern
3. Spec P2-08
4. Pre-plan P2-07
5. Update P2-07 roadmap file
6. Park P2-02

Correct sequence:

1. Verify and commit P3-14 (unblocks everything)
2. Validate Structured Debate (run /plan-hiring)
3. Update P2-07 roadmap file (housekeeping, do immediately)
4. Pre-plan P2-07 extraction mechanism (BEFORE P2-08)
5. Spec P2-08 with P2-07 mechanism in mind (AFTER P2-07 pre-plan)
6. Park P2-02

The reordering matters because P2-08 depends on P2-07's mechanism design.

---

## Summary

Both reports are thorough, well-sourced, and actionable. The researcher's data collection is excellent — every claim I
checked was factually accurate. The architect's technical analysis (especially the shared content binding constraint
argument) is sound. The two corrections above are about framing and consistency, not factual errors. The findings are
reliable enough to inform product decisions.
