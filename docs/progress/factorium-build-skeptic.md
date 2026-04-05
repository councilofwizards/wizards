# Factorium Build — Skeptic Review

**Reviewer:** Skeptic **Date:** 2026-04-05 **Scope:** All 8 deliverables from the Factorium build task

---

## REVIEW: docs/factorium/iron-laws.md

**Verdict: APPROVED**

Notes:

- All 16 laws present, matching the summary in FACTORIUM.md Section II exactly.
- Each law follows the pattern: Statement, Why it exists, In practice. Consistent and well-structured.
- Factorium-specific examples are woven into each law's "In practice" section, grounding abstract principles in concrete
  pipeline behavior.
- No loop logic. No stateless concerns (documentation file).

---

## REVIEW: docs/factorium/evaluation-framework.md

**Verdict: APPROVED**

Notes:

- Six rubric dimensions match FACTORIUM.md's evaluation framework table exactly.
- Go/no-go decision tree is complete: Go (>=3.5, no 1s, Adversary approves), Conditional Go (>=3.0, 2s present), No-Go
  (<3.0 or any 1 or veto).
- Three worked examples (keyboard shortcuts, query caching, collaborative editing) demonstrate all decision paths
  including the "any dimension scores 1 overrides average" rule.
- Edge cases section covers: uneven scorer, flat scorer, AG veto, duplicate detection — all handled correctly.
- The "Conditional Go" section has good vs. bad condition examples, enforcing specificity over vagueness.

---

## REVIEW: plugins/factorium/skills/necromancer/SKILL.md

**Verdict: APPROVED**

Notes:

- Single-agent type, matching FACTORIUM.md Stage 7 (manual invocation, Lazarus Fell works alone).
- Frontmatter complete: name, description, argument-hint, type (single-agent), category, tags.
- Setup correctly references FACTORIUM.md, github-conventions.md, and evaluation-framework.md (the Assayer's rubric is
  reused for re-scoring).
- Stateless constraint explicit: "One-pass, one-exit. This skill executes once and exits. It does not poll. It does not
  sleep. It does not loop."
- Revival gate is correctly dual-gated: requires BOTH passing rubric score AND expired rejection rationale. Neither
  alone is sufficient.
- State machine matches FACTORIUM.md: READ_GRAVEYARD -> IDENTIFY_CANDIDATES -> REASSESS_EACH -> {REVIVE | CONFIRM_DEAD}.
- Label transitions correct: graveyard -> assayer on revival, no label change on confirmed dead.
- Character voice and backstory are excellent and consistent with FACTORIUM.md's description.
- No files written to disk — GitHub Issues only, matching the Dreamer's pattern.

---

## REVIEW: plugins/factorium/skills/assayer/SKILL.md

**Verdict: REJECTED**

Blocking Issues:

1. **Missing evaluation-framework.md reference in Setup.** The Setup section reads FACTORIUM.md, github-conventions.md,
   CLAUDE.md, and iron-laws.md — but does NOT read `docs/factorium/evaluation-framework.md`. This is the authoritative,
   detailed reference for the scoring rubric the Assayer applies, including edge case handling (uneven scorer, flat
   scorer, AG veto, duplicate detection), scoring guidance per dimension, and the full go/no-go decision tree. The
   necromancer correctly references it. The assayer — the primary consumer of this document — must read it. The team
   lead needs the edge case guidance to handle non-obvious scoring scenarios. Add to Setup:
   `5. Read docs/factorium/evaluation-framework.md — the detailed scoring rubric, edge cases, and go/no-go decision tree.`

Non-blocking notes:

- Team composition matches FACTORIUM.md Stage 2: Market Scout, Feasibility Assessor, Value Appraiser, Cost Estimator,
  Adversary (Assayer General).
- Iron Law 01 correctly implemented: Phase 3 strips rationales, Adversary prompt confirms stripped input.
- Stateless constraint explicit in Constraints section.
- State machine matches: CLAIM -> RESEARCH -> EVALUATE -> ADVERSARIAL_REVIEW -> DECIDE -> {ADVANCE | REJECT | REQUEUE}.
- Label transitions correct for all three outcomes (Go, No-Go, Requeue).
- User Value is scored by both Market Scout and Value Appraiser, with the lower score taken (conservative default) —
  correct.

