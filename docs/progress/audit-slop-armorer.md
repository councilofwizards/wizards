---
feature: "audit-slop"
team: "conclave-forge"
agent: "armorer"
phase: "arm"
status: "complete"
last_action: "Manifest approved by Forge Auditor — 2 non-blocking notes forwarded to Scribe"
updated: "2026-04-04T17:43:00Z"
---

# METHODOLOGY MANIFEST: Slop Code Taxonomy — Codebase-Level AI Code Quality Audit

Armorer: Vex Ironbind, The Equipper Blueprint source: `docs/progress/audit-slop-architect.md`

---

## METHODOLOGY MANIFEST: Structural Assessor

**Concern**: Architectural coherence — inconsistent patterns, duplication, coupling, over/under-engineering, config
drift. 12 signals.

**Methodologies**:

1. **Dependency Graph Analysis** — Map module-level afferent and efferent coupling to identify unstable,
   tightly-coupled, or orphaned components.
   - Output: **Coupling Adjacency Matrix** — tabular matrix of module→module dependencies with instability index
     (Ce/(Ca+Ce)) per module.
   - Skeptic challenge surface: Any module flagged as "unstable" — skeptic can demand the specific import chains that
     justify the instability score.

2. **Code Clone Detection (Taxonomy Types 1–4)** — Identify duplicated logic across the codebase using the established
   clone taxonomy (exact, renamed, gapped, semantic).
   - Output: **Duplication Registry** — table of clone pairs with clone type, source locations (file:line), token count,
     and estimated extraction feasibility.
   - Skeptic challenge surface: Any Type 3/4 (gapped/semantic) clone — skeptic can question whether the similarity is
     genuine or coincidental, and whether extraction is actually warranted.

3. **Heuristic Evaluation (Architectural Pattern Conformance)** — Evaluate codebase against its own declared or inferred
   architectural patterns (MVC, layered, hexagonal, etc.) using Nielsen-style severity ratings.
   - Output: **Pattern Consistency Scorecard** — checklist of pattern rules with pass/fail/partial per module, severity
     rating (cosmetic → catastrophic), and violation evidence.
   - Skeptic challenge surface: Any "catastrophic" or "major" severity rating — skeptic can challenge whether the
     deviation actually harms maintainability or is an acceptable variant.

---

## METHODOLOGY MANIFEST: Security Assessor

**Concern**: Exploitable vulnerabilities in first-party code — missing validation, hardcoded credentials, injection
vectors, insecure defaults, deprecated APIs. 10 signals.

**Methodologies**:

1. **STRIDE Threat Modeling** — Systematically enumerate threats per component using Spoofing, Tampering, Repudiation,
   Information Disclosure, Denial of Service, Elevation of Privilege categories.
   - Output: **STRIDE Threat Matrix** — table of components × threat categories, with identified threats, affected
     signal IDs, and risk rating per cell.
   - Skeptic challenge surface: Any high-risk cell — skeptic can demand proof of exploitability (concrete attack
     scenario, not theoretical).

2. **Taint Analysis** — Trace data flow from untrusted sources (user input, external APIs, environment variables) to
   sensitive sinks (queries, file operations, rendered output) to identify unsanitized paths.
   - Output: **Taint Propagation Map** — directed graph of source→transform→sink chains with sanitization status
     (present/absent/insufficient) at each transform step.
   - Skeptic challenge surface: Any "absent sanitization" finding — skeptic can challenge whether the source is actually
     untrusted or the sink is actually sensitive in context.

3. **CWE Weakness Enumeration** — Classify each finding against the Common Weakness Enumeration taxonomy to ensure
   precise, standardized categorization and avoid vague "security issue" labels.
   - Output: **Weakness Catalog** — table of findings with CWE ID, description, affected file:line, CVSS-inspired
     severity score, and remediation class (input validation, output encoding, access control, etc.).
   - Skeptic challenge surface: Any CWE classification — skeptic can challenge whether the correct CWE was assigned and
     whether the severity score matches actual exploitability.

---

## METHODOLOGY MANIFEST: Supply Chain Assessor

