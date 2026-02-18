---
feature: "artifact-format-templates"
team: "plan-product"
agent: "architect"
phase: "design"
status: "awaiting_review"
last_action: "Tightened Setup wording with explicit Lead-only annotations, resubmitted"
updated: "2026-02-14T18:45:00Z"
---

## Progress Notes

- [17:55] Claimed task #2. Completed preliminary analysis of all 3 SKILL.md files, both existing specs, ADR-001, roadmap items, and progress files.
- [18:00] Completed template system design (below). Identified inconsistencies through direct codebase analysis. Submitted for review.
- [18:10] Researcher findings arrived (docs/progress/artifact-format-templates-researcher.md). Key insight: progress template should cover the progress SUMMARY format (team lead aggregates), not the checkpoint format (already in SKILL.md). Revised Section 3.2 accordingly. Also incorporated researcher's finding about `role` vs `agent` field name inconsistency in checkpoint files.
- [18:20] Skeptic rejected design (round 1). Two blocking issues: (1) seeding mechanism underspecified — how does the agent know template content? (2) scope ambiguity — what does "deviate when justified" mean? Revised Section 5 (static committed files) and added Section 10 (deviation policy).
- [18:30] Skeptic rejected seeding again (round 2). "Static committed files" doesn't solve new-project bootstrap. Revised Section 5 to use compact structural specs in Step 1 (~3 lines per template, ~9 lines total). Agent has enough info to generate correct template files without full inline content.
- [18:40] Received skeptic review (appears to be from round 1 -- references original "standard template" language). Issue #1 (seeding) already addressed in current Section 5 with compact structural specs. Issue #2 (progress template scope) valid -- clarified Setup wording in Sections 4.1-4.3 to specify which template applies to which artifact type, and added explicit note that checkpoint files follow SKILL.md Checkpoint Protocol, not the progress summary template.
- [18:45] Received skeptic review (round 2 -- references "Option A" and "static committed files" from revision 1). Issue #1 (seeding) already resolved in current Section 5 with compact structural specs. Issue #2 (Setup wording) -- tightened further: each Setup line now explicitly says "Team Lead only" / "QA Lead only" for progress template usage, with parenthetical noting agents use Checkpoint Protocol instead. Resubmitting.

---

# Artifact Format Templates — Architecture Design

## 1. Overview

Three template files provide reference structures for the three artifact types that lack formal templates: specs, progress summaries (team lead aggregates), and ADRs. Templates live alongside the artifacts they govern (`docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md`). Each SKILL.md's Setup section gets one additional line pointing agents to the relevant template.

Note: Checkpoint files and cost summaries already have formats defined in SKILL.md and the cost-guardrails spec respectively. They do not need separate template files.

Templates are reference documents, not enforced schemas. Some elements are required (frontmatter, Summary, Success Criteria); others are flexible (solution structure, optional sections). The deviation policy (Section 10) defines the boundary. The goal is consistency by default, not rigid conformity.

## 2. Inconsistencies Found (Direct Analysis)

Before designing templates, I catalogued what exists and where it diverges.

### 2.1 Spec Format Divergence

The two existing specs have different structures:

| Section | cost-guardrails/spec.md | project-bootstrap/spec.md |
|---------|------------------------|--------------------------|
| Frontmatter | title, status, priority, category, approved_by, created, updated | None |
| Opening | `# ... Specification` then `## Summary` | `# ... Implementation Spec` then `## Summary` |
| Problem statement | Implicit (woven into Summary) | Explicit `## Problem` section |
| Solution body | Numbered sections (1-7) with mixed concerns | `## Change` with before/after diffs |
| Constraints | `## Non-Negotiable Constraints` (numbered) | `## Properties` (bulleted) |
| Scope | No explicit scoping section | `## Out of Scope` |
| Files changed | `## Files to Modify` (table) | `## Files to Modify` (subsections) |
| Success criteria | `## Success Criteria` (numbered) | `## Success Criteria` (numbered) |

**Common ground**: Both have Summary, both end with Success Criteria, both list files to modify. The divergence is in the middle — how the solution is structured.

### 2.2 Progress File Divergence

There are two distinct types of progress files:

**Progress summaries** (team lead aggregates, written after work completes):

