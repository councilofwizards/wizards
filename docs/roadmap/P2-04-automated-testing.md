---
title: "Automated Testing Pipeline"
status: complete
priority: P2
category: quality-reliability
completed: "2026-02-18"
---

# P2-04: Automated Testing Pipeline

## Summary

Built a complete bash-based validation pipeline covering SKILL.md structure, shared content drift, roadmap frontmatter,
and spec frontmatter. Integrated into GitHub Actions CI. All validation uses pure bash + coreutils with no external
dependencies — compatible with bash 3.2 (macOS stock).

## What Was Built

- `scripts/validate.sh` — entry point; runs all validators, aggregates pass/fail, exits non-zero on failure
- `scripts/validators/skill-structure.sh` — A1 (frontmatter), A2 (required sections), A3 (spawn definitions), A4 (shared
  markers)
- `scripts/validators/skill-shared-content.sh` — B1 (principles drift), B2 (protocol drift with skeptic name
  normalization), B3 (authoritative source)
- `scripts/validators/roadmap-frontmatter.sh` — C1 (required fields + enum validation), C2 (filename convention)
- `scripts/validators/spec-frontmatter.sh` — D1 (required fields + enum validation)
- `.github/workflows/validate.yml` — GitHub Actions CI on push/PR to main

## Key Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-03 (adds E-series), P2-08 (adds G-series), all items that add validators thereafter
