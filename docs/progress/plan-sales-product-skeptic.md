---
feature: "plan-sales"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Completed review of researcher findings and architect system design"
updated: "2026-02-19"
---

# Product Skeptic Review: /plan-sales Research & Architecture

## Verdict: APPROVED (with conditions)

Both deliverables meet the quality bar. The mandatory conditions from Review Cycle 4 are satisfied. The Collaborative Analysis protocol is concretely defined. The scope is appropriately constrained. The design is at least as rigorous as the investor-update spec. Conditions below must be addressed during spec/implementation — they are not blocking.

---

## Mandatory Condition 1: Cross-Referencing Concreteness

**Status: SATISFIED.**

This was the hardest condition to meet and the one I was most prepared to reject on. The Review Cycle 4 approval explicitly required: "The deliverables MUST define 'cross-referencing' concretely — message timing, content, and synthesis protocol. Hand-waving about 'agents collaborate' is not acceptable."

The deliverables provide:

1. **Message timing**: Phase-gated with explicit triggers. Phase 1 produces Domain Briefs. Team Lead broadcasts the transition to Phase 2 only after all 3 briefs are received and pass a lightweight completeness check (Gate 1). Phase 2 produces Cross-Reference Reports. Phase 3 begins after all 3 reports are received. This is not hand-waving — there are defined gates with defined triggers.

2. **Message content**: Both Domain Briefs and Cross-Reference Reports have structured formats with specific sections. The Cross-Reference Report format (Contradictions Found, Gaps Filled, Assumptions Challenged, Synergies Identified, Answers to Peer Questions) is concrete enough that an implementation team could write the SKILL.md prompt from it. Each section has a template showing what entries look like (e.g., "[Brief A] says [X] but [Brief B] says [Y]. My assessment: [which is more likely correct, based on what evidence]. Confidence: [H/M/L]").

3. **Synthesis protocol**: The architect's decision to use lead-driven synthesis (not a separate Drafter agent) is well-justified. The synthesis process is defined in 5 steps: resolve contradictions, integrate gap-fills, evaluate challenged assumptions, highlight synergies, write the assessment. The rationale for lead synthesis over a Drafter agent is sound — the lead holds full context from orchestrating Phases 1-2 and must resolve contradictions, which requires judgment about the process, not just the text.

**What elevates this above hand-waving**: The combination of structured artifact formats, phase gates with explicit triggers, and a defined taxonomy (SUPPORTS/CONTRADICTS/EXTENDS/QUESTION in the researcher's proposal; Contradictions/Gaps/Assumptions/Synergies/Answers in the architect's refined version) makes the protocol implementable. An engineer reading these documents could write the SKILL.md prompts without guessing.

**Minor observation**: The researcher proposed a Phase 3 "Challenge Round" as a separate phase between cross-referencing and synthesis. The architect folded challenges into the cross-referencing phase (via the "Assumptions Challenged" section of the Cross-Reference Report) and eliminated the separate challenge phase. This is the right call — a separate challenge round adds another gate and another message round with marginal benefit, since challenges are naturally surfaced during cross-referencing. The architect's 5-phase design (Independent Research -> Cross-Referencing -> Synthesis -> Review -> Finalize) is cleaner than the researcher's proposed 5-phase design (which had a different Phase 3). This is a case where the architect correctly refined the researcher's proposal.

---

## Mandatory Condition 2: Scope Constraint

**Status: SATISFIED.**

Both deliverables explicitly scope to "sales strategy assessment for early-stage startups." The researcher defines 6 core deliverables (Target Market Assessment, Competitive Positioning, Pricing Strategy, Go-to-Market Approach, Sales Pipeline Framework, Key Risks & Assumptions) and lists 5 explicit out-of-scope items (CRM setup, sales forecasting, lead generation, hiring, marketing). The architect's Non-Goals section excludes real-time data gathering, financial modeling, CRM integration, enterprise sales strategy, and template customization.

No scope creep detected. The scope is narrow enough to be deliverable and broad enough to be useful.

---

## Additional Review Criteria

### 3. Is the Collaborative Analysis pattern well-defined enough for implementation?

**Yes.** The architect's phase diagram, phase details, artifact formats, transition triggers, and gate conditions form a complete specification. The SKILL.md structure section at the bottom of the system design maps every design element to a SKILL.md section. An implementation team could build this.

The one area that requires implementation-time judgment is the **Team Lead's synthesis process** (Phase 3). The 5 synthesis steps are defined (resolve contradictions, integrate gap-fills, evaluate challenged assumptions, highlight synergies, write assessment), but the Team Lead prompt will need to be specific about how to weigh evidence when resolving contradictions. This is acceptable — the spec provides the framework, the SKILL.md prompt provides the execution detail.

