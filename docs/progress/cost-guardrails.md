---
feature: "cost-guardrails"
status: "complete"
completed: "2026-02-14"
---

# P2-01: Cost Guardrails — Progress

## Summary

Added `--light` flag support to all 3 SKILL.md files and documented lightweight mode in README.md. Lightweight mode reduces Opus agent usage for cost-sensitive invocations while preserving all quality gates. Cost summary steps added to every skill's orchestration flow.

## Changes

### Lightweight Mode
- **plan-product**: `--light` downgrades Researcher and Architect to Sonnet, removes DBA. Skeptic stays Opus. (~56% savings)
- **build-product**: `--light` downgrades Impl Architect to Sonnet. Skeptic stays Opus. (~24% savings)
- **review-quality**: `--light` accepted but no changes applied (already at minimum viable configuration)

### Cost Summary Steps
- All 3 skills now include a final orchestration step for the Team Lead to write a cost summary file to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

### Argument Hints
- All 3 SKILL.md frontmatter `argument-hint` values updated to include `[--light]` as optional prefix

### README
- Added "Lightweight Mode" subsection inside "Cost Considerations" with per-skill savings table

## Files Modified

- `plugins/conclave/skills/plan-product/SKILL.md` — Lightweight Mode section, cost summary step, argument-hint
- `plugins/conclave/skills/build-product/SKILL.md` — Lightweight Mode section, cost summary step, argument-hint
- `plugins/conclave/skills/review-quality/SKILL.md` — Lightweight Mode section, cost summary step, argument-hint
- `README.md` — Lightweight Mode subsection in Cost Considerations

## Verification

- Pre-implementation plan reviewed and approved by Quality Skeptic (Gate 1)
- Post-implementation code reviewed and approved by Quality Skeptic (Gate 2)
- All 7 success criteria verified
- All non-negotiable constraints verified (Skeptic never downgraded, Security Auditor never downgraded)
