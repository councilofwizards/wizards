---
feature: "sprint-contracts"
team: "spec-writing"
agent: "architect"
phase: "complete"
status: "complete"
last_action: "Revised per skeptic feedback — RF-1 ordering fix, AN-1 injection clarity, AN-2 signer names"
updated: "2026-03-27T15:00:00Z"
---

# Architecture Design: Sprint Contracts / Definition of Done (P2-11)

## Overview

Sprint Contracts add a pre-execution negotiation step to the implementation pipeline. Before code is written, the Lead and Skeptic agree on specific, measurable acceptance criteria. The Quality Skeptic later evaluates against these criteria as explicit pass/fail items — not vague principles.

This is a **prompt-only** project. All changes are SKILL.md edits, one new artifact template, and one validator update. No application code, no shared content changes, no new agents.

## File Changes

| Action | File Path | Description |
|--------|-----------|-------------|
| create | `docs/templates/artifacts/sprint-contract.md` | Sprint contract artifact template with YAML frontmatter |
| modify | `plugins/conclave/skills/plan-implementation/SKILL.md` | Setup step + contract negotiation step + frontmatter link |
| modify | `plugins/conclave/skills/build-implementation/SKILL.md` | Setup step + Quality Skeptic prompt extension |
| modify | `plugins/conclave/skills/build-product/SKILL.md` | Artifact detection row + Stage 1 contract negotiation + Stage 2 contract injection |
| modify | `scripts/validators/artifact-templates.sh` | Add `sprint-contract:sprint-contract` to `expected_templates` |

---

## 1. Sprint Contract Artifact Template

**File**: `docs/templates/artifacts/sprint-contract.md`

```markdown
---
type: "sprint-contract"
feature: ""
status: "draft"              # draft | negotiating | signed
signed-by: []               # e.g. ["planning-lead", "plan-skeptic"]
created: ""
updated: ""
---

# Sprint Contract: {Feature}

## Acceptance Criteria

<!-- Each criterion is a numbered, pass/fail-evaluable item. Derive from spec success criteria and user story ACs. -->

1. {Criterion description} | Pass/Fail: [ ]
2. {Criterion description} | Pass/Fail: [ ]

## Out of Scope

<!-- Explicit exclusions. What this contract does NOT cover. Prevents scope creep during evaluation. -->

- {Exclusion}

## Performance Targets

<!-- Optional. Measurable performance requirements. Leave as placeholder if none apply. -->

<!-- No performance targets defined for this feature. -->

## Signatures

<!-- Both Lead and Skeptic must sign before the contract is considered binding. -->

- **Planning Lead**: __________ (date: ______)
- **Plan Skeptic**: __________ (date: ______)

## Amendment Log

<!-- Appended on first amendment. Each entry records what changed, why, and who approved. -->

<!-- No amendments. -->
```

**Design rationale**:

- `type: "sprint-contract"` matches the F-series validator convention (`name:expected_type` pair)
- `status` field has three states: `draft` (initial creation), `negotiating` (under review), `signed` (both parties approved)
- `signed-by` is a list to support verification — `status: signed` requires at least two entries
- Amendment Log is included in the template per Story 6 (could-have) — it's zero-cost to include and prevents appending a section later
- Pass/Fail format (`| Pass/Fail: [ ]`) gives the Quality Skeptic a concrete evaluation structure

---

## 2. plan-implementation SKILL.md Modifications

Three changes to `plugins/conclave/skills/plan-implementation/SKILL.md`:

### 2a. Setup — New Step 2b (Template Reading)

**Location**: After current Setup step 2 (line 25), insert a new step.

**Current** (step 2):
```
2. Read `docs/templates/artifacts/implementation-plan.md` — this is the output template your team must produce.
```

**New** (step 2, extended):
```
2. Read `docs/templates/artifacts/implementation-plan.md` — this is the output template your team must produce. Also read the sprint contract template using this lookup order:
   - First, check `.claude/conclave/templates/sprint-contract.md` (custom override)
   - If absent, read `docs/templates/artifacts/sprint-contract.md` (default)
   - Apply the defensive reading contract: custom file absent → use default silently; custom file unreadable or empty → log warning, fall back to default; custom file with `type` field not equal to `sprint-contract` → log warning, fall back to default; `.claude/conclave/` absent → use default silently
```

**Rationale**: Lookup order follows P2-13 convention. Defensive reading mirrors the pattern already established by build-implementation's guidance reader (Setup step 10). The custom template override is resolved once during Setup and used during contract negotiation.

