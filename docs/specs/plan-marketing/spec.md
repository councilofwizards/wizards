---
title: "Marketing Planning Skill (/plan-marketing) Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Marketing Planning (`/plan-marketing`) Specification

## Summary

A multi-agent Collaborative Analysis skill that assembles a Marketing Strategy
Team of parallel analysis agents — covering positioning, channel strategy, and
content strategy — who cross-reference each other's findings and produce a
synthesis reviewed through dual-skeptic validation. Output is a structured
marketing plan artifact written to `docs/marketing-plans/`. The skill follows
the Collaborative Analysis pattern established by `plan-sales`.

## Problem

Early-stage founders make marketing decisions reactively — choosing channels
based on familiarity, positioning based on instinct, and content based on
whatever feels urgent. There is no structured framework for evaluating whether
positioning aligns with channel choices, whether channel choices fit resource
constraints, or whether content strategy reinforces the overall positioning.

Key pain points:

- **No cross-domain analysis**: Positioning, channels, and content are evaluated
  independently. A channel strategy that contradicts the positioning wastes
  effort.
- **Hidden assumptions about reach**: Founders assume channels will reach their
  target audience without validating the assumption against segment data.
- **Resource-blind planning**: Marketing plans designed for well-funded teams
  get applied to pre-revenue startups with a founder doing marketing part-time.
- **No quality gate for marketing strategy**: Unlike code (tested) or investor
  updates (dual-skeptic reviewed), marketing plans go unquestioned.

Evidence:

- The business skill design guidelines define the Collaborative Analysis pattern
  for `/plan-marketing` with dual-skeptic assignments (Strategy Skeptic +
  Feasibility Skeptic).
- P3-11 roadmap item targets this skill as the third business skill, extending
  the Collaborative Analysis pattern proven by `/plan-sales`.
- Unlike `/plan-sales` which is ~60-70% user-data-driven, marketing planning
  relies on a roughly 50/50 split between project artifacts (roadmap, specs for
  product capabilities) and user-provided data (target segments, budget, brand
  constraints).

## Solution

### Architecture

This is a **multi-agent Collaborative Analysis skill** — parallel investigation
with structured cross-referencing and Team Lead synthesis. It follows the same
5-phase pattern as `/plan-sales`: independent research → cross-referencing →
synthesis → dual-skeptic review → finalize.

### Agent Team

| Role                | Name                  | Model | Responsibility                                                                                     |
| ------------------- | --------------------- | ----- | -------------------------------------------------------------------------------------------------- |
| Team Lead           | (invoking agent)      | opus  | Orchestrate phases, manage transitions, synthesize assessment, write final output                  |
| Positioning Analyst | `positioning-analyst` | opus  | Target segments, value proposition, competitive differentiation                                    |
| Channel Analyst     | `channel-analyst`     | opus  | Acquisition channels, relative ROI/effort per channel, channel-segment alignment                   |
| Content Analyst     | `content-analyst`     | opus  | Content strategy, messaging frameworks, thought-leadership angles                                  |
| Strategy Skeptic    | `strategy-skeptic`    | opus  | Coherence between positioning and channels, differentiation credibility, segment-channel alignment |
| Feasibility Skeptic | `feasibility-skeptic` | opus  | Budget realism, team capacity, timeline realism, dependency risks                                  |

**All-Opus rationale**: All three analysis agents require judgment about market
positioning, audience fit, and resource allocation — reasoning-heavy tasks where
Sonnet risks superficial cross-referencing. Same rationale as plan-sales.

**Lead-driven synthesis rationale**: The Team Lead synthesizes the assessment
directly (no separate Synthesizer). Same rationale as plan-sales — the lead
holds full context from Phases 1-2 and avoids context exhaustion from passing 6
artifacts to a separate agent.

### Collaborative Analysis Protocol

#### Phase 1: Parallel Research

**Agents**: Positioning Analyst, Channel Analyst, Content Analyst (concurrent
via `Agent` tool with `team_name: "plan-marketing"`)

Each agent investigates their domain independently:

- Read `docs/roadmap/`, `docs/specs/`, `docs/architecture/` for product
  capabilities
- Read `docs/marketing-plans/_user-data.md` for user-provided market data
- Read prior marketing plans in `docs/marketing-plans/` for consistency

**Output**: Each produces a **Domain Brief** (Positioning Brief, Channel Brief,
Content Brief) sent to the Team Lead via `SendMessage`.

**Gate 1**: Team Lead verifies all 3 briefs received and complete.

#### Phase 2: Cross-Referencing

**Trigger**: Team Lead distributes all 3 Domain Briefs to all 3 agents. Each
receives the two they did not write.

Each agent reviews the other two briefs for:

1. **Contradictions** — Does another agent's finding conflict with mine?
2. **Gaps** — Does another agent's analysis miss something I found?
3. **Assumptions Challenged** — Does another agent assume something I have
   evidence against?
4. **Synergies** — Do findings across domains reinforce each other?
5. **Answers to Peer Questions** — Respond to the "Questions for Other Analysts"
   section.

**Output**: Each produces a **Cross-Reference Note** sent to the Team Lead.

