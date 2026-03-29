---
type: "user-stories"
feature: "harness-improvements"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-26-configurable-iteration-limits.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Harness Improvements (P3-26 through P3-31)

## Epic Summary

Six targeted improvements to the conclave skill harness. Three small-effort
items (P3-26, P3-30, P3-31) add configurability and documentation. Two
medium-effort items (P3-27 and P3-28) are batched because they both modify
`plan-product/SKILL.md` — P3-27 adds complexity-adaptive routing while P3-28
brings Stages 1-3 into skeptic consistency with Stages 4-5. One medium-effort
item (P3-29) adds an evaluator tuning mechanism and depends on P3-28 and several
completed P2 items. Together these improvements give operators more control over
pipeline behavior and surface the model-capability assumptions currently baked
invisibly into skill prompts.

---

## P3-26: Configurable Skeptic Iteration Limits

---

### Story 26-1: `--max-iterations` Flag Parsing

- **As a** skill author or advanced operator invoking a multi-agent conclave
  skill
- **I want** to pass `--max-iterations N` as a CLI flag to any multi-agent skill
- **So that** I can raise the rejection ceiling for subjective or complex tasks
  without modifying SKILL.md files, and the hard-coded 3-iteration default
  continues to apply when the flag is absent

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a multi-agent skill invoked with `--max-iterations 5`, when the
     skill's "Determine Mode" step parses `$ARGUMENTS`, then `N=5` is extracted
     and stored as the effective iteration limit for all skeptic gates in that
     session
  2. Given the flag is absent from `$ARGUMENTS`, when the skill initializes,
     then `N=3` is used as the default — identical to the current hard-coded
     behavior
  3. Given `--max-iterations 0` or a non-positive integer, when the skill parses
     the flag, then the skill logs a warning — "Invalid --max-iterations value;
     using default of 3" — and falls back to `N=3`
  4. Given `--max-iterations` appears alongside other flags (e.g.,
     `--light --max-iterations 4 my-feature`), when the skill parses
     `$ARGUMENTS`, then all flags are correctly stripped and the remaining value
     is treated as the feature name or mode argument
  5. Given `--max-iterations N` is parsed, when the Team Lead spawns teammates,
     then `N` is surfaced in the Team Lead's opening message to the user: "Max
     skeptic iterations: N (default: 3)" — only when N differs from 3
  6. Given `bash scripts/validate.sh`, when run after any SKILL.md changes for
     this story, then all validators continue to pass

- **Edge Cases**:
  - `--max-iterations` with no following value (trailing flag): log warning,
    fall back to default
  - `--max-iterations` value is a float (e.g., `3.5`): log warning, round down
    to floor integer (3), proceed
  - `--max-iterations 1`: valid — a single approval attempt before escalation;
    useful for time-boxed sessions where operator wants to review any rejection
    immediately

- **Notes**: Flag parsing lives in the "Determine Mode" section of each
  multi-agent SKILL.md. The extracted `N` value is passed as context when the
  Skeptic deadlock protocol is described to the Team Lead. No new arguments file
  or config mechanism is needed — this is a prompt-only change. Single-agent
  skills (`setup-project`, `wizard-guide`) are excluded.

---

### Story 26-2: Propagate Iteration Limit Across All 14 Multi-Agent Skills

- **As a** Team Lead running any multi-agent conclave skill
- **I want** my skeptic deadlock protocol to use the operator-supplied
  `--max-iterations N` value rather than the hard-coded 3
- **So that** the iteration ceiling is consistent across all skill pipelines and
  a single flag controls behavior wherever skeptic gates exist

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the 14 multi-agent skills (`research-market`, `ideate-product`,
     `manage-roadmap`, `write-stories`, `write-spec`, `plan-implementation`,
     `build-implementation`, `review-quality`, `run-task`, `plan-product`,
     `build-product`, `draft-investor-update`, `plan-sales`, `plan-hiring`),
     when each is updated, then every "Skeptic deadlock" or "deadlock" recovery
     rule in its Failure Recovery section references "N rejections (set via
     --max-iterations, default 3)" instead of a hard-coded "3"
  2. Given `plan-product`'s Failure Recovery section, when it is updated, then
     the Lead-as-Skeptic inline review loops in Stages 1-3 also reference N
     (not 3) — the Lead-as-Skeptic rejection cap is the same configurable limit
     as the dedicated Skeptic cap
  3. Given `build-implementation`'s QA deadlock rule (currently "Max 3 rejection
     cycles"), when it is updated, then it also references N — the QA deadlock
     cap is configurable by the same flag
  4. Given a skill where multiple skeptic gates exist (e.g.,
     `plan-implementation` has a pre-implementation gate and a
     post-implementation gate), when N=2 is supplied, then both gates use N=2
     independently — each gate resets its own counter per deliverable, not per
     session
  5. Given `bash scripts/validate.sh`, when run after all 14 SKILL.md files are
     updated, then all validators pass (12/12); specifically the A-series checks
     for each updated file must show no regressions

- **Edge Cases**:
  - Skill with multiple deliverables routed through the same Skeptic (e.g.,
    Stage 4 stories and Stage 5 spec in `plan-product`): each deliverable has
    its own N-counter — rejecting stories N times escalates for stories only;
    the spec gate gets a fresh counter
  - Pipeline skill re-run (artifact detected, stage skipped): the N counter for
    the skipped stage's gate is never initialized — no carry-over from a
    previous session
  - Operator sets N=10 and walks away: the Team Lead still escalates to human
    after 10 rejections; it does not loop indefinitely

