---
title: "Sales Planning System Design"
status: "awaiting_review"
created: "2026-02-19"
updated: "2026-02-19"
---

# Sales Planning (`/plan-sales`) System Design

## Overview

A multi-agent Collaborative Analysis skill that produces a sales strategy assessment for early-stage startups. Agents research in parallel, share partial findings, cross-reference each other's work, and synthesize a unified assessment validated by dual-skeptic review.

This is the second business skill in the conclave framework and the first to implement the Collaborative Analysis consensus pattern from the business skill design guidelines. It introduces peer-to-peer mid-process knowledge sharing — agents read and react to each other's partial findings during analysis, rather than working independently (Hub-and-Spoke) or sequentially (Pipeline).

**Scope constraint (per Review Cycle 4 skeptic mandate):** Sales strategy assessment for early-stage startups. Not a full sales operations toolkit. Not pipeline management, forecasting, or CRM integration.

## Architecture Classification

This is a **multi-agent Collaborative Analysis skill** — parallel investigation with structured cross-referencing and collaborative synthesis. Unlike Pipeline (sequential handoffs) or Hub-and-Spoke (parallel independence), Collaborative Analysis requires agents to:

1. **Work in parallel** on different analysis domains
2. **Share partial findings** mid-process via SendMessage
3. **Cross-reference** each other's findings — identify contradictions, fill gaps, challenge assumptions
4. **Synthesize collaboratively** — the lead integrates findings + cross-references into a unified assessment
5. **Dual-skeptic validation** with non-overlapping concerns (Accuracy + Strategy)

### How Collaborative Analysis Differs from Existing Patterns

| Dimension | Hub-and-Spoke (plan-product) | Pipeline (draft-investor-update) | Collaborative Analysis (plan-sales) |
|-----------|------------------------------|----------------------------------|--------------------------------------|
| Agent concurrency | Parallel, independent | Sequential stages | Parallel with mid-process sharing |
| Inter-agent communication | Agents report to lead only | Artifacts passed between stages | Agents message each other directly |
| Knowledge sharing timing | After all agents complete | After each stage completes | During analysis (partial findings) |
| Quality gate | Single skeptic after aggregation | Dual skeptic after drafting | Dual skeptic after synthesis |
| Cross-referencing | None (lead aggregates) | None (each stage builds on prior) | Explicit: agents review peers' findings |
| Output construction | Lead synthesizes from independent reports | Final stage produces output | Lead synthesizes from cross-referenced findings |

## Agent Team

### Roles

| Role | Name | Model | Responsibility |
|------|------|-------|---------------|
| Team Lead | (invoking agent) | opus | Orchestrate phases, manage transitions, synthesize final assessment |
| Market Analyst | `market-analyst` | opus | Market sizing, competitive landscape, industry trends |
| Product Strategist | `product-strategist` | opus | Value proposition, differentiation, product-market fit |
| GTM Analyst | `gtm-analyst` | opus | Go-to-market channels, pricing, customer acquisition |
| Accuracy Skeptic | `accuracy-skeptic` | opus | Verify claims, projections, market data against evidence |
| Strategy Skeptic | `strategy-skeptic` | opus | Challenge assumptions, alternatives, strategic coherence |

### Team Composition Rationale

**Why 3 analysis agents (not 2, not 4):**

- **3 domains cover the core strategic questions** a startup founder needs answered: "Who is the market?" (Market Analyst), "Why us?" (Product Strategist), "How do we reach them?" (GTM Analyst). These map to the three pillars of early-stage sales strategy.
- **2 agents** would force one agent to cover too much ground, reducing the depth of cross-referencing (fewer perspectives to challenge each other).
- **4 agents** would add a domain (e.g., financial modeling) that falls outside the constrained scope of "sales strategy assessment." Pricing is included in GTM Analyst's scope as a channel/positioning concern, not a financial modeling exercise.

**Why all Opus:**

All three analysis agents require judgment-heavy reasoning: interpreting project context, assessing market positioning, evaluating strategic fit. Unlike the investor update Drafter (which executes a well-defined writing task from structured inputs), these agents must reason about ambiguous, incomplete data and form independent judgments. The cross-referencing phase specifically requires agents to identify contradictions and challenge peer assumptions — a task that benefits from stronger reasoning. Sonnet would risk superficial cross-referencing that defeats the purpose of the pattern.

