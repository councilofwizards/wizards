---
feature: "skill-architecture-redesign"
status: "complete"
completed: "2026-02-21"
---

# Skill Architecture Redesign -- Architect Checkpoint (Revised)

## Summary

Two-tier skill architecture design revised per Product Skeptic feedback. 8 Tier 1 granular skills, 2 Tier 2 composite skills, 2 utility skills, formal artifact contract system with frontmatter-based detection, Tier 2 invocation via Skill tool, failure propagation model, and interleaved migration plan with P2-07 as a hard Phase 1 dependency.

### Changes from v1

Addressed all 3 blocking issues, all 5 structural issues, and 4 of 5 advisory notes:

- **B1**: Added Skill tool as documented Tier 2 invocation mechanism. Added Phase 0 proof-of-concept.
- **B2**: Removed discover-product. 2 Tier 2 composites, not 3. All counts/tables updated.
- **B3**: Interleaved validator updates with every migration phase. Eliminated Phase 6 cleanup.
- **S4**: Artifact detection now uses frontmatter fields (type, feature, generated), feature-scoped. Precise algorithm documented.
- **S5**: Failure propagation defined: standalone escalates to user; inside composite escalates to Tier 2 lead first.
- **S6**: P2-07 moved to Phase 1 as a hard dependency.
- **S7**: run-task type contradiction resolved -- it is multi-agent with dynamic team composition.
- **S8**: idea-generator retyped from Builder to Scout. Sonnet retained with documented quality trade-off.
- **A9**: Concurrent Tier 2 invocation documented as unsupported.
- **A10**: ADR notes that SKILL.md files must translate archetypes into behavioral instructions.
- **A11**: setup-project changes specified (new directories, templates, CLAUDE.md updates).
- **A12**: ideate-product and manage-roadmap kept separate -- justification documented.
- **A13**: Skill discovery mechanism documented (directory-based scanning).

---

## Design: Two-Tier Skill Architecture

### Design Principles

1. **Context window efficiency.** Monolithic skills (plan-product at 390 lines, plan-sales at 1183 lines) load far more context than any single task requires. Granular skills scope context to exactly what the task needs.
2. **Reusability over repetition.** Market research logic exists in plan-product, plan-sales, and plan-hiring. Extracting it to a single research-market skill eliminates prompt duplication.
3. **Artifact contracts as integration points.** Skills communicate through typed artifacts with defined schemas, not through implicit file conventions.
4. **Consumer-owns-template.** The skill that READS an artifact defines its schema. The skill that PRODUCES it reads that schema during bootstrap. This prevents producer-consumer drift.
5. **Composites detect and skip.** Tier 2 skills check for existing artifacts (via frontmatter fields, feature-scoped) and skip completed stages.
6. **Skeptic is non-negotiable.** Every multi-agent skill has a skeptic presence. Granular skills with 2-3 agents use Lead-as-Skeptic. Skills with 4+ agents use a dedicated skeptic.
7. **Validation at every phase boundary.** Each migration phase that creates skills also updates validators. Validation must pass after every phase.
8. **Archetypes are behavioral, not labels.** Each SKILL.md must translate archetype assignments into specific behavioral prompts per agent-persona-performance.md. Listing "Scout" in a table is a design aid; the SKILL.md prompt is the actual implementation.

---

### Tier 2 Invocation Mechanism

Tier 2 composite skills invoke Tier 1 skills via Claude Code's **Skill tool**:

```
Skill(skill: "conclave:write-spec", args: "feature-name")
```

The Tier 2 SKILL.md instructs its lead agent to call the Skill tool for each stage in the pipeline. When a Tier 1 skill completes, control returns to the Tier 2 lead, which reads the produced artifact and decides whether to invoke the next stage.

**Context persistence**: The Tier 2 lead's context persists across Skill tool calls. The lead reads artifacts from disk between stages -- it does not need to hold Tier 1 outputs in memory.

**Checkpoint coexistence**: Tier 1 skills write checkpoints to `docs/progress/{feature}-{role}.md` scoped to their team name. Tier 2 leads write checkpoints to `docs/progress/{feature}-{tier2-skill}-lead.md`. No collision.

**Concurrency limitation**: Concurrent invocation of the same Tier 1 skill by multiple Tier 2 composites is unsupported. May produce artifact conflicts. This is acceptable for initial design -- document and do not solve. Users should not run /plan-product and another composite simultaneously.

---

### Tier 1: Granular Skills

#### 1. research-market

**Purpose**: Market analysis including competitive research, customer segmentation, and industry trends.

