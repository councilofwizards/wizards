---
type: architect-blueprint
skill: review-pr
status: draft
created: 2026-03-29
author: kael-draftmark
---

# TEAM BLUEPRINT: The Tribunal — PR Code Review Team

**Mission:** Review pull-requests

**Classification:** Engineering — agents analyze application code, run static analysis scripts, evaluate test coverage, inspect security vulnerabilities, and assess architecture. Every agent's mandate is rooted in code evaluation.

---

## Phase Decomposition

| Phase | Name         | Agent(s)                                                                                                 | Deliverable                  | Input                                   | Output                                                                                                       | Parallel?                          |
| ----- | ------------ | -------------------------------------------------------------------------------------------------------- | ---------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------------- |
| 1     | Intake       | Lead (orchestrator)                                                                                      | Review Dossier               | PR identifier (number, branch, or diff) | Structured context package: diff, affected files, related specs/stories, dependency graph                    | No — sequential, single actor      |
| 1.5   | Dossier Gate | Scrutineer (skeptic)                                                                                     | Dossier Validation           | Review Dossier                          | Validated dossier (or rejection with gaps to fill)                                                           | No — skeptic gate before fork      |
| 2     | Review       | Sentinel, Lexicant, Arbiter, Structuralist, Swiftblade, Prover, Delver, Chandler, Illuminator (9 agents) | 9 independent Review Reports | Review Dossier                          | 9 role-scoped review reports with findings, severity, evidence                                               | **Yes — all 9 in parallel (fork)** |
| 3     | Adjudication | Scrutineer (skeptic)                                                                                     | Adjudication Report          | 9 Review Reports                        | Validated findings with false-positive filtering, severity calibration, cross-cutting issue identification   | No — sequential, single actor      |
| 4     | Synthesis    | Lead (orchestrator)                                                                                      | Final Verdict                | Adjudication Report                     | Consolidated PR review with executive summary, categorized findings, and accept/revise/reject recommendation | No — sequential, single actor      |

---

## Agent Roster

| #   | Agent Name        | ID               | Concern (one sentence)                                                                                                   | Model  | Rationale                                                                                                                                |
| --- | ----------------- | ---------------- | ------------------------------------------------------------------------------------------------------------------------ | ------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | The Sentinel      | `sentinel`       | Identifies exploitable security vulnerabilities in changed code                                                          | Opus   | Adversarial reasoning required — must think like an attacker to find injection vectors, auth bypasses, and secrets exposure              |
| 2   | The Lexicant      | `lexicant`       | Verifies syntactic correctness, type safety, and import integrity through both manual review and inline script execution | Sonnet | Checklist-driven analysis with scripted validation — well-defined inputs, does not require deep reasoning                                |
| 3   | The Arbiter       | `arbiter`        | Determines whether the PR fulfills the stated requirements from specs and stories with no gaps or scope creep            | Opus   | Requirement-to-implementation mapping requires nuanced judgment about intent vs. literal compliance                                      |
| 4   | The Structuralist | `structuralist`  | Evaluates architectural decisions, design pattern adherence, error handling strategy, and concurrency safety             | Sonnet | Operates from a detailed checklist of structural concerns — patterns, SOLID, coupling, error propagation                                 |
| 5   | The Swiftblade    | `swiftblade`     | Identifies performance regressions including algorithmic complexity, N+1 queries, memory leaks, and caching misuse       | Sonnet | Pattern-matching against known anti-patterns — well-defined detection criteria                                                           |
| 6   | The Prover        | `prover`         | Assesses test adequacy: coverage of new code, edge case handling, assertion quality, and test isolation                  | Sonnet | Evaluates tests against a structured rubric — coverage metrics are largely mechanical                                                    |
| 7   | The Delver        | `delver`         | Reviews database migrations, schema changes, index coverage, query safety, and data integrity constraints                | Sonnet | Schema analysis follows well-defined safety rules (reversibility, index coverage, constraint validation)                                 |
| 8   | The Chandler      | `chandler`       | Evaluates new dependencies for supply chain risk, license compliance, version conflicts, and maintenance health          | Sonnet | Package registry lookups and license checks — mechanical evaluation against known criteria                                               |
| 9   | The Illuminator   | `illuminator`    | Assesses code readability, naming clarity, style consistency, and documentation adequacy of changed code                 | Sonnet | Surface-level quality assessment with clear heuristics — naming conventions, comment quality, clarity                                    |
| 10  | The Scrutineer    | `review-skeptic` | Challenges all 9 reports for false positives, severity inflation, missed cross-cutting issues, and completeness gaps     | Opus   | Adversarial meta-review requires the highest reasoning capability — must synthesize 9 independent analyses and find what they all missed |

