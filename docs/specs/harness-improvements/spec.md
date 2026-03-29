---
title: "Harness Improvements Specification (P3-26 through P3-31)"
status: "approved"
priority: "P3"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Harness Improvements Specification (P3-26 through P3-31)

## Summary

Six targeted improvements to the conclave skill harness that give operators more
control over pipeline behavior, bring skeptic coverage into consistency,
introduce evaluator calibration, and surface the model-capability assumptions
currently invisible in skill prompts. The changes are grouped into four
implementation batches: Group A (P3-27 + P3-28) adds complexity-adaptive routing
and `--full` skeptic mode to pipeline skills; Group B (P3-26) makes skeptic
iteration limits configurable; Group C (P3-29) adds evaluator tuning via
calibration examples and post-mortem ratings; Group D (P3-30 + P3-31) adds
checkpoint frequency control and SCAFFOLD assumption comments. All changes are
prompt-content modifications to existing SKILL.md files and CLAUDE.md — no new
agents, no shared content changes, no new validators.

## Problem

1. **Rigid pipeline depth** (P3-27): Every task enters the same pipeline
   regardless of complexity. A simple bug fix traverses the same 5-stage
   plan-product pipeline as a greenfield feature. Existing artifact detection
   provides partial fast-pathing but no explicit complexity classification.

2. **Inconsistent skeptic coverage** (P3-28): plan-product Stages 1-3 use
   Lead-as-Skeptic (self-evaluation) while Stages 4-5 use a dedicated
   product-skeptic. The Anthropic harness design paper identifies separating
   generation from evaluation as more tractable than self-criticism. There is no
   opt-in for dedicated skeptics in early stages.

3. **Hard-coded iteration ceiling** (P3-26): All skeptic deadlock rules
   hard-code "3 rejections" — appropriate for implementation tasks but
   potentially conservative for subjective outputs (research, ideation) where 5+
   refinement rounds may be needed. No per-invocation override exists.

4. **No evaluator calibration** (P3-29): Skeptics evaluate against general
   principles with no project-specific calibration. Out-of-the-box Claude is a
   poor QA agent — it identifies issues then talks itself out of flagging them.
   No mechanism exists for operators to provide graded examples of good and bad
   skeptic outputs.

5. **No checkpoint flexibility** (P3-30): Every agent checkpoints after every
   significant state change. On Opus-class models running coherently for 2+
   hours, per-action checkpoints may add unnecessary I/O for short skills.

6. **Invisible assumptions** (P3-31): SKILL.md files encode model-capability
   assumptions (iteration caps, checkpoint frequency, model selection for
   skeptics) that are invisible to maintainers. When a new model ships, there is
   no systematic way to identify which scaffolding can be relaxed.

---

## Group A: Complexity-Adaptive Pipeline + Lead-as-Skeptic Consistency Fix (P3-27 + P3-28)

> **Must be implemented together** — both modify `plan-product/SKILL.md`
> Determine Mode and Orchestration Flow. P3-27 also modifies
> `build-product/SKILL.md`.

### Summary

Add a complexity classifier at pipeline entry points that routes tasks to
appropriate pipeline depths (Simple/Standard/Complex). Simultaneously add a
`--full` flag to plan-product that enables dedicated product-skeptic agents for
Stages 1-3, bringing them into consistency with Stages 4-5.

### Solution

#### A1. Flag Parsing in plan-product Determine Mode

Add `--complexity` and `--full` flag parsing to the existing `$ARGUMENTS`
parsing block in `plan-product/SKILL.md` (line 84). Insert after the existing
`--light` check (line 132) and before "## Spawn the Team" (line 140).

**Before** (current Determine Mode, lines 82-89):

```markdown
## Determine Mode

Based on $ARGUMENTS:

- **"status"**: Read all checkpoint files...
- **Empty/no args"**: First, scan...
- **"new [idea]"**: Full pipeline...
- **"review [spec-name]"**: Skip to Stage 5...
- **"reprioritize"**: Run Stage 3 only.
```

**After** (add flag parsing paragraph between the mode list and Artifact
Detection):

