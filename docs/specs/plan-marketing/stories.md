---
type: "user-stories"
feature: "plan-marketing"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-11-plan-marketing.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Marketing Planning Skill (P3-11)

## Epic Summary

Add a `/plan-marketing` skill to the conclave plugin. The skill assembles a Marketing Strategy Team of parallel analysis
agents — covering positioning, channel strategy, and content strategy — that cross-reference each other's findings and
produce a synthesis reviewed through dual-skeptic validation. Output is a structured marketing plan artifact written to
`docs/marketing-plans/`. The skill follows the Collaborative Analysis pattern established by `plan-sales`.

## Stories

---

### Story 1: SKILL.md File Creation and Validator Compliance

- **As a** skill author adding the plan-marketing skill
- **I want** a valid `plugins/conclave/skills/plan-marketing/SKILL.md` that passes all A-series validators
- **So that** the skill is discoverable by the marketplace, structurally sound, and consistent with all other
  multi-agent business skills in the plugin
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `plugins/conclave/skills/plan-marketing/` directory exists, when `SKILL.md` is created, then its YAML
     frontmatter contains: `name: plan-marketing`, `description` (one-sentence summary ending with a period), and
     `argument-hint: "[--light] [status | (empty for new assessment)]"` — matching the plan-sales pattern
  2. Given the SKILL.md file, when A1 (frontmatter) validation runs, then all required frontmatter fields are present
     and no unknown fields exist
  3. Given the SKILL.md file, when A2 (sections) validation runs, then all required multi-agent sections exist:
     `## Setup`, `## Write Safety`, `## Checkpoint Protocol`, `## Determine Mode`, `## Lightweight Mode`,
     `## Spawn the Team`, `## Orchestration Flow`, `## Quality Gate`, `## Failure Recovery`,
     `## Teammate Spawn Prompts`, `## Shared Principles`, and `## Communication Protocol`
  4. Given the SKILL.md file, when A3 (spawn definitions) validation runs, then every teammate block contains both a
     `**Name**:` and a `**Model**:` field
  5. Given the SKILL.md file, when A4 (shared content markers) validation runs, then the file contains
     `<!-- BEGIN SHARED: universal-principles -->` and `<!-- END SHARED: universal-principles -->` markers; since
     plan-marketing is a non-engineering skill, it must NOT contain engineering-principles markers
  6. Given `bash scripts/validate.sh`, when run after the file is created and shared content is synced, then all 12/12
     validators pass
  7. Given `bash scripts/sync-shared-content.sh`, when run, then the skill is recognized as non-engineering and receives
     only the Universal Principles block (not Engineering Principles)

- **Edge Cases**:
  - SKILL.md created but `sync-shared-content.sh` not yet run: A4 (B2) drift check fails — this is expected and expected
    to be resolved by running the sync script before committing
  - `plan-marketing` not in the skill classification list in `sync-shared-content.sh`: script logs a WARN and defaults
    to engineering classification — the skill must be explicitly added to the non-engineering list

- **Notes**: Reference `plugins/conclave/skills/plan-sales/SKILL.md` for the header pattern, Setup section structure,
  Write Safety conventions, Checkpoint Protocol format, and Determine Mode logic. The `plan-marketing` skill must be
  added to the non-engineering skills list in both `scripts/sync-shared-content.sh` and
  `scripts/validators/skill-shared-content.sh` (the B2 normalizer). Check the B2 normalizer's skeptic name pairs list —
  two new pairs will be needed for the plan-marketing skeptics.

---

### Story 2: Agent Team Composition

- **As a** founder invoking `/plan-marketing`
- **I want** a team of three parallel analysis agents covering positioning, channel strategy, and content strategy, plus
  a dual-skeptic quality gate
