---
feature: "review-cycle-5"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed research on roadmap priorities after P3-10 spec completion"
updated: "2026-02-19"
---

# Research Findings: Review Cycle 5 — Post P3-10 Spec

## Summary

P3-10 (`/plan-sales`) has been fully specced and approved by the product-skeptic. It is now at `ready` status, awaiting implementation. The P3-22 spec is also approved. Since Review Cycle 4, two specs were completed (P3-22 investor-update and P3-10 plan-sales), and P3-22 was implemented. The project has 5 implemented skills. This cycle focuses on: (1) assessing P2 blocker progress, (2) recommending the NEXT item to spec after P3-10 is implemented, (3) auditing roadmap data integrity, and (4) validating consensus pattern coverage.

---

## 1. Delta Analysis: What Changed Since Review Cycle 4

| Item | Cycle 4 Status | Current Status | Changed? |
|------|---------------|----------------|----------|
| P3-10 (Plan Sales) | Selected for spec | **Spec approved, `ready` status** | Yes -- specced |
| P3-22 (Investor Update) | Complete (implemented) | Complete | No |
| P2-02 (Skill Composability) | Blocked | Still blocked | No |
| P2-07 (Universal Shared Principles) | Premature (5/8) | Still premature (5/8) | No -- no new skill implemented since Cycle 4 |
| P2-08 (Plugin Organization) | 1/2 prerequisite | Still 1/2 (P3-10 specced but not implemented) | No -- awaiting P3-10 implementation |
| Skill count (implemented) | 5 | 5 | No |
| Business skill count (implemented) | 1 | 1 | No |
| Roadmap data integrity | 19 missing files reported | **14 missing files** (improved -- P2-07, P2-08, P3-10, P3-22, P3-01 now have files) | Yes -- partial cleanup |
| P3-10 spec | Not yet written | **Approved spec at `docs/specs/plan-sales/spec.md`** | Yes -- major deliverable |

**Assessment (Confidence: HIGH)**: The primary change since Cycle 4 is that P3-10's spec was written and approved. No new skills were implemented, so the P2 blocker thresholds (skill count, business skill count) have not advanced. P3-10 implementation is the critical path item.

---

## 2. P2 Blocker Assessment

### P2-02 (Skill Composability) -- STILL BLOCKED

**Status**: `not_started` (roadmap file says `not_started`).

**Blocker**: No platform support for skill-to-skill invocation in Claude Code. This has been blocked since Cycle 1. No investigation has been performed.

**Has anything changed?** No. No new information in the codebase. The roadmap file (created 2026-02-14) still describes the original problem. No external investigation has been done.

**What would unblock it?** Either:
1. Claude Code adds native skill-to-skill invocation support (external dependency)
2. A workaround is designed (e.g., workflow definitions that invoke skills sequentially via shell, or a meta-skill that manages a multi-skill pipeline)

**Assessment (Confidence: HIGH)**: Still blocked. No path forward without either platform support or a deliberate engineering investigation to design a workaround.

**Open question**: Should we treat P2-02 as "blocked on external dependency" and stop tracking it as actionable? Or should we add an investigation task to explore workarounds?

### P2-07 (Universal Shared Principles) -- STILL PREMATURE

**Status**: `not_started`.

**ADR-002 threshold**: "When the skill count exceeds 8" (ADR-002, line 56).

**Current count**: 5 implemented skills (plan-product, build-product, review-quality, setup-project, draft-investor-update). If P3-10 is implemented, that becomes 6.

**Multi-agent skills with shared content**: 4 (plan-product, build-product, review-quality, draft-investor-update). P3-10 would make 5.

**Note on counting**: The P2-07 roadmap file says "Currently 4 multi-agent skills carry shared content" and references the ADR-002 threshold of 8 skills total. The _index.md says 5/8. There is a discrepancy: the P2-07 file was created before P3-02 (setup-project) was counted but setup-project is single-agent and does NOT carry shared content. So the count depends on whether we count total skills (5) or multi-agent skills with shared content (4, or 5 after P3-10).

**Interpretation (Confidence: MEDIUM)**: ADR-002 says "skill count exceeds 8" -- this likely means total skills, not just multi-agent skills. At 5 total (6 after P3-10), we are still below 8. Either way, premature.

**Assessment (Confidence: HIGH)**: P2-07 remains premature. Even after P3-10 implementation (6 total skills), we need 2 more skills beyond that to hit the threshold.

### P2-08 (Plugin Organization) -- STILL 1/2

**Status**: `not_started`.

**Prerequisite**: "2+ business skills built and validated."

**Current state**: 1 business skill implemented (draft-investor-update). P3-10 (plan-sales) is specced and ready for implementation.

**When will this unblock?** When P3-10 is implemented. That gives us 2 business skills, satisfying the prerequisite.

**Assessment (Confidence: HIGH)**: P3-10 implementation is the single most impactful action. It unblocks P2-08, advances P2-07 to 6/8, and validates the Collaborative Analysis consensus pattern.

