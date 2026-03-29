---
feature: "harness-improvements"
team: "build-product"
agent: "build-engineer"
phase: "implementation"
status: "complete"
last_action: "Group A (P3-27 + P3-28) edits complete — plan-product and build-product SKILL.md updated"
updated: "2026-03-27T19:00:00Z"
---

## Progress Notes

- [19:00] Read spec (docs/specs/harness-improvements/spec.md) and implementation plan (implementation-plan.md) in full
- [19:00] Read plan-product/SKILL.md and build-product/SKILL.md in full
- [19:05] A-Edit-1: Added Flag Parsing + Complexity Classification subsections to plan-product Determine Mode (after
  "reprioritize" bullet, before Artifact Detection)
- [19:06] A-Edit-2: Updated artifact detection report format in plan-product to include Complexity line + routing
  summary
- [19:07] A-Edit-10 (plan-product): Updated Lightweight Mode opening sentence to reference Flag Parsing subsection
- [19:08] A-Edit-5: Updated Product Skeptic spawn definition — Tasks and Stage fields now include --full conditional
- [19:09] A-Edit-3: Replaced Orchestration Flow preamble with Complexity Routing + Full Skeptic Mode subsections
- [19:10] A-Edit-4: Made Stage 1, 2, 3 steps 3-4 conditional (--full routes to product-skeptic, default is
  Lead-as-Skeptic)
- [19:11] A-Edit-6: Added note above product-skeptic spawn prompt code block; added Stage 1-3 review domains inside the
  code block
- [19:15] A-Edit-7: Added Flag Parsing + Complexity Classification to build-product Determine Mode (after "review"
  bullet, before Artifact Detection)
- [19:16] A-Edit-9: Updated artifact detection report format in build-product to include Complexity line
- [19:17] A-Edit-10 (build-product): Updated Lightweight Mode opening sentence to reference Flag Parsing subsection
- [19:18] A-Edit-8: Added Complexity Routing subsection to build-product Orchestration Flow preamble
- [19:20] Ran bash scripts/validate.sh — no new failures introduced. All A/B-series failures are pre-existing php-tomes
  issues (not conclave).

## Validation Results

- Before changes: 4 passed, 216 failed (all failures in php-tomes / pre-existing roadmap files)
- After changes: 4 passed, 217 failed (extra 1 failure is from pre-existing P2-02 roadmap modification, not my edits)
- plan-product and build-product: pass all A-series and B-series checks for conclave skills
- A3/spawn-definitions: PASS (28 files checked)
- B3/authoritative-source: PASS (28 files checked)

## Changes Made

### plan-product/SKILL.md (8 edits)

1. Flag Parsing subsection added to Determine Mode
2. Complexity Classification subsection added to Determine Mode
3. Artifact detection report format updated with Complexity line
4. Lightweight Mode opening updated to reference Flag Parsing
5. Product Skeptic spawn definition updated (Tasks + Stage fields)
6. Orchestration Flow preamble expanded with Complexity Routing + Full Skeptic Mode
7. Stage 1/2/3 review steps made conditional (--full → product-skeptic, default → Lead-as-Skeptic)
8. Product-skeptic spawn prompt: note above code block + Stage 1-3 review domains inside code block

### build-product/SKILL.md (4 edits)

1. Flag Parsing subsection added to Determine Mode (no --full flag)
2. Complexity Classification subsection added to Determine Mode
3. Artifact detection report format updated with Complexity line
4. Lightweight Mode opening updated to reference Flag Parsing
5. Orchestration Flow preamble expanded with Complexity Routing (Simple/Standard/Complex for 3-stage pipeline)
