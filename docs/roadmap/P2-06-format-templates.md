---
title: "Artifact Format Templates"
status: "complete"
priority: "P2"
category: "core-framework"
effort: "medium"
impact: "high"
dependencies: ["project-bootstrap"]
created: "2026-02-14"
updated: "2026-02-14"
spec: "docs/specs/artifact-format-templates/spec.md"
---

# Artifact Format Templates

## Problem

The original framework design defined specific formats for roadmap items, feature specs, progress notes, and ADRs. None of these templates exist in the current SKILL.md files. Without templates, agents produce inconsistent formats across sessions — one spec might have "Requirements" and "Data Model" sections, another might have "User Stories" and "API Design." This inconsistency makes cross-team handoffs unreliable.

The roadmap format is now defined (ADR-001), but spec, progress, and ADR formats are still undefined.

## Proposed Solution

1. **Template files in docs/**: Create starter templates that agents reference:
   - `docs/specs/_template.md` — Feature spec format (summary, problem, solution, requirements, data model, API contract, success criteria)
   - `docs/progress/_template.md` — Progress checkpoint format (YAML frontmatter + checklist body, per DBA's design)
   - `docs/architecture/_template.md` — ADR format (status, context, decision, alternatives, consequences)
2. **SKILL.md references**: Add instructions in each skill's Setup section to read the relevant template before producing artifacts.
3. **Template validation**: The automated testing pipeline (P2-04) validates that templates exist and that agent-produced artifacts follow them.

## Architectural Considerations

- Templates must be lightweight — agents should read them quickly, not burn context on boilerplate.
- The spec template should support progressive disclosure (summary first, details later) per the original design's principle.
- ADR-001 already serves as the implicit roadmap template. This item formalizes the pattern for other artifact types.
- Templates are reference documents, not enforced schemas. Agents can deviate when justified.

## Success Criteria

- Two different `/plan-product` sessions produce specs with the same section structure.
- A `/build-product` team can reliably parse a spec produced by `/plan-product` because the format is predictable.