**Agent Count Justification:** 10 spawned agents (9 reviewers + 1 skeptic). The user explicitly requested a "large family" covering "every angle." Each of the 9 review agents owns a distinct, non-overlapping concern verified by the boundary tests below. No agent could be removed without creating a coverage gap. No two agents could be merged without violating the one-concern rule. The Scrutineer earns their seat by being the only agent who sees all 9 reports together and can identify cross-cutting issues invisible to any single reviewer.

---

## Mandate Boundary Tests

Every pair of agents whose mandates could plausibly overlap is tested below. If the boundary can be stated in one sentence, the mandates are distinct.

| Agent A                      | Agent B                         | Boundary Statement                                                                                                                                                                                                                          |
| ---------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Sentinel (security)          | Lexicant (syntax)               | Sentinel asks "can an attacker exploit this code?" while Lexicant asks "does this code compile and type-check correctly?"                                                                                                                   |
| Sentinel (security)          | Chandler (dependencies)         | Sentinel reviews vulnerabilities in code _written in the PR_; Chandler owns CVE detection in _packages imported by the PR_ — Sentinel only assesses whether changed code exercises a Chandler-flagged vulnerable path                       |
| Sentinel (security)          | Structuralist (architecture)    | Sentinel identifies specific exploitable vectors (XSS, injection); Structuralist evaluates whether the overall error handling _design_ is sound                                                                                             |
| Sentinel (security)          | Structuralist (race conditions) | Sentinel owns race conditions that create _exploitable security vulnerabilities_ (TOCTOU, double-spend, auth timing); Structuralist owns race conditions that cause _correctness bugs_ (deadlocks, data corruption, thread-unsafe patterns) |
| Structuralist (architecture) | Illuminator (readability)       | Structuralist asks "is this the right structure?" (coupling, patterns, SOLID); Illuminator asks "is this structure readable?" (naming, clarity, comments)                                                                                   |
| Structuralist (architecture) | Swiftblade (performance)        | Structuralist evaluates structural correctness of design decisions; Swiftblade evaluates runtime efficiency of those decisions                                                                                                              |
| Swiftblade (performance)     | Delver (data)                   | Swiftblade owns N+1 query detection and all application-code performance; Delver owns schema-level concerns (missing indexes, migration reversibility, constraint integrity) — no overlap on query patterns                                 |
| Prover (tests)               | Arbiter (spec compliance)       | Prover asks "are the tests sufficient for the code that was written?"; Arbiter asks "does the code fulfill the requirements from specs/stories?"                                                                                            |
| Prover (tests)               | Lexicant (syntax)               | Prover evaluates whether tests _cover the right things_; Lexicant evaluates whether test code _compiles and is syntactically correct_                                                                                                       |
| Arbiter (spec compliance)    | Illuminator (readability)       | Arbiter checks _what_ was built against _what was required_; Illuminator checks _how_ it reads to a human reviewer                                                                                                                          |
| Chandler (dependencies)      | Delver (data)                   | Chandler reviews third-party package additions; Delver reviews first-party database schema changes                                                                                                                                          |

---

## Deliverable Chain

