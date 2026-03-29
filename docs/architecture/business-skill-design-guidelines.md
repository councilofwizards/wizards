---
title: "Business Skill Design Guidelines"
status: "approved"
created: "2026-02-18"
updated: "2026-02-18"
---

# Business Skill Design Guidelines

Framework-level design requirements for all future skills, with emphasis on
business-domain skills. Established during the Product Team review cycle
(2026-02-18) per Skeptic conditional approval.

## Multi-Skeptic Assignments

Every team MUST include at least one negative persona (Skeptic). Most teams
SHOULD include two, covering non-overlapping failure-mode scopes. Per PO
directive: be liberal with negative personas.

### Engineering Skills

| Skill              | Skeptic 1                                                         | Skeptic 2                                                                 |
| ------------------ | ----------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `/triage-incident` | **Quality Skeptic** — Solution correctness, root cause validity   | **Ops Skeptic** — Blast radius, rollback safety, monitoring gaps          |
| `/review-debt`     | **Code Quality Skeptic** — Severity ratings, remediation approach | **Business Impact Skeptic** — Prioritization, opportunity cost            |
| `/design-api`      | **Consistency Skeptic** — Conventions, naming, versioning         | **Consumer Advocate** — Usability, backwards compatibility, documentation |
| `/plan-migration`  | **Risk Skeptic** — Data loss, downtime, dependency chains         | **Rollback Skeptic** — Reversibility, contingency plans, testing coverage |

### Business Skills

| Skill                     | Skeptic 1                                                                | Skeptic 2                                                                           |
| ------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------- |
| `/plan-sales`             | **Accuracy Skeptic** — Claims, projections, market data                  | **Strategy Skeptic** — Market fit, competitive positioning, pricing                 |
| `/plan-marketing`         | **ROI Skeptic** — Budget justification, attribution, metrics             | **Brand Skeptic** — Messaging consistency, audience fit, tone                       |
| `/plan-finance`           | **Financial Rigor Skeptic** — Model accuracy, assumption sensitivity     | **Regulatory Skeptic** — Compliance, reporting requirements, audit trail            |
| `/plan-hiring`            | **Bias Skeptic** — Fairness, legal compliance, inclusive language        | **Fit Skeptic** — Role necessity, team composition, budget alignment                |
| `/plan-customer-success`  | **Retention Skeptic** — Churn risk signals, intervention timing          | **Scalability Skeptic** — Process sustainability at growth targets                  |
| `/build-sales-collateral` | **Accuracy Skeptic** — Claims backed by evidence, proof points           | **Effectiveness Skeptic** — Persuasiveness, differentiation, call to action         |
| `/build-content`          | **Quality Skeptic** — Writing standards, originality, accuracy           | **Strategy Skeptic** — Audience alignment, SEO, distribution fit                    |
| `/review-legal`           | **Completeness Skeptic** — Coverage, edge cases, jurisdiction            | **Severity Skeptic** — Risk assessment, prioritization, remediation urgency         |
| `/plan-analytics`         | **Methodology Skeptic** — Statistical validity, sample bias, confounders | **Actionability Skeptic** — Decision relevance, metric gaming risk                  |
| `/plan-operations`        | **Efficiency Skeptic** — Waste identification, bottleneck analysis       | **Risk Skeptic** — Single points of failure, vendor lock-in, resilience             |
| `/plan-onboarding`        | **Completeness Skeptic** — Coverage of roles, tools, processes           | **Experience Skeptic** — New hire perspective, cognitive load, time-to-productivity |
| `/draft-investor-update`  | **Accuracy Skeptic** — Numbers, claims, milestone verification           | **Narrative Skeptic** — Spin detection, omission, consistency with prior updates    |

### High-Stakes Domains (3 Skeptics)

Some domains warrant a third negative persona due to regulatory or financial
risk:

| Skill           | Additional Skeptic                                                                           |
| --------------- | -------------------------------------------------------------------------------------------- |
| `/plan-finance` | **Investor Readiness Skeptic** — Due diligence preparedness, fundraising narrative coherence |
| `/review-legal` | **Precedent Skeptic** — Case law awareness, enforceability, jurisdictional variation         |

## Consensus-Building Patterns

Business teams use one of three collaboration patterns, chosen per-skill based
on the nature of the work. All patterns emphasize peer-to-peer communication —
agents message each other directly, not just through the lead.

### Collaborative Analysis

All agents investigate simultaneously, share findings in real-time via
peer-to-peer messaging, and build on each other's discoveries. Best for
research-heavy skills where diverse perspectives compound.

**Best for**: `/plan-sales`, `/plan-marketing`, `/plan-customer-success`,
`/plan-analytics`

**Pattern**: Agents work in parallel → share partial findings via `SendMessage`
→ cross-reference and challenge each other's work → synthesize collaboratively →
Skeptics validate the synthesis.

### Structured Debate

Agents take defined positions (pro/con, optimistic/conservative,
risk-seeking/risk-averse), present evidence-backed arguments, and a neutral
party synthesizes. Best for high-stakes decisions where premature consensus is
dangerous.

**Best for**: `/plan-finance`, `/review-legal`, `/plan-operations`,
`/plan-hiring`

**Pattern**: Agents are assigned perspectives → each builds their case
independently → cases are presented to the full team → cross-examination via
direct messages → Skeptics judge the debate → synthesis produced.

### Pipeline

Sequential handoffs with quality gates between stages. Each stage builds on the
validated output of the previous stage. Best for production/build skills where
the output has a clear sequential structure.

**Best for**: `/build-sales-collateral`, `/build-content`,
`/draft-investor-update`, `/plan-onboarding`

**Pattern**: Research → Draft → Review → Revise → Final validation. Each stage
has a defined handoff artifact and acceptance criteria.

## Quality Without Ground Truth

Engineering skills verify outputs against code (tests pass, builds succeed,
schemas validate). Business skills lack this ground truth — their outputs are
verified against assumptions, projections, and judgment. This creates a quality
risk that must be mitigated at the framework level.

### Mandatory Output Requirements

All non-engineering skill outputs MUST include:

1. **Assumptions & Limitations section** — Every deliverable explicitly states
   what it assumes to be true and what constraints apply. Skeptics verify this
   section is complete and honest. Hidden assumptions are a rejection-worthy
   defect.

2. **Confidence levels** — All projections, estimates, and forecasts include a
   confidence qualifier (High / Medium / Low) with rationale. Skeptics reject
   unqualified certainty.

3. **Falsification triggers** — Each major conclusion answers: "What evidence
   would change this conclusion?" Skeptics verify these triggers are specific
   and testable, not vague.

4. **External validation checkpoints** — Skill outputs identify where human
   domain expertise should validate AI-generated analysis. The framework
   structures judgment — it does not replace it.

### Skeptic Enforcement Checklist

Skeptics in business skills must specifically verify:

- [ ] Are assumptions stated, not hidden?
- [ ] Are confidence levels present and justified?
- [ ] Are falsification triggers specific and actionable?
- [ ] Does the output acknowledge what it doesn't know?
- [ ] Would a domain expert find the framing credible?
- [ ] Are projections grounded in stated evidence, not optimism?

## Product Strategy Scope

Strategic planning is scoped within the existing `/plan-product` skill rather
than a standalone `/plan-strategy` skill. The plan-product team already performs
strategic analysis as part of roadmap assessment, competitive analysis, and
prioritization. A separate strategy skill would create scope overlap and
fragment the strategic conversation. If strategy needs grow beyond what
plan-product covers, this decision can be revisited.
