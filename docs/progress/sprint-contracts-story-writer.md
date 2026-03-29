---
type: "user-stories"
feature: "sprint-contracts"
status: "draft"
source_roadmap_item: "docs/roadmap/P2-11-sprint-contracts.md"
approved_by: ""
created: "2026-03-27"
updated: "2026-03-27T14:30:00Z"
---

# User Stories: Sprint Contracts / Definition of Done (P2-11)

## Epic Summary

Add a pre-execution Sprint Contract step to the implementation pipeline. Before any code is written, the Planning Lead
and Plan Skeptic negotiate and sign a contract defining specific, measurable acceptance criteria for the feature. The
Quality Skeptic then evaluates against the contract criteria as explicit pass/fail items — not vague principles —
producing reproducible, reliable quality gates across the full pipeline.

## Stories

---

### Story 1: Sprint Contract Artifact Template

- **As a** skill author modifying plan-implementation and build-implementation
- **I want** a standard sprint contract template at `docs/templates/artifacts/sprint-contract.md` with a defined YAML
  frontmatter schema
- **So that** agents have a consistent, machine-readable format for producing and consuming sprint contracts, and
  downstream consumers (Quality Skeptic, custom override readers) can rely on a stable schema
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the repository contains `docs/templates/artifacts/`, when the template is created, then
     `docs/templates/artifacts/sprint-contract.md` exists with valid YAML frontmatter containing these fields:
     `type: "sprint-contract"`, `feature`, `status` (`draft` | `negotiating` | `signed`), `signed-by` (list of agent
     names), `created`, `updated`
  2. Given the template body, when it is inspected, then it contains a `## Acceptance Criteria` section where each item
     is a numbered entry formatted as: `{criterion description} | Pass/Fail: [ ]`
  3. Given the template body, when it is inspected, then it contains an `## Out of Scope` section listing explicit
     exclusions
  4. Given the template body, when it is inspected, then it contains a `## Performance Targets` section (optional, may
     be empty with a placeholder comment)
  5. Given the template body, when it is inspected, then it contains a `## Signatures` section with named placeholders
     for Lead and Skeptic sign-off
  6. Given the F-series artifact template validator (`scripts/validators/artifact-templates.sh`), when
     `bash scripts/validate.sh` is run after the template is created, then all validators pass (12/12)
  7. Given `scripts/validators/artifact-templates.sh` contains a hardcoded `expected_templates` list, when the sprint
     contract template is added, then the validator script is updated to include `sprint-contract:sprint-contract` in
     that list so the new template is validated (not silently ignored)

- **Edge Cases**:
  - Template with empty `acceptance-criteria`: valid — a feature may have zero criteria before negotiation begins
  - Template with `signed-by: []`: valid for `status: draft` or `status: negotiating`; invalid for `status: signed`
    (must have at least two signers — Lead + Skeptic)
  - `performance-targets` section absent entirely: treat as optional — skills that produce contracts should include it
    as empty rather than omit it

- **Notes**: The F-series validator already checks `type` field existence and value. The new template must use
  `type: "sprint-contract"` exactly. Review `scripts/validators/artifact-templates.sh` before writing the template —
  specifically locate the `expected_templates` list and add the new entry there (AC 7).

---

### Story 2: Contract Negotiation Step in plan-implementation

- **As a** Planning Lead running `/plan-implementation`
- **I want** the Lead and Plan Skeptic to negotiate and sign a sprint contract before the implementation plan is
  finalized
- **So that** "done" is defined in specific, measurable terms before any implementation work begins, making the Quality
  Skeptic's later evaluation reproducible rather than judgment-based
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given plan-implementation's Setup section, when the skill is invoked, then step 2 (currently "Read
     `docs/templates/artifacts/implementation-plan.md`") is extended to also read
     `docs/templates/artifacts/sprint-contract.md` as the contract output template
  2. Given the Orchestration Flow, when the impl-architect has produced the implementation plan draft (current step 2),
     then a new Contract Negotiation step fires **before** the plan-skeptic's plan review gate: the Lead proposes
     initial acceptance criteria derived from the spec's success criteria, and plan-skeptic reviews and either approves
     or counters with additions/modifications
  3. Given the contract negotiation exchange, when plan-skeptic approves the contract terms, then the Lead writes the
     signed contract to `docs/specs/{feature}/sprint-contract.md` using the template schema, with `status: "signed"` and
     `signed-by` listing both `planning-lead` and `plan-skeptic`
  4. Given the signed contract is written, when plan-skeptic performs its existing plan review (current step 3), then
     the review prompt explicitly references the sprint contract: plan conformance is checked against contract criteria,
     not only against the spec
  5. Given plan-implementation's final artifact output (current step 7), when the Team Lead writes
     `docs/specs/{feature}/implementation-plan.md`, then the implementation plan's frontmatter includes
     `sprint-contract: "docs/specs/{feature}/sprint-contract.md"` linking the two artifacts
  6. Given `bash scripts/validate.sh`, when run after the SKILL.md changes, then all 12/12 validators still pass

