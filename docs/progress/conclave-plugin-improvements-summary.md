---
feature: "conclave-plugin-improvements"
status: "complete"
completed: "2026-03-10"
---

# Research: Conclave Plugin Improvements -- Progress

## Summary

Market Research Team (Eldara Voss directing) evaluated the Conclave plugin for
improvement opportunities. Two researchers worked in parallel — Theron Blackwell
on architecture/ecosystem, Lyssa Moonwhisper on user experience/thematic
cohesion. Lead-as-Skeptic review verified all key claims.

## Changes

The primary finding is that the fantasy persona system (45 fictional identities)
is invisible during skill execution — spawn prompts reference agents by role ID
only, never by fictional name. Secondary findings include wizard-guide omitting
business skills, no guided first-run path, and engineering-specific shared
principles in non-engineering contexts.

## Files Created

- `docs/research/conclave-plugin-improvements-research.md` -- Final research
  artifact
- `docs/progress/conclave-plugin-improvements-market-researcher.md` -- Market
  researcher checkpoint
- `docs/progress/conclave-plugin-improvements-customer-researcher.md` --
  Customer researcher checkpoint
- `docs/progress/research-market-conclave-plugin-improvements-2026-03-10-cost-summary.md`
  -- Cost summary

## Verification

- Lead-as-Skeptic review: All key claims verified via grep and file reads
- Fictional name absence in SKILL.md: confirmed zero matches
- wizard-guide business skill omission: confirmed via full file read
- setup-project Next Steps: confirmed no wizard-guide mention
- Communication protocol placeholder: confirmed "product-skeptic" in
  authoritative source
