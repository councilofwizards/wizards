---
type: armorer-manifest
skill: review-pr
status: draft
created: 2026-03-29
author: vex-ironbind
---

# METHODOLOGY MANIFEST: The Tribunal — PR Code Review Team

**Armorer:** Vex Ironbind, The Equipper
**Blueprint Reference:** `docs/progress/review-pr-architect.md` (Kael Draftmark)
**Design Principles Enforced:** DP-2 (methodology over role description), DP-4 (evidence over assertion)

---

## Methodology Assignment

### 1. The Sentinel — Security Review

**METHODOLOGY MANIFEST: Sentinel**

Methodologies:

1. **STRIDE Threat Modeling** — Systematic classification of each code change against six threat categories (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege).
   - Output: **Threat Classification Matrix** — table with columns: Changed Component | STRIDE Category | Threat Description | Exploitability (High/Med/Low) | Mitigation Present (Y/N)
   - Skeptic challenge surface: Scrutineer can demand proof of exploitability for any row rated High, or question why a STRIDE category was marked N/A for a given component.

2. **Taint Analysis** — Trace untrusted data from entry points (user input, API parameters, file reads, environment variables) through the call graph to sensitive sinks (SQL queries, command execution, file writes, HTML output).
   - Output: **Taint Flow Log** — ordered list of taint chains: Source (file:line) → Transform 1 → Transform 2 → ... → Sink (file:line) | Sanitized? (Y/N) | Sanitizer Adequate? (Y/N)
   - Skeptic challenge surface: Scrutineer can challenge any chain where "Sanitized: Y" is claimed — demand the specific sanitizer function and whether it covers the sink type.

3. **Attack Tree Construction** — For each Critical/High finding, decompose the attack into a tree of preconditions an attacker must satisfy, with AND/OR nodes showing alternative paths.
   - Output: **Attack Tree Diagram** (text-based) — root = exploit goal, leaves = preconditions, edges = AND/OR, each leaf annotated with difficulty (trivial/moderate/hard)
   - Skeptic challenge surface: Scrutineer can question whether leaf preconditions are truly required (over-constraining reduces apparent severity) or whether alternative paths were missed (under-constraining inflates severity).

4. **CVSS Vector Scoring** — Apply Common Vulnerability Scoring System v3.1 vector strings to each finding for standardized severity rating.
   - Output: **CVSS Scorecard** — table: Finding ID | Vector String (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N) | Base Score | Severity Label
   - Skeptic challenge surface: Scrutineer can challenge any individual vector component — e.g., "You rated Attack Complexity as Low, but the code requires authenticated access, so PR should be High."

---

### 2. The Lexicant — Syntax & Verification

**METHODOLOGY MANIFEST: Lexicant**

Methodologies:

1. **Static Analysis Rule Audit** — Execute language-appropriate linters/type-checkers (e.g., `tsc --noEmit`, `eslint`, `phpstan`, `mypy`) and map each diagnostic to the changed lines in the PR diff.
   - Output: **Diagnostic Hit Matrix** — table: Rule ID | Severity | File:Line | Message | In PR Diff? (Y/N) | Pre-existing? (Y/N)
   - Skeptic challenge surface: Scrutineer can challenge any finding marked "In PR Diff: Y" that may actually be pre-existing, or demand re-run evidence if the tool output is missing.

2. **Import Dependency Graph Analysis** — Build the import/require graph for changed files and verify: no circular imports introduced, no missing imports, no unused imports, all import paths resolve.
   - Output: **Import Integrity Ledger** — table: File | Imports (added/removed/unchanged) | Circular? | Resolves? | Used in file? | Finding (if any)
   - Skeptic challenge surface: Scrutineer can challenge circular import claims by demanding the full cycle path, or question whether an "unused import" is actually consumed via side effects.

3. **Type Flow Tracing** — For each public API boundary in changed code, trace the declared types from input parameters through transformations to return types, flagging any `any`-typed gaps, unsafe casts, or narrowing failures.
   - Output: **Type Safety Chain** — ordered trace per function: Param(type) → Op1(resulting type) → Op2(resulting type) → Return(type) | Gaps flagged with reason
   - Skeptic challenge surface: Scrutineer can challenge whether a flagged `any` type is genuinely unsafe (some framework patterns require it) or whether a "safe" cast is actually sound.

