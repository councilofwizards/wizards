---
feature: "harness-design-improvements"
team: "product-planning"
agent: "analyst"
phase: "analysis"
status: "complete"
last_action:
  "Addendum: user-writable config convention — new P2-13 item recommended"
updated: "2026-03-27T15:00:00Z"
---

# Harness-Design Improvements: Roadmap Placement Analysis (Revised)

**Author**: Caelen Greymark, Cartographer of the Path Forward **Date**:
2026-03-27 (revised after best-practices context) **Source**: Anthropic harness
design paper analysis + best practices synthesis document

---

## Executive Summary

Two of the seven improvements are strong P2 candidates: **Sprint Contracts**
(P2-11) and the **QA Agent** (P2-12). Both address generator-evaluator
separation, the paper's central finding. Sprint Contracts should precede the QA
Agent — the QA agent is more reliable when acceptance criteria are
pre-negotiated.

The remaining items are P3. The additional best-practices context raises
**Evaluator Tuning** (originally Item 6) from vague-and-large to
tractable-and-medium: few-shot calibration files in
`references/eval-examples.md` are a concrete, lower-effort implementation path.
It remains P3 but is now a stronger P3.

One new item emerges from the best-practices synthesis: **Design Assumptions
Documentation** (P3-31) — annotating SKILL.md files with explicit comments about
what scaffolding compensates for model limitations. Small effort, useful for
long-term maintainability.

The best-practices document also reinforces existing P2-10 (Skill
Discoverability) without requiring a new item: "pushy" triggering descriptions
that enumerate escalation signals should be folded into P2-10's implementation
scope.

Total new items: **2 P2, 6 P3** (7 original + 1 new). All items are additive —
no conflicts with existing roadmap items.

---

## Roadmap State at Time of Analysis

| Tier          | Status                                                           |
| ------------- | ---------------------------------------------------------------- |
| P1 (4 items)  | All complete                                                     |
| P2 (10 items) | P2-01 through P2-07, P2-09 complete; P2-08 and P2-10 not started |
| P3 (25 items) | 4 complete (P3-02, P3-10, P3-14, P3-22); 21 not started          |

**Current Wave 1**: P2-10 (Skill Discoverability) — small effort, high ROI, no
dependencies **Next in queue**: P2-07 (Role-Based Principles Split), P2-08
(Plugin Organization — deferred pending business skill validation)

New items from this analysis slot in as Wave 2 P2 work (P2-11, P2-12, P2-13) and
extend the P3 backlog (P3-26 through P3-31).

---

## Item-by-Item Analysis

### Item 1: QA Agent for Live Testing

**Recommended priority**: P2 **Recommended number**: P2-12 **Category**:
core-framework **Effort**: Large **Impact**: High

**Rationale**: The paper's most concrete finding is that live application
testing by evaluators dramatically outperforms text-only review. This is also
the user's explicitly stated highest priority. The QA Agent fills a genuine gap:
the existing code skeptic reviews code diffs but never executes tests. A
dedicated QA role that writes and runs e2e/Playwright tests before approving
implementation closes the most significant quality gap in the pipeline.

**Scope refinement from best-practices context**: The QA agent's evaluation
criteria should be framed as user-facing behaviors, not implementation checks.
Test assertions should be written as "a user should be able to..." rather than
"the function should return...". This framing is architecturally important — it
keeps the QA agent's role distinct from the code skeptic and forces tests to
exercise the artifact as a user would.

**Full scope**: Modifications to `build-implementation` and `build-product`
SKILL.md files. New QA agent spawn definition with distinct persona. Feedback
format must produce explicit PASS/FAIL verdicts with specific, actionable
failure descriptions (not suggestions). Integration point: QA agent receives
implementation artifacts and sprint contract, runs tests, returns structured
verdict before final skeptic approval.

**Dependencies**:

- Soft dependency on P2-11 (Sprint Contracts): QA agent is more reliable when
  acceptance criteria are pre-negotiated in a sprint contract. Without one, it
  evaluates against spec/stories — functional but less precise. Sprint Contracts
  should be implemented first.
- No dependency on any existing unfinished roadmap items.

**Conflicts**: None. Complements the existing code skeptic (reviews code
quality) rather than replacing it. Two distinct roles, distinct concerns.

**Position relative to Wave 1**: Implement after P2-10 and P2-11.

---