**Why no DBA:**

There is no database, no data model, no migrations. The skill reads markdown files and user-provided data, then produces a markdown document. A DBA role adds no value.

### Model Selection Rationale

- **Market Analyst (Opus)**: Must assess market dynamics from limited project data and user inputs. Judgment-heavy.
- **Product Strategist (Opus)**: Must evaluate value propositions and competitive differentiation. Requires nuanced analysis.
- **GTM Analyst (Opus)**: Must reason about go-to-market channels and pricing strategy. Judgment-heavy.
- **Accuracy Skeptic (Opus)**: Must cross-reference claims against evidence and detect unsupported projections. Reasoning-heavy adversarial role. Skeptics are always Opus.
- **Strategy Skeptic (Opus)**: Must challenge strategic assumptions and evaluate alternatives. Requires deep strategic reasoning. Skeptics are always Opus.

## Collaborative Analysis Architecture

This is the core design challenge. The business-skill-design-guidelines describe the pattern abstractly: "Agents work in parallel, share partial findings via SendMessage, cross-reference and challenge each other's work, synthesize collaboratively, Skeptics validate the synthesis." This section makes it concrete.

### Phase Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                              /plan-sales                                     │
│                                                                              │
│  Phase 1: INDEPENDENT RESEARCH                                               │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                  │
│  │ Market Analyst  │  │ Product Strat. │  │  GTM Analyst   │  (parallel)     │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                  │
│          │                   │                   │                            │
│          ▼                   ▼                   ▼                            │
│     Market Brief        Product Brief        GTM Brief                       │
│          │                   │                   │                            │
│          └───────────────────┼───────────────────┘                            │
│                              ▼                                                │
│                   GATE 1: Lead verifies all                                   │
│                   3 briefs received & complete                                │
│                              │                                                │
│  Phase 2: CROSS-REFERENCING  ▼                                                │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                  │
│  │ Market Analyst  │  │ Product Strat. │  │  GTM Analyst   │  (parallel)     │
│  │ reads Product + │  │ reads Market + │  │ reads Market + │                  │
│  │ GTM briefs      │  │ GTM briefs     │  │ Product briefs │                  │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘                  │
│          │                   │                   │                            │
│          ▼                   ▼                   ▼                            │
│    Cross-Ref Report    Cross-Ref Report    Cross-Ref Report                  │
│          │                   │                   │                            │
│          └───────────────────┼───────────────────┘                            │
│                              ▼                                                │
│                   GATE 2: Lead verifies all                                   │
│                   3 cross-ref reports received                                │
│                              │                                                │
│  Phase 3: SYNTHESIS          ▼                                                │
│  ┌──────────────────────────────────────────┐                                │
│  │  Team Lead synthesizes:                   │                                │
│  │  3 briefs + 3 cross-ref reports           │                                │
│  │  → Draft Sales Strategy Assessment        │                                │
│  └──────────────────────┬───────────────────┘                                │
│                         │                                                     │
│                         ▼  GATE 3: Dual-Skeptic Review                        │
│  Phase 4: REVIEW        │                                                     │
│  ┌────────────────┐  ┌────────────────┐                                      │
│  │   Accuracy      │  │   Strategy     │  (parallel review)                  │
│  │   Skeptic       │  │   Skeptic      │                                      │
│  └───────┬────────┘  └───────┬────────┘                                      │
│          │                   │                                                │
│          ▼                   ▼                                                │
│   Accuracy Verdict    Strategy Verdict                                        │
│          │                   │                                                │
│          └─────────┬─────────┘                                                │
│                    ▼                                                           │
│             BOTH APPROVED?                                                    │
│           ┌──yes──┴──no──┐                                                    │
│           ▼              ▼                                                     │
│  Phase 5: FINALIZE    Phase 3b: REVISE                                        │
│  Lead writes          Lead revises synthesis                                  │
│  final output         with skeptic feedback                                   │
│                       (returns to GATE 3)                                      │
│                                                                               │
│  Max 3 revision cycles before escalation                                      │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Phase Details

#### Phase 1: Independent Research

**Agents**: Market Analyst, Product Strategist, GTM Analyst (parallel)

Each agent investigates their assigned domain independently. They read project artifacts and user-provided data, but do NOT communicate with each other during this phase.

