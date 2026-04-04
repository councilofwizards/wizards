---
skill: plan-product
topic: session-recovery-continue-md
agent: analyst
role: Caelen Greymark — Cartographer of the Path Forward
status: complete
updated: 2026-04-03
---

# ROADMAP ANALYSIS: session-recovery-continue-md

## New Items Proposed

- **P2-14**: CONTINUE.md Disaster Recovery Protocol
  - Category: `quality-reliability`
  - Effort: Small-Medium
  - Status: not_started
  - Combines Ideas 1 + 5 + 4 into a single deliverable

---

## Dependency Analysis

### What this item depends on (all satisfied)

| Dependency | Item                                 | Status      | Why Required                                                                                                                                                                                                                                |
| ---------- | ------------------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| P1-02      | State Persistence & Checkpoints      | ✅ complete | Provides per-agent checkpoint files that CONTINUE.md indexes. Without the checkpoint format, the Materialized View (Idea 5) has nothing to aggregate.                                                                                       |
| P2-03      | Progress Observability               | ✅ complete | Established docs/progress/ file conventions and session summary pattern. CONTINUE.md is the aggregation layer above this infrastructure.                                                                                                    |
| P3-30      | Checkpoint Frequency Configurability | ✅ complete | Defines checkpoint frequency modes (every-step, milestones-only, final-only). CONTINUE.md update cadence must align with checkpoint-frequency setting — if Team Lead only updates at stage gates, that must mesh with milestones-only mode. |

**Zero blocking dependencies. All three prerequisites are complete.**

### What might depend on this item (future)

| Future Item                                              | Type             | Why                                                                                                                                                             |
| -------------------------------------------------------- | ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Idea 6 (Shared Content Template, DEFERRED)               | Design evolution | Extracting CONTINUE.md schema into shared/ content is premature until the protocol is battle-tested. This item is the prerequisite for that eventual migration. |
| Any automated re-invocation / "resume assistant" tooling | Hypothetical     | A future skill that reads CONTINUE.md and auto-reconstructs pipeline state would consume the YAML frontmatter and Saga Stage Map defined here.                  |
| LangGraph-style telemetry / run analytics                | Hypothetical     | The heartbeat field and run_id provide anchors for future session analytics. No current roadmap item proposes this, but the data would be available.            |

---

## Conflicts

**No blocking conflicts found.**

### P2-03 (Progress Observability) — Complementary, not conflicting

P2-03 defines per-agent progress files and end-of-session summaries. CONTINUE.md sits above that layer as the Team
Lead's aggregation index. The scope boundary is clear: per-agent checkpoints are ground truth (P2-03), CONTINUE.md is
the index + mission brief (this item). The only overlap is conceptual — both involve `docs/progress/` — but they operate
at different levels of abstraction with no write conflicts.

### P3-30 (Checkpoint Frequency Configurability) — Complementary, not conflicting

P3-30 controls agent checkpoint frequency; this item controls Team Lead CONTINUE.md update frequency. Different writers,
different files. Update cadence instructions in SKILL.md should reference the checkpoint-frequency mode to stay coherent
— a minor integration note, not a conflict.

### P1-02 (State Persistence) — Extends, not replaces

This item extends P1-02 infrastructure. The per-agent checkpoint format is unchanged. CONTINUE.md is additive.

---

## Recommended Priority: **P2**

### Scoring (roadmap framework)

| Factor       | Weight | Score                                                                                                                                                                                    | Weighted  |
| ------------ | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| Impact       | 40%    | High — directly affects every pipeline skill session; addresses P1-CRITICAL (exact resume command) and 6 additional pain points                                                          | 0.40      |
| Risk         | 30%    | High — without this, a session crash during a 5-stage, 9-agent plan-product run loses all orchestration context: which stage was PARTIAL, which agents completed, what flags were passed | 0.30      |
| Effort       | 20%    | Small-Medium — SKILL.md edits + CONTINUE.md schema definition; no new tooling, no validators, no runtime changes                                                                         | ~0.15     |
| Dependencies | 10%    | Unblocked — all three prerequisites complete                                                                                                                                             | 0.10      |
| **Total**    |        |                                                                                                                                                                                          | **~0.95** |

### Rationale for P2 over P3

P3 is "polish, convenience, or future-facing." This item prevents **catastrophic data loss** on the primary user
workflow — a solo developer running a multi-hour pipeline skill. The difference between P2 and P3 is whether the absence
of the feature causes real harm. It does: without CONTINUE.md, a crash forces a full restart, discarding hours of
accumulated work. That is P2-tier risk, not P3.

All existing P2 items are complete, making this a natural extension of the P2 batch rather than backlog pressure.

