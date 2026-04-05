---
title: "Artifact Format Templates"
status: complete
priority: P2
category: core-framework
completed: "2026-02-14"
---

# P2-06: Artifact Format Templates

## Summary

Created three template files that standardize the format of feature specs, progress summaries, and ADRs. Added a
template read step to each SKILL.md Setup section so agents load reference formats before producing artifacts. Templates
are reference documents, not enforced schemas.

## What Was Built

- `docs/specs/_template.md` — spec format (Summary, Problem, Solution, Constraints, Out of Scope, Files to Modify,
  Success Criteria + YAML frontmatter)
- `docs/progress/_template.md` — progress summary format (Summary, Changes, Files Modified, Files Created,
  Verification + YAML frontmatter)
- `docs/architecture/_template.md` — ADR format (Status, Context, Decision, Alternatives Considered, Consequences + YAML
  frontmatter)
- Template read step (Step 2 with "if they exist" guard) added to all 3 SKILL.md Setup sections

## Key Dependencies

- **Depends on**: P1-00 (project-bootstrap — docs/ directories must exist)
- **Depended on by**: P2-03 (session summaries reference progress template), P2-11 (artifact templates extended)
