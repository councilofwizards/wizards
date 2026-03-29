---
title: "Hiring Planning System Design"
status: "awaiting_review"
created: "2026-02-19"
updated: "2026-02-19"
---

# Hiring Planning (`/plan-hiring`) System Design

## Overview

A multi-agent Structured Debate skill that produces a hiring plan for early-stage startups. A neutral Researcher
establishes the shared evidence base, then debate agents are assigned distinct perspectives on hiring strategy, build
independent evidence-backed cases from that shared base, challenge each other through cross-examination, and a neutral
lead synthesizes the debate into a unified hiring plan validated by dual-skeptic review.

This is the third business skill in the conclave framework and the first to implement the Structured Debate consensus
pattern from the business skill design guidelines. It introduces adversarial position-taking — agents are assigned
perspectives they must defend with evidence, then directly challenge each other's arguments, rather than investigating
collaboratively (Collaborative Analysis) or passing work sequentially (Pipeline).

**Scope constraint:** Hiring plan for early-stage startups. Not a full HR toolkit. Not performance management,
compensation benchmarking, or recruiting pipeline management.

## Architecture Classification

This is a **multi-agent Structured Debate skill** — adversarial argumentation with structured cross-examination and
neutral synthesis. Unlike Collaborative Analysis (parallel cooperation) or Pipeline (sequential handoffs), Structured
Debate requires agents to:

1. **Take assigned positions** on the hiring question (growth-oriented vs. efficiency-oriented)
2. **Build independent cases** with evidence backing their perspective
3. **Cross-examine each other** — directly challenge the opposing case via SendMessage
4. **Skeptic judging** — skeptics review the full debate record for bias and fit
5. **Neutral synthesis** — the lead integrates the strongest arguments from both sides, preserving genuine disagreements

### How Structured Debate Differs from Existing Patterns

| Dimension                 | Hub-and-Spoke (plan-product)              | Pipeline (draft-investor-update) | Collaborative Analysis (plan-sales)              | Structured Debate (plan-hiring)                           |
| ------------------------- | ----------------------------------------- | -------------------------------- | ------------------------------------------------ | --------------------------------------------------------- |
| Agent concurrency         | Parallel, independent                     | Sequential stages                | Parallel with mid-process sharing                | Parallel case-building, then sequential cross-examination |
| Inter-agent communication | Agents report to lead only                | Artifacts passed between stages  | Agents message each other directly (cooperative) | Agents message each other directly (adversarial)          |
| Agent stance              | Neutral investigators                     | Neutral specialists              | Neutral investigators with peer review           | Assigned perspectives (advocate positions)                |
| Knowledge sharing timing  | After all agents complete                 | After each stage completes       | During analysis (partial findings)               | After case-building; cross-examination is the sharing     |
| Quality gate              | Single skeptic after aggregation          | Dual skeptic after drafting      | Dual skeptic after synthesis                     | Dual skeptic after synthesis (Bias + Fit)                 |
| Disagreement handling     | Lead resolves                             | Each stage builds on prior       | Preserved through synthesis, lead resolves       | Core mechanism — debate IS the disagreement               |
| Output construction       | Lead synthesizes from independent reports | Final stage produces output      | Lead synthesizes from cross-referenced findings  | Lead synthesizes from debate record (cases + cross-exam)  |
| Premature agreement risk  | Low (agents are independent)              | N/A (sequential)                 | Medium (agents may defer to peers)               | Low (agents are assigned to disagree)                     |

### Why Structured Debate for Hiring?

Hiring decisions are high-stakes and prone to premature consensus. A founder asking "should I hire a VP of Sales?" tends
to get a single answer rather than a rigorous exploration of tradeoffs. Structured Debate forces the system to:

1. **Surface tradeoffs explicitly.** A Growth Advocate must argue for expanding the team. A Resource Optimizer must
   argue for doing more with less. Both must present evidence. The founder sees both sides.
2. **Prevent groupthink.** In Collaborative Analysis, agents can converge too quickly — "everyone agrees we need to hire
   3 engineers" without rigorously examining whether contractors, automation, or reprioritization could achieve the same
   goal.
3. **Match the decision structure.** Hiring decisions are fundamentally about resource allocation under uncertainty. The
   two sides of every hiring decision are "invest in people now" vs. "preserve runway and flexibility." These map
   cleanly to debate positions.
4. **Produce actionable nuance.** The synthesis doesn't just say "hire 2 engineers." It says "hire 2 engineers IF
   [conditions], otherwise [alternative]" — because the debate surfaced the conditions under which each side is right.

## Agent Team

### Roles

| Role               | Name                 | Model | Responsibility                                                                                         |
| ------------------ | -------------------- | ----- | ------------------------------------------------------------------------------------------------------ |
| Team Lead          | (invoking agent)     | opus  | Orchestrate phases, assign positions, manage cross-examination turns, synthesize hiring plan           |
| Researcher         | `researcher`         | opus  | Gather neutral hiring context: current team, budget, roles, market data. Produce Hiring Context Brief  |
| Growth Advocate    | `growth-advocate`    | opus  | Argue FOR hiring: team gaps, growth bottlenecks, competitive pressure, talent market timing            |
| Resource Optimizer | `resource-optimizer` | opus  | Argue AGAINST premature hiring: efficiency gains, outsourcing options, automation, runway preservation |
| Bias Skeptic       | `bias-skeptic`       | opus  | Review for fairness, legal compliance, inclusive language, unconscious bias in role definitions        |
| Fit Skeptic        | `fit-skeptic`        | opus  | Review for role necessity, team composition balance, budget alignment, strategic fit                   |

### Team Composition Rationale

**Why 2 debate agents (not 3):**

- **Hiring decisions are fundamentally binary at the decision level:** "Should we hire for this role?" is a yes/no
  question at its core. Each role under consideration gets the same debate: expand vs. optimize. A two-sided debate maps
  to this structure cleanly.
- **3 debate positions** would require a "neutral" third position (e.g., "maybe hire, but differently"). This undermines
  the Structured Debate pattern — the purpose is to force agents into strong positions so the synthesis benefits from
  maximum tension. A "moderate" debater weakens the adversarial dynamic.

**Why these specific positions:**

- **Growth Advocate**: Represents the "invest in people" side. Argues from team gaps, growth bottlenecks, competitive
  talent pressure, and the cost of NOT hiring (missed opportunities, burnout, key-person risk). This perspective ensures
  the plan addresses real organizational needs.
- **Resource Optimizer**: Represents the "preserve flexibility" side. Argues from runway constraints,
  contractor/outsource alternatives, automation potential, and the risks OF hiring (overhead, mis-hires, premature
  scaling). This perspective ensures the plan doesn't default to "just hire more people."

These positions are NOT "pro-hiring" vs. "anti-hiring." The Resource Optimizer may recommend specific hires where the
evidence is overwhelming. The Growth Advocate may concede that some roles should be deferred. The positions are starting
stances that force thorough investigation, not rigid conclusions.

**Why a separate Researcher agent:**

The initial design omitted the Researcher, arguing that "research IS advocacy" and selective evidence gathering is a
feature. Per skeptic review, this was REVERSED. The Researcher is included because:

