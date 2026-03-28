---
title: "Sales Collateral Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Sales Collateral Skill Specification

## Summary

Create a new multi-agent business skill (`/build-sales-collateral`) that produces markdown-formatted sales assets (pitch decks, one-pagers, case studies) from project data. Uses a Hub-and-Spoke pattern with content strategist, copywriter, formatter, and content skeptic. Reads existing project docs for product context and routes by collateral type.

## Problem

Sales teams at startups produce collateral manually — each pitch deck, one-pager, or case study drafted from scratch without shared messaging architecture. This leads to inconsistent positioning across assets, time-consuming production, and collateral that doesn't reflect current product state because it's disconnected from specs and roadmap data.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/build-sales-collateral/SKILL.md` following the multi-agent Hub-and-Spoke pattern.

- **Category**: business
- **Tags**: [sales, collateral, content, pitch-deck]
- **Classification**: non-engineering (universal principles only)
- **Collateral types**: pitch-deck, one-pager, case-study

### Agent Team (4 agents + lead)

| Agent | Model | Role |
|-------|-------|------|
| Content Strategist | sonnet | Define messaging architecture: target audience, core message, section outline, proof points |
| Copywriter | sonnet | Draft all content sections from strategist's brief, citing sources, flagging unverified claims |
| Formatter | sonnet | Assemble sections into collateral type's canonical markdown structure |
| Content Skeptic | opus | Review for factual traceability, messaging consistency, CTA clarity |

### Pipeline Flow

1. **Setup**: Read `docs/roadmap/`, `docs/specs/`, `docs/research/`, `docs/collateral/_user-data.md`. Create `_user-data.md` from template if absent.
2. **Determine Mode**: Route by collateral type argument. Prompt if no type given.
3. **Phase 1 (Strategy)**: Strategist produces messaging brief.
4. **Phase 2 (Writing)**: Copywriter drafts sections, flags `[UNVERIFIED]` claims.
5. **Phase 3 (Formatting)**: Formatter assembles into canonical structure.
6. **Phase 4 (Review)**: Content Skeptic reviews. Max iterations: 3.
7. **Output**: `docs/collateral/{type}-{timestamp}.md` with YAML frontmatter.

### User Data Template (`docs/collateral/_user-data.md`)

Created on first run if absent. Fields: ICP description, core differentiators, proof points (metrics/case studies), competitor positioning, call-to-action target.

### Persona

New persona file: `plugins/conclave/shared/personas/content-skeptic.md` (shared with P3-17 build-content).

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering classification — universal principles only, no engineering principles block
3. Shared content synced via `bash scripts/sync-shared-content.sh`
4. All validators must pass after creation
5. `[UNVERIFIED]` flags preserved in final output — never silently removed

## Out of Scope

- Generating images, diagrams, or non-markdown assets
- Automated distribution or email integration
- A/B testing variants
- Modifying existing `/plan-sales` skill
- Multiple collateral types in one run

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/build-sales-collateral/SKILL.md` | New — full multi-agent skill definition |
| `plugins/conclave/shared/personas/content-skeptic.md` | New — content skeptic persona (shared with P3-17) |
| `plugins/conclave/.claude-plugin/plugin.json` | Add build-sales-collateral to skills array |
| `scripts/sync-shared-content.sh` | Add build-sales-collateral to NON_ENGINEERING_SKILLS array |
| `scripts/validators/skill-shared-content.sh` | Add build-sales-collateral to NON_ENGINEERING_SKILLS array |
| `CLAUDE.md` | Add build-sales-collateral to category taxonomy and classification tables |

## Success Criteria

1. SKILL.md exists and passes all A-series validators (A1-A4)
2. Shared content synced and B-series validators pass (B1-B3)
3. Skill correctly routes by collateral type (pitch-deck, one-pager, case-study)
4. `_user-data.md` template created on first run if absent
5. Content Skeptic gate enforced before final output
6. `[UNVERIFIED]` flags preserved in output and counted in summary
7. All validators pass after creation
