---
feature: "plan-sales"
team: "build-product"
agent: "impl-architect"
phase: "planning"
status: "awaiting_review"
last_action: "Completed section-by-section implementation plan for SKILL.md"
updated: "2026-02-19T12:00:00Z"
---

# Implementation Plan: plan-sales/SKILL.md

## Overview

This document provides a section-by-section implementation plan for `plugins/conclave/skills/plan-sales/SKILL.md`. Each section maps to specific spec success criteria and system design requirements.

The plan-sales SKILL.md is the first Collaborative Analysis skill in the conclave framework. It introduces peer-to-peer mid-process knowledge sharing (Domain Briefs + Cross-Reference Reports), lead-driven synthesis, and a Strategy Skeptic role.

---

## Section 1: YAML Frontmatter

**Source**: System design Section "SKILL.md Structure"

```yaml
---
name: plan-sales
description: >
  Assess sales strategy for early-stage startups. Parallel analysis agents
  research market, product positioning, and go-to-market, then cross-reference
  and challenge each other's findings before dual-skeptic validation.
argument-hint: "[--light] [status | (empty for new assessment)]"
---
```

**Notes**:
- `name` must match the directory name `plan-sales`
- `description` taken verbatim from system design
- `argument-hint` matches spec Arguments table (no `<period>` arg unlike investor update)
- No `type: single-agent` field -- this is multi-agent, so absence is correct (validator skips single-agent skills for shared content checks)

**Spec criteria mapped**: SC-7 (--light), SC-8 (status), SC-9 (first-run setup)

---

## Section 2: Main Heading and Team Lead Role Description

**Source**: System design overview + spec Architecture section

```markdown
# Sales Strategy Team Orchestration

You are orchestrating the Sales Strategy Team. Your role is TEAM LEAD.
Unlike Pipeline or Hub-and-Spoke skills, you are running a Collaborative Analysis --
parallel agents research independently, cross-reference each other's findings,
and YOU synthesize the final assessment. You coordinate AND write the synthesis
(Phase 3 is NOT delegate mode).
```

**Critical distinction from other skills**:
- `draft-investor-update`: "Enable delegate mode -- you coordinate, you do NOT write content yourself."
- `plan-product`: "Enable delegate mode -- you coordinate, you do NOT write specs yourself."
- `plan-sales`: Team Lead WRITES the synthesis. Phase 3 is lead-driven. Must be explicit about this difference.

**Notes**:
- Must explicitly state the Collaborative Analysis pattern
- Must explicitly state the lead writes the synthesis (not delegate mode for Phase 3)
- Must state the lead orchestrates phases 1, 2, 4, 5 in delegate mode but performs Phase 3 directly
- Spec criteria mapped: SC-2 (Collaborative Analysis protocol executes), SC-14 (Lead-driven synthesis)

---

## Section 3: Setup

**Source**: All existing SKILL.md Setup sections + system design First-Run Behavior

**Structure**:
1. Ensure project directory structure exists. Create any missing directories. For each empty directory, ensure `.gitkeep`:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
   - `docs/stack-hints/`
   - `docs/sales-plans/`  ← **NEW directory** (replaces `docs/investor-updates/` from investor update)
2. Read templates if they exist (same as other skills)
3. Detect project stack (same pattern as other skills)
4. Read `docs/roadmap/` to understand current state
5. Read `docs/progress/` for latest implementation status
6. Read `docs/specs/` for existing specs
7. Read `docs/architecture/` for technical decisions
8. Read `docs/sales-plans/_user-data.md` if it exists. Read any prior sales assessments in `docs/sales-plans/` for consistency reference.
9. **First-run convenience**: If `docs/sales-plans/` exists but `docs/sales-plans/_user-data.md` does not, create it using the User Data Template embedded in this file (see below). Output a message: "Created docs/sales-plans/_user-data.md -- fill in your market data, pricing, and constraints before the next run for a more specific assessment."
10. **Data dependency warning**: If `_user-data.md` does not exist OR is empty/template-only, output a prominent warning: "No user data found. Assessment quality depends heavily on user-provided market data. Create docs/sales-plans/_user-data.md for a more specific assessment."

