---
title: "Sales Planning Skill (/plan-sales)"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "product-skeptic"
created: "2026-02-19"
updated: "2026-02-19"
---

# Sales Planning (`/plan-sales`) Specification

## Summary

A multi-agent Collaborative Analysis skill that assesses sales strategy for early-stage startups by running parallel analysis agents who cross-reference and challenge each other's findings, then synthesizes a unified assessment validated by dual-skeptic review. This is the second business skill in the conclave framework and the first to implement the Collaborative Analysis consensus pattern from the business skill design guidelines.

## Problem

Early-stage startup founders make sales strategy decisions ad-hoc without structured analysis. Target market selection, competitive positioning, pricing, and go-to-market choices are based on assumptions rather than systematic evaluation. The result is scattered effort, missed opportunities, and strategies that don't hold up under scrutiny.

Key pain points:
- **No structured framework**: Founders evaluate market, product, and channels independently without cross-referencing insights across domains.
- **Hidden assumptions**: Strategic decisions rest on unexamined assumptions about market size, customer behavior, and competitive dynamics.
- **Narrow perspective**: A single founder assessing strategy lacks the benefit of multiple domain-specialized viewpoints challenging each other.
- **Quality without ground truth**: Unlike engineering deliverables (verified by tests), sales strategies are verified by judgment and market outcomes. Framework-level quality controls are needed to mitigate this.

Evidence:
- The business skill design guidelines (`docs/architecture/business-skill-design-guidelines.md`) define the Collaborative Analysis pattern and dual-skeptic assignments (Accuracy Skeptic + Strategy Skeptic) specifically for `/plan-sales`.
- Review Cycle 4 unanimously selected P3-10 as the next feature to unblock P2-08 (Plugin Organization, requires 2+ business skills) and validate the Collaborative Analysis pattern.
- The ratio of user-provided to auto-detected data is inverted compared to investor updates: sales planning is ~60-70% user-data-driven, requiring a more extensive user data template and prominent data-dependency warnings.

## Solution

### Architecture

This is a **multi-agent Collaborative Analysis skill** -- parallel investigation with structured cross-referencing and collaborative synthesis. Unlike Pipeline (sequential handoffs in `/draft-investor-update`) or Hub-and-Spoke (parallel independence in `/plan-product`), Collaborative Analysis requires agents to:

1. **Work in parallel** on different analysis domains (market, product, go-to-market)
2. **Share partial findings** mid-process via structured Domain Briefs
3. **Cross-reference** each other's findings -- identify contradictions, fill gaps, challenge assumptions, surface synergies
4. **Synthesize** -- the Team Lead integrates all findings + cross-references into a unified assessment
5. **Dual-skeptic validation** with non-overlapping concerns (Accuracy + Strategy)

See [System Design](../../architecture/plan-sales-system-design.md) for the full architecture.

### Agent Team

| Role | Name | Model | Responsibility |
|------|------|-------|---------------|
| Team Lead | (invoking agent) | opus | Orchestrate phases, manage transitions, synthesize assessment, write final output |
| Market Analyst | `market-analyst` | opus | Market sizing, competitive landscape, industry trends |
| Product Strategist | `product-strategist` | opus | Value proposition, differentiation, product-market fit |
| GTM Analyst | `gtm-analyst` | opus | Go-to-market channels, pricing, customer acquisition |
| Accuracy Skeptic | `accuracy-skeptic` | opus | Verify claims, projections, market data against evidence |
| Strategy Skeptic | `strategy-skeptic` | opus | Challenge assumptions, alternatives, strategic coherence |

**All-Opus rationale**: All three analysis agents require judgment-heavy reasoning: interpreting ambiguous data, assessing market positioning, evaluating strategic fit, and -- critically -- cross-referencing peers' findings to identify contradictions and challenge assumptions. Unlike the investor update Drafter (which executes a well-defined writing task from structured inputs), these agents must form independent judgments and defend them. Sonnet would risk superficial cross-referencing that defeats the purpose of the Collaborative Analysis pattern.

**Lead-driven synthesis rationale**: The Team Lead synthesizes the assessment directly (no separate Drafter agent). The lead holds full context from orchestrating Phases 1-2, has meta-context about which agents' findings were more evidence-based, and can resolve contradictions with process knowledge. A separate Drafter would need all 6 artifacts passed via messages, risking context exhaustion. This also reduces cost by one agent.

