---
type: "user-stories"
feature: "contribution-guide"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-03-contribution-guide.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-03 Architecture & Contribution Guide

## Epic Summary

The wizards plugin has no contributor documentation. A developer wanting to add
a new skill, modify agent prompts, or contribute a stack hint has nothing to
read but the full codebase. This epic delivers three artifacts — an architecture
overview, a contributing guide, and a starter SKILL.md template — that together
allow a first-time contributor to make a correct, validator-passing contribution
without reading existing skill files.

---

## Stories

### Story 1: Architecture Overview Document

- **As a** first-time contributor to the wizards plugin
- **I want** an architecture overview document that explains plugin structure,
  skill format, agent team patterns, and quality gate design
- **So that** I can understand how the system fits together before making
  changes, without having to reverse-engineer it from code
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I am a new contributor and I read `docs/architecture/overview.md`,
     when I finish, then I can correctly describe: the role of
     `plugins/conclave/plugin.json`, what a SKILL.md file contains, the
     difference between granular / pipeline / utility / business skills, and how
     Agent Teams replace subagents.
  2. Given the document covers skill categories, when I read the category table,
     then it matches the authoritative category taxonomy in CLAUDE.md
     (engineering, planning, business, utility) with no contradictions.
  3. Given the document covers shared content, when I read the shared content
     section, then it explains: what lives in `plugins/conclave/shared/`, why
     markers exist, how to sync via `bash scripts/sync-shared-content.sh`, and
     that single-agent skills are excluded.
  4. Given the document covers quality gates, when I read the validation
     section, then it explains: what `bash scripts/validate.sh` does, the A-G
     validator series, and what must pass before a commit.
  5. Given I run `bash scripts/validate.sh` after creating the file, then all
     validators pass with no new failures (the file is in `docs/architecture/`,
     not in a validated path).
- **Edge Cases**:
  - Document drift: if CLAUDE.md is updated (new validators, new skill
    category), the overview may become stale. Notes in the document should
    direct readers to CLAUDE.md as the authoritative source for validation
    rules.
  - ADR references: the overview should link to relevant ADRs (ADR-001 through
    ADR-005) rather than re-explaining decisions already recorded there.
  - Persona system: the overview should acknowledge persona files in
    `plugins/conclave/shared/personas/` but not require them — personas are not
    yet activated for contributors.
- **Notes**: This document is project-level documentation, not skill-level — it
  belongs in `docs/architecture/overview.md`. It should not duplicate CLAUDE.md
  but should complement it: CLAUDE.md is developer-conventions reference, the
  overview is narrative architecture explanation. Ideal length is 400-700 words.
  Diagrams are welcome but not required.

---

### Story 2: Contributing Guide

- **As a** developer who wants to contribute to the wizards plugin
- **I want** a step-by-step contributing guide covering the most common
  contribution paths
- **So that** I can make a correct, validator-passing contribution without
  reading the full codebase or asking a maintainer
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I read `docs/contributing.md`, when I follow the "Add a new skill"
     path, then I can produce a new SKILL.md file that passes all A-series and
     B-series validators without additional guidance.
  2. Given I read the "Add a stack hint" path, when I follow it, then I know:
     where stack hints live (`docs/stack-hints/`), what frontmatter they require
     (none — they are plain markdown), and how agents consume them.
  3. Given I read the "Modify agent prompts" path, when I follow it, then I
     understand: which content to edit directly in SKILL.md vs. which content
     lives in `plugins/conclave/shared/` and must be synced, and what the
     B-series validators will flag if I edit shared blocks in place.
  4. Given I read the "Add a custom agent role" path, when I follow it, then the
     guide notes this path depends on P3-01 (Custom Agent Roles) and links to
     that spec once available — the guide does not invent a workflow that does
     not yet exist. This section is a documented placeholder/future section.
  5. Given I follow any documented path and then run `bash scripts/validate.sh`,
     then I receive no unexpected failures caused by following the guide's
     instructions.
  6. Given I run `bash scripts/validate.sh` after creating the file, then all
     validators pass (the file is not in a validated path).
- **Edge Cases**:
  - Skill classification: the guide must explain that new skills require a
    classification decision (engineering vs. non-engineering) that determines
    which shared content blocks are injected. Default is engineering if
    uncertain.
  - Category assignment: new skills must be assigned a category in frontmatter.
    The guide should list valid values and where they are enforced (A-series
    validators).
  - Business skill split gate: the guide should note that if a contributor adds
    a business skill, the G-series validator will warn when the count approaches
    the split threshold (ADR-005). This is advisory, not a blocker.
  - Shared content markers: the guide must warn contributors never to edit
    content between `<!-- BEGIN SHARED -->` and `<!-- END SHARED -->` markers
    directly — changes will be overwritten by the sync script.
- **Notes**: The guide lives at `docs/contributing.md` (project root-adjacent,
  not inside `docs/architecture/`). Paths for the four contribution types are
  the primary content — the guide is a how-to, not an explainer. Cross-link to
  `docs/architecture/overview.md` for the "why" behind structural choices.

