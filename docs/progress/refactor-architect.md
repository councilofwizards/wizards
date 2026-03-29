# TEAM BLUEPRINT: Laravel API Code Cleanup & Refactoring

**Author:** Kael Draftmark, The Foundryman **Status:** DRAFT — Checkpoint 1
**Date:** 2026-03-28

---

## Mission

**Refine Codebase**

- **Verb:** Refine — encompasses cleanup, consolidation, standardization, and
  structural improvement without altering external behavior.
- **Noun:** Codebase — the full application surface: controllers, services,
  models, resources, tests.
- **Singularity validation:** "Refine" and "Codebase" cannot be split into
  independent skills. Refining requires the codebase as its object; the codebase
  requires an action. This is one mission.

---

## Classification

**ENGINEERING** — All agents read, analyze, write, or review application code.
No agent operates outside the codebase.

---

## Phase Decomposition

| Phase | Name        | Agent(s)         | Deliverable          | Input                                                  | Output                                                                                                                        |
| ----- | ----------- | ---------------- | -------------------- | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| 1     | **Audit**   | Surveyor         | Refactoring Manifest | User-specified scope (files, modules, or "full scan")  | Prioritized list of refactoring targets with severity, category, estimated effort, and file locations                         |
| 2     | **Plan**    | Strategist       | Refactoring Plan     | Refactoring Manifest (from Phase 1)                    | Ordered sequence of refactoring operations, each with: before/after contract assertion, dependency map, and rollback boundary |
| 3     | **Execute** | Artisan          | Refactored Code      | Refactoring Plan (from Phase 2)                        | Modified source files + passing test suite                                                                                    |
| 4     | **Verify**  | Warden (skeptic) | Verification Report  | Refactored Code + Refactoring Plan + original Manifest | Accept/reject verdict with evidence for each refactoring operation                                                            |

---

## Agent Roster

| Agent                | Concern (one sentence)                                                                                                                  | Model  | Rationale                                                                                                                                                                                                                                               |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Surveyor**         | Identifies what needs refactoring and why, producing a prioritized inventory of code smells, violations, and improvement opportunities. | Opus   | Analysis-intensive: must reason about code quality, architectural patterns, SOLID violations, N+1 queries, dead code, and duplication across 30 controllers, 67 models, and 7 services. Judgment calls on severity and priority require deep reasoning. |
| **Strategist**       | Transforms the audit inventory into a safe, ordered execution plan that respects API contract integrity and dependency boundaries.      | Opus   | Must reason about change ordering, backward compatibility constraints, cross-file dependencies, and rollback boundaries. A wrong ordering can cascade into breaking changes — this is risk-reasoning work.                                              |
| **Artisan**          | Executes planned refactoring operations, writing code that preserves external behavior while improving internal structure.              | Sonnet | Works from a well-defined plan with explicit before/after contracts. Execution, not analysis. Sonnet excels at following structured instructions to produce code.                                                                                       |
| **Warden** (skeptic) | Challenges every refactoring operation for behavioral preservation, contract integrity, and test evidence — gates phase completion.     | Opus   | The skeptic. Must adversarially reason about whether changes preserve behavior, whether tests actually prove what they claim, and whether API contracts remain intact. Always Opus per design principles.                                               |

### Agent Count Justification

**Four agents, four concerns:**

1. **Surveyor ≠ Strategist:** Finding problems (diagnosis) is fundamentally
   different from ordering their solutions (planning). The Surveyor asks "what's
   wrong?" while the Strategist asks "in what order can we safely fix it?"
   Merging them produces an agent that tries to plan while still discovering —
   leading to incomplete audits or premature optimization of the plan.

2. **Strategist ≠ Artisan:** Planning safe change sequences requires reasoning
   about the entire dependency graph. Executing a single change requires focus
   on the code being modified. An agent doing both will either under-plan
   (rushing to code) or over-plan (never starting). The Strategist's output is
   the Artisan's input — clean separation.

3. **Artisan ≠ Warden:** The person who wrote the code cannot objectively verify
   it. The Warden has no authorship bias and can challenge every change against
   the plan and the original audit.