### Item 2: Configurable Skeptic Iteration Limits

**Recommended priority**: P3 **Recommended number**: P3-26 **Category**:
core-framework **Effort**: Medium **Impact**: Medium

**Rationale**: The current 3-rejection cap then escalate-to-user pattern was
intentional: it prevents infinite loops and keeps humans in the loop on
subjective disagreements. The paper's 5-15 iteration recommendation applies to
human-supervised refinement loops, not fully automated pipelines. Current
behavior is not broken. A configurable `--max-iterations N` flag is genuine
convenience without being a quality gap.

**Scope**: Update skeptic loop exit instructions across all multi-agent skills
to respect `--max-iterations N` flag (default 3). Different defaults per skill
type documented in wizard-guide (research: 5, implementation with tests: 3).
Estimated changes: 14 SKILL.md files + wizard-guide.

**Dependencies**: None.

**Conflicts**: None. Purely additive flag.

---

### Item 3: Sprint Contracts / Definition of Done

**Recommended priority**: P2 **Recommended number**: P2-11 **Category**:
core-framework **Effort**: Large **Impact**: High

**Rationale**: The paper identifies vague acceptance criteria as the primary
driver of poor evaluator performance. Currently, the code skeptic reviews
against general principles. A Sprint Contract — negotiated between Lead and
Skeptic before implementation begins — makes each evaluation specific,
measurable, and reproducible. This also directly addresses the "hard thresholds,
not soft feedback" best practice: when the skeptic evaluates against explicit
contract terms, its REJECTED verdicts naturally become specific and actionable
without requiring changes to skeptic prompting logic.

**Scope refinement from best-practices context**: The sprint contract must be
written to a persisted file (not held in context) to survive long multi-agent
runs. This confirms the artifact-first approach. The template should live at
`docs/templates/artifacts/sprint-contract.md` following the established P2-06
pattern.

**Artifact template fields**:

```yaml
---
type: sprint-contract
feature: ""
version: ""
negotiated-by: [lead, skeptic]
signed-date: ""
acceptance-criteria:
  - ""
out-of-scope:
  - ""
performance-targets:
  - ""
qa-test-plan:
  - ""
---
```

`qa-test-plan` is a new field (not in original design) that documents what the
QA agent will test — negotiated alongside the acceptance criteria so the QA
agent has explicit test scope.

**New step in plan-implementation**: Lead proposes contract draft → Skeptic
reviews and challenges vague criteria → both sign → contract written to
`docs/progress/{feature}-sprint-contract.md` before plan is finalized.

**New behavior in build-implementation**: Code Skeptic cites specific contract
terms in all APPROVED/REJECTED verdicts. QA Agent executes the `qa-test-plan`
items from the contract.

**Dependencies**: P2-06 (Artifact Format Templates, complete) — follows
established template pattern.

**Conflicts**: None. Extends the plan-implementation → build-implementation
handoff without breaking it.

**Sequencing**: Implement before P2-12 (QA Agent).

---

### Item 4: Complexity-Adaptive Pipeline

**Recommended priority**: P3 **Recommended number**: P3-27 **Category**:
core-framework **Effort**: Medium **Impact**: Medium

**Rationale**: The existing artifact detection in `plan-product` and
`build-product` already provides a partial fast-path. An explicit complexity
classifier adds genuine value for simple bug fixes and small changes, but the
value is incremental. Most tasks entering the full pipeline benefit from all
stages.

**Scope**: Complexity classifier prompt at pipeline entry points (plan-product,
build-product). Three tiers: Simple (bug fix, well-scoped single-file change) →
skip to build-implementation; Standard (new feature with clear spec) → standard
pipeline; Complex (architectural change, cross-cutting concern) → full pipeline
with additional skeptic checkpoints.

**Dependencies**: None.

**Conflicts**: Touches plan-product and build-product SKILL.md files — same
files as Item 5 (Lead-as-Skeptic Fix, P3-28). Recommend batching these two items
in a single implementation pass.

---

### Item 5: Lead-as-Skeptic Consistency Fix

**Recommended priority**: P3 **Recommended number**: P3-28 **Category**:
quality-reliability **Effort**: Medium **Impact**: Medium

