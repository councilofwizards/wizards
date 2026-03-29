---
type: "user-stories"
feature: "qa-agent-live-testing"
status: "approved"
source_roadmap_item: "docs/roadmap/P2-12-qa-agent-live-testing.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: QA Agent for Live Testing (P2-12)

## Epic Summary

Add a dedicated QA agent to the `build-implementation` and `build-product` skills that writes and executes Playwright
e2e tests against the running application. The QA agent is a completely separate role from the code/quality skeptic — it
evaluates whether the application _works_ (user-facing behaviors, runtime correctness) while the skeptic evaluates
whether the code is _well-written_ (static quality, architecture). QA runs after the code skeptic approves and before
the Lead signs off.

---

## Stories

### Story 1: QA Agent Spawn Definition in build-implementation

- **As a** team lead running `build-implementation`
- **I want** a dedicated QA agent spawned with its own name, model, and role prompt
- **So that** runtime behavior verification is handled by a specialist who never reviews code diffs

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `build-implementation` skill is invoked, when the team is spawned, then a `qa-agent` teammate exists in
     the `TeamCreate` definition alongside `backend-eng`, `frontend-eng`, and `quality-skeptic`
  2. Given the spawn definitions section, when the QA agent entry is read, then it contains `Name: qa-agent`, a `Model`
     field, and a prompt that explicitly states the QA agent DOES NOT review code diffs or architecture
  3. Given the QA agent's role prompt, when it is read, then it instructs the agent to evaluate user-facing behavior
     through test execution — not through code inspection
  4. Given the orchestration flow, when the sequence is examined, then QA runs AFTER `quality-skeptic` approves code and
     BEFORE final Lead sign-off (a new step between the existing step 5 and step 6)
  5. Given the A3 validator, when it checks spawn definitions, then the QA agent entry passes (Name + Model fields
     present)

- **Edge Cases**:
  - `--light` mode: QA agent is NOT removed in lightweight mode — live testing is a quality gate, not optional
    scaffolding
  - QA agent's model selection: should be `opus` to match the skeptic tier (evaluation role, not implementation role)
  - QA agent must NOT be assigned tasks that involve writing application code or reviewing pull request diffs

- **Notes**: The new step in the Orchestration Flow must clearly label QA as a gate — "QA Agent verifies runtime
  behavior (GATE — blocks delivery)". The existing step numbering in Orchestration Flow shifts by one after the new QA
  gate is inserted.

---

### Story 2: QA Agent Writes Playwright Tests from Acceptance Criteria

