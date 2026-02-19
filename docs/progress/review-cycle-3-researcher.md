---
feature: "review-cycle-3"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed research on P3-22 (Investor Update Skill) as next feature candidate"
updated: "2026-02-19"
---

# Research Findings: P3-22 Investor Update Skill (`/draft-investor-update`)

## Summary

P3-22 remains the correct next feature. The recommendation from Review Cycle 2 is still valid -- no new items were added, no blockers resolved for the deferred P2 items, and P3-22's strategic rationale (simplest business skill pathfinder) is unchanged. This document provides the deep research needed to spec P3-22: the problem space, data sources, skill architecture, framework pattern analysis, risks, and open questions.

---

## 1. Validation: Is P3-22 Still the Right Next Feature?

### What Changed Since Cycle 2

| Item | Cycle 2 Status | Current Status | Changed? |
|------|---------------|----------------|----------|
| P3-02 (Onboarding Wizard) | Selected as next | **Complete** (implemented, merged) | Yes -- done |
| P2-02 (Skill Composability) | Blocked (no invocation mechanism) | Still blocked | No |
| P2-07 (Universal Shared Principles) | Premature (3/8 skills) | Now 4/8 skills (setup-project added) | Marginal -- still well below threshold |
| P2-08 (Plugin Organization) | Deferred (0/2 business skills) | Still 0 business skills | No |
| P3-22 (Investor Update) | Selected as business pathfinder | Not started | No |
| New roadmap items | N/A | None added | No |

**Assessment (Confidence: HIGH)**: Nothing has changed that would alter the P3-22 recommendation. The only change is P3-02's completion, which was the prerequisite for starting P3-22. The skill count increased from 3 to 4, but this does not change P2-07's prematurity (8-skill threshold per ADR-002) or P2-08's deferral (0 business skills still). P3-22 is unblocked and remains the highest strategic value item.

### Why P3-22 Over Other Candidates

The Cycle 2 debate was P3-10 (`/plan-sales`, Collaborative Analysis pattern) vs. P3-22 (`/draft-investor-update`, Pipeline pattern). The architect recommended P3-22, the researcher recommended P3-10. The skeptic noted the architect's argument was stronger on output verifiability.

**I now concur with the P3-22 recommendation.** After deeper analysis of both candidates:

1. **P3-22's output is more constrained and verifiable.** An investor update has a well-known structure. A sales plan is fuzzier -- there's no "standard sales plan format" the way there is a standard investor update structure.
2. **P3-22 primarily reads existing project data.** It synthesizes from `docs/roadmap/`, `docs/progress/`, `docs/specs/`, and `docs/architecture/`. A sales plan requires external market data, competitive intelligence, and pricing strategy that may not exist in the project.
3. **Pipeline is the simplest new consensus pattern to implement.** It's closest to the existing plan-product workflow (linear with quality gates), whereas Collaborative Analysis is a genuinely new pattern (parallel work with cross-referencing).
4. **Self-dogfooding opportunity.** We can immediately test `/draft-investor-update` on this project.

---

## 2. Problem Space: What Is an Investor Update?

### Standard Investor Update Structure

A startup investor update is a periodic communication (typically monthly or quarterly) from founders to investors. It follows a well-established format:

| Section | Purpose | Data Source in Conclave Project |
|---------|---------|-------------------------------|
| **TL;DR / Executive Summary** | 2-3 sentence overview of period | Synthesized from all sections |
| **Key Metrics / KPIs** | Quantitative progress indicators | User-provided or extracted from project data |
| **Highlights / Wins** | What went well this period | `docs/progress/` (completed features), `docs/roadmap/` (status changes) |
| **Lowlights / Challenges** | What didn't go well, what's hard | `docs/progress/` (blocked items, failed attempts), `docs/roadmap/` (stalled items) |
| **Product Update** | What was built, shipped, planned | `docs/roadmap/` (status changes), `docs/specs/` (new specs), `docs/progress/` (implementation summaries) |
| **Team Update** | Hiring, departures, org changes | No automatic data source -- requires user input |
| **Financial Update** | Burn, runway, revenue if applicable | No automatic data source -- requires user input |
| **Asks** | What the founder needs from investors | No automatic data source -- requires user input |
| **Looking Ahead** | Goals and priorities for next period | `docs/roadmap/` (upcoming items by priority) |

### Data Sources Available in a Conclave-Managed Project

**Rich, structured data (can be read automatically):**

