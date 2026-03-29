---
feature: "new-skills-research"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action:
  "Added dual negative personas, peer-to-peer collaboration patterns, and quality gate flows to all 17 skill team
  designs"
updated: "2026-02-18T18:30:00Z"
---

# Research Findings: Agent Team Skills for the Full Startup Organization

## Summary

Investigated potential agent team skills across 9 business domains to support the expanded vision: enabling lean,
high-leverage startups by providing orchestrated agent teams for ALL white-collar roles. Evaluated 30+ skill ideas
against the framework's core value proposition (multi-agent orchestration with specialized roles, adversarial quality
gates, structured communication). Identified 15 strong candidates across all domains. The framework's patterns (Skeptic
gate, checkpoint protocol, write safety, communication protocol) transfer remarkably well to non-engineering domains --
any task requiring multiple perspectives, structured output, and quality review benefits from the Council of Wizards
orchestration model.

**Updated**: All team designs now include multiple negative personas with scoped responsibilities, detailed peer-to-peer
collaboration patterns, and explicit consensus/quality gate flows. The design philosophy: every team must have
adversarial voices that prevent groupthink, and every agent must actively collaborate with peers rather than working in
isolation.

## Framework Applicability Beyond Engineering

Before evaluating individual skills, a key insight: the Council of Wizards framework is NOT code-specific. Its value
comes from:

1. **Specialized parallel investigation** -- multiple agents examining a problem from different angles simultaneously
2. **Adversarial quality gate** (Skeptic) -- preventing groupthink and catching gaps
3. **Structured artifact handoff** -- producing documents that other teams/skills can consume
4. **Checkpoint recovery** -- resuming long-running work across sessions

These patterns apply to any knowledge work where quality matters: marketing strategy, financial modeling, legal review,
hiring plans. The main adaptation needed per domain is: team composition, spawn prompts, output formats, and
domain-specific quality criteria for the Skeptic.

**What DOESN'T fit**: Tasks that are purely mechanical (data entry, formatting), require real-time human interaction
(sales calls, interviews), or need access to proprietary systems with no API (most CRM/ERP operations).

### Reusable Components for All New Skills

| Component              | Reuse Level | Adaptation Needed                                          |
| ---------------------- | ----------- | ---------------------------------------------------------- |
| Shared Principles      | ~80%        | Replace code-specific rules (TDD, SOLID) with domain rules |
| Communication Protocol | ~95%        | Change skeptic name per skill only                         |
| Skeptic Pattern        | 100%        | Change quality criteria per domain                         |
| Checkpoint Protocol    | 100%        | No changes                                                 |
| Write Safety           | 100%        | No changes                                                 |
| Failure Recovery       | 100%        | No changes                                                 |
| Lightweight Mode       | 100%        | Same pattern: downgrade non-critical agents to Sonnet      |
| Cost Summary           | 100%        | No changes                                                 |
| Setup pattern          | ~70%        | Domain-specific directory structure and context reading    |
| Artifact handoff       | ~80%        | Domain-specific output directories                         |

---

## Negative Personas & Collaboration Design Principles

### Why Multiple Negative Personas

The existing engineering skills use a single Skeptic per team. This works for focused technical review, but business
decisions have multiple failure modes that a single adversarial voice cannot cover. Examples:

- A financial model can be mathematically sound but ignore regulatory constraints
- A marketing strategy can be well-targeted but make legally problematic claims
- A hiring plan can be well-structured but introduce bias

Each negative persona covers a **specific scope** of failure modes. Their scopes are non-overlapping -- if two negative
personas cover the same ground, one is redundant.

### Collaboration Design Philosophy

Teams must be **highly collaborative by design**. This means:

1. **Peer-to-peer communication is expected, not optional**. Agents do not just report to the lead -- they actively
   consult each other. A market researcher shares early findings with the value proposition designer before the final
   report.
2. **Negative personas participate throughout**, not just at the gate. They review intermediate work, flag concerns
   early, and provide constructive direction -- not just rejection at the end.
3. **Consensus requires ALL negative personas to approve**. If a team has two negative personas, both must explicitly
   approve before work advances. A single holdout blocks progress.
4. **Negative personas do NOT collude**. Each evaluates independently from their scoped perspective. They may disagree
   with each other -- that is healthy and expected.

### Quality Gate Flow Pattern

For teams with multiple negative personas, the quality gate flow is:

```
Agents produce work
  -> Lead routes to ALL negative personas simultaneously
  -> Each negative persona reviews from their scoped perspective
  -> ALL must approve (explicit approval message required)
  -> If ANY rejects: team iterates on the specific concern
  -> If disagreement between negative personas: Lead mediates, citing scope boundaries
  -> After 3 rejections from the SAME persona on the SAME concern: escalate to human
```

---

## DOMAIN 1: Product & Engineering (Existing + Gaps)

Current coverage: `/plan-product`, `/build-product`, `/review-quality`

### 1.1 `/triage-incident` -- Incident Response Team

**Problem**: Production incidents require simultaneous investigation across code, infrastructure, and data. A single
engineer context-switching between domains is slow. Coordinated parallel investigation with adversarial checks on root
cause claims and fix safety is faster and more thorough.

**Team**:

- **Incident Commander** (lead, Opus): Coordinates investigation, maintains timeline, synthesizes findings
- **Code Investigator** (Sonnet): Reviews recent commits/deploys, reads error traces, identifies code-level root causes
- **Infrastructure Investigator** (Sonnet): Checks deployment configs, resource usage, service health
- **Database Investigator** (Sonnet): Reviews query patterns, migration recency, data integrity
- **Root Cause Skeptic** (Opus): Challenges root cause hypotheses, demands evidence chains, prevents premature
  conclusions. Scope: "Is this actually the root cause, or just a symptom?"
- **Fix Safety Skeptic** (Opus): Reviews proposed fixes for blast radius, rollback risk, and unintended side effects.
  Scope: "Will this fix make things worse?" Demands rollback plans for every remediation.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Root Cause Skeptic |
Causal analysis | "Where's the evidence chain?" "Could there be a deeper cause?" "Have you ruled out X?" | | Fix Safety
Skeptic | Remediation safety | "What's the blast radius?" "What's the rollback plan?" "What if this fix fails?" |

**Peer-to-Peer Collaboration**:

- Code, Infrastructure, and Database Investigators **share findings with each other** as they discover them -- a
  database slowdown may explain the code-level timeout, and investigators must connect these dots collaboratively
- Root Cause Skeptic reviews investigator findings **as they arrive**, not just the final report -- early challenges
  redirect investigation before time is wasted
- Fix Safety Skeptic consults with the investigator who owns the affected domain to understand implementation
  constraints before ruling on fix safety

**Quality Gate Flow**: Root Cause Skeptic must approve the root cause analysis before remediation planning begins. Fix
Safety Skeptic must approve all proposed fixes before execution. Both must approve the final postmortem.

**Modes**: `outage <description>`, `postmortem <incident>`, `runbook <scenario>`

**Multi-agent value**: HIGH. Parallel investigation is the core value. Three independent search spaces explored
simultaneously.

**Framework reuse**: ~70%. Checkpoint protocol = incident timeline. Communication protocol routes findings to commander.

**Startup priority**: HIGH. Every SaaS product has incidents. The postmortem mode alone saves hours of tedious
post-incident documentation.

**Effort**: Medium

### 1.2 `/assess-debt` -- Tech Debt Assessment Team

**Problem**: Tech debt accumulates invisibly. When assessed, a single engineer's view is biased. A multi-perspective
assessment (code quality, dependency health, architecture integrity) produces a more complete picture.

**Team**:

- **Debt Lead** (lead, Opus): Synthesizes findings into prioritized debt register
- **Code Analyst** (Sonnet): Code smells, complexity hotspots, duplication, low test coverage
- **Dependency Auditor** (Sonnet): Dependency freshness, CVEs, deprecated packages, license issues
- **Architecture Reviewer** (Opus): Structural debt, violated boundaries, circular dependencies
- **Severity Skeptic** (Opus): Challenges severity ratings, demands quantified impact evidence, prevents "everything is
  critical" inflation. Scope: "Is this debt actually slowing us down, or is it cosmetic?"
- **ROI Skeptic** (Opus): Challenges remediation proposals for cost-benefit. Scope: "Is fixing this worth the
  engineering investment?" Demands estimated effort vs. estimated velocity gain for every recommended fix.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Severity Skeptic |