**Notes**:
- Steps 1-3 are shared pattern (identical to other skills except directory list)
- Steps 4-6 are shared pattern
- Step 7 is new (architecture read for technical decisions -- analysis agents need this)
- Steps 8-10 are specific to plan-sales
- Spec criteria mapped: SC-9 (first-run setup), SC-10 (reads _user-data.md), SC-13 (first-run warnings)

---

## Section 4: Write Safety

**Source**: Standard pattern from all SKILL.md files

```markdown
## Write Safety

Agents working in parallel MUST NOT write to the same file. Follow these conventions:

- **Progress files**: Each agent writes ONLY to `docs/progress/plan-sales-{role}.md` (e.g., `docs/progress/plan-sales-market-analyst.md`). Agents NEVER write to a shared progress file.
- **Shared files**: Only the Team Lead writes to `docs/sales-plans/` output files and shared/aggregated progress summaries. The Team Lead aggregates agent outputs AFTER phases complete.
- **Architecture files**: Each agent writes to files scoped to their concern.
```

**Notes**:
- Same structure as other skills
- Role names change: `{role}` = market-analyst, product-strategist, gtm-analyst, accuracy-skeptic, strategy-skeptic
- Key difference: No agent writes to `docs/sales-plans/` except the Team Lead

---

## Section 5: Checkpoint Protocol

**Source**: Standard pattern + system design phase enum

**Phase enum**: `research | cross-reference | synthesis | review | revision | complete`

This differs from:
- plan-product: `research | design | review | complete`
- draft-investor-update: `research | draft | review | revision | complete`

```yaml
---
feature: "sales-strategy"
team: "plan-sales"
agent: "role-name"
phase: "research"         # research | cross-reference | synthesis | review | revision | complete
status: "in_progress"     # in_progress | blocked | awaiting_review | complete
last_action: "Brief description of last completed action"
updated: "ISO-8601 timestamp"
---
```

**Notes**:
- Standard format, just different phase enum
- `team: "plan-sales"` for validator compatibility
- Checkpoint timing rules same as other skills
- Spec criteria mapped: SC-8 (status mode reads these)

---

## Section 6: Determine Mode

**Source**: Standard pattern from other skills

```markdown
## Determine Mode

Based on $ARGUMENTS:
- **"status"**: Read all checkpoint files for this skill and generate a consolidated status report. Do NOT spawn any agents. Read `docs/progress/` files with `team: "plan-sales"` in their frontmatter, parse their YAML metadata, and output a formatted status summary. If no checkpoint files exist for this skill, report "No active or recent sessions found."
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "plan-sales"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** -- re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, start a new assessment.
```

**Notes**:
- No "period" argument (unlike investor update) -- sales assessments are not period-scoped
- No "new/review/reprioritize" modes (unlike plan-product) -- sales assessment is a single mode
- Just status and empty/resume
- Spec criteria mapped: SC-8 (status mode)

---

## Section 7: Lightweight Mode

**Source**: Spec Arguments table + system design

```markdown
## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight mode:
- Output to user: "Lightweight mode enabled: analysis agents using Sonnet. Skeptics remain Opus. Quality gates maintained."
- Market Analyst: spawn with model **sonnet** instead of opus
- Product Strategist: spawn with model **sonnet** instead of opus
- GTM Analyst: spawn with model **sonnet** instead of opus
- Accuracy Skeptic: unchanged (ALWAYS Opus)
- Strategy Skeptic: unchanged (ALWAYS Opus)
- All orchestration flow, quality gates, and communication protocols remain identical
```

**Notes**:
- Only analysis agents downgrade; skeptics stay Opus
- This is the same pattern as other skills but with 3 agents changing instead of 1-2
- Spec criteria mapped: SC-7 (--light mode)

---

## Section 8: Spawn the Team

**Source**: System design Agent Team section

5 agents total (no DBA, no separate Drafter):