4. **Warden is mandatory:** Per Design Principle 4, evidence over assertion. The
   Warden gates every phase, not just the final output. Without the Warden, the
   team produces code that "looks cleaner" but may silently break contracts.

**Why not more agents?** Considered splitting Surveyor into separate "code smell
detector" and "architecture analyzer" agents. Rejected: both consume the same
input (source files), produce the same output type (findings), and the boundary
between "code smell" and "architectural issue" is fuzzy. One agent with a
comprehensive checklist is better than two agents arguing over jurisdiction.

---

## Mandate Boundary Tests

| Agent A    | Agent B    | Boundary Statement                                                                                                                                        |
| ---------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Surveyor   | Strategist | Surveyor identifies _what_ needs changing and _why_; Strategist determines _when_ and _in what order_ changes can safely occur.                           |
| Surveyor   | Artisan    | Surveyor reads code to diagnose; Artisan reads code to transform — Surveyor never writes production code, Artisan never decides what to refactor.         |
| Surveyor   | Warden     | Surveyor asserts problems exist; Warden asserts solutions are correct — Surveyor's audit is an input the Warden validates against, not a verdict.         |
| Strategist | Artisan    | Strategist produces the plan; Artisan follows it — Artisan may not reorder, skip, or combine operations without Strategist approval.                      |
| Strategist | Warden     | Strategist defines what "safe" means for each operation (contract assertions, rollback points); Warden verifies those safety claims hold after execution. |
| Artisan    | Warden     | Artisan produces code; Warden judges it — Warden never writes fixes, only reject verdicts that send work back to Artisan.                                 |

---

## Deliverable Chain

```
[User scope input]
  → Phase 1: Audit
    → [Refactoring Manifest: prioritized targets with severity, category, effort, locations]
      → Phase 2: Plan
        → [Refactoring Plan: ordered operations with contracts, dependencies, rollback boundaries]
          → Phase 3: Execute
            → [Refactored Code + passing tests]
              → Phase 4: Verify
                → [Verification Report: accept/reject per operation with evidence]
```

### Downstream Guidance Rule Compliance

- **Manifest → Plan:** The Manifest includes priority rankings (P1/P2/P3) so the
  Strategist knows which targets to schedule first.
- **Plan → Execute:** The Plan includes explicit ordering so the Artisan
  processes operations sequentially as specified.
- **Execute → Verify:** Each executed operation is tagged back to its Plan entry
  so the Warden can verify against the original contract assertions.

### Implementation Phase Rule Compliance

- **Phase 3 (Execute):** The Artisan's procedure includes running
  `./container.sh artisan test` after each refactoring operation. No operation
  is considered complete until the full test suite passes.
- **Phase 4 (Verify):** The Warden demands test evidence (test output, coverage
  deltas) as part of the verification checklist. A passing suite is necessary
  but not sufficient — the Warden also checks for behavioral preservation beyond
  what tests cover.

---

## Parallelization Analysis

### Sequential Dependencies (strict)

- **Phase 1 → Phase 2:** The Strategist cannot plan without the Manifest.
  Strictly sequential.
- **Phase 2 → Phase 3:** The Artisan cannot execute without the Plan. Strictly
  sequential.
- **Phase 3 → Phase 4:** The Warden cannot verify code that hasn't been written.
  Strictly sequential.

### Within-Phase Parallelization

- **Phase 1 (Audit):** The Surveyor operates alone. However, the Surveyor CAN
  parallelize its own work by scanning independent code areas simultaneously
  (controllers, models, services, tests as separate scan targets).
- **Phase 3 (Execute):** The Artisan CANNOT parallelize refactoring operations.
  Each operation may depend on prior ones (e.g., extracting a service before
  consolidating duplicate calls to that service). The Plan's ordering must be
  respected sequentially.
- **Phase 4 (Verify):** The Warden operates alone, reviewing each operation in
  plan order.

### Cross-Phase Parallelization: None

All four phases are strictly sequential. This is inherent to the mission: you
cannot plan what you haven't found, execute what you haven't planned, or verify
what you haven't executed.