1. **Shared evidence base prevents evidence-shopping.** Without a neutral Researcher, each debater reads the same
   project files but extracts different facts to support their position. This is confirmation bias, not rigorous
   argumentation. The Researcher ensures both sides argue from the same facts, forcing the debate onto interpretation
   and strategy rather than "I found this fact" vs. "well I found THIS fact."

2. **Shared evidence base strengthens the adversarial dynamic.** When both sides argue from the same evidence, the
   debate produces genuine disagreement about meaning and priority. When both sides cherry-pick evidence, the debate
   devolves into evidence-shopping that cross-examination can only partially correct — the challenger may not know what
   evidence the other side ignored.

3. **Precedent**: The Researcher pattern is proven (plan-product, draft-investor-update). The Researcher gathers
   context, then the debaters use it. The Researcher does NOT participate in the debate or cross-examination.

4. **Cost is bounded**: The Researcher is only active in Phase 1 and can be shut down before the debate phases. The
   context cost of the Hiring Context Brief (one additional artifact passed to debaters) is modest.

**Why no DBA:**

There is no database, no data model, no migrations. The skill reads markdown files and user-provided data, then produces
a markdown document. A DBA role adds no value.

### Model Selection Rationale

- **Researcher (Opus)**: Must synthesize diverse project data (roadmap, specs, architecture, user data) into a coherent
  hiring context. Must identify relevant evidence without advocacy bias. Judgment-heavy research role.
- **Growth Advocate (Opus)**: Must build a persuasive, evidence-backed case for hiring, anticipate counterarguments, and
  respond to cross-examination challenges. Requires sophisticated reasoning about organizational dynamics, talent
  strategy, and tradeoff analysis. Sonnet would risk shallow cases that don't withstand scrutiny.
- **Resource Optimizer (Opus)**: Must build equally rigorous counterarguments, identify creative alternatives to hiring,
  and challenge the Growth Advocate's assumptions during cross-examination. Same reasoning intensity required.
- **Bias Skeptic (Opus)**: Must detect subtle bias in role descriptions, requirements language, and team composition
  assumptions. Must assess legal compliance implications. Reasoning-heavy adversarial role. Skeptics are always Opus.
- **Fit Skeptic (Opus)**: Must evaluate whether proposed roles genuinely address the company's needs, whether the team
  composition makes strategic sense, and whether the budget can support the plan. Requires deep strategic reasoning.
  Skeptics are always Opus.

## Structured Debate Architecture

This is the core design challenge. The business-skill-design-guidelines describe the pattern abstractly: "Agents are
assigned perspectives, each builds their case independently, cases are presented to the full team, cross-examination via
direct messages, Skeptics judge the debate, synthesis produced." This section makes it concrete.

### Phase Diagram

```
+---------------------------------------------------------------------------+
|                              /plan-hiring                                  |
|                                                                           |
|  Phase 1: RESEARCH (Neutral Evidence Gathering)                           |
|  +--------------------+                                                   |
|  |    Researcher       |  (single agent)                                  |
|  |  Gathers hiring     |                                                  |
|  |  context: team,     |                                                  |
|  |  budget, roles,     |                                                  |
|  |  market data        |                                                  |
|  +--------+-----------+                                                   |
|           |                                                               |
|           v                                                               |
|    Hiring Context Brief                                                   |
|           |                                                               |
|           v                                                               |
|  GATE 1: Lead verifies brief                                              |
|  complete (team, budget, roles)                                           |
|           |                                                               |
|  Phase 2: CASE BUILDING                                                   |
|           v                                                               |
|  +--------------------+  +--------------------+                           |
|  | Growth Advocate     |  | Resource Optimizer  |  (parallel)             |
|  | Receives Context    |  | Receives Context    |                         |
|  | Brief, builds       |  | Brief, builds       |                         |
|  | Growth Case         |  | Efficiency Case     |                         |
|  +--------+-----------+  +--------+-----------+                           |
|           |                       |                                       |
|           v                       v                                       |
|      Growth Case           Efficiency Case                                |
|           |                       |                                       |
|           +----------+------------+                                       |
|                      v                                                    |
|           GATE 2: Lead verifies both                                      |
|           cases received & substantive                                    |
|                      |                                                    |
|  Phase 3: CROSS-EXAMINATION (3-message rounds)                            |
|                      v                                                    |
|  +-------------------------------------------------------+               |
|  |  Round 1: Growth Advocate challenges Efficiency Case   |               |
|  |    1. Challenge (Growth -> Resource Optimizer)          |               |
|  |    2. Response (Resource Optimizer -> Growth)           |               |
|  |    3. Rebuttal (Growth -- last word on this round)     |               |
|  +-------------------------------------------------------+               |
|                      |                                                    |
|  +-------------------------------------------------------+               |
|  |  Round 2: Resource Optimizer challenges Growth Case    |               |
|  |    1. Challenge (Resource Optimizer -> Growth)          |               |
|  |    2. Response (Growth -> Resource Optimizer)           |               |
|  |    3. Rebuttal (Resource Optimizer -- last word)        |               |
|  +-------------------------------------------------------+               |
|                      |                                                    |
|  +-------------------------------------------------------+               |
|  |  Round 3 (optional): Lead-directed follow-up           |               |
|  |           on unresolved tensions                       |               |
|  +-------------------------------------------------------+               |
|                      |                                                    |
|           GATE 3: Lead verifies cross-exam                                |
|           substantive (not premature agreement)                           |
|                      |                                                    |
|  Phase 4: SYNTHESIS  v                                                    |
|  +--------------------------------------------+                          |
|  |  Team Lead synthesizes:                     |                          |
|  |  1 context brief + 2 cases + cross-exam     |                          |
|  |  -> Draft Hiring Plan                       |                          |
|  +---------------------+----------------------+                          |
|                         |                                                 |
|                         v  GATE 4: Dual-Skeptic Review                    |
|  Phase 5: REVIEW        |                                                 |
|  +----------------+  +----------------+                                   |
|  |   Bias          |  |   Fit          |  (parallel review)               |
|  |   Skeptic       |  |   Skeptic      |                                  |
|  +-------+--------+  +-------+--------+                                   |
|          |                   |                                            |
|          v                   v                                            |
|    Bias Verdict        Fit Verdict                                        |
|          |                   |                                            |
|          +--------+----------+                                            |
|                   v                                                       |
|            BOTH APPROVED?                                                 |
|          +--yes---+---no--+                                               |
|          v                v                                               |
|  Phase 6: FINALIZE    Phase 4b: REVISE                                    |
|  Lead writes          Lead revises synthesis                              |
|  final output         with skeptic feedback                               |
|                       (returns to GATE 4)                                 |
|                                                                           |
|  Max 3 revision cycles before escalation                                  |
+---------------------------------------------------------------------------+
```

### Phase Details

#### Phase 1: Research (Neutral Evidence Gathering)

**Agent**: Researcher (single agent)

The Researcher gathers the hiring context from project artifacts and user-provided data. This is a neutral
evidence-gathering phase -- the Researcher does not advocate for any position. The Researcher produces a shared evidence
base that both debate agents will argue from, preventing evidence-shopping and confirmation bias.

**Inputs** (Researcher reads):

- `docs/roadmap/_index.md` and individual roadmap files -- project priorities and delivery state
- `docs/specs/` -- what the product does and plans to do
- `docs/architecture/` -- technical decisions and system capabilities
- `docs/hiring-plans/_user-data.md` -- user-provided team data, budget, growth targets, roles under consideration
- `docs/hiring-plans/` -- prior hiring plans (for consistency reference)
- Project root files (README, CLAUDE.md) -- project context

