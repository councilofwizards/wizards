---
title: "Migration Planning Skill Specification"
status: "approved"
priority: "P3"
category: "new-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Migration Planning Skill Specification

## Summary

Create `plan-migration` as a new multi-agent engineering skill for planning
large-scale migrations (database, framework, infrastructure, service
extraction). A Scope Mapper identifies all affected components and dependencies,
a Migration Phaser breaks the migration into independently deployable phases, a
Risk Assessor evaluates failure modes per phase, and a Migration Skeptic
challenges all assumptions before the plan is published. Every phase must have a
defined rollback strategy — plans missing rollbacks are rejected.

## Problem

Large migrations are among the highest-risk engineering activities. Teams
currently plan migrations ad-hoc, frequently underestimating scope, missing
downstream dependencies, omitting rollback strategies, or attempting big-bang
cutovers that risk extended outages. No conclave skill provides structured
migration planning with dependency mapping, phased execution, per-phase risk
assessment, and rollback-first thinking enforced by a Skeptic gate. The
`plan-implementation` skill plans feature implementations but does not address
migration-specific concerns (expand-contract patterns, dual-write phases,
rollback strategies, cross-team coordination).

## Solution

### 1. SKILL.md Structure

**File**: `plugins/conclave/skills/plan-migration/SKILL.md`

**Frontmatter**:

```yaml
---
name: plan-migration
description: >
  Phased migration planning with dependency mapping, risk assessment, and
  rollback strategies. Supports database, framework, infrastructure, and service
  extraction migrations through a dedicated agent team.
argument-hint:
  "[--light] [status | --allow-bigbang | <migration-type> <scope-description>]"
tier: 1
---
```

**Required sections**: All 12 multi-agent engineering sections per the standard
structure.

### 2. Agent Team Composition

| Agent             | Name                | Model | Role                                                            | Spawned For               |
| ----------------- | ------------------- | ----- | --------------------------------------------------------------- | ------------------------- |
| Scope Mapper      | `scope-mapper`      | opus  | Map all affected components, dependencies, and blast radius     | all modes (except status) |
| Migration Phaser  | `migration-phaser`  | opus  | Break migration into sequenced, independently deployable phases | all modes (except status) |
| Risk Assessor     | `risk-assessor`     | opus  | Assess failure modes, likelihood, and impact per phase          | all modes (except status) |
| Migration Skeptic | `migration-skeptic` | opus  | Challenge scope, phasing, risk, and rollback completeness       | all modes (except status) |

**Lead**: Migration Lead (the orchestrating agent, not spawned).

**Note**: All agents use `opus` — migration planning is high-stakes reasoning
work where cost efficiency is secondary to correctness.

### 3. Invocation Modes (Determine Mode)

- **`<migration-type> <scope>`**: Full migration planning. Valid types:
  `database`, `framework`, `infrastructure`, `service-extraction`. Spawn all 4
  agents. Produce migration plan.
- **No arguments**: Prompt user for migration type and scope description. Exit
  without spawning.
- **`--allow-bigbang`**: Acknowledged. Migration Phaser may produce a
  single-phase plan but documents the risk and includes a mandatory rollback
  phase.
- **`status`**: Read all `docs/specs/*/migration-plan.md` files, parse
  frontmatter, output table (migration-id, type, complexity, phase-count,
  status). No agents spawned.
- **`--light`**: Acknowledged, no team composition changes.
- **Resume**: Scan `docs/progress/` for checkpoint files with
  `team: "plan-migration"` and incomplete status.

### 4. Orchestration Flow

1. Migration Lead reads Setup context: migration type and scope from arguments,
   stack hints, existing migration specs in `docs/specs/`, architecture ADRs
2. Migration Lead creates tasks and spawns Scope Mapper first (phasing and risk
   depend on its output)

**Stage 1: Scope Mapping**

3. **Scope Mapper** produces dependency map:
   - Each component classified: `primary` (directly migrated), `downstream-hard`
     (must change in lockstep), `downstream-soft` (can update asynchronously),
     `external` (third-party, verify but cannot modify)
   - Database migrations: explicitly lists tables, FK relationships crossing
     boundaries, stored procedures/triggers, application query layers
   - `migration-complexity` assessment: `low` (1-3 primary, no external),
     `medium` (4-10 or 1-2 external), `high` (10+ or multiple external or
     cross-team)
   - Circular dependencies flagged as `blocking-dependency`
   - Large scope (50+ components): cluster by domain with cluster-level map
   - Vague scope: requests clarification from Migration Lead before proceeding