```
[PR identifier]
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Phase 1: INTAKE (Lead)                              │
│ Input:  PR number, branch name, or raw diff         │
│ Transform: Gather diff, identify affected files,    │
│   locate related specs/stories, map dependency graph│
│ Output: Review Dossier                              │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Phase 1.5: DOSSIER GATE (Scrutineer — skeptic)      │
│ Input:  Review Dossier                              │
│ Transform: Validate dossier completeness — are all  │
│   changed files listed? specs/stories located? dep  │
│   graph coherent? If gaps found, reject with list   │
│   of missing items for Lead to fill before fork.    │
│ Output: Validated Dossier (or rejection)            │
│ Gate: Scrutineer must APPROVE before fork proceeds  │
└─────────────────────────────────────────────────────┘
    │
    ▼ (Validated Dossier distributed to all 9 agents)
┌─────────────────────────────────────────────────────┐
│ Phase 2: REVIEW (9 agents in parallel — fork-join)  │
│                                                     │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│ │ Sentinel │ │ Lexicant │ │ Arbiter  │             │
│ └──────────┘ └──────────┘ └──────────┘             │
│ ┌──────────────┐ ┌───────────┐ ┌────────┐          │
│ │Structuralist │ │ Swiftblade│ │ Prover │          │
│ └──────────────┘ └───────────┘ └────────┘          │
│ ┌────────┐ ┌──────────┐ ┌─────────────┐            │
│ │ Delver │ │ Chandler │ │ Illuminator │            │
│ └────────┘ └──────────┘ └─────────────┘            │
│                                                     │
│ Input:  Review Dossier (same for all)               │
│ Transform: Each agent analyzes diff through their   │
│   specific lens, using their checklist & methods    │
│ Output: 9 independent Review Reports                │
│ Gate: ALL 9 must complete before advancing (join)   │
└─────────────────────────────────────────────────────┘
    │
    ▼ (All 9 Review Reports)
┌─────────────────────────────────────────────────────┐
│ Phase 3: ADJUDICATION (Scrutineer — skeptic)        │
│ Input:  9 Review Reports                            │
│ Transform: Challenge each finding for evidence,     │
│   filter false positives, calibrate severities,     │
│   identify cross-cutting issues missed by all 9     │
│ Output: Adjudication Report                         │
│ Gate: Scrutineer must explicitly approve the         │
│   consolidated findings as complete and accurate    │
└─────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────┐
│ Phase 4: SYNTHESIS (Lead)                           │
│ Input:  Adjudication Report                         │
│ Transform: Consolidate into executive summary,      │
│   categorize by severity and domain, render final   │
│   verdict with actionable recommendations           │
│ Output: Final Verdict (the deliverable)             │
└─────────────────────────────────────────────────────┘
```

**Chain Validation:** Review Dossier (Phase 1 output) → Phase 1.5 input ✓ | Validated Dossier (Phase 1.5 output) → Phase 2 input ✓ | 9 Review Reports (Phase 2 output) → Phase 3 input ✓ | Adjudication Report (Phase 3 output) → Phase 4 input ✓ | No gaps.

---

## Parallelization Analysis

### Within-Phase Parallelism (Phase 2)

All 9 review agents are **independent assessors** — they consume the same input (Review Dossier) and produce independent outputs (their Review Report). No agent's work depends on any other agent's output. This is a classic **fork-join** pattern:

- **Fork:** Lead spawns all 9 agents simultaneously after Phase 1.5 (dossier gate) approves
- **Join:** Lead waits for all 9 to complete before advancing to Phase 3

This is the primary performance optimization. Without parallelism, 9 sequential reviews would be prohibitively slow. With parallelism, Phase 2 completes in the time of the slowest single reviewer.

### Cross-Phase Sequencing (Strictly Sequential)

- **Phase 1 → Phase 1.5:** Scrutineer validates the dossier before the fork. A bad dossier would poison all 9 parallel reviews — this gate is cheap insurance (one Opus call) vs. the cost of re-running 9 agents on incomplete context.
- **Phase 1.5 → Phase 2:** Phase 2 agents need the _validated_ Review Dossier. Cannot start without skeptic approval.
- **Phase 2 → Phase 3:** Scrutineer needs all 9 reports to do cross-cutting analysis. Cannot start with partial reports — a partial adjudication could miss interactions between findings from different agents.
- **Phase 3 → Phase 4:** Lead needs the validated, calibrated findings. Cannot synthesize unvalidated reports.

### Model Cost Optimization