**Output artifact**: The Researcher produces a **Hiring Context Brief** -- a neutral, structured summary of the
hiring-relevant evidence.

**Hiring Context Brief format:**

```
HIRING CONTEXT BRIEF
Agent: researcher

## Current Team
- [Team member/role]: [Level, tenure, key responsibilities]. Source: [file path or user data]
- ...
- Key person dependencies: [who is a single point of failure]
- Recent departures: [if any]

## Budget & Runway
- Monthly burn rate: [amount or "Not provided"]
- Runway remaining: [months or "Not provided"]
- Hiring budget: [amount or "Not provided"]
- Compensation philosophy: [from user data or "Not provided"]
Source: [file paths]

## Roles Under Consideration
For each role from user data or inferred from project artifacts:
- Role: [title]
- Source: [user-specified or inferred from {artifact}]
- Context: [Why this role appears needed based on evidence]
- Urgency signals: [evidence of urgency or lack thereof]

## Growth Context
- Revenue/customer targets: [from user data or "Not provided"]
- Product milestones requiring headcount: [from roadmap]
- Competitive pressures: [from user data or project context]
Source: [file paths]

## Efficiency Context
- Current team utilization signals: [from progress files, roadmap status]
- Automation opportunities: [from architecture, specs]
- Outsourcing potential: [from project context]
- Areas where current team may be stretched thin: [from progress files]
Source: [file paths]

## Data Gaps
- [What's missing]: [Why it matters for the hiring decision]. Confidence without this data: [H/M/L]
- ...

## Evidence Index
- [File path]: [What was extracted, relevance to hiring decisions]
- ...
```

**Gate 1**: Team Lead verifies the Hiring Context Brief is complete -- covers current team, budget, roles, and relevant
project context. This is a lightweight completeness check, not a quality review. If critical sections are empty (e.g.,
no roles identified at all), request the Researcher to expand before proceeding.

**Transition trigger**: Hiring Context Brief received and verified. Team Lead distributes it to both debate agents along
with their position assignments.

#### Phase 2: Case Building

**Agents**: Growth Advocate, Resource Optimizer (parallel)

Each agent receives the Hiring Context Brief from the Team Lead and builds their formal case from the shared evidence
base. Cases are structured arguments, not neutral analysis -- each agent advocates for their assigned perspective, but
both argue from the same facts.

**Inputs**: Both agents receive the Hiring Context Brief. They may also read project files directly for additional
detail, but the Context Brief is the primary evidence source. This ensures both sides argue from the same factual
foundation -- disagreements are about interpretation and priority, not about who found which facts.

**Output artifact**: Each agent produces a **Debate Case** -- a structured message sent to the Team Lead.

**Debate Case format:**

```
DEBATE CASE: [Growth Case | Efficiency Case]
Agent: [agent name]
Position: [1-sentence summary of the position being advocated]

## Executive Argument
<!-- 2-3 paragraph summary of the strongest version of this position -->

## Role-by-Role Assessment
For each role under consideration:
- Role: [role title]
- Position: [HIRE / DEFER / ALTERNATIVE]
- Argument: [Why this position on this specific role]
- Evidence: [File path or user data reference]
- Generalist vs. Specialist: [For this role, should the hire be a generalist or specialist? Why?]
- Timing: [When, if hire is recommended]
- Confidence: [H/M/L]

## Supporting Evidence
- [Evidence point]: [Source file or user data section]. Relevance: [How it supports the position]
- ...

## Anticipated Counterarguments
- [What the other side will likely argue]: [Pre-emptive rebuttal]. Confidence: [H/M/L]
- ...

## Assumptions Made
- [Assumption]: [Why necessary]. Impact if wrong: [assessment]
- ...

## Data Gaps
- [What's missing]: [How it affects this case]. Confidence without this data: [H/M/L]
- ...

## Key Risk If This Position Is NOT Adopted
- [Risk]: [Likelihood]. [Impact]. [Evidence]
- ...
```

**Transition trigger**: Both Debate Cases received by the Team Lead. The Team Lead performs a substantive-ness check
(Gate 2): Does each case present genuine arguments with evidence? Does each case address the specific roles under
consideration? Does each case address the generalist vs. specialist dimension for each role? A case that is vague,
unsupported, or obviously straw-manned is sent back for strengthening. This check ensures the cross-examination phase
has substantive material to work with.

#### Phase 3: Cross-Examination

**Agents**: Growth Advocate, Resource Optimizer (sequential turns, orchestrated by Team Lead)

This is the novel phase that distinguishes Structured Debate. Agents directly challenge each other's cases via
SendMessage, with the Team Lead orchestrating turn order. The challenger gets the last word in each round.

**Turn structure:**

The cross-examination follows a structured 2-round format (3 messages per round) with an optional 3rd round:

**Round 1: Growth Advocate challenges Efficiency Case (3 messages)**

1. **Challenge**: Team Lead sends the Efficiency Case to the Growth Advocate. Growth Advocate identifies the weakest
   points and issues challenges.
2. **Response**: Team Lead forwards challenges to the Resource Optimizer. Resource Optimizer defends their positions
   with evidence.
3. **Rebuttal**: Team Lead forwards response to the Growth Advocate. Growth Advocate assesses whether the response was
   adequate and gets the last word on this round.

**Round 2: Resource Optimizer challenges Growth Case (3 messages)**

1. **Challenge**: Team Lead sends the Growth Case to the Resource Optimizer. Resource Optimizer identifies the weakest
   points and issues challenges.
2. **Response**: Team Lead forwards challenges to the Growth Advocate. Growth Advocate defends their positions with
   evidence.
3. **Rebuttal**: Team Lead forwards response to the Resource Optimizer. Resource Optimizer assesses whether the response
   was adequate and gets the last word on this round.

Total: 6 messages in cross-examination (3 per round).

**Round ordering**: Round 1 goes first, meaning the Efficiency Case is challenged first. This creates a subtle
first-mover advantage -- the Growth Advocate sees the Resource Optimizer's defense before formulating their own. This is
mitigated by the symmetric structure: each side gets exactly one round as challenger (with last word) and one as
defender. The spec MUST preserve this symmetry if round ordering is rearranged.

**Round 3 (optional, Lead-directed):**

- If the Team Lead identifies unresolved tensions after Rounds 1-2 (e.g., both sides claimed contradictory facts, a
  critical role had no clear resolution), the lead poses specific follow-up questions to one or both agents
- Maximum 2 targeted questions per agent
- This round occurs ONLY if the lead identifies specific unresolved tensions, not as a routine step

**Challenge format:**

```
CHALLENGE: [agent name] -> [target case]
Round: [1 | 2]

## Challenges
1. [Claim being challenged]: "[exact quote from opposing case]"
   Challenge: [Why this claim is weak, wrong, or incomplete]
   Counter-evidence: [Evidence that contradicts or complicates the claim]. Source: [file path]
   Question: [Specific question the opponent must answer]

2. ...

## Points of Agreement
- [Claim from opposing case that is valid and I agree with]: [Why I agree]
- ...
(If none: "No points of agreement identified.")

## Concessions
- [Claim from opposing case that weakens my position]: [Why this concession is warranted]
  Impact on my position: [How this weakens or modifies my case]
- ...
(If none: "No concessions. All claims in the opposing case are contested.")
```

