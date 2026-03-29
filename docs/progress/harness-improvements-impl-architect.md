---
type: "implementation-plan"
feature: "harness-improvements"
status: "draft"
source_spec: "docs/specs/harness-improvements/spec.md"
approved_by: ""
created: "2026-03-27"
updated: "2026-03-27"
---

# Implementation Plan: Harness Improvements (P3-26 through P3-31)

## Overview

Six prompt-engineering improvements to 16 files (14 multi-agent SKILL.md files +
wizard-guide/SKILL.md + CLAUDE.md). All changes are markdown edits — no
application code, no validators, no shared content changes. Four implementation
groups (A → B → D → C) with strict ordering. The spec provides extensive
before/after diffs; this plan maps those diffs to exact file locations.

## File Changes

| #   | Action | File Path                                                | Group | Description                                                                                                                                                                                                                                                                                                                                                                 |
| --- | ------ | -------------------------------------------------------- | ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | modify | `plugins/conclave/skills/plan-product/SKILL.md`          | A     | Flag Parsing subsection (after line 89, before Artifact Detection ~91); Complexity Classification + Routing in Orchestration Flow (~209-212); `--full` skeptic mode conditionals in Stages 1-3 (~220, ~232, ~244); product-skeptic spawn definition update (~202-207); spawn timing conditional in Orchestration Flow preamble; artifact detection report format (~116-128) |
| 2   | modify | `plugins/conclave/skills/build-product/SKILL.md`         | A     | Flag Parsing subsection in Determine Mode (after line 95, before Artifact Detection ~97); Complexity Classification + Routing for 3-stage pipeline (~214-217); artifact detection report format (~130-145)                                                                                                                                                                  |
| 3   | modify | `plugins/conclave/skills/plan-product/SKILL.md`          | B     | Add `--max-iterations` and `--checkpoint-frequency` to existing Flag Parsing (from Group A); update deadlock rule in Failure Recovery (~306)                                                                                                                                                                                                                                |
| 4   | modify | `plugins/conclave/skills/build-product/SKILL.md`         | B     | Add `--max-iterations` and `--checkpoint-frequency` to existing Flag Parsing (from Group A); update deadlock rules in Failure Recovery (~312-313); update QA deadlock in Orchestration Flow Stage 2 step 7 (~263)                                                                                                                                                           |
| 5   | modify | `plugins/conclave/skills/build-implementation/SKILL.md`  | B     | Add Flag Parsing subsection in Determine Mode (after line 121, before Lightweight Mode ~123); update deadlock rules in Failure Recovery (~202-203)                                                                                                                                                                                                                          |
| 6   | modify | `plugins/conclave/skills/plan-implementation/SKILL.md`   | B     | Add Flag Parsing subsection in Determine Mode (after line 87, before next section); update deadlock rule in Failure Recovery (~142)                                                                                                                                                                                                                                         |
| 7   | modify | `plugins/conclave/skills/write-spec/SKILL.md`            | B     | Add Flag Parsing in Determine Mode (~82); update deadlock rule in Failure Recovery (~144+)                                                                                                                                                                                                                                                                                  |
| 8   | modify | `plugins/conclave/skills/write-stories/SKILL.md`         | B     | Add Flag Parsing in Determine Mode (~72); update deadlock rule in Failure Recovery (~127+)                                                                                                                                                                                                                                                                                  |
| 9   | modify | `plugins/conclave/skills/research-market/SKILL.md`       | B     | Add Flag Parsing in Determine Mode (~72); ADD new Skeptic deadlock rule to Failure Recovery (~125)                                                                                                                                                                                                                                                                          |
| 10  | modify | `plugins/conclave/skills/ideate-product/SKILL.md`        | B     | Add Flag Parsing in Determine Mode (~74); ADD new Skeptic deadlock rule to Failure Recovery (~129)                                                                                                                                                                                                                                                                          |
| 11  | modify | `plugins/conclave/skills/manage-roadmap/SKILL.md`        | B     | Add Flag Parsing in Determine Mode (~72); ADD new Skeptic deadlock rule to Failure Recovery (~122)                                                                                                                                                                                                                                                                          |
| 12  | modify | `plugins/conclave/skills/review-quality/SKILL.md`        | B     | Add Flag Parsing in Determine Mode (~74); update deadlock rule in Failure Recovery (~147+)                                                                                                                                                                                                                                                                                  |
| 13  | modify | `plugins/conclave/skills/run-task/SKILL.md`              | B     | Add Flag Parsing in Determine Mode (~69); update deadlock rule in Failure Recovery (~133+)                                                                                                                                                                                                                                                                                  |
| 14  | modify | `plugins/conclave/skills/draft-investor-update/SKILL.md` | B     | Add Flag Parsing in Determine Mode (~77); update deadlock rule in Failure Recovery (~182+)                                                                                                                                                                                                                                                                                  |
| 15  | modify | `plugins/conclave/skills/plan-sales/SKILL.md`            | B     | Add Flag Parsing in Determine Mode (~86); update deadlock rule in Failure Recovery (~300+)                                                                                                                                                                                                                                                                                  |
| 16  | modify | `plugins/conclave/skills/plan-hiring/SKILL.md`           | B     | Add Flag Parsing in Determine Mode (~93); update deadlock rule in Failure Recovery (~442+)                                                                                                                                                                                                                                                                                  |
| 17  | modify | `plugins/conclave/skills/wizard-guide/SKILL.md`          | B     | New "Common Flags" section (insert before "## The Conclave" at line 40)                                                                                                                                                                                                                                                                                                     |
| 18  | modify | `CLAUDE.md`                                              | D     | New "SCAFFOLD Comments" subsection in Development Guidelines (after line 158)                                                                                                                                                                                                                                                                                               |
| 19  | modify | All 14 multi-agent SKILL.md files                        | D     | Update "When to Checkpoint" to conditional format; add `--checkpoint-frequency` behavior                                                                                                                                                                                                                                                                                    |
| 20  | modify | All 14 multi-agent SKILL.md files                        | D     | Add SCAFFOLD comments (iteration caps, checkpoint defaults, Opus model selection)                                                                                                                                                                                                                                                                                           |
| 21  | modify | `plugins/conclave/skills/plan-product/SKILL.md`          | D     | Additional SCAFFOLD comment on Lead-as-Skeptic pattern in Stages 1-3                                                                                                                                                                                                                                                                                                        |
| 22  | modify | `plugins/conclave/skills/build-implementation/SKILL.md`  | C     | New Setup step 12 (eval examples reading, after line ~43); Pipeline Completion post-mortem step; Quality Skeptic spawn prompt calibration instruction                                                                                                                                                                                                                       |
| 23  | modify | `plugins/conclave/skills/plan-implementation/SKILL.md`   | C     | New Setup step (eval examples reading); plan-skeptic spawn prompt calibration instruction                                                                                                                                                                                                                                                                                   |
| 24  | modify | `plugins/conclave/skills/plan-product/SKILL.md`          | C     | Pipeline Completion post-mortem step (~285-286); product-skeptic spawn prompt calibration instruction; eval examples injection when `--full` active                                                                                                                                                                                                                         |
| 25  | modify | `plugins/conclave/skills/build-product/SKILL.md`         | C     | Pipeline Completion post-mortem step (~294-296); quality-skeptic spawn prompt calibration instruction                                                                                                                                                                                                                                                                       |