**Rationale**: plan-product Stages 1-3 (research, ideation, roadmap) use the
Lead as its own skeptic while Stages 4-5 (stories, spec) use a dedicated
product-skeptic. The paper confirms dedicated evaluators outperform
self-evaluation. The current pattern was a deliberate tradeoff to control agent
count. A `--full` mode flag activating dedicated skeptics for all stages is the
right compromise — paper-optimal for power users, default unchanged.

**Scope**: Add dedicated skeptic spawn definitions to plan-product Stages 1-3.
Gate activation behind `--full` flag. Skeptic personas for
research/ideation/roadmap stages need definition (3 new personas from the
existing persona library).

**Dependencies**: P2-09 (Persona System Activation, complete) — the new skeptic
spawn definitions follow the activated persona pattern.

**Conflicts**: Modifies plan-product SKILL.md — same file as Item 4
(Complexity-Adaptive Pipeline, P3-27). Batch together.

---

### Item 6: Evaluator Tuning Mechanism

**Recommended priority**: P3 **Recommended number**: P3-29 **Category**:
quality-reliability **Effort**: Medium _(revised from Large)_ **Impact**: Medium
_(revised from Low-Medium)_

**Rationale revision**: The original scope (structured feedback capture +
ML-style prompt calibration) was Large effort. The best-practices context
provides a concrete, lower-effort implementation path: **few-shot calibration
examples stored in `references/eval-examples.md`** (or per-skill eval files).
When a skeptic approves something it shouldn't, or rejects something reasonable,
the fix is to add a counter-example to the calibration file — not to edit the
skeptic's core prompt logic. This is a filing-cabinet model, not a data-pipeline
model, and it's much more tractable.

Still P3: the user has explicitly deprioritized this, and it benefits most from
richer evaluation data that P2-11 (Sprint Contracts) and P2-12 (QA Agent) will
produce. But it's a meaningfully stronger P3 than originally assessed.

**Revised scope**: Add per-skill calibration files at
`.claude/conclave/eval-examples/{skill-name}.md` (user-writable config space —
see P2-13) storing labeled examples: `GOOD_APPROVAL`, `BAD_APPROVAL`,
`GOOD_REJECTION`, `BAD_REJECTION`. Skeptic spawn prompts include a reference:
"If `.claude/conclave/eval-examples/{skill-name}.md` exists, read it for
calibration before evaluating." A post-run step prompts the user: "Was this
output quality acceptable? Any surprising approvals or rejections? If yes,
describe — I will add an example to the calibration file." This keeps the
feedback loop human-driven and file-based.

**Storage note**: Calibration files must live outside the plugin folder
(read-only after marketplace install). `.claude/conclave/eval-examples/` is the
correct location per P2-13.

**Dependencies**: P2-11 (Sprint Contracts) produces structured criteria that
make examples more precise. P2-12 (QA Agent) produces test-execution results
that are strong calibration signals. P3-28 (Lead-as-Skeptic Fix) increases the
number of skeptic gates that would benefit from calibration. Best implemented
after all three but not strictly blocked.

---

### Item 7: Checkpoint Frequency Configurability

**Recommended priority**: P3 **Recommended number**: P3-30 **Category**:
developer-experience **Effort**: Small **Impact**: Low

**Rationale**: Opus 4.6's improved context coherence reduces urgency.
Checkpoints are cheap (small markdown writes) and their cross-session resume
value remains high. Additional context from the best-practices synthesis
confirms our current checkpoint architecture is sound — structured handoff
artifacts for context resets are already covered by our checkpoint protocol
(P1-02) and the artifact contract system (P2-06). No architectural gap here;
configurability is convenience only.

**Scope**: Add `--checkpoint-frequency [every-step|milestones-only|final-only]`
flag. Default: `every-step` (current behavior). Skills read flag at setup,
adjust checkpoint instructions in spawn prompts.

**Dependencies**: P1-02 (State Persistence, complete).

---

### Item 8 (NEW): Design Assumptions Documentation

**Recommended priority**: P3 **Recommended number**: P3-31 **Category**:
documentation **Effort**: Small **Impact**: Low-Medium

**Rationale**: The best-practices synthesis introduces a principle: document
what scaffolding compensates for model limitations, so it can be tested for
removal when better models ship. Currently, SKILL.md files explain _what_ each
agent does but not _why_ certain design choices exist. Annotating design
assumptions explicitly makes future model upgrades cheaper (remove scaffolding
that no longer compensates for anything) and makes contributions easier
(contributors understand intent, not just structure).