```markdown
## Spawn the Team

Create an agent team called "plan-sales" with these teammates:

### Market Analyst
- **Name**: `market-analyst`
- **Model**: opus
- **Subagent type**: `general-purpose`
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Market sizing, competitive landscape, industry trends. Produce Market Domain Brief. Cross-reference peers' findings.

### Product Strategist
- **Name**: `product-strategist`
- **Model**: opus
- **Subagent type**: `general-purpose`
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Value proposition, differentiation, product-market fit. Produce Product Domain Brief. Cross-reference peers' findings.

### GTM Analyst
- **Name**: `gtm-analyst`
- **Model**: opus
- **Subagent type**: `general-purpose`
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Go-to-market channels, pricing, customer acquisition. Produce GTM Domain Brief. Cross-reference peers' findings.

### Accuracy Skeptic
- **Name**: `accuracy-skeptic`
- **Model**: opus
- **Subagent type**: `general-purpose`
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Verify all factual claims against evidence. Check projections, market data, sourcing. Apply business quality checklist.

### Strategy Skeptic
- **Name**: `strategy-skeptic`
- **Model**: opus
- **Subagent type**: `general-purpose`
- **Prompt**: [See Teammate Spawn Prompts below]
- **Tasks**: Challenge strategic assumptions, evaluate alternatives, verify coherence, assess early-stage feasibility. Apply business quality checklist.
```

**Notes**:
- All Opus rationale is in the spec/system design; no need to repeat in SKILL.md
- Team name "plan-sales" matches the skill name
- Spec criteria mapped: SC-1 (complete team), SC-2 (agents produce briefs/cross-refs)

---

## Section 9: Orchestration Flow

**Source**: System design Phase Diagram + Phase Details

This is the core section and the most novel part of the SKILL.md. Must include:

1. **ASCII Phase Diagram** -- Copy verbatim from system design (the box diagram showing all 5 phases + gates)

2. **Phase 1: Independent Research (Parallel)**
   - Trigger: Team Lead distributes initial instructions to all 3 analysis agents
   - Agents read: project artifacts + user data (list all input files)
   - Each agent produces a Domain Brief (structured format embedded)
   - Gate 1: Team Lead verifies all 3 briefs received and complete (lightweight completeness check)
   - Instructions for the lead: check that each brief addresses its key questions; if severely incomplete, request expansion

3. **Phase 2: Cross-Referencing (Parallel)**
   - Trigger: Team Lead distributes all 3 Domain Briefs to all 3 agents (each receives the two they did not write)
   - Each agent reviews peers' briefs for: contradictions, gaps, challenges, synergies, answers to peer questions
   - Each agent produces a Cross-Reference Report (structured format embedded)
   - Disagreement handling: disagreements are preserved, not resolved -- both sides flow to synthesis
   - Gate 2: Team Lead verifies all 3 Cross-Reference Reports received
   - Critical quality check: A report claiming "no contradictions, no gaps, no challenges" across two briefs is automatically suspect. Send back for revision.

4. **Phase 3: Synthesis (Lead-Driven -- NOT Delegate Mode)**
   - Agent: Team Lead (you write this yourself)
   - Input: 3 Domain Briefs + 3 Cross-Reference Reports (6 artifacts)
   - Synthesis process:
     1. Resolve contradictions -- weigh evidence, choose better-supported position, document reasoning
     2. Integrate gap-fills
     3. Evaluate challenged assumptions
     4. Highlight synergies
     5. Write the full assessment using the Output Template
   - Context management: Synthesize section by section (Target Market, then Competitive Positioning, etc.), not all at once. If context degrades, checkpoint and continue from last completed section.
   - Output: Draft Sales Strategy Assessment

5. **Phase 4: Review (Dual-Skeptic, Parallel)**
   - Send draft AND all 6 source artifacts to both skeptics
   - Accuracy Skeptic checklist (5 items + business quality checklist)
   - Strategy Skeptic checklist (6 items + business quality checklist)
   - Gate 3: BOTH must approve. If either rejects, return to Phase 3b.

6. **Phase 3b: Revise**
   - Team Lead revises synthesis based on ALL skeptic feedback
   - Document what changed and why
   - Return to Gate 3
   - Maximum 3 revision cycles before escalation