**Concern**: Third-party dependency trust — hallucinated packages, slopsquatting, dependency overuse, missing SBOM,
license risk. 7 signals.

**Methodologies**:

1. **Software Bill of Materials (SBOM) Generation** — Enumerate all direct and transitive dependencies with version,
   source registry, and resolved integrity hash.
   - Output: **Dependency Inventory** — table of every dependency with name, version, registry URL, integrity hash
     (present/absent), direct vs. transitive flag, and last-published date.
   - Skeptic challenge surface: Any dependency flagged as "hallucinated" or "unverifiable" — skeptic can demand the
     specific registry lookup that failed and whether an alternative spelling exists.

2. **Provenance Verification** — Verify each dependency's publication history, maintainer identity, and source
   repository linkage to detect slopsquatting, typosquatting, and hijacked packages.
   - Output: **Package Provenance Ledger** — table of dependencies with maintainer history (stable/changed), source repo
     link (present/absent/mismatched), publication age, download count, and provenance risk tier
     (low/medium/high/critical).
   - Skeptic challenge surface: Any "high" or "critical" provenance risk — skeptic can challenge whether the risk
     indicators (new maintainer, no source repo) represent actual malice vs. legitimate package lifecycle events.

3. **License Compatibility Analysis** — Map the license of every dependency against the project's declared license to
   identify incompatibilities, viral obligations, and attribution gaps.
   - Output: **License Compatibility Matrix** — table of dependencies × project license with compatibility verdict
     (compatible/incompatible/conditional), obligation type (attribution/copyleft/none), and compliance status.
   - Skeptic challenge surface: Any "incompatible" verdict — skeptic can challenge whether the dependency is actually
     distributed (vs. dev-only) and whether the specific license clause applies.

---

## METHODOLOGY MANIFEST: Concurrency Assessor

**Concern**: Parallel execution correctness — race conditions, misused synchronization primitives, shared state
mutations, false atomicity assumptions. 8 signals.

**Methodologies**:

1. **Happens-Before Analysis** — Trace ordering constraints between concurrent operations to identify unsynchronized
   access to shared resources.
   - Output: **Execution Order Graph** — directed acyclic graph of concurrent operations with happens-before edges,
     annotated with synchronization primitives (or their absence) at each ordering point. Tabular summary of unordered
     access pairs.
   - Skeptic challenge surface: Any identified race condition — skeptic can demand proof that the two operations
     actually execute concurrently in production (not just theoretically concurrent).

2. **State Machine Analysis** — Model shared mutable state as finite state machines and verify that all transitions are
   guarded by appropriate synchronization.
   - Output: **Shared State Mutation Log** — table of shared state variables with their state machine (states +
     transitions), guard status (locked/unlocked/partially-guarded), and violation evidence (file:line of unguarded
     mutation).
   - Skeptic challenge surface: Any "unguarded mutation" — skeptic can challenge whether the state is truly shared (vs.
     thread-local) or whether a higher-level invariant makes the guard unnecessary.

3. **Fault Tree Analysis (Concurrency Failures)** — Decompose potential concurrency failures (deadlock, livelock, data
   corruption) into contributing fault conditions using AND/OR trees.
   - Output: **Concurrency Fault Tree** — tree diagram per failure mode with contributing conditions, probability
     annotations (likely/possible/unlikely based on code evidence), and minimal cut sets.
   - Skeptic challenge surface: Any "likely" probability annotation — skeptic can demand the specific execution scenario
     and workload conditions that make the fault likely rather than merely possible.

---

## METHODOLOGY MANIFEST: Efficiency Assessor

**Concern**: Unnecessary code and assets — dead code, unused dependencies, uncompressed assets, heavy libraries for
trivial operations, commit bloat. 9 signals.

**Methodologies**:

1. **Dead Code Elimination Analysis** — Identify unreachable functions, unused exports, orphaned files, and
   commented-out code blocks through static reachability analysis from entry points.
   - Output: **Dead Code Registry** — table of unreachable items with type (function/file/export/comment block),
     location (file:line), last-referenced commit, and confidence level (definite/probable/possible).
   - Skeptic challenge surface: Any "definite" unreachable finding — skeptic can challenge whether dynamic dispatch,
     reflection, or runtime loading makes the code reachable via a path static analysis misses.

