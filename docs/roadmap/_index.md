# Product Roadmap

> **Source of truth**: Individual item files in this directory. This index is a convenience summary.
> **Last updated**: 2026-02-14

## Categories

| Category | Description |
|----------|-------------|
| `core-framework` | Improvements to the skill orchestration engine — agent spawning, communication, quality gates |
| `new-skills` | New slash commands beyond the existing three (`/plan-product`, `/build-product`, `/review-quality`) |
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
| 7 | [Progress Observability](P2-03-progress-observability.md) | quality-reliability | 🔴 | Medium |
| 8 | [Automated Testing Pipeline](P2-04-automated-testing.md) | quality-reliability | 🔴 | Large |
| 9 | [Content Deduplication](P2-05-content-deduplication.md) | core-framework | 🔴 | Medium |
| 10 | [Artifact Format Templates](P2-06-format-templates.md) | core-framework | ✅ | Medium |

### P3 — Nice-to-Have

| # | Item | Category | Status | Effort |
|---|------|----------|--------|--------|
| 11 | [Custom Agent Roles](P3-01-custom-agent-roles.md) | new-skills | 🔴 | Large |
| 12 | [Onboarding Wizard Skill](P3-02-onboarding-wizard.md) | developer-experience | 🔴 | Small |
| 13 | [Architecture & Contribution Guide](P3-03-contribution-guide.md) | documentation | 🔴 | Small |
