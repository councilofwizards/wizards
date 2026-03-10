# Product Roadmap

> **Source of truth**: Individual item files in this directory. This index is a convenience summary.
> **Last updated**: 2026-03-10

## Categories

| Category | Description |
|----------|-------------|
| `core-framework` | Improvements to the skill orchestration engine — agent spawning, communication, quality gates |
| `new-skills` | New slash commands beyond the existing core set |
| `business-skills` | Non-engineering skills for startup business functions (sales, marketing, finance, etc.) |
| `developer-experience` | Installation, configuration, onboarding, and day-to-day usability |
| `quality-reliability` | Testing infrastructure, error handling, resilience, and observability |
| `documentation` | Guides, tutorials, examples, and reference material |

## Prioritization Framework

Items are prioritized using two dimensions:

**Priority tiers**:
- **P1 (Critical)**: Blocks adoption or causes incorrect behavior. Must be addressed first.
- **P2 (Important)**: Significantly improves the product. Address after P1s.
- **P3 (Nice-to-have)**: Polish, convenience, or future-facing. Address when capacity allows.

**Scoring criteria** (used to assign priority):

| Factor | Weight | Description |
|--------|--------|-------------|
| Impact | 40% | How many users benefit? How much value does it create? |
| Risk | 30% | What breaks if we don't do this? What goes wrong if we do it badly? |
| Effort | 20% | How complex? A high-effort P1 still outranks a low-effort P3. |
| Dependencies | 10% | Does this unblock other high-value work? |

## Status Legend

- 🔴 `not_started` — No work begun
- 🟡 `spec_in_progress` — Spec being written by Product Team
- 🟢 `ready` — Spec approved, ready for Implementation Team
- 🔵 `impl_in_progress` — Implementation underway
- ✅ `complete` — Done and verified
- ⛔ `blocked` — Cannot proceed (see item for reason)

## Current Backlog

### P1 — Critical

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 1 | [Project Bootstrap & Initialization](P1-00-project-bootstrap.md) | core-framework | ✅ | Small |
| 2 | [Concurrent Write Safety](P1-01-concurrent-write-safety.md) | core-framework | ✅ | Medium |
| 3 | [State Persistence & Checkpoints](P1-02-state-persistence.md) | core-framework | ✅ | Large |
| 4 | [Stack Generalization](P1-03-stack-generalization.md) | core-framework | ✅ | Medium |

### P2 — Important

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 5 | [Cost Guardrails](P2-01-cost-guardrails.md) | developer-experience | ✅ | Medium |
| 6 | [Skill Composability](P2-02-skill-composability.md) | new-skills | 🔴 | Large |
| 7 | [Progress Observability](P2-03-progress-observability.md) | quality-reliability | ✅ | Medium |
| 8 | [Automated Testing Pipeline](P2-04-automated-testing.md) | quality-reliability | ✅ | Large |
| 9 | [Content Deduplication](P2-05-content-deduplication.md) | core-framework | ✅ | Medium |
| 10 | [Artifact Format Templates](P2-06-format-templates.md) | core-framework | ✅ | Medium |

| 11 | [Role-Based Principles Split](P2-07-universal-principles.md) | core-framework | 🔴 | Medium |
| 12 | [Plugin Organization (Multi-Plugin)](P2-08-plugin-organization.md) | core-framework | 🔴 | Medium |
| 13 | [Persona System Activation](P2-09-persona-system-activation.md) | core-framework | 🔴 | Small-Medium |
| 14 | [Skill Discoverability Improvements](P2-10-skill-discoverability.md) | developer-experience | 🔴 | Small |

> **P2-08 prerequisite**: Defer plugin organization until 2+ business skills are built and validated. Real-world skill structure should inform plugin boundaries.
> **P2-09 + P2-10**: Highest-ROI items from conclave-plugin-improvements research. Wave 1 implementation recommended.

### P3 — Nice-to-Have (Engineering)

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 15 | [Custom Agent Roles](P3-01-custom-agent-roles.md) | new-skills | 🔴 | Large |
| 16 | [Onboarding Wizard Skill](P3-02-onboarding-wizard.md) | developer-experience | ✅ | Small |
| 17 | [Architecture & Contribution Guide](P3-03-contribution-guide.md) | documentation | 🔴 | Small |
| 18 | [Incident Triage Skill](P3-04-triage-incident.md) | new-skills | 🔴 | Medium |
| 19 | [Tech Debt Review Skill](P3-05-review-debt.md) | new-skills | 🔴 | Medium |
| 20 | [API Design Skill](P3-06-design-api.md) | new-skills | 🔴 | Medium |
| 21 | [Migration Planning Skill](P3-07-plan-migration.md) | new-skills | 🔴 | Large |
| 22 | [Persona Reference Validator](P3-08-persona-reference-validator.md) | quality-reliability | 🔴 | Medium |
| 23 | [Artifact Continuity Badges](P3-09-artifact-continuity-badges.md) | core-framework | 🔴 | Small |

> **P3-08 dependency**: Must be implemented AFTER P2-09 (Persona System Activation). Validator checks for fictional names in spawn prompts — will fail if P2-09 is not done first.

### P3 — Nice-to-Have (Business)

> **Strategy note**: Strategic planning (`/plan-strategy`) is scoped within the existing `/plan-product` skill rather than a standalone skill. The plan-product team already covers roadmap assessment, prioritization, and competitive analysis.

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 24 | [Sales Planning Skill](P3-10-plan-sales.md) | business-skills | ✅ | Medium |
| 25 | [Marketing Planning Skill](P3-11-plan-marketing.md) | business-skills | 🔴 | Medium |
| 26 | [Finance Planning Skill](P3-12-plan-finance.md) | business-skills | 🔴 | Medium-Large |
| 27 | [Hiring Planning Skill](P3-14-plan-hiring.md) | business-skills | ✅ | Medium |
| 28 | [Customer Success Skill](P3-15-plan-customer-success.md) | business-skills | 🔴 | Medium |
| 29 | [Sales Collateral Skill](P3-16-build-sales-collateral.md) | business-skills | 🔴 | Medium |
| 30 | [Content Production Skill](P3-17-build-content.md) | business-skills | 🔴 | Medium |
| 31 | [Legal Review Skill](P3-18-review-legal.md) | business-skills | 🔴 | Medium-Large |

### P3 — Nice-to-Have (Business — Scale & Optimize)

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 32 | [Analytics Planning Skill](P3-19-plan-analytics.md) | business-skills | 🔴 | Medium |
| 33 | [Operations Planning Skill](P3-20-plan-operations.md) | business-skills | 🔴 | Medium |
| 34 | [Employee Onboarding Skill](P3-21-plan-onboarding.md) | business-skills | 🔴 | Small-Medium |
| 35 | [Investor Update Skill](P3-22-draft-investor-update.md) | business-skills | ✅ | Small-Medium |

### P3 — Nice-to-Have (Persona & Documentation)

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 36 | [Persona System ADR (ADR-005)](P3-23-persona-system-adr.md) | documentation | 🔴 | Small |
| 37 | [run-task Persona Archetypes](P3-24-run-task-persona-archetypes.md) | core-framework | 🔴 | Medium |
| 38 | [PoC Skills Deprecation Banner](P3-25-poc-deprecation-banner.md) | developer-experience | 🔴 | Small |

> **P3-23, P3-24 dependency**: Both depend on P2-09 (Persona System Activation). ADR documents the completed system; run-task archetypes follow the injection pattern established by P2-09.