### 2b. Orchestration Flow — New Contract Negotiation Step

**Location**: Between current step 2 ("impl-architect produces the implementation plan") and step 3 ("plan-skeptic reviews the plan"). This becomes the new step 3, bumping subsequent steps.

**Insert after current step 2**:

```
3. **Contract Negotiation** (GATE — must complete before plan review):
   - **Resumption guard**: If `docs/specs/{feature}/sprint-contract.md` exists with `status: "signed"`, read it and skip to step 4. Output: "Sprint contract found — signed by {signed-by}. Using existing contract."
   - **Lead proposes**: Derive initial acceptance criteria from the spec's success criteria and user story ACs. If no success criteria exist, synthesize from the spec's Scope section. Format as numbered pass/fail items per the sprint contract template.
   - **Send to plan-skeptic**: `write(plan-skeptic, "SPRINT CONTRACT PROPOSAL: [criteria list]")`. Plan-skeptic reviews for: specificity (each criterion must be evaluable as pass/fail by reading code), completeness (all spec requirements covered), measurability (no subjective terms like "should feel fast").
   - **Iterate**: If plan-skeptic counters, revise and re-propose. Max 3 rounds — same deadlock protocol as existing skeptic gates (see Failure Recovery).
   - **Sign**: When plan-skeptic approves, write the signed contract to `docs/specs/{feature}/sprint-contract.md` using the template, with `status: "signed"` and `signed-by: ["planning-lead", "plan-skeptic"]`.
   - The contract negotiation step is preserved in `--light` mode — the contract gate is non-negotiable regardless of mode.
```

**Updated step numbering** (full Orchestration Flow after change):

```
1. Share the technical spec and user stories (if available) with both agents
2. impl-architect produces the implementation plan
3. **Contract Negotiation** (new — described above)
4. plan-skeptic reviews the plan against the spec AND the sprint contract (GATE — blocks finalization). The review prompt explicitly references the contract: plan conformance is checked against contract criteria, not only against the spec.
5. If the skeptic rejects, send specific feedback and have impl-architect revise
6. Iterate until plan-skeptic approves
7. **Lead-as-Skeptic**: Review the approved plan yourself...
8. **Team Lead only**: Write the final implementation plan to `docs/specs/{feature}/implementation-plan.md`... The implementation plan's frontmatter MUST include `sprint-contract: "docs/specs/{feature}/sprint-contract.md"` linking the two artifacts.
9. **Team Lead only**: Write cost summary...
10. **Team Lead only**: Write end-of-session summary...
```

### 2c. Implementation Plan Frontmatter Extension

**Location**: The output artifact written in step 8 must include a new frontmatter field.

The implementation plan template (`docs/templates/artifacts/implementation-plan.md`) already has `source_spec` in its frontmatter. The Team Lead adds `sprint-contract: "docs/specs/{feature}/sprint-contract.md"` when writing the final artifact. This is an instruction in the SKILL.md, not a template change — the template remains generic.

**Rationale**: The link is written by the skill at runtime, not baked into the template. This keeps the template backward-compatible for features without contracts.

---

## 3. build-implementation SKILL.md Modifications

Three changes to `plugins/conclave/skills/build-implementation/SKILL.md`:

### 3a. Setup — New Step 4b (Contract Reading)

**Location**: After current Setup step 4 ("Read implementation-plan"), insert a new step.

**Insert as new step between current steps 4 and 5** (renumbered as step 5, bumping subsequent):

```
5. **Read sprint contract (optional).** Check `docs/specs/{feature}/sprint-contract.md`. If it exists and has `status: "signed"` in frontmatter, read it and prepare for injection into the Quality Skeptic's spawn prompt. Apply graceful degradation:
   - File absent → proceed silently, no contract-based evaluation
   - File exists with `status: "draft"` or `status: "negotiating"` → log warning: "Sprint contract present but unsigned; evaluating against spec only" — proceed without contract-based evaluation
   - File exists with `status: "signed"` → read contract, inject into Quality Skeptic prompt
```

### 3b. Spawn the Team — Quality Skeptic Prompt Extension

**Location**: In the Quality Skeptic spawn prompt (Teammate Spawn Prompts section), add contract-based evaluation instructions.

**Append to the Quality Skeptic prompt** (after existing `WHAT YOU CHECK (POST-IMPLEMENTATION GATE):` block):

