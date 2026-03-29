---
feature: "laravel-team"
team: "conclave-forge"
agent: "armorer"
phase: "methodology"
status: "in_progress"
last_action: "Manifest drafted"
updated: "2026-03-28"
---

# METHODOLOGY MANIFEST: Laravel Engineering Team

**Armorer**: Vex Ironbind, The Equipper **Design Principles enforced**: DP-2
(methodology over role description), DP-4 (evidence over assertion)

---

## METHODOLOGY MANIFEST: Analyst

**Phase**: Reconnaissance (Phase 1) **Mandate**: Owns problem understanding —
classifies work type, maps affected code, audits existing Laravel patterns.

### Methodologies:

1. **Invariant Extraction** — Systematically catalog which Laravel patterns
   (Form Requests, Policies, Events, Observers, Service Providers, Repositories)
   are already in use across the affected codebase areas, recording each
   pattern's location, configuration style, and consistency.
   - **Output**: **Laravel Pattern Inventory** — a table with columns: Pattern
     Type | File(s) | Usage Style | Consistency Notes | Deviation Flags
   - **Skeptic challenge surface**: The Skeptic can point at any row and demand:
     "You listed FormRequest usage in `app/Http/Requests/` — did you check for
     inline validation in controllers that bypasses this pattern? Is the
     'consistent' rating accurate?"

2. **Dependency Graph Analysis** — Trace the dependency chain of affected files:
   service provider bindings, route→controller→service→repository→model paths,
   event/listener registrations, middleware stacks, and queue job dispatch
   points. Produce a directed graph of what touches what.
   - **Output**: **Impact Dependency Map** — a directed adjacency list or table
     with columns: Source Component | Depends On | Dependency Type (DI binding /
     route / event / queue / middleware) | Risk Level
   - **Skeptic challenge surface**: The Skeptic can question any edge: "You show
     `OrderController` → `OrderService` but missed that `OrderService`
     dispatches `OrderCreated` event — where are the listeners? Is the risk
     level understated?"

3. **Hypothesis Elimination Matrix** — For bug/security work types: generate
   competing hypotheses for root cause, then systematically eliminate each with
   evidence from the codebase. For feature/refactor types: generate competing
   scope interpretations and eliminate with evidence.
   - **Output**: **Hypothesis Elimination Log** — a table with columns:
     Hypothesis | Evidence For | Evidence Against | Status (Active / Eliminated
     / Confirmed) | Confidence
   - **Skeptic challenge surface**: The Skeptic can challenge any elimination:
     "You ruled out N+1 as root cause based on one query log — did you check
     eager loading across all affected relationships?"

---

## METHODOLOGY MANIFEST: Architect

**Phase**: Architecture (Phase 2) **Mandate**: Owns solution design — selects
Laravel patterns, defines implementation approach, produces priority-ranked
action plan.

### Methodologies:

1. **Decision Matrix (Weighted Scoring)** — For each architectural choice point
   (e.g., "synchronous service call vs. Event/Listener", "Repository pattern vs.
   direct Eloquent", "Form Request vs. custom validator", "Job vs.
   synchronous"), score alternatives against weighted criteria: Laravel
   convention alignment, testability, complexity cost, performance impact, and
   team consistency (matching existing patterns from the Analyst's Inventory).
   - **Output**: **Pattern Decision Matrix** — one matrix per decision point
     with columns: Alternative | Convention Score | Testability Score |
     Complexity Cost | Performance Score | Consistency Score | Weighted Total |
     Selected?
   - **Skeptic challenge surface**: The Skeptic can challenge any weight or
     score: "You gave 'direct Eloquent' a 4/5 on testability but the Analyst's
     Inventory shows this codebase uses Repository pattern everywhere —
     shouldn't consistency score override here?"

2. **Interface Contract Definition** — Define the precise interfaces between
   components before any code is written: method signatures, parameter types,
   return types, exception contracts, and event payloads. For Laravel
   specifically: Form Request rules arrays, API Resource `toArray()` shapes,
   Policy method signatures, Job/Event constructor contracts.
   - **Output**: **Interface Contract Registry** — a structured list with:
     Component | Method/Contract | Input Shape (typed) | Output Shape (typed) |
     Exception/Error Contract | Laravel Artifact Type (FormRequest / Resource /
     Policy / Job / Event)
   - **Skeptic challenge surface**: The Skeptic can challenge any contract: "The
     `StoreOrderRequest` rules don't validate `shipping_method` — the Analyst
     flagged this field in the scope. Is the Resource `toArray` shape consistent
     with the existing API response format?"

3. **ATAM (Architecture Tradeoff Analysis Method)** — Identify the quality
   attribute tradeoffs in the proposed design: where does choosing pattern X
   improve attribute A but degrade attribute B? Specifically for Laravel: eager
   loading (performance vs. memory), event-driven decoupling (maintainability
   vs. debuggability), queue offloading (response time vs. complexity), service
   layer depth (testability vs. indirection).
   - **Output**: **Tradeoff Analysis Table** — columns: Decision | Quality
     Attribute Improved | Quality Attribute Degraded | Severity of Degradation |
     Mitigation Strategy | Accepted?
   - **Skeptic challenge surface**: The Skeptic can challenge any tradeoff
     acceptance: "You accepted the debuggability cost of 3 nested event/listener
     chains — what's the mitigation? How does a developer trace a failed order
     through this chain?"

---

## METHODOLOGY MANIFEST: Implementer

**Phase**: Construction (Phase 3, parallel with Tester) **Mandate**: Owns
production code — translates the blueprint into idiomatic Laravel code following
the Architect's pattern selections.

### Methodologies:

1. **Work Breakdown Structure (Priority-Ordered)** — Decompose the Architect's
   Solution Blueprint into atomic implementation tasks ordered by the
   Architect's priority ranking. Each task maps to exactly one file change or
   artisan generator invocation. Track status as tasks are completed.
   - **Output**: **Implementation Checklist** — an ordered checklist with:
     Priority Rank | Task Description | Target File | Laravel Artifact
     (Migration / Model / Controller / FormRequest / Policy / Resource / Event /
     Listener / Job / Test) | Artisan Command (if applicable) | Status (pending
     / done)
   - **Skeptic challenge surface**: The Skeptic can challenge ordering: "You
     implemented the controller before the FormRequest it depends on — did you
     temporarily use inline validation? Does the migration run before the model
     references the new column?"

2. **Change Impact Analysis** — Before and after each code change, verify that
   the change does not break existing functionality by: running the existing
   test suite, checking for broken service container bindings, verifying route
   registration, and confirming migration ordering.
   - **Output**: **Impact Verification Log** — a table with columns: Change Made
     | Tests Run (pass/fail count) | Binding Check (OK/broken) | Route Check
     (OK/broken) | Migration Order Valid? | Side Effects Detected
   - **Skeptic challenge surface**: The Skeptic can challenge any "OK" entry:
     "You marked bindings as OK after adding a new ServiceProvider — did you
     verify it's registered in `config/app.php` or auto-discovered? Did you run
     the full suite or just related tests?"

3. **Convention Compliance Checklist** — For each file written, verify adherence
   to Laravel conventions using a standardized checklist derived from the stack
   hints: controllers thin (no business logic), validation in FormRequests only,
   authorization in Policies only, DI over facades in business logic, Eloquent
   relationships properly defined, eager loading specified, factory defined for
   each new model.
   - **Output**: **Convention Compliance Matrix** — columns: File | Convention
     Rule | Compliant (yes/no) | Violation Detail (if any) | Remediation
   - **Skeptic challenge surface**: The Skeptic can challenge any "yes": "You
     marked `OrderController@store` as 'thin' but it contains 3 lines of query
     building — should that be in a Repository or Service?"

---

## METHODOLOGY MANIFEST: Tester

**Phase**: Construction (Phase 3, parallel with Implementer) **Mandate**: Owns
test coverage — writes Pest/PHPUnit tests from the blueprint independently of
production code, then verifies implementation against them.

### Methodologies:

1. **Equivalence Partitioning** — Partition each input domain from the
   Architect's Interface Contract Registry into equivalence classes: valid
   inputs, boundary inputs, and invalid inputs. For Laravel specifically:
   partition FormRequest validation rules into passing/failing groups, partition
   Policy authorization into allowed/denied user roles, partition API endpoints
   into authenticated/unauthenticated/forbidden scenarios.
   - **Output**: **Test Partition Map** — a table with columns:
     Interface/Contract | Partition Class | Representative Input | Expected
     Outcome (HTTP status / exception / return value) | Test Method Name
   - **Skeptic challenge surface**: The Skeptic can challenge missing
     partitions: "You partitioned `StoreOrderRequest` validation but didn't
     include a class for when `quantity` is zero — the FormRequest allows
     integers but should it allow zero?"

2. **Boundary Value Analysis** — For each equivalence partition boundary, design
   specific test cases at the exact boundary values. For Laravel: pagination
   limits, string length validation rules, numeric min/max rules, date range
   boundaries, file size upload limits, rate limiting thresholds.
   - **Output**: **Boundary Test Matrix** — columns: Field/Parameter | Lower
     Bound | Upper Bound | At Boundary (pass/fail) | Just Below (pass/fail) |
     Just Above (pass/fail) | Test Method Name
   - **Skeptic challenge surface**: The Skeptic can challenge boundary
     selection: "You tested `max:255` for `name` but the migration defines the
     column as `string(100)` — which is the actual boundary, the validation rule
     or the database constraint?"

3. **Coverage Delta Tracking** — Track test coverage before and after the new
   test suite. Measure at the method level for services/repositories and at the
   route level for HTTP endpoints. Identify any interface contract from the
   Architect's registry that lacks a corresponding test.
   - **Output**: **Coverage Delta Report** — columns: Component | Coverage
     Before | Coverage After | Delta | Untested Contracts (from Interface
     Registry) | Risk Assessment
   - **Skeptic challenge surface**: The Skeptic can challenge any untested
     contract: "The Architect defined an exception contract for
     `OrderService::cancel()` when order is already shipped — where's the test?
     The delta shows +15% but the highest-risk path (payment processing) is
     still at 0%."

---

## METHODOLOGY MANIFEST: Skeptic

**Phase**: Gates all phases (Phase 1→2→3→delivery) **Mandate**: Owns quality
judgment — challenges every phase for Laravel convention violations,
architectural drift, missing edge cases, and pattern misapplication.

### Methodologies:

1. **FMEA (Failure Mode and Effects Analysis)** — For each deliverable under
   review, systematically enumerate potential failure modes, their severity,
   likelihood of occurrence, and detectability. For Laravel: missed eager
   loading (N+1), mass assignment vulnerabilities, missing authorization checks,
   broken service container bindings, migration ordering errors, queue failure
   scenarios without retry/dead-letter handling.
   - **Output**: **Failure Mode Register** — columns: Component | Failure Mode |
     Severity (1-10) | Occurrence Likelihood (1-10) | Detectability (1-10) | RPN
     (Risk Priority Number) | Recommended Action
   - **Skeptic challenge surface**: Self-auditing — the Forge Master or any
     agent can challenge RPN scores: "You rated 'missing Policy check on
     OrderController@destroy' as Severity 4 — unauthorized deletion of orders is
     not a 4, it's a 9."

2. **Heuristic Evaluation (Laravel Convention Heuristics)** — Evaluate each
   deliverable against a fixed set of Laravel convention heuristics: (1)
   Controllers contain no business logic, (2) Validation lives in FormRequests,
   (3) Authorization lives in Policies, (4) Side effects use Events/Listeners,
   (5) Async work uses Jobs, (6) Response shaping uses Resources, (7) DI over
   Facades in services, (8) Eager loading declared on relationships, (9)
   Factories exist for all models, (10) Migrations are reversible.
   - **Output**: **Heuristic Violation Log** — columns: Heuristic # | Heuristic
     Name | File(s) Violating | Violation Description | Severity (blocker /
     warning / nitpick)
   - **Skeptic challenge surface**: Agents can challenge severity ratings or
     dispute violations: "Heuristic 4 violation flagged for `OrderService`
     dispatching a notification directly — but the Architect's Decision Matrix
     explicitly chose synchronous notification here with documented rationale."

3. **Mutation Testing (Mental Model)** — For the Tester's test suite: mentally
   "mutate" the production code (change a conditional, swap a comparison
   operator, remove a method call) and ask: would any existing test catch this
   mutation? If not, the test suite has a gap. Focus on high-risk mutations:
   removing authorization checks, changing validation rules, altering query
   scopes, removing event dispatches.
   - **Output**: **Mutation Survival Log** — columns: Mutation Description |
     Location (file:line) | Survived? (yes = test gap) | Which Test Should Catch
     It | Recommended Test Addition
   - **Skeptic challenge surface**: The Tester can challenge mutation relevance:
     "The mutation 'remove `->where('active', true)` from UserScope' would be
     caught by `test_inactive_users_excluded` — check the Partition Map before
     logging it as survived."

---

## Overlap Analysis

No two agents produce the same output type:

| Agent       | Output Artifacts                                                                |
| ----------- | ------------------------------------------------------------------------------- |
| Analyst     | Laravel Pattern Inventory, Impact Dependency Map, Hypothesis Elimination Log    |
| Architect   | Pattern Decision Matrix, Interface Contract Registry, Tradeoff Analysis Table   |
| Implementer | Implementation Checklist, Impact Verification Log, Convention Compliance Matrix |
| Tester      | Test Partition Map, Boundary Test Matrix, Coverage Delta Report                 |
| Skeptic     | Failure Mode Register, Heuristic Violation Log, Mutation Survival Log           |

**Overlap check**: No output type duplication detected. Each artifact is
uniquely produced by one agent. Cross-references exist (Skeptic reads
Architect's Decision Matrix to validate Heuristic Evaluation challenges; Tester
reads Architect's Interface Contract Registry for Equivalence Partitioning) but
these are consumption relationships, not production overlap.

---

## Methodology-to-Phase Mapping

| Phase              | Agent(s)    | Methodology Category     | Techniques                                                                        |
| ------------------ | ----------- | ------------------------ | --------------------------------------------------------------------------------- |
| 1 — Reconnaissance | Analyst     | Investigation + Analysis | Invariant Extraction, Dependency Graph Analysis, Hypothesis Elimination Matrix    |
| 2 — Architecture   | Architect   | Design                   | Decision Matrix, Interface Contract Definition, ATAM                              |
| 3 — Construction   | Implementer | Design + Verification    | Work Breakdown Structure, Change Impact Analysis, Convention Compliance Checklist |
| 3 — Construction   | Tester      | Verification             | Equivalence Partitioning, Boundary Value Analysis, Coverage Delta Tracking        |
| All gates          | Skeptic     | Verification + Analysis  | FMEA, Heuristic Evaluation, Mutation Testing (Mental)                             |
