---
title: "Operations Planning Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Operations Planning Skill Specification

## Summary

Create a new multi-agent business skill (`/plan-operations`) that audits current operational processes, identifies bottlenecks and risks, and produces a prioritized improvement plan with a 90-day implementation roadmap. Hub-and-Spoke pattern with operations auditor, process designer, and ops skeptic.

## Problem

As startups scale, operational processes (vendor management, internal workflows, resource allocation) become bottlenecks without structured planning. Processes that work for 5 people break at 15, and no one has documented what needs to change before it breaks.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/plan-operations/SKILL.md`.

- **Category**: business
- **Tags**: [operations, process, vendors, scaling]
- **Classification**: non-engineering (universal principles only)

### Agent Team (3 agents + lead)

| Agent | Model | Role |
|-------|-------|------|
| Operations Auditor | sonnet | Map current state: team structure, workflows, vendors, bottlenecks (frequency x impact), risks |
| Process Designer | sonnet | Propose improvements: prioritized list, tooling changes, 90-day implementation roadmap |
| Ops Skeptic | opus | Challenge realism of improvements, sequence feasibility, new fragility introduction |

### Pipeline Flow

1. **Setup**: Read project docs + `docs/ops-plans/_user-data.md` + `docs/hiring-plans/` (if present). Create template if absent.
2. **Phase 1 (Audit)**: Auditor produces current-state map, bottleneck inventory, risk list.
3. **Phase 2 (Design)**: Designer produces prioritized improvements, tooling changes, 90-day roadmap.
4. **Phase 3 (Review)**: Ops Skeptic reviews. Max iterations: 3.
5. **Output**: `docs/ops-plans/ops-plan-{timestamp}.md`

### User Data Template (`docs/ops-plans/_user-data.md`)

Fields: team size/structure, current tools, key vendors and contract status, workflow pain points, growth timeline, regulatory/compliance constraints.

### Persona

Check existing `plugins/conclave/shared/personas/ops-skeptic.md` for domain alignment. If scoped too narrowly to review-quality, create variant `ops-skeptic--plan-operations.md`.

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering — universal principles only
3. Vendor recommendations framed as criteria, not named products
4. All validators must pass

## Out of Scope

- Financial modeling or budget planning
- HR policy drafting
- Implementing proposed process changes
- Vendor contract review (`/review-legal`)

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-operations/SKILL.md` | New — full multi-agent skill definition |
| `plugins/conclave/shared/personas/ops-skeptic--plan-operations.md` | New or reuse existing ops-skeptic.md |
| `plugins/conclave/.claude-plugin/plugin.json` | Add plan-operations to skills array |
| `scripts/sync-shared-content.sh` | Add plan-operations to NON_ENGINEERING_SKILLS |
| `scripts/validators/skill-shared-content.sh` | Add plan-operations to NON_ENGINEERING_SKILLS |
| `CLAUDE.md` | Add plan-operations to taxonomy tables |

## Success Criteria

1. SKILL.md passes all A-series and B-series validators
2. Audit produces bottleneck inventory with frequency x impact ratings
3. Improvement plan includes 90-day sequenced roadmap
4. Ops Skeptic gate enforced before output
5. Cross-references hiring plan data when available
6. All validators pass after creation
