---
type: "implementation-plan"
feature: "sprint-contracts"
status: "approved"
source_spec: "docs/specs/sprint-contracts/spec.md"
approved_by: "Voss Grimthorn, Keeper of the War Table"
created: "2026-03-27"
updated: "2026-03-27"
---

# Implementation Plan: Sprint Contracts / Definition of Done (P2-11)

## Overview

Add a pre-execution Sprint Contract negotiation step to the implementation pipeline. Before code is written, the Lead
and Plan Skeptic negotiate and sign measurable acceptance criteria. The Quality Skeptic evaluates against these criteria
as explicit pass/fail items. Five files touched: 1 new artifact template, 3 SKILL.md prompt modifications, 1 validator
update. No new agents, no shared content changes.

## File Changes

| Action | File Path                                               | Description                                                                                                                                                                                                 |
| ------ | ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| create | `docs/templates/artifacts/sprint-contract.md`           | Sprint contract artifact template with YAML frontmatter                                                                                                                                                     |
| modify | `plugins/conclave/skills/plan-implementation/SKILL.md`  | Extend Setup step 2 (template reading) + insert Orchestration Flow step 3 (contract negotiation) + add frontmatter link instruction in step 8                                                               |
| modify | `plugins/conclave/skills/build-implementation/SKILL.md` | Insert Setup step 5 (contract reading) + add Spawn step 5 (contract injection) + extend Quality Skeptic prompt with SPRINT CONTRACT EVALUATION block                                                        |
| modify | `plugins/conclave/skills/build-product/SKILL.md`        | Extend Setup step 2 + add artifact detection row + update detection report format + insert Stage 1 step 3 (contract negotiation) + add Stage 2 step 2b (contract injection) + extend Quality Skeptic prompt |
| modify | `scripts/validators/artifact-templates.sh`              | Add `sprint-contract:sprint-contract` to `expected_templates` variable                                                                                                                                      |

---

## Dependency Order

```
1. docs/templates/artifacts/sprint-contract.md          — no dependencies
   scripts/validators/artifact-templates.sh             — depends on template existing (F1 checks it)

2. plugins/conclave/skills/plan-implementation/SKILL.md — defines contract negotiation
                                                          depends on template path being established

3. plugins/conclave/skills/build-implementation/SKILL.md — consumes the contract
                                                            depends on contract path defined by plan-implementation

4. plugins/conclave/skills/build-product/SKILL.md       — mirrors both plan-implementation and build-implementation
                                                            depends on all of the above for consistency
```

Run `bash scripts/validate.sh` after steps 1 and 2 (F-series gates template + validator). Run after each subsequent
file.

---

## Interface Definitions

### Sprint Contract Frontmatter Schema

```yaml
type: "sprint-contract" # required — checked by F1 validator
feature: "" # feature name, filled at runtime
status: "draft" # draft | negotiating | signed
signed-by: [] # ["planning-lead", "plan-skeptic"] or ["implementation-coordinator", "quality-skeptic"]
created: "" # ISO-8601
updated: "" # ISO-8601
```

### Artifact Detection Result (build-product only)

```
SIGNED     — file exists, frontmatter status: "signed" → skip contract negotiation
UNSIGNED   — file exists, frontmatter status: "draft" or "negotiating" → re-negotiate
NOT_FOUND  — file absent → negotiate in Stage 1 (or Stage 2 if Stage 1 was skipped)
```

### Quality Skeptic Evaluation Format (both build-implementation and build-product)

```
Sprint Contract Evaluation:
1. {Criterion text} — PASS / FAIL / INCONCLUSIVE
   Rationale: {one sentence}
2. ...

Contract Verdict: ALL PASS / FAILED ({N} of {total} criteria failed)
```

---

## File 1: `docs/templates/artifacts/sprint-contract.md` (CREATE)

**Action**: Create new file.

**Content**:

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

