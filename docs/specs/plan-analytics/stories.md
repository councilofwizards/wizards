---
type: "user-stories"
feature: "plan-analytics"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-19-plan-analytics.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-19 Analytics Planning Skill (plan-analytics)

## Epic Summary

Startups instrument tools, accumulate data, and still make decisions by intuition — because the data exists but the
measurement framework doesn't. `/plan-analytics` defines a multi-agent planning skill that assesses current analytics
tooling and KPIs, defines a business-function-aligned measurement framework, and produces a structured analytics plan
with instrumentation priorities and success metrics.

## Stories

### Story 1: Current Analytics State Assessment and User Data Ingestion

- **As a** founder or data lead invoking `/plan-analytics`
- **I want** the skill to read project docs and `_user-data.md` to understand my current analytics state before
  producing recommendations
- **So that** the resulting framework is grounded in what I actually have, not generic best practices
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/plan-analytics`, when Setup runs, then the Team Lead reads `docs/roadmap/`, `docs/specs/`,
     `docs/progress/`, and `docs/analytics/_user-data.md` before spawning agents.
  2. Given `docs/analytics/_user-data.md` does not exist, when Setup runs, then the Team Lead creates it from template
     and notifies the user.
  3. Given `_user-data.md` is missing or template-only, then the Team Lead outputs a data-dependency warning.
  4. Given user data and project docs are available, when Phase 1 runs, then the analytics strategist produces:
     current-state summary and business functions requiring measurement.
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - No analytics tooling mentioned: include tooling selection as prerequisite recommendation.
  - Early-stage with no users: focus on instrumentation readiness.
  - `--light` flag: skip assessment, use `_user-data.md` directly.
- **Notes**: Output: `docs/analytics/analytics-plan-{timestamp}.md`. `_user-data.md` fields: current tools, business
  stage, key funnels, existing KPIs, known gaps, data warehouse/BI tool.

### Story 2: KPI Framework Generation, Skeptic Gate, and Final Plan

- **As a** founder or data lead using `/plan-analytics`
- **I want** a measurement architect to map instrumentation to KPIs, and a skeptic to challenge vanity metrics and
  coverage gaps
- **So that** the KPI framework prioritizes signal over noise with no unmeasured critical paths
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given Phase 1 assessment, when Phase 2 runs, then the measurement architect produces: KPI definition table,
     prioritized instrumentation checklist, recommended reporting cadence.
  2. Given the framework draft, when Phase 3 runs, then the skeptic evaluates: vanity metrics, unmeasured funnels,
     achievability of instrumentation.
  3. Given issues found, the architect revises. Max iterations: 3.
  4. Given approval, the Team Lead writes to `docs/analytics/analytics-plan-{timestamp}.md` with appropriate
     frontmatter.
  5. Given I run `bash scripts/validate.sh`, then all validators pass.
- **Edge Cases**:
  - KPI conflicts between roadmap and `_user-data.md`: skeptic surfaces the conflict.
  - Missing instrumentation for a KPI: architect removes KPI or adds event — no gaps allowed.
- **Notes**: Metrics Skeptic persona at `plugins/conclave/shared/personas/metrics-skeptic.md`.

## Non-Functional Requirements

- Multi-agent SKILL.md with all 10 required sections. Category: `business`. Tags:
  `[analytics, kpis, measurement, data]`. Non-engineering.
- G-series ADR-005: verify business skill count before merging.

## Out of Scope

- Querying analytics platforms or data warehouses.
- Writing tracking code or SDK integration.
- Analyzing historical data.
- Dashboard or visualization design.