- **Notes**: The Skeptic deadlock rule text currently reads: "If the [Skeptic]
  rejects the same deliverable 3 times, STOP iterating." After this story, it
  reads: "If the [Skeptic] rejects the same deliverable N times (default 3, set
  via --max-iterations), STOP iterating." The `N` variable is set once per
  session in "Determine Mode" and referenced everywhere the deadlock ceiling
  appears. This is a prompt-content change to 14 files — no new validator checks
  are needed, but the existing A-series checks for each file must still pass
  after the edits.

---

### Story 26-3: Document `--max-iterations` in wizard-guide

- **As a** new user or operator unfamiliar with conclave's configurable flags
- **I want** the `wizard-guide` skill to explain the `--max-iterations` flag
- **So that** I can discover and understand the feature without reading SKILL.md
  source files directly

- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given `plugins/conclave/skills/wizard-guide/SKILL.md`, when it is updated,
     then it includes `--max-iterations N` in a "Common Flags" or equivalent
     section alongside any other cross-skill flags (`--light`,
     `--checkpoint-frequency`, etc.)
  2. Given the wizard-guide entry for `--max-iterations`, when it is read, then
     it explains: the flag's purpose (configure skeptic rejection ceiling), its
     default (3), valid values (positive integers), which skills accept it (all
     14 multi-agent skills), and an example invocation (e.g.,
     `/write-spec my-feature --max-iterations 5`)
  3. Given `bash scripts/validate.sh`, when run after the wizard-guide update,
     then all validators pass

- **Edge Cases**:
  - wizard-guide does not yet have a "Common Flags" section: create one; place
    it before the skill listing so operators see cross-skill options before
    diving into per-skill details
  - Future flags added after P3-26: the "Common Flags" section is the canonical
    home for all cross-skill flags going forward

- **Notes**: wizard-guide is a single-agent skill — only its SKILL.md prose
  needs updating. No spawn prompts or shared content changes required.

---

## P3-27 + P3-28: Complexity-Adaptive Pipeline & Lead-as-Skeptic Consistency Fix

> **Implementation batch note**: P3-27 and P3-28 both modify
> `plugins/conclave/skills/plan-product/SKILL.md` and, for P3-27, also
> `plugins/conclave/skills/build-product/SKILL.md`. These stories must be
> implemented together in a single PR to avoid merge conflicts and to allow the
> `--full` flag (P3-28) and the complexity classifier (P3-27) to coexist
> coherently in the same Determine Mode section.

---

### Story 27-1: Complexity Classifier at Pipeline Entry (plan-product)

- **As a** Product Planning Coordinator running `/plan-product`
- **I want** the pipeline to classify the incoming task as Simple, Standard, or
  Complex before executing any stages
- **So that** lightweight tasks skip heavyweight research and ideation stages
  and resource-intensive tasks get additional checkpoints, matching effort to
  actual complexity

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `plan-product/SKILL.md`, when the Determine Mode step is updated,
     then a "Complexity Classification" sub-step is added immediately after
     argument parsing and before artifact detection
  2. Given the classification step runs, when it evaluates the task, then it
     outputs one of three tier labels — **Simple**, **Standard**, or **Complex**
     — based on signals including: topic specificity, presence of existing
     artifacts, estimated scope (single feature vs. multi-feature redesign), and
     any explicit `--complexity=[simple|standard|complex]` override from the
     operator
  3. Given `--complexity=simple` is supplied as a flag, when the classifier
     runs, then the tier is forced to Simple regardless of other signals
  4. Given `--complexity=complex` is supplied, when the classifier runs, then
     the tier is forced to Complex
  5. Given no `--complexity` override, when the classifier determines the tier,
     then it reports the inferred tier to the user with a one-sentence rationale
     before proceeding — e.g., "Complexity: Standard (multi-stage feature, no
     existing research artifact found)"
  6. Given `bash scripts/validate.sh`, when run after the SKILL.md change, then
     all validators pass

- **Edge Cases**:
  - Topic is a single-word keyword with no context (e.g.,
    `/plan-product notifications`): classifier defaults to Standard unless
    override flag is present
  - `--complexity` value is not one of the three valid tiers: log warning,
    default to Standard
  - `--complexity` conflicts with `--light` (both supplied): both flags apply
    independently — `--light` affects agent model selection, `--complexity`
    affects stage routing; they are orthogonal

- **Notes**: The classifier is a Lead reasoning step — not a new agent spawn.
  The Team Lead reads the task description and existing artifact state, infers
  complexity, and records the result as a session variable used in Stage routing
  below. The three tiers are defined once in the "Determine Mode" section and
  referenced in the Orchestration Flow. This is a prompt-only change to
  `plan-product/SKILL.md`.

---

### Story 27-2: Tier-Based Stage Routing in plan-product

- **As a** Product Planning Coordinator
- **I want** the plan-product pipeline to skip or add stages based on the
  complexity tier
