# METHODOLOGY MANIFEST: Refine Codebase Team

**Author:** Vex Ironbind, The Equipper **Status:** DRAFT — Checkpoint 1
**Date:** 2026-03-28

---

## METHODOLOGY MANIFEST: Surveyor (Phase 1 — Audit)

**Mission:** Identify what needs refactoring; produce a prioritized Refactoring
Manifest.

### Methodologies:

1. **Heuristic Evaluation** — Systematic inspection of codebase artifacts
   against a predefined set of quality heuristics (Martin Fowler's code smell
   catalog, SOLID principles, Laravel conventions from CLAUDE.md).
   - **Output:** Heuristic Violation Matrix — a table with columns:
     `File | Line(s) | Heuristic Violated | Severity (P1/P2/P3) | Category | Description | Estimated Effort`.
   - **Skeptic challenge surface:** Are severity ratings justified? Is the
     heuristic correctly applied? Are false positives present (e.g., flagging
     intentional design decisions as violations)?

2. **Dependency Graph Analysis** — Traces import/use relationships between
   controllers, services, models, and resources to identify coupling, orphaned
   code, and missing abstraction layers.
   - **Output:** Dependency Adjacency Matrix — a structured map showing each
     module's inbound/outbound dependencies, with annotations for: circular
     dependencies, high fan-out (>5 dependents), orphaned nodes (zero inbound),
     and missing intermediary layers.
   - **Skeptic challenge surface:** Are orphaned nodes truly dead code or
     dynamically resolved? Are coupling metrics thresholds appropriate for this
     codebase size? Does the graph account for Laravel's service container
     bindings and facade resolution?

3. **Exploratory Testing Charters** — Time-boxed, goal-directed investigation
   sessions focused on specific audit categories (controller bloat, missing
   Resources, N+1 queries, test gaps) with documented findings per charter.
   - **Output:** Charter Log — a structured log per category with:
     `Charter Goal | Time Budget | Files Examined | Findings | Confidence Level`.
     Aggregated into the final Manifest.
   - **Skeptic challenge surface:** Was the charter scope sufficient? Were time
     budgets appropriate? Are confidence levels honest — did low-confidence
     findings get flagged rather than asserted?

---

## METHODOLOGY MANIFEST: Strategist (Phase 2 — Plan)

**Mission:** Transform the Manifest into a safe, ordered execution plan
respecting API contracts and dependencies.

### Methodologies:

1. **Work Breakdown Structure (WBS)** — Hierarchical decomposition of the
   Manifest's findings into discrete, atomic refactoring operations, each small
   enough to execute, test, and verify independently.
   - **Output:** WBS Tree — a hierarchical breakdown:
     `Epic (category) → Work Package (file/module scope) → Task (single atomic refactoring operation)`.
     Each leaf task includes: preconditions, postconditions, estimated LOC
     delta, and affected test files.
   - **Skeptic challenge surface:** Are tasks truly atomic? Can any task be
     further decomposed? Are precondition/postcondition pairs complete — does
     satisfying all postconditions guarantee behavioral preservation?

2. **Failure Mode and Effects Analysis (FMEA)** — For each refactoring
   operation, systematically enumerate what could go wrong, assess severity and
   likelihood, and define mitigations.
   - **Output:** FMEA Register — a table with columns:
     `Operation | Failure Mode | Effect on API Contract | Severity (1-10) | Likelihood (1-10) | Risk Priority Number | Mitigation | Rollback Boundary`.
   - **Skeptic challenge surface:** Are failure modes exhaustive? Are RPN scores
     consistent across operations? Are rollback boundaries actually achievable
     (can you revert Operation N without undoing N+1)? Are mitigations tested or
     assumed?

