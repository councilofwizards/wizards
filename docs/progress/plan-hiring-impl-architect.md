---
feature: "plan-hiring"
team: "build-product"
agent: "impl-architect"
phase: "design"
status: "complete"
last_action:
  "Completed section-by-section implementation plan for plan-hiring SKILL.md"
updated: "2026-02-19T17:30:00Z"
---

# Implementation Plan: plan-hiring SKILL.md

## 1. Section List with Line Estimates

The SKILL.md follows the structural template of plan-sales/SKILL.md (1182 lines)
with Structured Debate adaptations. Estimated total: **~1450 lines**.

| #   | Section                                              | Est. Lines | Shared? | Source/Notes                                                                                                                                                                                                            |
| --- | ---------------------------------------------------- | ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | YAML frontmatter                                     | 8          | No      | name, description, argument-hint                                                                                                                                                                                        |
| 2   | H1: Hiring Plan Team Orchestration (Team Lead intro) | 12         | No      | Adapted from plan-sales L10-L20. Key difference: "Structured Debate" not "Collaborative Analysis". Lead coordinates AND synthesizes (Phase 4).                                                                          |
| 3   | Setup                                                | 22         | No      | Template from plan-sales L24-L39. Adds `docs/hiring-plans/` directory. Reads `_user-data.md`. First-run template creation.                                                                                              |
| 4   | Write Safety                                         | 10         | No      | Template from plan-sales L42-L48. Role names: researcher, growth-advocate, resource-optimizer, bias-skeptic, fit-skeptic.                                                                                               |
| 5   | Checkpoint Protocol                                  | 30         | No      | Template from plan-sales L50-L82. Phase enum: `research \| case-building \| cross-examination \| synthesis \| review \| revision \| complete`.                                                                          |
| 6   | Determine Mode                                       | 12         | No      | Template from plan-sales L84-L88. Same status/resume logic. team: "plan-hiring".                                                                                                                                        |
| 7   | Lightweight Mode                                     | 12         | No      | Template from plan-sales L90-L99. growth-advocate + resource-optimizer -> sonnet. Researcher + Bias Skeptic + Fit Skeptic stay opus.                                                                                    |
| 8   | Spawn the Team                                       | 30         | No      | 5 agents: researcher, growth-advocate, resource-optimizer, bias-skeptic, fit-skeptic. All opus. Each with Name/Model/Subagent type/Prompt ref/Tasks.                                                                    |
| 9   | Orchestration Flow (intro + ASCII diagram)           | 55         | No      | NEW. Phase diagram from system-design.md L107-L196.                                                                                                                                                                     |
| 10  | Phase 1: Research                                    | 30         | No      | NEW. Researcher gathers Hiring Context Brief. Gate 1 completeness check.                                                                                                                                                |
| 11  | Phase 2: Case Building                               | 25         | No      | NEW. Parallel case building by Growth Advocate + Resource Optimizer. Gate 2 substantive check + generalist/specialist.                                                                                                  |
| 12  | Phase 3: Cross-Examination                           | 55         | No      | NEW. Core novel section. Round 1 (3 msgs), Round 2 (3 msgs), optional Round 3. Turn orchestration. Anti-premature-agreement rules. Idle fallback. Gate 3.                                                               |
| 13  | Phase 4: Synthesis (Lead-Driven)                     | 30         | No      | NEW. Lead synthesizes debate record. 7-step synthesis process. Context management.                                                                                                                                      |
| 14  | Phase 5: Review (Dual-Skeptic)                       | 20         | No      | Adapted from plan-sales Phase 4. Bias Skeptic checklist summary + Fit Skeptic checklist summary. Gate 4: both must approve.                                                                                             |
| 15  | Phase 4b: Revise                                     | 8          | No      | Same pattern as plan-sales Phase 3b. Max 3 revision cycles.                                                                                                                                                             |
| 16  | Phase 6: Finalize                                    | 12         | No      | Adapted from plan-sales Phase 5. Output to `docs/hiring-plans/`.                                                                                                                                                        |
| 17  | Quality Gate                                         | 6          | No      | Template from plan-sales L298-L299. Both Bias Skeptic AND Fit Skeptic must approve.                                                                                                                                     |
| 18  | Failure Recovery                                     | 18         | No      | Template from plan-sales L302-L305. Adds Phase 3 idle fallback (reminder -> re-spawn -> proceed with partial record).                                                                                                   |
| 19  | Shared Principles                                    | 30         | **YES** | Byte-identical copy from plan-product/SKILL.md L145-L174. `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->` markers.                                                                              |
| 20  | Communication Protocol                               | 36         | **YES** | Structural copy from plan-product/SKILL.md L178-L213. `<!-- BEGIN SHARED: communication-protocol -->` / `<!-- END SHARED: communication-protocol -->` markers. Skeptic name adapted to `bias-skeptic` / `Bias Skeptic`. |
| 21  | Contract Negotiation omission comment                | 1          | No      | Same one-line comment as plan-sales L378.                                                                                                                                                                               |
| 22  | Teammate Spawn Prompts intro                         | 4          | No      | Same intro as plan-sales L382-L383.                                                                                                                                                                                     |
| 23  | Spawn Prompt: Researcher                             | 85         | No      | NEW content. Neutral evidence gatherer. Produces Hiring Context Brief. Reads project artifacts + user data.                                                                                                             |
| 24  | Spawn Prompt: Growth Advocate                        | 120        | No      | NEW content. Builds Growth Case from shared evidence. Includes Debate Case format + Cross-Exam formats (challenge, response, rebuttal).                                                                                 |
| 25  | Spawn Prompt: Resource Optimizer                     | 120        | No      | NEW content. Builds Efficiency Case from shared evidence. Same format templates as Growth Advocate but from efficiency perspective.                                                                                     |
| 26  | Spawn Prompt: Bias Skeptic                           | 65         | No      | NEW content. 5-item checklist (inclusive language, stereotyping, legal compliance, inclusive process, business quality). Review format.                                                                                 |
| 27  | Spawn Prompt: Fit Skeptic                            | 65         | No      | NEW content. 6-item checklist (role necessity, team composition, budget alignment, strategic fit, early-stage appropriateness, business quality). Review format.                                                        |
| 28  | Output Template                                      | 130        | No      | From system-design.md L540-L704. Full hiring plan template with frontmatter, 12 content sections + 4 business quality + 1 debate resolution.                                                                            |
| 29  | User Data Template                                   | 40         | No      | From system-design.md L716-L778. Template for `docs/hiring-plans/_user-data.md`.                                                                                                                                        |
| 30  | Hiring Context Brief Format                          | 40         | No      | From system-design.md L219-L263. Neutral evidence format produced by Researcher.                                                                                                                                        |
| 31  | Debate Case Format                                   | 40         | No      | From system-design.md L279-L318. Structured advocacy format for Growth Advocate and Resource Optimizer.                                                                                                                 |
| 32  | Cross-Examination Formats                            | 65         | No      | From system-design.md L353-L421. Challenge format + Response format + Rebuttal format (with position tracking).                                                                                                         |

