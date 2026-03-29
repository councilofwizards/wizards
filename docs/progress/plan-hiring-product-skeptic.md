---
feature: "plan-hiring"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action:
  "Completed formal review of researcher findings and architect system design for P3-14 plan-hiring Structured Debate
  skill"
updated: "2026-02-19"
---

# Plan-Hiring (P3-14) Product Skeptic Review

## REVIEW: Research Findings + System Architecture for plan-hiring Structured Debate Skill

**Documents reviewed:**

- `docs/progress/plan-hiring-researcher.md` (researcher findings, updated with preliminary feedback fixes)
- `docs/architecture/plan-hiring-system-design.md` (architect system design)
- `docs/architecture/business-skill-design-guidelines.md` (authoritative pattern definitions)
- `docs/specs/plan-sales/spec.md` (reference spec for comparison)
- `docs/progress/review-cycle-6-researcher.md` (P3-10 lessons)

---

## Verdict: REJECTED

The research and architecture are individually strong but contain **5 unresolved divergences** that will produce an
incoherent spec if not reconciled. Additionally, I have **2 blocking issues** with the architecture's decision to remove
the Researcher agent and **1 blocking concern** about the cross-examination structure. These must be resolved before
spec writing proceeds.

---

## SECTION 1: CRITICAL DIVERGENCES BETWEEN RESEARCHER AND ARCHITECT

The researcher and architect made independent decisions that conflict on fundamental design points. The spec author
cannot write a coherent spec without explicit resolution of each.

### Divergence 1: Agent Name -- "Sustainability Advocate" vs. "Resource Optimizer"

- **Researcher**: "Sustainability Advocate" -- argues for conservative, capital-efficient hiring
- **Architect**: "Resource Optimizer" -- argues AGAINST premature hiring, for efficiency

These are different framings of the same role. "Sustainability Advocate" implies a strategic philosophy (preserve the
company). "Resource Optimizer" implies a tactical function (find the efficient solution). The name matters because it
shapes how the agent interprets its position.

**My assessment**: "Resource Optimizer" is the better name. It is more specific and less ideological. "Sustainability"
is vague -- sustainable how? Financially? Culturally? Operationally? "Resource Optimizer" clearly signals: find the most
efficient way to address the need, which may or may not involve hiring. The architect's framing also explicitly states
this agent is NOT "anti-hiring" -- it argues for alternatives where they exist and concedes where hiring is clearly
necessary.

**Resolution required**: Pick one name. I recommend "Resource Optimizer." The spec must use one name consistently.

### Divergence 2: Team Composition -- 6 Agents (with Researcher) vs. 5 Agents (no Researcher)

- **Researcher**: 6 agents -- Lead + Researcher + Growth Advocate + Sustainability Advocate + Bias Skeptic + Fit
  Skeptic. The Researcher produces a neutral Hiring Context Brief BEFORE the debate.
- **Architect**: 5 agents -- Lead + Growth Advocate + Resource Optimizer + Bias Skeptic + Fit Skeptic. No Researcher.
  Debate agents do their own research as part of case-building. The architect explicitly argues AGAINST a separate
  researcher.

This is the most significant divergence. See Section 2 for my detailed analysis.

### Divergence 3: Cross-Examination Message Count -- 6 Messages vs. 4 Messages (+optional 2)

- **Researcher**: 2 rounds, 3 messages each (Challenge -> Response -> Rebuttal) = 6 messages total
- **Architect**: 2 rounds, 2 messages each (Challenge -> Rebuttal) = 4 messages, plus an optional Round 3
  (Lead-directed, up to 4 more targeted messages)

These are structurally different protocols. The researcher's has a middle "Response" step before the rebuttal. The
architect's goes directly from challenge to rebuttal. The architect adds a Lead-directed optional third round for
unresolved tensions.

**My assessment**: The architect's structure is better. The "Response" step in the researcher's protocol is redundant --
a rebuttal IS a response. The two-message round (Challenge -> Rebuttal) is cleaner and forces the rebutting agent to
simultaneously defend AND update their position. The optional Round 3 is a good addition -- it gives the Lead a tool to
dig deeper on specific tensions without mandating more rounds.