1. **`docs/roadmap/_index.md`** -- Complete backlog with priorities, statuses, effort estimates. Shows what moved from not_started to complete, what's blocked, what's upcoming. This is the primary data source for product progress.

2. **`docs/roadmap/P*-*.md`** -- Individual roadmap item files with problem statements, solutions, success criteria. Where they exist, these provide detail on what was built and why.

3. **`docs/progress/*-summary.md`** -- End-of-session summaries for each feature. Contain what was accomplished, what remains, blockers, and completion status. There are currently 10+ summary files spanning the project's history.

4. **`docs/specs/*/spec.md`** -- Feature specifications. Show what was designed and the scope of each feature.

5. **`docs/architecture/*.md`** -- ADRs and design documents. Show architectural decisions and their rationale.

6. **`docs/progress/*-cost-summary.md`** -- Cost summaries for each skill invocation. Provide data on resource consumption (agent costs).

7. **`CLAUDE.md`** -- Project conventions. Context for understanding the project.

**Data that requires user input (no automatic source):**

- Financial metrics (revenue, burn, runway, MRR, ARR)
- Team updates (headcount, hiring, departures)
- Customer/user metrics (unless tracked in project files)
- Fundraising status
- Specific asks for investors
- Market/competitive context

### Key Challenges for AI-Generated Investor Updates

1. **Accuracy risk is the highest priority concern.** An investor update must contain accurate numbers and claims. AI hallucination of metrics or milestone completion would be severely damaging to founder credibility. The Accuracy Skeptic role is critical.

2. **Spin detection / narrative honesty.** AI models tend toward positive framing. Investor updates must be honest about challenges. The Narrative Skeptic must specifically check that lowlights are not minimized, that metrics are not cherry-picked, and that the overall narrative is consistent with the data.

3. **Completeness vs. brevity.** Investors want concise updates (1-2 pages). The skill must synthesize, not dump. Reading all progress files and producing a 10-page update would be counterproductive.

4. **User-provided data integration.** The skill cannot generate financial metrics or team updates from project data alone. It must accept user-provided data (via arguments or interactive prompts) and integrate it with automatically-gathered project data.

5. **Consistency with prior updates.** The Narrative Skeptic's mandate includes "consistency with prior updates." This implies the skill should read previous investor updates (if they exist) to ensure narrative continuity. This is a design decision: where are prior updates stored?

6. **Temporal scoping.** The skill must know what period the update covers. It needs to distinguish "what happened this month" from "what existed before." This means reading roadmap item `updated` timestamps, progress file dates, and git history (or timestamps in YAML frontmatter).

---

## 3. Framework Pattern Analysis

### Existing SKILL.md Patterns

I read all 4 existing SKILL.md files. Here is what's reusable vs. new:

#### Reusable from Existing Skills

| Pattern | Where It Exists | How P3-22 Would Use It |
|---------|----------------|----------------------|
| **YAML frontmatter** | All 4 skills | Same format: `name`, `description`, `argument-hint` |
| **Setup section** (dir creation, stack detection) | All 3 multi-agent skills | P3-22 does not need stack detection or dir creation (those are engineering concerns). It needs to read existing docs/ content. Simpler setup. |
| **Write Safety** (role-scoped files) | All 3 multi-agent skills | Same pattern: each agent writes to `docs/progress/{feature}-{role}.md` |
| **Checkpoint Protocol** | All 3 multi-agent skills | Same protocol, same file format |
| **Determine Mode** (`$ARGUMENTS` parsing) | All 4 skills | P3-22 needs its own modes (see below) |
| **Spawn the Team** section | 3 multi-agent skills | P3-22 needs different roles (see below) |
| **Orchestration Flow** | 3 multi-agent skills | P3-22 uses Pipeline pattern -- sequential handoffs |
| **Quality Gate** (Skeptic approval) | 3 multi-agent skills | P3-22 has TWO skeptics (Accuracy + Narrative) |
| **Failure Recovery** | 3 multi-agent skills | Identical pattern: re-spawn, deadlock escalation, context exhaustion |
| **Shared Principles** | All 3 multi-agent skills (synchronized via P2-05) | Same shared content block |
| **Communication Protocol** | All 3 multi-agent skills (synchronized via P2-05) | Same shared content block |
| **Lightweight Mode** (`--light`) | 3 multi-agent skills | P3-22 should support this: use Sonnet for Researcher, keep Skeptics as Opus |

#### New for P3-22 (Not in Any Existing Skill)

