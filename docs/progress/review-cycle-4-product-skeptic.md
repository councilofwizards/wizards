---
feature: "review-cycle-4"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Reviewed researcher findings and architect assessment for next feature selection after P3-22"
updated: "2026-02-19"
---

# Product Skeptic Review: Next Feature Selection After P3-22

## Review 1: Researcher Findings

REVIEW: Research findings on roadmap priorities after P3-22 completion (docs/progress/review-cycle-4-researcher.md)
Verdict: APPROVED

### Assessment

The research is thorough, well-structured, and evidence-based. I independently verified all key claims against source documents.

#### 1. Delta analysis is accurate

Verified. P3-22 is complete (CI passing, skill deployed). Skill count is 5 (confirmed via filesystem: 5 SKILL.md files exist). Business skill count is 1. The delta table correctly captures what changed since Cycle 3 and what did not.

#### 2. P2 blocker assessments are correct

All three assessments verified against source documents:

- **P2-02 (Skill Composability)**: STILL BLOCKED. Verified. The P2-02 spec describes a `/run-workflow` skill requiring skill-to-skill invocation. No such mechanism exists in the plugin system. No SKILL.md references invoking another skill. The architect independently confirms this finding. HIGH confidence is justified.

- **P2-07 (Universal Shared Principles)**: PREMATURE. Verified. ADR-002 line 56-57 states: "When the skill count exceeds 8, revisit this approach." Current count is 5. The researcher states 5/8, which is correct. HIGH confidence is justified.

- **P2-08 (Plugin Organization)**: HALFWAY. Verified. `_index.md` line 69 states: "Defer plugin organization until 2+ business skills are built and validated." Current business skill count is 1. The researcher states 1/2, which is correct. HIGH confidence is justified.

#### 3. Candidate analysis is well-tiered

The tiering (Tier 1: business skills, Tier 2: engineering skills, Tier 3: complex business skills) is the right structure. The reasoning for deferring engineering skills (none advance P2 blockers) and complex business skills (3-skeptic domains, too risky as second pathfinder) is sound.

#### 4. P3-10 recommendation is well-argued but has a genuine risk tradeoff

The researcher makes 5 arguments for P3-10. Arguments 1 (unblocks P2-08) and 3 (advances P2-07 to 6/8) are shared by all business skill candidates and therefore do not differentiate P3-10. Arguments 2 (validates Collaborative Analysis) and 4 (natural complement to P3-22) are the differentiating ones. Argument 5 (medium effort is manageable) is generic.

The researcher also correctly identifies 4 risks. These are substantive and honest. The "quality without ground truth" risk for sales planning (external market data) is a legitimate concern.

**One correction**: The researcher claims Collaborative Analysis is "the most commonly assigned business consensus pattern (4/12 business skills)." I verified this against the business-skill-design-guidelines.md. Collaborative Analysis is assigned to 4 skills: plan-sales, plan-marketing, plan-customer-success, plan-analytics. Pipeline is ALSO assigned to 4 skills: build-sales-collateral, build-content, draft-investor-update, plan-onboarding. Structured Debate is assigned to 4 skills: plan-finance, review-legal, plan-operations, plan-hiring. ALL THREE patterns are equally represented at 4/12 each. The researcher's claim that Collaborative Analysis is "the most commonly assigned" is misleading -- it is tied with the other two. This does not invalidate the recommendation, but the "highest-leverage" framing is unsupported by the frequency data. The actual differentiating argument is that it is the most commonly assigned pattern AMONG the lower-risk candidates (excluding 3-skeptic domains and Scale & Optimize items).

### Notes

- The data integrity debt section (21 missing roadmap files, P3-22 status inconsistency) is correctly flagged and appropriately scoped as cleanup work rather than blocking the next feature selection.
- The researcher appropriately asks the skeptic to weigh in on the pattern-diversity vs. pattern-refinement tradeoff. I address this in my cross-cutting analysis below.

---

## Review 2: Architect Assessment

REVIEW: Technical assessment of next feature candidates (docs/progress/review-cycle-4-architect.md)
Verdict: APPROVED

### Assessment

The architect's assessment is technically sound with correct ADR analysis and a defensible recommendation, though the reasoning differs from the researcher's.

#### 1. P2 blocker assessments agree with the researcher

The architect independently arrives at the same conclusions: P2-02 still blocked, P2-07 premature, P2-08 one business skill away. The architect provides additional technical detail on the P2-02 platform gap (no skill-to-skill invocation in plugin.json or SKILL.md files). Both agents converge on the same evidence without contradiction. This is strong signal.

