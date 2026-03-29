---
feature: "review-cycle-8"
team: "plan-product"
agent: "researcher"
phase: "findings-submitted"
status: "complete"
last_action:
  "Expanded research complete — added opportunity analysis per PO direction"
updated: "2026-02-19"
---

# Review Cycle 8 — Researcher Findings

## 1. P3-14 Commit Verification

**Status: FULLY COMMITTED AND TRACKED** (Confidence: H)

The RC7 action item #1 ("Verify and commit P3-14") has been completed. Commit
`35c0822` includes:

- `plugins/conclave/skills/plan-hiring/SKILL.md` — 1560 lines, fully tracked
- `docs/specs/plan-hiring/spec.md` — 333 lines
- `docs/architecture/plan-hiring-system-design.md` — 1125 lines
- `scripts/validators/skill-shared-content.sh` — updated
- `docs/roadmap/P3-14-plan-hiring.md` — status: `complete`
- `docs/roadmap/_index.md` — shows P3-14 as ✅
- 14 new P3 roadmap stubs (P3-04 through P3-21)
- All RC6 + RC7 review cycle progress files
- All plan-hiring build progress files
- Multiple cost summaries

**git status**: Clean. No untracked plan-hiring files.

**Validator status**: `skill-shared-content.sh` passes — "7 files checked" for
all 3 checks (principles-drift, protocol-drift, authoritative-source).

**RC7 Action #1: COMPLETE** ✅

## 2. Structured Debate Validation Status

**Status: IMPLEMENTED, NOT VALIDATED** (Confidence: H)

The SKILL.md for `/plan-hiring` is committed and validators pass, but there is
**no evidence that `/plan-hiring` has ever been run to produce actual output**:

- `docs/hiring-plans/` directory does **NOT exist** — glob returned no files
- No hiring plan output artifacts anywhere in the repo
- No runtime progress files (e.g., `plan-hiring-growth-advocate.md`,
  `plan-hiring-bias-skeptic.md` with actual run data)

The existing `docs/progress/plan-hiring-*.md` files are from the **build-product
implementation session**, not from a `/plan-hiring` execution. They document
implementation progress, not debate output.

**RC7 Action #2 ("Validate Structured Debate pattern"): NOT DONE** ❌

This means the Structured Debate pattern remains **untested in production**. We
have a 1560-line SKILL.md but zero evidence it produces correct output when
invoked.

## 3. P2-07 Stale Data Check

**Status: P2-07 HAS BEEN UPDATED** (Confidence: H)

RC7 noted P2-07 said "4 multi-agent skills" but should be higher. The current
P2-07 file (`docs/roadmap/P2-07-universal-principles.md`) now reads:

> "Currently 6 multi-agent skills carry shared content (7 total skills including
> 1 single-agent). ADR-002 sets the extraction threshold at 8 skills."

And the trigger condition says:

> "Current count: 7 total skills, 6 multi-agent skills with shared content. One
> more multi-agent skill triggers the threshold."

**RC7 Action #3 ("Update P2-07 roadmap file"): COMPLETE** ✅

### Verified Skill Count

| #   | Skill                 | Multi-agent?      | Shared Content? | Status    |
| --- | --------------------- | ----------------- | --------------- | --------- |
| 1   | plan-product          | Yes               | Yes             | committed |
| 2   | build-product         | Yes               | Yes             | committed |
| 3   | review-quality        | Yes               | Yes             | committed |
| 4   | setup-project         | No (single-agent) | No              | committed |
| 5   | draft-investor-update | Yes               | Yes             | committed |
| 6   | plan-sales            | Yes               | Yes             | committed |
| 7   | plan-hiring           | Yes               | Yes             | committed |

**Total: 7 skills, 6 multi-agent with shared content, 1 single-agent.**

P2-07 file is now accurate.

## 4. P2-07 Trigger Assessment

**Status: 1 multi-agent skill away from ADR-002 threshold** (Confidence: H)

