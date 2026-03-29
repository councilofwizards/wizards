# Proposed New Conclave Teams

This document catalogs proposed skills not yet on the roadmap, organized by
capability gap. Each entry describes what the team would do, why it's valuable,
the suggested agent composition, and how it fits into the existing artifact
flow.

Items already captured in the P3 roadmap (incident-triage, tech-debt-review,
plan-api-design, plan-migration, plan-marketing, plan-finance, plan-analytics,
plan-customer-success, review-legal, build-content, build-sales-collateral) are
excluded here — this list focuses on **net-new gaps**.

---

## Engineering

### `craft-frontend`

**What it does**: Frontend engineering counterpart to `craft-laravel`.
Orchestrates implementation of UI features through a phased workflow: component
design → state modeling → implementation → visual regression testing →
accessibility check.

**Why it's valuable**: `craft-laravel` fills a large gap for server-side work,
but frontend has its own distinct concerns — component hierarchies, state
management, reactivity models, bundle optimization, and CSS architecture.
Without a frontend-specific skill, agents building UI features fall back to
generic `build-implementation`, which lacks the pattern catalogs and quality
gates that make `craft-laravel` effective. A `craft-frontend` skill would carry
framework-specific guidance (React/Vue/Svelte), design-system conventions, and a
dedicated visual QA agent.

**Suggested agents**: Reconnaissance Agent, Component Architect, Implementation
Agent (x2 parallel), State & Data Agent, Visual QA Agent, Frontend Skeptic
(Opus)

**Artifact contract**: Consumes spec artifacts; produces
`docs/progress/{feature}-frontend-{role}.md` checkpoints; reads from
`docs/stack-hints/frontend.md` (new file)

---

### `audit-accessibility`

**What it does**: Conducts a systematic accessibility audit of a codebase or
feature area. Agents map WCAG 2.2 criteria against the implementation, produce a
prioritized remediation plan, generate code patches for fixable violations, and
write a conformance report.

**Why it's valuable**: `harden-security` follows a "threat model → audit → patch
→ verify" pattern that works equally well for accessibility. No equivalent skill
exists for a11y, yet accessibility is a legal compliance requirement (ADA, WCAG,
EU Accessibility Act) and a common quality gap that teams defer indefinitely.
The structured debate pattern ( severity vs. effort trade-offs) and dual-skeptic
validation from `plan-hiring` map naturally onto remediation prioritization.

**Suggested agents**: WCAG Mapper, Interaction Analyst, Remediation Engineer (x2
parallel — ARIA fixes, keyboard/focus fixes), Conformance Skeptic (Opus),
Accessibility Advocate (Ops Skeptic variant)

**Artifact contract**: Produces `docs/specs/{feature}-accessibility.md`;
checkpoints in `docs/progress/{feature}-a11y-{role}.md`

---

### `design-data-model`

**What it does**: Designs relational or document database schemas from a spec or
user stories. Agents produce entity-relationship diagrams (as Mermaid),
migration files, index strategies, and a data dictionary. A dedicated Evolution
Agent models how the schema must grow over the next 3 feature iterations to
avoid premature lock-in.

**Why it's valuable**: `write-spec` produces API contracts and component
boundaries but treats the data layer as a secondary concern.
`plan-implementation` makes file-level decisions but doesn't deeply reason about
schema normalization, index design, or schema evolution. Database design
mistakes are among the most expensive to reverse; a dedicated skill that forces
explicit modeling before any migration is written prevents a major category of
tech debt.

**Suggested agents**: Domain Modeler, Schema Architect, Evolution Agent, Index
Strategist, Migration Writer, Schema Skeptic (Opus)

**Artifact contract**: Consumes user stories or spec artifacts; produces
`docs/specs/{feature}-data-model.md` with embedded Mermaid ERD

---

### `build-api`

**What it does**: API-first development skill. Agents negotiate an OpenAPI 3.1
contract before writing any implementation code, then implement server stubs and
client SDKs in parallel, and verify contract compliance with contract tests.
Distinct from `build-implementation` in that the contract artifact is the
primary deliverable, not the code.