**Resolution required**: Pick one protocol. I recommend the architect's 2-message rounds with optional Round 3.

### Divergence 4: Rebuttal Format -- "Key Unresolved Disagreements" vs. Position Tracking

- **Researcher**: Rebuttal includes "Key Unresolved Disagreements" section listing remaining disputes
- **Architect**: Rebuttal includes "Updated Position" section with explicit MAINTAINED / MODIFIED / CONCEDED tracking
  per challenged claim

**My assessment**: The architect's position tracking is superior. MAINTAINED/MODIFIED/CONCEDED gives the synthesis
explicit resolution data per claim. "Key Unresolved Disagreements" is looser -- it asks the agent to summarize
disagreements, which risks omission. Position tracking forces claim-by-claim accounting.

However, the researcher's "Key Unresolved Disagreements" serves an important PURPOSE that position tracking alone does
not: it identifies the OVERALL state of the debate. An agent can mark individual positions as MAINTAINED while still
acknowledging that the aggregate picture is uncertain.

**Resolution required**: Use the architect's position tracking format AND add a brief "Remaining Tensions" field at the
end of each rebuttal (2-3 bullet points, not a full summary). This gives the synthesis both per-claim tracking AND a
higher-level signal.

### Divergence 5: Agreement Handling

- **Researcher** (per my preliminary feedback): Added "Points of Agreement" to the rebuttal format alongside "Key
  Unresolved Disagreements"
- **Architect**: No explicit agreement handling. The "Concessions" section in the challenge format handles partial
  agreement, but there is no mechanism for acknowledging FULL agreement on specific roles.

**My assessment**: Both debaters may genuinely agree on certain roles (e.g., both agree the CTO hire is urgent and
necessary). The protocol MUST handle this. Forced disagreement where none exists is as harmful as forced consensus.

**Resolution required**: The challenge format should include a "Points of Agreement" section. Where both debaters agree
on a role, that agreement is a strong signal for synthesis and should be explicitly captured. Anti-convergence rules
prevent WHOLESALE agreement but should not prevent agreement on individual points.

---

## SECTION 2: BLOCKING ISSUE -- RESEARCHER AGENT REMOVAL

The architect explicitly argues against a separate Researcher agent. I challenge this decision on two grounds.

### The Architect's Argument (summarized):

1. Both debate agents perform research as part of case-building -- a separate researcher is redundant
2. A neutral research dossier reduces adversarial dynamic because both sides start from the same framing
3. "Research IS advocacy" -- selective evidence gathering is a feature because cross-examination corrects for it

### My Rebuttal:

**Argument 1 (redundancy) is wrong.** The researcher's purpose is not to save the debaters from doing research. It is to
establish a SHARED EVIDENCE BASE. Without it, the two debaters read the same project files but extract different facts.
When they cross-examine, they may argue past each other because they are operating from different evidence selections.
The Researcher ensures both sides argue from the same facts, which makes the cross-examination more productive -- the
debate is about INTERPRETATION, not about who found which facts.

**Argument 2 (reduces adversarial dynamic) is backwards.** A shared evidence base STRENGTHENS the adversarial dynamic.
When both sides argue from the same facts, the debate is forced into genuine disagreement about interpretation and
strategy. When both sides cherry-pick their own evidence, the debate can devolve into "I found this fact" / "well I
found THIS fact" -- which is evidence-shopping, not rigorous argumentation.

**Argument 3 ("research IS advocacy") is the most concerning.** The architect states: "The Growth Advocate searches for
evidence of team gaps. The Resource Optimizer searches for evidence of efficiency opportunities. This selective framing
is a feature, not a bug." I STRONGLY disagree. Selective evidence gathering is the definition of confirmation bias. The
entire point of the Researcher agent (per the researcher's findings) is to prevent exactly this failure mode.
Cross-examination can only partially correct for cherry-picked evidence -- the challenger may not even know what
evidence the other side ignored.

### HOWEVER:

I acknowledge the architect's cost argument (one fewer agent) and context argument (the Lead doesn't have to pass a
research dossier). These are legitimate practical concerns.