---

### Story 3: Skill Authoring Template

- **As a** skill author creating a new skill for the wizards plugin
- **I want** a starter SKILL.md template with all required sections and
  placeholder content
- **So that** I can create a valid, validator-passing skill structure without
  copying an existing skill and manually removing live content
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I copy `docs/templates/skills/SKILL.md` and fill in the placeholders,
     when I run `bash scripts/validate.sh`, then the A-series validators pass
     for my new skill (A1 frontmatter, A2 required sections, A3 spawn
     definitions, A4 markers).
  2. Given I read the template's frontmatter block, when I count the fields,
     then it includes all required fields (`name`, `description`,
     `argument-hint`, `category`, `tags`) and marks optional fields (`tier`,
     `type`) with a comment indicating they are optional.
  3. Given the template includes a spawn definition block (A3 check), when I
     read it, then it contains placeholder `Name` and `Model` fields with inline
     comments explaining valid model choices.
  4. Given the template includes shared content marker blocks, when I examine
     them, then the markers are present and correctly formatted so B-series
     validators accept them after a sync run.
  5. Given the template is for a multi-agent skill, when I count the required
     sections, then all required sections are present: Setup, Write Safety,
     Checkpoint Protocol, Determine Mode, Lightweight Mode, Spawn the Team,
     Orchestration Flow, Failure Recovery, Shared Principles, Communication
     Protocol.
  6. Given I run `bash scripts/validate.sh` immediately on the unmodified
     template (as placed in `plugins/conclave/skills/`), then the A-series
     validators pass — the template is structurally valid, not a draft with
     known failures.
- **Edge Cases**:
  - Single-agent variant: the template covers the multi-agent path (most
    complex). The contributing guide should note that single-agent skills
    require only Setup and Determine Mode sections, and direct authors to
    `wizard-guide/SKILL.md` as a reference.
  - SCAFFOLD comments: the template should include one example SCAFFOLD comment
    (with all three required fields: what, assumption, test-removal condition)
    so authors know the convention exists.
  - Shared content sync: the template's shared content marker blocks will be
    empty until `bash scripts/sync-shared-content.sh` is run. The template
    should include a comment instructing the author to run the sync script after
    creating their skill directory.
  - Template location: the template lives in `docs/templates/skills/SKILL.md`,
    separate from the plugin skills directory.
- **Notes**: The template is the highest-leverage deliverable in this epic — it
  directly enables the success criterion. Placeholder text should be descriptive
  enough to explain what belongs in each section rather than just `TODO`.

---

### Story 4: Template-Format Synchronization Guard

- **As a** plugin maintainer evolving the skill format
- **I want** a validation check that warns when the skill authoring template's
  required sections diverge from what the A-series validators expect
- **So that** the template never silently drifts into producing invalid skills
  after a validator update
- **Priority**: could-have
- **Acceptance Criteria**:
  1. Given the skill authoring template exists at
     `docs/templates/skills/SKILL.md`, when I run `bash scripts/validate.sh`,
     then an advisory check verifies the template contains the same required
     section headings that A2 enforces, and warns if any are missing.
  2. Given I update A2 to require a new section, when I run
     `bash scripts/validate.sh`, then the template sync check emits a `WARN`
     (not a `FAIL`) that names the missing section so a maintainer knows to
     update the template.
  3. Given the warning fires, when I update the template and re-run validators,
     then the warning clears.
  4. Given the check is advisory, when it fires, then `validate.sh` exits 0 — a
     template drift warning does not block CI.
- **Edge Cases**:
  - Single-agent vs. multi-agent template divergence: the check validates the
    multi-agent template (more sections). If a single-agent template is added
    later, a separate check may be warranted.
  - False positives: SCAFFOLD comments in the template contain `##`-adjacent
    content that the section detector must not confuse with section headings.
    The check should use the same regex as A2 to avoid divergence.
- **Notes**: This story is could-have because the template is relatively stable.
  Implementation is a small addition to an existing validator (<=30 lines of
  shell).

---

## Non-Functional Requirements

- All new files are Markdown — no runtime code, no new validators required for
  Stories 1-3.
- Story 4 (template sync guard) adds <=30 lines to an existing validator script.
- `bash scripts/validate.sh` must pass after all Story 1-3 changes.
- Documents must render correctly in both terminal Markdown and GitHub Markdown
  preview.
- The skill authoring template (Story 3) must be structurally valid — not a
  skeleton with known A-series failures.
- Contributing guide prose should be concise: step-by-step instructions, not
  explanatory essays.

## Out of Scope

- Implementing custom agent roles (P3-01) — Story 2's "Add a custom agent role"
  section is a placeholder linking to P3-01.
- Activating the persona system — personas are mentioned in the architecture
  overview for completeness, not as a contribution path.
- Automated test infrastructure for the template (P2-04 scope).
- Updating existing skill files to conform to any new conventions introduced by
  this documentation.
- Public-facing README changes — this epic is contributor documentation, not
  end-user documentation.
