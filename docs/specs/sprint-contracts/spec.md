---
title: "Sprint Contracts / Definition of Done"
status: "approved"
priority: "P2"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Sprint Contracts / Definition of Done Specification

## Summary

Add a pre-execution Sprint Contract step to the implementation pipeline where
the Lead and Skeptic negotiate specific, measurable acceptance criteria before
code is written. The Quality Skeptic evaluates against these criteria as
explicit pass/fail items. Five files touched: 1 new artifact template, 3
SKILL.md modifications (plan-implementation, build-implementation,
build-product), 1 validator update. No new agents, no shared content changes.

## Problem

Currently, Skeptics review against general principles (INVEST, completeness,
testability). The Anthropic harness design paper identifies vague acceptance
criteria as the primary driver of poor evaluator performance. Evaluators talk
themselves into approving mediocre work when criteria are subjective. A Sprint
Contract makes each evaluation specific, measurable, and reproducible — directly
improving the reliability of every quality gate.

## Solution

### 1. Sprint Contract Artifact Template

**File**: `docs/templates/artifacts/sprint-contract.md`

```markdown
---
type: "sprint-contract"
feature: ""
status: "draft" # draft | negotiating | signed
signed-by: [] # e.g. ["planning-lead", "plan-skeptic"]
created: ""
updated: ""
---

# Sprint Contract: {Feature}

## Acceptance Criteria

<!-- Each criterion is a numbered, pass/fail-evaluable item. -->

1. {Criterion description} | Pass/Fail: [ ]
2. {Criterion description} | Pass/Fail: [ ]

## Out of Scope

- {Exclusion}

## Performance Targets

<!-- Optional. Measurable performance requirements. -->
<!-- No performance targets defined for this feature. -->

## Signatures

- **Planning Lead**: \***\*\_\_\*\*** (date: **\_\_**)
- **Plan Skeptic**: \***\*\_\_\*\*** (date: **\_\_**)

## Amendment Log

<!-- Appended on first amendment. -->
<!-- No amendments. -->
```

### 2. plan-implementation SKILL.md Modifications

**2a. Setup step 2 extension**: Read sprint contract template with custom
override lookup:

- First check `.claude/conclave/templates/sprint-contract.md` (custom override)
- If absent, read `docs/templates/artifacts/sprint-contract.md` (default)
- Full defensive reading contract per P2-13 convention

**2b. New Orchestration Flow step 3 — Contract Negotiation** (between plan
production and plan review):

- Resumption guard: if signed contract exists, skip
- Lead proposes criteria derived from spec success criteria and user story ACs
- Plan-skeptic reviews for specificity, completeness, measurability
- Max 3 rounds, same deadlock protocol as existing skeptic gates
- Writes signed contract to `docs/specs/{feature}/sprint-contract.md`
- Preserved in `--light` mode — contract gate is non-negotiable

**2c. Step 4 (plan review)**: Plan-skeptic reviews plan against both spec AND
sprint contract criteria.

**2d. Implementation plan frontmatter**: Includes
`sprint-contract: "docs/specs/{feature}/sprint-contract.md"` linking the two
artifacts.

### 3. build-implementation SKILL.md Modifications

**3a. New Setup step 5 — Contract Reading**: Read
`docs/specs/{feature}/sprint-contract.md` with graceful degradation:

- Absent → proceed silently, no contract-based evaluation
- Unsigned (draft/negotiating) → log warning, evaluate against spec only
- Signed → read and inject into Quality Skeptic prompt

**3b. Quality Skeptic prompt extension**: Sprint Contract Evaluation section in
POST-IMPLEMENTATION GATE review:

```
Sprint Contract Evaluation:
1. {Criterion text} — PASS / FAIL / INCONCLUSIVE
   Rationale: {one sentence}

Contract Verdict: ALL PASS / FAILED ({N} of {total} criteria failed)
```

Rules:

- Single FAIL = Verdict: REJECTED
- INCONCLUSIVE = non-blocking, note reason and how to verify post-deployment
- Zero criteria = note empty contract, evaluate against spec as fallback
- No contract = current behavior, no error

**3c. Spawn Step 5 (conditional) — Contract Injection**: Inject signed contract
into Quality Skeptic prompt only (not engineer prompts). Prompt assembly order:
(1) guidance block → (2) sprint contract block → (3) Quality Skeptic role
prompt.

### 4. build-product SKILL.md Modifications

**4a. Setup**: Read contract template with custom override lookup (same as
plan-implementation).