| File | Frontmatter | Sections |
|------|-------------|----------|
| cost-guardrails.md | feature, status, completed | Summary, Changes (subsections), Files Modified, Verification |
| concurrent-write-safety.md | feature, status, completed | Summary, Files Modified, Verification |
| stack-generalization.md | feature, status, completed | Summary, Files Modified, Files Created, Verification |
| state-persistence.md | feature, status, completed | Summary, Files Modified, Verification |
| project-bootstrap.md | feature, status, completed | Summary, Files Modified, Verification |

These are actually fairly consistent — all share Summary, Files Modified, Verification. The main gap is no template formalizing this pattern.

**Checkpoint files** (agent-scoped, written during work):

| File | Fields used | Matches SKILL.md spec? |
|------|------------|----------------------|
| cost-guardrails-architect.md | feature, team, agent, phase, status, last_action, updated | Yes |
| cost-guardrails-impl-architect.md | feature, role, status, created | No (`role` not `agent`, missing `team`/`phase`/`last_action`/`updated`) |
| p1-01-impl-architect.md | feature, role, status, created | No (same issues) |
| p1-02-impl-architect.md | feature, role, status, created | No (same issues) |
| p1-03-impl-architect.md | feature, role, status, created | No (same issues) |

The checkpoint format is well-defined in all 3 SKILL.md files but early files (pre-P1-02) use `role` instead of `agent` and lack several fields. This is a historical artifact — the format was formalized retroactively.

### 2.3 ADR Format

Only ADR-001 exists. Its structure (Status, Context, Decision, Alternatives Considered, Consequences) follows the standard Michael Nygard ADR pattern. No divergence to fix — just needs to be formalized as the template.

## 3. Template Designs

### 3.1 Spec Template (`docs/specs/_template.md`)

Design goals:
- Progressive disclosure: Summary first, then details. A reader can stop at any depth.
- Predictable structure: `/build-product` can reliably parse specs from `/plan-product`.
- Lightweight: ~40 lines including comments. Agents read it once per session.

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

**Design decisions:**

1. **Frontmatter fields standardized** from what exists in cost-guardrails spec, plus `status` field to track the spec's own lifecycle (distinct from the roadmap item's status).
2. **Problem and Solution are separate sections** — cost-guardrails merged them, project-bootstrap separated them. Separation is clearer for the implementation team.
3. **Constraints replaces "Non-Negotiable Constraints"** — shorter heading, same purpose.
4. **Out of Scope is mandatory** — project-bootstrap had it, cost-guardrails didn't. Its absence in cost-guardrails led to the architect having to explicitly reject scope expansion (the `--minimal` mode discussion).
5. **No numbered top-level sections** (1. Lightweight Mode, 2. SKILL.md Changes, etc.) — cost-guardrails used these but they are content-specific, not structural. Subsections under Solution handle this.
6. **Comments are HTML comments** so they don't render if accidentally left in.

### 3.2 Progress Summary Template (`docs/progress/_template.md`)

Design goals:
- Formalize the progress summary format used by team leads when aggregating completed work.
- Based on the pattern already emerging across the 5 existing progress summaries (all share Summary, Files Modified, Verification).
- Minimal — team leads write these once per session.

Note: This template covers **progress summaries** (team lead aggregates written after work completes), NOT **checkpoint files** (agent-scoped files written during work). The checkpoint format is already defined identically in all 3 SKILL.md Checkpoint Protocol sections and does not need a separate template file.

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

**Design decisions:**

1. **Based on actual existing pattern** — all 5 existing progress summaries share Summary, Files Modified, and Verification sections. This template formalizes what already works rather than inventing a new structure.
2. **Frontmatter standardized** from what exists (`feature`, `status`, `completed`). The researcher noted these are consistent across all 5 files.
3. **`Changes` section added** — cost-guardrails.md had detailed subsections describing what changed. Other summaries folded this into Summary. A dedicated Changes section provides a natural home for detail without overloading Summary.
4. **`Files Created` is optional** — only stack-generalization.md needed this (it created `docs/stack-hints/laravel.md`). The template notes it should be omitted when not applicable.
5. **Checkpoint files are NOT templated here** — the researcher correctly identified that checkpoint format is already defined in SKILL.md (3 identical copies). A template file would be redundant. The existing `role` vs `agent` field name inconsistency in older checkpoint files is a historical artifact from before P1-02 formalized the format; it does not warrant a separate template.

