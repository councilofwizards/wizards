# The Assayer's Evaluation Framework

> _The rubric exists so that "I think it's good" is never the reason an idea advances. Every score requires evidence.
> Every decision has a traceable rationale. The Assayer's job is not to have opinions — it is to apply a consistent
> standard to the evidence in front of it._

This document is the detailed version of the scoring rubric used by The Assayer's Guild (Stage 2). The summary version
is embedded in FACTORIUM.md. This document is the authoritative reference for scoring guidance, example evaluations,
edge cases, and the go/no-go decision tree.

---

## The Rubric

Each idea is scored on six dimensions. All scores are integers 1–5.

| Dimension                  | 1 (Poor)                                    | 3 (Acceptable)                     | 5 (Excellent)                       |
| -------------------------- | ------------------------------------------- | ---------------------------------- | ----------------------------------- |
| **User Value**             | No clear user benefit                       | Solves a real but minor pain point | Transformative for target users     |
| **Strategic Fit**          | Misaligned with product vision              | Tangentially aligned               | Core to product direction           |
| **Market Differentiation** | Commoditized; many alternatives             | Some differentiation               | Unique or best-in-class             |
| **Technical Feasibility**  | Major unknowns; likely architecture changes | Achievable with moderate effort    | Straightforward given current stack |
| **Effort-to-Impact Ratio** | High effort, low impact                     | Balanced                           | Low effort, high impact             |
| **Risk**                   | High technical or business risk             | Moderate, manageable risk          | Low risk                            |

**Composite Score:** Average of all six dimensions (arithmetic mean, rounded to one decimal place).

---

## Scoring Guidance

### User Value

**What this dimension measures:** The benefit a real user would receive if this feature shipped. Not the potential
market, not the strategic opportunity — the lived, day-to-day improvement for the target user.

| Score | Criteria                                                                                                                                                                         |
| ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | No identifiable user benefit. Feature solves a problem users do not have, adds complexity without utility, or duplicates an existing capability.                                 |
| 2     | Marginal benefit. A small subset of users would notice; most would not. Or the benefit is theoretical rather than demonstrated by user feedback, support tickets, or usage data. |
| 3     | Clear benefit for a meaningful segment of target users. Solves a documented pain point. Users would notice and appreciate the change.                                            |
| 4     | Significant benefit for a large portion of target users. Would likely reduce support burden, increase retention, or appear in user NPS feedback as a positive factor.            |
| 5     | Transformative. Removes a major blocker, enables a new category of use case, or dramatically improves the core user workflow. Users have been asking for this.                   |

**Evidence required for 4–5:** Direct user feedback (support tickets, user research, interviews), usage data showing
where users currently struggle, or competitive evidence that users are leaving for alternatives that offer this feature.
Intuition is not evidence.

---

### Strategic Fit

**What this dimension measures:** How well the idea aligns with the product's stated direction, roadmap priorities, and
long-term vision.

| Score | Criteria                                                                                                                                                                             |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1     | Actively misaligned. Building this would pull engineering resources away from the product's core direction, or would create architectural debt that undermines future roadmap items. |
| 2     | Neutral or weakly aligned. The idea doesn't conflict with product direction but doesn't advance it either. A "nice to have" with no strategic leverage.                              |
| 3     | Tangentially aligned. Supports the product's goals in a secondary way — improves the ecosystem around the core value proposition without directly advancing it.                      |
| 4     | Aligned with a specific roadmap priority or stated strategic goal. Advancing this idea directly enables or unblocks planned future work.                                             |
| 5     | Core to the product's direction. This idea is what the product is becoming. Shipping it advances the product's competitive position on its primary dimension.                        |

**Note:** High strategic fit for a low-value idea is not a reason to ship it. A feature that perfectly aligns with
strategy but that users will not use is still a poor investment.

---

### Market Differentiation

**What this dimension measures:** Whether this feature would set the product apart from alternatives in the market, or
whether it would simply bring it to parity with what already exists.

| Score | Criteria                                                                                                                                                                                                    |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Commodity feature. Every competitor has it. Users expect it as table stakes. Shipping it removes a disadvantage but creates no advantage.                                                                   |
| 2     | Minor differentiation. Most alternatives have something similar, though this product's implementation might be marginally better in a specific dimension.                                                   |
| 3     | Moderate differentiation. Some alternatives have this; others don't. The product would be among a smaller group offering it.                                                                                |
| 4     | Meaningful differentiation. Few alternatives have this feature, or no alternative implements it as well as this product could given its unique position.                                                    |
| 5     | Unique or best-in-class. No meaningful alternative offers this, or the product has a structural advantage (data, architecture, distribution) that would make its version of this feature uniquely superior. |