```markdown
## Determine Mode

Based on $ARGUMENTS:

- **"status"**: Read all checkpoint files...
- **Empty/no args"**: First, scan...
- **"new [idea]"**: Full pipeline...
- **"review [spec-name]"**: Skip to Stage 5...
- **"reprioritize"**: Run Stage 3 only.

### Flag Parsing

Parse the following flags from `$ARGUMENTS` before mode resolution. Strip
recognized flags; the remaining value is the mode argument (topic, spec-name,
etc.).

- **`--light`**: Enable lightweight mode (existing behavior, see Lightweight
  Mode section)
- **`--complexity=[simple|standard|complex]`**: Force complexity tier. If
  absent, the Lead infers it (see Complexity Classification below). If value is
  not one of the three valid tiers, log warning and default to Standard.
- **`--full`**: Enable dedicated product-skeptic for all five stages (see Full
  Skeptic Mode below). If absent, Stages 1-3 use Lead-as-Skeptic (current
  default).
- **`--max-iterations N`**: Configurable skeptic rejection ceiling (see Group B
  — P3-26). Default: 3.
- **`--checkpoint-frequency [every-step|milestones-only|final-only]`**:
  Checkpoint cadence (see Group D — P3-30). Default: every-step.

All flags are independent and composable. `--light` affects model selection,
`--complexity` affects stage routing, `--full` affects skeptic mode — they do
not conflict.

### Complexity Classification

Immediately after flag parsing and before artifact detection, the Team Lead
classifies the task:

1. If `--complexity` override is present, use that tier directly.
2. Otherwise, infer the tier based on:
   - **Simple**: Single well-defined feature, existing research/ideas artifacts
     found, narrow scope (one component), clear requirements stated in the
     invocation
   - **Standard**: Multi-component feature, partial or no existing artifacts,
     moderate scope — this is the default when signals are ambiguous
   - **Complex**: Multi-feature redesign, cross-cutting concerns, no existing
     artifacts, architecture-level changes, explicit user indication of high
     complexity
3. Report the classification to the user before proceeding:
```

Complexity: [tier] — [one-sentence rationale]

```
If inferred (no `--complexity` flag), add: "(override with --complexity=[simple|standard|complex])"
```

#### A2. Complexity-Based Stage Routing in plan-product Orchestration Flow

Modify the Orchestration Flow preamble (line 209-212) to include routing rules:

**Before** (lines 209-212):

```markdown
## Orchestration Flow

Execute stages sequentially. Each stage must complete before the next begins.
Skip stages where artifacts are FOUND per artifact detection.
```

**After**:

```markdown
## Orchestration Flow

Execute stages sequentially. Each stage must complete before the next begins.
Skip stages where artifacts are FOUND per artifact detection.

### Complexity Routing

The complexity tier modifies stage execution as follows:

- **Simple**: Skip Stage 1 (Research) and Stage 2 (Ideation) execution
  regardless of artifact detection. If research-findings or product-ideas
  artifacts exist, still consume them as inputs to Stage 3. If they don't exist,
  use the task description and existing docs as inputs. Stages 3-5 execute
  normally. Report: "Complexity: Simple — Stages 1-2 skipped"
- **Standard**: No routing changes. Artifact detection controls stage execution
  as before. This is the current behavior.
- **Complex**: All stages execute per artifact detection. Additionally, insert a
  **Complexity Review Checkpoint** between Stage 3 and Stage 4: the Team Lead
  summarizes scope, flags dependency risks across stages, and presents findings
  to the user before proceeding. The user may adjust scope or confirm
  continuation.

Artifact detection still runs for all 5 stages regardless of tier — it
determines which artifacts are available as inputs even when a stage's execution
is skipped.
```

Modify the Artifact Detection report (lines 116-128) to include tier:

**After** (updated report format):

```
Artifact Detection for "{topic}":
  Complexity:        [tier] ([rationale])
  research-findings: [result]
  product-ideas:     [result]
  roadmap-items:     [result]
  user-stories:      [result]
  technical-spec:    [result]

Pipeline will run: [stages to execute, reflecting complexity routing]
Skipping:          [stages skipped by artifact detection + complexity routing]
```

#### A3. `--full` Flag: Dedicated Product-Skeptic for Stages 1-3

Modify the product-skeptic spawn definition (lines 202-207):

**Before**:

```markdown
### Product Skeptic

- **Name**: `product-skeptic`
- **Model**: opus
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Review stories (Stage 4) and spec (Stage 5). Challenge
  completeness, consistency, testability. Nothing advances without your
  approval.
- **Stage**: 4, 5
```

**After**:

```markdown
### Product Skeptic

- **Name**: `product-skeptic`
- **Model**: opus
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: When `--full` is active: review research (Stage 1), ideas (Stage
  2), roadmap (Stage 3), stories (Stage 4), and spec (Stage 5). When `--full` is
  absent: review stories (Stage 4) and spec (Stage 5) only. Challenge
  completeness, consistency, testability. Nothing advances without your
  approval.
- **Stage**: 1-5 (with `--full`) or 4-5 (default)
```

Modify spawn timing: When `--full` is active, spawn product-skeptic before Stage
1 begins (not at Stage 4). Add this to the Orchestration Flow preamble:

```markdown
### Full Skeptic Mode (`--full`)

When `--full` is present:

1. Spawn product-skeptic at session start (before Stage 1), not at Stage 4.
2. Report to user: "Full mode: dedicated product-skeptic active for all five
   stages"
3. For each of Stages 1-3, replace Lead-as-Skeptic inline review with a
   product-skeptic gate:
   - After the stage's agents complete their work and the Lead synthesizes the
     artifact, route the artifact to product-skeptic via `SendMessage` with a
     `REVIEW REQUEST`.
   - product-skeptic reviews and issues `APPROVED` or `REJECTED` with specific
     feedback — same verdict format as Stages 4-5.
   - On `REJECTED`, iterate with the same deadlock protocol (N rejections,
     default 3).
4. Stages 4-5 are unchanged — product-skeptic already handles those.

When `--full` is absent:

- Stages 1-3 use Lead-as-Skeptic (current behavior, unchanged).
- product-skeptic spawns at Stage 4 (current behavior, unchanged).
```