- **As a** QA agent
- **I want** to write Playwright e2e tests derived from the feature's acceptance criteria
- **So that** each criterion maps to an executable, deterministic test that verifies a user-facing behavior

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a set of user story acceptance criteria, when the QA agent designs the test suite, then each Given/When/Then
     statement maps to at least one Playwright test scenario
  2. Given a Playwright test written by the QA agent, when it is read, then the test name describes a user action or
     workflow ("user can complete checkout", "login fails with invalid password") — not an implementation detail ("POST
     /api/checkout returns 200")
  3. Given the QA agent's spawn prompt, when it describes how tests should be written, then it specifies: (a) describe
     blocks per user workflow, (b) test steps that match user interaction steps, (c) assertions on visible UI state —
     not internal state or database rows
  4. Given a sprint contract with signed acceptance criteria, when the QA agent designs tests, then every criterion in
     the contract has a corresponding test (traceability)
  5. Given no sprint contract is present, when the QA agent designs tests, then it falls back to the user stories
     `stories.md` file, then the technical spec as the source of behavioral truth

- **Edge Cases**:
  - AC is implementation-framed ("function `processOrder` is called"): QA agent rewrites it as a behavioral test ("user
    sees order confirmation screen after checkout") and notes the reframing in its progress file
  - AC is ambiguous or untestable via Playwright (e.g., "background job completes"): QA agent marks it INCONCLUSIVE with
    a rationale and how to verify post-deployment
  - Feature has no AC, no stories, no spec: QA agent halts and sends a message to the Lead requesting source material
    before proceeding

- **Notes**: The QA agent writes test files to the project's test directory (detected from stack hints or package.json).
  It does NOT modify application source files. Tests are committed as part of the feature delivery.

---

### Story 3: QA Agent Executes Tests and Delivers a Verdict

- **As a** team lead
- **I want** the QA agent to run its test suite against the built application and report a structured PASS/FAIL verdict
- **So that** the delivery gate is based on observable application behavior, not the agent's subjective assessment of
  the code

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the QA agent has written its test suite, when it executes the tests, then it runs them against a live
     (locally running) instance of the application — not against mocks or stubs
  2. Given the test run completes, when the QA agent reports results, then the report lists each test by name with its
     outcome (PASS / FAIL / SKIP) and the total counts
  3. Given any test failure, when the QA agent reports it, then the report includes: (a) which test failed, (b) the
     exact assertion that failed, (c) the actual vs. expected value, and (d) a concrete suggestion for what the engineer
     should fix
  4. Given all tests pass, when the QA agent delivers its verdict, then the verdict is `APPROVED` and the Lead may
     proceed to final sign-off
  5. Given any test fails, when the QA agent delivers its verdict, then the verdict is `REJECTED` and the Lead must
     route back to the engineers for a fix before QA re-runs
  6. Given a REJECTED verdict, when engineers fix the failure, then QA re-runs ONLY the previously failing tests (not
     the full suite) unless the fix touches files outside the failing scenario's scope

- **Edge Cases**:
  - Application fails to start: QA agent reports `BLOCKED` (not `REJECTED`), logs the startup error, and sends a message
    to the Lead — this is an infrastructure failure, not a test failure
  - Test suite is empty (no tests written): QA agent reports `BLOCKED` with rationale "no tests generated — source
    material insufficient", never issues a false `APPROVED`
  - Flaky test fails on first run: QA agent re-runs it up to 2 additional times before marking it `FAIL`; notes
    flakiness in report
  - QA agent cannot install Playwright or dependencies: reports `BLOCKED` with dependency resolution instructions

- **Notes**: The QA agent's verdict is binary: `APPROVED` or `REJECTED` (or `BLOCKED` for infrastructure failures). It
  cannot issue a conditional approval like the skeptic's nuanced code review can. This prevents negotiation around
  failed behaviors.

---

### Story 4: QA Agent Integration in build-product Pipeline

- **As a** team lead running `build-product`
- **I want** the QA agent to be part of the build-product pipeline alongside the existing quality skeptic
- **So that** the full pipeline (planning → implementation → QA → sign-off) provides live-testing coverage without
  requiring users to invoke build-implementation separately

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `build-product` SKILL.md spawn definitions, when the team is created, then `qa-agent` appears alongside
     `impl-architect`, `backend-eng`, `frontend-eng`, and `quality-skeptic`
  2. Given the Stage 2 (implementation) orchestration flow in build-product, when the sequence is read, then the QA gate
     follows the quality skeptic's code approval and precedes the Lead's final sign-off — matching the
     build-implementation ordering
  3. Given a resumption scenario (partial build-product run), when the pipeline resumes from a checkpoint, then QA state
     is recoverable: if QA ran and approved, skip QA; if QA ran and rejected, resume at the fix cycle; if QA had not
     run, run it fresh
  4. Given the `--light` flag, when build-product runs in lightweight mode, then the QA gate is preserved — it is not
     removed or skipped
  5. Given the A3 validator runs on build-product, when it checks spawn definitions, then the `qa-agent` entry passes

- **Edge Cases**:
  - Stage 1 (planning) was skipped because an implementation plan already existed: QA still runs in Stage 2; the skip
    logic applies to planning only, not the QA gate
  - build-product is interrupted between quality-skeptic approval and QA execution: checkpoint state captures
    `phase: testing`, resumption re-runs QA from the start (tests may be already written; re-execution is safe)

- **Notes**: The `phase` values in the checkpoint protocol should be extended to include `qa-testing` as a valid value,
  distinct from `testing` (which currently covers unit/integration test runs by engineers) and `review` (which is the
  skeptic's gate).

---

### Story 5: QA Agent Reads Sprint Contract Acceptance Criteria

- **As a** QA agent
- **I want** to read the signed sprint contract when one is available and use its acceptance criteria as my primary test
  design source
- **So that** my tests are directly traceable to the negotiated definition of done rather than re-interpreting user
  stories or the spec

- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given a signed sprint contract at `docs/specs/{feature}/sprint-contract.md`, when the QA agent is spawned, then the
     Lead injects the contract contents into the QA agent's prompt (same injection pattern used for the quality skeptic)
  2. Given the sprint contract is injected, when the QA agent designs tests, then each criterion in the
     `## Acceptance Criteria` section of the contract becomes a named test scenario
  3. Given the sprint contract has an `Out of Scope` section, when the QA agent reads it, then it explicitly does NOT
     write tests for excluded items — and notes this in its progress file
  4. Given a draft or unsigned sprint contract (status: `draft` or `negotiating`), when the QA agent encounters it, then
     the Lead logs a warning ("Sprint contract unsigned; QA agent will test against spec + stories") and QA falls back
     to the next source in the hierarchy
  5. Given no sprint contract exists, when the QA agent is spawned, then it proceeds silently using stories.md and
     spec.md as the behavioral source — no error, no warning

- **Edge Cases**:
  - Sprint contract criteria conflict with spec behavior: QA agent flags the conflict in its progress file and tests
    against the contract criteria (contract is the negotiated DoD, not the spec)
  - Sprint contract has zero criteria (empty `## Acceptance Criteria` section): QA agent notes "empty contract" and
    falls back to spec/stories, matching the quality skeptic's existing empty-contract handling
  - Custom sprint contract template at `.claude/conclave/templates/sprint-contract.md` is in use: the runtime contract
    file at `docs/specs/{feature}/sprint-contract.md` is what QA reads — the template is irrelevant at QA time

- **Notes**: The prompt injection order for QA agent should match the quality skeptic's: (1) user guidance block → (2)
  sprint contract block → (3) QA agent role prompt. This ensures contract context is loaded before the role instructions
  that reference it.

---

### Story 6: QA Agent Persona Definition

- **As a** team lead
- **I want** the QA agent to have a named persona with a defined voice, values, and worldview
- **So that** the agent has a consistent identity that reinforces its behavioral mandate and is coherent with the
  conclave ensemble

- **Priority**: could-have

- **Acceptance Criteria**:
  1. Given a new persona file at `plugins/conclave/shared/personas/qa-agent.md`, when it is read, then it defines: (a) a
     character name, (b) role title, (c) core values, (d) what the agent cares about and ignores, and (e) interaction
     style with the team
  2. Given the persona's core values, when they are read, then they emphasize: user experience fidelity, behavioral
     correctness over code elegance, specificity in failure reporting, and non-negotiability of failing tests
  3. Given the persona's description of what the agent ignores, then it explicitly lists: code style, architecture
     patterns, test coverage percentage, and implementation choices — to enforce role separation from the code skeptic
  4. Given the QA agent's spawn prompt in build-implementation and build-product, when the persona file exists, then the
     prompt instructs the agent to read `plugins/conclave/shared/personas/qa-agent.md` for its role definition (matching
     the tech-lead.md reference pattern in build-implementation setup step 10)
  5. Given the persona file does not yet exist, when the QA agent runs, then the skill degrades gracefully — the agent
     uses its inline role prompt and the absence of a persona file is not an error

- **Edge Cases**:
  - Name collision with existing personas: the QA agent's character name must not duplicate any existing persona in
    `plugins/conclave/shared/personas/`
  - Persona instructs QA agent to "look at code if needed": this conflicts with the role separation mandate — the
    persona must explicitly prohibit reading application source files during the evaluation phase

- **Notes**: Suggested character archetype: a meticulous acceptance tester who has seen too many "it works on my
  machine" approvals fail in production. Values precision, user-perspective testing, and reproducible evidence over
  subjective judgment. Does not argue about code style — that is someone else's job. A name in the style of other
  conclave personas (e.g., "Maren Greystone, Inspector of Carried Paths") would fit the ensemble.

---

## Non-Functional Requirements

- **Validator compliance**: All A-series checks must pass after SKILL.md edits. The QA agent spawn definition must
  satisfy A3 (Name + Model fields present). No new validator categories required.
- **Write safety**: QA agent writes to `docs/progress/{feature}-qa-agent.md` for reporting and to the project's test
  directory for Playwright test files. It does not write to application source files, spec files, contract files, or
  other agent progress files.
- **Graceful degradation**: If the application cannot be started or Playwright cannot be installed, the QA agent reports
  `BLOCKED` (not a false `APPROVED`). The pipeline halts at the QA gate until the blocker is resolved.
- **Idempotency**: Re-running QA on an already-approved feature (e.g., during resume) should re-execute tests and
  re-issue the verdict — QA does not cache prior approvals.
- **No shared content changes**: `plugins/conclave/shared/principles.md` and
  `plugins/conclave/shared/communication-protocol.md` are untouched. No sync script run required.

## Out of Scope

- Visual regression testing (screenshot diffing) — QA agent uses behavioral Playwright assertions only
- Performance/load testing — that belongs to the quality-skeptic's ops review (`review-quality` skill)
- Changes to `plan-product`, `plan-implementation`, `write-stories`, or `write-spec` — QA is a build-phase concern
- Automated CI integration for the QA test suite — out of scope for P2-12; tracked separately
- Contract amendment protocol — already deferred to a follow-on item in the sprint-contracts spec
- QA agent participation in the contract negotiation phase — QA reads the signed contract, it does not author it