2. **Dependency Weight Analysis** — Measure the installed size, import cost, and utilization ratio of each dependency to
   identify heavy libraries used for trivial operations.
   - Output: **Dependency Weight Matrix** — table of dependencies with installed size (KB), number of imports in
     codebase, functions actually used vs. functions available (utilization ratio), and lighter alternative (if known).
   - Skeptic challenge surface: Any "replace with lighter alternative" recommendation — skeptic can challenge whether
     the alternative actually covers all used functionality and whether migration cost justifies the size savings.

3. **Asset Profiling** — Inventory all non-code assets (images, fonts, data files, compiled artifacts) by size,
   compression status, and reference count.
   - Output: **Asset Size Inventory** — table of assets with file path, size (raw and compressed), compression status
     (compressed/uncompressed/already-optimal), reference count in codebase, and savings estimate if compressed/removed.
   - Skeptic challenge surface: Any "unreferenced" asset — skeptic can challenge whether the asset is referenced
     dynamically (e.g., via computed paths, CMS, or build tool configuration).

---

## METHODOLOGY MANIFEST: Performance Assessor

**Concern**: Runtime execution quality — N+1 queries, missing caching, memory leaks, unbounded allocations,
accessibility failures affecting UX. 12 signals.

**Methodologies**:

1. **Query Plan Analysis (EXPLAIN-based)** — Analyze database query patterns for N+1 problems, missing indexes, full
   table scans, and unbounded result sets by tracing ORM calls to their generated SQL.
   - Output: **Query Performance Log** — table of query sites with file:line, generated SQL pattern, estimated row scan
     count, index usage (yes/no/partial), N+1 flag, and optimization recommendation.
   - Skeptic challenge surface: Any N+1 finding — skeptic can challenge whether the query actually executes in a loop at
     runtime (vs. appearing in a loop but short-circuited by caching or early return).

2. **Cache Effectiveness Analysis** — Identify cacheable operations that lack caching, cache invalidation gaps, and
   cache configurations that defeat their purpose (e.g., TTL of 0, cache-then-immediately-invalidate).
   - Output: **Cache Effectiveness Matrix** — table of cacheable operations with current cache status
     (cached/uncached/misconfigured), TTL, invalidation strategy, hit ratio estimate (if measurable), and severity of
     omission.
   - Skeptic challenge surface: Any "should be cached" finding — skeptic can challenge whether the data's volatility
     makes caching unsafe or whether the expected call frequency justifies caching overhead.

3. **WCAG Heuristic Evaluation (Accessibility)** — Evaluate UI-rendering code paths against WCAG 2.1 Level AA success
   criteria to identify accessibility failures that degrade UX for assistive technology users.
   - Output: **Accessibility Compliance Checklist** — table of WCAG criteria with pass/fail/not-applicable per UI
     component, failure evidence (file:line, rendered element), and severity (critical/major/minor per WCAG impact).
   - Skeptic challenge surface: Any "critical" accessibility failure — skeptic can challenge whether the component is
     actually user-facing (vs. admin-only or behind a feature flag) and whether the WCAG criterion was correctly
     applied.

---

## METHODOLOGY MANIFEST: Testing Assessor

**Concern**: Verification adequacy — happy-path-only tests, circular confidence, hallucinated fixtures, missing edge
cases, coverage gaps in AI-generated code. 8 signals.

**Methodologies**:

1. **Mutation Testing Analysis** — Evaluate test suite kill rate by identifying code locations where semantic mutations
   (operator changes, boundary shifts, return value inversions) would survive existing tests.
   - Output: **Mutation Survival Matrix** — table of mutation sites with file:line, mutation type, surviving/killed
     status, and the nearest test that should have caught it (if any).
   - Skeptic challenge surface: Any "survived" mutation — skeptic can challenge whether the mutation represents a
     meaningful behavioral change or an equivalent mutant that doesn't alter observable behavior.

