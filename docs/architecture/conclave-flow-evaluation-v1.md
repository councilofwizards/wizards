---
title: Conclave Flow Evaluation — Council of Wizards v1
status: shipped (4.0.0 — 2026-04-26)
author: Council of Wizards (5 Opus 4.7 evaluators + 1 Opus 4.7 Sentinel)
created: 2026-04-26
updated: 2026-04-26
review_method: parallel-discovery-then-synthesis-then-skeptic
---

> **Shipped 2026-04-26 in conclave 4.0.0.** All approved Council recommendations were implemented. The body of this
> document is preserved as the change-set rationale; cross-reference `CLAUDE.md` "4.0.0 Behavioral Changes" for the
> shipped surface area.

# Council of Wizards: Flow Evaluation — Conclave 3.0.0

> The user's north star is **simple perfection**: an elegant orchestrated flow from idea to monitored value, no obvious
> gaps, empty steps that respond appropriately, easy to use, likely to produce high-quality output.

The Council convened five Opus 4.7 evaluators in parallel — Pathwalker (flow), Voidseer (gaps), Threshold Warden (
empty-state), First Light (UX), Quality Oracle (output quality) — synthesized their findings, then submitted the
synthesis to the Sentinel for adversarial review. **The Sentinel verified the most consequential claims, falsified two,
contested several proposed fixes, and challenged the scope of the largest theme as scope creep.** This document is the
post-Sentinel revision — the version the user should act on.

---

## Headline finding

The realignment that just shipped (3.0.0, commit `b56a72b`) **fixed what was broken; it did not finish what was
incomplete.** The plugin is now coherent, capable, and well-described. It is not yet "simple perfection." The remaining
gap is shallow but real:

- A first-time user hits a half-trigger / half-theme description gauntlet on the very skills they reach for first.
- A returning user cannot resume work without remembering what they were doing — there is no global "what's running"
  surface.
- A power user concurrently working on multiple features hits CONTINUE.md collisions on day one.
- The empty-state behavior of 22 multi-agent skills sorts roughly: 10 close politely, 6 wander, 8 fail silently, 4
  abort/resume without explanation.
- The plugin's quality ceiling on its core engineering pipeline is **70-80%** in the Quality Oracle's estimate — capped
  by Lead-as-Skeptic on plan-product Stages 1-3 (Sonnet self-reviewing Sonnet output × 3 stages compounding) and
  bullet-list producer personas on backend-eng / frontend-eng / software-architect.
- The conclave plans, builds, gates, and reviews — then stops. **The Voidseer wanted to close the post-deploy loop with
  new skills; the Sentinel argued this is scope creep.** The right boundary is "code reviewed and ready to merge";
  release/monitor/incident belong in CI and observability tools the conclave doesn't usefully wrap. The data-model can
  extend to track lifecycle (`live`, `retired` states on roadmap items) without owning the execution.

---

## Verified by the Sentinel

The Sentinel verified six of the most consequential Council claims by reading the actual files:

- **✓ Voidseer**: `roadmap-item.md` template lacks `live` and `retired` states (status enum is exactly
  `draft|reviewed|approved|consumed|in_progress|complete`).
- **✓ Threshold Warden**: `plan-product` and `build-product` route empty-args silently through CONTINUE.md →
  progress-scan → artifact-detection without confirming with the user.
- **✓ First Light**: CONTINUE.md is hard-coded to `docs/CONTINUE.md` in both pipeline skills; concurrent invocation will
  collide.
- **✓ Quality Oracle**: `backend-eng.md` is bullet-list values, structurally weaker than `cartographer.md` (numbered
  procedures, named techniques like Tzerpos & Holt, Henry & Kafura).
- **✓ Quality Oracle**: Lead-as-Skeptic is the documented default for plan-product Stages 1-3; the SCAFFOLD assumption
  is unflipped after the realignment.
- **Partial — Pathwalker's "no skill executes a release"**: `review-quality deploy <feature>` mode runs deploy-readiness
  review (rollback, environment parity, CI/CD pipeline check). It does not _execute_ a release, but it is not a void —
  it's a gate.

