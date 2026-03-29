---
type: "user-stories"
feature: "design-api"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-06-design-api.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: API Design Skill (P3-06)

## Epic Summary

Create `design-api` as a new multi-agent conclave skill for structured API
design review. The skill evaluates proposed or existing APIs for interface
consistency, versioning hygiene, backward compatibility, and developer
experience (DX). An API Design Skeptic challenges all recommendations before the
design report is finalized, ensuring that API contracts are held to the same
rigor as the engineering principles the plugin enforces elsewhere.

## Stories

---

### Story 1: SKILL.md Scaffolding and Frontmatter

- **As a** skill author creating the API design skill
- **I want** a valid `plugins/conclave/skills/design-api/SKILL.md` with correct
  frontmatter, required sections, and shared content markers
- **So that** the skill is discoverable, passes all validators, and follows the
  established multi-agent engineering skill structure
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the skill directory, when created, then
     `plugins/conclave/skills/design-api/SKILL.md` exists with YAML frontmatter
     containing: `name: design-api`, a `description` field summarizing API
     design review and consistency enforcement, an `argument-hint` documenting
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
     from `plugins/conclave/shared/` with the API Design Skeptic's name
     substituted correctly in the Communication Protocol
  4. Given `bash scripts/validate.sh`, when run after the SKILL.md is created
     and synced, then all 12/12 validators pass
  5. Given the classification lists in `scripts/sync-shared-content.sh` and
     `scripts/validators/skill-shared-content.sh`, when `design-api` is added,
     then it is classified as `engineering`

- **Edge Cases**:
  - Skill name `design-api` conflicts with an internal tool name: verify no
    collision in `plugins/conclave/plugin.json`'s skill registry before writing
    the SKILL.md
  - Classification not added before sync: B-series validators default to
    engineering with WARN log; add explicitly before committing

- **Notes**: The Setup section should read `docs/specs/` for any existing API
  contracts and `docs/stack-hints/{stack}.md` for framework-specific API
  conventions. The `write-spec` skill's SKILL.md is a useful secondary reference
  for how an engineering skill reads specs.

---

### Story 2: API Consistency Reviewer Agent

- **As a** backend engineer who has proposed or implemented an API
- **I want** an API Consistency Reviewer agent that evaluates the API against
  established conventions
- **So that** my API follows the project's naming and structural patterns
  instead of introducing inconsistencies that API consumers will have to learn
  around
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given an API definition (provided as a spec file path, OpenAPI/Swagger doc,
     or inline description in the invocation arguments), when the API
     Consistency Reviewer is spawned, then it evaluates: naming conventions
     (resource nouns, plural collections, consistent casing), HTTP method
     semantics (GET for reads, POST for creates, PUT/PATCH for updates, DELETE
     for removes), status code correctness (200 vs 201 vs 204, 400 vs 422 vs
     409), and response envelope structure (consistent error format, pagination
     shape)
  2. Given the reviewer's findings, when inspected, then each finding includes:
     a `rule` (the convention being evaluated), a `verdict` (`pass` | `fail` |
     `warning`), the `location` (endpoint or field path), and a `recommendation`
     if the verdict is `fail` or `warning`
  3. Given a project with `docs/specs/` containing existing API contracts (from
     `write-spec` outputs), when the reviewer scans, then it uses those
     contracts as the consistency baseline — new APIs are evaluated against the
     established patterns, not just generic REST conventions
  4. Given no existing API contracts in `docs/specs/`, when the reviewer runs,
     then it applies general REST best practices (RFC 7807 error format, plural
     resource names, standard HTTP semantics) as the baseline and notes in the
     report that no project-specific baseline exists
  5. Given the reviewer's spawn prompt, when inspected, then it includes the
     instruction to checkpoint findings to
     `docs/progress/{api-name}-consistency-reviewer.md`

- **Edge Cases**:
  - API uses GraphQL or gRPC instead of REST: reviewer notes the protocol,
    applies protocol-appropriate conventions (GraphQL:
    query/mutation/subscription naming, gRPC: service/method naming), and flags
    any violations of those conventions
  - Multiple APIs in the same invocation: reviewer produces one findings file
    per API; the Design Lead aggregates them into the final report
  - API is internal-only (no external consumers): reviewer still applies
    consistency rules but demotes `warning` items to `info` and notes the
    internal context

- **Notes**: API Consistency Reviewer uses `sonnet` model. It does not generate
  new API designs — it reviews existing ones. Agent name:
  `api-consistency-reviewer`.

---

### Story 3: Breaking Change Analyzer Agent

- **As a** backend engineer modifying an existing API
- **I want** a Breaking Change Analyzer agent that identifies
  backward-incompatible changes
