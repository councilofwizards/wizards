---
feature: "plan-hiring"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action:
  "Completed comprehensive research on Structured Debate pattern, agent team design, debate protocol, hiring domain
  coverage, and validator changes for P3-14"
updated: "2026-02-19"
---

# Plan-Hiring Research Findings

## 1. Structured Debate Pattern Deep Dive

### Definition (from business-skill-design-guidelines.md, lines 63-69)

> "Agents take defined positions (pro/con, optimistic/conservative, risk-seeking/risk-averse), present evidence-backed
> arguments, and a neutral party synthesizes. Best for high-stakes decisions where premature consensus is dangerous."

**Pattern flow** (line 69):

> "Agents are assigned perspectives -> each builds their case independently -> cases are presented to the full team ->
> cross-examination via direct messages -> Skeptics judge the debate -> synthesis produced."

**Assigned skills**: `/plan-finance`, `/review-legal`, `/plan-operations`, `/plan-hiring`

**Confidence: HIGH** -- directly quoted from authoritative source.

### How Structured Debate Differs from Collaborative Analysis

| Dimension                   | Collaborative Analysis (plan-sales)           | Structured Debate (plan-hiring)                         |
| --------------------------- | --------------------------------------------- | ------------------------------------------------------- |
| Agent stance                | Neutral investigators                         | Assigned opposing positions                             |
| Goal of Phase 1             | Discover facts per domain                     | Build a case for a position                             |
| Phase 2 purpose             | Cross-reference for gaps/contradictions       | Cross-examine to stress-test positions                  |
| Conflict                    | Emergent (discovered during cross-ref)        | By design (positions are opposed)                       |
| Risk of premature consensus | Mitigated by cross-referencing                | Mitigated by adversarial structure                      |
| Synthesis challenge         | Integrate parallel research                   | Resolve genuinely opposing arguments                    |
| Why this pattern            | Research-heavy, diverse perspectives compound | High-stakes decisions, premature consensus is dangerous |

**Key insight**: Collaborative Analysis discovers disagreements organically. Structured Debate manufactures them
deliberately. Both patterns prevent premature consensus, but Structured Debate is more appropriate when the decision
itself has legitimate opposing viewpoints that need to be fully explored before a synthesis can be credible.

**Hiring is a natural fit** because every hiring decision involves genuine trade-offs:

- Hire now (growth) vs. wait (preserve runway)
- Hire a specialist vs. hire a generalist
- Build internally vs. outsource vs. automate
- Prioritize role A vs. role B with limited budget

**Confidence: HIGH** -- based on pattern definition and domain analysis.

## 2. Debate Positions for Hiring

### Recommended Positions: Growth Advocate vs. Sustainability Advocate

After analyzing the natural tensions in early-stage hiring, the most productive debate framing is:

**Growth Advocate** -- Argues for aggressive, ambitious hiring. Takes the position that the biggest risk is moving too
slowly. For each role, argues "hire now" and pushes for higher-quality (more expensive) candidates, larger teams, and
faster timelines.

**Sustainability Advocate** -- Argues for conservative, capital-efficient hiring. Takes the position that the biggest
risk is burning runway on premature hires. For each role, argues "defer," "outsource," or "automate where possible" and
pushes for doing more with less.

**Why this framing works:**

1. **Genuine opposition**: Both positions are defensible and represent real trade-offs founders face. Neither is a
   strawman. A reasonable founder could hold either position depending on context.

2. **Covers multiple sub-debates**: The Growth vs. Sustainability framing naturally encompasses:
   - Hire now vs. defer (timing)
   - Full-time vs. contractor/outsource (commitment level)
   - Senior hire vs. junior hire (cost vs. capability)
   - Competitive compensation vs. equity-heavy packages (cash vs. upside)

   **Cross-cutting concern**: Generalist vs. specialist is ORTHOGONAL to Growth vs. Sustainability, not subsumed by it.
   Either advocate could argue for either. The spec should require both advocates to address the generalist vs.
   specialist dimension for each role as a cross-cutting concern within their positions. (Per skeptic review feedback.)