---

## Effort/Impact Assessment by Component

### Idea 1 — Mission Brief (Fixed-Schema CONTINUE.md)

- **Effort**: Small
- **Impact**: High
- **Details**: YAML frontmatter (skill, topic, run_id, stage, status, flags, heartbeat). Four mandatory sections.
  Mandated update frequency in SKILL.md Checkpoint Protocol. Covers P1-CRITICAL and P2-HIGH, P6-MEDIUM pain points. This
  is the foundational layer — highest ROI of the three.
- **Implementation**: Two SKILL.md edits (plan-product, build-product) + CONTINUE.md schema doc. Existing
  docs/CONTINUE.md validates the structure works; gap is frequency, not format.

### Idea 5 — Materialized Checkpoint View

- **Effort**: Small
- **Impact**: Medium
- **Details**: CONTINUE.md always lists checkpoint file paths with exact frontmatter status values. Covers P3-HIGH
  (parallel agent status) and P4-HIGH (checkpoint filenames). Minimal incremental work once Idea 1's schema is in place
  — a table appended to the CONTINUE.md template.
- **Implementation**: Add checkpoint index section to CONTINUE.md template. Team Lead updates it when writing the
  materialized view at each stage gate.

### Idea 4 — Saga Stage Map (Idempotent Recovery Gates)

- **Effort**: Medium
- **Impact**: High
- **Details**: Stage Map table in CONTINUE.md with COMPLETE/PARTIAL/PENDING statuses and compensating actions per stage.
  Only PURSUE-tier idea covering P5 (mid-skeptic crash). Extends existing artifact detection logic with explicit PARTIAL
  semantics.
- **Implementation**: SKILL.md must define the Stage Map table format + instruct Team Lead on PARTIAL vs PENDING
  distinction. More prose than Ideas 1+5 but still no new tooling.

---

## Roadmap Placement

**Recommended item**: **P2-14 — CONTINUE.md Disaster Recovery Protocol**

```
Category: quality-reliability
Priority: P2
Effort: Small-Medium
Impact: High
Dependencies: P1-02 (complete), P2-03 (complete), P3-30 (complete)
Status: not_started
```

Placement rationale:

- Category `quality-reliability` over `core-framework`: This is resilience and crash recovery, not changes to the
  orchestration engine itself. The framework (checkpoint files, artifact detection) already exists; this item adds the
  human-readable aggregation layer.
- Category `quality-reliability` over `developer-experience`: DX items are about installation, configuration, and
  ergonomics. Session crash recovery is a reliability concern.
- Number P2-14: Follows naturally from P2-13 (last complete P2 item). Preserves P2 sequence for an item with P2-tier
  risk profile.

---

## Implementation Phasing

**Recommendation: Ship all three ideas together in a single implementation.**

### Rationale against phasing

1. **Effort is small-medium bundled.** Ideas 1+5+4 together require 2 SKILL.md edits and a CONTINUE.md schema document.
   The marginal cost of including Idea 4 while already editing the same SKILL.md files is low.

2. **Idea 1 alone creates an incomplete protocol.** Without Idea 5, CONTINUE.md doesn't surface checkpoint file paths
   (P4-HIGH unresolved). Without Idea 4, PARTIAL stage crashes leave the operator guessing how to recover (P5-MEDIUM
   unresolved). Shipping Idea 1 alone creates false confidence — users will trust CONTINUE.md before it fully covers the
   failure modes.

3. **All changes are in SKILL.md (no runtime risk).** The usual phasing argument is risk management — ship incrementally
   to isolate failures. Here there's no runtime, no build pipeline, no deployment. SKILL.md edits are safe to bundle.

4. **Ideas 1 + 5 were already evaluated as a portfolio.** The evaluation explicitly confirmed Ideas 1 + 5 + 4 cover all
   7 pain points with no new tooling. Phasing dismantles a validated portfolio.

### If phasing is required (e.g., timeline pressure)

| Phase   | Ideas                                               | Pain Points Covered | Gaps                                            |
| ------- | --------------------------------------------------- | ------------------- | ----------------------------------------------- |
| Phase 1 | Idea 1 (Mission Brief) + Idea 5 (Materialized View) | P1, P2, P3, P4, P6  | P5 (mid-skeptic crash), P7 (artifact integrity) |
| Phase 2 | Idea 4 (Saga Stage Map)                             | P5, P7              | None                                            |

Phase 1 delivers highest-ROI items covering 5/7 pain points. Phase 2 adds the Saga pattern for edge cases. Only pursue
this split if effort constraints are real — the bundled approach is strongly preferred.