**Total estimated: ~1428 lines**

## 2. Shared Content Boundaries

### Shared Principles (Section 19)

```
<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Shared Principles
...
<!-- END SHARED: principles -->
```

- **Source**: plan-product/SKILL.md lines 145-174
- **Rule**: BYTE-IDENTICAL copy. No modifications whatsoever.
- **Validator check**: B1/principles-drift (byte identity)

### Communication Protocol (Section 20)

```
<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Communication Protocol
...
<!-- END SHARED: communication-protocol -->
```

- **Source**: plan-product/SKILL.md lines 178-213
- **Rule**: Structurally equivalent after skeptic name normalization. The
  `write(product-skeptic, ...)` reference in the "Plan ready for review" row
  must use `bias-skeptic` for plan-hiring (matching the first-listed skeptic
  that receives plan review requests).
- **Validator check**: B2/protocol-drift (structural equivalence with
  normalization)

**Key observation from existing skills**: In plan-sales/SKILL.md line 359, the
"Plan ready for review" row uses `accuracy-skeptic`. In
draft-investor-update/SKILL.md line 240, it also uses `accuracy-skeptic`. In
plan-product/SKILL.md line 196, it uses `product-skeptic`. The pattern is: the
first-listed skeptic name appears in that row. For plan-hiring, this should be
`bias-skeptic` (the first-listed skeptic in the team table).

**Important**: The Shared Principles section is byte-identical (no skeptic name
references inside it). The Communication Protocol section has exactly ONE
skeptic name reference (the "Plan ready for review" row), which is the only
thing that differs per-skill and is handled by the normalizer.

## 3. New Content Outline

### Section 2: H1 + Team Lead Introduction (~12 lines)

```markdown
# Hiring Plan Team Orchestration

You are orchestrating the Hiring Plan Team. Your role is TEAM LEAD. Unlike
Collaborative Analysis or Pipeline skills, you are running a Structured Debate
-- a neutral Researcher establishes the shared evidence base, debate agents
build independent cases and cross-examine each other, and YOU synthesize the
final hiring plan. You coordinate AND write the synthesis (Phase 4 is NOT
delegate mode).

For Phases 1, 2, 3, 5, and 6 you orchestrate in delegate mode. For Phase 4
(Synthesis), you write the hiring plan directly -- leveraging the full debate
record (1 context brief + 2 cases + cross-examination messages) you witnessed.
```

### Section 3: Setup (~22 lines)

Directory list adds `docs/hiring-plans/`. Steps 1-7 match plan-sales exactly
(directories, templates, stack detection, roadmap, progress, specs,
architecture). Steps 8-10 are adapted:

- Step 8: Read `docs/hiring-plans/_user-data.md` if exists. Read prior hiring
  plans.
- Step 9: First-run convenience -- create `_user-data.md` from embedded
  template.
- Step 10: Data dependency warning if `_user-data.md` missing/empty.

### Section 4: Write Safety (~10 lines)

Same structure as plan-sales. Role-scoped files:

- `docs/progress/plan-hiring-researcher.md`
- `docs/progress/plan-hiring-growth-advocate.md`
- `docs/progress/plan-hiring-resource-optimizer.md`
- `docs/progress/plan-hiring-bias-skeptic.md`
- `docs/progress/plan-hiring-fit-skeptic.md`
- Only Team Lead writes to `docs/hiring-plans/` output files.

### Section 5: Checkpoint Protocol (~30 lines)

Same structure as plan-sales. Key difference:

- `team: "plan-hiring"`
- Phase enum:
  `research | case-building | cross-examination | synthesis | review | revision | complete`

### Section 6: Determine Mode (~12 lines)

Same structure as plan-sales:

- `status`: Read checkpoint files with `team: "plan-hiring"`.
- Empty/no args: Scan for incomplete checkpoints, resume or start new.

### Section 7: Lightweight Mode (~12 lines)

- `researcher` -> unchanged (ALWAYS Opus)
- `growth-advocate` -> sonnet
- `resource-optimizer` -> sonnet
- `bias-skeptic` -> unchanged (ALWAYS Opus)
- `fit-skeptic` -> unchanged (ALWAYS Opus)
- Output message: "Lightweight mode enabled: debate agents using Sonnet.
  Researcher and Skeptics remain Opus. Quality gates maintained."

### Section 8: Spawn the Team (~30 lines)

5 agent blocks, each with Name/Model/Subagent type/Prompt ref/Tasks:

1. Researcher (`researcher`, opus) -- Gather hiring context, produce Hiring
   Context Brief
2. Growth Advocate (`growth-advocate`, opus) -- Argue FOR hiring, build Growth
   Case, participate in cross-examination
3. Resource Optimizer (`resource-optimizer`, opus) -- Argue AGAINST premature
   hiring, build Efficiency Case, participate in cross-examination
4. Bias Skeptic (`bias-skeptic`, opus) -- Review for fairness, bias, legal
   compliance, inclusive language
5. Fit Skeptic (`fit-skeptic`, opus) -- Review for role necessity, team
   composition, budget alignment, strategic fit

### Section 9: Orchestration Flow Intro + ASCII Diagram (~55 lines)

Opening paragraph explains Structured Debate pattern: 6-phase flow. ASCII
diagram adapted from system-design.md L107-L196 (the full phase diagram).

### Section 10: Phase 1: Research (~30 lines)

- Agent: Researcher (single agent)
- Inputs: `docs/roadmap/`, `docs/specs/`, `docs/architecture/`,
  `docs/hiring-plans/_user-data.md`, `docs/hiring-plans/` (prior plans), project
  root files
- Output: Hiring Context Brief (structured format, see Format section)
- Gate 1: Team Lead verifies Brief is complete (current team, budget, roles,
  project context). Lightweight completeness check.
- Transition: Distribute Context Brief to both debate agents with position
  assignments.

### Section 11: Phase 2: Case Building (~25 lines)

- Agents: Growth Advocate + Resource Optimizer (parallel, no communication)
- Each receives Hiring Context Brief + position assignment
- Output: Debate Case (Growth Case / Efficiency Case) -- structured format
- Gate 2: Team Lead verifies both cases received, substantive, address specific
  roles, include generalist vs. specialist dimension. Straw-man cases sent back.

### Section 12: Phase 3: Cross-Examination (~55 lines)

This is the largest Orchestration Flow subsection.

- Round 1: Growth Advocate challenges Efficiency Case (3 messages)
  1. Team Lead sends Efficiency Case to Growth Advocate. GA issues Challenge.
  2. Team Lead forwards Challenge to Resource Optimizer. RO issues Response.
  3. Team Lead forwards Response to Growth Advocate. GA issues Rebuttal (last
     word).
- Round 2: Resource Optimizer challenges Growth Case (3 messages)
  1. Team Lead sends Growth Case to Resource Optimizer. RO issues Challenge.
  2. Team Lead forwards Challenge to Growth Advocate. GA issues Response.
  3. Team Lead forwards Response to Resource Optimizer. RO issues Rebuttal (last
     word).
- Round 3 (optional): Lead-directed follow-up on unresolved tensions. Max 2
  questions per agent.
- Anti-premature-agreement rules: Challenges section mandatory, concessions must
  state impact, "no concessions" must be justified, position updates tracked
  (MAINTAINED/MODIFIED/CONCEDED).
- Idle fallback: Reminder -> re-spawn with checkpoint -> proceed with partial
  record.