- **Planning Lead**: \***\*\_\_\*\*** (date: **\_\_**)
- **Plan Skeptic**: \***\*\_\_\*\*** (date: **\_\_**)

## Amendment Log

<!-- Appended on first amendment. Each entry records what changed, why, and who approved. -->

<!-- No amendments. -->
```

**Validator impact**: After creating this file AND updating `artifact-templates.sh`, `bash scripts/validate.sh` must
pass F1 with 5 templates checked.

---

## File 2: `scripts/validators/artifact-templates.sh` (MODIFY)

**Anchor**: Lines 20–23:

```bash
expected_templates="research-findings:research-findings
product-ideas:product-ideas
user-stories:user-stories
implementation-plan:implementation-plan"
```

**Change**: Replace closing `"` on line 23 with a new line before it:

```bash
expected_templates="research-findings:research-findings
product-ideas:product-ideas
user-stories:user-stories
implementation-plan:implementation-plan
sprint-contract:sprint-contract"
```

**One-line diff**: Add `sprint-contract:sprint-contract` as the 5th entry before the closing `"`.

**Validator impact**: F1 now checks 5 templates. Pass requires `docs/templates/artifacts/sprint-contract.md` to exist
with `type: "sprint-contract"`.

---

## File 3: `plugins/conclave/skills/plan-implementation/SKILL.md` (MODIFY)

Three insertion points. Current line references are stable textual anchors.

### Change 3a: Setup step 2 — Extend to read sprint contract template

**Anchor** (current line 25):

```
2. Read `docs/templates/artifacts/implementation-plan.md` — this is the output template your team must produce.
```

**Replace with**:

```
2. Read `docs/templates/artifacts/implementation-plan.md` — this is the output template your team must produce. Also read the sprint contract template using this lookup order:
   - First, check `.claude/conclave/templates/sprint-contract.md` (custom override)
   - If absent, read `docs/templates/artifacts/sprint-contract.md` (default)
   - Apply the defensive reading contract: custom file absent → use default silently; custom file unreadable or empty → log warning, fall back to default; custom file with `type` field not equal to `sprint-contract` → log warning, fall back to default; `.claude/conclave/` absent → use default silently
```

### Change 3b: Orchestration Flow — Insert Contract Negotiation as new step 3

**Anchor** — the block between these two existing lines (currently lines 112 and 113):

```
2. impl-architect produces the implementation plan
3. plan-skeptic reviews the plan against the spec (GATE — blocks finalization)
```

**Replace with** (inserting new step 3, renumbering old 3→4, 4→5, 5→6, 6→7, 7→8, 8→9, 9→10):

```
2. impl-architect produces the implementation plan
3. **Contract Negotiation** (GATE — must complete before plan review):
   - **Resumption guard**: If `docs/specs/{feature}/sprint-contract.md` exists with `status: "signed"`, read it and skip to step 4. Output: "Sprint contract found — signed by {signed-by}. Using existing contract."
   - **Lead proposes**: Derive initial acceptance criteria from the spec's success criteria and user story ACs. If no success criteria exist, synthesize from the spec's Scope section. Format as numbered pass/fail items per the sprint contract template.
   - **Send to plan-skeptic**: `write(plan-skeptic, "SPRINT CONTRACT PROPOSAL: [criteria list]")`. Plan-skeptic reviews for: specificity (each criterion must be evaluable as pass/fail by reading code), completeness (all spec requirements covered), measurability (no subjective terms like "should feel fast").
   - **Iterate**: If plan-skeptic counters, revise and re-propose. Max 3 rounds — same deadlock protocol as existing skeptic gates (see Failure Recovery).
   - **Sign**: When plan-skeptic approves, write the signed contract to `docs/specs/{feature}/sprint-contract.md` using the template, with `status: "signed"` and `signed-by: ["planning-lead", "plan-skeptic"]`.
   - The contract negotiation step is preserved in `--light` mode — the contract gate is non-negotiable regardless of mode.
4. plan-skeptic reviews the plan against the spec AND the sprint contract (GATE — blocks finalization). The plan review prompt explicitly references the contract: plan conformance is checked against contract criteria, not only against the spec.
5. If the skeptic rejects, send specific feedback and have impl-architect revise
6. Iterate until plan-skeptic approves
7. **Lead-as-Skeptic**: Review the approved plan yourself. Challenge for gaps the skeptic may have missed — particularly around existing codebase patterns and framework conventions. This is your additional skeptic duty.
8. **Team Lead only**: Write the final implementation plan to `docs/specs/{feature}/implementation-plan.md` conforming to the template at `docs/templates/artifacts/implementation-plan.md`. The frontmatter MUST include `sprint-contract: "docs/specs/{feature}/sprint-contract.md"` linking the two artifacts.
9. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
10. **Team Lead only**: Write end-of-session summary to `docs/progress/{feature}-summary.md` using the format from `docs/progress/_template.md`
```

