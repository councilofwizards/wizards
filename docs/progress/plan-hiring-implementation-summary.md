---
feature: "plan-hiring"
status: "complete"
completed: "2026-02-19"
---

# P3-14: Hiring Planning Skill -- Implementation Summary

## Summary

Implemented the `/plan-hiring` skill — the first Structured Debate skill in the
conclave framework. The SKILL.md is 1560 lines defining a 6-agent team (Team
Lead + Researcher + Growth Advocate + Resource Optimizer + Bias Skeptic + Fit
Skeptic) that produces hiring plans for early-stage startups through adversarial
argumentation and neutral synthesis.

## Changes

### SKILL.md (plugins/conclave/skills/plan-hiring/SKILL.md)

Created a 1560-line / 76KB Structured Debate skill with:

- 6-phase protocol: Research -> Case Building -> Cross-Examination -> Synthesis
  -> Review -> Finalize
- 3-message cross-examination rounds with position tracking
  (MAINTAINED/MODIFIED/CONCEDED)
- Anti-premature-agreement rules (6 rules)
- Points of Agreement and Remaining Tensions capture
- Debate Resolution Summary for synthesis transparency
- Dual-skeptic gate (Bias Skeptic + Fit Skeptic)
- Lead-driven synthesis (Phase 4 breaks delegate mode)
- 5 complete agent spawn prompts with format templates
- 17-section output template (12 content + 4 business quality + 1 debate
  resolution)
- User data template and graceful degradation
- Shared Principles and Communication Protocol (byte-identical markers)
- Lightweight mode (debate agents -> Sonnet, Researcher + Skeptics stay Opus)
- Status mode for session progress reporting

### Validator Update (scripts/validators/skill-shared-content.sh)

Added 4 new sed expressions to `normalize_skeptic_names()` for:

- `bias-skeptic` / `Bias Skeptic`
- `fit-skeptic` / `Fit Skeptic`

## Files Created

- `plugins/conclave/skills/plan-hiring/SKILL.md` -- 1560-line Structured Debate
  skill definition

## Files Modified

- `scripts/validators/skill-shared-content.sh` -- 4 new sed expressions for
  skeptic name normalization
- `docs/roadmap/P3-14-plan-hiring.md` -- Status: ready -> complete
- `docs/roadmap/_index.md` -- P3-14 status updated to ✅

## Verification

- **Pre-implementation gate**: APPROVED by quality-skeptic (all 20 success
  criteria mapped, 12 constraints addressed)
- **Post-implementation gate**: APPROVED by quality-skeptic (all 20 success
  criteria pass, all 8 CI validators pass)
- **CI validators**: A1-A4 (skill-structure) PASS, B1-B3 (shared-content) PASS,
  E1 (progress-checkpoint) PASS
- **Shared content**: Byte-identical with authoritative source
  (plan-product/SKILL.md)
- **Skeptic name normalization**: bias-skeptic and fit-skeptic correctly handled