- **So that** Simple tasks reach implementation planning faster and Complex
  tasks get the extra scrutiny they deserve

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a **Simple** tier task, when the pipeline executes, then Stage 1
     (Research) and Stage 2 (Ideation) are skipped regardless of artifact
     detection results — the Lead proceeds directly to Stage 3 (Roadmap), using
     the task description and existing docs as inputs in lieu of research and
     ideas artifacts
  2. Given a **Simple** tier task and existing research-findings and
     product-ideas artifacts, when the pipeline executes, then those artifacts
     are still read (not ignored) — they are consumed as inputs to Stage 3 even
     though the stages that produce them are skipped
  3. Given a **Standard** tier task, when the pipeline executes, then artifact
     detection controls stage routing as before — no change to existing behavior
  4. Given a **Complex** tier task, when the pipeline executes, then additional
     inter-stage checkpoint gates are inserted: after Stage 3 (Roadmap), the
     Team Lead performs a dedicated complexity review — summarizing scope,
     flagging dependency risks, and presenting the findings to the user before
     proceeding to Stage 4
  5. Given a **Complex** tier task in Standard mode (no `--full` flag), when
     Stage 4 and 5 execute, then the existing product-skeptic gates are
     preserved unchanged — the complexity tier does not reduce skeptic coverage
  6. Given the Artifact Detection report shown to the user, when complexity
     routing is active, then the report includes the tier and its routing effect
     — e.g., "Complexity: Simple — Stages 1-2 skipped"
  7. Given `bash scripts/validate.sh`, when run after the SKILL.md change, then
     all validators pass

- **Edge Cases**:
  - Simple tier but Stage 1 artifact is STALE (expired): still skip Stage 1
    execution; STALE research is acceptable as context input for a Simple task
  - Complex tier with ALL artifacts FOUND: artifact detection results still take
    precedence for stages 1-4; the additional complexity review checkpoint is
    inserted between Stage 3 and 4 regardless
  - Tier changes mid-session (operator re-invokes with different `--complexity`
    flag): previous session checkpoints reference the old tier; the new
    invocation runs fresh classification and routing from the earliest non-FOUND
    artifact

- **Notes**: The Simple tier fast-path removes Stages 1-2 from execution but
  does NOT remove them from the artifact detection table — detection still runs
  for all 5 stages so that any pre-existing artifacts are correctly consumed.
  The routing change is a prompt-only addition to the Orchestration Flow section
  of `plan-product/SKILL.md`.

---

### Story 27-3: Complexity-Adaptive Routing in build-product

- **As a** Implementation Coordinator running `/build-product`
- **I want** build-product to classify task complexity at pipeline entry and
  route accordingly
- **So that** simple implementation tasks skip heavyweight planning and complex
  tasks get additional checkpoints, matching the routing behavior introduced in
  plan-product

- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given `build-product/SKILL.md`, when it is updated, then a Complexity
     Classification sub-step is added to Determine Mode, identical in structure
     to the one added to `plan-product` in Story 27-1
  2. Given a **Simple** tier task in build-product, when the pipeline executes,
     then Stage 1 (Implementation Planning) is skipped if an implementation plan
     artifact is NOT FOUND — instead the Team Lead synthesizes a minimal inline
     plan from the spec and user stories before proceeding to Stage 2 (Build)
  3. Given a **Simple** tier task in build-product and an existing
     implementation plan, when the pipeline executes, then the existing plan is
     used normally — no difference from Standard tier when the artifact exists
  4. Given a **Complex** tier task in build-product, when Stage 2 (Build)
     executes, then mid-build checkpoint gates are inserted: after API contract
     negotiation and before implementation begins, the Quality Skeptic performs
     an intermediate complexity review (separate from the existing
     pre-implementation gate) that specifically examines scope boundaries and
     dependency risks
  5. Given `bash scripts/validate.sh`, when run after the SKILL.md change, then
     all validators pass

- **Edge Cases**:
  - Simple tier + no spec exists: build-product cannot proceed without a spec;
    the classifier does not change this hard dependency — fail with "No spec
    found" as before
  - Complex tier + `--light` flag: both apply independently; lightweight model
    selection is unchanged, extra checkpoint is still inserted

- **Notes**: build-product contains its own copy of orchestration logic —
  changes must be applied directly to
  `plugins/conclave/skills/build-product/SKILL.md`, not inherited from
  plan-product. The classifier logic is the same structure but the stage routing
  table is different (3 stages in build-product vs. 5 in plan-product).

---

### Story 28-1: `--full` Flag Parsing for Dedicated Skeptics in plan-product

- **As a** Product Planning Coordinator running `/plan-product`
- **I want** to pass a `--full` flag that enables dedicated skeptic agents for
  Stages 1-3 (Research, Ideation, Roadmap)