- **So that** every marketing plan receives independent expert analysis across all three strategic dimensions before
  synthesis, avoiding the blind spots of a single generalist agent
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Spawn the Team` section, when it is read, then it defines exactly five teammates:
     `positioning-analyst`, `channel-analyst`, `content-analyst`, `strategy-skeptic`, and `feasibility-skeptic`
  2. Given the `positioning-analyst` definition, when it is read, then `**Model**: opus` is specified and its Tasks
     field describes: "Analyze product positioning, target segments, value proposition, and competitive differentiation.
     Produce Positioning Domain Brief."
  3. Given the `channel-analyst` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Identify viable acquisition channels for the product and stage, estimate relative ROI and effort per
     channel. Produce Channel Domain Brief."
  4. Given the `content-analyst` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Recommend content strategy, messaging frameworks, and thought-leadership angles. Produce Content Domain
     Brief."
  5. Given the `strategy-skeptic` definition, when it is read, then `**Model**: opus` is specified and its Tasks field
     describes: "Evaluate whether the marketing synthesis is coherent, differentiated, and consistent with the product
     strategy."
  6. Given the `feasibility-skeptic` definition, when it is read, then `**Model**: opus` is specified and its Tasks
     field describes: "Evaluate whether the marketing plan is executable with early-stage resources — budget, team size,
     and timeline realism."
  7. Given lightweight mode (`--light`), when the skill runs, then all three analysis agents use `sonnet` instead of
     `opus`; both skeptics remain `opus` unchanged

- **Edge Cases**:
  - A3 validator checks Name + Model only — if a teammate block is missing either field, the validator fails; ensure
    both fields are present even if the spawn prompt is minimal during drafting
  - Skeptic model downgraded to sonnet: this violates the non-negotiable skeptic rule — both skeptics must always be
    opus; lightweight mode explicitly does NOT apply to skeptics

- **Notes**: Teammate names must be lowercase and hyphen-separated (matching the Write Safety convention
  `docs/progress/plan-marketing-{role}.md`). The dual-skeptic pattern with Strategy + Feasibility mirrors plan-hiring's
  dual-skeptic approach (Growth Skeptic + Culture Skeptic) — reference `plugins/conclave/skills/plan-hiring/SKILL.md`
  for the spawn definition format.

---

### Story 3: Orchestration Flow — Collaborative Analysis Pattern

- **As a** Marketing Strategy Team Lead
- **I want** the orchestration flow to run three parallel analysis phases, a cross-reference phase, a synthesis phase I
  write myself, and a dual-skeptic review cycle
- **So that** the final marketing plan incorporates independent analysis from all three domains, surfaced tensions are
  resolved explicitly, and no plan is finalized without skeptic sign-off
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Orchestration Flow` section, when it is read, then it defines five sequential phases: Phase 1
     (Parallel Research), Phase 2 (Cross-Reference), Phase 3 (Synthesis — lead writes directly), Phase 4 (Dual-Skeptic
     Review), Phase 5 (Finalize)
  2. Given Phase 1, when it runs, then `positioning-analyst`, `channel-analyst`, and `content-analyst` are spawned
     concurrently via `Agent` tool with `team_name: "plan-marketing"`; each produces a Domain Brief sent to the Team
     Lead via `SendMessage`
  3. Given Phase 2, when it runs, then each analyst receives the other two analysts' Domain Briefs and produces a
     cross-reference note identifying: agreements, contradictions, gaps, and integration opportunities; these notes are
     sent to the Team Lead
  4. Given Phase 3, when it runs, then the Team Lead (NOT a spawned agent) writes the Marketing Strategy Synthesis
     directly, incorporating all Domain Briefs and cross-reference notes; the orchestration instructions must explicitly
     state "Phase 3 is NOT delegate mode"
  5. Given Phase 4, when it runs, then `strategy-skeptic` and `feasibility-skeptic` are spawned concurrently and each
     independently reviews the synthesis; BOTH must return `Verdict: APPROVED` before Phase 5 can proceed
  6. Given a skeptic rejection in Phase 4, when it occurs, then the Team Lead revises the synthesis incorporating ALL
     rejection feedback from both skeptics, then returns to Phase 4 (max 3 cycles before human escalation)
  7. Given Phase 5, when it runs, then the Team Lead writes the final marketing plan to
     `docs/marketing-plans/{date}-marketing-plan.md` and writes a progress summary to
     `docs/progress/plan-marketing-summary.md`

- **Edge Cases**:
  - One analyst becomes unresponsive in Phase 1: Team Lead re-spawns that agent with the task context re-provided; the
    other two analysts' briefs are preserved and used as-is
  - Contradictions between analysts cannot be resolved in Phase 3: Team Lead explicitly documents the unresolved tension
    in the synthesis under a "Strategic Tensions" section rather than silently choosing one position; skeptics are
    informed via the synthesis text
  - Both skeptics reject on the same grounds: treated as a single round; Lead revises once addressing the shared concern
  - Skeptic deadlock (same issue rejected 3 times): Team Lead escalates to human operator with a summary of all
    submissions and rejection rationales — same protocol as plan-sales

- **Notes**: The Collaborative Analysis pattern differs from Hub-and-Spoke: the Team Lead synthesizes in Phase 3 rather
  than delegating to a dedicated Synthesizer agent. This is the same pattern used in plan-sales. Reference the
  plan-sales `## Orchestration Flow` ASCII diagram format — plan-marketing should include an equivalent diagram showing
  the 5 phases and gate positions.

---

### Story 4: Output Artifact Format

- **As a** founder reviewing the marketing plan output
- **I want** a structured markdown file in `docs/marketing-plans/` with YAML frontmatter and defined sections covering
  positioning, channels, content strategy, goals, and constraints