Impact assessment accuracy | "What's the evidence this slows development?" "How many engineers does this affect?" | |
ROI Skeptic | Remediation cost-benefit | "What's the fix effort?" "What velocity gain do we expect?" "Is this a
refactor-for-refactoring's-sake?" |

**Peer-to-Peer Collaboration**:

- Code Analyst and Architecture Reviewer **coordinate on boundaries** -- a code smell may indicate an architectural
  violation, and they should cross-reference findings
- Dependency Auditor shares CVE findings with Code Analyst to check if vulnerable paths are actually exercised in the
  codebase
- Architecture Reviewer consults with Code Analyst on whether structural violations are causing concrete problems or are
  theoretical concerns

**Quality Gate Flow**: Severity Skeptic must approve all severity ratings before the debt register is finalized. ROI
Skeptic must approve all remediation recommendations. Both review the final prioritized output.

**Modes**: full scan, `scope <path>`, `dependencies`, `hotspots`

**Multi-agent value**: HIGH. Three independent analysis domains in parallel.

**Framework reuse**: ~65%. Output format parallels security audit findings from review-quality.

**Startup priority**: HIGH. Tech debt is the #1 velocity killer in growing startups. Output feeds directly into
`/plan-product reprioritize`.

**Effort**: Medium

### 1.3 `/design-api` -- API Design Team

**Problem**: API design done ad-hoc during implementation produces inconsistent, poorly documented APIs. A dedicated
design phase with producer and consumer perspectives produces better contracts.

**Team**:

- **API Lead** (lead, Opus): Ensures consistency with existing API patterns
- **API Designer** (Opus): Endpoint structure, request/response shapes, pagination, error formats
- **Consumer Advocate** (Sonnet): Represents frontend/mobile/third-party consumers, reviews DX
- **Consistency Skeptic** (Opus): Reviews for consistency with existing API patterns, naming conventions, error format
  compliance, and versioning strategy. Scope: "Does this fit the existing API surface?"
- **DX Skeptic** (Opus): Reviews from a developer experience perspective -- documentation completeness, intuitive
  naming, predictable behavior, error message helpfulness. Scope: "Would a developer new to this API understand it
  without asking for help?"

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Consistency Skeptic |
API surface coherence | "Does this endpoint follow the same pattern as /existing?" "Error format differs from v2 --
why?" | | DX Skeptic | Developer experience | "The error message says 'invalid input' -- which input?" "No pagination on
a list endpoint?" |

**Peer-to-Peer Collaboration**:

- API Designer and Consumer Advocate **negotiate actively** -- the Designer proposes structure, the Consumer Advocate
  tests it against real usage scenarios, and they iterate together
- Consumer Advocate shares DX concerns with DX Skeptic to ensure alignment on what "good DX" means before the formal
  review gate
- API Designer consults with Consistency Skeptic early on naming and structure choices, not just at the final gate

**Quality Gate Flow**: Consistency Skeptic must approve that the API fits the existing surface. DX Skeptic must approve
that the API is usable without tribal knowledge. Both must approve before the API spec is finalized.

**Modes**: `new <feature>`, `review <endpoint>`, `document`

**Multi-agent value**: MEDIUM-HIGH. Producer and consumer perspectives in parallel.

**Framework reuse**: ~60%. Contract negotiation pattern from build-product directly applicable.

**Startup priority**: HIGH for API-first companies. MEDIUM otherwise.

**Effort**: Medium. NOTE: Could alternatively be a mode in `/plan-product` rather than standalone.

### 1.4 `/plan-migration` -- Migration Planning Team

**Problem**: Major migrations (framework upgrades, database changes, service splits) are high-risk. Teams consistently
underestimate complexity and discover problems mid-migration.

**Team**:

- **Migration Lead** (lead, Opus): Coordinates planning, maintains checklist and timeline
- **Code Migration Analyst** (Sonnet): Scope, breaking changes, dependency chains
- **Data Migration Planner** (Opus): ETL strategy, dual-write, zero-downtime patterns, rollback
- **Risk Assessor** (Opus): Phase-by-phase risk identification, blast radius, rollback plans
- **Feasibility Skeptic** (Opus): Challenges timeline estimates, resource assumptions, and scope definitions. Scope:
  "Can you actually do this migration with the team and timeline proposed?" Demands evidence for every estimate.
- **Rollback Skeptic** (Opus): Challenges every phase's rollback plan. Scope: "What happens when this fails at 2 AM?"
  Demands tested rollback procedures, not theoretical ones. Rejects any migration phase that lacks a verified rollback
  path.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Feasibility Skeptic |
Timeline and resource realism | "Your estimate assumes zero bugs -- add failure buffer." "Who's on-call during the
migration window?" | | Rollback Skeptic | Failure recovery | "What's the rollback for phase 3?" "Have you tested the
rollback?" "What data is lost on rollback?" |

**Peer-to-Peer Collaboration**:

- Code Migration Analyst and Data Migration Planner **must coordinate on ordering** -- data schema changes often must
  precede or follow code changes in a specific sequence, and they work together to define the dependency chain
- Risk Assessor consults with both Analysts to understand which phases are highest-risk, then produces phase-by-phase
  risk profiles that feed back into planning
- Data Migration Planner shares ETL design with Rollback Skeptic early to get rollback feasibility feedback before the
  formal gate

**Quality Gate Flow**: Feasibility Skeptic must approve the overall migration plan (timeline, resources, scope) before
phase-level planning begins. Rollback Skeptic must approve the rollback plan for each phase independently. Both must
approve the final migration runbook.

**Modes**: `framework <from> <to>`, `database <scope>`, `service <scope>`, `upgrade <dependency>`

**Multi-agent value**: HIGH. Code, data, and risk are independent analysis domains.

**Framework reuse**: ~60%.

**Startup priority**: MEDIUM-HIGH. Not frequent but highest-risk when it happens.

**Effort**: Large

---

## DOMAIN 2: Sales

### 2.1 `/plan-sales` -- Sales Strategy Team

**Problem**: Lean startups lack dedicated sales strategists. Founders and early hires wing it on positioning,
prospecting, and deal strategy. A structured approach to sales planning -- target market definition, value proposition
mapping, competitive positioning, pricing alignment -- produces better outcomes than ad-hoc selling.

**Team**:

- **Sales Strategist** (lead, Opus): Coordinates strategy development, synthesizes market analysis with product
  capabilities
- **Market Researcher** (Sonnet): Analyzes target market segments, company size profiles, buying patterns, industry
  trends. Reads any available market data files, competitor info, or customer feedback.
- **Value Proposition Designer** (Opus): Maps product capabilities to customer pain points. Creates positioning
  frameworks, battle cards, and objection handling guides.
- **Accuracy Skeptic** (Opus): Challenges all factual claims, market data, and competitive assertions. Scope: "Is this
  true?" Demands sources for TAM numbers, evidence for market claims, and verification of competitive positioning
  statements. Rejects unsubstantiated claims.
- **Strategy Skeptic** (Opus): Challenges the strategic coherence and specificity of the sales plan. Scope: "Will this
  work?" Tests positioning for differentiation ("this could describe any SaaS product" = rejection), challenges pricing
  alignment with value delivery, and demands evidence that the proposed ICP actually buys products like this.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Accuracy Skeptic |
Factual correctness | "Source for this TAM figure?" "This competitor comparison is outdated." "Your win rate claim needs
data." | | Strategy Skeptic | Strategic viability | "Your ICP is too broad." "This positioning is generic." "Why would
this buyer choose you over the incumbent?" |

**Peer-to-Peer Collaboration**:

- Market Researcher shares findings directly with Value Proposition Designer **as research progresses**, not just at the
  end -- early market insights shape positioning direction
- Value Proposition Designer tests positioning drafts with Market Researcher to verify they align with actual buyer
  language and pain points found in the research
- Accuracy Skeptic reviews Market Researcher's data sources and methodology early, before findings are baked into the
  strategy

**Quality Gate Flow**: Accuracy Skeptic must approve all factual claims and data before they are used in the strategy.
Strategy Skeptic must approve the strategic framework (ICP, positioning, pricing rationale) as coherent and specific.
Both must approve the final strategy document.

**Modes**:

