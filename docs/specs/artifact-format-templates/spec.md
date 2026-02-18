---
title: "Artifact Format Templates"
status: "ready_for_implementation"
priority: "P2"
category: "core-framework"
approved_by: "product-skeptic"
created: "2026-02-14"
updated: "2026-02-14"
---

# Artifact Format Templates Specification

## Summary

Create three template files (`docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md`) that standardize the format of specs, progress summaries, and ADRs. Add a single Setup step to each SKILL.md instructing agents to read relevant templates before producing artifacts. Templates are reference documents, not enforced schemas — agents may deviate when justified.

## Problem

The project has no standardized templates for its three main artifact types:

1. **Feature specs** are the worst offender. The two existing specs (`cost-guardrails/spec.md` and `project-bootstrap/spec.md`) share almost no structural similarity — different frontmatter, different section names, different organization. A `/build-product` team cannot reliably parse a spec produced by `/plan-product` because the format is unpredictable.

2. **Progress summaries** are surprisingly consistent (all 5 share Summary, Files Modified, Verification) but this consistency is accidental — there's no template enforcing it. New agents may drift.

3. **ADRs** have only one instance (ADR-001) which follows the standard Nygard pattern but lacks YAML frontmatter for machine parseability.

Checkpoint files and cost summaries already have formats defined in SKILL.md and the cost-guardrails spec respectively. They do not need separate templates.

## Solution

### 1. Spec Template (`docs/specs/_template.md`)

```markdown
---
title: ""
status: "draft"                  # draft | ready_for_review | approved | ready_for_implementation
priority: ""                     # P1 | P2 | P3
category: ""                     # core-framework | new-skills | developer-experience | quality-reliability | documentation
approved_by: ""                  # agent or role that approved
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
---

# {Title} Specification

## Summary

<!-- 1-3 sentences. A reader who stops here should understand WHAT this does and WHY. -->

## Problem

<!-- What's broken, missing, or suboptimal? Include evidence — references to code, user reports, or agent behavior. -->

## Solution

<!-- The proposed change. Structure with subsections as needed. For SKILL.md changes, show before/after diffs. For new systems, describe components and their interactions. -->

## Constraints

<!-- Non-negotiable rules, boundaries, or invariants. Numbered list. -->

## Out of Scope

<!-- What this spec explicitly does NOT cover. Prevents scope creep during implementation. -->

## Files to Modify

<!-- Table or list of files changed, with brief description of each change. -->

| File | Change |
|------|--------|

## Success Criteria

<!-- Numbered, testable statements. Each criterion should be verifiable by a human or automated test. -->
```

**Design rationale:**
- Progressive disclosure: Summary first, details later. A reader can stop at any depth.
- Frontmatter fields standardized from the cost-guardrails spec pattern, plus `status` to track the spec's own lifecycle.
- Problem and Solution are separate sections (clearer for the implementation team).
- Out of Scope is mandatory — its absence in cost-guardrails led to scope ambiguity during implementation.
- HTML comments as hints so they don't render if accidentally left in.

### 2. Progress Summary Template (`docs/progress/_template.md`)

This template covers **progress summaries** (team lead aggregates written after work completes), NOT **checkpoint files** (agent-scoped files written during work). The checkpoint format is already defined identically in all 3 SKILL.md Checkpoint Protocol sections.

```markdown
---
feature: ""
status: "complete"               # in_progress | complete
completed: ""                    # YYYY-MM-DD (when status is complete)
---

# {Priority}: {Title} -- Progress

## Summary

<!-- 1-3 sentences describing what was done and why. -->

## Changes

<!-- Subsections for each logical group of changes, if the work is complex enough to warrant them. For simple features, a single paragraph is sufficient. -->

## Files Modified

<!-- List of files changed, with brief description of each change. -->

- `path/to/file.md` -- Description of change

## Files Created

<!-- Only include this section if new files were created. Omit entirely if not applicable. -->

- `path/to/new-file.md` -- Description

## Verification

<!-- How was quality confirmed? Reference Skeptic approvals, test results, success criteria checks. -->
```

**Design rationale:**
- Based on the actual pattern across all 5 existing progress summaries (all share Summary, Files Modified, Verification).
- Changes section added to provide a natural home for detail without overloading Summary.
- Files Created is optional — only include when new files were actually created.
- Frontmatter standardized from existing files (`feature`, `status`, `completed`).

### 3. ADR Template (`docs/architecture/_template.md`)

```markdown
---
title: ""
status: "proposed"               # proposed | accepted | deprecated | superseded
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
superseded_by: ""                # ADR number, if applicable
---

# ADR-{NNN}: {Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-NNN}

## Context

<!-- What forces are at play? What problem does this address? What constraints exist? -->

## Decision

<!-- What was decided and why. Include enough detail for someone unfamiliar with the discussion to understand the rationale. Use subsections if the decision has multiple parts. -->

## Alternatives Considered

<!-- What else was evaluated? Why was each rejected? Brief — 2-3 sentences per alternative. -->

### {Alternative 1 name}

{Description and reason for rejection.}

## Consequences

<!-- What are the results of this decision? List positives and negatives explicitly. -->

- **Positive**: ...
- **Negative**: ...
```

