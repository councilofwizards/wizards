---
type: "user-stories"
feature: "sales-collateral"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-16-build-sales-collateral.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-16 Sales Collateral Skill (build-sales-collateral)

## Epic Summary

Founders and sales teams spend hours producing pitch decks, one-pagers, and case studies — and the results are often
inconsistent because each piece is drafted from scratch without a shared messaging architecture.
`/build-sales-collateral` defines a multi-agent Hub-and-Spoke skill that reads project docs for product context, routes
by collateral type, and runs a content strategist -> copywriter -> formatter pipeline with a dedicated skeptic gate
before producing markdown-formatted sales assets.

## Stories

### Story 1: Collateral Type Routing and Project Data Gathering

- **As a** founder preparing sales outreach
- **I want** to invoke `/build-sales-collateral [type]` (pitch-deck | one-pager | case-study) and have the skill read
  project docs for product data automatically
- **So that** the team builds from actual specs, roadmap, and research rather than a blank brief
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/build-sales-collateral pitch-deck`, when Setup runs, then it reads `docs/roadmap/`, `docs/specs/`,
     `docs/research/`, and `docs/collateral/_user-data.md` (if present) before spawning agents.
  2. Given no argument is provided, when Determine Mode runs, then it prompts the user to specify a collateral type
     before proceeding.
  3. Given an unrecognized type argument, when Determine Mode runs, then the Team Lead lists supported types and asks
     the user to choose.
  4. Given `docs/collateral/_user-data.md` does not exist, when Setup runs, then the Team Lead creates it from an
     embedded template and notifies the user.
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - No product docs exist: warn user that output quality will be limited; do not block.
  - `--light` flag: skip strategist phase; copywriter works from condensed brief.
- **Notes**: Output directory is `docs/collateral/`. Each run produces `docs/collateral/{type}-{timestamp}.md`.

### Story 2: Hub-and-Spoke Content Generation

- **As a** founder invoking `/build-sales-collateral`
- **I want** a content strategist to define messaging architecture, a copywriter to draft content, and a formatter to
  produce the final layout
- **So that** the output has coherent structure, consistent messaging, and polished language
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given project data is gathered, when Phase 1 runs, then the strategist produces a messaging brief sent to the Team
     Lead.
  2. Given the messaging brief, when Phase 2 runs, then the copywriter drafts each section, citing sources and flagging
     unverified claims with `[UNVERIFIED]`.
  3. Given the draft is complete, when Phase 3 runs, then the formatter assembles sections into the collateral type's
     canonical markdown structure.
  4. Given the three phases run sequentially, when the Team Lead monitors output, then each phase's output is available
     to the next before it begins.
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - Factual claims without source: flagged with `[UNVERIFIED]` inline.
  - Case study type with no customer proof points: placeholder language rather than fabrication.

### Story 3: Skeptic Review Gate and Final Output

- **As a** founder reviewing collateral before sending to prospects
- **I want** a dedicated skeptic to evaluate the draft for messaging accuracy, consistency, and persuasive effectiveness
- **So that** collateral passes adversarial review before delivery
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given a formatted draft, when the skeptic reviews, then it evaluates: factual traceability, messaging consistency,
     CTA clarity.
  2. Given the skeptic identifies issues, when revision is needed, then the copywriter revises. Max iterations: 3.
  3. Given the skeptic approves, when the Team Lead finalizes, then it writes to `docs/collateral/{type}-{timestamp}.md`
     and summarizes what was produced and which `[UNVERIFIED]` flags remain.
  4. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then all validators pass.
- **Edge Cases**:
  - Max iterations without approval: write best draft with `skeptic_approved: false` in frontmatter.
  - `[UNVERIFIED]` claims in final output: preserved and counted in summary.
- **Notes**: Content Skeptic persona at `plugins/conclave/shared/personas/content-skeptic.md`.

## Non-Functional Requirements

- Multi-agent SKILL.md with all 10 required sections.
- Non-engineering skill — universal principles only. Category: `business`. Tags:
  `[sales, collateral, content, pitch-deck]`.
- Output files use YAML frontmatter with type, collateral-type, status, created, sources fields.

## Out of Scope

- Generating images or non-markdown assets.
- Automated distribution or email integration.
- A/B testing variants.
- Modifying `/plan-sales`.