- Gate 3: Team Lead verifies substantive engagement. Wholesale agreement
  flagged.

### Section 13: Phase 4: Synthesis (~30 lines)

- Agent: Team Lead (NOT delegate mode)
- 7-step synthesis process (from system-design.md):
  1. Start from shared evidence (Hiring Context Brief)
  2. Identify points of agreement (consensus recommendations)
  3. Identify surviving arguments (position tracking + Remaining Tensions)
  4. Resolve genuine disagreements (weigh evidence quality; conditional if
     equal)
  5. Integrate concessions
  6. Preserve debate context (source attribution: growth/efficiency/consensus)
  7. Write the Debate Resolution Summary
- Context management: Synthesize role by role. Checkpoint if context degrades.
- Output: Draft Hiring Plan.

### Section 14: Phase 5: Review (~20 lines)

- Agents: Bias Skeptic + Fit Skeptic (parallel)
- Both receive Draft Hiring Plan AND all source artifacts
- Bias Skeptic: 5-item checklist (inclusive language, stereotyping, legal
  compliance, inclusive process, business quality)
- Fit Skeptic: 6-item checklist (role necessity, team composition, budget
  alignment, strategic fit, early-stage appropriateness, business quality)
- Gate 4: BOTH must approve. Either rejects -> Phase 4b.

### Section 15: Phase 4b: Revise (~8 lines)

- Team Lead revises synthesis with all skeptic feedback
- Documents what changed and why
- Returns to Gate 4. Max 3 revision cycles before escalation.

### Section 16: Phase 6: Finalize (~12 lines)

When both skeptics approve:

1. Write final hiring plan to `docs/hiring-plans/{date}-hiring-plan.md`
2. Write progress summary to `docs/progress/plan-hiring-summary.md`
3. Write cost summary to `docs/progress/plan-hiring-{date}-cost-summary.md`
4. Output final hiring plan to user with review instructions.

### Section 17: Quality Gate (~6 lines)

NO hiring plan finalized without BOTH Bias Skeptic AND Fit Skeptic approval.
Non-negotiable. Max 3 revision cycles before escalation to human operator.

### Section 18: Failure Recovery (~18 lines)

Standard 3 patterns from plan-sales:

1. **Unresponsive agent**: Re-spawn role, re-assign pending tasks.
2. **Skeptic deadlock**: EITHER skeptic rejects 3 times -> STOP. Escalate to
   human with summary of submissions, both skeptics' objections, and attempts to
   address.
3. **Context exhaustion**: Read checkpoint file, re-spawn with checkpoint
   context.

Plus Phase 3 specific idle fallback (already embedded in Phase 3 description):

- Cross-examination idle: Reminder -> re-spawn with checkpoint -> proceed with
  debate record as-is. Missing response = challenge stands uncontested. Missing
  rebuttal = round ends without last word. Both noted in synthesis.

### Section 23: Spawn Prompt -- Researcher (~85 lines)

```
You are the Researcher on the Hiring Plan Team.

YOUR ROLE: Investigate the hiring context. Gather neutral evidence about the current team,
budget, roles under consideration, growth context, and efficiency context. Your findings
establish the shared evidence base that both debate agents argue from -- be thorough,
neutral, and cite everything.

CRITICAL RULES:
- Every finding must cite a specific file path or user-data section as evidence.
- Distinguish verified facts from inferences. Label confidence: H/M/L.
- You are NEUTRAL. Do not advocate for or against hiring.
- If you can't find evidence, say so explicitly. Never fabricate.
- Flag all data gaps.

WHAT YOU INVESTIGATE:
[Same file list as system-design.md Phase 1 inputs]

USER DATA HANDLING:
[Same graceful degradation rules as plan-sales user data handling]

PHASE 1 OUTPUT -- HIRING CONTEXT BRIEF:
[Full Hiring Context Brief format from system-design.md L219-L263]

COMMUNICATION:
- Send Hiring Context Brief to Team Lead when complete
- Respond promptly to questions
- If you discover something urgent, message Team Lead immediately

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-hiring-researcher.md
- NEVER write to docs/hiring-plans/
- Checkpoint after: task claimed, research started, Brief sent
```

### Section 24: Spawn Prompt -- Growth Advocate (~120 lines)