**Design rationale:**
- Matches ADR-001's existing structure (standard Nygard ADR pattern).
- Added YAML frontmatter for machine parseability — enables P2-04 validation scripts.
- Status appears in both frontmatter (machine-readable) and body (human-readable).
- `superseded_by` field for standard ADR lifecycle management.

### 4. SKILL.md Integration

Each skill's Setup section gets one additional line after Step 1 (directory creation), before Step 2 (detect stack). Agents load templates before producing artifacts.

**plan-product/SKILL.md** — Insert new Step 2:
```
2. Read `docs/specs/_template.md`, `docs/progress/_template.md`, and `docs/architecture/_template.md` if they exist. Use these as reference formats when producing artifacts.
```
Renumber current Steps 2-5 to 3-6.

**build-product/SKILL.md** — Insert new Step 2:
```
2. Read `docs/specs/_template.md` and `docs/progress/_template.md` if they exist. Use these as reference formats when producing artifacts.
```
Renumber current Steps 2-6 to 3-7.

**review-quality/SKILL.md** — Insert new Step 2:
```
2. Read `docs/progress/_template.md` if it exists. Use it as a reference format when writing findings.
```
Renumber current Steps 2-6 to 3-7.

**Design rationale:**
- One line per skill — keeps Setup lean.
- "If they exist" guard — on a fresh project without templates, agents proceed normally.
- Skill-scoped references — each skill reads only the templates it needs. plan-product reads all 3 (produces specs, ADRs, progress). build-product reads 2 (consumes specs, produces progress). review-quality reads 1 (writes findings).
- No changes to spawn prompts — avoids bloating agent prompts. Templates are read by the team lead during setup.

### 5. Template Seeding

Template files are static reference documents committed to the project repo. They are created as part of the P2-06 implementation — the implementing agent creates the 3 files with the exact content specified in Sections 1-3 above.

**For existing projects**: The P2-06 implementation creates the 3 template files directly. They persist in the repo from that point forward.

**For new projects using the plugin**: The template read step uses "if they exist" guards, so agents proceed without them. Templates become available once the user runs `/plan-product` and the team lead creates them during the first planning session, or copies them from a reference project.

This is an acceptable bootstrap gap. A first-time user's first spec might lack template conformance, but every subsequent spec will have the template available. The alternative (embedding template content in SKILL.md) trades a one-time gap for permanent context bloat in every session.

No changes to SKILL.md Step 1 (directory creation). No runtime seeding logic.

## Constraints

1. **Templates are reference documents, not enforced schemas.** Agents may deviate when justified. The goal is consistency by default, not rigid conformity.
2. **No SKILL.md bloat.** SKILL.md references templates by file path, not by content. Each skill gets exactly one new Setup line.
3. **No changes to spawn prompts.** Templates are read by the team lead during setup. Agent prompts are not modified.
4. **Checkpoint format stays in SKILL.md.** The checkpoint protocol is already defined identically in all 3 SKILL.md files. No separate template file is created for checkpoints.
5. **Cost summary format stays in the cost-guardrails spec.** No separate template file is created for cost summaries.

## Out of Scope

- Template enforcement or validation (deferred to P2-04 Automated Testing Pipeline)
- Checkpoint file template (format already in SKILL.md)
- Cost summary template (format already in cost-guardrails spec)
- Roadmap item template (format already defined by ADR-001)
- Message format templates (review formats, research findings — these belong in spawn prompts)
- Team lead summary template variations (too varied to benefit from standardization)
- Runtime template generation or seeding logic in SKILL.md

## Files to Create

| File | Content |
|------|---------|
| `docs/specs/_template.md` | Spec template (Section 1) |
| `docs/progress/_template.md` | Progress summary template (Section 2) |
| `docs/architecture/_template.md` | ADR template (Section 3) |

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-product/SKILL.md` | Insert template read step as new Step 2 in Setup. Renumber Steps 2-5 to 3-6. |
| `plugins/conclave/skills/build-product/SKILL.md` | Insert template read step as new Step 2 in Setup. Renumber Steps 2-6 to 3-7. |
| `plugins/conclave/skills/review-quality/SKILL.md` | Insert template read step as new Step 2 in Setup. Renumber Steps 2-6 to 3-7. |

## Success Criteria

1. Two different `/plan-product` sessions produce specs with the same section structure (Summary, Problem, Solution, Constraints, Out of Scope, Files to Modify, Success Criteria).
2. A `/build-product` team can reliably parse a spec produced by `/plan-product` because the format is predictable.
3. Template files exist at `docs/specs/_template.md`, `docs/progress/_template.md`, and `docs/architecture/_template.md`.
4. Each SKILL.md Setup section includes a template read step with "if they exist" guard.
5. Templates add less than 8% context overhead per skill invocation (~720 tokens max for plan-product, which reads all 3).
6. Existing artifacts (specs, progress files, ADRs) are not retroactively reformatted — templates apply to new artifacts only.
7. Each template uses YAML frontmatter for machine parseability, enabling future P2-04 validation.
