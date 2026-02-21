---
title: "Two-Tier Skill Architecture Redesign"
status: "approved"
priority: "P2"
category: "core-framework"
approved_by: "product-skeptic"
created: "2026-02-21"
updated: "2026-02-21"
---

# Two-Tier Skill Architecture Redesign

## Summary

Decompose the monolithic plan-product and build-product skills into granular Tier 1 skills (single-purpose, tight context) and Tier 2 composite skills (orchestrators that chain Tier 1 via the Skill tool). Introduces a formal artifact contract system where consumers define artifact templates. Preserves the user's happy path (`/plan-product` -> `/build-product`) while enabling direct invocation of any individual stage.

## Problem

1. **Context window waste.** plan-product loads 390 lines of prompts for all agents even when the user only wants to reprioritize the roadmap. Business skills (1160 lines avg) show where engineering skills are headed.
2. **No reuse.** Market research logic is duplicated across plan-product, plan-sales, and plan-hiring.
3. **All-or-nothing invocation.** Users cannot run just the spec-writing phase or just the implementation planning phase.
4. **Implicit artifact contracts.** plan-product writes specs; build-product reads them. No formal schema. Changes in one break the other silently.

## Solution

### Tier 1: Granular Skills (8 skills)

| Skill | Purpose | Team | Skeptic | Context |
|-------|---------|------|---------|---------|
| research-market | Market analysis, competitive research, customer segments | Lead (Opus) + 2 Scouts (Sonnet) | Lead-as-Skeptic | Small |
| ideate-product | Feature ideation from research findings | Lead (Opus) + 2 Scouts (Sonnet) | Lead-as-Skeptic | Small |
| manage-roadmap | Roadmap prioritization; optionally ingest new items | Lead (Opus) + 1 Scout (Sonnet) | Lead-as-Skeptic | Small |
| write-stories | User stories with INVEST, SMART, acceptance criteria | Lead (Opus) + Builder (Sonnet) + Skeptic (Opus) | Dedicated | Medium |
| write-spec | Technical spec: architecture, data model, API contracts | Lead (Opus) + Architect (Opus) + DBA (Opus) + Skeptic (Opus) | Dedicated | Large |
| plan-implementation | Spec to implementation plan: file changes, interfaces, test strategy | Lead (Opus) + Builder (Opus) + Skeptic (Opus) | Dedicated | Medium |
| build-implementation | Execute implementation plan with TDD | Lead (Opus) + Backend (Sonnet) + Frontend (Sonnet) + Skeptic (Opus) | Dedicated | Large |
| review-quality | Security, performance, deployment readiness (existing, unchanged) | Variable per mode | Dedicated | Medium |

### Tier 2: Composite Skills (2 skills)

| Skill | Chains | Invocation |
|-------|--------|------------|
| plan-product | research-market -> ideate-product -> manage-roadmap -> write-stories -> write-spec | `Skill(skill: "conclave:{tier1}", args: "{feature}")` |
| build-product | plan-implementation -> build-implementation -> review-quality | `Skill(skill: "conclave:{tier1}", args: "{feature}")` |

Composites detect existing artifacts via frontmatter-based, feature-scoped detection and skip completed stages. Each Tier 1 skill has its own skeptic — composites do not add an additional skeptic layer.

### Utility Skills (2 skills)

- **run-task**: Generic multi-agent team. Lead reads prompt, composes 1-3 agents dynamically, ensures skeptic voice.
- **wizard-guide**: Single-agent. Explains available skills and recommends which to call.

### Artifact Contract System

Consumer-owns-template. Templates in `docs/templates/artifacts/`.

| Artifact | Location | Producer | Consumer (template owner) |
|----------|----------|----------|---------------------------|
| research-findings | `docs/research/{topic}-research.md` | research-market | ideate-product |
| product-ideas | `docs/ideas/{topic}-ideas.md` | ideate-product | manage-roadmap |
| roadmap-items | `docs/roadmap/{id}-{slug}.md` | manage-roadmap | write-stories |
| user-stories | `docs/specs/{feature}/stories.md` | write-stories | write-spec |
| technical-spec | `docs/specs/{feature}/spec.md` | write-spec | plan-implementation |
| implementation-plan | `docs/specs/{feature}/implementation-plan.md` | plan-implementation | build-implementation |

