---
type: "user-stories"
feature: "plan-operations"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-20-plan-operations.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-20 Operations Planning Skill (plan-operations)

## Epic Summary

Scaling startups hit operational ceilings: vendor contracts in spreadsheets, workflows that work for 5 people but break
at 15, resource allocation by feel. `/plan-operations` defines a multi-agent planning skill that audits current
operational processes, identifies bottlenecks and risks, and produces a prioritized operations improvement plan with a
90-day sequenced roadmap.

## Stories

### Story 1: Operations Audit and Context Gathering

- **As a** founder or operations lead invoking `/plan-operations`
- **I want** the skill to map current operational processes before proposing changes
- **So that** improvement recommendations are specific to my constraints
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/plan-operations`, when Setup runs, then it reads `docs/roadmap/`, `docs/progress/`,
     `docs/hiring-plans/`, and `docs/ops-plans/_user-data.md`.
  2. Given `_user-data.md` does not exist, it is created from template.
  3. Given `_user-data.md` is missing, a data-dependency warning is output.
  4. Given data is available, when Phase 1 runs, then the auditor produces: current-state map, bottleneck inventory
     (frequency x impact), and risk list.
  5. Validators pass after SKILL.md creation.
- **Edge Cases**:
  - Solo founder: scope to founder-scale ops.
  - Hiring plan context: account for planned headcount when rating bottlenecks.
  - `--light`: skip audit, use `_user-data.md` bottleneck list directly.
- **Notes**: Output: `docs/ops-plans/ops-plan-{timestamp}.md`. `_user-data.md` fields: team size, tools, vendors,
  workflow pain points, growth timeline, regulatory constraints.

### Story 2: Process Improvement Plan, Skeptic Gate, and Final Output

- **As a** founder or ops lead using `/plan-operations`
- **I want** prioritized improvements with a 90-day roadmap, challenged by a skeptic for realism
- **So that** the ops plan is actionable and honest about tradeoffs
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given Phase 1 audit, when Phase 2 runs, then the designer produces: prioritized improvements, tooling
     recommendations, 90-day implementation roadmap.
  2. Given the draft, when Phase 3 runs, then the skeptic challenges: effort justification, sequence realism, new single
     points of failure.
  3. Given issues, the designer revises. Max iterations: 3.
  4. Given approval, output written with appropriate frontmatter.
  5. Validators pass.
- **Edge Cases**:
  - Roadmap conflict in 90-day window: skeptic flags resource conflict.
  - Vendor recommendations: frame as criteria, not named products.
- **Notes**: Ops Skeptic — check existing `ops-skeptic.md` for domain alignment; create variant file
  `ops-skeptic--plan-operations.md` if needed.

## Non-Functional Requirements

- Multi-agent SKILL.md, all 10 sections. Category: `business`. Tags: `[operations, process, vendors, scaling]`.
  Non-engineering.
- G-series ADR-005: verify business skill count.

## Out of Scope

- Financial modeling or budget planning.
- HR policy drafting.
- Implementing process changes.
- Vendor contract review (`/review-legal`).