Note: "Points of Agreement" and "Concessions" are distinct. Agreement means "you are right AND this doesn't weaken my
case" (e.g., both sides agree a CTO hire is urgent). Concession means "you are right AND this weakens my case" (e.g.,
the Growth Advocate concedes that budget constraints make a Q1 hire unrealistic).

**Response format:**

```
RESPONSE: [agent name]
Responding to: [challenger name], Round [N]

## Responses
1. Re: "[challenged claim]"
   Response: [Defense of the claim, additional evidence, or qualified concession]
   Evidence: [Source]. Confidence: [H/M/L]

2. ...

## Counter-Points Raised
- [New point surfaced by the challenge that strengthens my position]
- ...
(If none: Section omitted.)
```

**Rebuttal format (challenger gets last word):**

```
REBUTTAL: [agent name]
Responding to: [defender name]'s response, Round [N]

## Assessment of Responses
1. Re: "[challenged claim]"
   Assessment: [Was the response adequate? Does additional evidence change my challenge?]
   Position update: [MAINTAINED / MODIFIED / CONCEDED]

2. ...

## Updated Position
Based on this cross-examination round:
- Positions maintained: [list]
- Positions modified: [list with explanation]
- Positions conceded: [list with explanation]

## Remaining Tensions
- [Tension 1]: [Brief description of unresolved disagreement and why it matters for synthesis]
- [Tension 2]: ...
(2-3 bullets maximum. These feed directly into synthesis as high-level signals.)
```

**Preventing premature agreement:**

The cross-examination format explicitly requires:

1. **Challenges section is mandatory.** A challenge submission with only agreements/concessions and no challenges is
   rejected by the Team Lead. Both cases have weaknesses -- the challenger's job is to find them.
2. **Concessions must include impact.** If an agent concedes a point, they must explain how it modifies their overall
   position. This prevents token concessions that don't affect the conclusion.
3. **Agreement on individual points is expected and valuable.** Both debaters may genuinely agree on certain roles
   (e.g., both agree the CTO hire is urgent). The "Points of Agreement" section captures this. Individual-point
   agreement is a strong signal for synthesis. Anti-convergence prevents WHOLESALE agreement, not agreement on specific
   points.
4. **"No concessions" and "No agreements" are valid responses** but must be justified. The Lead will scrutinize these to
   ensure genuine engagement, not stubbornness.
5. **Position updates are tracked.** The Rebuttal format requires agents to explicitly state whether each challenged
   position is maintained, modified, or conceded. The Lead uses this to identify convergence vs. genuine disagreement.
6. **Remaining Tensions provide synthesis signal.** The Rebuttal's "Remaining Tensions" field gives the Lead both
   per-claim tracking AND a high-level picture of where the debate stands after each round.

**What happens if an agent goes idle:**

Per P3-10 implementation lesson (quality-skeptic went idle during post-implementation review), the cross-examination
phase includes explicit fallback instructions:

1. **Timeout**: If an agent has not responded within a reasonable processing window, the Team Lead sends a reminder
   message: "REMINDER: Your [challenge/response/rebuttal] for Round [N] is overdue. Please submit or report if you are
   blocked."
2. **Second timeout**: If still no response, the Team Lead re-spawns the agent with the cross-examination context and
   their checkpoint file, requesting they continue from where they left off.
3. **Third timeout (agent presumed unrecoverable)**: The Team Lead proceeds with the debate record as-is. The synthesis
   notes that one round of cross-examination was incomplete and flags this in the Assumptions & Limitations section of
   the output. The missing agent's case still stands -- it just wasn't challenged in one direction.

**Transition trigger**: Cross-examination complete (Rounds 1-2 done, plus Round 3 if triggered). The Team Lead performs
Gate 3: verify that both agents engaged substantively (challenges issued, responses provided, rebuttals with position
tracking). A cross-examination where both agents immediately concede everything is not a debate -- it should be flagged
and the agents instructed to look harder for points of disagreement.

#### Phase 4: Synthesis (Lead-Driven -- NOT Delegate Mode)

**Agent**: Team Lead

The Team Lead synthesizes the full debate record (1 Hiring Context Brief + 2 Debate Cases + cross-examination
challenges/responses/rebuttals) into a Draft Hiring Plan. This is the one phase where the Team Lead writes content
directly (not delegate mode). The Team Lead is uniquely positioned for synthesis because they observed the full debate,
including which arguments survived cross-examination and which were conceded.

**Synthesis process:**

1. **Start from shared evidence**: The Hiring Context Brief provides the neutral factual foundation. Every claim in the
   synthesis must be traceable to the Context Brief or explicitly marked as an inference.

2. **Identify points of agreement**: Where both debaters agreed on a role (captured in "Points of Agreement" sections),
   these are strong consensus recommendations. Flag them as "Consensus" in the output.

3. **Identify surviving arguments**: For each contested role, which positions survived cross-examination? Use the
   Rebuttal position tracking (MAINTAINED/MODIFIED/CONCEDED) and "Remaining Tensions" to determine where the debate
   ended.

4. **Resolve genuine disagreements**: Where both sides maintained their positions after cross-examination, the Team Lead
   weighs the evidence quality against the Hiring Context Brief. The stronger evidence wins, but both sides are
   documented in the output. If evidence is roughly equal, the hiring plan presents both options with conditions: "Hire
   if [X], defer if [Y]."

5. **Integrate concessions**: Where agents conceded points, incorporate the concession into the relevant section. A
   concession from the Growth Advocate ("this role could be outsourced for 6 months") modifies the recommendation.

6. **Preserve debate context**: The output explicitly references which recommendations came from the growth perspective,
   which from the efficiency perspective, and which were consensus. This gives the founder visibility into the
   reasoning. The Debate Resolution Summary section makes this transparent.

7. **Write the hiring plan**: Produce the full hiring plan in the output format (see Output Artifact Format below).

**Context management**: With 1 context brief + 2 cases + 6 cross-examination messages (2 challenges + 2 responses + 2
rebuttals) + up to 4 optional Round 3 messages = 9-13 artifacts total, the context load is comparable to Collaborative
Analysis. Synthesize role by role rather than section by section. If context degrades during synthesis, write a
checkpoint to `docs/progress/plan-hiring-team-lead.md` noting the last completed section, then continue from that
section.

**Output**: Draft Hiring Plan.

**Transition trigger**: Draft hiring plan complete. Team Lead sends it to both Skeptics for review.

#### Phase 5: Review (Dual-Skeptic)

**Agents**: Bias Skeptic + Fit Skeptic (parallel)

Both skeptics receive the Draft Hiring Plan AND all source artifacts (1 Hiring Context Brief + 2 Debate Cases + all
cross-examination messages) so they can trace recommendations back to the evidence and debate.

##### Bias Skeptic Checklist

1. **Role descriptions are inclusive.** Job titles, responsibilities, and requirements avoid gendered language,
   age-coded language ("digital native"), or culturally exclusionary requirements. Requirements distinguish "must-have"
   from "nice-to-have" to prevent unnecessary credential inflation.
2. **Team composition analysis avoids stereotyping.** Assessments of "culture fit" must focus on skills and working
   style, not demographic assumptions. Recommendations should not implicitly favor or disadvantage any group.
