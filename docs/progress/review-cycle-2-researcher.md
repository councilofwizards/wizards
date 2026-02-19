---
feature: "review-cycle-2"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed research on next roadmap priorities after P2-03 completion"
updated: "2026-02-18"
---

# Research Findings: Next Roadmap Priorities (Post P2-03)

## Summary

P2-03 (Progress Observability) is now complete, leaving P2-02 (blocked), P2-07 (premature), and P2-08 (correctly deferred) as remaining P2 items. All three have valid reasons not to start now. The highest-value next action is to build a pathfinder business skill (P3-02 Onboarding Wizard or a business skill like P3-10 /plan-sales) to validate patterns before tackling P2-07 or P2-08, which both require real-world skill diversity to design properly.

## Key Facts

- **Completed P2 items**: P2-01, P2-03, P2-04, P2-05, P2-06 (5 of 8 P2 items done)
- **P2-03 status**: Marked `complete` in roadmap. Spec approved at `docs/specs/progress-observability/spec.md`. Status mode, end-of-session summaries, and optional checkpoint validator all specified.
- **P2-02 (Skill Composability)**: Still `not_started`. The showstopper identified in Cycle 1 (no documented mechanism for skill-to-skill invocation) remains unresolved. No new information found. Manual workflow continues to work.
- **P2-07 (Universal Shared Principles)**: Still `not_started`. **No roadmap file exists** -- only an `_index.md` entry. ADR-002 sets an explicit 8-skill threshold for extraction. We have 3 skills. Zero business skills built.
- **P2-08 (Plugin Organization)**: Still `not_started`. **No roadmap file exists**. Explicitly deferred until 2+ business skills are built. Zero business skills exist.
- **Current skill count**: 3 (plan-product, build-product, review-quality). All engineering-focused.
- **Business skill design guidelines**: Exist at `docs/architecture/business-skill-design-guidelines.md`. Covers multi-skeptic assignments, consensus patterns, quality-without-ground-truth framework for all planned business skills. This is a complete design framework waiting to be validated.
- **P3 roadmap files that exist**: Only P3-01 (Custom Agent Roles, Large), P3-02 (Onboarding Wizard, Small), P3-03 (Contribution Guide, Small). P3-04 through P3-22 are index-only entries with no roadmap files.
- **Data integrity issues persist**: P2-07 and P2-08 still lack roadmap files despite being referenced from `_index.md`. P3-04 through P3-22 also lack files. These were noted in Cycle 1 but not fixed.

## Candidate Analysis

### Remaining P2 Items

| Item | Actionable Now? | Blocker | Next Step |
|------|----------------|---------|-----------|
| P2-02 Skill Composability | No | Platform research needed (skill-to-skill invocation) | Standalone investigation, not a spec cycle |
| P2-07 Universal Shared Principles | No | 3/8 skills; 0 business skills; no roadmap file | Build first business skill to validate; create stub roadmap file |
| P2-08 Plugin Organization | No | 0/2 required business skills | Build 2+ business skills first |

**Assessment**: No remaining P2 item is ready for a full spec cycle. All three are blocked by prerequisites that cannot be shortcut.

### P3 Engineering Candidates

| Item | Effort | Impact | Dependencies | Ready? |
|------|--------|--------|-------------|--------|
| P3-01 Custom Agent Roles | Large | Medium | stack-generalization (done) | Yes, but Large |
| P3-02 Onboarding Wizard | Small | Medium | None | **Yes** |
| P3-03 Contribution Guide | Small | Low | None | Yes |
| P3-04 Incident Triage | Medium | Medium | None (index-only, needs roadmap file) | Needs scoping |
| P3-05 Tech Debt Review | Medium | Medium | None (index-only) | Needs scoping |
| P3-06 API Design | Medium | Medium | None (index-only) | Needs scoping |
| P3-07 Migration Planning | Large | Medium | None (index-only) | Needs scoping |

### P3 Business Candidates (Highest Strategic Value)

| Item | Effort | Impact | Strategic Value |
|------|--------|--------|----------------|
| P3-10 /plan-sales | Medium | Medium | **High** -- validates business skill pattern, informs P2-07 and P2-08 |
| P3-11 /plan-marketing | Medium | Medium | High -- validates business skill pattern |
| P3-12 /plan-finance | Medium-Large | Medium | Medium -- more complex, higher regulatory risk |
| P3-14 /plan-hiring | Medium | Medium | Medium |
| P3-16 /build-sales-collateral | Medium | Medium | High -- validates Pipeline consensus pattern |
| P3-17 /build-content | Medium | Medium | Medium |