**Scope**: Add a `## Design Assumptions` section to each multi-agent SKILL.md
(12 files). Example annotation:
`<!-- SCAFFOLD: Explicit APPROVED/REJECTED verdict protocol compensates for evaluator tendency to hedge with conditional feedback. Revisit with Opus 5+ evaluators. -->`.
Also add a `### Design Assumptions` subsection to `docs/architecture/`
contribution guide (P3-03). These are inline comments in markdown — invisible to
the model during execution but visible to contributors.

**Interaction with P3-03**: If P3-03 (Architecture & Contribution Guide) is
implemented, the convention should be documented there first. P3-31 then applies
the convention to all 12 SKILL.md files. Recommend sequencing P3-03 → P3-31 if
both are undertaken.

**Dependencies**: None blocking. Soft sequence after P3-03 if that item is taken
on.

---

## Insights That Affect Existing Roadmap Items (No New Items Required)

### P2-10: Skill Discoverability — add "pushy" triggering descriptions

Best-practices point 8: Skills with advanced agentic patterns risk
undertriggering. Descriptions should enumerate escalation signals — e.g., "Use
this when: the task involves multiple dependent files, requires architectural
decisions, or has failed in a prior attempt." This is a direct addition to
P2-10's implementation scope, not a new item. P2-10 should include this as a
fourth bundled change alongside the existing three (business skills section,
wizard-guide mention in setup-project, Conclave lore preamble, Persona Spotlight
— currently four changes, adding one more for escalation signals in skill
descriptions).

### Hard Thresholds vs. Soft Feedback — already satisfied

Best-practices point 2 confirms our Skeptic pattern (APPROVED/REJECTED with
rationale) is architecturally correct. The gap risk is feedback specificity: a
REJECTED verdict that says "this needs improvement" doesn't help the generator
without investigation. P2-11 (Sprint Contracts) closes this gap structurally —
when the skeptic evaluates against explicit contract terms, specificity follows
naturally. No separate action needed beyond implementing P2-11.

### Handoff Artifacts / Context Resets — architecture validated

Best-practices point 4 recommends structured handoff artifacts for context
resets during long runs. Our checkpoint protocol (P1-02, complete) and artifact
contract system (P2-06, complete) already serve this role. The sprint contract
artifact (P2-11) will explicitly add the `qa-test-plan` field as a handoff to
the QA agent. Architecture is sound; no new item warranted.

---

## Addendum: User-Writable Configuration Convention

**Trigger**: The plugin is distributed via marketplace. After installation,
users have no write access to the plugin folder (`plugins/conclave/`). Any item
that needs user-maintained configuration — calibration examples (P3-29),
project-specific template overrides (P2-11), future agent guidance files —
cannot store that configuration in the plugin directory.

### Evaluation of the Three Options

**Option A — New standalone item (recommended)**

Create P2-13: User-Writable Configuration Convention, establishing
`.claude/conclave/` as the standard user-writable namespace for plugin
configuration. This item is implemented once and all consumers (P2-11 template
overrides, P3-29 calibration files, future items) follow the established
convention.

Why standalone over folding into P2-11:

- P2-11 is already Large effort. Adding an architectural storage decision to it
  bloats scope.
- P3-29 also needs user-writable storage. If the convention is buried in P2-11,
  P3-29 has no clean reference point — it either re-invents or creates an
  undocumented dependency.
- The convention needs to be documented in wizard-guide and setup-project so
  users know it exists. That documentation work is independent of sprint
  contract logic.

Why P2 (not P3):

- It's a prerequisite for P2-11's template override capability and P3-29's
  calibration files. A convention that's deferred to P3 forces both of those
  items to either block or choose their own paths.
- Effort is Small — this is primarily a convention definition + documentation +
  minor setup-project update.

**Option B — Fold into P2-11**

Viable if sprint contracts are the only consumer and we're willing to retrofit
P3-29 later. Rejected: P3-29 is explicitly a different consumer, and forcing it
to depend on P2-11 for a storage convention it uses for an unrelated purpose is
architecturally messy.

**Option C — Foundational item that others depend on**

This is essentially Option A — a standalone item with explicit `dependsOn`
edges. The distinction from Option A is labeling; the implementation is the
same.

### Recommended Item: P2-13

**Title**: User-Writable Configuration Convention **Priority**: P2 **Category**:
core-framework **Effort**: Small **Impact**: Medium

