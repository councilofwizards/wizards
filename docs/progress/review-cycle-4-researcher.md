---
feature: "review-cycle-4"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed research on roadmap priorities after P3-22 completion"
updated: "2026-02-19"
---

# Research Findings: Roadmap Priorities After P3-22 Completion

## Summary

P3-22 (Investor Update / `/draft-investor-update`) and P3-02 (Onboarding Wizard / `/setup-project`) are both now complete. The project has 5 skills (plan-product, build-product, review-quality, setup-project, draft-investor-update), including 1 business skill. Two of the three blocked P2 items have measurably progressed toward their unblocking thresholds. The next action should be a second business skill to unblock P2-08 (Plugin Organization), which requires 2+ business skills. The strongest candidate is P3-10 (`/plan-sales`) or P3-16 (`/build-sales-collateral`), with a dark horse of P3-17 (`/build-content`).

---

## 1. Delta Analysis: What Changed Since Review Cycle 3

| Item | Cycle 3 Status | Current Status | Changed? |
|------|---------------|----------------|----------|
| P3-22 (Investor Update) | Selected for spec | **Complete** (implemented, merged, CI passing) | Yes -- done |
| P3-02 (Onboarding Wizard) | Complete | Complete | No -- already done before Cycle 3 |
| P2-02 (Skill Composability) | Blocked (no invocation mechanism) | Still blocked | No |
| P2-07 (Universal Shared Principles) | Premature (4/8 skills) | Now **5/8 skills** (draft-investor-update added) | Yes -- closer to threshold |
| P2-08 (Plugin Organization) | Deferred (0/2 business skills) | Now **1/2 business skills** (draft-investor-update) | Yes -- halfway there |
| Skill count | 4 | **5** | Yes |
| Business skill count | 0 | **1** | Yes |
| Roadmap data integrity | 19 P3 + 2 P2 items missing files | **Still missing** -- P2-07, P2-08, P3-04 through P3-21 lack files | No |
| New roadmap items | None | None | No |

**Assessment (Confidence: HIGH)**: Two significant changes since Cycle 3:
1. P3-22 is complete, giving us our first business skill and advancing P2-07 (5/8) and P2-08 (1/2) thresholds.
2. The skill count is now 5, meaning P2-07's 8-skill threshold is 62.5% reached.

---

## 2. P2 Blocker Assessment

### P2-02 (Skill Composability) -- STILL BLOCKED

**Status**: `not_started`. Blocked since Cycle 1.

**Blocker**: No documented mechanism for skill-to-skill invocation in Claude Code. This was flagged in Cycle 1 and Cycle 2 as requiring a standalone platform investigation (not a spec cycle). The investigation has not been performed.

**Has anything changed?** No. No new information in the codebase about this capability. The SKILL.md files do not reference any cross-skill invocation mechanism. This remains blocked.