### My Verdict on the Researcher Agent:

**The architect's design CAN work without the Researcher, but it is WEAKER without it.** The spec author must make a
deliberate choice here, not just default to one proposal. If the Researcher is cut, the spec MUST include:

1. An explicit instruction for both debaters to cite ALL evidence they used (not just evidence that supports their
   position)
2. A cross-examination requirement to call out evidence the opposing side IGNORED (not just evidence they
   misinterpreted)
3. The synthesis must note which side's evidence base was more comprehensive

If the Researcher is kept, Phase 1 and Phase 2 need clearer separation (the researcher's document combines them well,
the architect's merges them).

**This is a BLOCKING issue.** The spec must explicitly state the decision and its rationale. I do not mandate the
Researcher, but I reject a design that silently drops it without addressing the evidence-shopping risk.

---

## SECTION 3: BLOCKING CONCERN -- CROSS-EXAMINATION DEPTH

The architect's cross-examination protocol has 2 mandatory rounds of 2 messages each (4 messages total) plus an optional
Round 3. The researcher proposed 2 rounds of 3 messages each (6 messages total).

I am concerned that 4 messages is insufficient for substantive cross-examination. Here is why:

- Round 1: Growth challenges Efficiency Case (1 message). Resource Optimizer rebuts (1 message). That is ONE exchange on
  the Efficiency Case.
- Round 2: Resource Optimizer challenges Growth Case (1 message). Growth Advocate rebuts (1 message). That is ONE
  exchange on the Growth Case.

Each case gets challenged ONCE and rebutted ONCE. There is no opportunity for the challenger to respond to the rebuttal.
The challenger raises issues, the defender responds, and the exchange ends. This means the challenger cannot say "your
rebuttal is insufficient because [X]" -- the debate just moves on.

The researcher's 3-message round (Challenge -> Response -> Rebuttal) gives the CHALLENGER the last word, which is
correct -- the challenger raised the issue, the defender responded, and the challenger gets to assess whether the
response was adequate.

**My assessment**: The 4-message protocol is too shallow. The 6-message protocol is better structured. BUT the
architect's optional Round 3 partially compensates by allowing the Lead to dig into unresolved tensions.

**Resolution required**: Either adopt the researcher's 3-message rounds (Challenge -> Response -> Rebuttal, with the
challenger getting last word) OR strengthen the architect's optional Round 3 to be a MANDATORY "Final Position
Statement" where each debater summarizes their post-cross-examination position. The synthesis needs a clear picture of
where each side ended up, not just where they started.

---

## SECTION 4: NON-BLOCKING ISSUES

### 4a. Structured Debate is Genuinely Different from Collaborative Analysis -- VERIFIED

Both documents clearly differentiate the patterns. The comparison tables are accurate. Key differentiators are present:
assigned positions (not neutral investigation), adversarial cross-examination (not cooperative cross-referencing), and
debate resolution in synthesis. This is NOT "Collaborative Analysis with different labels." **PASSED.**

### 4b. Debate Positions are Genuine Opposing Views -- VERIFIED

Both Growth Advocate and Resource Optimizer (or Sustainability Advocate) are defensible positions. Neither is a
strawman. Both documents correctly note that agents may concede individual points -- the positions are starting stances,
not rigid conclusions. **PASSED.**

### 4c. Agent Team Follows Guidelines -- VERIFIED

Bias Skeptic + Fit Skeptic per business-skill-design-guidelines.md line 32. Non-overlapping concerns: Bias Skeptic
handles fairness/legal/inclusion; Fit Skeptic handles necessity/composition/budget/strategy. No overlap detected.
**PASSED.**

### 4d. Mandatory Business Quality Sections -- VERIFIED