- `/plan-sales strategy` -- Full sales strategy development (ICP, positioning, pricing rationale, channel strategy)
- `/plan-sales battlecard <competitor>` -- Competitive battle card for a specific competitor
- `/plan-sales proposal <prospect>` -- Customized proposal/pitch for a specific prospect (reads prospect context from
  input)
- `/plan-sales pipeline` -- Pipeline analysis and deal prioritization (reads deal data from provided files)

**Multi-agent value**: HIGH. Market research, value proposition design, and competitive analysis are independent
parallel workstreams. Two Skeptics cover orthogonal failure modes: saying something false (Accuracy) vs. saying
something true but strategically useless (Strategy).

**Framework reuse**: ~55%. Skeptic pattern, communication protocol, checkpoint protocol all transfer. Output directory:
`docs/sales/`. Artifact format needs new templates (battle card, proposal, strategy doc).

**Startup priority**: HIGH. Sales strategy is where most early-stage startups fail. They build but can't sell. An agent
team that forces rigorous market analysis and positioning is extremely high-leverage.

**Effort**: Medium

### 2.2 `/build-sales-collateral` -- Sales Content Team

**Problem**: Sales teams need decks, one-pagers, case study drafts, email sequences, and demo scripts. These are
time-consuming to produce and often inconsistent with the brand and product positioning.

**Team**:

- **Content Lead** (lead, Opus): Coordinates collateral production, ensures consistency with sales strategy
- **Copywriter** (Sonnet): Writes the actual content -- email sequences, one-pagers, deck copy, demo scripts
- **Data Analyst** (Sonnet): Pulls relevant metrics, ROI calculations, customer proof points, product stats to support
  claims
- **Claims Skeptic** (Opus): Reviews every factual claim, statistic, and proof point for accuracy and verifiability.
  Scope: "Can we prove this?" Rejects "industry-leading", "best-in-class", and any unsubstantiated superlative. Demands
  cited sources for every data point.
- **Brand Skeptic** (Opus): Reviews for brand voice consistency, positioning alignment with the sales strategy, and
  message coherence across collateral pieces. Scope: "Is this on-brand and on-message?" Rejects content that contradicts
  the positioning framework or uses inconsistent terminology.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Claims Skeptic |
Factual accuracy of claims | "Source for this ROI figure?" "'Industry-leading' -- by what measure?" "This stat is from
2019 -- is it current?" | | Brand Skeptic | Brand and positioning alignment | "This contradicts our positioning." "Wrong
tone for this audience." "The product name is inconsistent across slides." |

**Peer-to-Peer Collaboration**:

- Copywriter and Data Analyst **work in tandem** -- the Copywriter requests specific proof points, and the Data Analyst
  supplies verified data with sources. They do not work in isolation and merge at the end.
- Data Analyst shares available proof points with Claims Skeptic early to pre-validate data before it is woven into copy
- Copywriter consults Brand Skeptic on tone and voice questions during drafting, not just at the final gate

**Quality Gate Flow**: Claims Skeptic must approve all factual claims and data points before they appear in final
collateral. Brand Skeptic must approve voice, positioning alignment, and cross-piece consistency. Both must approve
before any collateral is delivered.

**Modes**:

- `/build-sales-collateral deck <audience>` -- Sales deck for a target audience
- `/build-sales-collateral email-sequence <campaign>` -- Outbound email sequence
- `/build-sales-collateral case-study <customer>` -- Case study draft from provided customer data
- `/build-sales-collateral one-pager <product-area>` -- Product one-pager

**Multi-agent value**: MEDIUM-HIGH. Copywriting and data research are parallel tasks. Two Skeptics cover orthogonal
failures: saying something false (Claims) vs. saying something off-brand (Brand).

**Framework reuse**: ~50%. Orchestration patterns transfer. New output formats needed.

**Startup priority**: MEDIUM-HIGH. Every B2B startup needs sales collateral. The bottleneck is usually that founders
write it themselves poorly or it never gets done.

**Effort**: Medium

---

## DOMAIN 3: Marketing

### 3.1 `/plan-marketing` -- Marketing Strategy Team

**Problem**: Lean startups lack structured marketing strategy. They jump to tactics (write blog posts, run ads) without
a coherent positioning, messaging framework, or channel strategy. The result is scattered effort with poor ROI.

**Team**:

- **Marketing Strategist** (lead, Opus): Coordinates strategy development, synthesizes research into a coherent
  marketing plan
- **Market Researcher** (Sonnet): Analyzes competitor marketing, audience segments, keyword landscape, content gaps,
  channel effectiveness data
- **Brand & Messaging Designer** (Opus): Develops messaging framework, tone guidelines, positioning statements,
  taglines, elevator pitches. Ensures consistency across all touchpoints.
- **Measurability Skeptic** (Opus): Challenges strategy for specificity and measurability. Scope: "Can you measure
  this?" Rejects vague goals ("increase brand awareness" without a metric), demands target numbers for every KPI, and
  challenges budget allocation rationale against expected ROI.
- **Legal/Claims Skeptic** (Opus): Reviews all marketing claims, competitive comparisons, and positioning statements for
  legal risk. Scope: "Could this get us in trouble?" Flags unsubstantiated superiority claims, potential trademark
  issues, misleading statistics, and regulatory compliance gaps (FTC guidelines, GDPR for marketing data).

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Measurability Skeptic |
Strategy rigor | "What's the target number?" "How do you measure 'brand awareness'?" "What's the CAC for this channel?"
| | Legal/Claims Skeptic | Legal and regulatory risk | "Can you prove 'fastest'?" "This comparison may violate
competitor's TM." "GDPR-compliant data collection plan?" |

**Peer-to-Peer Collaboration**:

- Market Researcher shares competitive findings directly with Brand & Messaging Designer to inform differentiation --
  the messaging must be grounded in actual competitive gaps, not assumed ones
- Brand & Messaging Designer tests positioning drafts with Market Researcher to verify they resonate with audience
  research findings
- Market Researcher consults with Legal/Claims Skeptic on competitor data usage and comparison claims before they enter
  the strategy

**Quality Gate Flow**: Measurability Skeptic must approve that every strategy element has measurable targets and budget
rationale. Legal/Claims Skeptic must approve all claims, comparisons, and data practices. Both must approve before the
marketing strategy is finalized.

**Modes**:

- `/plan-marketing strategy` -- Full marketing strategy (positioning, messaging, channels, metrics)
- `/plan-marketing gtm <product>` -- Go-to-market plan for a product/feature launch
- `/plan-marketing content-strategy` -- Content marketing strategy (topics, cadence, channels, SEO)
- `/plan-marketing competitive` -- Competitive marketing analysis

**Multi-agent value**: HIGH. Market research, messaging design, and competitive analysis are independent parallel
workstreams. Two Skeptics cover orthogonal failure modes: unmeasurable strategy (Measurability) vs. legally risky claims
(Legal/Claims).

**Framework reuse**: ~55%. Same orchestration patterns. Output: `docs/marketing/`.

**Startup priority**: HIGH. Marketing strategy done right is the difference between product-market fit and wasting
runway on unfocused campaigns.

**Effort**: Medium

### 3.2 `/build-content` -- Content Production Team

**Problem**: Content marketing requires consistent, high-quality output across multiple formats (blog posts, social
media, email newsletters, landing pages). Most startups either don't produce enough content or produce content that's
generic and undifferentiated.

**Team**:

- **Content Editor** (lead, Opus): Coordinates production, maintains editorial calendar consistency, ensures brand voice
- **Content Writer** (Sonnet): Writes drafts -- blog posts, social posts, email copy, landing page copy
- **SEO Researcher** (Sonnet): Keyword research, competitive content analysis, search intent mapping, internal linking
  strategy
- **Originality Skeptic** (Opus): Reviews for originality and genuine insight. Scope: "Would a human expert write this?"
  Rejects generic AI-sounding content, repackaged common knowledge, and anything that does not add a distinct
  perspective. The #1 risk of AI-generated content is that it reads like AI-generated content -- this Skeptic's entire
  job is to catch that.
- **Accuracy & Brand Skeptic** (Opus): Reviews for factual accuracy of technical claims, brand voice consistency, and
  SEO alignment (keywords present but natural). Scope: "Is this correct and on-brand?" Verifies technical claims against
  the codebase or documentation, ensures tone matches brand guidelines, and checks that SEO optimization does not
  compromise readability.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Originality Skeptic |
