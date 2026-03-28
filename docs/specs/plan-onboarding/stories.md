---
type: "user-stories"
feature: "plan-onboarding"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-21-plan-onboarding.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-21 Employee Onboarding Skill (plan-onboarding)

## Epic Summary

Startups hire people and hand them a Notion page. The result is inconsistent ramp-up, missed context, and early attrition. `/plan-onboarding` defines a multi-agent planning skill that assesses current onboarding state, maps existing documentation to milestones, and produces a 30/60/90-day program with role-specific tracks and a gap inventory of content needing creation.

## Stories

### Story 1: Current Onboarding State Assessment and Context Gathering

- **As a** founder or people lead invoking `/plan-onboarding`
- **I want** the skill to understand what onboarding materials already exist before designing anything new
- **So that** the program builds on real assets rather than duplicating what's there
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/plan-onboarding`, when Setup runs, then it reads `docs/roadmap/`, `docs/architecture/`, `docs/stack-hints/`, `docs/hiring-plans/`, and `docs/onboarding/_user-data.md`.
  2. Given `_user-data.md` does not exist, it is created from template.
  3. Given `_user-data.md` is missing, a data-dependency warning is output.
  4. Given data is available, when Phase 1 runs, then the designer produces: asset inventory, gap map, role-track list.
  5. Validators pass after SKILL.md creation.
- **Edge Cases**:
  - First hire ever: treat as greenfield, note to validate with first hire's feedback.
  - Multiple role types: produce separate tracks for each.
  - `--light`: skip assessment, produce single generic track.
- **Notes**: Output: `docs/onboarding/onboarding-plan-{role}-{timestamp}.md`. Optional role argument: `/plan-onboarding engineer`.

### Story 2: 30/60/90 Program Design, Skeptic Gate, and Final Output

- **As a** founder or people lead
- **I want** a clear 30/60/90 milestone structure with linked resources and skeptic review
- **So that** new hires have a structured, realistic path
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given Phase 1, when Phase 2 runs, then the designer produces: 30/60/90 plan with milestones, resource list, tool access checklist, first-two-weeks schedule.
  2. Given the draft, when Phase 3 runs, then the skeptic evaluates: 30-day achievability, missing context blocking day-60 productivity, placeholder resources.
  3. Given issues, the designer revises. Max iterations: 3.
  4. Given approval, output written with frontmatter including gap-count.
  5. Validators pass.
- **Edge Cases**:
  - Gap count non-zero: Team Lead lists all missing resources.
  - Too dense: skeptic flags specific items for deferral from 30 to 60 days.
- **Notes**: People Skeptic — check `fit-skeptic.md` for domain alignment; create variant if needed. Single designer agent for lean skill.

## Non-Functional Requirements

- Multi-agent SKILL.md, all 10 sections. Category: `business`. Tags: `[onboarding, hiring, people-ops, 30-60-90]`. Non-engineering.
- Note: effort bumped from small to medium per skeptic review feedback.
- G-series ADR-005: verify business skill count.

## Out of Scope

- Generating missing onboarding content (use `/build-content`).
- HR policy or handbook drafting.
- Offboarding or performance review planning.
- HRIS/ATS integration.
