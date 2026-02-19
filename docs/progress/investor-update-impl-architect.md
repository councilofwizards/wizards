---
feature: "investor-update"
team: "build-product"
agent: "impl-architect"
phase: "design"
status: "complete"
last_action: "Implementation plan finalized"
updated: "2026-02-19T00:00:00Z"
---

# P3-22: Implementation Plan for `/draft-investor-update`

## Overview

Two deliverables: (1) create `plugins/conclave/skills/draft-investor-update/SKILL.md` and (2) extend `scripts/validators/skill-shared-content.sh`. This plan is section-by-section with exact sourcing for each block.

---

## Part A: SKILL.md Section-by-Section Plan

### A1. YAML Frontmatter (NEW)

```yaml
---
name: draft-investor-update
description: >
  Draft an investor update from project data. Gathers metrics and milestones
  from the roadmap, progress files, and specs, then drafts, reviews, and
  refines a structured investor update through dual-skeptic validation.
argument-hint: "[--light] [status | <period> | (empty for current period)]"
---
```

**Source**: New content. Matches the frontmatter format of all 4 existing skills. Fields: `name`, `description`, `argument-hint` (all 3 required by `skill-structure.sh` A1). No `type: single-agent` field (this is multi-agent).

**Validator check**: A1 checks name matches parent directory `draft-investor-update`. Confirmed.

---

### A2. Title + Lead Role (ADAPTED from plan-product)

```markdown
# Investor Update Team Orchestration

You are orchestrating the Investor Update Team. Your role is TEAM LEAD.
Enable delegate mode -- you coordinate, you do NOT write content yourself.
```

**Source**: Adapted from plan-product line 10-13. Changed "Product Team" to "Investor Update Team", role from "Product Owner" to "TEAM LEAD", and "write specs" to "write content".

---

### A3. Setup (ADAPTED from plan-product)

**Source**: Adapted from plan-product lines 16-27. Key changes:
- Add `docs/investor-updates/` to directory list (new output directory)
- Add reading `docs/investor-updates/_user-data.md` and prior updates
- Keep standard reads: `docs/roadmap/`, `docs/progress/`, `docs/specs/`, `docs/architecture/`
- Keep template reading: `docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md`
- Keep stack detection (unchanged)
- Add: Create `docs/investor-updates/_user-data.md` template if directory exists but file does not (first-run convenience, per spec S.C. 9)

**Validator check**: A2 requires `## Setup` heading. Confirmed.

---

### A4. Write Safety (ADAPTED from plan-product)

**Source**: Adapted from plan-product lines 29-35. Same pattern, different role names:
- `docs/progress/investor-update-{role}.md` (e.g., `investor-update-researcher.md`)
- Only Team Lead writes to `docs/investor-updates/` output files
- Only Team Lead writes to shared/aggregated progress summaries

**Validator check**: A2 requires `## Write Safety` heading. Confirmed.

---

### A5. Checkpoint Protocol (ADAPTED from plan-product)

**Source**: Adapted from plan-product lines 37-69. Changes:
- `team: "draft-investor-update"` (was `"plan-product"`)
- Phase enum: `research | draft | review | revision | complete` (was `research | design | review | complete`)
- Same checkpoint file format and "When to Checkpoint" triggers

**Validator check**: A2 requires `## Checkpoint Protocol` heading. Confirmed.

---

### A6. Determine Mode (ADAPTED from plan-product)

**Source**: Adapted from plan-product lines 72-78. Key changes per spec:
- **"status"**: Same pattern -- read checkpoint files with `team: "draft-investor-update"`, report status, no agents spawned (S.C. 7)
- **Empty/no args**: Same resume-from-checkpoint pattern. If no incomplete checkpoints, infer current period from latest progress file timestamps and run full pipeline (S.C. 1)
- **"<period>"**: NEW -- research a specific period (e.g., "2026-02" or "2026-01-15 to 2026-02-15") (S.C. 8)
- **No "new" or "review" or "reprioritize"** modes (those are plan-product-specific)

**Validator check**: A2 requires `## Determine Mode` heading. Confirmed.

---

### A7. Lightweight Mode (ADAPTED from plan-product)

**Source**: Adapted from plan-product lines 82-88. Changes per spec:
- Researcher: spawn with model **sonnet** instead of opus (S.C. 6)
- Drafter: unchanged (already sonnet)
- Accuracy Skeptic: unchanged (ALWAYS opus)
- Narrative Skeptic: unchanged (ALWAYS opus)
- All orchestration, quality gates, and communication protocols remain identical

**Validator check**: A2 requires `## Lightweight Mode` heading. Confirmed.

