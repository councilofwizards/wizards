---
title: "Plugin Organization — Internal Taxonomy & Infrastructure"
status: "spec_in_progress"
priority: "P2"
category: "core-framework"
effort: "small"
impact: "high"
dependencies: ["universal-shared-principles"]
created: "2026-02-19"
updated: "2026-03-27"
---

# Plugin Organization — Internal Taxonomy & Infrastructure

## Problem

All skills currently live in a single `conclave` plugin. As the skill count grows (17 today, 27+ at P3 completion) and diversifies across engineering and business domains, users need better taxonomy and discovery. Research confirms a domain split is premature at current scale (3 business skills) but will become necessary when business skills reach 7-10. The right move now is internal reorganization that enables a clean split later.

## Research Findings

- **Primary user segment** (technical founders) uses both domains — a split increases their friction
- **Shared content coupling** (sync scripts, validators, personas) makes splitting expensive today
- **Business domain too small** (3 skills) to justify split overhead; threshold estimated at 7-10
- **Option 3 (internal reorg) dominates** at current scale: zero infrastructure risk, enables clean split later

See: `docs/research/plugin-organization-research.md`, `docs/ideas/plugin-organization-ideas.md`

## Solution — 4 Sub-tasks

### Sub-task 1: Category Metadata + Skill Discovery Tags (batch with wizard-guide updates)
Add `category` and `tags` fields to SKILL.md frontmatter and plugin.json manifest. Update wizard-guide with progressive disclosure (role-gated opening prompt for Technical Founder / Engineering Team / Founder-Operator).

### Sub-task 2: Split Readiness ADR (ADR-005) + Automated Gate
Write ADR-005 documenting the 7-10 business skill threshold, prerequisites for a domain split (parameterized infra + persona extraction), and trigger conditions. Add bash validator that emits WARN when threshold is crossed.

### Sub-task 3: Parameterized Shared Content Infrastructure
Refactor `SHARED_DIR` hardcodes in `scripts/sync-shared-content.sh` and `scripts/validators/skill-shared-content.sh` to accept env var or CLI argument. ~20 lines of bash. Removes primary technical blocker.

### Sub-task 4: Progressive Disclosure in wizard-guide
Batch with Sub-task 1's wizard-guide edits. Role-gated skill presentation for different user segments.

## Implementation Sequence

Sub-task 1 → Sub-task 2 (needs taxonomy vocabulary) → Sub-task 3 (ADR defines infra contract) → Sub-task 4 (batch with Sub-task 1)

Deferred: Persona Extraction (Idea 5) → P3-gated, captured in ADR-005 as trigger prerequisite.

## Success Criteria

- All 17 SKILL.md files have `category` and `tags` frontmatter fields
- ADR-005 written with threshold, prerequisites, and trigger conditions
- `SHARED_DIR` in sync script and B-series validator accepts env var/CLI arg
- wizard-guide presents role-appropriate skill subsets
- All 12/12 validators pass
- No regression in shared content management