3. **Decision Matrix (Weighted Scoring)** — Prioritize and sequence operations
   using weighted criteria: API risk, dependency depth, test coverage of
   affected area, estimated effort, and value delivered.
   - **Output:** Prioritized Operation Sequence — a scored matrix with columns:
     `Operation | API Risk (w=3) | Dependency Depth (w=2) | Test Coverage (w=2) | Effort (w=1) | Value (w=2) | Weighted Score | Execution Order`.
     Operations ordered by score, with dependency constraints as hard overrides.
   - **Skeptic challenge surface:** Are weights justified for this domain? Does
     the scoring correctly reflect the CLAUDE.md constraint hierarchy (API
     contract > test safety > code quality)? Do dependency overrides actually
     resolve conflicts or mask them?

---

## METHODOLOGY MANIFEST: Artisan (Phase 3 — Execute)

**Mission:** Execute planned refactoring operations, preserving external
behavior while improving internal structure.

### Methodologies:

1. **Strangler Fig Pattern** — Incrementally replace legacy code by building the
   new implementation alongside the old, routing traffic to the new path, then
   removing the old once verified. Prevents big-bang rewrites.
   - **Output:** Migration Ledger — a structured log per operation:
     `Operation ID | Old Path (file:line) | New Path (file:line) | Routing Status (parallel/switched/old-removed) | Test Status (pass/fail) | Contract Assertion (before hash → after hash)`.
   - **Skeptic challenge surface:** Was the parallel phase actually tested with
     both paths active? Was the old code fully removed or left as dead code? Do
     contract assertions compare actual response payloads, not just status
     codes?

2. **Red-Green-Refactor (TDD Cycle)** — For each operation: (Red) write or
   identify a failing/characterization test that captures current behavior,
   (Green) confirm it passes against existing code, (Refactor) apply the
   transformation and confirm the test still passes.
   - **Output:** TDD Cycle Log — per operation:
     `Operation ID | Red Phase (test file:method, assertion) | Green Phase (pass confirmation, timestamp) | Refactor Phase (files changed, diff summary) | Final Test Run (full suite pass/fail, duration)`.
   - **Skeptic challenge surface:** Does the characterization test actually
     capture the behavior that matters (not just "returns 200")? Was the Green
     phase confirmed _before_ refactoring, or was it assumed? Did the full test
     suite run after each operation, not just the targeted test?

3. **Extract-Verify-Inline** — Three-step mechanical refactoring: Extract the
   target code into a new named unit (method, class, service), Verify behavior
   preservation via tests, then Inline or integrate as the plan specifies. Each
   step is independently reversible.
   - **Output:** Transformation Record — per operation:
     `Operation ID | Extract (what was extracted, from where, to where) | Verify (test evidence: suite run output, specific assertions) | Inline/Integrate (final location, public interface) | Reversibility Checkpoint (git SHA)`.
   - **Skeptic challenge surface:** Was each step committed separately so
     rollback is granular? Does the extraction change any public interface
     signatures? Is the verify step testing the extracted unit _and_ the
     original call site?

---

## METHODOLOGY MANIFEST: Warden (Phase 4 — Verify, Skeptic)

**Mission:** Challenge every refactoring operation for behavioral preservation,
contract integrity, and test evidence. Gate phase completion.

### Methodologies:

1. **Change Impact Analysis** — Trace every modified file's upstream and
   downstream dependencies to identify potentially affected behavior beyond the
   direct change scope. Ensures no side effects escaped testing.
   - **Output:** Impact Traceability Matrix — per operation:
     `Changed File | Direct Dependents | Transitive Dependents | API Endpoints Affected | Test Coverage of Affected Paths (covered/uncovered) | Verdict (safe/at-risk)`.
   - **Skeptic challenge surface (self-applied):** Is the transitive dependency
     trace complete? Are dynamically resolved dependencies (Laravel service
     container, event listeners) included? Does "covered" mean the test actually
     exercises the changed path, or just touches the file?

2. **Equivalence Partitioning** — For each refactored endpoint, partition the
   input space into equivalence classes and verify that representative inputs
   produce identical outputs before and after refactoring.
   - **Output:** Equivalence Partition Table — per endpoint:
     `Endpoint | Partition Class | Representative Input | Expected Output (pre-refactor baseline) | Actual Output (post-refactor) | Match (yes/no) | Divergence Detail`.
   - **Skeptic challenge surface (self-applied):** Are partition classes
     exhaustive (valid, invalid, boundary, auth states, tenant variations)? Were
     baselines captured from actual pre-refactor execution, not assumed? Do
     "match" comparisons include response headers and status codes, not just
     body?