**Note:** A score of 1 does not mean "don't build it." Commodity features are sometimes necessary to remain competitive.
The dimension informs the go/no-go in combination with other dimensions, not in isolation.

---

### Technical Feasibility

**What this dimension measures:** How achievable the idea is given the current codebase, stack, team capabilities, and
known technical constraints.

| Score | Criteria                                                                                                                                                                                                                                                                 |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1     | Major unknowns or likely architecture changes. The idea requires technology the team has no experience with, or would require restructuring core architectural decisions. High probability of discovery work revealing the idea is significantly harder than it appears. |
| 2     | Significant challenges. The idea is implementable but requires substantial new infrastructure, third-party integrations with unclear APIs, or significant performance work. Effort estimate has wide error bars.                                                         |
| 3     | Achievable with moderate effort. The existing codebase supports this feature with some non-trivial extension. No fundamental architectural changes needed. Standard complexity for this team and stack.                                                                  |
| 4     | Straightforward. The codebase has most of what's needed. Implementation is largely additive. Clear implementation path with narrow error bars on effort.                                                                                                                 |
| 5     | Trivial given current stack. The infrastructure is essentially already in place. This is a configuration change, a thin wrapper, or a small extension of existing functionality.                                                                                         |

**Evidence required for 1–2:** Specific technical blockers identified. Not "this might be hard" but "we would need to
replace the auth layer" or "the upstream API does not support this operation."

---

### Effort-to-Impact Ratio

**What this dimension measures:** The return on engineering investment. High impact for low effort is excellent; low
impact for high effort is poor.

| Score | Criteria                                                                                                                                              |
| ----- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Poor ratio. Large engineering investment (weeks to months) for marginal or speculative user impact. Classic "big bet with small upside" failure mode. |
| 2     | Below average. More effort than impact justifies, or impact is uncertain enough that the expected value of the investment is low.                     |
| 3     | Balanced. The engineering effort is proportional to the expected impact. Neither a windfall nor a waste — a reasonable use of resources.              |
| 4     | Good ratio. Relatively low effort for meaningful user impact. Or: high effort, but impact is clear and substantial enough to justify it.              |
| 5     | Excellent ratio. Small engineering investment, large and certain user benefit. Quick win with lasting value.                                          |

**Note:** This dimension interacts with Technical Feasibility but is distinct. An idea that is technically easy but
addresses a problem only three users have scores high on Feasibility but low on Effort-to-Impact. Score each
independently.

---

### Risk

**What this dimension measures:** The technical and business risk of building this feature. Includes implementation
risk, security risk, data integrity risk, regulatory risk, and the risk of negative user response.

| Score | Criteria                                                                                                                                                                                                                                                              |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | High risk. One or more of: significant security surface area added, data model changes with migration risk, potential regulatory exposure, high probability of negative user response if the feature ships and underperforms, or irreversible infrastructure changes. |
| 2     | Elevated risk. Some of the above apply at lower severity, or the risk is manageable but requires careful handling that adds to the effort and complexity.                                                                                                             |
| 3     | Moderate risk. Standard implementation risks. No unusual security, data, or regulatory concerns. Mistakes can be corrected without major consequence.                                                                                                                 |
| 4     | Low risk. The feature is additive, doesn't touch sensitive areas, and can be shipped behind a flag if needed. Easy to roll back.                                                                                                                                      |
| 5     | Minimal risk. Read-only or purely additive changes. No data model changes, no security surface expansion, no regulatory implications. If it ships and underperforms, removing it is simple.                                                                           |

**Note:** Risk and Feasibility are not the same. A technically straightforward feature can carry high business risk
(e.g., a simple API endpoint that exposes sensitive user data). Score both accurately.

---

## Example Evaluations

### Example A: Keyboard Shortcut Customization

_Idea: Allow users to remap keyboard shortcuts in the application UI._