3. **Avoids false dichotomy on individual roles**: Rather than "hire/don't hire" for each role (which is reductive),
   both advocates must reason about _how_ and _when_ for each role from their perspective. The Growth Advocate may still
   recommend deferring a role if the evidence doesn't support it; the Sustainability Advocate may still recommend an
   immediate hire if it's critical. This prevents mechanical role-by-role yes/no debates.

4. **Maps to real founder psychology**: Founders are typically biased toward one of these positions. Having both argued
   explicitly helps them see the trade-offs they might be ignoring.

**Alternative considered and rejected**: Role-specific positions (e.g., "hire engineer" vs. "hire marketer") -- this
creates N debates instead of one structured debate and doesn't surface the deeper strategic tensions. It also doesn't
scale well -- if the user lists 6 roles, you'd need 6 separate debates.

**Alternative considered and rejected**: Generalist Advocate vs. Specialist Advocate -- this is a narrower concern that
is better addressed as a sub-point within the Growth vs. Sustainability framing rather than the primary axis.

**Confidence: HIGH** -- based on domain analysis of early-stage hiring decisions and pattern requirements.

## 3. Agent Team Design

### Recommended Team: 7 agents (Lead + 2 Debaters + 1 Researcher + 1 Moderator + 2 Skeptics)

Wait -- this needs more careful analysis. Let me reason through the options:

### Option A: 2 Debaters + 2 Skeptics + Lead (5 agents total)

- Growth Advocate, Sustainability Advocate, Bias Skeptic, Fit Skeptic, Team Lead
- **Pro**: Minimal team size. Clear adversarial structure.
- **Con**: No neutral research phase. Debaters must both research AND argue, which risks confirmation bias (they'll seek
  evidence for their position, not against it).

### Option B: 2 Debaters + 1 Researcher + 2 Skeptics + Lead (6 agents total)

- Researcher, Growth Advocate, Sustainability Advocate, Bias Skeptic, Fit Skeptic, Team Lead
- **Pro**: Neutral researcher gathers facts first. Debaters build cases from shared evidence base. This prevents
  cherry-picking.
- **Con**: One more agent than Option A. But the researcher is only active in Phase 1 and could potentially be shut down
  before the debate phase.

### Option C: 3 Debaters + 2 Skeptics + Lead (6 agents total)

- Three-way debate (e.g., Growth Advocate, Sustainability Advocate, Balance Advocate)
- **Pro**: More perspectives.
- **Con**: A "Balance Advocate" undermines the adversarial structure -- they'd agree with both sides and dilute the
  debate. Three-way cross-examination is also significantly more complex to orchestrate.

### Recommendation: Option B (6 agents)

**Rationale**:

1. **Neutral evidence base prevents cherry-picking**: The Researcher produces a neutral Hiring Context Brief (analogous
   to the Research Dossier in draft-investor-update). Both debaters argue from the same evidence, which makes the debate
   productive rather than two agents talking past each other with different facts.

2. **Precedent from P3-10 lessons**: The plan-sales Collaborative Analysis uses 3 analysis agents + 2 skeptics + lead =
   6 agents. Plan-hiring at 6 agents follows the same scale. The RC6 researcher findings (Section 1a) note SKILL.md
   sizes of 1182 lines for plan-sales; plan-hiring at similar complexity should be comparable.

3. **Researcher is reusable**: The Researcher pattern is proven (plan-product, draft-investor-update). The researcher
   gathers data, then the debaters use it. The researcher does NOT participate in the debate or cross-examination.

4. **2 debaters, not 3**: Two opposing positions create the clearest adversarial dynamic. The guidelines say "pro/con,
   optimistic/conservative, risk-seeking/risk-averse" -- all binary oppositions. A third position adds complexity
   without proportional value.

