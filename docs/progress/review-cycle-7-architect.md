---
feature: "review-cycle-7"
team: "plan-product"
agent: "architect"
phase: "review"
status: "complete"
last_action: "Completed technical assessment for Review Cycle 7"
updated: "2026-02-19T00:00:00Z"
---

# Review Cycle 7 — Architect Assessment

## 1. P3-14 Implementation Readiness

**Verdict: READY for build-product team with minor notes.**

The spec (`docs/specs/plan-hiring/spec.md`) and system design (`docs/architecture/plan-hiring-system-design.md`) are
thorough and implementation-ready. The SKILL.md (`plugins/conclave/skills/plan-hiring/SKILL.md`) has already been
drafted at 1560 lines / 76KB.

### Spec Completeness

- **Agent team**: Fully specified — 6 roles with model assignments, rationale for each.
- **Debate protocol**: The 6-phase flow is precisely defined with gate conditions, transition triggers, and
  anti-premature-agreement rules.
- **Cross-examination format**: Challenge/Response/Rebuttal formats are detailed with position tracking
  (MAINTAINED/MODIFIED/CONCEDED), Points of Agreement, Concessions with impact, and Remaining Tensions.
- **Output format**: 17-section output template is fully specified with the Debate Resolution Summary as the novel
  section.
- **CI impact**: Validator changes documented — only `skill-shared-content.sh` needs 4 new sed expressions for
  bias-skeptic/fit-skeptic.
- **Failure recovery**: Agent idle fallback protocol derived from P3-10 lessons.
- **User data input**: Template, graceful degradation, and first-run behavior all specified.
- **Success criteria**: 20 specific, testable criteria.

### Technical Gaps (Minor)

1. **SKILL.md already exists.** The spec says "Files to Modify: SKILL.md — Create." But
   `plugins/conclave/skills/plan-hiring/SKILL.md` already exists at 1560 lines with full content. The build team needs
   to validate the existing SKILL.md against the spec rather than create from scratch. This is a clarification, not a
   blocker.

2. **Validator changes already applied.** The spec says `skill-shared-content.sh` needs 4 new sed expressions. These are
   already present in the current validator (lines 63-68). The build team should verify, not re-implement.

3. **Shared content is already synced.** All validators pass with plan-hiring included (7 files checked across A1-A4,
   B1-B3). The SKILL.md's shared Principles and Communication Protocol blocks are byte-identical to the authoritative
   source (plan-product/SKILL.md).

4. **`--light` mode spec discrepancy.** The spec says `--light` makes "Researcher and debate agents use Sonnet." The
   system design and SKILL.md say only "debate agents use Sonnet; Researcher remains Opus." The SKILL.md is correct per
   the Researcher model rationale (judgment-heavy research role requires Opus). The spec should be clarified, but the
   SKILL.md already implements the right behavior.

### Recommendation

P3-14 is ready for the build team. Primary work is validating the existing SKILL.md against the spec (it appears
complete) and doing a live integration test. No structural implementation work appears missing.

## 2. P2-08 Plugin Organization Assessment

**Verdict: Keep single plugin. Reorganize internal structure when skill count reaches 8.**

### Current Skill Inventory (7 skills)

| Skill                 | Type         | Pattern                | Domain      | Lines | Size |
| --------------------- | ------------ | ---------------------- | ----------- | ----- | ---- |
| plan-product          | multi-agent  | Hub-and-Spoke          | engineering | 389   | 20KB |
| build-product         | multi-agent  | Hub-and-Spoke          | engineering | 472   | 25KB |
| review-quality        | multi-agent  | Hub-and-Spoke          | engineering | 440   | 24KB |
| setup-project         | single-agent | Single-Agent           | engineering | 393   | 17KB |
| draft-investor-update | multi-agent  | Pipeline               | business    | 737   | 35KB |
| plan-sales            | multi-agent  | Collaborative Analysis | business    | 1182  | 56KB |
| plan-hiring           | multi-agent  | Structured Debate      | business    | 1560  | 76KB |