```
SPRINT CONTRACT EVALUATION (when contract provided):
If a sprint contract is provided in your prompt context, your POST-IMPLEMENTATION GATE review
MUST include a "Sprint Contract Evaluation" section BEFORE the standard quality checks.

Format:
  Sprint Contract Evaluation:
  1. {Criterion text} — PASS / FAIL / INCONCLUSIVE
     Rationale: {one sentence}
  2. ...

  Contract Verdict: ALL PASS / FAILED ({N} of {total} criteria failed)

Rules:
- A single FAIL criterion means Verdict: REJECTED — regardless of code quality
- INCONCLUSIVE (criterion cannot be evaluated via code review, e.g. requires runtime data):
  treated as non-blocking; note the reason and recommend how to verify post-deployment
- If the contract has zero acceptance criteria: note the empty contract, evaluate against spec as fallback
- New requirements discovered during review that are NOT in the contract: note as
  "Uncovered Requirements" — these do not block approval if covered by the spec,
  but should inform a potential contract amendment

If NO sprint contract is provided, perform your standard review (current behavior). No error, no warning.
```

### 3c. Spawn the Team — Step 5 (Contract Injection)

**Location**: After existing "Step 4 (conditional)" for guidance injection, add a new conditional step.

**Add as Step 5 (conditional)**:

```
**Step 5 (conditional):** If a signed sprint contract was found in Setup step 5, inject it into the Quality Skeptic's prompt only. Do not inject into Backend Engineer or Frontend Engineer prompts — the contract is an evaluation tool, not an implementation instruction. Format:

## Sprint Contract for {feature}

{full contents of docs/specs/{feature}/sprint-contract.md}
```

**Full prompt assembly order for Quality Skeptic** (clarifying how Sections 3b and 3c combine with existing Step 4):

1. Guidance block (from Step 4, if guidance files found in `.claude/conclave/guidance/`)
2. Sprint contract block (from Step 5, if signed contract found)
3. Quality Skeptic role prompt (the existing spawn prompt from Teammate Spawn Prompts section, which now includes the SPRINT CONTRACT EVALUATION instructions from Section 3b)

This ordering ensures user guidance and contract context are available before the role prompt's critical rules, so those rules take precedence over any conflicting content. The contract block provides the data; the SPRINT CONTRACT EVALUATION block in the role prompt provides the evaluation instructions.

---

## 4. build-product SKILL.md Modifications

Four changes to `plugins/conclave/skills/build-product/SKILL.md`:

### 4a. Setup — New Step 2b (Template Reading)

**Location**: After current Setup step 2 ("Read `docs/templates/artifacts/implementation-plan.md`"), add:

```
   Also read the sprint contract template using this lookup order:
   - First, check `.claude/conclave/templates/sprint-contract.md` (custom override)
   - If absent, read `docs/templates/artifacts/sprint-contract.md` (default)
   - Apply the same defensive reading contract as plan-implementation (see Section 2a above)
```

### 4b. Artifact Detection — New Row

**Location**: In the "Detection Paths" table, add a new row after the Stage 1 row.

**Current table**:

| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| 1 (Planning) | implementation-plan | `docs/specs/{feature}/implementation-plan.md` | FOUND / INCOMPLETE / NOT_FOUND |
| 2 (Build) | code changes | Progress checkpoints with `team: "build-product"` | COMPLETE / IN_PROGRESS / NOT_FOUND |
| 3 (Quality) | quality report | Progress checkpoints with `team: "build-product"`, `phase: "review"` | COMPLETE / NOT_FOUND |

**New table** (add row between Stage 1 and Stage 2):

| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| 1 (Planning) | implementation-plan | `docs/specs/{feature}/implementation-plan.md` | FOUND / INCOMPLETE / NOT_FOUND |
| 1 (Planning) | sprint-contract | `docs/specs/{feature}/sprint-contract.md` | SIGNED / UNSIGNED / NOT_FOUND |
| 2 (Build) | code changes | Progress checkpoints with `team: "build-product"` | COMPLETE / IN_PROGRESS / NOT_FOUND |
| 3 (Quality) | quality report | Progress checkpoints with `team: "build-product"`, `phase: "review"` | COMPLETE / NOT_FOUND |

**Detection logic for sprint-contract**:
- `SIGNED`: File exists, frontmatter `status: "signed"` — skip contract negotiation
- `UNSIGNED`: File exists, frontmatter `status: "draft"` or `"negotiating"` — re-negotiate
- `NOT_FOUND`: File absent — negotiate in Stage 1 (or Stage 2 if Stage 1 was skipped)

