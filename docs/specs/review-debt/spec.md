---
title: "Tech Debt Review Skill Specification"
status: "approved"
priority: "P3"
category: "new-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Tech Debt Review Skill Specification

## Summary

Create `review-debt` as a new multi-agent engineering skill for systematic technical debt identification, categorization, and prioritization against ongoing feature work. A Debt Analyst scans the codebase, the Debt Lead prioritizes findings against the roadmap, and a Debt Skeptic challenges the findings before the debt report is published. Supports full-codebase scans, targeted scope/category filtering, and status reporting.

## Problem

Technical debt accumulates invisibly across codebases. Teams rely on tribal knowledge to track debt, resulting in inconsistent identification and reactive (rather than proactive) remediation. No conclave skill currently surfaces hidden debt, categorizes it by type, or ranks it against in-flight feature work. The `review-quality` skill handles operational readiness but does not perform debt-specific analysis with feature-conflict scoring. Teams need a structured debt review that produces an actionable, prioritized backlog — not just a list of code smells.

## Solution

### 1. SKILL.md Structure

**File**: `plugins/conclave/skills/review-debt/SKILL.md`

**Frontmatter**:
```yaml
---
name: review-debt
description: >
  Systematic technical debt identification, categorization, and prioritization.
  Scans codebases for debt across six categories, ranks findings against
  active feature work, and produces a prioritized debt backlog.
argument-hint: "[--light] [status | --scope <path> | --category <category> | (empty for full scan)]"
tier: 1
---
```

**Required sections**: All 12 multi-agent engineering sections per the standard structure.

### 2. Agent Team Composition

| Agent | Name | Model | Role | Spawned For |
|---|---|---|---|---|
| Debt Analyst | `debt-analyst` | sonnet | Scan codebase and docs for debt items across 6 categories | full scan, scoped scan, category scan |
| Debt Skeptic | `debt-skeptic` | opus | Challenge findings and prioritization before report publication | all modes (except status) |

**Lead**: Debt Lead (the orchestrating agent, not spawned). The Debt Lead handles prioritization and feature-conflict scoring — this is a lead-level coordination task, not a separate agent.

### 3. Invocation Modes (Determine Mode)

- **No arguments**: Full-codebase debt review. Spawn debt-analyst + debt-skeptic. Produce report scoped to `full-codebase`.
- **`--scope <path>`**: Targeted scan. Debt Analyst limits scanning to the specified path. If path does not exist, return error and exit without spawning. Report's `scope` field set to the provided path.
- **`--category <category>`**: Category-filtered scan. Valid categories: `code-quality`, `architecture`, `test-coverage`, `documentation`, `dependency`, `security`. Invalid category returns the list of valid categories and exits.
- **`--scope` + `--category`**: Combined — scan the specified path for the specified category only.
- **`status`**: Read all `docs/progress/*-debt-report.md` files, parse frontmatter, output formatted table (scope, top-debt-count, status, created). No agents spawned.
- **`--light`**: Acknowledged, no team composition changes.
- **Resume**: Scan `docs/progress/` for checkpoint files with `team: "review-debt"` and incomplete status. If found, resume from checkpoint.

### 4. Orchestration Flow

1. Debt Lead reads Setup context: project stack, roadmap (`docs/roadmap/`), specs (`docs/specs/`), progress files, stack hints
2. Debt Lead creates tasks and spawns Debt Analyst
3. **Debt Analyst** scans across 6 categories:
   - `code-quality`: Complexity, duplication, naming violations
   - `architecture`: Coupling, missing abstractions, violated patterns
   - `test-coverage`: Untested code, brittle tests, missing integration coverage
   - `documentation`: Missing, stale, or misleading docs
   - `dependency`: Outdated dependencies, known CVEs, deprecated APIs
   - `security`: Low-severity security issues not meeting the bar for immediate fix
   - Each item: `category`, `location` (file path + line range), `description`, `estimated-effort` (small/medium/large), `severity` (high/medium/low)
   - Checkpoints after each category scan
   - Large codebases: focuses on highest-risk areas (recently changed files, files with known issues)
   - Zero debt found: produces clean assessment, does not fabricate items
   - Security debt crossing Critical/High: escalates immediately with `URGENT` flag
4. Debt Analyst sends findings to Debt Lead
5. **Debt Lead prioritizes** (lead-level work, not delegated):
   - Reads roadmap for `in_progress` and `not_started` items
   - Scores: `severity × (1 + feature-conflict-multiplier)` where multiplier is `1` if debt location overlaps with an active roadmap item, `0` otherwise
   - Top 5 high-severity items overlapping active features get `pay-before-feature` flag
   - Each item tagged with `recommended-sprint`: `current`, `next`, or `backlog`
   - Large-effort items split into `discovery` (small) + `implementation` (large)
   - No roadmap: severity-only ranking with a note