#### 2. P2-07 threshold analysis has a useful nuance

The architect distinguishes between total skills (5) and multi-agent skills carrying shared content (4, since setup-project is single-agent). This is a valid technical observation. ADR-002 says "skill count," not "multi-agent skill count," so the threshold is still 5/8 by the letter of the ADR. But the architect's point that the maintenance burden scales with multi-agent skills (which carry shared content) rather than total skills is worth noting. This does not change the decision but is a useful data point for when we revisit the threshold.

#### 3. Candidate ranking is architecturally sound

The architect ranks candidates by architectural simplicity, with Pipeline-reuse candidates (P3-16, P3-17) at the top and Collaborative Analysis candidates (P3-10, P3-15) second. This is an appropriate lens for an architect -- minimize risk, maximize reuse.

The architect's recommendation of P3-16 (`/build-sales-collateral`) is defensible: it reuses the Pipeline pattern, validates that the pattern was well-designed (not investor-update-specific), and carries lower risk. The secondary suggestion of P3-15 (`/plan-customer-success`) over P3-10 (`/plan-sales`) is an interesting divergence from the researcher -- the architect prefers customer success because it avoids the external market data problem. However, the architect does not provide strong evidence for P3-15 over P3-10 beyond this single concern.

#### 4. ADR review table is complete and accurate

All 4 ADRs are correctly assessed for their impact on this decision. No omissions.

#### 5. One gap in the architect's reasoning

The architect's primary argument for Pipeline-reuse is that it "validates the pattern was well-designed (not just investor-update-specific)." This is true but incomplete. The question is: what is more valuable at this stage of the project -- confirming that Pipeline works in a second context, or discovering whether Collaborative Analysis works at all? The architect frames this as "risk reduction vs. higher learning" but does not analyze which is more strategically valuable for the project's goals. The researcher does a better job of connecting the pattern choice to P2-07 and P2-08 implications.

### Notes

- The architect correctly identifies P3-01 (Custom Agent Roles) as premature. "We need more skills to understand customization needs before designing a generic role system" is exactly right.
- The ADR review is a good addition not present in the researcher's report. This should become a standard element of architect assessments.

---

## Review 3: Cross-Cutting Analysis

### The Core Disagreement

Both agents agree on the strategic priority: build a second business skill to unblock P2-08. The disagreement is:

| | Researcher | Architect |
|---|---|---|
| **Recommendation** | P3-10 `/plan-sales` | P3-16 `/build-sales-collateral` |
| **Pattern** | Collaborative Analysis (new) | Pipeline (proven) |
| **Risk** | Medium | Low |
| **Strategic value** | Higher (new pattern data) | Lower (pattern reuse confirmation) |
| **Lens** | Maximize learning | Minimize risk |

### My Resolution: P3-10 (`/plan-sales`)

I side with the researcher. Here is my reasoning:

**1. Pattern reuse confirmation has diminishing returns.**

The architect argues that building a second Pipeline skill proves the pattern is reusable. This is true but low-information. We already know Pipeline works -- we just built it for P3-22. Confirming it works a second time tells us very little we don't already know. The Pipeline pattern is sequential handoffs with quality gates. It is architecturally simple by design. The probability that it fails in a second context is low.

By contrast, Collaborative Analysis has never been implemented. We have zero data on whether it works. Building one instance gives us our first data point on the most novel of the three consensus patterns (parallel work with cross-referencing is genuinely harder than sequential handoffs). This information is more valuable per unit of effort.

**2. P2-08 is unblocked by any second business skill. The differentiator is P2-07 learning.**

Both candidates equally satisfy P2-08 (second business skill). Both equally advance the skill count toward P2-07's 8-skill threshold. But P2-07 is about "universal shared principles" -- and you cannot derive universal principles from a homogeneous sample. Two Pipeline skills and three Hub-and-Spoke skills give us data on only two patterns. Adding a Collaborative Analysis skill gives us data on three patterns. More pattern diversity means more meaningful data when we eventually tackle P2-07.

**3. The "external market data" risk is manageable.**

The researcher flags that sales planning requires external market data. The architect echoes this concern. But this is the same class of risk we already solved in P3-22: "quality without ground truth." The investor update skill reads project data that was itself written by AI agents -- the "circular evidence" risk the architect identified in Cycle 3. Sales planning reading external market assumptions is not fundamentally different. The business-skill-design-guidelines already mandate Assumptions & Limitations sections, Confidence levels, Falsification triggers, and External validation checkpoints. These mitigations apply to `/plan-sales` just as they do to `/draft-investor-update`. The risk is real but already mitigated by the framework.