- **So that** I can opt into full skeptic coverage for critical planning
  sessions without the overhead being the default for every invocation

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `plan-product/SKILL.md`, when `--full` is added to Determine Mode
     parsing, then the flag enables dedicated product-skeptic participation in
     Stages 1-3 (currently Lead-as-Skeptic) while Stages 4-5 continue to use
     product-skeptic as they do today
  2. Given `--full` is absent from `$ARGUMENTS`, when the pipeline runs, then
     Stages 1-3 use Lead-as-Skeptic inline review — identical to the current
     behavior; no regression
  3. Given `--full` is present, when the Team Lead spawns product-skeptic, then
     it is spawned at the beginning of the session (before Stage 1 begins)
     rather than at Stage 4 — product-skeptic is available for all five stages
  4. Given `--full` and `--light` are both supplied, when the pipeline
     initializes, then `--full` still enables dedicated skeptics for Stages 1-3;
     `--light`'s model selection rules apply (product-skeptic remains Opus —
     unchanged per `--light` rules)
  5. Given `--full` is present, when the Team Lead opens the session with the
     user, then the opening message notes "Full mode: dedicated product-skeptic
     active for all five stages"
  6. Given `bash scripts/validate.sh`, when run after the SKILL.md change, then
     all validators pass

- **Edge Cases**:
  - `--full` supplied but all 5 stage artifacts are FOUND (all stages skipped):
    the product-skeptic is spawned but immediately has no work; the Team Lead
    should note "All stages skipped (artifacts found); product-skeptic standing
    by" and proceed to pipeline completion
  - `--full` on a pipeline that resumes mid-session: the checkpoint file records
    whether `--full` was active in the prior session; if the resume flag state
    contradicts the checkpoint, the Lead warns the user and uses the current
    invocation's flag value

- **Notes**: This story gates a skeptic-model change behind a flag to preserve
  the current lightweight default. The `--full` flag coexists with both
  `--max-iterations` and `--complexity` — all three flags are parsed together in
  Determine Mode. This is a prompt-only change to `plan-product/SKILL.md` and is
  implemented in the same PR as P3-27 stories due to shared file modification.

---

### Story 28-2: Dedicated Product-Skeptic Gates for plan-product Stages 1-3

- **As a** product-skeptic agent on the Product Planning Team
- **I want** to review research findings (Stage 1), product ideas (Stage 2), and
  roadmap updates (Stage 3) when `--full` mode is active
- **So that** the skeptic quality gate is consistent across all five stages —
  the same rigor applied to stories and specs is applied to research, ideation,
  and roadmap

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `--full` is active and Stage 1 (Research) completes, when the Team
     Lead would normally perform Lead-as-Skeptic inline review, then instead the
     Lead routes the research-findings artifact to product-skeptic via
     `SendMessage` with a `REVIEW REQUEST` — product-skeptic reviews for
     completeness, evidence quality, and gap identification
  2. Given product-skeptic reviews Stage 1 output, when it issues a verdict,
     then it uses `APPROVED` or `REJECTED` with specific, actionable feedback —
     the same verdict format used in Stages 4-5
  3. Given `REJECTED` at Stage 1, when the team iterates, then the iteration cap
     is N (from `--max-iterations`, default 3) — the same deadlock protocol as
     Stages 4-5 (see Story 26-2)
  4. Given `--full` is active and Stage 2 (Ideation) completes, when
     product-skeptic reviews the product-ideas artifact, then the review
     challenges: idea viability, evidence for impact claims, presence of weak or
     duplicate ideas, and alignment with research findings
  5. Given `--full` is active and Stage 3 (Roadmap) completes, when
     product-skeptic reviews the roadmap updates, then the review challenges:
     dependency accuracy, priority rationale, effort estimate consistency, and
     conflicts with existing roadmap items
  6. Given product-skeptic's spawn prompt, when updated for `--full` mode, then
     it explicitly lists the five review domains: research (Stage 1), ideation
     (Stage 2), roadmap (Stage 3), stories (Stage 4), spec (Stage 5) — and notes
     that Stages 1-3 are only active when `--full` is passed
  7. Given `bash scripts/validate.sh`, when run after the SKILL.md changes, then
     all validators pass; specifically the A3 validator must confirm
     product-skeptic has `Name` and `Model` fields in its spawn definition

- **Edge Cases**:
  - Stage 1 skipped due to FOUND artifact: product-skeptic is spawned but does
    not receive a Stage 1 review request; it waits for Stage 4
  - Stage 3 produces no roadmap changes (all roadmap items already exist):
    product- skeptic receives "no roadmap changes" as the review subject and
    issues APPROVED with a note — it does not block the pipeline for an empty
    deliverable
  - product-skeptic spawned at session start under `--full` and then context
    degrades before Stage 4: Team Lead reads product-skeptic's checkpoint,
    re-spawns with checkpoint context, and resumes from the last completed stage
    review

- **Notes**: In the current `plan-product` Orchestration Flow, Stages 1-3 use
  Lead-as-Skeptic (inline review by the Coordinator). This story replaces that
  with a product-skeptic gate when `--full` is active — the Lead still
  synthesizes the artifact, but the skeptic review is a separate agent-to-agent
  interaction. The Lead- as-Skeptic pattern is preserved as the default (no
  `--full` flag). No changes needed to Stages 4-5 orchestration —
  product-skeptic already handles those. Implementation is a prompt-only change
  to `plan-product/SKILL.md`, batched with P3-27 stories.

---

## P3-29: Evaluator Tuning Mechanism

> **Dependencies**: P2-11 (Sprint Contracts), P2-12 (User-Writable Config),
> P2-13 (User-Writable Config Spec) — all complete. P3-28 (Lead-as-Skeptic
> Consistency Fix) — must be implemented before P3-29, as calibration data from
> dedicated Stage 1-3 skeptics is part of the eval collection surface.