- **So that** I understand what consumers will break before deploying, and can
  plan a versioning or migration strategy
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given an existing API contract (from `docs/specs/` or provided as a file
     path) and a proposed new version, when the Breaking Change Analyzer is
     spawned, then it identifies changes classified as: `breaking` (removes
     field, changes type, removes endpoint, changes required parameter to
     optional or vice versa), `potentially-breaking` (adds required field to
     request, changes error code), or `non-breaking` (adds optional field to
     response, adds new endpoint)
  2. Given the analyzer's findings, when inspected, then each breaking change
     includes: the `change-type` classification, the affected endpoint or field,
     the `before` and `after` state, and a `migration-path` recommendation
     (e.g., "version the endpoint as /v2/", "add deprecation header to v1
     responses")
  3. Given zero breaking changes in the diff, when the analyzer completes, then
     it outputs a `CLEAN` verdict — no breaking changes detected — alongside the
     full change list for confirmation
  4. Given breaking changes found, when the analyzer sends its findings to the
     Design Lead, then the message includes a `BREAKING CHANGES DETECTED` header
     and lists the count by classification tier
  5. Given the analyzer's spawn prompt, when inspected, then it includes the
     instruction to checkpoint findings to
     `docs/progress/{api-name}-breaking-change-analyzer.md`

- **Edge Cases**:
  - No existing API contract found in `docs/specs/` for comparison: analyzer
    outputs a notice — "No prior version found; breaking change analysis
    requires a baseline" — and skips the analysis; the Consistency Reviewer
    still runs
  - API version is explicitly `v1` with no production consumers (pre-launch):
    analyzer runs but classifies breaking changes as `low-risk` with a note that
    no consumers are affected yet
  - Change removes a deprecated field that was announced for removal: analyzer
    classifies it as `breaking` but adds a `previously-deprecated: true` flag to
    acknowledge the prior announcement

- **Notes**: Breaking Change Analyzer uses `opus` model for careful diff
  reasoning. Agent name: `breaking-change-analyzer`. This agent only runs when a
  prior API version is available for comparison — the Determine Mode section
  must handle the no-baseline case gracefully.

---

### Story 4: DX Evaluation Agent

- **As a** developer who will consume the API
- **I want** a DX (Developer Experience) Evaluator agent that assesses how easy
  the API is to discover, understand, and use correctly
- **So that** the API's design is evaluated from the consumer's perspective, not
  just the implementer's
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given an API definition, when the DX Evaluator is spawned, then it
     evaluates: discoverability (are endpoint names self-documenting?),
     learnability (can a developer infer behavior from the first two or three
     endpoints?), consistency of error messages (are they human-readable and
     actionable?), and documentation completeness (does each endpoint have a
     description, example request, and example response?)
  2. Given the DX Evaluator's findings, when inspected, then each finding is
     rated on a `dx-score` from 1–5 (1 = poor, 5 = excellent) with a
     one-sentence rationale per score
  3. Given the DX Evaluator's overall assessment, when summarized, then it
     produces a single `overall-dx-score` (average of individual ratings,
     rounded to one decimal) and a `dx-summary` (1-paragraph narrative about the
     API's consumer experience)
  4. Given a dx-score below 3 for any criterion, when the DX Evaluator sends
     findings to the Design Lead, then it includes at least one concrete
     improvement suggestion per low-scoring criterion
  5. Given the DX Evaluator's spawn prompt, when inspected, then it includes the
     instruction to checkpoint findings to
     `docs/progress/{api-name}-dx-evaluator.md`

- **Edge Cases**:
  - API has no documentation at all (code only): DX Evaluator rates
    `documentation completeness` as 1/5 and focuses recommendations on which
    documentation to add first
  - Internal API with no external consumers: DX Evaluator runs with reduced
    scope — discoverability and learnability only; documentation completeness is
    `not-applicable` for internal-only APIs
  - API with excellent DX score across all criteria: DX Evaluator produces a
    positive summary with `overall-dx-score: 4.5+` and notes it as a strong
    reference for future API designs

- **Notes**: DX Evaluator uses `sonnet` model. Agent name: `dx-evaluator`. This
  agent is spawned when reviewing a proposed or new API design; it is optional
  when the invocation mode is `breaking-changes-only` (Story 5 AC3).

---

### Story 5: Invocation Modes and API Design Skeptic Gate

- **As a** developer invoking design-api
- **I want** the skill to support focused modes (full review,
  breaking-changes-only, consistency-only) and a mandatory Skeptic gate
- **So that** I can run a targeted check without a full review when speed
  matters, and all final recommendations are challenged before publication
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given invocation with no arguments or with an API spec path, when the skill
     runs, then it performs a full review: spawns API Consistency Reviewer +
     Breaking Change Analyzer + DX Evaluator + API Design Skeptic
  2. Given invocation with `--breaking-changes {spec-path}`, when the skill
     runs, then it spawns only the Breaking Change Analyzer + API Design Skeptic
     and produces a focused breaking-change report
  3. Given invocation with `--consistency {spec-path}`, when the skill runs,
     then it spawns only the API Consistency Reviewer + API Design Skeptic and
     produces a focused consistency report
  4. Given the API Design Skeptic's review of any output, when inspected, then
     the Skeptic evaluates: (a) are breaking-change classifications correct? (b)
     are consistency violations genuine or false positives? (c) are DX scores
     calibrated against realistic consumer expectations? (d) are recommendations
     actionable?
  5. Given a `REJECTED` verdict from the API Design Skeptic, when the Design
     Lead receives it, then the affected agents revise their findings and
     resubmit; the three-rejection deadlock protocol applies
  6. Given `bash scripts/validate.sh`, when run after the Determine Mode section
     is written, then the A2 validator confirms all required sections are
     present

- **Edge Cases**:
  - `--breaking-changes` invoked but no prior API version exists: skill returns
    "No baseline API version found. Provide a prior version spec to enable
    breaking change analysis." and exits without spawning agents
  - Full review invoked but no API spec is provided and no specs exist in
    `docs/specs/`: skill prompts the user to provide an API spec or spec file
    path and exits without spawning agents
  - API Design Skeptic approves consistency findings but rejects DX findings:
    Consistency Reviewer's output is preserved; DX Evaluator revises its
    assessment

- **Notes**: Agent name: `api-design-skeptic`. Model: `opus`. The Skeptic must
  not produce its own API recommendations — its role is to challenge the agents'
  findings and ensure the recommendations are sound.

---

### Story 6: API Design Report Artifact

- **As a** engineering team lead who ran an API design review
- **I want** a structured API design report written to
  `docs/specs/{api-name}/api-design-report.md`
- **So that** the review findings are preserved alongside the spec for future
  reference and implementation guidance
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all Skeptic-approved findings, when the Design Lead writes the
     report, then `docs/specs/{api-name}/api-design-report.md` is created with
     YAML frontmatter: `type: "api-design-report"`, `api-name`, `status`
     (`draft` | `reviewed` | `approved`), `breaking-changes-found` (boolean),
     `overall-dx-score` (if DX evaluation ran), `created`, `updated`
  2. Given the report body, when inspected, then it contains:
     `## Executive Summary`, `## Consistency Findings` (if Consistency Reviewer
     ran), `## Breaking Changes` (if Analyzer ran), `## DX Assessment` (if DX
     Evaluator ran), `## Recommendations` (top 5 prioritized by impact), and
     `## Skeptic Review`
  3. Given the `## Recommendations` section, when inspected, then each
     recommendation includes a `priority` (`critical` | `high` | `medium` |
     `low`), a description, and a `before/after` example where applicable
  4. Given the report is written with `breaking-changes-found: true`, when the
     Design Lead sends the report to the user, then the summary message
     prominently calls out the breaking changes count and recommends a
     versioning strategy
  5. Given `bash scripts/validate.sh`, when run after the skill is created, then
     all 12/12 validators pass — the report lives in `docs/specs/` (by the
     api-name convention) but is not a SKILL.md or artifact template, so no
     validator change is needed

- **Edge Cases**:
  - `{api-name}` directory does not exist in `docs/specs/`: Design Lead creates
    it before writing the report
  - Report written before Skeptic approval: `status: "draft"` until Skeptic
    approves; Design Lead sets `status: "approved"` only after `APPROVED`
    verdict
  - API name contains path separators or spaces: sanitize to slug before using
    in file path

- **Notes**: API design reports live in `docs/specs/{api-name}/` to co-locate
  them with the API's spec files. This mirrors the pattern where
  `sprint-contract.md` lives alongside `implementation-plan.md` in
  `docs/specs/{feature}/`.

---

## Non-Functional Requirements

- **Validator stability**: 12/12 validators must pass; `design-api` must be
  added to engineering classification lists in both sync and validation scripts
- **Spec-agnostic**: The skill must work with API descriptions in any format —
  OpenAPI YAML, inline markdown tables, plain prose — without requiring a
  specific format
- **Contracts are sacred**: API design recommendations that conflict with
  existing signed sprint contracts must be flagged; the skill must not
  inadvertently encourage breaking changes to contracted APIs
- **Non-destructive**: The skill never modifies existing spec files or API
  contracts; it only creates new report files

## Out of Scope

- Automated API schema validation against a live server — the skill operates on
  static spec files only
- Code generation from API specs — the skill produces design guidance, not
  implementation artifacts
- Integration with API management platforms (Apigee, Kong, AWS API Gateway) —
  report output is markdown only
- GraphQL schema generation or validation tooling — the skill reviews GraphQL
  APIs but does not integrate with GraphQL-specific tooling
- Changes to existing skills — design-api is a standalone new skill; write-spec
  and build-implementation are not modified
