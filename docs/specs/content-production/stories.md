---
type: "user-stories"
feature: "content-production"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-17-build-content.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-17 Content Production Skill (build-content)

## Epic Summary

Startups need a consistent stream of blog posts, documentation, and thought leadership but rarely have bandwidth for quality publishing. `/build-content` defines a multi-agent skill with a content strategist, writer, and editor/skeptic that takes a topic or brief as input and produces a markdown content draft ready for publishing.

## Stories

### Story 1: Content Brief Ingestion and Type Routing

- **As a** founder or marketer invoking `/build-content`
- **I want** to provide a topic or brief and have the skill classify the content type and apply the right structure
- **So that** a blog post, documentation page, and thought leadership piece each receive appropriate outline, tone, and formatting
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/build-content "how we scaled our API"`, when Determine Mode runs, then the Team Lead classifies as blog post (narrative, hook + story + takeaway).
  2. Given I invoke `/build-content docs "authentication flow"`, when Determine Mode runs, then it classifies as documentation (instructional, step-by-step).
  3. Given I invoke `/build-content thought-leadership "future of AI"`, when Determine Mode runs, then it classifies as thought leadership (opinion, evidence-backed argument).
  4. Given no argument, when Setup runs, then it checks `docs/content/_user-data.md` for a pending brief; if none, prompts the user.
  5. Given `docs/content/_user-data.md` does not exist, when Setup runs, then the Team Lead creates it from an embedded template.
  6. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - Ambiguous type: ask user to confirm rather than guessing.
  - `--light` flag: skip strategist; writer drafts from default structure.
- **Notes**: Output: `docs/content/{slug}-{timestamp}.md`. `_user-data.md` includes: brand voice, target audience, SEO keywords, publishing channel, word count target.

### Story 2: Strategist -> Writer -> Editor Pipeline with Skeptic Gate

- **As a** content author using `/build-content`
- **I want** a strategist to define the outline, a writer to draft the piece, and an editor/skeptic to review for quality
- **So that** published content has clear structure, accurate claims, and meets quality standards
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given type is confirmed, when Phase 1 runs, then the strategist produces: section outline, narrative arc, SEO angle, and docs to reference.
  2. Given the strategist's brief, when Phase 2 runs, then the writer drafts full piece citing sources, flagging gaps with `[NEEDS EXAMPLE]` or `[NEEDS DATA]`.
  3. Given the draft, when Phase 3 runs, then the skeptic/editor evaluates: logical flow, factual accuracy, tone consistency, readability.
  4. Given issues found, when revision is needed, then the writer revises. Max iterations: 3.
  5. Given approval, when the Team Lead finalizes, then the draft is written with frontmatter including `inline-flags` count.
  6. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - Inline flags in final output: listed in Team Lead summary.
  - Max iterations without approval: write best draft with `skeptic_approved: false`.
  - Documentation type: skeptic additionally checks numbered steps, prerequisites, code fencing.
- **Notes**: Skeptic/editor is a single agent. Persona: `content-skeptic.md` (shared with P3-16).

## Non-Functional Requirements

- Multi-agent SKILL.md with all 10 required sections.
- Non-engineering skill. Category: `business`. Tags: `[content, blogging, documentation, thought-leadership]`.
- Output files use YAML frontmatter with type, content-type, status, word-count, created, inline-flags fields.

## Out of Scope

- Publishing to CMS or external platforms.
- Generating images or non-text assets.
- SEO keyword research.
- Multi-piece content series or editorial calendars.
- Editing user-provided drafts.