Of the 10 spawned agents, only 3 use Opus (Sentinel, Arbiter, Scrutineer). The remaining 7 use Sonnet. Since all Phase 2 agents run in parallel, cost scales with the number of agents but wall-clock time does not. The Opus agents in Phase 2 (Sentinel, Arbiter) may take longer than Sonnet agents, so Phase 2 completion time is bounded by the slowest Opus agent.

---

## Review Agent Detailed Mandates

Each Phase 2 agent operates from an explicit checklist. These are the specific items each agent examines — not vague categories, but concrete, actionable review criteria.

### 1. The Sentinel (Security Review)

**Checklist — OWASP Top 10 + Beyond:**

- **Injection:** SQL injection, NoSQL injection, OS command injection, LDAP injection, ORM injection, header injection
- **Cross-Site Scripting (XSS):** Reflected XSS, stored XSS, DOM-based XSS, template injection
- **Broken Authentication:** Hardcoded credentials, weak token generation, missing session invalidation, insecure password handling
- **Sensitive Data Exposure:** Secrets in code (API keys, tokens, passwords), PII logged or exposed, missing encryption at rest/transit
- **Broken Access Control:** Missing authorization checks, IDOR vulnerabilities, privilege escalation paths, CORS misconfiguration
- **Security Misconfiguration:** Debug mode enabled, default credentials, overly permissive headers, missing security headers
- **Insecure Deserialization:** Untrusted data deserialized without validation, prototype pollution
- **Insufficient Logging:** Security-relevant events not logged, sensitive data in logs
- **SSRF:** Server-side request forgery via user-controlled URLs
- **Exploitable Race Conditions:** TOCTOU vulnerabilities, double-spend scenarios, auth timing bypasses — race conditions that create _security-exploitable_ vectors (correctness-only race conditions belong to the Structuralist)
- **Cryptographic Weakness:** Weak algorithms, insufficient key lengths, predictable randomness

**Cross-Reference with Chandler:** If Chandler flags a dependency CVE, Sentinel assesses whether changed code in the PR exercises the vulnerable code path. Sentinel does NOT independently scan for dependency CVEs — that is Chandler's mandate.

**Method:** Manual code review of all changed files. For each finding, cite the exact file, line, and vulnerable code snippet. Classify severity as Critical/High/Medium/Low with CVSS-like rationale.

### 2. The Lexicant (Syntax & Verification)

**Checklist — Static Analysis + Scripted Validation:**

- **Import Integrity:** Missing imports, unused imports, circular imports, incorrect import paths
- **Type Safety:** `any` types in TypeScript, missing type annotations on public APIs, type assertion abuse, generic misuse
- **Syntax Errors:** Unclosed brackets, missing semicolons (where required), invalid syntax constructs
- **Dead Code:** Unreachable code paths, unused variables, unused function parameters, commented-out code
- **Null Safety:** Unguarded nullable access, missing null checks, optional chaining opportunities
- **Language Idioms:** Anti-patterns specific to the language (e.g., `==` vs `===` in JS, mutable default args in Python)
- **Compilation/Lint:** Run language-appropriate lint commands inline (e.g., `tsc --noEmit`, `eslint`, `mypy`, `phpstan`) and report results
- **API Misuse:** Incorrect method signatures, deprecated API usage, wrong argument types

**Method:** Two-pass approach: (1) Manual review against checklist, (2) Execute inline scripts (lint, type-check, compile) and report output. Flag any finding from either pass.

### 3. The Arbiter (Spec & Story Compliance)

**Checklist — Requirements Fulfillment:**

- **Story Coverage:** Each acceptance criterion in linked stories must map to changed code. Uncovered criteria = gap.
- **Spec Compliance:** Technical spec constraints (data models, API contracts, component boundaries) must be implemented as specified.
- **Scope Creep:** Changes not traceable to any story or spec requirement. Flag as potential scope creep.
- **Missing Edge Cases:** Edge cases mentioned in stories/specs but not handled in code.
- **Behavioral Contracts:** Does the code behave as the spec describes under normal, edge, and error conditions?
- **Non-Functional Requirements:** Performance targets, accessibility requirements, i18n requirements from specs.

**Method:** Cross-reference the PR diff against linked specs/stories. Build a traceability matrix: requirement → code location. Empty rows = gaps. Flag requirements with partial implementation. Report both covered and uncovered requirements.

