---
title: "Onboarding Wizard Skill"
status: "complete"
priority: "P3"
category: "developer-experience"
effort: "small"
impact: "medium"
dependencies: []
created: "2026-02-14"
updated: "2026-02-19"
---

# Onboarding Wizard Skill

## Problem

New users must read the README, understand the three skills, set environment variables, and figure out the plan → build
→ review workflow. The learning curve is steeper than necessary for a tool meant to simplify development.

## Proposed Solution

1. **`/setup-project` skill**: A lightweight skill (no multi-agent team needed — single agent) that:
   - Detects the project's tech stack
   - Creates the `docs/` directory structure if missing
   - Generates starter `docs/roadmap/_index.md` with project-specific categories
   - Writes a `CLAUDE.md` with project conventions
   - Explains the workflow and next steps

## Architectural Considerations

- This is a single-agent skill — no team spawning, no Skeptic. It's a setup utility.
- Must be idempotent — running it twice should not overwrite existing docs.
- Should detect and respect existing project configuration.
- Prerequisite: CI validator must be adapted to support `type: single-agent` SKILL.md files.

## Spec

See [docs/specs/onboarding-wizard/spec.md](../specs/onboarding-wizard/spec.md)

## Architecture

- [ADR-003: Single-Agent Skill with File-Existence Idempotency](../architecture/ADR-003-onboarding-wizard-single-agent.md)
- [System Design](../architecture/onboarding-wizard-system-design.md)
- [Data Model Evaluation](../architecture/onboarding-wizard-data-model.md)

## Success Criteria

- A new user can go from install to first `/plan-product` invocation in under 5 minutes.