## Detailed Edit Specifications

### Group A: Complexity-Adaptive Pipeline + Full Skeptic Mode (P3-27 + P3-28)

**Files: plan-product/SKILL.md, build-product/SKILL.md**

#### A-Edit-1: Flag Parsing subsection in plan-product Determine Mode

- **Location**: `plan-product/SKILL.md`, after line 89 (the "reprioritize"
  bullet), before "### Artifact Detection" at line 91
- **Action**: INSERT new `### Flag Parsing` and `### Complexity Classification`
  subsections
- **Content**: Verbatim from spec section A1 — the Flag Parsing block with
  `--light`, `--complexity`, `--full`, `--max-iterations`,
  `--checkpoint-frequency` flags, followed by the Complexity Classification step
- **Note**: `--max-iterations` and `--checkpoint-frequency` are included here
  with `TODO: P3-26` / `TODO: P3-30` markers if Group A lands before Group B/D.
  If implemented in sequence (A then B then D), wire them up in Group B/D passes
  instead.
- **Decision**: Include all 5 flags in the Flag Parsing block from the start.
  Group B and D will update the deadlock rules and checkpoint sections that
  reference them, but the flag parsing itself is complete in Group A. This
  avoids re-editing the same parse block 3 times.

#### A-Edit-2: Artifact Detection report format in plan-product

