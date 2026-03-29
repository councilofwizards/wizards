---
type: "user-stories"
feature: "plan-customer-success"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-15-plan-customer-success.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Customer Success Skill (P3-15)

## Epic Summary

Add a `/plan-customer-success` skill to the conclave plugin. The skill assembles
a Customer Success Team using a Hub-and-Spoke pattern: three specialist agents
analyze churn signals, onboarding design, and expansion revenue opportunities,
then a CS Strategist synthesizes their findings into a unified CS playbook. A
single CS Skeptic quality gate ensures the playbook is actionable and
right-sized for an early-stage team. Output is a structured CS playbook written
to `docs/cs-plans/`. The skill follows the Hub-and-Spoke pattern established by
`write-spec` and `plan-implementation`.

## Stories

---

### Story 1: SKILL.md File Creation and Validator Compliance

- **As a** skill author adding the plan-customer-success skill
- **I want** a valid `plugins/conclave/skills/plan-customer-success/SKILL.md`
  that passes all A-series validators
- **So that** the skill is discoverable, structurally sound, and consistent with
  the conclave plugin's multi-agent skill conventions before any agents are
  invoked
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `plugins/conclave/skills/plan-customer-success/` directory
     exists, when `SKILL.md` is created, then its YAML frontmatter contains:
     `name: plan-customer-success`, a one-sentence `description` ending with a
     period, and
     `argument-hint: "[--light] [status | (empty for new playbook)]"`
  2. Given the SKILL.md file, when A1 (frontmatter) validation runs, then all
     required fields are present and no unknown fields exist
  3. Given the SKILL.md file, when A2 (sections) validation runs, then all
     required multi-agent sections exist: `## Setup`, `## Write Safety`,
     `## Checkpoint Protocol`, `## Determine Mode`, `## Lightweight Mode`,
     `## Spawn the Team`, `## Orchestration Flow`, `## Quality Gate`,
     `## Failure Recovery`, `## Teammate Spawn Prompts`, `## Shared Principles`,
     and `## Communication Protocol`
  4. Given the SKILL.md file, when A3 (spawn definitions) validation runs, then
     every teammate block contains `**Name**:` and `**Model**:` fields
  5. Given the SKILL.md file, when A4 (shared content markers) validation runs,
     then it contains `<!-- BEGIN SHARED: universal-principles -->` and
     `<!-- END SHARED: universal-principles -->` markers; it must NOT contain
     engineering-principles markers (plan-customer-success is non-engineering)
  6. Given `bash scripts/validate.sh`, when run after creation and sync, then
     all 12/12 validators pass
  7. Given `plan-customer-success` is not yet in the non-engineering
     classification lists, when the skill is added, then
     `scripts/sync-shared-content.sh` and
     `scripts/validators/skill-shared-content.sh` are both updated to include
     `plan-customer-success` in the non-engineering list

- **Edge Cases**:
  - Skill name contains a hyphen-heavy slug (`plan-customer-success`): verify
    the A1 validator handles multi-hyphen names correctly by checking the name
    field pattern; this is longer than most skill names
  - B2 normalizer skeptic pair for `cs-skeptic` / `CS Skeptic` does not yet
    exist: it must be added to the normalizer before running validators
    post-sync

- **Notes**: Reference `plugins/conclave/skills/plan-sales/SKILL.md` for Setup,
  Write Safety, Checkpoint Protocol, and Determine Mode boilerplate. The
  directory name `plan-customer-success` must match the `name:` field in
  frontmatter exactly — the A1 validator checks this against the directory path.

---

### Story 2: Agent Team Composition (Hub-and-Spoke)

- **As a** founder invoking `/plan-customer-success`
- **I want** three specialist agents (Churn Analyst, Onboarding Designer,
  Expansion Analyst) reporting to a CS Strategist hub, with a CS Skeptic
  providing a single quality gate
