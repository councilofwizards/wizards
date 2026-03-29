---
type: "user-stories"
feature: "plan-finance"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-12-plan-finance.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Finance Planning Skill (P3-12)

## Epic Summary

Add a `/plan-finance` skill to the conclave plugin. The skill assembles a Finance Planning Team with specialist agents
for burn rate analysis, revenue modeling, and scenario planning. Agents produce independent analyses that the Team Lead
synthesizes into a financial model covering base-case, optimistic, and pessimistic scenarios. A dual-skeptic quality
gate (Accuracy Skeptic + Risk Skeptic) ensures all numbers are traceable and risks are honestly assessed before the plan
is finalized. Output is written to `docs/finance-plans/`. This is the highest-complexity business skill (Large effort)
due to the quantitative scenario modeling requirement and multi-source data dependency.

## Stories

---

### Story 1: SKILL.md File Creation and Validator Compliance

- **As a** skill author adding the plan-finance skill
- **I want** a valid `plugins/conclave/skills/plan-finance/SKILL.md` that passes all A-series validators
- **So that** the skill is discoverable, structurally correct, and consistent with business skill conventions before any
  agents are invoked
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `plugins/conclave/skills/plan-finance/` directory exists, when `SKILL.md` is created, then its YAML
     frontmatter contains: `name: plan-finance`, a one-sentence `description` ending with a period, and
     `argument-hint: "[--light] [status | (empty for new assessment)]"`
  2. Given the SKILL.md file, when A1 (frontmatter) validation runs, then all required fields are present and no unknown
     fields exist
  3. Given the SKILL.md file, when A2 (sections) validation runs, then all required multi-agent sections exist:
     `## Setup`, `## Write Safety`, `## Checkpoint Protocol`, `## Determine Mode`, `## Lightweight Mode`,
     `## Spawn the Team`, `## Orchestration Flow`, `## Quality Gate`, `## Failure Recovery`,
     `## Teammate Spawn Prompts`, `## Shared Principles`, and `## Communication Protocol`
  4. Given the SKILL.md file, when A3 (spawn definitions) validation runs, then every teammate block contains
     `**Name**:` and `**Model**:` fields
  5. Given the SKILL.md file, when A4 (shared content markers) validation runs, then it contains
     `<!-- BEGIN SHARED: universal-principles -->` and `<!-- END SHARED: universal-principles -->` markers; it must NOT
     contain engineering-principles markers (plan-finance is non-engineering)
  6. Given `bash scripts/validate.sh`, when run after creation and sync, then all 12/12 validators pass
  7. Given `plan-finance` is not yet in the non-engineering skills classification lists, when the skill is added, then
     `scripts/sync-shared-content.sh` and `scripts/validators/skill-shared-content.sh` are both updated to include
     `plan-finance` in the non-engineering list

- **Edge Cases**:
  - `plan-finance` classified as engineering by default WARN path: this causes incorrect shared content injection; must
    be explicitly added to the non-engineering list before the first sync
  - B2 normalizer lacks skeptic name pairs for `accuracy-skeptic` and `risk-skeptic`: the normalizer already has
    `accuracy-skeptic` / `Accuracy Skeptic` from draft-investor-update; only `risk-skeptic` / `Risk Skeptic` needs to be
    added

- **Notes**: Check the B2 normalizer in `scripts/validators/skill-shared-content.sh` for existing skeptic name pair
  entries before adding new ones — `accuracy-skeptic` may already be covered. The plan-finance SKILL.md is expected to
  be significantly longer than plan-marketing due to the scenario modeling instructions; this is expected and consistent
  with the "Business skills are larger" note in CLAUDE.md.

---

### Story 2: Agent Team Composition

- **As a** founder invoking `/plan-finance`
- **I want** a team of three specialist analysis agents — burn rate analyst, revenue modeler, and scenario planner —
  plus a dual-skeptic quality gate of Accuracy Skeptic and Risk Skeptic