**Inputs** (all agents read):
- `docs/roadmap/_index.md` and individual roadmap files — project state and priorities
- `docs/specs/` — what the product does and plans to do
- `docs/architecture/` — technical decisions and capabilities
- `docs/sales-plans/_user-data.md` — user-provided market data, customer info, pricing context
- `docs/sales-plans/` — prior sales plan assessments (for consistency reference)
- Project root files (README, CLAUDE.md) — project context

**Domain-specific focus:**

| Agent | Primary Focus | Key Questions |
|-------|---------------|---------------|
| Market Analyst | Market sizing, competitive landscape, industry trends | Who are the target customers? How big is the opportunity? Who are the competitors? |
| Product Strategist | Value proposition, differentiation, product-market fit | What problem does this solve? Why is this solution better? What is the unique value? |
| GTM Analyst | Go-to-market channels, pricing, customer acquisition | How do we reach customers? What should pricing look like? What channels work? |

**Output artifact**: Each agent produces a **Domain Brief** — a structured message sent to the Team Lead containing their findings.

**Domain Brief format:**

```
DOMAIN BRIEF: [Market Analysis | Product Strategy | Go-to-Market]
Agent: [agent name]

## Key Findings
- [Finding]: [Evidence or reasoning]. Confidence: [H/M/L]
- ...

## Data Sources Used
- [File path or user data section]: [What was extracted]
- ...

## Assumptions Made
- [Assumption]: [Why it was necessary]. Impact if wrong: [assessment]
- ...

## Data Gaps
- [What's missing]: [Why it matters]. Confidence without this data: [H/M/L]
- ...

## Initial Recommendations
- [Recommendation]: [Supporting evidence]. Confidence: [H/M/L]
- ...

## Questions for Other Analysts
- For [Market Analyst | Product Strategist | GTM Analyst]: [Question about their domain that would strengthen this analysis]
- ...
```

**Transition trigger**: All 3 Domain Briefs received by the Team Lead. The Team Lead performs a lightweight completeness check (Gate 1): Does each brief address its key questions? Are there critical gaps that would prevent meaningful cross-referencing? If a brief is severely incomplete, the Team Lead requests the agent to expand it before proceeding. This is NOT a quality review — just a completeness check.

#### Phase 2: Cross-Referencing

**Agents**: Market Analyst, Product Strategist, GTM Analyst (parallel)

This is the novel phase that distinguishes Collaborative Analysis. Each agent receives the other two agents' Domain Briefs and reviews them through the lens of their own expertise.

**Transition trigger**: Team Lead distributes all 3 Domain Briefs to all 3 agents via SendMessage (each agent receives the two briefs they did not write).

**Cross-referencing tasks:**

Each agent reviews the other two briefs for:

1. **Contradictions**: Does another agent's finding conflict with mine? Example: Market Analyst says "enterprise market is too crowded" but GTM Analyst recommends "enterprise sales channels." The agent flags the contradiction with evidence from both sides.

2. **Gaps I can fill**: Does another agent's analysis miss something I found? Example: Product Strategist identified a key differentiator, but Market Analyst didn't mention it in competitive positioning. The agent fills the gap.

3. **Assumptions I can challenge**: Does another agent assume something I have evidence against? Example: GTM Analyst assumes "developers are the primary buyer" but Product Strategist's analysis shows the product solves a business problem, suggesting business buyers. The agent challenges with evidence.

4. **Synergies**: Do findings across domains reinforce each other? Example: Market Analyst's target segment aligns with GTM Analyst's best-performing channel. The agent highlights the alignment.

5. **Answers to questions**: If another agent asked a question in their "Questions for Other Analysts" section, answer it.

**Cross-Reference Report format:**

