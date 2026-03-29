---
title: "API Design Skill Specification"
status: "approved"
priority: "P3"
category: "new-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# API Design Skill Specification

## Summary

Create `design-api` as a new multi-agent engineering skill for structured API design review. An API Consistency Reviewer
evaluates naming and structural conventions, a Breaking Change Analyzer identifies backward-incompatible changes, a DX
Evaluator assesses developer experience, and an API Design Skeptic challenges all recommendations before the design
report is published. Supports full review, breaking-changes-only, and consistency-only modes.

## Problem

API design inconsistencies accumulate across projects — endpoint naming drifts, error formats vary, breaking changes
ship without migration strategies, and developer experience degrades as APIs grow. No conclave skill currently reviews
API contracts for consistency, backward compatibility, or consumer experience. The `write-spec` skill produces API
contracts during spec writing but does not evaluate existing APIs against conventions or detect breaking changes between
versions. Teams need a dedicated API review skill that applies the same Skeptic-gated rigor to API design that the
plugin enforces for code quality and operational readiness.

## Solution

### 1. SKILL.md Structure

**File**: `plugins/conclave/skills/design-api/SKILL.md`

**Frontmatter**:

```yaml
---
name: design-api
description: >
  Structured API design review: consistency evaluation, breaking change detection, developer experience assessment, and
  design recommendations through a dedicated agent team with mandatory Skeptic review.
argument-hint: "[--light] [status | --breaking-changes <spec-path> | --consistency <spec-path> | <api-spec-path>]"
tier: 1
---
```

**Required sections**: All 12 multi-agent engineering sections per the standard structure.

### 2. Agent Team Composition

| Agent                    | Name                       | Model  | Role                                                                       | Spawned For                       |
| ------------------------ | -------------------------- | ------ | -------------------------------------------------------------------------- | --------------------------------- |
| API Consistency Reviewer | `api-consistency-reviewer` | sonnet | Evaluate API against naming, structural, and protocol conventions          | full review, `--consistency`      |
| Breaking Change Analyzer | `breaking-change-analyzer` | opus   | Identify backward-incompatible changes between API versions                | full review, `--breaking-changes` |
| DX Evaluator             | `dx-evaluator`             | sonnet | Assess API discoverability, learnability, error quality, and documentation | full review only                  |
| API Design Skeptic       | `api-design-skeptic`       | opus   | Challenge all findings and recommendations before report publication       | all modes (except status)         |

**Lead**: Design Lead (the orchestrating agent, not spawned).

### 3. Invocation Modes (Determine Mode)

- **No arguments / API spec path**: Full review. Spawn api-consistency-reviewer + breaking-change-analyzer +
  dx-evaluator + api-design-skeptic. If no API spec provided and no specs in `docs/specs/`, prompt user to provide a
  spec or spec path and exit.
- **`--breaking-changes <spec-path>`**: Breaking change analysis only. Spawn breaking-change-analyzer +
  api-design-skeptic. If no prior API version exists for comparison, return error: "No baseline API version found.
  Provide a prior version spec to enable breaking change analysis."
- **`--consistency <spec-path>`**: Consistency review only. Spawn api-consistency-reviewer + api-design-skeptic.
- **`status`**: Read existing `api-design-report.md` files in `docs/specs/`, parse frontmatter, output summary. No
  agents spawned.
- **`--light`**: Acknowledged, no team composition changes.
- **Resume**: Scan `docs/progress/` for checkpoint files with `team: "design-api"` and incomplete status.

### 4. Orchestration Flow

1. Design Lead reads Setup context: API spec (from arguments or `docs/specs/`), stack hints, existing API contracts for
   baseline
2. Design Lead creates tasks and spawns appropriate agents per mode
3. **Agents work in parallel**:

   **API Consistency Reviewer**:
   - Evaluates: naming conventions (resource nouns, plural collections, consistent casing), HTTP method semantics,
     status code correctness (200/201/204, 400/422/409), response envelope structure (error format, pagination shape)
   - Uses existing contracts in `docs/specs/` as consistency baseline; falls back to general REST best practices (RFC
     7807 errors, plural resources) if no baseline exists
   - Handles non-REST protocols: GraphQL (query/mutation/subscription naming), gRPC (service/method naming)
   - Each finding: `rule`, `verdict` (pass/fail/warning), `location` (endpoint or field path), `recommendation`
   - Multiple APIs: one findings file per API

   **Breaking Change Analyzer**:
   - Classifies changes: `breaking` (removes field/endpoint, changes type, changes required/optional),
     `potentially-breaking` (adds required field, changes error code), `non-breaking` (adds optional response field,
     adds endpoint)
   - Each breaking change: `change-type`, affected endpoint/field, `before`/`after` state, `migration-path`
     recommendation
   - Zero breaking changes: outputs `CLEAN` verdict with full change list
   - Breaking changes found: sends `BREAKING CHANGES DETECTED` header to Design Lead with count by tier
   - No baseline version: outputs notice and skips analysis (Consistency Reviewer still runs)

   **DX Evaluator**:
   - Evaluates: discoverability (self-documenting names?), learnability (infer behavior from first 2-3 endpoints?),
     error message quality (human-readable, actionable?), documentation completeness (description, example request,
     example response per endpoint?)
   - Each criterion: `dx-score` 1-5 with one-sentence rationale
   - Overall: `overall-dx-score` (average, 1 decimal) + `dx-summary` (1-paragraph narrative)
   - Score below 3: includes concrete improvement suggestion per low-scoring criterion
   - Internal-only API: reduced scope (discoverability + learnability only)