**Rationale**: Without a defined user-writable config location, each item that
needs project-specific configuration will invent its own storage path. One item
uses `docs/`, another uses a dotfile, a third prompts the user to choose. This
fragmentation makes the plugin harder to understand and harder to maintain. A
single convention, established once, solves this permanently.

**Storage split** (important distinction):

| What                                    | Where                                            | Why                                                                 |
| --------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------- |
| Sprint contract artifacts (per feature) | `docs/progress/{feature}-sprint-contract.md`     | These are project outputs — same as checkpoints and other artifacts |
| Sprint contract template overrides      | `.claude/conclave/templates/sprint-contract.md`  | Project-specific customization of the template structure            |
| Evaluator calibration examples          | `.claude/conclave/eval-examples/{skill-name}.md` | Plugin configuration, not project documentation                     |
| Project-specific agent guidance         | `.claude/conclave/guidance/`                     | Plugin configuration, not project documentation                     |

This split keeps `docs/` for outputs and `.claude/conclave/` for configuration —
parallel to how `docs/templates/artifacts/` holds the shipped templates while
user overrides live in `.claude/conclave/templates/`.

**Scope**:

1. Define the `.claude/conclave/` directory convention and subdirectory naming
   (`templates/`, `eval-examples/`, `guidance/`)
2. Update `setup-project` SKILL.md to create `.claude/conclave/` skeleton on
   project initialization