---

### A8. Spawn the Team (NEW content, standard format)

**Source**: New content following the build-product format (lines 100-131). Four agents:

#### Researcher
- **Name**: `researcher`
- **Model**: opus
- **Subagent type**: general-purpose
- **Tasks**: Investigate project artifacts. Gather metrics, milestones, blockers. Produce Research Dossier.

#### Drafter
- **Name**: `drafter`
- **Model**: sonnet
- **Subagent type**: general-purpose
- **Tasks**: Compose investor update from Research Dossier. Revise based on skeptic feedback.

#### Accuracy Skeptic
- **Name**: `accuracy-skeptic`
- **Model**: opus
- **Subagent type**: general-purpose
- **Tasks**: Verify all factual claims against evidence. Check numbers, milestones, timelines. Business quality checklist.

#### Narrative Skeptic
- **Name**: `narrative-skeptic`
- **Model**: opus
- **Subagent type**: general-purpose
- **Tasks**: Detect spin, omissions, prior-update inconsistency. Check balanced framing and audience appropriateness. Business quality checklist.

**Validator check**: A2 requires `## Spawn the Team` heading. A3 checks each H3 entry has `**Name**:` (backtick-quoted), `**Model**:` (opus or sonnet), `**Subagent type**:`. All 4 entries comply.

---

### A9. Orchestration Flow (NEW -- Pipeline pattern)

**Source**: New content. This is the key differentiator from existing skills. Based on spec "Pipeline Stages" and system design "Pipeline Architecture" sections.

```
1. **Stage 1: Research** -- Researcher gathers data, produces Research Dossier
2. **Gate 1**: Team Lead reviews dossier for completeness (lightweight check)
3. **Stage 2: Draft** -- Drafter composes investor update from dossier + template + prior updates
4. **Stage 3: Review** -- Both Skeptics review draft AND dossier in parallel
5. **Gate 2**: BOTH skeptics must approve. If either rejects -> Stage 2b
6. **Stage 2b: Revise** -- Drafter revises with rejection feedback, returns to Gate 2 (max 3 cycles)
7. **Stage 4: Finalize** -- Team Lead writes final output, progress summary, cost summary
8. **Team Lead only**: Write final update to docs/investor-updates/{date}-investor-update.md
9. **Team Lead only**: Write progress summary to docs/progress/investor-update-summary.md
10. **Team Lead only**: Write cost summary to docs/progress/draft-investor-update-{date}-cost-summary.md
```

**Validator check**: A2 requires `## Orchestration Flow` heading. Confirmed.

---

### A10. Quality Gate (NEW -- dual-skeptic)

```markdown
## Quality Gate

NO investor update is finalized without BOTH Accuracy Skeptic AND Narrative Skeptic approval. If either skeptic has concerns, the Drafter revises. This is non-negotiable. Maximum 3 revision cycles before escalation to the human operator.
```

**Source**: New content. Adapted from plan-product's single-skeptic gate (line 135-136) to dual-skeptic per spec constraint 3.

**Validator check**: A2 requires one of `## Critical Rules` or `## Quality Gate`. Using `## Quality Gate`. Confirmed.

---

### A11. Failure Recovery (COPIED from plan-product with minor adaptation)

**Source**: Nearly identical to plan-product lines 138-141. Same three patterns:
1. **Unresponsive agent**: Re-spawn role, re-assign tasks
2. **Skeptic deadlock**: 3 rejections -> escalate. Adapted to: "If EITHER skeptic rejects the same deliverable 3 times..."
3. **Context exhaustion**: Read checkpoint, re-spawn with context

**Validator check**: A2 requires `## Failure Recovery` heading. Confirmed.

---

### A12. Shared Principles (COPIED VERBATIM from plan-product)

**Source**: plan-product lines 145-174. BYTE-IDENTICAL copy including:
- `<!-- BEGIN SHARED: principles -->` marker
- `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->` comment
- Full content (12 principles across 4 tiers)
- `<!-- END SHARED: principles -->` marker

**Validator checks**:
- A2 requires `## Shared Principles` heading. Confirmed.
- A4 requires matched BEGIN/END markers for "principles". Confirmed.
- B1 requires byte-identical content to authoritative source. Confirmed (verbatim copy).
- B3 requires authoritative source comment on line after BEGIN marker. Confirmed.

---

### A13. Communication Protocol (COPIED from plan-product, skeptic names adapted)

**Source**: plan-product lines 178-213. Copied with ONE change:
- Line 196: `write(product-skeptic, ...)` -> `write(accuracy-skeptic, ...)` and `Product Skeptic` -> `Accuracy Skeptic`

