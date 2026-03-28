---
title: "Employee Onboarding Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Employee Onboarding Skill Specification

## Summary

Create a new multi-agent business skill (`/plan-onboarding`) that assesses current onboarding state, maps existing documentation to milestones, and produces a structured 30/60/90-day onboarding program with role-specific tracks. Lean Hub-and-Spoke pattern with a single onboarding designer and people skeptic.

## Problem

New hires at startups face inconsistent onboarding due to ad-hoc processes. They get a Notion page, some Slack channels, and good luck. This leads to slower ramp-up, missed institutional context, and early attrition from hires who never felt properly oriented.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/plan-onboarding/SKILL.md`.

- **Category**: business
- **Tags**: [onboarding, hiring, people-ops, 30-60-90]
- **Classification**: non-engineering (universal principles only)

### Agent Team (2 agents + lead)

| Agent | Model | Role |
|-------|-------|------|
| Onboarding Designer | sonnet | Assess current state, design 30/60/90 program, curate resource list, identify gaps |
| People Skeptic | opus | Challenge milestone realism, resource completeness, role-track specificity |

Lean 2-agent design — the designer handles both assessment and program design to match the medium effort estimate.

### Pipeline Flow

1. **Setup**: Read project docs + `docs/onboarding/_user-data.md` + `docs/hiring-plans/` (if present). Create template if absent.
2. **Phase 1 (Assessment)**: Designer produces asset inventory, gap map, role-track list.
3. **Phase 2 (Design)**: Designer produces 30/60/90 plan with milestones, resources, access checklist, first-two-weeks schedule.
4. **Phase 3 (Review)**: People Skeptic reviews. Max iterations: 3.
5. **Output**: `docs/onboarding/onboarding-plan-{role}-{timestamp}.md` (or without role suffix if no role specified)

### User Data Template (`docs/onboarding/_user-data.md`)

Fields: company stage, role types, existing documentation links, required tool access steps with owners, 30/60/90 success definitions per role, buddy/mentor structure, first-week schedule template.

### Persona

Check existing `plugins/conclave/shared/personas/fit-skeptic.md` for domain alignment. If "role necessity, team composition balance, budget alignment, strategic fit" overlaps sufficiently with onboarding review, reuse it. Otherwise create `fit-skeptic--plan-onboarding.md` variant.

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering — universal principles only
3. Gap inventory explicitly listed in output — not hidden
4. All validators must pass

## Out of Scope

- Generating missing onboarding content (identified gaps are for `/build-content`)
- HR policy or employee handbook drafting
- Offboarding or performance review planning
- HRIS/ATS integration

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-onboarding/SKILL.md` | New — full multi-agent skill definition |
| `plugins/conclave/shared/personas/fit-skeptic--plan-onboarding.md` | New or reuse existing fit-skeptic.md |
| `plugins/conclave/.claude-plugin/plugin.json` | Add plan-onboarding to skills array |
| `scripts/sync-shared-content.sh` | Add plan-onboarding to NON_ENGINEERING_SKILLS |
| `scripts/validators/skill-shared-content.sh` | Add plan-onboarding to NON_ENGINEERING_SKILLS |
| `CLAUDE.md` | Add plan-onboarding to taxonomy tables |

## Success Criteria

1. SKILL.md passes all A-series and B-series validators
2. Assessment produces asset inventory and gap map from existing docs
3. 30/60/90 plan has per-milestone success criteria and linked resources
4. Role-specific tracks supported when role argument provided
5. People Skeptic gate enforced before output
6. Gap count included in frontmatter and Team Lead summary
7. All validators pass after creation