**Update the artifact detection report format**:

```
Artifact Detection for "{feature}":
  Prerequisites:
    technical-spec:      [FOUND / NOT_FOUND]
    user-stories:        [FOUND / NOT_FOUND] (optional)
  Pipeline:
    implementation-plan: [result]
    sprint-contract:     [SIGNED / UNSIGNED / NOT_FOUND]
    build:               [result]
    quality-review:      [result]

Pipeline will run: [stages to execute]
Skipping:          [stages with FOUND/COMPLETE artifacts]
```

### 4c. Stage 1 — Contract Negotiation Step

**Location**: In "Stage 1: Implementation Planning", insert as new step 3, BEFORE the plan-skeptic review gate. This mirrors the ordering in plan-implementation (Section 2b): plan produced → contract negotiated → plan reviewed against contract + spec.

**Updated Stage 1 step sequence**:

```
1. Share the technical spec, user stories, and ADRs with impl-architect and plan-skeptic
2. Spawn impl-architect to produce the implementation plan
3. **Contract Negotiation** (must complete before plan review):
   - **Resumption guard**: If sprint-contract detected as SIGNED, skip to step 4.
   - Lead proposes initial acceptance criteria derived from spec success criteria and user story ACs.
   - Send to plan-skeptic for review. plan-skeptic checks specificity, completeness, measurability.
   - Iterate max 3 rounds (same deadlock protocol as existing skeptic gates).
   - When approved, write signed contract to `docs/specs/{feature}/sprint-contract.md` with `status: "signed"` and `signed-by: ["planning-lead", "plan-skeptic"]`.
4. plan-skeptic reviews the plan against the spec AND the sprint contract (GATE — blocks implementation)
5. If plan-skeptic rejects, send specific feedback and have impl-architect revise
6. Iterate until plan-skeptic approves
7. **Lead-as-Skeptic**: Review the approved plan yourself.
8. **Team Lead only**: Write the final plan to `docs/specs/{feature}/implementation-plan.md`. Frontmatter must include `sprint-contract: "docs/specs/{feature}/sprint-contract.md"`.
9. Report: "Stage 1 (Planning) complete."
```

**Rationale**: The contract MUST precede the plan review gate so that plan-skeptic evaluates the plan against contract criteria, not just the spec. Placing it after approval (as originally specified) would defeat the purpose — the plan would be approved without being checked against the contract.

**Edge case**: Stage 1 was skipped (implementation-plan FOUND) but sprint-contract NOT_FOUND. In this case, run contract negotiation at the start of Stage 2, using the existing implementation plan and spec as inputs. Add to Stage 2 step 1:

```
1. Share the implementation plan, technical spec, and user stories with backend-eng and frontend-eng.
   **Contract check**: If no signed sprint contract exists (sprint-contract NOT_FOUND or UNSIGNED despite implementation-plan FOUND), negotiate one now: Lead proposes criteria from spec, quality-skeptic reviews (quality-skeptic is the available skeptic in Stage 2; plan-skeptic is not spawned), write to `docs/specs/{feature}/sprint-contract.md` with `signed-by: ["implementation-coordinator", "quality-skeptic"]`.
```

**Note on `signed-by` names**: The signer names vary by context. In plan-implementation and build-product Stage 1, signers are `["planning-lead", "plan-skeptic"]`. In the Stage 2 fallback (when Stage 1 was skipped), signers are `["implementation-coordinator", "quality-skeptic"]` because quality-skeptic is the available skeptic. The contract is valid regardless of which pair signs — the `signed-by` field is informational, not a fixed schema.

### 4d. Stage 2 — Contract Injection into Quality Skeptic

**Location**: In "Stage 2: Build Implementation", update the Quality Skeptic spawning.

**Add after Stage 2 step 2**:

```
2b. If a signed sprint contract exists (from Stage 1, prior session, or just-negotiated), inject it into the Quality Skeptic's spawn prompt using the same format as build-implementation (Section 3c). The contract shapes the POST-IMPLEMENTATION GATE evaluation.
```

**Pipeline resume safety**: On checkpoint recovery mid-Stage 2, re-read `docs/specs/{feature}/sprint-contract.md` from disk. Never re-negotiate a signed contract on resume.

### 4e. Quality Skeptic Prompt — Contract Evaluation