The B2 validator normalizes all skeptic name variants to `SKEPTIC_NAME` before comparison, so this adaptation is allowed and expected.

**Content between markers is structurally identical** -- only skeptic names differ.

**Validator checks**:
- A2 requires `## Communication Protocol` heading. Confirmed.
- A4 requires matched BEGIN/END markers for "communication-protocol". Confirmed.
- B2 requires structural equivalence after skeptic name normalization. Confirmed (only skeptic names change).
- B3 requires authoritative source comment on line after BEGIN marker. Confirmed.

**Important**: The "Plan ready for review" row references `accuracy-skeptic` / `Accuracy Skeptic` as the target. This is correct since the Accuracy Skeptic is the natural first target for plan reviews in a data-accuracy-focused pipeline. Both skeptics will receive review requests through the orchestration flow regardless.

---

### A14. Contract Negotiation Pattern comment (OMIT)

**Source**: Following the pattern of plan-product (line 215) and review-quality (line 223), include the comment:

```markdown
<!-- Contract Negotiation Pattern omitted -- not relevant to draft-investor-update. See build-product/SKILL.md. -->
```

This maintains consistency with other skills that omit the build-product-specific section.

---

### A15. Teammate Spawn Prompts (NEW content, standard structure)

**Source**: New content following the pattern of plan-product (lines 217-389) and build-product (lines 291-472). The section header follows the pattern: one of `## Teammate Spawn Prompts` or `## Teammates to Spawn` (per A2 validator).

**Sub-sections (each H3 with Model and code-fenced prompt)**:

#### Researcher (Model: Opus)

Adapted from plan-product Researcher (lines 224-263) with significant changes:
- Role is research-for-investor-update, not research-for-spec-writing
- Reads: roadmap, progress, specs, architecture, investor-updates, _user-data.md
- Output: Research Dossier (structured format from system design)
- Temporal scoping from period argument or inferred timestamps
- Write safety: `docs/progress/investor-update-researcher.md`
- Must report to Team Lead AND both skeptics
- Data Gaps section is mandatory
- Confidence Assessment section is mandatory

#### Drafter (Model: Sonnet)

New role (no analog in existing skills):
- Receives Research Dossier + embedded template + prior updates
- Instructions: write from facts only, no fabrication, calibrate language to confidence, include ALL sections with "[Requires user input]" placeholders where needed
- Must include mandatory business quality sections
- Append Drafter Notes with assumptions, framing choices, questions
- Write safety: `docs/progress/investor-update-drafter.md`
- Model upgrade note: if revision cycles consistently fail, Team Lead may upgrade to Opus

#### Accuracy Skeptic (Model: Opus)

New role. Adapted from the spec's Accuracy Skeptic Checklist (spec lines 106-113):
- 6-item checklist as detailed in spec/system design
- Review format: `ACCURACY REVIEW: ...` with Verdict
- Must receive both draft AND research dossier
- Communicates with narrative-skeptic and team lead
- Write safety: `docs/progress/investor-update-accuracy-skeptic.md`

#### Narrative Skeptic (Model: Opus)

New role. Adapted from the spec's Narrative Skeptic Checklist (spec lines 115-121):
- 6-item checklist as detailed in spec/system design
- First-run behavior: skip prior-update consistency checks when no prior updates exist (S.C. 13)
- Review format: `NARRATIVE REVIEW: ...` with Verdict
- Must receive both draft AND research dossier
- Communicates with accuracy-skeptic and team lead
- Write safety: `docs/progress/investor-update-narrative-skeptic.md`

**Validator check**: A2 requires one of `## Teammate Spawn Prompts` or `## Teammates to Spawn`. Using `## Teammate Spawn Prompts`. Confirmed.

---

### A16. Embedded Content: Output Artifact Template

Within the Drafter's spawn prompt (or as a standalone section referenced by the Drafter), include the full investor update output template from the spec (spec lines 191-260). This is the template the Drafter writes to.

---

### A17. Embedded Content: User Data Template

Include the `_user-data.md` template (from spec lines 152-181) so the skill can create it on first run (S.C. 9). This is embedded in the Setup section instructions.

---

### A18. Embedded Content: Research Dossier Format

Include the Research Dossier format (from system design lines 107-134) in the Researcher's spawn prompt so the output structure is well-defined.

---

## Part B: Shared Content Blocks (Exact Lines)

### B1: Shared Principles Block

Copy lines 145-174 of `plugins/conclave/skills/plan-product/SKILL.md` VERBATIM. This is 30 lines starting with `<!-- BEGIN SHARED: principles -->` and ending with `<!-- END SHARED: principles -->`.

