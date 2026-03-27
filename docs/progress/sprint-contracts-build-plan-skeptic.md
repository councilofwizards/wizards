---
feature: "sprint-contracts"
team: "build-product"
agent: "plan-skeptic"
phase: "review"
status: "complete"
last_action: "Reviewed both architecture design AND formal implementation plan — APPROVED with one non-blocking observation"
updated: "2026-03-27T15:35:00Z"
---

# Plan Review: Sprint Contracts / Definition of Done (P2-11)

## Review Methodology

1. Read spec (11 success criteria) and stories (6 stories)
2. Read architecture design (docs/progress/sprint-contracts-architect.md)
3. Read formal implementation plan (docs/progress/sprint-contracts-build-impl-architect.md)
4. Read all 4 target files to verify insertion points against current content
5. Cross-referenced every spec success criterion against planned changes
6. Verified dependency ordering
7. Checked contract negotiation placement relative to plan-skeptic review gates
8. Verified custom template override convention
9. Checked for scope creep
10. Verified exact line-referenced anchors in the implementation plan match current file content

## Success Criteria Coverage

| SC# | Criterion | Plan Section | Covered? |
|-----|-----------|-------------|----------|
| 1 | Template exists with correct type and sections | Section 1 | YES |
| 2 | Validator includes sprint-contract entry | Section 5 | YES |
| 3 | plan-impl reads template, negotiates, writes, links frontmatter | Sections 2a, 2b, 2c | YES |
| 4 | plan-impl skips negotiation when signed contract exists | Section 2b (resumption guard) | YES |
| 5 | build-impl reads contract, injects into QS, evaluates PASS/FAIL/INCONCLUSIVE | Sections 3a, 3b, 3c | YES |
| 6 | build-impl graceful degradation (no contract = current behavior) | Section 3a | YES |
| 7 | build-product artifact detection + Stage 1 negotiation + Stage 2 injection | Sections 4b, 4c, 4d, 4e | YES |
| 8 | build-product edge case (Stage 1 skipped, no contract) | Section 4c edge case | YES |
| 9 | Custom template override with defensive reading | Section 6 | YES |
| 10 | No shared content changes | Plan does not touch shared/ | YES |
| 11 | --light mode preserves contract negotiation | Section 2b + current lightweight mode sections | YES |

All 11 success criteria are achievable with the planned changes.

## Dependency Ordering

template -> validator -> plan-implementation -> build-implementation -> build-product

- Template must exist before validator can check it: CORRECT
- Template must exist before plan-impl reads it: CORRECT
- plan-impl negotiation protocol defined before build-product mirrors it: CORRECT
- build-impl contract evaluation format defined before build-product copies it: CORRECT

No circular or missing dependencies.

## Contract Negotiation Placement

- **plan-implementation**: Contract Negotiation = Step 3, Plan-Skeptic Review = Step 4. CORRECT.
- **build-product Stage 1**: Contract Negotiation = Step 3, Plan-Skeptic Review = Step 4. CORRECT.

Both place negotiation BEFORE review, as required by the spec.

## Insertion Point Verification

### plan-implementation SKILL.md
- Section 2a (Setup step 2 extension): Current line 25 matches `2. Read docs/templates/artifacts/implementation-plan.md`. VALID.
- Section 2b (New Orchestration Flow step 3): Current steps at lines 111-119, inserting between step 2 (line 112) and step 3 (line 113). VALID.
- Section 2c (Frontmatter link): Current step 7 (line 117) is the artifact write step. VALID.

### build-implementation SKILL.md
- Section 3a (New Setup step): Current step 4 at line 27 ("Read implementation-plan"). VALID.
- Section 3b (QS prompt extension): Current QS prompt at lines 446-503, POST-IMPLEMENTATION GATE block at lines 469-477. VALID.
- Section 3c (Step 5 conditional): Current Step 4 (conditional) at line 132 for guidance injection. VALID.

### build-product SKILL.md
- Section 4a (Setup step 2 extension): Current line 25 reads implementation-plan template. VALID.
- Section 4b (Artifact detection table): Current table at lines 110-114. VALID.
- Section 4c (Stage 1 contract negotiation): Current Stage 1 steps at lines 200-211. VALID.
- Section 4d (Stage 2 contract injection): Current Stage 2 steps at lines 213-225. VALID.