- **Location**: `plan-product/SKILL.md`, lines 116-128 (the report format block)
- **Action**: REPLACE the report format to include `Complexity:` line and
  routing summary
- **Content**: Verbatim from spec section A2 (updated report format)

#### A-Edit-3: Complexity Routing in plan-product Orchestration Flow

- **Location**: `plan-product/SKILL.md`, lines 209-212 (Orchestration Flow
  preamble)
- **Action**: REPLACE the 2-line preamble with expanded version including
  `### Complexity Routing` and `### Full Skeptic Mode (--full)` subsections
- **Content**: Verbatim from spec sections A2 and A3

#### A-Edit-4: Conditional review gates in plan-product Stages 1-3

- **Location**: `plan-product/SKILL.md`:
  - Stage 1 steps 3-4 (lines ~220-221): Replace Lead-as-Skeptic with conditional
    `--full` gate
  - Stage 2 steps 3-4 (lines ~232-233): Same conditional pattern,
    product-skeptic reviews idea viability
  - Stage 3 steps 3-4 (lines ~244-245): Same conditional pattern,
    product-skeptic reviews dependency accuracy
- **Action**: REPLACE each Lead-as-Skeptic step with a conditional block (if
  `--full` → product-skeptic gate, else → Lead-as-Skeptic as before)
- **Content**: Verbatim from spec section A3 (Stage 1 example, apply same
  pattern to Stages 2 and 3 with domain-specific review criteria)

#### A-Edit-5: Product Skeptic spawn definition update in plan-product

- **Location**: `plan-product/SKILL.md`, lines 202-207 (Product Skeptic spawn
  entry)
- **Action**: REPLACE the Tasks and Stage fields
- **Before**: `Tasks: Review stories (Stage 4) and spec (Stage 5)...` /
  `Stage: 4, 5`
- **After**: Include `--full` conditional stages and
  `Stage: 1-5 (with --full) or 4-5 (default)`
- **Content**: Verbatim from spec section A3

#### A-Edit-6: Product Skeptic spawn prompt update in plan-product

- **Location**: `plan-product/SKILL.md`, Product Skeptic spawn prompt (lines
  ~764-812, the code block)
- **Action**: ADD review domains for Stages 1-3 (research, ideation, roadmap)
  with note that they are only active when `--full` is passed
- **Placement**: OUTSIDE the code block (add a note above the code block), and
  inside the code block add review domain descriptions after the existing Stage
  4/5 review descriptions
- **CRITICAL**: SCAFFOLD comments must NOT go inside the spawn prompt code block

#### A-Edit-7: Flag Parsing subsection in build-product Determine Mode

- **Location**: `build-product/SKILL.md`, after line 95 (the "review" bullet),
  before "### Artifact Detection" at line 97
- **Action**: INSERT new `### Flag Parsing` and `### Complexity Classification`
  subsections
- **Content**: Same structure as plan-product but WITHOUT `--full` flag (not
  applicable to build-product). Include `--complexity`, `--max-iterations`,
  `--checkpoint-frequency`, `--light`.

#### A-Edit-8: Complexity Routing in build-product Orchestration Flow

- **Location**: `build-product/SKILL.md`, lines 214-217 (Orchestration Flow
  preamble)
- **Action**: REPLACE with expanded version including `### Complexity Routing`
  for 3-stage pipeline
- **Content**: Verbatim from spec section A4 (Simple/Standard/Complex routing
  for build-product)

#### A-Edit-9: Artifact Detection report format in build-product

- **Location**: `build-product/SKILL.md`, lines 130-145 (the report format
  block)
- **Action**: REPLACE to include `Complexity:` line
- **Content**: Same format as plan-product, adapted for build-product's artifact
  types

#### A-Edit-10: Update build-product Lightweight Mode to reference Flag Parsing

- **Location**: `build-product/SKILL.md`, lines 147-157 (Lightweight Mode
  section)
- **Action**: MODIFY the opening line to reference the Flag Parsing subsection:
  `--light` is now part of the unified flag parse block. The behavior
  description stays the same.
- **Similarly for plan-product** lines 130-138: same update.

**Intra-group dependencies**: A-Edit-1 must precede A-Edit-3 (Flag Parsing
before Orchestration references it). A-Edit-5 must precede A-Edit-6 (spawn
definition before spawn prompt). All other edits within Group A are independent.

