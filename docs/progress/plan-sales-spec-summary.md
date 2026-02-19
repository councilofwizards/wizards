---
feature: "plan-sales-spec"
team: "plan-product"
agent: "team-lead"
phase: "complete"
status: "complete"
last_action: "Completed P3-10 /plan-sales spec cycle"
updated: "2026-02-19"
---

# P3-10: Sales Planning Skill Spec -- Summary

## Summary

The plan-product team researched and specified P3-10 (`/plan-sales`) -- the first Collaborative Analysis skill in the conclave framework and the second business skill. The spec defines a concrete cross-referencing protocol where 3 analysis agents (Market Analyst, Product Strategist, GTM Analyst) work in parallel, share structured Domain Briefs, cross-reference each other's findings for contradictions/gaps/challenges/synergies, and the Team Lead synthesizes the result for dual-skeptic validation (Accuracy + Strategy).

## Outcome

- **Spec written**: `docs/specs/plan-sales/spec.md` (approved by product-skeptic)
- **System design**: `docs/architecture/plan-sales-system-design.md`
- **Roadmap status**: Updated from 🔴 to 🟢 (ready for implementation)

## Key Design Decisions

1. **Phase-gated Collaborative Analysis**: 5 phases (Independent Research -> Cross-Referencing -> Synthesis -> Review -> Finalize) with structured gates between each phase. Not free-form collaboration.
2. **Structured artifacts**: Domain Briefs (Phase 1 output) and Cross-Reference Reports (Phase 2 output) have defined formats with mandatory sections.
3. **Lead-driven synthesis**: Team Lead writes the assessment directly (no Drafter agent) because the lead holds full context from orchestrating cross-referencing.
4. **All-Opus analysis agents**: Cross-referencing requires judgment-heavy reasoning that Sonnet would do superficially.
5. **3 analysis domains**: Market (external), Product (internal), GTM (channels/pricing) -- covers the three pillars of early-stage sales strategy.
6. **Inverted data ratio**: ~60-70% user-data-driven (vs. ~70-80% project-data-driven for investor updates). Requires more extensive user data template and prominent data-dependency warnings.

## Skeptic Conditions Satisfied

From Review Cycle 4:
1. Cross-referencing defined concretely -- phase gates, Domain Brief format, Cross-Reference Report format with 5 mandatory sections
2. Scope constrained to early-stage startup sales strategy assessment
3. Roadmap file created (done in Review Cycle 4)
4. P3-22 status fixed (done in Review Cycle 4)

From spec review:
1. Lead context management addressed -- section-by-section synthesis with checkpoint recovery
2. Formal spec sections included -- Files to Modify, Constraints, Success Criteria

## Files Created

- `docs/specs/plan-sales/spec.md` -- Full specification
- `docs/architecture/plan-sales-system-design.md` -- System design
- `docs/progress/plan-sales-researcher.md` -- Research findings
- `docs/progress/plan-sales-architect.md` -- Architect progress
- `docs/progress/plan-sales-product-skeptic.md` -- Skeptic review
- `docs/progress/plan-sales-spec-summary.md` -- This file

## Files Modified

- `docs/roadmap/_index.md` -- Updated P3-10 status from 🔴 to 🟢
- `docs/roadmap/P3-10-plan-sales.md` -- Updated status from `not_started` to `ready`

## Agents

| Agent | Tasks | Status |
|-------|-------|--------|
| researcher | #1 Research problem space | Complete |
| architect | #2 Design system architecture | Complete |
| product-skeptic | #3 Review and approve | Complete (approved with 2 non-blocking conditions) |
| team-lead | Spec writing, roadmap updates | Complete |
