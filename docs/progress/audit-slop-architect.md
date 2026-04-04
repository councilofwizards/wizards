---
feature: "audit-slop"
team: "conclave-forge"
agent: "architect"
phase: "design"
status: "complete"
last_action: "Blueprint finalized — auditor approved, non-blocking notes addressed"
updated: "2026-04-04T17:38:00Z"
---

# TEAM BLUEPRINT: Slop Code Taxonomy — Codebase-Level AI Code Quality Audit

## Mission

**Audit slop.**

Detect and report AI-generated code quality problems across an entire codebase using the Slop Code Taxonomy's 9
categories and 83 signals.

**Scope boundary**: This team DETECTS and REPORTS. It does not remediate. Remediation is a separate mission — existing
skills (refine-code, build-implementation, squash-bugs) handle that. Mixing detection and remediation in one team
violates Principle 1 (one mission). The audit report is the deliverable; what happens after is the user's decision.

**Classification**: engineering — agents read, analyze, and instrument code. They don't write application code, but they
execute static analysis, query profiling, dependency audits, and test suite evaluation. Engineering classification is
the safe default.

## Existing Team Analysis

Before designing a new team, I evaluated whether existing teams could cover this mission:

| Existing Skill  | Coverage                                                                                   | Gap                                                                                                                                                                       |
| --------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| review-pr       | ~6/9 categories (security, architecture, performance, testing, dependencies, code quality) | Operates on PR diffs, not codebase-level. Missing: concurrency, bloat, governance, compliance. Cannot assess accumulated slop across files that weren't recently changed. |
| review-quality  | ~3/9 (security, performance, testing)                                                      | Mode-based, not comprehensive. No structural coherence, supply chain, concurrency, bloat, governance, or compliance coverage.                                             |
| harden-security | ~2/9 (security, partial supply chain)                                                      | Security-only scope. No coverage for 7 other categories.                                                                                                                  |
| refine-code     | ~2/9 (structural, partial bloat)                                                           | Refactoring-focused, not audit-focused. Writes code rather than producing findings reports.                                                                               |

**Verdict**: No existing team covers more than ~6/9 categories, and none operates at codebase-level (vs. PR-level or
feature-level). A dedicated team is warranted.

## Agent Consolidation Analysis

The taxonomy proposes 10 specialist agents + 1 conductor. I evaluated every possible merge:

### Merges Rejected

| Candidate Merge                  | Rejection Rationale                                                                                                                                                                                                                                                                                                                  |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Security + Supply Chain          | Both share root cause 2, but concerns are methodologically distinct. Security uses STRIDE/OWASP/taint analysis on first-party code. Supply Chain uses SBOM generation, provenance verification, and slopsquatting detection on third-party dependencies. review-pr keeps these separate (Sentinel vs. Chandler) for the same reason. |
| Bloat + Performance              | Both share root cause 4, but Bloat asks "what shouldn't be here?" (dead code, unused assets, heavy libraries) while Performance asks "does what's here run well?" (N+1, caching, memory leaks). Different detection methods, different remediation paths.                                                                            |
| Structural + Concurrency         | Structural is about design-time architecture decisions. Concurrency is about runtime correctness under parallelism. An over-engineered class hierarchy and a race condition require entirely different analytical methods.                                                                                                           |
| Testing as cross-cutting concern | Making 8 agents each check testing would dilute focus. A dedicated testing agent knows mutation analysis, equivalence partitioning, coverage gap detection, and circular-confidence identification. These are specialized skills, not checklists.                                                                                    |

### Merge Accepted

| Merge                                                | Rationale                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Human Bottleneck + Legal/Regulatory → **Governance** | Both address organizational risk rather than code-level defects. Human Bottleneck analyzes process signals (PR volume vs. review capacity, automation bias, rubber-stamp approvals, comprehension debt). Legal analyzes compliance signals (GPL attribution, audit trails, shadow AI, vibe compliance). A single "Governance" agent can cover both because: (1) they share an analytical mode — examining process artifacts and metadata rather than source code; (2) their signal counts are manageable together (8 + 9 = 17 signals); (3) separating them would produce two agents that both scan git logs, CI configs, and process metadata with overlapping tooling. |

### Final Count: 8 assessors + 1 skeptic = 9 agents

Down from 10 + 1. The single merge (Human Bottleneck + Legal → Governance) is justified. Every remaining agent owns a
concern no other agent covers.

## Phase Decomposition

