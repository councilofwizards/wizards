---
title: "Plugin Organization (Multi-Plugin)"
status: "not_started"
priority: "P2"
category: "core-framework"
effort: "Medium"
impact: "medium"
dependencies: []
created: "2026-02-19"
updated: "2026-02-19"
---

# Plugin Organization (Multi-Plugin)

## Problem

All skills currently live in a single `conclave` plugin. As the skill count grows and diversifies across engineering and business domains, a single-plugin structure may become unwieldy. Plugin boundaries should be informed by real-world usage patterns.

## Prerequisite

Defer until 2+ business skills are built and validated. Real-world skill structure should inform plugin boundaries.

Current status: 1/2 business skills complete (`/draft-investor-update`). Second business skill (P3-10 `/plan-sales`) selected as next feature.

## Proposed Solution

TBD — depends on patterns observed after building 2+ business skills. Likely options:
1. Split into `conclave-engineering` and `conclave-business` plugins
2. Split by collaboration pattern (hub-spoke, pipeline, collaborative-analysis)
3. Keep single plugin but reorganize internal directory structure

## Success Criteria

- Plugin boundaries reflect meaningful domain or pattern groupings
- Skills can be installed/updated independently if split
- No regression in CI validation or shared content management
