---
title: "Custom Agent Roles"
status: "not_started"
priority: "P3"
category: "new-skills"
effort: "large"
impact: "medium"
dependencies: ["stack-generalization"]
created: "2026-02-14"
updated: "2026-02-14"
---

# Custom Agent Roles

## Problem

The current agent roles (Researcher, Architect, DBA, Backend Engineer, etc.) are fixed in the SKILL.md files. Projects with different needs (e.g., a data pipeline project that needs a Data Engineer instead of a Frontend Engineer) must edit the skill files directly.

## Proposed Solution

1. **Role definition files**: Allow users to define custom agent roles in `docs/agents/` or a project-level config.
2. **Role composition**: Skills read available roles at startup and compose teams from the available pool.
3. **Role templates**: Provide starter templates for common roles (Data Engineer, ML Engineer, Mobile Engineer) that users can drop in.

## Architectural Considerations

- The Skeptic role must remain mandatory and non-customizable — it's the quality gate.
- Custom roles must follow the same communication protocol and shared principles.
- This significantly increases SKILL.md complexity. Consider whether a separate "team config" file format is needed.

## Success Criteria

- A user can add a custom agent role without editing any SKILL.md file.
- The Skeptic pattern is preserved regardless of team composition.