- **So that** each financial domain receives dedicated specialist attention and the final plan is validated for
  numerical accuracy AND risk completeness before being finalized
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Spawn the Team` section, when it is read, then it defines exactly five teammates:
     `burn-rate-analyst`, `revenue-modeler`, `scenario-planner`, `accuracy-skeptic`, and `risk-skeptic`
  2. Given the `burn-rate-analyst` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Analyze current and projected burn rate, cash position, and runway. Produce Burn Rate Brief."
  3. Given the `revenue-modeler` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Model revenue growth scenarios using product roadmap milestones and any user-provided revenue data.
     Produce Revenue Model Brief."
  4. Given the `scenario-planner` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Synthesize burn and revenue into base-case, optimistic, and pessimistic scenarios with explicit
     assumptions. Produce Scenario Brief."
  5. Given the `accuracy-skeptic` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Verify every number in the financial plan traces back to a stated source or assumption. No unsourced
     projections pass."
  6. Given the `risk-skeptic` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Evaluate completeness of risk identification and whether mitigations are realistic given startup
     resources."
  7. Given lightweight mode (`--light`), when the skill runs, then `burn-rate-analyst`, `revenue-modeler`, and
     `scenario-planner` use `sonnet`; both skeptics remain `opus` unchanged

- **Edge Cases**:
  - `accuracy-skeptic` spawn prompt must NOT reuse the exact prompt from draft-investor-update verbatim — the checklist
    items must be finance-specific (number traceability for projections, not investor update claims); the name and title
    may be the same persona if desired, but the checklist differs
  - Risk Skeptic must not be confused with the Plan Skeptic from engineering skills — this is a distinct agent with a
    distinct checklist focused on financial and execution risk

- **Notes**: The Accuracy Skeptic role appears in multiple skills (draft-investor-update, plan-sales). For plan-finance,
  the accuracy checklist must be adapted to financial modeling: every projection must cite a stated assumption, not just
  a file path. Consider whether to reuse the `Gideon Factstone` persona or define a finance-specific variant — either is
  acceptable, but the checklist must be adapted.

---

### Story 3: Orchestration Flow — Data-First Pipeline

- **As a** Finance Planning Team Lead
- **I want** a sequential pipeline that (1) collects financial data, (2) runs three specialist analyses in parallel, (3)
  produces multi-scenario synthesis, (4) runs dual-skeptic review, and (5) finalizes the plan
- **So that** analysis agents work from the same data foundation and the final plan contains validated scenarios rather
  than single-point estimates that give false precision
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Orchestration Flow` section, when it is read, then it defines five sequential phases: Phase 1 (Data
     Collection — Team Lead reads all financial artifacts), Phase 2 (Parallel Specialist Analysis), Phase 3 (Scenario
     Synthesis — Team Lead writes directly), Phase 4 (Dual-Skeptic Review), Phase 5 (Finalize)
  2. Given Phase 1, when it runs, then the Team Lead reads: `docs/finance-plans/_user-data.md` (if exists),
     `docs/roadmap/_index.md` and roadmap files (for milestone timelines), `docs/progress/` files (for delivery
     velocity), and any prior finance plans in `docs/finance-plans/` for baseline context
  3. Given Phase 2, when it runs, then all three analysis agents are spawned concurrently via `Agent` tool with
     `team_name: "plan-finance"`; each receives the Team Lead's data summary as context in their spawn prompt; each
     produces a Domain Brief sent to the Team Lead
  4. Given Phase 3, when it runs, then the Team Lead (NOT a spawned agent) writes the Financial Plan Synthesis directly,
     containing: base-case scenario, optimistic scenario, pessimistic scenario, and a scenario comparison table; the
     SKILL.md orchestration instructions must state "Phase 3 is NOT delegate mode"
  5. Given Phase 4, when it runs, then `accuracy-skeptic` and `risk-skeptic` are spawned concurrently; both receive the
     synthesis AND the three Domain Briefs as context; BOTH must return `Verdict: APPROVED` before Phase 5
  6. Given a rejection in Phase 4, when it occurs, then the Team Lead revises the synthesis incorporating ALL rejection
     feedback, returns to Phase 4 (max 3 cycles before human escalation)
  7. Given Phase 5, when it runs, then the Team Lead writes the final finance plan to
     `docs/finance-plans/{YYYY-MM-DD}-finance-plan.md` and progress summary to `docs/progress/plan-finance-summary.md`

