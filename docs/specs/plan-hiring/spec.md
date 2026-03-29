---
title: "Hiring Planning Skill (/plan-hiring)"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "product-skeptic"
created: "2026-02-19"
updated: "2026-02-19"
---

# Hiring Planning (`/plan-hiring`) Specification

## Summary

A multi-agent Structured Debate skill that produces a hiring plan for early-stage startups. A neutral Researcher
establishes the shared evidence base, then two debate agents argue opposing perspectives on hiring strategy (growth vs.
efficiency), cross-examine each other's cases through structured rounds, and a neutral lead synthesizes the debate into
a unified hiring plan validated by dual-skeptic review (Bias Skeptic + Fit Skeptic). This is the third business skill in
the conclave framework and the first to implement the Structured Debate consensus pattern from the business skill design
guidelines.

## Problem

Early-stage startup founders make hiring decisions ad-hoc without structured analysis of trade-offs. Decisions about
roles, timing, compensation, and team composition are based on gut instinct rather than systematic evaluation. The
result is costly mis-hires, suboptimal team composition, premature scaling, or missed talent opportunities.

Key pain points:

- **Premature consensus**: Hiring discussions tend to converge on "yes, hire" without rigorously examining whether
  contractors, automation, or reprioritization could achieve the same goal. Existing multi-agent patterns (Collaborative
  Analysis, Pipeline) mitigate consensus through cross-referencing but do not force agents into opposing positions.
- **Hidden trade-offs**: Every hiring decision involves genuine tension between investing in people (growth) and
  preserving flexibility (efficiency). These trade-offs are often resolved implicitly rather than through explicit
  evidence-based argumentation.
- **Bias risk**: Hiring decisions are uniquely susceptible to unconscious bias in role definitions, requirements
  language, and team composition assumptions. No existing skill has a dedicated bias review gate.
- **No structured framework**: Founders evaluate roles independently without cross-referencing insights across growth
  strategy, resource efficiency, and team composition analysis.

Evidence:

- The business skill design guidelines (`docs/architecture/business-skill-design-guidelines.md`) assign `/plan-hiring`
  to the Structured Debate pattern and define dual-skeptic assignments: Bias Skeptic (fairness, legal compliance,
  inclusive language) + Fit Skeptic (role necessity, team composition, budget alignment).
- Review Cycle 6 cleared P3-14 to spec, with P3-10 implementation lessons extracted for incorporation.
- The Structured Debate pattern has not been implemented in any existing skill. This is the pathfinder implementation.

## Solution

### Architecture

This is a **multi-agent Structured Debate skill** -- adversarial argumentation with structured cross-examination and
neutral synthesis. Unlike Collaborative Analysis (parallel cooperation in `/plan-sales`) or Pipeline (sequential
handoffs in `/draft-investor-update`), Structured Debate requires agents to:

1. **Take assigned positions** on the hiring question (growth-oriented vs. efficiency-oriented)
2. **Build independent cases** with evidence backing their perspective, from a shared evidence base
3. **Cross-examine each other** -- directly challenge the opposing case via SendMessage
4. **Skeptic judging** -- skeptics review the full debate record for bias and fit
5. **Neutral synthesis** -- the lead integrates the strongest arguments from both sides, preserving genuine
   disagreements

See [System Design](../../architecture/plan-hiring-system-design.md) for the full architecture.

### Agent Team

| Role               | Name                 | Model | Responsibility                                                                                         |
| ------------------ | -------------------- | ----- | ------------------------------------------------------------------------------------------------------ |
| Team Lead          | (invoking agent)     | opus  | Orchestrate phases, assign positions, manage cross-examination turns, synthesize hiring plan           |
| Researcher         | `researcher`         | opus  | Gather neutral hiring context: current team, budget, roles, market data. Produce Hiring Context Brief  |
| Growth Advocate    | `growth-advocate`    | opus  | Argue FOR hiring: team gaps, growth bottlenecks, competitive pressure, talent market timing            |
| Resource Optimizer | `resource-optimizer` | opus  | Argue AGAINST premature hiring: efficiency gains, outsourcing options, automation, runway preservation |
| Bias Skeptic       | `bias-skeptic`       | opus  | Review for fairness, legal compliance, inclusive language, unconscious bias in role definitions        |
| Fit Skeptic        | `fit-skeptic`        | opus  | Review for role necessity, team composition balance, budget alignment, strategic fit                   |