```
CROSS-REFERENCE REPORT: [agent name]
Reviewed: [names of the two briefs reviewed]

## Contradictions Found
- [Brief A] says [X] but [Brief B] says [Y].
  My assessment: [Which is more likely correct, based on what evidence]. Confidence: [H/M/L]
- ...
(If none: "No contradictions found between the reviewed briefs and my analysis.")

## Gaps Filled
- [Brief X] did not address [topic].
  From my research: [Finding that fills this gap]. Evidence: [source]. Confidence: [H/M/L]
- ...
(If none: "No significant gaps identified.")

## Assumptions Challenged
- [Brief X] assumes [assumption].
  Challenge: [Why this assumption may be wrong]. Evidence: [source]. Confidence: [H/M/L]
  Suggested revision: [What the finding should say instead]
- ...
(If none: "No assumptions challenged.")

## Synergies Identified
- [Finding from Brief A] + [Finding from Brief B] → [Combined insight].
  Implication: [What this means for the sales strategy]
- ...
(If none: "No cross-domain synergies identified.")

## Answers to Peer Questions
- [Agent X] asked: [question]
  Answer: [response]. Evidence: [source]. Confidence: [H/M/L]
- ...
(If no questions were asked: Section omitted.)

## Revised Recommendations
Based on cross-referencing, I [confirm | revise] my initial recommendations:
- [Recommendation]: [Updated reasoning after seeing peers' work]. Confidence: [H/M/L]
- ...
```

**What happens if agents disagree**: Disagreements are explicitly preserved, not resolved during cross-referencing. When an agent finds a contradiction, they state their assessment of which side is more likely correct and why, but they do NOT override the other agent's finding. Both the original finding and the challenge are forwarded to the synthesis phase, where the Team Lead weighs the evidence and the Skeptics evaluate the resolution.

**Transition trigger**: All 3 Cross-Reference Reports received by the Team Lead. No quality gate here — the reports go directly to synthesis. The cross-referencing phase is designed to surface information, not to produce a finished product.

#### Phase 3: Synthesis

**Agent**: Team Lead

The Team Lead synthesizes all 6 artifacts (3 Domain Briefs + 3 Cross-Reference Reports) into a Draft Sales Strategy Assessment. This is the only phase where the Team Lead writes content (not delegate mode). The Team Lead is uniquely positioned for synthesis because they have the full picture — all briefs, all cross-references, and the user's context.

**Synthesis process:**

1. **Resolve contradictions**: For each contradiction flagged in cross-reference reports, weigh the evidence from both sides and choose the better-supported position. Document the resolution and reasoning.

2. **Integrate gap-fills**: Where one agent filled a gap in another's analysis, incorporate the additional finding into the relevant section.

3. **Evaluate challenged assumptions**: For each challenged assumption, determine whether the challenge is valid. If yes, revise the relevant section. If no, note why the original assumption stands.

4. **Highlight synergies**: Where cross-domain findings reinforce each other, make the connection explicit in the assessment.

5. **Write the assessment**: Produce the full sales strategy assessment in the output format (see Output Artifact Format below).

**Output**: Draft Sales Strategy Assessment written to the Team Lead's working context (not a file yet — it goes to skeptic review first).

**Transition trigger**: Draft assessment complete. Team Lead sends it to both Skeptics for review.

#### Phase 4: Review (Dual-Skeptic)

**Agents**: Accuracy Skeptic + Strategy Skeptic (parallel)

Both skeptics receive the Draft Sales Strategy Assessment AND all 6 source artifacts (3 Domain Briefs + 3 Cross-Reference Reports) so they can trace claims back to evidence.

##### Accuracy Skeptic Checklist

1. **Every claim has evidence.** Market sizes, competitive positions, and growth rates must trace to user-provided data, project artifacts, or be explicitly marked as assumptions. Unsourced claims are flagged.
2. **Projections are grounded.** Revenue estimates, customer counts, and growth rates must be based on stated assumptions, not optimism. Each projection must include confidence level and sensitivity.
3. **Contradictions are resolved, not hidden.** If analysts disagreed, the synthesis must address both sides and explain why one position was chosen. Hiding a contradiction is a rejection-worthy defect.
4. **Data gaps are acknowledged.** Missing data must be stated explicitly. An assessment that claims certainty without data is automatically suspect.
5. **Business quality checklist:**
   - Are assumptions stated, not hidden?
   - Are confidence levels present and justified?
   - Are falsification triggers specific and actionable?
   - Does the output acknowledge what it doesn't know?
   - Are projections grounded in stated evidence, not optimism?

##### Strategy Skeptic Checklist