### Natural Boundary Analysis

**By domain**: 4 engineering + 3 business skills. Clean split.

- Engineering: plan-product, build-product, review-quality, setup-project
- Business: draft-investor-update, plan-sales, plan-hiring

**By collaboration pattern**: 3 Hub-and-Spoke, 1 Pipeline, 1 Collaborative Analysis, 1 Structured Debate, 1
Single-Agent. No natural grouping by pattern — each business skill uses a different pattern.

**By shared content coupling**: All 6 multi-agent skills share Shared Principles and Communication Protocol (validated
byte-identical). The single-agent skill (setup-project) correctly skips shared content checks. Splitting into separate
plugins would mean shared content management across plugin boundaries — more complex, not less.

### Recommendation: Defer Split to P2-07 Threshold

ADR-002 sets an 8-skill revision trigger for content deduplication extraction. Plugin organization should follow the
same threshold. At 7 skills, we're one skill away. Reasons to wait:

1. **Shared content management is the binding constraint.** With validated duplication across 6 multi-agent files,
   splitting plugins means either (a) duplicating the shared content validator per plugin or (b) running a cross-plugin
   validator. Both add complexity for marginal organizational benefit.

2. **No operational pain yet.** All 7 skills pass all validators. No developer has reported difficulty navigating the
   skill directory. The directory listing is clean.

3. **The 8th skill will force the decision.** When P2-07 (Universal Shared Principles) is implemented alongside skill
   #8, the shared content will likely be extracted to a plugin-scoped file. At that point, plugin boundaries become
   cleaner because the binding constraint (shared content duplication) is resolved.

4. **Business skill sizes are growing.** plan-hiring at 76KB is 3x the size of the engineering skills. If anything, the
   split should account for file size management, not just domain boundaries.

**If forced to split now**, the domain split (conclave-engineering / conclave-business) is the natural choice.
Pattern-based splitting doesn't work because each business skill uses a different pattern.

## 3. Shared Content Health

**Verdict: Healthy. No drift detected. Validator is comprehensive.**

### Current State

- **6 multi-agent skills** carry shared content (Shared Principles + Communication Protocol)
- **1 single-agent skill** (setup-project) correctly excluded from shared content checks
- **All 6 are byte-identical** for Shared Principles (B1 pass)
- **All 6 are structurally equivalent** for Communication Protocol after skeptic name normalization (B2 pass)
- **All BEGIN SHARED markers** are followed by the authoritative source comment (B3 pass)

### Validator Approach (skill-shared-content.sh)

The validator at `scripts/validators/skill-shared-content.sh` (236 lines) implements:

1. **B1 (Principles Drift)**: Extracts content between `<!-- BEGIN SHARED: principles -->` markers, compares
   byte-for-byte against plan-product/SKILL.md (authoritative source).
2. **B2 (Protocol Drift)**: Extracts communication-protocol blocks, normalizes all skeptic name variants to
   `SKEPTIC_NAME`, then compares. Currently handles 16 name variants (8 slug + 8 display name): product, quality, ops,
   accuracy, narrative, strategy, bias, fit.
3. **B3 (Authoritative Source)**: Verifies every `<!-- BEGIN SHARED -->` marker is followed by the authoritative source
   comment.
4. **Single-agent exclusion**: Properly detects `type: single-agent` in frontmatter and skips shared content checks.

### Observations

- The `normalize_skeptic_names()` function is growing (16 sed expressions). At 10+ skeptic types, consider a regex
  pattern instead. Not urgent.
- New skeptic names (bias-skeptic, fit-skeptic) are already present in the validator — no changes needed for P3-14
  build.
- plan-hiring introduces a `<!-- Contract Negotiation Pattern omitted -->` comment where build-product has a
  skill-specific section. This is correctly handled by the shared content markers (the skill-specific section is outside
  the shared markers).