### 4. Agent team composition vs. business-skill-design-guidelines

**Mostly aligned.** The guidelines specify Accuracy Skeptic + Strategy Skeptic for `/plan-sales`. Both deliverables include these. The 3 analysis agents (Market Analyst, Product Strategist, GTM Analyst) are justified by the architect — each covers a distinct strategic domain, and 3 agents provide meaningful cross-referencing (2 agents would be too few perspectives; 4 would introduce scope creep).

**One naming inconsistency**: The researcher proposes `market-researcher`, `product-analyst`, `strategy-synthesizer`. The architect proposes `market-analyst`, `product-strategist`, `gtm-analyst`. The architect's naming is better — it uses consistent "[domain]-[role]" naming and eliminates the separate synthesizer agent. The architect's naming should be used.

**Model selection divergence**: The researcher proposes a Strategy Synthesizer agent using Sonnet, following the investor-update Drafter pattern. The architect eliminates the Synthesizer role entirely and has the Team Lead synthesize. The architect's decision is correct and better-justified: the lead holds full context, a Drafter would need all 6 artifacts passed via messages (context risk), and eliminating one agent reduces cost. This is a sound architectural improvement over the researcher's proposal.

### 5. Quality-without-ground-truth requirements

**Addressed.** The output artifact format includes all 4 mandatory sections: Assumptions & Limitations, Confidence Assessment (per-section table), Falsification Triggers, External Validation Checkpoints. Both skeptic checklists explicitly verify these sections. The Accuracy Skeptic checklist item 6 and Strategy Skeptic checklist item 6 both include the business quality checklist from the guidelines.

The researcher correctly identifies (Risk 1) that quality-without-ground-truth is harder for sales planning than investor updates because sales planning involves forward-looking market claims rather than backward-looking project data. This risk is real. The mitigation (dual-skeptic validation + mandatory quality sections) is the same as investor updates but may be less effective for forward-looking claims. The External Validation Checkpoints section is the key safety valve — it must direct users to validate specific claims with domain experts and market data. This is noted as a residual risk, which is honest.

### 6. Output artifact format

**Well-defined and useful.** The architect's output template has: YAML frontmatter (type, period, generated, confidence, review_status, approved_by), Executive Summary, Target Market (with TAM/SAM/SOM table), Competitive Positioning, Value Proposition, Go-to-Market Strategy (with channel table), Pricing Considerations, Strategic Risks (with risk table), Recommended Next Steps, and all 4 mandatory quality sections.

**Comparison with investor-update output**: The sales assessment output is structured more like a strategy document (recommendations, risks, next steps) vs. the investor update's reporting document (metrics, milestones, outlook). This is appropriate — the two artifacts serve different purposes. The sales assessment template is slightly more structured (more tables, more specific section guidance), which is appropriate given the heavier reliance on user-provided data.

**One minor observation**: The researcher's proposed output has a "Sales Pipeline Framework" section (Customer Journey Map, Key Conversion Points, Metrics to Track, Pipeline Health Indicators). The architect's output has "Go-to-Market Strategy" and "Recommended Next Steps" but no explicit pipeline framework section. The architect's version is more appropriate for early-stage startups — a detailed pipeline framework is premature for companies that may not yet have a pipeline. The GTM Analyst's scope includes customer acquisition, which covers the essential pipeline elements without the enterprise-level formality. This is a correct scope decision.

### 7. User data template

**Comprehensive without being overwhelming.** The architect's template has 5 sections (Product & Market, Market Context, Current Sales, Pricing, Constraints) with approximately 20 fields. This is fewer than the researcher's proposed template (6 sections, ~25 fields) and more appropriate — the architect eliminated fields like "Monthly runway" and "Revenue target" that drift toward financial modeling (out of scope).

