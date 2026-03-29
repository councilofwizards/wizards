---
type: "user-stories"
feature: "plan-migration"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-07-plan-migration.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Migration Planning Skill (P3-07)

## Epic Summary

Create `plan-migration` as a new multi-agent conclave skill for planning
large-scale migrations (database, framework, infrastructure). The skill maps
migration scope and dependencies, assesses risk by phase, defines rollback
strategies, and produces a phased migration plan artifact. A Migration Skeptic
challenges all assumptions before the plan is finalized — migration plans that
underestimate scope or omit rollback strategies are rejected before they can
cause production failures.

## Stories

---

### Story 1: SKILL.md Scaffolding and Frontmatter

- **As a** skill author creating the migration planning skill
- **I want** a valid `plugins/conclave/skills/plan-migration/SKILL.md` with
  correct frontmatter, required sections, and shared content markers
- **So that** the skill is discoverable, passes all validators, and follows the
  established structure for multi-agent engineering skills
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the skill directory, when created, then
     `plugins/conclave/skills/plan-migration/SKILL.md` exists with YAML
     frontmatter containing: `name: plan-migration`, a `description` field
     summarizing phased migration planning with risk assessment and rollback
     strategies, an `argument-hint` documenting supported invocation patterns
     (migration type and scope), and `tier: 1`
  2. Given the SKILL.md, when inspected for required multi-agent sections, then
     it contains all 12 required multi-agent sections: `## Setup`,
     `## Write Safety`, `## Checkpoint Protocol`, `## Determine Mode`,
     `## Lightweight Mode`, `## Spawn the Team`, `## Orchestration Flow`,
     `## Critical Rules`, `## Failure Recovery`, `## Teammates to Spawn`,
     `## Shared Principles` (containing both universal-principles and
     engineering-principles marker blocks), and `## Communication Protocol`
  3. Given the shared content markers, when
     `bash scripts/sync-shared-content.sh` is run, then the blocks are populated
     from `plugins/conclave/shared/` with the Migration Skeptic's name
     substituted correctly
  4. Given `bash scripts/validate.sh`, when run after the SKILL.md is created
     and synced, then all 12/12 validators pass
  5. Given the classification lists in `scripts/sync-shared-content.sh` and
     `scripts/validators/skill-shared-content.sh`, when `plan-migration` is
     added, then it is classified as `engineering`

- **Edge Cases**:
  - Classification added to sync script but not validator script (or vice
    versa): B-series validator will flag drift; both files must be updated
    together
  - Skill added to plugin.json before SKILL.md passes validators: plugin.json
    update should be deferred until validators pass

- **Notes**: The Setup section must read `docs/stack-hints/{stack}.md` if
  present (same as `review-quality`) and read any existing migration-related
  specs in `docs/specs/` to understand what migrations have already been
  planned. Reference `plugins/conclave/skills/plan-implementation/SKILL.md` as a
  secondary structural reference for planning-class skills.

---

### Story 2: Scope and Dependency Mapper Agent

- **As a** engineering team planning a large migration
- **I want** a Scope Mapper agent that identifies all components, systems, and
  dependencies affected by the migration
- **So that** the team understands the full blast radius before committing to a
  migration timeline
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a migration description (type: `database` | `framework` |
     `infrastructure` | `service-extraction`) and a scope (path, service name,
     or description), when the Scope Mapper is spawned, then it produces a
     dependency map listing: all source components that must change, all
     consumer components that depend on the migrating component, external
     integrations that may be affected, and data stores that will be modified
  2. Given the dependency map, when inspected, then each component is classified
     as: `primary` (directly migrated), `downstream-hard` (hard dependency, must
     change in lockstep), `downstream-soft` (soft dependency, can be updated
     asynchronously), or `external` (third-party, cannot be modified but must be
     verified)
  3. Given a database migration type, when the Scope Mapper runs, then the
     dependency map explicitly lists: tables being migrated, foreign key
     relationships crossing migration boundaries, any stored procedures or
     triggers that reference migrated tables, and application layers that
     execute queries against those tables
  4. Given the Scope Mapper's findings, when inspected, then the report includes
     a `migration-complexity` assessment: `low` (1-3 primary components, no
     external dependencies), `medium` (4-10 components, or 1-2 external
     dependencies), or `high` (10+ components, or multiple external
     dependencies, or cross-team coordination required)
  5. Given the Scope Mapper's spawn prompt, when inspected, then it includes the
     instruction to checkpoint findings to
     `docs/progress/{migration-id}-scope-mapper.md`

