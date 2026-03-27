---
title: "Skill Discoverability Improvements"
status: "draft"
priority: "P2"
category: "developer-experience"
approved_by: ""
created: "2026-03-27"
updated: "2026-03-27"
---

# Skill Discoverability Improvements Specification

## Summary

Four focused Markdown edits to `wizard-guide` and `setup-project` close the primary discoverability gaps: business
skills are missing from the guide, new users are never told the guide exists, and the guide lacks narrative framing
and persona introductions that set expectations for the fantasy-themed experience. No validator logic changes. No
shared-content sync. Both target files are `type: single-agent` and excluded from B-series checks.

## Problem

1. **Invisible business skills**: `draft-investor-update`, `plan-sales`, and `plan-hiring` are production-quality
   skills that do not appear anywhere in the Skill Ecosystem Overview. A user running `/wizard-guide` cannot discover
   them without already knowing they exist.

2. **No path from setup to guide**: `setup-project` Step 6 Next Steps sends new users directly to `/plan-product`
   without mentioning `/wizard-guide`. First-time users never learn the guide exists.

3. **Stale tier labels**: The current wizard-guide overview uses "Tier 1" and "Tier 2" framing that was removed by
   ADR-004. The listing is factually incorrect.

4. **No narrative framing**: The fantasy-themed persona layer never surfaces until agents introduce themselves at
   runtime. A new user has no context for why agents have names and titles, or what the "Conclave" is.

## Solution

### Change 1 — Business Skills Section in wizard-guide

Add a "Business Skills" category to the Skill Ecosystem Overview and remove the outdated tier labels. Restructure
into four named groups: Granular Skills, Pipeline Skills, Business Skills, Utility Skills.

**Before (lines 41–64 of wizard-guide SKILL.md):**

```markdown
### Tier 1: Granular Skills (invoke directly for fine-grained control)

**Planning Pipeline:**
1. `research-market` — Market research and competitive analysis
2. `ideate-product` — Feature ideation from research findings
3. `manage-roadmap` — Roadmap prioritization and maintenance
4. `write-stories` — User stories with acceptance criteria
5. `write-spec` — Technical specifications

**Implementation Pipeline:**
6. `plan-implementation` — File-by-file implementation plans
7. `build-implementation` — Code writing with TDD and contract negotiation
8. `review-quality` — Security audits, performance, deployment readiness

### Tier 2: Composite Skills (orchestrate Tier 1 pipelines automatically)

9. `plan-product` — Chains: research-market → ideate-product → manage-roadmap → write-stories → write-spec
10. `build-product` — Chains: plan-implementation → build-implementation → review-quality

### Utility Skills

11. `setup-project` — Bootstrap project structure and CLAUDE.md
12. `run-task` — Ad-hoc tasks with dynamic team composition
13. `wizard-guide` — This skill. Help and guidance.
```

**After:**

```markdown
### Granular Skills (invoke directly for fine-grained control)

**Planning Pipeline:**
1. `research-market` — Market research and competitive analysis
2. `ideate-product` — Feature ideation from research findings
3. `manage-roadmap` — Roadmap prioritization and maintenance
4. `write-stories` — User stories with acceptance criteria
5. `write-spec` — Technical specifications

**Implementation Pipeline:**
6. `plan-implementation` — File-by-file implementation plans
7. `build-implementation` — Code writing with TDD and contract negotiation
8. `review-quality` — Security audits, performance, deployment readiness

### Pipeline Skills (orchestrate full workflows automatically)

9. `plan-product` — Full planning pipeline: research → ideation → roadmap → stories → spec
10. `build-product` — Full build pipeline: planning → implementation → quality review

### Business Skills

11. `draft-investor-update` — Draft a structured investor update from roadmap, progress, and spec data
12. `plan-sales` — Sales strategy for early-stage startups: market, positioning, and go-to-market
13. `plan-hiring` — Hiring plan for early-stage startups: growth vs. efficiency debate with dual-skeptic validation

### Utility Skills

14. `setup-project` — Bootstrap project structure and CLAUDE.md
15. `run-task` — Ad-hoc tasks with dynamic team composition
16. `wizard-guide` — This skill. Help and guidance.
```

Also add business workflow examples to the Common Workflows section:

**After the existing Quick task block, add:**

```markdown
**Business operations:**
```
/draft-investor-update          # Draft investor update from project data
/plan-sales {topic}             # Sales strategy for a market or product
/plan-hiring {role}             # Hiring plan for a role or team
```
```

### Change 2 — Determine Mode: Fix Tier Reference and Add Business Skills to recommend

**Before (Determine Mode, "Empty/no args" bullet):**

```markdown
- **Empty/no args**: Provide a friendly overview of the skill ecosystem. Show the two tiers, list all available skills
  grouped by tier, and explain the general workflow (plan -> build -> review).
```

**After:**

```markdown
- **Empty/no args**: Provide a friendly overview of the skill ecosystem. Open with the lore preamble and persona
  spotlight, then list all available skills grouped by category (granular, pipeline, business, utility) and explain
  the general workflow (plan → build → review). Omit preamble and spotlight in list mode and explain mode.
```

**Before (Determine Mode, "list" bullet):**

```markdown
- **"list"**: Output a concise table of all skills with name, tier, and one-line description. No narrative — just
  the reference table.
```

**After:**

```markdown
- **"list"**: Output a concise table of all skills with name, category, and one-line description. No narrative,
  no lore preamble, no persona spotlight — just the reference table. Include all 16 skills (granular, pipeline,
  business, utility).
```

**Before (Determine Mode, "recommend" section, third example):**

```markdown
  - "I want to understand the market" → `/research-market {topic}`
```

**After:**

```markdown
  - "I want to understand the market" → `/research-market {topic}`
  - "I need to draft an investor update" → `/draft-investor-update`
  - "I want to plan our sales strategy" → `/plan-sales {topic}`
  - "I need a hiring plan" → `/plan-hiring {role}`
```

### Change 3 — Conclave Lore Preamble in wizard-guide

Add a new `## The Conclave` section immediately before `## Skill Ecosystem Overview`. This section is rendered in
overview mode only — omitted in `list` and `explain` modes (governed by the Determine Mode rules above).

**Insert before `## Skill Ecosystem Overview`:**

```markdown
## The Conclave

In the age before frameworks, great products were built by heroes working in isolation — every decision carried
alone, every trade-off made without challenge. The Conclave was founded on a different conviction: that great
software emerges from structured collaboration, honest challenge, and shared craft.

The wizards of the Conclave are not assistants. They are specialists with distinct roles, rivalries, and
responsibilities — drawn together by the belief that no single mind can hold every perspective a product demands.
They will plan your features, challenge your assumptions, write your code, and inspect their own work with the
rigor of someone whose seal means something.

*Invoke a skill. The Council assembles.*

```

Word count: ~107 words. Within the 80–150 word target.

### Change 4 — Persona Spotlight ("Meet the Council") in wizard-guide

Add a `## Meet the Council` section immediately after `## The Conclave` and before `## Skill Ecosystem Overview`.
This section is rendered in overview mode only — omitted in `list` and `explain` modes.

**Persona selection rationale**: Five personas chosen for cross-skill structural stability. All five represent
archetypes (Lead, Skeptic, Planner, Builder, Researcher) that persist across skill renames. They collectively
cover all three pipeline phases.

**Insert after `## The Conclave`:**

```markdown
## Meet the Council

A few of the wizards you will encounter:

| Name | Title | Role |
|------|-------|------|
| **Eldara Voss** | Archmage of Divination | Research Lead — reads patterns others miss; merciless with assumptions |
| **Seren Mapwright** | Siege Engineer | Implementation Architect — turns specs into file-level blueprints; allergic to ambiguity |
| **Vance Hammerfall** | Forge Master | Tech Lead — runs the build forge; coordinates engineers through contract negotiation and quality gates |
| **Mira Flintridge** | Master Inspector | Quality Skeptic — guards two mandatory gates before any code ships; nothing passes without her seal |
| **Bram Copperfield** | Foundry Smith | Backend Engineer — shapes server-side code with TDD discipline; negotiates API contracts before writing a line |

The full Council is larger. Run `/wizard-guide explain <skill-name>` to meet the team assigned to any skill.

```

### Change 5 — wizard-guide Mention in setup-project Next Steps