1. **Strategic coherence.** Does the target market, value proposition, positioning, and go-to-market strategy tell a consistent story? Does the pricing align with the target segment?
2. **Alternative consideration.** Has the assessment considered at least one alternative strategy? An assessment that presents only one path without considering alternatives is incomplete.
3. **Risk assessment is honest.** Are risks substantive or token? "Competition may increase" is token. "Enterprise incumbents have 5-year contracts and switching costs that make displacement a 12-18 month sales cycle" is substantive.
4. **Early-stage appropriateness.** Are recommendations feasible for a startup with limited resources? A strategy requiring a 20-person sales team is not appropriate for a seed-stage company.
5. **Scope discipline.** Does the assessment stay within "sales strategy assessment for early-stage startup"? Scope creep into financial modeling, operations planning, or product roadmapping is a rejection-worthy defect.
6. **Business quality checklist:**
   - Would a domain expert find the framing credible?
   - Are projections grounded in stated evidence, not optimism?

##### Review Verdicts

Each skeptic independently produces:

```
[ACCURACY|STRATEGY] REVIEW: Sales Strategy Assessment
Verdict: APPROVED / REJECTED

[If rejected:]
Issues:
1. [Specific issue]: [Why it's a problem]. [Evidence reference]. Fix: [What to do]
2. ...

[If approved:]
Notes: [Any minor observations]
```

**Gate 3 rule**: BOTH skeptics must approve. If either rejects, the assessment returns to Phase 3b (Revise).

#### Phase 3b: Revise

**Agent**: Team Lead

The Team Lead revises the synthesis based on skeptic feedback. The revision must address every blocking issue explicitly — the Team Lead documents what changed and why.

The revised draft returns to Gate 3 (both skeptics review again). Maximum 3 revision cycles before escalation to the human operator.

#### Phase 5: Finalize

**Agent**: Team Lead

When both skeptics approve, the Team Lead:
1. Writes the final sales strategy assessment to `docs/sales-plans/{date}-sales-strategy.md`
2. Writes a progress summary to `docs/progress/plan-sales-summary.md`
3. Writes a cost summary to `docs/progress/plan-sales-{date}-cost-summary.md`
4. Outputs the final assessment to the user with instructions for review and implementation

## Output Artifact Format

The sales strategy assessment follows a structured template:

```markdown
---
type: "sales-strategy"
period: "YYYY-MM-DD"
generated: "YYYY-MM-DD"
confidence: "high|medium|low"
review_status: "approved"
approved_by:
  - accuracy-skeptic
  - strategy-skeptic
---

# Sales Strategy Assessment: {Project Name}

## Executive Summary

<!-- 3-5 sentences. The single most important strategic insight for the founder. -->

## Target Market

### Primary Segment
<!-- Who is the ideal customer? What problem do they have? Why now? -->

### Market Sizing
<!-- TAM/SAM/SOM estimates with stated methodology and confidence levels. -->
<!-- If data insufficient: "[Requires user input -- see docs/sales-plans/_user-data.md]" -->

| Metric | Estimate | Methodology | Confidence |
|--------|----------|-------------|------------|
| TAM | ... | ... | H/M/L |
| SAM | ... | ... | H/M/L |
| SOM | ... | ... | H/M/L |

## Competitive Positioning

### Competitive Landscape
<!-- Key competitors, their strengths and weaknesses. -->

### Differentiation
<!-- What makes this product uniquely valuable? Why would customers choose this? -->

### Positioning Statement
<!-- One-paragraph positioning statement following standard framework. -->

## Value Proposition

<!-- Core value proposition: what problem is solved, for whom, and why this solution is better. -->
<!-- Evidence from project artifacts: what does the product actually do? -->

## Go-to-Market Strategy

### Recommended Channels
<!-- Ranked by expected effectiveness for this target segment. -->

| Channel | Rationale | Effort | Expected Impact | Confidence |
|---------|-----------|--------|-----------------|------------|
| ... | ... | H/M/L | H/M/L | H/M/L |

### Customer Acquisition
<!-- How to find and convert early customers. Specific, actionable steps. -->

### Sales Process
<!-- Recommended sales process for the target segment. Keep it simple for early-stage. -->

## Pricing Considerations

<!-- Pricing model recommendations. Competitor benchmarks if available. -->
<!-- Value-based vs. cost-plus vs. competitive pricing analysis. -->
<!-- This is guidance, not a pricing decision. -->

## Strategic Risks

<!-- Substantive risk assessment, not token risks. -->
<!-- Each risk includes: what it is, likelihood, impact, and mitigation. -->

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ... | H/M/L | H/M/L | ... |

## Recommended Next Steps

<!-- 3-5 specific, actionable next steps the founder should take. -->
<!-- Prioritized by impact and feasibility for an early-stage startup. -->

1. [Action]: [Why]. [Expected outcome]. [Timeline suggestion]
2. ...

---

## Assumptions & Limitations

<!-- Mandatory per business skill design guidelines. -->
<!-- What this assessment assumes to be true. What data was unavailable. -->

## Confidence Assessment

<!-- Mandatory per business skill design guidelines. -->
<!-- Per-section confidence levels with rationale. -->

| Section | Confidence | Rationale |
|---------|------------|-----------|
| Target Market | H/M/L | ... |
| Competitive Positioning | H/M/L | ... |
| Value Proposition | H/M/L | ... |
| Go-to-Market | H/M/L | ... |
| Pricing | H/M/L | ... |
| Outlook | H/M/L | ... |

## Falsification Triggers

<!-- Mandatory per business skill design guidelines. -->
<!-- What evidence would change the conclusions in this assessment? -->

- If [condition], then [conclusion X] should be revised because [reason]
- ...

## External Validation Checkpoints

<!-- Mandatory per business skill design guidelines. -->
<!-- Where should a human domain expert validate this assessment? -->

- [ ] Verify [specific claim] with [data source or person]
- ...
```

