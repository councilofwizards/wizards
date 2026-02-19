---
title: "Investor Update Skill (/draft-investor-update)"
status: "complete"
priority: "P3"
category: "business-skills"
effort: "Small-Medium"
impact: "medium"
dependencies: []
created: "2026-02-19"
updated: "2026-02-19"
---

# Investor Update Skill (`/draft-investor-update`)

## Problem

Startup founders send periodic investor updates summarizing progress, challenges, metrics, and asks. Writing these updates is time-consuming: data is scattered across roadmap files, progress checkpoints, specs, and architecture docs. Accuracy is hard to verify manually, narrative bias is natural, and consistency across updates erodes over time.

## Proposed Solution

A multi-agent Pipeline skill that:
1. **Gathers** project data from `docs/roadmap/`, `docs/progress/`, `docs/specs/`, `docs/architecture/` and user-provided financial/team data from a template file
2. **Drafts** a structured investor update following standard format (executive summary, metrics, milestones, challenges, outlook, team, financial, asks)
3. **Validates** through dual-skeptic review: Accuracy Skeptic (numbers, claims, evidence) + Narrative Skeptic (spin, omissions, consistency with prior updates)

This is the first business skill in the conclave framework and serves as the pathfinder for the Pipeline collaboration pattern and "quality without ground truth" requirements defined in the business skill design guidelines.

## Architectural Considerations

- **Pipeline pattern**: Sequential handoffs (Research -> Draft -> Review -> Revise -> Finalize) with quality gates. First implementation of this collaboration pattern.
- **Dual-skeptic review**: Two skeptics with non-overlapping concerns, both must approve. First multi-skeptic implementation.
- **Evidence tracing**: Every factual claim links to a source file. Substitutes for code-test verification in business documents.
- **User data integration**: Financial metrics, team updates, and asks come from a template file (`_user-data.md`), not from project artifacts.
- **Self-dogfooding**: Can be tested on the conclave project itself.

## Strategic Value

- Validates the entire business-skill design guidelines framework
- Advances skill count toward P2-07 threshold (5/8)
- Creates the first business skill needed for P2-08 (1/2)
- Pipeline pattern is the simplest new consensus pattern to implement

## Success Criteria

- Produces a complete investor update from project data with dual-skeptic approval
- Every claim traces to evidence
- Handles first-run gracefully (no prior updates, no user data file)
- All mandatory business quality sections present (Assumptions, Confidence, Falsification Triggers, External Validation)

## References

- [Full Specification](../specs/investor-update/spec.md)
- [System Design](../architecture/investor-update-system-design.md)
- [Business Skill Design Guidelines](../architecture/business-skill-design-guidelines.md)