---

## REVIEW: plugins/factorium/skills/planner/SKILL.md

**Verdict: APPROVED**

Notes:

- Team composition matches FACTORIUM.md Stage 3: Requirements Architect, Story Weaver, Metrics Smith, Edge Case Hunter,
  Adversary (Skeptic of Scope).
- All five agents are gnomish-themed (planners/scribes), matching the fantasy theming guide.
- State machine matches: CLAIM -> ANALYZE -> SPECIFY -> ADVERSARIAL_REVIEW -> {ADVANCE | REQUEUE}.
- Orchestration is correctly sequenced: Requirements first (Caelen), then Stories (Mira depends on requirements), then
  Metrics + Edge Cases in parallel, then Adversary.
- Iron Law 01 correctly implemented in Phase 3.
- Iron Law 02 (halt on ambiguity) explicitly called out in Constraints.
- Four output documents match FACTORIUM.md: product-requirements.md, product-stories.md, product-metrics.md,
  product-edge-cases.md.
- Label transitions correct: factorium:planner -> factorium:architect on advance, factorium:assayer on requeue.
- Requeue commits WIP work to git before transitioning — preserves work per FACTORIUM.md principle.
- Stateless constraint explicit in Constraints section.

---

## REVIEW: plugins/factorium/skills/architect/SKILL.md

**Verdict: APPROVED**

Notes:

- Team composition matches FACTORIUM.md Stage 4: System Designer, Schema Artisan, Contract Keeper, Security Warden,
  Shard Master, Adversary (Stress Tester). Six agents — largest team, correctly reflecting the scope.
- Orchestration correctly phased: parallel design (3 agents) -> security review -> decomposition -> adversary. Security
  Warden reads all three design docs before producing threat model. Shard Master reads all four before producing
  workplan. Correct dependency ordering.
- Iron Law 01 correctly implemented in Phase 5.
- Iron Law 16 (human is the architect) correctly flagged in System Designer prompt, Stress Tester prompt, and
  Constraints section.
- Iron Law 08 (every action reversible) correctly referenced in Schema Artisan prompt for migration rollbacks.
- Five output documents match FACTORIUM.md: architecture-design.md, architecture-schema.md, architecture-contracts.md,
  architecture-security.md, architecture-workplan.md.
- Branch creation is idempotent (checks if branch exists first) — correct.
- Branch created from main — correct per FACTORIUM.md git branching strategy.
- Label transitions correct: factorium:architect -> factorium:engineer on advance, with requeue paths to both planner
  and assayer.
- Stateless constraint explicit in Constraints section.
- Fantasy theming: dwarven masters and warforged planners — matches FACTORIUM.md.

---

## REVIEW: plugins/factorium/skills/engineer/SKILL.md

**Verdict: REJECTED**

Blocking Issues:

1. **Wrong path for iron-laws.md.** Setup step 4 says `Read docs/iron-laws.md if it exists`. The correct path is
   `docs/factorium/iron-laws.md`. The Security Auditor spawn prompt also references `docs/iron-laws.md`. Both are wrong.
   The agent will look for the file at the wrong path, not find it, and fall back to the FACTORIUM.md summary — losing
   the detailed guidance. Fix both references.

2. **Missing `## Constraints` section.** Every other skill (dreamer, necromancer, assayer, planner, architect) has an
   explicit Constraints section documenting the stateless/single-execution guarantee and other operational boundaries.
   The engineer skill has no such section. While the flow is clearly single-execution, the explicit contract is
   important for consistency and for the external harness to verify. Add a Constraints section matching the pattern of
   the other skills (stateless, no rationales to adversary, append only, correct stage label required, escalate on
   stalemate).

Non-blocking notes:

- Team composition matches FACTORIUM.md Stage 5: Lead Engineer, Implementors (1-N), Test Smith, Security Auditor,
  Adversary (Gatekeeper).
