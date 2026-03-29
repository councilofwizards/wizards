---
feature: "review-cycle-6"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action:
  "Completed RC6 research: P3-10 implementation lessons extracted, P2 readiness assessed, action sequence recommended"
updated: "2026-02-19"
---

# Review Cycle 6 — Researcher Findings

## 1. P3-10 Implementation Lessons (for P3-14 spec)

### 1a. 55KB SKILL.md Size

**Fact**: plan-sales SKILL.md is 1182 lines / 55KB — the largest skill file in the framework. The next largest is
draft-investor-update at 737 lines. The average for other skills is ~420 lines.

**Finding**: The size itself is not a problem, but it exposed a latent bug in `skill-structure.sh` where `printf | grep`
truncated output on files >30KB. This was fixed (direct `grep` on file). **Confidence: HIGH** — the fix is trivial and
validated.

**Lesson for P3-14**: Structured Debate will likely produce a similarly large SKILL.md (6+ agents, multi-phase
orchestration). The validator is now fixed, but spec authors should be aware that the Structured Debate pattern may
produce the largest SKILL.md yet due to the cross-examination phase requiring explicit orchestration. No blocker — just
awareness.

### 1b. Lead-Driven Synthesis (Phase 3 Breaking Delegate Mode)

**Fact**: plan-sales Phase 3 explicitly has the Team Lead write the synthesis directly, departing from the delegate mode
used in all other skills.

**Finding**: This worked. The implementation summary confirms all 14 success criteria were met and CI passes.
**Confidence: HIGH** — validated by implementation.

**Lesson for P3-14**: Structured Debate also needs a neutral synthesizer after the cross-examination phase. The
plan-sales precedent confirms that lead-driven synthesis is viable. However, Structured Debate has a key difference: the
synthesis must integrate opposing positions, not parallel research. The spec should be explicit about whether the lead
synthesizes or whether a dedicated "mediator" agent does. Recommendation: follow the plan-sales precedent (lead
synthesizes) unless there is a strong reason for a separate agent.

### 1c. Dual-Skeptic Pattern

**Fact**: plan-sales used Accuracy Skeptic + Strategy Skeptic. The `skill-shared-content.sh` validator was updated to
recognize `strategy-skeptic` / `Strategy Skeptic`.

**Finding**: The dual-skeptic pattern itself worked without issues. The only friction was the validator needing to be
updated for the new skeptic name — a one-time mechanical fix. **Confidence: HIGH**.

**Lesson for P3-14**: plan-hiring is assigned Bias Skeptic + Fit Skeptic per the business-skill-design-guidelines. The
validator will need both names added to `normalize_skeptic_names()`. This is a known mechanical step, not a risk. The
plan-sales implementation proves the pattern scales.

### 1d. Collaborative Analysis Orchestration Flow vs. Pipeline

**Fact**: Collaborative Analysis (plan-sales) uses 5 phases: independent research → cross-reference → lead synthesis →
skeptic review → finalization. Pipeline (draft-investor-update) uses sequential handoffs with quality gates.

**Finding**: The key difference is that Collaborative Analysis requires explicit peer-to-peer messaging between agents
in Phase 2 (cross-reference). This is what drives the larger SKILL.md — the orchestration instructions for "read other
agents' findings and challenge them" are verbose. Pipeline's sequential handoffs are simpler to specify. **Confidence:
HIGH** — observable from the SKILL.md structure.

**Lesson for P3-14**: Structured Debate will be even more complex than Collaborative Analysis. It requires: (1) assigned
positions, (2) independent case-building, (3) cross-examination (agents directly challenge each other), (4) skeptic
judging, (5) synthesis. The cross-examination phase is structurally similar to Collaborative Analysis's cross-reference
phase but more adversarial. Expect the SKILL.md to be 1000-1400 lines.

### 1e. Surprises and Lessons for Structured Debate Design

1. **Quality-skeptic went idle during post-impl review** (noted in implementation summary). This is a risk for any skill
   with many agents — context limits or timing can cause agents to drop out. The Structured Debate spec should ensure
   the cross-examination phase has explicit fallback instructions if an agent goes idle.

2. **Validator bugs were fixed during implementation, not before**. RC5 recommended fixing CI first, but the
   implementation team bundled the fixes. This worked fine but created a larger PR surface. For P3-14, the
   recommendation is the same: fix any known CI issues before implementation.

3. **No plugin.json modification needed** — skills are auto-discovered. This simplifies implementation for new skills.

## 2. P2-07 Readiness Assessment (Universal Shared Principles)

**Current state**: 6 total skills, 5 multi-agent skills with shared content markers. ADR-002 threshold is 8 skills.

| Metric                                  | Value                                                                              |
| --------------------------------------- | ---------------------------------------------------------------------------------- |
| Total skills                            | 6                                                                                  |
| Multi-agent skills with shared content  | 5 (plan-product, build-product, review-quality, draft-investor-update, plan-sales) |
| Single-agent skills (no shared content) | 1 (setup-project)                                                                  |
| ADR-002 extraction threshold            | 8 skills                                                                           |
| Gap to threshold                        | 2 more multi-agent skills needed                                                   |

