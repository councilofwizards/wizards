---
feature: "content-deduplication"
status: "complete"
completed: "2026-02-18"
---

# P2-05: Content Deduplication -- Progress

## Summary

Added HTML comment markers around the Shared Principles and Communication Protocol sections in all 3 SKILL.md files.
Normalized cosmetic inconsistencies in plan-product/SKILL.md (quote style, table formatting, horizontal rule separator)
so shared content is byte-identical. Created ADR-002 documenting the validated duplication strategy and the 8-skill
revision trigger.

## Changes

### Normalization (plan-product only)

- Normalized single quotes to double quotes in Shared Principle #2 and Communication Protocol tool mapping note
- Normalized table formatting from unpadded to padded style in the "When to Message" table
- Added `---` horizontal rule before Shared Principles section to match other files

### Shared Section Markers (all 3 files)

- Added `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->` around Shared Principles
- Added `<!-- BEGIN SHARED: communication-protocol -->` / `<!-- END SHARED: communication-protocol -->` around
  Communication Protocol
- Added `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->` after each BEGIN marker
- Added `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` / `<!-- END SKILL-SPECIFIC: communication-extras -->`
  around build-product's Contract Negotiation Pattern

### ADR-002

- Created ADR documenting the validated duplication decision, alternatives considered (CLAUDE.md extraction, shared
  plugin file), and the 8-skill revision trigger

## Files Modified

- `plugins/conclave/skills/plan-product/SKILL.md` -- 6 edits: quote normalization, table normalization, separator
  addition, shared section markers
- `plugins/conclave/skills/build-product/SKILL.md` -- 3 edits: shared section markers, skill-specific markers
- `plugins/conclave/skills/review-quality/SKILL.md` -- 2 edits: shared section markers
- `docs/roadmap/P2-05-content-deduplication.md` -- Status updated to complete
- `docs/roadmap/_index.md` -- Status emoji updated to complete

## Files Created

- `docs/architecture/ADR-002-content-deduplication-strategy.md` -- Validated duplication decision record

## Verification

- Quality Skeptic pre-implementation review: APPROVED (plan completeness, all 10 success criteria covered)
- Quality Skeptic post-implementation review: APPROVED (byte-identity verified for principles, structural equivalence
  verified for communication protocol, all markers present, ADR exists)
- All 10 success criteria from the spec confirmed met