**Agent name resolution**: The researcher proposed "Sustainability Advocate" and the architect proposed "Resource
Optimizer" for the efficiency-side debater. "Resource Optimizer" is the chosen name because it is more specific and less
ideological. "Sustainability" is vague (sustainable how?). "Resource Optimizer" clearly signals: find the most efficient
way to address the need, which may or may not involve hiring. This agent is NOT "anti-hiring" -- it argues for
alternatives where they exist and concedes where hiring is clearly necessary.

**Why a separate Researcher agent**: The initial architecture draft omitted the Researcher, arguing that "research IS
advocacy" and selective evidence gathering is a feature. This was reversed after skeptic review. The Researcher is
included because:

1. **Shared evidence base prevents evidence-shopping.** Without a neutral Researcher, each debater reads the same
   project files but extracts different facts to support their position. This is confirmation bias, not rigorous
   argumentation. The Researcher ensures both sides argue from the same facts, forcing the debate onto interpretation
   and strategy.
2. **Shared evidence base strengthens the adversarial dynamic.** When both sides argue from the same evidence, the
   debate produces genuine disagreement about meaning and priority. When both sides cherry-pick evidence, the debate
   devolves into evidence-shopping that cross-examination can only partially correct.
3. **Precedent**: The Researcher pattern is proven (plan-product, draft-investor-update). The Researcher gathers
   context, then the debaters use it. The Researcher does NOT participate in the debate or cross-examination.
4. **Cost is bounded**: The Researcher is only active in Phase 1 and can be shut down before the debate phases.

