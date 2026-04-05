---
type: "compact-reference"
feature: "automated-testing"
source_roadmap: "docs/roadmap/P2-04-automated-testing.md"
compacted: "2026-04-05"
---

# Automated Testing Pipeline — Engineering Reference

## What Was Built

Complete bash validation pipeline (A–D series, 10 checks) covering SKILL.md structure, shared content drift,
roadmap/spec frontmatter. Integrated into GitHub Actions CI. Pure bash + coreutils, bash 3.2 compatible.

## Entrypoints

- `scripts/validate.sh` — run all validators
- `scripts/validators/skill-structure.sh` — A-series (A1 frontmatter, A2 sections, A3 spawn defs, A4 markers)
- `scripts/validators/skill-shared-content.sh` — B-series (B1 principles drift, B2 protocol drift, B3 auth source)
- `scripts/validators/roadmap-frontmatter.sh` — C-series (C1 required fields, C2 filename convention)
- `scripts/validators/spec-frontmatter.sh` — D-series (D1 required fields)
- `.github/workflows/validate.yml` — CI trigger

## Files Modified/Created

- `scripts/validate.sh` — Created: entry point
- `scripts/validators/skill-structure.sh` — Created
- `scripts/validators/skill-shared-content.sh` — Created
- `scripts/validators/roadmap-frontmatter.sh` — Created
- `scripts/validators/spec-frontmatter.sh` — Created
- `.github/workflows/validate.yml` — Created
- `docs/specs/project-bootstrap/spec.md` — Added missing YAML frontmatter

## Dependencies

- **Depends on**: nothing
- **Depended on by**: P2-03 (adds E-series), P2-07 (updates A4/B1/B3), P2-08 (adds G-series)

## Configuration

Run all checks: `bash scripts/validate.sh`. Exits non-zero on any failure.

## Validation

Self-validating: `bash scripts/validate.sh` is the validation command.
