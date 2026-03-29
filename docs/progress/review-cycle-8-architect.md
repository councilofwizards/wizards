---
feature: "review-cycle-8"
team: "plan-product"
agent: "architect"
phase: "review"
status: "complete"
last_action:
  "Completed P2-07/P2-08 assessment + expanded opportunity analysis (sections 7-11: cross-skill extraction, helper
  scripts, utilities, net-new skills)"
updated: "2026-02-19T00:00:00Z"
---

# Review Cycle 8 — Architect Assessment

## 1. Shared Content Current State

**Verdict: Healthy. Infrastructure ready for extraction.**

### ADR-002 Status

ADR-002 (Content Deduplication Strategy) established "validated duplication with HTML comment markers." Current state:

- **6 multi-agent skills** carry shared content (Shared Principles + Communication Protocol)
- **1 single-agent skill** (setup-project) correctly excluded via `type: single-agent` frontmatter
- **Authoritative source**: plan-product/SKILL.md
- **All validators pass** with 7 skills checked (B1, B2, B3 all green)
- **ADR-002 8-skill revision trigger**: Currently at 7 total skills, 6 with shared content. One more multi-agent skill
  triggers extraction.

### Shared Content Markers Inventory

All 6 multi-agent skills have identical marker structure:

```
<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
[~30 lines: 12 numbered principles in 4 tiers]
<!-- END SHARED: principles -->

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
[~35 lines: tool mapping, When to Message table, Message Format template]
<!-- END SHARED: communication-protocol -->
```

### Per-Skill Variations (Within Communication Protocol)

The only intentional per-skill variation is the skeptic name in one table row:

| Skill                 | Skeptic in "Plan ready for review" row |
| --------------------- | -------------------------------------- |
| plan-product          | `product-skeptic` / Product Skeptic    |
| build-product         | `quality-skeptic` / Quality Skeptic    |
| review-quality        | `ops-skeptic` / Ops Skeptic            |
| draft-investor-update | `accuracy-skeptic` / Accuracy Skeptic  |
| plan-sales            | `accuracy-skeptic` / Accuracy Skeptic  |
| plan-hiring           | `bias-skeptic` / Bias Skeptic          |

### CI Validator (skill-shared-content.sh)

The validator at `scripts/validators/skill-shared-content.sh` (236 lines) implements:

1. **B1 (Principles Drift)**: Byte-identical comparison against authoritative source
2. **B2 (Protocol Drift)**: Structural equivalence after normalizing 16 skeptic name variants (8 slug + 8 display)
3. **B3 (Authoritative Source)**: Verifies BEGIN SHARED markers are followed by source comment
4. **Single-agent exclusion**: Detects `type: single-agent` in frontmatter, skips checks

**Key observation**: The `normalize_skeptic_names()` function has grown to 16 sed expressions. At 10+ skeptic types, a
regex pattern would be cleaner. Not urgent but worth noting for P2-07 design.

### build-product Skill-Specific Section

`build-product/SKILL.md` has a unique `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` section (Contract
Negotiation Pattern). This is correctly outside the shared markers and not affected by extraction. All other skills have
a comment: `<!-- Contract Negotiation Pattern omitted — ... See build-product/SKILL.md. -->`.

## 2. P2-07 Extraction Mechanism Analysis

**Verdict: Build-time injection is the only viable approach. Design it as ADR-003.**

### Constraint: Claude Code Plugin Architecture

Claude Code skills are **static markdown files**. When a user invokes a skill (e.g., `/plan-hiring`), Claude Code reads
`plugins/conclave/skills/plan-hiring/SKILL.md` as a complete markdown document. There is:

- No include directive
- No import mechanism
- No pre-processing of the markdown before it reaches the agent
- No runtime file resolution

**This constraint eliminates two of the three candidate approaches.**

### Option A: Includes (Source Files Referenced at Skill Read Time)

**REJECTED.**

Concept: Each SKILL.md would contain `<!-- INCLUDE shared/principles.md -->` and the system would resolve it at read
time.

Why it fails:

- Claude Code has no include/import directive for SKILL.md files
- We cannot modify Claude Code's skill-reading behavior (it's a third-party tool)
- We could instruct agents to manually read a referenced file, but this:
  - Breaks self-containment (ADR-002's core property)
  - Adds a tool call per agent spawn (context cost + latency)
  - Creates a runtime dependency on a file that may not exist
  - Changes agent behavior (violates ADR-002's "no agent behavior changes" constraint)

### Option B: References (Pointers to Shared Content Files)

**REJECTED.**

Concept: Each SKILL.md would contain `See plugins/conclave/shared/principles.md for shared principles` and agents would
read the file.

Why it fails:

- Same problems as Option A — breaks self-containment
- Doubles the number of file reads per skill invocation (one for SKILL.md, one for shared file)
- Agents would need instructions to read the referenced file, adding complexity to every spawn prompt
- If the shared file is missing or corrupted, all skills degrade simultaneously

### Option C: Build-Time Injection

**RECOMMENDED.**

Concept: A build script reads authoritative source files and injects their content between existing HTML comment markers
in each SKILL.md.

#### How it works:

1. **Source files** (new):
   - `plugins/conclave/shared/principles.md` — The 12 shared principles (single source of truth)
   - `plugins/conclave/shared/communication-protocol.md` — The communication protocol (single source of truth)

2. **Build script** (new): `scripts/build-shared-content.sh`
   - Reads source files
   - For each multi-agent SKILL.md, replaces content between `<!-- BEGIN SHARED: principles -->` and
     `<!-- END SHARED: principles -->` with the source file content
   - Similarly for communication-protocol
   - Handles per-skill skeptic name substitution (see below)

3. **Per-skill variation handling**:
   - Source file uses a placeholder: `write(REVIEW_SKEPTIC, "PLAN REVIEW REQUEST: ...")` and `REVIEW_SKEPTIC` /
     `Review Skeptic` in the table
   - Each SKILL.md's frontmatter gains a field: `review-skeptic: bias-skeptic` (slug) and
     `review-skeptic-display: Bias Skeptic`
   - Build script reads frontmatter, replaces placeholders with skill-specific values
   - This is exactly what `normalize_skeptic_names()` already does in reverse — we're just automating the direction

4. **Existing infrastructure preserved**:
   - HTML comment markers (`<!-- BEGIN SHARED -->` / `<!-- END SHARED -->`) already define injection boundaries — no new
     markers needed
   - Authoritative source comments already present — build script updates these
   - CI validators (B1/B2/B3) continue to work as a safety net
   - SKILL-SPECIFIC sections are untouched (outside shared markers)
   - Single-agent skills are skipped (no shared markers)

5. **Workflow change**:
   - **Before**: Edit plan-product/SKILL.md, manually copy to 5 other files, hope CI catches drift
   - **After**: Edit `plugins/conclave/shared/principles.md`, run `scripts/build-shared-content.sh`, done
   - CI validators remain as post-build verification

#### Advantages:

- **Self-containment preserved**: At runtime, every SKILL.md is a complete, standalone markdown file. Agents never need
  to read external files. This is the core property ADR-002 protects.
- **Single-source editing**: Authors edit one file, build script propagates. Eliminates the N-file manual sync that
  ADR-002 acknowledges becomes burdensome at 8+ skills.
- **Existing markers as injection points**: No new SKILL.md modifications needed. The markers from P2-05 implementation
  are already in place.
- **CI validators as safety net**: B1/B2/B3 validators continue to catch drift even if someone edits a SKILL.md directly
  (before running the build script).
- **Incremental adoption**: Can be introduced alongside skill #8 without modifying existing skills. Existing skills
  already have the markers.

#### Risks and mitigations:

| Risk                                    | Mitigation                                                                                     |
| --------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Developer forgets to run build script   | Add pre-commit hook that runs build script; CI validators catch drift                          |
| Build script corrupts SKILL.md          | Build script only modifies content between markers; existing content before/after is preserved |
| Frontmatter extension breaks validators | Add A-series validator check for new frontmatter fields                                        |
| Source file out of sync with SKILL.md   | Build script is idempotent — running it always produces the correct state                      |

## 3. P2-08 Plugin Boundary Analysis

**Verdict: Domain split (engineering/business) is the natural boundary. But P2-07 extraction must come first.**

### Current Skill Inventory

| Skill                 | Domain      | Pattern                | Shared Content | Lines | Size |
| --------------------- | ----------- | ---------------------- | -------------- | ----- | ---- |
| plan-product          | Engineering | Hub-and-Spoke          | Yes            | 389   | 20KB |
| build-product         | Engineering | Hub-and-Spoke          | Yes            | 472   | 25KB |
| review-quality        | Engineering | Hub-and-Spoke          | Yes            | 440   | 24KB |
| setup-project         | Engineering | Single-Agent           | No             | 393   | 17KB |
| draft-investor-update | Business    | Pipeline               | Yes            | 737   | 35KB |
| plan-sales            | Business    | Collaborative Analysis | Yes            | 1182  | 56KB |
| plan-hiring           | Business    | Structured Debate      | Yes            | 1560  | 76KB |

### Boundary Options Evaluated

#### Option 1: Domain Split (Engineering / Business)

**RECOMMENDED (when P2-07 is resolved).**

- Engineering: plan-product, build-product, review-quality, setup-project (4 skills, avg 22KB)
- Business: draft-investor-update, plan-sales, plan-hiring (3 skills, avg 56KB)

Strengths:

- Clean, intuitive grouping — a user installing "conclave" might want just engineering or just business skills
- Each domain has a coherent purpose (SDLC vs. business operations)
- Size imbalance (engineering avg 22KB, business avg 56KB) is manageable

Weaknesses:

- Shared content must be managed across two plugins (binding constraint — see P2-07 dependency)
- setup-project is borderline — it scaffolds for all skills, not just engineering

#### Option 2: Pattern Split

**REJECTED.**

- Hub-and-Spoke: plan-product, build-product, review-quality
- Pipeline: draft-investor-update
- Collaborative Analysis: plan-sales
- Structured Debate: plan-hiring
- Single-Agent: setup-project

Why it fails:

- 5 groups for 7 skills is over-partitioned
- Each business skill uses a different pattern — no grouping benefit
- Patterns are implementation details, not user-facing concepts
- Users think in terms of "plan my sales strategy" not "invoke a Collaborative Analysis"

#### Option 3: Keep Single Plugin, Reorganize Internally

**ACCEPTABLE as interim.**

Keep `plugins/conclave/` but add subdirectories:

```
plugins/conclave/skills/
├── engineering/
│   ├── plan-product/
│   ├── build-product/
│   ├── review-quality/
│   └── setup-project/
├── business/
│   ├── draft-investor-update/
│   ├── plan-sales/
│   └── plan-hiring/
└── shared/
    ├── principles.md
    └── communication-protocol.md
```

Strengths:

- No plugin-split complexity
- Shared content stays within one plugin
- Clean internal organization

Weaknesses:

- May break Claude Code's skill discovery (needs investigation — does Claude Code scan nested directories?)
- Doesn't enable independent installation/updating of skill domains

### P2-07 Location Implication

The extraction mechanism design directly affects P2-08:

| P2-07 Source Location             | P2-08 Impact                                                                    |
| --------------------------------- | ------------------------------------------------------------------------------- |
| `plugins/conclave/shared/`        | If single plugin: clean. If split: shared/ must move or be cross-referenced.    |
| `plugins/shared/` (above plugins) | Clean for both single and multi-plugin. But: new directory outside any plugin.  |
| `.claude/shared/` (project level) | Decoupled from plugins entirely. But: ownership ambiguity (project vs. plugin). |

**Recommendation**: Place source files at `plugins/conclave/shared/` for now. If P2-08 splits plugins, the build script
path is trivially updated. Don't over-engineer the file location for a split that hasn't happened.

## 4. Skill Pattern Classification — Confirmed

| Pattern                | Skills                                      | Key Characteristics                                                                         | Validated?                                  |
| ---------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------- |
| Hub-and-Spoke          | plan-product, build-product, review-quality | Lead orchestrates; agents work on separate concerns; outputs flow through lead              | Yes (original 3 skills)                     |
| Pipeline               | draft-investor-update                       | Sequential stages with quality gates: Research → Draft → Review → Finalize                  | Yes (P3-22 implementation)                  |
| Collaborative Analysis | plan-sales                                  | Parallel research → cross-referencing → lead synthesis → dual-skeptic review                | Yes (P3-10 implementation)                  |
| Structured Debate      | plan-hiring                                 | Neutral research → case building → cross-examination → lead synthesis → dual-skeptic review | Implemented, not yet validated by execution |
| Single-Agent           | setup-project                               | No team, no skeptic, deterministic pipeline                                                 | Yes (P3-02 implementation)                  |

### Structural Similarities Across All Multi-Agent Skills

Every multi-agent skill (6/7) shares these structural elements:

1. **Setup section**: Directory creation, template reading, stack detection
2. **Write Safety section**: Role-scoped progress files, lead-only shared files
3. **Checkpoint Protocol section**: YAML frontmatter format, when-to-checkpoint rules
4. **Determine Mode section**: status / empty / args handling, --light mode
5. **Spawn the Team section**: Named roles with model assignments
6. **Orchestration Flow section**: Phases, gates, agent assignments
7. **Quality Gate section**: Skeptic approval required
8. **Failure Recovery section**: Unresponsive agent, skeptic deadlock, context exhaustion
9. **Shared Principles section**: 12 principles in 4 tiers (SHARED marker)
10. **Communication Protocol section**: Tool mapping, message table, format (SHARED marker)
11. **Teammate Spawn Prompts section**: Full prompt text for each role

Of these 11 sections, sections 9-10 are already tracked by shared content markers. Sections 1-3 and 7-8 are structurally
similar but not byte-identical (different team names, role names, phase names). These are candidates for future
extraction or templatization — but that's a P2-07+ concern, not an immediate action.

### Per-Pattern Unique Elements

| Pattern                | Unique Elements                                                                                                                                                                   |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hub-and-Spoke          | Contract Negotiation Pattern (build-product only)                                                                                                                                 |
| Pipeline               | Output Template, Research Dossier Format, User Data Template                                                                                                                      |
| Collaborative Analysis | Domain Brief Format, Cross-Reference Report Format, Phase 2 Cross-Referencing protocol, User Data Template                                                                        |
| Structured Debate      | Debate Case Format, Cross-Examination Formats (Challenge/Response/Rebuttal), Anti-Premature-Agreement Rules, Agent Idle Fallback, Hiring Context Brief Format, User Data Template |
| Single-Agent           | Embedded Templates (spec, progress, architecture), Stack Detection Table, Roadmap Categories Table, CLAUDE.md Template                                                            |

Business skills are larger because they include: Output Templates, User Data Templates, and domain-specific format
definitions. These are NOT candidates for shared content extraction — they are genuinely skill-specific.

## 5. P2-07 → P2-08 Dependency Validation

**Verdict: RC7 assessment is CORRECT. P2-07 mechanism must be designed before P2-08.**

### The Binding Constraint Argument

RC7 determined: "Shared content coupling is the binding constraint." This is architecturally sound for three reasons:

1. **Source file location determines plugin organization.** If shared content is extracted to
   `plugins/conclave/shared/`, then splitting conclave into two plugins means either:
   - The shared/ directory stays in one plugin (asymmetric ownership)
   - The shared/ directory moves above both plugins (new abstraction layer)
   - Both plugins maintain independent copies (back to square one) Designing the extraction mechanism first resolves
     this ambiguity.

2. **Build script scope depends on plugin boundaries.** A build script that injects shared content into SKILL.md files
   needs to know where all the skills are. In a single plugin, that's one glob pattern. In two plugins, it's two. The
   mechanism must accommodate the future structure.

3. **CI validator scope depends on plugin boundaries.** The current `skill-shared-content.sh` uses
   `find "$REPO_ROOT/plugins" -path "*/skills/*/SKILL.md"`. This works for any number of plugins because it searches
   from the plugins root. But if plugins have different shared content needs (e.g., business skills add a "Business
   Quality Checklist" shared section not relevant to engineering skills), the validator needs to know about these
   boundaries.

### Dependency Chain

```
P2-07 (extraction mechanism design)
  → determines: source file location, build script design, validator updates
    → P2-08 (plugin organization)
      → determines: directory structure, plugin boundaries
        → skill #8+ (new skills built with extracted shared content)
```

### Recommendation

The action sequence from RC7 is correct:

1. Pre-plan P2-07 extraction mechanism (ADR-003)
2. Design accounts for potential future plugin split
3. Spec P2-08 with P2-07 mechanism in hand
4. Implement P2-07 alongside skill #8
5. Implement P2-08 if/when operational pain justifies the split

## 6. Architectural Recommendation Summary

### Immediate Actions (This Review Cycle)

| #   | Action                                                 | Rationale                                                                        |
| --- | ------------------------------------------------------ | -------------------------------------------------------------------------------- |
| 1   | Draft ADR-003 for P2-07 build-time injection mechanism | Mechanism must be designed before skill #8 enters spec                           |
| 2   | Update P2-07 roadmap file                              | Stale: says "4 multi-agent skills" but actual is 6. Count is 7/8 toward trigger. |
| 3   | Confirm P2-07 → P2-08 sequencing in roadmap            | P2-08 depends on P2-07 mechanism; add explicit dependency                        |

### P2-07 Design Decision (For ADR-003)

| Decision             | Recommendation                                                                               |
| -------------------- | -------------------------------------------------------------------------------------------- |
| Extraction mechanism | Build-time injection                                                                         |
| Source file location | `plugins/conclave/shared/principles.md`, `plugins/conclave/shared/communication-protocol.md` |
| Build script         | `scripts/build-shared-content.sh`                                                            |
| Per-skill variation  | Skeptic name via frontmatter config + placeholder substitution                               |
| CI validator changes | None (existing B1/B2/B3 remain as safety net)                                                |
| Pre-commit hook      | Recommended: run build script and fail if SKILL.md files change                              |
| ADR-002 revision     | ADR-002 → superseded by ADR-003 when implemented                                             |

### P2-08 Design Signal (For Future Spec)

| Decision                | Recommendation                                                          |
| ----------------------- | ----------------------------------------------------------------------- |
| Plugin boundary         | Domain split (engineering / business) — if split is needed              |
| Trigger                 | Operational pain or skill count >12. No pain yet at 7.                  |
| Shared content location | Stays within primary plugin; build script handles cross-plugin if split |
| setup-project placement | Engineering (it scaffolds for the conclave plugin as a whole)           |

### Risk Register

| Risk                                        | Likelihood | Impact                         | Mitigation                                                                |
| ------------------------------------------- | ---------- | ------------------------------ | ------------------------------------------------------------------------- |
| Skill #8 built before P2-07 designed        | Medium     | High (manual sync of 7+ files) | Block skill #8 spec on ADR-003 completion                                 |
| Build-time injection adds workflow friction | Low        | Medium                         | Pre-commit hook automates; no manual step                                 |
| Claude Code changes skill loading           | Low        | Low                            | Build-time injection is Claude Code-agnostic (produces standard SKILL.md) |
| Business skill sizes continue growing       | High       | Medium                         | Address in P2-07 — consider extracting more sections                      |

---

## 7. Opportunity Analysis: Cross-Skill Structural Extraction

**Beyond shared principles and communication protocol, 4 more sections are nearly identical across all 6 multi-agent
skills.**

### Section-by-Section Comparison

| Section                | Identical?             | What Varies                                | Extraction Candidate?                       |
| ---------------------- | ---------------------- | ------------------------------------------ | ------------------------------------------- |
| Setup (steps 1-6)      | 95% identical          | Output directory name in step 1            | Yes — parameterize from frontmatter         |
| Setup (steps 7-10)     | Business-only          | Domain-specific data paths, messages       | No — business-specific extension            |
| Write Safety           | Template-identical     | Team name, role names, output paths        | Yes — generate from frontmatter + role list |
| Checkpoint Protocol    | Template-identical     | Team name, phase list                      | Yes — generate from frontmatter + phases    |
| Failure Recovery       | Template-identical     | Path prefix, "skeptic" vs "either skeptic" | Yes — parameterize from frontmatter         |
| Determine Mode         | Structurally similar   | Argument patterns, skill-specific logic    | No — too much per-skill variation           |
| Shared Principles      | Byte-identical         | None                                       | Already tracked (P2-07)                     |
| Communication Protocol | Structurally identical | Skeptic name in one row                    | Already tracked (P2-07)                     |

### Concrete Findings

**Setup section** (plan-product lines 15-28 vs plan-sales lines 22-39 vs plan-hiring lines 22-39):

- Steps 1-6 are verbatim except for one directory name in step 1 (`docs/sales-plans/` vs `docs/hiring-plans/`)
- Business skills add steps 7-10 (read architecture, read prior plans, first-run convenience, data dependency warning).
  These follow an identical template with only path and message strings swapped.

**Write Safety** (plan-product lines 29-36 vs plan-sales lines 41-48 vs plan-hiring lines 41-55):

- Identical pattern: "Each agent writes ONLY to `docs/progress/{team}-{role}.md`" + "Only the Team Lead writes to shared
  files." Business skills add an explicit role-file inventory.

**Checkpoint Protocol** (plan-product lines 37-69 vs plan-sales lines 49-82 vs plan-hiring lines 56-88):

- Identical structure: YAML format block + "When to Checkpoint" rules. Only differences: `team:` value, `phase:` enum
  (engineering uses `research | design | review | complete`; business adds domain-specific phases like
  `cross-reference | synthesis | case-building | cross-examination`).

**Failure Recovery** (plan-product lines 137-141 vs plan-sales lines 300-305 vs plan-hiring lines 442-449):

- Three scenarios in every skill: Unresponsive agent, Skeptic deadlock, Context exhaustion. Only variation:
  single-skeptic skills say "the Skeptic rejects", dual-skeptic skills say "EITHER skeptic rejects" + "both skeptics'
  objections."

### Implication for P2-07

P2-07 as currently scoped covers ONLY Shared Principles and Communication Protocol. But the analysis shows 4 additional
sections that are extraction candidates: Setup (base), Write Safety, Checkpoint Protocol, and Failure Recovery.

**Recommendation**: P2-07 build-time injection should be designed to handle these sections in a future phase. The
mechanism should support:

- Parameterized templates (not just verbatim injection)
- Frontmatter-driven variable substitution (team name, output directory, skeptic count, phase list)
- Section-level extraction (each shared section is independently managed)

This doesn't change the P2-07 immediate scope (principles + communication protocol first), but the mechanism design
should accommodate future extraction of these 4 sections.

## 8. Opportunity Analysis: Helper Scripts & Tooling

### 8a. `scripts/build-shared-content.sh` (P2-07 Implementation)

Already designed in Section 2. The core P2-07 deliverable. Not repeated here.

### 8b. `scripts/scaffold-skill.sh` — New Skill Generator

**Problem**: Creating a new skill currently requires copying an existing SKILL.md (1560 lines for plan-hiring, 1182 for
plan-sales) and manually replacing team names, role names, output paths, phases, and domain-specific content. This is
error-prone and produces skills with inherited cruft.

**Proposed solution**: A scaffolding script that generates a new SKILL.md from parameters.

```
Usage: scripts/scaffold-skill.sh \
  --name plan-marketing \
  --pattern collaborative-analysis \
  --domain business \
  --skeptic strategy-skeptic \
  --output-dir docs/marketing-plans \
  --roles "market-analyst,brand-strategist,channel-planner" \
  --phases "research,cross-reference,synthesis,review,revision"
```

Outputs:

- `plugins/conclave/skills/plan-marketing/SKILL.md` — Skeleton with all 11 sections, shared content injected,
  pattern-specific structure, placeholder domain content
- Updates `scripts/validators/skill-shared-content.sh` — Adds new skeptic normalization entries
- Reports files created and manual steps remaining

**Value**: Reduces new skill creation from "copy 1500 lines and find-replace" to "run script, fill in domain-specific
sections." Would have prevented the plan-hiring SKILL.md size problem by starting from a minimal template.

**Effort**: Small-Medium. Most of the templates already exist in the skills themselves. The script needs to assemble
them.

### 8c. `scripts/validators/output-consistency.sh` — F-series Validator

**Problem**: No validator checks whether SKILL.md files follow consistent output conventions. The Output Template and
User Data Template sections in business skills use similar but not validated patterns.

**Proposed checks**:

- **F1**: Every business skill (domain: business in frontmatter) has `## Output Template` and `## User Data Template`
  sections
- **F2**: User Data Template sections follow the standard \_user-data.md pattern (YAML-ish frontmatter + sections)
- **F3**: Output file paths referenced in SKILL.md match the directory listed in Setup step 1

**Value**: Catches structural inconsistencies before they become drift. Currently, each business skill reinvents the
output template structure.

**Effort**: Small. Pattern follows existing validator structure exactly.

### 8d. `scripts/validators/stale-checkpoint.sh` — G-series Validator

**Problem**: The plan-hiring backend-eng checkpoint showing `in_progress` despite work being complete (noted in RC7) was
only caught by manual review. No automated detection of stale checkpoints.

**Proposed checks**:

- **G1**: Any checkpoint file with `status: "in_progress"` where the file's mtime is >N hours old (configurable, default
  72h) emits a WARNING
- **G2**: Any checkpoint file with `status: "in_progress"` where ALL other checkpoint files for the same `team:` are
  `complete` emits a FAIL (the team is done but this agent didn't close out)
- **G3**: Any checkpoint file with `phase: "complete"` but `status: "in_progress"` emits a FAIL (contradictory state)

**Value**: RC7 explicitly called this out: "Checkpoint hygiene: Backend-eng checkpoint for plan-hiring shows
`in_progress` despite SKILL.md being complete. Progress-checkpoint validator should flag stale in_progress checkpoints."

**Effort**: Small. Reads existing checkpoint files, checks mtime and cross-references team state.

## 9. Opportunity Analysis: Cross-Skill Utilities

### 9a. Shared User Data Pattern

All 3 business skills implement a User Data Template:

- `docs/sales-plans/_user-data.md` (plan-sales)
- `docs/hiring-plans/_user-data.md` (plan-hiring)
- `docs/investor-updates/_user-data.md` (draft-investor-update)

Each template follows the same structure: section headers with placeholder content, Markdown formatting, data categories
specific to the domain. The _first-run convenience_ and _data dependency warning_ patterns in Setup steps 9-10 are also
identical in template (different in message text).

**Recommendation**: When the 8th business skill is built, consider extracting the User Data infrastructure into a shared
pattern:

- Standardized \_user-data.md structure (common header, per-skill sections)
- Shared first-run and missing-data messages (parameterized by domain name and path)
- A cross-skill `_user-data.md` that aggregates company-wide data (company name, founding date, team size, funding)
  shared by all business skills

**This is low urgency** at 3 business skills but becomes valuable at 5+, when users would benefit from entering
company-wide data once.

### 9b. Stack Hints Expansion

The project currently has exactly 1 stack hint: `docs/stack-hints/laravel.md`. The setup-project skill references a
Stack Detection Table with 7 common stacks (Node.js, Laravel, Rails, Django, Go, Rust, Java/Spring). Only 1 of 7 has a
hint file.

**Recommendation**: Create stack hints for the remaining 6 stacks. These don't require full skill implementation —
they're static Markdown files that inform agent behavior. High value-to-effort ratio.

**Effort**: Small per hint. A dedicated session could produce all 6 in one pass.

### 9c. Project CLAUDE.md

**Finding**: This project has NO CLAUDE.md file. Claude Code loads CLAUDE.md as persistent project context on every
invocation. Without one, every Claude session starts cold with no project context.

The setup-project skill generates CLAUDE.md for user projects, but the conclave project itself doesn't have one.

**Recommendation**: Create a CLAUDE.md for the conclave project covering:

- Project purpose and architecture overview
- Skill directory structure
- Validator run command (`bash scripts/validate.sh`)
- Key conventions (shared content markers, checkpoint protocol, progress file naming)
- ADR references

**Effort**: Small. One-time creation. High ongoing value.

## 10. Opportunity Analysis: Net-New Skill Concepts

### Beyond the Existing Roadmap

The roadmap has 14 P3 stubs (7 engineering, 7 business). Analyzing the current skill inventory and user workflows
reveals additional high-value concepts:

### 10a. `/run-retro` — Retrospective Skill

**Concept**: After a feature ships (build-product + review-quality complete), run a structured retrospective.

**Why it's missing**: The current SDLC covers plan → build → review but has no "reflect" phase. Every shipped feature
generates lessons (what worked, what didn't, process improvements). These lessons currently evaporate.

**Pattern**: Collaborative Analysis (parallel perspectives → cross-reference → synthesis)

**Value**: Medium-High. The conclave project itself would benefit — each review cycle already produces observations (RC7
noted checkpoint hygiene, SKILL.md size growth, etc.) but no structured mechanism captures and tracks them.

### 10b. `/audit-deps` — Dependency Audit Skill

**Concept**: Analyze project dependencies for security vulnerabilities, license compliance, outdated versions, and
unused packages.

**Why it's missing**: review-quality covers code quality but not supply chain quality. With growing concern about
dependency security, this is a natural extension.

**Pattern**: Pipeline (scan → categorize → prioritize → report)

**Value**: Medium. Every project has this need. The setup-project skill already detects dependency manifests — this
skill would actually analyze them.

### 10c. `/write-docs` — Technical Writing Skill

**Concept**: Generate user-facing documentation from code, specs, and architecture files.

**Why it's missing**: The Documentation category on the roadmap has only P3-03 (Architecture & Contribution Guide). No
skill generates end-user docs from code.

**Pattern**: Pipeline (inventory code → extract structure → draft docs → review → finalize)

**Value**: Medium. Fills the gap between specs (developer-facing) and documentation (user-facing).

### 10d. `/plan-sprint` — Sprint Planning Skill

**Concept**: Given a roadmap and team capacity, produce a sprint plan with task breakdown, assignments, and dependency
ordering.

**Why it's missing**: plan-product handles backlog prioritization and spec creation but not tactical sprint execution
planning. This is the gap between "what to build" and "who builds what when."

**Pattern**: Hub-and-Spoke or Collaborative Analysis

**Value**: Medium-High for teams using the conclave skills in an ongoing SDLC. Currently, the human must translate
plan-product output into sprint tasks manually.

### Prioritization of Net-New Concepts

| Concept          | Impact      | Effort | Dependency   | Priority vs. Existing P3s               |
| ---------------- | ----------- | ------ | ------------ | --------------------------------------- |
| CLAUDE.md (9c)   | High        | Small  | None         | Do immediately — not even a skill       |
| Stack Hints (9b) | Medium      | Small  | None         | Do alongside next skill build           |
| `/run-retro`     | Medium-High | Medium | None         | Above most P3 business stubs            |
| `/audit-deps`    | Medium      | Medium | None         | Comparable to P3-04 (triage-incident)   |
| `/write-docs`    | Medium      | Medium | None         | Comparable to P3-06 (design-api)        |
| `/plan-sprint`   | Medium-High | Large  | plan-product | Below `/run-retro`, comparable to P3-07 |

## 11. Summary of Opportunities

### Immediate (No Spec Required)

| #   | Opportunity                  | Effort | Impact                               |
| --- | ---------------------------- | ------ | ------------------------------------ |
| 1   | Create project CLAUDE.md     | Small  | High — persistent project context    |
| 2   | Create 6 missing stack hints | Small  | Medium — better stack-aware guidance |

### Next Skill Cycle (P2-07 Implementation)

| #   | Opportunity                                                 | Effort       | Impact                                  |
| --- | ----------------------------------------------------------- | ------------ | --------------------------------------- |
| 3   | `build-shared-content.sh`                                   | Medium       | High — core P2-07 deliverable           |
| 4   | `scaffold-skill.sh`                                         | Small-Medium | Medium — accelerates new skill creation |
| 5   | Design P2-07 mechanism for 4 additional structural sections | Small        | Medium — future-proofs extraction       |

### Validator Improvements

| #   | Opportunity                            | Effort | Impact                                  |
| --- | -------------------------------------- | ------ | --------------------------------------- |
| 6   | F-series: output consistency validator | Small  | Low-Medium — catches structural drift   |
| 7   | G-series: stale checkpoint validator   | Small  | Medium — addresses RC7 finding directly |

### New Skills (Beyond Current Roadmap)

| #   | Opportunity                      | Effort | Impact                             |
| --- | -------------------------------- | ------ | ---------------------------------- |
| 8   | `/run-retro` retrospective skill | Medium | Medium-High — closes SDLC loop     |
| 9   | `/audit-deps` dependency audit   | Medium | Medium — supply chain quality      |
| 10  | `/write-docs` technical writing  | Medium | Medium — user-facing documentation |
| 11  | `/plan-sprint` sprint planning   | Large  | Medium-High — tactical execution   |