**Gate 2**: Team Lead verifies all 3 Cross-Reference Notes received.

#### Phase 3: Synthesis (Lead-Driven)

The Team Lead (NOT a spawned agent) writes the Marketing Strategy Synthesis
directly. **Phase 3 is NOT delegate mode.**

Synthesis process:

1. Resolve contradictions — weigh evidence, document reasoning
2. Integrate gap-fills into relevant sections
3. Evaluate challenged assumptions
4. Highlight cross-domain synergies
5. Write the full marketing plan in the output template format

Unresolvable tensions are documented in a "Strategic Tensions" section rather
than silently choosing one position.

**Output**: Draft Marketing Plan.

#### Phase 4: Dual-Skeptic Review

**Agents**: Strategy Skeptic + Feasibility Skeptic (concurrent)

Both receive the draft AND all 6 source artifacts.

**Strategy Skeptic checklist** (5+ items):

1. Coherence between positioning and channel choices
2. Differentiation credibility vs. competitive landscape
3. Alignment between target segments and channel reach
4. Whether success metrics are achievable given stated resources
5. Whether the plan acknowledges what it doesn't know

**Feasibility Skeptic checklist** (4+ items):

1. Budget realism for selected channels
2. Team capacity to execute the 90-day plan
3. Timeline realism
4. Dependency risks (e.g., requires product feature not yet built)

**Gate 3**: BOTH skeptics must return `Verdict: APPROVED`. If either rejects →
Phase 3b.

**Review format**:

- Strategy Skeptic: `STRATEGY REVIEW: Marketing Plan Synthesis` /
  `Verdict: APPROVED / REJECTED`
- Feasibility Skeptic: `FEASIBILITY REVIEW: Marketing Plan Synthesis` /
  `Verdict: APPROVED / REJECTED`

If rejected: numbered list where each issue includes the specific claim, why
it's problematic, and what a correct version would look like.

#### Phase 3b: Revise

Team Lead revises synthesis incorporating ALL rejection feedback from both
skeptics. Returns to Gate 3. Maximum 3 revision cycles before escalation to
human operator.

#### Phase 5: Finalize

When both skeptics approve:

1. Write final plan to `docs/marketing-plans/{YYYY-MM-DD}-marketing-plan.md`
2. Write progress summary to `docs/progress/plan-marketing-summary.md`
3. Output the final plan to the user

### User Data Input

**Location**: `docs/marketing-plans/_user-data.md`

**Template sections**:

- Target Customer (description, segments, ICP)
- Existing Marketing Efforts (channels in use, what's working/not)
- Budget (monthly/quarterly, allocation preferences)
- Team Capacity (hours/week available for marketing)
- Brand Constraints (existing guidelines, tone, positioning mandates)
- Additional Context (free-form)

**Behavior**:

- If `_user-data.md` exists and is populated: agents read alongside project data
- If partially populated: agents use available data, flag gaps
- If missing: sections use
  `[Requires user input — see docs/marketing-plans/_user-data.md]` placeholder.
  Skill creates template on first run.

### Output Artifact Format

**Location**: `docs/marketing-plans/{YYYY-MM-DD}-marketing-plan.md`

**YAML frontmatter**: `type: "marketing-plan"`, `generated`,
`confidence: "high|medium|low"`, `review_status: "approved"`,
`approved_by: [strategy-skeptic, feasibility-skeptic]`

**Body sections** (in order):

1. Executive Summary
2. Target Segments
3. Positioning Statement
4. Competitive Differentiation
5. Channel Strategy (table: Channel / Priority / Effort / Expected ROI —
   qualitative, no fabricated numbers)
6. Content Strategy
7. 90-Day Focus
8. Success Metrics (time-bound, measurable, sourced from roadmap or
   \_user-data.md)
9. Resource Constraints
10. Assumptions & Limitations (mandatory business quality)
11. Confidence Assessment (mandatory business quality — table)
12. Falsification Triggers (mandatory business quality)
13. External Validation Checkpoints (mandatory business quality)

**Version handling**: If a plan exists for the same date, append `-v2`, `-v3`
suffix.

### Arguments

| Argument  | Effect                                                                            |
| --------- | --------------------------------------------------------------------------------- |
| (empty)   | Scan for in-progress sessions. If found, resume. Otherwise, start new assessment. |
| `status`  | Report on in-progress session without spawning agents.                            |
| `--light` | Analysis agents use Sonnet; both Skeptics remain Opus.                            |

### SKILL.md Structure

The SKILL.md file must contain all required multi-agent sections:

- `## Setup` — directory creation, artifact detection, user-data handling,
  persona read
- `## Write Safety` — role-scoped progress files, Team Lead-only output writes
- `## Checkpoint Protocol` — standard format with `team: "plan-marketing"`,
  phases:
  `research | cross-reference | synthesis | review | revision | complete`
- `## Determine Mode` — three states: status, resume, fresh
- `## Lightweight Mode` — analysis agents → sonnet, skeptics unchanged
- `## Spawn the Team` — TeamCreate + TaskCreate + Agent with team_name
- `## Orchestration Flow` — 5-phase diagram matching plan-sales format
- `## Quality Gate` — dual-skeptic, non-negotiable
- `## Failure Recovery` — unresponsive agent, skeptic deadlock, context
  exhaustion
- `## Shared Principles` — universal-principles markers only (non-engineering)
- `## Communication Protocol` — shared communication-protocol markers
- `## Teammate Spawn Prompts` — full prompts for all 5 teammates
- `## Output Template` — embedded template for the marketing plan
- `## User Data Template` — embedded template for `_user-data.md`

### CI Validator Impact

| Validator                 | Impact           | Changes Needed                                                                                                                                                                                     |
| ------------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `skill-structure.sh`      | Works as-is      | None — standard multi-agent checks                                                                                                                                                                 |
| `skill-shared-content.sh` | Extension needed | Add `plan-marketing` to non-engineering list. Add skeptic name pairs: `strategy-skeptic`/`Strategy Skeptic` (may already exist from plan-sales), `feasibility-skeptic`/`Feasibility Skeptic` (new) |
| `sync-shared-content.sh`  | Extension needed | Add `plan-marketing` to non-engineering classification list                                                                                                                                        |
| `spec-frontmatter.sh`     | N/A              | Output goes to `docs/marketing-plans/`                                                                                                                                                             |
| `progress-checkpoint.sh`  | Works as-is      | Standard format                                                                                                                                                                                    |
| `artifact-templates.sh`   | N/A              | No new artifact template needed                                                                                                                                                                    |

## Constraints

1. **Non-engineering skill**: Universal Principles only. No Engineering
   Principles block. Must be explicitly added to non-engineering lists in
   `sync-shared-content.sh` and `skill-shared-content.sh`.
2. **Dual-skeptic gate is non-negotiable**: BOTH Strategy Skeptic and
   Feasibility Skeptic must approve. No shortcuts.
3. **Maximum 3 revision cycles**: After 3 rejections, escalate to human
   operator.
4. **No fabricated metrics**: Channel ROI must be qualitative. Success metrics
   must cite a source (roadmap or user data). No invented market sizing,
   CAC/LTV, or competitor details.
5. **Business quality sections mandatory**: Assumptions & Limitations,
   Confidence Assessment, Falsification Triggers, External Validation
   Checkpoints must appear in every output — not removable under lightweight
   mode.
6. **Cross-referencing must be substantive**: Agents must engage with peers'
   findings. A report claiming nothing to report is suspect.
7. **Disagreements are preserved through synthesis**: Both sides documented with
   resolution reasoning.
8. **Shared content uses markers**: Synced via `sync-shared-content.sh`,
   byte-identical to authoritative source (with skeptic name normalization).
9. **Write isolation**: Parallel agents write only to their own progress files.
   Only Team Lead writes to `docs/marketing-plans/`.

## Out of Scope

- Automated execution of marketing campaigns or channel integrations
- Brand asset generation (logos, copy templates, visual identity)
- Marketing automation tool configuration or integrations
- Integration with plan-sales output (cross-referencing is manual)
- A/B test design or experiment frameworks (future P3-19)
- Changes to existing skills — plan-marketing is additive only
- Real-time market data via APIs

## Files to Modify

| File                                              | Change                                                                                                                                                                                 |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-marketing/SKILL.md` | **Create** — New multi-agent Collaborative Analysis skill definition                                                                                                                   |
| `scripts/sync-shared-content.sh`                  | **Modify** — Add `plan-marketing` to non-engineering classification list                                                                                                               |
| `scripts/validators/skill-shared-content.sh`      | **Modify** — Add `plan-marketing` to non-engineering list. Add `feasibility-skeptic`/`Feasibility Skeptic` to B2 normalizer (verify `strategy-skeptic` already exists from plan-sales) |

## Success Criteria

1. Running `/plan-marketing` on a project with populated `_user-data.md`
   produces a complete marketing plan with all sections populated and both
   skeptics approving.
2. The Collaborative Analysis protocol executes: 3 agents produce Domain Briefs
   (Phase 1), cross-reference findings (Phase 2), and Team Lead synthesizes
   (Phase 3).
3. Cross-Reference Notes contain substantive engagement — contradictions, gaps,
   challenges, or synergies identified.
4. Strategy Skeptic verifies coherence, differentiation credibility,
   segment-channel alignment, and metric achievability.
5. Feasibility Skeptic verifies budget realism, team capacity, timeline realism,
   and dependency risks.
6. Both skeptics must approve before finalization.
7. `--light` mode uses Sonnet for analysis agents; both Skeptics remain Opus.
8. `status` mode reports session progress without spawning agents.
9. First-run setup creates `docs/marketing-plans/` and `_user-data.md` template.
10. Output includes all mandatory business quality sections.
11. All 12/12 CI validators pass after creation and sync.
12. Session recovery resumes from last checkpoint without losing completed work.
13. On first run without user data, the skill completes with low-confidence
    markers and prominent data-dependency warnings.
14. Channel Strategy table uses qualitative ROI — no fabricated numerical
    projections.
