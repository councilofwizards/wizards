---
feature: "review-cycle-2026-02-18"
status: "complete"
completed: "2026-02-18"
---

# Product Team Review Cycle -- Progress

## Summary

Conducted a full roadmap review cycle with the Product Team (Researcher, Architect, Skeptic). Assessed all 7 remaining
roadmap items, reprioritized the backlog, produced a P2-05 Content Deduplication spec, and expanded the roadmap with 17
new skill proposals covering 9 business domains for a total catalog of 32 items.

## Changes

### P2-05 Content Deduplication Spec

Produced a full spec at `docs/specs/content-deduplication/spec.md` with Skeptic approval. The spec recommends
**validated duplication with HTML markers** (Option C):

- Add `<!-- BEGIN SHARED -->` / `<!-- END SHARED -->` markers around shared sections in all 3 SKILL.md files
- Normalize cosmetic inconsistencies (quote style, table formatting, horizontal rules)
- Designate `plan-product/SKILL.md` as the authoritative source
- CI validation (P2-04) enforces consistency
- ADR-002 decision trigger: revisit at 8+ skills in favor of shared-file extraction

Alternatives rejected:

- Option A (CLAUDE.md extraction): Context pollution in non-skill sessions, ownership conflict
- Option B (Plugin-scoped shared file): Path resolution fragility, portability regression
- Option D (Hybrid): Premature for current skill count

### Roadmap Expansion

Added 17 new skills and 2 new infrastructure items to the roadmap:

**P2 (Important) additions:**

- P2-07: Universal Shared Principles (generalize engineering principles for all domains)
- P2-08: Plugin Organization (split into 3-4 persona-based plugins)

**Engineering skills (P3):**

- P3-04: `/triage-incident` -- Incident response with parallel investigation
- P3-05: `/assess-debt` -- Tech debt assessment with prioritized debt register
- P3-06: `/design-api` -- API design with consumer advocacy
- P3-07: `/plan-migration` -- Migration planning with risk assessment

**Business skills -- Tier 1 (Core Startup Functions):**

- P3-10: `/plan-sales` -- Sales strategy and pipeline planning
- P3-11: `/plan-marketing` -- GTM strategy, content calendar, campaign planning
- P3-12: `/plan-finance` -- Financial modeling, budgets, fundraising
- P3-13: `/plan-strategy` -- Strategic planning, OKRs, competitive analysis

**Business skills -- Tier 2 (Growth Enablers):**

- P3-14: `/plan-hiring` -- Job design, interview frameworks, evaluation rubrics
- P3-15: `/plan-customer-success` -- Customer lifecycle, health scoring, playbooks
- P3-16: `/build-sales-collateral` -- Proposals, battle cards, sales playbooks
- P3-17: `/build-content` -- Blog posts, email campaigns, social media
- P3-18: `/review-legal` -- Contract review, policy drafting, compliance gaps

**Business skills -- Tier 3 (Scale & Optimize):**

- P3-19: `/plan-analytics` -- Metrics definition, dashboard design, experiment design
- P3-20: `/plan-operations` -- Process design, vendor evaluation, cost optimization
- P3-21: `/plan-onboarding` -- Employee onboarding program design
- P3-22: `/draft-investor-update` -- Investor communications from provided data

### Architectural Findings

The Architect's assessment confirmed:

1. **Framework scales to 20+ skills with ZERO structural changes** -- each skill is self-contained
2. **Multi-skeptic is a per-skill design choice** -- sequential or parallel gate flows
3. **Peer-to-peer collaboration is already supported** -- orchestration flow patterns vary per skill
4. **3-4 persona-based plugins** is recommended over 9 domain-based plugins
5. **One universal principle set + domain appendices** is better than two separate principle sets
6. **The framework is a pattern library, not a platform** -- its value is in reusable patterns

### Priority Ordering (Next Actions)

The team recommends this implementation sequence for remaining P2 items:

1. **P2-05 Content Deduplication** (spec ready, approved)
2. **P2-07 Universal Shared Principles** (generalize principles for multi-domain expansion)
3. **P2-04 Automated Testing Pipeline** (validates content consistency)
4. **P2-03 Progress Observability** (status commands for running teams)
5. **P2-08 Plugin Organization** (split into persona-based plugins before business skill launch)
6. **P2-02 Skill Composability** (workflow chaining -- defer until platform research is done)

### Design Principles Established

Per Product Owner direction, all future skills must:

- Include **negative personas** (Skeptics, devil's advocates, bar-raisers) that demand evidence and reject assumptions
- Some teams should have **multiple negative personas** covering different scopes
- Be **highly collaborative by design** with peer-to-peer communication, not just hub-and-spoke
- Support three collaboration patterns: Collaborative Analysis, Structured Debate, and Pipeline

### Naming Convention

Established a consistent verb taxonomy for skills:

- `plan-{domain}` -- Strategy, analysis, planning (output: documents, plans, frameworks)
- `build-{domain}` -- Content creation, production (output: collateral, code, designs)
- `review-{domain}` -- Audit, assessment, evaluation (output: findings, reports)
- `triage-{domain}` -- Urgent response, investigation (output: root causes, action plans)
- `assess-{domain}` -- Analyze existing state (output: inventories, registers)

## Files Created

- `docs/specs/content-deduplication/spec.md` -- P2-05 Content Deduplication spec
- `docs/progress/review-cycle-researcher.md` -- Researcher: prioritization analysis
- `docs/progress/review-cycle-architect.md` -- Architect: architecture assessment
- `docs/progress/content-dedup-researcher.md` -- Researcher: P2-05 implementation options
- `docs/progress/content-dedup-architect.md` -- Architect: P2-05 design
- `docs/progress/new-skills-researcher.md` -- Researcher: 20-skill catalog across 9 domains
- `docs/progress/new-skills-architect.md` -- Architect: framework scalability assessment
- `docs/progress/plan-product-review-cycle-2026-02-18.md` -- This progress summary

## Files Modified

- `docs/roadmap/_index.md` -- Updated P2-05 status to ready, added 2 P2 items, added 17 P3 items across engineering and
  business domains, added `business-skills` category

## Verification

- P2-05 spec reviewed and approved by Product Skeptic
- Prioritization recommendations reviewed and approved by Product Skeptic
- New skills catalog reviewed by Product Skeptic
- Framework scalability assessment completed by Architect
- All team deliverables written to role-scoped progress files (write safety maintained)