**Note**: None of the P3 business skills have individual roadmap files. They are all index-only entries. Building any of them requires creating the roadmap file first.

## Inferences

1. **The project has a "cold start" problem for P2-07 and P2-08** (Confidence: High). Both require real business skill experience, but no business skills exist. The business skill design guidelines are a theoretical framework. Without a real pathfinder skill, any "universal principles" work would be designing in a vacuum.

2. **P3-02 (Onboarding Wizard) is the safest next item** (Confidence: High). Small effort, medium impact, no dependencies, has a complete roadmap file. It's a single-agent skill (no team spawning), which is architecturally simpler than anything else on the roadmap. It also exercises a new skill pattern (setup utility) that's different from the team-based patterns.

3. **A business pathfinder skill (P3-10 or P3-16) provides the most strategic value** (Confidence: Medium). Building one business skill would: (a) validate the business-skill-design-guidelines in practice, (b) reveal which engineering principles are truly universal vs. domain-specific (informing P2-07), (c) create the first of the 2 business skills needed for P2-08, (d) provide real-world data for the 8-skill threshold question in ADR-002. However, these are medium effort and we'd be building from an index-only description with no roadmap file.

4. **P3-10 /plan-sales is the best pathfinder candidate** (Confidence: Medium). Rationale: It uses the "Collaborative Analysis" consensus pattern (the most common among business skills), it already has multi-skeptic assignments defined (Accuracy Skeptic + Strategy Skeptic), and sales planning is a concrete domain where output quality can be somewhat evaluated (projections can be stress-tested against stated assumptions). It's also a "plan-*" skill, which is closest in structure to the existing plan-product, making the first business skill less architecturally novel.

5. **P2-02 requires a standalone platform investigation, not a spec cycle** (Confidence: High). The showstopper question (can one Claude Code skill invoke another?) has been outstanding since Cycle 1. It won't resolve itself. If someone spends 30 minutes testing this in Claude Code, we'd know whether P2-02 is feasible or needs re-scoping. This is a micro-task, not a product team effort.

## Risks and Concerns

1. **Roadmap data integrity is degrading**. P2-07, P2-08, and 19 P3 items (P3-04 through P3-22) exist only as `_index.md` entries with no corresponding files. The `_index.md` links to files that don't exist. This was flagged in Cycle 1 and remains unfixed. Risk: accumulating technical debt in the roadmap itself.

2. **Business skills are uncharted territory**. The design guidelines exist, but no business skill has been built. The first one will likely surface design issues not anticipated in the guidelines. We should expect iteration.

3. **Scope of "next item" is ambiguous**. The project has traditionally done one item at a time through the plan-build-review pipeline. Starting a P3 item while P2 items remain (even if blocked) changes the prioritization precedent. This may be fine -- blocked items should not block all progress -- but the decision should be explicit.

4. **P3-02 is useful but doesn't advance the P2-07/P2-08 prerequisites**. If the goal is to unblock the remaining P2 items, P3-02 doesn't help (it's a setup utility, not a new domain). A business skill does.

## Recommendation

**Primary recommendation: Start P3-02 (Onboarding Wizard) as the next spec cycle.**

Rationale:
- Smallest effort on the entire roadmap (Small)
- No dependencies or prerequisites
- Has a complete roadmap file with problem, solution, and success criteria
- Immediate user value (reduces onboarding friction)
- Exercises a new skill pattern (single-agent setup utility) that's architecturally simpler
- Low risk, high confidence in deliverability

**Secondary recommendation: Begin a business skill pathfinder (P3-10 /plan-sales) as the item after P3-02.**

Rationale:
- Validates the business skill design guidelines in practice
- Creates progress toward unblocking P2-07 and P2-08
- Highest strategic value among all P3 items
- Medium effort is manageable after a Small warm-up item

**Parallel recommendation: Create stub roadmap files for P2-07 and P2-08** as a cleanup task (not a spec cycle). Fix the data integrity issue flagged in Cycle 1.

**Optional micro-task: Test skill-to-skill invocation** in Claude Code. Spend 30 minutes determining if one skill can programmatically invoke another. Result determines whether P2-02 is feasible or must be re-scoped.

## Open Questions

1. Should we do P3-02 first (safest, fastest) or jump straight to a business skill pathfinder (highest strategic value but higher risk)?
2. Is there appetite for creating stub roadmap files for P2-07, P2-08, and the missing P3 items as a cleanup task?
3. Has anyone tested skill-to-skill invocation in Claude Code? Can this be done as a quick investigation outside the product team process?
4. Should the priority of P3-02 be elevated to P2 given its impact on adoption? The current P3 classification implies it's less important than items that are all blocked.