**Assessment**: NOT ready to spec. At 5/8, we are still 2 skills short of the ADR-002 threshold. After P3-14
(plan-hiring) is implemented, we will be at 6/8. We should start pre-planning extraction at 7/8 (per RC5 architect
recommendation) and execute at 8/8.

**Confidence: HIGH** — the threshold is explicitly documented in ADR-002.

**Recommendation**: Do not spec P2-07 this cycle. Re-assess at RC7 or when skill count reaches 7.

## 3. P2-08 Readiness Assessment (Plugin Organization)

**Current state**: 2/2 business skills now implemented (draft-investor-update + plan-sales). The prerequisite documented
in the roadmap item is MET.

| Metric                            | Value                                     |
| --------------------------------- | ----------------------------------------- |
| Business skills implemented       | 2 (draft-investor-update, plan-sales)     |
| Prerequisite (2+ business skills) | MET                                       |
| Patterns validated                | 2 of 3 (Pipeline, Collaborative Analysis) |

**Assessment**: The prerequisite is technically met, but I recommend WAITING until Structured Debate is also validated
before speccing P2-08. Rationale: the P2-08 description says "plugin boundaries should be informed by real-world usage
patterns." With only 2 of 3 patterns validated, we do not yet have the full picture of how skills are structured.
Structured Debate may introduce structurally different requirements (e.g., different shared content, different agent
configurations).

**Confidence: MEDIUM** — the prerequisite is met (fact), but the recommendation to wait is judgment-based. A reasonable
counter-argument is that 2 patterns are enough to start planning plugin boundaries.

**Recommendation**: Deprioritize P2-08 this cycle. Revisit after P3-14 is implemented and Structured Debate is
validated.

## 4. Pattern Validation Status (Updated)

| Pattern                | RC5 Status  | RC6 Status    | Pathfinder                           |
| ---------------------- | ----------- | ------------- | ------------------------------------ |
| Pipeline               | VALIDATED   | VALIDATED     | P3-22 (draft-investor-update)        |
| Collaborative Analysis | SPECCED     | **VALIDATED** | P3-10 (plan-sales) — now implemented |
| Structured Debate      | NOT SPECCED | NOT SPECCED   | P3-14 (plan-hiring) — next to spec   |

**Key change since RC5**: Collaborative Analysis is now VALIDATED (was only specced). This is significant — it confirms
the pattern works end-to-end and provides concrete implementation lessons for the remaining pattern (Structured Debate).

## 5. Roadmap Stub Assessment

**Current state**: 14 roadmap stubs are missing (same as RC5). The \_index.md references items that have no
corresponding file:

Missing stubs: P3-04, P3-05, P3-06, P3-07, P3-11, P3-12, P3-14, P3-15, P3-16, P3-17, P3-18, P3-19, P3-20, P3-21

**Assessment**: Creating all 14 stubs in this cycle is feasible — each stub is just frontmatter + a one-line problem
statement. However, this is mechanical work that should not block the P3-14 spec.

**Skeptic condition from RC5**: "Roadmap stubs must be minimal (frontmatter + one-line problem) — NOT pre-specs." This
remains valid.

**Note**: P3-14 (plan-hiring) is one of the missing stubs. It will need a full roadmap file (not just a stub) once the
spec is approved. Creating the stub first, then upgrading it when the spec lands, is the cleanest approach.

**Recommendation**: Create 14 stubs as a parallel workstream. Not a blocker for P3-14 spec.

## 6. P2-08 Prerequisite Status Update

The P2-08 roadmap file (`docs/roadmap/P2-08-plugin-organization.md`) still says "1/2 business skills complete." This
should be updated to reflect 2/2 status. This is a factual correction, not a strategic decision.

## 7. Recommended Action Sequence

Based on all findings:

1. **Spec P3-14 (plan-hiring)** — The skeptic's sequencing condition from RC5 is now MET (P3-10 is implemented).
   Implementation lessons have been extracted (Section 1 above). This is the clear next action.

2. **Create 14 roadmap stubs** — Parallel with P3-14 spec. Mechanical task, low risk.

3. **Update P2-08 prerequisite text** — Minor factual correction (1/2 → 2/2). Can be done during stub creation.

4. **Implement P3-14** — After spec is approved. Will advance P2-07 to 6/8 and validate Structured Debate.

5. **Re-assess P2-07 and P2-08** — In RC7, after P3-14 is implemented.

**Do NOT do this cycle**:

- Spec P2-07 (only at 6/8, threshold is 8)
- Spec P2-08 (wait until P3-14 specced and 3 business skills available to observe)
- Any P2-02 work (external dependency, per RC5 decision to stop reporting)

## 8. Delta Since Review Cycle 5

| Change                           | Detail                                                             |
| -------------------------------- | ------------------------------------------------------------------ |
| P3-10 implemented                | Status: ready → complete. SKILL.md created (1182 lines).           |
| 3 CI bugs fixed                  | skill-structure.sh, roadmap-frontmatter.sh, progress-checkpoint.sh |
| Collaborative Analysis VALIDATED | Was specced-only in RC5                                            |
| P2-08 prerequisite MET           | 2/2 business skills (was 1/2)                                      |
| P2-07 at 6/8                     | 6 total skills, 5 multi-agent with shared content (threshold: 8)   |
| Skeptic sequencing condition MET | P3-10 implemented, P3-14 can now be specced                        |