### 3.3 ADR Template (`docs/architecture/_template.md`)

Design goals:
- Match ADR-001's structure (it's already good).
- Standard Nygard ADR pattern with one addition: a frontmatter block for machine-parseability.

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

**Design decisions:**

1. **Added YAML frontmatter** — ADR-001 lacks it. The frontmatter enables P2-04 validation scripts to parse ADR status without reading the full document.
2. **Status in both frontmatter and body** — the frontmatter is machine-readable, the body is human-readable. This matches the roadmap pattern (YAML status + emoji convention).
3. **`superseded_by` field** — standard ADR practice for evolving decisions.
4. **Alternatives as subsections** — ADR-001 used `###` subsections for alternatives. The template formalizes this.

## 4. SKILL.md Integration

Each skill's Setup section gets one additional line. The line is inserted after directory creation (Step 1) and before any "Read docs/" steps, so agents load templates before producing artifacts.

### 4.1 plan-product/SKILL.md — Setup Addition

After Step 1 (directory creation), before Step 2 (detect stack):

```
2. Read artifact templates if they exist. Use `docs/specs/_template.md` and `docs/architecture/_template.md` as reference formats when producing specs and ADRs. Use `docs/progress/_template.md` as the reference format when writing the final progress summary (Team Lead only — agents write checkpoint files per the Checkpoint Protocol, not this template).
```

Remaining steps renumber (current 2-5 become 3-6).

### 4.2 build-product/SKILL.md — Setup Addition

After Step 1, before Step 2:

```
2. Read artifact templates if they exist. Use `docs/specs/_template.md` as reference when reading specs. Use `docs/progress/_template.md` as the reference format when writing the final progress summary (Team Lead only — agents write checkpoint files per the Checkpoint Protocol, not this template).
```

Remaining steps renumber (current 2-6 become 3-7).

**Note**: build-product does not reference the ADR template. The implementation team reads ADRs but does not write them — that is the product team architect's role.

### 4.3 review-quality/SKILL.md — Setup Addition

After Step 1, before Step 2:

```
2. Read `docs/progress/_template.md` if it exists. Use it as the reference format when writing the final quality summary (QA Lead only — agents write checkpoint files per the Checkpoint Protocol, not this template).
```

Remaining steps renumber (current 2-6 become 3-7).

**Note**: review-quality only references the progress summary template. It does not produce specs or ADRs.

### 4.4 Design Rationale for Setup Additions

1. **One line per skill** — keeps the Setup section lean. The line says "read templates if they exist" not "you must follow these templates exactly."
2. **"If they exist" guard** — after Step 1 seeding, templates will normally exist. The guard is a safety check for edge cases: seeding failure, user-deleted templates, or projects where the plugin was installed before P2-06. Without templates, agents proceed with their existing behavior rather than erroring.
3. **Skill-scoped template references** — each skill only reads the templates it needs. plan-product reads all three (it produces specs, ADRs, and progress). build-product reads specs and progress (it consumes specs, produces progress). review-quality reads only progress (it writes findings).
4. **No changes to spawn prompts** — templates are read by the team lead during setup and their structure is implicitly communicated through the checkpoint format already embedded in SKILL.md. Adding template references to every spawn prompt would bloat them.

## 5. Template Seeding (How Templates Get Into Projects)

Templates must exist before agents can read them. The approach: extend Step 1 in each SKILL.md to seed template files if they don't exist, using a **compact structural description** that gives the agent enough information to generate a correct template without inlining the full content.

### Alternatives considered and rejected

**Full template content inline in SKILL.md**: Each template is ~30-40 lines. Three templates times 3 SKILL.md files = ~300 lines of boilerplate added to the skill files. This bloats every session's context. Rejected.

**Manual creation by users**: Defeats the purpose — templates solve the "agents don't know what format to use" problem. Rejected.

**Static committed files only (no seeding)**: Works for existing projects but not for new projects using the plugin for the first time. A first-time user's first session has no templates and no way to get them. The "if they exist" guard means agents silently skip templates, producing inconsistent artifacts — exactly the problem P2-06 exists to solve. Rejected.