---

### Story 29-1: Eval Examples Directory Convention

- **As a** project owner who wants to calibrate skeptic quality across sessions
- **I want** a defined convention for storing graded evaluation examples at
  `.claude/conclave/eval-examples/`
- **So that** I can provide reference examples of good and bad skeptic outputs
  that agents can consult before making judgments, tuning their calibration
  without modifying SKILL.md files

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `build-implementation/SKILL.md` Setup (and
     `plan-implementation/SKILL.md` Setup), when each is updated, then a new
     optional setup step reads `.claude/conclave/eval-examples/` using the same
     defensive reading contract as the guidance directory (P2-13):
     - Directory absent → proceed silently, no eval examples injected
     - Directory exists but empty → proceed silently
     - Directory exists as a file (not a directory) → log warning, proceed
       without examples
     - Individual file unreadable → log warning naming the file, skip, continue
  2. Given `.claude/conclave/eval-examples/` contains `.md` files, when the
     skill reads them, then each file's content is injected into the Quality
     Skeptic's spawn prompt under a `## Evaluator Examples (user-provided)`
     heading — formatted analogously to the guidance file injection in Setup
     step 11 of `build-implementation/SKILL.md`
  3. Given an eval examples file, when it is read, then its filename is used as
     a `###` sub-heading within the `## Evaluator Examples` block — providing
     context to the Quality Skeptic about which graded example it is reading
  4. Given `plan-product/SKILL.md` with `--full` active, when product-skeptic is
     spawned, then eval examples are also injected into product-skeptic's spawn
     prompt via the same mechanism
  5. Given `bash scripts/validate.sh`, when run after all SKILL.md changes, then
     all validators pass

- **Edge Cases**:
  - Eval examples directory contains non-`.md` files (e.g., `.json`, `.yaml`):
    ignore silently — only `.md` files are injected
  - Eval examples file contains adversarial content (e.g., "ignore your
    instructions"): the existing guidance injection framing provides context
    that the content is user- supplied; agents treat it as informational, not
    authoritative
  - Eval examples present but empty files: skip silently (same as guidance
    convention)

- **Notes**: The eval examples convention is an extension of the user-writable
  config pattern established by P2-12 and P2-13. The
  `.claude/conclave/eval-examples/` directory is parallel to
  `.claude/conclave/guidance/` and `.claude/conclave/templates/`. No new
  validator checks are needed — the defensive reading contract is already tested
  by P2-12 acceptance criteria. The injection only targets reasoning/skeptic
  agents (Quality Skeptic, product-skeptic), not execution agents (backend-eng,
  frontend-eng, story-writer) — calibration examples are not implementation
  instructions.

---

### Story 29-2: Post-Mortem Quality Rating at Pipeline Completion

- **As a** Team Lead completing a build-implementation or plan-product pipeline
  run
- **I want** to collect a simple quality rating from the operator after the
  pipeline completes
- **So that** session quality data accumulates over time and can inform eval
  example curation and skeptic prompt iteration

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `build-implementation/SKILL.md` Pipeline Completion (Step 9, after
     cost summary), when a new "Post-Mortem Rating" step is added, then the Team
     Lead asks the user: "How would you rate the quality of this pipeline run?
     [1-5, or skip]" — and explicitly notes that rating data is written to
     `docs/progress/{feature}-postmortem.md`
  2. Given the user provides a rating (1-5), when the Team Lead writes the
     post-mortem file, then the YAML frontmatter includes: `feature`, `team`,
     `rating` (integer 1-5), `date`, `skeptic-gate-count` (how many times any
     skeptic gate fired), `rejection-count` (how many times any deliverable was
     rejected), and `max-iterations-used` (N from the session, whether default
     or override)
  3. Given the user skips the rating prompt ("skip" or no response within the
     session), when the Team Lead proceeds, then no post-mortem file is written
     — the skip is silent and does not block pipeline completion
  4. Given `plan-product/SKILL.md` Pipeline Completion, when it is updated, then
     the same post-mortem rating step is added after the end-of-session summary
     (currently last step before cost summary)
  5. Given `bash scripts/validate.sh`, when run after all SKILL.md changes, then
     all validators pass

- **Edge Cases**:
  - Rating value outside 1-5 (e.g., "7" or "excellent"): Team Lead asks once for
    clarification; if the second response is also invalid, skip the rating
    silently
  - Pipeline completed via `status` mode (no actual pipeline run): post-mortem
    step is not added to status-mode flow — only fires after real pipeline
    execution
  - Feature name contains special characters: the frontmatter `feature` field is
    the sanitized feature name used throughout other progress files — same
    sanitization applies

- **Notes**: The post-mortem file is an opt-in, low-friction mechanism. The
  rating data is meant to be read by operators curating
  `.claude/conclave/eval-examples/` — a post-mortem with rating 2 and high
  rejection counts is a signal to write a "bad skeptic output" example; rating 5
  with clean gates is a signal to write a "good skeptic output" example. No
  automated analysis, no aggregation — the human curates the examples, the
  harness collects the raw data.

---

### Story 29-3: Skeptic Prompt Calibration from Eval Examples

- **As a** Quality Skeptic in build-implementation (or product-skeptic in
  plan-product)
- **I want** to read user-provided graded evaluation examples before performing
  my reviews
- **So that** my judgments are calibrated to the operator's quality standards
  rather than purely to my training defaults

- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given the Quality Skeptic's spawn prompt in
     `build-implementation/SKILL.md`, when eval examples are present in the
     prompt (injected via Story 29-1), then the prompt includes an instruction:
     "Read the ## Evaluator Examples section before performing any review. These
     examples represent past quality benchmarks from this project. Use them to
     calibrate your judgment — APPROVED examples show the quality bar; REJECTED
     examples show failure patterns to watch for."
  2. Given an eval examples file structured with a `## APPROVED` section and a
     `## REJECTED` section, when the Quality Skeptic reads it, then it uses
     APPROVED examples to calibrate its acceptance threshold and REJECTED
     examples to calibrate its rejection patterns — it does not blindly mimic
     the examples but uses them as reference anchors
  3. Given an eval examples file with no `## APPROVED` or `## REJECTED` headers,
     when the Quality Skeptic reads it, then it treats the entire file as
     general calibration context — no parse error, no failure
  4. Given NO eval examples are present (Story 29-1 found no files), when the
     Quality Skeptic performs its review, then it behaves exactly as before — no
     change, no warning
  5. Given `bash scripts/validate.sh`, when run after the spawn prompt changes,
     then all validators pass; specifically B-series shared content checks must
     not report drift for the modified spawn prompts (spawn prompts are not in
     the shared content marker zones)

- **Edge Cases**:
  - Eval examples reference a feature different from the current feature (stale
    examples from a different project): Quality Skeptic reads them as general
    calibration anchors, not feature-specific verdicts — the project owner is
    responsible for keeping examples relevant
  - Large number of eval files (>10): Quality Skeptic reads all of them; no cap
    is enforced at the harness level — if context pressure is a concern, the
    operator should curate their examples directory

- **Notes**: This story is a spawn prompt addition only — the calibration
  instruction is injected into the Quality Skeptic's (and product-skeptic's)
  prompt when eval examples are present. The format of eval examples files is
  not enforced by the harness; the `## APPROVED` / `## REJECTED` structure is a
  recommended convention, not a requirement. Operators writing eval examples
  should use their post-mortem quality ratings (Story 29-2) to identify
  candidates for curation.

