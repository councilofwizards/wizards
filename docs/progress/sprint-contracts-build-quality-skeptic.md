---
feature: "sprint-contracts"
team: "build-product"
agent: "quality-skeptic"
phase: "review"
status: "complete"
last_action: "Post-implementation quality review of P2-11 Sprint Contracts"
updated: "2026-03-27T15:00:00Z"
---

# QUALITY REVIEW: P2-11 Sprint Contracts

**Gate**: POST-IMPLEMENTATION **Verdict**: APPROVED

## Success Criteria Evaluation

### SC-1: Sprint contract template exists with correct type and sections

**PASS**

`docs/templates/artifacts/sprint-contract.md` exists with:

- Frontmatter: `type: "sprint-contract"`, `feature`, `status` (draft/negotiating/signed), `signed-by`, `created`,
  `updated`
- Sections: Acceptance Criteria, Out of Scope, Performance Targets, Signatures, Amendment Log
- All match spec section 1 exactly

### SC-2: Validator includes sprint-contract — validators pass

**PASS**

`scripts/validators/artifact-templates.sh` line 24: `sprint-contract:sprint-contract` present in `expected_templates`.
F1 validator output:
`[PASS] F1/artifact-templates: All artifact templates exist with correct type fields (5 templates checked)`. Note:
A-series failures are all from `php-tomes` plugin (separate plugin, pre-existing), not from conclave changes.

### SC-3: plan-implementation reads template, negotiates contract, writes to specs, links from frontmatter

**PASS**

- Setup step 2 (line 25-28): Reads contract template with custom override lookup and full defensive reading contract
- Orchestration step 3 (lines 116-122): Contract Negotiation gate with Lead proposes → plan-skeptic reviews → max 3
  rounds → write signed contract to `docs/specs/{feature}/sprint-contract.md`
- Orchestration step 8 (line 127): Frontmatter MUST include `sprint-contract: "docs/specs/{feature}/sprint-contract.md"`

### SC-4: plan-implementation skips negotiation when signed contract exists

**PASS**

Orchestration step 3, first bullet (line 117): Resumption guard checks if `docs/specs/{feature}/sprint-contract.md`
exists with `status: "signed"` — if so, reads it and skips to step 4. Includes user-facing output message.

### SC-5: build-implementation reads contract, injects into QS prompt; QS evaluates PASS/FAIL/INCONCLUSIVE

**PASS**

- Setup step 5 (lines 28-31): Reads sprint contract with three-way graceful degradation (absent/unsigned/signed)
- Spawn Step 5 (lines 136-144): Conditional injection into Quality Skeptic prompt only, with correct assembly order:
  guidance → contract → role prompt
- QS spawn prompt (lines 490-511): Sprint Contract Evaluation section with exact format from spec: criterion text —
  PASS/FAIL/INCONCLUSIVE, rationale, Contract Verdict line
- Rules match spec: single FAIL = REJECTED, INCONCLUSIVE = non-blocking, zero criteria = fallback to spec, no contract =
  current behavior

### SC-6: build-implementation degrades gracefully when no contract present

**PASS**

- Setup step 5 (line 29): "File absent → proceed silently, no contract-based evaluation"
- Setup step 5 (line 30): Unsigned contract → log warning, proceed without contract-based evaluation
- QS prompt (line 511): "If NO sprint contract is provided, perform your standard review (current behavior). No error,
  no warning."

### SC-7: build-product artifact detection includes sprint-contract; Stage 1 mirrors negotiation; Stage 2 injects

**PASS**

- Detection table (line 116): `sprint-contract` row with `SIGNED / UNSIGNED / NOT_FOUND` states
- Detection logic (lines 120-123): Three-way detection with correct semantics
- Artifact detection report template (line 138): Includes `sprint-contract: [SIGNED / UNSIGNED / NOT_FOUND]`
- Stage 1 step 3 (lines 216-223): Contract negotiation mirroring plan-implementation with identical protocol
- Stage 1 step 8 (line 228): Frontmatter includes `sprint-contract` link
- Stage 2 step 2b (lines 238-244): Contract injection into QS prompt with same format as build-implementation

