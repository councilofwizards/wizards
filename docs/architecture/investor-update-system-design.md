---
title: "Investor Update System Design"
status: "accepted"
created: "2026-02-19"
updated: "2026-02-19"
---

# Investor Update (`/draft-investor-update`) System Design

## Overview

A multi-agent pipeline skill that drafts investor updates by gathering project data, composing a structured narrative, and validating accuracy and tone through dual-skeptic review. This is the first business skill in the conclave framework — it validates the Pipeline collaboration pattern and the "quality without ground truth" requirements defined in the business skill design guidelines.

## Architecture Classification

This is a **multi-agent Pipeline skill** — sequential handoffs with quality gates between stages. Unlike the existing engineering skills (which use parallel work with a single skeptic gate), `/draft-investor-update` uses:

1. **Sequential pipeline stages** rather than parallel agent work
2. **Dual skeptics** with non-overlapping concerns (Accuracy + Narrative) rather than a single quality gatekeeper
3. **No code output** — the artifact is a structured document, not software
4. **No ground truth** — quality is measured against internal consistency, stated assumptions, and evidence, not test results

The Pipeline pattern (Research -> Draft -> Review -> Revise -> Final validation) is defined in the business skill design guidelines. This skill is the first concrete implementation.

## Agent Team

### Roles

| Role | Name | Model | Responsibility |
|------|------|-------|---------------|
| Team Lead | (invoking agent) | opus | Orchestrate pipeline, manage handoffs, write final output |
| Researcher | `researcher` | opus | Gather metrics, milestones, blockers from project artifacts |
| Drafter | `drafter` | sonnet | Compose the investor update from research findings |
| Accuracy Skeptic | `accuracy-skeptic` | opus | Verify numbers, claims, milestone status against evidence |
| Narrative Skeptic | `narrative-skeptic` | opus | Detect spin, omissions, inconsistency with prior updates |

### Model Selection Rationale

- **Researcher (Opus)**: Must reason about what data matters, identify gaps, and assess confidence. Judgment-heavy.
- **Drafter (Sonnet)**: Executes a well-defined writing task from structured inputs. Cheaper model is sufficient when the inputs are strong. **Risk note (per skeptic review)**: If revision cycles consistently hit the 3-cycle maximum, the Drafter should be upgraded to Opus. Writing compelling investor narrative from structured findings is harder than writing code from a spec. The spec should provide this upgrade path.
- **Accuracy Skeptic (Opus)**: Must cross-reference claims against evidence and detect subtle inaccuracies. Reasoning-heavy adversarial role.
- **Narrative Skeptic (Opus)**: Must detect omissions, spin, and tone inconsistencies. Requires nuanced judgment. Skeptics are always Opus per shared principles.

### Why No DBA

There is no database, no data model, no migrations. The skill reads markdown files and produces a markdown document. A DBA role adds no value.

## Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         /draft-investor-update                          │
│                                                                         │
│  Stage 1: RESEARCH                                                      │
│  ┌──────────────┐                                                       │
│  │  Researcher   │──► Research Dossier (structured findings)            │
│  └──────────────┘         │                                             │
│                           ▼  GATE 1: Lead verifies completeness         │
│  Stage 2: DRAFT                                                         │
│  ┌──────────────┐         │                                             │
│  │   Drafter     │◄───────┘                                             │
│  │              │──► Draft Investor Update                              │
│  └──────────────┘         │                                             │
│                           ▼  GATE 2: Dual-Skeptic Review                │
│  Stage 3: REVIEW          │                                             │
│  ┌──────────────┐  ┌──────────────┐                                     │
│  │  Accuracy     │  │  Narrative    │  (parallel review)                │
│  │  Skeptic      │  │  Skeptic      │                                   │
│  └──────────────┘  └──────────────┘                                     │
│         │                  │                                            │
│         ▼                  ▼                                            │
│   Accuracy Verdict   Narrative Verdict                                  │
│         │                  │                                            │
│         └────────┬─────────┘                                            │
│                  ▼                                                       │
│           BOTH APPROVED?                                                │
│          ┌──yes──┴──no──┐                                               │
│          ▼              ▼                                                │
│  Stage 4: FINALIZE   Stage 2b: REVISE                                   │
│  Lead writes          Drafter revises with                              │
│  final output         skeptic feedback                                  │
│                       (returns to GATE 2)                               │
│                                                                         │
│  Max 3 revision cycles before escalation                                │
└──────────────────────────────────────────────────────────────────────────┘
```

### Stage Details

#### Stage 1: Research

**Agent**: Researcher

**Inputs**: The researcher reads:
- `docs/roadmap/_index.md` and individual roadmap files — to identify completed milestones, current priorities, and blockers
- `docs/progress/` — to gather implementation status, recent session summaries, and any quantitative outcomes
- `docs/specs/` — to understand what was planned vs. what was delivered
- `docs/architecture/` — to identify significant technical decisions made in the period
- `docs/investor-updates/_user-data.md` — user-provided financial metrics, team updates, and investor asks (see User Data Input below)
- `docs/investor-updates/` — prior investor updates for consistency reference
- Project root files (README, CLAUDE.md, etc.) — for project context

**If `_user-data.md` is missing or incomplete**: The researcher notes the missing data in the Data Gaps section of the dossier. The drafter uses "[Requires user input -- see docs/investor-updates/_user-data.md]" placeholders for affected sections. The skill does not refuse to run.

**Output artifact**: Research Dossier — a structured message (not a file) sent to the Team Lead containing:

```
RESEARCH DOSSIER: Investor Update Data
Period: [inferred from progress files or user-specified]

## Metrics & Milestones
- [Completed item]: [Evidence file path]. Status: [verified/inferred]
- ...

## In-Progress Work
- [Item]: [Current status]. [Evidence]
- ...

## Blockers & Risks
- [Blocker]: [Impact]. [Evidence]
- ...

## Technical Decisions
- [ADR/Decision]: [Summary]. [Rationale]
- ...