The Sentinel falsified or qualified several other claims:

- **Partial — First Light's "6 flagship descriptions lead with fantasy name"**: actual count is 5 (`craft-laravel`,
  `unearth-specification`, `audit-slop`, `profile-competitor`, `create-conclave-team`). `plan-product` and
  `build-product` already lead with team-role ("Invoke the Product Team", "Invoke the Implementation Team"), not fantasy
  nouns. Rewriting them is unnecessary.
- **Partial — Quality Oracle's "run-task has no Interrogator"**: technically true (the `interrogator` persona is
  `create-conclave-team`-only), but `run-task/SKILL.md` Setup Step 4 includes a soft "If the task is unclear, ask the
  user for clarification before proceeding." Not equivalent to the hard 8-question methodology, but not absent.
- **Critical caveat — Quality Oracle's "delete APPROVED_WITH_CAVEATS"**: doing this without replacement breaks the
  Stale-Rejection Rule's escape valve. The fix must include forcing ESCALATE in its place, accepting the cost of more
  user-facing escalations.

---

## The Fix Stack

Five themes. Each theme groups related fixes. **Scopes** at the bottom bundle themes into shippable units.

### Theme A — Lifecycle Closure (in data, not execution)

**Original Voidseer proposal: build 3-4 new skills (`release-feature`, `verify-production`, `analyze-incident`,
`setup-monitoring`).**

**Sentinel verdict: scope creep.** The conclave's natural boundary is "spec → code → review." Release execution belongs
in CI; production verification belongs in observability. The conclave doesn't have the integrations to do these well,
and adding 4 skills opposes "simple perfection." Preserve the _data_ model of the lifecycle without overreaching into
_execution_.

| #   | Change                                                                                                                                                                                                                                    | Status                                                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| A1  | **Add `live` and `retired` states to `roadmap-item.md`** template. Document the convention: roadmap-item moves to `live` when the user manually marks it post-deploy; `retired` when the user removes it from the product. No automation. | **Ship** in Scope 1                                                                                  |
| A2  | Build `release-feature` skill                                                                                                                                                                                                             | **Defer** — belongs in CI                                                                            |
| A3  | Build `verify-production` skill                                                                                                                                                                                                           | **Defer** — belongs in observability                                                                 |
| A4  | Build `analyze-incident` skill                                                                                                                                                                                                            | **Defer** — distinct enough from `squash-bugs` to consider later, but not blocking simple perfection |

### Theme B — The Forward Baton + Threshold Litany

**Pathwalker + Threshold Warden converge.** Two related defects:

1. **Silent baton.** Artifacts carry provenance backward (`source_research`, `source_ideas`, `source_roadmap_item`,
   `source_spec`) but never forward. The user must remember the chain or consult `wizard-guide`.
2. **Inconsistent empty-state.** 6 skills wander; 8 fail silently; 4 abort/resume without explanation.