3. **Legal compliance surface.** Are there any recommendations that could create legal liability? (e.g., age-based
   timing, location restrictions that serve as demographic proxies). Flag anything that a compliance officer would
   question.
4. **Inclusive hiring process.** Do process recommendations include structured interviews, consistent evaluation
   criteria, and diverse candidate sourcing? Do they avoid subjective "gut feel" recommendations?
5. **Business quality checklist:**
   - Are assumptions stated, not hidden?
   - Are confidence levels present and justified?
   - Are falsification triggers specific and actionable?
   - Does the output acknowledge what it doesn't know?

##### Fit Skeptic Checklist

1. **Role necessity is justified.** For each recommended hire, is the case for necessity convincing? Could the work be
   done by existing team members, contractors, or automation? Did the synthesis properly weigh the Resource Optimizer's
   alternatives?
2. **Team composition makes sense.** Does the hiring plan create a balanced team, or does it create redundancy? Are
   there gaps that the plan doesn't address? Is the sequencing of hires logical (e.g., hiring a VP of Sales before
   hiring SDRs)?
3. **Budget alignment.** Do compensation ranges and hiring timelines fit the stated budget/runway? A plan that
   recommends 5 hires on a 12-month runway with limited funding is a rejection-worthy defect.
4. **Strategic fit.** Do the recommended hires align with the company's stated growth targets and product roadmap? A
   plan to hire a marketing team when the product isn't launched is suspect.
5. **Early-stage appropriateness.** Are recommendations feasible for a startup? Recommending a full HR department or a
   10-step interview process for a 5-person company is not appropriate.
6. **Business quality checklist:**
   - Would a domain expert find the framing credible?
   - Are projections grounded in stated evidence, not optimism?

##### Review Verdicts

Each skeptic independently produces:

```
[BIAS|FIT] REVIEW: Hiring Plan
Verdict: APPROVED / REJECTED

[If rejected:]
Issues:
1. [Specific issue]: [Why it's a problem]. [Evidence reference]. Fix: [What to do]
2. ...

[If approved:]
Notes: [Any minor observations]
```

**Gate 4 rule**: BOTH skeptics must approve. If either rejects, the plan returns to Phase 4b (Revise).

#### Phase 4b: Revise

**Agent**: Team Lead

The Team Lead revises the synthesis based on skeptic feedback. The revision must address every blocking issue explicitly
-- the Team Lead documents what changed and why.

The revised draft returns to Gate 4 (both skeptics review again). Maximum 3 revision cycles before escalation to the
human operator.

#### Phase 6: Finalize

**Agent**: Team Lead

When both skeptics approve, the Team Lead:

1. Writes the final hiring plan to `docs/hiring-plans/{date}-hiring-plan.md`
2. Writes a progress summary to `docs/progress/plan-hiring-summary.md`
3. Writes a cost summary to `docs/progress/plan-hiring-{date}-cost-summary.md`
4. Outputs the final hiring plan to the user with instructions for review and implementation

## Output Artifact Format

The hiring plan follows a structured template:

```markdown
---
type: "hiring-plan"
period: "YYYY-MM-DD"
generated: "YYYY-MM-DD"
confidence: "high|medium|low"
review_status: "approved"
approved_by:
  - bias-skeptic
  - fit-skeptic
---

# Hiring Plan: {Project Name}

## Executive Summary

<!-- 3-5 sentences. The single most important hiring insight for the founder. -->
<!-- State: how many roles recommended, total budget impact, and the #1 strategic rationale. -->

## Team Composition Analysis

### Current Team

<!-- Summary of current team from user-provided data. -->
<!-- Roles, levels, tenure, key person dependencies. -->

| Role | Level | Tenure | Key Person Risk |
| ---- | ----- | ------ | --------------- |
| ...  | ...   | ...    | H/M/L           |

### Identified Gaps

<!-- Where the current team is understaffed or missing critical capabilities. -->
<!-- Sourced from both the Growth Case and user-provided data. -->

### Overlaps & Redundancies

<!-- Where the current team has redundancy. -->
<!-- Sourced from the Efficiency Case. -->

## Role Prioritization

<!-- Ordered list of recommended hires with timing. -->
<!-- Each role indicates whether it was consensus, growth-recommended, or conditional. -->

| Priority | Role | Timing  | Source                  | Conditions     | Confidence |
| -------- | ---- | ------- | ----------------------- | -------------- | ---------- |
| 1        | ...  | Q1 2026 | Consensus               | ...            | H/M/L      |
| 2        | ...  | Q2 2026 | Growth Case (contested) | If [condition] | M          |
| ...      | ...  | ...     | ...                     | ...            | ...        |

## Role Profiles

### [Role Title 1]

- **Priority**: [1-N]
- **Debate outcome**: [Consensus / Growth-recommended / Conditional]
- **Responsibilities**: [Key responsibilities]
- **Requirements**: [Must-have skills and experience]
- **Nice-to-have**: [Preferred but not required qualifications]
- **Level**: [Junior / Mid / Senior / Lead / VP]
- **Compensation range**: [Based on user data or marked as requiring user input]
- **Timing**: [When to start the search and target start date]
- **Rationale**: [Why this hire, sourced from the debate]
- **Alternative considered**: [What the Resource Optimizer proposed instead]

### [Role Title 2]

<!-- Same structure -->

## Hiring Process Recommendations

<!-- Structured interview process appropriate for the company's stage. -->
<!-- Must include: consistent evaluation criteria, diverse sourcing, structured interviews. -->
<!-- Must NOT include: subjective "culture fit" assessments, unnecessarily complex processes. -->

## Budget Impact Analysis

<!-- Total cost of recommended hires. -->
<!-- Phased by quarter to show runway impact. -->

| Quarter | New Hires | Incremental Cost | Cumulative Burn Impact |
| ------- | --------- | ---------------- | ---------------------- |
| ...     | ...       | ...              | ...                    |

### Runway Impact

<!-- How the hiring plan affects runway. -->
<!-- If runway < 12 months after plan, flag prominently. -->

## Build / Hire / Outsource Assessment

<!-- For each capability gap, assess the three options. -->

| Capability | Hire (FTE)  | Outsource (Contract) | Build (Automate) | Recommendation |
| ---------- | ----------- | -------------------- | ---------------- | -------------- |
| ...        | [pros/cons] | [pros/cons]          | [pros/cons]      | ...            |

## Strategic Risks

<!-- Risks of the recommended hiring plan AND risks of not hiring. -->
<!-- Sourced from both sides of the debate. -->

| Risk                 | Source          | Likelihood | Impact | Mitigation |
| -------------------- | --------------- | ---------- | ------ | ---------- |
| [Risk of hiring]     | Efficiency Case | H/M/L      | H/M/L  | ...        |
| [Risk of not hiring] | Growth Case     | H/M/L      | H/M/L  | ...        |
| ...                  | ...             | ...        | ...    | ...        |

## Recommended Next Steps

<!-- 3-5 specific, actionable next steps. -->
<!-- Prioritized by impact and urgency. -->

1. [Action]: [Why]. [Expected outcome]. [Timeline suggestion]
2. ...

## Debate Resolution Summary

<!-- Unique to Structured Debate. Makes the synthesis process transparent. -->
<!-- For each major disagreement between Growth Advocate and Resource Optimizer: -->
<!-- what both sides argued, how it was resolved, and why. -->

| Topic           | Growth Position              |             Efficiency Position | Resolution                 | Reasoning                                      |
| --------------- | ---------------------------- | ------------------------------: | -------------------------- | ---------------------------------------------- |
| [Role/Decision] | [Growth Advocate's position] | [Resource Optimizer's position] | [What the plan recommends] | [Why this resolution, citing evidence quality] |
| ...             | ...                          |                             ... | ...                        | ...                                            |

### Points of Consensus

<!-- Where both sides agreed. These are the strongest recommendations. -->

- [Point of agreement]: [Both sides agreed because...]
- ...

---

## Assumptions & Limitations

<!-- Mandatory per business skill design guidelines. -->
<!-- What this plan assumes to be true. What data was unavailable. -->

## Confidence Assessment

<!-- Mandatory per business skill design guidelines. -->
<!-- Per-section confidence levels with rationale. -->

| Section              | Confidence | Rationale |
| -------------------- | ---------- | --------- |
| Team Composition     | H/M/L      | ...       |
| Role Prioritization  | H/M/L      | ...       |
| Role Profiles        | H/M/L      | ...       |
| Budget Impact        | H/M/L      | ...       |
| Build/Hire/Outsource | H/M/L      | ...       |
| Strategic Risks      | H/M/L      | ...       |

## Falsification Triggers

<!-- Mandatory per business skill design guidelines. -->
<!-- What evidence would change the conclusions in this plan? -->

- If [condition], then [recommendation X] should be revised because [reason]
- ...

## External Validation Checkpoints

<!-- Mandatory per business skill design guidelines. -->
<!-- Where should a human domain expert validate this plan? -->

- [ ] Verify [specific claim] with [data source or person]
- ...
```