**Why it's valuable**: `write-spec` defines API contracts as prose, not
machine-readable schemas. `build-implementation` can implement an API but
doesn't enforce contract-first discipline. When multiple teams consume an API,
the contract needs to be the source of truth — generated, versioned, and tested
independently of the implementation. This skill enforces that discipline and
produces an artifact that can gate downstream frontend or mobile work.

**Suggested agents**: Contract Architect, Server Implementation Agent, Client
SDK Agent, Contract Test Agent, API Skeptic (Opus)

**Artifact contract**: Produces `docs/specs/{feature}-openapi.yaml` and
`docs/specs/{feature}-api-contract.md`; designed to be consumed by
`craft-frontend` or `craft-laravel`

---

### `setup-observability`

**What it does**: Instruments an application with structured logging,
distributed tracing, metrics, and alerting. Agents audit the current
observability state, design an instrumentation plan, implement OpenTelemetry
spans and metrics, configure alert thresholds, and produce a runbook for the ops
team.

**Why it's valuable**: `harden-security` addresses security posture and
`review-quality` addresses code quality, but neither addresses operational
observability — knowing what's happening in production. Observability is
consistently deferred by teams under time pressure yet is the first thing needed
when an incident occurs. A dedicated skill that produces instrumentation code,
dashboards-as-code (Grafana JSON), and a runbook fills a genuine operational
gap.

**Suggested agents**: Observability Auditor, Instrumentation Engineer, Metrics
Designer, Alert Strategist, Runbook Writer, Ops Skeptic (Opus)

**Artifact contract**: Produces `docs/architecture/observability-runbook.md`;
checkpoints in `docs/progress/observability-{role}.md`

---

### `plan-experiments`

**What it does**: Designs an experimentation framework for a product — feature
flags, A/B tests, and hypothesis-driven development. Agents define experiment
hypotheses, select statistical methods, design flag architecture, write the
instrumentation spec, and produce a go/no-go decision rubric for each
experiment.

**Why it's valuable**: The current pipeline goes from spec → implementation →
quality review, but there's no skill for " should we build this at all?" or "how
do we know if this change worked?" Experimentation is the feedback loop between
shipping and learning. `plan-product` can surface ideas but doesn't produce
experiment designs. This skill bridges the gap between product intuition and
evidence-based iteration.

**Suggested agents**: Hypothesis Agent, Statistical Advisor, Flag Architecture
Agent, Instrumentation Spec Agent, Experiment Skeptic (Opus)

**Artifact contract**: Produces `docs/specs/{feature}-experiment.md`; compatible
with `review-quality` for post-experiment analysis

---

### `craft-mobile`

**What it does**: Mobile engineering counterpart to `craft-laravel`.
Orchestrates implementation of mobile features with phases specific to mobile:
platform capability assessment → navigation & state design → implementation →
platform-specific testing → app store compliance check.

**Why it's valuable**: Mobile development carries constraints invisible to web
engineers — native APIs, platform review guidelines, offline-first data sync,
push notification lifecycles, and binary distribution pipelines.
`build-implementation` handles mobile code in principle but without the pattern
catalogs, testing strategies, or compliance gates that mobile shipping requires.
A `craft-mobile` skill with React Native and/or native iOS/Android stack hints
would give mobile teams the same quality leverage that `craft-laravel` gives
backend teams.

**Suggested agents**: Platform Reconnaissance Agent, Navigation Architect,
Feature Implementation Agent (x2 — iOS, Android/RN), Platform QA Agent, App
Store Compliance Agent, Mobile Skeptic (Opus)

**Artifact contract**: Reads from `docs/stack-hints/mobile.md` (new file);
produces checkpoints in `docs/progress/{feature}-mobile-{role}.md`

---

## Documentation

### `generate-docs`

**What it does**: Generates developer-facing documentation from existing code
and specs. Agents produce API reference docs (from OpenAPI or code comments),
architecture decision records, contribution guides, and onboarding READMEs. A
Clarity Skeptic reviews all output for accuracy and readability before
publishing.