**Note on step 4**: The old step 3 text (`plan-skeptic reviews the plan against the spec`) is extended to include
contract reference. The new text replaces it entirely.

**Note on step 8**: Old step 7 text ends with
`conforming to the template at \`docs/templates/artifacts/implementation-plan.md\``. New step 8 extends that sentence to add the `sprint-contract:`
frontmatter requirement.

---

## File 4: `plugins/conclave/skills/build-implementation/SKILL.md` (MODIFY)

Three insertion points.

### Change 4a: Setup — Insert new step 5 (contract reading)

**Anchor** (current lines 27–28):

```
4. **Read implementation-plan (REQUIRED).** Search `docs/specs/{feature}/implementation-plan.md` for the plan. If none exists, inform the user: "No implementation-plan found for this feature. Run `/plan-implementation {feature}` first, or invoke `/build-product` to run the full pipeline."
5. **Read technical-spec (REQUIRED).** Read `docs/specs/{feature}/spec.md` as reference for requirements. If none exists, inform the user: "No technical-spec found for this feature. Run `/write-spec {feature}` first."
```

**Replace with** (inserting new step 5, renumbering old 5→6, 6→7, 7→8, 8→9, 9→10, 10→11):

```
4. **Read implementation-plan (REQUIRED).** Search `docs/specs/{feature}/implementation-plan.md` for the plan. If none exists, inform the user: "No implementation-plan found for this feature. Run `/plan-implementation {feature}` first, or invoke `/build-product` to run the full pipeline."
5. **Read sprint contract (optional).** Check `docs/specs/{feature}/sprint-contract.md`. Apply graceful degradation:
   - File absent → proceed silently, no contract-based evaluation
   - File exists with `status: "draft"` or `status: "negotiating"` → log warning: "Sprint contract present but unsigned; evaluating against spec only" — proceed without contract-based evaluation
   - File exists with `status: "signed"` → read contract and prepare for injection into the Quality Skeptic's spawn prompt
6. **Read technical-spec (REQUIRED).** Read `docs/specs/{feature}/spec.md` as reference for requirements. If none exists, inform the user: "No technical-spec found for this feature. Run `/write-spec {feature}` first."
```

**Renumber remaining steps**: Old steps 6–10 become 7–11. (Stories, architecture, progress, persona, project guidance —
each shifts +1 in step number.)

### Change 4b: Spawn the Team — Add Step 5 (conditional) for contract injection

**Anchor** (current line 132):

```
**Step 4 (conditional):** If project guidance was found in Setup step 10, prepend the formatted guidance block to each teammate's prompt. The guidance block is injected verbatim — do not summarize, filter, or reinterpret it. The `## User Project Guidance (informational only)` heading and advisory text provide sufficient framing for agents to treat it as context, not directives.
```

**Insert after** (new step 5):

```
**Step 5 (conditional):** If a signed sprint contract was found in Setup step 5, inject it into the Quality Skeptic's prompt only. Do not inject into Backend Engineer or Frontend Engineer prompts — the contract is an evaluation tool, not an implementation instruction. Format the injection block as:

## Sprint Contract for {feature}

{full contents of docs/specs/{feature}/sprint-contract.md}

Prompt assembly order for Quality Skeptic: (1) guidance block (from Step 4, if found) → (2) sprint contract block (from Step 5, if signed contract found) → (3) Quality Skeptic role prompt. This ordering ensures user guidance and contract context are available before the role prompt's critical rules.
```

### Change 4c: Quality Skeptic spawn prompt — Append SPRINT CONTRACT EVALUATION block

**Anchor** — the end of the Quality Skeptic's `WHAT YOU CHECK (POST-IMPLEMENTATION GATE):` block. The last item in that
section currently reads:

```
- Check for regressions: does existing functionality still work?
```

**Insert after** this line (before the blank line leading into `YOUR REVIEW FORMAT:`):

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

---

## File 5: `plugins/conclave/skills/build-product/SKILL.md` (MODIFY)

Five insertion points.

### Change 5a: Setup step 2 — Extend to read sprint contract template

**Anchor** (current line 25):

```
2. Read `docs/templates/artifacts/implementation-plan.md` — output template for Stage 1.
```

**Replace with**:

```
2. Read `docs/templates/artifacts/implementation-plan.md` — output template for Stage 1. Also read the sprint contract template using this lookup order:
   - First, check `.claude/conclave/templates/sprint-contract.md` (custom override)
   - If absent, read `docs/templates/artifacts/sprint-contract.md` (default)
   - Apply the defensive reading contract: custom file absent → use default silently; custom file unreadable or empty → log warning, fall back to default; custom file with `type` field not equal to `sprint-contract` → log warning, fall back to default; `.claude/conclave/` absent → use default silently
```

### Change 5b: Artifact Detection — Add sprint-contract row to table

**Anchor** — the Detection Paths table (current lines 110–114):

```
| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| 1 (Planning) | implementation-plan | `docs/specs/{feature}/implementation-plan.md` | FOUND / INCOMPLETE / NOT_FOUND |
| 2 (Build) | code changes | Progress checkpoints with `team: "build-product"` | COMPLETE / IN_PROGRESS / NOT_FOUND |
| 3 (Quality) | quality report | Progress checkpoints with `team: "build-product"`, `phase: "review"` | COMPLETE / NOT_FOUND |
```

**Replace with**:

```
| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| 1 (Planning) | implementation-plan | `docs/specs/{feature}/implementation-plan.md` | FOUND / INCOMPLETE / NOT_FOUND |
| 1 (Planning) | sprint-contract | `docs/specs/{feature}/sprint-contract.md` | SIGNED / UNSIGNED / NOT_FOUND |
| 2 (Build) | code changes | Progress checkpoints with `team: "build-product"` | COMPLETE / IN_PROGRESS / NOT_FOUND |
| 3 (Quality) | quality report | Progress checkpoints with `team: "build-product"`, `phase: "review"` | COMPLETE / NOT_FOUND |
```

**Detection logic** (insert as a new paragraph after the table, before the FOUND/COMPLETE bullet points):

```
Sprint-contract detection logic:
- `SIGNED`: File exists, frontmatter `status: "signed"` — skip contract negotiation, use existing contract
- `UNSIGNED`: File exists, frontmatter `status: "draft"` or `"negotiating"` — re-negotiate
- `NOT_FOUND`: File absent — negotiate in Stage 1 (or Stage 2 if Stage 1 was skipped)
```

### Change 5c: Artifact Detection report format — Add sprint-contract line

**Anchor** — the report format block (current lines 122–133):

```
Artifact Detection for "{feature}":
  Prerequisites:
    technical-spec:      [FOUND / NOT_FOUND]
    user-stories:        [FOUND / NOT_FOUND] (optional)
  Pipeline:
    implementation-plan: [result]
    build:               [result]
    quality-review:      [result]