| #   | Change                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Status              |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| B1  | **Inject a static `next_action` map into every multi-agent skill's Setup section** — derived from artifact type (`research-findings → /conclave:ideate-product`; `product-ideas → /conclave:manage-roadmap ingest`; etc.). The Lead doesn't generate `next_action` from judgment — it pulls from the static map. _(Sentinel-revised — original proposal relied on Lead populating a frontmatter field, same producer-reliability gap it was supposed to fix.)_ | **Ship** in Scope 1 |
| B2  | Every Lead's final report ends with `Next: /conclave:{skill} {arg}` (or `Pipeline complete. The road ends here.` for terminal stages). Map values from B1.                                                                                                                                                                                                                                                                                                     | **Ship** in Scope 1 |
| B3  | **Add Threshold Check section to `orchestrator-preamble.md`** (Threshold Warden's Litany). Default action on user silence is **proceed**, not abort. _(Sentinel-revised — abort-on-silence introduced a new failure mode for AFK users and CI invocations.)_ Format: `[skill] — Threshold Check / Mode resolved / Checkpoints found / Required input / Decision`. User can interrupt at any time. Add a `--confirm` flag for users who want a hard pause.      | **Ship** in Scope 1 |
| B4  | Patch the 6 wandering skills (`research-market`, `ideate-product`, `manage-roadmap`, `plan-sales`, `plan-hiring`, `draft-investor-update`) to print the Threshold Check before falling through to "general" mode.                                                                                                                                                                                                                                              | **Ship** in Scope 1 |
| B5  | Patch the 8 silent-skip skills (`plan-product`, `build-product`, `write-spec`, `write-stories`, `plan-implementation`, `build-implementation`, `review-quality`) to print the Threshold Check before spawning their team.                                                                                                                                                                                                                                      | **Ship** in Scope 1 |
| B6  | Adopt `profile-competitor`'s freshness-window pattern (`--refresh-after Nd`) on `research-market` and `ideate-product`. **Specify**: refresh applies to Stage 1 artifact only; downstream stages re-evaluate against the refreshed input but reuse approved artifacts where input is unchanged. _(Sentinel-revised — original was ambiguous about cascade.)_                                                                                                   | **Ship** in Scope 1 |

### Theme C — Concurrent Work + Project State

**First Light + Sentinel converge.** Three defects, two of them with new dimensions the Sentinel surfaced.

| #   | Change                                                                                                                                                                                                                                                                                                           | Status                  |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| C1  | **Per-feature CONTINUE.md scoping**: `docs/continues/{feature}.md` with `docs/continues/_index.md` as the registry. _(Sentinel-added — also archive completed/abandoned ones to `docs/continues/_archive/{date}-{feature}.md`. The dominant collision case is temporal abandonment, not concurrent invocation.)_ | **Ship** in Scope 1     |
| C2  | **New `/wizard-guide status` mode** — single-agent skill scans `docs/progress/` and `docs/continues/` and reports all active and recently-abandoned work in a one-screen summary. _(Sentinel-revised — original proposed a new skill; reusing `wizard-guide` keeps the catalog small.)_                          | **Ship** in Scope 1     |
| C3  | **Extend `run_id` from 4 to 8 hex characters** in all spawn prompts. _(Sentinel-added — Birthday-paradox collision risk on 4-char IDs in heavy-use projects; 8 chars = 4.3B possibilities.)_                                                                                                                     | **Ship** in Scope 1     |
| C4  | Document TeamCreate session-state constraints in `wizard-guide`: cross-team SendMessage behavior, when to use TeamDelete, how `team_name` collisions resolve. _(Sentinel-added.)_                                                                                                                                | **Ship** in Scope 1     |
| C5  | CONTINUE.md exists for only 2 of 25 skills today. Decision: keep it pipeline-only and document the boundary explicitly. **Don't expand it to all skills** — explicit boundary is better than unfinished expansion.                                                                                               | **Document** in Scope 1 |

### Theme D — Producer Rigor + Skeptic Calibration

**Quality Oracle's core finding.** Skeptic infrastructure is rigorous; producer personas are bullet-list values.
Backwards for quality. **Sentinel split this theme into two sub-scopes** — D1/D2/D5 are pure improvements; D3/D4/D6 are
user-facing behavioral changes that deserve separate decisions.

#### Sub-theme D-pure (no behavioral tradeoffs)

| #   | Change                                                                                                                                                                                                                                                                                                                                         | Status              |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| D1  | **Promote producer personas to methodology-rich.** `backend-eng`, `frontend-eng`, `software-architect` (the one in plan-product), `implementer` (in craft-laravel). Add 2-4 named methodologies with concrete procedures, output formats, verification steps. Pattern: model on `cartographer.md`, `logic-excavator.md`, or `cartomarshal.md`. | **Ship** in Scope 2 |
| D2  | **Generalize Interrogator pattern (Iron Law #05) to `run-task`.** Phase 0.5 between intake and team composition. _(Sentinel-noted — `run-task` already has a soft "ask if unclear" check; this is a hardening to the 8-question methodology, not creation of a missing check.)_                                                                | **Ship** in Scope 2 |
| D5  | **Strengthen Verification micro-step.** Currently verifies frontmatter only. Add: Lead spot-checks 1 randomly-selected substantive section against the spec acceptance criteria. If fails, status reverts to `reviewed` and producer iterates.                                                                                                 | **Ship** in Scope 2 |

#### Sub-theme D-tradeoffs (each is a separate user decision)

| #   | Change                                                                                                                                                                                                                              | Tradeoff                                                         | Recommendation                                                                                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| D3  | **Make `--full` the default for `plan-product`** (dedicated skeptic for all 5 stages, not just 4-5).                                                                                                                                | +Quality on Stages 1-3 / +Cost (5 stages of Opus skepticism)     | **Ship** if cost-per-invocation isn't a concern; **Defer** if it is. The user should choose explicitly. |
| D4  | **Eliminate `APPROVED_WITH_CAVEATS` verdict** AND simultaneously remove the Stale-Rejection Rule's "Accept with caveats" branch. Force ESCALATE.                                                                                    | +Rigor / +User interrupts (more escalation requests)             | **Ship** if the user prefers fewer-but-cleaner gates over more-but-quieter ones.                        |
| D6  | **Make "Humans Validate Tests" an actual blocking gate** on `build-implementation` only (NOT `build-product`). _(Sentinel-revised — `build-product` is a 3-stage pipeline; a synchronous human gate mid-pipeline is catastrophic.)_ | +Iron Law #14 honesty / -User must be present at test-write step | **Ship** with the Sentinel's scope correction (build-implementation only).                              |

### Theme E — UX Polish (last mile)

| #   | Change                                                                                                                                                                                                                                                                                          | Status              |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| E1  | **Rewrite 5 flagship skill descriptions** to lead with trigger: `craft-laravel`, `unearth-specification`, `audit-slop`, `profile-competitor`, `create-conclave-team`. _(Sentinel-revised — count is 5, not 6. `plan-product` and `build-product` already lead with team-role; do not rewrite.)_ | **Ship** in Scope 1 |
| E2  | **Delete `tier1-test`.** Q5 of the realignment was "delete"; never honored. Still appears in slash-pickers despite `category: internal`.                                                                                                                                                        | **Ship** in Scope 1 |
| E3  | **Standardize argument-grammar across all 25 skills.** Six different "(empty for X)" phrasings exist. Apply the unified grammar from `shared/argument-grammar.md` (which itself needs to be authored — was named in the realignment doc but doesn't exist).                                     | **Ship** in Scope 1 |
| E4  | **Lengthen `plugin.json` description** so the bootstrap hint survives narrow slash-pickers. Current sentence has the critical instruction at character ~63; pickers truncate before that.                                                                                                       | **Ship** in Scope 1 |
| E5a | Replace `roadmap-item` template's `category` enum (currently the conclave-plugin's own categories) with project-agnostic open string + comment.                                                                                                                                                 | **Ship** in Scope 1 |
| E5b | Move technical-spec template from `docs/specs/_template.md` to `docs/templates/artifacts/technical-spec.md` to live with siblings.                                                                                                                                                              | **Ship** in Scope 1 |
| E5c | Either rename `sprint-contract` signed-state from `approved` to `signed`, or document the divergence loudly in the template comment.                                                                                                                                                            | **Ship** in Scope 1 |

---

## Scopes (the user's decision tree)

### Scope 1 — "Finish what the realignment started" (~7 hours)

Themes B, C, E, plus A1 (lifecycle states) and the Sentinel-added items C3 (8-char run_id) and C4 (team-state docs).

**No new skills. No producer-methodology changes. No behavioral defaults flipped.** Plugin becomes consistent and easy
to navigate. The deeper quality and lifecycle gaps remain.

**Ship this immediately.** It's polish on already-shipped work and removes the friction the Council called out. Nothing
in Scope 1 changes any agent's behavioral defaults.

### Scope 2a — "Producer rigor + run-task hardening" (~6 hours additional)

Theme D-pure (D1, D2, D5). Promote producer personas to methodology-rich; generalize Interrogator to run-task; deepen
the verification micro-step.

**Pure improvement.** No tradeoffs. Producer personas catch up to skeptic personas; vague invocations get harder;
verification verifies content not just frontmatter.

**Ship this after Scope 1.** Improves the quality ceiling without changing user-facing defaults.

### Scope 2b — "Behavioral defaults" (~3 hours additional, 3 separate decisions)

Theme D-tradeoffs (D3, D4, D6). Each is a separate yes/no:

- D3: `--full` becomes default for plan-product? (Quality vs cost)
- D4: Eliminate `APPROVED_WITH_CAVEATS`? (Rigor vs interrupt frequency)
- D6: Humans-Validate-Tests as blocking gate on `build-implementation`? (Honesty vs synchronous user presence)

The user picks zero, one, two, or all three. Each ships independently.

### Scope 3 — DECLINED

Original proposal: 3-4 new skills for release / verification / monitoring / incident analysis. **Sentinel verdict: scope
creep.** The conclave doesn't have the CI/observability integrations to do these well, and the additions oppose "simple
perfection." A1 (lifecycle states in `roadmap-item.md`) is the only piece worth keeping; it ships in Scope 1.

If the user disagrees with the Sentinel's scope verdict and wants to build these skills anyway, they should ship after
Scopes 1 and 2 — the new skills inherit Scope 1's flow patterns and Scope 2's quality patterns.

---

## Open questions for the user

| #   | Question                                                               | Council recommendation                                                                                                                               |
| --- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Q1  | Ship Scope 1 immediately?                                              | **Yes.** Pure polish; no behavioral tradeoffs.                                                                                                       |
| Q2  | Ship Scope 2a after Scope 1?                                           | **Yes.** Pure improvement; no behavioral tradeoffs.                                                                                                  |
| Q3  | D3 — make `--full` the default for plan-product?                       | **Yes if cost-tolerant**; the single biggest quality lever.                                                                                          |
| Q4  | D4 — eliminate `APPROVED_WITH_CAVEATS`?                                | **Yes**, accepting more user-facing escalations. The "with caveats" verdict has been the pressure-release valve that propagates weakness downstream. |
| Q5  | D6 — Humans-Validate-Tests as blocking gate on `build-implementation`? | **Yes**, restricted to `build-implementation` (Sentinel correction — never on `build-product`).                                                      |
| Q6  | Scope 3 — build the 4 lifecycle skills?                                | **No** (Sentinel verdict). The conclave's boundary is "code reviewed and ready to merge."                                                            |
| Q7  | Reverse Q6 if the user disagrees?                                      | If yes, ship after Scope 2 — new skills inherit improved patterns.                                                                                   |

---

## What the Council does NOT recommend changing

To prevent re-litigating settled decisions:

- **Lore preamble in `wizard-guide`**: keep. First Light verified it's terse, opt-in, and earns its place.
- **Persona names in agent signoffs**: keep. Tier 2.5 of the realignment got the register right.
- **Variant-files override pattern**: keep. Settled by Q4 of the realignment doc.
- **CONTINUE.md as a pipeline-only protocol**: keep. Don't expand to all 25 skills; document the boundary instead.
- **Six review/audit skills coexisting**: keep. The disambiguation table in `wizard-guide` handles this well per First
  Light's review.
- **`plan-product` / `build-product` skill descriptions**: keep. Sentinel verified they already lead with team-role, not
  fantasy theme. Do not rewrite.
- **`run-task` continuing to exist**: keep. With D2 hardening, it becomes a viable safe harbor for ad-hoc work.

---

## Methodology

5 Opus 4.7 evaluators ran in parallel. Each had a focused brief and a ≤1800-word report cap. Their reports were
synthesized into a draft change set. The draft was submitted to a 6th Opus 4.7 reviewer (Sentinel) with adversarial
framing: verify claims, contest fixes, identify missing dimensions, render verdict on the proposed scopes. The Sentinel
verified 6 claims, falsified 2, contested 8 fixes, surfaced 4 missing dimensions, and downgraded one entire theme as
scope creep. The post-Sentinel revisions are reflected throughout this document.

This is the document the user should act on.