Both documents include all 4 mandatory sections: Assumptions & Limitations, Confidence Assessment, Falsification
Triggers, External Validation Checkpoints. The architect's output template has them clearly defined. **PASSED.**

### 4e. P3-10 Implementation Lessons -- PARTIALLY VERIFIED

| Lesson                                  | Researcher                                 | Architect                                                | Status                                 |
| --------------------------------------- | ------------------------------------------ | -------------------------------------------------------- | -------------------------------------- |
| Agent idle fallback                     | Designed (reminder -> re-spawn -> proceed) | Designed (3-tier timeout per phase)                      | PASSED -- architect's is more detailed |
| Lead-driven synthesis                   | Follows plan-sales precedent               | Follows plan-sales precedent                             | PASSED                                 |
| Validator changes for new skeptic names | 4 new sed expressions documented           | 4 new sed expressions documented                         | PASSED                                 |
| SKILL.md size awareness                 | 1200-1500 lines estimated                  | Not explicitly estimated but SKILL.md structure outlined | MINOR GAP                              |
| Skills auto-discovered (no plugin.json) | Noted                                      | Noted                                                    | PASSED                                 |

### 4f. Scope Constraint -- VERIFIED

Both documents correctly scope to early-stage startup hiring planning. Out of scope items are comprehensive and
appropriate: no enterprise HR, no recruiting ops, no compensation administration, no performance management. The
architect adds "no legal advice" explicitly, which is good given the Bias Skeptic touches legal compliance surface.
**PASSED.**

### 4g. Spec Completeness Readiness -- ASSESSED

Both documents provide sufficient detail for a spec. The spec template requires: Summary, Problem, Solution,
Constraints, Out of Scope, Files to Modify, Success Criteria. The researcher covers domain/problem/scope. The architect
covers solution/architecture/CI. Together they cover all required sections, pending resolution of the divergences above.

---

## SECTION 5: WHAT THE SPEC MUST CONTAIN (Minimum requirements for my approval)

When the spec is written, I will verify:

1. **One consistent agent name for the efficiency advocate.** No mixing of "Sustainability Advocate" and "Resource
   Optimizer."
2. **Explicit decision on the Researcher agent** with documented rationale. If no Researcher, the evidence-shopping
   mitigations from Section 2 must be present.
3. **One consistent cross-examination protocol** with clear message formats. If 2-message rounds, the lack of challenger
   follow-up must be compensated.
4. **Position tracking (MAINTAINED/MODIFIED/CONCEDED)** in the rebuttal format.
5. **Points of Agreement** handling in the cross-examination format.
6. **"Remaining Tensions"** field in the rebuttal format for synthesis.
7. **All 4 mandatory business quality sections** in the output template.
8. **Numbered, testable success criteria.**
9. **Files to Modify table** (SKILL.md, validator, any others).
10. **Debate Resolution Summary** section in the output (both documents agree on this).
11. **Round ordering acknowledgment** -- the spec must note which side is challenged first and confirm the structure is
    symmetric.
12. **Generalist vs. specialist as cross-cutting concern** -- not claimed as subsumed by the primary debate framing.

---

## SUMMARY

**Verdict: REJECTED** -- not because the individual work is poor (it is thorough), but because the researcher and
architect diverged on fundamental design decisions that must be reconciled before spec writing. The 5 divergences (agent
name, team composition, message count, rebuttal format, agreement handling) need explicit resolution. The Researcher
agent question is the most consequential.

**Path to approval**: Resolve the 5 divergences, address the 3 blocking issues (Researcher agent evidence-shopping risk,
cross-examination depth, agreement handling), and produce a spec that meets the 12 requirements in Section 5. I will
review the spec when it is submitted.

---

## RE-REVIEW: Revised Architecture (2026-02-19)

**Document reviewed:** `docs/architecture/plan-hiring-system-design.md` (revised per reconciliation)

### Verdict: APPROVED

All 5 divergences are resolved. All 3 blocking issues are addressed. The revised architecture meets my requirements.