### 4. The Structuralist (Architecture & Design)

**Checklist — Structural Integrity:**

- **SOLID Violations:** Single responsibility breaches, interface segregation issues, dependency inversion failures
- **Design Pattern Compliance:** Misapplied patterns, pattern violations in existing architecture, missing patterns where warranted
- **Coupling & Cohesion:** Inappropriate tight coupling, god classes/functions, feature envy, shotgun surgery
- **Error Handling Strategy:** Inconsistent error propagation, swallowed exceptions, missing error boundaries, error type hierarchy violations
- **Concurrency Correctness:** Race conditions that cause _correctness bugs_ — deadlocks, data corruption, thread-unsafe patterns, missing locks (exploitable security race conditions such as TOCTOU and double-spend belong to the Sentinel)
- **API Design:** Breaking changes, inconsistent naming, missing versioning, unclear contracts
- **Dependency Direction:** Circular dependencies, wrong-direction imports (e.g., domain importing infrastructure)
- **Layer Violations:** Business logic in controllers, UI logic in services, data access outside repositories

**Method:** Analyze the changed code in context of the broader architecture. Reference existing patterns in the codebase and flag deviations. Each finding must include the architectural principle violated and a concrete suggestion.

### 5. The Swiftblade (Performance)

**Checklist — Runtime Efficiency:**

- **Algorithmic Complexity:** O(n²) or worse in hot paths, unnecessary nested loops, inefficient search/sort
- **N+1 Queries:** Database queries inside loops, missing eager loading, redundant queries
- **Memory Leaks:** Unclosed resources, event listener accumulation, cache without eviction, growing collections
- **Caching Misuse:** Missing cache for repeated expensive operations, stale cache without invalidation strategy
- **Bundle Size:** Unnecessary large imports, tree-shaking blockers, missing code splitting
- **Rendering Performance:** Unnecessary re-renders (React), missing virtualization for large lists, layout thrashing
- **Network Efficiency:** Chatty APIs, missing pagination, over-fetching, missing compression
- **Blocking Operations:** Synchronous I/O in async context, long-running operations on main thread

**Method:** Trace execution paths through changed code. For each hot path, estimate complexity. Flag any pattern matching the checklist with specific file/line references and suggested alternatives.

### 6. The Prover (Test Adequacy)

**Checklist — Test Quality:**

- **Coverage of New Code:** Every new function, branch, and error path should have corresponding test(s)
- **Edge Case Testing:** Boundary values, empty inputs, null/undefined, maximum values, concurrent access
- **Assertion Quality:** Meaningful assertions (not just "doesn't throw"), specific value checks, error message validation
- **Test Isolation:** No shared mutable state between tests, proper setup/teardown, no order dependencies
- **Test Naming:** Descriptive names that document behavior (not `test1`, `testFoo`)
- **Mock Appropriateness:** Mocking at the right boundary, not over-mocking, mock behavior matches real behavior
- **Regression Coverage:** If this is a bug fix, is there a test that would have caught the original bug?
- **Integration Test Gaps:** Unit tests present but missing integration tests for cross-component flows

**Method:** Map each changed code path to its test(s). Identify untested paths. Evaluate each test against the quality rubric. Run test suite if available and report results. Produce a coverage gap matrix.

### 7. The Delver (Data & Migration Safety)

**Checklist — Database & Schema:**

- **Migration Reversibility:** Every migration must have a working rollback. Destructive operations (DROP, data transforms) flagged as HIGH.
- **Index Coverage:** New queries must have supporting indexes. Missing indexes on WHERE/JOIN columns flagged.
- **Schema Compatibility:** Breaking changes to existing tables (column renames, type changes, NOT NULL on existing columns)
- **Data Integrity:** Missing foreign key constraints, orphan-creating cascades, constraint violations on existing data
- **Schema-Level Query Safety:** Full table scans caused by absent indexes, missing LIMIT on unbounded queries (N+1 query detection in application code belongs to the Swiftblade)
- **Seed Data:** Test data that could leak to production, hardcoded IDs, environment-specific values
- **Transaction Safety:** Operations that should be atomic but aren't wrapped in transactions