- **Edge Cases**:
  - Migration scope description is vague (e.g., "migrate the database"): Scope
    Mapper requests clarification from the Migration Lead — specifically: which
    database, what is the target schema or engine, what is the target state?
  - Circular dependencies detected (Component A depends on B, B depends on A
    across migration boundary): Scope Mapper flags the cycle as a
    `blocking-dependency` in the map; the Migration Lead must resolve it before
    phasing can proceed
  - External dependency is a vendor API with no source code available:
    classified as `external`; Scope Mapper recommends the team contact the
    vendor for compatibility confirmation
  - Migration affects 50+ components: Scope Mapper clusters components by domain
    and produces a cluster-level map with a note that per-component detail is
    available on request

- **Notes**: Scope Mapper uses `opus` model for comprehensive dependency
  reasoning. Agent name: `scope-mapper`. The dependency map is the foundation
  for phasing (Story 3) and risk assessment (Story 4) — it must be complete
  before those agents can run.

---

### Story 3: Migration Phaser Agent

- **As a** engineering team that has mapped migration scope
- **I want** a Migration Phaser agent that breaks the migration into a
  sequenced, executable plan of phases
- **So that** the migration can be executed incrementally, each phase
  independently verifiable, rather than as a single risky big-bang cutover
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Scope Mapper's dependency map, when the Migration Phaser is
     spawned, then it produces a phased migration plan where each phase
     satisfies: (a) all `downstream-hard` dependencies of phase N's primary
     components are handled in phase N or earlier, (b) each phase is
     independently deployable and verifiable, (c) the system is in a valid (if
     transitional) state after each phase
  2. Given the phased plan, when inspected, then each phase contains: a
     `phase-id` (e.g., `phase-1`), a `description`, a list of `components` being
     migrated in that phase, `pre-conditions` that must be true before the phase
     starts, `success-criteria` (specific, verifiable outcomes), and an
     `estimated-duration`
  3. Given a database migration, when the Migration Phaser produces phases, then
     the plan explicitly includes a `dual-write` or `expand-contract` phase if
     the migration involves changing column types or renaming fields — the old
     and new schemas must coexist for at least one deploy cycle
  4. Given a `migration-complexity: high` assessment from the Scope Mapper, when
     the Migration Phaser produces the plan, then it includes a
     `phase-0: preparation` that covers pre-migration prerequisites (backups
     confirmed, monitoring in place, rollback tested, stakeholders notified)
     before any data or code changes begin
  5. Given the Migration Phaser's spawn prompt, when inspected, then it includes
     the instruction to checkpoint the phased plan to
     `docs/progress/{migration-id}-migration-phaser.md`

- **Edge Cases**:
  - Dependency cycle identified by Scope Mapper: Migration Phaser cannot produce
    a valid sequential phase plan; it flags the cycle as a blocker and sends a
    `BLOCKED` message to the Migration Lead with the cycle description
  - All components are `downstream-soft` (no hard dependencies): Migration
    Phaser may produce a single-phase plan (low-complexity migration); this is
    valid and should not trigger a false warning
  - User requests a "big bang" migration (single cutover): Migration Phaser
    notes the risk, documents it in the plan, but produces the requested
    single-phase plan if the user confirms via `--allow-bigbang` flag; includes
    a mandatory rollback phase