### Divergence Resolution Verification

| #   | Divergence          | Resolution                                                                                                                                                              | Verified                                                                          |
| --- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1   | Agent name          | "Resource Optimizer" used consistently throughout                                                                                                                       | YES -- lines 46, 58-59, 73, 131, 271, etc. No "Sustainability Advocate" anywhere. |
| 2   | Researcher agent    | ADDED. Neutral Researcher produces Hiring Context Brief in Phase 1 (lines 77-87, 201-267). Rationale explicitly cites evidence-shopping prevention.                     | YES -- my rebuttal arguments are reflected in the rationale (lines 79-84).        |
| 3   | Cross-exam messages | 3-message rounds adopted: Challenge -> Response -> Rebuttal, challenger gets last word (lines 330-342). 6 mandatory messages + optional Round 3.                        | YES -- matches my demand for challenger follow-up.                                |
| 4   | Rebuttal format     | Position tracking (MAINTAINED/MODIFIED/CONCEDED) at lines 884-895 + "Remaining Tensions" at lines 897-901.                                                              | YES -- both per-claim tracking AND high-level synthesis signal.                   |
| 5   | Agreement handling  | "Points of Agreement" section in Challenge format (lines 365-370). Distinct from Concessions (line 377). Anti-convergence allows individual-point agreement (line 428). | YES -- exactly as required.                                                       |

### Blocking Issue Resolution Verification

| #   | Blocking Issue                     | Resolution                                                                                                                                | Verified                                         |
| --- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| 1   | Researcher agent evidence-shopping | Researcher included. Shared evidence base established in Phase 1. Both debaters receive Hiring Context Brief (line 273-275).              | YES -- fully resolved.                           |
| 2   | Cross-examination depth            | 3-message rounds with challenger getting last word. Rebuttal includes "Assessment of Responses" with adequacy evaluation (lines 884-886). | YES -- challenger can flag inadequate responses. |
| 3   | Agreement handling                 | Points of Agreement in challenge format. Anti-convergence prevents wholesale agreement, not per-point (line 428).                         | YES -- fully resolved.                           |

### Section 5 Requirements Pre-Check (for spec)

| #   | Requirement                                 | Architecture Status                                                                    |
| --- | ------------------------------------------- | -------------------------------------------------------------------------------------- |
| 1   | One consistent agent name                   | SATISFIED -- "Resource Optimizer" throughout                                           |
| 2   | Explicit Researcher decision with rationale | SATISFIED -- lines 77-87, with evidence-shopping rationale                             |
| 3   | One consistent cross-exam protocol          | SATISFIED -- 3-message rounds, all three formats specified                             |
| 4   | Position tracking in rebuttal               | SATISFIED -- MAINTAINED/MODIFIED/CONCEDED                                              |
| 5   | Points of Agreement                         | SATISFIED -- in Challenge format                                                       |
| 6   | Remaining Tensions                          | SATISFIED -- in Rebuttal format                                                        |
| 7   | All 4 mandatory business quality sections   | SATISFIED -- in output template (lines 670-703)                                        |
| 8   | Numbered, testable success criteria         | N/A -- spec responsibility, not architecture                                           |
| 9   | Files to Modify table                       | N/A -- spec responsibility, not architecture                                           |
| 10  | Debate Resolution Summary                   | SATISFIED -- in output template (lines 652-666)                                        |
| 11  | Round ordering acknowledgment               | SATISFIED -- line 344, explicitly notes first-mover advantage and symmetric mitigation |
| 12  | Generalist vs. specialist as cross-cutting  | SATISFIED -- in Debate Case format (lines 295, 320) and Gate 2 check (line 320)        |

### Remaining Minor Notes (non-blocking)

1. **Lightweight Mode inconsistency**: Line 915 says "Researcher + Debate agents -> sonnet" but line 1046 says "Debate
   agents -> sonnet" only. The SKILL.md structure section omits the Researcher from lightweight mode. Should be
   consistent -- if Researcher uses Sonnet in light mode, both references should say so.