### Recommended approach: Compact structural specs in Step 1

Add seeding instructions to Step 1 in each SKILL.md, after directory creation. Each template is described in ~2-3 lines — enough for the agent to generate the correct file, but not the full template content. Total addition: ~12 lines per SKILL.md.

#### Step 1 addition (identical across all 3 SKILL.md files)

After the existing directory creation bullet points, add:

```markdown
   - Seed template files if they don't exist (do not overwrite existing templates):
     - `docs/specs/_template.md`: YAML frontmatter (title, status [draft|ready_for_review|approved|ready_for_implementation], priority [P1|P2|P3], category, approved_by, created, updated) and sections: Summary, Problem, Solution, Constraints, Out of Scope, Files to Modify (as table), Success Criteria. Include HTML comment hints in each section.
     - `docs/progress/_template.md`: YAML frontmatter (feature, status [in_progress|complete], completed) and sections: Summary, Changes, Files Modified, Files Created (note: include only when applicable), Verification. Include HTML comment hints in each section.
     - `docs/architecture/_template.md`: YAML frontmatter (title, status [proposed|accepted|deprecated|superseded], created, updated, superseded_by) and sections: Status, Context, Decision, Alternatives Considered (with ### subsections per alternative), Consequences (with Positive/Negative bullet points). Include HTML comment hints in each section.
```

#### Why this works

- **Compact**: ~12 lines added to Step 1 per SKILL.md. Manageable context cost (~150 tokens).
- **Deterministic**: The structural description is precise enough that different agents generating from it will produce structurally identical templates. Field names, section names, and enum values are all specified.
- **Idempotent**: "If they don't exist" guard means existing templates (including user-customized ones) are never overwritten.
- **No bootstrap gap**: First-time users on fresh projects get templates seeded on the very first skill invocation.
- **Customizable**: Users can edit the generated templates after seeding. Subsequent invocations see the customized versions.

#### Impact on Section 4 (SKILL.md Integration)

The template read step (Section 4) still applies, but the "if they exist" guard becomes a safety check rather than a common case. After Step 1 seeds templates, Step 2 reads them. The guard handles the edge case where seeding fails or the user deleted a template intentionally.

## 6. Relationship with P2-04 (Automated Testing Pipeline)

P2-04 proposes structural validation scripts. Templates provide the reference structures those scripts validate against.

**Integration points:**

1. **Template existence check**: P2-04 validation can verify that `_template.md` files exist in the expected directories.
2. **Frontmatter field validation**: P2-04 can parse YAML frontmatter in specs, ADRs, and progress summaries, and verify required fields are present (as defined by the templates).
3. **Section presence validation**: P2-04 can check that spec files contain the required sections (Summary, Problem, Solution, Success Criteria) as defined by the spec template.
4. **Checkpoint format validation**: P2-04 can verify that checkpoint files (agent-scoped progress files) match the YAML schema defined in SKILL.md Checkpoint Protocol sections (feature, team, agent, phase, status, last_action, updated). The schema source is SKILL.md, not a template file.
5. **Progress summary validation**: P2-04 can verify that team lead summary files contain the required sections (Summary, Files Modified, Verification) as defined by the progress template.

**What P2-04 should NOT validate:**
- Section content quality (that's the Skeptic's job)
- Whether agents deviated from templates with justification (deviation is permitted)
- Progress note formatting beyond the YAML frontmatter

This design intentionally keeps templates simple enough that a validation script can check conformance with basic YAML parsing and markdown heading extraction — no custom parser needed.

## 7. Template Sizing and Context Cost

A key constraint is that templates must not burn significant context when agents read them.

| Template | Estimated size | Context cost |
|----------|---------------|-------------|
| Spec template | ~40 lines, ~1.2KB | Negligible (~300 tokens) |
| Progress summary template | ~30 lines, ~0.8KB | Negligible (~200 tokens) |
| ADR template | ~30 lines, ~0.9KB | Negligible (~220 tokens) |
| **Total per skill** | **varies** | **~720 tokens max** |