### Full Agent Team

| Role                    | Name                      | Model | Responsibility                                                                                                      |
| ----------------------- | ------------------------- | ----- | ------------------------------------------------------------------------------------------------------------------- |
| Team Lead               | (invoking agent)          | opus  | Orchestrate phases, moderate cross-examination, synthesize hiring plan, write final output                          |
| Researcher              | `researcher`              | opus  | Gather hiring context: current team, budget, roles needed, market data. Produce neutral Hiring Context Brief        |
| Growth Advocate         | `growth-advocate`         | opus  | Build the case for aggressive hiring. Argue for hiring now, investing in talent, and scaling the team               |
| Sustainability Advocate | `sustainability-advocate` | opus  | Build the case for conservative hiring. Argue for capital efficiency, outsourcing, automation, and deferral         |
| Bias Skeptic            | `bias-skeptic`            | opus  | Verify fairness, legal compliance, inclusive language, bias in role requirements and evaluation criteria            |
| Fit Skeptic             | `fit-skeptic`             | opus  | Verify role necessity, team composition, budget alignment, and whether each role genuinely fits the company's needs |

**All-Opus rationale**: Both debate agents must reason about ambiguous trade-offs, construct persuasive evidence-based
arguments, and respond to cross-examination challenges. The Researcher must synthesize diverse project data into a
coherent hiring context. All three require judgment-heavy reasoning. The skeptics are always Opus per convention.

**Lead-driven synthesis rationale**: Following the plan-sales precedent (RC6 lesson 1b), the Team Lead synthesizes the
hiring plan directly. The lead observed the full debate, heard both sides' strongest arguments and cross-examination
responses, and has meta-context about which arguments were better supported. A separate synthesizer agent would lack
this process context.

**No DBA**: No database involved.

**Confidence: HIGH** -- based on pattern requirements, precedent analysis, and domain fit.

## 4. Debate Protocol Design

### Phase Structure (6 phases)

```
Phase 1: RESEARCH (Researcher only)
Phase 2: CASE BUILDING (Debaters, parallel, independent)
Phase 3: CROSS-EXAMINATION (Debaters, sequential peer-to-peer)
Phase 4: SYNTHESIS (Lead-driven)
Phase 5: REVIEW (Dual-skeptic, parallel)
Phase 4b: REVISE (Lead, if skeptics reject -- returns to Phase 5 gate)
Phase 6: FINALIZE (Lead)
```

### Phase 1: Research (Single Agent)

**Agent**: Researcher

The Researcher gathers the hiring context from project artifacts and user-provided data. This is a neutral
evidence-gathering phase -- the Researcher does not advocate for any position.

**Output**: Hiring Context Brief (sent to Team Lead, who distributes to both debaters).

**Gate 1**: Team Lead verifies the brief is complete and covers the key data categories (current team, budget, roles,
timeline, market context).

### Phase 2: Case Building (Parallel, Independent)

**Agents**: Growth Advocate + Sustainability Advocate (in parallel, NO communication)

Each debater receives the Hiring Context Brief and builds their case independently. They do not see each other's
arguments during this phase.

**Output**: Each debater produces a **Position Brief** -- a structured argument for their position on each role and on
the overall hiring strategy.

**Gate 2**: Team Lead verifies both Position Briefs received.

### Phase 3: Cross-Examination (Sequential, Peer-to-Peer)

This is the novel phase that distinguishes Structured Debate. This is where the protocol differs most from Collaborative
Analysis.

**Mechanism**: The Team Lead distributes both Position Briefs to both debaters. Then cross-examination proceeds in
structured rounds:

**Round structure** (2 rounds):

1. **Round 1**: Growth Advocate challenges Sustainability Advocate's position. Sustainability Advocate responds. Growth
   Advocate gets one rebuttal. (3 messages)
