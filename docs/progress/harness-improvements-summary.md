---
feature: "harness-design-improvements"
status: "complete"
completed: "2026-03-27"
---

# Harness Design Improvements — Roadmap Planning Summary

## Summary

Analyzed Anthropic's harness design paper for long-running application development against the Conclave plugin
architecture. Identified 9 improvement areas, roadmapped as 3 P2 items and 6 P3 items. Product Skeptic approved with 3
corrections (all applied). Analyst revision added P2-13 (user-writable config convention) and P3-31 (design assumptions
documentation).

## What Was Accomplished

- Fetched and analyzed the Anthropic harness design paper
- Compared paper findings against Conclave's existing architecture (strengths and gaps)
- Incorporated user priorities (QA Agent high, cost tracking excluded, QA separate from code skeptic)
- Incorporated best practices document on skill design patterns
- Spawned Analyst (Caelen Greymark) for dependency/effort/impact analysis
- Spawned Product Skeptic (Wren Cinderglass) for quality gate review
- Applied Skeptic corrections: P2-12 category fix, P2-11 effort downgrade, roadmap state errors
- Wrote 7 roadmap item files and updated \_index.md
- Established `.claude/conclave/` user-writable config convention (scoped in P2-11)

## Roadmap Items Created

| Item                                         | Priority | Category             | Effort | Impact     |
| -------------------------------------------- | -------- | -------------------- | ------ | ---------- |
| P2-11 Sprint Contracts / Definition of Done  | P2       | core-framework       | Medium | High       |
| P2-12 QA Agent for Live Testing              | P2       | quality-reliability  | Large  | High       |
| P2-13 User-Writable Configuration Convention | P2       | core-framework       | Small  | High       |
| P3-26 Configurable Skeptic Iteration Limits  | P3       | core-framework       | Small  | Medium     |
| P3-27 Complexity-Adaptive Pipeline           | P3       | core-framework       | Medium | Medium     |
| P3-28 Lead-as-Skeptic Consistency Fix        | P3       | quality-reliability  | Medium | Medium     |
| P3-29 Evaluator Tuning Mechanism             | P3       | quality-reliability  | Medium | Medium     |
| P3-30 Checkpoint Frequency Configurability   | P3       | developer-experience | Small  | Low        |
| P3-31 Design Assumptions Documentation       | P3       | documentation        | Small  | Low-Medium |

## Wave Sequencing

1. **Wave 1 (current)**: P2-10 (Skill Discoverability)
2. **Wave 2a**: P2-07 (Principles Split) + P2-13 (Config Convention) in parallel
3. **Wave 2b**: P2-11 (Sprint Contracts) — after P2-13 settles the convention
4. **Wave 3**: P2-12 (QA Agent) + P2-08 (Plugin Organization, if ready)
5. **P3 batch**: P3-26/27/28 in any order; P3-27 + P3-28 batched (same files); P3-29 last; P3-31 anytime

## Files Created

- `docs/roadmap/P2-11-sprint-contracts.md`
- `docs/roadmap/P2-12-qa-agent-live-testing.md`
- `docs/roadmap/P3-26-configurable-iteration-limits.md`
- `docs/roadmap/P3-27-complexity-adaptive-pipeline.md`
- `docs/roadmap/P3-28-lead-skeptic-consistency.md`
- `docs/roadmap/P3-29-evaluator-tuning.md`
- `docs/roadmap/P3-30-checkpoint-configurability.md`
- `docs/roadmap/P3-31-design-assumptions-docs.md`
- `docs/roadmap/P2-13-user-writable-config.md`
- `docs/progress/harness-improvements-analyst.md`
- `docs/progress/harness-improvements-product-skeptic.md`
- `docs/progress/harness-improvements-summary.md`

## Files Modified

- `docs/roadmap/_index.md` — Added 7 new items, renumbered rows, updated date

## Verification

- Product Skeptic approved with corrections (all applied)
- Skeptic corrections: P2-12 category core-framework→quality-reliability, P2-11 effort Large→Medium, roadmap state
  errors noted