For comparison, a single SKILL.md file is 300-450 lines (~8,000-12,000 tokens). Templates add <8% overhead to the setup phase. This is acceptable.

plan-product reads all three templates (~720 tokens). build-product reads two (~500 tokens). review-quality reads one (~200 tokens). Lightweight and proportional.

## 8. Files to Create

| File | Content |
|------|---------|
| `docs/specs/_template.md` | Spec template (Section 3.1) |
| `docs/progress/_template.md` | Progress summary template (Section 3.2) |
| `docs/architecture/_template.md` | ADR template (Section 3.3) |

## 9. Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-product/SKILL.md` | Extend Step 1 with template seeding (Section 5), add template read step in Setup (Section 4.1) |
| `plugins/conclave/skills/build-product/SKILL.md` | Extend Step 1 with template seeding (Section 5), add template read step in Setup (Section 4.2) |
| `plugins/conclave/skills/review-quality/SKILL.md` | Extend Step 1 with template seeding (Section 5), add template read step in Setup (Section 4.3) |

## 10. Deviation Policy

The overview states "agents can deviate when justified." This section defines what that means concretely.

### What is required (non-deviable)

These elements are always required. P2-04 validation scripts can enforce them:

1. **YAML frontmatter must be present** in specs, ADRs, and progress summaries. The frontmatter is the machine-readable contract between artifacts and tooling.
2. **Required frontmatter fields must be populated.** For specs: `title`, `status`, `created`. For ADRs: `title`, `status`, `created`. For progress summaries: `feature`, `status`.
3. **Summary section must be present** in specs and progress summaries. This is the progressive disclosure entry point — without it, other agents cannot quickly assess the artifact.
4. **Success Criteria section must be present** in specs. This is the verification contract between the product team and the implementation team.

### What is flexible (deviable without documentation)

These elements can be added, removed, or renamed without explanation:

1. **Solution subsection structure.** The spec template shows `## Solution` as a single section, but agents may split it into numbered subsections (as cost-guardrails did) or use domain-specific headings. The internal structure of the solution depends on the feature.
2. **Optional sections.** `Out of Scope`, `Files Created`, `Constraints`, and `Alternatives Considered` (in ADRs) may be omitted if not applicable. Empty sections waste reader attention.
3. **Additional sections.** Agents may add sections not in the template (e.g., `## Migration Plan`, `## API Contract`, `## Performance Considerations`) when the feature warrants it.

### What requires a note when deviating

These deviations should include a brief comment (1 sentence) explaining why:

1. **Omitting `## Problem` from a spec.** The Problem section is important for context but some spec types (e.g., refactoring, cleanup) may not have a "problem" in the traditional sense. If omitted, the Summary should explain the motivation.
2. **Omitting `## Verification` from a progress summary.** Verification is the quality audit trail. If omitted, note why (e.g., "Verification deferred to implementation phase").
3. **Using non-standard frontmatter `status` values.** The templates define specific enums. Using a value outside the enum (e.g., `status: "plan-pending-review"` as seen in p1-01-impl-architect.md) should include a comment explaining why the standard values don't apply.

### How deviations are caught

Deviations are not policed by templates — they are policed by the Skeptic. The Skeptic reviews all artifacts and can reject those with unjustified omissions. This is the existing quality gate; templates do not add a new enforcement layer. P2-04 validation scripts check the "non-deviable" requirements only.

## 11. What This Design Does NOT Do

1. **Does not rigidly enforce templates** — agents can deviate per the deviation policy (Section 10). Required elements are enforced by P2-04 validation; flexible elements are reviewed by the Skeptic.
2. **Does not template checkpoint files** — the checkpoint format is already defined identically in all 3 SKILL.md Checkpoint Protocol sections. A separate template file would be redundant.
3. **Does not template cost summary files** — the cost summary format is already defined in the cost-guardrails spec and does not need a separate template file.
4. **Does not template roadmap items** — ADR-001 already defines the roadmap format. No separate template needed.
5. **Does not add template references to spawn prompts** — avoids bloating agent prompts. The team lead reads templates during setup; the structure propagates through the checkpoint format already in SKILL.md.
6. **Does not template message formats** — review formats, research finding formats, and other message structures are embedded in spawn prompts (where they belong) and are not file templates.
