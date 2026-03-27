---
feature: "harness-design-improvements"
team: "product-planning"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Skeptic review complete — approved with required corrections"
updated: "2026-03-27T13:30:00Z"
---

# Harness-Design Improvements: Skeptic Review

**Reviewer**: Wren Cinderglass, Siege Inspector
**Date**: 2026-03-27
**Source**: Analyst roadmap placement analysis (harness-improvements-analyst.md)

---

## REVIEW: Harness Design Improvements Roadmap Items

**Verdict: APPROVED**

The analyst's structural analysis is sound. Priority assignments are well-justified by evidence and user input. Dependencies are acyclic and valid. All 7 improvement areas are covered. No conflicts with existing roadmap items. User alignment is strong — QA Agent is P2, cost tracking is excluded.

The proposals can proceed to roadmap authoring with the corrections noted below.

---

## Required Corrections

### 1. QA Agent (P2-12) Category: core-framework → quality-reliability

The analyst categorizes P2-12 as `core-framework`. This is wrong. The QA Agent writes and executes e2e/Playwright tests — that is quality assurance, not core orchestration. The existing P2-04 (Automated Testing Pipeline) uses `quality-reliability` for analogous testing infrastructure. Consistency demands the same category here.

**Fix**: Change P2-12 category from `core-framework` to `quality-reliability`.

### 2. Sprint Contracts (P2-11) Effort: Large → Medium

The analyst rates P2-11 as Large. The actual scope is: one new artifact template (following the P2-06 pattern), a negotiation step added to plan-implementation SKILL.md, and evaluation criteria updates in build-implementation SKILL.md. Compare: P2-06 (Artifact Format Templates) created *all* artifact templates and was rated Medium. A single template plus protocol instructions in 2 markdown files does not exceed that benchmark.

**Fix**: Change P2-11 effort from `Large` to `Medium`.

### 3. Roadmap State Table Contains Factual Errors

The analyst's "Roadmap State at Time of Analysis" section (line 34) claims "P2-01 through P2-07, P2-09 complete." Verified against individual roadmap files:

- **P2-02 (Skill Composability)**: `status: not_started` — parked, superseded by ADR-004
- **P2-07 (Role-Based Principles Split)**: `status: not_started`

The analyst correctly places P2-07 in Wave 2 as work-to-be-done, contradicting the status table. This error does not affect proposed items or dependencies (none depend on P2-02 or P2-07), but the background section should be corrected for accuracy.

**Fix**: Update roadmap state table to reflect P2-02 as parked/not_started and P2-07 as not_started.

---

## Notes

**Priority assignments are correct.** P2-11 and P2-12 both clear the P2 bar: Sprint Contracts address the paper's primary finding (vague evaluation criteria), and QA Agent fills the highest-impact quality gap with explicit user backing. The five P3 items are correctly classified as incremental improvements.

**Sequencing is well-reasoned.** P2-11 before P2-12 is the right call — the QA Agent evaluates against acceptance criteria, so Sprint Contracts should exist first. The soft dependency appropriately signals "better with" rather than "blocked without."

**P3-29 (Evaluator Tuning) effort is Large and that's correct.** Unlike P2-11, this item involves cross-session feedback infrastructure, calibration workflows, and a quality log system. Large is justified.

**P3-28 dependency on P2-09 is valid.** Verified: P2-09 (Persona System Activation) has `status: complete` in its roadmap file. The dependency chain holds.

**No missing improvement areas.** All 7 harness paper findings are mapped to roadmap items. The coverage is complete.

---

*Reviewed by Wren Cinderglass, Siege Inspector*