## Data Gaps
- [What's missing]: [Why it matters]. Confidence without this data: [H/M/L]
- ...

## Confidence Assessment
- Overall data completeness: [H/M/L]
- Areas with low confidence: [list]
```

**Quality gate (Gate 1)**: Team Lead reviews the dossier for completeness before passing to the Drafter. This is a lightweight check — does the dossier cover all roadmap categories? Are there major gaps? The Team Lead does NOT write content; they verify the research is sufficient to draft from.

#### Stage 2: Draft

**Agent**: Drafter

**Inputs**: Research Dossier (from Stage 1) + investor update template (embedded in SKILL.md) + prior investor updates (if they exist in `docs/investor-updates/`)

**Output artifact**: Draft Investor Update — written to the Drafter's progress file, containing:

1. The full investor update in the output format (see Output Artifact Format below)
2. A "Drafter Notes" appendix listing:
   - Assumptions made where data was incomplete
   - Choices made about framing (e.g., "Chose to lead with milestone X because...")
   - Questions for the skeptics

**Instructions to Drafter**:
- Write from the facts in the research dossier. Do not invent metrics, timelines, or achievements.
- Where data is incomplete, state the limitation explicitly in the update rather than filling in optimistic placeholders.
- Use the confidence levels from the research dossier to calibrate language strength (High confidence -> assertive language; Low confidence -> hedged language with caveats).
- Include the mandatory quality sections (Assumptions & Limitations, Confidence Levels, Falsification Triggers, External Validation Checkpoints) as defined in the business skill design guidelines.

#### Stage 3: Review (Dual-Skeptic)

**Agents**: Accuracy Skeptic + Narrative Skeptic (working in parallel)

Both skeptics receive the Draft Investor Update AND the Research Dossier (so they can cross-reference claims against evidence).

##### Accuracy Skeptic Checklist

The Accuracy Skeptic verifies:

1. **Every number has a source.** Every metric, count, percentage, or timeline in the update must trace back to a specific file in the research dossier. If a number cannot be traced, it is flagged.
2. **Milestone statuses are correct.** "Completed" items must match `complete` status in roadmap/progress files. "In progress" items must match actual progress evidence.
3. **No hallucinated achievements.** Cross-reference every claim against the project's actual file history. If the update says "we shipped X," the research dossier must show evidence of X.
4. **Timelines are honest.** If the update references timeframes ("over the past month," "ahead of schedule"), verify against actual dates in progress files.
5. **Blocker severity is accurate.** Blockers mentioned in the update should match the severity implied by the evidence. Understating a blocker is a rejection-worthy defect.
6. **Business skill quality checklist** (from design guidelines):
   - Are assumptions stated, not hidden?
   - Are confidence levels present and justified?
   - Are falsification triggers specific and actionable?
   - Does the output acknowledge what it doesn't know?
   - Are projections grounded in stated evidence, not optimism?

##### Narrative Skeptic Checklist

The Narrative Skeptic verifies:

1. **Spin detection.** Is the update unreasonably positive? Does it minimize real problems? Does it use vague language to obscure specifics? ("Making great progress" without saying what was actually done.)
2. **Omission detection.** Compare the research dossier to the update. Is anything significant from the dossier absent from the update? Deliberate omission of bad news is a rejection-worthy defect.
3. **Consistency with prior updates.** If prior updates exist in `docs/investor-updates/`, check: Are previously mentioned plans followed up on? Are changes in direction acknowledged? Does the tone shift inexplicably?
4. **Balanced framing.** The update should present both progress and challenges. An update with only good news is suspect. An update that buries challenges at the bottom is suspect.
5. **Audience appropriateness.** Is the update written for investors (strategic, outcome-focused) rather than engineers (implementation-detail-focused)?
6. **Business skill quality checklist** (from design guidelines):
   - Would a domain expert find the framing credible?
   - Are projections grounded in stated evidence, not optimism?

##### Review Verdicts

Each skeptic independently produces:

```
[ACCURACY|NARRATIVE] REVIEW: Investor Update Draft
Verdict: APPROVED / REJECTED

[If rejected:]
Issues:
1. [Specific issue]: [Why it's a problem]. [Evidence reference]. Fix: [What to do]
2. ...

[If approved:]
Notes: [Any minor observations]
```

**Gate 2 rule**: BOTH skeptics must approve. If either rejects, the draft returns to Stage 2b (Revise).

#### Stage 2b: Revise

**Agent**: Drafter

The Drafter receives the rejection feedback from one or both skeptics and produces a revised draft. The revision must address every blocking issue explicitly — the Drafter should note what changed and why in the Drafter Notes appendix.

The revised draft returns to Gate 2 (both skeptics review again). Maximum 3 revision cycles before escalation to the human operator.

#### Stage 4: Finalize

**Agent**: Team Lead

When both skeptics approve, the Team Lead:
1. Writes the final investor update to `docs/investor-updates/{date}-investor-update.md`
2. Writes a progress summary to `docs/progress/investor-update-summary.md`
3. Writes a cost summary to `docs/progress/draft-investor-update-{date}-cost-summary.md`
4. Outputs the final update to the user with instructions for review and distribution

## Output Artifact Format

The investor update follows a structured template:

```markdown
---
type: "investor-update"
period: "YYYY-MM-DD to YYYY-MM-DD"
generated: "YYYY-MM-DD"
confidence: "high|medium|low"
review_status: "approved"
approved_by:
  - accuracy-skeptic
  - narrative-skeptic
---

# Investor Update: {Period}

## Executive Summary

<!-- 2-3 sentences. The single most important thing an investor should know. -->

## Key Metrics

| Metric | Value | Period | Source | Confidence |
|--------|-------|--------|--------|------------|
| ... | ... | ... | ... | H/M/L |

## Milestones Completed

<!-- Bulleted list. Each milestone links to evidence (spec, progress file, etc.) -->

## Current Focus

<!-- What the team is actively working on. Status of each item. -->

## Challenges & Risks

<!-- Honest assessment. Each challenge includes: what it is, impact, mitigation plan. -->

## Team Update

<!-- Key hires, departures, role changes. Sourced from _user-data.md. -->
<!-- If no user data: "[Requires user input -- see docs/investor-updates/_user-data.md]" -->

## Financial Summary

<!-- MRR/ARR, burn rate, runway, key financial metrics. Sourced from _user-data.md. -->
<!-- If no user data: "[Requires user input -- see docs/investor-updates/_user-data.md]" -->

## Asks

<!-- What the company needs from investors: intros, advice, resources. Sourced from _user-data.md. -->
<!-- If no user data: "[Requires user input -- see docs/investor-updates/_user-data.md]" -->

## Outlook

<!-- Forward-looking. What's planned next. Hedged appropriately based on confidence. -->

---

## Assumptions & Limitations

<!-- Mandatory per business skill design guidelines. -->
<!-- What this update assumes to be true. What data was unavailable. -->

## Confidence Assessment

<!-- Mandatory per business skill design guidelines. -->
<!-- Per-section confidence levels with rationale. -->

| Section | Confidence | Rationale |
|---------|------------|-----------|
| Key Metrics | H/M/L | ... |
| Milestones | H/M/L | ... |
| Challenges | H/M/L | ... |
| Outlook | H/M/L | ... |

## Falsification Triggers

<!-- Mandatory per business skill design guidelines. -->
<!-- What evidence would change the conclusions in this update? -->

- If [condition], then [conclusion X] should be revised because [reason]
- ...

## External Validation Checkpoints

<!-- Mandatory per business skill design guidelines. -->
<!-- Where should a human domain expert validate this update before distribution? -->

- [ ] Verify [specific claim] with [data source or person]
- ...
```

## What Is New vs. Reusable

### Reusable from Existing Skills

| Component | Source | Adaptation Needed |
|-----------|--------|-------------------|
| YAML frontmatter format | All SKILL.md files | New fields: `type: investor-update` in output |
| Shared Principles section | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers |
| Communication Protocol section | plan-product/SKILL.md (authoritative) | Copied verbatim with shared markers; skeptic names adapted |
| Checkpoint Protocol | plan-product/SKILL.md | Phase enum changes: `research \| draft \| review \| revision \| complete` |
| Write Safety conventions | All SKILL.md files | Same pattern, different role names |
| Failure Recovery | All SKILL.md files | Same 3 patterns (unresponsive, deadlock, context exhaustion) |
| Lightweight Mode | All SKILL.md files | Same pattern: Researcher to sonnet, Drafter stays sonnet, Skeptics stay opus |
| Determine Mode with status/resume | All SKILL.md files | Same checkpoint-based resume pattern |
| Setup section (directory creation, stack detection, template reading) | All SKILL.md files | Adds `docs/investor-updates/` to directory list |

### New Patterns Introduced

| Pattern | Description | Why It Is Needed |
|---------|-------------|-----------------|
| **Pipeline handoffs** | Sequential stage execution with explicit artifacts between stages. Existing skills use parallel agents with message-passing. | The Pipeline collaboration pattern defined in the design guidelines. First concrete implementation. |
| **Dual-skeptic review** | Two skeptics with non-overlapping concerns review in parallel, and BOTH must approve. Existing skills have a single skeptic. | Business skill design guidelines require domain-specific skeptic specialization. Accuracy and narrative quality are independent failure modes. |
| **Research Dossier artifact** | A structured intermediate artifact (not a file) passed between stages. Existing skills share findings via messages. | Pipeline stages need a well-defined handoff format. The dossier is the "contract" between researcher and drafter. |
| **Evidence-traced claims** | Every factual claim in the output links to a source file. Existing skills verify against code/tests. | No ground truth exists for business documents. Evidence tracing is the substitute for test results. |
| **Mandatory quality sections** | Output includes Assumptions, Confidence Levels, Falsification Triggers, External Validation Checkpoints. | Business skill design guidelines mandate these for all non-engineering skills. First skill to implement them. |
| **Output directory** | `docs/investor-updates/` as a new output location. Existing skills write to `docs/specs/`, `docs/progress/`, `docs/architecture/`. | Investor updates are a new artifact type that don't fit existing directory categories. |
| **Prior-update consistency checking** | Narrative Skeptic checks new updates against prior ones for consistency. | Business continuity requirement. Investors notice when narratives shift without explanation. |

### How Pipeline Differs from Existing Orchestration

| Dimension | Existing (plan-product, build-product) | Pipeline (draft-investor-update) |
|-----------|---------------------------------------|--------------------------------|
| Agent concurrency | Researcher + Architect work in parallel | Sequential: Researcher finishes before Drafter starts |
| Skeptic timing | Skeptic reviews after all agents complete | Skeptics review after each draft; may trigger re-drafting |
| Skeptic count | 1 skeptic per skill | 2 skeptics, both must approve |
| Handoff mechanism | Messages between agents | Structured artifact (Research Dossier) between stages |
| Iteration pattern | Skeptic rejects -> agent revises -> re-review | Skeptic rejects -> specific stage re-executes -> re-review |
| Output type | Specs, code, architecture docs | Structured prose document |
| Quality verification | Code tests, schema validation | Evidence tracing, cross-referencing, consistency checks |

## Quality Without Ground Truth

This is the central design challenge. Engineering skills verify quality by running tests — the code either works or it doesn't. Business skills have no equivalent. An investor update can be grammatically correct, well-structured, and entirely misleading.

### The Problem

The "facts" in an investor update are project-internal. The researcher reads markdown files written by agents in previous sessions. These files may contain:
- **Optimistic progress notes** — agents describing their own work in favorable terms
- **Stale data** — progress files from sessions that were interrupted or superseded
- **Missing context** — work that happened but wasn't checkpointed
- **Circular evidence** — the investor update citing a progress file that was itself generated by an AI agent

There is no external oracle to verify against.

### Mitigation Strategy

The design addresses this through layered verification:

1. **Source attribution**: Every claim in the update must cite a specific file. This makes the evidence chain auditable by humans.

2. **Confidence grading**: The researcher grades each finding's confidence (High/Medium/Low) based on evidence quality. The drafter calibrates language accordingly. The skeptics reject unqualified certainty.

3. **Gap acknowledgment**: The update must explicitly state what data was unavailable, what assumptions were made, and where confidence is low. An update that claims 100% confidence is automatically suspect.

4. **Dual-skeptic specialization**: The Accuracy Skeptic catches factual errors (wrong numbers, false claims). The Narrative Skeptic catches framing errors (spin, omission, inconsistency). These are independent failure modes that require different expertise.

5. **External validation checkpoints**: The update includes a checklist of items that a human should verify before distribution. The skill structures judgment — it does not replace it.

6. **Falsification triggers**: Each major conclusion identifies what evidence would invalidate it. This forces the drafter to consider the conditions under which the update's narrative breaks down.

7. **Prior-update consistency**: The Narrative Skeptic checks whether the new update is consistent with prior updates. If the previous update said "X is our top priority" and the new update doesn't mention X, that's flagged.

### What This Cannot Prevent

- **Garbage in, garbage out**: If the project's progress files are misleading, the investor update will be misleading. The skill can verify internal consistency but cannot fact-check against reality.
- **Unknown unknowns**: The update can only report on work that was documented. Undocumented work is invisible.
- **Strategic judgment**: The skill cannot determine whether the right work is being prioritized. It reports what happened, not whether what happened was wise.

These limitations are stated in the Assumptions & Limitations section of every generated update, and in the External Validation Checkpoints.

## CI Validator Implications

### Existing Validators — Impact

| Validator | Impact | Changes Needed |
|-----------|--------|---------------|
| `skill-structure.sh` | Works as-is | None — the skill is multi-agent, so standard section checks apply (Setup, Write Safety, Checkpoint Protocol, Determine Mode, Lightweight Mode, Spawn the Team, Orchestration Flow, Failure Recovery, Shared Principles, Communication Protocol, Quality Gate or Critical Rules, Spawn Prompts) |
| `skill-shared-content.sh` | Works as-is | None — the skill will include `<!-- BEGIN SHARED: principles -->` and `<!-- BEGIN SHARED: communication-protocol -->` markers with content byte-identical to plan-product/SKILL.md (authoritative source). Skeptic names will differ (`accuracy-skeptic`, `narrative-skeptic`) but are normalized by the validator. |
| `spec-frontmatter.sh` | Not applicable | This validator checks `docs/specs/` files. The investor update output goes to `docs/investor-updates/`. No impact. |
| `roadmap-frontmatter.sh` | Not applicable | The skill does not modify roadmap files. |
| `progress-checkpoint.sh` | Works as-is | Checkpoint files follow the standard format with `team: "draft-investor-update"`. |

### New Validator Considerations

The `skill-shared-content.sh` normalize function currently handles three skeptic name pairs:

```
product-skeptic / Product Skeptic
quality-skeptic / Quality Skeptic
ops-skeptic / Ops Skeptic
```

The investor update skill introduces two new skeptic names: `accuracy-skeptic` / `Accuracy Skeptic` and `narrative-skeptic` / `Narrative Skeptic`. The normalize function must be extended to handle these:

```bash
-e 's/accuracy-skeptic/SKEPTIC_NAME/g' \
-e 's/narrative-skeptic/SKEPTIC_NAME/g' \
-e 's/Accuracy Skeptic/SKEPTIC_NAME/g' \
-e 's/Narrative Skeptic/SKEPTIC_NAME/g'
```

This is a small, additive change to an existing validator — not a new validator.

### New Output Directory

The skill writes final outputs to `docs/investor-updates/`. This directory should be:
1. Created by `/setup-project` if it doesn't exist (requires a small update to the setup-project SKILL.md's directory scaffold list)
2. Alternatively, created by the `/draft-investor-update` skill itself in its Setup section (following the pattern of existing skills that create missing directories)

Option 2 is preferred for now — the skill creates its own output directory. Adding it to setup-project can happen when more skills need similar output directories, avoiding premature generalization.

## SKILL.md Structure

The SKILL.md will follow the standard multi-agent format with all required sections:

```
---
name: draft-investor-update
description: >
  Draft an investor update from project data. Gathers metrics and milestones
  from the roadmap, progress files, and specs, then drafts, reviews, and
  refines a structured investor update through dual-skeptic validation.
argument-hint: "[--light] [status | <period> | (empty for current period)]"
---

# Investor Update Team Orchestration
(Team Lead instructions)

## Setup
(Directory creation, stack detection, read project state)

## Write Safety
(Standard pattern with role-scoped files)

## Checkpoint Protocol
(Standard pattern with phases: research | draft | review | revision | complete)

## Determine Mode
(status, empty/resume, period specification)

## Lightweight Mode
(Researcher -> sonnet; Drafter stays sonnet; Skeptics stay opus)

## Spawn the Team
### Researcher (opus)
### Drafter (sonnet)
### Accuracy Skeptic (opus)
### Narrative Skeptic (opus)

## Orchestration Flow
(Pipeline stages 1-4 as described above)

## Quality Gate
(Dual-skeptic: both must approve)

## Failure Recovery
(Standard 3 patterns)

## Shared Principles
(Copied from plan-product/SKILL.md with shared markers)

## Communication Protocol
(Copied from plan-product/SKILL.md with shared markers)

## Teammate Spawn Prompts
(Detailed prompts for each role)
```

## Integration Points

### With Existing Skills

- **plan-product**: The investor update reads the same roadmap and spec artifacts that plan-product creates. No write conflicts — draft-investor-update is read-only with respect to these files.
- **build-product**: The investor update reads progress files written by build-product sessions. Again, read-only.
- **review-quality**: The investor update may reference quality findings from review-quality sessions. Read-only.
- **setup-project**: Does not currently create `docs/investor-updates/`. The draft-investor-update skill creates its own output directory in Setup.

### With Plugin System

- Registered in `plugin.json` alongside existing skills
- Lives at `plugins/conclave/skills/draft-investor-update/SKILL.md`
- Uses the same YAML frontmatter format

### New Artifacts

| Artifact | Location | Created By |
|----------|----------|-----------|
| Investor updates | `docs/investor-updates/{date}-investor-update.md` | Team Lead (final output) |
| Checkpoint files | `docs/progress/investor-update-{role}.md` | Each agent |
| Session summary | `docs/progress/investor-update-summary.md` | Team Lead |
| Cost summary | `docs/progress/draft-investor-update-{date}-cost-summary.md` | Team Lead |

## Arguments

| Argument | Effect |
|----------|--------|
| (empty) | Research current period (inferred from latest progress files), resume if in-progress session exists |
| `status` | Report on in-progress session without spawning agents |
| `<period>` | Research a specific period (e.g., "2026-02-01 to 2026-02-15") |
| `--light` | Researcher uses sonnet instead of opus. Skeptics remain opus. |

## User Data Input

Per skeptic review, the skill needs a mechanism for user-provided data that cannot be auto-detected from project files (financial metrics, team updates, investor asks).

### Mechanism: Template File

A template file at `docs/investor-updates/_user-data.md` that the user populates before running the skill. The Researcher reads this file alongside project artifacts.

**Why a template file (over alternatives)**:
- **Arguments** (`--mrr 50000 --runway 14`): Too fragile for structured data, makes `argument-hint` unwieldy
- **Interactive prompts**: Not well-supported in the agent spawning model — subagents cannot easily prompt the user mid-pipeline
- **Template file**: Persistent, version-controlled, editable. User fills it once and updates each period. Graceful degradation when missing.

### Template Format

```markdown
# Investor Update: User-Provided Data

> Fill in the sections below before running `/draft-investor-update`.
> Delete placeholder text and replace with your data.
> Leave sections blank if not applicable -- the update will show "[Requires user input]".

## Financial Metrics

- MRR/ARR:
- Burn rate:
- Runway (months):
- Notable financial events:

## Team Update

- Current headcount:
- Key hires:
- Key departures:
- Open roles:

## Asks

- Introductions needed:
- Advice needed:
- Resources needed:
- Other asks:

## Additional Context

<!-- Anything else investors should know that isn't captured in project files. -->
```

### Graceful Degradation

- **File missing**: Researcher notes in Data Gaps. Drafter uses "[Requires user input -- see docs/investor-updates/_user-data.md]" for Team Update, Financial Summary, and Asks sections.
- **File partially filled**: Researcher extracts available data. Missing fields get placeholders.
- **File empty/template-only**: Treated same as missing.

## First-Run Behavior

On a project's first investor update:

1. **No prior updates exist**: Narrative Skeptic skips prior-update consistency checks. No error, no warning — this is expected behavior.
2. **No `_user-data.md` exists**: Researcher flags all user-data sections as gaps. Output includes placeholders. The skill also outputs the template to `docs/investor-updates/_user-data.md` so the user has it for next time.
3. **No `docs/investor-updates/` directory exists**: Skill creates it in Setup (standard pattern).

## Non-Goals

1. **No real-time data gathering.** The skill reads project artifacts on disk. It does not query APIs, dashboards, or external services.
2. **No email/distribution integration.** The skill produces a markdown file. Distribution is the user's responsibility.
3. **No financial modeling.** The update reports metrics; it does not forecast revenue or calculate burn rate.
4. **No template customization at runtime.** The output format is fixed in the SKILL.md. Users who need a different format must modify the SKILL.md.
5. **No automatic period detection from git history.** Period is inferred from progress file timestamps or user-specified. Git log analysis is out of scope.