## User Data Input

Hiring planning requires significant external data about the current team, budget, and growth plans. The user provides
this via a template file.

### Mechanism: Template File

A template file at `docs/hiring-plans/_user-data.md` that the user populates before running the skill. The Researcher
reads this file alongside project artifacts and incorporates the data into the Hiring Context Brief.

### Template Format

```markdown
# Hiring Planning: User-Provided Data

> Fill in the sections below before running `/plan-hiring`. The more you provide, the more specific the hiring plan will
> be. Leave sections blank if not applicable -- the plan will note the gaps.

## Current Team

- Team members (role, level, tenure for each):
- Reporting structure:
- Key person dependencies:
- Recent departures:
- Current open roles:

## Budget & Runway

- Total headcount budget:
- Available hiring budget (annual):
- Current monthly burn rate:
- Runway remaining (months):
- Expected funding events:

## Growth Targets

- Revenue targets (next 12 months):
- User/customer targets:
- Product milestones that require new hires:
- Geographic expansion plans:

## Roles Under Consideration

<!-- List specific roles you're thinking about hiring for. -->
<!-- The debate agents will assess each one. -->

- Role 1: [title, why considering, urgency]
- Role 2: [title, why considering, urgency]
- ...

## Industry & Market Context

- Industry/vertical:
- Talent market conditions (competitive, abundant, etc.):
- Location (remote, hybrid, office) preference:
- Visa sponsorship capability:

## Company Culture & Values

- Core values relevant to hiring:
- Working style (async, sync, etc.):
- Diversity goals or commitments:

## Constraints

- Timeline constraints (e.g., must hire by date):
- Compensation constraints:
- Geographic constraints:
- Other constraints:

## Additional Context

<!-- Anything else relevant to hiring decisions that isn't captured above. -->
```

### Graceful Degradation

- **File missing**: The Researcher notes data gaps in the Hiring Context Brief. Plan uses project artifact data with
  explicit low-confidence markers. The skill creates the template file at `docs/hiring-plans/_user-data.md`.
- **File partially filled**: The Researcher extracts available data, notes missing fields as gaps in the Context Brief.
- **File empty/template-only**: Treated same as missing.

## Debate Case Format

Debate agents send this structured format to the Team Lead at the end of Phase 2:

```
DEBATE CASE: [Growth Case | Efficiency Case]
Agent: [agent name]
Position: [1-sentence summary of the position being advocated]

## Executive Argument
<!-- 2-3 paragraph summary of the strongest version of this position -->

## Role-by-Role Assessment
For each role under consideration:
- Role: [role title]
- Position: [HIRE / DEFER / ALTERNATIVE]
- Argument: [Why this position on this specific role]
- Evidence: [File path or user data reference]
- Generalist vs. Specialist: [For this role, should the hire be a generalist or specialist? Why?]
- Timing: [When, if hire is recommended]
- Confidence: [H/M/L]

## Supporting Evidence
- [Evidence point]: [Source file or user data section]. Relevance: [How it supports the position]
- ...

## Anticipated Counterarguments
- [What the other side will likely argue]: [Pre-emptive rebuttal]. Confidence: [H/M/L]
- ...

## Assumptions Made
- [Assumption]: [Why necessary]. Impact if wrong: [assessment]
- ...

## Data Gaps
- [What's missing]: [How it affects this case]. Confidence without this data: [H/M/L]
- ...

## Key Risk If This Position Is NOT Adopted
- [Risk]: [Likelihood]. [Impact]. [Evidence]
- ...
```

## Cross-Examination Format

Challenge, response, and rebuttal formats used during Phase 3. Each round has 3 messages; the challenger gets the last
word.

### Challenge Format (Message 1 of each round)

```
CHALLENGE: [agent name] -> [target case]
Round: [1 | 2]

## Challenges
1. [Claim being challenged]: "[exact quote from opposing case]"
   Challenge: [Why this claim is weak, wrong, or incomplete]
   Counter-evidence: [Evidence that contradicts or complicates the claim]. Source: [file path]
   Question: [Specific question the opponent must answer]

2. ...

## Points of Agreement
- [Claim from opposing case that is valid and I agree with]: [Why I agree]
- ...
(If none: "No points of agreement identified.")

## Concessions
- [Claim from opposing case that weakens my position]: [Why this concession is warranted]
  Impact on my position: [How this weakens or modifies my case]
- ...
(If none: "No concessions. All claims in the opposing case are contested.")
```

### Response Format (Message 2 of each round)

```
RESPONSE: [agent name]
Responding to: [challenger name], Round [N]

## Responses
1. Re: "[challenged claim]"
   Response: [Defense of the claim, additional evidence, or qualified concession]
   Evidence: [Source]. Confidence: [H/M/L]

2. ...

## Counter-Points Raised
- [New point surfaced by the challenge that strengthens my position]
- ...
(If none: Section omitted.)
```

### Rebuttal Format (Message 3 of each round -- challenger gets last word)

```
REBUTTAL: [agent name]
Responding to: [defender name]'s response, Round [N]

## Assessment of Responses
1. Re: "[challenged claim]"
   Assessment: [Was the response adequate? Does additional evidence change my challenge?]
   Position update: [MAINTAINED / MODIFIED / CONCEDED]

2. ...

## Updated Position
Based on this cross-examination round:
- Positions maintained: [list]
- Positions modified: [list with explanation]
- Positions conceded: [list with explanation]

## Remaining Tensions
- [Tension 1]: [Brief description of unresolved disagreement and why it matters for synthesis]
- [Tension 2]: ...
(2-3 bullets maximum. These feed directly into synthesis as high-level signals.)
```

## What Is New vs. Reusable