**4b. Artifact detection table**: New `sprint-contract` row:

| Stage        | Artifact Type   | Expected Path                             | Possible Results              |
| ------------ | --------------- | ----------------------------------------- | ----------------------------- |
| 1 (Planning) | sprint-contract | `docs/specs/{feature}/sprint-contract.md` | SIGNED / UNSIGNED / NOT_FOUND |

**4c. Stage 1 step 3 — Contract Negotiation**: After impl-architect produces
plan, BEFORE plan-skeptic review gate. Same protocol as plan-implementation.
Plan-skeptic then reviews plan against both spec and contract. Note: `signed-by`
names vary by context — `["planning-lead", "plan-skeptic"]` in normal flow,
`["implementation-coordinator", "quality-skeptic"]` when plan-skeptic is
unavailable.

**4d. Stage 2 — Contract Injection**: Inject signed contract into Quality
Skeptic prompt. Same format and evaluation rules as build-implementation.
Resume-safe: re-read from disk, don't re-negotiate.

**Edge case**: Stage 1 skipped (implementation-plan FOUND) but sprint-contract
NOT_FOUND → negotiate at start of Stage 2.

### 5. Validator Update

**File**: `scripts/validators/artifact-templates.sh`

Add `sprint-contract:sprint-contract` to `expected_templates` list. One line
change.

### 6. Custom Template Override

**Lookup order** (resolved once during Setup):

1. `.claude/conclave/templates/sprint-contract.md` (custom override)
2. `docs/templates/artifacts/sprint-contract.md` (default)

Full defensive reading contract per P2-13 convention. Pre-populated criteria in
custom templates are included in the Lead's initial proposal.

### 7. Amendment Protocol (Story 6, Deferred)

Template includes Amendment Log section for forward-compatibility. No SKILL.md
changes until Story 6 is implemented in a follow-on item.

## Constraints

1. No new agents — contract negotiation is a Lead ↔ plan-skeptic exchange
2. No shared content changes (principles.md, communication-protocol.md)
3. No sync script changes
4. All 12/12 validators must pass after changes
5. Graceful degradation — features without contracts experience zero behavior
   change
6. `--light` mode preserves contract negotiation in all skills
7. Contract gate is non-negotiable — cannot be skipped or weakened

## Out of Scope

- Schema enforcement for contract criteria format
- Contract versioning beyond Amendment Log
- Cross-feature contract inheritance
- Changes to `plan-product` (produces specs, not implementation plans)
- Story 6 (Contract Amendment Protocol) — deferred to follow-on item

## Files to Modify

| File                                                    | Change                                                                             |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `docs/templates/artifacts/sprint-contract.md`           | Create — sprint contract artifact template                                         |
| `plugins/conclave/skills/plan-implementation/SKILL.md`  | Setup step extension + Contract Negotiation step + frontmatter link                |
| `plugins/conclave/skills/build-implementation/SKILL.md` | Setup step + Quality Skeptic prompt extension + contract injection                 |
| `plugins/conclave/skills/build-product/SKILL.md`        | Artifact detection row + Stage 1 contract negotiation + Stage 2 contract injection |
| `scripts/validators/artifact-templates.sh`              | Add `sprint-contract:sprint-contract` to expected_templates                        |

## Success Criteria

1. `docs/templates/artifacts/sprint-contract.md` exists with
   `type: "sprint-contract"` and all required sections
2. `scripts/validators/artifact-templates.sh` includes
   `sprint-contract:sprint-contract` — validators pass
3. plan-implementation reads contract template (with custom override),
   negotiates contract, writes to `docs/specs/{feature}/sprint-contract.md`,
   links from implementation plan frontmatter
4. plan-implementation skips negotiation when signed contract exists (resumption
   guard)
5. build-implementation reads sprint contract, injects into Quality Skeptic
   prompt; Quality Skeptic evaluates each criterion as PASS/FAIL/INCONCLUSIVE
6. build-implementation degrades gracefully when no contract is present
7. build-product artifact detection includes sprint-contract row
   (SIGNED/UNSIGNED/NOT_FOUND); Stage 1 mirrors contract negotiation before plan
   review; Stage 2 injects contract into Quality Skeptic
8. build-product handles edge case where Stage 1 was skipped but no contract
   exists
9. Custom template override works via
   `.claude/conclave/templates/sprint-contract.md` with defensive reading
10. No shared content changes — `plugins/conclave/shared/` untouched
11. `--light` mode preserves contract negotiation in all three skills