### SC-8: build-product handles edge case (Stage 1 skipped, no contract)

**PASS**

- Stage 1 step 3 (line 222): "Edge case: If artifact detection result was `implementation-plan: FOUND` but
  `sprint-contract: NOT_FOUND`, run this negotiation at the start of Stage 2 instead, using quality-skeptic as the
  signing skeptic"
- Stage 2 step 1 (lines 235-236): Explicit contract check and negotiation when Stage 1 was skipped
- `signed-by` correctly uses `["implementation-coordinator", "quality-skeptic"]` per spec section 4c

### SC-9: Custom template override via `.claude/conclave/templates/sprint-contract.md`

**PASS**

- plan-implementation Setup step 2 (lines 26-28): Custom override lookup with full defensive reading contract
- build-product Setup step 2 (lines 26-28): Identical lookup and defensive reading contract
- Defensive contract covers: absent → default silently, unreadable/empty → warn + fallback, wrong type → warn +
  fallback, `.claude/conclave/` absent → default silently

### SC-10: No shared content changes

**PASS**

`git diff plugins/conclave/shared/` returns empty — no modifications to shared principles or communication protocol.

### SC-11: `--light` mode preserves contract negotiation

**PASS**

- plan-implementation (line 122): "The contract negotiation step is preserved in `--light` mode — the contract gate is
  non-negotiable regardless of mode."
- build-product (line 223): "The contract negotiation step is preserved in `--light` mode — non-negotiable regardless of
  mode."
- build-implementation: `--light` mode section (lines 125-129) does not touch contract reading or QS prompt injection —
  both remain active.

## Critical Ordering Check

### plan-implementation

- Step 2: impl-architect produces plan
- **Step 3: Contract Negotiation** (GATE)
- Step 4: plan-skeptic reviews plan against spec AND contract

**CORRECT** — contract negotiation at step 3, before plan review at step 4.

### build-product Stage 1

- Step 2: impl-architect produces plan
- **Step 3: Contract Negotiation** (GATE)
- Step 4: plan-skeptic reviews plan against spec AND contract

**CORRECT** — contract negotiation at step 3, before plan review at step 4.

## Additional Checks

### Step Numbering Consistency

**plan-implementation**: 10 steps in Orchestration Flow (1-10). Correct — matches spec expectation.

**build-implementation**: Setup has 11 steps (1-11). Contract reading is step 5, guidance reader is step 11.
Orchestration flow has 8 steps. All consistent.

### Sprint Contract Evaluation Block Format

QS prompt (lines 493-500) matches spec format exactly:

```
Sprint Contract Evaluation:
1. {Criterion text} — PASS / FAIL / INCONCLUSIVE
   Rationale: {one sentence}

Contract Verdict: ALL PASS / FAILED ({N} of {total} criteria failed)
```

### Template YAML Frontmatter

Template has: `type`, `feature`, `status`, `signed-by`, `created`, `updated`. All match spec section 1.

### No Existing Content Accidentally Modified

- Shared content markers intact in all three SKILL.md files
- Shared content blocks unchanged (verified via git diff)
- Existing orchestration steps preserved and correctly renumbered
- No deletions of pre-existing content detected

### Code Fence Nesting

All code fences in spawn prompts correctly use triple backticks. Sprint Contract Evaluation format in QS prompt uses
proper indentation within the existing code fence. No nesting issues detected.

## Notes

- Implementation is clean and minimal — exactly 5 files touched as specified
- Contract negotiation protocol is consistent across all three skills
- Defensive reading contract is thorough and consistently applied
- The edge case handling in build-product (Stage 1 skipped, no contract) is well-designed with appropriate `signed-by`
  variation
- All 11 success criteria pass without qualification