- **So that** each CS domain receives focused expert analysis before a
  synthesist draws them together into a coherent playbook, and a skeptic ensures
  the playbook is actionable for a small team
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Spawn the Team` section, when it is read, then it defines
     exactly five teammates: `churn-analyst`, `onboarding-designer`,
     `expansion-analyst`, `cs-strategist`, and `cs-skeptic`
  2. Given the `churn-analyst` definition, when it is read, then
     `**Model**: opus` is specified and its Tasks field describes: "Identify
     leading and lagging churn indicators from product roadmap, support
     patterns, and user feedback. Produce Churn Signal Brief."
  3. Given the `onboarding-designer` definition, when it is read, then
     `**Model**: sonnet` is specified and its Tasks field describes: "Design a
     systematic onboarding journey from sign-up to first value. Produce
     Onboarding Brief."
  4. Given the `expansion-analyst` definition, when it is read, then
     `**Model**: sonnet` is specified and its Tasks field describes: "Identify
     expansion revenue opportunities (upsell, cross-sell, seat growth) aligned
     with the product roadmap. Produce Expansion Brief."
  5. Given the `cs-strategist` definition, when it is read, then
     `**Model**: opus` is specified and its Tasks field describes: "Synthesize
     the three specialist briefs into a unified CS playbook. Revise based on CS
     Skeptic feedback."
  6. Given the `cs-skeptic` definition, when it is read, then `**Model**: opus`
     is specified and its Tasks field describes: "Evaluate whether the playbook
     is actionable for an early-stage team and whether churn risks are honestly
     addressed. Approve or reject with specific feedback."
  7. Given lightweight mode (`--light`), when the skill runs, then
     `churn-analyst`, `onboarding-designer`, and `expansion-analyst` use
     `sonnet`; `cs-strategist` uses `sonnet`; `cs-skeptic` remains `opus`

- **Edge Cases**:
  - `onboarding-designer` and `expansion-analyst` are already `sonnet` in the
    standard team: lightweight mode has no effect on these two agents (they are
    already using the lighter model); SKILL.md should document this so
    implementers don't accidentally try to "downgrade" them further
  - Hub-and-Spoke differs from Collaborative Analysis: the CS Strategist
    synthesizes (not the Team Lead); the Team Lead remains in delegate mode for
    all phases except final output writing
  - cs-skeptic is a single skeptic (not dual): this is appropriate for a
    Medium-effort skill; plan-finance and plan-marketing use dual skeptics due
    to their higher complexity and risk

- **Notes**: The onboarding-designer and expansion-analyst can be Sonnet because
  their work is more execution-oriented (design and identification) than the
  churn-analyst and cs-strategist (pattern recognition and synthesis). This
  model assignment reflects the "Use Sonnet for execution agents, Opus for
  reasoning agents" principle from the shared Universal Principles block.

---

### Story 3: Orchestration Flow — Hub-and-Spoke Pattern

- **As a** Customer Success Team Lead
- **I want** an orchestration flow where three specialist agents work in
  parallel, report to the CS Strategist hub for synthesis, and the synthesis
  passes a single skeptic gate before finalization
- **So that** the playbook benefits from parallel specialist depth without
  requiring the Team Lead to synthesize financial complexity directly (as in
  plan-finance's Team Lead synthesis)
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Orchestration Flow` section, when it is read, then it defines
     four sequential phases: Phase 1 (Parallel Specialist Analysis), Phase 2
     (Strategist Synthesis), Phase 3 (Skeptic Review), Phase 4 (Finalize)
  2. Given Phase 1, when it runs, then `churn-analyst`, `onboarding-designer`,
     and `expansion-analyst` are spawned concurrently via `Agent` tool with
     `team_name: "plan-customer-success"`; each produces a Domain Brief sent to
     the Team Lead
  3. Given Phase 2, when it runs, then `cs-strategist` is spawned with all three
     Domain Briefs provided as context; the CS Strategist produces a CS Playbook
     Draft and sends it to the Team Lead
  4. Given Phase 3, when it runs, then `cs-skeptic` is spawned with the Playbook
     Draft as context; the skeptic returns `Verdict: APPROVED` or
     `Verdict: REJECTED` with specific feedback
  5. Given a rejection in Phase 3, when it occurs, then the CS Strategist is
     re-spawned with the rejection feedback and revises the playbook; the
     revised draft returns to Phase 3 (max 3 cycles before human escalation)
  6. Given Phase 4, when it runs, then the Team Lead writes the final CS
     playbook to `docs/cs-plans/{YYYY-MM-DD}-cs-playbook.md` and progress
     summary to `docs/progress/plan-customer-success-summary.md`
  7. Given the `## Orchestration Flow` section, when it includes an ASCII
     diagram, then the diagram shows the Hub-and-Spoke structure: three spokes
     (analysts) → hub (cs-strategist) → gate (cs-skeptic) → output

- **Edge Cases**:
  - CS Strategist becomes unresponsive after receiving Domain Briefs: Team Lead
    re-spawns with the three Domain Briefs re-provided as context; work from
    Phase 1 is not lost
  - All three analysts report the same churn signal from different angles: CS
    Strategist should highlight this convergence in the playbook rather than
    treating it as three separate signals
  - Pre-launch product (no existing customers to churn): churn-analyst produces
    a "pre-launch risk assessment" brief instead of a historical churn analysis;
    the skill must handle this gracefully without erroring on missing customer
    data