**Method:** Examine all migration files, schema changes, and query modifications. For migrations, verify both up and down paths. For queries, analyze execution plan implications. Report with specific table/column references.

**Scope Note:** If the PR contains no database changes, migrations, or query modifications, The Delver reports "No findings — PR contains no data layer changes" and completes immediately.

### 8. The Chandler (Dependency & Supply Chain)

**Checklist — Package Safety:**

- **New Dependencies:** Any new package added — justify its necessity, check download counts, maintenance status, last publish date
- **Known Vulnerabilities:** Check for CVEs in new or updated dependencies (npm audit, composer audit, pip audit equivalent)
- **License Compliance:** Incompatible licenses (GPL in MIT project, etc.), missing license files
- **Version Pinning:** Unpinned versions, overly broad version ranges, missing lockfile updates
- **Dependency Size:** Bundle size impact of new dependencies, available lighter alternatives
- **Maintenance Health:** Abandoned packages (no commits in 12+ months), single-maintainer packages, low bus factor
- **Duplicate Dependencies:** Multiple packages solving the same problem, conflicting versions of the same package
- **Transitive Risk:** New transitive dependencies introduced, known-vulnerable transitive deps

**Method:** Diff lockfiles (package-lock.json, composer.lock, etc.) to identify added/removed/changed packages. For each new package, evaluate against the checklist. Run available audit commands inline. Report with specific package names and versions.

**Scope Note:** If the PR changes no dependency files, The Chandler reports "No findings — PR contains no dependency changes" and completes immediately.

### 9. The Illuminator (Code Quality & Readability)

**Checklist — Human Readability:**

- **Naming Clarity:** Variable/function/class names that are ambiguous, abbreviated, or misleading
- **Function Length:** Functions exceeding ~30 lines that should be decomposed (context-dependent)
- **Cognitive Complexity:** Deeply nested conditionals, complex boolean expressions, unclear control flow
- **Comment Quality:** Missing comments on non-obvious logic, outdated comments, comments that restate code
- **Consistency:** Style inconsistencies with surrounding code (naming conventions, formatting patterns, idioms)
- **Magic Values:** Hardcoded numbers/strings without named constants or explanation
- **Code Duplication:** Copy-pasted blocks within the PR that should be extracted
- **API Documentation:** Public APIs missing JSDoc/PHPDoc/docstrings, unclear parameter descriptions

**Method:** Read each changed file for human comprehension. Flag anything that made the reviewer pause or re-read. Each finding should include the original code and a suggested improvement. Focus on changes that _reduce_ readability, not pre-existing issues.

---

## Output Templates

### Individual Review Report (each Phase 2 agent produces one)

```markdown
# [Agent Name] Review Report

**PR:** [identifier]
**Reviewer:** [agent name]
**Domain:** [one-word domain]
**Findings:** [count]
**Severity Distribution:** [Critical: N, High: N, Medium: N, Low: N, Info: N]

## Findings

### [F-001] [Short title]

- **Severity:** Critical | High | Medium | Low | Info
- **File:** `path/to/file.ext:line`
- **Code:**
```

[relevant code snippet]

```
- **Issue:** [What is wrong, with evidence]
- **Recommendation:** [Specific fix or improvement]
- **References:** [OWASP ID, pattern name, rule link, etc.]

### [F-002] ...

## Domain Summary
[2-3 sentence summary of overall health in this domain]

## No-Finding Domains
[If the PR doesn't touch this agent's domain, state explicitly: "PR contains no changes in [domain]. No findings."]
```

### Adjudication Report (Scrutineer produces this)