2. **Equivalence Partitioning with Boundary Value Analysis** — Identify input partitions for each testable unit and
   verify that tests cover representative values from each partition plus boundary values.
   - Output: **Test Coverage Partition Map** — table of testable units with identified input partitions, boundary
     values, and coverage status (covered/uncovered) per partition-boundary combination.
   - Skeptic challenge surface: Any "uncovered partition" — skeptic can challenge whether the partition is reachable
     given upstream validation or whether it represents a genuine gap.

3. **Test Smell Detection** — Catalog anti-patterns in the test suite: hallucinated fixtures (assertions against
   nonexistent data), tautological tests (always pass), over-mocking (testing the mock, not the code), and
   assertion-free tests.
   - Output: **Test Smell Catalog** — table of test files with smell type, specific test name, evidence (the problematic
     assertion or mock), and confidence level (definite/probable).
   - Skeptic challenge surface: Any "definite" smell — skeptic can challenge whether the pattern serves a legitimate
     purpose (e.g., an assertion-free test that validates "no exception thrown" as its contract).

---

## METHODOLOGY MANIFEST: Governance Assessor

**Concern**: Organizational and compliance risk — PR review bottleneck, automation bias, comprehension debt, GPL
attribution gaps, shadow AI indicators, missing audit trails. 17 signals.

**Methodologies**:

1. **Process Metrics Analysis (Review Velocity)** — Extract PR review patterns from git history and CI metadata to
   quantify review bottlenecks, rubber-stamp rates, and automation bias.
   - Output: **Review Velocity Dashboard** — table of reviewers with PRs reviewed per week, median review time,
     approval-without-comment rate, lines-changed-per-review ratio, and bottleneck flag.
   - Skeptic challenge surface: Any "rubber-stamp" flag — skeptic can challenge whether the reviewer's domain expertise
     justifies quick approvals or whether the PRs were genuinely trivial.

2. **SPDX License Scanning** — Scan repository for license declarations, attribution notices, and SPDX identifiers to
   identify missing or incorrect compliance artifacts.
   - Output: **License Attribution Ledger** — table of files/components with detected license, required attribution
     (present/absent), SPDX identifier (valid/invalid/missing), and compliance gap description.
   - Skeptic challenge surface: Any "missing attribution" — skeptic can challenge whether the file is actually
     distributed, whether the license requires attribution for this use case, and whether attribution exists elsewhere
     (e.g., NOTICE file).

3. **Change Impact Analysis (Comprehension Debt)** — Measure the ratio of AI-generated code to human-reviewed code by
   analyzing commit patterns, PR sizes vs. review depth, and code ownership concentration.
   - Output: **Comprehension Debt Register** — table of modules with estimated AI-generation ratio, review depth score,
     ownership concentration (bus factor), and comprehension risk tier.
   - Skeptic challenge surface: Any "high comprehension risk" rating — skeptic can challenge the AI-generation detection
     heuristic and whether concentrated ownership is actually a risk (vs. deliberate specialization).

4. **Audit Trail Verification** — Check for the presence and completeness of audit trails: CI/CD logs, deployment
   records, access controls, and change authorization chains.
   - Output: **Governance Compliance Checklist** — checklist of required audit trail artifacts with presence (yes/no),
     completeness (complete/partial/empty), staleness, and gap description.
   - Skeptic challenge surface: Any "missing audit trail" — skeptic can challenge whether the trail exists in an
     external system not visible to the assessor (e.g., separate deployment platform logs).

---

## METHODOLOGY MANIFEST: Skeptic

**Concern**: Adversarial quality gate — challenges all findings for false positives, calibrates severities, surfaces
cross-cutting patterns, deduplicates across reports.

**Methodologies**:

1. **Hypothesis Elimination Matrix** — Treat each assessor finding as a hypothesis and systematically attempt to falsify
   it by seeking counter-evidence, alternative explanations, or mitigating context.
   - Output: **False Positive Elimination Matrix** — table of findings with original hypothesis, counter-evidence
     sought, counter-evidence found (yes/no), verdict (confirmed/downgraded/rejected), and reasoning.
   - Skeptic challenge surface: N/A (the Skeptic IS the challenger) — but the Lead can review any "confirmed" verdict to
     ensure the falsification attempt was genuine, not cursory.

