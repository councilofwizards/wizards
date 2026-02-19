---
feature: "review-cycle-2"
team: "plan-product"
agent: "architect"
phase: "review"
status: "complete"
last_action: "Completed technical assessment of remaining P2 and P3 candidates post-P2-03"
updated: "2026-02-18"
---

# Technical Assessment: Next Feature Candidates (Post-P2-03)

## Context

P2-03 (Progress Observability) is now complete and implemented. P1-00 through P1-03, P2-01, P2-04, P2-05, P2-06 were previously complete. The remaining P2 candidates are P2-02 (Skill Composability), P2-07 (Universal Shared Principles), and P2-08 (Plugin Organization). P3 engineering items P3-01 through P3-07 exist, plus 12 P3 business skills.

My prior assessment from earlier today recommended P2-03, which is now done. This assessment covers what comes next.

---

## P2 Candidates

### P2-02: Skill Composability (Large) -- DEFER

**Status since last assessment**: Nothing has changed. The fundamental blocker remains: there is no documented mechanism for one skill to programmatically invoke another skill. Skills are triggered by user slash commands (`/plan-product`, `/build-product`, `/review-quality`). No API exists for skill-to-skill invocation within the Claude Code plugin framework.

**Feasibility**: LOW. The skill-to-skill invocation gap is a platform-level constraint, not something we can engineer around within the plugin. The two feasible alternatives are:
1. **Manual workflow checklist**: The "workflow skill" writes "next step: run /build-product feature-x" and the user invokes manually. This is barely a feature -- it is a formatted TODO list.
2. **Shell-level automation**: A script outside the plugin that invokes `claude /plan-product`, waits for completion, then invokes `claude /build-product`. This moves the orchestration outside the plugin, breaking the self-containment model.

Neither alternative delivers the value proposition described in the P2-02 roadmap item ("A user can define a plan-build-review pipeline that runs with a single command").

**Value**: Medium in theory (power users want chained workflows), but the viable implementations deliver low actual value.

**Risk**: HIGH. Showstopper risk on the invocation mechanism. Scope creep risk (users will want conditional logic, parallel steps, error recovery). Testing difficulty across multi-session workflows.

**Effort**: Large+. Even the "manual checklist" version requires workflow definition format, validation, and documentation. The full version may require platform changes.

**Recommendation**: Defer until Claude Code plugin framework provides a skill-to-skill invocation mechanism. Periodically check platform updates.

---

### P2-07: Universal Shared Principles (Medium) -- DEFER

**Has anything changed since last assessment?** Yes -- P2-05 (Content Deduplication) is now complete. The shared section marker system (`<!-- BEGIN SHARED: principles -->`, `<!-- BEGIN SHARED: communication-protocol -->`) is in place across all 3 SKILL.md files, with CI-enforced drift detection via `skill-shared-content.sh`.

**The question**: Is there architectural justification for expanding shared markers sooner than ADR-002's 8-skill threshold?

**Analysis**: The P2-05 shared sync mechanism does part of what P2-07 envisions -- it tracks and validates shared content across skills. But P2-07's value proposition is reducing the burden of maintaining shared content across many skills. At 3 skills, that burden is manageable:
- Edit 3 files for a principles change
- CI catches drift automatically
- The highest-value shared content (principles, communication protocol) is already tracked

**What would P2-07 add?** More shared markers for: checkpoint protocol (has per-skill phase enum variations), write safety conventions (has per-skill role name variations), failure recovery (nearly identical). Each new marker requires normalization rules because these sections have more per-skill variation than principles/protocol. The marginal value is low.

**Feasibility**: HIGH -- technically straightforward.

**Value**: LOW at 3 skills. The incremental maintenance burden is ~minutes per shared content change. The ROI doesn't justify the work until we have more skills.

**Risk**: LOW technically. Risk of premature optimization -- spending effort on a problem that isn't yet painful.

**Effort**: Small-Medium.

**Recommendation**: Defer until skill count reaches 5-6 (before the ADR-002 trigger of 8, but after enough skills exist to feel the maintenance burden). Revisit once the first business skill is built.

---

### P2-08: Plugin Organization (Medium) -- EXPLICITLY DEFERRED

The roadmap note is clear: "Defer plugin organization until 2+ business skills are built and validated." No P2-08 roadmap file even exists. Not a candidate.

---

## P3 Engineering Candidates

### P3-01: Custom Agent Roles (Large) -- NOT RECOMMENDED

**Feasibility**: Medium. Requires significant SKILL.md refactoring to separate role definitions from skill orchestration. The Skeptic non-customizability constraint adds complexity.

**Value**: Medium. Helps projects with non-standard team compositions (data pipelines, ML projects). But at 3 skills, the number of users hitting this limitation is small.

**Risk**: Medium. Increases SKILL.md complexity significantly. Could destabilize the currently working skill system.

**Effort**: Large. This is a framework-level change affecting all 3 skills.

**Dependencies**: Stack Generalization (P1-03, complete). But benefits from more skills existing first to understand the pattern better.

Not recommended as next item. Too large, too much framework disruption for current user base.

### P3-02: Onboarding Wizard (Small) -- RECOMMENDED

