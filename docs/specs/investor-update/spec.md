---
title: "Investor Update Skill (/draft-investor-update)"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "product-skeptic"
created: "2026-02-19"
updated: "2026-02-19"
---

# Investor Update (`/draft-investor-update`) Specification

## Summary

A multi-agent Pipeline skill that drafts investor updates by gathering project data, composing a structured narrative, and validating accuracy and tone through dual-skeptic review. This is the first business skill in the conclave framework -- it validates the Pipeline collaboration pattern, the dual-skeptic review model, and the "quality without ground truth" requirements defined in the business skill design guidelines.

## Problem

Startup founders send periodic investor updates (monthly or quarterly) summarizing progress, challenges, metrics, and asks. Writing these updates is time-consuming and error-prone:

- **Data gathering is manual**: Progress is scattered across roadmap files, progress checkpoints, specs, and architecture docs. Assembling a complete picture requires reading dozens of files.
- **Accuracy is hard to verify**: Claims about milestones, timelines, and progress must be cross-referenced against actual project artifacts. Manual verification is tedious and often skipped.
- **Narrative bias is natural**: Founders tend toward optimistic framing. Challenges get minimized. Metrics get cherry-picked. Investors notice.
- **Consistency erodes over time**: Each update should follow up on previously mentioned plans and honestly address changes in direction. Without systematic tracking, narrative threads get dropped.

Evidence:
- A conclave-managed project generates rich, structured data in `docs/roadmap/`, `docs/progress/`, `docs/specs/`, and `docs/architecture/` -- exactly the data needed for an investor update.
- The business skill design guidelines (`docs/architecture/business-skill-design-guidelines.md`) define the Pipeline pattern, dual-skeptic assignments, and quality-without-ground-truth requirements specifically for this class of skill.
- Review Cycle 2 and Review Cycle 3 both recommended P3-22 as the highest strategic value next item: it validates the entire business-skill design framework, advances the skill count toward the P2-07 threshold (5/8), and creates the first business skill needed for P2-08.

## Solution

### Architecture

This is a **multi-agent Pipeline skill** -- sequential handoffs with quality gates between stages. Unlike the existing engineering skills (which use parallel work with a single skeptic gate), `/draft-investor-update` uses:

1. **Sequential pipeline stages** (Research -> Draft -> Review -> Revise -> Finalize)
2. **Dual skeptics** with non-overlapping concerns (Accuracy + Narrative)
3. **Evidence-traced claims** as a substitute for code-test verification
4. **Mandatory business quality sections** (Assumptions, Confidence, Falsification Triggers, External Validation)

See [System Design](../../architecture/investor-update-system-design.md) for the full architecture.

### Agent Team

| Role | Name | Model | Responsibility |
|------|------|-------|---------------|
| Team Lead | (invoking agent) | opus | Orchestrate pipeline, manage handoffs, write final output |
| Researcher | `researcher` | opus | Gather metrics, milestones, blockers from project artifacts and user data |
| Drafter | `drafter` | sonnet | Compose and revise the investor update from research findings |
| Accuracy Skeptic | `accuracy-skeptic` | opus | Verify numbers, claims, milestone status against evidence |
| Narrative Skeptic | `narrative-skeptic` | opus | Detect spin, omissions, inconsistency with prior updates |

**Drafter model note**: The Drafter uses Sonnet for cost efficiency. If revision cycles consistently fail (Drafter cannot produce prose that satisfies both skeptics within 2 cycles), the Team Lead should consider upgrading the Drafter to Opus for the remaining attempts. This is a known risk -- "write a compelling investor narrative from structured findings" is a harder task than "write code from a spec."

### Pipeline Stages

#### Stage 1: Research

**Agent**: Researcher

