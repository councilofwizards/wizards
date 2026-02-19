---
feature: "plan-sales"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed comprehensive research on /plan-sales problem space and Collaborative Analysis pattern"
updated: "2026-02-19"
---

# Research Findings: /plan-sales Problem Space and Collaborative Analysis Pattern

## Summary

`/plan-sales` will be the second business skill and the first Collaborative Analysis skill in the conclave framework. This research covers: (1) the early-stage startup sales planning problem space, (2) available project data and auto-detection capabilities, (3) a concrete protocol for the Collaborative Analysis pattern, (4) user data requirements, (5) agent team composition, (6) comparison with existing patterns, and (7) risks.

---

## 1. Problem Space: Early-Stage Startup Sales Strategy Assessment

**Scope constraint (per Review Cycle 4 skeptic, mandatory):** Sales strategy assessment for early-stage startups only. NOT full sales operations.

### What Founders Need

Early-stage founders typically lack dedicated sales leadership and make sales decisions ad-hoc. A structured sales strategy assessment should cover:

**Core deliverables (scoped to strategy assessment):**

1. **Target Market Assessment** -- Who are the ideal customers? What segments are most likely to convert? What is the total addressable market (TAM), serviceable addressable market (SAM), and serviceable obtainable market (SOM)?

2. **Competitive Positioning** -- How does the product compare to alternatives? What is the unique value proposition? Where does the product win vs. lose against competitors?

3. **Pricing Strategy** -- What pricing model fits the market? What are comparable products charging? What is the pricing floor (cost) and ceiling (value)? Is the model sustainable?

4. **Go-to-Market Approach** -- What channels will reach the target customers? What is the initial sales motion (product-led, sales-led, community-led)? What is the minimum viable sales process?

5. **Sales Pipeline Framework** -- What does the customer journey look like (awareness -> consideration -> decision -> purchase)? What are the key conversion points? What metrics matter at each stage?

6. **Key Risks & Assumptions** -- What must be true for this strategy to work? What are the biggest unknowns? What would invalidate the strategy?

**What this is NOT:**