The block MUST be preceded by a `---` horizontal rule (following the pattern of all existing skills).

### B2: Communication Protocol Block

Copy lines 178-213 of `plugins/conclave/skills/plan-product/SKILL.md`. Make ONLY the following substitutions:

| Line (in plan-product) | Original | Replacement |
|------------------------|----------|-------------|
| L196 (table row) | `write(product-skeptic, "PLAN REVIEW REQUEST: ...)` | `write(accuracy-skeptic, "PLAN REVIEW REQUEST: ...)` |
| L196 (table row) | `Product Skeptic` | `Accuracy Skeptic` |

No other changes. The block MUST be preceded by a `---` horizontal rule.

---

## Part C: New Patterns Implementation Details

### C1. Pipeline Orchestration

The orchestration flow in Section A9 is the primary new pattern. Key implementation details:

1. **Sequential gating**: The Team Lead must explicitly verify Gate 1 (dossier completeness) before spawning the Drafter. This is unlike existing skills where agents work in parallel.

2. **Dual-skeptic parallel review**: After the draft is ready, BOTH skeptics are tasked simultaneously. The Team Lead waits for both verdicts before proceeding.

3. **Revision loop**: If either skeptic rejects, the Drafter is re-tasked with the rejection feedback. Both skeptics re-review the revision (even if only one rejected). Maximum 3 cycles.

4. **The orchestration flow section should include the pipeline diagram** from the system design (lines 51-86) adapted to markdown/ASCII art.

### C2. Dual-Skeptic Gate

Implementation in the Quality Gate section (A10) and Orchestration Flow (A9):
- Both skeptics work in parallel (they are separate agents)
- Both MUST approve for Gate 2 to pass
- If EITHER rejects, ALL rejection feedback goes to the Drafter
- Revision count is tracked by the Team Lead
- 3 rejections (from either skeptic, cumulative) triggers escalation

### C3. Evidence Tracing

Implemented through:
- Researcher: every finding in the Research Dossier cites a file path
- Drafter: instructed to trace claims to dossier entries
- Accuracy Skeptic: checklist item 1 ("Every number has a source")
- Output template: Key Metrics table includes "Source" column

### C4. Business Quality Sections

Implemented through:
- Output template includes all 4 mandatory sections (Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints)
- Both skeptics have checklist item 6 verifying business quality
- Drafter instructions mandate inclusion of these sections

---

## Part D: Validator Modification

### File: `scripts/validators/skill-shared-content.sh`

**Function to modify**: `normalize_skeptic_names()` (lines 51-59)

**Current content (lines 51-59)**:
```bash
normalize_skeptic_names() {
    sed \
        -e 's/product-skeptic/SKEPTIC_NAME/g' \
        -e 's/quality-skeptic/SKEPTIC_NAME/g' \
        -e 's/ops-skeptic/SKEPTIC_NAME/g' \
        -e 's/Product Skeptic/SKEPTIC_NAME/g' \
        -e 's/Quality Skeptic/SKEPTIC_NAME/g' \
        -e 's/Ops Skeptic/SKEPTIC_NAME/g'
}
```

**New content (add 4 lines)**:
```bash
normalize_skeptic_names() {
    sed \
        -e 's/product-skeptic/SKEPTIC_NAME/g' \
        -e 's/quality-skeptic/SKEPTIC_NAME/g' \
        -e 's/ops-skeptic/SKEPTIC_NAME/g' \
        -e 's/accuracy-skeptic/SKEPTIC_NAME/g' \
        -e 's/narrative-skeptic/SKEPTIC_NAME/g' \
        -e 's/Product Skeptic/SKEPTIC_NAME/g' \
        -e 's/Quality Skeptic/SKEPTIC_NAME/g' \
        -e 's/Ops Skeptic/SKEPTIC_NAME/g' \
        -e 's/Accuracy Skeptic/SKEPTIC_NAME/g' \
        -e 's/Narrative Skeptic/SKEPTIC_NAME/g'
}
```

**Lines added**: 4 new `-e` entries (2 slug forms + 2 display forms) for accuracy-skeptic and narrative-skeptic.

**Placement**: The new slug entries go after `ops-skeptic` and the new display entries go after `Ops Skeptic`, maintaining the grouping pattern (slugs first, then display names).

---

## Part E: Success Criteria Mapping

