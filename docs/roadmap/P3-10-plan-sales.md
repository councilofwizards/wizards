---
title: "Sales Planning Skill (/plan-sales)"
status: complete
priority: P3
category: business-skills
completed: "2026-02-19"
---

# P3-10: Sales Planning Skill

## Summary

Implemented `/plan-sales`, the second business skill and the first to use the Collaborative Analysis consensus pattern.
Three parallel analysis agents (Market Analyst, Product Strategist, GTM Analyst) independently research their domains,
share Domain Briefs, cross-reference peer findings, and the Team Lead synthesizes a sales strategy assessment validated
by dual-skeptic review (Accuracy Skeptic + Strategy Skeptic).

## What Was Built

- `plugins/conclave/skills/plan-sales/SKILL.md` — Collaborative Analysis skill (~1200 lines)
- `scripts/validators/skill-shared-content.sh` — extended `normalize_skeptic_names()` with
  `strategy-skeptic`/`Strategy Skeptic`
- Output artifact written to `docs/sales-plans/{date}-sales-strategy.md`
- User data template at `docs/sales-plans/_user-data.md` (created on first run if missing)
- Supports `--light` (Sonnet for analysis agents) and `status` argument

## Key Dependencies

- **Depends on**: Business skill design guidelines (`docs/architecture/business-skill-design-guidelines.md`),
  `plan-sales-system-design.md`
- **Depended on by**: P2-08 (Plugin Organization) prerequisite — 2nd business skill (2/2 required)
- **Introduced patterns**: Collaborative Analysis (Domain Briefs, Cross-Reference Reports, lead-driven synthesis)