**Confidence**: HIGH that this is still blocked. LOW confidence on whether the platform gap has been addressed upstream (we haven't checked).

### P2-07 (Universal Shared Principles) -- APPROACHING BUT NOT AT THRESHOLD

**Status**: `not_started`. No roadmap file exists (index-only entry).

**ADR-002 threshold**: "When the skill count exceeds 8, revisit this approach." (Line 56 of ADR-002-content-deduplication-strategy.md)

**Current state**: 5 skills. 3 skills away from the 8-skill threshold. The shared content system (HTML markers + CI drift validator) is working well across all 5 skills. No drift has been reported.

**Has anything changed?** Yes -- the skill count went from 4 to 5. But 5 is still well below 8. The business-skill-design-guidelines.md framework was successfully validated by P3-22 (the first skill to implement all quality-without-ground-truth requirements), which provides some data on what "universal" means across engineering and business contexts. However, with only 1 business skill, we have insufficient diversity to generalize.

**Assessment (Confidence: HIGH)**: P2-07 remains premature. The ADR-002 threshold is clear and quantitative. 5 < 8. Taking action now would be premature and speculative.

### P2-08 (Plugin Organization) -- HALFWAY UNBLOCKED

**Status**: `not_started`. No roadmap file exists (index-only entry).

**Prerequisite**: "Defer plugin organization until 2+ business skills are built and validated." (Line 69 of `_index.md`)

**Current state**: 1 business skill (draft-investor-update). Needs 1 more.

**Has anything changed?** Yes -- P3-22's completion moves us from 0/2 to 1/2. This is the most significant unblocking progress of any P2 item.

**Assessment (Confidence: HIGH)**: Building one more business skill directly unblocks P2-08. This is the strongest strategic argument for prioritizing a second business skill as the next feature.

---

## 3. Current Skill Inventory

| # | Skill | Category | Pattern | Agents |
|---|-------|----------|---------|--------|
| 1 | `/plan-product` | core-engineering | Parallel + Skeptic | 4 (researcher, architect, product-skeptic, + lead) |
| 2 | `/build-product` | core-engineering | Parallel + Skeptic | 6 (impl-architect, backend-eng, frontend-eng, dba, quality-skeptic, + lead) |
| 3 | `/review-quality` | core-engineering | Parallel + Skeptic | 4 (auditor, reviewer, ops-skeptic, + lead) |
| 4 | `/setup-project` | developer-experience | Single-agent | 1 (validator + lead) |
| 5 | `/draft-investor-update` | business | Pipeline + Dual-Skeptic | 5 (researcher, drafter, accuracy-skeptic, narrative-skeptic, + lead) |

**Pattern diversity**:
- Parallel + Single Skeptic: 3 skills (engineering)
- Single-agent: 1 skill (setup)
- Pipeline + Dual Skeptic: 1 skill (business)

**Consensus patterns NOT YET IMPLEMENTED** (from business-skill-design-guidelines.md):
- **Collaborative Analysis**: Planned for `/plan-sales`, `/plan-marketing`, `/plan-customer-success`, `/plan-analytics`
- **Structured Debate**: Planned for `/plan-finance`, `/review-legal`, `/plan-operations`, `/plan-hiring`

---

## 4. Next Feature Candidate Analysis

### Tier 1: Strongest Strategic Candidates (Second Business Skill)

Building a second business skill would:
- Unblock P2-08 (Plugin Organization) -- moves from 1/2 to 2/2
- Advance P2-07 skill count from 5/8 to 6/8
- Validate a SECOND consensus pattern (either Collaborative Analysis or Structured Debate)
- Provide cross-business-skill data for the "universal principles" question

| Candidate | Effort | Consensus Pattern | Strategic Value | Risk Level |
|-----------|--------|------------------|-----------------|------------|
| **P3-10 `/plan-sales`** | Medium | Collaborative Analysis | **Very High** | Medium |
| **P3-16 `/build-sales-collateral`** | Medium | Pipeline | Medium | Low |
| **P3-17 `/build-content`** | Medium | Pipeline | Medium | Low |
| **P3-11 `/plan-marketing`** | Medium | Collaborative Analysis | High | Medium |
| **P3-14 `/plan-hiring`** | Medium | Structured Debate | High | Medium |

#### P3-10 `/plan-sales` -- RECOMMENDED

**Strengths**:
- Validates the **Collaborative Analysis** consensus pattern (the most commonly assigned pattern among business skills, used by 4 of 12 skills). This is the highest-leverage pattern to validate next.
- Already has multi-skeptic assignments defined: Accuracy Skeptic + Strategy Skeptic (from business-skill-design-guidelines.md)
- Sales planning is a concrete domain where output quality can be stress-tested against assumptions and projections
- A "plan-*" skill, structurally closest to existing `/plan-product`, reducing architectural novelty

**Weaknesses**:
- No roadmap file exists (index-only). Needs to be created as part of the spec cycle.
- Medium effort -- not as fast as a Small item.
- Collaborative Analysis is a genuinely new pattern (parallel work with cross-referencing). More design work needed than Pipeline (which P3-22 already validated).
- Sales planning requires external market data and projections that may not exist in the project. More "quality without ground truth" risk than investor updates.

#### P3-16 `/build-sales-collateral` -- ALTERNATIVE

**Strengths**:
- Uses the **Pipeline** pattern, which P3-22 already validated. Lower design risk.
- Sales collateral has a concrete, verifiable output (pitch decks, one-pagers, case studies).
- Pairs naturally with `/plan-sales` for eventual composability.

**Weaknesses**:
- Pipeline pattern already validated by P3-22. Lower strategic value for pattern diversity.
- Requires sales plan data as input -- circular dependency with `/plan-sales` in practice.
- Less useful standalone (collateral needs a strategy to be based on).

#### P3-17 `/build-content` -- DARK HORSE

**Strengths**:
- Uses Pipeline pattern. Low design risk.
- Content production is universally useful (every startup needs content).
- Has verifiable output quality (blog posts, documentation, etc.)
- Quality Skeptic + Strategy Skeptic assignments defined.

**Weaknesses**:
- Pipeline already validated. Low pattern diversity value.
- Content production is broad -- scoping may be harder than it looks.
- Less strategic urgency than sales-related skills.

### Tier 2: Engineering Skills (Defer)

| Candidate | Effort | Value Now | Why Defer |
|-----------|--------|-----------|-----------|
| P3-01 Custom Agent Roles | Large | Low | Large effort. Does not advance P2 blockers. No urgent user need. |
| P3-03 Contribution Guide | Small | Low | Documentation. Low impact. Does not advance P2 blockers. Can be done anytime. |
| P3-04 Incident Triage | Medium | Low | Engineering skill. Does not advance P2 blockers. No roadmap file. |
| P3-05 Tech Debt Review | Medium | Low | Engineering skill. Does not advance P2 blockers. No roadmap file. |
| P3-06 API Design | Medium | Low | Engineering skill. Does not advance P2 blockers. No roadmap file. |
| P3-07 Migration Planning | Large | Low | Engineering skill. Large effort. Does not advance P2 blockers. No roadmap file. |

**Assessment (Confidence: HIGH)**: No engineering P3 item advances the P2 blockers. The strategic priority is clearly a second business skill.

### Tier 3: More Complex Business Skills (Not Yet)

| Candidate | Why Not Now |
|-----------|------------|
| P3-12 `/plan-finance` | Medium-Large effort + regulatory complexity (3 skeptics). Too risky as second pathfinder. |
| P3-18 `/review-legal` | Medium-Large effort + regulatory complexity (3 skeptics). Too risky as second pathfinder. |
| P3-15 `/plan-customer-success` | Depends on having customers. May not be testable on current project. |
| P3-19, P3-20, P3-21 | "Scale & Optimize" category. Premature for a project in the build phase. |

---

## 5. Roadmap Data Integrity Debt

**Still outstanding from Cycle 2**: 21 items in `_index.md` that reference non-existent roadmap files.

**Missing P2 roadmap files**: P2-07, P2-08
**Missing P3 roadmap files**: P3-04, P3-05, P3-06, P3-07, P3-10, P3-11, P3-12, P3-14, P3-15, P3-16, P3-17, P3-18, P3-19, P3-20, P3-21

**Note**: P3-22 now has a roadmap file (created in Cycle 3). This is the only data integrity improvement since Cycle 2.

**Impact**: The `_index.md` links to files that don't exist, which would break any automated tooling that follows those links. This is minor debt currently, but grows as more items are referenced.

**Recommendation**: At minimum, create roadmap files for the selected next feature and for P2-07 and P2-08 (since they are the most frequently discussed items). The remaining stub files can be batch-created as a cleanup task.

---

## 6. Status of P3-22 Roadmap File

The roadmap file at `docs/roadmap/P3-22-draft-investor-update.md` shows status `ready`, not `complete`. The `_index.md` shows P3-22 as complete (`✅`). This is a minor inconsistency -- the individual roadmap file should be updated to `status: "complete"`.

---

## 7. Recommendation

**Primary recommendation: P3-10 `/plan-sales` as the next feature.**

Rationale:
1. **Directly unblocks P2-08**: Completing a second business skill satisfies the "2+ business skills" prerequisite.
2. **Validates Collaborative Analysis**: The most commonly assigned consensus pattern (4/12 business skills). Highest leverage second pattern to validate.
3. **Advances P2-07**: Skill count goes from 5/8 to 6/8 (75% of threshold).
4. **Natural complement to P3-22**: Investor updates report what happened; sales plans drive what happens next. Together they cover retrospective and forward-looking business functions.
5. **Medium effort is manageable**: We've successfully delivered multiple Medium-effort items in sequence.

**Alternative recommendation: P3-16 `/build-sales-collateral` if the team prefers lower design risk.**

Rationale: Pipeline pattern already validated, so less design work. But it provides less strategic value (no new consensus pattern validated).

**Cleanup tasks (micro-work, not a spec cycle)**:
1. Update P3-22 roadmap file status from `ready` to `complete`
2. Create stub roadmap files for P2-07 and P2-08
3. Create a roadmap file for the selected next feature (P3-10 or alternative)

**Confidence levels**:
- Second business skill is the right category: HIGH
- P3-10 is the best specific candidate: MEDIUM (P3-16 and P3-17 are viable alternatives)
- P2-08 will unblock after 2 business skills: HIGH (explicit prerequisite in `_index.md`)
- P2-07 remains premature: HIGH (5/8, clear ADR-002 threshold)
- P2-02 remains blocked: HIGH (no new information on platform gap)