| Dimension              | Score   | Reasoning                                                                                        |
| ---------------------- | ------- | ------------------------------------------------------------------------------------------------ |
| User Value             | 3       | Meaningful for power users; irrelevant to most. No strong user demand signals.                   |
| Strategic Fit          | 2       | Not aligned with any roadmap priority. Nice-to-have polish feature.                              |
| Market Differentiation | 1       | Every desktop app offers this. Table stakes for power-user audiences.                            |
| Technical Feasibility  | 4       | Standard pattern; existing input handling supports it with moderate extension.                   |
| Effort-to-Impact Ratio | 2       | Implementation is non-trivial (persistence, conflict detection, UI) for narrow audience benefit. |
| Risk                   | 4       | Low risk. Additive UI feature with no data model impact.                                         |
| **Average**            | **2.7** |                                                                                                  |

**Decision: No-Go.** Average below 3.0. Market Differentiation scores 1 (commodity feature). Conditional Go is not
available when the threshold is below 3.0. The idea is archived in the graveyard. `necromancy-candidate` label may be
added if the product's target audience shifts toward power users.

---

### Example B: Intelligent Query Caching

_Idea: Automatically cache expensive database queries based on access patterns, with automatic invalidation on write._

| Dimension              | Score   | Reasoning                                                                                                         |
| ---------------------- | ------- | ----------------------------------------------------------------------------------------------------------------- |
| User Value             | 4       | Directly improves perceived performance for all users. Addresses known latency complaints in support tickets.     |
| Strategic Fit          | 4       | Aligns with roadmap priority P3-15 (performance at scale). Enables future scaling work.                           |
| Market Differentiation | 3       | Some competitors auto-cache; most require manual configuration. A seamless implementation would be above average. |
| Technical Feasibility  | 2       | Cache invalidation on write requires careful scoping. Unknown interactions with existing ORM patterns.            |
| Effort-to-Impact Ratio | 3       | Significant engineering effort, but broadly impactful. Balanced.                                                  |
| Risk                   | 2       | Cache invalidation bugs can cause stale data issues. Data integrity risk requires careful testing.                |
| **Average**            | **3.0** |                                                                                                                   |

**Decision: Conditional Go.** Average is 3.0 (meets conditional threshold). Two dimensions score 2. Conditions: (1)
Feasibility assessment must include a prototype demonstrating the invalidation strategy works with the existing ORM. (2)
Risk mitigation requires a feature flag for staged rollout and a documented rollback procedure. Advance to
`factorium:planner` with conditions noted in the Research Summary.

---

### Example C: Real-Time Collaborative Editing

_Idea: Allow multiple users to edit the same document simultaneously, with conflict resolution and cursor presence._

| Dimension              | Score   | Reasoning                                                                                                                                                 |
| ---------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| User Value             | 5       | Directly addresses the #1 user request over the past two quarters. Would transform the product's use in team contexts.                                    |
| Strategic Fit          | 5       | Explicitly in the product vision statement. This is a core direction item.                                                                                |
| Market Differentiation | 4       | Most direct competitors do not offer this. Would be a significant differentiator in the target segment.                                                   |
| Technical Feasibility  | 1       | Requires CRDT or OT infrastructure that does not exist in the codebase. Current data model is single-writer. Fundamental architecture change.             |
| Effort-to-Impact Ratio | 2       | Impact is high but effort is extremely high. 6-12 months of infrastructure work before user-visible benefit.                                              |
| Risk                   | 1       | Collaborative editing introduces data consistency, conflict resolution, and presence infrastructure risk. Data loss scenarios if implemented incorrectly. |
| **Average**            | **3.0** |                                                                                                                                                           |

**Decision: No-Go (overridden).** Average meets the conditional threshold (3.0), but Technical Feasibility and Risk both
score 1. The go/no-go rule states: any dimension scoring 1 triggers No-Go regardless of average. Archive to graveyard.
Apply `necromancy-candidate` — this idea has extremely high user value and strategic fit; it is not dead forever, only
dead until the technical foundation is established. The rejection rationale must clearly state: "Revival condition:
codebase has a CRDT or OT infrastructure in place."

---

## Edge Cases

### The Uneven Scorer: High Value, Low Feasibility

An idea scores 5 on User Value, 5 on Strategic Fit, 4 on Market Differentiation — but 1 on Technical Feasibility and 1
on Risk.

**Decision:** No-Go. The go/no-go rule is explicit: any dimension scoring 1 triggers rejection regardless of average.
This is intentional. An idea that users would love but that would require architectural surgery is not a No today — it
is a No until the architecture supports it.

**Correct handling:** Archive to graveyard. Apply `necromancy-candidate`. Write a clear rejection rationale that
identifies the specific technical blockers: not "too hard," but "requires X capability, which does not exist." When the
capability exists, the Necromancer can identify this issue as a revival candidate.