### artifact-templates.sh
- Section 5: Current lines 20-23 match the expected content exactly. VALID.

All insertion points verified against current file content.

## Custom Template Override

- Lookup order: `.claude/conclave/templates/sprint-contract.md` -> `docs/templates/artifacts/sprint-contract.md`. Follows P2-13 convention.
- Defensive reading contract covers: directory absent, file absent, unreadable, empty, wrong type, malformed YAML, directory-instead-of-file. All Story 5 edge cases addressed.
- Pre-populated criteria from custom template included in Lead's initial proposal. CORRECT.

## Scope Creep Check

- No changes to plan-product: CONFIRMED
- No changes to shared/: CONFIRMED
- No new agents: CONFIRMED
- No sync script changes: CONFIRMED
- Story 6 deferred with Amendment Log section included for forward-compatibility: CONFIRMED
- No changes beyond the 5 files listed in the spec: CONFIRMED

## Implementation Plan Verification (Second Pass)

Reviewed formal implementation plan at docs/progress/sprint-contracts-build-impl-architect.md. This adds:
- Exact line-referenced anchors for each insertion point
- Full "Replace with" blocks with intended text
- Test strategy with validator checkpoints between each file
- Execution ordering (template -> validator -> validate -> plan-impl -> validate -> build-impl -> validate -> build-product -> validate)

### Anchor Verification

| Change | Anchor Text | Current File Line | Match? |
|--------|-------------|-------------------|--------|
| 3a | `2. Read \`docs/templates/artifacts/implementation-plan.md\`` | plan-implementation line 25 | YES |
| 3b | `2. impl-architect produces...` / `3. plan-skeptic reviews...` | plan-implementation lines 112-113 | YES |
| 4a | `4. **Read implementation-plan (REQUIRED).**` / `5. **Read technical-spec**` | build-implementation lines 27-28 | YES |
| 4b | `**Step 4 (conditional):**` | build-implementation line 132 | YES |
| 4c | `- Check for regressions: does existing functionality still work?` | build-implementation line 476 | YES |
| 5a | `2. Read \`docs/templates/artifacts/implementation-plan.md\`` | build-product line 25 | YES |
| 5b | Detection Paths table | build-product lines 110-114 | YES |
| 5c | Report format block | build-product lines 122-133 | YES |
| 5d | Stage 1 steps 1-8 | build-product lines 204-211 | YES |
| 5e | Stage 2 steps 1-2 | build-product lines 217-219 | YES |
| 5f | QS POST-IMPLEMENTATION GATE last item | build-product line 657 | YES |

All anchors verified.

### Step Renumbering Verification

- **plan-implementation Orchestration Flow**: Old 9 steps -> new 10 steps (contract negotiation inserted as step 3). Correct.
- **build-implementation Setup**: Old 10 steps -> new 11 steps (contract reading inserted as step 5). Correct.
- **build-product Stage 1**: Old 8 steps -> new 9 steps (contract negotiation inserted as step 3). Correct.

## Verdict

```
PLAN REVIEW: Sprint Contracts / Definition of Done (P2-11)
Verdict: APPROVED

Non-blocking Issues (should fix):
1. Change 5e (build-product Stage 2 contract injection): The plan says "inject it into
   the Quality Skeptic's spawn prompt" but Quality Skeptic may already be spawned from
   Stage 1 (current build-product line 219: "Spawn... quality-skeptic (if not already
   spawned)"). If QS persists across stages, prompt injection at spawn time is not
   possible. Suggestion: Clarify that when QS is already spawned from Stage 1, the
   contract should be sent via SendMessage at the start of Stage 2 instead of prompt
   injection. When QS is spawned fresh in Stage 2 (e.g., Stage 1 was skipped), use
   prompt injection as described.

Notes:
- All 11 success criteria map to specific plan sections with complete coverage
- Dependency ordering is correct with no circular references
- Contract negotiation is correctly placed before plan-skeptic review in both skills
- All insertion points verified against current file content — no stale references
- The prompt assembly order (guidance -> contract -> role prompt) is well-reasoned
- --light mode implicitly preserves contract negotiation because lightweight sections
  only affect model choices, not orchestration flow
- Story 6 deferral is clean — the template accommodates future amendments without
  requiring current SKILL.md changes
- Test strategy with validator checkpoints between each file is thorough
- Anchors use textual content, not just line numbers — resilient to minor reformatting
```
