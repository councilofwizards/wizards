---
type: "user-stories"
feature: "review-debt"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-05-review-debt.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Tech Debt Review Skill (P3-05)

## Epic Summary

Create `review-debt` as a new multi-agent conclave skill for systematic
technical debt identification, categorization, and prioritization. The skill
surfaces hidden debt across a codebase, categorizes it by type and severity, and
produces a prioritized backlog of debt items ranked against ongoing feature
work. A Debt Skeptic reviews all findings before the debt report is finalized,
preventing over-reporting and ensuring items are actionable.

## Stories

---

### Story 1: SKILL.md Scaffolding and Frontmatter

- **As a** skill author creating the tech debt review skill
- **I want** a valid `plugins/conclave/skills/review-debt/SKILL.md` with correct
  frontmatter, required sections, and shared content markers
- **So that** the skill is discoverable, passes all validators, and follows the
  established structure for multi-agent engineering skills
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the skill directory, when created, then
     `plugins/conclave/skills/review-debt/SKILL.md` exists with YAML frontmatter
     containing: `name: review-debt`, a `description` field summarizing tech
     debt identification and prioritization, an `argument-hint` documenting
     supported invocation patterns, and `tier: 1`
  2. Given the SKILL.md, when inspected for required multi-agent sections, then
     it contains all 12 required multi-agent sections: `## Setup`,
     `## Write Safety`, `## Checkpoint Protocol`, `## Determine Mode`,
     `## Lightweight Mode`, `## Spawn the Team`, `## Orchestration Flow`,
     `## Critical Rules`, `## Failure Recovery`, `## Teammates to Spawn`,
     `## Shared Principles` (containing both universal-principles and
     engineering-principles marker blocks), and `## Communication Protocol`
  3. Given the shared content markers, when
     `bash scripts/sync-shared-content.sh` is run, then the blocks are populated
     from `plugins/conclave/shared/` with the Debt Skeptic's name substituted
     correctly
  4. Given `bash scripts/validate.sh`, when run after the SKILL.md is created
     and synced, then all 12/12 validators pass
  5. Given the skill-classification lists in `scripts/sync-shared-content.sh`
     and `scripts/validators/skill-shared-content.sh`, when `review-debt` is
     added, then it is classified as `engineering`

- **Edge Cases**:
  - Skill name conflicts with an existing skill: `review-debt` is a new name;
    confirm no collision with `review-quality` in the validator's known-skill
    list before writing
  - Sync run before classification is added: validators default to engineering
    with a WARN log; add classification explicitly before final commit

- **Notes**: Reference `plugins/conclave/skills/review-quality/SKILL.md` as the
  structural template. The Setup section should read `docs/roadmap/`,
  `docs/specs/`, and the project's source code to understand what feature work
  is in flight before debt analysis begins.

---

### Story 2: Debt Identification Agent

- **As a** engineering team lead running a tech debt review
- **I want** a Debt Analyst agent that systematically scans the codebase and
  documentation for technical debt items
- **So that** debt is surfaced consistently rather than relying on tribal
  knowledge or developer memory
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a project's source code and docs, when the Debt Analyst is spawned,
     then it identifies debt across these categories: `code-quality`
     (complexity, duplication, naming), `architecture` (coupling, missing
     abstractions, violated patterns), `test-coverage` (untested code, brittle
     tests, missing integration coverage), `documentation` (missing, stale, or
     misleading docs), `dependency` (outdated dependencies, known CVEs,
     deprecated APIs), and `security` (low-severity issues not meeting the bar
     for immediate fix)
  2. Given the Debt Analyst's findings, when inspected, then each debt item
     includes: a `category` (from the taxonomy above), a `location` (file path
     and line range where applicable), a `description` of the issue, an
     `estimated-effort` to resolve (`small` | `medium` | `large`), and a
     `severity` (`high` | `medium` | `low`) based on impact on maintainability
     or reliability
  3. Given a codebase with no source files readable by the agent, when the Debt
     Analyst is spawned, then it pivots to documentation-based debt analysis
     (roadmap, specs, progress files) and notes that code-level findings are not
     available
  4. Given the Debt Analyst's spawn prompt, when inspected, then it instructs
     the agent to checkpoint findings to `docs/progress/{scope}-debt-analyst.md`
     after completing each category scan
  5. Given a project with `docs/stack-hints/{stack}.md` loaded in Setup, when
     the Debt Analyst is spawned, then the stack-specific guidance is injected
     into its prompt (same pattern as `review-quality`)

- **Edge Cases**:
  - Very large codebase (hundreds of files): Debt Analyst focuses on
    highest-risk areas (recently changed files per git log, files with known
    issues from progress notes) and notes the sampling approach in its findings
  - Debt item spans multiple files: single debt entry with all affected file
    paths listed under `location`
  - Security debt found that crosses into Critical/High severity: Debt Analyst
    escalates it to the Debt Lead immediately with an `URGENT` flag — it should
    be addressed as a security issue, not a debt backlog item
  - Zero debt found: Debt Analyst produces a findings file noting the clean
    assessment; does not fabricate items