---

### The Flat Scorer: All Threes

An idea scores 3 across all six dimensions. Average: 3.0.

**Decision:** Conditional Go. Average meets the 3.0 threshold. No dimension scores 1 or 2, so no conditions apply.
However: the Assayer General should note that this is a marginal pass. A flat-3 idea is not exciting. It solves a real
problem, is achievable, carries moderate risk, and aligns with strategy — but it will not move the needle. It advances,
but should be de-prioritized in the planning queue relative to higher-scoring items.

---

### The Assayer General Veto

An idea scores an average of 4.2 across all dimensions — a clear Go by the rubric — but the Assayer General finds a
specific piece of evidence that invalidates the Feasibility Assessor's findings: the upstream API the feature depends on
is deprecated and scheduled for shutdown.

**Decision:** No-Go or Requeue. The Assayer General has veto authority independent of the rubric. The veto must be
accompanied by specific evidence, not intuition. In this case: deprecated API documentation is specific evidence.

**Correct handling:** Requeue to self with a note: "Feasibility re-assessment required. Upstream dependency [X] is
deprecated per [source]. Alternative approaches must be evaluated before this idea can advance." The Assayer General
does not veto an idea because it "feels risky" — veto requires evidence that contradicts or invalidates a dimension
score.

---

### Duplicate Detection

An idea is substantially identical to one currently in the pipeline at `factorium:planner`.

**Decision:** No-Go. The idea is a duplicate. Archive to graveyard with rejection rationale: "Duplicate of #[issue
number], currently in planning. Revisit if the existing implementation is scoped differently."

**Note:** Do not archive with `necromancy-candidate` for true duplicates. The Necromancer revives ideas whose rejection
reasons have expired — a duplicate's rejection reason cannot expire while the original is still live.

---

## The Go/No-Go Decision Tree

```
                    ┌─────────────────────────────────┐
                    │  Calculate composite score       │
                    │  (average of 6 dimensions)       │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────▼──────────────────┐
                    │  Any dimension scores 1?         │
                    └──────┬──────────────────┬───────┘
                          YES                 NO
                           │                  │
              ┌────────────▼──┐   ┌───────────▼──────────────┐
              │  → NO-GO      │   │  Composite score >= 3.5? │
              │  Archive to   │   └───────────┬──────────────┘
              │  graveyard    │              / \
              └───────────────┘            YES  NO
                                            │    │
                             ┌──────────────▼┐  ┌▼──────────────────────────┐
                             │  Adversary    │  │  Composite score >= 3.0?  │
                             │  approves?    │  └──────────────┬────────────┘
                             └──────┬────────┘               / \
                                   / \                      YES  NO
                                 YES  NO                     │    │
                                  │    │        ┌────────────▼┐  ┌▼────────┐
                           ┌──────▼┐  ┌▼──────┐ │  Any dim   │  │ NO-GO  │
                           │  GO   │  │NO-GO  │ │  scores 2? │  └────────┘
                           │ →     │  │Archive│ └──────┬─────┘
                           │planner│  └───────┘       / \
                           └───────┘                YES   NO
                                                     │     │
                                          ┌──────────▼┐  ┌─▼──────────┐
                                          │CONDITIONAL │  │  GO (flat  │
                                          │    GO      │  │  3.0 pass) │
                                          │Advance with│  └────────────┘
                                          │conditions  │
                                          └────────────┘
```

### The Conditional Go Path

A Conditional Go advances the idea to `factorium:planner` but attaches conditions to the Research Summary that the
Planner must acknowledge and address. Conditions are specific, not generic.

**Good conditions:**

- "Advance only if the Planner can scope this to the existing mobile web surface area; native app extension is out of
  scope for this pass."
- "Feasibility score was 2 due to unknown cache invalidation behavior with the ORM. The Planner should flag this as a
  technical risk item that requires a proof-of-concept before architecture begins."
- "Strategic Fit was 2 because the roadmap does not currently include this area. The Planner should verify with the
  product owner that this aligns with the next planning cycle's priorities."

**Bad conditions:**

- "This should be investigated further." (Not actionable.)
- "The team should think carefully about feasibility." (Not specific.)
- "May want to reconsider the scope." (No measurable acceptance criterion.)

Conditions that cannot be stated specifically are a sign that the research is inconclusive. Requeue to self rather than
advancing on vague conditions.