- **Notes**: Migration Phaser uses `opus` model. Agent name: `migration-phaser`.
  The phased plan is the central output artifact — it must be produced before
  the Risk Assessor runs, as risk is assessed per-phase.

---

### Story 4: Risk Assessment Agent

- **As a** engineering team who has a phased migration plan
- **I want** a Risk Assessment agent that identifies failure modes, probability,
  and impact for each migration phase
- **So that** the team can prioritize risk mitigation and know which phases
  require extra safeguards before execution
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the phased migration plan from Story 3, when the Risk Assessment
     agent is spawned, then it assesses risk for each phase using two
     dimensions: `likelihood` (`high` | `medium` | `low`) and `impact`
     (`critical` | `high` | `medium` | `low`), producing a 2×4 risk matrix entry
     per phase
  2. Given the risk assessment output, when inspected, then each risk item
     includes: the `phase-id`, a `risk-description`, `likelihood`, `impact`, a
     `risk-score` (likelihood × impact, normalized to `critical` | `high` |
     `medium` | `low`), and a `mitigation-strategy`
  3. Given a phase with `risk-score: critical`, when the Risk Assessment agent
     sends findings to the Migration Lead, then it includes a `CRITICAL RISK`
     header and recommends either: (a) splitting the phase into smaller steps to
     reduce blast radius, (b) adding a mandatory rollback rehearsal before phase
     execution, or (c) additional stakeholder sign-off before proceeding
  4. Given a database migration phase that involves destructive operations (DROP
     COLUMN, DROP TABLE, data type changes), when assessed, then the risk item
     is automatically classified at `impact: critical` unless a confirmed
     rollback strategy exists — the absence of a rollback strategy for a
     destructive operation is itself a `critical` risk
  5. Given the Risk Assessment agent's spawn prompt, when inspected, then it
     includes the instruction to checkpoint findings to
     `docs/progress/{migration-id}-risk-assessor.md`

- **Edge Cases**:
  - All phases assess as `risk-score: low`: Risk Assessor produces a clean risk
    report; Migration Skeptic may probe whether the assessment is genuinely
    complete or underestimating risk
  - Infrastructure migration involving DNS cutover: assessed as
    `impact: critical` (even short DNS propagation windows affect users);
    mitigation must include a TTL-reduction step in phase-0
  - Risk mitigation strategy for a phase is "move quickly and monitor": Risk
    Assessor flags this as an invalid mitigation strategy and proposes a
    specific, actionable alternative

- **Notes**: Risk Assessment agent uses `opus` model. Agent name:
  `risk-assessor`. Risk assessment runs in parallel with rollback strategy
  definition (Story 5) — they are both inputs to the Migration Skeptic gate
  (Story 6).

---

### Story 5: Rollback Strategy Definition

- **As a** engineering team executing a migration phase
- **I want** each migration phase to have a defined, tested rollback strategy
- **So that** if a phase fails mid-execution, the team knows exactly how to
  return to a known-good state without data loss
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the phased migration plan, when the Migration Lead (or a dedicated
     Rollback Planner sub-role) defines rollback strategies, then each phase has
     a `rollback-strategy` entry containing: the trigger conditions for rollback
     (what failure mode or metric threshold activates it), the rollback steps in
     order, the estimated rollback duration, and the expected post-rollback
     state
  2. Given a destructive database operation in a phase (DROP, TRUNCATE, schema
     type change), when the rollback strategy is defined, then it must include:
     a confirmed backup timestamp, the restore command or procedure, and a
     verification step to confirm data integrity after restore
  3. Given a rollback strategy that requires coordination with external teams or
     vendors, when the Migration Lead defines it, then the strategy includes the
     contact information and SLA for the external party's involvement
  4. Given a phase where rollback is genuinely impossible (e.g., irreversible
     data migration with no backup), when the rollback strategy is defined, then
     the phase is flagged as `rollback: impossible` with a mandatory human
     operator sign-off requirement in the migration plan's pre-conditions
  5. Given the Migration Skeptic's review of rollback strategies (Story 6), when
     the Skeptic finds a phase with no rollback strategy, then it issues a
     `REJECTED` verdict citing missing rollback as a blocking issue — no phase
     may have an empty rollback strategy