---

## P3-30: Checkpoint Frequency Configurability

---

### Story 30-1: `--checkpoint-frequency` Flag Parsing

- **As a** Team Lead or operator invoking any multi-agent conclave skill
- **I want** to pass
  `--checkpoint-frequency [every-step|milestones-only|final-only]` to control
  how often progress checkpoints are written
- **So that** I can reduce file write noise on long runs (milestones-only or
  final-only) or retain full granularity when debugging (every-step)

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a multi-agent skill invoked with
     `--checkpoint-frequency milestones-only`, when the skill's "Determine Mode"
     step parses `$ARGUMENTS`, then the effective checkpoint frequency is set to
     `milestones-only` for all agents in the session
  2. Given the flag is absent, when the skill initializes, then `every-step` is
     the default — identical to the current behavior where agents checkpoint
     after every significant state change
  3. Given an unrecognized value (e.g., `--checkpoint-frequency whenever`), when
     the skill parses the flag, then it logs a warning — "Invalid
     --checkpoint-frequency value; using default (every-step)" — and falls back
     to `every-step`
  4. Given `--checkpoint-frequency` appears alongside other flags (e.g.,
     `--light --checkpoint-frequency final-only`), when the skill parses
     `$ARGUMENTS`, then all flags are correctly stripped and the remaining value
     is treated as the mode argument
  5. Given `bash scripts/validate.sh`, when run after any SKILL.md changes, then
     all validators pass

- **Edge Cases**:
  - Flag applied to a single-agent skill (setup-project, wizard-guide): no
    checkpoint protocol exists in single-agent skills; the flag is silently
    ignored
  - `--checkpoint-frequency` and `--max-iterations` both supplied: both are
    parsed and applied independently
  - Checkpoint frequency flag supplied in `status` mode: ignored — `status` mode
    reads existing checkpoints, never writes new ones

- **Notes**: Flag parsing for `--checkpoint-frequency` lives in the same
  "Determine Mode" parse block as `--max-iterations` and `--complexity`. All
  three flags are parsed in a single pass. The extracted frequency value is
  referenced in each agent's "When to Checkpoint" instructions (passed as
  context when the Team Lead describes checkpoint behavior to spawned agents).

  **Design assumption note** (see also P3-31): The every-step default exists
  because agents on smaller models needed fine-grained checkpoints for reliable
  context recovery. On Opus-class models, milestones-only may be sufficient.
  This assumption should be tested when Opus-class models are the primary
  execution model and the `--checkpoint-frequency` flag may become less
  necessary over time.

---

### Story 30-2: Per-Frequency Checkpoint Behavior

- **As an** agent running inside a multi-agent conclave skill
- **I want** my checkpoint instructions to reflect the operator-supplied
  frequency mode