This is a **fork-join** pattern (like review-pr), not a sequential pipeline. The 8 assessment concerns are independent —
they analyze the same codebase from different angles and produce independent reports. Sequential scanning would waste
time with no quality benefit.

| Phase | Name         | Agent(s)                    | Deliverable           | Input                                   | Output                                                                                                                                                                         |
| ----- | ------------ | --------------------------- | --------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1     | Intake       | Lead (you)                  | Audit Brief           | User's scope directive + codebase       | Codebase profile: languages, frameworks, size, directory map, dependency manifest, test framework, CI config. Priority zones flagged for deep scanning.                        |
| 1.5   | Brief Gate   | Skeptic                     | Validated Audit Brief | Audit Brief                             | Skeptic validates: correct stack identification, complete directory coverage, sensible priority zone ranking, no scope gaps that would cause assessors to miss critical areas. |
| 2     | Assessment   | 8 assessors (parallel fork) | 8 Assessment Reports  | Validated Audit Brief + codebase access | One report per category: findings with severity, evidence (file:line), signal classification, and remediation priority.                                                        |
| 3     | Adjudication | Skeptic                     | Adjudicated Findings  | 8 Assessment Reports                    | Validated findings: false positives removed, severities calibrated, cross-cutting patterns surfaced, duplicates merged.                                                        |
| 4     | Synthesis    | Lead (you)                  | Slop Audit Report     | Adjudicated Findings                    | Final report: executive summary, severity matrix, category breakdown, top-10 priority findings, root cause distribution, remediation roadmap (ordered, not executed).          |

**Why a Brief Gate?** A poisoned Audit Brief propagates to all 8 parallel assessors simultaneously — the same risk
review-pr identified for its dossier gate. Misidentified stack, missed directories, or wrong priority zones would cause
8 agents to waste effort or miss critical areas. The Brief is the only shared input to the fork; gating it once is
cheaper than debugging 8 misdirected reports.

## Agent Roster

| #   | Agent                 | Concern (one sentence)                                                                                                                                                   | Model  | Phase | Rationale                                                                                                                                                        |
| --- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ | ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Structural Assessor   | Architectural coherence — inconsistent patterns, duplication, coupling, over/under-engineering, config drift                                                             | Sonnet | 2     | Procedural checklist against 12 structural signals. Well-defined methodology (coupling metrics, DRY analysis, pattern consistency).                              |
| 2   | Security Assessor     | Exploitable vulnerabilities in first-party code — missing validation, hardcoded credentials, injection vectors, insecure defaults, deprecated APIs                       | Opus   | 2     | Reasoning-intensive: must identify exploit chains, perform taint analysis, assess actual exploitability. Security false negatives are expensive.                 |
| 3   | Supply Chain Assessor | Third-party dependency trust — hallucinated packages, slopsquatting, excessive dependencies, missing SBOM, license risk in dependencies                                  | Sonnet | 2     | Procedural: SBOM generation, registry verification, version pinning checks. Structured methodology with clear pass/fail criteria.                                |
| 4   | Concurrency Assessor  | Parallel execution correctness — race conditions, misused synchronization primitives, shared state mutations, false atomicity assumptions                                | Opus   | 2     | Reasoning-intensive: must trace execution paths across threads/processes, reason about happens-before relationships, identify subtle timing windows.             |
| 5   | Efficiency Assessor   | Unnecessary code and assets — dead code, unused dependencies, uncompressed assets, heavy libraries for trivial operations, commit bloat                                  | Sonnet | 2     | Procedural: dead code detection, asset size profiling, dependency weight analysis. Clear metrics-driven methodology.                                             |
| 6   | Performance Assessor  | Runtime execution quality — N+1 queries, missing caching, memory leaks, unbounded allocations, accessibility failures affecting UX                                       | Sonnet | 2     | Procedural with some judgment: query pattern detection, cache hit analysis, memory profiling setup. Structured methodologies (EXPLAIN analysis, heap profiling). |
| 7   | Testing Assessor      | Verification adequacy — happy-path-only tests, circular confidence, hallucinated fixtures, missing edge cases, coverage gaps in AI-generated code                        | Sonnet | 2     | Procedural: coverage analysis, mutation testing setup, fixture validation, test smell detection. Well-defined checklists.                                        |
| 8   | Governance Assessor   | Organizational and compliance risk — PR review bottleneck signals, automation bias, comprehension debt, GPL attribution gaps, shadow AI indicators, missing audit trails | Sonnet | 2     | Procedural: git log analysis, CI config review, license scanning, process metric extraction. Merged Human Bottleneck + Legal concerns.                           |
| 9   | Skeptic               | Adversarial quality gate — challenges all findings for false positives, calibrates severities, surfaces cross-cutting patterns, deduplicates across reports              | Opus   | 3     | Non-negotiable. The skeptic must match or exceed the reasoning capability of the agents it reviews. An audit that reports false positives erodes trust.          |