- **Notes**: Debt Analyst uses `sonnet` model for execution-class scanning. It
  does not rewrite code or suggest specific diffs — it identifies and describes.
  Agent name: `debt-analyst`.

---

### Story 3: Debt Prioritization Against Feature Work

- **As a** engineering team deciding where to invest next sprint
- **I want** the debt review skill to produce a ranked debt backlog that
  accounts for in-flight feature work
- **So that** I can make an informed tradeoff decision between paying down debt
  and shipping features rather than managing two disconnected lists
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Debt Analyst's findings and the current roadmap (read in Setup
     from `docs/roadmap/`), when the Debt Lead produces the prioritized backlog,
     then each debt item is ranked using a combined score:
     `severity × (1 + feature-conflict-multiplier)` where
     `feature-conflict-multiplier` is `1` if the debt item's location overlaps
     with a roadmap item in `in_progress` or `not_started` status, and `0`
     otherwise
  2. Given the ranked backlog, when inspected, then the top 5 items are
     annotated with a `pay-before-feature` flag if their severity is `high` and
     they overlap with an active feature — these are recommended for resolution
     before the overlapping feature begins implementation
  3. Given the ranked backlog, when inspected, then each item includes a
     `recommended-sprint` field: `current` (resolve this sprint), `next` (queue
     for next sprint), or `backlog` (monitor but defer)
  4. Given the Debt Lead reads `docs/roadmap/_index.md` (the roadmap index),
     when it identifies items with `status: in_progress`, then those features
     are used as the "active work" set for conflict detection in AC1
  5. Given a debt item with `estimated-effort: large`, when ranked, then it is
     automatically split into a `discovery` task (small) and an `implementation`
     task (large) in the backlog to allow incremental progress

- **Edge Cases**:
  - No roadmap exists in `docs/roadmap/`: Debt Lead produces the ranked backlog
    without feature-conflict scoring, notes that no roadmap was found, and
    applies severity-only ranking
  - All debt items have `severity: low` and no feature conflicts: ranked backlog
    still produced; all items tagged `backlog`; Debt Lead notes the codebase is
    in relatively healthy shape
  - Debt item's location is a deleted file (found via stale reference): Debt
    Lead flags the item as `stale` — debt in deleted code is informational, not
    actionable
  - User provides a `--scope {path}` argument: Debt Analyst limits scanning to
    the specified path; prioritization still considers the full roadmap

- **Notes**: The feature-conflict scoring model is a simple heuristic, not a
  rigorous formula. The Debt Skeptic (Story 4) may challenge the ranking if the
  logic produces counterintuitive orderings. The prioritized backlog is the
  primary output artifact.

---

### Story 4: Debt Skeptic Gate

- **As a** Debt Lead finalizing a tech debt review
- **I want** a Debt Skeptic to challenge the debt findings and prioritization
  before the report is published
- **So that** over-reported debt doesn't overwhelm the team and under-reported
  debt doesn't hide real problems
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Debt Lead's assembled findings and prioritized backlog, when
     submitted to the Debt Skeptic, then the Skeptic reviews them before the
     Debt Lead writes the final report
  2. Given the Debt Skeptic's review, when inspected, then it evaluates: (a) are
     high-severity items genuinely impactful or over-classified? (b) is the
     prioritization logic sound given the active feature work? (c) are the
     `estimated-effort` assessments realistic? (d) are there categories of debt
     that appear absent from the findings (potential blind spots)?
  3. Given a `REJECTED` verdict, when the Debt Lead receives it, then the
     specific agents whose findings were rejected (Debt Analyst or Debt Lead)
     revise and resubmit — the three-rejection deadlock protocol applies
  4. Given an `APPROVED` verdict, when the Debt Lead proceeds, then the final
     report notes any Skeptic conditions in a `## Skeptic Review` section
  5. Given the Debt Skeptic's spawn prompt, when inspected, then it includes the
     instruction that the Skeptic's job is to challenge the findings, not to
     produce its own independent debt analysis

- **Edge Cases**:
  - Debt Skeptic identifies a major debt category entirely missed by the Debt
    Analyst (e.g., no dependency debt checked): Debt Skeptic issues a `REJECTED`
    verdict specifying the missed category; Debt Analyst re-runs that category
    scan
  - Debt Skeptic agrees with all findings but recommends demoting 3 items from
    `high` to `medium`: Skeptic issues `APPROVED` with conditions listing the
    recommended demotions; Debt Lead applies the demotions before writing the
    final report
  - All debt items have consensus between Analyst and Skeptic: Skeptic approves
    on first review; this is the happy path

- **Notes**: Agent name: `debt-skeptic`. Model: `opus`. The Skeptic's most
  important function here is preventing both over-reporting (team paralysis) and
  under-reporting (hidden risk) — two failure modes specific to debt reviews.

---

### Story 5: Debt Report Artifact

- **As a** engineering team lead who ran a tech debt review
- **I want** a structured debt report written to
  `docs/progress/{scope}-debt-report.md`