---

## 3. Implementation Queue Assessment

### Current Queue

The implementation queue currently has ONE item: **P3-10 (`/plan-sales`)** at `ready` status.

### What Should Be Specced Next?

After P3-10 is implemented, we'll have:
- 6 total skills
- 2 business skills (investor-update + plan-sales)
- P2-08 unblocked (2/2 business skills)
- P2-07 at 6/8 (needs 2 more skills)
- 2 of 3 consensus patterns validated (Pipeline + Collaborative Analysis)

**Strategic priorities for the NEXT spec cycle:**

#### Priority A: Third Business Skill to Validate Structured Debate

The three consensus patterns from business-skill-design-guidelines.md:
1. **Pipeline** -- Validated by P3-22 (`/draft-investor-update`) -- DONE
2. **Collaborative Analysis** -- Will be validated by P3-10 (`/plan-sales`) -- IN QUEUE
3. **Structured Debate** -- NOT YET VALIDATED

Structured Debate candidates (from design guidelines):
| Candidate | Effort | Complexity | Risk |
|-----------|--------|------------|------|
| P3-14 `/plan-hiring` | Medium | Moderate | Low -- well-scoped domain |
| P3-20 `/plan-operations` | Medium | Moderate | Low |
| P3-12 `/plan-finance` | Medium-Large | High | High -- 3 skeptics, regulatory |
| P3-18 `/review-legal` | Medium-Large | High | High -- 3 skeptics, regulatory |

**Recommendation: P3-14 (`/plan-hiring`)** as the next spec after P3-10 implementation.

Rationale:
1. Validates the Structured Debate pattern (completing all 3 consensus patterns)
2. Medium effort (not Medium-Large like finance/legal)
3. 2-skeptic model (Bias Skeptic + Fit Skeptic) -- no 3-skeptic complexity
4. Well-scoped domain (role definition, requirements, evaluation criteria)
5. Advances P2-07 to 7/8 (one skill away from threshold)
6. Concrete, testable output (job descriptions, hiring criteria, evaluation rubrics)

**Alternative: P3-11 (`/plan-marketing`)**

If the team prefers to validate another Collaborative Analysis skill before moving to Structured Debate (to get more data on how the pattern works in practice), `/plan-marketing` is the natural choice:
- Same Collaborative Analysis pattern as plan-sales
- ROI Skeptic + Brand Skeptic (interesting new skeptic types)
- But: provides pattern repetition data, not pattern diversity

#### Priority B: Unblock P2-07 (if the goal is to hit 8 skills fast)

If the goal shifts to reaching the 8-skill threshold for P2-07, any combination of skills works. The fastest path would be to pick 2 Small-Medium effort items. But this is a weaker strategic rationale than pattern validation.

#### Priority C: Engineering P3 Items (still not strategic)

No engineering P3 item advances P2 blockers. They remain low strategic priority. P3-03 (Contribution Guide) is Small effort and could be done as a filler task, but it provides no P2 blocker progress.

### Recommendation Summary

| Priority | Item | Rationale | Confidence |
|----------|------|-----------|------------|
| 1st (now) | **P3-10 implement** | Unblocks P2-08, validates Collaborative Analysis | HIGH |
| 2nd (next spec) | **P3-14 `/plan-hiring`** | Validates Structured Debate, advances P2-07 to 7/8 | MEDIUM-HIGH |
| Alt 2nd | **P3-11 `/plan-marketing`** | Deepens Collaborative Analysis data, advances P2-07 | MEDIUM |
| 3rd | **P3-12 or P3-20** | Complete Structured Debate portfolio | MEDIUM |

---

## 4. Roadmap Data Integrity Audit

### Items WITH individual roadmap files (17 items):

| # | Item | File Exists | Status |
|---|------|-------------|--------|
| P1-00 | Project Bootstrap | Yes | complete |
| P1-01 | Concurrent Write Safety | Yes | complete |
| P1-02 | State Persistence | Yes | complete |
| P1-03 | Stack Generalization | Yes | complete |
| P2-01 | Cost Guardrails | Yes | complete |
| P2-02 | Skill Composability | Yes | not_started |
| P2-03 | Progress Observability | Yes | complete |
| P2-04 | Automated Testing | Yes | complete |
| P2-05 | Content Deduplication | Yes | complete |
| P2-06 | Artifact Format Templates | Yes | complete |
| P2-07 | Universal Shared Principles | Yes (stub) | not_started |
| P2-08 | Plugin Organization | Yes (stub) | not_started |
| P3-01 | Custom Agent Roles | Yes | not_started |
| P3-02 | Onboarding Wizard | Yes | complete |
| P3-03 | Contribution Guide | Yes | not_started |
| P3-10 | Sales Planning | Yes | ready |
| P3-22 | Investor Update | Yes | complete |

### Items WITHOUT individual roadmap files (14 items):