- **Notes**: This is Hub-and-Spoke, not Collaborative Analysis — the CS
  Strategist synthesizes, not the Team Lead. The Team Lead is in delegate mode
  for Phases 1-3 and only writes the final output file in Phase 4. Reference the
  `write-spec` and `plan-implementation` skills for Hub-and-Spoke orchestration
  flow examples, though plan-customer-success has a different domain focus.

---

### Story 4: CS Playbook Output Artifact

- **As a** founder reviewing the customer success plan output
- **I want** a structured CS playbook in `docs/cs-plans/` with defined sections
  for churn signals, onboarding journey, expansion strategy, and a prioritized
  90-day action plan
- **So that** the team has a concrete, actionable plan with clear ownership and
  measurable success criteria rather than a generic list of CS best practices
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the `## Output Template` section of SKILL.md, when the playbook is
     finalized, then the output file is written to
     `docs/cs-plans/{YYYY-MM-DD}-cs-playbook.md`
  2. Given the output file YAML frontmatter, when it is validated, then it
     contains: `type: "cs-playbook"`, `generated: "{YYYY-MM-DD}"`,
     `confidence: "high|medium|low"`, `review_status: "approved"`,
     `approved_by: [cs-skeptic]`
  3. Given the output file body, when it is read, then it contains these
     sections in order: Executive Summary, Customer Health Indicators (table),
     Churn Signal Catalog, Onboarding Journey Map, Expansion Opportunity Matrix,
     90-Day Action Plan, Success Metrics, Team Capacity Assessment, Assumptions
     & Limitations, Confidence Assessment, Falsification Triggers, External
     Validation Checkpoints
  4. Given the Customer Health Indicators table, when it is read, then each row
     contains: Indicator / Signal Type (leading/lagging) / Measurement Method /
     Threshold / Action Trigger
  5. Given the 90-Day Action Plan section, when it is read, then each action
     item specifies: action, owner (role, not person), timeline (day 1-30,
     31-60, 61-90), effort (hours), and expected outcome
  6. Given the Expansion Opportunity Matrix, when it is read, then each
     opportunity row contains: opportunity type, applicable customer segment,
     trigger condition, and estimated revenue impact labeled as "estimated" with
     a confidence level — not a precise projection
  7. Given `docs/cs-plans/_user-data.md` does not exist, when the skill runs for
     the first time, then it creates the file and outputs: "Created
     docs/cs-plans/\_user-data.md — fill in your current customer count, average
     contract value, known support issues, and NPS data for a more specific
     playbook."

- **Edge Cases**:
  - Pre-launch product: Churn Signal Catalog is replaced with "Pre-Launch Risk
    Factors" covering the signals to watch from day one; the section header
    should adapt but the section must still exist
  - Zero known customers: Team Capacity Assessment defaults to "founding team"
    and the 90-Day Action Plan focuses on onboarding the first 10 customers
    rather than retention at scale
  - Expansion Opportunity Matrix is empty (single-product, single-tier
    offering): section must still appear with a note "No expansion paths
    identified for current product stage" rather than being omitted

- **Notes**: The mandatory business quality sections (Assumptions & Limitations,
  Confidence Assessment, Falsification Triggers, External Validation
  Checkpoints) are non-negotiable. The User Data Template for `_user-data.md`
  should prompt for: current customer count, churn rate (if known), NPS or CSAT
  data, average contract value, known support pain points, and team members
  available for CS work.

---

### Story 5: CS Skeptic Quality Gate

- **As a** CS Skeptic reviewing the CS playbook draft
- **I want** a structured checklist embedded in my spawn prompt that evaluates
  actionability and honesty of the playbook
- **So that** my review produces specific, fixable feedback rather than general
  endorsements or vague concerns, and founders receive a playbook they can
  actually execute
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the CS Skeptic's spawn prompt, when it is read, then it includes a
     numbered checklist of at least 6 items covering: (a) whether churn signals
     are specific enough to measure with the tools a startup realistically has,
     (b) whether the onboarding journey has clear stage exits and success
     criteria, (c) whether the 90-day action plan is achievable given the Team
     Capacity Assessment, (d) whether expansion opportunities are appropriately
     hedged (no fabricated revenue projections), (e) whether the plan
     acknowledges what it doesn't know about the customer base, (f) whether the
     "pre-launch" vs. "established" product state is correctly reflected
     throughout
  2. Given a CS Skeptic review, when it is complete, then the output format is:
     `CS REVIEW: Customer Success Playbook` / `Verdict: APPROVED / REJECTED` /
     if rejected: numbered issues with specific section, why it fails the
     checklist item, and what a correct version looks like
  3. Given a playbook that recommends hiring a dedicated CSM immediately, when
     the CS Skeptic reviews, then the skeptic flags this as potentially
     infeasible for a pre-Series A startup and requests a founder-led CS
     alternative unless headcount budget is confirmed in \_user-data.md
  4. Given an approved playbook, when Phase 4 begins, then the output
     frontmatter contains `review_status: "approved"` and
     `approved_by: [cs-skeptic]`
  5. Given the CS Skeptic spawn prompt, when it is read, then it instructs: "You
     MUST be explicitly asked to review. Do not self-assign." — per shared
     communication protocol