**Team Composition (3 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Orchestrate research, synthesize findings, perform skeptic review (Lead-as-Skeptic) |
| market-researcher | Scout | sonnet | Competitive landscape, market sizing, industry trends |
| customer-researcher | Scout | sonnet | Customer segments, pain points, buyer personas |

**Skeptic Placement**: Lead-as-Skeptic. Small team with well-scoped research outputs. Lead reviews and challenges findings before producing the final artifact. Cost-effective for a research-only skill.

**Input Artifacts**: user-context (if exists), prior research-findings (if exists)
**Output Artifacts**: research-findings (market analysis, competitive landscape, customer segments)

**Context Window Load**: Small (~150 lines of SKILL.md). Agents read project files but produce a single structured output.

**Pattern**: Hub-and-Spoke (simple: lead + 2 scouts)

---

#### 2. ideate-product

**Purpose**: Generate and evaluate feature ideas from research findings, roadmap gaps, and user needs.

**Team Composition (3 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Frame ideation scope, synthesize ideas, perform skeptic review (Lead-as-Skeptic) |
| idea-generator | Scout | sonnet | Divergent idea generation from research findings and roadmap gaps |
| idea-evaluator | Scout | sonnet | Evaluate ideas against market data, feasibility, and strategic fit |

**Skeptic Placement**: Lead-as-Skeptic. Ideas are evaluated and filtered, not shipped. The Lead challenges viability and prioritization before producing the output.

**idea-generator archetype rationale**: Typed as Scout (divergent, comparative, exploratory) rather than Builder (action-biased, forward-moving). Idea generation is a creative divergent task -- the Scout archetype's mandate to "present options with trade-offs, recommendations, confidence levels" aligns better than the Builder's "produce the simplest thing that works." Sonnet is retained because the Lead-as-Skeptic (Opus) filters and challenges the ideas. If ideation quality proves insufficient with Sonnet, the --light flag pattern can be inverted: standard mode uses Opus for idea-generator, --light uses Sonnet.

**Input Artifacts**: research-findings (required), roadmap-items (optional, for gap analysis)
**Output Artifacts**: product-ideas (ranked list with evidence and confidence levels)

**Context Window Load**: Small (~120 lines). Reads research findings, produces ideas.

**Pattern**: Hub-and-Spoke (simple)

**Why not merge with manage-roadmap**: ideate-product and manage-roadmap serve different purposes invoked at different frequencies. ideate-product runs when exploring new feature space -- creative, divergent work. manage-roadmap runs for reprioritization, dependency analysis, and status updates -- analytical, convergent work. The standalone manage-roadmap use case (invoked via plan-product's "reprioritize" argument or directly) is the most frequent lightweight invocation pattern. Merging would force the roadmap reprioritization path to load ideation prompts and agent definitions unnecessarily, recreating the context-waste problem this architecture solves. Kept separate.

---

#### 3. manage-roadmap

**Purpose**: Prioritize and maintain the roadmap. Optionally ingest new items from ideation or research artifacts.

**Team Composition (2 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Prioritize items, resolve conflicts, write roadmap updates (Lead-as-Skeptic) |
| analyst | Scout | sonnet | Analyze dependencies, estimate effort/impact, identify conflicts |

**Skeptic Placement**: Lead-as-Skeptic. Roadmap management is a prioritization exercise, not a production task. The Lead challenges priorities and dependency ordering.

**Input Artifacts**: product-ideas (optional), research-findings (optional), roadmap-items (reads current state)
**Output Artifacts**: roadmap-items (updated/new items with priorities, dependencies, statuses)

**Context Window Load**: Small (~100 lines). Reads existing roadmap, writes updates.

**Pattern**: Hub-and-Spoke (minimal)

---

#### 4. write-stories

**Purpose**: Write user stories from roadmap items using INVEST criteria, acceptance criteria, and modern story-writing techniques.

**Team Composition (3 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Orchestrate story writing, review for completeness |
| story-writer | Builder | sonnet | Write stories with INVEST criteria, acceptance criteria, edge cases |
| story-skeptic | Skeptic | opus | Challenge stories for testability, completeness, ambiguity |

**Skeptic Placement**: Dedicated skeptic. User stories are a critical handoff artifact between planning and implementation. Weak stories produce weak specs and weak code. Worth the cost of a dedicated skeptic.

**Input Artifacts**: roadmap-items (required, specific item(s) to write stories for), research-findings (optional, for context)
**Output Artifacts**: user-stories (INVEST-compliant stories with acceptance criteria)

**Context Window Load**: Medium (~200 lines). Story templates and INVEST framework add bulk.

**Pattern**: Hub-and-Spoke

---

#### 5. write-spec

**Purpose**: Produce a technical specification from user stories. Defines component boundaries, data models, API contracts, and implementation constraints.

**Team Composition (4 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Orchestrate spec production, coordinate architect and DBA |
| architect | Builder | opus | System design, component boundaries, interface definitions, ADRs |
| dba | Builder | opus | Data model, schema design, migration strategy |
| spec-skeptic | Skeptic | opus | Review spec for completeness, consistency, testability |

**Skeptic Placement**: Dedicated skeptic. Specs are the contract between planning and implementation. A weak spec produces rework in build-implementation.

**Input Artifacts**: user-stories (required), research-findings (optional), roadmap-items (optional, for priority context)
**Output Artifacts**: technical-spec (component design, data model, API contracts, ADRs)

**Context Window Load**: Large (~350 lines). This is the heaviest planning skill.

**Pattern**: Hub-and-Spoke (mirrors current plan-product's architect + DBA + skeptic pattern)

---

#### 6. plan-implementation

**Purpose**: Translate a technical spec into a concrete implementation plan: file-by-file changes, dependency ordering, interface definitions, test strategy.

**Team Composition (3 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Orchestrate planning, resolve ambiguities, review plan |
| impl-architect | Builder | opus | File-by-file plan, interface definitions, dependency graph |
| plan-skeptic | Skeptic | opus | Challenge plan for completeness, missing edge cases, spec conformance |

**Skeptic Placement**: Dedicated skeptic. The implementation plan is the last checkpoint before code is written. Gaps here become bugs later.

**Input Artifacts**: technical-spec (required), user-stories (optional, for traceability)
**Output Artifacts**: implementation-plan (file-by-file changes, interfaces, test strategy, dependency order)

**Context Window Load**: Medium (~200 lines). Reads the spec, produces a plan.

**Pattern**: Hub-and-Spoke

---

#### 7. build-implementation

**Purpose**: Execute the implementation plan. Write code following TDD, negotiate API contracts between frontend and backend, produce tested code.

**Team Composition (4 agents)**:
| Agent | Archetype | Model | Role |
|-------|-----------|-------|------|
| team-lead | Strategist | opus | Orchestrate implementation, manage contract negotiation |
| backend-eng | Builder | sonnet | Server-side code, TDD, API endpoints |
| frontend-eng | Builder | sonnet | Client-side code, TDD, API integration |
| quality-skeptic | Skeptic | opus | Pre-implementation gate (plan + contracts), post-implementation gate (code) |

**Skeptic Placement**: Dedicated skeptic with two gates. This is the current build-product's quality-skeptic pattern -- proven effective.

**Input Artifacts**: implementation-plan (required), technical-spec (required, for reference)
**Output Artifacts**: (code changes -- no formal artifact, but progress checkpoints written)

**Context Window Load**: Large (~350 lines). Contract negotiation pattern, two skeptic gates, TDD workflow all require substantial prompt space.

**Pattern**: Hub-and-Spoke (mirrors current build-product)

---

#### 8. review-quality

**Purpose**: Security audits, performance analysis, deployment readiness, regression testing. **Existing skill -- stays as-is with minimal changes.**

**Team Composition**: Unchanged from current review-quality (variable team based on mode: test-eng, devops-eng, security-auditor, ops-skeptic).

**Skeptic Placement**: Dedicated ops-skeptic. Unchanged.

**Input Artifacts**: technical-spec (optional), implementation-plan (optional)
**Output Artifacts**: (quality report -- written to progress files)

**Context Window Load**: Medium (~250 lines). Already well-scoped.

**Pattern**: Hub-and-Spoke (unchanged)

---

### Tier 2: Composite Skills

Composite skills chain Tier 1 skills via the Skill tool. They detect existing artifacts using frontmatter fields, skip completed stages, and pass artifacts between stages. The composite SKILL.md instructs the lead agent to invoke Tier 1 skills sequentially.

#### 1. plan-product (composite)

**Chains**: research-market -> ideate-product -> manage-roadmap -> write-stories -> write-spec

**Invocation mechanism**: The Tier 2 SKILL.md instructs the lead to call:
```
Skill(skill: "conclave:research-market", args: "{topic}")
Skill(skill: "conclave:ideate-product", args: "{topic}")
Skill(skill: "conclave:manage-roadmap", args: "{feature}")
Skill(skill: "conclave:write-stories", args: "{feature}")
Skill(skill: "conclave:write-spec", args: "{feature}")
```

**Behavior**:
- Detects existing artifacts at startup using frontmatter-based detection (see Artifact Detection Algorithm below).
- Each stage produces an artifact that the next stage consumes.
- Quality gates are enforced within each Tier 1 skill (each has its own skeptic). The composite does NOT add an additional skeptic layer.

**Arguments**: `[--light] [status | new <idea> | review <spec-name> | reprioritize | (empty for general review)]`
- "new <idea>": Full pipeline from research through spec.
- "review <spec-name>": Skip to write-spec for an existing spec.
- "reprioritize": Run manage-roadmap only.
- Empty: Assess which stages need running based on artifact state.

**Failure propagation**: See Failure Propagation Model below.

---

#### 2. build-product (composite)

**Chains**: plan-implementation -> build-implementation -> review-quality

**Invocation mechanism**:
```
Skill(skill: "conclave:plan-implementation", args: "{feature}")
Skill(skill: "conclave:build-implementation", args: "{feature}")
Skill(skill: "conclave:review-quality", args: "{feature}")
```

**Behavior**:
- Detects existing implementation-plan for the target feature. If one exists and status is "approved", skip plan-implementation.
- After build-implementation completes, automatically runs review-quality in its default mode.
- Each Tier 1 skill has its own skeptic gate.

**Arguments**: `[--light] [status | <spec-name> | review | (empty for next item)]`

**Failure propagation**: See Failure Propagation Model below.

---

### Utility Skills

#### 1. run-task

**Purpose**: Generic ad-hoc team for tasks that don't fit existing skills. The Lead reads the user's prompt, composes a team dynamically, and ensures a skeptic voice.

**Team Composition (dynamic, multi-agent)**:
- Lead (Opus, Strategist) always present
- Lead spawns 1-3 agents based on the task description
- At least one agent must be assigned skeptic duties (either a dedicated skeptic or Lead-as-Skeptic for simple tasks)

**Frontmatter type**: Default (multi-agent). No `type: single-agent` flag. The Lead is the skill's orchestrating agent; it spawns teammates dynamically based on the user's prompt.

**Input/Output Artifacts**: None (ad-hoc). The Lead reads the prompt and decides what to produce.

**Context Window Load**: Small SKILL.md (~100 lines), but the task-specific content varies.

**Pattern**: Dynamic Hub-and-Spoke. The Lead determines the pattern at runtime.

---

#### 2. wizard-guide

**Purpose**: Explain available skills, recommend which to use, and guide the user through the skill ecosystem.

**Team Composition**: Single agent. No team needed.

**Type**: `single-agent` in frontmatter.

**Input Artifacts**: None (reads plugin manifest and skill frontmatter).
**Output Artifacts**: None (conversational output only).

**Context Window Load**: Minimal.

---

### Artifact Contract System

#### Design: Consumer-Owns-Template

The CONSUMER of an artifact defines its expected schema. The PRODUCER reads that schema during its bootstrap phase and writes output conforming to it.

**Why consumer-owns**: The consumer knows what it needs. If write-spec needs user-stories in a specific format with acceptance criteria and priority fields, write-spec defines that format. The write-stories skill reads write-spec's template during bootstrap and produces stories matching the expected schema. This prevents the common failure mode where a producer writes in a format the consumer can't parse.

**Template location**: `docs/templates/artifacts/`

Each artifact type has a template file that defines:
1. YAML frontmatter schema (required/optional fields, types, allowed values)
2. Required markdown sections
3. Example content

#### Artifact Detection Algorithm

Tier 2 composites use this algorithm to determine whether a stage can be skipped. Detection is **frontmatter-based** and **feature-scoped** -- never based on file existence or mtime alone.

```
function artifact_exists(type, feature):
    # 1. Determine search path based on artifact type
    search_path = artifact_location_for(type, feature)
    # e.g., "docs/specs/{feature}/stories.md" for user-stories

    # 2. Check if file exists at the expected path
    if file does not exist at search_path:
        return NOT_FOUND

    # 3. Read YAML frontmatter from the file
    frontmatter = parse_frontmatter(search_path)

    # 4. Validate type field matches expected artifact type
    if frontmatter.type != type:
        return NOT_FOUND  # wrong artifact type at this path

    # 5. Validate feature field matches the target feature
    if frontmatter.feature != feature AND frontmatter.topic != feature:
        return NOT_FOUND  # artifact is for a different feature/topic

    # 6. Check staleness for research artifacts (optional expiry)
    if type == "research-findings" AND frontmatter.expires exists:
        if today > frontmatter.expires:
            return STALE  # Tier 2 lead decides whether to re-run

    # 7. Check status field (artifact must be in a usable state)
    if frontmatter.status in ["draft"]:
        return INCOMPLETE  # exists but not ready for consumption

    return FOUND  # artifact is valid, feature-matched, and usable

function should_skip_stage(tier1_skill, feature):
    output_type = tier1_skill.output_artifact_type
    result = artifact_exists(output_type, feature)

    if result == FOUND:
        return true   # skip this stage
    if result == STALE:
        return false  # re-run to refresh
    if result == INCOMPLETE:
        return false  # re-run to complete
    if result == NOT_FOUND:
        return false  # must run this stage
```

**Key properties**:
- Feature-scoped: research for "feature-X" does not satisfy research for "feature-Y"
- Type-validated: a spec.md that lacks `type: "technical-spec"` in frontmatter is treated as not found
- Status-aware: draft artifacts do not satisfy the detection check
- Staleness: only research-findings has an expiry field (30-day default). Other artifacts do not expire.

#### Artifact Type Definitions

##### 1. research-findings

**Location**: `docs/research/{topic}-research.md`
**Producer**: research-market
**Consumers**: ideate-product, write-stories, write-spec, plan-sales, plan-hiring
**Template owner**: ideate-product (primary consumer)

```yaml
# Template: docs/templates/artifacts/research-findings.md
---
type: "research-findings"
topic: ""                    # research topic or market segment
feature: ""                  # feature name if scoped to a specific feature
generated: ""                # YYYY-MM-DD
confidence: ""               # high | medium | low
expires: ""                  # YYYY-MM-DD (30 days from generation by default)
---

# Research Findings: {Topic}

## Executive Summary
<!-- 3-5 sentences. Key findings for quick consumption. -->

## Market Analysis
### Market Size
<!-- TAM/SAM/SOM with methodology and confidence levels -->

### Industry Trends
<!-- Trends, tailwinds, headwinds -->

## Competitive Landscape
<!-- Key competitors, strengths, weaknesses, positioning -->

## Customer Segments
<!-- Primary and secondary segments with pain points -->

## Data Sources
<!-- File paths and external references used -->

## Data Gaps
<!-- What's missing and why it matters -->

## Confidence Assessment
| Section | Confidence | Rationale |
|---------|------------|-----------|
```

##### 2. product-ideas

**Location**: `docs/ideas/{topic}-ideas.md`
**Producer**: ideate-product
**Consumers**: manage-roadmap
**Template owner**: manage-roadmap (primary consumer)

```yaml
# Template: docs/templates/artifacts/product-ideas.md
---
type: "product-ideas"
topic: ""
generated: ""
source_research: ""          # path to research-findings artifact
---

# Product Ideas: {Topic}

## Ideas
### Idea 1: {Title}
- **Description**: ...
- **User Need**: ...
- **Evidence**: [source reference]
- **Estimated Effort**: small | medium | large
- **Estimated Impact**: low | medium | high
- **Confidence**: H/M/L
- **Priority Score**: [effort * impact heuristic]

### Idea 2: {Title}
...

## Evaluation Criteria Used
<!-- How ideas were scored and ranked -->

## Rejected Ideas
<!-- Ideas considered but filtered out, with reasons -->
```

##### 3. roadmap-items

**Location**: `docs/roadmap/{id}-{slug}.md` (existing convention)
**Producer**: manage-roadmap
**Consumers**: write-stories, write-spec, plan-implementation
**Template owner**: Already defined by ADR-001 and existing roadmap convention. No change needed.

Existing frontmatter schema:
```yaml
---
title: ""
status: ""           # not_started | in_progress | ready_for_implementation | complete | blocked
priority: ""         # P1 | P2 | P3 | P4
category: ""
effort: ""           # small | medium | large
impact: ""           # low | medium | high
dependencies: []
created: ""
updated: ""
---
```

##### 4. user-stories

**Location**: `docs/specs/{feature}/stories.md`
**Producer**: write-stories
**Consumers**: write-spec, plan-implementation
**Template owner**: write-spec (primary consumer)

```yaml
# Template: docs/templates/artifacts/user-stories.md
---
type: "user-stories"
feature: ""
status: "draft"              # draft | reviewed | approved
source_roadmap_item: ""      # path to roadmap item
approved_by: ""
created: ""
updated: ""
---

# User Stories: {Feature}

## Epic Summary
<!-- 1-3 sentences describing the feature -->

## Stories

### Story 1: {Title}
- **As a** {user type}
- **I want** {capability}
- **So that** {benefit}
- **Priority**: must-have | should-have | could-have
- **Acceptance Criteria**:
  1. Given {context}, when {action}, then {result}
  2. ...
- **Edge Cases**:
  - {edge case}: {expected behavior}
- **Notes**: {implementation hints or constraints}

### Story 2: {Title}
...

## Non-Functional Requirements
<!-- Performance, security, accessibility requirements -->

## Out of Scope
<!-- Explicitly excluded from this feature -->
```

##### 5. technical-spec

**Location**: `docs/specs/{feature}/spec.md` (existing convention)
**Producer**: write-spec
**Consumers**: plan-implementation, build-implementation, review-quality
**Template owner**: Already defined by `docs/specs/_template.md`. No new artifact template needed.

##### 6. implementation-plan

**Location**: `docs/specs/{feature}/implementation-plan.md`
**Producer**: plan-implementation
**Consumers**: build-implementation
**Template owner**: build-implementation (primary consumer)

```yaml
# Template: docs/templates/artifacts/implementation-plan.md
---
type: "implementation-plan"
feature: ""
status: "draft"              # draft | approved | in_progress | complete
source_spec: ""              # path to technical spec
approved_by: ""
created: ""
updated: ""
---

# Implementation Plan: {Feature}

## Overview
<!-- 1-3 sentences: what is being built and the high-level approach -->

## File Changes
| Action | File Path | Description |
|--------|-----------|-------------|
| create | ... | ... |
| modify | ... | ... |

## Interface Definitions
### {Interface Name}
<!-- type signatures, API contracts, etc. -->

## Dependency Order
<!-- What must be built first, second, etc. Directed acyclic graph. -->
1. {Component A} -- no dependencies
2. {Component B} -- depends on A
3. ...

## Test Strategy
| Test Type | Scope | Description |
|-----------|-------|-------------|
| unit | {component} | {what is tested} |
| integration | {feature} | {what is tested} |

## Existing Patterns to Follow
<!-- References to existing code patterns the engineers should follow -->
- {pattern}: see {file path}

## Open Questions
<!-- Anything unresolved that engineers need to decide during implementation -->
```

---

### Failure Propagation Model

Tier 1 skills can fail in three ways: agent crash, skeptic deadlock (3 rejections), and context exhaustion. The escalation path depends on whether the Tier 1 skill is running standalone or inside a Tier 2 composite.

#### Path A: Standalone Tier 1 Invocation

When a user invokes a Tier 1 skill directly (e.g., `/write-spec feature-name`):

1. **Agent crash**: Tier 1 lead re-spawns the agent with checkpoint context (existing behavior).
2. **Skeptic deadlock**: After 3 rejections, Tier 1 lead escalates to the **user** with a summary of submissions, objections, and attempts. User decides: override, provide guidance, or abort.
3. **Context exhaustion**: Tier 1 lead re-spawns agent with checkpoint (existing behavior).

This is identical to the current behavior of monolithic skills.

#### Path B: Tier 1 Inside a Tier 2 Composite

When a Tier 2 composite invokes a Tier 1 skill via the Skill tool:

1. **Agent crash**: Handled internally by Tier 1 lead (same as Path A). Transparent to Tier 2.
2. **Skeptic deadlock**: After 3 rejections, Tier 1 skill completes with a failure status. The Tier 2 lead reads the failure output and has three options:
   - **Re-invoke with guidance**: The Tier 2 lead may re-invoke the Tier 1 skill with additional context or constraints in the args (e.g., "focus on the data model, the architecture is approved"). Maximum 1 re-invocation.
   - **Skip and continue** (only for non-critical stages): If the failed stage's output is optional for downstream stages, the Tier 2 lead may skip it and note the gap. Example: research-market fails, but the user has provided enough context in _user-data.md to proceed with ideation.
   - **Escalate to user**: If the failed stage is required (write-spec, plan-implementation, build-implementation) or the re-invocation also fails, the Tier 2 lead escalates to the user.
3. **Context exhaustion**: Handled internally by Tier 1 lead. Transparent to Tier 2.

**Failure signal mechanism**: When a Tier 1 skill completes after a deadlock escalation, it writes a checkpoint with `status: "escalated"` and `escalation_reason: "skeptic deadlock after 3 rejections"`. The Tier 2 lead reads this checkpoint to detect the failure.

**Maximum depth**: Tier 2 -> Tier 1 is the maximum nesting depth. Tier 1 skills never invoke other skills. Tier 2 skills never invoke other Tier 2 skills.

---

### Shared Content Strategy (P2-07 Hard Dependency)

The current shared content strategy (ADR-002) uses HTML comment markers and byte-identical duplication across skills. With the move to 12 skills (8 Tier 1 + 2 Tier 2 + 2 utility), this exceeds the 8-skill threshold defined in ADR-002 as the trigger for extraction.

**P2-07 is a hard dependency of this architecture.** It must be completed in Phase 1 of migration, before any new skills are created. The mechanism for shared content in the new architecture is:

**Approach**: Shared content remains duplicated inline in each SKILL.md (preserving self-containment per ADR-002), but extraction uses a build-time sync script rather than `<!-- INCLUDE -->` directives (which are not a standard markdown feature and Claude Code does not process them).

The sync script:
1. Reads `plugins/conclave/shared/principles.md` and `plugins/conclave/shared/communication-protocol.md` (authoritative sources).
2. Replaces content between `<!-- BEGIN SHARED: X -->` and `<!-- END SHARED: X -->` markers in all SKILL.md files.
3. Runs as part of `scripts/validate.sh` (check mode) and as a standalone `scripts/sync-shared-content.sh` (write mode).

This preserves the ADR-002 property that each SKILL.md is self-contained while making synchronization automated rather than manual. The B-series validators continue to work -- they verify that shared content is identical across all skills.

---

### Validator Impact (Interleaved with Migration)

Validators are updated in every migration phase, not deferred. Details per phase:

**Phase 0 (Proof of Concept)**: No validator changes needed.

**Phase 1 (Foundation + P2-07)**:
- A1: Accept optional `tier` and `chains` frontmatter fields.
- A4/B-series: Update for extracted shared content (sync script + marker checks).
- New F-series stub: Validate artifact templates exist in `docs/templates/artifacts/` with correct frontmatter schemas.

**Phase 2 (Extract from plan-product)**:
- A2: Add section requirements for new Tier 1 skills (research-market, ideate-product, manage-roadmap, write-stories, write-spec).
- A3: Validate spawn definitions for new Tier 1 skills.
- F-series: Validate producer-consumer links for research-findings, product-ideas, user-stories artifact types.
- Run `bash scripts/validate.sh` -- all checks pass.

**Phase 3 (Extract from build-product)**:
- A2: Add section requirements for plan-implementation, build-implementation.
- A3: Validate spawn definitions for new Tier 1 skills.
- F-series: Validate producer-consumer links for implementation-plan artifact type.
- Run `bash scripts/validate.sh` -- all checks pass.

**Phase 4 (Create composites)**:
- A2: Add section requirements for Tier 2 skills (different from Tier 1: "Artifact Detection Logic", "Skill Invocation Chain", "Failure Propagation" instead of "Spawn the Team").
- A3: For Tier 2 skills, validate Skill tool invocation syntax instead of spawn blocks. Check that `chains` frontmatter lists valid Tier 1 skill names.
- Run `bash scripts/validate.sh` -- all checks pass.

**Phase 5 (Utility skills)**:
- A2: Add section requirements for utility skills (run-task: dynamic spawn; wizard-guide: single-agent).
- A3: run-task validates dynamic spawn pattern; wizard-guide validates no spawn (single-agent).
- Run `bash scripts/validate.sh` -- all checks pass.

---

### Migration Path (Revised)

**Phase 0: Proof of Concept (prerequisite, must pass before proceeding)**

Create a minimal Tier 2 skill that invokes a minimal Tier 1 skill via the Skill tool. Validate:
1. The Skill tool (`Skill(skill: "conclave:tier1-skill", args: "test")`) successfully invokes the Tier 1 skill.
2. The Tier 2 lead's context persists after the Tier 1 skill completes.
3. Artifacts written by the Tier 1 skill are readable by the Tier 2 lead after invocation.
4. Checkpoint files from Tier 1 and Tier 2 do not collide.

If any of these fail, the Tier 2 layer needs a fallback approach: Tier 2 skills become monolithic skills with modular internal prompts (effectively the current pattern with better organization). Document the fallback in the ADR.

**Phase 1: Foundation + Shared Content Extraction (P2-07)**
1. Complete P2-07: Extract shared content to `plugins/conclave/shared/`, create sync script, update B-series validators.
2. Create `docs/templates/artifacts/` directory with artifact template files.
3. Create `docs/research/` and `docs/ideas/` directories (empty with `.gitkeep`).
4. Add `tier` and `chains` frontmatter fields to existing SKILL.md files (backward-compatible).
5. Update A1 validator to accept new frontmatter fields.
6. Create F-series validator stub for artifact template validation.
7. Update setup-project to scaffold new directories and reference new skill names (see setup-project Changes below).
8. Run `bash scripts/validate.sh` -- all checks pass.

**Phase 2: Extract Tier 1 Skills from plan-product**
1. Create research-market, ideate-product, manage-roadmap, write-stories, write-spec as independent Tier 1 SKILL.md files.
2. Sync shared content into new skills via sync script.
3. Update A2, A3, F-series validators for the new skills.
4. Test each Tier 1 skill independently.
5. Run `bash scripts/validate.sh` -- all checks pass.
6. Original plan-product remains functional (unchanged) during this phase.

**Phase 3: Extract Tier 1 Skills from build-product**
1. Create plan-implementation, build-implementation as independent Tier 1 SKILL.md files.
2. review-quality stays as-is (already well-scoped).
3. Sync shared content into new skills.
4. Update A2, A3, F-series validators for the new skills.
5. Test each Tier 1 skill independently.
6. Run `bash scripts/validate.sh` -- all checks pass.
7. Original build-product remains functional (unchanged) during this phase.

**Phase 4: Create Tier 2 Composites**
1. Rewrite plan-product as a Tier 2 composite that chains Tier 1 skills via Skill tool.
2. Rewrite build-product as a Tier 2 composite that chains Tier 1 skills via Skill tool.
3. Add Tier 2 validation rules to A2, A3: check for "Artifact Detection Logic" section, Skill tool invocation syntax, `chains` frontmatter validation.
4. Test end-to-end pipelines.
5. Run `bash scripts/validate.sh` -- all checks pass.

**Phase 5: Utility Skills**
1. Create run-task (multi-agent, dynamic team).
2. Create wizard-guide (single-agent).
3. Update A2, A3 validators for utility skill patterns.
4. Run `bash scripts/validate.sh` -- all checks pass.

---

### setup-project Changes

The setup-project skill must be updated in Phase 1 to scaffold the new architecture:

**New directories to create**:
- `docs/research/` (with `.gitkeep`)
- `docs/ideas/` (with `.gitkeep`)
- `docs/templates/` (with `.gitkeep`)
- `docs/templates/artifacts/` (with `.gitkeep`)

**New template files to create** (embedded in setup-project's SKILL.md):
- `docs/templates/artifacts/research-findings.md`
- `docs/templates/artifacts/product-ideas.md`
- `docs/templates/artifacts/user-stories.md`
- `docs/templates/artifacts/implementation-plan.md`

**CLAUDE.md template updates**:
- Update "Project Structure" section to include `docs/research/`, `docs/ideas/`, `docs/templates/`
- Update "Workflow" section to reference new granular skills:
  ```
  - Use `/research-market` for standalone market research
  - Use `/write-spec` for standalone spec writing from stories
  - Use `/plan-product` to run the full planning pipeline (research through spec)
  - Use `/build-product` to run the full build pipeline (plan through review)
  ```

**Roadmap _index.md**: No changes. Roadmap structure is unchanged.

---

### Skill Discovery Mechanism

Claude Code discovers skills in a plugin by **directory-based scanning**: it looks for `SKILL.md` files at `plugins/{plugin}/skills/{skill-name}/SKILL.md`. Adding a new skill directory with a valid SKILL.md is sufficient for discovery. The plugin manifest (`plugin.json`) does not enumerate skills and does not need updating when skills are added.

This means Phases 2-5 of migration only need to create the skill directories and SKILL.md files. No manifest changes required.

---

### Skill Taxonomy Summary

| Skill | Tier | Pattern | Agents | Skeptic | Context Load |
|-------|------|---------|--------|---------|--------------|
| research-market | 1 | Hub-and-Spoke | 3 | Lead-as-Skeptic | Small |
| ideate-product | 1 | Hub-and-Spoke | 3 | Lead-as-Skeptic | Small |
| manage-roadmap | 1 | Hub-and-Spoke | 2 | Lead-as-Skeptic | Small |
| write-stories | 1 | Hub-and-Spoke | 3 | Dedicated | Medium |
| write-spec | 1 | Hub-and-Spoke | 4 | Dedicated | Large |
| plan-implementation | 1 | Hub-and-Spoke | 3 | Dedicated | Medium |
| build-implementation | 1 | Hub-and-Spoke | 4 | Dedicated | Large |
| review-quality | 1 | Hub-and-Spoke | 2-4 | Dedicated | Medium |
| plan-product | 2 | Composite | (chains T1) | Per-stage | N/A |
| build-product | 2 | Composite | (chains T1) | Per-stage | N/A |
| run-task | Utility | Dynamic | 2-4 | Required | Small |
| wizard-guide | Utility | Single-Agent | 1 | None | Minimal |

**Total: 12 skills** (8 Tier 1 + 2 Tier 2 + 2 Utility)

### Business Skills Unchanged

The business skills (draft-investor-update, plan-sales, plan-hiring) are NOT part of this decomposition. They use different patterns (Pipeline, Collaborative Analysis, Structured Debate) that are already well-scoped and don't suffer from the monolithic context problem. They remain as Tier 1 skills with their existing patterns.

### Cost Comparison

**Current plan-product** (monolithic): 4 agents, all Opus = ~4x Opus cost per invocation, even for simple tasks like "reprioritize the roadmap."

**New architecture** (composites with Tier 1):
- Full pipeline (research through spec): ~14 agent-sessions across 5 Tier 1 skills, but Sonnet agents reduce cost per session
- Reprioritize only: 2 agents (1 Opus + 1 Sonnet) via manage-roadmap alone
- Write spec only: 4 agents via write-spec alone

The two-tier architecture enables cost-proportional invocation -- you only pay for the skills you need.

## Files Modified

- `docs/progress/skill-architecture-redesign-architect.md` -- This file (revised)
- `docs/architecture/ADR-004-two-tier-skill-architecture.md` -- Architecture Decision Record (revised)