7. **Phase 5: Finalize**
   - Write final assessment to `docs/sales-plans/{date}-sales-strategy.md`
   - Write progress summary to `docs/progress/plan-sales-summary.md`
   - Write cost summary to `docs/progress/plan-sales-{date}-cost-summary.md`
   - Output final assessment to user with review/implementation instructions

**Notes**:
- The phase diagram should be copied exactly from the system design
- Phase 3 must explicitly state "YOU write this -- not delegate mode"
- Phase 2 quality check (empty cross-refs) must be explicit
- Context management guidance for Phase 3 is critical for practical success
- Spec criteria mapped: SC-1 (full assessment), SC-2 (protocol executes), SC-3 (substantive cross-refs), SC-4 (accuracy verification), SC-5 (strategy verification), SC-6 (both approve), SC-9 (writes output), SC-14 (section-by-section synthesis)

---

## Section 10: Quality Gate

**Source**: Standard dual-skeptic pattern from draft-investor-update

```markdown
## Quality Gate

NO sales strategy assessment is finalized without BOTH Accuracy Skeptic AND Strategy Skeptic approval. If either skeptic has concerns, the Team Lead revises. This is non-negotiable. Maximum 3 revision cycles before escalation to the human operator.
```

**Notes**:
- Same structure as investor update quality gate, but with different skeptic names
- Spec criteria mapped: SC-6 (both must approve)

---

## Section 11: Failure Recovery

**Source**: Standard 3-pattern from all SKILL.md files

```markdown
## Failure Recovery

- **Unresponsive agent**: If any teammate becomes unresponsive or crashes, the Team Lead should re-spawn the role and re-assign any pending tasks or review requests.
- **Skeptic deadlock**: If EITHER skeptic rejects the same deliverable 3 times, STOP iterating. The Team Lead escalates to the human operator with a summary of the submissions, both skeptics' objections across all rounds, and the team's attempts to address them. The human decides: override the skeptics, provide guidance, or abort.
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should read the agent's checkpoint file at `docs/progress/plan-sales-{role}.md`, then re-spawn the agent with the checkpoint content as context to resume from the last known state.
```

**Notes**:
- Identical structure to draft-investor-update Failure Recovery
- "EITHER skeptic" phrasing matches dual-skeptic pattern
- Role-scoped checkpoint file path uses `plan-sales-{role}` convention

---

## Section 12: Shared Principles (COPY VERBATIM)

**Source**: `plan-product/SKILL.md` lines 145-174

**Action**: Copy the ENTIRE block between `<!-- BEGIN SHARED: principles -->` and `<!-- END SHARED: principles -->` markers from plan-product/SKILL.md. BYTE-IDENTICAL. No changes whatsoever.

This includes:
- The horizontal rule `---` before the block
- `<!-- BEGIN SHARED: principles -->`
- `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->`
- The full `## Shared Principles` section (12 numbered items across 4 tiers)
- `<!-- END SHARED: principles -->`

**Validation**: CI validator B1 checks byte-identity. Any change will fail the build.

**Spec criteria mapped**: SC-12 (CI validator passes, shared content drift check)

---

## Section 13: Communication Protocol (COPY WITH SKEPTIC ADAPTATION)

**Source**: `plan-product/SKILL.md` lines 178-213

**Action**: Copy the ENTIRE block between `<!-- BEGIN SHARED: communication-protocol -->` and `<!-- END SHARED: communication-protocol -->` markers from plan-product/SKILL.md.