### Reusable from Existing Skills

| Component                         | Source                                | Adaptation Needed                                                                     |
| --------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------- | ------------- | ----------------- | --------- | ------ | -------- | --------- |
| YAML frontmatter format           | All SKILL.md files                    | New fields: `type: hiring-plan` in output                                             |
| Shared Principles section         | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers                                                   |
| Communication Protocol section    | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers; skeptic names adapted                            |
| Checkpoint Protocol               | plan-product/SKILL.md                 | Phase enum changes: `research                                                         | case-building | cross-examination | synthesis | review | revision | complete` |
| Write Safety conventions          | All SKILL.md files                    | Same pattern, different role names                                                    |
| Failure Recovery                  | All SKILL.md files                    | Same 3 patterns (unresponsive, deadlock, context exhaustion)                          |
| Lightweight Mode                  | All SKILL.md files                    | Researcher + Debate agents -> sonnet; Skeptics stay opus                              |
| Determine Mode with status/resume | All SKILL.md files                    | Same checkpoint-based resume pattern                                                  |
| Setup section                     | All SKILL.md files                    | Adds `docs/hiring-plans/` to directory list                                           |
| Business quality sections         | draft-investor-update                 | Same mandatory sections (Assumptions, Confidence, Falsification, External Validation) |
| Dual-skeptic gate                 | draft-investor-update                 | Same both-must-approve rule; different skeptic specializations                        |

### New Patterns Introduced

| Pattern                        | Description                                                                                                                                                                                                                    | Why It Is Needed                                                                                                                                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Structured Debate phases**   | 6-phase flow with neutral research, assigned positions, adversarial case-building, and 3-message cross-examination. No existing skill has agents arguing opposing positions.                                                   | First implementation of the Structured Debate consensus pattern from the design guidelines.                                                                   |
| **Hiring Context Brief**       | Neutral evidence-gathering artifact (produced by Researcher) that establishes a shared evidence base for the debate. Unlike Domain Briefs (per-agent neutral findings), this is one shared brief that all debaters argue from. | Prevents evidence-shopping -- both debaters must argue from the same facts, forcing disagreement onto interpretation rather than fact selection.              |
| **Debate Cases**               | Structured advocacy artifacts where agents argue from assigned positions rather than neutral analysis. Unlike Domain Briefs (neutral findings) or Research Dossiers (neutral data), these are persuasive by design.            | The adversarial dynamic requires agents to build the strongest version of their assigned position.                                                            |
| **Cross-Examination protocol** | Structured 3-message turn-taking (Challenge -> Response -> Rebuttal) where challenger gets last word. Includes Points of Agreement, Concessions with impact, position tracking, and Remaining Tensions.                        | This is the core mechanism that distinguishes Structured Debate. No existing skill has agents in adversarial dialogue.                                        |
| **Position tracking**          | Agents explicitly declare MAINTAINED / MODIFIED / CONCEDED for each challenged position, creating a debate resolution record. Combined with "Remaining Tensions" for high-level synthesis signal.                              | The synthesis phase needs both per-claim tracking AND a high-level picture of where the debate ended.                                                         |
| **Turn orchestration**         | Team Lead orchestrates sequential cross-examination turns (3 messages per round) rather than parallel peer review. Round 1, Round 2, optional Round 3.                                                                         | Cross-examination must be sequential -- an agent needs to see the opposing case before challenging it. Challenger gets last word to assess response adequacy. |
| **Output directory**           | `docs/hiring-plans/` as a new output location.                                                                                                                                                                                 | Hiring plans are a new artifact type that don't fit existing directory categories.                                                                            |
| **Bias Skeptic**               | New skeptic specialization focused on fairness, inclusive language, legal compliance, and unconscious bias.                                                                                                                    | Hiring has unique failure modes around bias that no other business skill shares.                                                                              |
| **Fit Skeptic**                | New skeptic specialization focused on role necessity, team composition, budget alignment, and strategic fit.                                                                                                                   | Hiring recommendations must be evaluated against organizational fit, not just accuracy or strategy.                                                           |

### Design Decision: Lead-Driven Synthesis (Following plan-sales Precedent)

Per P3-10 implementation lessons, lead-driven synthesis is the validated approach. The Team Lead synthesizes the debate
directly rather than delegating to a separate agent. Rationale:

1. **Context load**: The synthesizer must hold 2 cases + cross-examination record. The Team Lead has this context from
   orchestrating the debate. A separate agent would need all of it passed via messages.

2. **Debate resolution requires judgment**: The Lead observed which arguments survived cross-examination, which were
   conceded, and where the evidence was strongest. This meta-context is critical for fair synthesis.

3. **Fewer agents, lower cost**: The team has 1 researcher + 2 debate agents + 2 skeptics = 5 agents. Adding a
   synthesizer would bring it to 6 with marginal benefit.

4. **Precedent**: plan-sales confirmed lead-driven synthesis works for Collaborative Analysis. The context load for
   Structured Debate is comparable (1 context brief + 2 cases + 6 cross-exam messages vs. 3 briefs + 3 cross-refs).

### Design Decision: Why These Specific Debate Positions

The Growth Advocate and Resource Optimizer positions were chosen because they represent the two fundamental forces in
every hiring decision:

1. **Growth Advocate = organizational need**: Every open role exists because someone believes the organization needs
   more capability. This agent gives voice to that need with rigor.

2. **Resource Optimizer = resource discipline**: Every hire consumes runway and adds complexity. This agent forces
   honest accounting of the cost and surfaces alternatives.

These positions are NOT strawmen. Both are legitimate perspectives that a good founder holds simultaneously. The debate
externalizes this internal tension so it can be examined with evidence rather than gut instinct.

Alternative positions considered and rejected:

- **Optimistic/Conservative**: Too generic. Doesn't map to the specific tradeoffs of hiring decisions.
- **Short-term/Long-term**: Interesting but creates a false dichotomy. Both perspectives already consider timing within
  their arguments.
- **Technical/Business**: Only relevant for technical hires. The skill must handle all types of roles.

### Design Decision: Agent Idle Fallback

Per P3-10 lesson (quality-skeptic went idle during review), every phase that depends on agent response includes explicit
timeout handling:

1. **Phase 1 (Research)**: If the Researcher hasn't submitted the Hiring Context Brief, the Lead sends a reminder. After
   a second timeout, re-spawn. After a third timeout, the Lead compiles a minimal context brief from project artifacts
   and proceeds -- the output notes the abbreviated research in Assumptions & Limitations.

2. **Phase 2 (Case Building)**: If either debate agent hasn't submitted their case, the Lead sends a reminder. After a
   second timeout, re-spawn the agent. After a third timeout, proceed with only one case -- the synthesis notes the
   incomplete debate in Assumptions & Limitations.

3. **Phase 3 (Cross-Examination)**: If an agent doesn't respond to a challenge/response/rebuttal, the Lead sends a
   reminder. After re-spawn attempt, proceed with the debate record as-is. A missing response means the challenge stands
   uncontested. A missing rebuttal means the round ends without the challenger's last word. Both are noted in synthesis.

4. **Phase 5 (Review)**: If a skeptic doesn't respond, the Lead sends a reminder. After re-spawn attempt, the Lead
   proceeds with the available verdict only. The output notes that one skeptic review was incomplete. This is NOT the
   same as approval -- the output is flagged as partially reviewed.

