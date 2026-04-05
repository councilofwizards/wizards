---
title: "Content Deduplication"
status: complete
priority: P2
category: core-framework
completed: "2026-02-18"
---

# P2-05: Content Deduplication

## Summary

Added HTML comment markers around the Shared Principles and Communication Protocol sections in all 3 SKILL.md files to
enable drift detection. Normalized cosmetic inconsistencies in plan-product so shared content is byte-identical across
files. Created ADR-002 documenting the validated duplication strategy (extraction deferred per portability constraint).

## What Was Built

- `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->` markers in 3 SKILL.md files
- `<!-- BEGIN SHARED: communication-protocol -->` / `<!-- END SHARED: communication-protocol -->` markers in 3 SKILL.md
  files
- Authoritative source comment after each BEGIN marker
- `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` marker for build-product's Contract Negotiation Pattern
- Normalization of plan-product (quote style, table formatting, horizontal rule)
- `docs/architecture/ADR-002-content-deduplication-strategy.md`

## Key Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-07 (principles-split — builds on the shared/ + marker architecture)
