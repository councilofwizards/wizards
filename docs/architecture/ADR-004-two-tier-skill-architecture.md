---
title: "Two-Tier Skill Architecture with Artifact Contracts"
status: "accepted"
created: "2026-02-21"
updated: "2026-02-21"
superseded_by: ""
---

# ADR-004: Two-Tier Skill Architecture with Artifact Contracts

## Status

Accepted

## Context

The conclave plugin has 7 skills: 3 engineering skills (plan-product, build-product, review-quality), 3 business skills (draft-investor-update, plan-sales, plan-hiring), and 1 utility skill (setup-project). The engineering skills have a monolithic problem:

**1. Context window waste.** `plan-product` (390 lines of SKILL.md) loads researcher, architect, DBA, and skeptic agent prompts every invocation -- even when the user only wants to reprioritize the roadmap. `plan-sales` at 1183 lines and `plan-hiring` at 1561 lines demonstrate that skills grow large as they mature. Engineering skills will follow the same trajectory as they gain output templates and user-data handling.

**2. No reuse across skills.** Market research logic lives in plan-product's researcher prompt, plan-sales's market-analyst prompt, and plan-hiring's researcher prompt. Each is independently authored and maintained. Changes to research methodology require editing multiple skills.

**3. All-or-nothing invocation.** Users cannot run just the architecture phase of plan-product or just the implementation planning phase of build-product. Every invocation spawns the full team and runs the full pipeline.

**4. Implicit artifact contracts.** plan-product writes specs to `docs/specs/{feature}/spec.md`. build-product reads from the same path. But the schema is implicit -- there is no formal contract defining what fields the spec must contain. If plan-product's architect changes the spec structure, build-product's impl-architect may break.

**5. P2-02 (Skill Composability) identified this problem** but proposed workflow YAML files as the solution. That approach was parked per RC5 directive. The underlying need remains.

Key constraints:
- SKILL.md files must remain self-contained (ADR-002 principle). Each skill functions in isolation.
- The Skeptic role is non-negotiable in every multi-agent skill.
- Business skills (Pipeline, Collaborative Analysis, Structured Debate patterns) are already well-scoped and don't need decomposition.
- The validator infrastructure must be able to check the new structure, and validation must pass at every migration phase boundary.
- Migration must be incremental -- no big-bang rewrite.
- P2-07 (shared content extraction) is a hard dependency -- the skill count exceeds ADR-002's 8-skill threshold.

## Decision

### Part 1: Two-Tier Architecture

Decompose engineering skills into two tiers:

**Tier 1 (Granular)**: Single-purpose skills with tight context windows. Each skill has one team, produces one artifact type, and can run independently. 8 Tier 1 skills:

| Skill | Purpose | Agents | Skeptic |
|-------|---------|--------|---------|
| research-market | Market analysis, competitive research | 3 | Lead-as-Skeptic |
| ideate-product | Feature ideation from research | 3 | Lead-as-Skeptic |
| manage-roadmap | Roadmap prioritization and maintenance | 2 | Lead-as-Skeptic |
| write-stories | User stories with INVEST criteria | 3 | Dedicated |
| write-spec | Technical specification | 4 | Dedicated |
| plan-implementation | Spec to implementation plan | 3 | Dedicated |
| build-implementation | Execute implementation plan | 4 | Dedicated |
| review-quality | Quality audits (existing, unchanged) | 2-4 | Dedicated |

**Tier 2 (Composite)**: Orchestration skills that chain Tier 1 skills via Claude Code's Skill tool. No team of their own -- they invoke Tier 1 skills sequentially, passing artifacts between them. 2 Tier 2 skills:

| Skill | Chains |
|-------|--------|
| plan-product | research-market -> ideate-product -> manage-roadmap -> write-stories -> write-spec |
| build-product | plan-implementation -> build-implementation -> review-quality |

**Tier 2 invocation mechanism**: The Tier 2 SKILL.md instructs its lead to invoke Tier 1 skills via `Skill(skill: "conclave:{tier1-name}", args: "{feature}")`. Control returns to the Tier 2 lead after each stage completes. The lead reads the produced artifact from disk and decides whether to invoke the next stage.