- **Edge Cases**:
  - Plan Skeptic rejects proposed criteria (too vague, missing edge cases): Lead revises and re-proposes; max 3 rounds
    before escalation to human operator (same deadlock protocol as existing skeptic gates — see "Skeptic deadlock" in
    the Failure Recovery section of plan-implementation SKILL.md)
  - Feature with an existing sprint contract from a prior session (resumption): skip negotiation if
    `docs/specs/{feature}/sprint-contract.md` exists with `status: "signed"` — read and use the existing contract
  - Spec with no explicit success criteria section: Lead derives criteria from user stories acceptance criteria; if no
    stories exist, Lead synthesizes criteria from the spec's Scope section and proposes them to plan-skeptic
  - `--light` mode: contract negotiation step is preserved unchanged — the contract gate is non-negotiable regardless of
    mode

- **Notes**: The contract negotiation is a Lead-to-plan-skeptic exchange, not a new agent spawn. It fits within the
  existing Orchestration Flow as a new step between "impl-architect produces plan" and "plan-skeptic reviews plan." The
  contract defines what plan-skeptic will later evaluate — so it must precede the plan review. Keep the step prompt
  tight: Lead proposes, Skeptic approves/counters, Lead writes. No new roles needed.

---

### Story 3: Contract-Based Evaluation in build-implementation

- **As a** Quality Skeptic in `/build-implementation`
- **I want** to evaluate each sprint contract criterion explicitly as pass/fail during my post-implementation review
- **So that** my verdict is grounded in specific, pre-agreed terms rather than general principles, making rejections
  actionable and approvals meaningful
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given build-implementation's Setup section, when the skill is invoked for a feature, then a new setup step reads
     `docs/specs/{feature}/sprint-contract.md` if it exists; if absent, the skill proceeds without contract-based
     evaluation (graceful degradation — no failure)
  2. Given the Quality Skeptic's spawn prompt, when a sprint contract is present, then the prompt instructs the Quality
     Skeptic to read the contract from `docs/specs/{feature}/sprint-contract.md` before performing the
     POST-IMPLEMENTATION GATE review
  3. Given the Quality Skeptic's POST-IMPLEMENTATION GATE review, when a sprint contract is present, then the review
     output includes a `Sprint Contract Evaluation` section listing each criterion with an explicit `PASS` or `FAIL`
     verdict and one-sentence rationale per item
  4. Given all contract criteria passing, when the Quality Skeptic issues their verdict, then `Verdict: APPROVED` is
     only valid if every criterion is `PASS`; a single `FAIL` criterion must produce `Verdict: REJECTED`
  5. Given a criterion that cannot be evaluated (e.g., requires runtime data not available in code review), when the
     Quality Skeptic encounters it, then it is marked `INCONCLUSIVE: [reason]` and treated as a non-blocking issue in
     the review
  6. Given a feature with no sprint contract, when the Quality Skeptic performs their review, then they evaluate against
     the spec and existing quality principles (current behavior), with no error or warning

- **Edge Cases**:
  - Sprint contract exists but is `status: "draft"` or `status: "negotiating"` (unsigned): Quality Skeptic logs a
    warning — "Sprint contract present but unsigned; evaluating against spec only" — and falls back to current behavior
  - Contract criterion is ambiguous (e.g., "the UI should feel fast"): Quality Skeptic flags it as `INCONCLUSIVE` and
    recommends the criterion be sharpened for future contracts
  - New acceptance criteria discovered during implementation not in the contract: Quality Skeptic notes them as
    "uncovered requirements" in the review; these inform a potential contract amendment (see Story 6) but do not block
    approval if covered by spec
  - Contract has zero acceptance criteria: Quality Skeptic notes the empty contract in their review and evaluates
    against the spec as fallback

- **Notes**: The change is primarily to the Quality Skeptic's spawn prompt in `build-implementation/SKILL.md` — add the
  contract reading instruction and the Sprint Contract Evaluation section to the review format. The Tech Lead's Setup
  section needs one new step to read the contract and inject it into the Quality Skeptic's prompt (analogous to how
  guidance files are injected in Setup step 10).