6. **Debt Skeptic gate** (BLOCKS report publication):
   - Reviews: (a) are high-severity items genuinely impactful or over-classified? (b) is the prioritization logic sound? (c) are effort estimates realistic? (d) are there missing categories (blind spots)?
   - APPROVED → Debt Lead writes report with `## Skeptic Review` section
   - REJECTED → Affected work revised and resubmitted (3-rejection deadlock applies)
7. Debt Lead writes debt report to `docs/progress/{scope}-debt-report.md`
8. Debt Lead writes end-of-session summary

### 5. Critical Rules

- Debt Skeptic MUST approve all findings before the debt report is published
- Every debt item must have `estimated-effort` and `recommended-sprint` — vague items without actionable guidance are grounds for Skeptic rejection
- Security debt crossing Critical/High severity must be escalated immediately, not queued as debt
- The skill is read-only — never modifies source code or existing project files (except progress/report files)
- Debt in deleted files is flagged as `stale`, not actionable
- Zero-debt findings are valid outcomes — the Debt Analyst must not fabricate items

### 6. Debt Report Artifact

**File**: `docs/progress/{scope}-debt-report.md` (scope sanitized: `/` → `-`)

**Frontmatter**:
```yaml
---
type: "debt-report"
scope: ""                    # path or "full-codebase"
status: "approved"              # draft | reviewed | complete
top-debt-count: 0            # number of high-severity items
created: ""
updated: ""
---
```

**Sections**: `## Executive Summary` (2-3 sentences), `## Debt Inventory` (grouped by category, full item schema), `## Prioritized Backlog` (ranked, top 15 if inventory exceeds 50 items), `## Recommendations` (top 5 actionable items), `## Skeptic Review`.

The report lives in `docs/progress/` (operational output, not planning). Not registered in the F-series validator.

### 7. Shared Content and Classification

- **Classification**: `engineering` in both `scripts/sync-shared-content.sh` and `scripts/validators/skill-shared-content.sh`
- **Skeptic name pair**: `debt-skeptic` / `Debt Skeptic` added to B2 normalizer and sync script
- **Shared content**: Both universal-principles and engineering-principles blocks

## Constraints

1. All 12 required multi-agent engineering sections must be present
2. `review-debt` classified as `engineering` in both sync and validation scripts
3. `debt-skeptic` / `Debt Skeptic` added to B2 normalizer (2 new sed entries)
4. Skeptic gate is non-negotiable
5. All 12/12 validators must pass after creation and sync
6. The skill never modifies source code — read-only except for progress/report files
7. No name collision with `review-quality` — verify in validator's known-skill list

## Out of Scope

- Automated debt resolution (identifies and prioritizes only, does not write fixes)
- Integration with issue trackers (Jira, Linear, GitHub Issues)
- Metrics tracking over time (each review is independent)
- Style linting or formatting enforcement (CI/CD tooling concern)
- Changes to existing skills

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/review-debt/SKILL.md` | Create — full multi-agent engineering skill |
| `scripts/sync-shared-content.sh` | Add `review-debt` to engineering classification list; add `debt-skeptic` / `Debt Skeptic` to skeptic name mapping |
| `scripts/validators/skill-shared-content.sh` | Add `review-debt` to engineering classification list; add `debt-skeptic` / `Debt Skeptic` to B2 normalizer |
| `plugins/conclave/shared/personas/debt-lead.md` | Create — persona file for Debt Lead |
| `plugins/conclave/shared/personas/debt-analyst.md` | Create — persona file for Debt Analyst |
| `plugins/conclave/shared/personas/debt-skeptic.md` | Create — persona file for Debt Skeptic |

## Success Criteria

1. `plugins/conclave/skills/review-debt/SKILL.md` exists with all 12 required multi-agent sections
2. YAML frontmatter contains `name: review-debt`, `tier: 1`, and a description
3. Shared content blocks populated correctly after sync; Communication Protocol contains `debt-skeptic`
4. `review-debt` appears in engineering classification lists in both scripts
5. `debt-skeptic` / `Debt Skeptic` appears in the B2 normalizer
6. Full scan mode spawns debt-analyst + debt-skeptic and produces a debt report
7. `--scope` and `--category` flags filter the scan appropriately
8. Status mode reads `*-debt-report.md` files without spawning agents
9. Prioritized backlog includes feature-conflict scoring when a roadmap exists
10. `bash scripts/validate.sh` reports 12/12 PASS