- **So that** the plan is machine-readable by downstream skills, human-reviewable at a glance, and consistent with other
  business skill output artifacts (investor updates, sales plans)
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Output Template` section of SKILL.md, when the plan is finalized, then the output file is written to
     `docs/marketing-plans/{YYYY-MM-DD}-marketing-plan.md`
  2. Given the output file YAML frontmatter, when it is validated, then it contains: `type: "marketing-plan"`,
     `generated: "{YYYY-MM-DD}"`, `confidence: "high|medium|low"`, `review_status: "approved"`,
     `approved_by: [strategy-skeptic, feasibility-skeptic]`
  3. Given the output file body, when it is read, then it contains these sections in order: Executive Summary, Target
     Segments, Positioning Statement, Competitive Differentiation, Channel Strategy (table with Channel / Priority /
     Effort / Expected ROI columns), Content Strategy, 90-Day Focus, Success Metrics, Resource Constraints, Assumptions
     & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints
  4. Given the Channel Strategy table, when it is populated, then each row specifies: channel name, priority
     (high/medium/low), effort level (high/medium/low), and qualitative expected ROI — not fabricated numerical
     projections
  5. Given the Success Metrics section, when it is populated, then every metric is time-bound and measurable (e.g., "100
     email subscribers by day 30") and sourced from either the product roadmap or \_user-data.md
  6. Given `docs/marketing-plans/_user-data.md` does not exist, when the skill runs for the first time, then it creates
     the file using the User Data Template embedded in SKILL.md and outputs the creation message to the user: "Created
     docs/marketing-plans/\_user-data.md — fill in your target segments, existing channels, and budget constraints
     before the next run."
  7. Given sections that require user data (budget, existing brand guidelines), when \_user-data.md is empty, then those
     sections use the placeholder `[Requires user input — see docs/marketing-plans/_user-data.md]`

- **Edge Cases**:
  - `docs/marketing-plans/` directory does not exist: Setup step creates it along with a `.gitkeep` file
  - A previous marketing plan exists for the same date: output file is appended with `-v2`, `-v3` suffix to prevent
    silent overwrite
  - Confidence level is "low" (insufficient product/market data): Executive Summary includes a prominent warning that
    the plan requires validation before acting on

- **Notes**: The mandatory business quality sections (Assumptions & Limitations, Confidence Assessment, Falsification
  Triggers, External Validation Checkpoints) are required in ALL business skill outputs — see
  `draft-investor-update/SKILL.md` Output Template for the established format. plan-marketing must follow the same
  pattern. The User Data Template should prompt for: target customer description, existing marketing efforts, budget
  range, team capacity (hours/week), and known brand constraints.

---

### Story 5: Skeptic Quality Gates

- **As a** Strategy Skeptic or Feasibility Skeptic reviewing the marketing synthesis
- **I want** a structured checklist embedded in my spawn prompt and a defined approval/rejection format
- **So that** my reviews are systematic, actionable, and consistent — not subjective opinions that vary by invocation
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Strategy Skeptic's spawn prompt, when it is read, then it includes a numbered checklist of at least 5
     items covering: (a) coherence between positioning and channel choices, (b) differentiation credibility vs.
     competitive landscape, (c) alignment between target segments and channel reach, (d) whether success metrics are
     achievable given stated resources, (e) whether the plan acknowledges what it doesn't know
  2. Given the Feasibility Skeptic's spawn prompt, when it is read, then it includes a numbered checklist of at least 4
     items covering: (a) budget realism for selected channels, (b) team capacity to execute the 90-day plan, (c)
     timeline realism, (d) dependency risks (e.g., requires product feature not yet built)
  3. Given a skeptic review, when it is complete, then the output follows the format:
     `STRATEGY REVIEW: Marketing Plan Synthesis` (or `FEASIBILITY REVIEW:`), `Verdict: APPROVED / REJECTED`, and if
     rejected, a numbered list where each issue includes: specific claim, why it's problematic, and what a correct
     version would look like
  4. Given both skeptics approve, when Phase 5 begins, then the Team Lead writes the final plan with
     `review_status: "approved"` and both skeptic names in `approved_by`
  5. Given the Communication Protocol's `<!-- BEGIN SHARED: communication-protocol -->` block, when the skeptic reviews
     a plan, then the skeptic sends verdicts to both the Drafter (Team Lead in this context) AND the Team Lead using
     `SendMessage` — not direct file writes
  6. Given the skeptic spawn prompts, when they are read, then both instruct: "You MUST be explicitly asked to review
     something. Don't self-assign review tasks." — matching the pattern in draft-investor-update

- **Edge Cases**:
  - Feasibility Skeptic approves but Strategy Skeptic rejects: revision is required; BOTH verdicts must be APPROVED —
    one approval does not advance to Phase 5
  - Skeptic provides approval with minor observations: plan proceeds to Phase 5; observations are noted in the
    `## Assumptions & Limitations` section of the output artifact
  - Contradictory feedback between skeptics (Strategy says add channels, Feasibility says cut channels): Team Lead
    surfaces the contradiction to the user in the progress summary and documents the chosen resolution in the output
    artifact

