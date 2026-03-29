---
title: "Finance Planning Skill (/plan-finance) Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Finance Planning (`/plan-finance`) Specification

## Summary

A multi-agent Collaborative Analysis skill that assembles a Finance Planning Team with specialist agents for burn rate
analysis, revenue modeling, and scenario planning. The Team Lead pre-reads all financial data (data-first Phase 1),
distributes a data summary to agents, then synthesizes their findings into a financial model covering base-case,
optimistic, and pessimistic scenarios. A dual-skeptic quality gate (Accuracy Skeptic + Risk Skeptic) ensures all numbers
are traceable and risks are honestly assessed. Output is written to `docs/finance-plans/`. This is the
highest-complexity business skill (Large effort) due to quantitative scenario modeling and multi-source data
dependencies.

## Problem

Early-stage founders make financial decisions — hiring timing, spending priorities, fundraising urgency — based on
back-of-the-envelope calculations or single-point estimates. There is no structured framework for exploring multiple
scenarios, tracing projections to stated assumptions, or honestly assessing financial risk.

Key pain points:

- **Single-point estimates**: Founders project one scenario (usually optimistic) without exploring what happens if
  assumptions fail. Decisions based on one scenario are fragile.
- **Untraceable projections**: Financial numbers lack a clear link to stated assumptions. When an assumption changes
  (revenue timeline slips by 3 months), it's unclear which projections are invalidated.
- **Risk blindness**: Financial risks are acknowledged in passing but not systematically cataloged with mitigations.
  Key-person risk, concentration risk, and milestone-dependency risk are common blind spots.
- **No quality gate**: Unlike code (tested) or investor updates (dual-skeptic reviewed), financial projections go
  unvalidated for internal consistency or completeness.

Evidence:

- P3-12 roadmap item targets this skill as a Large-effort business skill filling the gap between strategic planning
  (plan-sales, plan-marketing) and operational execution.
- The data-dependency ratio is the highest of any business skill — ~70-80% of projections depend on user-provided
  financial data (cash, burn, revenue), making the `_user-data.md` pattern critical.
- The multi-scenario requirement differentiates this from all other business skills. A single-scenario output is a
  defect — the skill's core value is range-based analysis.

## Solution

### Architecture

This is a **multi-agent Collaborative Analysis skill** with a **data-first pipeline modification**. Unlike plan-sales
and plan-marketing (where agents read project data directly), plan-finance adds a Phase 1 where the Team Lead pre-reads
and summarizes all financial data before agents are spawned. This prevents agents from independently reading the same
data and producing inconsistent summaries.

### Agent Team

| Role              | Name                | Model | Responsibility                                                                                   |
| ----------------- | ------------------- | ----- | ------------------------------------------------------------------------------------------------ |
| Team Lead         | (invoking agent)    | opus  | Pre-read financial data, orchestrate phases, synthesize multi-scenario plan, write final output  |
| Burn Rate Analyst | `burn-rate-analyst` | opus  | Analyze current/projected burn rate, cash position, runway                                       |
| Revenue Modeler   | `revenue-modeler`   | opus  | Model revenue growth scenarios from roadmap milestones and user data                             |
| Scenario Planner  | `scenario-planner`  | opus  | Synthesize burn and revenue into base/optimistic/pessimistic scenarios with explicit assumptions |
| Accuracy Skeptic  | `accuracy-skeptic`  | opus  | Verify every number traces to a stated source or assumption. No unsourced projections pass.      |
| Risk Skeptic      | `risk-skeptic`      | opus  | Evaluate completeness of risk identification and realism of mitigations                          |

**All-Opus rationale**: All three analysis agents work with quantitative reasoning — projecting burn rates, modeling
revenue under uncertainty, and constructing scenarios with explicit assumption dependencies. Sonnet risks shallow
scenario construction where assumptions aren't meaningfully varied.

**Data-first rationale**: The Team Lead reads all financial sources (user data, roadmap, prior plans, progress files) in
Phase 1 and produces a Data Summary injected into each agent's spawn prompt. This ensures all agents work from the same
data foundation — critical for a quantitative skill where inconsistent inputs would produce meaningless scenarios.

