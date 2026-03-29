---
title: "Artifact Continuity Badges"
status: "ready"
priority: "P3"
category: "core-framework"
effort: "small"
impact: "low"
dependencies: []
created: "2026-03-10"
updated: "2026-03-10"
---

# Artifact Continuity Badges

## Problem

Tier 2 composite skills (plan-product, build-product) skip stages when artifacts already exist, but skip messages are
functional and terse: "Stage 1 skipped — artifact found." This misses an opportunity to reinforce the fantasy theme
during pipeline orchestration.

## Proposed Solution

Add narrative flavor text to artifact detection skip messages in Tier 2 SKILL.md files. Example: "The Archives of the
Conclave already hold research findings for this topic (found: docs/research/{topic}-research.md). Proceeding to
ideation."

## Scope

- Flavor text additions to 2 Tier 2 SKILL.md files (plan-product, build-product)
- No structural changes — cosmetic text only

## Success Criteria

- Skip messages in plan-product and build-product use Conclave-themed language
- All validators pass after changes