```
You are the Growth Advocate on the Hiring Plan Team.

YOUR ROLE: Argue FOR hiring. Build the strongest evidence-based case for expanding
the team. Your job is to surface team gaps, growth bottlenecks, competitive pressure,
and talent market timing. You are not "pro-hiring at all costs" -- you argue for
hiring where the evidence supports it and concede where it doesn't.

CRITICAL RULES:
- Build your case from the Hiring Context Brief (shared evidence base).
- You may read project files directly for additional detail, but the Brief is primary.
- Every argument must cite evidence. No unsourced advocacy.
- Address the generalist vs. specialist dimension for EACH role.
- During Phase 2 (Case Building), do NOT communicate with the Resource Optimizer.
- During Phase 3 (Cross-Examination), engage substantively. Challenges with only
  agreements are rejected.

YOUR POSITION: Argue that the company should invest in people where the evidence
supports it. Surface: team gaps, growth bottlenecks, competitive talent pressure,
cost of NOT hiring (burnout, key-person risk, missed opportunities).

PHASE 2 OUTPUT -- DEBATE CASE:
[Full Debate Case format from system-design.md]

PHASE 3 -- CROSS-EXAMINATION:
You participate in two rounds:

Round 1 (YOU ARE CHALLENGER): You receive the Efficiency Case.
- Issue Challenge (Challenge format)
- Receive Response from Resource Optimizer
- Issue Rebuttal with position tracking (Rebuttal format) -- you get last word

Round 2 (YOU ARE DEFENDER): Resource Optimizer challenges your Growth Case.
- Receive Challenge from Resource Optimizer
- Issue Response (Response format)
- Receive Rebuttal from Resource Optimizer

[Challenge format from system-design.md L353-L375]
[Response format from system-design.md L380-L396]
[Rebuttal format from system-design.md L398-L421]

Anti-premature-agreement rules:
- Challenges section is mandatory. Cannot submit only agreements.
- Concessions must include impact on overall position.
- "No concessions" and "No agreements" are valid but must be justified.

COMMUNICATION:
- Send Debate Case to Team Lead when Phase 2 complete
- Send Challenge/Response/Rebuttal to Team Lead during Phase 3
- Respond promptly to Team Lead orchestration messages

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-hiring-growth-advocate.md
- NEVER write to docs/hiring-plans/
- Checkpoint after: task claimed, case building started, Debate Case sent,
  each cross-exam message sent
```

### Section 25: Spawn Prompt -- Resource Optimizer (~120 lines)

Same structure as Growth Advocate but from the efficiency perspective:

```
You are the Resource Optimizer on the Hiring Plan Team.

YOUR ROLE: Argue for efficiency and alternatives to premature hiring. Build the
strongest evidence-based case for doing more with less. Surface: runway constraints,
contractor/outsource alternatives, automation potential, risks OF hiring (overhead,
mis-hires, premature scaling). You are not "anti-hiring" -- you argue for alternatives
where they exist and concede where hiring is clearly necessary.

[Same CRITICAL RULES, same Phase 2/3 format templates]

Round 1 (YOU ARE DEFENDER): Growth Advocate challenges your Efficiency Case.
- Receive Challenge from Growth Advocate
- Issue Response (Response format)
- Receive Rebuttal from Growth Advocate

Round 2 (YOU ARE CHALLENGER): You challenge the Growth Case.
- Receive Growth Case
- Issue Challenge (Challenge format)
- Receive Response from Growth Advocate
- Issue Rebuttal with position tracking (Rebuttal format) -- you get last word

[Same format templates, communication, write safety]
```

### Section 26: Spawn Prompt -- Bias Skeptic (~65 lines)

```
You are the Bias Skeptic on the Hiring Plan Team.

YOUR ROLE: Review the hiring plan for fairness, inclusive language, legal compliance,
and unconscious bias. Nothing passes without your explicit approval.

CRITICAL RULES:
- You MUST be explicitly asked to review.
- Work through every item on your checklist.
- Approve or reject. No "probably fine."
- When rejecting, provide SPECIFIC, ACTIONABLE feedback.
- You receive the draft hiring plan AND all source artifacts (1 Context Brief +
  2 Debate Cases + cross-examination messages).

YOUR CHECKLIST (5 items + business quality):
1. Role descriptions are inclusive (no gendered/age-coded/culturally exclusionary language;
   must-have vs. nice-to-have distinguished)
2. Team composition analysis avoids stereotyping (culture fit = skills and working style,
   not demographics)
3. Legal compliance surface (flag anything a compliance officer would question)
4. Inclusive hiring process (structured interviews, consistent criteria, diverse sourcing)
5. Business quality checklist (assumptions stated, confidence justified, falsification
   triggers specific, unknowns acknowledged)

YOUR REVIEW FORMAT:
  BIAS REVIEW: Hiring Plan
  Verdict: APPROVED / REJECTED
  [standard review format]

COMMUNICATION:
- Send review to Team Lead
- Coordinate with Fit Skeptic -- discuss shared concerns, submit independent verdicts
- If critical bias issue found, message Team Lead immediately

WRITE SAFETY:
- Write progress ONLY to docs/progress/plan-hiring-bias-skeptic.md
- Checkpoint after: review request received, review in progress, verdict submitted
```

### Section 27: Spawn Prompt -- Fit Skeptic (~65 lines)

