---
title: "Hiring Planning Skill (/plan-hiring)"
status: complete
priority: P3
category: business-skills
completed: "2026-02-19"
---

# P3-14: Hiring Planning Skill

## Summary

Implemented `/plan-hiring`, the third business skill and the first to use the Structured Debate consensus pattern. A
neutral Researcher gathers a shared evidence base, then Growth Advocate and Resource Optimizer agents argue opposing
positions through structured cross-examination rounds (Challenge → Response → Rebuttal). The Team Lead synthesizes the
debate into a hiring plan validated by dual-skeptic review (Bias Skeptic + Fit Skeptic).

## What Was Built

- `plugins/conclave/skills/plan-hiring/SKILL.md` — Structured Debate skill (~1400 lines)
- `scripts/validators/skill-shared-content.sh` — extended `normalize_skeptic_names()` with `bias-skeptic`/`Bias Skeptic`
  and `fit-skeptic`/`Fit Skeptic` (4 new sed expressions)
- Output artifact written to `docs/hiring-plans/{date}-hiring-plan.md`
- User data template at `docs/hiring-plans/_user-data.md` (created on first run if missing)
- Supports `--light` (Sonnet for debate agents) and `status` argument

## Key Dependencies

- **Depends on**: `docs/architecture/plan-hiring-system-design.md`, `business-skill-design-guidelines.md`, P3-10 lessons
- **Depended on by**: P2-07 threshold progress (7/8 skills)
- **Introduced patterns**: Structured Debate (Debate Cases, Cross-Examination protocol, Debate Resolution Summary, Bias
  Skeptic)
