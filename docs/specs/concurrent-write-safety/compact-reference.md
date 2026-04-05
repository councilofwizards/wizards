---
type: "compact-reference"
feature: "concurrent-write-safety"
source_roadmap: "docs/roadmap/P1-01-concurrent-write-safety.md"
compacted: "2026-04-05"
---

# Concurrent Write Safety — Engineering Reference

## What Was Built

File-per-concern partitioning convention enforced via Write Safety sections in all 3 original SKILL.md files. Parallel
agents write only to role-scoped files; only the team lead writes to shared/index files after parallel work completes.

## Entrypoints

- `plugins/conclave/skills/plan-product/SKILL.md` — Write Safety section
- `plugins/conclave/skills/build-product/SKILL.md` — Write Safety section
- `plugins/conclave/skills/review-quality/SKILL.md` — Write Safety section

## Files Modified/Created

- `plugins/conclave/skills/plan-product/SKILL.md` — Write Safety section: role-scoped naming for Researcher, Architect,
  DBA
- `plugins/conclave/skills/build-product/SKILL.md` — Write Safety section: role-scoped naming for Backend/Frontend
  engineers
- `plugins/conclave/skills/review-quality/SKILL.md` — Write Safety section: role-scoped naming for auditors and test
  engineers

## Dependencies

- **Depends on**: nothing
- **Depended on by**: P1-02 (state-persistence — checkpoint files use role-scoped filenames)

## Configuration

Convention: `docs/progress/{feature}-{role}.md`. No config files.

## Validation

No dedicated validator. Convention is enforced by agent instructions in SKILL.md Write Safety sections.