4. All findings routed to Design Lead
5. **API Design Skeptic gate** (BLOCKS report publication):
   - Reviews: (a) breaking-change classifications correct? (b) consistency violations genuine or false positives? (c) DX
     scores calibrated against realistic expectations? (d) recommendations actionable?
   - May approve subset (e.g., approve consistency, reject DX) — only rejected agents revise
   - APPROVED → Design Lead writes report with `## Skeptic Review` section
   - REJECTED → Affected agents revise and resubmit (3-rejection deadlock applies)
6. Design Lead writes API design report
7. Design Lead writes end-of-session summary

### 5. Critical Rules

- API Design Skeptic MUST approve all findings before the design report is published
- The skill never modifies existing spec files or API contracts — it creates new report files only
- API recommendations that conflict with existing signed sprint contracts must be flagged
- The skill must work with API descriptions in any format (OpenAPI YAML, inline markdown, plain prose)
- Each finding must include a specific `recommendation` — vague "could be better" findings are grounds for Skeptic
  rejection
- The Breaking Change Analyzer only runs when a prior API version is available for comparison

### 6. API Design Report Artifact

**File**: `docs/specs/{api-name}/api-design-report.md` (api-name sanitized to slug)

**Frontmatter**:

```yaml
---
type: "api-design-report"
api-name: ""
status: "approved" # draft | reviewed | approved
breaking-changes-found: false
overall-dx-score: null # null if DX evaluation didn't run
created: ""
updated: ""
---
```

**Sections**: `## Executive Summary`, `## Consistency Findings` (if reviewer ran), `## Breaking Changes` (if analyzer
ran), `## DX Assessment` (if evaluator ran), `## Recommendations` (top 5, each with priority + description +
before/after example), `## Skeptic Review`.

The report lives in `docs/specs/{api-name}/` to co-locate with the API's spec files. Not an artifact template — no
F-series validator change needed.

### 7. Shared Content and Classification

- **Classification**: `engineering` in both `scripts/sync-shared-content.sh` and
  `scripts/validators/skill-shared-content.sh`
- **Skeptic name pair**: `api-design-skeptic` / `API Design Skeptic` added to B2 normalizer and sync script
- **Shared content**: Both universal-principles and engineering-principles blocks

## Constraints

1. All 12 required multi-agent engineering sections must be present
2. `design-api` classified as `engineering` in both sync and validation scripts
3. `api-design-skeptic` / `API Design Skeptic` added to B2 normalizer (2 new sed entries)
4. Skeptic gate is non-negotiable
5. All 12/12 validators must pass after creation and sync
6. The skill never modifies existing spec files or API contracts
7. Spec-agnostic — must work with any API description format
8. Contracts are sacred — must flag conflicts with signed sprint contracts

## Out of Scope

- Automated API schema validation against a live server
- Code generation from API specs
- Integration with API management platforms (Apigee, Kong, AWS API Gateway)
- GraphQL schema generation or validation tooling
- Changes to existing skills (write-spec, build-implementation)

## Files to Modify

| File                                                           | Change                                                                                                                       |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/design-api/SKILL.md`                  | Create — full multi-agent engineering skill                                                                                  |
| `scripts/sync-shared-content.sh`                               | Add `design-api` to engineering classification list; add `api-design-skeptic` / `API Design Skeptic` to skeptic name mapping |
| `scripts/validators/skill-shared-content.sh`                   | Add `design-api` to engineering classification list; add `api-design-skeptic` / `API Design Skeptic` to B2 normalizer        |
| `plugins/conclave/shared/personas/design-lead.md`              | Create — persona file for Design Lead                                                                                        |
| `plugins/conclave/shared/personas/api-consistency-reviewer.md` | Create — persona file for API Consistency Reviewer                                                                           |
| `plugins/conclave/shared/personas/breaking-change-analyzer.md` | Create — persona file for Breaking Change Analyzer                                                                           |
| `plugins/conclave/shared/personas/dx-evaluator.md`             | Create — persona file for DX Evaluator                                                                                       |
| `plugins/conclave/shared/personas/api-design-skeptic.md`       | Create — persona file for API Design Skeptic                                                                                 |

## Success Criteria

1. `plugins/conclave/skills/design-api/SKILL.md` exists with all 12 required multi-agent sections
2. YAML frontmatter contains `name: design-api`, `tier: 1`, and a description
3. Shared content blocks populated correctly after sync; Communication Protocol contains `api-design-skeptic`
4. `design-api` appears in engineering classification lists in both scripts
5. `api-design-skeptic` / `API Design Skeptic` appears in the B2 normalizer
6. Full review mode spawns all 4 agents; `--breaking-changes` spawns analyzer + skeptic; `--consistency` spawns
   reviewer + skeptic
7. API Consistency Reviewer uses existing contracts as baseline when available, REST best practices otherwise
8. Breaking Change Analyzer classifies changes into 3 tiers with migration paths
9. DX Evaluator produces 1-5 scores per criterion with an overall score
10. `bash scripts/validate.sh` reports 12/12 PASS