The Next Steps block is a literal string embedded in Step 6. Add one bullet before the existing `/plan-product`
recommendation.

**Before (Step 6, Next Steps block):**

```markdown
### Next Steps:
1. Review the generated CLAUDE.md and adjust conventions to match your project
2. Run `/plan-product` to start planning your first feature
3. (Optional) Add or refine the stack hint at docs/stack-hints/{stack}.md for deeper framework guidance
```

**After:**

```markdown
### Next Steps:
1. Review the generated CLAUDE.md and adjust conventions to match your project
2. Run `/wizard-guide` to explore all available skills and find the right one for your task
3. Run `/plan-product` to start planning your first feature
4. (Optional) Add or refine the stack hint at docs/stack-hints/{stack}.md for deeper framework guidance
```

This bullet must appear in normal mode, `--force` mode, and `--dry-run` mode without exception. No logic change
is needed — this is content only.

## Constraints

1. Edit `wizard-guide` and `setup-project` only. No other files are modified by this feature.
2. Lore preamble must not exceed 150 words. Current draft is 107 words — do not expand.
3. Persona spotlight must contain exactly 4–5 personas. Do not add a sixth.
4. Preamble and persona spotlight are suppressed in `list` mode and `explain` mode — this is enforced by the
   Determine Mode wording, not by code.
5. All 12 validators must pass after changes. Both target files are `type: single-agent` and are excluded from
   B-series shared-content checks — no sync step required.
6. The Skeptic role must remain prominently represented in the persona spotlight. Mira Flintridge is the chosen
   representative — do not remove or replace without strong justification.
7. Tier labels ("Tier 1", "Tier 2", "chains:") must be removed from the Skill Ecosystem Overview. Replace with
   the four category names in Change 1.

## Out of Scope

- Adding new skills to the plugin.
- Modifying SKILL.md files for business skills (`draft-investor-update`, `plan-sales`, `plan-hiring`) even for
  pushy description improvements (Story 5). Those changes require editing skills outside the allowed file set and
  should be tracked as a separate P3 item.
- Changing agent behavior or runtime persona names inside any multi-agent skill.
- Automated skill suggestion / intent matching infrastructure.
- Updating the plugin manifest (`plugin.json`) or marketplace catalog.
- Shared content sync — wizard-guide and setup-project are both `type: single-agent` and are excluded.

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/wizard-guide/SKILL.md` | (1) Remove tier labels, add Business Skills section, business Common Workflows. (2) Fix Determine Mode: remove "two tiers" language, add business skills to recommend mode, add preamble/spotlight suppression rule to list/explain modes. (3) Add `## The Conclave` lore preamble section. (4) Add `## Meet the Council` persona spotlight section. |
| `plugins/conclave/skills/setup-project/SKILL.md` | Add `/wizard-guide` bullet as item 2 in Step 6 Next Steps, before `/plan-product`. Renumber existing items 2–3 to 3–4. |

## Success Criteria

1. Invoking `/wizard-guide` with no arguments renders `## The Conclave` preamble (≥80 words, ≤150 words) before
   any skill listings.
2. Invoking `/wizard-guide` with no arguments renders `## Meet the Council` section with exactly 5 personas, each
   showing fictional name, title, and one-line description. All 5 match agents defined in actual SKILL.md files.
3. Invoking `/wizard-guide` with no arguments shows a "Business Skills" section listing `draft-investor-update`,
   `plan-sales`, and `plan-hiring` with descriptions — and no "Tier 1" or "Tier 2" labels anywhere in the output.
4. Invoking `/wizard-guide list` renders a reference table of all 16 skills with no preamble, no persona spotlight,
   and no tier labels. Business skills appear in the table.
5. Invoking `/wizard-guide explain <skill>` omits the preamble and persona spotlight — shows only skill details.
6. The Common Workflows section includes at least one business workflow example
   (e.g., `Run /draft-investor-update to draft an investor update`).
7. `/setup-project` Step 6 Next Steps includes `Run /wizard-guide to explore all available skills and find the
   right one for your task` as item 2, before the `/plan-product` recommendation. Bullet appears in all modes
   (`--force`, `--dry-run`, normal).
8. `bash scripts/validate.sh` passes all 12 validators after both file edits.