- **Edge Cases**:
  - Rollback requires downtime: this is acceptable and must be documented as
    `rollback-requires-downtime: true` in the phase entry; stakeholders must be
    made aware in the plan's `## Communication Plan` section
  - Blue/green deployment is the rollback strategy for an infrastructure
    migration: valid — the rollback strategy is the switch back to blue; the
    plan must confirm the blue environment is preserved until green is verified
    stable
  - Rollback strategy exists but has never been tested: flagged as
    `rollback-tested: false`; Risk Assessor updates the risk score for that
    phase to `medium` minimum if rollback is untested

- **Notes**: Rollback strategy definition may be handled by the Migration Phaser
  as part of each phase definition (Story 3 AC2 already includes
  success-criteria per phase) or by a dedicated sub-role. The skill author
  should decide at implementation time; either approach is acceptable as long as
  every phase has a defined rollback strategy before reaching the Skeptic gate.

---

### Story 6: Migration Skeptic Gate

- **As a** Migration Lead finalizing a migration plan
- **I want** a Migration Skeptic to challenge the scope map, phasing, risk
  assessment, and rollback strategies before the plan is published
- **So that** no migration plan with underestimated scope, missing rollbacks, or
  unchallenged critical risks is treated as ready to execute
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all agent findings assembled (scope map, phased plan, risk
     assessment, rollback strategies), when submitted to the Migration Skeptic,
     then the Skeptic reviews them before the Migration Lead writes the final
     artifact
  2. Given the Migration Skeptic's review, when inspected, then it evaluates:
     (a) is the scope map complete — are there obvious components missing? (b)
     does the phasing sequence respect all hard dependencies? (c) are critical
     risks assessed accurately or understated? (d) does every phase have a
     defined, plausible rollback strategy? (e) are there "big bang" phases that
     should be split further?
  3. Given a phase with `rollback: impossible` and no human operator sign-off
     documented in the pre-conditions, when the Skeptic reviews it, then it
     issues a `REJECTED` verdict and requires the sign-off requirement to be
     added explicitly before approval
  4. Given a critical risk with mitigation strategy "monitor and respond," when
     the Skeptic reviews it, then it issues a `REJECTED` verdict and requires a
     specific, proactive mitigation step rather than a reactive one
  5. Given an `APPROVED` verdict, when the Migration Lead writes the final plan,
     then it includes the Skeptic's conditions (if any) in a `## Skeptic Review`
     section, and any Skeptic-required additions are reflected in the phase
     definitions
  6. Given the three-rejection deadlock protocol, when the Skeptic rejects the
     same deliverable three times, then the Migration Lead escalates to the
     human operator with a summary of all three rounds of objections and the
     team's attempts to address them