---

### Group B: Configurable Skeptic Iteration Limits (P3-26)

**Files: All 14 multi-agent SKILL.md files + wizard-guide/SKILL.md**

#### B-Edit-1: Flag Parsing in pipeline skills (plan-product, build-product)

- **Location**: Already added by Group A. In Group B, verify that
  `--max-iterations N` is present in the Flag Parsing subsection. If Group A
  used TODO markers, replace them with the full parsing rules from spec B1.
- **Action**: VERIFY or UPDATE the existing Flag Parsing subsection

#### B-Edit-2: Flag Parsing in 12 granular/business skills

For each of the 12 remaining multi-agent skills, insert a `### Flag Parsing`
subsection at the TOP of `## Determine Mode`, before the mode resolution
bullets.

| Skill                 | Determine Mode line | Insert after                                                                 |
| --------------------- | ------------------- | ---------------------------------------------------------------------------- |
| build-implementation  | 115                 | After `## Determine Mode` heading, before `Based on $ARGUMENTS:` at line 117 |
| plan-implementation   | 78                  | After heading, before `Based on $ARGUMENTS:`                                 |
| write-spec            | 82                  | After heading, before `Based on $ARGUMENTS:`                                 |
| write-stories         | 72                  | After heading, before `Based on $ARGUMENTS:`                                 |
| research-market       | 72                  | After heading, before `Based on $ARGUMENTS:`                                 |
| ideate-product        | 74                  | After heading, before `Based on $ARGUMENTS:`                                 |
| manage-roadmap        | 72                  | After heading, before `Based on $ARGUMENTS:`                                 |
| review-quality        | 74                  | After heading, before `Based on $ARGUMENTS:`                                 |
| run-task              | 69                  | After heading, before `Based on $ARGUMENTS:`                                 |
| draft-investor-update | 77                  | After heading, before `Based on $ARGUMENTS:`                                 |
| plan-sales            | 86                  | After heading, before `Based on $ARGUMENTS:`                                 |
| plan-hiring           | 93                  | After heading, before `Based on $ARGUMENTS:`                                 |

- **Content for each**: The 2-flag parse block from spec B1:

  ```markdown
  ### Flag Parsing

  Parse the following flags from `$ARGUMENTS` before mode resolution. Strip
  recognized flags; the remaining value is the mode argument.

  - **`--max-iterations N`**: Set the skeptic rejection ceiling for this
    session. Default: 3. If N ≤ 0 or non-integer, log warning ("Invalid
    --max-iterations value; using default of 3") and fall back to 3. If
    `--max-iterations` appears with no following value, log warning and fall
    back to 3. If N is a float (e.g., 3.5), floor to integer.
  - **`--checkpoint-frequency [every-step|milestones-only|final-only]`**:
    Checkpoint cadence (default: every-step). If invalid value, log warning and
    fall back to every-step.
  ```

- **Note**: `--checkpoint-frequency` is included here so Group D doesn't need to
  re-edit the parse block. The checkpoint behavior modification happens in Group
  D.

#### B-Edit-3: Update deadlock rules in 11 skills that already have them

Replace every hard-coded "3" in skeptic deadlock rules with the configurable N
pattern.

| Skill                          | Failure Recovery line | Current text pattern                   | Roles affected                      |
| ------------------------------ | --------------------- | -------------------------------------- | ----------------------------------- |
| plan-product                   | ~306                  | `rejects the same deliverable 3 times` | product-skeptic                     |
| build-product                  | ~312                  | `rejects the same deliverable 3 times` | quality-skeptic, plan-skeptic       |
| build-product                  | ~313                  | `rejects the same tests 3 times`       | qa-agent                            |
| build-product Orch Flow        | ~263                  | `Max 3 rejection cycles`               | qa-agent                            |
| build-implementation           | ~202                  | `rejects the same deliverable 3 times` | quality-skeptic                     |
| build-implementation           | ~203                  | `rejects the same tests 3 times`       | qa-agent                            |
| build-implementation Orch Flow | ~182                  | `Max 3 rejection cycles`               | qa-agent                            |
| plan-implementation            | ~142                  | `rejects the same deliverable 3 times` | plan-skeptic                        |
| write-spec                     | ~144+                 | `rejects the same deliverable 3 times` | spec-skeptic                        |
| write-stories                  | ~127+                 | `rejects the same deliverable 3 times` | story-skeptic                       |
| review-quality                 | ~147+                 | `rejects the same deliverable 3 times` | ops-skeptic                         |
| run-task                       | ~133+                 | `rejects the same deliverable 3 times` | task-skeptic                        |
| draft-investor-update          | ~182+                 | `rejects the same deliverable 3 times` | narrative-skeptic, accuracy-skeptic |
| plan-sales                     | ~300+                 | `rejects the same deliverable 3 times` | strategy-skeptic, bias-skeptic      |
| plan-hiring                    | ~442+                 | `rejects the same deliverable 3 times` | fit-skeptic                         |