### Collaborative Analysis Protocol

This is the core innovation. The protocol is phase-gated, not free-form.

#### Phase 1: Independent Research (Parallel)

**Agents**: Market Analyst, Product Strategist, GTM Analyst

Each agent investigates their assigned domain independently. They read project artifacts and user-provided data but do NOT communicate with each other during this phase.

**Inputs** (all agents read):
- `docs/roadmap/_index.md` and individual roadmap files
- `docs/specs/` -- product capabilities
- `docs/architecture/` -- technical decisions
- `docs/sales-plans/_user-data.md` -- user-provided market data
- `docs/sales-plans/` -- prior sales assessments (for consistency)
- Project root files (README, CLAUDE.md)

**Output**: Each agent produces a **Domain Brief** -- a structured artifact containing:
- Key Findings (with evidence and confidence levels)
- Data Sources Used
- Assumptions Made (with impact-if-wrong assessment)
- Data Gaps
- Initial Recommendations
- Questions for Other Analysts

**Gate 1**: Team Lead verifies all 3 briefs received and complete (lightweight completeness check, not quality review).

#### Phase 2: Cross-Referencing (Parallel)

**Trigger**: Team Lead distributes all 3 Domain Briefs to all 3 agents (each receives the two they did not write).

Each agent reviews the other two briefs for:

1. **Contradictions Found** -- Does another agent's finding conflict with mine? State both sides with evidence and assessment of which is more likely correct.
2. **Gaps Filled** -- Does another agent's analysis miss something I found? Fill the gap with evidence.
3. **Assumptions Challenged** -- Does another agent assume something I have evidence against? Challenge with evidence and suggest revision.
4. **Synergies Identified** -- Do findings across domains reinforce each other? Highlight alignment and strategic implications.
5. **Answers to Peer Questions** -- Respond to questions from the "Questions for Other Analysts" section.

**Output**: Each agent produces a **Cross-Reference Report** in the structured format above. Agents must engage substantively -- a report claiming "no contradictions, no gaps, no challenges" across two briefs is automatically suspect and should be sent back for revision.

**Disagreement handling**: Disagreements are preserved, not resolved. Each agent states their assessment with evidence. Both the original finding and the challenge flow to synthesis, where the Team Lead weighs the evidence and the Skeptics evaluate the resolution.

**Gate 2**: Team Lead verifies all 3 Cross-Reference Reports received.

#### Phase 3: Synthesis (Lead-Driven)

**Agent**: Team Lead

The Team Lead synthesizes all 6 artifacts (3 Domain Briefs + 3 Cross-Reference Reports) into a Draft Sales Strategy Assessment.

**Synthesis process:**
1. Resolve contradictions -- weigh evidence from both sides, choose the better-supported position, document reasoning
2. Integrate gap-fills -- incorporate additional findings into relevant sections
3. Evaluate challenged assumptions -- determine if challenges are valid, revise or note why original stands
4. Highlight synergies -- make cross-domain connections explicit
5. Write the assessment -- produce the full output in the artifact format

**Context management**: To manage the context load of 6 artifacts, the Team Lead should synthesize section by section (Target Market, then Competitive Positioning, etc.) rather than attempting to hold all artifacts simultaneously. If context degrades during synthesis, the Team Lead should checkpoint progress and continue from the last completed section.

**Output**: Draft Sales Strategy Assessment.

#### Phase 4: Review (Dual-Skeptic, Parallel)

**Agents**: Accuracy Skeptic + Strategy Skeptic

Both skeptics receive the Draft Assessment AND all 6 source artifacts for evidence tracing.

**Accuracy Skeptic checklist:**
1. Every claim has evidence (traced to user data, project artifacts, or explicitly marked as assumption)
2. Projections are grounded in stated assumptions, not optimism
3. Contradictions are resolved, not hidden
4. Data gaps are acknowledged
5. Business quality checklist (assumptions stated, confidence justified, falsification triggers specific, unknowns acknowledged)