2. **Round 2**: Sustainability Advocate challenges Growth Advocate's position. Growth Advocate responds. Sustainability
   Advocate gets one rebuttal. (3 messages)

Total: 6 messages in cross-examination.

**Round ordering effect** (per skeptic review): Round 1 goes first, meaning Sustainability's position gets challenged
first. This creates a subtle first-mover advantage -- Growth Advocate sees Sustainability's defense before formulating
their own challenge. This is mitigated by the symmetric structure: each side gets exactly one round as challenger and
one as defender. The spec MUST preserve this symmetry if round ordering is rearranged.

**Why structured rounds, not free-form**:

- Free-form cross-examination risks devolving into agreement (agents are cooperative by nature) or going in circles
- Structured rounds ensure both sides get equal opportunity to challenge
- Message count is bounded, preventing runaway conversations
- Each message has a clear purpose: challenge, respond, or rebut

**Cross-examination message format**:

```
CHALLENGE: [Advocate name] to [Other advocate name]
Round: [1 or 2]

## Points Challenged
1. [Position Brief claim]: [Why this is wrong or overstated]. Evidence: [from Hiring Context Brief].
   Question: [Specific question the other advocate must answer]
2. ...

## Concessions
- [Any points from the opposing brief that I concede are valid]
  (Concessions are important -- they signal intellectual honesty and help synthesis)
```

```
RESPONSE: [Advocate name] responding to [Challenger name]
Round: [1 or 2]

## Responses
1. Re: [challenged point]: [Defense or revised position]. Evidence: [source].
2. ...

## Counter-Points Raised
- [New point surfaced by the challenge that strengthens my position]
```

```
REBUTTAL: [Advocate name] final rebuttal
Round: [1 or 2]

## Final Points
1. [Last word on the key disagreements]. Evidence: [source].
2. ...

## Points of Agreement
- [Specific points where both sides genuinely agree after this round]
  (Genuine consensus on specific points is a strong signal for synthesis)

## Key Unresolved Disagreements
- [List the specific points where both sides still disagree after this round]
  (This feeds directly into synthesis -- the Team Lead must resolve these)
```

**Handling agreement vs. disagreement** (per skeptic review): The protocol must handle both genuine agreement AND
genuine disagreement gracefully:

- **Agreement on individual points is expected and valuable**: If both advocates agree a CTO hire is critical and
  urgent, that consensus is a strong signal for synthesis. The "Points of Agreement" section in each rebuttal captures
  this.
- **Wholesale agreement is suspect**: If a debater claims no disagreements across ALL points, the cross-examination has
  failed its purpose. The anti-convergence mechanism prevents wholesale convergence, not agreement on individual points.
- Concessions are allowed (and encouraged for intellectual honesty) but must be specific and limited.
- The rebuttal format forces the debater to state their final position on disputed points, not just agree with the other
  side.

**Fallback for idle agents** (per P3-10 lesson, RC6 Section 1e):

- If a debater does not respond to a cross-examination message within a reasonable time, the Team Lead sends a reminder
  message
- If still unresponsive after the reminder, the Team Lead re-spawns the agent with checkpoint context and the current
  cross-examination state
- If re-spawn fails, the Team Lead proceeds with the available arguments (one-sided cross-examination is better than no
  cross-examination)
- The idle risk is documented as a known limitation in the output

**Do skeptics participate in cross-examination?** NO. Skeptics judge AFTER the debate, not during. This separation
ensures:

- The debate is between the two advocates only
- Skeptics maintain independence -- they haven't been influenced by participating in the debate
- Skeptics can evaluate the quality of the debate itself (were challenges substantive? were responses adequate?)

**Gate 3**: Team Lead verifies both rounds of cross-examination are complete. All 6 messages (or fallback equivalents)
received.

### Phase 4: Synthesis (Lead-Driven)

**Agent**: Team Lead (NOT delegate mode, following plan-sales precedent)