Modify Stage 1 orchestration (lines 214-224) to be conditional:

**Before** (Stage 1, step 3-4):

```markdown
3. **Lead-as-Skeptic**: Review all findings yourself. Challenge conclusions,
   demand evidence, identify gaps.
4. If findings are insufficient, send specific feedback via SendMessage and have
   agents iterate
```

**After**:

```markdown
3. **Review gate** (conditional):
   - If `--full`: Route synthesized findings to product-skeptic via
     `SendMessage` with `REVIEW REQUEST`. product-skeptic reviews for
     completeness, evidence quality, gap identification. On `REJECTED`, iterate
     (deadlock cap: N rejections). On `APPROVED`, proceed.
   - If default (no `--full`): **Lead-as-Skeptic**: Review all findings
     yourself. Challenge conclusions, demand evidence, identify gaps. If
     findings are insufficient, send specific feedback via SendMessage and have
     agents iterate.
```

Apply the same conditional pattern to Stage 2 (lines 232-233) and Stage 3 (lines
244-245):

- Stage 2 product-skeptic review domain: idea viability, evidence for impact
  claims, weak/duplicate ideas, alignment with research
- Stage 3 product-skeptic review domain: dependency accuracy, priority
  rationale, effort estimate consistency, conflicts with existing roadmap items

Update the product-skeptic spawn prompt to list all five review domains
(research, ideation, roadmap, stories, spec) and note that Stages 1-3 are only
active when `--full` is passed.

#### A4. Complexity-Adaptive Routing in build-product

Apply the same flag parsing and complexity classification pattern to
`build-product/SKILL.md`:

1. **Determine Mode** (line 89): Add `--complexity` flag parsing using the same
   format as plan-product (Flag Parsing subsection). `--full` is NOT applicable
   to build-product (it has no Lead-as-Skeptic asymmetry).

2. **Complexity Routing** for build-product's 3 stages:
   - **Simple**: If implementation-plan NOT_FOUND, skip Stage 1 (Planning) — the
     Lead synthesizes a minimal inline plan from the spec and user stories
     before proceeding to Stage 2. If implementation-plan is FOUND, use it
     normally.
   - **Standard**: No change (current behavior).
   - **Complex**: Insert a mid-build complexity review after API contract
     negotiation and before implementation begins — quality-skeptic performs an
     intermediate review examining scope boundaries and dependency risks
     (separate from the existing pre-implementation gate).

3. **Artifact Detection report**: Include tier, same format as plan-product.

### Files to Modify

| File                                             | Change                                                                                                                                                                                                                                                             |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Flag Parsing subsection in Determine Mode; Complexity Classification step; Complexity Routing in Orchestration Flow; `--full` conditional gates in Stages 1-3; product-skeptic spawn definition update; spawn timing conditional; artifact detection report format |
| `plugins/conclave/skills/build-product/SKILL.md` | Flag Parsing subsection in Determine Mode; Complexity Classification step; Complexity Routing for 3-stage pipeline; artifact detection report format                                                                                                               |

### Success Criteria

1. plan-product Determine Mode parses `--complexity` and `--full` flags without
   breaking existing mode resolution
2. plan-product classifies tasks as Simple/Standard/Complex and reports the tier
   to the user
3. Simple tier skips Stages 1-2 execution in plan-product; existing artifacts
   are still consumed as inputs
4. Complex tier inserts a Complexity Review Checkpoint between Stage 3 and Stage
   4 in plan-product
5. Standard tier behavior is identical to current behavior (no regression)
6. `--full` spawns product-skeptic before Stage 1 and routes Stage 1-3 artifacts
   through product-skeptic gates
7. Without `--full`, Stages 1-3 use Lead-as-Skeptic (no regression)
8. build-product parses `--complexity` flag and applies Simple/Standard/Complex
   routing to its 3-stage pipeline
9. `bash scripts/validate.sh` passes (12/12) after all changes

### Dependency Notes

- Group A has no external dependencies — all prerequisite P2 items are complete.
- P3-27 and P3-28 MUST be implemented in the same PR to avoid merge conflicts in
  `plan-product/SKILL.md`.
- `--max-iterations` flag (P3-26, Group B) is referenced in the Flag Parsing
  subsection. If Group A is implemented before Group B, use the hard-coded
  default of 3 and add a `TODO: P3-26` marker for the flag reference. If
  implemented together, wire them up directly.

---

## Group B: Configurable Skeptic Iteration Limits (P3-26)

### Summary

Add a `--max-iterations N` flag to all 14 multi-agent skills that controls the
skeptic rejection cap before escalation. Default remains 3 (current behavior).
Document the flag in wizard-guide.