- **Notes**: The skeptic spawn prompts must include the full Communication Protocol shared content block (injected by
  sync-shared-content.sh). The skeptic name substitution in the B2 normalizer requires adding two new pairs:
  `strategy-skeptic` / `Strategy Skeptic` and `feasibility-skeptic` / `Feasibility Skeptic`. Verify the normalizer
  handles these before running validation.

---

### Story 6: Session Recovery and Status Mode

- **As a** founder who interrupted a `/plan-marketing` session mid-run
- **I want** the skill to detect incomplete checkpoints on re-invocation and resume from the last known state
- **So that** I don't lose analyst work or have to restart the full 5-phase pipeline when a session is interrupted by a
  context limit, error, or deliberate pause
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given `$ARGUMENTS` is `"status"`, when the skill is invoked, then the Team Lead reads all `docs/progress/` files
     with `team: "plan-marketing"` in their frontmatter and outputs a formatted status summary; no agents are spawned
  2. Given `$ARGUMENTS` is empty and no incomplete checkpoints exist, when the skill is invoked, then a fresh assessment
     begins from Phase 1
  3. Given `$ARGUMENTS` is empty and checkpoint files with `status: "in_progress"` or `"blocked"` or `"awaiting_review"`
     exist with `team: "plan-marketing"`, when the skill is invoked, then the Team Lead reads the checkpoint files and
     re-spawns only the agents whose work is incomplete, providing their checkpoint content as context
  4. Given a re-spawned agent receives its checkpoint content, when it resumes, then it continues from the `last_action`
     recorded in the checkpoint rather than restarting its phase from scratch
  5. Given checkpoint files with `status: "complete"` for all team members and the marketing plan output file exists,
     when the skill is invoked with no args, then it outputs: "Marketing plan already complete. See
     docs/marketing-plans/{filename}. Use 'status' argument to review session history."

- **Edge Cases**:
  - Checkpoint file has malformed YAML frontmatter: Team Lead logs a warning and treats that agent's work as incomplete,
    re-spawning with the phase's original prompt
  - Phase 2 checkpoint exists but Phase 1 checkpoints are missing: Phase 2 cross-reference notes are preserved; Team
    Lead re-reads the Domain Briefs from the checkpoint content rather than re-running Phase 1
  - Two analysts completed Phase 1 but the third did not: only the incomplete analyst is re-spawned; Team Lead uses the
    two completed Domain Briefs directly from their checkpoint files

- **Notes**: Checkpoint format mirrors plan-sales exactly, with `team: "plan-marketing"` in YAML frontmatter. The
  `phase` field values for plan-marketing are: `research | cross-reference | synthesis | review | revision | complete`.
  The `Determine Mode` section of SKILL.md must describe all three states (status, resume, fresh) with the same
  conditional logic used in plan-sales.

---

## Non-Functional Requirements

- **Validator stability**: Creating plan-marketing must not break the existing 12/12 validator pass rate. The skill must
  be added to the non-engineering classification list in both `sync-shared-content.sh` and `skill-shared-content.sh`
  before running validators.
- **Write isolation**: Parallel agents in Phase 1 write only to their own `docs/progress/plan-marketing-{role}.md`
  files. No two agents write to the same file. Only the Team Lead writes to `docs/marketing-plans/`.
- **No hallucinated metrics**: Analysis agents must cite evidence from project files (roadmap, specs, stack) or
  \_user-data.md for all claims. Agents must not invent market sizing numbers, CAC/LTV estimates, or competitor details
  without a source.
- **Business quality sections mandatory**: Assumptions & Limitations, Confidence Assessment (table), Falsification
  Triggers, and External Validation Checkpoints must appear in every finalized output — not optional, not skippable
  under lightweight mode.

## Out of Scope

- Automated execution of marketing campaigns or channel integrations
- Brand asset generation (logos, copy templates, visual identity)
- Marketing automation tool configuration or integrations
- Integration with plan-sales output (plans are independent; cross-referencing is a manual step)
- A/B test design or experiment frameworks — these belong in a future analytics skill (P3-19)
- Changes to existing skills (plan-sales, draft-investor-update) — plan-marketing is additive only