4. **Dead Code Reachability Analysis** — For each suspected dead code segment, trace all possible call sites to determine if any execution path reaches it.
   - Output: **Reachability Verdict Table** — table: Code Segment (file:line range) | Call Sites Found | Conditional Paths | Verdict (Reachable/Unreachable/Conditionally Reachable)
   - Skeptic challenge surface: Scrutineer can challenge an "Unreachable" verdict by pointing to dynamic dispatch, reflection, or framework magic that the static trace missed.

---

### 3. The Arbiter — Spec & Story Compliance

**METHODOLOGY MANIFEST: Arbiter**

Methodologies:

1. **Requirements Traceability Matrix (RTM)** — Map every acceptance criterion and spec constraint to specific code locations in the PR diff, producing a bidirectional trace.
   - Output: **Traceability Matrix** — table: Requirement ID | Requirement Text | Code Location(s) | Status (Covered/Partial/Missing) | Evidence Notes
   - Skeptic challenge surface: Scrutineer can challenge any "Covered" status by demanding the evidence that the code actually fulfills the requirement's intent (not just that code exists at the location).

2. **Gap Analysis** — Systematically compare the full set of requirements against implemented changes to identify omissions, partial implementations, and unaddressed edge cases.
   - Output: **Requirements Gap Register** — table: Gap ID | Requirement Source | Gap Description | Severity (Blocking/Non-Blocking) | Recommendation
   - Skeptic challenge surface: Scrutineer can challenge whether a gap is truly a gap (the requirement may be addressed elsewhere) or whether a "Blocking" severity is warranted.

3. **Scope Boundary Audit** — For every changed file/function NOT traceable to a requirement, determine whether it is justified (refactoring to enable a requirement) or scope creep.
   - Output: **Scope Deviation Log** — table: Changed Code (file:line) | Linked Requirement | Justification | Verdict (In-Scope/Scope Creep/Enabling Refactor)
   - Skeptic challenge surface: Scrutineer can challenge "Enabling Refactor" verdicts — demand proof that the refactored code is actually needed by a traced requirement.

4. **Behavioral Contract Verification** — For each spec-defined behavior (normal, edge, error conditions), verify the code implements the described behavior by tracing the logical path.
   - Output: **Behavioral Contract Checklist** — table: Behavior ID | Condition (Normal/Edge/Error) | Spec Description | Code Path | Matches Spec? (Y/N/Partial) | Discrepancy Notes
   - Skeptic challenge surface: Scrutineer can challenge any "Y" match by requesting the specific code path trace, or question whether an edge condition list is exhaustive.

---

### 4. The Structuralist — Architecture & Design

**METHODOLOGY MANIFEST: Structuralist**

Methodologies:

1. **SOLID Compliance Audit** — Evaluate each changed class/module against all five SOLID principles individually, producing per-principle pass/fail with evidence.
   - Output: **SOLID Scorecard** — table: Class/Module | S (Y/N + reason) | O (Y/N + reason) | L (Y/N + reason) | I (Y/N + reason) | D (Y/N + reason)
   - Skeptic challenge surface: Scrutineer can challenge any "N" rating by questioning whether the principle genuinely applies in context (e.g., SRP for a small utility function), or challenge "Y" by pointing to a missed violation.

2. **Coupling & Cohesion Measurement** — Measure afferent coupling (Ca: who depends on this module) and efferent coupling (Ce: what this module depends on) for changed modules, computing instability ratio I = Ce/(Ca+Ce).
   - Output: **Coupling Profile** — table: Module | Ca | Ce | Instability (I) | Abstractness (A) | Distance from Main Sequence | Assessment
   - Skeptic challenge surface: Scrutineer can challenge the counted dependencies (did the analysis miss indirect coupling?) or whether high instability is actually appropriate for the module's role.