```markdown
# Adjudication Report

**PR:** [identifier]
**Reports Reviewed:** 9
**Findings Submitted:** [total across all reports]
**Findings Validated:** [count after filtering]
**False Positives Removed:** [count]
**Severity Adjustments:** [count]
**Cross-Cutting Issues Added:** [count]

## False Positives Identified

| Original Finding | Agent | Reason for Rejection |
| ---------------- | ----- | -------------------- |

## Severity Adjustments

| Finding | Agent | Original | Adjusted | Rationale |
| ------- | ----- | -------- | -------- | --------- |

## Cross-Cutting Issues

[Issues that span multiple agents' domains but were missed by all — e.g., a security issue that is also a performance issue, or an architecture violation that causes a test gap]

### [X-001] [Title]

- **Spans:** [Agent A domain] + [Agent B domain]
- **Issue:** [description]
- **Why Missed:** [each agent saw their piece but not the whole]

## Completeness Assessment

- [ ] All 9 domains reviewed
- [ ] Every Critical/High finding has evidence (file + line + snippet)
- [ ] No contradictions between agent reports
- [ ] Scope coverage: all changed files appear in at least one report

## Verdict

**VALIDATED** — findings are complete, evidence-backed, and correctly severity-rated.
```

### Final Verdict (Lead produces this)

```markdown
# PR Review: Final Verdict

**PR:** [identifier]
**Date:** [date]
**Recommendation:** APPROVE | REVISE | REJECT

## Executive Summary

[3-5 sentences: what the PR does, what the review found, and why the recommendation]

## Findings by Severity

### Critical ([count])

[Findings that MUST be fixed before merge — security vulnerabilities, data loss risks, breaking changes]

### High ([count])

[Findings that SHOULD be fixed before merge — significant bugs, performance regressions, missing tests for critical paths]

### Medium ([count])

[Findings that should be addressed but don't block merge — code quality, minor performance, style inconsistencies]

### Low ([count])

[Suggestions for improvement — readability, naming, minor refactoring opportunities]

### Info ([count])

[Observations — no action required, but noted for awareness]

## Coverage Matrix

| Domain            | Findings | Critical | High | Medium | Low | Info |
| ----------------- | -------- | -------- | ---- | ------ | --- | ---- |
| Security          |          |          |      |        |     |      |
| Syntax & Types    |          |          |      |        |     |      |
| Spec Compliance   |          |          |      |        |     |      |
| Architecture      |          |          |      |        |     |      |
| Performance       |          |          |      |        |     |      |
| Test Adequacy     |          |          |      |        |     |      |
| Data & Migrations |          |          |      |        |     |      |
| Dependencies      |          |          |      |        |     |      |
| Code Quality      |          |          |      |        |     |      |
| **Cross-Cutting** |          |          |      |        |     |      |

## Detailed Findings

[Full findings organized by severity, each with file/line/snippet/recommendation — pulled from adjudicated reports]

## Recommendation Rationale

[Why APPROVE/REVISE/REJECT based on the severity distribution and nature of findings]
```

---

## Design Rationale

### Why 4 Phases + Dossier Gate

1. **Intake** is necessary to gather context — review agents need more than raw diff (specs, stories, dependency graph). Without this, each agent would redundantly gather context.
2. **Dossier Gate (Phase 1.5)** validates the dossier before the fork. A bad dossier would poison all 9 parallel reviews simultaneously — this is the highest-leverage skeptic gate in the pipeline. One Opus call here prevents potentially re-running 9 agents on incomplete context.
3. **Review** is the core work — 9 parallel analyses of the same input from 9 distinct angles.
4. **Adjudication** is the post-review skeptic gate — filters false positives, calibrates severity, catches cross-cutting issues no single agent can see.
5. **Synthesis** produces the user-facing deliverable — a consolidated report, not 9 separate ones. The user asked for "a high-level summary at the end."

The Scrutineer gates twice (Phase 1.5 and Phase 3) — different concerns at each: completeness of _input_ vs. quality of _output_. This dual-gate pattern is justified by the fan-out cost: 9 parallel agents means errors in the dossier are amplified 9x.

### Why 10 Agents (9 Reviewers + 1 Skeptic)

The user explicitly requested "a large family of agents" covering "every angle." Each of the 9 review agents owns a concern that:

1. Cannot be covered by any other agent (mandate boundary test passes for all pairs)
2. Has a concrete, enumerable checklist (not vague "look for problems")
3. Produces findings that are independently actionable

The 10th agent (Scrutineer) is non-negotiable per Conclave design principles — every team has exactly one skeptic.

**Agents NOT included and why:**