Content quality and differentiation | "This is generic -- what unique insight does it offer?" "I've read this take 100
times." "This sounds like AI wrote it." | | Accuracy & Brand Skeptic | Correctness and brand alignment | "This technical
claim is wrong." "This doesn't sound like our brand." "Keywords feel forced." |

**Peer-to-Peer Collaboration**:

- Content Writer and SEO Researcher **collaborate throughout the writing process** -- SEO Researcher provides target
  keywords, search intent, and competitive content gaps BEFORE writing begins, and reviews drafts for natural keyword
  integration
- Content Writer shares early drafts with Originality Skeptic for directional feedback before completing the full piece
  -- catching generic direction early saves full rewrites
- SEO Researcher and Accuracy & Brand Skeptic coordinate on whether SEO-optimized changes compromise accuracy or brand
  voice

**Quality Gate Flow**: Originality Skeptic must approve that the content offers genuine insight and does not read as
generic AI output. Accuracy & Brand Skeptic must approve factual correctness, brand voice, and SEO integration. Both
must approve before content is delivered.

**Modes**:

- `/build-content blog <topic>` -- Blog post from topic/outline
- `/build-content social <campaign>` -- Social media content batch
- `/build-content email <campaign>` -- Email newsletter or drip campaign
- `/build-content landing-page <product>` -- Landing page copy

**Multi-agent value**: MEDIUM-HIGH. Writing and SEO research are parallel. Two Skeptics cover the two biggest content
failures: generic/undifferentiated (Originality) vs. inaccurate/off-brand (Accuracy & Brand).

**Framework reuse**: ~50%. Orchestration patterns transfer. New output formats.

**Startup priority**: MEDIUM-HIGH. Content marketing is the primary growth lever for many SaaS startups.

**Effort**: Medium

---

## DOMAIN 4: Finance & Accounting

### 4.1 `/plan-finance` -- Financial Planning Team

**Problem**: Startups need financial models, budget plans, unit economics analysis, and fundraising materials. Most
founders lack finance expertise and produce models with unrealistic assumptions. Getting the financial story right is
critical for fundraising and resource allocation.

**Team**:

- **Finance Lead** (lead, Opus): Coordinates financial planning, synthesizes analysis into cohesive financial narrative
- **Financial Modeler** (Opus): Builds revenue projections, cost models, cash flow forecasts, scenario analyses. Needs
  Opus for reasoning about interdependent financial variables.
- **Unit Economics Analyst** (Sonnet): Calculates CAC, LTV, payback period, gross margin, burn rate, runway. Reads
  provided financial data.
- **Financial Rigor Skeptic** (Opus): Challenges model assumptions, growth projections, and cost estimates for realism.
  Scope: "Are these numbers defensible?" Demands evidence for every growth rate, rejects hockey-stick projections
  without supporting data, and verifies that cost models include hidden costs (engineering time, infrastructure scaling,
  hiring ramp-up).
- **Regulatory Compliance Skeptic** (Opus): Reviews financial outputs for regulatory and reporting standards compliance.
  Scope: "Would this pass scrutiny?" Flags revenue recognition issues, inconsistent accounting treatment, missing
  disclosures for fundraising materials, and ensures financial representations to investors meet legal standards. Every
  financial document must include appropriate disclaimers.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Financial Rigor Skeptic
| Model accuracy and realism | "10% MoM growth -- based on what?" "Your CAC ignores engineering time." "Runway assumes
zero new hires -- you just approved 3." | | Regulatory Compliance Skeptic | Legal and reporting standards | "Revenue
recognition timing is wrong." "This projection needs a disclaimer." "Investor materials must disclose assumptions." |

**Peer-to-Peer Collaboration**:

- Financial Modeler and Unit Economics Analyst **must align on shared inputs** -- both use the same revenue and cost
  data, and inconsistencies between their outputs indicate a data disagreement that must be resolved collaboratively
- Financial Modeler shares model assumptions with Financial Rigor Skeptic early for directional validation before
  building the full model
- Unit Economics Analyst and Regulatory Compliance Skeptic coordinate on metric definitions to ensure they align with
  standard reporting practices

**Quality Gate Flow**: Financial Rigor Skeptic must approve all model assumptions and projections as defensible.
Regulatory Compliance Skeptic must approve that all financial representations meet legal and reporting standards. Both
must approve before any financial document is delivered. For fundraising materials, both gates are especially strict.

**Modes**:

- `/plan-finance model <scenario>` -- Financial model for a scenario (fundraise, new product line, expansion)
- `/plan-finance unit-economics` -- Unit economics deep dive
- `/plan-finance budget <period>` -- Budget planning for a period
- `/plan-finance fundraise` -- Fundraising narrative: deck financials, investor FAQ, valuation rationale

**Multi-agent value**: HIGH. Financial modeling, unit economics, and assumption validation are genuinely independent
analytical tracks. Two Skeptics cover orthogonal risks: unrealistic numbers (Rigor) vs. non-compliant representations
(Regulatory).

**Framework reuse**: ~55%. Orchestration patterns transfer cleanly. Need financial-specific output templates. Output:
`docs/finance/`.

**Startup priority**: HIGH. Financial planning quality directly determines fundraising success and resource allocation
effectiveness. Most founders are not finance experts.

**Effort**: Medium-Large. Financial modeling requires careful prompt engineering to produce useful (not hallucinated)
numbers. The skill must emphasize that outputs are MODELS, not forecasts -- assumptions must be made explicit and
testable.

**Risk**: Financial model accuracy depends heavily on input data quality. The skill must have strong disclaimers and
both Skeptics must flag unsupported assumptions aggressively.

**Confidence**: MEDIUM-HIGH

### 4.2 `/draft-investor-update` -- Investor Communications

**Problem**: Founders spend 4-8 hours monthly writing investor updates. The updates are often inconsistent in format and
miss key metrics. A structured agent team can draft updates from provided data, ensuring completeness and consistency.

**Team**:

- **Communications Lead** (lead, Opus): Coordinates update assembly
- **Metrics Analyst** (Sonnet): Compiles key metrics, calculates period-over-period changes, highlights trends
- **Narrative Writer** (Sonnet): Writes the qualitative sections -- wins, challenges, asks, strategy updates
- **Honesty Skeptic** (Opus): Reviews for completeness and candor. Scope: "Is this honest?" Rejects sugarcoated
  challenges, demands that bad news is presented clearly, and ensures the update does not bury unfavorable metrics.
  Investors respect transparency -- this Skeptic enforces it.