The Team Lead synthesizes: 1 Hiring Context Brief + 2 Position Briefs + 6 Cross-Examination messages = 9 artifacts.

**Synthesis process**:

1. For each role/decision, identify where the advocates agreed (these go into the plan as strong recommendations)
2. For each role/decision, identify where they disagreed (resolve using evidence quality, hiring context, and domain
   judgment)
3. Document resolution reasoning for every disagreement
4. Write the hiring plan with the full output template

**Context management**: Synthesize section by section (same as plan-sales). If context degrades, checkpoint and
continue.

### Phase 5: Review (Dual-Skeptic, Parallel)

**Agents**: Bias Skeptic + Fit Skeptic

Both skeptics receive the Draft Hiring Plan AND all 9 source artifacts.

**Bias Skeptic checklist**:

1. Job descriptions use inclusive language (no gendered terms, no unnecessary requirements)
2. Evaluation criteria are job-relevant, not proxies for protected characteristics
3. Compensation recommendations don't perpetuate pay gaps
4. Interview process is structured and bias-resistant
5. Team composition analysis doesn't make assumptions based on demographics
6. Business quality checklist (assumptions stated, confidence levels, falsification triggers)

**Fit Skeptic checklist**:

1. Each recommended hire is justified by a specific, evidenced need
2. Team composition analysis is honest (gaps are real, not padded)
3. Budget impact is accurately calculated (not just salary -- total cost of employment)
4. Timing recommendations are feasible given runway and hiring timelines
5. Build/hire/outsource decisions are genuinely evaluated, not defaulted to "hire"
6. Business quality checklist (framing credible, projections grounded)

**Gate 4**: Both skeptics must approve.

### Phase 4b: Revise (if skeptics reject)

Same as plan-sales Phase 3b. Lead revises based on ALL skeptic feedback, returns to Phase 5 gate. Max 3 cycles before
escalation.

### Phase 6: Finalize

When both skeptics approve. Write final output, progress summary, cost summary.

**Confidence: HIGH** -- based on pattern definition, plan-sales precedent, and domain requirements.

## 5. Hiring Domain Coverage

### What a hiring plan for an early-stage startup should cover:

1. **Role Prioritization and Timing**
   - Which roles to hire first, second, third
   - Timing aligned with product roadmap and revenue milestones
   - Dependencies between roles (e.g., engineering lead before individual contributors)

2. **Role Definitions**
   - Clear job descriptions with must-have vs. nice-to-have requirements
   - Inclusive language review (Bias Skeptic validates)
   - Realistic experience requirements (not inflated to filter)
   - Remote/hybrid/onsite preference with rationale

3. **Compensation Strategy**
   - Market-rate benchmarking approach (not actual numbers -- that requires real-time data)
   - Cash vs. equity trade-offs for early-stage
   - Benefits and perks that matter at early stage vs. enterprise-stage
   - Geographic compensation considerations

4. **Interview Process Design**
   - Structured interview framework (not ad-hoc)
   - Skills assessment methodology
   - Culture fit evaluation (with bias guardrails)
   - Reference check approach
   - Timeline from posting to offer

5. **Team Composition Analysis**
   - Current team gaps (skills, experience, perspective)
   - Diversity and inclusion considerations
   - Generalist vs. specialist balance
   - Seniority mix (too many juniors = no mentorship, too many seniors = high cost)

6. **Budget and Runway Impact**
   - Per-role cost modeling (salary + benefits + equipment + onboarding)
   - Cumulative burn rate impact
   - Runway impact analysis (months of runway consumed by each hire)
   - Break-even analysis for revenue-generating roles (e.g., salespeople)

7. **Build vs. Hire vs. Outsource Analysis**
   - For each role/capability: should you hire full-time, use contractors, outsource, or automate?
   - Decision framework based on: strategic importance, duration of need, availability of talent, budget