**Feasibility**: HIGH. Single-agent skill (no multi-agent team, no Skeptic). Detects stack, creates directory structure, generates starter files. All of these operations are well-understood patterns already performed in the Setup section of existing skills.

**Value**: MEDIUM. Directly reduces the onboarding friction that is the primary barrier to new user adoption. Every new user must currently read the README, understand the 3 skills, create the directory structure manually, and figure out the workflow. This is the highest-leverage small item on the roadmap.

**Risk**: NEAR-ZERO. Single-agent skill with no team coordination complexity. Idempotency requirement is the only design challenge, and it is straightforward (check if files exist before creating). Cannot break existing skills since it operates independently.

**Effort**: Small. Truly small. The skill needs:
1. A SKILL.md file (single agent, no team spawn)
2. Stack detection logic (already exists in every SKILL.md's Setup section)
3. Directory creation logic (already exists in every SKILL.md's Setup section)
4. Starter template generation (new but simple -- write markdown files)
5. Validation (add to existing pipeline)

**Dependencies**: None.

**Architectural note**: This would be the first single-agent skill (no Skeptic). This is architecturally significant -- it proves the framework supports non-team skills. However, this is also trivially simple to implement since a single-agent skill is just a SKILL.md without the team spawning section. The business-skill design guidelines document already acknowledges non-team patterns exist.

**This is the simplest skill we can build and it validates the single-agent skill pattern.**

### P3-03: Architecture & Contribution Guide (Small) -- NOT NOW

Documentation. Low impact. Write it when we have more skills and actual contributors. Not a priority.

### P3-04 through P3-07: Engineering Skills (Medium-Large) -- NOT NOW

These are substantial new skills (incident triage, tech debt review, API design, migration planning) that each require multi-agent teams with specialized roles. They are not simple validation candidates -- they are full skill implementations. Better to build simpler skills first.

---

## P3 Business Skills

### Which is simplest to build and validates the business-skill pattern?

The business-skill design guidelines document (`docs/architecture/business-skill-design-guidelines.md`) defines three collaboration patterns: Collaborative Analysis, Structured Debate, and Pipeline.

**The simplest pattern to implement is Pipeline** -- sequential handoffs with quality gates between stages. It is closest to the existing skill architecture (linear workflow with skeptic gates). The Pipeline skills are:
- `/build-sales-collateral` (P3-16)
- `/build-content` (P3-17)
- `/draft-investor-update` (P3-22)
- `/plan-onboarding` (P3-21)

**Among these, `/draft-investor-update` (P3-22) is the simplest candidate:**

1. **Smallest scope**: An investor update has a well-defined structure (metrics, progress, challenges, ask). The output format is constrained and predictable.
2. **Lowest domain complexity**: It primarily reads existing project data (roadmap, progress files, metrics) and synthesizes. Unlike sales or marketing, it doesn't require external market research or competitive analysis.
3. **Pipeline pattern**: Research (gather metrics and progress) -> Draft (write the update) -> Review (skeptic validates accuracy) -> Revise -> Final validation. This is nearly identical to the plan-product workflow.
4. **Two skeptics (per guidelines)**: Accuracy Skeptic (numbers, claims, milestone verification) + Narrative Skeptic (spin detection, omission, consistency with prior updates). Both are straightforward to implement.
5. **Effort**: Small-Medium per the roadmap.
6. **Validates all business-skill requirements**: assumptions section, confidence levels, falsification triggers, external validation checkpoints.
7. **Self-dogfooding potential**: We can use it on this project to draft investor updates about the Conclave framework itself, providing immediate real-world validation.

**However**: No P3 business skill has a roadmap file with details. The roadmap index lists them with effort estimates but the individual files don't exist. This means any business skill requires writing the roadmap item, then speccing it, then building it -- a full plan-build cycle.

---

## Ranked Recommendations

### Rank 1: P3-02 Onboarding Wizard (Small)

**Rationale**: Highest value-to-effort ratio on the entire backlog. Small effort, zero risk, no dependencies, immediate user impact. Reduces the #1 adoption barrier. Validates the single-agent skill pattern (no team, no skeptic). Can be specced and built in a single cycle.

### Rank 2: P3-22 Investor Update Skill (Small-Medium)

**Rationale**: Simplest business skill candidate. Pipeline pattern (closest to existing architecture). Well-defined output format. Validates the entire business-skill design pattern including multi-skeptic assignments, quality-without-ground-truth requirements, and the pipeline collaboration model. Provides self-dogfooding opportunity.

**Sequencing note**: P3-02 should come first. It's smaller, validates a different pattern (single-agent), and its output (better onboarding) benefits all subsequent skill development. P3-22 should follow as the first multi-agent business skill.

### NOT recommended next:
- **P2-02**: Blocked by platform constraint (no skill-to-skill invocation). Defer.
- **P2-07**: Premature at 3 skills per ADR-002. Defer to 5-6 skills.
- **P2-08**: Explicitly deferred until 2+ business skills exist.
- **P3-01**: Too large and disruptive for current stage.
- **P3-04 through P3-07**: Full multi-agent engineering skills. Not simple enough to be next.
