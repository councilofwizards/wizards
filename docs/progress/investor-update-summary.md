---
feature: "investor-update"
status: "complete"
completed: "2026-02-19"
---

# P3-22: Investor Update Skill -- Progress

## Summary

Implemented the `/draft-investor-update` multi-agent Pipeline skill -- the first business skill in the conclave framework. The skill gathers project data, drafts a structured investor update, and validates accuracy and tone through dual-skeptic review (Accuracy Skeptic + Narrative Skeptic). Also extended the CI validator to support the new skeptic names.

## Changes

### New Skill

Created `plugins/conclave/skills/draft-investor-update/SKILL.md` (738 lines) -- the first business skill and the first Pipeline-pattern skill in the framework. Implements:

- **Pipeline orchestration**: 4-stage sequential pipeline (Research -> Draft -> Review -> Revise) with quality gates between stages
- **Dual-skeptic review**: Accuracy Skeptic (numbers, claims, evidence) + Narrative Skeptic (spin, omissions, consistency), both must approve
- **Evidence-traced claims**: Every factual claim links to a source file in the project
- **Business quality sections**: Mandatory Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints
- **User data integration**: Template file at `docs/investor-updates/_user-data.md` for financial/team/asks data
- **Prior-update consistency**: Narrative Skeptic checks against prior updates in `docs/investor-updates/`
- **First-run handling**: Graceful degradation when no prior updates or user data file exist

### Validator Extension

Extended `normalize_skeptic_names()` in `scripts/validators/skill-shared-content.sh` with 4 new entries for `accuracy-skeptic`/`Accuracy Skeptic` and `narrative-skeptic`/`Narrative Skeptic`.

## Files Created

- `plugins/conclave/skills/draft-investor-update/SKILL.md` -- New multi-agent Pipeline skill definition

## Files Modified

- `scripts/validators/skill-shared-content.sh` -- Extended normalize function for new skeptic names
- `docs/roadmap/_index.md` -- Updated P3-22 status to ✅

## Verification

- Quality Skeptic pre-implementation gate: APPROVED (all 13 success criteria mapped to plan)
- Quality Skeptic post-implementation gate: APPROVED (all 13 success criteria verified against code)
- CI validation: All checks pass across 5 SKILL.md files
  - A1/frontmatter, A2/required-sections, A3/spawn-definitions, A4/shared-markers: PASS
  - B1/principles-drift, B2/protocol-drift, B3/authoritative-source: PASS
- Shared Principles: byte-identical to plan-product/SKILL.md authoritative source
- Communication Protocol: structurally equivalent after skeptic name normalization