- **Before**: `rejects the same deliverable 3 times`
- **After**:
  `rejects the same deliverable N times (default 3, set via \`--max-iterations\`)`
- **Same pattern for QA deadlock rules**: `rejects the same tests 3 times` →
  `rejects the same tests N times (default 3, set via \`--max-iterations\`)`
- **Same for inline `Max 3 rejection cycles`**: →
  `Max N rejection cycles (default 3, set via \`--max-iterations\`)`

#### B-Edit-4: ADD Skeptic deadlock rule to 3 skills that lack it

research-market, ideate-product, and manage-roadmap currently have no Skeptic
deadlock rule in their Failure Recovery sections. These skills use
Lead-as-Skeptic, but the spec requires all 14 skills to have the configurable
deadlock rule.

For each of these 3 skills, ADD a new bullet to Failure Recovery:

```markdown
- **Skeptic deadlock**: If the {skeptic-name} rejects the same deliverable N
  times (default 3, set via `--max-iterations`), STOP iterating. The Team Lead
  escalates to the human operator with a summary of the submissions, the
  Skeptic's objections across all rounds, and the team's attempts to address
  them. The human decides: override the Skeptic, provide guidance, or abort.
```

Skeptic names: research-market → `research-skeptic`, ideate-product →
`product-skeptic`, manage-roadmap → `product-skeptic`.

**Note**: These skills use Lead-as-Skeptic, not a dedicated skeptic agent. The
deadlock rule applies to the Lead's own review iteration loop. The rule text
should reference the Lead-as-Skeptic pattern: "If the Team Lead (acting as
skeptic) rejects the same deliverable N times..."

#### B-Edit-5: Common Flags section in wizard-guide

- **Location**: `wizard-guide/SKILL.md`, insert before `## The Conclave` at line
  40
- **Action**: INSERT new `## Common Flags` section
- **Content**: Verbatim from spec section B3 — two tables (multi-agent flags +
  pipeline-only flags) with examples

**Intra-group dependencies**: B-Edit-1 depends on Group A being complete.
B-Edit-2 through B-Edit-5 are independent of each other and can be done in any
order.

**Batching strategy**: The 12 granular/business skill edits (B-Edit-2) are
repetitive. Process them alphabetically. Each skill gets two edits: (1) Flag
Parsing insertion, (2) deadlock rule update/addition. Both edits per skill
should be done together before moving to the next skill.

---

### Group D: Checkpoint Frequency + SCAFFOLD Comments (P3-30 + P3-31)

**Files: All 14 multi-agent SKILL.md files + CLAUDE.md**

#### D-Edit-1: SCAFFOLD Comments convention in CLAUDE.md

