---
feature: "skill-architecture-redesign"
status: "complete"
completed: "2026-02-21"
---

# Skill Architecture Redesign -- Spec Session Summary

## Summary

The Product Team produced an approved specification for decomposing the monolithic plan-product and build-product skills into a two-tier architecture: 8 granular Tier 1 skills, 2 composite Tier 2 skills, and 2 utility skills. The spec defines a consumer-owns-template artifact contract system, a 6-phase migration plan (Phase 0-5) with validator gates at every boundary, and a failure propagation model for cross-tier escalation.

## What Was Accomplished

- **Research brief**: Complete catalog of all 7 existing skills, team compositions, artifact types, shared content dependencies, orchestration patterns, and risk analysis.
- **Architecture design**: Full two-tier taxonomy with team compositions, artifact contracts, skeptic placement strategy, artifact detection algorithm, failure propagation model, and migration path.
- **ADR-004**: Accepted. Documents the decision, alternatives considered (4 rejected), and consequences (7 positive, 6 negative).
- **Skeptic review**: Initial review identified 3 blocking, 5 structural, 4 advisory issues. All resolved in revision. Final verdict: APPROVED.
- **Spec**: Aggregated to `docs/specs/skill-architecture-redesign/spec.md` with 10 success criteria.

## Key Decisions

1. **Stories before specs.** User stories (INVEST, SMART) define the need; technical specs define the solution. This is a pipeline reordering from the current architecture.
2. **Consumer-owns-template.** The skill that reads an artifact defines its schema. Producers read the template during bootstrap.
3. **Smart skeptic placement.** Lead-as-Skeptic for 2-3 agent teams; dedicated skeptic for 4+ agents or high-stakes outputs.
4. **Tier 2 invocation via Skill tool.** Composites call `Skill(skill: "conclave:{tier1}", args: "{feature}")`. Phase 0 PoC required before proceeding.
5. **P2-07 is a hard Phase 1 dependency.** Shared content extraction happens first, not last.
6. **discover-product deferred.** Achievable via direct Tier 1 invocation or plan-product's artifact detection.
7. **ideate-product and manage-roadmap remain separate.** Different cognitive modes, different invocation frequencies.

## Files Created

- `docs/specs/skill-architecture-redesign/spec.md` -- Approved specification
- `docs/architecture/ADR-004-two-tier-skill-architecture.md` -- Architecture Decision Record (accepted)
- `docs/progress/skill-architecture-redesign-researcher.md` -- Research brief
- `docs/progress/skill-architecture-redesign-architect.md` -- Architecture design
- `docs/progress/skill-architecture-redesign-product-skeptic.md` -- Skeptic review (2 rounds)
- `docs/progress/skill-architecture-redesign-summary.md` -- This file

## What Remains

The spec is ready for implementation. Next step: Phase 0 proof-of-concept to validate the Tier 2 -> Tier 1 Skill tool invocation mechanism.

## Verification

- Product Skeptic approved after 2 review rounds (initial REJECTED, revision APPROVED)
- All 3 blocking issues resolved: Tier 2 invocation specified with PoC gate, discover-product removed, validators interleaved
- All 5 structural issues resolved: artifact detection formalized, failure propagation defined, P2-07 dependency established, run-task type resolved, idea-generator retyped
- All 4 advisory notes addressed