- **So that** the findings are preserved, reviewable, and actionable across
  sessions without requiring a re-run
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all Skeptic-approved findings, when the Debt Lead writes the report,
     then `docs/progress/{scope}-debt-report.md` is created with YAML
     frontmatter: `type: "debt-report"`, `scope` (path or `full-codebase`),
     `status` (`draft` | `reviewed` | `complete`), `created`, `updated`, and a
     `top-debt-count` field with the number of high-severity items
  2. Given the report body, when inspected, then it contains sections:
     `## Executive Summary` (2-3 sentence overview), `## Debt Inventory` (full
     list of findings), `## Prioritized Backlog` (ranked list with
     `pay-before-feature` annotations), `## Recommendations` (top 5 actionable
     items), and `## Skeptic Review` (Skeptic verdict and conditions)
  3. Given the `## Debt Inventory` section, when inspected, then items are
     grouped by category and each item follows the schema from Story 2 AC2
     (category, location, description, effort, severity)
  4. Given the `## Prioritized Backlog` section, when inspected, then items are
     listed in ranked order (highest-priority first) with the
     `recommended-sprint` field and `pay-before-feature` flag where applicable
  5. Given the `status` invocation mode (Story 6), when the Debt Lead reads
     existing reports, then it reads `docs/progress/*-debt-report.md` files by
     their YAML `type: "debt-report"` field to distinguish them from other
     progress files

- **Edge Cases**:
  - `{scope}` contains path separators: sanitize to a slug (replace `/` with
    `-`) before using in the filename
  - Report written before Skeptic approval: `status: "draft"` until approved;
    Debt Lead does not set `status: "complete"` until Skeptic issues an
    `APPROVED` verdict
  - Very long debt inventory (50+ items): `## Debt Inventory` is written in
    full; `## Prioritized Backlog` surfaces the top 15 items only; a note
    explains the full inventory is in the section above

- **Notes**: Debt reports live in `docs/progress/` not `docs/specs/` — they are
  output artifacts of a review run, not planning specifications. The
  `type: "debt-report"` frontmatter field follows convention but the file is not
  registered in the F-series validator.

---

### Story 6: Invocation Modes

- **As a** developer invoking review-debt
- **I want** the skill to support targeted scope flags and a status mode
- **So that** I can run a full codebase scan, a targeted file/module scan, or a
  quick status check without separate workflows
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given invocation with no arguments, when the skill runs, then it performs a
     full-codebase debt review: spawns Debt Analyst + Debt Skeptic and produces
     a report scoped to `full-codebase`
  2. Given invocation with `--scope {path}`, when the skill runs, then the Debt
     Analyst limits its scan to the specified path; the report's `scope`
     frontmatter field is set to the provided path
  3. Given invocation with `--category {category}`, when the skill runs, then
     the Debt Analyst scans only the specified category (e.g.,
     `--category test-coverage`); valid categories match the taxonomy from Story
     2 AC1
  4. Given invocation with `status`, when the skill runs, then it reads all
     `docs/progress/*-debt-report.md` files, parses their frontmatter, and
     outputs a formatted table (scope, top-debt-count, status, created date)
     without spawning any agents
  5. Given invocation with `--light`, when the skill runs, then the flag is
     acknowledged; no team composition changes are made (all agents are needed
     for a valid debt assessment)

- **Edge Cases**:
  - `--scope` path does not exist: skill returns an error message to the user
    and exits without spawning agents
  - `--category` value is not in the defined taxonomy: skill returns a list of
    valid categories and exits without spawning agents
  - `status` invoked with no debt reports in `docs/progress/`: returns "No debt
    reports found." without error

- **Notes**: The `--scope` and `--category` flags can be combined (e.g.,
  `--scope src/api --category architecture`) to focus the review on a specific
  area and category.

---

## Non-Functional Requirements

- **Validator stability**: 12/12 validators must pass after the new SKILL.md is
  created and synced; `review-debt` must be added to engineering classification
  lists in both sync and validation scripts
- **Codebase access**: The Debt Analyst must be able to read source files using
  the `Read` and `Glob` tools — the skill must not assume a specific language or
  file structure
- **Actionability**: Every debt item in the final report must have an
  `estimated-effort` and a `recommended-sprint` — vague items without actionable
  guidance are grounds for Skeptic rejection
- **Non-destructive**: The skill never modifies source code or existing project
  files; it is read-only (except for progress/report files it creates)

## Out of Scope

- Automated debt resolution (the skill identifies and prioritizes debt; it does
  not write fixes)
- Integration with issue trackers (Jira, Linear, GitHub Issues) — debt items are
  output to markdown only
- Metrics tracking over time (comparing debt levels across sessions) — each
  review is independent; trend analysis is a future item
- Style linting or formatting enforcement — these are code-quality tasks handled
  by CI/CD tools, not the debt review skill
- Changes to existing skills — review-debt is a standalone new skill with no
  modifications to review-quality or other existing skills