**Tier 2 artifact detection**: Composite skills check for existing artifacts using frontmatter-based, feature-scoped detection (see Part 2) and skip completed stages. Running `/plan-product` when a spec already exists for the target feature skips research, ideation, and story writing.

**Utility skills** (2): `run-task` (generic multi-agent ad-hoc team with dynamic composition) and `wizard-guide` (single-agent skill explainer).

**Concurrency limitation**: Concurrent invocation of the same Tier 1 skill by multiple Tier 2 composites is unsupported and may produce artifact conflicts. This is acceptable for the initial design -- users should not run composites simultaneously.

**Total: 12 skills** (8 Tier 1 + 2 Tier 2 + 2 Utility). Business skills (3) and setup-project (1) are unchanged, bringing the plugin total to 16.

### Part 2: Artifact Contract System

Skills communicate through typed artifacts with defined schemas stored in `docs/templates/artifacts/`.

**Consumer-owns-template pattern**: The skill that READS an artifact defines the template. The skill that PRODUCES it reads that template during bootstrap. This ensures the producer writes what the consumer needs.

6 artifact types:

| Artifact | Location | Producer | Primary Consumer |
|----------|----------|----------|------------------|
| research-findings | `docs/research/{topic}-research.md` | research-market | ideate-product |
| product-ideas | `docs/ideas/{topic}-ideas.md` | ideate-product | manage-roadmap |
| roadmap-items | `docs/roadmap/{id}-{slug}.md` | manage-roadmap | write-stories |
| user-stories | `docs/specs/{feature}/stories.md` | write-stories | write-spec |
| technical-spec | `docs/specs/{feature}/spec.md` | write-spec | plan-implementation |
| implementation-plan | `docs/specs/{feature}/implementation-plan.md` | plan-implementation | build-implementation |

Each template defines YAML frontmatter schema, required sections, and example content.

**Artifact detection algorithm**: Tier 2 composites determine whether to skip a stage using frontmatter-based, feature-scoped detection:

1. Check if the expected artifact file exists at the type-specific path for the target feature.
2. Parse YAML frontmatter and validate: `type` field matches expected artifact type, `feature` or `topic` field matches the target feature.
3. For research-findings only: check the `expires` field (30-day default). If expired, mark as STALE.
4. Check `status` field: draft artifacts do not satisfy the detection check.
5. Result: FOUND (skip stage), STALE (re-run to refresh), INCOMPLETE (re-run to complete), or NOT_FOUND (must run).

Key properties: feature-scoped (research for feature-X does not satisfy feature-Y), type-validated, status-aware, with staleness only for research artifacts.

### Part 3: Skeptic Placement Strategy

- **Skills with 2-3 agents**: Lead-as-Skeptic. The Lead performs skeptic duties (research-market, ideate-product, manage-roadmap). Cost-efficient; appropriate when outputs are filtered/evaluated rather than shipped.
- **Skills with 4+ agents or high-stakes outputs**: Dedicated skeptic agent (write-stories, write-spec, plan-implementation, build-implementation). Worth the cost when the output is a critical handoff artifact.
- **Business skills**: Unchanged. Dual-skeptic pattern remains.

### Part 4: Failure Propagation

Tier 1 skills can fail via agent crash, skeptic deadlock, or context exhaustion. The escalation path depends on invocation context:

**Standalone invocation** (user invokes Tier 1 directly): Current behavior -- agent crash is re-spawned, skeptic deadlock after 3 rejections escalates to the user, context exhaustion triggers re-spawn with checkpoint.

**Inside a Tier 2 composite**: Agent crash and context exhaustion are handled internally by Tier 1 (transparent to Tier 2). Skeptic deadlock produces a checkpoint with `status: "escalated"`. The Tier 2 lead reads this status and has three options: (a) re-invoke the Tier 1 skill with additional guidance (max 1 retry), (b) skip the stage if non-critical and downstream stages can proceed without it, (c) escalate to the user if the stage is required or the retry also fails.