### Optimization Note

While phases are sequential, the team can operate on **batches** within a single
invocation. The Strategist can group independent operations into "batches" that
the Artisan executes and the Warden verifies together. This reduces round-trips
without breaking dependency ordering.

---

## Design Rationale

### Why four phases?

Considered three (merge Audit+Plan, Execute, Verify). Rejected: audit and
planning are distinct cognitive modes. The Surveyor should exhaustively catalog
without worrying about ordering constraints. The Strategist should optimize
ordering without worrying about discovery. Merging them produces an agent that
prematurely narrows scope.

Considered five (split Execute into "Write" and "Test"). Rejected: writing code
and running tests are part of the same feedback loop. An agent that writes
without testing is incomplete; an agent that only runs tests is just a CI
server. The Artisan owns the write-test cycle as one concern.

### Why four agents?

One per phase. Each phase requires a fundamentally different cognitive mode:

1. **Diagnosis** (what's wrong?) — Surveyor
2. **Strategy** (how to fix safely?) — Strategist
3. **Execution** (do the work) — Artisan
4. **Adversarial review** (prove it's right) — Warden

No agent can be removed without losing a critical capability. No agent's concern
overlaps with another's (verified by boundary tests above).

### Alternatives Considered and Rejected

1. **Separate "Test Writer" agent:** Considered adding an agent to write new
   tests for refactored code. Rejected: the Artisan should write tests as part
   of execution (you can't refactor without testing), and a separate test agent
   would need to understand the refactored code deeply — duplicating the
   Artisan's context. Instead, the Artisan's procedure includes test updates,
   and the Warden verifies test quality.

2. **Separate "Dead Code Detector" agent:** Considered a specialized agent for
   unused code/imports. Rejected: dead code detection is one category within the
   Surveyor's audit checklist, not a standalone concern. It doesn't warrant its
   own agent.

3. **Two execution agents (one for controllers, one for models):** Rejected:
   refactoring operations frequently span both (e.g., extracting logic from a
   controller into a service that delegates to a model). Splitting by code layer
   creates coordination overhead that exceeds the parallelization benefit.

---

## Domain-Specific Constraints (yms-api)

The following constraints from CLAUDE.md MUST be enforced across all phases:

1. **API Contract Integrity:** No breaking changes. The Warden's primary gate is
   behavioral preservation of all API responses.
2. **No Migrations:** Refactoring must not require schema changes. If a
   refactoring reveals a schema dependency, it is flagged and deferred.
3. **No Table Truncation in Tests:** Any test modifications must respect the
   existing test patterns (DatabaseTransactions for Feature, manual cleanup for
   Integration).
4. **Multi-tenant Architecture:** Refactoring must preserve landlord/tenant
   connection behavior. Cross-connection visibility rules are particularly
   sensitive.
5. **Test Suite Must Pass:** `./container.sh artisan test` is the verification
   command. Both Artisan and Warden use it.

---

## Surveyor Audit Categories

The Surveyor's Manifest should categorize findings into:

| Category               | Description                                                        | Example in yms-api                                                              |
| ---------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| **Controller Bloat**   | Business logic in controllers that belongs in services             | Controllers without corresponding services (only 7 services for 30 controllers) |
| **Missing Resources**  | Endpoints returning raw models/arrays instead of API Resources     | Only 6 Resources exist for ~30 endpoints                                        |
| **Duplication**        | Repeated logic across files                                        | Shared patterns between v1/v2 controllers                                       |
| **Query Inefficiency** | N+1 queries, missing eager loading, unscoped queries               | Model relationships traversed without `with()`                                  |
| **Dead Code**          | Unused imports, methods, classes, or config                        | Post-migration artifacts                                                        |
| **SOLID Violations**   | Single-responsibility breaches, tight coupling, missing interfaces | Fat controllers, god services                                                   |
| **Test Gaps**          | Missing test coverage for existing behavior                        | Only 5 unit tests for 67 models + 7 services                                    |

---

_Checkpoint 1: Blueprint drafted. Awaiting Forge Master review._
