---
feature: "plan-hiring"
team: "plan-product"
agent: "architect"
phase: "design"
status: "awaiting_review"
last_action:
  "Revised system design per skeptic review: added Researcher, 3-message
  cross-exam, Points of Agreement, Remaining Tensions"
updated: "2026-02-19"
---

## Progress Notes

- [--:--] Read all reference files: plan-sales system design (739 lines),
  business-skill-design-guidelines, plan-sales spec, RC6 researcher findings,
  plan-sales SKILL.md, draft-investor-update SKILL.md, plan-product SKILL.md
- [--:--] Designed architecture classification: Structured Debate vs
  Collaborative Analysis vs Pipeline vs Hub-and-Spoke comparison table
- [--:--] Designed agent team: Growth Advocate + Resource Optimizer (debate
  agents) + Bias Skeptic + Fit Skeptic + Team Lead
- [--:--] Designed 6-phase Structured Debate flow: Research -> Case Building ->
  Cross-Examination -> Synthesis -> Review -> Finalize
- [--:--] Designed cross-examination protocol with explicit turn structure (2
  mandatory rounds + 1 optional), challenge/rebuttal formats, and
  anti-premature-agreement rules
- [--:--] Designed agent idle fallback per P3-10 lesson (3-tier timeout
  escalation)
- [--:--] Designed output template including Build/Hire/Outsource assessment
- [--:--] Designed user data template with 8 input sections
- [--:--] Documented CI validator impact: 4 new sed expressions for bias-skeptic
  and fit-skeptic
- [--:--] Documented new patterns introduced, reusable components from existing
  skills
- [--:--] Documented key design decisions with rationale
- [--:--] Wrote complete system design to
  docs/architecture/plan-hiring-system-design.md
- [--:--] **SKEPTIC REVIEW: REJECTED** -- 5 divergences with researcher, 3
  blocking issues
- [--:--] **REVISION**: Addressed all 5 divergences and 3 blocking issues:

## Revision Log (Post-Skeptic Review)

### Divergence 1: Agent Name -- RESOLVED

- Kept "Resource Optimizer" per skeptic recommendation. No change needed.

### Divergence 2: Researcher Agent -- RESOLVED (conceded)

- **Original**: No Researcher. "Research IS advocacy" -- selective framing is a
  feature.
- **Skeptic rebuttal**: Selective evidence gathering is confirmation bias.
  Shared evidence base strengthens adversarial dynamic by forcing debate over
  interpretation, not fact selection.
- **Resolution**: CONCEDED. Added Researcher agent (opus) to produce neutral
  Hiring Context Brief in Phase 1. Both debaters argue from the shared evidence
  base. Skeptic's argument that "a shared evidence base strengthens the
  adversarial dynamic" was persuasive.
- **Impact**: Team size 5 -> 6 agents. Phase 1 is now Researcher-only. Phase
  diagram updated. Context brief format designed. Graceful degradation updated.

### Divergence 3: Cross-Examination Depth -- RESOLVED (adopted researcher's 3-message rounds)

- **Original**: 2-message rounds (Challenge -> Rebuttal) + optional Round 3.
- **Skeptic concern**: Too shallow. Challenger cannot assess rebuttal quality.
  Researcher's 3-message round (Challenge -> Response -> Rebuttal) gives
  challenger last word.
- **Resolution**: Adopted 3-message rounds (Challenge -> Response -> Rebuttal).
  Challenger gets last word. Still 2 mandatory rounds + optional Round 3. Total:
  6 messages minimum.

### Divergence 4: Rebuttal Format -- RESOLVED (combined both)

- **Original**: Position tracking (MAINTAINED/MODIFIED/CONCEDED) only.
- **Skeptic recommendation**: Add "Remaining Tensions" field alongside position
  tracking.
- **Resolution**: Added "Remaining Tensions" (2-3 bullets) to Rebuttal format.
  Gives synthesis both per-claim tracking AND high-level signal.

### Divergence 5: Agreement Handling -- RESOLVED (added Points of Agreement)

- **Original**: No explicit agreement handling. Only Concessions in challenge
  format.
- **Skeptic recommendation**: Add "Points of Agreement" to challenge format.
  Anti-convergence prevents wholesale agreement, not individual-point agreement.
- **Resolution**: Added "Points of Agreement" to Challenge format. Distinguished
  from Concessions: Agreement = "you're right AND this doesn't weaken my case."
  Concession = "you're right AND this weakens my case."

### Additional Changes

- Added generalist vs. specialist as cross-cutting concern in Debate Case format
  (per researcher findings / skeptic feedback)
- Added Debate Resolution Summary section to output template (from researcher
  design, adopted)
- Added Hiring Context Brief format (new artifact for Phase 1)
- Updated all gate numbers (Gate 1 through Gate 4)
- Updated phase diagram to reflect Researcher phase and 3-message rounds
- Updated all artifact count references throughout the document

## Key Design Decisions (Updated)

1. **2 debate agents (not 3)**: Hiring decisions are binary (hire/defer). A
   third "moderate" position weakens the adversarial dynamic.
2. **Growth Advocate + Resource Optimizer positions**: Map to the fundamental
   tension in every hiring decision (invest in people vs. preserve flexibility).
   Not strawmen -- both are legitimate perspectives.
3. **Researcher agent with shared evidence base** (revised per skeptic review):
   Prevents evidence-shopping. Both debaters argue from the same facts, forcing
   debate onto interpretation rather than fact selection.
4. **3-message cross-examination rounds** (revised per skeptic review):
   Challenge -> Response -> Rebuttal. Challenger gets last word to assess
   response adequacy. 2 mandatory rounds + 1 optional.
5. **Position tracking + Remaining Tensions** (revised per skeptic review):
   Per-claim MAINTAINED/MODIFIED/CONCEDED + high-level Remaining Tensions
   bullets. Gives synthesis both granular and aggregate signal.
6. **Points of Agreement + Concessions** (revised per skeptic review): Distinct
   categories. Agreement on individual points is valuable signal; wholesale
   agreement is suspect.
7. **Lead-driven synthesis (following plan-sales precedent)**: Validated by
   P3-10 implementation. Lead has full debate context.