**Strategy Skeptic checklist:**
1. Strategic coherence (target market, value prop, positioning, GTM tell consistent story)
2. Alternative consideration (at least one alternative strategy evaluated)
3. Risk assessment is substantive, not token
4. Early-stage appropriateness (recommendations feasible with startup resources)
5. Scope discipline (stays within sales strategy assessment, no creep into financial modeling, operations, etc.)
6. Business quality checklist (framing credible to domain expert, projections grounded in evidence)

**Gate 3**: BOTH skeptics must approve. If either rejects, the assessment returns to Phase 3b.

#### Phase 3b: Revise

**Agent**: Team Lead

Revises synthesis based on ALL skeptic feedback. Documents what changed and why. Returns to Gate 3. Maximum 3 revision cycles before escalation to human operator.

#### Phase 5: Finalize

**Agent**: Team Lead

When both skeptics approve:
1. Write final assessment to `docs/sales-plans/{date}-sales-strategy.md`
2. Write progress summary to `docs/progress/plan-sales-summary.md`
3. Write cost summary to `docs/progress/plan-sales-{date}-cost-summary.md`
4. Output the final assessment to the user with review and implementation instructions

### User Data Input

Sales strategy assessment requires significant external data that cannot be auto-detected from project files. The user provides this via a template file.

**Location**: `docs/sales-plans/_user-data.md`

**Template sections:**
- Product & Market (description, target customer, problem, stage, existing customers)
- Market Context (industry, competitors, trends, market size estimates)
- Current Sales (revenue, channels, deal size, cycle length, win rate)
- Pricing (model, price points, competitor pricing)
- Constraints (team size, budget, geography, timeline)
- Additional Context (free-form)

**Behavior:**
- If `_user-data.md` exists and is populated: All agents read it alongside project data.
- If `_user-data.md` exists but is partially populated: Agents use available data, flag gaps.
- If `_user-data.md` does not exist: All user-data-dependent analysis uses project artifacts only with explicit low-confidence markers. Skill creates the template file for next run. Prominent warning at invocation: "No user data found. Assessment quality depends heavily on user-provided market data. Create docs/sales-plans/_user-data.md for a more specific assessment."

### Output Artifact Format

The sales strategy assessment follows a structured template with YAML frontmatter, 9 content sections (Executive Summary, Target Market, Competitive Positioning, Value Proposition, Go-to-Market Strategy, Pricing Considerations, Strategic Risks, Recommended Next Steps), and 4 mandatory business quality sections (Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints).

See [System Design](../../architecture/plan-sales-system-design.md) for the complete output template.

### Arguments

| Argument | Effect |
|----------|--------|
| (empty) | Scan for in-progress sessions. If found, resume. Otherwise, start new assessment. |
| `status` | Report on in-progress session without spawning agents. |
| `--light` | Analysis agents use Sonnet instead of Opus. Skeptics remain Opus. |

### CI Validator Impact

| Validator | Impact | Changes Needed |
|-----------|--------|---------------|
| `skill-structure.sh` | Works as-is | None -- standard multi-agent section checks apply |
| `skill-shared-content.sh` | Minor extension | Extend `normalize_skeptic_names()` with `strategy-skeptic`/`Strategy Skeptic` (2 new sed expressions). `accuracy-skeptic` already handled. |
| `spec-frontmatter.sh` | Not applicable | Output goes to `docs/sales-plans/`, not `docs/specs/` |
| `roadmap-frontmatter.sh` | Not applicable | Skill does not modify roadmap files |
| `progress-checkpoint.sh` | Works as-is | Standard format with `team: "plan-sales"` |

### New Patterns This Skill Introduces

1. **Collaborative Analysis phases** -- 5-phase flow with structured cross-referencing between parallel agents. No existing skill has agents reading and reacting to each other's partial work mid-process.
2. **Domain Briefs** -- Structured partial-finding artifacts shared peer-to-peer (not just agent-to-lead).
3. **Cross-Reference Reports** -- Structured artifacts where each agent evaluates peers' findings for contradictions, gaps, challenges, and synergies.
4. **Lead-driven synthesis** -- Team Lead writes the assessment (not a Drafter agent), leveraging full process context.
5. **Output directory** -- `docs/sales-plans/` as a new artifact location.
6. **Strategy Skeptic** -- New skeptic specialization focused on strategic coherence, alternatives, and early-stage feasibility.