```
You are the Fit Skeptic on the Hiring Plan Team.

YOUR ROLE: Review the hiring plan for role necessity, team composition balance,
budget alignment, strategic fit, and early-stage appropriateness.
Nothing passes without your explicit approval.

YOUR CHECKLIST (6 items + business quality):
1. Role necessity justified (build/hire/outsource alternatives genuinely evaluated)
2. Team composition balanced (no redundancy, gaps addressed, sequencing logical)
3. Budget alignment (compensation + timelines fit stated budget/runway)
4. Strategic fit (hires align with growth targets and product roadmap)
5. Early-stage appropriateness (feasible for a startup)
6. Business quality checklist (framing credible, projections grounded in evidence)

YOUR REVIEW FORMAT:
  FIT REVIEW: Hiring Plan
  Verdict: APPROVED / REJECTED
  [standard review format]

[Same communication, write safety pattern]
```

### Sections 28-32: Format Templates

These are the reference format sections at the end of the SKILL.md (after the
spawn prompts), following the same pattern as plan-sales which has Output
Template, User Data Template, Domain Brief Format, and Cross-Reference Report
Format at the end.

For plan-hiring:

- **Output Template** (Section 28, ~130 lines): Full hiring plan template from
  system-design.md L540-L704.
- **User Data Template** (Section 29, ~40 lines): From system-design.md
  L716-L778.
- **Hiring Context Brief Format** (Section 30, ~40 lines): From system-design.md
  L219-L263.
- **Debate Case Format** (Section 31, ~40 lines): From system-design.md
  L279-L318.
- **Cross-Examination Formats** (Section 32, ~65 lines): Challenge + Response +
  Rebuttal from system-design.md L353-L421.

## 4. Agent Spawn Prompts Outline

### 4.1 Researcher

- **Role**: Neutral evidence gatherer. Does NOT advocate.
- **Key difference from plan-sales analysts**: Single researcher (not 3 parallel
  analysts). Produces ONE shared Hiring Context Brief (not domain-specific
  briefs).
- **Key difference from draft-investor-update researcher**: Focus is on
  hiring-relevant evidence (team, budget, roles, growth/efficiency context), not
  temporal metrics.
- **Inputs**: Same file list as other skills + `docs/hiring-plans/_user-data.md`
- **Output**: Hiring Context Brief (format embedded in prompt)
- **Communication**: Report to Team Lead only. No inter-agent communication.
- **Write Safety**: `docs/progress/plan-hiring-researcher.md`
- **Shutdown timing**: Can be shut down after Phase 1 (before debate phases).

### 4.2 Growth Advocate

- **Role**: Argue FOR hiring from the shared evidence base.
- **Phase 2 behavior**: Build Growth Case independently (no communication with
  Resource Optimizer).