The graceful degradation behavior (file missing: use project data with low-confidence markers and create template; file partial: use what's available; file empty: treat as missing) is consistent with the investor-update pattern.

### 8. Comparison with investor-update spec quality

**At least as rigorous.** The investor-update spec is well-structured with clear sections: Summary, Problem, Solution (with subsections), Constraints, Out of Scope, Files to Modify, and Success Criteria. The plan-sales deliverables are more detailed in several areas:

- The phase architecture is more complex (5 phases with cross-referencing vs. 4 pipeline stages) and is documented with a phase diagram, per-phase details, artifact formats, and transition triggers.
- The cross-referencing protocol is novel and well-specified — the investor-update spec didn't need to solve this problem.
- The agent team rationale is more detailed (justifying 3 analysis agents, justifying all-Opus, justifying no DBA, justifying lead-driven synthesis).
- The CI impact analysis is equivalent in quality.

**One gap vs. investor-update spec**: The investor-update spec has explicit "Files to Modify" and "Success Criteria" sections. The architect's system design does not have these as formal sections, though the information is distributed across the document (SKILL.md Structure section, New Artifacts table, Non-Goals). The final spec (to be written from these deliverables) should include formal Files to Modify and Success Criteria sections. This is a spec-formatting concern, not a design concern.

### 9. Risks the team hasn't identified

**One risk not adequately addressed**:

- **Context exhaustion during synthesis (Phase 3)**: The Team Lead must hold all 6 artifacts (3 Domain Briefs + 3 Cross-Reference Reports) in working memory during synthesis. These are structured but could be substantial. The researcher's Domain Brief format has 6 sections; the Cross-Reference Report has 5-6 sections. If each agent produces 1,000-2,000 tokens of findings, the lead is synthesizing from 6,000-12,000 tokens of input. This is within Opus's capabilities but is a real operational risk. The architect mentions this in the lead-driven synthesis rationale ("a newly-spawned Drafter would need all of this context passed via messages, risking context exhaustion") but does not discuss what happens if the Lead itself hits context limits during synthesis. The Failure Recovery section handles context exhaustion for agents but not for the lead. **Condition**: The spec should address lead context management during synthesis — either by structuring the synthesis in passes (section by section) or by defining what happens if the lead's context degrades.

**Risks already identified and adequately addressed**:

- User data dependency (both deliverables flag this as HIGH concern with mitigations)
- Quality without ground truth (both deliverables address with dual-skeptic + mandatory sections)
- Cross-referencing complexity (researcher flags as MEDIUM concern; architect addresses with structured formats)
- Scope creep (both deliverables explicitly constrain scope)
- First-run degradation (both deliverables handle gracefully)

---

## Cross-Reference Check: Researcher vs. Architect Consistency

The two deliverables are largely consistent, with the architect correctly refining several of the researcher's proposals:

| Topic | Researcher | Architect | Assessment |
|-------|-----------|-----------|------------|
| Phase structure | 5 phases (Research, Cross-Ref, Challenge, Synthesis, Skeptic) | 5 phases (Research, Cross-Ref, Synthesis, Review, Finalize) | Architect's version is better — folds challenges into cross-ref |
| Agent names | market-researcher, product-analyst, strategy-synthesizer | market-analyst, product-strategist, gtm-analyst | Architect's naming is better — consistent pattern, no synthesizer |
| Synthesizer model | Sonnet (Synthesizer agent) | N/A (Lead synthesizes) | Architect's decision is correct — eliminates unnecessary agent |
| Cross-ref format | 7-field message (topic, from, re, type, details, impact, action) | 5-section report (contradictions, gaps, assumptions, synergies, answers) | Architect's format is better — more structured, less per-item overhead |
| User data template | 6 sections, ~25 fields | 5 sections, ~20 fields | Architect's is tighter — fewer scope-creep fields |
| Output format | 12 sections including Sales Pipeline Framework | 10 sections, no pipeline framework | Architect's is more appropriate for early-stage |
| Scope definition | 6 deliverables + 5 out-of-scope items | 5 non-goals | Both adequate; researcher is more verbose, architect more concise |

No contradictions that would block approval. The architect consistently made better-scoped decisions than the researcher — this is the expected outcome (researcher provides breadth, architect provides precision).

---

## Conditions for Spec/Implementation

These are NOT blocking — the deliverables are approved. These must be addressed when the spec and SKILL.md are written:

1. **Lead context management during synthesis**: Define how the Team Lead manages context during Phase 3 when holding 6 artifacts. Consider structured synthesis (section-by-section) or define escalation if context degrades.

2. **Formal spec sections**: The final spec should include explicit "Files to Modify," "Constraints," and "Success Criteria" sections, following the investor-update spec format.

3. **Use architect's naming**: Agent names should follow the architect's proposal (market-analyst, product-strategist, gtm-analyst), not the researcher's.

---

## Final Assessment

The Collaborative Analysis pattern is now concretely defined. The two deliverables complement each other well — the researcher provides breadth and risk analysis, the architect provides precision and structural decisions. The architect correctly refined several of the researcher's proposals. The scope is tight, the artifacts are structured, the quality gates are defined, and the mandatory conditions from Review Cycle 4 are met.

This is ready for spec writing and implementation.