### Pathfinder Role

This is the first Collaborative Analysis skill. It is explicitly a pathfinder -- lessons learned will inform:
- Whether the Collaborative Analysis protocol needs adjustment after real-world use
- How cross-referencing works in practice (do agents engage substantively or produce superficial reports?)
- Whether all-Opus analysis agents are justified vs. a Sonnet option
- Progress toward P2-07 threshold (6/8 skills)
- Completion of P2-08 prerequisite (2/2 business skills)

## Constraints

1. **Scope is early-stage startup sales strategy assessment.** No CRM integration, sales forecasting, lead generation, enterprise sales, or financial modeling.
2. **Every claim must have evidence or be marked as an assumption.** The Accuracy Skeptic rejects unsourced claims.
3. **Both skeptics must approve.** No shortcutting the dual-skeptic gate.
4. **Maximum 3 revision cycles.** After 3 rejections, escalate to human operator.
5. **No data fabrication.** Where data is missing, the assessment states the gap explicitly with low-confidence markers.
6. **No real-time data gathering.** The skill reads project artifacts and user-provided data on disk. No API calls or external services.
7. **Cross-referencing must be substantive.** Agents must engage with peers' findings. A Cross-Reference Report claiming nothing to report across two briefs is sent back for revision.
8. **Shared content must use shared markers.** Shared Principles and Communication Protocol sections use `<!-- BEGIN SHARED -->` markers and are byte-identical to the authoritative source (plan-product/SKILL.md), with skeptic name normalization.
9. **Disagreements are preserved through synthesis.** The Team Lead documents both sides and resolution reasoning. Hidden disagreements are a rejection-worthy defect.

## Out of Scope

- CRM setup or pipeline management tools
- Sales forecasting or revenue modeling
- Lead generation workflows
- Sales team hiring (that's `/plan-hiring`)
- Marketing strategy (that's `/plan-marketing`)
- Customer success planning (that's `/plan-customer-success`)
- Enterprise sales strategy (complex multi-stakeholder deals)
- Template customization at runtime
- Real-time market data via APIs
- Comparison with industry benchmarks from external databases

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-sales/SKILL.md` | **Create** -- New multi-agent Collaborative Analysis skill definition |
| `scripts/validators/skill-shared-content.sh` | **Modify** -- Extend `normalize_skeptic_names()` with `strategy-skeptic`/`Strategy Skeptic` (2 new sed expressions) |
| `plugins/conclave/plugin.json` | **Modify** -- Register new skill |

## Success Criteria

1. Running `/plan-sales` on a project with a populated `_user-data.md` produces a complete sales strategy assessment with all sections populated and both skeptics approving.
2. The Collaborative Analysis protocol executes: 3 agents produce Domain Briefs (Phase 1), cross-reference each other's findings (Phase 2), and the Team Lead synthesizes (Phase 3).
3. Cross-Reference Reports contain substantive engagement -- contradictions identified, gaps filled, assumptions challenged, or synergies surfaced. Empty cross-references are rejected.
4. The Accuracy Skeptic verifies all claims trace to evidence (user data, project artifacts, or explicit assumptions) before approval.
5. The Strategy Skeptic verifies strategic coherence, alternatives consideration, honest risk assessment, and early-stage feasibility before approval.
6. Both skeptics must approve before the assessment is finalized.
7. Running the skill with `--light` uses Sonnet for analysis agents while keeping both Skeptics at Opus.
8. Running the skill with `status` reports session progress without spawning agents.
9. The skill creates `docs/sales-plans/` and `_user-data.md` template if they don't exist (first-run setup).
10. The skill reads and integrates data from `docs/sales-plans/_user-data.md` when present.
11. The output includes all mandatory business quality sections: Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints.
12. The CI validator passes for the new SKILL.md (shared content drift check with skeptic name normalization for `strategy-skeptic`).
13. On first run (no prior assessments, no user data), the skill completes with prominent data-dependency warnings and low-confidence markers throughout.
14. Lead-driven synthesis handles context load via section-by-section synthesis, with checkpoint recovery if context degrades.

## Architecture References

- [System Design: Sales Planning](../../architecture/plan-sales-system-design.md)
- [Business Skill Design Guidelines](../../architecture/business-skill-design-guidelines.md)