Pipeline will run: [stages to execute]
Skipping:          [stages with FOUND/COMPLETE artifacts]
```

**Replace with**:

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

### Change 5d: Stage 1 Orchestration Flow — Insert Contract Negotiation as new step 3

**Anchor** — Stage 1 steps (current lines 204–211):

```
1. Share the technical spec, user stories, and ADRs with impl-architect and plan-skeptic
2. Spawn impl-architect to produce the implementation plan
3. Spawn plan-skeptic to review the plan against the spec (GATE — blocks implementation)
4. If plan-skeptic rejects, send specific feedback and have impl-architect revise
5. Iterate until plan-skeptic approves
6. **Lead-as-Skeptic**: Review the approved plan yourself. Challenge for gaps — particularly around existing codebase patterns and framework conventions.
7. **Team Lead only**: Write the final plan to `docs/specs/{feature}/implementation-plan.md` conforming to `docs/templates/artifacts/implementation-plan.md`
8. Report: `"Stage 1 (Planning) complete. Artifact: docs/specs/{feature}/implementation-plan.md"`
```

**Replace with** (inserting new step 3 BEFORE plan-skeptic review, renumbering 3→4, 4→5, 5→6, 6→7, 7→8, 8→9):

```
1. Share the technical spec, user stories, and ADRs with impl-architect and plan-skeptic
2. Spawn impl-architect to produce the implementation plan
3. **Contract Negotiation** (must complete before plan review):
   - **Resumption guard**: If sprint-contract detected as SIGNED, skip to step 4.
   - Lead proposes initial acceptance criteria derived from spec success criteria and user story ACs. If no success criteria exist, synthesize from the spec's Scope section.
   - `write(plan-skeptic, "SPRINT CONTRACT PROPOSAL: [criteria list]")`. Plan-skeptic checks specificity, completeness, measurability.
   - Iterate max 3 rounds (same deadlock protocol as existing skeptic gates — see Failure Recovery).
   - When approved, write signed contract to `docs/specs/{feature}/sprint-contract.md` with `status: "signed"` and `signed-by: ["planning-lead", "plan-skeptic"]`.
   - **Edge case** (Stage 1 skipped but sprint-contract NOT_FOUND): If the artifact detection result was `implementation-plan: FOUND` but `sprint-contract: NOT_FOUND`, run this negotiation at the start of Stage 2 instead, using quality-skeptic as the signing skeptic (see Stage 2 step 1 below). In that case, `signed-by: ["implementation-coordinator", "quality-skeptic"]`.
   - The contract negotiation step is preserved in `--light` mode — non-negotiable regardless of mode.
4. Spawn plan-skeptic to review the plan against the spec AND the sprint contract (GATE — blocks implementation). Plan conformance is checked against contract criteria, not only against the spec.
5. If plan-skeptic rejects, send specific feedback and have impl-architect revise
6. Iterate until plan-skeptic approves
7. **Lead-as-Skeptic**: Review the approved plan yourself. Challenge for gaps — particularly around existing codebase patterns and framework conventions.
8. **Team Lead only**: Write the final plan to `docs/specs/{feature}/implementation-plan.md` conforming to `docs/templates/artifacts/implementation-plan.md`. Frontmatter MUST include `sprint-contract: "docs/specs/{feature}/sprint-contract.md"`.
9. Report: `"Stage 1 (Planning) complete. Artifact: docs/specs/{feature}/implementation-plan.md"`
```

### Change 5e: Stage 2 Build — Add step 2b for contract injection + edge case step 1 addendum

**Stage 2 step 1 addendum** — After the current Stage 2 step 1:

```
1. Share the implementation plan, technical spec, and user stories with backend-eng and frontend-eng
```

**Replace with**:

```
1. Share the implementation plan, technical spec, and user stories with backend-eng and frontend-eng.
   **Contract check**: If sprint-contract was NOT_FOUND or UNSIGNED from artifact detection (and Stage 1 was skipped), run contract negotiation now before any other Stage 2 steps: Lead proposes criteria from spec, quality-skeptic reviews and approves, write to `docs/specs/{feature}/sprint-contract.md` with `signed-by: ["implementation-coordinator", "quality-skeptic"]`.