**Why 2 debate agents (not 3)**: Hiring decisions are fundamentally binary at the decision level ("Should we hire for
this role?" is yes/no). A third "moderate" position weakens the adversarial dynamic. The lead IS the neutral party.

**All-Opus rationale**: Both debate agents must reason about ambiguous trade-offs, construct persuasive evidence-based
arguments, and respond to cross-examination challenges. The Researcher must synthesize diverse project data. Skeptics
are always Opus per convention.

**Lead-driven synthesis rationale**: Following the plan-sales precedent (validated by P3-10 implementation), the Team
Lead synthesizes the hiring plan directly. The lead observed the full debate and has meta-context about which arguments
survived cross-examination.

### Structured Debate Protocol

The protocol is phase-gated with 6 phases.

#### Phase 1: Research (Neutral Evidence Gathering)

**Agent**: Researcher (single agent)

The Researcher gathers the hiring context from project artifacts and user-provided data. This is a neutral
evidence-gathering phase -- the Researcher does not advocate for any position.

**Inputs**: `docs/roadmap/`, `docs/specs/`, `docs/architecture/`, `docs/hiring-plans/_user-data.md`,
`docs/hiring-plans/` (prior plans), project root files.

**Output**: Hiring Context Brief -- a neutral, structured summary covering: Current Team, Budget & Runway, Roles Under
Consideration, Growth Context, Efficiency Context, Data Gaps, Evidence Index. Each section cites source files.

**Gate 1**: Team Lead verifies the Brief is complete (covers current team, budget, roles, and relevant project context).
Lightweight completeness check. If critical sections are empty, request expansion.

#### Phase 2: Case Building (Parallel, Independent)

**Agents**: Growth Advocate + Resource Optimizer (parallel, no communication)

Each agent receives the Hiring Context Brief and builds their formal case from the shared evidence base. Cases are
structured arguments, not neutral analysis.

**Output**: Each agent produces a Debate Case containing: Executive Argument, Role-by-Role Assessment (with
HIRE/DEFER/ALTERNATIVE position, evidence, generalist vs. specialist assessment, timing, confidence per role),
Supporting Evidence, Anticipated Counterarguments, Assumptions Made, Data Gaps, Key Risk If Position Not Adopted.

**Cross-cutting concern**: Generalist vs. specialist is orthogonal to the Growth vs. Efficiency axis. Both advocates
MUST address the generalist vs. specialist dimension for each role as a cross-cutting concern within their positions.
This is not subsumed by the primary debate framing.

**Gate 2**: Team Lead verifies both cases are substantive, address specific roles, and include the generalist vs.
specialist dimension. Straw-man cases are sent back for strengthening.

#### Phase 3: Cross-Examination (3-Message Rounds)

**Agents**: Growth Advocate, Resource Optimizer (sequential turns, orchestrated by Team Lead)

This is the novel phase that distinguishes Structured Debate. Agents directly challenge each other's cases, with the
Team Lead orchestrating turn order. The challenger gets the last word in each round.

**Round 1: Growth Advocate challenges Efficiency Case (3 messages)**

1. **Challenge**: Growth Advocate identifies weakest points, issues challenges with counter-evidence and specific
   questions.
2. **Response**: Resource Optimizer defends positions with evidence.
3. **Rebuttal**: Growth Advocate assesses whether responses were adequate. Gets last word.

**Round 2: Resource Optimizer challenges Growth Case (3 messages)**

1. **Challenge**: Resource Optimizer identifies weakest points, issues challenges.
2. **Response**: Growth Advocate defends positions with evidence.
3. **Rebuttal**: Resource Optimizer assesses and gets last word.

Total: 6 messages in cross-examination (3 per round).

**Round ordering**: Round 1 goes first (Efficiency Case challenged first). This creates a subtle first-mover advantage
mitigated by symmetric structure: each side gets exactly one round as challenger (with last word) and one as defender.
The SKILL.md MUST preserve this symmetry if round ordering is rearranged.

**Round 3 (optional, Lead-directed)**: If the Team Lead identifies unresolved tensions after Rounds 1-2, the lead poses
specific follow-up questions to one or both agents. Maximum 2 targeted questions per agent. Occurs ONLY if the lead
identifies specific unresolved tensions.

**Challenge format** includes:

- **Challenges section** (mandatory -- cannot submit only agreements/concessions)
- **Points of Agreement** section: Where the opposing case is valid and challenger agrees. Distinct from concessions --
  agreement means "you are right AND this doesn't weaken my case." Individual-point agreement is a strong signal for
  synthesis. Anti-convergence prevents wholesale agreement, not agreement on specific points.
- **Concessions** section: Where the opposing case weakens the challenger's position, with impact on overall position
  stated.

**Response format** includes: point-by-point responses with evidence and confidence, plus any counter-points raised.

**Rebuttal format** (challenger gets last word) includes:

- **Assessment of Responses**: Per-challenge assessment with explicit position update: MAINTAINED / MODIFIED / CONCEDED.
- **Updated Position**: Summary of positions maintained, modified, and conceded.
- **Remaining Tensions**: 2-3 bullet points of unresolved disagreements that feed directly into synthesis as high-level
  signals. This gives synthesis both per-claim tracking AND a higher-level picture of where the debate stands.

**Preventing premature agreement**:

1. Challenges section is mandatory. Submission with only agreements is rejected.
2. Concessions must include impact on overall position.
3. Position updates tracked per claim (MAINTAINED/MODIFIED/CONCEDED).
4. "No concessions" and "No agreements" are valid but must be justified.

**Agent idle fallback** (per P3-10 lesson): Reminder -> re-spawn with checkpoint context -> proceed with available
debate record. Missing rebuttal means challenge stands uncontested (noted in synthesis).

**Gate 3**: Team Lead verifies both agents engaged substantively. A cross-examination where both agents immediately
concede everything is not a debate and should be flagged.

#### Phase 4: Synthesis (Lead-Driven -- NOT Delegate Mode)

**Agent**: Team Lead

The Team Lead synthesizes the full debate record (1 Hiring Context Brief + 2 Debate Cases + cross-examination messages)
into a Draft Hiring Plan.

**Synthesis process**:

1. Start from shared evidence (Hiring Context Brief).
2. Identify points of agreement (consensus recommendations, flagged as "Consensus" in output).
3. Identify surviving arguments using position tracking (MAINTAINED/MODIFIED/CONCEDED) and Remaining Tensions.
4. Resolve genuine disagreements by weighing evidence quality. If evidence is roughly equal, present both options with
   conditions: "Hire if [X], defer if [Y]."
5. Integrate concessions into relevant sections.
6. Preserve debate context with explicit sourcing (growth perspective, efficiency perspective, or consensus).
7. Write the Debate Resolution Summary making the synthesis process transparent.

**Context management**: Synthesize role by role. If context degrades, checkpoint and continue.

#### Phase 5: Review (Dual-Skeptic)

**Agents**: Bias Skeptic + Fit Skeptic (parallel)

Both skeptics receive the Draft Hiring Plan AND all source artifacts for evidence tracing.

**Bias Skeptic checklist**:

1. Role descriptions use inclusive language (no gendered terms, age-coded language, culturally exclusionary
   requirements). Must-have vs. nice-to-have distinguished.
2. Team composition analysis avoids stereotyping. "Culture fit" focuses on skills and working style, not demographics.
3. Legal compliance surface flagged. Anything a compliance officer would question is identified.
4. Hiring process includes structured interviews, consistent evaluation criteria, diverse sourcing.
5. Business quality checklist: assumptions stated, confidence levels justified, falsification triggers specific,
   unknowns acknowledged.

**Fit Skeptic checklist**:

1. Role necessity justified. Build/hire/outsource alternatives genuinely evaluated.
2. Team composition balanced (no redundancy, gaps addressed, sequencing logical).
3. Budget alignment verified (compensation + hiring timelines fit stated budget/runway).
4. Strategic fit (hires align with growth targets and product roadmap).
5. Early-stage appropriateness (recommendations feasible for a startup).
6. Business quality checklist: framing credible, projections grounded in evidence.

**Gate 4**: BOTH skeptics must approve. If either rejects, returns to Phase 4b.

#### Phase 4b: Revise

Team Lead revises synthesis based on ALL skeptic feedback. Documents what changed and why. Returns to Gate 4. Maximum 3
revision cycles before escalation to human operator.

#### Phase 6: Finalize

When both skeptics approve, the Team Lead:

1. Writes final hiring plan to `docs/hiring-plans/{date}-hiring-plan.md`
2. Writes progress summary
3. Writes cost summary
4. Outputs final hiring plan to user

### User Data Input

Hiring planning requires significant external data. The user provides this via `docs/hiring-plans/_user-data.md`.

**Template sections**: Current Team, Budget & Runway, Growth Targets, Roles Under Consideration, Industry & Market
Context, Company Culture & Values, Constraints, Additional Context.

**Graceful degradation**:

- File missing: use project artifacts only with low-confidence markers. Create template.
- Partially filled: use available data, note gaps.
- Empty/template-only: treat as missing.

### Output Artifact Format

The hiring plan includes 12 content sections + 4 mandatory business quality sections + 1 debate resolution section = 17
sections total:

**Content sections (12)**:

1. Executive Summary
2. Team Composition Analysis (Current Team, Identified Gaps, Overlaps & Redundancies)
3. Role Prioritization (ranked table with timing, source [Consensus/Growth Case/Conditional], conditions, confidence)
4. Role Profiles (per role: priority, debate outcome, responsibilities, requirements, nice-to-have, level, compensation
   range, timing, rationale, alternative considered)
5. Hiring Process Recommendations
6. Budget Impact Analysis (quarterly breakdown, runway impact)
7. Build / Hire / Outsource Assessment
8. Strategic Risks (from both sides of the debate)
9. Recommended Next Steps

**Mandatory business quality sections (4)**: 10. Assumptions & Limitations 11. Confidence Assessment (per-section
confidence with rationale) 12. Falsification Triggers 13. External Validation Checkpoints

**Debate resolution section (1 -- new for Structured Debate)**: 14. Debate Resolution Summary -- How key disagreements
were resolved, which positions survived cross-examination, which were conceded, and the reasoning behind each
resolution. This makes the synthesis process transparent.

### Arguments

| Argument  | Effect                                                                                                               |
| --------- | -------------------------------------------------------------------------------------------------------------------- |
| (empty)   | Scan for in-progress sessions. If found, resume. Otherwise, start new plan.                                          |
| `status`  | Report on in-progress session without spawning agents.                                                               |
| `--light` | Debate agents (Growth Advocate, Resource Optimizer) use Sonnet instead of Opus. Researcher and Skeptics remain Opus. |

### CI Validator Impact

| Validator                 | Impact          | Changes Needed                                                                                                               |
| ------------------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `skill-structure.sh`      | Works as-is     | None                                                                                                                         |
| `skill-shared-content.sh` | Minor extension | Extend `normalize_skeptic_names()` with 4 new sed expressions: `bias-skeptic`/`Bias Skeptic` and `fit-skeptic`/`Fit Skeptic` |
| `spec-frontmatter.sh`     | Not applicable  | Output goes to `docs/hiring-plans/`                                                                                          |
| `roadmap-frontmatter.sh`  | Not applicable  | Skill does not modify roadmap files                                                                                          |
| `progress-checkpoint.sh`  | Works as-is     | Standard format with `team: "plan-hiring"`                                                                                   |

### New Patterns This Skill Introduces

1. **Structured Debate phases** -- 6-phase flow with assigned positions, adversarial case-building, and
   cross-examination. No existing skill has agents arguing opposing positions.
2. **Debate Cases** -- Structured advocacy artifacts where agents argue from assigned positions. Unlike Domain Briefs
   (neutral) or Research Dossiers (neutral), these are persuasive by design.
3. **Cross-Examination protocol** -- Structured turn-taking with Challenge + Response + Rebuttal formats, position
   tracking (MAINTAINED/MODIFIED/CONCEDED), Points of Agreement, Remaining Tensions, and anti-premature-agreement rules.
4. **Turn orchestration** -- Team Lead orchestrates sequential cross-examination turns (not parallel peer review).
5. **Bias Skeptic** -- New skeptic specialization focused on fairness, inclusive language, legal compliance, and
   unconscious bias.
6. **Fit Skeptic** -- New skeptic specialization focused on role necessity, team composition, budget alignment, and
   strategic fit.
7. **Debate Resolution Summary** -- Output section that makes synthesis reasoning transparent.
8. **Output directory** -- `docs/hiring-plans/` as a new artifact location.

### Pathfinder Role

This is the first Structured Debate skill. Lessons learned will inform:

- Whether the cross-examination protocol needs adjustment after real-world use
- Whether 3-message rounds produce sufficient depth or if adjustments are needed
- Whether the Researcher agent's shared evidence base meaningfully improves debate quality vs. agent-driven research
- Whether all-Opus debate agents are justified vs. a Sonnet option
- Progress toward P2-07 threshold (7/8 skills)

## Constraints

1. **Scope is early-stage startup hiring planning.** Not enterprise HR, recruiting operations, compensation
   administration, or performance management.
2. **Every claim must have evidence or be marked as an assumption.** The Bias Skeptic and Fit Skeptic reject unsourced
   claims.
3. **Both skeptics must approve.** No shortcutting the dual-skeptic gate.
4. **Maximum 3 revision cycles.** After 3 rejections, escalate to human operator.
5. **No data fabrication.** Where data is missing, state the gap with low-confidence markers.
6. **No real-time data gathering.** The skill reads project artifacts and user-provided data on disk. No API calls or
   external services.
7. **Cross-examination must be substantive.** Challenges with only agreements and no challenges are rejected.
8. **Shared content must use shared markers.** Shared Principles and Communication Protocol sections use
   `<!-- BEGIN SHARED -->` markers and are byte-identical to the authoritative source (plan-product/SKILL.md), with
   skeptic name normalization.
9. **Disagreements are preserved through synthesis.** The Team Lead documents both sides and resolution reasoning in the
   Debate Resolution Summary. Hidden disagreements are a rejection-worthy defect.
10. **Agent name is "Resource Optimizer" consistently.** No mixing with "Sustainability Advocate" or other names.
11. **Generalist vs. specialist is a cross-cutting concern.** Both debate agents must address this dimension for each
    role. It is not subsumed by the Growth vs. Efficiency axis.
12. **No legal advice.** The Bias Skeptic flags potential compliance concerns for human review. The output is not legal
    counsel.

## Out of Scope

- Enterprise HR processes (performance management, annual reviews, promotion frameworks)
- Recruiting operations (sourcing, screening, pipeline management, ATS/CRM tools)
- Compensation administration (payroll, benefits enrollment, tax implications)
- Legal compliance advice (employment law is jurisdiction-specific and requires legal counsel)
- Specific salary numbers (requires real-time market data the skill doesn't have access to)
- Visa/immigration processing
- Employee retention strategies (closer to a future `/plan-onboarding` skill)
- Firing/termination processes
- Training and development programs (beyond initial onboarding mention)
- Marketing strategy (that's `/plan-marketing`)
- Sales team hiring (that's both `/plan-hiring` output and `/plan-sales` context)
- Template customization at runtime
- Real-time market data via APIs

## Files to Modify

| File                                           | Change                                                                                                                                        |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-hiring/SKILL.md` | **Create** -- New multi-agent Structured Debate skill definition (~1200-1500 lines)                                                           |
| `scripts/validators/skill-shared-content.sh`   | **Modify** -- Extend `normalize_skeptic_names()` with 4 new sed expressions for `bias-skeptic`/`Bias Skeptic` and `fit-skeptic`/`Fit Skeptic` |

## Success Criteria

1. Running `/plan-hiring` on a project with a populated `_user-data.md` produces a complete hiring plan with all output
   sections populated and both skeptics approving.
2. The Structured Debate protocol executes: Researcher produces Hiring Context Brief (Phase 1), debate agents build
   independent cases from shared evidence (Phase 2), cross-examine each other through structured 3-message rounds (Phase
   3), and the Team Lead synthesizes (Phase 4).
3. The Hiring Context Brief establishes a shared evidence base that both debate agents reference. Neither debater relies
   solely on self-gathered evidence.
4. Cross-examination contains substantive challenges -- claims challenged with counter-evidence, specific questions
   posed, responses with evidence, and rebuttals with explicit position tracking (MAINTAINED/MODIFIED/CONCEDED).
5. Points of Agreement are captured in the challenge format. Where both debaters agree on a role, that agreement flows
   to synthesis as a consensus recommendation.
6. Remaining Tensions are captured in the rebuttal format, providing synthesis with both per-claim tracking and
   high-level signals.
7. The Debate Resolution Summary in the output makes synthesis reasoning transparent -- which positions survived
   cross-examination, which were conceded, and why the plan chose its recommendations.
8. The Bias Skeptic verifies inclusive language, bias-free requirements, structured interview process, and legal
   compliance surface before approval.
9. The Fit Skeptic verifies role necessity, team composition balance, budget alignment, strategic fit, and early-stage
   appropriateness before approval.
10. Both skeptics must approve before the hiring plan is finalized.
11. Running the skill with `--light` uses Sonnet for debate agents (Growth Advocate, Resource Optimizer) while keeping
    both Skeptics and Researcher at Opus.
12. Running the skill with `status` reports session progress without spawning agents.
13. The skill creates `docs/hiring-plans/` and `_user-data.md` template if they don't exist (first-run setup).
14. The skill reads and integrates data from `docs/hiring-plans/_user-data.md` when present.
15. The output includes all 4 mandatory business quality sections: Assumptions & Limitations, Confidence Assessment,
    Falsification Triggers, External Validation Checkpoints.
16. The CI validator passes for the new SKILL.md (shared content drift check with skeptic name normalization for
    `bias-skeptic` and `fit-skeptic`).
17. On first run (no prior plans, no user data), the skill completes with prominent data-dependency warnings and
    low-confidence markers throughout.
18. Lead-driven synthesis handles context load via role-by-role synthesis, with checkpoint recovery if context degrades.
19. Cross-examination round ordering is symmetric: each side gets exactly one round as challenger (with last word) and
    one as defender.
20. Both debate agents address the generalist vs. specialist dimension for each role as a cross-cutting concern within
    their positions.

## Architecture References

- [System Design: Hiring Planning](../../architecture/plan-hiring-system-design.md)
- [Business Skill Design Guidelines](../../architecture/business-skill-design-guidelines.md)