- Dynamic Implementor count (1 per work unit, max 4) is a good design choice.
- TDD protocol (Red/Green/Refactor) correctly specified in Implementor prompt.
- Iron Law 01 correctly implemented in Phase 4 (Gatekeeper receives stripped work).
- Iron Law 14 correctly implemented: Test Smith notifies human via Forge Lead for critical-path test validation.
- Automated gates (unit tests, feature tests, linter, type checker, static analysis) match FACTORIUM.md.
- PR template is well-structured with issue reference, implementation notes, test coverage, and gate results.
- State machine matches: CLAIM -> REVIEW_SPECS -> IMPLEMENT -> TEST -> ADVERSARIAL_REVIEW -> GATES -> {ADVANCE |
  REQUEUE}.
- Category is `engineering` while assayer/planner/architect use `pipeline` — minor inconsistency but not blocking.
- Fantasy theming excellent: warforged lead, gnomish tinkers, goblin tester — matches FACTORIUM.md.

---

## REVIEW: plugins/factorium/skills/gremlin/SKILL.md

**Verdict: REJECTED**

Blocking Issues:

1. **Wrong path for iron-laws.md.** Setup step 4 says `Read docs/iron-laws.md if it exists`. The correct path is
   `docs/factorium/iron-laws.md`. Same issue as engineer skill. Fix.

2. **Missing `## Constraints` section.** Same issue as engineer skill. Every other skill has an explicit Constraints
   section. The gremlin needs one too, documenting: stateless, no rationales to adversary, correct stage label required,
   escalate on stalemate after 3 cycles.

Non-blocking notes:

- Team composition matches FACTORIUM.md Stage 6: Inspector General, Chaos Gremlin, Standards Auditor, Adversary (The
  Final Word).
- Both review modes (Pipeline and On-Demand) correctly implemented, matching FACTORIUM.md exactly.
- On-demand mode correctly parses the review request comment for routing (ON_PASS, ON_FAIL).
- Iron Law 01 correctly implemented: each Gremlin prompt says "Do NOT include your reasoning or rationale," and Phase 2
  strips rationales before submitting to Final Word.
- Pipeline approval correctly: factorium:complete + status:passed, PR approval via `gh pr review --approve`.
- Pipeline rejection correctly determines requeue target based on finding category (spec compliance -> engineer,
  architectural gaps -> architect, requirements misunderstood -> planner).
- On-demand routing follows the review request comment's ON_PASS/ON_FAIL directives.
- Gremlins are isolated during Phase 1 (no collaboration during audit) — prevents anchoring bias. Good.
- Category is `engineering` — same minor inconsistency as engineer skill.
- Fantasy theming: homunculus inspector, gremlin chaos engineer, goblin auditor — exactly matches FACTORIUM.md's
  creature types.

---

## OVERALL VERDICT: REJECTED

**Blocking: 3 files need fixes**

- `plugins/factorium/skills/assayer/SKILL.md` — missing evaluation-framework.md reference in Setup
- `plugins/factorium/skills/engineer/SKILL.md` — wrong iron-laws.md path (2 locations) + missing Constraints section
- `plugins/factorium/skills/gremlin/SKILL.md` — wrong iron-laws.md path + missing Constraints section

**Approved: 5 files pass**

- `docs/factorium/iron-laws.md`
- `docs/factorium/evaluation-framework.md`
- `plugins/factorium/skills/necromancer/SKILL.md`
- `plugins/factorium/skills/planner/SKILL.md`
- `plugins/factorium/skills/architect/SKILL.md`

**Summary of fixes required:**

1. Assayer Setup: add `5. Read docs/factorium/evaluation-framework.md` line
2. Engineer Setup step 4: change `docs/iron-laws.md` to `docs/factorium/iron-laws.md`
3. Engineer Security Auditor spawn prompt: change `docs/iron-laws.md` to `docs/factorium/iron-laws.md`
4. Engineer: add `## Constraints` section
5. Gremlin Setup step 4: change `docs/iron-laws.md` to `docs/factorium/iron-laws.md`
6. Gremlin: add `## Constraints` section

All fixes are surgical — no structural or design changes needed. The architecture, team compositions, state machines,
Iron Law compliance, and fantasy theming are solid across all 8 deliverables.