- **Edge Cases**:
  - Skeptic approves scope and phasing but rejects risk assessment: only the
    Risk Assessor revises; Scope Mapper and Migration Phaser outputs are not
    re-run unless the revised risk assessment reveals a scope or phasing gap
  - Skeptic requests an additional phase (e.g., "you need a phase-0 preparation
    step"): Migration Phaser adds the phase; Risk Assessor and rollback planner
    update their outputs for the new phase; Skeptic reviews the complete updated
    plan
  - Migration is genuinely low-risk (small database migration, well-understood
    process): Skeptic approves quickly without generating extensive conditions;
    fast approvals are expected for simple migrations

- **Notes**: Agent name: `migration-skeptic`. Model: `opus`. This is the most
  critical Skeptic gate in the plugin — migration failures are among the
  highest-cost production incidents. The Skeptic should apply extra scrutiny to
  any plan that does not include a phase-0 preparation step or has phases with
  `rollback: impossible`.

---

### Story 7: Migration Plan Artifact

- **As a** engineering team that has completed migration planning
- **I want** a structured migration plan artifact written to
  `docs/specs/{migration-id}/migration-plan.md`
- **So that** the plan is a durable, reviewable document that guides execution
  and provides evidence of due diligence
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all Skeptic-approved findings, when the Migration Lead writes the
     plan, then `docs/specs/{migration-id}/migration-plan.md` is created with
     YAML frontmatter: `type: "migration-plan"`, `migration-id`,
     `migration-type` (`database` | `framework` | `infrastructure` |
     `service-extraction`), `status` (`draft` | `reviewed` | `approved` |
     `in-progress` | `complete`), `migration-complexity`, `phase-count`,
     `created`, `updated`
  2. Given the plan body, when inspected, then it contains:
     `## Executive Summary`, `## Scope Map` (from Scope Mapper),
     `## Migration Phases` (each phase as a subsection), `## Risk Register` (all
     risk items from Risk Assessor), `## Rollback Strategies` (one per phase),
     `## Communication Plan` (stakeholders to notify, sign-off required steps),
     and `## Skeptic Review`
  3. Given the `## Migration Phases` section, when inspected, then each phase is
     a subsection (`### Phase N: {description}`) containing: components,
     pre-conditions, success-criteria, estimated-duration, rollback-strategy,
     and rollback-tested status
  4. Given the migration plan's `status: "approved"` and an artifact template
     for migration plans at `docs/templates/artifacts/migration-plan.md`, when
     `bash scripts/validate.sh` runs the F-series checks, then the template must
     be registered in `artifact-templates.sh`'s `expected_templates` list
  5. Given `bash scripts/validate.sh`, when run after the skill is created and
     the artifact template is added, then all 12/12 validators pass

- **Edge Cases**:
  - Migration plan written before Skeptic approval: `status: "draft"` until
    Skeptic approves; Migration Lead sets `status: "approved"` only on
    `APPROVED` verdict
  - Migration ID contains path separators: sanitize to slug before using in file
    path
  - Plan with 10+ phases: each phase is still a full subsection; no truncation;
    the Executive Summary may reference the full phase count and recommend
    reading phases in order

- **Notes**: Migration plan artifacts live in `docs/specs/{migration-id}/` to
  co-locate with any specs for systems being migrated. The artifact template at
  `docs/templates/artifacts/migration-plan.md` must be added and registered in
  the F-series validator to maintain 12/12 passing. This is analogous to how
  `sprint-contract.md` was added in P2-11 Story 1.

---

## Non-Functional Requirements

- **Validator stability**: 12/12 validators must pass; `plan-migration` must be
  in engineering classification lists; the new artifact template must be
  registered in the F-series validator
- **Rollback-first thinking**: The Migration Skeptic must treat any phase
  missing a rollback strategy as a blocking issue — this is non-negotiable
  regardless of migration complexity
- **Phase atomicity**: Each phase must be independently deployable and
  verifiable. The Migration Phaser must not produce phases that can only succeed
  or fail as a unit spanning multiple deploys
- **No live execution**: The skill plans migrations; it does not execute them.
  It never runs database commands, deploys infrastructure, or modifies
  production systems

## Out of Scope

- Automated migration script generation — the skill produces a plan, not
  executable migration scripts
- Integration with migration tooling (Liquibase, Flyway, Alembic, Terraform) —
  the skill produces markdown plans readable by engineers using those tools
- Real-time migration monitoring — the skill plans for monitoring but does not
  run or interpret monitoring dashboards
- Post-migration verification execution — the skill defines success criteria and
  verification steps; execution is performed by the engineering team
- Changes to existing skills — plan-migration is a standalone new skill;
  plan-implementation and build-product are not modified
