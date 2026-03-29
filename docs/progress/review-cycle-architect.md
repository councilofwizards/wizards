---
feature: "review-cycle"
team: "plan-product"
agent: "architect"
phase: "review"
status: "complete"
last_action: "Completed technical assessment of remaining P2 candidates (P2-02, P2-03, P2-07)"
updated: "2026-02-18"
---

# Technical Assessment: Remaining P2 Roadmap Candidates

## Executive Summary

After reading all three SKILL.md files, both ADRs, the full validation pipeline (4 validators, 10 checks), and all
progress files, my assessment is that **P2-03 (Progress Observability)** has the best effort-to-value ratio. It builds
almost entirely on existing infrastructure, requires minimal new components, and the roadmap's "medium" effort estimate
is possibly generous. P2-02 (Skill Composability) is genuinely large and carries a potential showstopper architectural
risk. P2-07 (Universal Shared Principles) is premature at 3 skills given that ADR-002 explicitly defers extraction to
the 8-skill threshold.

**Context**: P1-00 through P1-03, P2-01, P2-04, P2-05, P2-06 are all complete. The remaining P2 candidates are P2-02,
P2-03, and P2-07 (P2-08 is explicitly deferred per roadmap note).

---

## Candidate 1: P2-02 Skill Composability (Large)

### What Already Exists

- **Checkpoint protocol** (all 3 SKILL.md files): Structured YAML frontmatter checkpoints with `feature`, `team`,
  `agent`, `phase`, `status`, `last_action`, `updated`. This is the natural handoff mechanism between workflow steps.
- **Session recovery** (all 3 "Determine Mode" sections): Each skill already scans `docs/progress/` for incomplete
  checkpoints and resumes. This is primitive workflow state management.
- **Implicit handoff contracts**: `docs/specs/{feature}/spec.md` (plan output / build input) and
  `docs/progress/{feature}-summary.md` (session output) already serve as step I/O contracts by convention.
- **Quality gates**: Skeptic approval is non-negotiable in every skill. A workflow engine must respect these.

### What Needs to Be Built

1. **Workflow definition format**: YAML files in `docs/workflows/` defining step sequences (skill name, arguments,
   success condition, quality gate requirements).
2. **Workflow orchestrator skill** (`/run-workflow`): New SKILL.md that reads definitions and invokes skills
   sequentially. Must handle step completion detection, error pausing, context passing, and Skeptic gate enforcement.
3. **Handoff contract formalization**: The implicit convention (plan writes spec, build reads spec) must become a
   documented, reliable interface.
4. **New validator**: Workflow definition schema validator extending `scripts/validate.sh`.

### Complexity Assessment

The roadmap says **Large**. I agree -- possibly underestimated. The fundamental challenge is not orchestration logic but
**skill-to-skill invocation**. Each skill invocation is a separate Claude Code session. There is no documented mechanism
for one skill to programmatically invoke another skill. Skills are triggered by user slash commands, not by other
skills.

This is a potential **showstopper**: if the Claude Code plugin framework doesn't support skill chaining, the entire
feature must be re-scoped to a "manual workflow checklist" pattern (skill writes "next step" guidance, user invokes
manually).

### Architectural Risks

1. **Skill-to-skill invocation gap**: No existing mechanism. May require framework changes outside project scope.
2. **State consistency across sessions**: If a skill crashes mid-execution, checkpoint files may be inconsistent.
   Recovery logic for a multi-step workflow is substantially harder than single-skill recovery.
3. **Scope creep**: Linear workflows are tractable. Users will immediately want conditional branching, parallel steps,
   retry logic.
4. **Testing difficulty**: Multi-session workflow orchestration is very difficult to validate with the bash-based
   pipeline.

### Effort-to-Value: LOW

Genuinely Large+ effort, medium impact, significant architectural risk with a potential showstopper. Needs platform
research before even speccing.

---

## Candidate 2: P2-03 Progress Observability (Medium)

### What Already Exists

- **Checkpoint files already written**: Every agent in every skill writes structured YAML frontmatter to
  `docs/progress/{feature}-{role}.md`. The data is already being produced by all 3 skills.
- **Standardized checkpoint format**: Identical across all skills -- `feature`, `team`, `agent`, `phase`, `status`,
  `last_action`, `updated`. Machine-parseable today.
- **Summary files already written by convention**: Team leads write `docs/progress/{feature}-summary.md` (see
  `automated-testing-summary.md` as example -- structured with Summary, Files Created, Files Modified, Verification
  sections).
- **Cost summaries already written**: `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md` produced by team
  leads.
- **Progress template exists**: `docs/progress/_template.md` defines the expected structure.
- **Validation pipeline extensible**: `scripts/validate.sh` runs 4 validators (10 checks). Adding a
  `progress-checkpoint.sh` validator is straightforward using the existing patterns from `roadmap-frontmatter.sh`.

### What Needs to Be Built

1. **Status mode in "Determine Mode"**: Add a `status` argument handler to each SKILL.md (3 edits, ~15-20 lines each).
   The handler reads all `docs/progress/{feature}-*.md` files, parses YAML frontmatter, and generates a consolidated
   report. Key property: **no agent spawning** -- the team lead reads and summarizes alone.
2. **Status report format**: Define a standard output structure:
   ```
   Feature: {name} | Team: {skill} | Phase: {overall}
   Agents:
     - {role}: {phase}/{status} -- {last_action} (updated: {timestamp})
   Blockers: {list or "none"}
   ```
3. **End-of-session summary enforcement**: Formalize the existing convention that team leads write
   `{feature}-summary.md` on completion or interruption.