The build-product Quality Skeptic spawn prompt receives the same "SPRINT CONTRACT EVALUATION" block as described in Section 3b for build-implementation. This is a direct copy — the evaluation format, rules, and fallback behavior are identical.

---

## 5. Validator Update

**File**: `scripts/validators/artifact-templates.sh`

**Change**: Add `sprint-contract:sprint-contract` to the `expected_templates` variable.

**Current** (lines 20-23):
```bash
expected_templates="research-findings:research-findings
product-ideas:product-ideas
user-stories:user-stories
implementation-plan:implementation-plan"
```

**New**:
```bash
expected_templates="research-findings:research-findings
product-ideas:product-ideas
user-stories:user-stories
implementation-plan:implementation-plan
sprint-contract:sprint-contract"
```

This ensures the F-series validator checks that `docs/templates/artifacts/sprint-contract.md` exists and contains `type: "sprint-contract"` in its frontmatter. No other validator changes are needed — the template follows the same conventions as existing templates.

---

## 6. Custom Template Override Mechanism

**Convention**: Follows P2-13's `.claude/conclave/templates/` directory.

**Lookup order** (resolved once during Setup):
1. `.claude/conclave/templates/sprint-contract.md` — custom override
2. `docs/templates/artifacts/sprint-contract.md` — default

**Defensive reading contract** (mirrors P2-13 spec Section 4):

| Condition | Behavior |
|-----------|----------|
| `.claude/conclave/` absent | Use default silently |
| `.claude/conclave/templates/` absent | Use default silently |
| Custom file absent | Use default silently |
| Custom file unreadable (permission error) | Log warning: "Custom sprint contract template unreadable; using default" — fall back |
| Custom file empty | Log warning: "Custom sprint contract template is empty; using default" — fall back |
| Custom file with `type` != `sprint-contract` | Log warning: "Custom sprint contract template has invalid type; using default" — fall back |
| Custom file with malformed YAML | Log warning: "Custom sprint contract template has invalid frontmatter; using default" — fall back |
| Custom file is a directory | Log warning — fall back |

**Usage**: When the Lead proposes initial acceptance criteria, any pre-populated criteria in the custom template are included in the initial proposal. This allows projects to define baseline criteria (e.g., regulatory requirements, performance SLAs) that appear in every contract.

**Consumers**: plan-implementation (Setup step 2), build-product (Setup step 2b). Both resolve the template once and use it for contract negotiation.

---

## 7. Contract Amendment Protocol (Story 6, Could-Have)

Story 6 is at could-have priority. The architecture accommodates it without requiring it for initial implementation:

- The Amendment Log section is included in the template (zero cost)
- No SKILL.md changes are required for Story 6 — it's a prompt-only change to the "Critical Rules" section of plan-implementation and build-implementation if implemented later
- The Quality Skeptic evaluates against the current state of the contract file, so amendments that modify the file are automatically picked up

**Recommendation**: Defer Story 6 implementation to a follow-on item. The template includes the Amendment Log section so the format is established, but the amendment negotiation protocol can be added later without breaking changes.

---

## Success Criteria

1. `docs/templates/artifacts/sprint-contract.md` exists with `type: "sprint-contract"`, all required sections (Acceptance Criteria, Out of Scope, Performance Targets, Signatures, Amendment Log)
2. `scripts/validators/artifact-templates.sh` includes `sprint-contract:sprint-contract` — `bash scripts/validate.sh` passes 12/12
3. plan-implementation SKILL.md reads the contract template (with custom override lookup), negotiates a contract between Lead and plan-skeptic, writes to `docs/specs/{feature}/sprint-contract.md`, links it from the implementation plan frontmatter
4. plan-implementation skips negotiation when a signed contract already exists (resumption guard)
5. build-implementation SKILL.md reads the sprint contract and injects it into the Quality Skeptic's prompt; Quality Skeptic evaluates each criterion as PASS/FAIL/INCONCLUSIVE
6. build-implementation degrades gracefully when no contract is present (current behavior, no error)
7. build-product artifact detection includes sprint-contract row (SIGNED/UNSIGNED/NOT_FOUND); Stage 1 mirrors contract negotiation; Stage 2 injects contract into Quality Skeptic
8. build-product handles the edge case where Stage 1 was skipped but no contract exists
9. Custom template override works via `.claude/conclave/templates/sprint-contract.md` with full defensive reading
10. No shared content changes (`plugins/conclave/shared/` untouched, sync script not needed)
11. `--light` mode preserves contract negotiation in all three skills