- ADR-002 extraction threshold: **8 skills** (see ADR-002: "When the skill count
  exceeds 8, revisit this approach")
- Current total skills: **7**
- Current multi-agent skills with shared content: **6**
- Skills needed to trigger: **1 more multi-agent skill** (making 8 total, 7 with
  shared content)

**What's the next skill likely to be built?** Based on P3 backlog analysis
(Section 6 below):

The most likely next multi-agent skill candidates are:

1. **P3-11 (plan-marketing)** — business skill, medium effort, natural
   complement to plan-sales
2. **P3-04 (triage-incident)** — engineering skill, medium effort, high
   operational value
3. **P3-05 (review-debt)** — engineering skill, medium effort, high developer
   value
4. **P3-15 (plan-customer-success)** — business skill, medium effort,
   complements sales

Any of these would trigger the P2-07 threshold. **RC7 recommended pre-planning
P2-07 extraction mechanism BEFORE skill #8 is built** (Action #4). This has NOT
been done yet.

**RC7 Action #4 ("Pre-plan P2-07 extraction mechanism"): NOT DONE** ❌

## 5. P2-08 Prerequisite Check

**Status: Prerequisites MET** (Confidence: H)

P2-08 requires "2+ business skills built and validated." Current business
skills:

| Skill                 | Type     | Pattern                | Validated?                      |
| --------------------- | -------- | ---------------------- | ------------------------------- |
| draft-investor-update | Business | Pipeline               | ✅ Yes (pathfinder)             |
| plan-sales            | Business | Collaborative Analysis | ✅ Yes (pathfinder)             |
| plan-hiring           | Business | Structured Debate      | ❌ Not validated (no execution) |

**2/2 validated business skills** (draft-investor-update + plan-sales).
Prerequisite met.

The P2-08 roadmap file itself already notes: "Current status: 2/2 business
skills complete (`/draft-investor-update` + `/plan-sales`). Prerequisite met as
of 2026-02-19."

However, per RC7 skeptic-approved sequence: **P2-08 spec should happen AFTER
P2-07 pre-plan**. P2-07 pre-plan has not happened yet, so P2-08 is effectively
**blocked on P2-07 pre-planning**.

**RC7 Action #5 ("Spec P2-08 with P2-07 mechanism in mind"): BLOCKED on Action
#4** ⏳

## 6. P3 Backlog Triage

### Completed P3 Items (4 of ~19)

| Item                          | Category             | Status      |
| ----------------------------- | -------------------- | ----------- |
| P3-02 (setup-project)         | developer-experience | ✅ Complete |
| P3-22 (draft-investor-update) | business-skills      | ✅ Complete |
| P3-10 (plan-sales)            | business-skills      | ✅ Complete |
| P3-14 (plan-hiring)           | business-skills      | ✅ Complete |

### Not-Started P3 Items — Value Assessment

#### Engineering Skills (4 not started)

| Item                       | Effort | Impact | Assessment                                                                               |
| -------------------------- | ------ | ------ | ---------------------------------------------------------------------------------------- |
| P3-01 (custom-agent-roles) | Large  | Medium | Low urgency. Depends on stack-generalization. Increases complexity significantly. Defer. |
| P3-04 (triage-incident)    | Medium | Medium | **HIGH VALUE**. Operational tool with clear use case. Would exercise existing patterns.  |
| P3-05 (review-debt)        | Medium | Medium | **HIGH VALUE**. Developer tool with clear use case. Natural complement to build-product. |
| P3-06 (design-api)         | Medium | Medium | Medium value. Useful but narrower audience than triage/debt.                             |
| P3-07 (plan-migration)     | Large  | Medium | Lower urgency. Large effort. Defer unless needed.                                        |

#### Business Skills — Core (7 not started)

| Item                           | Effort | Impact | Assessment                                                                       |
| ------------------------------ | ------ | ------ | -------------------------------------------------------------------------------- |
| P3-11 (plan-marketing)         | Medium | Medium | **HIGH VALUE**. Natural next business skill after sales. Complements plan-sales. |
| P3-12 (plan-finance)           | Large  | Medium | High value but large effort. Important for startup planning.                     |
| P3-15 (plan-customer-success)  | Medium | Medium | Medium-high value. Complements sales pipeline.                                   |
| P3-16 (build-sales-collateral) | Medium | Medium | Medium value. Depends on plan-sales data.                                        |
| P3-17 (build-content)          | Medium | Medium | Medium value. Content marketing production.                                      |
| P3-18 (review-legal)           | Large  | Medium | Lower urgency. Large effort. Specialized domain.                                 |
| P3-21 (plan-onboarding)        | Small  | Medium | **Good value/effort ratio**. Natural companion to plan-hiring.                   |

#### Business Skills — Scale & Optimize (3 not started)

| Item                    | Effort | Impact | Assessment                              |
| ----------------------- | ------ | ------ | --------------------------------------- |
| P3-19 (plan-analytics)  | Medium | Medium | Lower urgency. Optimization-phase tool. |
| P3-20 (plan-operations) | Medium | Medium | Lower urgency. Optimization-phase tool. |

#### Documentation (1 not started)

| Item                       | Effort | Impact | Assessment                                                   |
| -------------------------- | ------ | ------ | ------------------------------------------------------------ |
| P3-03 (contribution-guide) | Small  | Low    | Low urgency. Useful when external contributors are expected. |

### Highest-Value Next Items (Researcher's Assessment)

**Tier 1 — Build next (highest value, reasonable effort):**

1. P3-11 (plan-marketing) — Complements plan-sales, medium effort, triggers
   P2-07 threshold
2. P3-04 (triage-incident) — High operational value, medium effort, triggers
   P2-07 threshold

**Tier 2 — Build soon:** 3. P3-05 (review-debt) — Developer tool, medium
effort 4. P3-21 (plan-onboarding) — Small effort, companion to plan-hiring 5.
P3-15 (plan-customer-success) — Complements sales pipeline

**Tier 3 — Defer:**

- P3-01, P3-07, P3-12, P3-18 (large effort or lower urgency)
- P3-19, P3-20 (optimization-phase, premature now)
- P3-03, P3-06, P3-16, P3-17 (lower relative value)

**CRITICAL NOTE**: Building ANY Tier 1 or Tier 2 multi-agent skill triggers
P2-07 (8+ skills). The P2-07 extraction mechanism MUST be pre-planned before the
next multi-agent skill is built.

## 7. RC7 Action Sequence Progress

| #   | Action                                  | Status      | Evidence                                |
| --- | --------------------------------------- | ----------- | --------------------------------------- |
| 1   | Verify and commit P3-14                 | ✅ COMPLETE | Commit `35c0822`, clean git status      |
| 2   | Validate Structured Debate pattern      | ❌ NOT DONE | No `docs/hiring-plans/` output exists   |
| 3   | Update P2-07 roadmap file               | ✅ COMPLETE | P2-07 now says "6 multi-agent, 7 total" |
| 4   | Pre-plan P2-07 extraction mechanism     | ❌ NOT DONE | No ADR or design doc exists             |
| 5   | Spec P2-08 with P2-07 mechanism in mind | ⏳ BLOCKED  | Depends on Action #4                    |
| 6   | Park P2-02                              | ✅ PARKED   | Per RC5 directive, unchanged            |

**Summary: 3 of 6 actions complete. 2 not done. 1 blocked.**

## Pattern Validation Status (Updated)

| Pattern                | Skill                                       | Status                         |
| ---------------------- | ------------------------------------------- | ------------------------------ |
| Hub-and-Spoke          | plan-product, build-product, review-quality | VALIDATED (original 3 skills)  |
| Pipeline               | draft-investor-update (P3-22)               | VALIDATED                      |
| Collaborative Analysis | plan-sales (P3-10)                          | VALIDATED                      |
| Structured Debate      | plan-hiring (P3-14)                         | **IMPLEMENTED, NOT VALIDATED** |

## Key Findings Summary

1. **P3-14 is fully committed and tracked.** Clean git status. Validators pass.
   Roadmap updated.
2. **Structured Debate is untested.** SKILL.md exists but has never been
   executed. This is the top remaining risk.
3. **P2-07 is 1 skill away from trigger.** Next multi-agent skill triggers the
   8-skill threshold. Pre-planning extraction mechanism is urgent.
4. **P2-07 pre-plan and P2-08 spec are the critical path.** Both RC7 actions #4
   and #5 are undone.
5. **P2-08 prerequisites are met** (2/2 validated business skills) but spec is
   blocked on P2-07 pre-plan.
6. **P3-11 (plan-marketing) and P3-04 (triage-incident) are the highest-value
   next skills**, but building either one triggers P2-07.
7. **3 of 6 RC7 actions are complete**, 2 undone, 1 blocked.

---

## 8. Expanded Analysis: Opportunities Beyond the Backlog

Per Product Owner direction, investigating new feature ideas, helper scripts,
cross-skill utilities, and net-new skill concepts.

### 8.1 README Is Stale

**Status: README outdated** (Confidence: H)

The README (`README.md`) is significantly out of date:

- **Lists only 3 skills** (plan-product, build-product, review-quality) — actual
  count is 7
- **Project Structure section** only shows the original 3 skill directories
- **Missing skills**: setup-project, draft-investor-update, plan-sales,
  plan-hiring
- **No mention of business skills**, Collaborative Analysis, Pipeline, or
  Structured Debate patterns
- **Cost Considerations** section only covers the original 3 skills
- States "default is Laravel/PHP" in Customization — this is inaccurate for the
  plugin itself (it's stack-agnostic; the Laravel stack hint is for projects
  using the plugin)

This is a user-facing documentation gap. Anyone discovering the project sees
only 3 of 7 skills.

### 8.2 Existing Validator Infrastructure

**Current validators** (5 scripts in `scripts/validators/`):

1. `skill-structure.sh` — A1-A4: YAML frontmatter, required sections, spawn
   definitions, shared content markers
2. `skill-shared-content.sh` — B1-B3: principles drift, protocol drift,
   authoritative source
3. `roadmap-frontmatter.sh` — C1-C2: roadmap file frontmatter, filename
   conventions
4. `spec-frontmatter.sh` — D1: spec file frontmatter
5. `progress-checkpoint.sh` — E1: checkpoint file frontmatter

**Orchestrated by**: `scripts/validate.sh` (runs all 5 in sequence, aggregates
pass/fail counts)

### 8.3 Helper Script Opportunities

**HIGH VALUE — Missing tooling identified:**

#### a) Skill Scaffolding Script (NEW)

**Problem**: Creating a new skill requires manually writing ~400-1500 lines of
SKILL.md with correct frontmatter, shared content blocks, section structure,
spawn definitions, checkpoint protocol, etc. This is error-prone and slows skill
development. **Proposal**: `scripts/scaffold-skill.sh <skill-name> <pattern>`
that generates a skeleton SKILL.md with:

- Correct YAML frontmatter
- Shared content blocks copied from authoritative source (plan-product)
- Section stubs matching pattern (hub-spoke, pipeline, collaborative-analysis,
  structured-debate)
- Placeholder spawn definitions
- Checkpoint protocol stub
- Write safety section **Value**: Reduces new skill creation from hours to
  minutes. Ensures consistency. Directly supports P2-07 by making shared content
  extraction easier — new skills would get shared content from a single source.
  **Effort**: Small-Medium. Confidence: H.

#### b) Cost Aggregation Script (NEW)

**Problem**: 18 cost summary files exist in `docs/progress/` but no aggregation.
No way to answer "how much has the project spent across all sessions?" or "which
skills cost the most?" **Proposal**: `scripts/cost-report.sh` that parses cost
summary files and produces:

- Total cost across all sessions
- Cost by skill
- Cost by session type (plan-product vs build-product vs review-quality)
- Agent model mix (Opus vs Sonnet usage) **Value**: Directly supports the P2-01
  cost guardrails work. Provides visibility into the actual economics of the
  framework. **Effort**: Small. Confidence: M (depends on cost summary file
  format consistency).

#### c) Roadmap Dashboard Script (NEW)

**Problem**: The roadmap index (`_index.md`) is manually maintained and already
partially stale. Understanding project status requires reading the index plus
individual files. **Proposal**: `scripts/roadmap-status.sh` that:

- Reads all roadmap files, extracts frontmatter
- Generates a summary table (like `_index.md` but auto-generated)
- Shows completion percentage by category and priority
- Flags stale items (status doesn't match evidence)
- Shows dependency graph **Value**: Replaces manual index maintenance. Could be
  run as a validator check or as a standalone report. **Effort**: Small-Medium.
  Confidence: H.

#### d) Shared Content Sync Script (NEW)

**Problem**: When shared content changes in the authoritative source
(plan-product), all other skills must be manually updated. The validator catches
drift but doesn't fix it. **Proposal**: `scripts/sync-shared-content.sh` that:

- Reads shared content blocks from authoritative source
- Replaces shared content blocks in all other SKILL.md files
- Preserves per-skill variations (skeptic names in communication protocol)
- Reports what changed **Value**: Directly enables P2-07 workflow. When
  extraction isn't yet justified, this script is the stopgap. Reduces shared
  content update effort from "edit 6 files" to "edit 1 file, run script."
  **Effort**: Small-Medium. Confidence: H. This is essentially a precursor to
  the P2-07 extraction mechanism.

### 8.4 Cross-Skill Utility Opportunities

#### a) Output Format Standardizer

**Problem**: Each business skill defines its own output template inline in
SKILL.md. Templates share structural patterns (frontmatter, mandatory quality
sections, confidence assessments) but are not reusable. **Proposal**: A shared
output template library in `docs/templates/` or `plugins/conclave/templates/`
that skills reference. Business skill SKILL.md files would say "use the
business-output template" instead of embedding 150+ lines of output format.
**Value**: Reduces SKILL.md size (plan-hiring is 1560 lines, partly because of
the embedded output template). Ensures consistency. Directly supports P2-07.
**Effort**: Medium. Depends on P2-07 mechanism design.

#### b) User Data Template Registry

**Problem**: Business skills each define their own `_user-data.md` template
inline (draft-investor-update, plan-sales, plan-hiring all have embedded
templates). Each is different and there's no shared registry. **Proposal**: A
shared user-data template directory at `docs/templates/user-data/` with
per-skill templates, or a combined template that covers all skills. **Value**:
Reduces SKILL.md bloat. Enables a potential "fill in your company data once, use
across all business skills" workflow. **Effort**: Small-Medium. Could be part of
P2-08 plugin organization.

### 8.5 Net-New Skill Concepts (Beyond Existing P3 Stubs)

#### a) `/retrospective` — Sprint/Cycle Retrospective Skill

**Problem**: Development teams running iterative cycles need structured
retrospectives. What went well, what didn't, what to change. **Pattern**:
Collaborative Analysis (multiple agents review different aspects) **Value**:
High for teams using this framework regularly. Self-dogfooding opportunity —
could retrospect on the conclave project itself. **Effort**: Medium.

#### b) `/competitive-analysis` — Competitive Intelligence Skill

**Problem**: Startups need structured competitive analysis but it's often
ad-hoc. **Pattern**: Collaborative Analysis **Value**: Medium. Currently
partially covered by plan-product and plan-sales, but a dedicated skill could go
deeper. **Effort**: Medium. Overlap risk with plan-product.

#### c) `/design-system` — Design System Specification Skill

**Problem**: Frontend teams need consistent design systems but lack structured
processes for defining them. **Pattern**: Pipeline (Research → Draft → Review)
**Value**: Medium. More relevant for larger teams. **Effort**: Medium-Large.

#### d) `/plan-infrastructure` — Infrastructure Planning Skill

**Problem**: Startups need to make infrastructure decisions (cloud provider,
architecture, scaling strategy) but lack structured evaluation processes.
**Pattern**: Structured Debate (cloud vs. on-prem, monolith vs. microservice)
**Value**: High for technical startups. **Effort**: Medium.

**Assessment**: Of these, `/retrospective` has the highest value-to-effort ratio
and the strongest self-dogfooding benefit. `/plan-infrastructure` fills a
genuine gap in the existing skill set (no infrastructure-focused skill exists).

### 8.6 Structural Observations

#### SKILL.md Size Growth Is Unsustainable

| Skill                 | Lines | Category                     |
| --------------------- | ----- | ---------------------------- |
| plan-product          | 389   | Engineering                  |
| review-quality        | 440   | Engineering                  |
| build-product         | 472   | Engineering                  |
| setup-project         | 393   | Single-agent                 |
| draft-investor-update | 737   | Business (Pipeline)          |
| plan-sales            | 1182  | Business (Collab. Analysis)  |
| plan-hiring           | 1560  | Business (Structured Debate) |

Business skills average 1160 lines vs engineering 434 lines (2.7x). The trend is
accelerating: 737 → 1182 → 1560. At this rate, the next business skill will be
~1900 lines. This is **unsustainable** without addressing:

- Shared content duplication (~130 lines per file × 6 multi-agent skills = 780
  duplicate lines)
- Output template embedding (100-200 lines per business skill)
- Cross-examination format definitions (plan-hiring has ~200 lines of format
  definitions)
- Spawn prompt embedding (each agent's full prompt is inline)

**P2-07 (shared content extraction) would save ~130 lines per skill.** But the
larger wins are in template extraction (output templates, format definitions)
which aren't covered by P2-07.

#### Progress File Accumulation

`docs/progress/` contains ~115 files. This will keep growing with each skill
invocation. No cleanup mechanism exists. Consider:

- Archive/rotation for old checkpoint files
- A validator that flags stale `in_progress` checkpoints (RC7 noted this issue)

#### Single Stack Hint

Only `docs/stack-hints/laravel.md` exists. The framework is stack-agnostic, but
there's only one stack hint. Adding stack hints for common stacks (Node.js,
Python/Django, Go, Ruby/Rails, React/Next.js) would improve adoption. This is
low-effort, high-value for developer experience.

### 8.7 Opportunity Priority Ranking

**Immediate high-value, low-effort:**

1. **Shared content sync script** — precursor to P2-07, solves current pain
2. **Skill scaffolding script** — accelerates future skill development
3. **README update** — user-facing documentation gap
4. **Additional stack hints** — broadens framework appeal

**Medium-term, medium-effort:** 5. **Cost aggregation script** — operational
visibility 6. **Roadmap dashboard script** — replaces manual index
maintenance 7. **Output format standardizer** — reduces SKILL.md bloat (needs
P2-07 mechanism first) 8. **Stale checkpoint validator** — catches the issue RC7
flagged

**Longer-term, larger-effort:** 9. **Net-new skills** (retrospective,
plan-infrastructure) — after P2-07 is resolved 10. **User data template
registry** — part of P2-08 scope