| Pattern | Description | Design Decision Needed |
|---------|-------------|----------------------|
| **Multi-Skeptic with distinct scopes** | Two skeptics with non-overlapping concerns (Accuracy vs. Narrative). Existing skills have one skeptic. | How do they coordinate? Sequential review? Parallel review with separate verdicts? |
| **Pipeline consensus pattern** | Sequential handoffs with quality gates between stages. Existing skills use parallel-then-review. | Define the stages, handoff artifacts, and gate criteria explicitly. |
| **User data integration** | Accepting financial/team data from the user that cannot be auto-detected. | Via arguments? Interactive prompts? A pre-populated template file? |
| **Business output requirements** | Assumptions section, confidence levels, falsification triggers, external validation checkpoints (per business-skill-design-guidelines.md). | Must be woven into the output format and enforced by skeptics. |
| **Temporal scoping** | Determining what "this period" means and filtering project data accordingly. | Period parameter? Date range? "Since last update"? |
| **Output artifact format** | Investor updates have a specific format that differs from specs, progress files, or ADRs. | Define a new output template. Where does it get saved? `docs/updates/`? |

### Pipeline Pattern Design for `/draft-investor-update`

Per the business-skill design guidelines, the Pipeline pattern is: Research -> Draft -> Review -> Revise -> Final validation.

**Proposed P3-22 Pipeline Stages:**

```
Stage 1: RESEARCH (Data Gatherer agent)
  Read docs/roadmap/, docs/progress/, docs/specs/, docs/architecture/
  Read prior investor updates (if any exist)
  Read user-provided data (financial, team, asks)
  Output: Structured research brief with all data points, timestamped

Stage 2: DRAFT (Writer agent)
  Receive research brief
  Draft the investor update in standard format
  Include all mandatory business output sections (assumptions, confidence, etc.)
  Output: Draft investor update

Stage 3: REVIEW (Accuracy Skeptic + Narrative Skeptic)
  Both skeptics review the draft
  Accuracy Skeptic: verify every number, claim, milestone against source data
  Narrative Skeptic: check for spin, omissions, consistency with prior updates
  Output: Verdicts (APPROVED/REJECTED with specific feedback)

Stage 4: REVISE (Writer agent)
  Address all skeptic feedback
  Output: Revised draft

Stage 5: FINAL VALIDATION (Both Skeptics)
  Re-review revised draft
  Both must approve for the update to be published
  Output: Final approved investor update
```

### Agent Team Composition

| Role | Model | Responsibility |
|------|-------|---------------|
| **Team Lead** | (the orchestrator) | Pipeline coordination, user interaction, final artifact assembly |
| **Data Gatherer** (Researcher) | Opus | Read project data, synthesize research brief |
| **Writer** (Drafter) | Sonnet | Draft and revise the investor update |
| **Accuracy Skeptic** | Opus | Verify numbers, claims, milestone completeness |
| **Narrative Skeptic** | Opus | Check spin, omissions, narrative consistency |

**Cost note**: 3 Opus agents + 1 Sonnet agent. This is comparable to existing skills. The `--light` flag could downgrade the Data Gatherer to Sonnet while keeping both Skeptics at Opus (skeptics are never downgraded per existing precedent).

---

## 4. Risks and Open Questions

### Risks

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | **Accuracy hallucination** -- AI fabricates metrics or claims not in the source data | HIGH | Accuracy Skeptic explicitly cross-references every claim against source files. Research brief includes source citations. |
| 2 | **Insufficient user data** -- User doesn't provide financial/team data, resulting in an incomplete update | MEDIUM | Skill should clearly communicate what data it needs. Provide a template or checklist. Gracefully degrade (produce update with "[TBD]" sections) rather than fabricate. |
| 3 | **Temporal scoping ambiguity** -- Unclear what period the update covers, leading to inclusion of stale data | MEDIUM | Require explicit period parameter (e.g., `--period 2026-02` or `--since 2026-01-15`). Use YAML frontmatter `updated` timestamps to filter. |
| 4 | **First business skill friction** -- Unexpected framework issues when building a non-engineering skill | MEDIUM | This is expected. The whole point of a pathfinder is to discover these issues. Budget extra time for iteration. |
| 5 | **Multi-Skeptic coordination** -- Two skeptics may produce conflicting feedback | LOW | Both skeptics review the same draft but from non-overlapping scopes. Writer addresses all feedback from both. If they conflict (rare given non-overlapping scopes), the Team Lead adjudicates. |
| 6 | **No roadmap file exists for P3-22** -- Must be created as part of the spec cycle | LOW | Standard operating procedure. Create the roadmap file during this cycle. |
| 7 | **Prior update consistency** -- No storage location defined for prior updates | LOW | Define a convention: `docs/updates/` directory. First run has no prior to compare against. |
| 8 | **Business output requirements add bulk** -- Assumptions, confidence levels, falsification triggers may make the update too long | LOW | These can be in a separate "appendix" or "methodology" section, not in the main update body. Investors see the clean update; the appendix satisfies the framework requirements. |