4. Scope Mapper sends findings to Migration Lead

**Stage 2: Phasing and Risk Assessment (parallel)**

5. Migration Lead spawns Migration Phaser + Risk Assessor after Scope Mapper
   completes
6. **Migration Phaser** produces phased plan from dependency map:
   - Each phase: `phase-id`, `description`, `components`, `pre-conditions`,
     `success-criteria`, `estimated-duration`, `rollback-strategy`,
     `rollback-tested` status
   - Phase constraints: (a) all `downstream-hard` deps handled in same phase or
     earlier, (b) each phase independently deployable and verifiable, (c) system
     in valid transitional state after each phase
   - Database migrations: includes `dual-write` or `expand-contract` phase for
     column type changes or renames
   - `migration-complexity: high`: mandatory `phase-0: preparation` (backups,
     monitoring, rollback tested, stakeholders notified)
   - Circular dependency detected: sends `BLOCKED` to Migration Lead with cycle
     description
   - `--allow-bigbang`: single-phase plan with documented risk + mandatory
     rollback phase
   - **Rollback strategy per phase** (non-negotiable): trigger conditions,
     rollback steps in order, estimated rollback duration, expected
     post-rollback state
   - Destructive DB operations (DROP, TRUNCATE, type change): rollback must
     include backup timestamp, restore procedure, verification step
   - `rollback: impossible`: flagged with mandatory human operator sign-off
     requirement
   - `rollback-requires-downtime: true`: documented, stakeholders notified in
     Communication Plan
   - Untested rollback: `rollback-tested: false`, risk score set to `medium`
     minimum
7. **Risk Assessor** evaluates per-phase risk (runs in parallel with Phaser,
   iterates after Phaser output):
   - Two dimensions: `likelihood` (high/medium/low) × `impact`
     (critical/high/medium/low)
   - Each risk: `phase-id`, `risk-description`, `likelihood`, `impact`,
     `risk-score` (normalized), `mitigation-strategy`
   - `risk-score: critical`: sends `CRITICAL RISK` header to Migration Lead with
     recommendation (split phase, add rollback rehearsal, or additional
     sign-off)
   - Destructive operations without confirmed rollback: `impact: critical`
     automatically
   - DNS cutover: `impact: critical`, mitigation must include TTL-reduction step
     in phase-0
   - "Monitor and respond" is not a valid mitigation — must propose specific,
     proactive alternative
   - All phases `risk-score: low`: valid but Migration Skeptic may probe for
     underestimation

**Stage 3: Skeptic Review**

8. **Migration Skeptic gate** (BLOCKS plan publication — highest-scrutiny gate
   in the plugin):
   - Reviews: (a) scope map complete — obvious components missing? (b) phasing
     respects all hard dependencies? (c) critical risks assessed accurately or
     understated? (d) every phase has defined, plausible rollback? (e) "big
     bang" phases that should be split?
   - `rollback: impossible` without human sign-off documented: REJECTED
   - "Monitor and respond" mitigation: REJECTED
   - No phase-0 for high-complexity migration: REJECTED (requests phase-0
     addition)
   - APPROVED → Migration Lead writes plan with `## Skeptic Review` section
   - REJECTED → Affected agents revise and resubmit (3-rejection deadlock
     applies)
9. Migration Lead writes migration plan artifact
10. Migration Lead writes end-of-session summary

### 5. Critical Rules

- Migration Skeptic MUST approve all findings before the migration plan is
  published
- Every phase MUST have a defined rollback strategy — no exceptions
- `rollback: impossible` requires mandatory human operator sign-off
- "Monitor and respond" is not an acceptable mitigation strategy
- The skill plans migrations — it never executes them (no DB commands, deploys,
  or infrastructure changes)
- Phase atomicity: each phase independently deployable and verifiable
- Destructive database operations without confirmed rollback are
  `impact: critical`
- High-complexity migrations require phase-0 preparation

### 6. Migration Plan Artifact

**File**: `docs/specs/{migration-id}/migration-plan.md` (migration-id sanitized
to slug)

**Frontmatter**:

```yaml
---
type: "migration-plan"
migration-id: ""
migration-type: "" # database | framework | infrastructure | service-extraction
status: "approved" # draft | reviewed | approved | in-progress | complete
migration-complexity: "" # low | medium | high
phase-count: 0
created: ""
updated: ""
---
```