8. **Onboarding Planning**
   - What does a new hire need to be productive?
   - First 30/60/90 day expectations
   - Documentation and knowledge transfer requirements
   - Mentorship/buddy system needs

**Confidence: HIGH** -- based on standard early-stage hiring planning practices.

## 6. Output Format

### Proposed output sections (compared to plan-sales)

Plan-sales has 9 content sections + 4 mandatory business quality sections = 13 total.

Plan-hiring should have a similar structure:

**Content sections** (10):

1. **Executive Summary** -- Key hiring recommendations in 3-5 sentences
2. **Current Team Assessment** -- Existing team composition, gaps, strengths
3. **Hiring Priorities** -- Ranked roles with justification and timing
4. **Role Specifications** -- For each priority role: description, requirements, compensation guidance
5. **Build vs. Hire vs. Outsource** -- Analysis for each capability need
6. **Compensation Strategy** -- Overall approach to cash, equity, benefits
7. **Interview Process** -- Structured interview framework
8. **Team Composition & Diversity** -- How hires affect team composition and inclusion
9. **Budget Impact** -- Financial impact of recommended hires on runway
10. **Recommended Next Steps** -- Specific, actionable next steps

**Mandatory business quality sections** (4): 11. **Assumptions & Limitations** -- What the plan assumes, what data was
unavailable 12. **Confidence Assessment** -- Per-section confidence with rationale 13. **Falsification Triggers** --
What evidence would change these recommendations 14. **External Validation Checkpoints** -- Where human HR/hiring
expertise should validate

**Debate Resolution section** (1 -- new for Structured Debate): 15. **Debate Resolution Summary** -- How key
disagreements between Growth and Sustainability advocates were resolved, with reasoning

Total: 15 sections (10 content + 4 business quality + 1 debate resolution).

The Debate Resolution Summary is a new pattern unique to Structured Debate. It makes the synthesis process transparent
-- the user can see what the two sides argued and why the plan chose the position it did. This is particularly valuable
for hiring decisions where the user may have strong opinions and wants to understand the trade-offs.

**Confidence: HIGH** -- based on plan-sales precedent and domain requirements.

## 7. User Data Template

### Required user data for hiring planning

The hiring plan is heavily user-data-dependent (similar to plan-sales at ~60-70% user-data-driven). The user provides
this via `docs/hiring-plans/_user-data.md`.

**Proposed template sections**:

```
## Current Team
- Team size:
- Key roles filled:
- Key roles missing (your assessment):
- Team strengths:
- Team gaps:

## Budget & Runway
- Current monthly burn rate:
- Current runway (months):
- Budget allocated for hiring:
- Compensation philosophy (competitive market rate / below market + equity / above market):

## Roles Needed
- Role 1: [title]. Why: [reason]. Urgency: [immediate / next quarter / next 6 months]
- Role 2: ...
- (Add as many as needed)

## Company Context
- Stage (pre-seed / seed / Series A / bootstrapped):
- Industry/vertical:
- Remote / hybrid / onsite:
- Location(s):
- Company culture (brief):

## Hiring Constraints
- Timeline to first hire:
- Willingness to use contractors:
- Geographic restrictions:
- Visa sponsorship availability:
- Existing recruiting channels or partnerships:

## Additional Context
<!-- Anything else relevant to hiring decisions -->
```

**Graceful degradation** (same as plan-sales):

- File missing: use project artifacts only, low-confidence markers everywhere, create template
- File partially filled: use available data, note gaps
- File empty/template-only: treat as missing

**Confidence: HIGH** -- based on plan-sales precedent and hiring domain requirements.

## 8. Scope Constraints

### In Scope

- Hiring planning for early-stage startups (pre-seed through Series A)
- Role prioritization and timing recommendations
- Job description quality review (inclusive language, realistic requirements)
- Compensation strategy guidance (approach, not specific numbers)
- Interview process framework design
- Team composition and diversity analysis
- Build vs. hire vs. outsource decisions
- Budget/runway impact analysis
- Structured debate between growth and sustainability perspectives