**Model allocation summary**: 3 Opus (Security, Concurrency, Skeptic) + 6 Sonnet (Structural, Supply Chain, Efficiency,
Performance, Testing, Governance) + Lead.

## Mandate Boundary Tests

| Agent A      | Agent B      | Boundary Statement                                                                                                                                                                                                                                                                                                |
| ------------ | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Structural   | Security     | Structural assesses design quality (is the code well-organized?); Security assesses exploitability (can the code be attacked?). A tightly-coupled module is Structural's concern; an SQL injection in that module is Security's.                                                                                  |
| Structural   | Efficiency   | Structural assesses architectural patterns (is it coherent?); Efficiency assesses resource waste (is it bloated?). Over-engineering is Structural's concern; dead code from that over-engineering is Efficiency's.                                                                                                |
| Security     | Supply Chain | Security assesses first-party code for vulnerabilities; Supply Chain assesses third-party dependencies for trust and provenance. A hardcoded credential is Security's concern; a hallucinated package name is Supply Chain's.                                                                                     |
| Security     | Concurrency  | Security assesses exploit vectors; Concurrency assesses synchronization correctness. An unauthenticated endpoint is Security's concern; a race condition on that endpoint's shared state is Concurrency's.                                                                                                        |
| Supply Chain | Efficiency   | Supply Chain assesses whether dependencies are trustworthy; Efficiency assesses whether they're necessary. A slopsquatted package is Supply Chain's concern; using lodash for a single array operation is Efficiency's.                                                                                           |
| Concurrency  | Performance  | Concurrency assesses correctness under parallel execution; Performance assesses speed and resource usage. A deadlock is Concurrency's concern; a missing cache causing slow responses is Performance's.                                                                                                           |
| Efficiency   | Performance  | Efficiency assesses whether code/assets should exist (dead code, unused deps, bloated assets); Performance assesses whether existing code runs well (N+1 queries, caching, memory leaks). Importing lodash for one utility is Efficiency's concern; a slow database query in a necessary module is Performance's. |
| Performance  | Testing      | Performance assesses runtime behavior; Testing assesses verification adequacy. An N+1 query is Performance's concern; a test that doesn't exercise the N+1 code path is Testing's.                                                                                                                                |
| Efficiency   | Testing      | Efficiency assesses whether code/assets should exist; Testing assesses whether tests verify what does exist. An unused utility file is Efficiency's concern; a test with a hallucinated fixture is Testing's.                                                                                                     |
| Testing      | Governance   | Testing assesses technical verification quality; Governance assesses organizational process quality. A happy-path-only test suite is Testing's concern; a team approving PRs faster than they can read them is Governance's.                                                                                      |
| Governance   | Security     | Governance assesses process and compliance risks; Security assesses code-level exploit risks. Missing GPL attribution is Governance's concern; a SQL injection is Security's.                                                                                                                                     |
| Governance   | Supply Chain | Governance assesses audit trail and licensing compliance at the organizational level; Supply Chain assesses dependency provenance and trust at the package level. Shadow AI usage without audit trail is Governance's concern; a dependency with no published source is Supply Chain's.                           |

## Deliverable Chain

```
[User scope directive + codebase]
  → Phase 1: Intake
    → [Audit Brief: codebase profile, priority zones, scope boundaries]
      → Phase 1.5: Brief Gate (Skeptic validates)
        → [Validated Audit Brief]
          → Phase 2: Assessment (8 agents in parallel)
            → [8 Assessment Reports: findings with severity, evidence, signal classification]
              → Phase 3: Adjudication (Skeptic adjudicates)
                → [Adjudicated Findings: validated, calibrated, deduplicated, cross-referenced]
                  → Phase 4: Synthesis
                    → [Slop Audit Report: executive summary, severity matrix, category breakdown, top-10 priorities, root cause distribution, remediation roadmap]
```

## Parallelization

- **Phase 2 is fully parallel**: All 8 assessors consume the same input (Audit Brief + codebase) and produce independent
  outputs. No inter-assessor dependencies. Spawn all 8 simultaneously.
