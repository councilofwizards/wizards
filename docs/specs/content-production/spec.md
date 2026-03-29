---
title: "Content Production Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Content Production Skill Specification

## Summary

Create a new multi-agent business skill (`/build-content`) that produces markdown content drafts (blog posts,
documentation, thought leadership) from a topic or brief. Uses a Hub-and-Spoke pattern with content strategist, writer,
and editor/skeptic. Adapts structure and tone to content type.

## Problem

Startups need consistent content production for marketing, SEO, and thought leadership but lack bandwidth for regular
quality publishing. Content is produced ad-hoc with inconsistent tone, structure, and quality — or not produced at all
because the overhead exceeds available capacity.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/build-content/SKILL.md` following the multi-agent Hub-and-Spoke pattern.

- **Category**: business
- **Tags**: [content, blogging, documentation, thought-leadership]
- **Classification**: non-engineering (universal principles only)
- **Content types**: blog, docs, thought-leadership

### Agent Team (3 agents + lead)

| Agent                    | Model  | Role                                                                         |
| ------------------------ | ------ | ---------------------------------------------------------------------------- |
| Content Strategist       | sonnet | Define outline, narrative arc, SEO/messaging angle, source docs to reference |
| Writer                   | sonnet | Draft full piece section by section, citing sources, flagging gaps           |
| Content Skeptic (Editor) | opus   | Review for logical flow, factual accuracy, tone consistency, readability     |

### Pipeline Flow

1. **Setup**: Read `docs/content/_user-data.md`. Create from template if absent.
2. **Determine Mode**: Classify content type from argument (blog/docs/thought-leadership). Prompt if ambiguous.
3. **Phase 1 (Strategy)**: Strategist produces outline and brief.
4. **Phase 2 (Writing)**: Writer drafts full piece, flags `[NEEDS EXAMPLE]` and `[NEEDS DATA]` inline.
5. **Phase 3 (Review)**: Content Skeptic evaluates. Max iterations: 3.
6. **Output**: `docs/content/{slug}-{timestamp}.md` with YAML frontmatter.

### User Data Template (`docs/content/_user-data.md`)

Created on first run if absent. Fields: brand voice guide, target audience, SEO keywords (optional), publishing channel,
word count target.

### Persona

Shares `plugins/conclave/shared/personas/content-skeptic.md` with P3-16 (build-sales-collateral). If P3-16 is not yet
implemented, this skill creates the persona file.

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering classification — universal principles only
3. Shared content synced via `bash scripts/sync-shared-content.sh`
4. All validators must pass after creation
5. Inline flags (`[NEEDS EXAMPLE]`, `[NEEDS DATA]`) preserved in final output

## Out of Scope

- Publishing to CMS or external platforms
- Generating images or non-text assets
- SEO keyword research (accepts keywords as input, does not research them)
- Multi-piece content series or editorial calendars
- Editing user-provided drafts

## Files to Modify

| File                                                  | Change                                                           |
| ----------------------------------------------------- | ---------------------------------------------------------------- |
| `plugins/conclave/skills/build-content/SKILL.md`      | New — full multi-agent skill definition                          |
| `plugins/conclave/shared/personas/content-skeptic.md` | New if not already created by P3-16                              |
| `plugins/conclave/.claude-plugin/plugin.json`         | Add build-content to skills array                                |
| `scripts/sync-shared-content.sh`                      | Add build-content to NON_ENGINEERING_SKILLS array                |
| `scripts/validators/skill-shared-content.sh`          | Add build-content to NON_ENGINEERING_SKILLS array                |
| `CLAUDE.md`                                           | Add build-content to category taxonomy and classification tables |

## Success Criteria

1. SKILL.md exists and passes all A-series validators
2. Shared content synced and B-series validators pass
3. Skill correctly classifies content type from argument
4. `_user-data.md` template created on first run if absent
5. Content Skeptic gate enforced before final output
6. Inline flags preserved in output and counted in summary
7. All validators pass after creation