**Sections**: `## Executive Summary`, `## Scope Map` (dependency map from Scope
Mapper), `## Migration Phases` (each phase as `### Phase N: {description}` with
components, pre-conditions, success-criteria, estimated-duration,
rollback-strategy, rollback-tested), `## Risk Register` (all risk items),
`## Rollback Strategies` (consolidated per-phase), `## Communication Plan`
(stakeholders, sign-off steps, downtime windows), `## Skeptic Review`.

**Artifact template**: `docs/templates/artifacts/migration-plan.md` must be
created and registered in `scripts/validators/artifact-templates.sh`'s
`expected_templates` list to maintain F-series validator passing.

### 7. Shared Content and Classification

- **Classification**: `engineering` in both `scripts/sync-shared-content.sh` and
  `scripts/validators/skill-shared-content.sh`
- **Skeptic name pair**: `migration-skeptic` / `Migration Skeptic` added to B2
  normalizer and sync script
- **Shared content**: Both universal-principles and engineering-principles
  blocks

## Constraints

1. All 12 required multi-agent engineering sections must be present
2. `plan-migration` classified as `engineering` in both sync and validation
   scripts
3. `migration-skeptic` / `Migration Skeptic` added to B2 normalizer (2 new sed
   entries)
4. Skeptic gate is non-negotiable — highest-scrutiny gate in the plugin
5. All 12/12 validators must pass after creation, sync, and artifact template
   registration
6. The skill never executes migrations — planning only
7. Every phase must have a rollback strategy (Skeptic-enforced)
8. `migration-plan` artifact template registered in F-series validator
9. Phase atomicity: each phase independently deployable and verifiable

## Out of Scope

- Automated migration script generation
- Integration with migration tooling (Liquibase, Flyway, Alembic, Terraform)
- Real-time migration monitoring
- Post-migration verification execution
- Changes to existing skills (plan-implementation, build-product)

## Files to Modify

| File                                                    | Change                                                                                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `plugins/conclave/skills/plan-migration/SKILL.md`       | Create — full multi-agent engineering skill                                                                                    |
| `docs/templates/artifacts/migration-plan.md`            | Create — migration plan artifact template with `type: "migration-plan"` frontmatter                                            |
| `scripts/sync-shared-content.sh`                        | Add `plan-migration` to engineering classification list; add `migration-skeptic` / `Migration Skeptic` to skeptic name mapping |
| `scripts/validators/skill-shared-content.sh`            | Add `plan-migration` to engineering classification list; add `migration-skeptic` / `Migration Skeptic` to B2 normalizer        |
| `scripts/validators/artifact-templates.sh`              | Add `migration-plan:migration-plan` to `expected_templates` list                                                               |
| `plugins/conclave/shared/personas/migration-lead.md`    | Create — persona file for Migration Lead                                                                                       |
| `plugins/conclave/shared/personas/scope-mapper.md`      | Create — persona file for Scope Mapper                                                                                         |
| `plugins/conclave/shared/personas/migration-phaser.md`  | Create — persona file for Migration Phaser                                                                                     |
| `plugins/conclave/shared/personas/risk-assessor.md`     | Create — persona file for Risk Assessor                                                                                        |
| `plugins/conclave/shared/personas/migration-skeptic.md` | Create — persona file for Migration Skeptic                                                                                    |

## Success Criteria

1. `plugins/conclave/skills/plan-migration/SKILL.md` exists with all 12 required
   multi-agent sections
2. YAML frontmatter contains `name: plan-migration`, `tier: 1`, and a
   description
3. Shared content blocks populated correctly after sync; Communication Protocol
   contains `migration-skeptic`
4. `plan-migration` appears in engineering classification lists in both scripts
5. `migration-skeptic` / `Migration Skeptic` appears in the B2 normalizer
6. `docs/templates/artifacts/migration-plan.md` exists with
   `type: "migration-plan"` and is registered in the F-series validator
7. Scope Mapper produces dependency maps with 4-tier component classification
8. Migration Phaser produces phased plans with rollback strategies per phase
9. Risk Assessor evaluates per-phase risk with specific mitigation strategies
10. Migration Skeptic rejects plans with missing rollbacks or "monitor and
    respond" mitigations
11. `bash scripts/validate.sh` reports 12/12 PASS