- **Edge Cases**:
  - `_user-data.md` missing or empty in Phase 1: Team Lead outputs a data-dependency warning to the user ("No financial
    data found — projections will be low-confidence estimates based on roadmap timelines only") and proceeds; all
    projection sections in the output use `confidence: "low"` and placeholders for user-provided metrics
  - Prior finance plan exists: Team Lead reads it and uses it as a baseline; scenario planner receives it as context to
    ensure revised projections are consistent with or explicitly diverge from prior assumptions
  - Revenue modeler receives no revenue data (pre-revenue startup): modeler produces a zero-revenue baseline and
    projects first-revenue timeline from roadmap milestones rather than refusing to produce a brief

- **Notes**: The data-first Phase 1 differentiates plan-finance from plan-sales and plan-marketing, where analysis
  agents read the project directly. For finance, the Team Lead pre-reads and summarizes financial data before agents are
  spawned — this avoids each agent independently reading the same data and producing inconsistent summaries. The Team
  Lead's data summary is injected into each agent's spawn prompt.

---

### Story 4: Multi-Scenario Output Artifact

- **As a** founder reviewing the finance plan output
- **I want** a structured markdown file in `docs/finance-plans/` with three explicit scenarios (base, optimistic,
  pessimistic), a scenario comparison table, and all assumptions stated
- **So that** I can make funding, hiring, and spending decisions based on a range of outcomes rather than a single
  fragile projection
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Output Template` section of SKILL.md, when the plan is finalized, then the output file is written to
     `docs/finance-plans/{YYYY-MM-DD}-finance-plan.md`
  2. Given the output file YAML frontmatter, when it is validated, then it contains: `type: "finance-plan"`,
     `generated: "{YYYY-MM-DD}"`, `scenarios: [base, optimistic, pessimistic]`, `confidence: "high|medium|low"`,
     `review_status: "approved"`, `approved_by: [accuracy-skeptic, risk-skeptic]`
  3. Given the output file body, when it is read, then it contains these sections in order: Executive Summary, Financial
     Snapshot (current state), Base-Case Scenario, Optimistic Scenario, Pessimistic Scenario, Scenario Comparison Table,
     Key Assumptions, Risks & Mitigations, Recommended Actions, Assumptions & Limitations, Confidence Assessment,
     Falsification Triggers, External Validation Checkpoints
  4. Given each scenario section (Base, Optimistic, Pessimistic), when it is read, then it contains: runway estimate in
     months, burn rate assumption, revenue assumption, key events required for this scenario to materialize, and
     confidence level (H/M/L)
  5. Given the Scenario Comparison Table, when it is read, then it has columns: Scenario / Runway / Monthly Burn /
     Revenue by Month-6 / Key Risk / Confidence — with one row per scenario
  6. Given the Key Assumptions section, when it is read, then every quantitative projection in any scenario section is
     referenced back to a numbered assumption (e.g., "Runway: 14 months [assumes A1, A3]")
  7. Given `docs/finance-plans/_user-data.md` does not exist, when the skill runs for the first time, then it creates
     the file and outputs: "Created docs/finance-plans/\_user-data.md — fill in your current cash position, monthly
     burn, MRR, and team headcount for accurate projections."

- **Edge Cases**:
  - All three scenarios produce identical runway: valid — this signals insensitivity to assumptions; the Accuracy
    Skeptic must flag this for review (it may indicate the scenario planner did not vary assumptions meaningfully)
  - Pessimistic scenario produces negative runway (already past the brink): valid and must be represented honestly; the
    Executive Summary must prominently flag this
  - User-provided data has internal inconsistencies (e.g., burn > cash but "18 months runway"): Accuracy Skeptic must
    catch and reject; revision required before finalization

- **Notes**: The mandatory business quality sections — Assumptions & Limitations, Confidence Assessment, Falsification
  Triggers, External Validation Checkpoints — are non-negotiable per business skill design guidelines. For finance
  plans, Falsification Triggers are especially important: e.g., "If MRR growth drops below X%, the optimistic scenario
  should be revised to base-case." The User Data Template must prompt for: cash on hand, monthly burn, current MRR/ARR,
  headcount cost breakdown, and known large upcoming expenses.

---

### Story 5: Accuracy Skeptic Financial Checklist

- **As an** Accuracy Skeptic reviewing the financial plan synthesis
- **I want** a finance-specific checklist that verifies every projection traces to a stated assumption and every number
  is internally consistent
- **So that** no fabricated or internally contradictory projections reach the founder, preventing financial decisions
  based on hallucinated data
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Accuracy Skeptic's spawn prompt, when it is read, then it includes a numbered checklist of at least 6
     items covering: (a) every runway figure traces to a burn rate assumption, (b) every revenue projection traces to a
     stated growth assumption or roadmap milestone, (c) scenario comparison table values match the individual scenario
     sections, (d) all assumptions are numbered and each is referenced from at least one projection, (e) no metric is
     asserted with "high" confidence when the underlying data is user-estimated or unavailable, (f) all placeholders
     (`[Requires user input]`) are correctly placed in sections that lack user data
  2. Given an Accuracy review, when it is complete, then the output format is: `ACCURACY REVIEW: Finance Plan` /
     `Verdict: APPROVED / REJECTED` / if rejected: numbered list of issues with specific claim, why it's wrong, evidence
     (domain brief or assumption reference), and fix
  3. Given a projection that cannot be traced to a stated assumption, when the Accuracy Skeptic encounters it, then it
     is a rejection-worthy defect — not a "minor observation"
  4. Given all scenarios having identical numbers, when the Accuracy Skeptic reviews, then they flag this as a potential
     modeling defect and request the scenario planner confirm intentionality
  5. Given the Accuracy Skeptic spawn prompt, when it is read, then it instructs: "You MUST be explicitly asked to
     review. Do not self-assign." — per shared communication protocol

- **Edge Cases**:
  - Accuracy Skeptic receives synthesis but not the Domain Briefs: the spawn prompt must include all four documents
    (synthesis + 3 Domain Briefs) as context; if only the synthesis is provided, skeptic must message the Team Lead
    requesting the Domain Briefs before reviewing
  - Synthesis references a prior finance plan as a baseline: Accuracy Skeptic must verify the baseline numbers match the
    prior plan file, not just the current session's context

- **Notes**: This checklist is distinct from the draft-investor-update Accuracy Skeptic checklist which focuses on
  milestone and claim verification. The finance checklist focuses on quantitative traceability and internal consistency.
  Both checklists can coexist in the B2 normalizer under the same role name `accuracy-skeptic` since the name
  normalization is per-skill — the spawn prompts contain the actual skill-specific checklists.

---

### Story 6: Risk Skeptic Financial Risk Review

- **As a** Risk Skeptic reviewing the financial plan synthesis
- **I want** a structured risk review checklist that evaluates completeness of risk identification and realism of
  mitigations
- **So that** founders receive an honest assessment of financial vulnerability, not just a plan that confirms their
  optimism
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Risk Skeptic's spawn prompt, when it is read, then it includes a numbered checklist of at least 5 items
     covering: (a) concentration risk (single customer, channel, or team member dependency), (b) runway adequacy for the
     next planned milestone, (c) whether the pessimistic scenario is actually pessimistic (not just "slightly worse base
     case"), (d) whether mitigations are actionable given startup resources (not "raise more money" as the only
     mitigation), (e) whether key-person risk is addressed
  2. Given a Risk review, when it is complete, then the output format is: `RISK REVIEW: Finance Plan` /
     `Verdict: APPROVED / REJECTED` / if rejected: numbered issues with specific risk domain, why it's inadequately
     addressed, and what adequate coverage looks like
  3. Given the pessimistic scenario assumes all bad things happen simultaneously, when the Risk Skeptic reviews, then
     they verify whether this is realistic or artificially extreme — extreme pessimism is as problematic as extreme
     optimism
  4. Given a risk without a mitigation strategy, when the Risk Skeptic reviews, then this is a rejection-worthy defect —
     every identified risk in Risks & Mitigations must have at least one actionable mitigation
  5. Given the Risk Skeptic spawn prompt, when it is read, then it instructs: "You MUST be explicitly asked to review.
     Do not self-assign." — per shared communication protocol

- **Edge Cases**:
  - Pre-revenue startup with no revenue risk to assess: Risk Skeptic adjusts checklist to focus on time-to-first-revenue
    risk and customer acquisition risk rather than revenue concentration
  - Risk Skeptic and Accuracy Skeptic identify the same issue from different angles: both verdicts may reject; the Team
    Lead incorporates both objections in the revision
  - Synthesis acknowledges risks but mitigation section is empty: this is a rejection-worthy defect; the mitigation
    section cannot be a placeholder when risks are explicitly identified

- **Notes**: The Risk Skeptic is unique to plan-finance. It does not appear in any existing skill's B2 normalizer —
  `risk-skeptic` / `Risk Skeptic` must be added as a new skeptic name pair in both
  `scripts/validators/skill-shared-content.sh` and the Communication Protocol skeptic name substitution in
  `scripts/sync-shared-content.sh`.

---

### Story 7: Session Recovery and Status Mode

- **As a** founder who interrupted a `/plan-finance` session
- **I want** the skill to detect incomplete checkpoints on re-invocation and resume from the last phase
- **So that** long-running financial modeling sessions (which may span multiple context windows) can resume without
  restarting the entire data collection and analysis pipeline
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given `$ARGUMENTS` is `"status"`, when the skill is invoked, then the Team Lead reads all `docs/progress/` files
     with `team: "plan-finance"` in their frontmatter and outputs a status summary without spawning agents
  2. Given `$ARGUMENTS` is empty and no incomplete checkpoints exist, when the skill is invoked, then a fresh assessment
     begins from Phase 1 (Data Collection)
  3. Given `$ARGUMENTS` is empty and incomplete checkpoints exist for `team: "plan-finance"`, when the skill is invoked,
     then the Team Lead reads checkpoint files and re-spawns only agents with incomplete work, providing checkpoint
     content as context
  4. Given Phase 1 (Data Collection) was completed and checkpointed, when the skill resumes, then Phase 1 is skipped and
     agents are spawned directly with the data summary from the checkpoint
  5. Given the finance plan output file already exists when the skill is invoked with no args, then the Team Lead
     outputs: "Finance plan already complete. See docs/finance-plans/{filename}."

- **Edge Cases**:
  - Phase 1 data collection checkpoint is stale (more than 7 days old and roadmap has changed): Team Lead warns the user
    that financial data may be outdated and offers to re-run Phase 1 before resuming
  - Scenario planner checkpoint exists but accuracy-skeptic rejected the synthesis: Team Lead re-reads the rejection
    feedback from the skeptic's checkpoint file and passes it to the synthesis phase for revision
  - No `docs/finance-plans/` directory exists: Setup creates it with `.gitkeep` on first run

- **Notes**: Phase 1's data collection step makes plan-finance's resumption logic more nuanced than other skills — the
  Team Lead must distinguish between "Phase 1 data is checkpointed" (skip Phase 1) and "Phase 1 data may be stale" (warn
  and offer re-run). The checkpoint format uses
  `phase: "data-collection | analysis | synthesis | review | revision | complete"` for plan-finance specifically.

---

## Non-Functional Requirements

- **Validator stability**: plan-finance must not break 12/12 passing validators. All classification list updates (sync
  script + B2 validator) must be made before running `bash scripts/validate.sh`.
- **No fabricated projections**: All agents must be instructed in their spawn prompts that every quantitative claim
  requires a stated source or explicit assumption. Agents must use confidence labels and placeholders rather than
  inventing numbers when data is absent.
- **Write isolation**: Parallel agents in Phase 2 write only to `docs/progress/plan-finance-{role}.md`. Only the Team
  Lead writes to `docs/finance-plans/`.
- **Business quality sections mandatory**: Assumptions & Limitations, Confidence Assessment (table), Falsification
  Triggers, and External Validation Checkpoints are non-negotiable in every output — not removable under lightweight
  mode.
- **Scenario completeness**: The output must always contain all three scenarios (base, optimistic, pessimistic).
  Producing a single-scenario plan is a defect — the whole point of this skill is multi-scenario analysis.

## Out of Scope

- Live financial data integrations (QuickBooks, Stripe, bank accounts)
- Spreadsheet or model export (CSV, Excel)
- Cap table analysis or equity planning
- Tax planning or accounting advice
- Integration with plan-sales or plan-hiring output artifacts — cross-skill synthesis is a manual step
- Automated alerting when financial metrics cross thresholds (a future analytics/monitoring concern)
- Valuation modeling or fundraising term sheet analysis