- **So that** I write checkpoints at the right cadence: every state change, at
  milestones only, or only at final completion

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `every-step` frequency (the default), when any agent's "When to
     Checkpoint" list is consulted, then it is unchanged — checkpoint after:
     task claimed, deliverable completed, review feedback received, blocked,
     work complete
  2. Given `milestones-only` frequency, when any agent's "When to Checkpoint"
     list is evaluated, then checkpoints are only written at these events:
     deliverable completed (status: awaiting_review), blocked (status: blocked),
     work complete (status: complete) — "task claimed" and "review feedback
     received" checkpoints are skipped
  3. Given `final-only` frequency, when any agent's "When to Checkpoint" list is
     evaluated, then the ONLY checkpoint written is at work complete (status:
     complete) — all intermediate checkpoints are skipped
  4. Given `milestones-only` or `final-only` and a session interruption
     mid-pipeline, when the Team Lead attempts recovery from checkpoints, then
     it reads available checkpoint files and notes in its recovery message that
     "reduced checkpoint frequency was active — recovery resolution may be
     coarser than usual"
  5. Given the Team Lead spawns teammates, when it describes checkpoint behavior
     in each spawn prompt, then the frequency mode is communicated: "Checkpoint
     frequency: milestones-only — skip intermediate checkpoints"
  6. Given `bash scripts/validate.sh`, when run after all SKILL.md changes for
     the 14 multi-agent skills, then all validators pass

- **Edge Cases**:
  - Agent blocked mid-implementation with `final-only` frequency: the `blocked`
    event is always checkpointed regardless of frequency — a blocked state is a
    milestone; omitting it would break the recovery protocol
  - Agent context exhaustion (Team Lead triggers re-spawn) with `final-only`:
    Team Lead reads the one existing checkpoint (if any) and re-spawns from the
    last known state; if no checkpoint exists, the agent restarts from scratch —
    this is a known tradeoff of `final-only` mode
  - Checkpoint frequency change mid-session (operator re-invokes with different
    flag): the new frequency applies from the re-invocation point forward;
    earlier checkpoints written at the old frequency are not deleted

- **Notes**: This story propagates the frequency mode to all 14 multi-agent
  SKILL.md files — the same 14 files updated in P3-26 Story 26-2. The change is
  to each skill's "When to Checkpoint" section, which currently lists the same
  events across all skills. With this story, the section becomes conditional on
  the frequency mode. Implementation is prompt-content only.

---

## P3-31: Design Assumptions Documentation

---

### Story 31-1: `SCAFFOLD` Comment Convention Definition

- **As a** skill author modifying or reviewing conclave SKILL.md files
- **I want** a defined convention for inline `<!-- SCAFFOLD: ... -->` HTML
  comments that document model-capability assumptions embedded in skill prompts
- **So that** the assumptions baked into the harness are visible, attributable,
  and testable — removing them is a conscious decision, not a guess

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `CLAUDE.md`, when it is updated, then a "SCAFFOLD Comments"
     subsection is added to the "Development Guidelines" section defining: the
     comment format, when to write one, what fields it must contain, and an
     example
  2. Given the convention definition, when it is inspected, then it specifies
     this format:
     ```
     <!-- SCAFFOLD: [what this scaffolding does] | ASSUMPTION: [model-capability
     assumption being made] | TEST REMOVAL: [condition under which this scaffold
     should be tested for removal] -->
     ```
  3. Given a SCAFFOLD comment is written, when it is reviewed, then it must
     contain all three fields — `what`, `ASSUMPTION`, and `TEST REMOVAL` — a
     comment missing any field is considered malformed
  4. Given the convention definition in CLAUDE.md, when it is read by a skill
     author, then it includes a guidance note: "SCAFFOLD comments are not
     end-user-visible — they are documentation for skill maintainers. Do not add
     them to sections that are injected verbatim into agent spawn prompts."
  5. Given `bash scripts/validate.sh`, when run after the CLAUDE.md change, then
     all validators pass (CLAUDE.md is not covered by the validator suite, so
     this criterion is trivially satisfied — but is noted as a confirmation
     step)

- **Edge Cases**:
  - A developer writes a SCAFFOLD comment inside a spawn prompt section (which
    is injected verbatim into agent context): agents may see and misinterpret it
    as an instruction — CLAUDE.md guidance explicitly warns against this
  - Multi-line SCAFFOLD comment (assumption is verbose): acceptable; HTML
    comments can span lines — use line breaks inside the comment for readability

- **Notes**: The SCAFFOLD comment convention is documentation-only. No validator
  is added to enforce it — enforcement is by code review. The convention is
  defined once in CLAUDE.md and referenced when Story 31-2 applies it to
  existing SKILL.md files.

---

### Story 31-2: Apply SCAFFOLD Comments to Multi-Agent SKILL.md Files

- **As a** conclave skill maintainer
- **I want** every model-capability assumption currently implicit in multi-agent
  SKILL.md orchestration logic to be annotated with a `<!-- SCAFFOLD: ... -->`
  comment