**Maximum nesting depth**: Tier 2 -> Tier 1. Tier 1 skills never invoke other skills. Tier 2 skills never invoke other Tier 2 skills.

### Part 5: Frontmatter Extensions

SKILL.md frontmatter gains two optional fields:

```yaml
---
name: plan-product
tier: 2                      # 1 | 2 | utility (optional, default: 1)
chains:                      # Tier 2 only: ordered list of Tier 1 skills
  - research-market
  - ideate-product
  - manage-roadmap
  - write-stories
  - write-spec
---
```

### Part 6: Archetype-to-Behavioral-Prompt Requirement

Agent archetypes (Strategist, Builder, Scout, Skeptic, Verifier) from `docs/agent-persona-performance.md` are used in this ADR as design-level type assignments. Per the persona guide: "Behavioral prompts, not aspirational labels." Each SKILL.md must translate archetype assignments into specific behavioral instructions in the spawn prompts. Listing "Scout" in an architecture table is a design aid; the SKILL.md's actual agent prompt is the implementation.

### Part 7: Migration Path

5-phase incremental migration preceded by a proof-of-concept. Validator updates are interleaved with skill creation -- validation must pass at every phase boundary.

**Phase 0: Proof of Concept**
- Create a minimal Tier 2 skill that invokes a minimal Tier 1 skill via `Skill(skill: "conclave:tier1-test", args: "test")`.
- Validate: (a) Skill tool invocation works, (b) Tier 2 lead context persists, (c) Tier 1 artifacts are readable by Tier 2 lead, (d) checkpoints do not collide.
- If any fail, fallback: Tier 2 skills become monolithic skills with modular internal prompts.

**Phase 1: Foundation + P2-07 (Shared Content Extraction)**
- Complete P2-07: extract shared content to `plugins/conclave/shared/`, create sync script, update B-series validators.
- Create artifact template files in `docs/templates/artifacts/`.
- Create `docs/research/` and `docs/ideas/` directories.
- Add `tier` and `chains` frontmatter to existing skills. Update A1 validator.
- Create F-series validator stub for artifact templates.
- Update setup-project to scaffold new directories and reference new skills.
- `bash scripts/validate.sh` must pass.

**Phase 2: Extract Tier 1 Skills from plan-product**
- Create research-market, ideate-product, manage-roadmap, write-stories, write-spec.
- Sync shared content. Update A2, A3, F-series validators.
- Test each independently. `bash scripts/validate.sh` must pass.
- Original plan-product remains functional (unchanged) during this phase.

**Phase 3: Extract Tier 1 Skills from build-product**
- Create plan-implementation, build-implementation. review-quality stays as-is.
- Sync shared content. Update A2, A3, F-series validators.
- Test each independently. `bash scripts/validate.sh` must pass.
- Original build-product remains functional (unchanged) during this phase.

**Phase 4: Create Tier 2 Composites**
- Rewrite plan-product and build-product as Tier 2 composites.
- Add Tier 2 validation rules (A2, A3): check "Artifact Detection Logic" section, Skill tool invocation syntax, `chains` frontmatter validation.
- Test end-to-end pipelines. `bash scripts/validate.sh` must pass.

**Phase 5: Utility Skills**
- Create run-task (multi-agent, dynamic team) and wizard-guide (single-agent).
- Update A2, A3 validators for utility skill patterns.
- `bash scripts/validate.sh` must pass.

### Part 8: Skill Discovery

Claude Code discovers skills via directory-based scanning: it looks for `SKILL.md` files at `plugins/{plugin}/skills/{skill-name}/SKILL.md`. Adding a new skill directory with a valid SKILL.md is sufficient for discovery. The plugin manifest (`plugin.json`) does not enumerate skills and does not need updating.

## Alternatives Considered

### Keep monolithic skills

Status quo. plan-product stays as one large skill with 4 agents. build-product stays as one large skill with 4 agents.

Rejected because the context window problem worsens as skills gain output templates and user-data handling (business skills average 1160 lines vs engineering skills at 434 lines -- engineering skills will grow similarly). The cost-proportional invocation problem is unsolvable without decomposition.