| # | Criterion | Where Addressed in SKILL.md |
|---|-----------|---------------------------|
| 1 | Complete investor update with all sections populated or marked "[Requires user input]" | A16 (Output Template -- all sections present), A15-Drafter instructions (placeholder rule), A3 (Setup -- first-run _user-data.md creation) |
| 2 | Every factual claim traces to a source file | A15-Researcher (dossier format cites file paths), A15-Drafter (instructed to trace claims), A15-Accuracy Skeptic (checklist item 1), A16 (Key Metrics table has Source column) |
| 3 | Accuracy Skeptic verifies numbers, milestones, timelines | A15-Accuracy Skeptic (6-item checklist), A10 (Quality Gate requires approval) |
| 4 | Narrative Skeptic checks spin, omissions, consistency | A15-Narrative Skeptic (6-item checklist), A10 (Quality Gate requires approval) |
| 5 | Both skeptics must approve before finalization | A10 (Quality Gate -- dual requirement), A9 (Orchestration Flow -- Gate 2 logic) |
| 6 | --light uses Sonnet for Researcher, Opus for Skeptics | A7 (Lightweight Mode section) |
| 7 | status mode reports without spawning agents | A6 (Determine Mode -- "status" branch) |
| 8 | Period argument scopes research to time range | A6 (Determine Mode -- "<period>" branch), A15-Researcher (temporal scoping instructions) |
| 9 | Creates docs/investor-updates/ and _user-data.md template on first run | A3 (Setup -- directory and template creation), A17 (embedded template content) |
| 10 | Reads and integrates _user-data.md when present | A15-Researcher (reads _user-data.md), A15-Drafter (includes user data sections) |
| 11 | Output includes all 4 mandatory business quality sections | A16 (Output Template -- all 4 sections), A15-Drafter (instructions), A15-both skeptics (checklist item 6) |
| 12 | CI validator passes (shared content drift with normalization) | A12 (verbatim Shared Principles), A13 (Communication Protocol with skeptic name adaptation), Part D (validator extension) |
| 13 | First run succeeds with Narrative Skeptic skipping consistency checks | A15-Narrative Skeptic (explicit first-run behavior instruction) |

---

## Part F: Dependency Ordering

### What the backend-eng (SKILL.md writer) does:

1. Create directory: `plugins/conclave/skills/draft-investor-update/`
2. Write `SKILL.md` with all sections A1-A17 as specified above
3. Verify by running both validators locally:
   - `bash scripts/validators/skill-structure.sh .` (all A-checks pass)
   - `bash scripts/validators/skill-shared-content.sh .` (all B-checks pass -- requires Part D completed first)

### What the frontend-eng (validator modifier) does:

1. Modify `scripts/validators/skill-shared-content.sh` line 51-59 as specified in Part D
2. Verify by running: `bash scripts/validators/skill-shared-content.sh .` on the repo (existing skills must still pass)

### Dependency graph:

```
Part D (validator modification) ─── can happen independently ───┐
                                                                 │
Part A (SKILL.md creation) ───────── can happen independently ──┤
                                                                 │
                                                                 ▼
                                                   Final validation
                                              (both validators pass
                                               against new SKILL.md)
```

**Both tasks are independent** and can proceed in parallel. The final validation step requires both to be complete.

**Recommended ordering**: Start the validator modification first (it is small and fast), then the SKILL.md creation (it is large and complex). This way, the SKILL.md writer can validate against the updated validator as soon as they finish.

---

## Summary of Section-by-Section Decisions

| Section | Strategy | Source |
|---------|----------|--------|
| Frontmatter | NEW | Spec + existing pattern |
| Title + Lead Role | ADAPTED | plan-product L10-13 |
| Setup | ADAPTED | plan-product L16-27 + new investor-updates dir |
| Write Safety | ADAPTED | plan-product L29-35 |
| Checkpoint Protocol | ADAPTED | plan-product L37-69 |
| Determine Mode | ADAPTED | plan-product L72-78 |
| Lightweight Mode | ADAPTED | plan-product L82-88 |
| Spawn the Team | NEW | Spec agent table + standard format |
| Orchestration Flow | NEW | Spec pipeline stages + system design |
| Quality Gate | NEW | Spec dual-skeptic requirement |
| Failure Recovery | ADAPTED | plan-product L138-141 |
| Shared Principles | VERBATIM | plan-product L145-174 |
| Communication Protocol | ADAPTED (names only) | plan-product L178-213 |
| Contract Pattern comment | OMIT (with comment) | plan-product L215 pattern |
| Teammate Spawn Prompts | NEW | Spec checklists + existing prompt pattern |
| Output Template | NEW (embedded) | Spec output format |
| User Data Template | NEW (embedded) | Spec user data format |
| Research Dossier Format | NEW (embedded) | System design dossier format |