### Solution

#### B1. Flag Parsing in Determine Mode (all 14 multi-agent skills)

Add `--max-iterations N` parsing to the Determine Mode section of each
multi-agent SKILL.md. For pipeline skills (plan-product, build-product), this is
part of the Flag Parsing subsection defined in Group A. For granular and
business skills, add a new "Flag Parsing" paragraph at the top of Determine
Mode.

**Change to each skill's Determine Mode** (insert before mode resolution):

```markdown
### Flag Parsing

Parse the following flags from `$ARGUMENTS` before mode resolution. Strip
recognized flags; the remaining value is the mode argument.

- **`--max-iterations N`**: Set the skeptic rejection ceiling for this session.
  Default: 3. If N ≤ 0 or non-integer, log warning ("Invalid --max-iterations
  value; using default of 3") and fall back to 3. If `--max-iterations` appears
  with no following value, log warning and fall back to 3. If N is a float
  (e.g., 3.5), floor to integer.
- **`--checkpoint-frequency [every-step|milestones-only|final-only]`**:
  Checkpoint cadence (see Group D — P3-30). Default: every-step.
```

When N differs from default (3), the Team Lead reports it in the session
opening: "Max skeptic iterations: N (default: 3)".

#### B2. Propagate N to Skeptic Deadlock Rules (all 14 multi-agent skills)

Replace every hard-coded "3" in skeptic deadlock rules with the configurable N.

**Before** (example from plan-product, line 306):

```markdown
- **Skeptic deadlock**: If the product-skeptic rejects the same deliverable 3
  times, STOP iterating. The Team Lead escalates to the human operator with a
  summary of the submissions, the Skeptic's objections across all rounds, and
  the team's attempts to address them. The human decides: override the Skeptic,
  provide guidance, or abort.
```

**After**:

```markdown
- **Skeptic deadlock**: If the product-skeptic rejects the same deliverable N
  times (default 3, set via `--max-iterations`), STOP iterating. The Team Lead
  escalates to the human operator with a summary of the submissions, the
  Skeptic's objections across all rounds, and the team's attempts to address
  them. The human decides: override the Skeptic, provide guidance, or abort.
```

Apply this pattern to all deadlock rules across 14 skills:

| Skill                 | Deadlock rule location                              | Roles affected                                |
| --------------------- | --------------------------------------------------- | --------------------------------------------- |
| plan-product          | Failure Recovery: "Skeptic deadlock"                | product-skeptic, Lead-as-Skeptic (Stages 1-3) |
| build-product         | Failure Recovery: "Skeptic deadlock", "QA deadlock" | quality-skeptic, plan-skeptic, qa-agent       |
| build-implementation  | Failure Recovery: "Skeptic deadlock", "QA deadlock" | quality-skeptic, qa-agent                     |
| plan-implementation   | Failure Recovery: "Skeptic deadlock"                | plan-skeptic                                  |
| research-market       | Failure Recovery: "Skeptic deadlock"                | research-skeptic                              |
| ideate-product        | Failure Recovery: "Skeptic deadlock"                | product-skeptic                               |
| manage-roadmap        | Failure Recovery: "Skeptic deadlock"                | product-skeptic                               |
| write-stories         | Failure Recovery: "Skeptic deadlock"                | story-skeptic                                 |
| write-spec            | Failure Recovery: "Skeptic deadlock"                | spec-skeptic                                  |
| review-quality        | Failure Recovery: "Skeptic deadlock"                | ops-skeptic                                   |
| run-task              | Failure Recovery: "Skeptic deadlock"                | task-skeptic                                  |
| draft-investor-update | Failure Recovery: "Skeptic deadlock"                | narrative-skeptic, accuracy-skeptic           |
| plan-sales            | Failure Recovery: "Skeptic deadlock"                | strategy-skeptic, bias-skeptic                |
| plan-hiring           | Failure Recovery: "Skeptic deadlock"                | fit-skeptic                                   |

**Counter semantics**: Each gate resets its own counter per deliverable, not per
session. A skill with multiple skeptic gates (e.g., plan-implementation with
pre- and post-implementation gates) uses N independently for each gate. Pipeline
skill stage skips do not carry over counters.

#### B3. Document in wizard-guide

Add a "Common Flags" section to `plugins/conclave/skills/wizard-guide/SKILL.md`
before the skill listing ("The Conclave" section, line 40). This becomes the
canonical location for cross-skill flags.

**New section**:

```markdown
## Common Flags

These flags are accepted by all 14 multi-agent skills. Single-agent skills
(setup-project, wizard-guide) ignore them.

| Flag                     | Values                                        | Default      | Description                                                   |
| ------------------------ | --------------------------------------------- | ------------ | ------------------------------------------------------------- |
| `--max-iterations N`     | Positive integer                              | 3            | Skeptic rejection ceiling before escalation to operator       |
| `--checkpoint-frequency` | `every-step`, `milestones-only`, `final-only` | `every-step` | How often agents write progress checkpoints                   |
| `--light`                | (flag, no value)                              | off          | Reduce agent models for cost savings; quality gates stay Opus |

Pipeline skills (plan-product, build-product) also accept:

| Flag           | Values                          | Default       | Description                                           |
| -------------- | ------------------------------- | ------------- | ----------------------------------------------------- |
| `--complexity` | `simple`, `standard`, `complex` | auto-inferred | Force complexity tier for stage routing               |
| `--full`       | (flag, no value)                | off           | plan-product only: dedicated skeptic for all 5 stages |

Example: `/write-spec my-feature --max-iterations 5` Example:
`/plan-product new auth-redesign --complexity=complex --full`
```

### Files to Modify

| File                                            | Change                                                               |
| ----------------------------------------------- | -------------------------------------------------------------------- |
| All 14 multi-agent `SKILL.md` files             | Flag Parsing subsection in Determine Mode; deadlock rule text update |
| `plugins/conclave/skills/wizard-guide/SKILL.md` | New "Common Flags" section                                           |

### Success Criteria

1. `--max-iterations 5` correctly sets N=5 for all skeptic gates in any
   multi-agent skill
2. Absent flag defaults to N=3 — identical to current behavior
3. Invalid values (0, negative, non-integer, missing) fall back to 3 with a
   warning
4. Each deadlock rule references "N times (default 3, set via --max-iterations)"
   instead of hard-coded "3"
5. Counter resets per deliverable, not per session
6. wizard-guide includes "Common Flags" section documenting the flag
7. `bash scripts/validate.sh` passes (12/12) after all changes

### Dependency Notes

- No external dependencies.
- If implemented alongside Group A, the Flag Parsing subsection is shared — wire
  `--max-iterations` into the same parse block as `--complexity` and `--full`.

---

## Group C: Evaluator Tuning Mechanism (P3-29)

> **Dependencies**: P2-11 (Sprint Contracts), P2-12 (User-Writable Config),
> P2-13 (User-Writable Config Spec) — all complete. P3-28 (Group A) — should be
> implemented first so calibration data from dedicated Stage 1-3 skeptics is
> part of the eval collection surface.

### Summary

Establish a calibration system for skeptic prompts: store graded evaluation
examples in `.claude/conclave/eval-examples/`, inject them into skeptic spawn
prompts, and collect post-mortem quality ratings after pipeline runs. Over time,
operators curate examples using rating data to improve skeptic calibration.

### Solution

#### C1. Eval Examples Directory Convention

Add a new optional setup step to `build-implementation/SKILL.md` (after the
guidance reading step 11) and to `plan-implementation/SKILL.md` (analogous
location):

**New step 12 in build-implementation Setup**:

````markdown
12. **Read evaluator examples (optional).** Check whether
    `.claude/conclave/eval-examples/` exists and is a directory. If it exists
    and contains `.md` files, read each file and prepare the content for
    injection into the Quality Skeptic's spawn prompt. Apply the same defensive
    reading contract as the guidance directory (step 11):
    - Directory absent → proceed silently, no eval examples injected
    - Directory exists but empty → proceed silently
    - Directory exists as a file (not a directory) → log warning, proceed
      without examples
    - Individual file unreadable → log warning naming the file, skip, continue
    - Non-`.md` files → ignore silently

    When eval example files are found, format them as a single block for the
    Quality Skeptic's spawn prompt:

    ```markdown
    ## Evaluator Examples (user-provided)

    Read these examples before performing any review. They represent past
    quality benchmarks from this project. Use them to calibrate your judgment —
    APPROVED examples show the quality bar; REJECTED examples show failure
    patterns to watch for.

    ### passing-example.md

    [contents of passing-example.md]

    ### failing-patterns.md

    [contents of failing-patterns.md]
    ```

    Each file's content is introduced by its filename as a `###` sub-heading.
    The `## Evaluator Examples (user-provided)` heading is mandatory. If no eval
    example files are found, omit the block entirely. Inject into Quality
    Skeptic (and QA Agent) spawn prompts ONLY — not execution agents
    (backend-eng, frontend-eng).
````

For `plan-product/SKILL.md` with `--full` active: inject eval examples into
product-skeptic's spawn prompt using the same mechanism.

#### C2. Post-Mortem Quality Rating

Add a post-mortem step to pipeline completion in `build-implementation/SKILL.md`
(after step 9, cost summary) and `plan-product/SKILL.md` (after end-of-session
summary):

**New step in build-implementation Pipeline Completion**:

````markdown
10. **Post-Mortem Rating (optional).** Ask the user: "How would you rate the
    quality of this pipeline run? [1-5, or skip]"
    - If the user provides a rating (1-5): write post-mortem to
      `docs/progress/{feature}-postmortem.md` with frontmatter:
      ```yaml
      ---
      feature: "{feature}"
      team: "build-implementation"
      rating: { 1-5 }
      date: "{ISO-8601}"
      skeptic-gate-count: { number of times any skeptic gate fired }
      rejection-count: { number of times any deliverable was rejected }
      max-iterations-used: { N from session }
      ---
      ```
    - If the user skips (says "skip" or provides no response): proceed silently,
      no post-mortem file written.
    - If the user provides an invalid value (outside 1-5): ask once for
      clarification. If still invalid, skip silently.
    - This step only fires after real pipeline execution, not in `status` mode.