**The ONLY change**: In the "When to Message" table, the row:
```
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Product Skeptic |
```
becomes:
```
| Plan ready for review | `write(accuracy-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Accuracy Skeptic |
```

This is the ONLY allowed difference. The rest must be byte-identical.

**Validation**: CI validator B2 normalizes skeptic names (`product-skeptic` -> `SKEPTIC_NAME`, `accuracy-skeptic` -> `SKEPTIC_NAME`) before comparison. After normalization, blocks must be identical. The `strategy-skeptic` / `Strategy Skeptic` normalization will be added to the validator as a separate change (see spec Files to Modify).

**Important**: The "Plan ready for review" row targets `accuracy-skeptic`, not `strategy-skeptic`. This matches the pattern in draft-investor-update where the first skeptic is the primary review target. Both skeptics still review during Phase 4, but the communication protocol routes plan review requests to the accuracy skeptic.

**Spec criteria mapped**: SC-12 (CI validator passes)

---

## Section 14: Teammate Spawn Prompts

**Source**: System design Phase Details + spec Agent Team

Each prompt must include these components:
1. Role introduction ("You are the [Role] on the Sales Strategy Team.")
2. Domain focus
3. Critical rules (specific to role)
4. Inputs to read
5. Output format (Domain Brief for analysts, Cross-Reference Report for analysts in Phase 2, Review format for skeptics)
6. Communication instructions
7. Write safety (role-scoped files)
8. Checkpoint instructions

### 14a: Market Analyst Prompt

```
You are the Market Analyst on the Sales Strategy Team.

YOUR ROLE: Research and analyze the market opportunity. Market sizing,
competitive landscape, industry trends, and target customer identification.

[Critical rules about evidence-based findings, confidence levels, no fabrication]

WHAT YOU INVESTIGATE:
- docs/roadmap/_index.md and individual roadmap files
- docs/specs/ -- product capabilities
- docs/architecture/ -- technical decisions
- docs/sales-plans/_user-data.md -- user-provided market data
- docs/sales-plans/ -- prior assessments for consistency
- Project root (README, CLAUDE.md)

YOUR PRIMARY FOCUS:
- Who are the target customers?
- How big is the market opportunity (TAM/SAM/SOM)?
- Who are the competitors and what are their strengths/weaknesses?
- What industry trends or tailwinds exist?

PHASE 1 OUTPUT -- DOMAIN BRIEF:
[Full Domain Brief format from system design]

PHASE 2 -- CROSS-REFERENCING:
When the Team Lead sends you the other two agents' briefs, review them for:
1. Contradictions with your findings
2. Gaps you can fill from your research
3. Assumptions you can challenge with evidence
4. Synergies across domains
5. Answers to their questions for you
[Full Cross-Reference Report format from system design]

COMMUNICATION:
- Send Domain Brief to Team Lead when Phase 1 is complete
- Send Cross-Reference Report to Team Lead when Phase 2 is complete
- Respond promptly to questions from other agents
- If you discover something urgent, message the Team Lead immediately

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-sales-market-analyst.md
- NEVER write to shared files

CHECKPOINT:
- Checkpoint after: task claimed, research started, Domain Brief sent, cross-referencing started, Cross-Reference Report sent
```

### 14b: Product Strategist Prompt

Same structure as Market Analyst, with domain focus on:
- Value proposition assessment
- Product differentiation analysis
- Product-market fit evaluation
- Key questions: What problem does this solve? Why is this solution better? What is the unique value?

### 14c: GTM Analyst Prompt

Same structure as Market Analyst, with domain focus on:
- Go-to-market channel analysis
- Pricing considerations
- Customer acquisition strategy
- Key questions: How do we reach customers? What should pricing look like? What channels work?

### 14d: Accuracy Skeptic Prompt

```
You are the Accuracy Skeptic on the Sales Strategy Team.

YOUR ROLE: Verify every factual claim in the sales strategy assessment against
the source artifacts. Claims, projections, and market data must be traceable.
Nothing passes without your explicit approval.

CRITICAL RULES:
- You MUST be explicitly asked to review. Don't self-assign.
- Work through every item on your checklist. Vague approvals are as bad as vague assessments.
- Approve or reject. No "probably fine."
- When rejecting, provide SPECIFIC, ACTIONABLE feedback.
- You receive the draft assessment AND all 6 source artifacts (3 briefs + 3 cross-ref reports).

YOUR CHECKLIST (5 items + business quality):
1. Every claim has evidence (traced to user data, project artifacts, or explicit assumption)
2. Projections are grounded in stated assumptions, not optimism
3. Contradictions are resolved, not hidden
4. Data gaps are acknowledged
5. Business quality checklist:
   - Are assumptions stated, not hidden?
   - Are confidence levels present and justified?
   - Are falsification triggers specific and actionable?
   - Does the output acknowledge what it doesn't know?
   - Are projections grounded in stated evidence, not optimism?

REVIEW FORMAT:
[Accuracy review verdict format from system design]

COMMUNICATION:
- Send review to Team Lead
- If critical accuracy issue, message Team Lead immediately
- Coordinate with Strategy Skeptic -- discuss shared concerns but submit independent verdicts

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-sales-accuracy-skeptic.md
- NEVER write to shared files
```

### 14e: Strategy Skeptic Prompt

```
You are the Strategy Skeptic on the Sales Strategy Team.

YOUR ROLE: Challenge strategic assumptions, evaluate alternatives, and verify
strategic coherence. Ensure the sales strategy is honest, feasible for an
early-stage startup, and would hold up under domain expert scrutiny.
Nothing passes without your explicit approval.

CRITICAL RULES:
- You MUST be explicitly asked to review. Don't self-assign.
- Work through every item on your checklist systematically.
- Approve or reject. No "good enough."
- When rejecting, provide SPECIFIC, ACTIONABLE feedback.
- You receive the draft assessment AND all 6 source artifacts.

YOUR CHECKLIST (6 items + business quality):
1. Strategic coherence (target market, value prop, positioning, GTM tell consistent story)
2. Alternative consideration (at least one alternative strategy evaluated)
3. Risk assessment is honest (substantive, not token)
4. Early-stage appropriateness (feasible with startup resources)
5. Scope discipline (stays within sales strategy assessment)
6. Business quality checklist:
   - Would a domain expert find the framing credible?
   - Are projections grounded in stated evidence, not optimism?

REVIEW FORMAT:
[Strategy review verdict format from system design]

COMMUNICATION:
- Send review to Team Lead
- If critical strategic issue, message Team Lead immediately
- Coordinate with Accuracy Skeptic -- discuss shared concerns but submit independent verdicts

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-sales-strategy-skeptic.md
- NEVER write to shared files
```

---

## Section 15: Output Template

**Source**: System design "Output Artifact Format" section (lines 362-489)

Copy the FULL template from the system design, including:
- YAML frontmatter with `type: "sales-strategy"`, `period`, `generated`, `confidence`, `review_status`, `approved_by` (accuracy-skeptic + strategy-skeptic)
- All 9 content sections: Executive Summary, Target Market (Primary Segment + Market Sizing), Competitive Positioning (Landscape + Differentiation + Positioning Statement), Value Proposition, Go-to-Market Strategy (Channels + Customer Acquisition + Sales Process), Pricing Considerations, Strategic Risks, Recommended Next Steps
- 4 mandatory business quality sections: Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints

**Spec criteria mapped**: SC-1 (complete assessment), SC-11 (all business quality sections)

---

## Section 16: User Data Template

**Source**: System design "User Data Input" section (lines 500-547)

Copy the full template. This is what gets created at `docs/sales-plans/_user-data.md` on first run.

Sections:
- Product & Market
- Market Context
- Current Sales
- Pricing
- Constraints
- Additional Context

**Spec criteria mapped**: SC-9 (creates template), SC-10 (reads user data)

---

## Section 17: Domain Brief Format

**Source**: System design lines 173-200

Copy the full structured format. This is referenced in spawn prompts and orchestration flow.

```
DOMAIN BRIEF: [Market Analysis | Product Strategy | Go-to-Market]
Agent: [agent name]

## Key Findings
## Data Sources Used
## Assumptions Made
## Data Gaps
## Initial Recommendations
## Questions for Other Analysts
```

**Spec criteria mapped**: SC-2 (agents produce Domain Briefs)

---

## Section 18: Cross-Reference Report Format

**Source**: System design lines 228-267

Copy the full structured format. Referenced in spawn prompts and orchestration flow.

```
CROSS-REFERENCE REPORT: [agent name]
Reviewed: [names of the two briefs reviewed]

## Contradictions Found
## Gaps Filled
## Assumptions Challenged
## Synergies Identified
## Answers to Peer Questions
## Revised Recommendations
```

**Spec criteria mapped**: SC-3 (substantive cross-referencing)

---

## Spec Success Criteria Coverage Matrix

| SC# | Criterion | SKILL.md Section(s) |
|-----|-----------|-------------------|
| SC-1 | Complete assessment with all sections, both skeptics approve | Sections 9 (Orchestration), 10 (Quality Gate), 15 (Output Template) |
| SC-2 | Collaborative Analysis executes: briefs + cross-refs + synthesis | Sections 9 (Orchestration), 17 (Domain Brief), 18 (Cross-Ref) |
| SC-3 | Substantive cross-referencing | Section 9 (Phase 2 quality check), 18 (Cross-Ref format) |
| SC-4 | Accuracy Skeptic verifies evidence tracing | Section 14d (Accuracy Skeptic prompt) |
| SC-5 | Strategy Skeptic verifies coherence + alternatives + risks | Section 14e (Strategy Skeptic prompt) |
| SC-6 | Both skeptics must approve | Section 10 (Quality Gate) |
| SC-7 | --light uses Sonnet for analysts, Opus for skeptics | Section 7 (Lightweight Mode) |
| SC-8 | status mode reports without spawning | Section 6 (Determine Mode) |
| SC-9 | Creates docs/sales-plans/ and _user-data.md template | Section 3 (Setup) |
| SC-10 | Reads and integrates _user-data.md | Section 3 (Setup), 14a-c (analyst prompts) |
| SC-11 | All business quality sections in output | Section 15 (Output Template) |
| SC-12 | CI validator passes (shared content + skeptic normalization) | Sections 12 (Shared Principles), 13 (Communication Protocol) |
| SC-13 | First-run completes with warnings and low-confidence markers | Section 3 (Setup warning), 14a-c (analyst prompts handle missing data) |
| SC-14 | Lead-driven synthesis with section-by-section + checkpoint | Section 9 (Phase 3) |

**All 14 success criteria are mapped.** No gaps.

---

## Files to Create/Modify

| File | Action | Notes |
|------|--------|-------|
| `plugins/conclave/skills/plan-sales/SKILL.md` | **Create** | This plan |
| `scripts/validators/skill-shared-content.sh` | **Modify** | Add 2 sed expressions for `strategy-skeptic`/`Strategy Skeptic` to `normalize_skeptic_names()` |
| `plugins/conclave/.claude-plugin/plugin.json` | **Modify** | Register new skill (if needed -- current plugin.json has no skills array, so may need investigation) |

---

## Key Design Decisions

1. **Communication Protocol skeptic target**: `accuracy-skeptic` (not `strategy-skeptic`) in the "Plan ready for review" row. This matches the pattern where the first/primary skeptic receives plan review requests.

2. **Phase 3 phrasing**: Must be extremely explicit that the Team Lead writes the synthesis directly. Every other SKILL.md says "delegate mode" -- this one must break that pattern clearly for Phase 3 while maintaining orchestration role for other phases.

3. **Cross-reference quality check**: Phase 2 includes explicit instruction to reject empty cross-reference reports. This is a spec constraint (SC-3) and must be in the orchestration flow, not just the spawn prompts.

4. **Context management for synthesis**: The section-by-section synthesis guidance from the system design must be included in Phase 3 instructions. Without it, the lead risks context exhaustion with 6 artifacts.

5. **Disagreement preservation**: Must be stated in both the orchestration flow (Phase 2) and the analyst spawn prompts. Disagreements flow to synthesis; they are not resolved during cross-referencing.

---

## Implementation Order

1. Create the SKILL.md file with all sections in order
2. Verify shared content blocks are byte-identical (principles) / structurally equivalent (communication protocol)
3. Run `scripts/validators/skill-shared-content.sh` to verify B1/B2/B3 pass
4. Modify `skill-shared-content.sh` to add strategy-skeptic normalization
5. Run validator again to confirm
6. Update plugin.json if registration is needed
