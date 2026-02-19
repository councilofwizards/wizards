---
title: "Sales Planning Skill (/plan-sales)"
status: "complete"
priority: "P3"
category: "business-skills"
effort: "medium"
impact: "medium"
dependencies: []
created: "2026-02-19"
updated: "2026-02-19"
---

# Sales Planning Skill (`/plan-sales`)

## Problem

Early-stage startups need a structured sales strategy but often lack dedicated sales leadership. Founders make ad-hoc decisions about target markets, pricing, positioning, and go-to-market without systematic analysis. The result is scattered efforts, missed opportunities, and strategies based on assumptions rather than evidence.

## Proposed Solution

A multi-agent Collaborative Analysis skill that:
1. **Researches** the project's current state, market context, and competitive positioning from project artifacts and user-provided data
2. **Analyzes** in parallel via multiple agents who cross-reference and challenge each other's findings
3. **Synthesizes** a sales strategy assessment with evidence-traced recommendations
4. **Validates** through dual-skeptic review: Accuracy Skeptic (data, projections, evidence) + Strategy Skeptic (assumptions, alternatives, risks)

This is the second business skill in the conclave framework and the first to implement the Collaborative Analysis consensus pattern from the business skill design guidelines.

## Architectural Considerations

- **Collaborative Analysis pattern**: Agents work in parallel, share partial findings via SendMessage, cross-reference and challenge each other's work, then synthesize collaboratively. First implementation of this consensus pattern.
- **Dual-skeptic review**: Accuracy Skeptic + Strategy Skeptic. Both must approve.
- **Scope constraint**: Sales strategy assessment for early-stage startups only. Not a full sales operations toolkit.
- **Quality without ground truth**: Sales projections and market assessments cannot be verified against code. Mandatory business quality sections (Assumptions, Confidence, Falsification Triggers, External Validation) apply.

## Strategic Value

- Unblocks P2-08 (Plugin Organization) — provides the 2nd business skill (2/2 prerequisite)
- Validates the Collaborative Analysis consensus pattern (first implementation)
- Advances skill count toward P2-07 threshold (6/8)
- Natural complement to `/draft-investor-update` (forward-looking vs. retrospective)
- Provides pattern diversity data for eventual P2-07 analysis

## Success Criteria

- Produces a structured sales strategy assessment with dual-skeptic approval
- Implements Collaborative Analysis with concrete cross-referencing protocol
- Every claim traces to evidence or is explicitly marked as an assumption
- All mandatory business quality sections present (Assumptions, Confidence, Falsification Triggers, External Validation)
- Handles first-run gracefully (no prior sales plans, minimal project data)

## References

- [Business Skill Design Guidelines](../architecture/business-skill-design-guidelines.md)