## 4. Architecture Debt

**Verdict: Two items worth noting before more skills are built.**

### 4a. SKILL.md Size Growth

The business skills are significantly larger than engineering skills:

- Engineering average: ~22KB (389-472 lines)
- Business average: ~56KB (737-1560 lines)
- plan-hiring alone: 76KB / 1560 lines

This matters because SKILL.md files are loaded into agent context on every skill invocation. At 76KB, plan-hiring is
consuming meaningful context window for every agent spawn. The cross-examination format definitions
(Challenge/Response/Rebuttal) repeat similar structure for each agent role — there may be an opportunity to reduce
redundancy in future skills.

**Not a blocker** for P3-14. The `skill-structure.sh` validator bug (printf | grep truncation on >30KB files) was
already fixed in P3-10. The current validator uses `grep -qF` directly on files, handling any file size.

### 4b. ADR-002 Revision Trigger Approaching

ADR-002 sets the 8-skill trigger for extracting shared content to a plugin-scoped file. With 7 skills and several P3
business skills in the backlog (plan-marketing, plan-finance, plan-customer-success), we'll hit the trigger soon. The
markers make extraction straightforward, but the architectural decision (where the shared file lives, how skills
reference it) hasn't been designed yet.

**Recommendation**: When the 8th multi-agent skill enters spec, create ADR-003 for the extraction mechanism before
implementation begins.

### 4c. Output Directory Proliferation

Each business skill creates its own output directory:

- `docs/investor-updates/` (draft-investor-update)
- `docs/sales-plans/` (plan-sales)
- `docs/hiring-plans/` (plan-hiring)

Plus potential future: `docs/marketing-plans/`, `docs/finance-plans/`, etc. This is manageable but worth noting — the
output directory pattern is consistent, but the top-level `docs/` directory will grow. Not actionable now; revisit if
docs/ becomes cluttered.

## 5. CI/Validator Health

**Verdict: All validators passing. No known issues.**

### Validator Run Results (Current State)

| Validator                       | Result   | Files Checked |
| ------------------------------- | -------- | ------------- |
| skill-structure.sh (A1-A4)      | All PASS | 7 files       |
| skill-shared-content.sh (B1-B3) | All PASS | 7 files       |
| progress-checkpoint.sh (E1)     | PASS     | 61 files      |

### Validator Coverage for P3-14

- **skill-structure.sh**: plan-hiring SKILL.md already passes A1 (frontmatter), A2 (required sections), A3 (spawn
  definitions), A4 (shared markers). No changes needed.
- **skill-shared-content.sh**: plan-hiring's shared content already validated. bias-skeptic/fit-skeptic normalization
  already in the validator. No changes needed.
- **progress-checkpoint.sh**: Will work as-is with `team: "plan-hiring"` checkpoint files.
- **spec-frontmatter.sh**: Not applicable (output goes to docs/hiring-plans/).
- **roadmap-frontmatter.sh**: Not applicable.

### No Known Bugs

The P3-10 printf|grep truncation bug that affected >30KB files was fixed. All validators now use `grep -qF` directly on
files. The plan-hiring SKILL.md at 76KB passes all checks, confirming the fix works at scale.

## Summary

| Area              | Verdict | Action Needed                                                              |
| ----------------- | ------- | -------------------------------------------------------------------------- |
| P3-14 readiness   | Ready   | Build team validates existing SKILL.md against spec; live integration test |
| P2-08 plugin org  | Defer   | Keep single plugin; revisit at skill #8 alongside ADR-002 extraction       |
| Shared content    | Healthy | No drift; all validators pass with 7 skills                                |
| Architecture debt | Minor   | Note SKILL.md size growth; plan ADR-003 for extraction when #8 enters spec |
| CI/Validators     | Clean   | All passing; no changes needed for P3-14                                   |