2. **Cross-Impact Analysis** — Identify findings from different assessors that share root causes, compound each other's
   severity, or represent the same defect viewed from different angles.
   - Output: **Cross-Cutting Pattern Map** — table of finding clusters with member findings (by assessor + ID), shared
     root cause, compounded severity assessment, and deduplication verdict (keep all/merge/drop duplicate).
   - Skeptic challenge surface: N/A (Skeptic's own output) — Lead verifies that cross-cutting patterns were genuinely
     identified, not fabricated to inflate report importance.

3. **Severity Calibration (CVSS-inspired)** — Recalibrate every finding's severity using a consistent framework:
   exploitability/impact for security, blast radius/frequency for non-security, with explicit comparison to peer
   findings to ensure relative consistency.
   - Output: **Severity Calibration Table** — table of all findings with original severity (from assessor), calibrated
     severity, calibration rationale, and peer comparison (which findings are more/less severe and why).
   - Skeptic challenge surface: N/A (Skeptic's own output) — Lead verifies that calibration rationale is evidence-based
     and that severity ordering is internally consistent.

---

## Output Type Uniqueness Verification

No two agents produce the same output type:

| Agent        | Output Artifacts                                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------------------------- |
| Structural   | Coupling Adjacency Matrix, Duplication Registry, Pattern Consistency Scorecard                                      |
| Security     | STRIDE Threat Matrix, Taint Propagation Map, Weakness Catalog                                                       |
| Supply Chain | Dependency Inventory, Package Provenance Ledger, License Compatibility Matrix                                       |
| Concurrency  | Execution Order Graph, Shared State Mutation Log, Concurrency Fault Tree                                            |
| Efficiency   | Dead Code Registry, Dependency Weight Matrix, Asset Size Inventory                                                  |
| Performance  | Query Performance Log, Cache Effectiveness Matrix, Accessibility Compliance Checklist                               |
| Testing      | Mutation Survival Matrix, Test Coverage Partition Map, Test Smell Catalog                                           |
| Governance   | Review Velocity Dashboard, License Attribution Ledger, Comprehension Debt Register, Governance Compliance Checklist |
| Skeptic      | False Positive Elimination Matrix, Cross-Cutting Pattern Map, Severity Calibration Table                            |

**27 unique output types across 9 agents. Zero overlaps.**

## Methodology Count Verification

| Agent                 | Count | Within 2–4? |
| --------------------- | ----- | ----------- |
| Structural Assessor   | 3     | Yes         |
| Security Assessor     | 3     | Yes         |
| Supply Chain Assessor | 3     | Yes         |
| Concurrency Assessor  | 3     | Yes         |
| Efficiency Assessor   | 3     | Yes         |
| Performance Assessor  | 3     | Yes         |
| Testing Assessor      | 3     | Yes         |
| Governance Assessor   | 4     | Yes         |
| Skeptic               | 3     | Yes         |

## Auditor Note Compliance

The Architect's blueprint included an auditor note on the Performance Assessor: "ensure UX/accessibility signals are
explicitly covered in methodologies, not just performance." This is addressed by Methodology #3 on the Performance
Assessor: **WCAG Heuristic Evaluation (Accessibility)**, which produces a dedicated Accessibility Compliance Checklist
covering WCAG 2.1 Level AA criteria for UI-rendering code paths.

## Progress Notes

- [17:43] Task claimed — reading architect blueprint
- [17:44] Methodology selection in progress — all 9 agents
- [17:45] Manifest drafted — sending to Forge Auditor for review
- [17:46] Forge Auditor: APPROVED. Two non-blocking notes for Scribe:
  1. Supply Chain ↔ Governance license boundary: Scribe should add a "YOUR LICENSE SCOPE" note to both agents' spawn
     prompts to prevent lane drift.
  2. WCAG on non-UI codebases: Performance Assessor prompt should instruct "Not applicable — no UI rendering code paths
     detected" rather than silent skip or fabrication.
