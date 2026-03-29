---
title: "Customer Success Skill (/plan-customer-success) Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Customer Success (`/plan-customer-success`) Specification

## Summary

A multi-agent Hub-and-Spoke skill that assembles a Customer Success Team with
three specialist agents (Churn Analyst, Onboarding Designer, Expansion Analyst)
reporting to a CS Strategist hub, with a single CS Skeptic quality gate. The CS
Strategist synthesizes specialist findings into a unified CS playbook — the Team
Lead delegates to the Strategist rather than synthesizing directly. Output is a
structured CS playbook written to `docs/cs-plans/`. This is a Medium-effort
skill appropriate for a single skeptic.

## Problem

Early-stage founders handle customer success reactively — responding to churn
after it happens, onboarding by intuition, and missing expansion opportunities
entirely. There is no structured framework for systematically analyzing churn
signals, designing onboarding journeys, or identifying expansion revenue paths.

Key pain points:

- **Reactive churn management**: Founders discover churn when customers cancel.
  Leading indicators go unmonitored because no one has cataloged what to watch.
- **Ad-hoc onboarding**: New users receive the same generic onboarding
  regardless of segment, use case, or contract value. Time-to-first-value is
  unmeasured.
- **Missed expansion revenue**: Upsell and cross-sell opportunities are
  identified anecdotally. No systematic analysis of which customer segments are
  expansion-ready.
- **Overly ambitious playbooks**: Generic CS best practices recommend tooling,
  headcount, and processes that don't fit pre-Series A startups with no
  dedicated CS team.

Evidence:

- P3-15 roadmap item targets this skill as a Medium-effort business skill
  filling the gap between acquisition (plan-sales, plan-marketing) and
  retention/growth.
- The Hub-and-Spoke pattern is appropriate because CS requires a synthesist (CS
  Strategist) to weave three specialist analyses into a coherent playbook —
  unlike plan-sales where the Team Lead holds sufficient context to synthesize
  directly.
- A single CS Skeptic (not dual) is appropriate for the Medium effort level and
  the lower risk profile compared to financial (plan-finance) or strategic
  (plan-marketing) planning.

## Solution

### Architecture

This is a **multi-agent Hub-and-Spoke skill** — three specialist spokes report
to a CS Strategist hub, which produces the synthesis. The Team Lead is in
delegate mode for all phases except final output writing in Phase 4. This
differs from plan-sales and plan-marketing (Collaborative Analysis, where the
Team Lead synthesizes directly).

### Agent Team

| Role                | Name                  | Model  | Responsibility                                                                                  |
| ------------------- | --------------------- | ------ | ----------------------------------------------------------------------------------------------- |
| Team Lead           | (invoking agent)      | opus   | Orchestrate phases, manage transitions, write final output                                      |
| Churn Analyst       | `churn-analyst`       | opus   | Identify leading/lagging churn indicators from product roadmap, support patterns, user feedback |
| Onboarding Designer | `onboarding-designer` | sonnet | Design systematic onboarding journey from sign-up to first value                                |
| Expansion Analyst   | `expansion-analyst`   | sonnet | Identify expansion revenue opportunities aligned with product roadmap                           |
| CS Strategist       | `cs-strategist`       | opus   | Synthesize three specialist briefs into unified CS playbook; revise based on skeptic feedback   |
| CS Skeptic          | `cs-skeptic`          | opus   | Evaluate actionability for early-stage team and honesty of churn risk assessment                |

**Model rationale**: Churn Analyst uses Opus (pattern recognition from ambiguous
signals). Onboarding Designer and Expansion Analyst use Sonnet
(execution-oriented design and identification tasks). CS Strategist uses Opus
(cross-domain synthesis). CS Skeptic uses Opus (always — non-negotiable).

**Hub-and-Spoke rationale**: The CS Strategist synthesizes (not the Team Lead).
CS requires a dedicated synthesist to weave churn signals, onboarding design,
and expansion paths into a coherent playbook. The Team Lead remains in delegate
mode for Phases 1-3 and only writes the final output file in Phase 4.

### Orchestration Protocol

#### Phase 1: Parallel Specialist Analysis

**Agents**: Churn Analyst, Onboarding Designer, Expansion Analyst (concurrent
via `Agent` tool with `team_name: "plan-customer-success"`)

Each agent investigates their domain:

- Read `docs/roadmap/`, `docs/specs/` for product capabilities and planned
  features
- Read `docs/cs-plans/_user-data.md` for customer data
- Read prior CS playbooks in `docs/cs-plans/` for consistency

**Output**: Each produces a **Domain Brief** (Churn Signal Brief, Onboarding
Brief, Expansion Brief) sent to the Team Lead.

**Pre-launch handling**: If no customer data exists, Churn Analyst produces a
"Pre-Launch Risk Factors" brief covering signals to watch from day one.
Onboarding Designer and Expansion Analyst adapt to pre-launch context (first 10
customers, not scale).

**Gate 1**: Team Lead verifies all 3 briefs received and complete.

#### Phase 2: Strategist Synthesis

**Agent**: CS Strategist (spawned with all three Domain Briefs as context)