- **Location**: `CLAUDE.md`, after line 158 (the "Skeptic role is
  non-negotiable" bullet in Development Guidelines)
- **Action**: INSERT new `### SCAFFOLD Comments` subsection
- **Content**: Verbatim from spec section D3 — format definition, examples,
  placement rules

#### D-Edit-2: Update "When to Checkpoint" section in all 14 multi-agent skills

For each of the 14 multi-agent skills, replace the "When to Checkpoint" section
with the conditional format.

| Skill                 | "When to Checkpoint" line |
| --------------------- | ------------------------- |
| plan-product          | 71                        |
| build-product         | 78                        |
| build-implementation  | 104                       |
| plan-implementation   | ~68                       |
| write-spec            | ~62                       |
| write-stories         | ~55                       |
| research-market       | ~55                       |
| ideate-product        | ~57                       |
| manage-roadmap        | ~55                       |
| review-quality        | ~57                       |
| run-task              | ~52                       |
| draft-investor-update | ~60                       |
| plan-sales            | ~68                       |
| plan-hiring           | ~75                       |

- **Before** (same across all 14 skills):

  ```markdown
  ### When to Checkpoint

  Agents write a checkpoint after:

  - Claiming a task (phase: current phase, status: in_progress)
  - Completing a deliverable (status: awaiting_review)
  - Receiving review feedback (status: in_progress, note the feedback)
  - Being blocked (status: blocked, note what's needed)
  - Completing their work (status: complete)
  ```

- **After** (verbatim from spec section D2):

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

  When using `milestones-only` or `final-only`, session recovery resolution may
  be coarser than usual. The Team Lead notes this in recovery messages.
  ```

#### D-Edit-3: SCAFFOLD comments — Skeptic iteration caps (all 14 skills)

- **Location**: In each skill's Failure Recovery section, directly ABOVE the
  Skeptic deadlock rule
- **Action**: INSERT one SCAFFOLD comment
- **Content**:
  ```html
  <!-- SCAFFOLD: Max N skeptic rejections before escalation | ASSUMPTION: models below Opus require a hard cap to prevent infinite skeptic loops | TEST REMOVAL: when pipeline consistently converges in ≤2 rejections across 10+ sessions -->
  ```
- **Placement**: Above the `- **Skeptic deadlock**:` bullet, NOT inside any code
  block

#### D-Edit-4: SCAFFOLD comments — Checkpoint default (all 14 skills)

- **Location**: In each skill's "When to Checkpoint" section, directly above the
  section heading
- **Action**: INSERT one SCAFFOLD comment
- **Content**:
  ```html
  <!-- SCAFFOLD: Checkpoint after every significant state change | ASSUMPTION: agent context degrades on long runs; frequent checkpoints enable recovery | TEST REMOVAL: on Opus-class models, test milestones-only and measure recovery accuracy -->
  ```

#### D-Edit-5: SCAFFOLD comments — Opus model for skeptic/QA agents (all 14 skills)

- **Location**: In each skill's spawn definitions, directly above the skeptic/QA
  agent spawn entry (the `### {Skeptic Name}` heading)
- **Action**: INSERT one SCAFFOLD comment per skeptic/QA agent spawn definition
- **Content**:
  ```html
  <!-- SCAFFOLD: {Skeptic/QA} always uses Opus model | ASSUMPTION: Sonnet-class models produce more false approvals at quality gates | TEST REMOVAL: A/B comparison — Opus vs. Sonnet skeptic on 5 identical pipelines; measure rejection accuracy -->
  ```
- **Skill-specific skeptic names**: product-skeptic (plan-product,
  ideate-product, manage-roadmap), quality-skeptic (build-product,
  build-implementation, review-quality), plan-skeptic (plan-implementation,
  build-product), qa-agent (build-product, build-implementation),
  research-skeptic (research-market), story-skeptic (write-stories),
  spec-skeptic (write-spec), ops-skeptic (review-quality), task-skeptic
  (run-task), narrative-skeptic + accuracy-skeptic (draft-investor-update),
  strategy-skeptic + bias-skeptic (plan-sales), fit-skeptic (plan-hiring)
- **CRITICAL**: Place above the `###` heading, NEVER inside spawn prompt code
  blocks

#### D-Edit-6: SCAFFOLD comment — Lead-as-Skeptic pattern (plan-product only)

- **Location**: `plan-product/SKILL.md`, above the Stage 1 Lead-as-Skeptic
  conditional block (from Group A edit A-Edit-4)
- **Action**: INSERT one SCAFFOLD comment
- **Content**:
  ```html
  <!-- SCAFFOLD: Lead performs inline skeptic review instead of spawning dedicated skeptic | ASSUMPTION: Sonnet-class model sufficient for early-stage research review; dedicated Opus skeptic adds cost without quality gain for research/ideation | TEST REMOVAL: benchmark --full vs. default quality on the same pipeline topic -->
  ```

**Intra-group dependencies**: D-Edit-1 (CLAUDE.md convention) should be done
first as reference. D-Edit-2 through D-Edit-6 are independent and can be
batched. Process all edits per file together (checkpoint + SCAFFOLD comments in
one pass per file).

**Batching strategy**: Process the 14 skills in the same alphabetical order as
Group B. For each skill, apply D-Edit-2 (checkpoint), D-Edit-3 (iteration cap
SCAFFOLD), D-Edit-4 (checkpoint SCAFFOLD), and D-Edit-5 (Opus model SCAFFOLD) in
a single editing pass.

---

### Group C: Evaluator Tuning Mechanism (P3-29)

**Files: build-implementation/SKILL.md, plan-implementation/SKILL.md,
plan-product/SKILL.md, build-product/SKILL.md**

#### C-Edit-1: Eval examples Setup step in build-implementation

- **Location**: `build-implementation/SKILL.md`, after Setup step 11 (guidance
  reading, line ~43)
- **Action**: INSERT new step 12
- **Content**: Verbatim from spec section C1 — defensive reading contract for
  `.claude/conclave/eval-examples/`, format as
  `## Evaluator Examples (user-provided)` block for injection

#### C-Edit-2: Eval examples Setup step in plan-implementation

- **Location**: `plan-implementation/SKILL.md`, analogous location after the
  guidance reading step (if it exists) or after the last Setup step
- **Action**: INSERT new setup step
- **Content**: Same pattern as C-Edit-1, adapted for plan-implementation's
  plan-skeptic

#### C-Edit-3: Post-mortem step in build-implementation Pipeline Completion

- **Location**: `build-implementation/SKILL.md`, Orchestration Flow step 9 (cost
  summary, line ~186)
- **Action**: INSERT new step 10 after step 9
- **Content**: Verbatim from spec section C2 — post-mortem rating prompt with
  frontmatter fields

#### C-Edit-4: Post-mortem step in plan-product Pipeline Completion

- **Location**: `plan-product/SKILL.md`, Pipeline Completion section (lines
  ~284-286), after end-of-session summary
- **Action**: INSERT new step after the summary step, before cost summary
- **Content**: Same post-mortem pattern, adapted for plan-product (team:
  "plan-product")

#### C-Edit-5: Post-mortem step in build-product Pipeline Completion

- **Location**: `build-product/SKILL.md`, Pipeline Completion section (lines
  ~294-296), after end-of-session summary
- **Action**: INSERT new step after the summary step
- **Content**: Same post-mortem pattern, adapted for build-product

#### C-Edit-6: Calibration instruction in build-implementation Quality Skeptic spawn prompt

- **Location**: `build-implementation/SKILL.md`, Quality Skeptic spawn prompt
  code block
- **Action**: ADD `### Evaluator Calibration` section INSIDE the spawn prompt
  code block (this is intentional — the calibration instruction IS part of the
  agent's prompt)
- **Content**: Verbatim from spec section C3

#### C-Edit-7: Calibration instruction in plan-product product-skeptic spawn prompt

- **Location**: `plan-product/SKILL.md`, product-skeptic spawn prompt code block
- **Action**: ADD `### Evaluator Calibration` section inside the spawn prompt
- **Content**: Same calibration instruction, adapted for product-skeptic

#### C-Edit-8: Calibration instruction in build-product quality-skeptic spawn prompt

- **Location**: `build-product/SKILL.md`, Quality Skeptic spawn prompt code
  block
- **Action**: ADD calibration instruction inside the spawn prompt
- **Content**: Same pattern

#### C-Edit-9: Calibration instruction in plan-implementation plan-skeptic spawn prompt

- **Location**: `plan-implementation/SKILL.md`, plan-skeptic spawn prompt code
  block
- **Action**: ADD calibration instruction inside the spawn prompt
- **Content**: Same pattern

#### C-Edit-10: Eval examples injection in plan-product (--full mode)

- **Location**: `plan-product/SKILL.md`, Setup section or Spawn the Team section
- **Action**: ADD conditional eval examples injection for product-skeptic when
  `--full` is active
- **Content**: Note in the Setup or Spawn section that when eval examples are
  found AND `--full` is active, inject them into product-skeptic's spawn prompt
  using the same format as build-implementation

**Intra-group dependencies**: C-Edit-1 and C-Edit-2 (setup steps) should be done
before C-Edit-6/C-Edit-9 (spawn prompt calibration instructions) since the setup
step determines what gets injected. C-Edit-3/C-Edit-4/C-Edit-5 (post-mortem) are
independent.

---

## Dependency Order

```
Group A (plan-product + build-product)
  │
  ▼
Group B (14 skills + wizard-guide)
  │  ├── B-Edit-1: Verify/update pipeline skill Flag Parsing (depends on Group A)
  │  ├── B-Edit-2: Add Flag Parsing to 12 granular/business skills (independent)
  │  ├── B-Edit-3: Update deadlock rules in 11 skills (independent)
  │  ├── B-Edit-4: Add deadlock rules to 3 skills (independent)
  │  └── B-Edit-5: wizard-guide Common Flags (independent)
  │
  ▼
Group D (14 skills + CLAUDE.md)
  │  ├── D-Edit-1: SCAFFOLD convention in CLAUDE.md (do first as reference)
  │  ├── D-Edit-2: Update "When to Checkpoint" in 14 skills (independent)
  │  └── D-Edit-3/4/5/6: SCAFFOLD comments in 14 skills (independent)
  │
  ▼
Group C (4 skills)
  │  ├── C-Edit-1/2: Eval examples setup steps (do first)
  │  ├── C-Edit-3/4/5: Post-mortem steps (independent)
  │  └── C-Edit-6/7/8/9/10: Calibration instructions (after setup steps)
```

## Test Strategy

| Test Type | Scope              | Description                                                                                                                                                                                                                  |
| --------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| validator | all skills         | `bash scripts/validate.sh` after each group — must pass 12/12. A-series checks are most sensitive to SKILL.md structural changes (frontmatter, required sections, spawn definitions, shared content markers).                |
| validator | per-file           | After editing each SKILL.md, verify A-series passes for that specific file. Key risks: (1) Flag Parsing `###` heading could interfere with A2 section detection, (2) SCAFFOLD comments must not contain `##`-prefixed lines. |
| manual    | Flag Parsing       | After Group A: read plan-product Determine Mode end-to-end and verify flag parsing, complexity classification, and mode resolution are coherent. Verify `--light` existing behavior is preserved.                            |
| manual    | Deadlock rules     | After Group B: grep all 14 SKILL.md files for "3 times" — should find ZERO matches in Failure Recovery sections (all replaced with "N times").                                                                               |
| manual    | SCAFFOLD placement | After Group D: grep for `SCAFFOLD` inside code blocks (between triple-backtick markers). Should find ZERO matches. All SCAFFOLD comments must be outside code blocks.                                                        |
| manual    | Shared content     | After all groups: run `bash scripts/sync-shared-content.sh` and verify no drift. Our changes are outside shared content markers, so sync should produce no diffs.                                                            |
| manual    | Regression         | After all groups: verify that invoking a skill with NO flags produces identical behavior to before (all defaults match current behavior).                                                                                    |

### Verification Commands

````bash
# After each group:
bash scripts/validate.sh

# After Group B — verify no hard-coded "3 times" remain in deadlock rules:
grep -r "rejects the same deliverable 3 times" plugins/conclave/skills/
grep -r "rejects the same tests 3 times" plugins/conclave/skills/
grep -r "Max 3 rejection cycles" plugins/conclave/skills/
# Expected: zero matches

# After Group D — verify no SCAFFOLD inside code blocks:
# (Manual check: search for SCAFFOLD and verify each is outside ``` markers)

# After all groups — verify shared content is clean:
bash scripts/sync-shared-content.sh
git diff  # should show no changes to shared content markers
````

## Risk Assessment

1. **A-series validator sensitivity**: Adding `### Flag Parsing` as a new H3
   heading inside `## Determine Mode` could trigger A2 section detection issues
   if the validator counts or enumerates required sections. **Mitigation**: The
   A2 validator checks for specific required sections (Setup, Determine Mode,
   Spawn the Team, etc.) — subsection headings within those sections should not
   interfere. Verify after first file edit.

2. **SCAFFOLD comments with `##` content**: If a SCAFFOLD comment accidentally
   contains `##`-prefixed text, A-series section detection could produce false
   positives. **Mitigation**: All SCAFFOLD comment content uses `|`-separated
   fields, never `##` prefixes. The spec explicitly prohibits this.

3. **Shared content drift**: Our edits are in skill-specific sections (Determine
   Mode, Failure Recovery, Orchestration Flow, spawn prompts) — all outside the
   `<!-- BEGIN SHARED: ... -->` markers. **Mitigation**: Run the shared content
   sync script after all changes and verify zero drift.

4. **14-file batch edits**: Groups B and D each touch all 14 multi-agent skills.
   A mistake in the edit template could propagate across all files.
   **Mitigation**: Edit one representative file first (build-implementation),
   run validators, then batch the remaining 13.