**Reads**:
- `docs/roadmap/_index.md` and individual roadmap files -- completed milestones, current priorities, blockers
- `docs/progress/` -- implementation status, session summaries, quantitative outcomes
- `docs/specs/` -- what was planned vs. delivered
- `docs/architecture/` -- significant technical decisions
- `docs/investor-updates/_user-data.md` -- user-provided financial, team, and strategic data (see User Data Input below)
- `docs/investor-updates/` -- prior investor updates (for period context and consistency checking)
- Project root files (README, CLAUDE.md) -- project context

**Output**: Research Dossier (structured message to Team Lead), containing:
- Metrics & Milestones (with evidence file paths and verified/inferred status)
- In-Progress Work (current status with evidence)
- Blockers & Risks (impact assessment with evidence)
- Technical Decisions (ADR summaries)
- User-Provided Data (financial, team, asks -- or gaps if `_user-data.md` is missing/incomplete)
- Data Gaps (what's missing, confidence without the data)
- Confidence Assessment (overall completeness, low-confidence areas)

**Temporal scoping**: The Researcher uses the period specified by the user (via `$ARGUMENTS`) or infers it from the most recent progress file timestamps. YAML frontmatter `updated` fields are the primary timestamp source. The Researcher should validate timestamp formats and flag inconsistencies in the Data Gaps section.

**Gate 1**: Team Lead reviews the dossier for completeness -- does it cover all roadmap categories? Are there major gaps? The Team Lead does NOT write content; they verify the research is sufficient to draft from.

#### Stage 2: Draft

**Agent**: Drafter

**Inputs**: Research Dossier + investor update template (embedded in SKILL.md) + prior investor updates (if they exist)

**Instructions**:
- Write from the facts in the research dossier. Do not invent metrics, timelines, or achievements.
- Where data is incomplete, state the limitation explicitly. Use "[Requires user input]" for sections that depend on data from `_user-data.md` that was not provided.
- Calibrate language strength to confidence levels (High -> assertive; Medium -> hedged; Low -> explicitly uncertain).
- Include ALL output sections, including Team Update, Financial Summary, and Asks (with "[Requires user input]" placeholders when data is unavailable).
- Include mandatory business quality sections (Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints).
- Append Drafter Notes listing assumptions made, framing choices, and questions for skeptics.

**Output**: Draft investor update written to Drafter's progress file.

#### Stage 3: Review (Dual-Skeptic, Parallel)

**Agents**: Accuracy Skeptic + Narrative Skeptic (working in parallel)

Both skeptics receive the Draft Investor Update AND the Research Dossier.

**Accuracy Skeptic checklist**:
1. Every number has a source (traceable to a specific file)
2. Milestone statuses match roadmap/progress evidence
3. No hallucinated achievements
4. Timelines are honest (verified against actual dates)
5. Blocker severity is accurate
6. Business skill quality checklist (assumptions stated, confidence justified, falsification triggers specific, unknowns acknowledged, projections grounded in evidence)

**Narrative Skeptic checklist**:
1. Spin detection (unreasonably positive? minimizes problems? vague language?)
2. Omission detection (significant dossier findings absent from update?)
3. Consistency with prior updates (plans followed up on? direction changes acknowledged?)
4. Balanced framing (both progress and challenges represented?)
5. Audience appropriateness (strategic/outcome-focused, not implementation-detail-focused?)
6. Business skill quality checklist (framing credible to domain expert? projections grounded?)

**Note**: Items 6 on both checklists intentionally overlap -- both skeptics verify quality from their respective angles.

**Gate 2**: BOTH skeptics must approve. If either rejects, the draft returns to Stage 2b (Revise).

**First-run behavior**: On a project's first investor update, the Narrative Skeptic skips consistency-with-prior-updates checks (there are no prior updates). This is expected and should not affect the verdict.

#### Stage 2b: Revise

**Agent**: Drafter

Receives rejection feedback from one or both skeptics. Produces a revised draft addressing every blocking issue. Notes what changed and why in Drafter Notes. Returns to Gate 2. Maximum 3 revision cycles before escalation to the human operator.

#### Stage 4: Finalize

**Agent**: Team Lead

When both skeptics approve:
1. Write final investor update to `docs/investor-updates/{date}-investor-update.md`
2. Write progress summary to `docs/progress/investor-update-summary.md`
3. Write cost summary to `docs/progress/draft-investor-update-{date}-cost-summary.md`
4. Output the final update to the user with review and distribution instructions

### User Data Input

Financial metrics, team updates, and investor asks cannot be auto-detected from project artifacts. Users provide this data via a template file:

**Location**: `docs/investor-updates/_user-data.md`

**Template format**:

```markdown
---
period: "YYYY-MM-DD to YYYY-MM-DD"
updated: "YYYY-MM-DD"
---

# Investor Update: User-Provided Data

## Financial Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| MRR | | |
| ARR | | |
| Burn Rate | | |
| Runway (months) | | |
| Revenue | | |

## Team Update

<!-- Headcount changes, key hires, departures, org changes -->

## Asks

<!-- What do you need from investors? Introductions, advice, hiring referrals, etc. -->

## Additional Context

<!-- Anything else investors should know that isn't captured in project files -->
```

**Behavior**:
- If `_user-data.md` exists and is populated: Researcher reads it alongside project data. Financial, team, and asks sections are populated in the update.
- If `_user-data.md` exists but is partially populated: Populated fields are used; empty fields get "[Requires user input]" placeholders.
- If `_user-data.md` does not exist: All user-data-dependent sections get "[Requires user input -- create docs/investor-updates/_user-data.md to provide this data]" placeholders. The update is still produced with all project-derived sections populated.
- The skill creates the `_user-data.md` template file if the directory exists but the file does not (first-run convenience).

### Output Artifact Format

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

## Milestones Completed

<!-- Bulleted list. Each milestone links to evidence (spec, progress file, etc.) -->

## Current Focus

<!-- What the team is actively working on. Status of each item. -->

## Challenges & Risks

<!-- Honest assessment. Each challenge includes: what it is, impact, mitigation plan. -->

## Team Update

<!-- From _user-data.md or "[Requires user input]" -->

## Financial Summary

<!-- From _user-data.md or "[Requires user input]" -->

## Asks

<!-- From _user-data.md or "[Requires user input]" -->

## Outlook

<!-- Forward-looking. What's planned next. Hedged appropriately based on confidence. -->

---

## Assumptions & Limitations

<!-- What this update assumes to be true. What data was unavailable. -->

## Confidence Assessment

| Section | Confidence | Rationale |
|---------|------------|-----------|

## Falsification Triggers

- If [condition], then [conclusion X] should be revised because [reason]

## External Validation Checkpoints

- [ ] Verify [specific claim] with [data source or person]
```

### Arguments

| Argument | Effect |
|----------|--------|
| (empty) | Research current period (inferred from latest progress files). Resume if in-progress session exists. |
| `status` | Report on in-progress session without spawning agents. |
| `<period>` | Research a specific period (e.g., "2026-02" or "2026-01-15 to 2026-02-15"). |
| `--light` | Researcher uses Sonnet instead of Opus. Skeptics remain Opus. |

### CI Validator Impact

| Validator | Impact | Changes Needed |
|-----------|--------|---------------|
| `skill-structure.sh` | Works as-is | None -- standard multi-agent section checks apply |
| `skill-shared-content.sh` | Minor extension | Extend normalize function to handle `accuracy-skeptic`/`Accuracy Skeptic` and `narrative-skeptic`/`Narrative Skeptic` |
| `spec-frontmatter.sh` | Not applicable | Output goes to `docs/investor-updates/`, not `docs/specs/` |
| `roadmap-frontmatter.sh` | Not applicable | Skill does not modify roadmap files |
| `progress-checkpoint.sh` | Works as-is | Checkpoint files use standard format with `team: "draft-investor-update"` |

### New Patterns This Skill Introduces

1. **Pipeline handoffs** -- sequential stage execution with structured artifacts between stages
2. **Dual-skeptic parallel review** -- two skeptics with non-overlapping concerns, both must approve
3. **Research Dossier artifact** -- structured intermediate artifact passed between pipeline stages
4. **Evidence-traced claims** -- every factual claim links to a source file
5. **Mandatory business quality sections** -- Assumptions, Confidence, Falsification Triggers, External Validation
6. **Output directory** -- `docs/investor-updates/` as a new artifact location
7. **Prior-update consistency checking** -- Narrative Skeptic checks against prior updates
8. **User data template** -- `_user-data.md` for information the skill cannot auto-detect

### Pathfinder Role

This is the first business skill in the conclave framework. It is explicitly a pathfinder -- lessons learned will inform:
- Whether the business-skill design guidelines need revision
- How the dual-skeptic pattern works in practice
- Whether the Pipeline consensus pattern needs adjustment
- What new shared content patterns emerge for P2-07 (Universal Shared Principles)
- Progress toward the P2-08 prerequisite (1/2 required business skills)

## Constraints

1. **All standard investor update sections always present.** User-data sections show "[Requires user input]" when data is unavailable. No silently missing sections.
2. **Every factual claim must be evidence-traced.** The Accuracy Skeptic rejects any claim without a source file reference.
3. **Both skeptics must approve.** No shortcutting the dual-skeptic gate.
4. **Maximum 3 revision cycles.** After 3 rejections, escalate to human operator.
5. **No data fabrication.** Where data is missing, the update states the gap explicitly. Never fill gaps with plausible-sounding numbers.
6. **No real-time data gathering.** The skill reads project artifacts on disk. No API calls, dashboards, or external services.
7. **No email/distribution integration.** Output is a markdown file. Distribution is the user's responsibility.
8. **No financial modeling.** The update reports metrics; it does not forecast revenue or calculate burn rate.
9. **Shared content must use shared markers.** Shared Principles and Communication Protocol sections use `<!-- BEGIN SHARED -->` markers and are byte-identical to the authoritative source (plan-product/SKILL.md), with skeptic name normalization.

## Out of Scope

- Template customization at runtime (users modify SKILL.md for different formats)
- Automatic period detection from git history
- Integration with email, Slack, or other distribution channels
- Financial forecasting or revenue modeling
- Comparison with industry benchmarks
- Multi-project aggregation (one project per update)

## Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | **Create** -- New multi-agent Pipeline skill definition |
| `scripts/validators/skill-shared-content.sh` | **Modify** -- Extend normalize function for `accuracy-skeptic` and `narrative-skeptic` |

## Success Criteria

1. Running `/draft-investor-update` on a conclave-managed project produces a complete investor update with all sections populated (project-derived) or marked "[Requires user input]" (user-data-dependent).
2. Every factual claim in the generated update traces to a specific source file via the evidence-tracing mechanism.
3. The Accuracy Skeptic verifies all numbers, milestones, and timelines against project artifacts before approval.
4. The Narrative Skeptic checks for spin, omissions, and prior-update consistency before approval.
5. Both skeptics must approve before the update is finalized.
6. Running the skill with `--light` uses Sonnet for the Researcher while keeping both Skeptics at Opus.
7. Running the skill with `status` reports session progress without spawning agents.
8. Running the skill with a period argument scopes the research to that time range.
9. The skill creates `docs/investor-updates/` and `_user-data.md` template if they don't exist (first-run setup).
10. The skill reads and integrates data from `docs/investor-updates/_user-data.md` when present.
11. The output includes all mandatory business quality sections: Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints.
12. The CI validator passes for the new SKILL.md (shared content drift check with skeptic name normalization).
13. On first run (no prior updates), the skill completes successfully with the Narrative Skeptic skipping consistency checks.

## Architecture References

- [System Design: Investor Update](../../architecture/investor-update-system-design.md)
- [Business Skill Design Guidelines](../../architecture/business-skill-design-guidelines.md)