- Not a CRM setup or sales operations toolkit
- Not a sales forecasting engine (no revenue modeling)
- Not a lead generation system
- Not a sales team hiring plan (that's `/plan-hiring`)
- Not a marketing strategy (that's `/plan-marketing`)
- Not a customer success plan (that's `/plan-customer-success`)

**Confidence: HIGH** that this scope is appropriate. These 6 areas represent the strategic foundation that precedes sales execution. The scope is narrow enough to be deliverable and broad enough to be useful.

---

## 2. Available Project Data and Auto-Detection

### What Can Be Auto-Detected from Project Artifacts

| Data Source | What's Extractable | Relevant For |
|-------------|-------------------|--------------|
| `README.md` | Product description, value proposition, feature list | Target market, competitive positioning |
| `docs/roadmap/_index.md` | Feature priorities, product direction, status | Go-to-market timing, product capabilities |
| `docs/specs/` | Feature specifications, technical capabilities | Value proposition refinement, competitive features |
| `docs/architecture/` | Technical decisions, system design | Technical differentiation, scalability claims |
| `docs/progress/` | Implementation status, velocity data | Timeline credibility, capacity claims |
| `docs/investor-updates/` (if exists) | Prior updates, financial context | Strategic context, past assumptions |
| `package.json` / `composer.json` / etc. | Tech stack, dependencies | Technical positioning |

**Evidence**: The current project has: README.md (product description), docs/roadmap/_index.md (31 items with priorities and status), 9 specs in docs/specs/, 8 architecture docs, and extensive progress files. Source: filesystem listing above.

### What Cannot Be Auto-Detected (Requires User Input)

| Data Category | Why It's Needed | Why It Can't Be Auto-Detected |
|--------------|-----------------|-------------------------------|
| **Market data** | TAM/SAM/SOM, market growth, trends | External to project files |
| **Competitive intel** | Competitor names, pricing, features, positioning | External to project files |
| **Customer personas** | Ideal customer profiles, pain points, buying behavior | External to project files |
| **Pricing information** | Current pricing, cost structure, margins | Not in project artifacts |
| **Existing sales data** | Pipeline metrics, conversion rates, deal sizes | Not in project artifacts |
| **Business model** | Revenue model, unit economics, customer lifetime value | Not in project artifacts |
| **Strategic context** | Funding stage, runway, growth targets, board priorities | Not in project artifacts |

**Assessment (Confidence: HIGH):** The ratio of user-provided to auto-detected data is much higher for `/plan-sales` than for `/draft-investor-update`. Investor updates are primarily project-data-driven with user data as supplementary. Sales planning is primarily user-data-driven with project data as supplementary. This is a fundamental difference that affects the skill design.

---

## 3. Collaborative Analysis Pattern: Concrete Protocol

**Mandatory constraint (per Review Cycle 4 skeptic):** The spec MUST define "cross-referencing" concretely -- message timing, content, and synthesis protocol.

### Current Definition (from business-skill-design-guidelines.md)

> "Agents work in parallel -> share partial findings via SendMessage -> cross-reference and challenge each other's work -> synthesize collaboratively -> Skeptics validate the synthesis."

This is abstract. Below is a concrete proposal for how to implement it.

### Proposed Concrete Protocol: Phase-Gated Collaborative Analysis

The key insight is that Collaborative Analysis is NOT free-form collaboration. It is **structured parallel research with defined sharing points**. Agents work on their own domains but share findings at phase boundaries, and each agent must explicitly acknowledge and incorporate relevant cross-domain findings.

#### Phase 1: Independent Research (Parallel)

**What happens:** Each research agent investigates their assigned domain independently.

**Duration:** Until each agent completes their initial domain analysis.

**Sharing:** Agents write findings to their individual progress files. No cross-referencing yet.

**Gate:** Each agent sends a "FINDINGS READY" message to the Team Lead when their initial research is complete.

#### Phase 2: Cross-Reference Exchange (Parallel with Messaging)

**Trigger:** Team Lead broadcasts "BEGIN CROSS-REFERENCE" once all (or a configurable threshold of) research agents report findings ready.

**What happens:** Each agent reads the other agents' progress files. Each agent then:
1. Identifies findings from other agents that **support, contradict, or extend** their own findings
2. Sends structured cross-reference messages to the relevant agents
3. Updates their own findings based on cross-domain insights

**Message structure for cross-references:**

```
CROSS-REFERENCE: [topic]
From: [my domain]
Re: [their finding in their progress file]
Type: SUPPORTS | CONTRADICTS | EXTENDS | QUESTION
Details: [1-3 sentences explaining the connection]
Impact on my findings: [how this changes my analysis]
Action needed: [yes/no — if yes, what]
```

**Gate:** Each agent sends "CROSS-REFERENCE COMPLETE" to Team Lead when they have reviewed all other agents' findings and updated their own. Each agent must cite at least one cross-reference (to prove they actually read others' work). If an agent finds zero relevant cross-references, they must explicitly state "No cross-domain connections found" with rationale.

#### Phase 3: Challenge Round (Parallel with Messaging)

**Trigger:** Team Lead broadcasts "BEGIN CHALLENGE" once all agents complete cross-referencing.

**What happens:** Each agent reviews the OTHER agents' updated findings (post-cross-reference) and raises challenges:

```
CHALLENGE: [specific claim or recommendation]
Target: [agent name]
Issue: [why this claim is questionable]
Evidence: [what contradicts it or what's missing]
Suggested resolution: [what to do instead]
```

**Gate:** Agents send "CHALLENGES COMPLETE" to Team Lead. If no challenges are raised, the phase is skipped (but this should be rare if agents are doing their jobs).

#### Phase 4: Synthesis (Lead-Coordinated)

**Trigger:** Team Lead broadcasts "BEGIN SYNTHESIS" once all challenges are resolved or acknowledged.

**Who synthesizes:** The Team Lead assigns synthesis responsibility. Two options:

- **Option A (recommended for v1):** A designated Synthesizer agent produces the synthesis from all agents' final findings. Other agents review the synthesis for accuracy of their domain.
- **Option B:** Each agent writes their section of the final output, and the Team Lead merges them.

**Output:** A complete sales strategy assessment document with:
- Each section attributed to the contributing agent(s)
- Cross-references cited inline (e.g., "This pricing recommendation accounts for the competitive positioning analysis [see Section 2]")
- Disagreements between agents noted and resolved (or flagged as open questions)

#### Phase 5: Dual-Skeptic Review (Parallel)

**What happens:** Both Accuracy Skeptic and Strategy Skeptic review the synthesis + all agent findings (for evidence tracing).

**Gate:** Both must approve. Rejection sends specific sections back to the relevant agents.

### Why This Protocol Works

1. **Phase-gated sharing prevents chaos.** Free-form real-time messaging between research agents would create noise and context bloat. Phase gates ensure agents focus on their domain first, then cross-reference.

2. **Structured cross-reference messages are parseable.** Context-constrained agents need structured messages to process efficiently. The SUPPORTS/CONTRADICTS/EXTENDS/QUESTION taxonomy forces agents to classify the relationship.

3. **The challenge round enforces intellectual honesty.** Without an explicit challenge phase, agents tend to politely accept each other's findings. A dedicated challenge round requires agents to look for problems.

4. **Synthesis has clear ownership.** Without a designated synthesizer, the "synthesize collaboratively" instruction from the guidelines would produce inconsistent outputs.

### How This Differs from Hub-and-Spoke (plan-product)

| Dimension | Hub-and-Spoke (plan-product) | Collaborative Analysis (plan-sales) |
|-----------|------------------------------|--------------------------------------|
| Agent interaction | Agents work independently; Lead aggregates | Agents read and respond to each other's work |
| Cross-referencing | None; agents are siloed | Mandatory; agents must cite cross-references |
| Challenge mechanism | Skeptic challenges final output | Agents challenge each other BEFORE skeptic review |
| Synthesis | Lead aggregates outputs | Designated synthesizer combines findings |
| Phase structure | Research + Design (parallel) -> Skeptic review | Research (parallel) -> Cross-reference -> Challenge -> Synthesis -> Skeptic review |

### How This Differs from Pipeline (draft-investor-update)

| Dimension | Pipeline (draft-investor-update) | Collaborative Analysis (plan-sales) |
|-----------|----------------------------------|--------------------------------------|
| Agent concurrency | Sequential stages | Parallel research with phase-gated sharing |
| Handoff mechanism | Complete artifact between stages | Partial findings shared via messages + files |
| Iteration | Drafter revises based on skeptic feedback | Agents iterate with each other before skeptic sees output |
| Agent autonomy | Each agent has a narrow, sequential role | Each agent has broad domain authority and challenges peers |

**Confidence: MEDIUM-HIGH.** The protocol is architecturally sound and addresses the skeptic's mandatory constraint. However, the specifics of cross-reference timing (e.g., threshold for "all agents ready" vs. waiting for stragglers) and challenge resolution (how to handle unresolved disagreements) need to be refined during the architecture phase.

---

## 4. User Data Requirements

### Proposed Template: `docs/sales-plans/_user-data.md`

Following the pattern established by `/draft-investor-update` (which uses `docs/investor-updates/_user-data.md`):

```markdown
---
period: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
---

# Sales Strategy Assessment: User-Provided Data

> Fill in the sections below before running `/plan-sales`.
> Delete placeholder text and replace with your data.
> Leave sections blank if not applicable -- the assessment will note what data was unavailable.

## Company Overview

- Product name:
- One-line description:
- Current stage: (pre-revenue | early revenue | growth)
- Funding status: (bootstrapped | pre-seed | seed | series-A | etc.)
- Monthly runway:

## Target Market

- Primary customer type: (B2B | B2C | B2B2C)
- Target company size: (solo | SMB | mid-market | enterprise)
- Target industry/vertical:
- Geographic focus:
- Known customer pain points:

## Current Sales Data (if any)

- Current MRR/ARR:
- Number of paying customers:
- Average deal size:
- Sales cycle length:
- Current conversion rate (trial-to-paid or lead-to-customer):
- Primary acquisition channel:

## Competitive Landscape

- Direct competitors (name, pricing, key differentiator):
  1.
  2.
  3.
- Indirect competitors / alternatives:
- Key competitive advantages of your product:
- Key competitive disadvantages:

## Pricing

- Current pricing model: (freemium | free trial | paid-only | enterprise-only)
- Current price points:
- Pricing constraints or goals:

## Goals & Constraints

- Revenue target (next 6-12 months):
- Key milestones (e.g., first 10 customers, $10k MRR):
- Resource constraints (team size, budget for sales):
- Non-negotiable requirements:

## Additional Context

<!-- Anything else that would help the sales strategy assessment -->
```

### Graceful Degradation (following investor-update pattern)

- **File missing:** All sections that depend on user data get "[Requires user input -- see docs/sales-plans/_user-data.md]" placeholders. The skill still produces a strategy assessment based on available project data, but it will be heavily qualified.
- **File partially filled:** Populated fields are used; empty fields get placeholders.
- **File empty/template-only:** Treated same as missing.

### Comparison with Investor Update User Data

| Dimension | Investor Update `_user-data.md` | Sales Plan `_user-data.md` |
|-----------|-------------------------------|---------------------------|
| Fields | 4 sections, ~15 fields | 6 sections, ~25 fields |
| Importance to output | Supplementary (most data is project-derived) | Primary (most analysis depends on this data) |
| First-run impact | Update still useful without user data | Assessment is significantly less useful without user data |

**Risk (Confidence: HIGH):** Unlike investor updates, where project artifacts provide 70-80% of the needed data, sales planning relies on user-provided data for 60-70% of the analysis. If the user doesn't populate `_user-data.md`, the output will be heavily placeholder-laden and of limited value. The skill should prominently warn the user about this dependency at invocation time.

---

## 5. Agent Team Composition

### Recommended Team

| Role | Name | Model | Responsibility | Domain |
|------|------|-------|---------------|--------|
| Team Lead | (invoking agent) | opus | Orchestrate phases, manage cross-referencing, write final output | Coordination |
| Market Researcher | `market-researcher` | opus | External market context: TAM/SAM/SOM, market trends, competitive landscape, industry dynamics | Market analysis |
| Product Analyst | `product-analyst` | opus | Internal product analysis: feature capabilities, technical differentiation, product-market fit assessment, value proposition | Product analysis |
| Strategy Synthesizer | `strategy-synthesizer` | sonnet | Pull findings together into coherent strategy: pricing, GTM, pipeline framework, integrated recommendations | Synthesis |
| Accuracy Skeptic | `accuracy-skeptic` | opus | Verify claims, projections, market data citations, evidence quality | Accuracy |
| Strategy Skeptic | `strategy-skeptic` | opus | Challenge strategic assumptions, alternative strategies, competitive blind spots, risk assessment | Strategy |

### Rationale for 3 Research/Analysis Agents + 2 Skeptics

**Why separate Market Researcher and Product Analyst:**
- Market Researcher focuses on EXTERNAL context (competitors, market size, industry trends). This requires reasoning about data the user provides about the external world.
- Product Analyst focuses on INTERNAL context (product capabilities, technical differentiation, development velocity). This can be partially auto-detected from project artifacts.
- Separating these domains ensures neither gets shortchanged. In Hub-and-Spoke (plan-product), a single Researcher covers everything. In Collaborative Analysis, the value comes from specialists who cross-reference -- a market insight should inform the product analysis, and vice versa.

**Why Strategy Synthesizer uses Sonnet:**
- Following the pattern from `/draft-investor-update` where the Drafter uses Sonnet. The Synthesizer is executing a well-defined composition task from structured inputs (research findings). The research and skeptic roles require deeper reasoning (Opus).
- **Risk note (same as investor-update Drafter):** If the Synthesizer cannot produce a strategy that satisfies both skeptics within 2 revision cycles, the Team Lead should consider upgrading to Opus.

**Why not a dedicated Pricing Analyst or GTM Specialist:**
- Adding more agents increases cost linearly. 5 agents (3 research + 2 skeptic) is already substantial.
- Pricing analysis and GTM planning naturally emerge from the intersection of market research and product analysis. The cross-referencing protocol ensures these topics get covered without needing a dedicated agent.
- The Strategy Synthesizer pulls the pricing and GTM threads together from the research agents' findings.

### Why This Team Differs from Plan-Product

| Dimension | Plan-Product | Plan-Sales |
|-----------|-------------|-----------|
| Research agents | 1 (Researcher) | 2 (Market Researcher + Product Analyst) |
| Design agents | 2 (Architect + DBA) | 0 (no system design needed) |
| Synthesis | Lead aggregates | Strategy Synthesizer agent |
| Skeptics | 1 (Product Skeptic) | 2 (Accuracy + Strategy) |
| Total agents | 4 + lead | 5 + lead |

The shift from design agents (Architect, DBA) to a second research agent and a synthesis agent reflects the shift from "design a system" to "analyze a market and produce a strategy."

### Why This Team Differs from Draft-Investor-Update

| Dimension | Draft-Investor-Update | Plan-Sales |
|-----------|----------------------|-----------|
| Researching agents | 1 (Researcher) | 2 (Market Researcher + Product Analyst) |
| Production agents | 1 (Drafter) | 1 (Strategy Synthesizer) |
| Skeptics | 2 (Accuracy + Narrative) | 2 (Accuracy + Strategy) |
| Concurrency | Sequential (pipeline) | Parallel research + phased collaboration |

---

## 6. Output Artifact Format

Following the business-skill-design-guidelines mandatory requirements, the output should include:

```markdown
---
type: "sales-strategy-assessment"
generated: "YYYY-MM-DD"
stage: "early-stage"
confidence: "high|medium|low"
review_status: "approved"
approved_by:
  - accuracy-skeptic
  - strategy-skeptic
---

# Sales Strategy Assessment

## Executive Summary
<!-- 3-5 sentences. The single most important strategic insight. -->

## Target Market Assessment
### Market Overview
### Ideal Customer Profile
### Total Addressable Market (TAM/SAM/SOM)
### Market Trends

## Competitive Positioning
### Competitive Landscape
### Unique Value Proposition
### Competitive Advantages & Disadvantages
### Differentiation Strategy

## Pricing Strategy
### Pricing Model Recommendation
### Price Point Analysis
### Pricing Rationale

## Go-to-Market Approach
### Sales Motion (product-led / sales-led / hybrid)
### Channel Strategy
### Initial Sales Process
### First 90 Days Priorities

## Sales Pipeline Framework
### Customer Journey Map
### Key Conversion Points
### Metrics to Track
### Pipeline Health Indicators

## Key Risks & Open Questions
### Strategy Risks
### Market Risks
### Execution Risks

---

## Assumptions & Limitations
## Confidence Assessment
| Section | Confidence | Rationale |
|---------|------------|-----------|
## Falsification Triggers
## External Validation Checkpoints
```

---

## 7. Risks

### Risk 1: Quality Without Ground Truth (HIGH concern)

**Description:** Sales projections and market assessments cannot be verified against code or tests. Unlike investor updates (which report on verifiable project data), sales planning involves forward-looking market claims that may be plausible but wrong.

**Mitigation:** The business-skill-design-guidelines framework already mandates Assumptions & Limitations, Confidence levels, Falsification triggers, and External validation checkpoints. The Accuracy Skeptic specifically verifies that claims are evidence-traced. The Strategy Skeptic specifically challenges strategic assumptions.

**Residual risk:** Even with these mitigations, a well-structured but wrong market assessment looks exactly like a well-structured correct one. The External Validation Checkpoints section must be particularly robust for sales planning, directing the user to validate specific claims with domain experts, potential customers, and market data sources.

**Confidence: HIGH** that this is a real risk. **Confidence: MEDIUM** that the existing mitigations are sufficient.

### Risk 2: Heavy User Data Dependency (HIGH concern)

**Description:** As noted in section 4, 60-70% of the analysis depends on user-provided data. An empty `_user-data.md` produces an assessment that is mostly placeholders.

**Mitigation:**
1. The skill should check for `_user-data.md` completeness at invocation time and warn the user prominently if key sections are missing.
2. The output should clearly distinguish between "analysis based on provided data" and "generic guidance due to missing data."
3. The Template should be designed to be quick to fill (structured fields, not open-ended prose).

**Residual risk:** Some users will skip the data template and expect useful output. The skill should still run (following the investor-update precedent) but the output quality will be poor.

**Confidence: HIGH** that this is a real risk and a significant UX concern.

### Risk 3: Scope Creep (MEDIUM concern)

**Description:** "Sales planning" is a broad domain. Without discipline, the skill could try to cover market sizing, competitive analysis, pricing optimization, lead generation, CRM setup, sales team hiring, forecasting, and more.

**Mitigation:** The scope constraint from Review Cycle 4 skeptic is clear: "sales strategy assessment for early-stage startups." The spec must define explicit out-of-scope items (similar to the investor-update spec's Out of Scope section).

**Residual risk:** Low, if the spec is disciplined about scope.

### Risk 4: Cross-Referencing Complexity (MEDIUM concern)

**Description:** The Collaborative Analysis cross-referencing protocol (section 3) requires agents to read each other's partial findings and produce structured cross-reference messages. This is more complex than Pipeline (sequential handoffs) or Hub-and-Spoke (independent work). Agents may either ignore cross-references (reducing the pattern to Hub-and-Spoke) or spend excessive context on cross-referencing (context bloat).

**Mitigation:**
1. Structured cross-reference messages with a fixed taxonomy (SUPPORTS/CONTRADICTS/EXTENDS/QUESTION)
2. Minimum cross-reference requirement (each agent must cite at least one)
3. Phase gates prevent free-form messaging chaos
4. Context management: cross-reference messages are concise (1-3 sentences per item)

**Residual risk:** This is the first implementation of Collaborative Analysis. The protocol is a best-guess design. It may need adjustment after the first run.

**Confidence: HIGH** that this is a real complexity risk. **Confidence: MEDIUM** that the phase-gated protocol adequately addresses it.

### Risk 5: External Data Dependency (LOW concern)

**Description:** The skill cannot access external APIs, market databases, or competitive intelligence platforms. All "market data" comes from what the user provides in `_user-data.md`.

**Mitigation:** This is explicitly a non-goal, consistent with the investor-update precedent. The skill reads project artifacts and user-provided data on disk. No API calls, no web scraping. The External Validation Checkpoints section directs users to verify market claims externally.

**Residual risk:** Minimal. This is a known limitation shared with all conclave skills.

### Risk 6: First-Run Degradation (LOW concern)

**Description:** On a brand-new project with no prior sales plans, no investor updates, minimal roadmap data, and an empty `_user-data.md`, the output will be of very limited value.

**Mitigation:** The skill should handle first-run gracefully (following the investor-update pattern: skip consistency checks, create templates, note data gaps prominently).

---

## 8. Open Questions for Architect and Skeptic

1. **Cross-reference threshold:** Should the Team Lead wait for ALL research agents to report "FINDINGS READY" before triggering Phase 2, or use a majority threshold? A stalled agent could block the entire pipeline. Proposal: Wait for all, with a timeout (if one agent takes 2x the others, proceed without them).

2. **Challenge resolution:** If two agents disagree and cannot resolve during the Challenge phase, who decides? Options: (a) Team Lead arbitrates, (b) Strategy Skeptic arbitrates, (c) the disagreement is noted in the output and left for the user. Proposal: Option (c) -- note the disagreement, let the user decide. Trying to resolve all disagreements algorithmically may suppress useful nuance.

3. **Output directory:** Should the output go to `docs/sales-plans/` (following the `docs/investor-updates/` pattern) or `docs/specs/sales-strategy/` (following the spec pattern)? Proposal: `docs/sales-plans/` -- it's a new artifact type, not a feature spec.

4. **Strategy Synthesizer model:** Sonnet is proposed for cost efficiency (following the Drafter pattern). But strategy synthesis requires pulling together complex, potentially contradictory findings into a coherent narrative. Is this harder than investor update drafting? If so, should the Synthesizer default to Opus?

5. **User data completeness check:** Should the skill refuse to run if `_user-data.md` has fewer than N fields populated, or should it always run with degraded output? Proposal: Always run (following investor-update precedent), but add a prominent "DATA COMPLETENESS WARNING" at the start of the output.