- **So that** I can audit assumptions at a glance and plan systematic removal
  testing as model capabilities improve

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all 14 multi-agent SKILL.md files, when SCAFFOLD comments are added,
     then at minimum the following categories of assumptions are annotated:
     - **Skeptic iteration caps**: e.g.,
       `<!-- SCAFFOLD: Max N skeptic rejections before escalation | ASSUMPTION: models below Opus require a hard cap to prevent infinite skeptic loops | TEST REMOVAL: when pipeline consistently converges in ≤2 rejections across 10+ sessions -->`
     - **Lead-as-Skeptic pattern** (Stages 1-3 in plan-product): e.g.,
       `<!-- SCAFFOLD: Lead performs inline skeptic review instead of spawning a dedicated skeptic agent | ASSUMPTION: Sonnet-class model sufficient for early-stage research review; dedicated Opus skeptic adds cost without quality gain for research/ideation | TEST REMOVAL: benchmark --full vs. default quality on the same pipeline topic -->`
     - **every-step checkpoint default**: e.g.,
       `<!-- SCAFFOLD: Checkpoint after every significant state change | ASSUMPTION: agent context degrades on long runs; frequent checkpoints enable recovery | TEST REMOVAL: on Opus-class models, test milestones-only and measure recovery accuracy -->`
     - **Opus model for skeptic/QA agents**: e.g.,
       `<!-- SCAFFOLD: Quality Skeptic and QA Agent always use Opus model | ASSUMPTION: Sonnet-class models produce more false approvals at quality gates | TEST REMOVAL: run a/b comparison: Opus vs. Sonnet Quality Skeptic on 5 identical pipelines; measure rejection accuracy -->`
  2. Given a SCAFFOLD comment is placed, when it is inspected, then it appears
     directly above or on the same line as the construct it documents — not in a
     separate section far from the code
  3. Given `plan-product/SKILL.md` Stages 1-3 Lead-as-Skeptic inline review
     steps, when SCAFFOLD comments are added (before or alongside P3-28
     implementation), then the Lead-as-Skeptic pattern is annotated before
     `--full` mode is available, so the assumption is documented regardless of
     whether `--full` ships first
  4. Given SCAFFOLD comments are added inside HTML comment markers, when
     `bash scripts/validate.sh` runs, then all validators continue to pass —
     HTML comments do not interfere with YAML frontmatter parsing or section
     detection
  5. Given SCAFFOLD comments are NOT placed inside spawn prompt code blocks (the
     verbatim content between triple-backtick markers), when spawn prompts are
     injected into agent context, then no SCAFFOLD comment text appears in any
     agent's received instructions

- **Edge Cases**:
  - SCAFFOLD comment accidentally placed inside a spawn prompt code block: the
    agent receives the comment as text and may attempt to interpret it as an
    instruction — this is a malformed placement; reviewer must catch it before
    merge
  - A1-series validator reads SKILL.md sections and may match on
    `<!-- SCAFFOLD:` content: HTML comments are transparent to the current
    section-detection grep patterns; if a SCAFFOLD comment happens to contain a
    section header keyword (e.g., `## Setup`), it could cause false positives —
    SCAFFOLD comment content must not contain `##`-prefixed lines

- **Notes**: This story is a documentation pass over existing SKILL.md files,
  not a behavioral change. SCAFFOLD comments are read by humans, not agents. The
  four categories listed in AC 1 are the minimum required set — additional
  assumptions discovered during the annotation pass should also be documented.
  The annotation pass should be done as a single commit so the "before" state of
  implicit assumptions is clearly visible in git history.

---

## Non-Functional Requirements

- **Validator stability**: All 12/12 validators must continue passing after
  every story. SKILL.md structural changes are especially sensitive to A-series
  checks (frontmatter, sections, spawn definitions, markers). Verify with
  `bash scripts/validate.sh` before committing any SKILL.md change.
- **Prompt injection safety**: `--max-iterations`, `--complexity`, and
  `--checkpoint-frequency` flag values are parsed from `$ARGUMENTS` and used as
  numeric/enum scalars — they are never injected verbatim into agent prompts as
  freeform strings. The Team Lead interpolates them as structured values (e.g.,
  "Max skeptic iterations: 5") — not raw user input.
- **No shared content changes**: `plugins/conclave/shared/principles.md` and
  `plugins/conclave/shared/communication-protocol.md` are out of scope for all
  six items. All changes are SKILL.md prompt content, spawn prompts, or
  CLAUDE.md documentation.
- **Backward compatibility**: All flags are optional with documented defaults
  matching current behavior. Existing invocations without flags must behave
  identically to today.
- **Eval examples isolation**: `.claude/conclave/eval-examples/` content is
  injected under a clearly labeled `## Evaluator Examples (user-provided)`
  heading in agent prompts. Agents are instructed that this content is
  user-supplied context, not system-authoritative directives.

## Out of Scope

- Automated validation of `<!-- SCAFFOLD: ... -->` comment format (P3-31):
  convention is enforced by code review, not tooling
- Persisting `--max-iterations` or `--checkpoint-frequency` as project defaults
  in `.claude/conclave/` config — flags are per-invocation only; persistent
  config is a separate future item
- Evaluator tuning for single-agent skills (setup-project, wizard-guide): P3-29
  targets skeptic/quality agents only; single-agent skills have no skeptic gate
  to calibrate
- Complexity classifier training data or automated classification: the
  classifier in P3-27 is a Team Lead reasoning step — no ML, no training data,
  no external API
- Cross-session eval example analysis or dashboards: P3-29 collects raw
  post-mortem data; reporting and trend analysis are out of scope
- `--full` flag for skills other than plan-product: Stage 1-3 Lead-as-Skeptic is
  unique to plan-product's pipeline structure; other skills already use
  dedicated skeptics or do not have the same asymmetry
