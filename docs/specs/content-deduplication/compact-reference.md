---
type: "compact-reference"
feature: "content-deduplication"
source_roadmap: "docs/roadmap/P2-05-content-deduplication.md"
compacted: "2026-04-05"
---

# Content Deduplication — Engineering Reference

## What Was Built

HTML comment markers added around Shared Principles and Communication Protocol sections in 3 SKILL.md files to enable
drift detection. plan-product normalized to achieve byte-identical shared content. ADR-002 documents validated
duplication strategy.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — `<!-- BEGIN SHARED: principles -->` /
  `<!-- END SHARED: principles -->` and communication-protocol markers (authoritative source)
- `plugins/conclave/skills/build-product/SKILL.md` — same markers +
  `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->`
- `plugins/conclave/skills/review-quality/SKILL.md` — same markers
- `docs/architecture/ADR-002-content-deduplication-strategy.md`

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — 6 edits: quote normalization, table normalization, `---` separator,
  shared markers
- `plugins/conclave/skills/build-product/SKILL.md` — 3 edits: shared markers, skill-specific marker
- `plugins/conclave/skills/review-quality/SKILL.md` — 2 edits: shared markers
- `docs/architecture/ADR-002-content-deduplication-strategy.md` — Created

## Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-07 (principles-split — uses the shared/ + marker convention)

## Configuration

Marker pattern: `<!-- BEGIN SHARED: {block-name} -->` / `<!-- END SHARED: {block-name} -->` with authoritative source
comment.

## Validation

`bash scripts/validate.sh` — B1 (principles drift), B2 (protocol drift with skeptic name normalization), B3
(authoritative source comments).