## User Data Input

Sales strategy assessment requires significant external data that cannot be auto-detected from project files. The user provides this via a template file.

### Mechanism: Template File

A template file at `docs/sales-plans/_user-data.md` that the user populates before running the skill. All analysis agents read this file alongside project artifacts.

### Template Format

```markdown
# Sales Planning: User-Provided Data

> Fill in the sections below before running `/plan-sales`.
> The more you provide, the more specific the assessment will be.
> Leave sections blank if not applicable -- the assessment will note the gaps.

## Product & Market

- Product description (1-2 sentences):
- Target customer profile:
- Problem being solved:
- Current stage (idea / MVP / launched / revenue):
- Existing customers (count and type):

## Market Context

- Industry/vertical:
- Known competitors:
- Market trends or tailwinds:
- Market size estimates (if known):

## Current Sales

- Current revenue (MRR/ARR):
- Sales channels in use:
- Average deal size:
- Sales cycle length:
- Win rate (if known):

## Pricing

- Current pricing model:
- Current price points:
- Competitor pricing (if known):

## Constraints

- Team size / sales headcount:
- Budget for sales & marketing:
- Geographic focus:
- Timeline constraints:

## Additional Context

<!-- Anything else relevant to sales strategy that isn't captured above. -->
```

### Graceful Degradation

- **File missing**: All agents note data gaps in their Domain Briefs. Assessment uses project artifact data with explicit low-confidence markers. The skill also outputs the template to `docs/sales-plans/_user-data.md` so the user has it for next time.
- **File partially filled**: Agents extract available data, note missing fields as gaps.
- **File empty/template-only**: Treated same as missing.

## What Is New vs. Reusable

### Reusable from Existing Skills

| Component | Source | Adaptation Needed |
|-----------|--------|-------------------|
| YAML frontmatter format | All SKILL.md files | New fields: `type: sales-strategy` in output |
| Shared Principles section | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers |
| Communication Protocol section | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers; skeptic names adapted |
| Checkpoint Protocol | plan-product/SKILL.md | Phase enum changes: `research \| cross-reference \| synthesis \| review \| revision \| complete` |
| Write Safety conventions | All SKILL.md files | Same pattern, different role names |
| Failure Recovery | All SKILL.md files | Same 3 patterns (unresponsive, deadlock, context exhaustion) |
| Lightweight Mode | All SKILL.md files | Analysis agents -> sonnet; Skeptics stay opus |
| Determine Mode with status/resume | All SKILL.md files | Same checkpoint-based resume pattern |
| Setup section | All SKILL.md files | Adds `docs/sales-plans/` to directory list |
| Business quality sections | draft-investor-update | Same mandatory sections (Assumptions, Confidence, Falsification, External Validation) |
| Dual-skeptic gate | draft-investor-update | Same both-must-approve rule; different skeptic specializations |

### New Patterns Introduced