The CS Strategist produces a **CS Playbook Draft** containing all output
sections. Convergent findings across analysts are highlighted as high-confidence
signals. Conflicting findings are surfaced as tensions to resolve.

**Output**: CS Playbook Draft sent to the Team Lead.

#### Phase 3: Skeptic Review

**Agent**: CS Skeptic (spawned with Playbook Draft as context)

**CS Skeptic checklist** (6+ items):

1. Whether churn signals are specific enough to measure with tools a startup
   realistically has
2. Whether the onboarding journey has clear stage exits and success criteria
3. Whether the 90-day action plan is achievable given the Team Capacity
   Assessment
4. Whether expansion opportunities are appropriately hedged (no fabricated
   revenue projections)
5. Whether the plan acknowledges what it doesn't know about the customer base
6. Whether "pre-launch" vs. "established" product state is correctly reflected
   throughout

**Review format**: `CS REVIEW: Customer Success Playbook` /
`Verdict: APPROVED / REJECTED`

If rejected: numbered issues with specific section, why it fails the checklist
item, and what a correct version looks like.

**Gate 2**: CS Skeptic must approve. If rejected → CS Strategist is re-spawned
with rejection feedback for revision. Maximum 3 cycles before human escalation.

**Special checks**:

- Playbook recommends hiring a dedicated CSM: skeptic flags as potentially
  infeasible for pre-Series A unless headcount budget confirmed in
  `_user-data.md`
- Health scoring requires engineering not on roadmap: skeptic flags as
  dependency risk, requests simpler proxy
- Approved with minor observations: observations go into Assumptions &
  Limitations section, don't block finalization

#### Phase 4: Finalize

When CS Skeptic approves:

1. Team Lead writes final playbook to
   `docs/cs-plans/{YYYY-MM-DD}-cs-playbook.md`
2. Team Lead writes progress summary to
   `docs/progress/plan-customer-success-summary.md`
3. Output the final playbook to the user

### User Data Input

**Location**: `docs/cs-plans/_user-data.md`

**Template sections**:

- Customer Count (current, growth rate if known)
- Average Contract Value (ACV, range if variable)
- Churn Rate (if known, time period)
- NPS/CSAT Data (scores, survey frequency)
- Known Support Pain Points (top issues, volume)
- Team Members Available for CS Work (names/roles, hours/week)
- Additional Context (product stage, customer segments)

**Behavior**:

- If populated: agents use data alongside project artifacts
- If partially populated: use available data, flag gaps
- If missing: create template, output message, proceed with low-confidence
  markers

### Output Artifact Format

**Location**: `docs/cs-plans/{YYYY-MM-DD}-cs-playbook.md`

**YAML frontmatter**: `type: "cs-playbook"`, `generated`,
`confidence: "high|medium|low"`, `review_status: "approved"`,
`approved_by: [cs-skeptic]`

**Body sections** (in order):

1. Executive Summary
2. Customer Health Indicators (table: Indicator / Signal Type (leading/lagging)
   / Measurement Method / Threshold / Action Trigger)
3. Churn Signal Catalog (or "Pre-Launch Risk Factors" for pre-launch products)
4. Onboarding Journey Map (stages with clear exit criteria and success metrics)
5. Expansion Opportunity Matrix (table: Opportunity Type / Customer Segment /
   Trigger Condition / Estimated Revenue Impact with confidence level)
6. 90-Day Action Plan (Action / Owner (role) / Timeline (day 1-30, 31-60, 61-90)
   / Effort (hours) / Expected Outcome)
7. Success Metrics (time-bound, measurable)
8. Team Capacity Assessment
9. Assumptions & Limitations (mandatory business quality)
10. Confidence Assessment (mandatory business quality — table)
11. Falsification Triggers (mandatory business quality)
12. External Validation Checkpoints (mandatory business quality)

**Pre-launch adaptations**:

- Churn Signal Catalog → "Pre-Launch Risk Factors"
- Team Capacity Assessment defaults to "founding team"
- 90-Day Action Plan focuses on onboarding first 10 customers
- Expansion Opportunity Matrix shows "No expansion paths identified" if
  single-product, single-tier

### Arguments

| Argument  | Effect                                                                                                                                     |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| (empty)   | Scan for in-progress sessions. If found, resume. Otherwise, start new playbook.                                                            |
| `status`  | Report on in-progress session without spawning agents.                                                                                     |
| `--light` | `churn-analyst` → sonnet (already sonnet for onboarding-designer, expansion-analyst). `cs-strategist` → sonnet. `cs-skeptic` remains Opus. |

**Lightweight mode note**: `onboarding-designer` and `expansion-analyst` are
already Sonnet in standard mode. Lightweight mode has no additional effect on
these agents.

### SKILL.md Structure

The SKILL.md file must contain all required multi-agent sections:

- `## Setup` — directory creation, artifact detection, user-data handling,
  persona read
- `## Write Safety` — role-scoped progress files, Team Lead-only output writes
- `## Checkpoint Protocol` — standard format with
  `team: "plan-customer-success"`, phases:
  `research | synthesis | review | revision | complete`