---

### Story 4: build-product Pipeline Integration

- **As an** Implementation Coordinator running `/build-product`
- **I want** the full build-product pipeline (Stage 1 and Stage 2) to include sprint contract negotiation and
  contract-based evaluation
- **So that** projects using the full pipeline get the same contract-based quality guarantees as projects using the
  individual skills directly
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given build-product's Stage 1 (Implementation Planning), when it runs, then it produces a signed sprint contract at
     `docs/specs/{feature}/sprint-contract.md` — by mirroring the contract negotiation prompt changes made to
     plan-implementation's Orchestration Flow (build-product contains its own copy of this logic, not a delegation to
     plan-implementation)
  2. Given build-product's Stage 2 (Build Implementation), when it runs, then Setup reads the sprint contract produced
     in Stage 1 (or found from a prior session) and injects it into the Quality Skeptic's spawn prompt
  3. Given the artifact detection table in build-product, when the pipeline checks which stages to skip, then a new
     `sprint-contract` row is added: artifact type `sprint-contract`, path `docs/specs/{feature}/sprint-contract.md`,
     possible results `SIGNED / UNSIGNED / NOT_FOUND`
  4. Given `sprint-contract: SIGNED`, when artifact detection runs before Stage 2, then the contract negotiation
     sub-step within Stage 2 is skipped and the existing signed contract is used
  5. Given `sprint-contract: NOT_FOUND`, when artifact detection runs before Stage 2, then the contract negotiation
     sub-step is executed before API contract negotiation begins in Stage 2
  6. Given `bash scripts/validate.sh`, when run after the SKILL.md changes, then all 12/12 validators still pass

- **Edge Cases**:
  - Stage 1 was skipped (implementation-plan FOUND): Check whether `sprint-contract.md` also exists; if absent despite
    an existing plan, run contract negotiation at the start of Stage 2 using the existing plan and spec as inputs
  - Pipeline resumes mid-Stage 2 (checkpoint recovery): Re-read the sprint contract from disk — do not re-negotiate a
    signed contract on resume
  - `--light` mode: contract negotiation step preserved, same as Story 2's light-mode rule

- **Notes**: build-product contains its own copy of the implementation planning and build orchestration logic — it does
  not invoke plan-implementation or build-implementation as sub-skills. Changes must be applied directly to
  `plugins/conclave/skills/build-product/SKILL.md`. Stage 1's orchestration flow gets the same contract negotiation step
  added as Story 2 adds to plan-implementation. Stage 2's Quality Skeptic prompt gets the same contract evaluation
  instructions added as Story 3 adds to build-implementation.

---

### Story 5: Custom Template Override via `.claude/conclave/templates/`

- **As a** project owner
- **I want** to override the default sprint contract template by placing a custom version at
  `.claude/conclave/templates/sprint-contract.md`
- **So that** my project's specific definition-of-done requirements — regulatory criteria, performance SLAs, team
  conventions — are always included in every sprint contract without agents needing to be told each time
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given a file exists at `.claude/conclave/templates/sprint-contract.md`, when plan-implementation (or build-product
     Stage 1) runs the contract negotiation step, then the Lead reads and uses the custom template instead of the
     default at `docs/templates/artifacts/sprint-contract.md`
  2. Given the custom template is read, when the Lead proposes initial acceptance criteria, then the custom template's
     pre-populated criteria (if any) are included in the initial proposal presented to plan-skeptic
  3. Given no file exists at `.claude/conclave/templates/sprint-contract.md`, when the skill runs, then the default
     template is used silently — no error, no warning
  4. Given `.claude/conclave/templates/` exists but `sprint-contract.md` is absent, when the skill runs, then the skill
     proceeds with the default template (same as condition 3)
  5. Given the defensive reading contract established by P2-13 (user-writable config spec), when
     `.claude/conclave/templates/sprint-contract.md` is unreadable (permission error), then the skill logs a warning —
     "Custom sprint contract template unreadable; using default" — and falls back to the default template
  6. Given `.claude/conclave/` does not exist at all, when the skill runs, then the skill proceeds with zero behavior
     change — no directory check failure, no error

- **Edge Cases**:
  - Custom template with malformed YAML frontmatter: Lead logs a warning — "Custom sprint contract template has invalid
    frontmatter; using default" — and falls back; does not crash
  - Custom template with `type` field set to something other than `sprint-contract`: treat as malformed (same warning +
    fallback)
  - Custom template is a directory (not a file): log warning, fall back to default
  - Custom template present but empty: log warning — "Custom sprint contract template is empty; using default" — fall
    back