- **Phase 3 behavior**: Round 1 challenger (challenges Efficiency Case, gets
  last word). Round 2 defender (responds to Resource Optimizer's challenges).
- **Format templates embedded**: Debate Case format, Challenge format, Response
  format, Rebuttal format.
- **Cross-cutting concern**: Must address generalist vs. specialist for each
  role.
- **Anti-premature-agreement**: Challenges mandatory, concessions must state
  impact.
- **Write Safety**: `docs/progress/plan-hiring-growth-advocate.md`

### 4.3 Resource Optimizer

- **Role**: Argue for efficiency and alternatives to premature hiring.
- **Phase 2 behavior**: Build Efficiency Case independently (no communication
  with Growth Advocate).
- **Phase 3 behavior**: Round 1 defender (responds to Growth Advocate's
  challenges). Round 2 challenger (challenges Growth Case, gets last word).
- **Same format templates as Growth Advocate** but from efficiency perspective.
- **Cross-cutting concern**: Must address generalist vs. specialist for each
  role.
- **Write Safety**: `docs/progress/plan-hiring-resource-optimizer.md`

### 4.4 Bias Skeptic

- **Role**: Review for fairness, bias, inclusive language, legal compliance.
- **5-item checklist** (from spec Phase 5, Bias Skeptic Checklist):
  1. Inclusive role descriptions
  2. Stereotyping avoidance in team composition
  3. Legal compliance surface
  4. Inclusive hiring process recommendations
  5. Business quality checklist
- **Review format**: `BIAS REVIEW: Hiring Plan` / `Verdict: APPROVED / REJECTED`
- **Write Safety**: `docs/progress/plan-hiring-bias-skeptic.md`
- **Note**: This is a NEW skeptic specialization. No precedent in existing
  skills.

### 4.5 Fit Skeptic

- **Role**: Review for role necessity, team composition, budget, strategic fit.
- **6-item checklist** (from spec Phase 5, Fit Skeptic Checklist):
  1. Role necessity justified
  2. Team composition balanced
  3. Budget alignment
  4. Strategic fit
  5. Early-stage appropriateness
  6. Business quality checklist
- **Review format**: `FIT REVIEW: Hiring Plan` / `Verdict: APPROVED / REJECTED`
- **Write Safety**: `docs/progress/plan-hiring-fit-skeptic.md`
- **Note**: This is a NEW skeptic specialization. No precedent in existing
  skills.

## 5. Skeptic Name Mapping

### Communication Protocol Table

The "Plan ready for review" row in the Communication Protocol table will use
`bias-skeptic` and `Bias Skeptic`:

```
| Plan ready for review | `write(bias-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Bias Skeptic |
```

This follows the pattern where the first-listed skeptic appears in the table
row:

- plan-product: `product-skeptic` / `Product Skeptic`
- plan-sales: `accuracy-skeptic` / `Accuracy Skeptic`
- draft-investor-update: `accuracy-skeptic` / `Accuracy Skeptic`
- **plan-hiring**: `bias-skeptic` / `Bias Skeptic`

### Normalization Scope

The normalizer must handle both the kebab-case slug and the display name for
both new skeptics:

- `bias-skeptic` -> `SKEPTIC_NAME`
- `Bias Skeptic` -> `SKEPTIC_NAME`
- `fit-skeptic` -> `SKEPTIC_NAME`
- `Fit Skeptic` -> `SKEPTIC_NAME`

These names may appear in:

- The Communication Protocol table (Section 20)
- Spawn prompts (Sections 26-27) -- but spawn prompts are NOT inside shared
  content markers, so normalization only matters for the shared Communication
  Protocol block.

## 6. Validator Changes

### File: `scripts/validators/skill-shared-content.sh`

Add 4 new sed expressions to the `normalize_skeptic_names()` function (lines
51-65).

Insert after the existing `strategy-skeptic` / `Strategy Skeptic` entries (lines
63-64):

```bash
-e 's/bias-skeptic/SKEPTIC_NAME/g' \
-e 's/Bias Skeptic/SKEPTIC_NAME/g' \
-e 's/fit-skeptic/SKEPTIC_NAME/g' \
-e 's/Fit Skeptic/SKEPTIC_NAME/g'
```

The full function after modification:

```bash
normalize_skeptic_names() {
    sed \
        -e 's/product-skeptic/SKEPTIC_NAME/g' \
        -e 's/quality-skeptic/SKEPTIC_NAME/g' \
        -e 's/ops-skeptic/SKEPTIC_NAME/g' \
        -e 's/accuracy-skeptic/SKEPTIC_NAME/g' \
        -e 's/narrative-skeptic/SKEPTIC_NAME/g' \
        -e 's/Product Skeptic/SKEPTIC_NAME/g' \
        -e 's/Quality Skeptic/SKEPTIC_NAME/g' \
        -e 's/Ops Skeptic/SKEPTIC_NAME/g' \
        -e 's/Accuracy Skeptic/SKEPTIC_NAME/g' \
        -e 's/Narrative Skeptic/SKEPTIC_NAME/g' \
        -e 's/strategy-skeptic/SKEPTIC_NAME/g' \
        -e 's/Strategy Skeptic/SKEPTIC_NAME/g' \
        -e 's/bias-skeptic/SKEPTIC_NAME/g' \
        -e 's/Bias Skeptic/SKEPTIC_NAME/g' \
        -e 's/fit-skeptic/SKEPTIC_NAME/g' \
        -e 's/Fit Skeptic/SKEPTIC_NAME/g'
}
```

## 7. Success Criteria Mapping

| SC# | Criterion                                                                                                 | SKILL.md Section(s)                                                                                                                                                 |
| --- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Complete hiring plan with all sections, both skeptics approving                                           | Sections 14, 16, 17 (Phase 5 Review, Phase 6 Finalize, Quality Gate) + Section 28 (Output Template)                                                                 |
| 2   | Structured Debate protocol executes (Research -> Case Build -> Cross-Exam -> Synthesis)                   | Sections 10-13 (Phases 1-4)                                                                                                                                         |
| 3   | Hiring Context Brief establishes shared evidence base for both debaters                                   | Section 10 (Phase 1) + Section 23 (Researcher Prompt) + Section 30 (Brief Format)                                                                                   |
| 4   | Cross-examination contains substantive challenges with position tracking                                  | Section 12 (Phase 3) + Sections 24-25 (Debate Agent Prompts) + Section 32 (Cross-Exam Formats)                                                                      |
| 5   | Points of Agreement captured in challenge format, flow to consensus                                       | Section 12 (Phase 3 anti-agreement rules) + Section 32 (Challenge Format -- Points of Agreement section)                                                            |
| 6   | Remaining Tensions captured in rebuttal format                                                            | Section 32 (Rebuttal Format -- Remaining Tensions section) + Section 13 (Phase 4 synthesis step 3)                                                                  |
| 7   | Debate Resolution Summary makes synthesis transparent                                                     | Section 13 (Phase 4 synthesis step 7) + Section 28 (Output Template -- Debate Resolution Summary section)                                                           |
| 8   | Bias Skeptic verifies inclusive language, bias-free requirements, structured process, legal compliance    | Section 14 (Phase 5) + Section 26 (Bias Skeptic Prompt -- 5-item checklist)                                                                                         |
| 9   | Fit Skeptic verifies role necessity, team composition, budget, strategic fit, early-stage appropriateness | Section 14 (Phase 5) + Section 27 (Fit Skeptic Prompt -- 6-item checklist)                                                                                          |
| 10  | Both skeptics must approve before finalization                                                            | Section 14 (Gate 4) + Section 17 (Quality Gate)                                                                                                                     |
| 11  | `--light` uses Sonnet for debate agents, keeps Skeptics+Researcher at Opus                                | Section 7 (Lightweight Mode)                                                                                                                                        |
| 12  | `status` reports session progress without spawning agents                                                 | Section 6 (Determine Mode)                                                                                                                                          |
| 13  | Skill creates `docs/hiring-plans/` and `_user-data.md` template on first run                              | Section 3 (Setup -- steps 1, 9)                                                                                                                                     |
| 14  | Skill reads and integrates `docs/hiring-plans/_user-data.md`                                              | Section 3 (Setup -- step 8) + Section 23 (Researcher Prompt -- USER DATA HANDLING)                                                                                  |
| 15  | Output includes all 4 mandatory business quality sections                                                 | Section 28 (Output Template -- Assumptions, Confidence, Falsification, External Validation)                                                                         |
| 16  | CI validator passes (shared content drift check with skeptic name normalization)                          | Section 19 (Shared Principles) + Section 20 (Communication Protocol) + Validator Changes (Section 6 of this plan)                                                   |
| 17  | First run with no data completes with low-confidence markers                                              | Section 3 (Setup -- step 10) + Section 23 (Researcher Prompt -- graceful degradation)                                                                               |
| 18  | Lead-driven synthesis handles context via role-by-role synthesis with checkpoint recovery                 | Section 13 (Phase 4 -- context management paragraph)                                                                                                                |
| 19  | Cross-examination round ordering is symmetric (each side: 1 challenger round + 1 defender round)          | Section 12 (Phase 3 -- Round 1 and Round 2 structure)                                                                                                               |
| 20  | Both debate agents address generalist vs. specialist for each role                                        | Section 11 (Phase 2 -- Gate 2 check) + Sections 24-25 (Debate Agent Prompts -- CRITICAL RULES) + Section 31 (Debate Case Format -- Generalist vs. Specialist field) |

## 8. Key Design Decisions for the Engineer

### 8.1 Communication Protocol Skeptic Name

Use `bias-skeptic` in the "Plan ready for review" row. This is the first-listed
skeptic and follows the established pattern.

### 8.2 Lightweight Mode Scope

The spec says `--light` affects "Debate agents (Growth Advocate, Resource
Optimizer)" and keeps "both Skeptics and Researcher at Opus" (SC #11). However,
the system-design.md L1080 says "Researcher + Debate agents -> sonnet". The spec
is the authority and says Researcher stays Opus. **Follow the spec: only Growth
Advocate and Resource Optimizer switch to Sonnet. Researcher remains Opus.**

Wait -- re-reading spec line 237: "--light: Debate agents (Growth Advocate,
Resource Optimizer) use Sonnet instead of Opus. Researcher and Skeptics remain
Opus." This is clear. Researcher stays Opus.

But the system-design.md L1080 says "Researcher + Debate agents -> sonnet;
Skeptics stay opus." This contradicts the spec.

**Resolution**: The spec is authoritative. **Researcher remains Opus in
`--light` mode.** Only Growth Advocate and Resource Optimizer switch to Sonnet.

### 8.3 Debate Agent Prompt Length

Each debate agent prompt includes 3 format templates (Debate Case,
Challenge/Response/Rebuttal for their role). This is necessary because the
agents need the format templates during both Phase 2 and Phase 3, and they may
be re-spawned with checkpoint context. Keeping templates in the prompt ensures
they are always available.

### 8.4 No Contract Negotiation Pattern

Like plan-sales, the Contract Negotiation Pattern is omitted with a one-line
comment:
`<!-- Contract Negotiation Pattern omitted -- not relevant to plan-hiring. See build-product/SKILL.md. -->`

### 8.5 Section Ordering After Spawn Prompts

Follow plan-sales ordering: Output Template -> User Data Template -> artifact
format sections. For plan-hiring: Output Template -> User Data Template ->
Hiring Context Brief Format -> Debate Case Format -> Cross-Examination Formats.

### 8.6 HR separators

Follow plan-sales pattern: `---` horizontal rules placed:

- Between Failure Recovery and Shared Principles (before shared content)
- Between Shared Principles and Communication Protocol (matching plan-product)
- After Communication Protocol (after shared content)
- After Contract Negotiation omission comment / before Teammate Spawn Prompts
- Before Output Template
- Before User Data Template
- Between each format section