| Pattern | Description | Why It Is Needed |
|---------|-------------|-----------------|
| **Collaborative Analysis phases** | 5-phase flow with cross-referencing between parallel agents. No existing skill has agents reading and reacting to each other's partial work mid-process. | First implementation of the Collaborative Analysis consensus pattern from the design guidelines. |
| **Domain Briefs** | Structured partial-finding artifacts shared between peers. Unlike the Research Dossier (one agent to lead) or Pipeline artifacts (one agent to next), these go from each agent to all other agents. | Cross-referencing requires each agent to have access to all peers' findings in a parseable format. |
| **Cross-Reference Reports** | Structured artifacts where each agent evaluates peers' findings for contradictions, gaps, challenges, and synergies. | This is the "cross-reference and challenge" step that distinguishes Collaborative Analysis. No existing skill has this. |
| **Lead-driven synthesis** | Team Lead writes the assessment content (not an agent). In Pipeline, a Drafter agent writes. In Hub-and-Spoke, the lead aggregates. Here, the lead must resolve contradictions and integrate cross-references. | The synthesis requires weighing contradictory evidence from multiple sources. A separate Drafter agent would need the full context of all 6 artifacts plus cross-references, making the lead the natural synthesizer. |
| **Output directory** | `docs/sales-plans/` as a new output location. | Sales plans are a new artifact type that don't fit existing directory categories. |
| **Strategy Skeptic** | New skeptic specialization focused on strategic coherence, alternatives consideration, and early-stage feasibility. | Sales strategy has different failure modes than accuracy alone. A strategy can be factually accurate but strategically incoherent. |

### Design Decision: Lead-Driven Synthesis (Not a Drafter Agent)

In the Pipeline pattern (draft-investor-update), a separate Drafter agent composes the output from the Research Dossier. In Collaborative Analysis, the Team Lead performs synthesis directly. Rationale:

1. **Context load**: The synthesizer must hold 6 artifacts (3 briefs + 3 cross-refs) in working memory simultaneously. A newly-spawned Drafter would need all of this context passed via messages, risking context exhaustion. The Team Lead already has this context from orchestrating Phases 1-2.

2. **Contradiction resolution**: The Team Lead observed the cross-referencing process and has meta-context about which agents' findings were more evidence-based. A Drafter agent would only see the text, not the process.

3. **Fewer agents, lower cost**: Eliminating the Drafter role removes one agent from the team. With 3 analysis agents + 2 skeptics already (5 total), adding a Drafter would bring the team to 6 agents — a higher cost with marginal benefit.

4. **Precedent**: This is consistent with Hub-and-Spoke (plan-product), where the lead aggregates findings. The difference here is that the lead must also resolve contradictions surfaced by cross-referencing, which requires judgment the lead is well-positioned to exercise.

## CI Validator Impact

### Existing Validators — Impact

| Validator | Impact | Changes Needed |
|-----------|--------|---------------|
| `skill-structure.sh` | Works as-is | None — the skill is multi-agent, so standard section checks apply |
| `skill-shared-content.sh` | Needs extension | New skeptic names must be added to the normalize function (see below) |
| `spec-frontmatter.sh` | Not applicable | Output goes to `docs/sales-plans/`, not `docs/specs/` |
| `roadmap-frontmatter.sh` | Not applicable | The skill does not modify roadmap files |
| `progress-checkpoint.sh` | Works as-is | Checkpoint files follow the standard format with `team: "plan-sales"` |

### New Skeptic Names for `skill-shared-content.sh`

The normalize function in `skill-shared-content.sh` currently handles these skeptic name variants:

```
product-skeptic / Product Skeptic
quality-skeptic / Quality Skeptic
ops-skeptic / Ops Skeptic
accuracy-skeptic / Accuracy Skeptic
narrative-skeptic / Narrative Skeptic
```

The plan-sales skill introduces one new skeptic name: `strategy-skeptic` / `Strategy Skeptic`. The `accuracy-skeptic` / `Accuracy Skeptic` pair is already handled (added for draft-investor-update).

The normalize function must be extended with:

```bash
-e 's/strategy-skeptic/SKEPTIC_NAME/g' \
-e 's/Strategy Skeptic/SKEPTIC_NAME/g'
```

This is a small, additive change to the existing `normalize_skeptic_names` function — two new sed expressions.

### New Output Directory