3. **Error Propagation Path Analysis** — Trace each error/exception type from its throw site through catch/handle sites to the final consumer (user, log, retry), identifying gaps where errors are swallowed or mistyped.
   - Output: **Error Propagation Map** — per error type: Throw Site (file:line) → Handler 1 (action) → Handler 2 (action) → Terminal (user-facing/logged/swallowed) | Gap? (Y/N)
   - Skeptic challenge surface: Scrutineer can challenge any "swallowed" finding (maybe it's intentionally suppressed) or demand proof that a handler actually catches the specific error type.

4. **Design Pattern Conformance Check** — Identify design patterns already established in the codebase's architecture, then verify changed code conforms to or intentionally departs from those patterns.
   - Output: **Pattern Conformance Ledger** — table: Established Pattern | Where Used in Codebase | Changed Code Conforms? (Y/N/Departs) | Departure Justified? | Evidence
   - Skeptic challenge surface: Scrutineer can challenge whether the "established pattern" is actually consistently used (maybe it's already inconsistent) or whether a departure is genuinely justified.

---

### 5. The Swiftblade — Performance

**METHODOLOGY MANIFEST: Swiftblade**

Methodologies:

1. **Asymptotic Complexity Analysis** — For each function in the hot path of changed code, determine the Big-O time and space complexity and flag any superlinear operations.
   - Output: **Complexity Profile** — table: Function (file:line) | Time Complexity | Space Complexity | Input Scale (expected N) | Projected Cost at Scale | Acceptable? (Y/N)
   - Skeptic challenge surface: Scrutineer can challenge the stated complexity (missed nested loops, amortized vs. worst-case) or question whether the function is actually in a hot path.

2. **N+1 Query Detection via Call-Graph Trace** — Trace database query calls within loops and iteration constructs, identifying patterns where a query executes once per element rather than batched.
   - Output: **Query-in-Loop Register** — table: Loop Location (file:line) | Query Call (file:line) | Iterations (estimated) | Batch Alternative Available? | Severity
   - Skeptic challenge surface: Scrutineer can challenge whether the loop actually executes at scale (maybe it's bounded to a small constant) or whether the suggested batch alternative maintains correctness.

3. **Resource Lifecycle Audit** — Track allocation and deallocation of resources (connections, file handles, streams, event listeners, timers) through changed code paths, flagging unclosed or leaked resources.
   - Output: **Resource Lifecycle Ledger** — table: Resource Type | Allocation Site (file:line) | Deallocation Site (file:line) | Guaranteed Cleanup? (Y/N) | Cleanup Mechanism (try-finally/using/destructor/none)
   - Skeptic challenge surface: Scrutineer can challenge "Guaranteed Cleanup: Y" by asking about error paths — does cleanup occur when an exception is thrown between allocation and deallocation?

4. **Caching Strategy Evaluation** — For repeated expensive operations in changed code, assess whether caching is present, appropriate, and correctly invalidated.
   - Output: **Caching Assessment Matrix** — table: Expensive Operation (file:line) | Cacheable? (Y/N) | Cache Present? (Y/N) | Invalidation Strategy | TTL Appropriate? | Staleness Risk
   - Skeptic challenge surface: Scrutineer can challenge "Cacheable: N" assessments (maybe it is cacheable with the right key) or question whether the invalidation strategy handles all mutation paths.

---

### 6. The Prover — Test Adequacy

**METHODOLOGY MANIFEST: Prover**

Methodologies:

1. **Coverage Delta Tracking** — Map every new or changed code branch/path to its corresponding test(s), producing a matrix showing which paths are tested and which are gaps.
   - Output: **Coverage Delta Matrix** — table: Code Path (file:line, branch) | Test(s) Covering It | Assertion Type | Gap? (Y/N) | Risk if Untested
   - Skeptic challenge surface: Scrutineer can challenge "covered" claims by examining whether the test actually exercises the specific branch (not just the function), or question risk ratings for untested paths.

2. **Mutation Testing (Conceptual)** — For each test, mentally introduce plausible mutations to the code under test (negate conditionals, swap operators, remove statements) and assess whether existing assertions would catch them.
   - Output: **Mutation Survival Register** — table: Test Name | Mutation Applied | Would Test Fail? (Y/N = killed/survived) | If Survived: Missing Assertion
   - Skeptic challenge surface: Scrutineer can challenge "killed" verdicts by questioning whether the assertion is specific enough (a test that checks "no error thrown" kills few mutations), or whether the mutation is realistic.

3. **Equivalence Partitioning & Boundary Analysis** — For each function under test, identify input equivalence classes and boundary values, then check whether tests cover at least one value from each class and all boundaries.
   - Output: **Partition Coverage Table** — table: Function | Input Parameter | Equivalence Classes | Boundary Values | Classes Tested | Boundaries Tested | Gaps
   - Skeptic challenge surface: Scrutineer can challenge whether the equivalence classes are correctly identified (maybe a class should be split further) or whether a "tested" boundary actually uses the exact boundary value.

4. **Test Smell Detection** — Scan test code for known anti-patterns (Fowler/Meszaros test smell catalog): flaky indicators, shared mutable state, assertion roulette, mystery guest, eager test, etc.
   - Output: **Test Smell Catalog** — table: Test File:Line | Smell Name | Description | Severity (High/Med/Low) | Remediation
   - Skeptic challenge surface: Scrutineer can challenge whether a flagged smell is actually harmful in context (e.g., shared state that's immutable) or question missed smells.

---

### 7. The Delver — Data & Migration Safety

**METHODOLOGY MANIFEST: Delver**

Methodologies:

1. **Migration Reversibility Audit** — For every migration file, execute the `up` and `down` paths mentally and verify the `down` path fully reverses the `up` path without data loss or schema inconsistency.
   - Output: **Reversibility Verification Table** — table: Migration File | Up Operation | Down Operation | Fully Reversible? (Y/N) | Data Loss Risk | Blocking Issues
   - Skeptic challenge surface: Scrutineer can challenge "Fully Reversible: Y" claims — does the down migration restore dropped columns' data? Does it handle rows added after the up migration?

2. **Index-Query Coverage Analysis** — For every query modified or added in the PR, identify the WHERE, JOIN, and ORDER BY columns and verify supporting indexes exist.
   - Output: **Index Coverage Matrix** — table: Query Location (file:line) | Table | Filter/Join/Sort Columns | Index Exists? (Y/N) | Index Name | Estimated Row Scan Without Index
   - Skeptic challenge surface: Scrutineer can challenge "Index Exists: Y" by checking whether the index column order matches the query's column order (leftmost prefix rule), or question estimated row counts.

3. **Schema Change Impact Analysis** — For each schema modification (column add/drop/rename/retype, constraint change), trace all code paths that read or write the affected columns and verify they are updated.
   - Output: **Schema Ripple Map** — table: Schema Change | Affected Table.Column | Code References (file:line) | Updated? (Y/N) | Breaking? (Y/N)
   - Skeptic challenge surface: Scrutineer can challenge completeness — did the analysis find all code references, including ORM model definitions, raw queries, and seed files?

4. **Transaction Boundary Analysis** — Identify operations in changed code that should be atomic (multiple related writes) and verify they are wrapped in database transactions with appropriate isolation levels.
   - Output: **Atomicity Audit Table** — table: Operation Group | Write Operations | Transaction Wrapped? (Y/N) | Isolation Level | Partial Failure Consequence
   - Skeptic challenge surface: Scrutineer can challenge "Transaction Wrapped: Y" — is the transaction boundary wide enough to cover all related writes? Is the isolation level sufficient to prevent phantom reads?

---

### 8. The Chandler — Dependency & Supply Chain

**METHODOLOGY MANIFEST: Chandler**

Methodologies:

1. **Supply Chain Risk Scoring** — For each new or updated dependency, score it across multiple risk dimensions using a weighted evaluation.
   - Output: **Supply Chain Risk Matrix** — table: Package | Version | Weekly Downloads | Last Publish | Maintainer Count | Open Issues/PRs Ratio | Risk Score (0-10) | Verdict (Accept/Flag/Reject)
   - Skeptic challenge surface: Scrutineer can challenge the weighting — why is maintainer count weighted higher than download volume? Can also challenge individual scores if the underlying data is stale.

2. **License Compatibility Analysis** — Map each new dependency's license against the project's license and all existing dependency licenses, identifying conflicts using a compatibility matrix.
   - Output: **License Compatibility Matrix** — table: Package | License | Compatible with Project License? (Y/N) | Conflicts With | Copyleft Obligations | Action Required
   - Skeptic challenge surface: Scrutineer can challenge compatibility verdicts — some licenses have exceptions or dual-licensing options. Can also question whether transitive dependencies were included.

3. **CVE & Advisory Audit** — Run available audit commands (`npm audit`, `composer audit`, etc.) and cross-reference results with the National Vulnerability Database for each dependency in the changed lockfile.
   - Output: **Vulnerability Audit Log** — table: Package | Version | CVE ID | Severity (CVSS) | Fixed In Version | Exploitable in PR Context? | Remediation
   - Skeptic challenge surface: Scrutineer can challenge "Exploitable in PR Context: N" — demand the specific code path analysis that proves the vulnerable function is never called. Cross-reference with Sentinel.

4. **Dependency Graph Diff** — Compare the before/after dependency trees to identify all transitive dependencies added, removed, or changed, not just direct dependencies.
   - Output: **Dependency Tree Delta** — table: Package | Direct/Transitive | Change Type (Added/Removed/Updated) | Old Version | New Version | Transitive Depth | Notable (CVE/Deprecated/Unmaintained)
   - Skeptic challenge surface: Scrutineer can challenge completeness — was the full transitive tree analyzed, or only direct dependencies? Can question whether "Notable: No" entries were actually checked.

---

### 9. The Illuminator — Code Quality & Readability

**METHODOLOGY MANIFEST: Illuminator**

Methodologies:

1. **Cognitive Complexity Scoring** — Apply the SonarSource Cognitive Complexity metric to each changed function, counting nesting depth increments, breaks in linear flow, and boolean operator sequences.
   - Output: **Cognitive Complexity Scorecard** — table: Function (file:line) | Complexity Score | Threshold (15) | Over Threshold? | Primary Contributors (nesting/branching/boolean chains)
   - Skeptic challenge surface: Scrutineer can challenge the score calculation (was a specific nesting increment counted correctly?) or whether the threshold is appropriate for the function's domain.

2. **Naming Heuristic Evaluation** — Assess every new or renamed identifier against Feathers' naming heuristics: length proportional to scope, specificity proportional to usage breadth, verb-noun for functions, noun-phrase for variables.
   - Output: **Naming Assessment Table** — table: Identifier | Kind (var/fn/class/const) | Scope | Current Name | Issue (ambiguous/abbreviated/misleading/none) | Suggested Alternative
   - Skeptic challenge surface: Scrutineer can challenge suggestions — is the proposed name actually clearer in the domain context? Some abbreviations are conventional (e.g., `ctx`, `req`, `i`).

3. **Consistency Deviation Analysis** — Sample the surrounding codebase for established conventions (naming style, file organization, comment patterns, error message formats), then flag deviations in the PR.
   - Output: **Consistency Deviation Log** — table: Convention Observed | Evidence (3+ examples in codebase) | PR Deviation (file:line) | Severity (Style Break/Minor Drift/Acceptable Variation)
   - Skeptic challenge surface: Scrutineer can challenge whether the "convention" is actually consistent in the codebase (maybe there are already two competing conventions) or whether the deviation is intentional improvement.

4. **Code Duplication Detection** — Within the PR diff, identify duplicated or near-duplicated code blocks (3+ similar lines or structurally identical logic with different names).
   - Output: **Duplication Register** — table: Block A (file:line range) | Block B (file:line range) | Similarity (exact/structural/near) | Extractable? (Y/N) | Suggested Abstraction
   - Skeptic challenge surface: Scrutineer can challenge extraction suggestions — is the duplication truly problematic, or would premature abstraction be worse? Are the blocks likely to diverge?

---

### 10. The Scrutineer — Meta-Review (Skeptic)

**METHODOLOGY MANIFEST: Scrutineer**

Methodologies:

1. **Evidence Demand Protocol** — For every Critical/High finding across all 9 reports, demand the complete evidence chain: claim → code reference → exploitation/impact scenario → severity justification. Findings without complete chains are downgraded or rejected.
   - Output: **Evidence Chain Audit** — table: Finding ID | Agent | Claim | Code Ref Present? | Impact Demonstrated? | Severity Justified? | Verdict (Validated/Downgraded/Rejected) | Reason
   - Challenge mechanism: This IS the skeptic's primary challenge tool. Self-validation: the Forge Master can verify that every Critical/High finding was processed through this protocol.

2. **Severity Calibration via Cross-Report Normalization** — Compare severity ratings across all 9 agents to detect inflation (agent rates everything High) or deflation (agent rates genuine issues as Low). Normalize against a shared rubric: Critical = exploitable in production, High = causes incorrect behavior, Medium = degrades quality, Low = improvement opportunity, Info = observation.
   - Output: **Severity Calibration Matrix** — table: Agent | Findings Count | Critical% | High% | Medium% | Low% | Distribution Assessment (Inflated/Deflated/Calibrated) | Adjustments Made
   - Challenge mechanism: Applies statistical lens to individual agent tendencies. Agents producing >50% High/Critical findings without matching evidence density are flagged for inflation.

3. **Coverage Completeness Verification** — Verify that every changed file in the PR appears in at least one agent's report, and that every agent's domain was actually exercised (or explicitly marked N/A with justification).
   - Output: **File-Agent Coverage Grid** — matrix: rows = changed files, columns = 9 agents, cells = Reviewed/N-A/Missing. Bottom row: per-agent domain exercised? (Y/N/N-A with reason)
   - Challenge mechanism: Missing cells represent blind spots. If a file touches multiple domains (e.g., a controller with SQL and auth logic), it should appear in multiple agents' reports.

4. **Cross-Cutting Concern Synthesis** — Identify issues that span two or more agents' domains but were not flagged by any single agent because each saw only their piece. Apply Rasmussen's risk framework: look for latent conditions where individually-acceptable decisions combine into systemic risk.
   - Output: **Cross-Cutting Issue Register** — table: Issue ID | Domains Spanned | Agent A's View | Agent B's View | Combined Risk | Why Each Agent Missed the Whole | Severity
   - Challenge mechanism: This is the Scrutineer's unique value — the only agent who sees all 9 reports together. The Forge Master validates by checking whether any multi-domain file went without a cross-cutting assessment.

---

## Output Artifact Uniqueness Verification

No two agents produce artifacts with the same structure or purpose:

| Agent         | Primary Artifact Type                                    | Unique Characteristic                                        |
| ------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| Sentinel      | Threat matrices, taint flows, attack trees               | Security-specific: exploitability, CVSS vectors              |
| Lexicant      | Diagnostic hits, import graphs, type traces              | Tool-output-driven: linter/compiler diagnostics              |
| Arbiter       | Traceability matrices, gap registers                     | Requirement-to-code mapping: bidirectional traces            |
| Structuralist | SOLID scorecards, coupling profiles, error maps          | Architecture-level: principle adherence, module metrics      |
| Swiftblade    | Complexity profiles, query-loop registers                | Runtime-focused: Big-O, resource lifecycles                  |
| Prover        | Coverage deltas, mutation registers, partition tables    | Test-centric: assertion quality, input space coverage        |
| Delver        | Reversibility tables, index matrices, schema ripple maps | Database-specific: migration paths, schema impacts           |
| Chandler      | Risk scores, license matrices, dependency tree diffs     | Package-level: supply chain, transitive analysis             |
| Illuminator   | Complexity scores, naming tables, consistency logs       | Human-readability: cognitive load, convention adherence      |
| Scrutineer    | Evidence chains, calibration matrices, coverage grids    | Meta-level: cross-report synthesis, validation of validators |

**Overlap Check:** No two agents produce the same output type. Closest adjacencies:

- Sentinel (CVSS scores) vs. Chandler (CVE severity): Sentinel scores vulnerabilities in _written code_; Chandler scores vulnerabilities in _imported packages_. Different input domains, same scoring system is acceptable.
- Swiftblade (query detection) vs. Delver (index coverage): Swiftblade detects N+1 patterns in _application code loops_; Delver checks _schema-level index support_ for queries. Different analysis layers as defined in the architect's boundary tests.
- Structuralist (error handling) vs. Lexicant (type safety): Structuralist evaluates error _propagation design_; Lexicant verifies error types _resolve correctly_. Different abstraction levels.

---

## Methodology Count Summary

| Agent         | Count | Methodologies                                                                                                                                      |
| ------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sentinel      | 4     | STRIDE Threat Modeling, Taint Analysis, Attack Tree Construction, CVSS Vector Scoring                                                              |
| Lexicant      | 4     | Static Analysis Rule Audit, Import Dependency Graph Analysis, Type Flow Tracing, Dead Code Reachability Analysis                                   |
| Arbiter       | 4     | Requirements Traceability Matrix, Gap Analysis, Scope Boundary Audit, Behavioral Contract Verification                                             |
| Structuralist | 4     | SOLID Compliance Audit, Coupling & Cohesion Measurement, Error Propagation Path Analysis, Design Pattern Conformance Check                         |
| Swiftblade    | 4     | Asymptotic Complexity Analysis, N+1 Query Detection via Call-Graph Trace, Resource Lifecycle Audit, Caching Strategy Evaluation                    |
| Prover        | 4     | Coverage Delta Tracking, Mutation Testing (Conceptual), Equivalence Partitioning & Boundary Analysis, Test Smell Detection                         |
| Delver        | 4     | Migration Reversibility Audit, Index-Query Coverage Analysis, Schema Change Impact Analysis, Transaction Boundary Analysis                         |
| Chandler      | 4     | Supply Chain Risk Scoring, License Compatibility Analysis, CVE & Advisory Audit, Dependency Graph Diff                                             |
| Illuminator   | 4     | Cognitive Complexity Scoring, Naming Heuristic Evaluation, Consistency Deviation Analysis, Code Duplication Detection                              |
| Scrutineer    | 4     | Evidence Demand Protocol, Severity Calibration via Cross-Report Normalization, Coverage Completeness Verification, Cross-Cutting Concern Synthesis |

**Total: 40 methodologies across 10 agents. Every methodology is a named, real technique. Every output is a structured artifact. Every artifact has an explicit skeptic challenge surface.**