| # | Item | Category | Status in _index.md |
|---|------|----------|-------------------|
| P3-04 | Incident Triage | new-skills | not_started |
| P3-05 | Tech Debt Review | new-skills | not_started |
| P3-06 | API Design | new-skills | not_started |
| P3-07 | Migration Planning | new-skills | not_started |
| P3-11 | Marketing Planning | business-skills | not_started |
| P3-12 | Finance Planning | business-skills | not_started |
| P3-14 | Hiring Planning | business-skills | not_started |
| P3-15 | Customer Success | business-skills | not_started |
| P3-16 | Sales Collateral | business-skills | not_started |
| P3-17 | Content Production | business-skills | not_started |
| P3-18 | Legal Review | business-skills | not_started |
| P3-19 | Analytics Planning | business-skills | not_started |
| P3-20 | Operations Planning | business-skills | not_started |
| P3-21 | Employee Onboarding | business-skills | not_started |

**Improvement since Cycle 4**: Cycle 4 reported 19 missing files (including P2-07, P2-08, P3-10, P3-22, and P3-01). Current count is 14. That's 5 files created since Cycle 3/4 cleanup work.

**Remaining scope**: 14 stub files needed. All are `not_started` P3 items (4 engineering, 10 business).

### Cleanup Recommendation

**Option A: Batch create all 14 stubs** (recommended)
- Small effort (template + iteration)
- Eliminates all broken links in `_index.md`
- Provides a consistent structure for future spec cycles
- Can be done as a quick cleanup task, not a full spec cycle

**Option B: Create stubs only for the next 2-3 candidates**
- Lower effort but leaves 11-12 broken links
- Requires repeated cleanup in future cycles

**Assessment (Confidence: HIGH)**: Option A is strictly better. The effort is small (14 stub files following the existing pattern), and it eliminates a recurring discussion point across 4 review cycles.

---

## 5. Consensus Pattern Validation Status

### Three Defined Patterns (from business-skill-design-guidelines.md)

| Pattern | Assigned Skills | Status | Validated By |
|---------|----------------|--------|--------------|
| **Pipeline** | build-sales-collateral, build-content, draft-investor-update, plan-onboarding | **VALIDATED** | P3-22 `/draft-investor-update` (complete) |
| **Collaborative Analysis** | plan-sales, plan-marketing, plan-customer-success, plan-analytics | **SPECCED, AWAITING IMPLEMENTATION** | P3-10 `/plan-sales` (ready) |
| **Structured Debate** | plan-finance, review-legal, plan-operations, plan-hiring | **NOT YET SPECCED** | None |

### Pattern Distribution

| Pattern | Skills Assigned | Skills Validated | Skills Specced |
|---------|----------------|-----------------|----------------|
| Pipeline | 4 | 1 (P3-22) | 1 (P3-22) |
| Collaborative Analysis | 4 | 0 | 1 (P3-10) |
| Structured Debate | 4 | 0 | 0 |

**Assessment (Confidence: HIGH)**: Equal distribution (4 skills per pattern) confirmed. Pipeline is validated. Collaborative Analysis will be validated when P3-10 is implemented. Structured Debate has no pathfinder yet.

### Engineering Skills Pattern

The 3 engineering skills (plan-product, build-product, review-quality) use a "Parallel + Single Skeptic" (hub-and-spoke) pattern that predates the business skill guidelines. Setup-project uses a single-agent pattern. Neither is formally classified under the 3 consensus patterns -- those patterns are business-skill-specific.

---

## 6. Open Questions

1. **P2-02 disposition**: Should Skill Composability be reclassified as "blocked on external dependency" to distinguish it from items where we can take action? Or should we investigate workarounds?

2. **P2-07 counting methodology**: Does "skill count exceeds 8" mean total skills or multi-agent skills with shared content? (Impact: if multi-agent only, we're at 4/8 not 5/8.)

3. **Roadmap cleanup ownership**: Should the 14 missing stub files be created by the Product Team as a cleanup task, or should it be delegated to an implementation cycle?

4. **Spec pipeline strategy**: Should we spec the next item (P3-14 or P3-11) now, while P3-10 awaits implementation? This would build a 2-deep implementation queue. The risk is speccing something that changes based on P3-10 implementation lessons.

---

## 7. Confidence Summary

| Finding | Confidence | Rationale |
|---------|------------|-----------|
| P2-02 still blocked | HIGH | No new information, no investigation done |
| P2-07 still premature | HIGH | 5 < 8, clear quantitative threshold |
| P2-08 unblocks after P3-10 implementation | HIGH | Explicit "2+ business skills" prerequisite |
| P3-10 is the critical path item | HIGH | Unblocks P2-08, validates Collaborative Analysis |
| P3-14 is the best next spec candidate | MEDIUM-HIGH | Best for pattern diversity, but P3-11 is viable alternative |
| 14 roadmap files missing | HIGH | Verified by file system audit |
| Batch stub creation is recommended | HIGH | Low effort, eliminates recurring issue |
| Spec pipeline question is unresolved | LOW | Depends on team strategy and P3-10 implementation timeline |