**4. The "plan-*" structural similarity reduces implementation risk.**

The researcher correctly notes that `/plan-sales` is structurally closest to `/plan-product` (both are "plan-*" skills with research-heavy analysis). The team orchestration, write safety patterns, checkpoint protocol, and shared content sections are well-established. The novelty is in the consensus pattern (Collaborative Analysis vs. Hub-and-Spoke), not in the overall skill structure. This means the implementation risk is concentrated in one dimension (consensus pattern) rather than spread across multiple dimensions.

**5. P3-16 has a practical dependency problem the architect understates.**

The researcher notes that `/build-sales-collateral` "requires sales plan data as input -- circular dependency with `/plan-sales` in practice." The architect does not address this. Sales collateral (pitch decks, one-pagers, case studies) needs to be based on something -- a sales strategy, positioning, target market analysis. Without `/plan-sales` producing that strategy, what does `/build-sales-collateral` build from? It would either produce generic collateral (low value) or require the user to provide the strategy manually (defeating the purpose of the skill framework). This is a meaningful practical limitation that makes P3-16 less standalone than it appears.

### Risks I Am Adding

Beyond the risks identified by both agents, I flag:

1. **No roadmap file for P3-10.** Both agents note this. The index entry for P3-10 is a single line: "Sales Planning Skill." This means the spec cycle starts from nearly zero. The spec team will need to define the problem space, agent team composition, output format, and Collaborative Analysis implementation from scratch. This is additional effort compared to P3-16 (which could crib more from the P3-22 Pipeline implementation). The team should account for this in the spec cycle.

2. **Collaborative Analysis cross-referencing complexity.** The business-skill-design-guidelines describe Collaborative Analysis as: "Agents work in parallel, share partial findings via SendMessage, cross-reference and challenge each other's work, synthesize collaboratively." The "cross-reference and challenge" step is genuinely new. In Pipeline, each stage hands off a complete artifact. In Hub-and-Spoke, agents work independently and the lead aggregates. In Collaborative Analysis, agents must read each other's partial work mid-process and adapt. This requires careful prompt engineering to avoid agents either ignoring each other's findings or deferring to them uncritically. The spec must define what "cross-referencing" means concretely -- what messages agents send, when they send them, and how findings are synthesized.

3. **Scope creep risk.** "Sales planning" is a broad domain. Without a roadmap file constraining scope, the spec team may try to cover too much (market sizing, competitive analysis, pricing strategy, go-to-market, pipeline management, forecasting). The spec must define a narrow first scope. I recommend the spec be explicitly constrained to "sales strategy assessment for an early-stage startup" -- not a full sales operations toolkit.

### Data Integrity Issues

Both agents flag the same issues. Confirmed:

1. P3-22 roadmap file status should be `complete`, not `ready`. Minor fix.
2. P2-07 and P2-08 lack roadmap files. Flagged since Cycle 2. Still not fixed.
3. 21 items in `_index.md` reference non-existent files.

These are cleanup items, not blockers. But the persistence of this debt across 3 review cycles is concerning. I recommend the team lead assign this as explicit cleanup work rather than continuing to flag it as a "minor note."

---

## Final Verdict

REVIEW: Researcher findings and Architect assessment for next feature selection
Verdict: APPROVED

**Approved recommendation: P3-10 `/plan-sales` as the next feature.**

Both deliverables are well-researched and technically sound. The disagreement between agents is legitimate and well-reasoned on both sides. I resolve it in favor of P3-10 because:

1. Pattern diversity is more valuable than pattern reuse confirmation at this stage
2. Collaborative Analysis data is needed for meaningful P2-07 analysis
3. P3-16 has an understated practical dependency on P3-10
4. The "external market data" risk is already mitigated by the business-skill design guidelines framework
5. The "plan-*" structural similarity to existing skills limits implementation risk

**Mandatory conditions for the spec cycle:**

1. The spec MUST define what "cross-referencing" means concretely in the Collaborative Analysis pattern -- message timing, content, and synthesis protocol
2. The spec MUST constrain scope to sales strategy assessment for an early-stage startup, not full sales operations
3. A roadmap file for P3-10 MUST be created before the spec cycle begins
4. The P3-22 roadmap file status MUST be updated from `ready` to `complete`

**Recommended (non-blocking):**

5. Create stub roadmap files for P2-07 and P2-08 to resolve long-standing data integrity debt
6. The team lead should assign roadmap data integrity cleanup as explicit work rather than continuing to defer it