```

**Stage 2 step 2b** — After current Stage 2 step 2:

```
2. Spawn backend-eng, frontend-eng, and quality-skeptic (if not already spawned)
```

**Insert after**:

```
2b. **Contract injection**: If a signed sprint contract exists (from Stage 1, a prior session, or just-negotiated in step 1), inject it into the Quality Skeptic's spawn prompt using the same format as build-implementation:

    ## Sprint Contract for {feature}

    {full contents of docs/specs/{feature}/sprint-contract.md}

    Do NOT inject into backend-eng or frontend-eng prompts. On checkpoint recovery, re-read the contract from disk — never re-negotiate a signed contract on resume.
```

### Change 5f: Quality Skeptic spawn prompt — Append SPRINT CONTRACT EVALUATION block

**Anchor** — the last item in `WHAT YOU CHECK (POST-IMPLEMENTATION GATE):`:

```
- Check for regressions: does existing functionality still work?
```

**Insert after** this line (before `YOUR REVIEW FORMAT:`):

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

---

## Test Strategy

| Test Type  | Scope                   | Description                                                                                                                       |
| ---------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| validator  | F-series                | Run `bash scripts/validate.sh` after creating template + updating validator — must show 5 templates checked, all PASS             |
| validator  | all-series              | Run `bash scripts/validate.sh` after each SKILL.md edit — 12/12 checks must pass throughout                                       |
| structural | plan-implementation     | Verify step numbering is coherent (no gaps, no duplicate numbers, 10 steps total in Orchestration Flow)                           |
| structural | build-implementation    | Verify setup step numbering is coherent (old 5-10 shifted to 6-11, total 11 steps)                                                |
| structural | build-product           | Verify Stage 1 has 9 steps, Stage 2 has steps 1, 1-addendum, 2, 2b, 3-9, detection table has 4 rows                               |
| content    | Quality Skeptic prompts | Both build-implementation and build-product Quality Skeptic prompts contain identical SPRINT CONTRACT EVALUATION blocks           |
| content    | setup step 2            | Both plan-implementation and build-product setup step 2 contain identical defensive reading contract for sprint contract template |

### Execution Order

```
1. Create docs/templates/artifacts/sprint-contract.md
2. Edit scripts/validators/artifact-templates.sh
3. bash scripts/validate.sh  ← F1 must pass with 5 templates
4. Edit plugins/conclave/skills/plan-implementation/SKILL.md
5. bash scripts/validate.sh  ← still 12/12
6. Edit plugins/conclave/skills/build-implementation/SKILL.md
7. bash scripts/validate.sh  ← still 12/12
8. Edit plugins/conclave/skills/build-product/SKILL.md
9. bash scripts/validate.sh  ← still 12/12 — final gate
```

---

## Critical Constraints

1. **Contract BEFORE plan review** — in both plan-implementation and build-product Stage 1, the contract negotiation
   step is step 3 (after plan production, before plan review). This is non-negotiable per the Skeptic review.
2. **Quality Skeptic only** — Sprint contract is injected ONLY into the Quality Skeptic prompt, not backend-eng or
   frontend-eng.
3. **No shared content changes** — `plugins/conclave/shared/` is untouched. No sync script run needed.
4. **Graceful degradation** — All contract reading steps are optional. Features without contracts experience zero
   behavior change.
5. **`--light` mode** — Contract negotiation is preserved in all three skills regardless of `--light` flag.
6. **`signed-by` varies by context** — `["planning-lead", "plan-skeptic"]` in normal flow;
   `["implementation-coordinator", "quality-skeptic"]` in Stage 2 fallback. Both are valid.