- **Accessibility/UX Agent:** Too narrow — only applies to frontend PRs with UI changes. The Structuralist can note accessibility concerns as an architectural consideration when relevant, without a dedicated agent that would produce empty reports on most PRs.
- **Documentation Agent (separate from Illuminator):** Would overlap with Illuminator's comment/docstring mandate and Arbiter's spec compliance mandate. Not enough unique concern to justify a seat.
- **Internationalization Agent:** Too specialized — would produce empty reports on most PRs. Can be a Sentinel sub-concern (user-facing strings) or Arbiter sub-concern (i18n requirements in spec).

### Why Hub-and-Spoke with Fork-Join

The user asked for agents that "can mostly run in parallel." The PR review domain is naturally parallelizable — each angle is an independent analysis of the same input. Hub-and-spoke with fork-join is the optimal pattern because:

- **All reviewers consume identical input** (Review Dossier) — no inter-reviewer dependencies
- **All reviewers produce independent output** (their report) — no write conflicts
- **The skeptic needs all reports together** — fork-join provides a clean synchronization point
- **Wall-clock time = time of slowest single reviewer**, not sum of all reviewers

### Alternatives Considered and Rejected

1. **Sequential pipeline (refine-code pattern):** Each agent reviews after the previous one. Rejected: unnecessarily slow for independent analyses, and later agents would be biased by earlier findings.
2. **Two-phase (skip intake):** Each agent gathers its own context. Rejected: 9 agents redundantly reading specs/stories/deps wastes tokens and time.
3. **Two skeptics (build-implementation pattern):** One skeptic for security, one for everything else. Rejected: a single Opus skeptic can handle the cross-cutting synthesis, and two skeptics would create a coordination problem about which findings belong to which gate.
4. **Fewer, broader agents (e.g., "Code Quality" combining Lexicant + Illuminator + Structuralist):** Rejected: violates one-concern mandate. A combined agent would either rush through sub-concerns or produce an unfocused report. The user explicitly wanted depth per angle.

---

## Orchestration Notes for the Scribe

### Phase 1: Intake

The Lead (skill orchestrator) performs intake directly — no agent spawn needed. Steps:

1. Parse the PR identifier (number, branch, or diff path)
2. Fetch the diff (via `gh pr diff` or `git diff`)
3. Identify all changed files and their types (language, layer, purpose)
4. Locate related specs (`docs/specs/`), stories (`docs/roadmap/`), and any linked issues
5. Map the dependency graph of changed files (what imports what)
6. Package everything into the Review Dossier and write to `docs/progress/{pr}-dossier.md`

### Phase 1.5: Dossier Gate

Spawn the Scrutineer to validate the Review Dossier before forking. The Scrutineer checks:

- All changed files are listed and categorized
- Related specs/stories have been located (or confirmed absent)
- Dependency graph is coherent
- No obvious context gaps that would undermine parallel review

If the Scrutineer rejects, Lead fills the gaps and resubmits. Max 3 iterations before escalation to user. This gate is cheap (one Opus call) vs. re-running 9 agents on an incomplete dossier.

### Phase 2: Review (Fork)

Spawn all 9 review agents simultaneously using Agent tool with `team_name`. Each agent receives:

- The Review Dossier content (injected into prompt)
- Their specific checklist and methods (from their section above)
- Their output template
- Write target: `docs/progress/{pr}-{agent-id}.md`

**Critical:** No two agents write to the same file. Each writes ONLY to their role-scoped progress file.

### Phase 3: Adjudication

After all 9 agents complete (join point), spawn the Scrutineer with all 9 reports injected into their prompt. The Scrutineer writes to `docs/progress/{pr}-adjudication.md`.

### Phase 4: Synthesis

Lead reads the Adjudication Report and produces the Final Verdict at `docs/progress/{pr}-verdict.md`. This is the primary deliverable presented to the user.

### Write Safety

- Phase 2 agents: `docs/progress/{pr}-{agent-id}.md` (9 non-overlapping files)
- Phase 3 skeptic: `docs/progress/{pr}-adjudication.md`
- Phase 4 lead: `docs/progress/{pr}-verdict.md`
- No agent writes to shared files, specs, or source code. This is a read-only review skill.