3. Document in `wizard-guide` under a new "Project Configuration" section
4. Add `.claude/conclave/` to `.gitignore` template in `setup-project`
   (calibration examples and guidance may contain project-specific information
   users don't want committed)
5. Skills that read from `.claude/conclave/` do so defensively — if the file
   doesn't exist, proceed without it (graceful degradation, never required)

**Consumers (items that depend on P2-13)**:

- P2-11 Sprint Contracts — template overrides at
  `.claude/conclave/templates/sprint-contract.md`
- P3-29 Evaluator Tuning — calibration examples at
  `.claude/conclave/eval-examples/{skill-name}.md`
- Future: agent guidance files, persona overrides, skill-specific defaults

**Dependencies**: None blocking. Complements P1-02 (State Persistence, complete)
— same principle of structured file conventions, different scope.

**Conflicts**: None. `.claude/conclave/` is unoccupied namespace.

---

## Full Recommended Roadmap Additions

| #     | Title                                  | Priority | Category             | Effort | Impact     | Dependencies                      |
| ----- | -------------------------------------- | -------- | -------------------- | ------ | ---------- | --------------------------------- |
| P2-11 | Sprint Contracts / Definition of Done  | P2       | core-framework       | Large  | High       | P2-06 ✅, P2-13                   |
| P2-12 | QA Agent for Live Testing              | P2       | core-framework       | Large  | High       | P2-11 (soft)                      |
| P2-13 | User-Writable Configuration Convention | P2       | core-framework       | Small  | Medium     | —                                 |
| P3-26 | Configurable Skeptic Iteration Limits  | P3       | core-framework       | Medium | Medium     | —                                 |
| P3-27 | Complexity-Adaptive Pipeline           | P3       | core-framework       | Medium | Medium     | —                                 |
| P3-28 | Lead-as-Skeptic Consistency Fix        | P3       | quality-reliability  | Medium | Medium     | P2-09 ✅                          |
| P3-29 | Evaluator Tuning Mechanism             | P3       | quality-reliability  | Medium | Medium     | P2-13, P2-11, P2-12, P3-28 (soft) |
| P3-30 | Checkpoint Frequency Configurability   | P3       | developer-experience | Small  | Low        | P1-02 ✅                          |
| P3-31 | Design Assumptions Documentation       | P3       | documentation        | Small  | Low-Medium | P3-03 (soft)                      |

---

## Sequencing Recommendations

**Wave 1 (current)**: P2-10 (Skill Discoverability) — add "pushy" triggering
descriptions to P2-10 scope during implementation

**Wave 2a**: P2-07 (Role-Based Principles Split) + P2-13 (User-Writable Config
Convention) in parallel

- P2-07: shared content edit, sync-script ready
- P2-13: convention definition + setup-project scaffold + wizard-guide
  documentation
- No file overlap — safe to run concurrently

**Wave 2b**: P2-11 (Sprint Contracts) — after P2-13 completes

- Needs config convention settled before defining where template overrides live
- New artifact template + plan-implementation/build-implementation edits

**Wave 3**: P2-12 (QA Agent) — builds on P2-11's sprint contract artifact and
`qa-test-plan` field

- Also a good time for P2-08 (Plugin Organization) if business skills are
  validated

**P3 batch (when capacity allows)**:

- P3-26 (Iteration Limits): standalone, any time
- P3-27 + P3-28: batch together — both touch plan-product SKILL.md
- P3-29 (Evaluator Tuning): after P2-11 + P2-12 produce calibration-worthy data
- P3-30 (Checkpoint Configurability): standalone, any time
- P3-31 (Design Assumptions): after P3-03 if taken on; otherwise standalone

---

## Dependency Map

```
P2-13 User-Writable Config Convention  ← no dependencies (establish first)
  ├─ P2-11 Sprint Contracts (template overrides in .claude/conclave/templates/)
  │    └─ P2-12 QA Agent (soft dep — more reliable with sprint contract)
  └─ P3-29 Evaluator Tuning (calibration files in .claude/conclave/eval-examples/)

P2-06 ✅
  └─ P2-11 Sprint Contracts (artifact template follows established pattern)

P2-09 ✅
  └─ P3-28 Lead-as-Skeptic Fix (needs persona defs for new skeptic roles)
       └─ P3-29 Evaluator Tuning (more skeptic gates = more calibration surface)

P2-12 QA Agent
  └─ P3-29 Evaluator Tuning (QA test data is strong calibration signal)

P1-02 ✅
  └─ P3-30 Checkpoint Configurability

P3-03 (not_started) → soft dep
  └─ P3-31 Design Assumptions Documentation (convention first, then apply it)

P3-26 Configurable Iteration Limits  ← no dependencies
P3-27 Complexity-Adaptive Pipeline   ← no dependencies (batch with P3-28)
```

---

## No Conflicts With Existing Items

Verified across all 38 existing roadmap items:

- **P2-04** (Automated Testing Pipeline, complete): tests SKILL.md structure —
  orthogonal to QA Agent which tests running applications
- **P2-06** (Artifact Format Templates, complete): provides the template
  framework Sprint Contracts follows
- **P2-10** (Skill Discoverability, not_started): "pushy descriptions" folds
  into this item's scope — no new item
- **P3-01** (Custom Agent Roles, not_started): QA Agent is a first-party role
  addition, not a conflict
- **P3-03** (Contribution Guide, not_started): Design Assumptions Documentation
  soft-sequences after it
- **P3-08** (Persona Reference Validator, not_started): P3-28's new skeptic
  personas will be validated by P3-08 once both are done — healthy dependency
  chain

---

## Changes From Initial Analysis

| Item                | Change                                            | Reason                                                                                      |
| ------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Item 6 (P3-29)      | Effort Large → Medium; Impact Low-Medium → Medium | Concrete path: few-shot calibration files, not ML infrastructure                            |
| Item 6 (P3-29)      | Storage path corrected                            | `plugins/conclave/` is read-only; corrected to `.claude/conclave/eval-examples/` per P2-13  |
| Item 3 (P2-11)      | Scope expanded; dependency on P2-13 added         | Artifact fields include `qa-test-plan`; template overrides in `.claude/conclave/templates/` |
| Item 1 (P2-12)      | Scope note added                                  | User-facing behavior framing for Playwright tests; explicit PASS/FAIL verdict format        |
| New: Item 8 (P3-31) | Design Assumptions Documentation                  | New item from best-practices synthesis                                                      |
| New: P2-13          | User-Writable Configuration Convention            | Plugin is read-only after marketplace install; need `.claude/conclave/` for user config     |
| P2-10               | Scope addendum                                    | "Pushy descriptions" folds into P2-10 — no new item                                         |
| Hard thresholds     | Architecture note                                 | Our APPROVED/REJECTED pattern satisfies this; P2-11 closes specificity gap                  |
| Context resets      | Architecture note                                 | P1-02 + P2-06 already cover this; validated, no action needed                               |
| Sequencing          | Wave 2 split into 2a + 2b                         | P2-13 must precede P2-11; P2-07 can still run in parallel with P2-13                        |

---

_Analysis by Caelen Greymark, Cartographer of the Path Forward_ _Revised after
best-practices synthesis context from team lead_