### Split without composition layer (Tier 1 only)

Create granular skills but do not create Tier 2 composites. Users invoke individual skills directly: `/research-market`, then `/write-stories`, then `/write-spec`.

Rejected because it pushes orchestration burden to the user. The current `/plan-product` workflow (one command from idea to spec) is a key value proposition. Removing it forces users to understand the artifact pipeline and invoke skills in the correct order. Composites preserve the one-command experience while enabling granular invocation for advanced users.

### Workflow YAML files (P2-02 original proposal)

Define skill chains in YAML files (e.g., `docs/workflows/plan-to-build.yml`) with a `/run-workflow` skill that reads and executes them.

Rejected because it adds a new abstraction layer (YAML workflows) on top of the existing abstraction layer (SKILL.md files). The Tier 2 composite pattern achieves the same result without introducing a new file format, parser, or validation category. Composites are just SKILL.md files -- the existing validator infrastructure handles them.

### Microservice-style event-driven architecture

Skills publish artifacts as events; other skills subscribe to artifact types. A new skill automatically integrates with the pipeline by subscribing to the right event.

Rejected because it is over-engineered for the current scale (12 skills). The conclave plugin operates on static markdown files with no runtime event system. Introducing event-driven architecture would require building infrastructure that doesn't exist and isn't needed. Direct skill invocation via composites is simpler and sufficient.

### Three Tier 2 composites (including discover-product)

A third Tier 2 composite chaining research-market -> ideate-product -> manage-roadmap for "discovery without spec commitment."

Rejected because it provides no behavior that cannot be achieved by either: (a) running Tier 1 skills directly (research-market, ideate-product are independently invocable), or (b) running /plan-product which naturally stops after manage-roadmap if no feature needs stories/specs via artifact detection. The architecture supports adding Tier 2 composites later if users demonstrate the need.

## Consequences

### Positive

- **Cost-proportional invocation.** Users pay only for the skills they need. Reprioritizing the roadmap costs 2 agent-sessions (manage-roadmap) instead of 4 (full plan-product team).
- **Tight context windows.** Each Tier 1 skill loads only the context relevant to its task. research-market doesn't load architecture prompts. write-spec doesn't load market research prompts.
- **Reusable research.** research-market is invoked by plan-product and can be invoked standalone. One research methodology, maintained in one place.
- **Formal artifact contracts.** Consumer-owns-template with frontmatter-based, feature-scoped detection eliminates implicit schema drift between producers and consumers.
- **Incremental migration.** Each phase is independently deployable with validation passing at every boundary. No broken intermediate states.
- **Existing business skills unaffected.** Pipeline, Collaborative Analysis, and Structured Debate patterns remain unchanged.
- **Defined failure propagation.** Tier 1 failures inside composites escalate through the Tier 2 lead before reaching the user, enabling re-invocation with additional guidance.

### Negative

- **More files.** 12 skills (8 + 2 + 2) vs. current 7. More SKILL.md files to maintain, more validator rules, more documentation. Plugin total goes from 7 to 16 skills.
- **Validator updates required in every phase.** A-series validators need per-type section lists (Tier 1, Tier 2, utility). New F-series validators for artifact contracts. B-series updates for shared content extraction. This is significant engineering effort interleaved across 5 migration phases.
- **Composite orchestration complexity.** Tier 2 skills must implement artifact detection logic, Skill tool invocation chains, and failure propagation. This is new logic that doesn't exist today.
- **P2-07 becomes a hard prerequisite.** Shared content extraction must happen in Phase 1, not at leisure. This front-loads a significant work item.
- **Tier 2 invocation depends on Skill tool behavior.** Phase 0 proof-of-concept must validate that the Skill tool supports the chaining pattern. If it does not, the fallback (Tier 2 as monolithic skills with modular prompts) changes the implementation significantly.
- **Testing surface area.** Each Tier 1 skill needs independent testing. Each Tier 2 composite needs end-to-end pipeline testing. Total test effort increases.