**Why it's valuable**: Documentation is the perpetual last item on every sprint
board. `unearth-specification` extracts specs from undocumented code, but the
reverse — generating docs from well-specified code — has no skill. The pain is
acute for: new contributor onboarding, API consumers, and compliance audits.
This skill formalizes "doc sprint" work that currently happens ad hoc.

**Suggested agents**: Code Analyst, API Doc Writer, Architecture Narrator,
Contribution Guide Agent, Clarity Skeptic ( Opus)

**Artifact contract**: Consumes OpenAPI artifacts, spec files, and ADRs;
produces `docs/` markdown files in appropriate subdirectory

---

### `internationalize`

**What it does**: Plans and executes internationalization (i18n) and
localization (l10n) for a product. Agents audit string extraction completeness,
design locale file architecture, generate translation scaffolding, identify
locale-sensitive data (dates, currencies, pluralization), and produce a
localization workflow document for the translation team.

**Why it's valuable**: i18n is notoriously painful to retrofit — string
extraction, bidirectional text, plural forms, and locale-sensitive formatting
all require architectural decisions that are expensive to change later. There's
no current skill that addresses this, and it's a prerequisite for international
market expansion that `plan-sales` might recommend. A dedicated skill catches
i18n concerns before they become migration-class tech debt.

**Suggested agents**: String Auditor, Locale Architect, Extraction Agent, Format
& Plural Agent, Translation Workflow Writer, i18n Skeptic (Opus)

**Artifact contract**: Produces `docs/specs/{feature}-i18n.md` and locale
scaffolding files

---

## Business

### `interview-customers`

**What it does**: Designs and synthesizes customer research. Agents construct
interview guides aligned to specific hypotheses, analyze provided interview
transcripts or survey data, extract jobs-to-be-done and pain themes, update
persona documents, and produce a synthesis artifact with actionable product
insights.

**Why it's valuable**: `research-market` focuses on competitive and industry
analysis. `ideate-product` generates ideas from research artifacts. But neither
skill handles primary customer research — talking to actual users. This is the
missing link in the evidence chain. The `plan-sales` skill's cross-examination
pattern (agents arguing opposing interpretations of evidence) maps well to
qualitative research synthesis, where different analysts often surface
conflicting themes.

**Suggested agents**: Research Designer, Interview Analyst (x2 parallel — theme
extraction, sentiment analysis), Jobs-to-be-Done Synthesizer, Persona Updater,
Insight Skeptic (Opus)

**Artifact contract**: Produces `docs/research/customer-insights-{date}.md`;
compatible with `ideate-product` and `write-stories` as upstream input

---

### `plan-capacity`

**What it does**: Maps team capacity against roadmap demand. Agents model
velocity from historical sprint data, map upcoming roadmap items to estimated
effort, identify bottlenecks and overcommitment risks, propose a sprint
allocation plan, and flag staffing gaps for `plan-hiring` to address.

**Why it's valuable**: `plan-hiring` decides who to hire; `manage-roadmap`
decides what to build. But neither answers " can we actually ship this quarter?"
— the intersection of headcount, velocity, and scope. Sprint planning is
currently done manually, and the results aren't connected to roadmap artifacts.
A `plan-capacity` skill that reads roadmap frontmatter (effort fields) and
produces a capacity model closes the loop between strategy and execution.

**Suggested agents**: Velocity Analyst, Roadmap Demand Mapper, Bottleneck
Identifier, Sprint Allocation Agent, Capacity Skeptic (Opus)

**Artifact contract**: Reads roadmap frontmatter (`effort` fields); produces
`docs/architecture/capacity-plan.md`; designed to trigger `plan-hiring` when
gaps are found

---

### `build-pitch-deck`

**What it does**: Creates a fundraising pitch deck from existing product
artifacts. Agents extract the narrative arc from roadmap progress and investor
updates, write slide copy (problem, solution, traction, market, team, ask),
design the story flow, stress-test the pitch against investor objections, and
produce a slide-by-slide outline with speaker notes.

**Why it's valuable**: `draft-investor-update` handles ongoing investor
communication but not the initial fundraising narrative. A pitch deck requires a
different structure — compressed, conviction-forward, designed for cold
audiences. The structured debate pattern from `plan-hiring` (skeptic argues
investor objections) and `plan-sales` (cross-examining market claims) make this
a natural extension of existing business skill patterns.