4. **Optional checkpoint validator**: A `progress-checkpoint.sh` script following the pattern of
   `roadmap-frontmatter.sh` (C1 field validation). Low effort given the existing framework.

### Complexity Assessment

The roadmap says **Medium**. This is accurate to generous. The work is:

- 3 SKILL.md edits (add status mode)
- 1 format definition (status report template)
- 1 formalization of existing convention (summary file requirement)
- 1 optional validator script

None of this requires new architectural patterns. It is purely additive, building on existing conventions and file
formats. The checkpoint data already exists; this feature makes it consumable.

### Architectural Risks

1. **Stale data**: Between checkpoints, the status view may lag. Mitigation: timestamps in frontmatter let the reader
   detect staleness. This is inherent to file-based state and acceptable.
2. **Format coupling**: Status reader depends on checkpoint format stability. Mitigation: format is already standardized
   across all 3 skills and validated by CI.
3. **Minimal overall risk**: Read-only feature adding a new consumption path for existing data. No new write patterns,
   no concurrency concerns, no new state management.

### Effort-to-Value: HIGH

Low-to-medium effort, medium impact, near-zero risk. Directly addresses the most common user frustration (waiting for
multi-agent teams with no visibility into progress). Leverages nearly 100% of existing infrastructure.

---

## Candidate 3: P2-07 Universal Shared Principles (Medium)

### What Already Exists

- **Shared content markers** (P2-05 complete): `<!-- BEGIN SHARED: principles -->` and
  `<!-- BEGIN SHARED: communication-protocol -->` in all 3 SKILL.md files.
- **Authoritative source designation** (ADR-002): `plan-product/SKILL.md` is canonical, with authoritative source
  comments after every BEGIN marker.
- **Automated drift detection** (P2-04 complete): `skill-shared-content.sh` validates B1 (byte-identity for principles),
  B2 (structural equivalence with skeptic name normalization for protocol), B3 (authoritative source comments). CI
  catches any drift automatically.
- **SKILL-SPECIFIC markers**: Already exist for build-product's Contract Negotiation Pattern.
- **ADR-002's 8-skill trigger**: Explicitly states "When the skill count exceeds 8, revisit this approach."

### What Would Need to Be Built

1. **Extended marker catalog**: Identify additional shared content beyond principles and communication protocol.
   Candidates: checkpoint protocol (similar but with per-skill phase enum variants), write safety conventions (identical
   pattern, different role names), failure recovery (identical across all 3).
2. **New markers and validators**: Add `<!-- BEGIN SHARED: checkpoint-protocol -->`, etc. Update
   `skill-shared-content.sh` to validate new blocks.
3. **Normalization rules**: Checkpoint protocol has per-skill variations (phase values differ:
   `research | design | review | complete` vs.
   `planning | contract-negotiation | implementation | testing | review | complete`). Need normalization logic like the
   existing skeptic name handling.
4. **Documentation**: Update ADR-002 or create ADR-003.

### Complexity Assessment

The roadmap says **Medium**. Technically Small-Medium, but the work has a **premature optimization** character:

- We have 3 skills. The existing drift detection (P2-05 markers + P2-04 CI) already catches inconsistencies
  automatically.
- Adding more markers doesn't reduce duplication -- it just makes more of it trackable. Actual duplication reduction
  only comes at the 8-skill threshold per ADR-002.
- The remaining shared content candidates (checkpoint, write safety, failure recovery) have more per-skill variation
  than principles/protocol, making byte-identity checks harder and requiring more normalization logic.
- The marginal value over current state (2 shared blocks tracked) is low.

### Architectural Risks

1. **Premature per ADR-002**: The architecture decision explicitly defers extraction until 8 skills. Expanding markers
   at 3 skills is incremental maintenance work, not architectural improvement.
2. **Scope ambiguity**: The P2-07 roadmap file doesn't exist. The `_index.md` says "extending shared content pattern"
   but this is underspecified. Does it mean more markers? Shared file extraction? A principles file agents read at
   runtime?
3. **Diminishing returns**: The highest-value shared content is already tracked. What remains has more per-skill
   variation, making synchronization validation more complex for less benefit.

### Effort-to-Value: LOW-MEDIUM

Small-medium effort, low marginal value. The heavy lifting for content deduplication is done (P2-05 + P2-04). This item
addresses a problem that isn't yet painful at 3 skills.

---

## Recommendation

**Build P2-03 (Progress Observability) next.**

| Factor                   | P2-02 Composability         | P2-03 Observability   | P2-07 Shared Principles   |
| ------------------------ | --------------------------- | --------------------- | ------------------------- |
| Existing infra leveraged | Partial                     | ~100%                 | Mostly                    |
| New components           | Significant                 | Minimal               | Small                     |
| Effort estimate accuracy | Large, possibly under       | Medium, possibly over | Medium, technically small |
| Architectural risk       | HIGH (showstopper possible) | NEAR-ZERO             | LOW                       |
| User value               | Medium (power users)        | Medium (all users)    | Low (dev convenience)     |
| **Effort-to-value**      | **LOW**                     | **HIGH**              | **LOW-MEDIUM**            |

P2-03 is the clear winner: lowest risk, highest readiness, leverages existing checkpoint infrastructure, and addresses a
real user pain point (no visibility during agent execution). Can likely be specced and built in a single plan+build
cycle.

P2-02 should be deferred until platform research answers the skill-to-skill invocation question. P2-07 should wait until
the skill count approaches the 8-skill threshold defined in ADR-002.