**Detection algorithm**: Check file existence -> validate frontmatter type field -> match feature/topic -> check expiry (research only) -> check status (draft doesn't satisfy). Returns: FOUND / STALE / INCOMPLETE / NOT_FOUND.

### Failure Propagation

- **Standalone Tier 1**: Skeptic deadlock after 3 rejections -> escalate to user (current behavior).
- **Inside Tier 2 composite**: Skeptic deadlock -> checkpoint with `status: "escalated"` -> Tier 2 lead reads -> re-invoke with guidance (max 1 retry), skip if non-critical, or escalate to user.
- **Nesting limit**: Tier 2 -> Tier 1 only. No deeper nesting.

### Shared Content (P2-07 dependency)

12 multi-agent skills exceed ADR-002's 8-skill extraction threshold. P2-07 (shared content extraction) is a hard Phase 1 prerequisite. Mechanism: sync script reads from `plugins/conclave/shared/` authoritative sources and replaces content between existing `<!-- BEGIN SHARED -->` markers. SKILL.md self-containment preserved.

## Constraints

1. Every multi-agent skill must have a skeptic presence (dedicated agent or Lead-as-Skeptic).
2. Tier 2 skills invoke Tier 1 via the Skill tool only. No direct team spawning.
3. Tier 1 skills never invoke other skills. Maximum nesting: Tier 2 -> Tier 1.
4. Validators must pass at every migration phase boundary.
5. Business skills (draft-investor-update, plan-sales, plan-hiring) are unchanged.
6. Phase 0 PoC must pass before any subsequent phase begins.
7. Concurrent Tier 2 invocation is unsupported.

## Out of Scope

- Business skill decomposition (Pipeline, Collaborative Analysis, Structured Debate are already well-scoped)
- discover-product composite (can be added later if users demonstrate the need)
- Event-driven artifact subscriptions
- Workflow YAML files (P2-02 original proposal, superseded)
- Cross-Tier-2 composition (one composite invoking another)

## Migration Plan

| Phase | Work | Validator Updates |
|-------|------|-------------------|
| 0 | PoC: minimal Tier 2 invokes minimal Tier 1 via Skill tool. Validate invocation, context persistence, artifact readability, checkpoint isolation. | None |
| 1 | P2-07 shared content extraction. Create artifact templates, new directories (`docs/research/`, `docs/ideas/`, `docs/templates/artifacts/`). Update setup-project. | A1 (new frontmatter), B-series (sync script), F-series stub |
| 2 | Create research-market, ideate-product, manage-roadmap, write-stories, write-spec | A2, A3, F-series for Tier 1 |
| 3 | Create plan-implementation, build-implementation. review-quality stays as-is. | A2, A3, F-series for Tier 1 |
| 4 | Rewrite plan-product and build-product as Tier 2 composites | A2, A3 for Tier 2 patterns |
| 5 | Create run-task and wizard-guide | A2, A3 for utility patterns |

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-product/SKILL.md` | Phase 2: extract Tier 1 logic. Phase 4: rewrite as Tier 2 composite. |
| `plugins/conclave/skills/build-product/SKILL.md` | Phase 3: extract Tier 1 logic. Phase 4: rewrite as Tier 2 composite. |
| `plugins/conclave/skills/review-quality/SKILL.md` | Minimal: add `tier: 1` frontmatter |
| `plugins/conclave/skills/setup-project/SKILL.md` | Phase 1: scaffold new directories and templates |
| `plugins/conclave/shared/` (NEW) | Phase 1: shared principles and communication protocol |
| `plugins/conclave/skills/research-market/SKILL.md` (NEW) | Phase 2 |
| `plugins/conclave/skills/ideate-product/SKILL.md` (NEW) | Phase 2 |
| `plugins/conclave/skills/manage-roadmap/SKILL.md` (NEW) | Phase 2 |
| `plugins/conclave/skills/write-stories/SKILL.md` (NEW) | Phase 2 |
| `plugins/conclave/skills/write-spec/SKILL.md` (NEW) | Phase 2 |
| `plugins/conclave/skills/plan-implementation/SKILL.md` (NEW) | Phase 3 |
| `plugins/conclave/skills/build-implementation/SKILL.md` (NEW) | Phase 3 |
| `plugins/conclave/skills/run-task/SKILL.md` (NEW) | Phase 5 |
| `plugins/conclave/skills/wizard-guide/SKILL.md` (NEW) | Phase 5 |
| `docs/templates/artifacts/*.md` (NEW) | Phase 1: 4 new artifact templates |
| `scripts/validators/skill-structure.sh` | Phases 1-5: incremental updates |
| `scripts/validators/skill-shared-content.sh` | Phase 1: sync script integration |
| `docs/architecture/ADR-004-two-tier-skill-architecture.md` | Already written (status: proposed -> accepted) |
| `docs/roadmap/_index.md` | Add this spec as roadmap item |

## Success Criteria

1. Phase 0 PoC demonstrates Tier 2 -> Tier 1 invocation via Skill tool with context persistence and checkpoint isolation.
2. All 8 Tier 1 skills are independently invocable and produce correctly-formatted artifacts.
3. `/plan-product "new feature idea"` chains research through spec, skipping stages where artifacts already exist.
4. `/build-product` chains plan-implementation through review-quality, skipping stages where artifacts exist.
5. `/run-task "arbitrary prompt"` spawns a dynamic team with skeptic presence and delivers a result.
6. `/wizard-guide` explains all available skills and recommends the right entry point.
7. `bash scripts/validate.sh` passes after every migration phase.
8. Existing business skills (plan-sales, plan-hiring, draft-investor-update) continue to function unchanged.
9. Consumer-owns-template: each artifact template is maintained by its primary consumer skill and read by its producer during bootstrap.
10. Cost reduction: `/manage-roadmap reprioritize` uses 2 agent-sessions instead of 4 (current plan-product).

## Supporting Documents

- ADR: `docs/architecture/ADR-004-two-tier-skill-architecture.md`
- Research: `docs/progress/skill-architecture-redesign-researcher.md`
- Architecture: `docs/progress/skill-architecture-redesign-architect.md`
- Review: `docs/progress/skill-architecture-redesign-product-skeptic.md`
- Persona Guide: `docs/agent-persona-performance.md`