**Suggested agents**: Narrative Architect, Market Claim Validator, Traction
Story Agent, Investor Objection Skeptic ( Opus), Deck Outline Writer

**Artifact contract**: Consumes `docs/research/` and `docs/progress/` artifacts;
produces `docs/artifacts/pitch-deck-outline.md`

---

### `plan-customer-success`

**What it does**: Designs a customer success playbook — onboarding sequences,
health scoring criteria, escalation paths for at-risk accounts, QBR templates,
and renewal strategy. Distinct from `plan-hiring`'s people focus and
`plan-sales`'s acquisition focus; this skill focuses on retention and expansion
after the sale.

**Why it's valuable**: Already on the P3 roadmap (P3-14) but included here
because the agent composition design is non-obvious. The skill needs both
quantitative modeling (health score weights, churn prediction signals) and
qualitative playbook writing (escalation scripts, success criteria by segment).
The collaborative analysis pattern from `plan-sales` — parallel agents
researching independent dimensions then cross-validating — fits well here.

**Suggested agents**: Onboarding Designer, Health Score Modeler, Escalation
Strategist, Renewal Playbook Agent, CS Skeptic (Opus)

**Artifact contract**: Produces `docs/specs/customer-success-playbook.md`;
inputs from `interview-customers` synthesis artifacts

---

## Meta / Infrastructure

### `evaluate-skill`

**What it does**: Runs structured evaluation of an existing conclave skill.
Agents execute the skill against a set of benchmark prompts, score output
quality across defined rubrics (correctness, completeness, skeptic
effectiveness, artifact format compliance), identify regressions from prior
runs, and recommend tuning changes.

**Why it's valuable**: `create-conclave-team` builds new skills; `skill-creator`
(an external skill) evaluates them. But there's no native conclave skill for
ongoing skill quality monitoring. As models improve, SCAFFOLD assumptions may
become outdated. As the skill count grows, regressions in one skill can go
unnoticed. An `evaluate-skill` team that produces structured eval reports would
provide the feedback loop needed for skill maintenance at scale.

**Suggested agents**: Prompt Designer (benchmark prompts), Execution Agent (runs
the skill under test), Rubric Scorer, Regression Analyst, Eval Skeptic (Opus)

**Artifact contract**: Produces
`docs/progress/skill-eval-{skill-name}-{date}.md`; reads SCAFFOLD comments from
target SKILL.md

---

### `map-dependencies`

**What it does**: Audits a codebase's dependency graph — both package
dependencies and internal module dependencies. Agents identify outdated
packages, flag security vulnerabilities in the dependency tree, detect circular
imports, map coupling between internal modules, and produce a dependency health
report with upgrade priority recommendations.

**Why it's valuable**: `harden-security` addresses application vulnerabilities
but doesn't deeply analyze the dependency supply chain. `review-tech-debt` (P3
roadmap) addresses code quality but not dependency hygiene specifically.
Dependency rot is one of the most common sources of both security risk and
upgrade pain. A focused skill that treats the dependency graph as a first-class
artifact fills a gap between security hardening and general tech debt review.

**Suggested agents**: Package Auditor, Vulnerability Scanner, Internal Coupling
Analyst, Upgrade Path Planner, Dependency Skeptic (Opus)

**Artifact contract**: Produces `docs/architecture/dependency-health.md`;
designed to feed into `plan-migration` for major upgrades

---

## Skill Composition Notes

Several of the proposed skills above are most powerful when composed in
sequence:

```
interview-customers  →  ideate-product  →  plan-experiments  →  build-implementation
design-data-model    →  build-api        →  craft-frontend
map-dependencies     →  plan-migration   →  build-implementation
plan-capacity        →  manage-roadmap   →  plan-hiring
```

These compositions are not prescriptive — `run-task` can orchestrate ad-hoc
sequences today — but dedicated pipeline skills (similar to `plan-product` and
`build-product`) could eventually codify the most common chains.