- **Completeness Skeptic** (Opus): Reviews for structural completeness and consistency with prior updates. Scope: "Is
  anything missing?" Verifies all standard metrics are present, asks for context on metric changes, and ensures asks are
  specific and actionable (not "we need help with hiring" but "we need introductions to senior backend engineers in the
  SF Bay Area").

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Honesty Skeptic |
Transparency and candor | "This 'challenge' section is too positive." "Why is churn not mentioned?" "This spins the miss
-- be direct." | | Completeness Skeptic | Structural completeness | "MRR is missing." "Last month you reported ARR --
where is it?" "Your ask is vague -- what specifically do you need?" |

**Peer-to-Peer Collaboration**:

- Metrics Analyst and Narrative Writer **coordinate to ensure the narrative matches the data** -- the Narrative Writer
  must reference specific metrics, and the Metrics Analyst must verify that narrative claims are supported by the
  numbers
- Metrics Analyst shares notable trends or anomalies with Honesty Skeptic so the Skeptic knows what to look for in the
  narrative section
- Narrative Writer consults Completeness Skeptic on prior update format to ensure structural consistency

**Quality Gate Flow**: Honesty Skeptic must approve that the update is transparent and does not obscure bad news.
Completeness Skeptic must approve that all standard metrics and sections are present and consistent with prior updates.
Both must approve before the update is delivered.

**Multi-agent value**: MEDIUM. Metrics compilation and narrative writing are parallel. Two Skeptics prevent the two
investor update failure modes: dishonesty and incompleteness.

**Framework reuse**: ~55%.

**Startup priority**: MEDIUM. Useful time-saver but not existential.

**Effort**: Small-Medium

---

## DOMAIN 5: People Operations / HR

### 5.1 `/plan-hiring` -- Hiring Strategy Team

**Problem**: Startups rush to write job descriptions and post them without defining the role clearly, aligning on
interview criteria, or structuring the evaluation process. This leads to bad hires, wasted interview time, and candidate
experience problems.

**Team**:

- **Hiring Lead** (lead, Opus): Coordinates the hiring plan, ensures alignment between role definition, JD, and
  interview process
- **Role Designer** (Opus): Defines the role: responsibilities, success metrics, required vs. nice-to-have skills,
  reporting structure, growth path. Reads existing team structure and product needs.
- **JD Writer** (Sonnet): Writes the job description -- clear, specific, inclusive, honest about challenges. Avoids
  jargon and unrealistic requirements.
- **Interview Designer** (Sonnet): Creates structured interview plan: stages, questions per stage, rubric, take-home
  assignment (if any), timeline
- **Bias & Inclusion Skeptic** (Opus): Reviews all hiring materials for bias, exclusionary language, and legal risk.
  Scope: "Is this fair and inclusive?" Flags gendered language, unnecessary requirements that exclude qualified
  candidates, "culture fit" criteria without measurable definition, and interview questions that test for privilege
  rather than ability.
- **Rigor Skeptic** (Opus): Challenges the structural quality of the hiring process. Scope: "Will this actually identify
  the best candidate?" Rejects rubrics without scoring criteria ("vibes-based hiring"), JDs with 15+ requirements
  ("you'll get zero applicants"), role definitions without success metrics, and interview designs without calibration
  guidance.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Bias & Inclusion
Skeptic | Fairness and legal compliance | "This language is gendered." "Do you really need a CS degree?" "'Culture fit'
-- define the measurement." | | Rigor Skeptic | Process quality and effectiveness | "No scoring rubric = vibes hiring."
"15 requirements = 0 applicants." "How do you calibrate across interviewers?" |

**Peer-to-Peer Collaboration**:

- Role Designer and JD Writer **iterate together** -- the Role Designer defines the role, the JD Writer translates it
  into an appealing description, and they cross-check that the JD accurately reflects the role without inflation
- Interview Designer consults with Role Designer to ensure interview questions map to the defined success criteria, not
  unrelated proxy signals
- JD Writer shares drafts with Bias & Inclusion Skeptic early for language review before the formal gate
- Interview Designer and Rigor Skeptic collaborate on rubric design -- the Skeptic provides feedback on scoring criteria
  while the designer builds the interview plan

**Quality Gate Flow**: Bias & Inclusion Skeptic must approve all hiring materials for fairness, inclusive language, and
legal compliance. Rigor Skeptic must approve the structural quality of the role definition, JD, interview plan, and
rubric. Both must approve before any hiring materials are delivered.

**Modes**:

- `/plan-hiring role <title>` -- Full hiring plan for a role
- `/plan-hiring jd <title>` -- Job description only
- `/plan-hiring interview <role>` -- Interview process design only
- `/plan-hiring rubric <role>` -- Evaluation rubric and scorecard

**Multi-agent value**: HIGH. Role design, JD writing, and interview design are independent parallel tracks. Two Skeptics
cover orthogonal hiring failures: bias/exclusion (Bias & Inclusion) vs. process weakness (Rigor).

**Framework reuse**: ~55%. Orchestration patterns transfer. Output: `docs/hiring/`.

**Startup priority**: HIGH. Bad hires are the most expensive mistake a startup makes. A structured approach to hiring
saves tens of thousands in mis-hires.

**Effort**: Medium

### 5.2 `/plan-onboarding` -- Employee Onboarding Design

**Problem**: New hire onboarding is often ad-hoc at startups -- "shadow someone for a week." Structured onboarding
(30-60-90 day plan, learning resources, milestone check-ins) dramatically improves time-to-productivity and retention.

**Team**:

- **Onboarding Lead** (lead, Opus): Coordinates onboarding program design
- **Program Designer** (Sonnet): Creates the 30-60-90 plan, learning modules, milestone definitions
- **Content Curator** (Sonnet): Identifies existing documentation, tools, and resources for the onboarding package
- **Realism Skeptic** (Opus): Challenges timeline feasibility and workload assumptions. Scope: "Can a new hire actually
  do this?" Rejects overloaded Day 1 schedules ("7 tools to set up is a full day lost"), unrealistic learning
  expectations, and missing rest/absorption time. Demands that the plan accounts for the new hire being a human, not a
  machine.
- **Retention Skeptic** (Opus): Challenges for early warning signals and engagement design. Scope: "Will you know if
  they're struggling?" Demands regular check-ins (no gaps longer than a week), feedback mechanisms, clear success
  milestones that the new hire and manager agree on, and escalation paths for when onboarding goes off track.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Realism Skeptic |
Feasibility and workload | "Day 1: 7 tools? That's a full day lost." "Week 2: shipping a feature? Too soon for most
roles." | | Retention Skeptic | Engagement and early warning | "No check-in until day 30?" "How does the manager know if
they're stuck?" "What's the escalation path?" |

**Peer-to-Peer Collaboration**:

- Program Designer and Content Curator **coordinate on resource availability** -- the plan should only reference
  resources that actually exist, and Content Curator flags gaps that require new documentation
- Program Designer shares the 30-60-90 plan with Realism Skeptic early for timeline validation before detailing learning
  modules
- Content Curator and Retention Skeptic coordinate on feedback mechanisms -- the Skeptic specifies what check-ins are
  needed, and the Curator identifies existing tools or templates for them

**Quality Gate Flow**: Realism Skeptic must approve that the timeline and workload are feasible for a new hire.
Retention Skeptic must approve that engagement mechanisms and early warning signals are adequate. Both must approve
before the onboarding program is delivered.

**Multi-agent value**: MEDIUM. Parallel but the scope is narrower than hiring.

**Framework reuse**: ~55%.

**Startup priority**: MEDIUM. Important but less urgent than hiring strategy.

**Effort**: Small-Medium

---

## DOMAIN 6: Legal & Compliance

### 6.1 `/review-legal` -- Legal Review Team

**Problem**: Startups sign contracts, write ToS/privacy policies, and enter vendor agreements without legal review
because lawyers are expensive. An AI-assisted legal review that identifies risk areas, missing clauses, and unfavorable
terms -- while clearly disclaiming it's NOT legal advice -- can prevent costly mistakes.

**Team**:

- **Legal Analyst** (lead, Opus): Coordinates review, synthesizes findings into risk-rated report
- **Contract Reviewer** (Opus): Reads contracts clause by clause, identifies problematic terms, missing protections,
  unusual obligations, liability exposure. Needs Opus for nuanced legal reasoning.
- **Compliance Checker** (Sonnet): Cross-references terms against relevant regulations (GDPR data processing clauses,
  SOC2 vendor requirements, etc.)
- **Completeness Skeptic** (Opus): Reviews for missed clauses, gaps in analysis, and overlooked risk areas. Scope: "What
  did you miss?" Challenges the review for thoroughness -- "You flagged indemnification but missed the unlimited
  liability in Section 8.3." "Your compliance check missed the data residency requirement." In legal review, what you
  miss is more dangerous than what you find.
- **Severity Skeptic** (Opus): Challenges risk ratings and prioritization. Scope: "How bad is this really?" Prevents
  both over-alarming (flagging standard boilerplate as "high risk") and under-alarming (rating genuinely dangerous
  clauses as "low risk"). Demands that every risk rating is justified with specific consequences and likelihood.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Completeness Skeptic |
Coverage thoroughness | "Did you check Section 8.3?" "What about data residency?" "Termination clause analysis is
missing." | | Severity Skeptic | Risk rating accuracy | "This is standard boilerplate -- not high risk." "Unlimited
liability IS high risk -- why rated medium?" |

**Peer-to-Peer Collaboration**:

- Contract Reviewer and Compliance Checker **share clause-level findings** as they progress through the document -- a
  contractual obligation may have compliance implications, and vice versa, so they must cross-reference in real time
- Contract Reviewer flags clauses with regulatory implications to Compliance Checker for deeper analysis
- Compliance Checker shares regulatory context with Contract Reviewer so contract-level risks are understood in their
  regulatory context
- Both share intermediate findings with Completeness Skeptic so the Skeptic can identify gaps early rather than only at
  the final gate

**Quality Gate Flow**: Completeness Skeptic must approve that the review covers all material clauses and compliance
areas -- no significant gaps. Severity Skeptic must approve that all risk ratings are calibrated and justified. Both
must approve before the legal analysis report is delivered. Every output must begin with: "This analysis identifies
potential concerns for discussion with qualified legal counsel. It is not legal advice."

**Modes**:

- `/review-legal contract <type>` -- Review a vendor/customer/partnership contract
- `/review-legal policy <type>` -- Review privacy policy, ToS, or acceptable use policy
- `/review-legal compliance <regulation>` -- Compliance gap analysis (GDPR, SOC2, HIPAA)

**Multi-agent value**: HIGH. Contract review and compliance checking are independent parallel analyses. Two Skeptics
cover orthogonal legal review failures: missing something (Completeness) vs. miscalibrating risk (Severity).

**Framework reuse**: ~55%.

**Startup priority**: HIGH. Legal risk is existential for startups. Even a basic AI-assisted review that catches the
obvious problems saves thousands in legal fees.

**Effort**: Medium-Large. Legal domain requires careful prompt engineering. Strong disclaimers that this is NOT legal
advice and does NOT replace attorney review are non-negotiable.

**Risk**: Users may over-rely on AI legal review. Disclaimer enforcement is the Severity Skeptic's additional
responsibility.

**Confidence**: MEDIUM

---

## DOMAIN 7: Customer Success

### 7.1 `/plan-customer-success` -- Customer Success Strategy Team

**Problem**: Startups often lack a structured approach to post-sale customer engagement. Onboarding is ad-hoc, churn
signals are missed, and expansion opportunities are invisible. A systematic customer success program design creates the
playbooks that prevent churn and drive expansion.

**Team**:

- **CS Strategist** (lead, Opus): Coordinates customer success program design
- **Journey Mapper** (Opus): Designs the customer lifecycle: onboarding, adoption, renewal, expansion. Defines
  touchpoints, health scores, and intervention triggers.
- **Playbook Writer** (Sonnet): Creates specific playbooks for each stage: onboarding steps, at-risk intervention
  scripts, QBR templates, expansion conversation guides
- **Feasibility Skeptic** (Opus): Challenges for operational realism and tooling constraints. Scope: "Can you actually
  execute this?" Reviews health scores for measurability ("Can you track all 8 metrics with your current tooling?"),
  playbooks for realism ("3 days to integrate an API is unrealistic for enterprise"), and intervention triggers for
  signal availability.
- **Customer Empathy Skeptic** (Opus): Challenges from the customer's perspective. Scope: "Would a customer actually
  want this?" Reviews touchpoint frequency for annoyance risk ("5 check-ins in month 1 feels pushy"), playbook language
  for authenticity ("this QBR template is a thinly disguised upsell pitch"), and intervention timing for
  appropriateness. Demands that every customer interaction provides genuine value to the customer, not just to the
  company.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Feasibility Skeptic |
Operational realism | "Can you track this metric?" "Do you have the staff for this touchpoint cadence?" "This trigger
requires data you don't collect." | | Customer Empathy Skeptic | Customer experience quality | "5 check-ins in month 1
is pushy." "This QBR is really a sales pitch." "Would a customer find this valuable?" |

**Peer-to-Peer Collaboration**:

- Journey Mapper and Playbook Writer **iterate closely** -- the Journey Mapper defines lifecycle stages and triggers,
  the Playbook Writer creates specific scripts for each, and they cross-check that playbooks align with the journey
  design
- Journey Mapper shares health score design with Feasibility Skeptic early to validate that proposed metrics are
  actually trackable
- Playbook Writer shares intervention scripts with Customer Empathy Skeptic for tone and authenticity feedback before
  the formal gate

**Quality Gate Flow**: Feasibility Skeptic must approve that all metrics, triggers, and playbooks are operationally
executable with the company's current capabilities. Customer Empathy Skeptic must approve that the customer experience
is genuinely valuable and not annoying or manipulative. Both must approve before the CS program is delivered.

**Modes**:

- `/plan-customer-success program` -- Full CS program design
- `/plan-customer-success onboarding <product>` -- Customer onboarding workflow
- `/plan-customer-success health-scoring` -- Customer health score model design
- `/plan-customer-success playbook <scenario>` -- Specific playbook (at-risk, renewal, expansion, QBR)

**Multi-agent value**: HIGH. Journey mapping, playbook writing, and tooling analysis are parallel tracks. Two Skeptics
cover orthogonal CS failures: unexecutable programs (Feasibility) vs. customer-hostile programs (Customer Empathy).

**Framework reuse**: ~55%. Output: `docs/customer-success/`.

**Startup priority**: HIGH for B2B SaaS. Churn is the killer metric. A structured CS program is the primary defense.

**Effort**: Medium

---

## DOMAIN 8: Operations & Strategy

### 8.1 `/plan-strategy` -- Strategic Planning Team

**Problem**: Startups make strategic decisions (market focus, pricing, feature prioritization, hiring plan, fundraising
timing) based on gut feeling and founder conviction. A structured strategic planning process that forces evidence-based
analysis and adversarial challenge produces better decisions.

**Team**:

- **Strategy Lead** (lead, Opus): Coordinates strategic planning session
- **Market Analyst** (Opus): Analyzes market trends, competitor positioning, customer segments, TAM/SAM/SOM. Reads
  provided market data, competitor info, and product metrics.
- **Internal Analyst** (Sonnet): Reviews current company metrics: growth rate, retention, unit economics, team capacity,
  product velocity, technical debt indicators
- **Scenario Planner** (Opus): Develops 2-3 strategic scenarios (aggressive, moderate, conservative) with resource
  implications, risk profiles, and decision criteria
- **Assumptions Skeptic** (Opus): Challenges every factual assumption and projection. Scope: "Is this true?" Demands
  evidence for growth assumptions, market size claims, competitive positioning assertions, and resource availability
  claims. "Your aggressive scenario assumes hiring 5 engineers in Q2 -- your current pipeline has 0 candidates."
- **Execution Skeptic** (Opus): Challenges strategic plans for executability given current resources and capabilities.
  Scope: "Can you actually do this?" Reviews strategies against team capacity, technical capabilities, financial runway,
  and organizational readiness. "You're planning to enter 3 new markets while your core product has 40% churn."

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Assumptions Skeptic |
Factual basis of the strategy | "Evidence for this TAM?" "Pipeline has 0 candidates for 5 roles." "Competitor data is 6
months old." | | Execution Skeptic | Organizational capacity to execute | "Team is at 90% capacity -- where does this
initiative fit?" "3 new markets with 40% churn?" "Who owns this?" |

**Peer-to-Peer Collaboration**:

- Market Analyst and Internal Analyst **cross-reference findings** -- external market opportunities only matter if
  internal capabilities can capture them, and they must jointly identify the intersection of market opportunity and
  company readiness
- Scenario Planner consults with both Analysts to ensure scenarios are grounded in actual data, not hypothetical
  possibilities
- Market Analyst shares competitive intelligence with Assumptions Skeptic to get early validation on market claims
  before they shape the strategy
- Internal Analyst shares capacity and velocity data with Execution Skeptic to calibrate "what's realistic" before the
  formal gate

**Quality Gate Flow**: Assumptions Skeptic must approve that all assumptions, data claims, and projections are
evidence-based. Execution Skeptic must approve that the strategy is executable given current resources and capabilities.
Both must approve before the strategic plan is finalized. In `decision` mode, both must approve the decision framework
before it is used.

**Modes**:

- `/plan-strategy quarterly` -- Quarterly strategic review
- `/plan-strategy annual` -- Annual strategic plan
- `/plan-strategy decision <question>` -- Structured decision analysis for a specific strategic question
- `/plan-strategy competitive` -- Competitive landscape and positioning analysis

**Multi-agent value**: HIGH. Market analysis, internal analysis, and scenario planning are genuinely independent
parallel tracks. Two Skeptics prevent the two biggest strategic planning failures: believing things that aren't true
(Assumptions) vs. planning things you can't execute (Execution).

**Framework reuse**: ~55%. Output: `docs/strategy/`.

**Startup priority**: HIGH. Strategic clarity is the difference between focused execution and scattered effort.

**Effort**: Medium-Large

### 8.2 `/plan-operations` -- Operations Design Team

**Problem**: As startups grow, they need operational processes: vendor evaluation criteria, procurement workflows,
internal communication structures, meeting cadences, tool selection, cost optimization. This operational scaffolding is
usually built reactively (after something breaks) rather than proactively.

**Team**:

- **Ops Lead** (lead, Opus): Coordinates operations design
- **Process Designer** (Sonnet): Designs specific processes, workflows, and documentation
- **Tool/Vendor Evaluator** (Sonnet): Evaluates tool options, vendor proposals, pricing, integration requirements
- **Overhead Skeptic** (Opus): Challenges every proposed process for cost-to-the-organization. Scope: "Is the cure worse
  than the disease?" Calculates meeting hours, admin burden, and cognitive overhead of proposed processes. "This adds 3
  meetings per week to a 10-person team." "Do you actually need this process, or are you solving a people problem with a
  process?"
- **Scalability Skeptic** (Opus): Challenges designs for future growth compatibility. Scope: "Does this still work at
  5x?" Reviews processes for brittleness at scale, vendor pricing at higher tiers, tool limitations at volume, and
  organizational dependencies that become bottlenecks.

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Overhead Skeptic |
Process cost and necessity | "3 new meetings for a 10-person team?" "Is this a process or bureaucracy?" "What problem
does this actually solve?" | | Scalability Skeptic | Growth compatibility | "This breaks at 50 people." "Vendor pricing
5x at next tier." "This creates a single point of failure." |

**Peer-to-Peer Collaboration**:

- Process Designer and Tool/Vendor Evaluator **coordinate on process-tool fit** -- processes should be designed around
  available tooling, and tool choices should support the designed processes
- Process Designer shares workflow drafts with Overhead Skeptic early for overhead assessment before detailing the full
  design
- Tool/Vendor Evaluator shares vendor options with Scalability Skeptic for growth-tier pricing and limitation analysis

**Quality Gate Flow**: Overhead Skeptic must approve that every proposed process justifies its organizational cost and
is genuinely necessary. Scalability Skeptic must approve that designs will function at 5x the current scale. Both must
approve before operational designs are delivered.

**Modes**:

- `/plan-operations process <area>` -- Design a specific operational process
- `/plan-operations vendor <category>` -- Vendor evaluation and comparison
- `/plan-operations cost-review` -- Operational cost optimization review
- `/plan-operations tools <category>` -- Tool evaluation and selection

**Multi-agent value**: MEDIUM-HIGH. Process design and vendor/tool evaluation are parallel. Two Skeptics cover
orthogonal operational failures: over-engineering processes (Overhead) vs. designing for today at the expense of
tomorrow (Scalability).

**Framework reuse**: ~55%.

**Startup priority**: MEDIUM. Important for growth-stage startups (20+ employees). Less critical for early-stage.

**Effort**: Medium

---

## DOMAIN 9: Data & Analytics

### 9.1 `/plan-analytics` -- Analytics Strategy Team

**Problem**: Startups collect data but don't analyze it systematically. Dashboards are built ad-hoc, metrics are
inconsistently defined, and data-driven decisions are aspirational rather than actual. A structured analytics strategy
defines what to measure, how to measure it, and what actions to take.

**Team**:

- **Analytics Lead** (lead, Opus): Coordinates analytics strategy development
- **Metrics Designer** (Opus): Defines key metrics for each business function (product, sales, marketing, CS), including
  calculation methodology, data sources, and acceptable ranges
- **Dashboard Planner** (Sonnet): Designs dashboard layouts, visualization types, audience-specific views, alert
  thresholds
- **Actionability Skeptic** (Opus): Challenges every metric for decision-driving value. Scope: "Does this metric change
  a decision?" Demands that every tracked metric has a defined action threshold ("if metric X drops below Y, we do Z").
  Rejects vanity metrics ("page views is not a business metric"), metric bloat ("47 metrics means no one looks at any of
  them"), and metrics without owners.
- **Integrity Skeptic** (Opus): Challenges metric definitions for statistical validity, data quality, and
  misinterpretation risk. Scope: "Can you trust this number?" Reviews calculation methodologies for correctness, data
  source reliability, sample size adequacy for experiments, and dashboard visualizations for misleading presentations
  (truncated axes, cherry-picked time ranges, correlation-as-causation).

**Negative Personas**: | Persona | Scope | Key Questions | |---------|-------|---------------| | Actionability Skeptic |
Metric usefulness | "What decision does this metric inform?" "47 metrics = 0 metrics." "Who acts on this alert?" | |
Integrity Skeptic | Data quality and statistical validity | "How is this calculated?" "Sample size is too small." "That
Y-axis is misleading." |

**Peer-to-Peer Collaboration**:

- Metrics Designer and Dashboard Planner **coordinate on visualization-metric fit** -- the metric definition should
  inform the visualization type, and the dashboard should only display metrics that have been formally defined (no
  ad-hoc additions)
- Metrics Designer shares metric definitions with Actionability Skeptic early to validate that each metric has a clear
  decision-use before investing in dashboard design
- Dashboard Planner shares visualization drafts with Integrity Skeptic to catch misleading presentations before the
  formal gate
- For `experiment` mode: Metrics Designer and Integrity Skeptic collaborate on experimental design (hypothesis, sample
  size, significance threshold) before the experiment is defined

**Quality Gate Flow**: Actionability Skeptic must approve that every metric drives a specific decision and has an owner.
Integrity Skeptic must approve that all definitions, calculations, and visualizations are statistically valid and not
misleading. Both must approve before the analytics strategy is delivered.

**Modes**:

- `/plan-analytics strategy` -- Full analytics strategy
- `/plan-analytics metrics <domain>` -- Metrics definition for a business domain
- `/plan-analytics dashboard <audience>` -- Dashboard design for a specific audience
- `/plan-analytics experiment <hypothesis>` -- A/B test or experiment design

**Multi-agent value**: MEDIUM-HIGH. Metrics design and dashboard planning are parallel. Two Skeptics prevent the two
biggest analytics failures: tracking things that don't matter (Actionability) vs. tracking things incorrectly
(Integrity).

**Framework reuse**: ~55%. Output: `docs/analytics/`.

**Startup priority**: MEDIUM-HIGH. Data-driven decision-making is a competitive advantage, but most startups survive
without it in year one.

**Effort**: Medium

---

## Skills NOT Recommended (With Reasoning)

| Idea                             | Reason for Rejection                                                                   |
| -------------------------------- | -------------------------------------------------------------------------------------- |
| CRM data enrichment              | Requires CRM API access; mechanical data task, not multi-perspective analysis          |
| Social media posting/scheduling  | Execution task requiring platform APIs; single-agent with tool access, not multi-agent |
| Bookkeeping / invoicing          | Transactional task requiring accounting system access; not knowledge work              |
| Recruitment sourcing             | Requires LinkedIn/job board API access; platform-dependent execution                   |
| Customer support ticket response | Real-time task requiring support system integration; latency-sensitive                 |
| Sprint retrospective             | Human conversation facilitation; AI can summarize but shouldn't facilitate             |
| Feature flag management          | Configuration task; single-agent or script                                             |
| Monitoring/alerting setup        | Configuration-driven; not a multi-perspective problem                                  |
| Code formatting / linting        | Tooling task; not a multi-perspective problem                                          |
| Meeting notes / transcription    | Single-agent task with no adversarial quality gate value                               |

**Common rejection criteria**: The task is either (a) mechanical/transactional rather than analytical, (b) requires
real-time platform API access that agents can't provide, (c) doesn't benefit from multiple perspectives, or (d) doesn't
need a Skeptic quality gate.

---

## Complete Skill Catalog: Priority-Ordered

### Tier 1 -- Core Startup Functions (Build First)

| #   | Skill             | Domain      | Multi-Agent Value | Effort       | Startup Year-1 Priority |
| --- | ----------------- | ----------- | ----------------- | ------------ | ----------------------- |
| 1   | `/plan-product`   | Engineering | HIGH              | Exists       | CRITICAL                |
| 2   | `/build-product`  | Engineering | HIGH              | Exists       | CRITICAL                |
| 3   | `/review-quality` | Engineering | HIGH              | Exists       | CRITICAL                |
| 4   | `/plan-sales`     | Sales       | HIGH              | Medium       | CRITICAL                |
| 5   | `/plan-marketing` | Marketing   | HIGH              | Medium       | CRITICAL                |
| 6   | `/plan-finance`   | Finance     | HIGH              | Medium-Large | CRITICAL                |
| 7   | `/plan-strategy`  | Operations  | HIGH              | Medium-Large | CRITICAL                |

**Rationale**: These are the functions that determine whether a startup survives year one. Product, sales, marketing,
finance, and strategy are the core decision-making functions. Every startup needs all five, and quality in these areas
determines fundraising success, customer acquisition, and resource allocation.

### Tier 2 -- Growth Enablers (Build After Core)

| #   | Skill                     | Domain           | Multi-Agent Value | Effort       | Startup Year-1 Priority |
| --- | ------------------------- | ---------------- | ----------------- | ------------ | ----------------------- |
| 8   | `/plan-hiring`            | People Ops       | HIGH              | Medium       | HIGH                    |
| 9   | `/plan-customer-success`  | Customer Success | HIGH              | Medium       | HIGH (B2B)              |
| 10  | `/triage-incident`        | Engineering      | HIGH              | Medium       | HIGH                    |
| 11  | `/assess-debt`            | Engineering      | HIGH              | Medium       | HIGH                    |
| 12  | `/build-sales-collateral` | Sales            | MEDIUM-HIGH       | Medium       | HIGH                    |
| 13  | `/build-content`          | Marketing        | MEDIUM-HIGH       | Medium       | HIGH                    |
| 14  | `/review-legal`           | Legal            | HIGH              | Medium-Large | HIGH                    |

**Rationale**: Once the core strategy skills are in place, these skills support execution and growth. Hiring, customer
success, and sales collateral directly drive growth. Legal review prevents existential risk. Engineering maintenance
(incidents, debt) keeps the product healthy.

### Tier 3 -- Scale & Optimize (Build When Capacity Allows)

| #   | Skill                    | Domain           | Multi-Agent Value | Effort       | Startup Year-1 Priority |
| --- | ------------------------ | ---------------- | ----------------- | ------------ | ----------------------- |
| 15  | `/plan-analytics`        | Data & Analytics | MEDIUM-HIGH       | Medium       | MEDIUM-HIGH             |
| 16  | `/plan-operations`       | Operations       | MEDIUM-HIGH       | Medium       | MEDIUM                  |
| 17  | `/design-api`            | Engineering      | MEDIUM-HIGH       | Medium       | MEDIUM                  |
| 18  | `/plan-migration`        | Engineering      | HIGH              | Large        | MEDIUM                  |
| 19  | `/plan-onboarding`       | People Ops       | MEDIUM            | Small-Medium | MEDIUM                  |
| 20  | `/draft-investor-update` | Finance          | MEDIUM            | Small-Medium | MEDIUM                  |

---

## Naming Convention Recommendation

The existing skills use a `{verb}-{domain}` pattern:

- `plan-product`, `build-product`, `review-quality`

Proposed convention for expanded catalog:

- **`/plan-{domain}`** -- Strategy, analysis, and planning skills. Output: documents, plans, frameworks.
- **`/build-{domain}`** -- Content creation and production skills. Output: collateral, code, designs.
- **`/review-{domain}`** -- Audit, assessment, and evaluation skills. Output: findings, reports, scores.
- **`/triage-{domain}`** -- Urgent response and investigation skills. Output: root causes, action plans.

This gives a consistent verb taxonomy: | Verb | Purpose | Example Skills | |------|---------|---------------| | `plan` |
Strategize, design, decide | plan-product, plan-sales, plan-marketing, plan-finance, plan-strategy, plan-hiring,
plan-customer-success, plan-analytics, plan-operations, plan-migration, plan-onboarding | | `build` | Create, produce,
implement | build-product, build-sales-collateral, build-content | | `review` | Audit, assess, evaluate |
review-quality, review-legal | | `triage` | Investigate, respond | triage-incident | | `assess` | Analyze existing state
| assess-debt |

---

## Plugin Organization Recommendation

With 15+ skills, a single `conclave` plugin becomes unwieldy. Recommend organizing into multiple plugins within the
`wizards` marketplace:

| Plugin                | Skills                                                   | Domain           |
| --------------------- | -------------------------------------------------------- | ---------------- |
| `conclave` (existing) | plan-product, build-product, review-quality              | Engineering      |
| `conclave-sales`      | plan-sales, build-sales-collateral                       | Sales            |
| `conclave-marketing`  | plan-marketing, build-content                            | Marketing        |
| `conclave-finance`    | plan-finance, draft-investor-update                      | Finance          |
| `conclave-people`     | plan-hiring, plan-onboarding                             | People Ops       |
| `conclave-legal`      | review-legal                                             | Legal            |
| `conclave-strategy`   | plan-strategy, plan-operations, plan-analytics           | Strategy & Ops   |
| `conclave-eng-ops`    | triage-incident, assess-debt, design-api, plan-migration | Engineering Ops  |
| `conclave-cs`         | plan-customer-success                                    | Customer Success |

This allows users to install only the plugins relevant to their role. An engineer installs `conclave` +
`conclave-eng-ops`. A founder installs everything. A marketing hire installs `conclave-marketing`.

**Alternative**: A single `conclave-business` plugin bundling all non-engineering skills, with `conclave` remaining
engineering-focused. Simpler but less granular.

## Shared Principles Adaptation

The current 12 Shared Principles are engineering-focused (TDD, SOLID, contracts). For non-engineering skills, ~4
principles need domain-specific replacements:

| Current Principle           | Engineering Context     | Business Context Replacement                                                                          |
| --------------------------- | ----------------------- | ----------------------------------------------------------------------------------------------------- |
| #4 Minimal, clean solutions | Code minimalism         | Concise, actionable outputs -- no padding, no filler                                                  |
| #5 TDD by default           | Test-driven development | Evidence-driven analysis -- every claim backed by data or cited source                                |
| #6 SOLID and DRY            | Code design principles  | Structured, non-redundant outputs -- no repeated points, clear hierarchy                              |
| #7 Unit tests with mocks    | Testing strategy        | Assumptions explicitly stated -- every model/projection lists its assumptions                         |
| #8 Contracts are sacred     | API contracts           | Commitments are tracked -- when a plan states "we will do X by date Y", that's a trackable commitment |

Principles #1-3 (Skeptic approval, communication, no assumptions) and #9-12 (document decisions, delegate mode,
progressive disclosure, model selection) transfer without modification.

## Open Questions

1. **Shared Principles versioning**: If engineering and business skills use different principle sets, should there be a
   `shared/principles-engineering.md` and `shared/principles-business.md`? Or one unified set with domain-specific
   appendices?
2. **Cross-skill handoff**: `/plan-sales strategy` outputs a sales strategy. `/build-sales-collateral` consumes it. The
   current artifact handoff pattern (via `docs/` directories) works, but should there be a formal cross-skill dependency
   declaration?
3. **Data input**: Business skills (finance, analytics, sales pipeline) depend on the user providing data files. The
   engineering skills read code directly. Should business skills have a standardized data input format, or accept
   whatever the user provides?
4. **Disclaimer framework**: Legal and finance skills produce outputs that could be mistaken for professional advice.
   Should there be a framework-level disclaimer pattern (like the Skeptic pattern) that every advisory skill includes?
5. **MCP integration**: Some business skills would benefit enormously from MCP server access (CRM for sales, analytics
   platforms for data, financial systems for finance). Should skills be designed to work with and without MCP, with
   degraded capability when MCP is unavailable?
6. **Negative persona cost impact**: Every team now has 2 negative personas (both Opus). This adds ~2 Opus agents per
   skill invocation. For a 6-agent team with 2 Opus Skeptics, cost increases ~40% vs. a single-Skeptic design. Is this
   acceptable? Should lightweight mode downgrade one Skeptic to Sonnet? Or should the "primary" Skeptic remain Opus and
   the "secondary" be Sonnet by default?
7. **Skeptic interaction protocol**: Should the two negative personas on each team communicate with each other, or only
   independently with the lead? Independent evaluation prevents collusion but may miss cross-scope concerns. The current
   design says "do NOT collude" but some failure modes span both scopes.
8. **Retroactive engineering skill redesign**: The existing 3 engineering skills (plan-product, build-product,
   review-quality) each have a single Skeptic. Should they be upgraded to dual-Skeptic designs for consistency with the
   new skills? This would require SKILL.md changes and affects the existing user base.