### Out of Scope

- Enterprise HR processes (performance management, annual reviews, promotion frameworks)
- Recruiting operations (sourcing, screening, pipeline management)
- Compensation administration (payroll, benefits enrollment, tax implications)
- Legal compliance advice (employment law is jurisdiction-specific and requires legal counsel)
- Specific salary numbers (requires real-time market data the skill doesn't have access to)
- Visa/immigration processing
- Employee retention strategies (that's closer to `/plan-onboarding` or a future HR skill)
- Firing/termination processes
- Training and development programs (beyond initial onboarding mention)
- CRM/ATS tool selection

**Confidence: HIGH** -- based on skill scope conventions and domain boundaries.

## 9. P3-10 Implementation Lessons to Incorporate

From RC6 researcher findings (docs/progress/review-cycle-6-researcher.md, Section 1):

### 9a. SKILL.md Size (RC6 Section 1a)

- Plan-sales SKILL.md is 1182 lines / 55KB
- Plan-hiring with Structured Debate will be similar or larger due to cross-examination phase requiring explicit
  orchestration
- **Estimate: 1200-1500 lines**
- The `skill-structure.sh` validator bug (printf | grep truncation on >30KB files) has been fixed
- No blocker, but awareness needed

### 9b. Lead-Driven Synthesis (RC6 Section 1b)

- Plan-sales Phase 3 has the Team Lead write synthesis directly (not delegate mode)
- This worked -- all 14 success criteria were met
- **Plan-hiring should follow the same pattern**: Team Lead synthesizes the hiring plan after the debate
- The synthesis must integrate opposing positions, not just parallel research. This is harder than plan-sales synthesis.
  The lead must explicitly resolve disagreements with stated reasoning.

### 9c. Dual-Skeptic Pattern (RC6 Section 1c)

- Plan-sales used Accuracy Skeptic + Strategy Skeptic, worked without issues
- Plan-hiring uses Bias Skeptic + Fit Skeptic per business-skill-design-guidelines (line 32)
- Validator needs both new names added to `normalize_skeptic_names()` -- a known mechanical step

### 9d. Agent Idle Risk (RC6 Section 1e)

- Quality-skeptic went idle during plan-sales post-impl review
- **Critical for cross-examination**: If a debater goes idle during cross-examination, the debate stalls. The protocol
  MUST have explicit fallback instructions.
- Fallback designed in Section 4 above: reminder -> re-spawn -> proceed with available arguments

### 9e. Skills Are Auto-Discovered (RC6 Section 1e, point 3)

- No plugin.json modification needed
- Simplifies implementation -- just create the SKILL.md at the right path

### 9f. Cross-Examination Verbosity (RC6 Section 1d)

- Collaborative Analysis's cross-referencing drove the larger SKILL.md size
- Structured Debate's cross-examination is even more complex to specify (adversarial + structured rounds)
- Each cross-examination message has its own format
- This will be the single largest contributor to SKILL.md line count

**Confidence: HIGH** -- directly from validated implementation evidence.

## 10. Validator Changes Needed

### New skeptic names for `skill-shared-content.sh`

Current `normalize_skeptic_names()` handles (from script lines 51-64):

```
product-skeptic / Product Skeptic
quality-skeptic / Quality Skeptic
ops-skeptic / Ops Skeptic
accuracy-skeptic / Accuracy Skeptic
narrative-skeptic / Narrative Skeptic
strategy-skeptic / Strategy Skeptic
```

Plan-hiring introduces TWO new skeptic names:

1. `bias-skeptic` / `Bias Skeptic`
2. `fit-skeptic` / `Fit Skeptic`

**Changes needed** (4 new sed expressions):

```bash
-e 's/bias-skeptic/SKEPTIC_NAME/g' \
-e 's/Bias Skeptic/SKEPTIC_NAME/g' \
-e 's/fit-skeptic/SKEPTIC_NAME/g' \
-e 's/Fit Skeptic/SKEPTIC_NAME/g'
```

This is the same mechanical pattern used when plan-sales added `strategy-skeptic` / `Strategy Skeptic`. Small, additive
change.

**Confidence: HIGH** -- directly from validator source code analysis.

## Skeptic Feedback Incorporated

The following changes were made based on preliminary skeptic review:

1. **Generalist vs. specialist is orthogonal, not subsumed** -- corrected the claim. Both advocates must address this
   cross-cutting concern for each role.
2. **Round ordering effect acknowledged** -- Round 1 gives Growth Advocate a subtle first-mover advantage. Mitigated by
   symmetric structure. Spec must preserve symmetry.
3. **Points of Agreement added to rebuttal format** -- genuine consensus on individual points is valuable for synthesis.
   Anti-convergence mechanism prevents wholesale agreement, not agreement on specific points.
4. **Phase numbering cleaned up** -- revision is Phase 4b (follows plan-sales 3b convention), consistent with Phase 5
   review gate.
5. **Output section count**: Skeptic noted 15 may be excessive. "Build vs. Hire vs. Outsource" could potentially fold
   into "Hiring Priorities" or "Role Specifications." Low-impact formatting concern -- defer to spec author.

## Summary of Key Decisions and Recommendations

| Decision                               | Recommendation                                                                            | Skeptic Verdict                               | Confidence        |
| -------------------------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------------- | ----------------- |
| Consensus pattern                      | Structured Debate (per guidelines)                                                        | n/a (per guidelines)                          | HIGH              |
| Debate positions                       | Growth Advocate vs. Sustainability Advocate                                               | ACCEPTABLE WITH CONCERN (gen/spec orthogonal) | HIGH              |
| Team size                              | 6 agents (Lead + Researcher + 2 Debaters + 2 Skeptics)                                    | APPROVED                                      | HIGH              |
| Research phase                         | Yes -- neutral Researcher produces Hiring Context Brief before debate                     | APPROVED                                      | HIGH              |
| Cross-examination                      | 2 structured rounds, 6 messages total, sequential peer-to-peer                            | APPROVED WITH DEMAND (ordering ack)           | HIGH              |
| Skeptic participation in debate        | No -- skeptics judge after, not during                                                    | APPROVED                                      | HIGH              |
| Synthesis                              | Lead-driven (following plan-sales precedent)                                              | n/a (reviewed elsewhere)                      | HIGH              |
| Output sections                        | 15 (10 content + 4 business quality + 1 debate resolution)                                | ACCEPTABLE (15 may be excessive)              | HIGH              |
| Output directory                       | `docs/hiring-plans/`                                                                      | n/a (not reviewed)                            | HIGH              |
| User data template                     | `docs/hiring-plans/_user-data.md`                                                         | n/a (not reviewed)                            | HIGH              |
| SKILL.md size estimate                 | 1200-1500 lines                                                                           | ACCEPTABLE                                    | MEDIUM (estimate) |
| Validator changes                      | 4 new sed expressions in normalize_skeptic_names()                                        | n/a (not reviewed)                            | HIGH              |
| Phase count                            | 6 phases + 4b revision (research, case-building, cross-exam, synthesis, review, finalize) | ACCEPTABLE (numbering cleaned)                | HIGH              |
| Idle agent fallback                    | Reminder -> re-spawn -> proceed with available arguments                                  | n/a (not reviewed)                            | HIGH              |
| New pattern: Debate Resolution Summary | Unique to Structured Debate -- makes synthesis transparent                                | APPROVED                                      | HIGH              |
| New pattern: Points of Agreement       | In rebuttal format alongside Key Unresolved Disagreements                                 | ADDED per skeptic                             | HIGH              |