2. **Artifact count in synthesis**: Line 464 says "1 context brief + 2 cases + up to 6 cross-examination messages."
   Correct. But it should also note the optional Round 3 messages (up to 4 more). The synthesis section should say "up
   to 10 cross-exam messages" to account for Round 3.

3. **SKILL.md size estimate**: Not in the architecture. The researcher estimated 1200-1500 lines. With the addition of
   the Researcher agent, Hiring Context Brief format, and 3-message cross-exam formats, I expect it may reach 1400-1600
   lines. Not a blocker -- just awareness.

These are minor and do not affect my approval. The spec author should note them.

### Final Verdict

**APPROVED.** The revised architecture resolves all divergences, addresses all blocking issues, and satisfies 10 of 12
Section 5 requirements (remaining 2 are spec-level, not architecture-level). The architecture is ready for spec writing.

The spec will receive its own review against the full Section 5 checklist.

---

## FINAL SPEC REVIEW: docs/specs/plan-hiring/spec.md (2026-02-19)

### Verdict: APPROVED

The spec meets all 12 Section 5 requirements, follows the spec template structure, and is ready for implementation.

### Section 5 Requirements -- Final Verification

| #   | Requirement                                        | Spec Location                                             | Status |
| --- | -------------------------------------------------- | --------------------------------------------------------- | ------ |
| 1   | One consistent agent name ("Resource Optimizer")   | Lines 53, 57, 90, 102, 111-114, Constraint #10 (line 280) | PASSED |
| 2   | Explicit Researcher decision with rationale        | Lines 59-64, 4 numbered points                            | PASSED |
| 3   | One consistent cross-exam protocol                 | Lines 100-142, 3-message rounds                           | PASSED |
| 4   | Position tracking (MAINTAINED/MODIFIED/CONCEDED)   | Lines 130-131, Success Criterion #4                       | PASSED |
| 5   | Points of Agreement handling                       | Lines 122-124, Success Criterion #5                       | PASSED |
| 6   | Remaining Tensions field                           | Lines 131-132, Success Criterion #6                       | PASSED |
| 7   | All 4 mandatory business quality sections          | Lines 222-226, sections 10-13, Success Criterion #15      | PASSED |
| 8   | Numbered, testable success criteria                | Lines 309-328, 20 numbered criteria                       | PASSED |
| 9   | Files to Modify table                              | Lines 300-305, 2 files listed                             | PASSED |
| 10  | Debate Resolution Summary                          | Lines 228-229, section 14, Success Criterion #7           | PASSED |
| 11  | Round ordering acknowledgment                      | Line 118, Success Criterion #19                           | PASSED |
| 12  | Generalist vs. specialist as cross-cutting concern | Lines 96-98, Constraint #11, Success Criterion #20        | PASSED |

All 12 requirements: **PASSED**.

### Spec Template Compliance

All required sections present: Summary, Problem, Solution, Constraints, Out of Scope, Files to Modify, Success Criteria,
Architecture References.

### Quality Assessment

**Strengths:**

1. Documents agent name resolution and Researcher inclusion as DECISIONS with rationale (lines 57-64). Transparent and
   auditable.
2. 20 testable success criteria -- each maps to a specific design aspect.
3. Cross-examination protocol well-specified: round structure, message formats, anti-convergence, idle fallback, round
   ordering.
4. 12 constraints include meta-constraints I required (consistent naming, cross-cutting concerns, no legal advice).
5. Output section count (17) justified by debate resolution and hiring-specific sections.

**One non-blocking observation:**

- Line 237 (`--light` argument) says "Debate agents use Sonnet" but does not mention Researcher. Success Criterion #11
  (line 319) clarifies Researcher stays Opus. Slightly misleading but not wrong. Same inconsistency flagged in
  architecture re-review.

### Final Verdict

**APPROVED.** The spec is complete, internally consistent, resolves all identified divergences, and meets all 12
requirements. Ready for implementation.

This concludes my review of P3-14 (plan-hiring).
