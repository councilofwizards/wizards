---
feature: "business-skills-specs"
status: "complete"
completed: "2026-03-27"
---

# P3: Business Skills Technical Specs — Progress

## Summary

Wrote technical specifications for three P3 business skills: plan-marketing (P3-11), plan-finance (P3-12), and plan-customer-success (P3-15). Each spec defines SKILL.md structure, agent team composition, collaboration pattern, orchestration flow, quality gates, output artifact format, user-data dependency, and CI validator impact.

## Changes

### plan-marketing (P3-11) — Collaborative Analysis
- 5-phase Collaborative Analysis pattern matching plan-sales
- 5 agents: positioning-analyst, channel-analyst, content-analyst + strategy-skeptic, feasibility-skeptic (dual)
- All analysis agents Opus, lead-driven synthesis (Phase 3)
- Output: `docs/marketing-plans/{date}-marketing-plan.md`
- New B2 normalizer pair: `feasibility-skeptic`/`Feasibility Skeptic`

### plan-finance (P3-12) — Collaborative Analysis (Data-First Variant)
- Data-first pipeline: Team Lead pre-reads financial data in Phase 1, distributes Data Summary
- 5 agents: burn-rate-analyst, revenue-modeler, scenario-planner + accuracy-skeptic, risk-skeptic (dual)
- Multi-scenario requirement: base/optimistic/pessimistic always present
- Assumption traceability: every projection references numbered assumptions
- Output: `docs/finance-plans/{date}-finance-plan.md`
- New B2 normalizer pair: `risk-skeptic`/`Risk Skeptic`

### plan-customer-success (P3-15) — Hub-and-Spoke
- Hub-and-Spoke pattern (unlike Collaborative Analysis for the other two): CS Strategist synthesizes, not Team Lead
- 5 agents: churn-analyst (opus), onboarding-designer (sonnet), expansion-analyst (sonnet) + cs-strategist (opus), cs-skeptic (single)
- 4-phase flow (no cross-reference phase — Hub-and-Spoke delegates synthesis to cs-strategist)
- Pre-launch adaptation: all sections produce meaningful output with zero customers
- Output: `docs/cs-plans/{date}-cs-playbook.md`
- New B2 normalizer pair: `cs-skeptic`/`CS Skeptic`

### Cross-Cutting Concerns
- All three skills are non-engineering (Universal Principles only)
- All three require classification list updates in `sync-shared-content.sh` and `skill-shared-content.sh`
- All three require new skeptic name pairs in B2 normalizer (4 new pairs total: feasibility-skeptic, risk-skeptic, cs-skeptic; strategy-skeptic may already exist from plan-sales)
- All three include mandatory business quality sections: Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints
- All three follow session recovery and status mode conventions from plan-sales

## Files Created

- `docs/specs/plan-marketing/spec.md` — Marketing Planning skill specification
- `docs/specs/plan-finance/spec.md` — Finance Planning skill specification
- `docs/specs/plan-customer-success/spec.md` — Customer Success skill specification

## Verification

- Specs follow `docs/specs/_template.md` format with all required sections
- Agent team compositions match approved stories exactly
- Collaboration patterns match story requirements (Collaborative Analysis for marketing/finance, Hub-and-Spoke for CS)
- CI validator impact tables identify all needed changes
- Constraints and success criteria are testable and traceable to story acceptance criteria
