---
title: "PoC Skills Deprecation Banner"
status: "not_started"
priority: "P3"
category: "developer-experience"
effort: "small"
impact: "low"
dependencies: []
created: "2026-03-10"
updated: "2026-03-10"
---

# PoC Skills Deprecation Banner

## Problem

tier1-test and tier2-test are Phase 0 PoC skills visible in skill discovery alongside production skills. They have no documentation warning users they are internal test scaffolding, which may cause minor confusion.

## Proposed Solution

1. Add `status: internal` to tier1-test and tier2-test SKILL.md frontmatter
2. Add a banner as the first line of content: "This is an internal test skill used for PoC validation. Not intended for production use."

## Success Criteria

- Both PoC skills have `status: internal` in frontmatter
- Both PoC skills display an internal-only banner
- All validators pass after changes