## CI Validator Impact

### Existing Validators -- Impact

| Validator                 | Impact          | Changes Needed                                                            |
| ------------------------- | --------------- | ------------------------------------------------------------------------- |
| `skill-structure.sh`      | Works as-is     | None -- the skill is multi-agent, so standard section checks apply        |
| `skill-shared-content.sh` | Needs extension | Two new skeptic names must be added to the normalize function (see below) |
| `spec-frontmatter.sh`     | Not applicable  | Output goes to `docs/hiring-plans/`, not `docs/specs/`                    |
| `roadmap-frontmatter.sh`  | Not applicable  | The skill does not modify roadmap files                                   |
| `progress-checkpoint.sh`  | Works as-is     | Checkpoint files follow the standard format with `team: "plan-hiring"`    |

### New Skeptic Names for `skill-shared-content.sh`

The normalize function in `skill-shared-content.sh` currently handles these skeptic name variants:

```
product-skeptic / Product Skeptic
quality-skeptic / Quality Skeptic
ops-skeptic / Ops Skeptic
accuracy-skeptic / Accuracy Skeptic
narrative-skeptic / Narrative Skeptic
strategy-skeptic / Strategy Skeptic
```

The plan-hiring skill introduces two new skeptic names: `bias-skeptic` / `Bias Skeptic` and `fit-skeptic` /
`Fit Skeptic`.

The normalize function must be extended with:

```bash
-e 's/bias-skeptic/SKEPTIC_NAME/g' \
-e 's/Bias Skeptic/SKEPTIC_NAME/g' \
-e 's/fit-skeptic/SKEPTIC_NAME/g' \
-e 's/Fit Skeptic/SKEPTIC_NAME/g'
```

This is a small, additive change to the existing `normalize_skeptic_names` function -- four new sed expressions.

### New Output Directory

The skill writes final outputs to `docs/hiring-plans/`. This directory is created by the skill itself in its Setup
section, following the same pattern as `draft-investor-update` creating `docs/investor-updates/` and `plan-sales`
creating `docs/sales-plans/`.

## SKILL.md Structure

The SKILL.md will follow the standard multi-agent format with all required sections:

```
---
name: plan-hiring
description: >
  Develop a hiring plan for early-stage startups. Debate agents argue for
  growth vs. efficiency, cross-examine each other's cases, then dual-skeptic
  validation ensures fairness and strategic fit.
argument-hint: "[--light] [status | (empty for new plan)]"
---

# Hiring Plan Team Orchestration
(Team Lead instructions -- coordinate AND synthesize in Phase 4)

## Setup
(Directory creation, stack detection, read project state, read user data)

## Write Safety
(Standard pattern with role-scoped files)

## Checkpoint Protocol
(Standard pattern with phases: research | case-building | cross-examination | synthesis | review | revision | complete)

## Determine Mode
(status, empty/resume)

## Lightweight Mode
(Researcher + Debate agents -> sonnet; Skeptics stay opus)

## Spawn the Team
### Researcher (opus)
### Growth Advocate (opus)
### Resource Optimizer (opus)
### Bias Skeptic (opus)
### Fit Skeptic (opus)

## Orchestration Flow
(Structured Debate phases 1-6 as described above)

## Quality Gate
(Dual-skeptic: both must approve)

## Failure Recovery
(Standard 3 patterns + Phase 3 idle fallback)

## Shared Principles
(Copied from plan-product/SKILL.md with shared markers)

## Communication Protocol
(Copied from plan-product/SKILL.md with shared markers)

## Teammate Spawn Prompts
(Detailed prompts for each role)
```

## Arguments

| Argument  | Effect                                                                         |
| --------- | ------------------------------------------------------------------------------ |
| (empty)   | Scan for in-progress sessions. If found, resume. Otherwise, start new plan.    |
| `status`  | Report on in-progress session without spawning agents.                         |
| `--light` | Researcher and debate agents use Sonnet instead of Opus. Skeptics remain Opus. |

## Integration Points

### With Existing Skills

- **plan-product**: Hiring plan reads roadmap and spec artifacts that plan-product creates. No write conflicts --
  plan-hiring is read-only with respect to these files. Product milestones may inform hiring timing.
- **plan-sales**: Sales strategy assessment may identify hiring needs (e.g., "need a sales hire to execute this GTM
  strategy"). Read-only dependency.
- **draft-investor-update**: Hiring plan decisions can inform investor updates (team growth narrative). Read-only
  dependency.
- **build-product**: Hiring plan reads progress files for understanding current product state and team velocity.
  Read-only.

### With Plugin System

- Registered alongside existing skills (auto-discovered per P3-10 lesson)
- Lives at `plugins/conclave/skills/plan-hiring/SKILL.md`
- Uses the same YAML frontmatter format

### New Artifacts

| Artifact           | Location                                           | Created By                 |
| ------------------ | -------------------------------------------------- | -------------------------- |
| Hiring plans       | `docs/hiring-plans/{date}-hiring-plan.md`          | Team Lead (final output)   |
| User data template | `docs/hiring-plans/_user-data.md`                  | Team Lead (first-run only) |
| Checkpoint files   | `docs/progress/plan-hiring-{role}.md`              | Each agent                 |
| Session summary    | `docs/progress/plan-hiring-summary.md`             | Team Lead                  |
| Cost summary       | `docs/progress/plan-hiring-{date}-cost-summary.md` | Team Lead                  |

## First-Run Behavior

1. **No prior hiring plans exist**: Agents skip consistency checks with prior plans. Expected behavior.
2. **No `_user-data.md` exists**: Researcher flags all user-data sections as gaps in the Hiring Context Brief. Plan uses
   project artifacts only, with explicit low-confidence markers. Skill creates the template file at
   `docs/hiring-plans/_user-data.md`.
3. **No `docs/hiring-plans/` directory exists**: Skill creates it in Setup.
4. **No roles specified in user data**: Researcher infers potential roles from project artifacts (roadmap blockers, team
   gaps evident from progress files) and includes them in the Hiring Context Brief. Both the growth and efficiency
   perspectives are applied to the inferred roles. The output notes that roles were inferred, not user-specified.

## SKILL.md Size Estimate

Based on P3-10 lessons (plan-sales SKILL.md is 1182 lines / 55KB) and the additional complexity of Structured Debate
(3-message cross-examination rounds, adversarial formats, Researcher phase), the plan-hiring SKILL.md is estimated at
**1400-1600 lines**. The cross-examination phase with Challenge, Response, and Rebuttal formats for each agent will be
the largest contributor to line count. The `skill-structure.sh` validator bug (printf | grep truncation on >30KB files)
has been fixed, so this is not a blocker.

## Non-Goals

1. **No real-time data gathering.** The skill reads project artifacts and user-provided data on disk. No API calls, job
   board queries, or salary database lookups.
2. **No compensation benchmarking.** The plan may include compensation ranges from user-provided data or explicit
   low-confidence estimates. It does not query external salary databases.
3. **No recruiting pipeline management.** No candidate tracking, interview scheduling, or applicant management.
4. **No performance management.** The skill plans new hires. It does not assess existing team performance.
5. **No legal advice.** The Bias Skeptic flags potential compliance concerns for human review. The output is not legal
   counsel.
6. **No template customization at runtime.** The output format is fixed in the SKILL.md.
