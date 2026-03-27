---
feature: "plugin-organization"
team: "plan-product"
agent: "customer-researcher"
phase: "research"
status: "complete"
last_action: "Findings complete and submitted to Team Lead"
updated: "2026-03-27T17:20:00Z"
---

## Progress Notes

- [17:09] Task claimed — P2-08 Customer Research assigned
- [17:10] Began reading role definition, roadmap, marketplace.json, plugin.json, wizard-guide
- [17:14] Read pipeline skill SKILL.md files (plan-product, build-product) — too large, read frontmatter sections
- [17:15] Read business skill SKILL.md files (draft-investor-update, plan-hiring)
- [17:16] Read engineering skill SKILL.md files (build-implementation, review-quality)
- [17:18] Read P2-08 roadmap item
- [17:20] Findings compiled and submitted

---

## Customer Findings: Plugin Organization / Multi-Plugin

### Summary

Two highly distinct user personas exist — Engineering Teams and Founders/Operators — with almost zero cross-over in skill usage patterns. The business/engineering divide is architecturally clean, and the roadmap projects this gap widening dramatically at P3. The current monolithic structure creates moderate friction today but will create significant friction once P3 business skills are implemented.

---

### Segment 1: Engineering Teams

**Profile**: CTOs, tech leads, developers, solo founders with engineering background who use conclave to plan and build product.

**Skills they use**:
- Granular engineering pipeline: research-market, ideate-product, manage-roadmap, write-stories, write-spec, plan-implementation, build-implementation, review-quality
- Pipeline orchestrators: plan-product, build-product
- Utility: setup-project, wizard-guide, run-task

**Skills they almost certainly DON'T use**: draft-investor-update, plan-sales, plan-hiring (unless wearing a founder hat)

**Key Facts**:
- Engineering skills share an Engineering Principles block (TDD, SOLID, contracts) — confidence: High (read in shared content sync architecture)
- Engineering pipeline is tightly sequenced: research → ideation → roadmap → stories → spec → plan → build → review (confidence: High)
- plan-product and build-product orchestrate these granular skills as stages — they're the "all in one" wrapper for engineering users (confidence: High)
- Engineering skills require tooling (Playwright, test runners, code execution) — business users would find these irrelevant (confidence: High)

**Pain Points (current monolithic structure)**:
- Receives all 17 skills (including business) when installing; no way to install only engineering skills
- Minor friction: skill list is longer than needed for pure engineering users
- Confidence: Medium (inferred from UX; no direct user feedback available)

---

### Segment 2: Founders / Operators (non-technical or business-focused)

**Profile**: Non-technical founders, COOs, head of sales/marketing who use conclave for business operational planning.

**Skills they use**: draft-investor-update, plan-sales, plan-hiring

**Skills they almost certainly DON'T use**: build-implementation, review-quality, write-spec, plan-implementation — all require technical context to be useful

**Key Facts**:
- Business skills receive ONLY Universal Principles (no Engineering Principles) — architecturally clean separation (confidence: High)
- Business skills require user-provided `_user-data.md` files (financial metrics, team data) — a pattern absent in engineering skills (confidence: High)
- Business skill outputs (investor updates, hiring plans, sales strategies) require no technical codebase context to generate (confidence: High)
- Business quality checklist is unique to business skills: assumptions stated, confidence levels, falsification triggers, external validation checkpoints — these appear in draft-investor-update and plan-hiring but NOT in engineering skills (confidence: High)
- plan-hiring uses a "Structured Debate" pattern (growth vs. efficiency advocates) — no equivalent in engineering skills (confidence: High)

**Pain Points (current monolithic structure)**:
- Business users must install all 17 skills to get 3 business-relevant ones
- Skill list noise: 14 non-business skills appear in their skill list
- Potential confusion: engineering skill descriptions ("write code," "TDD," "API contracts") may be confusing or off-putting to non-technical users
- Confidence: Medium (inferred from skill content analysis; no direct user feedback)

---

### Segment 3: Solo Founder / Full-Stack (Bridge Users)

**Profile**: Technical founders who wear both hats — building the product AND running the business. Likely the primary user of conclave today given the project's focus on SaaS startups.

**Skills they use**: ALL or most skills across both categories

**Pain Points (current monolithic structure)**:
- Minimal — they benefit from a single unified install
- Splitting would ADD friction: two install steps, two update cycles
- Confidence: Medium

---

### Natural Skill Clusters (usage pattern analysis)

Based on SKILL.md content and dependency analysis:

**Cluster A — Engineering Planning** (could be a standalone plugin):
- research-market, ideate-product, manage-roadmap, write-stories, write-spec
- Consumed by: plan-product (as stages)

**Cluster B — Engineering Implementation** (could combine with A or stay separate):
- plan-implementation, build-implementation, review-quality, run-task
- Consumed by: build-product (as stages)

**Cluster C — Business Operations** (naturally standalone):
- draft-investor-update, plan-sales, plan-hiring
- No dependencies on engineering skills
- No engineering skills depend on them

**Cluster D — Utility** (needed by everyone):
- setup-project, wizard-guide
- Cross-cutting — no clear plugin home

**Key observation**: Clusters A+B together form the core engineering product. Clusters A and B are always used together (plan then build). Splitting A from B would add friction for the primary engineering workflow. Engineering users think in terms of "plan and build" as one workflow, not two separate plugins.

**Recommended groupings** (if split occurs):
1. `conclave` (core engineering): Clusters A + B + Utility (13 skills)
2. `conclave-business` (business operations): Cluster C (3 skills now, 10+ at P3 completion)

---

### Installation Friction Analysis

**Current structure**:
- marketplace.json: 2 plugins total (`conclave` + `php-tomes`)
- conclave plugin.json: single manifest, no sub-groupings
- Install experience: atomic — all 17 skills or none
- Version: plugin-level only (v1.2.0)

**Impact of splitting**:
- Would require 2 separate install commands for users who want both
- Each plugin would version and update independently — benefit for selective users, friction for full-stack users
- CI validation would need to run per-plugin
- Shared content sync (`sync-shared-content.sh`) currently operates on all skills in the plugins directory — would need scoping logic per plugin

**Confidence: High** (read from marketplace.json and plugin.json directly)

---

### Roadmap Trajectory (P3 context)

The P3 roadmap plans 10+ additional business skills:
- plan-marketing, plan-finance, plan-customer-success, build-sales-collateral, build-content, review-legal, plan-analytics, plan-operations, plan-onboarding + investor-update (complete)

At P3 completion, ratio would be approximately **~14 business skills : ~13 engineering skills**. The case for splitting becomes significantly stronger once business skills equal or exceed engineering skills in count.

**Today** (3 business, 14 engineering+utility): Split is premature for user convenience, justified for future architecture.

**At P3** (14 business, 13 engineering+utility): Split is strongly justified for both user convenience AND architecture.

**Confidence: High** (read directly from roadmap backlog)

---

### Wizard-Guide Insight

The `/wizard-guide` skill already groups skills into: Granular, Pipeline, Business, Utility. The product's own navigation already treats Business as a distinct category. This is strong evidence that the product team has already identified the business/engineering divide as user-meaningful.

However, wizard-guide presents them as one unified ecosystem — the common workflows section shows engineering and business as complementary, not competing.

**Confidence: High** (read directly from wizard-guide SKILL.md)

---

### Pain Points Ranked by Severity

1. **MEDIUM (future)**: Business users discovering/installing all 17 skills when they need 3 — manageable today, problematic at P3 scale (14 business skills buried in a 27-skill list)
2. **LOW (today)**: Engineering users seeing 3 irrelevant business skills — minimal noise, unlikely to cause real friction
3. **LOW**: Version coupling — engineering and business updates force a single version bump
4. **NEGLIGIBLE (today)**: Skill discovery friction — wizard-guide already separates business from engineering

---

### Inferences

1. **The split should happen, but not urgently.** Today's 3 business skills don't justify the installation friction of a split for bridge users. The P3 roadmap trajectory (10+ more business skills) IS the real trigger.
2. **Splitting A (planning) from B (implementation) is NOT user-justified.** Engineering users think in "plan then build" — these clusters always co-occur.
3. **The right split is `conclave` (engineering+utility) + `conclave-business` (business ops)** — this mirrors how the wizard-guide already categorizes skills and reflects real user workflow boundaries.
4. **Bridge users (primary early users) would experience friction from a split.** Mitigate with a "get everything" bundle install option or documentation.

---

### Data Gaps

- **No actual user feedback available** — all pain points and persona inferences are based on skill content analysis, not real user interviews. Confidence on pain severity ratings is Medium at best.
- **No install telemetry** — cannot determine whether users actually install both plugins or just one.
- **No usage frequency data** — cannot determine which skills are invoked most frequently.
- **No cohort data** — cannot distinguish what % of users are engineering-only vs. business-only vs. bridge.