- **Edge Cases**:
  - CS Skeptic rejects the playbook 3 times on the same issue: human escalation
    protocol applies — Team Lead presents the three submission attempts, skeptic
    objections, and the team's revision rationales to the human operator for a
    decision
  - CS Skeptic approves with minor observations: minor observations are
    incorporated into the Assumptions & Limitations section of the output; they
    do not block finalization
  - Playbook recommends a health scoring system that requires engineering work
    not on the roadmap: CS Skeptic flags this as a dependency risk and requests
    either a simpler proxy or a roadmap reference

- **Notes**: Unlike plan-finance and plan-marketing (which use dual skeptics),
  plan-customer-success uses a single CS Skeptic. This is appropriate for the
  Medium effort level. A single skilled skeptic with a rigorous checklist
  provides sufficient quality assurance for a CS playbook, and keeps the skill
  lean. The B2 normalizer must have `cs-skeptic` / `CS Skeptic` added as a
  skeptic name pair.

---

### Story 6: Session Recovery and Status Mode

- **As a** founder who interrupted a `/plan-customer-success` session
- **I want** the skill to detect incomplete checkpoints and resume from the last
  known state
- **So that** I don't lose analyst work when a session is interrupted mid-way
  through the playbook creation process
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given `$ARGUMENTS` is `"status"`, when the skill is invoked, then the Team
     Lead reads all `docs/progress/` files with `team: "plan-customer-success"`
     in their frontmatter and outputs a status summary without spawning agents
  2. Given `$ARGUMENTS` is empty and no incomplete checkpoints exist, when the
     skill is invoked, then a fresh playbook creation begins from Phase 1
  3. Given `$ARGUMENTS` is empty and incomplete checkpoints exist for
     `team: "plan-customer-success"`, when the skill is invoked, then the Team
     Lead reads checkpoint files and re-spawns only the agents with incomplete
     work, providing checkpoint content as context
  4. Given Phase 1 completed (all three Domain Briefs checkpointed) but Phase 2
     not started, when the skill resumes, then the CS Strategist is spawned with
     the three Domain Briefs read from checkpoint files — Phase 1 agents are not
     re-spawned
  5. Given the CS Skeptic rejected and the revision is in progress, when the
     skill resumes at that state, then the CS Strategist is re-spawned with the
     rejection feedback from the skeptic's checkpoint file

- **Edge Cases**:
  - Only two of three analyst checkpoints exist (one agent failed silently):
    Team Lead re-spawns the missing analyst with the original Phase 1 prompt;
    the two completed briefs are preserved
  - CS playbook output file already exists: Team Lead outputs: "CS playbook
    already complete. See docs/cs-plans/{filename}." and does not overwrite

- **Notes**: Checkpoint `phase` field values for plan-customer-success:
  `research | synthesis | review | revision | complete`. The `Determine Mode`
  section must follow the same three-state logic (status / resume / fresh) as
  plan-sales and plan-marketing.

---

## Non-Functional Requirements

- **Validator stability**: Adding plan-customer-success must not break the 12/12
  validator pass rate. Classification list updates must precede
  `bash scripts/validate.sh` execution.
- **No prescriptive tooling**: The CS playbook must not recommend specific
  software tools (e.g., Gainsight, Intercom) as requirements — it recommends
  process, and tools are referenced as examples only, clearly labeled as such.
- **Write isolation**: Parallel agents in Phase 1 write only to their own
  progress files (`docs/progress/plan-customer-success-{role}.md`). Only the
  Team Lead writes to `docs/cs-plans/`.
- **Business quality sections mandatory**: Assumptions & Limitations, Confidence
  Assessment (table), Falsification Triggers, and External Validation
  Checkpoints are non-negotiable in every output.
- **Pre-launch adaptation**: The skill must handle a pre-launch product state
  gracefully — all sections must produce meaningful output even when there are
  zero customers; agents must be instructed in their spawn prompts to check
  whether customer data exists before attempting to analyze it.

## Out of Scope

- Customer support ticket triage or automated routing
- NPS survey design or distribution
- Integration with CRM tools (Salesforce, HubSpot) or ticketing systems
  (Zendesk, Intercom)
- Customer segmentation analysis (covered by research-market)
- Post-churn win-back campaign design
- SLA definition or service tier structuring
- Integration with plan-sales output — cross-skill synthesis is a manual step
  for the founder
- Changes to existing skills — plan-customer-success is additive only