3. **Coverage Delta Tracking** — Compare test coverage metrics before and after
   each refactoring operation to detect coverage regressions (new code paths
   introduced without tests) or phantom coverage (tests pass but don't exercise
   the refactored path).
   - **Output:** Coverage Delta Report — per operation:
     `Operation ID | Files Changed | Pre-Coverage (line/branch %) | Post-Coverage (line/branch %) | Delta | New Uncovered Lines | Phantom Coverage Risk (tests that pass but don't exercise changed code) | Verdict`.
   - **Skeptic challenge surface (self-applied):** Is coverage measured at the
     branch level, not just line level? Are "phantom coverage" risks identified
     by actually tracing test execution paths, not just checking coverage
     percentages? Does a coverage increase prove correctness, or just that more
     lines were touched?

4. **Contract Snapshot Comparison** — Capture complete API response snapshots
   (status, headers, body structure, field types) before refactoring and compare
   against post-refactoring responses for every affected endpoint.
   - **Output:** Contract Comparison Ledger — per endpoint:
     `Endpoint | Method | Auth Context | Request Payload | Pre-Snapshot (full response) | Post-Snapshot (full response) | Structural Diff | Field-Level Changes | Breaking Change (yes/no) | Verdict`.
   - **Skeptic challenge surface (self-applied):** Were snapshots captured under
     identical conditions (same tenant, same auth, same data state)? Does the
     comparison account for non-deterministic fields (timestamps, UUIDs)? Were
     all auth contexts tested (unauthenticated, authorized, unauthorized)?

---

## Cross-Agent Artifact Uniqueness Verification

| Agent      | Methodology                  | Primary Output Type                                |
| ---------- | ---------------------------- | -------------------------------------------------- |
| Surveyor   | Heuristic Evaluation         | Violation Matrix (findings table)                  |
| Surveyor   | Dependency Graph Analysis    | Adjacency Matrix (relationship map)                |
| Surveyor   | Exploratory Testing Charters | Charter Log (investigation journal)                |
| Strategist | Work Breakdown Structure     | Hierarchical Tree (task decomposition)             |
| Strategist | FMEA                         | Risk Register (failure analysis table)             |
| Strategist | Decision Matrix              | Scored Sequence (prioritized ranking)              |
| Artisan    | Strangler Fig Pattern        | Migration Ledger (transition tracking)             |
| Artisan    | Red-Green-Refactor           | TDD Cycle Log (test-code feedback loop)            |
| Artisan    | Extract-Verify-Inline        | Transformation Record (mechanical refactoring log) |
| Warden     | Change Impact Analysis       | Impact Traceability Matrix                         |
| Warden     | Equivalence Partitioning     | Partition Table (input/output comparison)          |
| Warden     | Coverage Delta Tracking      | Coverage Delta Report (metrics comparison)         |
| Warden     | Contract Snapshot Comparison | Contract Comparison Ledger (API snapshot diff)     |

**No duplicate output types across agents.** Each artifact is structurally
distinct and serves a unique purpose in the deliverable chain.

---

## Skeptic Challenge Chain

The Warden's four methodologies are designed to challenge the outputs of all
three preceding agents:

- **Change Impact Analysis** challenges the **Surveyor's Dependency Graph** —
  did the Surveyor find all the dependencies that the changes actually touched?
- **Equivalence Partitioning** challenges the **Artisan's TDD Cycle Log** — did
  the tests actually cover meaningful input partitions, or just happy paths?
- **Coverage Delta Tracking** challenges the **Artisan's Transformation Record**
  — did the refactoring introduce untested paths?
- **Contract Snapshot Comparison** challenges the **Strategist's FMEA** — did
  the failure modes and mitigations actually prevent contract breakage?

---

_Checkpoint 1: Methodology Manifest drafted. Awaiting Forge Master review._