- **Phases 1, 1.5, 3, 4 are strictly sequential**: Phase 1 scopes the audit. Phase 1.5 gates the Brief before the fork.
  Phase 3 requires all 8 reports (join point). Phase 4 requires adjudicated findings.
- **No partial-output streaming**: Unlike a remediation pipeline, an audit benefits from complete reports before
  adjudication. Partial streaming would force the skeptic to re-adjudicate as new findings arrive — complexity without
  benefit.

## Downstream Guidance

The Audit Brief (Phase 1 output) MUST include a **priority zone ranking** — directories/modules flagged for deep
scanning based on: recently AI-generated code (git log patterns), high complexity, low test coverage, or known risk
areas. This prevents assessors from allocating effort blindly across large codebases.

## Design Rationale

- **Why fork-join over sequential pipeline?** The 8 assessment concerns are independent analyses of the same input.
  Sequential scanning would take 8x longer with no quality improvement. review-pr uses this pattern successfully with 9
  parallel reviewers.
- **Why 8 assessors?** Each covers a distinct concern from the taxonomy with non-overlapping methodologies. The one
  merge (Human Bottleneck + Legal → Governance) is justified by shared analytical mode (process artifacts, not source
  code). Further merges would force agents to context-switch between incompatible methodologies.
- **Why detect-only?** Remediation requires a different mission verb, different agent skills (code writing, TDD), and
  different quality gates (does the fix work? vs. is the finding valid?). Existing skills handle remediation. Mixing
  detection and remediation would violate Principle 1.
- **Why 3 Opus agents?** Security and Concurrency require adversarial reasoning (exploit chain identification,
  happens-before analysis). The Skeptic is always Opus per convention. The other 6 agents follow structured, procedural
  methodologies that Sonnet handles well.
- **Alternatives rejected**:
  - _Sequential pipeline (triage → scan per category)_: Unnecessary serialization. Categories don't depend on each
    other.
  - _Fewer agents via aggressive merging_: Considered merging Bloat+Performance and Security+Supply Chain. Rejected
    because methodologies are too different — merged agents would context-switch and miss signals.
  - _More agents (keeping Human Bottleneck and Legal separate)_: 17 combined signals are manageable for one agent
    analyzing process artifacts. Splitting would create two agents with overlapping tooling (both scan git logs, CI
    configs).

## Root Cause Coverage Matrix

| Root Cause                          | Categories Covered                                                           | Agents                                                         |
| ----------------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------- |
| 1. Context blindness                | Structural Incoherence                                                       | Structural Assessor                                            |
| 2. Pattern mimicry without judgment | Security Vulnerabilities, Supply Chain Poisoning, Concurrency & State Errors | Security Assessor, Supply Chain Assessor, Concurrency Assessor |
| 3. Volume outpaces capacity         | Human Bottleneck (merged into Governance)                                    | Governance Assessor                                            |
| 4. Optimized for "does it run"      | Bloat & Waste, Runtime & UX Quality, Testing & Verification Gaps             | Efficiency Assessor, Performance Assessor, Testing Assessor    |
| 5. Institutional exposure           | Legal & Regulatory Exposure (merged into Governance)                         | Governance Assessor                                            |

All 5 root causes covered. All 9 categories covered. All 83 signals assigned to exactly one agent.

## Signal Distribution

| Agent                 | Category Source(s)                  | Signal Count |
| --------------------- | ----------------------------------- | ------------ |
| Structural Assessor   | Structural Incoherence              | 12           |
| Security Assessor     | Security Vulnerabilities            | 10           |
| Supply Chain Assessor | Supply Chain Poisoning              | 7            |
| Concurrency Assessor  | Concurrency & State Errors          | 8            |
| Efficiency Assessor   | Bloat & Waste                       | 9            |
| Performance Assessor  | Runtime & UX Quality                | 12           |
| Testing Assessor      | Testing & Verification Gaps         | 8            |
| Governance Assessor   | Human Bottleneck + Legal/Regulatory | 17           |
| **Total**             |                                     | **83**       |

## Progress Notes

- [17:37] Task claimed — reading reference skills
- [17:38] Blueprint drafted — sending to Forge Auditor for review
- [17:39] Forge Auditor APPROVED — 3 non-blocking notes
- [17:39] Addressed note 1: added Efficiency ↔ Performance formal boundary test
- [17:39] Addressed note 2: added Phase 1.5 (Brief Gate) with rationale matching review-pr pattern
- [17:39] Note 3 (UX signals in Performance Assessor) deferred to Armorer — methodology concern, not structural
- [17:39] Blueprint finalized