- `## Determine Mode` — three states: status, resume, fresh
- `## Lightweight Mode` — churn-analyst and cs-strategist → sonnet, skeptic
  unchanged
- `## Spawn the Team` — TeamCreate + TaskCreate + Agent with team_name
- `## Orchestration Flow` — 4-phase Hub-and-Spoke diagram showing spokes → hub →
  gate → output
- `## Quality Gate` — single CS Skeptic, non-negotiable
- `## Failure Recovery` — unresponsive agent, skeptic deadlock (3 cycles),
  context exhaustion
- `## Shared Principles` — universal-principles markers only (non-engineering)
- `## Communication Protocol` — shared communication-protocol markers
- `## Teammate Spawn Prompts` — full prompts for all 5 teammates
- `## Output Template` — embedded template for the CS playbook
- `## User Data Template` — embedded template for `_user-data.md`

### CI Validator Impact

| Validator                 | Impact           | Changes Needed                                                                                       |
| ------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------- |
| `skill-structure.sh`      | Works as-is      | None — standard multi-agent checks                                                                   |
| `skill-shared-content.sh` | Extension needed | Add `plan-customer-success` to non-engineering list. Add `cs-skeptic`/`CS Skeptic` to B2 normalizer. |
| `sync-shared-content.sh`  | Extension needed | Add `plan-customer-success` to non-engineering classification list                                   |
| `spec-frontmatter.sh`     | N/A              | Output goes to `docs/cs-plans/`                                                                      |
| `progress-checkpoint.sh`  | Works as-is      | Standard format                                                                                      |

## Constraints

1. **Non-engineering skill**: Universal Principles only. No Engineering
   Principles block. Must be added to non-engineering lists in both
   `sync-shared-content.sh` and `skill-shared-content.sh`.
2. **Single CS Skeptic gate is non-negotiable**: CS Skeptic must approve before
   finalization.
3. **Maximum 3 revision cycles**: After 3 rejections, escalate to human
   operator.
4. **No prescriptive tooling**: The playbook recommends process, not specific
   software. Tools are referenced as examples only, clearly labeled.
5. **Business quality sections mandatory**: Non-removable under lightweight
   mode.
6. **Pre-launch adaptation**: All sections must produce meaningful output even
   with zero customers. Agents check for customer data before attempting
   analysis.
7. **No fabricated revenue projections**: Expansion Opportunity Matrix uses
   estimated revenue impact with confidence levels, not precise numbers.
8. **Write isolation**: Parallel agents write only to their own progress files.
   Only Team Lead writes to `docs/cs-plans/`.
9. **Hub-and-Spoke pattern**: CS Strategist synthesizes, not the Team Lead. Team
   Lead is in delegate mode for Phases 1-3.
10. **Shared content uses markers**: Synced via `sync-shared-content.sh`, with
    skeptic name normalization for `cs-skeptic`.

## Out of Scope

- Customer support ticket triage or automated routing
- NPS survey design or distribution
- Integration with CRM tools (Salesforce, HubSpot) or ticketing systems
  (Zendesk, Intercom)
- Customer segmentation analysis (covered by research-market)
- Post-churn win-back campaign design
- SLA definition or service tier structuring
- Integration with plan-sales output — cross-skill synthesis is manual
- Changes to existing skills — plan-customer-success is additive only

## Files to Modify

| File                                                     | Change                                                                                                            |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-customer-success/SKILL.md` | **Create** — New multi-agent Hub-and-Spoke skill definition                                                       |
| `scripts/sync-shared-content.sh`                         | **Modify** — Add `plan-customer-success` to non-engineering classification list                                   |
| `scripts/validators/skill-shared-content.sh`             | **Modify** — Add `plan-customer-success` to non-engineering list. Add `cs-skeptic`/`CS Skeptic` to B2 normalizer. |

## Success Criteria

1. Running `/plan-customer-success` on a project with populated `_user-data.md`
   produces a complete CS playbook with all sections populated and CS Skeptic
   approving.
2. Hub-and-Spoke pattern executes: 3 specialists produce Domain Briefs (Phase
   1), CS Strategist synthesizes (Phase 2), CS Skeptic reviews (Phase 3).
3. CS Skeptic verifies actionability, honesty, pre-launch/established state
   correctness, and resource feasibility.
4. CS Skeptic must approve before finalization.
5. `--light` mode downgrades churn-analyst and cs-strategist to Sonnet;
   cs-skeptic remains Opus; onboarding-designer and expansion-analyst are
   already Sonnet.
6. `status` mode reports session progress without spawning agents.
7. First-run setup creates `docs/cs-plans/` and `_user-data.md` template.
8. Output includes all mandatory business quality sections.
9. All 12/12 CI validators pass after creation and sync.
10. Session recovery resumes from last checkpoint without losing completed work.
11. Pre-launch products receive adapted output (Pre-Launch Risk Factors,
    first-10-customer focus) without errors.
12. Expansion Opportunity Matrix uses estimated revenue impact with confidence
    levels, not fabricated projections.
13. 90-Day Action Plan specifies owner (role), timeline, effort, and expected
    outcome for each action.
14. No specific software tools are recommended as requirements — only as labeled
    examples.