### Orchestration Protocol

#### Phase 1: Data Collection (Team Lead)

The Team Lead reads:

- `docs/finance-plans/_user-data.md` (cash, burn, MRR, headcount)
- `docs/roadmap/_index.md` and roadmap files (milestone timelines)
- `docs/progress/` files (delivery velocity)
- Prior finance plans in `docs/finance-plans/` (baseline context)

**Output**: A structured Data Summary injected into each agent's spawn prompt in Phase 2.

**Missing data handling**: If `_user-data.md` is missing or empty, Team Lead outputs: "No financial data found —
projections will be low-confidence estimates based on roadmap timelines only" and proceeds with `confidence: "low"`
throughout.

#### Phase 2: Parallel Specialist Analysis

**Agents**: Burn Rate Analyst, Revenue Modeler, Scenario Planner (concurrent via `Agent` tool with
`team_name: "plan-finance"`)

Each agent receives the Team Lead's Data Summary as context and produces a **Domain Brief**:

- **Burn Rate Brief**: Current burn, projected burn, cash position, runway estimates
- **Revenue Model Brief**: Revenue scenarios based on roadmap milestones, growth assumptions
- **Scenario Brief**: Base/optimistic/pessimistic scenarios with numbered assumptions

Each brief is sent to the Team Lead via `SendMessage`.

**Gate 1**: Team Lead verifies all 3 briefs received and complete.

#### Phase 3: Scenario Synthesis (Lead-Driven)

The Team Lead (NOT a spawned agent) writes the Financial Plan Synthesis directly. **Phase 3 is NOT delegate mode.**

The synthesis contains:

- Base-case scenario (most likely outcomes given stated assumptions)
- Optimistic scenario (key upside assumptions realized)
- Pessimistic scenario (key downside risks materialized)
- Scenario Comparison Table
- All assumptions numbered and cross-referenced from projections

**Context management**: Synthesize section by section. Checkpoint progress if context degrades.

**Output**: Draft Finance Plan.

#### Phase 4: Dual-Skeptic Review

**Agents**: Accuracy Skeptic + Risk Skeptic (concurrent)

Both receive the synthesis AND the three Domain Briefs as context.

**Accuracy Skeptic checklist** (6+ items):

1. Every runway figure traces to a burn rate assumption
2. Every revenue projection traces to a stated growth assumption or roadmap milestone
3. Scenario comparison table values match individual scenario sections
4. All assumptions are numbered and each is referenced by at least one projection
5. No metric is asserted with "high" confidence when underlying data is user-estimated or unavailable
6. All `[Requires user input]` placeholders correctly placed in sections lacking user data

**Risk Skeptic checklist** (5+ items):

1. Concentration risk addressed (single customer, channel, or team member dependency)
2. Runway adequacy for the next planned milestone
3. Whether pessimistic scenario is actually pessimistic (not just "slightly worse base case")
4. Whether mitigations are actionable given startup resources (not just "raise more money")
5. Whether key-person risk is addressed

**Review formats**:

- Accuracy Skeptic: `ACCURACY REVIEW: Finance Plan` / `Verdict: APPROVED / REJECTED`
- Risk Skeptic: `RISK REVIEW: Finance Plan` / `Verdict: APPROVED / REJECTED`

If rejected: numbered list with specific claim, why it's wrong, evidence reference, and fix.

**Gate 2**: BOTH must approve. If either rejects → Phase 3b.

**Special checks**:

- Identical numbers across all three scenarios → Accuracy Skeptic flags as potential modeling defect
- Risk without mitigation → Risk Skeptic rejects (every identified risk must have at least one actionable mitigation)
- Pessimistic scenario simultaneously assumes all bad outcomes → Risk Skeptic verifies realism

#### Phase 3b: Revise

Team Lead revises synthesis with ALL rejection feedback. Returns to Gate 2. Maximum 3 cycles before human escalation.

#### Phase 5: Finalize

When both skeptics approve:

1. Write final plan to `docs/finance-plans/{YYYY-MM-DD}-finance-plan.md`
2. Write progress summary to `docs/progress/plan-finance-summary.md`
3. Output the final plan to the user

### User Data Input

**Location**: `docs/finance-plans/_user-data.md`

**Template sections**:

- Cash Position (cash on hand, last updated date)
- Monthly Burn (total, breakdown by category if known)
- Revenue (current MRR/ARR, growth rate, customer count)
- Headcount (team size, cost breakdown by role)
- Upcoming Expenses (known large upcoming costs)
- Additional Context (fundraising plans, pending deals)

**Behavior**:

- If populated: all agents use data via Team Lead's Data Summary
- If partially populated: use what's there, flag gaps
- If missing: create template, output warning, proceed with low-confidence markers

### Output Artifact Format

**Location**: `docs/finance-plans/{YYYY-MM-DD}-finance-plan.md`

**YAML frontmatter**: `type: "finance-plan"`, `generated`, `scenarios: [base, optimistic, pessimistic]`,
`confidence: "high|medium|low"`, `review_status: "approved"`, `approved_by: [accuracy-skeptic, risk-skeptic]`

**Body sections** (in order):

1. Executive Summary
2. Financial Snapshot (current state)
3. Base-Case Scenario (runway, burn assumption, revenue assumption, key events, confidence)
4. Optimistic Scenario (same structure)
5. Pessimistic Scenario (same structure)
6. Scenario Comparison Table (Scenario / Runway / Monthly Burn / Revenue by Month-6 / Key Risk / Confidence)
7. Key Assumptions (numbered, each referenced by projections: e.g., "Runway: 14 months [assumes A1, A3]")
8. Risks & Mitigations
9. Recommended Actions
10. Assumptions & Limitations (mandatory business quality)
11. Confidence Assessment (mandatory business quality — table)
12. Falsification Triggers (mandatory business quality — e.g., "If MRR growth drops below X%, revise optimistic to
    base-case")
13. External Validation Checkpoints (mandatory business quality)

**Scenario completeness**: The output must always contain all three scenarios. A single-scenario output is a defect.

### Arguments

| Argument  | Effect                                                                      |
| --------- | --------------------------------------------------------------------------- |
| (empty)   | Scan for in-progress sessions. If found, resume. Otherwise, start new plan. |
| `status`  | Report on in-progress session without spawning agents.                      |
| `--light` | Analysis agents use Sonnet; both Skeptics remain Opus.                      |

### SKILL.md Structure

The SKILL.md file must contain all required multi-agent sections:

- `## Setup` — directory creation, artifact detection, user-data handling, persona read
- `## Write Safety` — role-scoped progress files, Team Lead-only output writes
- `## Checkpoint Protocol` — standard format with `team: "plan-finance"`, phases:
  `data-collection | analysis | synthesis | review | revision | complete`
- `## Determine Mode` — three states: status, resume, fresh. Resume must distinguish "Phase 1 checkpointed" (skip) from
  "Phase 1 stale" (warn and offer re-run)
- `## Lightweight Mode` — analysis agents → sonnet, skeptics unchanged
- `## Spawn the Team` — TeamCreate + TaskCreate + Agent with team_name
- `## Orchestration Flow` — 5-phase diagram (data-first variant)
- `## Quality Gate` — dual-skeptic, non-negotiable
- `## Failure Recovery` — unresponsive agent, skeptic deadlock, context exhaustion
- `## Shared Principles` — universal-principles markers only (non-engineering)
- `## Communication Protocol` — shared communication-protocol markers
- `## Teammate Spawn Prompts` — full prompts for all 5 teammates with finance-specific checklists
- `## Output Template` — embedded template for the finance plan
- `## User Data Template` — embedded template for `_user-data.md`

### CI Validator Impact

| Validator                 | Impact           | Changes Needed                                                                                                                            |
| ------------------------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `skill-structure.sh`      | Works as-is      | None — standard multi-agent checks                                                                                                        |
| `skill-shared-content.sh` | Extension needed | Add `plan-finance` to non-engineering list. Add `risk-skeptic`/`Risk Skeptic` to B2 normalizer. Verify `accuracy-skeptic` already exists. |
| `sync-shared-content.sh`  | Extension needed | Add `plan-finance` to non-engineering classification list                                                                                 |
| `spec-frontmatter.sh`     | N/A              | Output goes to `docs/finance-plans/`                                                                                                      |
| `progress-checkpoint.sh`  | Works as-is      | Standard format                                                                                                                           |

## Constraints

1. **Non-engineering skill**: Universal Principles only. No Engineering Principles block. Must be added to
   non-engineering lists in both `sync-shared-content.sh` and `skill-shared-content.sh`.
2. **Dual-skeptic gate is non-negotiable**: BOTH Accuracy Skeptic and Risk Skeptic must approve.
3. **Maximum 3 revision cycles**: After 3 rejections, escalate to human operator.
4. **No fabricated projections**: Every quantitative claim requires a stated source or explicit assumption. Agents use
   confidence labels and placeholders when data is absent.
5. **Business quality sections mandatory**: Non-removable under lightweight mode.
6. **Scenario completeness**: Output must always contain all three scenarios (base, optimistic, pessimistic). A
   single-scenario plan is a defect.
7. **Assumption traceability**: Every projection must reference numbered assumptions. Unsourced projections are
   rejection-worthy.
8. **Data-first pipeline**: Team Lead pre-reads financial data in Phase 1 before agents are spawned. Agents work from
   the Team Lead's Data Summary, not independent reads.
9. **Write isolation**: Parallel agents write only to their own progress files. Only Team Lead writes to
   `docs/finance-plans/`.
10. **Pre-revenue handling**: Revenue Modeler produces a zero-revenue baseline and projects first-revenue timeline from
    roadmap milestones rather than refusing to produce a brief.

## Out of Scope

- Live financial data integrations (QuickBooks, Stripe, bank accounts)
- Spreadsheet or model export (CSV, Excel)
- Cap table analysis or equity planning
- Tax planning or accounting advice
- Integration with plan-sales or plan-hiring output artifacts — cross-skill synthesis is manual
- Automated alerting when financial metrics cross thresholds
- Valuation modeling or fundraising term sheet analysis
- Real-time market data via APIs

## Files to Modify

| File                                            | Change                                                                                                       |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `plugins/conclave/skills/plan-finance/SKILL.md` | **Create** — New multi-agent Collaborative Analysis skill with data-first pipeline                           |
| `scripts/sync-shared-content.sh`                | **Modify** — Add `plan-finance` to non-engineering classification list                                       |
| `scripts/validators/skill-shared-content.sh`    | **Modify** — Add `plan-finance` to non-engineering list. Add `risk-skeptic`/`Risk Skeptic` to B2 normalizer. |

## Success Criteria

1. Running `/plan-finance` on a project with populated `_user-data.md` produces a complete 3-scenario finance plan with
   all sections populated and both skeptics approving.
2. Phase 1 (Data Collection) produces a structured Data Summary that is injected into all Phase 2 agent spawn prompts.
3. All three scenarios (base, optimistic, pessimistic) are present in every output with distinct assumptions.
4. Every projection references numbered assumptions (e.g., "Runway: 14 months [assumes A1, A3]").
5. Accuracy Skeptic verifies number traceability, internal consistency, and confidence-level accuracy.
6. Risk Skeptic verifies completeness of risk identification, mitigation realism, and pessimistic scenario honesty.
7. Both skeptics must approve before finalization.
8. `--light` mode uses Sonnet for analysis agents; both Skeptics remain Opus.
9. `status` mode reports session progress without spawning agents.
10. First-run setup creates `docs/finance-plans/` and `_user-data.md` template with data-dependency warning.
11. Output includes all mandatory business quality sections.
12. All 12/12 CI validators pass after creation and sync.
13. Session recovery resumes from last checkpoint, with stale-data warning if Phase 1 checkpoint is >7 days old.
14. Pre-revenue startups receive zero-revenue baseline projections with first-revenue timeline estimates.
15. Scenario Comparison Table values match the individual scenario section values (Accuracy Skeptic verification).
