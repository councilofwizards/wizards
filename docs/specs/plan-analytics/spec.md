---
title: "Analytics Planning Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Analytics Planning Skill Specification

## Summary

Create a new multi-agent business skill (`/plan-analytics`) that assesses current analytics state, defines a KPI framework aligned to business functions, and produces a structured analytics plan with instrumentation priorities. Hub-and-Spoke pattern with analytics strategist, measurement architect, and metrics skeptic.

## Problem

Startups collect data across multiple tools but lack a coherent measurement framework. This leads to vanity metrics, unmeasured funnels, and data-uninformed decision-making. Teams instrument what's easy to track rather than what matters for business outcomes.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/plan-analytics/SKILL.md`.

- **Category**: business
- **Tags**: [analytics, kpis, measurement, data]
- **Classification**: non-engineering (universal principles only)

### Agent Team (3 agents + lead)

| Agent | Model | Role |
|-------|-------|------|
| Analytics Strategist | sonnet | Assess current state: tools, existing KPIs, coverage gaps, business functions needing measurement |
| Measurement Architect | sonnet | Design KPI framework: metric definitions, data sources, instrumentation checklist, reporting cadence |
| Metrics Skeptic | opus | Challenge vanity metrics, flag unmeasured funnels, verify instrumentation achievability |

### Pipeline Flow

1. **Setup**: Read project docs + `docs/analytics/_user-data.md`. Create template if absent.
2. **Phase 1 (Assessment)**: Strategist produces current-state summary and business function inventory.
3. **Phase 2 (Framework Design)**: Architect produces KPI table, instrumentation checklist, reporting cadence.
4. **Phase 3 (Review)**: Metrics Skeptic reviews. Max iterations: 3.
5. **Output**: `docs/analytics/analytics-plan-{timestamp}.md`

### User Data Template (`docs/analytics/_user-data.md`)

Fields: current analytics tools, business stage, key funnels, existing KPIs and owners, known measurement gaps, data warehouse/BI tool.

### Persona

New: `plugins/conclave/shared/personas/metrics-skeptic.md`

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering — universal principles only
3. All validators must pass after creation

## Out of Scope

- Querying analytics platforms or data warehouses
- Writing tracking code
- Analyzing historical data
- Dashboard design

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-analytics/SKILL.md` | New — full multi-agent skill definition |
| `plugins/conclave/shared/personas/metrics-skeptic.md` | New — metrics skeptic persona |
| `plugins/conclave/.claude-plugin/plugin.json` | Add plan-analytics to skills array |
| `scripts/sync-shared-content.sh` | Add plan-analytics to NON_ENGINEERING_SKILLS |
| `scripts/validators/skill-shared-content.sh` | Add plan-analytics to NON_ENGINEERING_SKILLS |
| `CLAUDE.md` | Add plan-analytics to taxonomy tables |

## Success Criteria

1. SKILL.md passes all A-series and B-series validators
2. Assessment phase produces current-state summary grounded in project data
3. KPI framework maps metrics to business functions with instrumentation plan
4. Metrics Skeptic gate enforced before output
5. All validators pass after creation