````

Apply the same post-mortem step to `plan-product/SKILL.md` Pipeline Completion
(after the end-of-session summary, before cost summary).

#### C3. Skeptic Prompt Calibration Instruction

Add a calibration instruction to the Quality Skeptic's spawn prompt in
`build-implementation/SKILL.md` — this instruction is conditional on eval
examples being present:

```markdown
### Evaluator Calibration

If `## Evaluator Examples (user-provided)` appears above in your prompt:

- Read all examples before performing any review
- Files with `## APPROVED` sections show the quality bar — use as acceptance
  threshold anchors
- Files with `## REJECTED` sections show failure patterns — use as rejection
  pattern anchors
- Files without these headers are general calibration context
- Do NOT blindly mimic examples — use them as reference anchors for your own
  judgment
- If no eval examples are present, perform your review as normal — no change in
  behavior
```

Add the same instruction to product-skeptic's spawn prompt in
`plan-product/SKILL.md`.

### Files to Modify

| File                                                    | Change                                                                                                                                   |
| ------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/build-implementation/SKILL.md` | New Setup step 12 (eval examples reading); Pipeline Completion post-mortem step; Quality Skeptic spawn prompt calibration instruction    |
| `plugins/conclave/skills/plan-implementation/SKILL.md`  | New Setup step (eval examples reading); plan-skeptic spawn prompt calibration instruction                                                |
| `plugins/conclave/skills/plan-product/SKILL.md`         | Pipeline Completion post-mortem step; product-skeptic spawn prompt calibration instruction; eval examples injection when `--full` active |
| `plugins/conclave/skills/build-product/SKILL.md`        | Pipeline Completion post-mortem step; quality-skeptic spawn prompt calibration instruction                                               |

### Success Criteria

1. `.claude/conclave/eval-examples/` directory absent: skills proceed silently
   with no behavioral change
2. Eval example `.md` files present: content injected into Quality Skeptic /
   product-skeptic spawn prompts under `## Evaluator Examples (user-provided)`
   heading
3. Injection targets skeptic agents only — not execution agents
4. Post-mortem rating prompt appears after real pipeline completion (not status
   mode)
5. Rating 1-5 writes post-mortem file with correct frontmatter fields
6. Skip/invalid response: no file written, no pipeline blockage
7. Calibration instruction references APPROVED/REJECTED section conventions
8. `bash scripts/validate.sh` passes (12/12) after all changes

### Dependency Notes

- **Hard dependency on P3-28 (Group A)**: Calibration data from dedicated Stage
  1-3 skeptics (when `--full` is active) is part of the eval collection surface.
  Implement Group A first.
- **Soft dependency on P2-11/P2-12/P2-13**: All complete. The eval examples
  directory follows the same user-writable config pattern established by
  `.claude/conclave/guidance/`.
- No new validators needed — defensive reading contract is already proven by
  P2-12.

---

## Group D: Checkpoint Frequency + Design Assumptions Documentation (P3-30 + P3-31)

### Summary

Add a `--checkpoint-frequency` flag to control checkpoint cadence across all
multi-agent skills. Separately, define and apply `<!-- SCAFFOLD: ... -->`
comments that document model-capability assumptions in SKILL.md files.

### Solution

#### D1. `--checkpoint-frequency` Flag Parsing (P3-30)

Add `--checkpoint-frequency` to the Flag Parsing subsection in each multi-agent
skill's Determine Mode (same parse block as `--max-iterations`). See Group B,
section B1 for the parse block template — `--checkpoint-frequency` is included
there.

**Parsing rules**:

- Valid values: `every-step`, `milestones-only`, `final-only`
- Default: `every-step` (current behavior)
- Invalid value: log warning ("Invalid --checkpoint-frequency value; using
  default (every-step)"), fall back to `every-step`
- Single-agent skills ignore the flag silently

#### D2. Per-Frequency Checkpoint Behavior

Modify the "When to Checkpoint" section in each of the 14 multi-agent SKILL.md
files to be conditional on frequency mode.

**Before** (example from build-implementation, lines 104-111):

```markdown
### When to Checkpoint

Agents write a checkpoint after:

- Claiming a task (phase: current phase, status: in_progress)
- Completing a deliverable (status: awaiting_review)
- Receiving review feedback (status: in_progress, note the feedback)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)
```

**After**:

```markdown
### When to Checkpoint

Checkpoint frequency is set via `--checkpoint-frequency` (default:
`every-step`).

**`every-step`** (default) — checkpoint after:

- Claiming a task (phase: current phase, status: in_progress)
- Completing a deliverable (status: awaiting_review)
- Receiving review feedback (status: in_progress, note the feedback)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)

**`milestones-only`** — checkpoint after:

- Completing a deliverable (status: awaiting_review)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)

**`final-only`** — checkpoint after:

- Being blocked (status: blocked, note what's needed) — always checkpointed
  regardless of frequency
- Completing their work (status: complete)

When using `milestones-only` or `final-only`, session recovery resolution may be
coarser than usual. The Team Lead notes this in recovery messages.
```

The Team Lead communicates the frequency to spawned agents: "Checkpoint
frequency: [mode] — [skip intermediate checkpoints | checkpoint at milestones
only]"

#### D3. SCAFFOLD Comment Convention in CLAUDE.md (P3-31)

Add a "SCAFFOLD Comments" subsection to the "Development Guidelines" section of
`CLAUDE.md`:

**New subsection** (insert after the existing "The Skeptic role is
non-negotiable..." bullet):

```markdown
### SCAFFOLD Comments

SKILL.md files encode assumptions about model capabilities that may become stale
as models improve. Document these assumptions with inline HTML comments using
this format:
```

<!-- SCAFFOLD: [what this scaffolding does] | ASSUMPTION: [model-capability assumption] | TEST REMOVAL: [condition for testing removal] -->

```

All three fields are required. A comment missing any field is considered malformed.

Examples:
- `<!-- SCAFFOLD: Max N skeptic rejections before escalation | ASSUMPTION: models below Opus require a hard cap to prevent infinite skeptic loops | TEST REMOVAL: when pipeline consistently converges in ≤2 rejections across 10+ sessions -->`
- `<!-- SCAFFOLD: Lead performs inline skeptic review for Stages 1-3 | ASSUMPTION: Sonnet-class model sufficient for early-stage review; dedicated Opus skeptic adds cost without quality gain | TEST REMOVAL: benchmark --full vs. default quality on the same pipeline topic -->`

**Placement rules**:
- Place directly above or on the same line as the construct it documents
- NEVER place inside spawn prompt code blocks (verbatim content injected into agent context) — agents may misinterpret the comment as an instruction
- SCAFFOLD comment content must NOT contain `##`-prefixed lines (would interfere with A-series section detection)

SCAFFOLD comments are documentation for skill maintainers, not end-user-visible. No validator enforces the convention — enforcement is by code review.
```

#### D4. Apply SCAFFOLD Comments to Multi-Agent SKILL.md Files (P3-31)

Add `<!-- SCAFFOLD: ... -->` comments to all 14 multi-agent SKILL.md files.
Minimum required annotations:

1. **Skeptic iteration caps** (in Failure Recovery section of each skill):

   ```
   <!-- SCAFFOLD: Max N skeptic rejections before escalation | ASSUMPTION: models below Opus require a hard cap to prevent infinite skeptic loops | TEST REMOVAL: when pipeline consistently converges in ≤2 rejections across 10+ sessions -->
   ```

2. **Lead-as-Skeptic pattern** (in plan-product Stages 1-3):

   ```
   <!-- SCAFFOLD: Lead performs inline skeptic review instead of spawning dedicated skeptic | ASSUMPTION: Sonnet-class model sufficient for early-stage research review; dedicated Opus skeptic adds cost without quality gain for research/ideation | TEST REMOVAL: benchmark --full vs. default quality on the same pipeline topic -->
   ```

3. **every-step checkpoint default** (in When to Checkpoint section of each
   skill):

   ```
   <!-- SCAFFOLD: Checkpoint after every significant state change | ASSUMPTION: agent context degrades on long runs; frequent checkpoints enable recovery | TEST REMOVAL: on Opus-class models, test milestones-only and measure recovery accuracy -->
   ```

4. **Opus model for skeptic/QA agents** (in spawn definitions of each skill):
   ```
   <!-- SCAFFOLD: Quality Skeptic and QA Agent always use Opus model | ASSUMPTION: Sonnet-class models produce more false approvals at quality gates | TEST REMOVAL: A/B comparison — Opus vs. Sonnet skeptic on 5 identical pipelines; measure rejection accuracy -->
   ```

Additional assumptions discovered during the annotation pass should also be
documented. The annotation pass should be done as a single commit.

### Files to Modify

| File                                            | Change                                                                                                                                                       |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| All 14 multi-agent `SKILL.md` files             | "When to Checkpoint" section updated to conditional format (P3-30); SCAFFOLD comments added at iteration caps, checkpoint defaults, model selections (P3-31) |
| `plugins/conclave/skills/plan-product/SKILL.md` | Additional SCAFFOLD comment on Lead-as-Skeptic pattern (P3-31)                                                                                               |
| `CLAUDE.md`                                     | New "SCAFFOLD Comments" subsection in Development Guidelines (P3-31)                                                                                         |

### Success Criteria

1. `--checkpoint-frequency milestones-only` reduces checkpoints to
   deliverable-complete, blocked, and work-complete events
2. `--checkpoint-frequency final-only` reduces checkpoints to blocked and
   work-complete events only
3. Default (`every-step`) behavior is identical to current behavior (no
   regression)
4. Blocked events always trigger a checkpoint regardless of frequency (safety
   invariant)
5. `CLAUDE.md` defines the SCAFFOLD comment convention with format, examples,
   and placement rules
6. All 14 multi-agent SKILL.md files have at minimum 3 SCAFFOLD comments
   (iteration cap, checkpoint default, Opus model selection)
7. plan-product has an additional SCAFFOLD comment on Lead-as-Skeptic
8. No SCAFFOLD comments appear inside spawn prompt code blocks
9. `bash scripts/validate.sh` passes (12/12) after all changes

### Dependency Notes

- P3-30 has no external dependencies. Can be implemented independently.
- P3-31 has a soft dependency on P3-03 (Contribution Guide) for context but does
  not require it.
- P3-30 and P3-31 can be implemented in parallel — they touch different parts of
  the same files (When to Checkpoint vs. inline comments).

---

## Constraints

1. No new agents — all changes are prompt-content modifications
2. No shared content changes (`plugins/conclave/shared/principles.md` and
   `communication-protocol.md` are untouched)
3. No sync script changes
4. All 12/12 validators must pass after each group's changes
5. All flags are optional with defaults matching current behavior — zero
   behavioral regression for existing invocations
6. Flag values are parsed as structured scalars (integers, enums) — never
   injected as freeform strings into agent prompts
7. Eval examples are injected under clearly labeled
   `## Evaluator Examples (user-provided)` heading — agents treat as context,
   not directives
8. The Skeptic role is non-negotiable — no change weakens skeptic gates; P3-28
   strengthens them

## Out of Scope

- Automated validation of `<!-- SCAFFOLD: ... -->` comment format — enforced by
  code review
- Persisting flags as project defaults in `.claude/conclave/` config — flags are
  per-invocation only
- Evaluator tuning for single-agent skills (no skeptic gate to calibrate)
- Complexity classifier training data or ML-based classification — the
  classifier is a Lead reasoning step
- Cross-session eval example analysis or dashboards
- `--full` flag for skills other than plan-product (other skills already use
  dedicated skeptics)
- Contract amendment protocol (deferred per Sprint Contracts spec)

## Complete Files to Modify

| File                                                     | Groups     | Change Summary                                                                                                                                                                                      |
| -------------------------------------------------------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`          | A, B, C, D | Flag Parsing (all flags); Complexity Classification + Routing; `--full` skeptic mode; deadlock rule update; post-mortem step; eval examples injection; checkpoint frequency; SCAFFOLD comments      |
| `plugins/conclave/skills/build-product/SKILL.md`         | A, B, C, D | Flag Parsing (--complexity, --max-iterations, --checkpoint-frequency); Complexity Routing; deadlock rule update; post-mortem step; eval examples injection; checkpoint frequency; SCAFFOLD comments |
| `plugins/conclave/skills/build-implementation/SKILL.md`  | B, C, D    | Flag Parsing; deadlock rule update; eval examples Setup step; post-mortem step; Quality Skeptic calibration instruction; checkpoint frequency; SCAFFOLD comments                                    |
| `plugins/conclave/skills/plan-implementation/SKILL.md`   | B, C, D    | Flag Parsing; deadlock rule update; eval examples Setup step; plan-skeptic calibration instruction; checkpoint frequency; SCAFFOLD comments                                                         |
| `plugins/conclave/skills/research-market/SKILL.md`       | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/ideate-product/SKILL.md`        | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/manage-roadmap/SKILL.md`        | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/write-stories/SKILL.md`         | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/write-spec/SKILL.md`            | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/review-quality/SKILL.md`        | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/run-task/SKILL.md`              | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/plan-sales/SKILL.md`            | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/plan-hiring/SKILL.md`           | B, D       | Flag Parsing; deadlock rule update; checkpoint frequency; SCAFFOLD comments                                                                                                                         |
| `plugins/conclave/skills/wizard-guide/SKILL.md`          | B          | New "Common Flags" section documenting all cross-skill flags                                                                                                                                        |
| `CLAUDE.md`                                              | D          | New "SCAFFOLD Comments" subsection in Development Guidelines                                                                                                                                        |

## Implementation Order

1. **Group A (P3-27 + P3-28)** — implement first. Largest change, touches
   plan-product and build-product Determine Mode and Orchestration Flow. Single
   PR.
2. **Group B (P3-26)** — implement second. Touches all 14 multi-agent skills +
   wizard-guide. Builds on Flag Parsing subsection introduced by Group A in
   pipeline skills. Single PR.
3. **Group D (P3-30 + P3-31)** — implement third. Touches all 14 multi-agent
   skills + CLAUDE.md. Builds on Flag Parsing subsection. Can be split into two
   PRs (P3-30 and P3-31 independently) or one.
4. **Group C (P3-29)** — implement last. Depends on Group A (`--full` mode for
   broader eval collection). Touches 4 skills. Single PR.
