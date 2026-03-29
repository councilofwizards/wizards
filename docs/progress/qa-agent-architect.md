---
type: "spec-draft"
feature: "qa-agent-live-testing"
status: "draft"
priority: "P2"
category: "quality-reliability"
created: "2026-03-27"
updated: "2026-03-27"
---

# QA Agent for Live Testing — Specification

## Summary

Add a dedicated QA agent to `build-implementation` and `build-product` that writes and executes Playwright e2e tests
against the running application. The QA agent is a separate role from the Quality Skeptic — it evaluates whether the
application _works_ (runtime behavior) while the Skeptic evaluates whether the code is _well-written_ (static quality).
Five files modified, one file created. No shared content changes, no new validators.

## Problem

The Quality Skeptic reviews code diffs but never runs the application. This catches structural problems (bad patterns,
missing error handling, spec divergence) but misses an entire class of bugs that only manifest at runtime: broken user
workflows, missing UI interactions, incorrect state transitions, and integration failures between frontend and backend.
The Anthropic harness design paper found that live application testing by evaluators dramatically outperforms text-only
code review for catching these issues.

Currently, the only way to catch runtime bugs is for the human operator to manually test after delivery. This defeats
the purpose of an autonomous build pipeline.

## Solution

### 1. QA Agent Spawn Definition

Added to both `build-implementation` and `build-product` as a new teammate.

**Name**: `qa-agent` **Model**: opus **Stage**: Runs after Quality Skeptic's POST-IMPLEMENTATION gate, before Lead
sign-off.

The QA agent is an **evaluation role** (like the Skeptic), not an execution role (like the engineers). It uses Opus for
deeper reasoning about test design and failure analysis.

**Role separation enforcement** — the spawn prompt explicitly prohibits:

- Reading application source code during evaluation (tests only interact with the running app)
- Reviewing code diffs or architecture patterns
- Commenting on code style, test coverage percentage, or implementation choices
- Writing or modifying application source files

**What the QA agent DOES**:

- Read acceptance criteria (sprint contract → stories → spec, in priority order)
- Write Playwright e2e test files to the project's test directory
- Start the application (or verify it's running)
- Execute the test suite against the live application
- Report structured pass/fail results
- Issue a verdict: APPROVED, REJECTED, or BLOCKED

### 2. QA Agent Spawn Prompt

```
First, read plugins/conclave/shared/personas/qa-agent.md for your complete role definition and cross-references.

You are Maren Greystone, Inspector of Carried Paths — the QA Agent on the {team-name} Team.
When communicating with the user, introduce yourself by your name and title.

YOUR ROLE: Verify that the built application works correctly by writing and executing
Playwright e2e tests against the RUNNING application. You test user-facing behavior,
not code quality. You are the final behavioral gate before delivery.

YOU DO NOT:
- Read or review application source code, diffs, or architecture
- Comment on code style, patterns, test coverage metrics, or implementation choices
- Write or modify application source files
- Issue conditional approvals — your verdict is binary (APPROVED/REJECTED) or BLOCKED

YOUR TEST DESIGN PROCESS:
1. Read acceptance criteria from the best available source (in priority order):
   a. Sprint contract at docs/specs/{feature}/sprint-contract.md (if signed)
   b. User stories at docs/specs/{feature}/stories.md
   c. Technical spec at docs/specs/{feature}/spec.md
   If NO source material is available, report BLOCKED with rationale "no test source material"
   and message the Team Lead requesting input.

2. For each acceptance criterion, write a Playwright test that verifies the criterion
   as a USER-FACING BEHAVIOR:
   - Describe blocks per user workflow (e.g., "user can complete checkout")
   - Test steps mirror user interaction steps (navigate, click, fill, submit)
   - Assertions target visible UI state (text content, element visibility, URL changes)
     — NOT internal state, database rows, or API response bodies
   - If a criterion is implementation-framed ("function X is called"), rewrite it as a
     behavioral test ("user sees Y after doing Z") and note the reframing in your progress file

3. If a criterion cannot be tested via Playwright (e.g., "background job completes within 5s"):
   - Mark it INCONCLUSIVE with a rationale
   - Suggest how to verify it post-deployment
   - Do NOT skip it silently

SPRINT CONTRACT TRACEABILITY:
When a signed sprint contract is provided, EVERY criterion in the contract's
## Acceptance Criteria section MUST have a corresponding named test. Your progress
file must include a traceability matrix:
  Contract Criterion 1: "..." → Test: "test name" → PASS/FAIL/INCONCLUSIVE
  Contract Criterion 2: "..." → Test: "test name" → PASS/FAIL/INCONCLUSIVE
If the contract's Out of Scope section excludes items, explicitly note that you
did NOT write tests for them and why.

TEST EXECUTION:
1. Detect the project's test runner and Playwright configuration:
   - Check package.json for @playwright/test dependency
   - Check for playwright.config.ts or playwright.config.js
   - If Playwright is not installed, attempt: npx playwright install --with-deps
   - If installation fails, report BLOCKED with dependency resolution instructions
2. Start the application if not already running:
   - Detect the start command from package.json scripts, Procfile, docker-compose, etc.
   - If the application fails to start, report BLOCKED (not REJECTED) with the startup error
   - Wait for the application to be ready (health check or port availability)
3. Run the test suite: npx playwright test {test-file}
   - If a test fails on first run, re-run it up to 2 additional times before marking FAIL
   - Note flakiness in the report if a test passes on retry
4. Collect results: test name, outcome (PASS/FAIL/SKIP), assertion details for failures

VERDICT FORMAT:
  QA VERDICT: {feature}
  Tests: {passed}/{total} passed, {failed} failed, {skipped} skipped
  Verdict: APPROVED / REJECTED / BLOCKED

  [Test Results]
  1. {test name} — PASS
  2. {test name} — FAIL
     Assertion: {what was expected vs. what happened}
     Suggestion: {concrete fix recommendation for the engineers}
  3. {test name} — INCONCLUSIVE
     Reason: {why this can't be tested via Playwright}
     Post-deployment verification: {how to check}

  [If REJECTED:]
  Failed tests must be fixed before re-running QA. Route back to engineers.

  [If BLOCKED:]
  Reason: {infrastructure failure, missing dependencies, no source material, etc.}
  Resolution: {what needs to happen before QA can proceed}

VERDICT RULES:
- ALL tests pass → APPROVED
- ANY test fails → REJECTED (no exceptions, no negotiation)
- Infrastructure failure (app won't start, Playwright won't install, no source material) → BLOCKED
- Empty test suite (no tests generated) → BLOCKED, never a false APPROVED

RE-RUN BEHAVIOR:
When engineers fix failures and QA re-runs:
- Re-run ONLY previously failing tests unless the fix touches files outside the failing scenario's scope
- If new files were touched, re-run the full suite
- A re-run that passes clears the prior REJECTED status

COMMUNICATION:
- Send your verdict to the Team Lead AND the quality-skeptic
- If you find a behavioral failure, describe it in user terms: "user cannot complete checkout
  because the submit button does not respond to clicks" — not "button onClick handler is missing"
- If you are BLOCKED, message the Team Lead with URGENT priority
- You may ask any agent for clarification about expected behavior. Message them directly.

WRITE SAFETY:
- Write test files ONLY to the project's test directory (detected from config or convention)
- Write your progress/verdict ONLY to docs/progress/{feature}-qa-agent.md
- NEVER write to application source files, spec files, contract files, or other agent progress files
- Checkpoint after: task claimed, tests written, execution started, verdict delivered
```

### 3. Orchestration Flow Changes — build-implementation

Current flow:

```
1. Share plan + spec + stories
2. Backend + Frontend negotiate API contracts
3. Quality Skeptic reviews plan + contracts (GATE)
4. Backend + Frontend implement in parallel
5. Quality Skeptic reviews all code (GATE)
6. Agents write progress
7. Lead writes summary
8. Lead writes cost summary
```

New flow (QA gate inserted between steps 5 and 6):

```
1. Share plan + spec + stories
2. Backend + Frontend negotiate API contracts
3. Quality Skeptic reviews plan + contracts (GATE — blocks implementation)
4. Backend + Frontend implement in parallel
5. Quality Skeptic reviews all code (GATE — blocks delivery)
6. QA Agent verifies runtime behavior (GATE — blocks delivery)
7. Each agent writes progress to docs/progress/{feature}-{role}.md
8. Lead writes summary
9. Lead writes cost summary
```

**Step 6 details**:

- Spawn `qa-agent` (if not already spawned)
- Lead injects: (1) guidance block (if found), (2) sprint contract (if signed), (3) QA agent role prompt. Same injection
  order as Quality Skeptic.
- QA agent reads acceptance criteria, writes tests, executes them, delivers verdict
- If APPROVED → proceed to step 7
- If REJECTED → route failing test details back to backend-eng/frontend-eng for fixes. After fixes, QA re-runs failed
  tests only. Max 3 rejection cycles (same deadlock protocol as Skeptic gates).
- If BLOCKED → Lead escalates to human operator with the blocker details. Pipeline halts at QA gate.

**Critical Rules update** — add:

- QA Agent MUST approve runtime behavior before delivery
- QA Agent does NOT review code — that is the Quality Skeptic's role

**Failure Recovery update** — add:

- **QA deadlock**: If the QA Agent rejects the same tests 3 times, STOP iterating. The Team Lead escalates to the human
  operator with a summary of the test failures, the engineers' fix attempts, and the QA Agent's repeated rejections. The
  human decides: override QA, provide guidance, or abort.

### 4. Orchestration Flow Changes — build-product

**Stage 2 (Build Implementation)** — QA gate inserted after quality-skeptic post-implementation review:

Current Stage 2:

```
1. Share plan + spec + stories (+ contract check/negotiation)
2. Spawn backend-eng, frontend-eng, quality-skeptic
2b. Contract injection into quality-skeptic
3. Backend + Frontend negotiate API contracts
4. Quality-skeptic reviews plan + contracts (PRE-IMPLEMENTATION GATE)
5. Backend + Frontend implement in parallel
6. Quality-skeptic reviews all code (POST-IMPLEMENTATION GATE)
7. Agents write progress
8. Update roadmap status
9. Report Stage 2 complete
```

New Stage 2:

```
1. Share plan + spec + stories (+ contract check/negotiation)
2. Spawn backend-eng, frontend-eng, quality-skeptic
2b. Contract injection into quality-skeptic
3. Backend + Frontend negotiate API contracts
4. Quality-skeptic reviews plan + contracts (PRE-IMPLEMENTATION GATE)
5. Backend + Frontend implement in parallel
6. Quality-skeptic reviews all code (POST-IMPLEMENTATION GATE)
7. QA Agent verifies runtime behavior (QA GATE — blocks delivery)
8. Agents write progress
9. Update roadmap status
10. Report Stage 2 complete
```

**Step 7 details**: Same as build-implementation step 6. Spawn `qa-agent`, inject context, execute tests, handle
verdict. Same rejection cycle limit (3) and deadlock escalation.

**Artifact Detection table** — add QA row:

| Stage     | Artifact Type | Expected Path                                                       | Possible Results                |
| --------- | ------------- | ------------------------------------------------------------------- | ------------------------------- |
| 2 (Build) | qa-verdict    | Progress checkpoint with `agent: "qa-agent"`, `phase: "qa-testing"` | APPROVED / REJECTED / NOT_FOUND |

Detection logic:

- `APPROVED`: QA checkpoint exists with `status: "complete"` and verdict APPROVED in progress notes → skip QA on resume
- `REJECTED`: QA checkpoint exists with `status: "in_progress"` or verdict REJECTED → resume at fix cycle
- `NOT_FOUND`: No QA checkpoint → run QA fresh

**Stage 3 (Quality Review)** — no QA involvement. Stage 3 is the security audit and final quality check by the Skeptic.
QA's behavioral gate is complete by end of Stage 2.

**Spawn definitions** — add `qa-agent` entry:

```
### QA Agent
- **Name**: `qa-agent`
- **Model**: opus
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Write and execute Playwright e2e tests. Verify runtime behavior. Deliver APPROVED/REJECTED/BLOCKED verdict.
- **Stage**: 2 (Build)
```

**Lightweight mode** — QA agent is preserved. It is NOT removed in `--light` mode. Add to the `--light` section:

- qa-agent: unchanged (ALWAYS Opus) — QA gate is non-negotiable

### 5. QA Verdict Format

Three possible verdicts:

| Verdict  | Meaning                | Pipeline Effect                                     |
| -------- | ---------------------- | --------------------------------------------------- |
| APPROVED | All tests pass         | Proceed to next step/stage                          |
| REJECTED | One or more tests fail | Route back to engineers for fixes; QA re-runs after |
| BLOCKED  | Infrastructure failure | Pipeline halts; Lead escalates to human             |

BLOCKED is distinct from REJECTED:

- REJECTED = the application doesn't work correctly (behavioral failure)
- BLOCKED = QA cannot run at all (app won't start, Playwright won't install, no acceptance criteria)

The QA agent NEVER issues a conditional approval. The verdict is binary. This prevents negotiation around failing
behaviors that the Skeptic's nuanced review format allows.

### 6. Sprint Contract Integration

The QA agent reads the sprint contract using the same injection pattern as the Quality Skeptic:

**Injection trigger**: Setup step 5 (build-implementation) or artifact detection (build-product) finds a signed
contract.

**Injection format** (same as Quality Skeptic):

```markdown
## Sprint Contract for {feature}

{full contents of docs/specs/{feature}/sprint-contract.md}
```

**Prompt assembly order**: (1) guidance block → (2) sprint contract block → (3) QA agent role prompt.

**Fallback hierarchy** (when no signed contract):

1. Sprint contract signed → use contract criteria as primary test source
2. Sprint contract draft/negotiating → Lead logs warning, QA uses stories/spec
3. Sprint contract absent → QA uses stories/spec silently
4. Stories absent → QA uses spec
5. All absent → QA reports BLOCKED

**Contract-spec conflict**: If a contract criterion conflicts with a spec behavior, the QA agent tests against the
contract (it is the negotiated Definition of Done). The conflict is flagged in the progress file.

### 7. Persona File

**File**: `plugins/conclave/shared/personas/qa-agent.md`

**Character**: Maren Greystone, Inspector of Carried Paths

**Archetype**: A meticulous acceptance tester who has seen too many "it works on my machine" approvals fail in
production. Values precision, user-perspective testing, and reproducible evidence over subjective judgment.

**Core values**:

- User experience fidelity — does the application work the way a user expects?
- Behavioral correctness over code elegance — a beautifully-written feature that doesn't work is worthless
- Specificity in failure reporting — "the submit button doesn't respond" not "something's broken"
- Non-negotiability of failing tests — a fail is a fail, no exceptions

**What the persona explicitly ignores** (role separation enforcement):

- Code style and formatting
- Architecture patterns and design decisions
- Test coverage percentage
- Implementation choices (ORM vs. raw SQL, framework X vs. Y)

**Interaction style**: Direct, evidence-based, non-confrontational. Reports facts (test passed, test failed) not
opinions. Does not argue about code with the Quality Skeptic — different domains, mutual respect. When reporting
failures, describes them from the user's perspective.

**Cross-references** (files the persona reads):

- `docs/specs/{feature}/sprint-contract.md` — primary test source
- `docs/specs/{feature}/stories.md` — fallback test source
- `docs/specs/{feature}/spec.md` — secondary fallback
- `docs/stack-hints/{stack}.md` — for test runner/framework conventions

The persona file's existence is optional. The spawn prompt contains all necessary role instructions inline. If the
persona file does not exist, the QA agent uses its inline prompt and the absence is not an error (graceful degradation,
matching the pattern in build-implementation setup step 10).

### 8. Checkpoint Phase Extension

Add `qa-testing` as a valid phase value in the checkpoint protocol for both skills.

**build-implementation** checkpoint format:

```yaml
phase: "qa-testing" # planning | contract-negotiation | implementation | testing | qa-testing | review | complete
```

**build-product** checkpoint format:

```yaml
phase: "qa-testing" # planning | contract-negotiation | implementation | testing | qa-testing | review | complete
```

The `qa-testing` phase is distinct from:

- `testing` — unit/integration test runs by engineers during implementation
- `review` — the Quality Skeptic's code review gate

QA agent checkpoints after:

- Task claimed (`phase: qa-testing`, `status: in_progress`)
- Tests written (`status: in_progress`, note test count)
- Execution started (`status: in_progress`)
- Verdict delivered (`status: complete` if APPROVED, `status: blocked` if BLOCKED, `status: in_progress` if REJECTED and
  awaiting fixes)

### 9. Lightweight Mode Behavior

**build-implementation**: QA agent is unchanged in `--light` mode. Add to the Lightweight Mode section:

```
- QA Agent: unchanged (ALWAYS Opus) — QA gate is non-negotiable
```

**build-product**: QA agent is unchanged in `--light` mode. Add to the Lightweight Mode section:

```
- qa-agent: unchanged (ALWAYS Opus) — QA gate is non-negotiable
```

Rationale: The QA gate is a quality gate, not scaffolding. Lightweight mode reduces cost on planning/execution roles,
not on evaluation roles. This is consistent with the existing treatment of Quality Skeptic and plan-skeptic (both
preserved at Opus in `--light`).

### 10. Spawn Step Conditional — Contract and Guidance Injection into QA Agent

The QA agent receives the same context injections as the Quality Skeptic:

**Step 5 (build-implementation) / Step 2b equivalent (build-product)**: If a signed sprint contract was found, inject it
into BOTH the Quality Skeptic's AND the QA Agent's prompts. Format and ordering are identical.

**Step 4 (build-implementation) / guidance injection (build-product)**: If project guidance was found, prepend it to the
QA Agent's prompt (same as all other teammates).

Update the conditional injection text in "Spawn the Team" to reference `qa-agent` alongside `quality-skeptic`:

> **Step 5 (conditional):** If a signed sprint contract was found in Setup step 5, inject it into the Quality Skeptic's
> AND QA Agent's prompts. Do not inject into Backend Engineer or Frontend Engineer prompts...

## Constraints

1. No new agents beyond `qa-agent` — the QA role is a single additional teammate
2. No shared content changes (`plugins/conclave/shared/principles.md`,
   `plugins/conclave/shared/communication-protocol.md` untouched)
3. No sync script changes — `qa-agent` does not appear in the B2 normalizer's skeptic name list (it is not a skeptic)
4. All 12/12 validators must pass after changes
5. QA gate is non-negotiable — cannot be skipped, weakened, or removed in any mode
6. QA agent does NOT review code — role separation with Quality Skeptic is absolute
7. Graceful degradation — if app won't start or Playwright won't install, verdict is BLOCKED (not false APPROVED)
8. `--light` mode preserves QA agent at Opus
9. No changes to `plan-product`, `plan-implementation`, `write-stories`, `write-spec`, or any planning-phase skills
10. The QA agent writes to `docs/progress/{feature}-qa-agent.md` and the project test directory only

## Out of Scope

- Visual regression testing (screenshot diffing) — behavioral assertions only
- Performance/load testing — belongs to `review-quality` skill
- Changes to planning-phase skills — QA is a build-phase concern
- Automated CI integration for the QA test suite
- Contract amendment protocol (deferred per sprint-contracts spec)
- QA participation in contract negotiation — QA reads the signed contract, does not author it
- Non-Playwright test frameworks — the spec assumes Playwright; other frameworks are a follow-on

## Files to Modify

| File                                                    | Change                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/build-implementation/SKILL.md` | Add `qa-agent` spawn definition, insert QA gate (new step 6) in Orchestration Flow, update Critical Rules, update Failure Recovery, extend checkpoint phase values, update `--light` mode section, update contract injection to include QA agent                                             |
| `plugins/conclave/skills/build-product/SKILL.md`        | Add `qa-agent` spawn definition, insert QA gate (Stage 2 step 7) in Orchestration Flow, add QA row to artifact detection table, update Critical Rules, update Failure Recovery, extend checkpoint phase values, update `--light` mode section, update contract injection to include QA agent |
| `plugins/conclave/shared/personas/qa-agent.md`          | **Create** — persona file for Maren Greystone, Inspector of Carried Paths                                                                                                                                                                                                                    |
| `scripts/validators/skill-structure.sh`                 | No change expected — A3 checks for Name + Model fields, which the new spawn definition provides                                                                                                                                                                                              |
| `scripts/validators/skill-shared-content.sh`            | No change expected — `qa-agent` is not a skeptic role, so B2 normalizer does not need a new entry                                                                                                                                                                                            |

**Files explicitly NOT modified**:

- `plugins/conclave/shared/principles.md` — no shared content changes
- `plugins/conclave/shared/communication-protocol.md` — no shared content changes
- `scripts/sync-shared-content.sh` — no sync changes
- Any planning-phase SKILL.md files
- Any validator scripts (existing validators cover the new spawn definition)

## Success Criteria

1. `plugins/conclave/skills/build-implementation/SKILL.md` contains a `qa-agent` spawn definition with Name (`qa-agent`)
   and Model (`opus`) fields that pass A3 validation
2. `plugins/conclave/skills/build-product/SKILL.md` contains a `qa-agent` spawn definition with Name (`qa-agent`) and
   Model (`opus`) fields that pass A3 validation
3. The QA agent's spawn prompt instructs it to write and execute Playwright tests against the running application — not
   review code
4. The QA agent's spawn prompt explicitly prohibits reading application source code, reviewing diffs, and commenting on
   code style
5. The Orchestration Flow in build-implementation has the QA gate after step 5 (Quality Skeptic POST-IMPLEMENTATION
   review) and before progress writing
6. The Orchestration Flow in build-product Stage 2 has the QA gate after step 6 (Quality Skeptic POST-IMPLEMENTATION
   review) and before progress writing
7. The QA verdict format supports three outcomes: APPROVED, REJECTED, BLOCKED — with structured failure reporting for
   REJECTED and blocker details for BLOCKED
8. Sprint contract injection into QA agent follows the same pattern as Quality Skeptic (same format, same assembly
   order, same graceful degradation)
9. `plugins/conclave/shared/personas/qa-agent.md` exists with character name, core values, and explicit role separation
   from Quality Skeptic
10. Checkpoint phase values include `qa-testing` in both skills
11. `--light` mode preserves QA agent at Opus in both skills
12. The QA agent's fallback hierarchy (contract → stories → spec → BLOCKED) is documented in the spawn prompt
13. All 12/12 validators pass after implementation — `bash scripts/validate.sh` returns 0
14. No shared content files are modified — `plugins/conclave/shared/principles.md` and `communication-protocol.md` are
    byte-identical before and after