### Open Questions for the Spec

1. **User data input mechanism**: How does the user provide financial/team data? Options:
   - (a) Via `$ARGUMENTS` (e.g., `--mrr 50000 --runway 14`)
   - (b) Via an interactive prompt at the start of the skill
   - (c) Via a pre-populated template file the user fills in before running the skill (e.g., `docs/updates/_data.md`)
   - (d) Via a combination: auto-detect what exists, prompt for what's missing

2. **Output location**: Where does the final investor update get saved?
   - (a) `docs/updates/{date}-investor-update.md` (new directory)
   - (b) `docs/progress/investor-update-{date}.md` (reuse existing directory)
   - (c) Console output only (user copies where they want)

3. **Period specification**: How does the user specify what time period the update covers?
   - (a) Explicit argument: `--period 2026-02` or `--from 2026-01-15 --to 2026-02-15`
   - (b) Auto-detect: "since last investor update" or "since last month"
   - (c) Required argument: skill refuses to run without a period

4. **Prior update consistency checking**: Should the skill read prior updates to check narrative consistency?
   - (a) Yes -- read all files in `docs/updates/` and feed to Narrative Skeptic
   - (b) Only if prior updates exist -- graceful degradation on first run
   - (c) No -- too complex for v1; add in a future iteration

5. **Mandatory vs. optional sections**: Should the skill produce ALL sections (TL;DR, metrics, highlights, lowlights, product, team, financial, asks, outlook) or only the ones where data is available?
   - The recommendation is to produce all sections, marking user-data-dependent sections as "[Requires input]" when data is not provided, so the user can see what's missing and fill it in.

6. **Multi-Skeptic review flow**: Do the two skeptics review sequentially or in parallel?
   - Recommendation: Parallel review. Both skeptics receive the draft simultaneously, review from their own scope, and return independent verdicts. The Writer then addresses all feedback. This is more time-efficient.

7. **What shared content needs to be synchronized?** P3-22 will include the same Shared Principles and Communication Protocol blocks as the other skills (per P2-05's shared marker system). The CI drift validator will need to validate this new skill.

---

## 5. Relationship to Business-Skill Design Guidelines

The guidelines at `docs/architecture/business-skill-design-guidelines.md` define several requirements. Here is P3-22's compliance mapping:

| Guideline Requirement | P3-22 Implementation |
|----------------------|---------------------|
| Multi-Skeptic: Accuracy Skeptic + Narrative Skeptic | Defined per the guidelines table |
| Consensus pattern: Pipeline | Sequential handoffs: Research -> Draft -> Review -> Revise -> Validate |
| Mandatory output: Assumptions & Limitations | Included in output format (appendix section) |
| Mandatory output: Confidence levels | Applied to all projections in the update |
| Mandatory output: Falsification triggers | Included for major claims ("What would change this conclusion?") |
| Mandatory output: External validation checkpoints | Included -- e.g., "Have your accountant verify financial figures" |
| Skeptic enforcement checklist | Both skeptics use the 6-item checklist from the guidelines |

**P3-22 is the first skill to implement ALL of these requirements.** This makes it the definitive test of the business-skill design guidelines. Lessons learned from P3-22 will directly inform whether the guidelines need revision before more business skills are built.

---

## 6. Conclusion

P3-22 (`/draft-investor-update`) is validated as the correct next feature. It is:

- **Strategically valuable**: First business skill, validates the entire business-skill design framework, creates progress toward P2-07 (skill count -> 5) and P2-08 (business skill count -> 1).
- **Technically feasible**: Pipeline pattern is closest to existing architecture. All reusable patterns are well-established. New patterns (multi-skeptic, business output requirements) are well-defined in the guidelines.
- **Appropriately scoped**: Small-Medium effort. Constrained output format. Primary data comes from existing project structure. User input supplements but doesn't dominate.
- **Self-dogfoodable**: We can test it on this project immediately after building it.

The spec should resolve the 7 open questions above and define the SKILL.md structure, agent roles, pipeline stages, output format, and argument parsing.