The skill writes final outputs to `docs/sales-plans/`. This directory is created by the skill itself in its Setup section, following the same pattern as `draft-investor-update` creating `docs/investor-updates/`.

## SKILL.md Structure

The SKILL.md will follow the standard multi-agent format with all required sections:

```
---
name: plan-sales
description: >
  Assess sales strategy for early-stage startups. Parallel analysis agents
  research market, product positioning, and go-to-market, then cross-reference
  and challenge each other's findings before dual-skeptic validation.
argument-hint: "[--light] [status | (empty for new assessment)]"
---

# Sales Strategy Team Orchestration
(Team Lead instructions)

## Setup
(Directory creation, stack detection, read project state, read user data)

## Write Safety
(Standard pattern with role-scoped files)

## Checkpoint Protocol
(Standard pattern with phases: research | cross-reference | synthesis | review | revision | complete)

## Determine Mode
(status, empty/resume)

## Lightweight Mode
(Analysis agents -> sonnet; Skeptics stay opus)

## Spawn the Team
### Market Analyst (opus)
### Product Strategist (opus)
### GTM Analyst (opus)
### Accuracy Skeptic (opus)
### Strategy Skeptic (opus)

## Orchestration Flow
(Collaborative Analysis phases 1-5 as described above)

## Quality Gate
(Dual-skeptic: both must approve)

## Failure Recovery
(Standard 3 patterns)

## Shared Principles
(Copied from plan-product/SKILL.md with shared markers)

## Communication Protocol
(Copied from plan-product/SKILL.md with shared markers)

## Teammate Spawn Prompts
(Detailed prompts for each role)
```

## Arguments

| Argument | Effect |
|----------|--------|
| (empty) | Scan for in-progress sessions. If found, resume. Otherwise, start new assessment. |
| `status` | Report on in-progress session without spawning agents. |
| `--light` | Analysis agents use sonnet instead of opus. Skeptics remain opus. |

## Integration Points

### With Existing Skills

- **plan-product**: Sales assessment reads the same roadmap and spec artifacts that plan-product creates. No write conflicts — plan-sales is read-only with respect to these files.
- **draft-investor-update**: Sales assessment output can inform future investor updates (forward-looking sales strategy vs. retrospective progress). Read-only dependency.
- **build-product**: Sales assessment reads progress files for understanding current product state. Read-only.
- **build-sales-collateral** (future P3-16): The sales strategy assessment produced by `/plan-sales` is the natural input for `/build-sales-collateral`. This validates the skeptic's observation from Review Cycle 4 that P3-16 has a practical dependency on P3-10.

### With Plugin System

- Registered in `plugin.json` alongside existing skills
- Lives at `plugins/conclave/skills/plan-sales/SKILL.md`
- Uses the same YAML frontmatter format

### New Artifacts

| Artifact | Location | Created By |
|----------|----------|-----------|
| Sales strategy assessments | `docs/sales-plans/{date}-sales-strategy.md` | Team Lead (final output) |
| User data template | `docs/sales-plans/_user-data.md` | Team Lead (first-run only) |
| Checkpoint files | `docs/progress/plan-sales-{role}.md` | Each agent |
| Session summary | `docs/progress/plan-sales-summary.md` | Team Lead |
| Cost summary | `docs/progress/plan-sales-{date}-cost-summary.md` | Team Lead |

## First-Run Behavior

1. **No prior sales plans exist**: Agents skip consistency checks with prior plans. Expected behavior.
2. **No `_user-data.md` exists**: All agents flag user-data sections as gaps. Assessment uses project artifacts only, with explicit low-confidence markers. Skill creates the template file at `docs/sales-plans/_user-data.md`.
3. **No `docs/sales-plans/` directory exists**: Skill creates it in Setup.

## Non-Goals

1. **No real-time data gathering.** The skill reads project artifacts and user-provided data on disk. It does not query APIs, databases, or external services.
2. **No financial modeling.** The assessment provides pricing considerations and market sizing guidance, not financial projections or revenue models.
3. **No CRM integration.** No pipeline management, deal tracking, or sales forecasting.
4. **No enterprise sales strategy.** The scope is early-stage startup sales. Enterprise sales motions, channel partner programs, and complex multi-stakeholder deals are out of scope.
5. **No template customization at runtime.** The output format is fixed in the SKILL.md.