- **Notes**: **Depends on P2-13 (User-Writable Configuration Convention)** — this story consumes the
  `.claude/conclave/templates/` convention established by that item. P2-13 must land before this story can be
  implemented. The lookup order is: (1) `.claude/conclave/templates/sprint-contract.md`, (2)
  `docs/templates/artifacts/sprint-contract.md`. No new mechanisms are needed — the check is purely a conditional read
  in the Setup step of plan-implementation (and build-product Stage 1). The defensive reading rules mirror those already
  defined for guidance file reading in build-implementation Setup step 10.

---

### Story 6: Contract Amendment Protocol

- **As a** Tech Lead mid-implementation in build-implementation or build-product Stage 2
- **I want** a defined protocol for amending a signed sprint contract when new requirements emerge or original criteria
  prove unverifiable
- **So that** the team can adapt to legitimate scope changes without abandoning the contract discipline or losing
  traceability of what changed and why
- **Priority**: could-have

- **Acceptance Criteria**:
  1. Given a signed sprint contract and a mid-implementation discovery that a criterion needs to change, when the Tech
     Lead proposes an amendment, then the amendment must be reviewed and approved by both the original signers (Planning
     Lead + Plan Skeptic, or Quality Skeptic if triggered during build review) before the contract is updated
  2. Given an approved amendment, when the sprint contract is updated, then the change is recorded in a new
     `## Amendment Log` section appended to `docs/specs/{feature}/sprint-contract.md`, with fields: `amended-by`,
     `amendment-date`, `criterion-changed`, `original-text`, `new-text`, `reason`
  3. Given the amendment log entry, when the Quality Skeptic performs their post-implementation review, then they
     evaluate against the **amended** criteria, not the original — the amendment log is informational, not normative
  4. Given a criterion is removed via amendment (not just modified), when the Quality Skeptic reviews, then the removed
     criterion is noted as "waived" in the Sprint Contract Evaluation section with the amendment reason
  5. Given an amendment proposed but not yet approved by all signers, when the Tech Lead reports status to the user,
     then the amendment is flagged as "pending" and implementation on the affected criterion is paused until approval

- **Edge Cases**:
  - Amendment proposed to add a net-new criterion not in original spec: Plan Skeptic may reject the amendment if the
    criterion represents scope creep; human operator escalation applies
  - Multiple amendments in a single session: each gets its own Amendment Log entry; Quality Skeptic evaluates against
    the cumulative state
  - Amendment to a criterion already evaluated as PASS in an interim review: Quality Skeptic re-evaluates that criterion
    against the new text; overall verdict may change
  - Sprint contract with no Amendment Log section (pre-amendment): section is appended on first amendment — document is
    append-only for the log

- **Notes**: **Extends beyond the P2-11 roadmap item scope** — the roadmap does not explicitly specify an amendment
  protocol, so this story is additive. It is included at could-have priority to prevent teams from abandoning contracts
  when reality diverges from plan, but it may be deferred to a follow-on item if implementation scope needs to be
  constrained. Implementation is a prompt-only change to the Orchestration Flow "Critical Rules" section of both
  plan-implementation and build-implementation — no new files, no new validators.

---

## Non-Functional Requirements

- **Graceful degradation**: All contract-reading steps must proceed silently when no contract is found. Features built
  before P2-11 lands must experience zero behavior change.
- **Validator stability**: The 12/12 passing validator suite must continue passing after all SKILL.md and template
  changes. The F-series validator must be checked before writing the template to ensure the `type` field naming
  convention matches.
- **Prompt injection safety**: Custom template content is read from `.claude/conclave/templates/` and injected verbatim
  into agent prompts. The same injection framing used by the guidance reader (P2-13) applies: content is preceded by its
  filename as a `###` sub-heading within an advisory block. This provides context to agents that the content is
  user-supplied, not system-authoritative.
- **No shared content changes**: Changes to `plugins/conclave/shared/principles.md` and
  `plugins/conclave/shared/communication-protocol.md` are out of scope. All modifications are SKILL.md prompt content
  only.

## Out of Scope

- Automated validation of contract criteria format (schema enforcement) — contracts are plain markdown; enforcement is
  left to agent judgment
- Contract versioning beyond the Amendment Log — no git-style diff tracking
- Cross-feature contract inheritance — each feature has its own contract; no global template merging
- UI or tooling for contract authoring — contracts are written by agents in plain markdown
- Changes to `plan-product` (the 5-stage planning pipeline) — P2-11 targets `plan-implementation`,
  `build-implementation`, and `build-product` only; `plan-product` produces specs, not implementation plans
