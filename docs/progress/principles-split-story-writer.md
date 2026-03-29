---
type: "user-stories"
feature: "Role-Based Principles Split"
status: "draft"
source_roadmap_item: "docs/roadmap/P2-07-universal-principles.md"
approved_by: ""
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Role-Based Principles Split

## Epic Summary

The `plugins/conclave/shared/principles.md` file currently contains 12
principles — 7 universal ones and 5 engineering-specific ones (minimal/clean
solutions, TDD, SOLID/DRY, unit tests with mocks, API contracts). All 12 are
synced identically to every multi-agent skill, including non-engineering skills
(research-market, ideate-product, manage-roadmap, plan-sales, plan-hiring,
draft-investor-update) whose agents cannot act on TDD or mock guidance. This
split removes cognitive noise in non-engineering skill contexts while keeping
engineering skills whole.

---

## Stories

### Story 1: Split Shared Principles into Universal and Engineering Blocks

- **As a** skill author
- **I want** `plugins/conclave/shared/principles.md` to contain two clearly
  delimited blocks — a universal block (items 1–3, 9–12) and an engineering
  block (items 4–8) — each wrapped in their own HTML marker pairs
- **So that** the sync script can inject the right subset into each skill
  without managing two separate source files

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the current `principles.md` file, when the split is applied, then a
     `<!-- BEGIN SHARED: universal-principles -->` /
     `<!-- END SHARED: universal-principles -->` block exists containing
     principles 1–3 and 9–12 (Skeptic sign-off, Communicate, No assumptions,
     Document decisions, Delegate mode, Progressive disclosure, Sonnet/Opus
     guidance).
  2. Given the split file, when it is read, then a
     `<!-- BEGIN SHARED: engineering-principles -->` /
     `<!-- END SHARED: engineering-principles -->` block exists containing
     principles 4–8 (Minimal/clean solutions, TDD, SOLID/DRY, Unit tests with
     mocks, Contracts are sacred).
  3. Given the split file, when the existing `<!-- BEGIN SHARED: principles -->`
     / `<!-- END SHARED: principles -->` outer wrapper is checked, then it
     either no longer exists OR it wraps both sub-blocks — the decision must be
     documented as a note in the file header.
  4. Given the authoritative source comment convention
     (`<!-- Authoritative source: ... -->`), when either sub-block begins, then
     the authoritative source comment follows immediately on the next line.
  5. Given the split file, when its content is validated, then
     `bash scripts/validate.sh` passes with 12/12 checks (F-series checks are
     not affected; B-series checks must be updated separately per Story 3).

- **Edge Cases**:
  - Wrapper removal: If the outer `principles` marker is removed, B3 must not
    flag missing authoritative source on markers that no longer exist. Story 3
    handles this.
  - Principle ordering: Engineering principles must remain in their original
    sequence (4→8) inside the engineering block. Do not reorder items.
  - Empty blocks: Neither block may be empty. If a principle is ambiguous (e.g.,
    "Minimal, clean solutions" — item 4), place it in the engineering block per
    the roadmap spec (items 4–8 = engineering).

- **Notes**: The simplest implementation is two named sub-blocks within the same
  file, with no outer `principles` wrapper. The sync script already reads the
  whole file; switching to named-block extraction is a contained change. The
  outer wrapper can be retired.

---

### Story 2: Update Sync Script to Inject Correct Block Per Skill Type

- **As a** developer running `bash scripts/sync-shared-content.sh`
- **I want** the script to detect whether each skill is an engineering skill or
  a non-engineering skill and inject only the appropriate principles block(s)
- **So that** non-engineering skills receive only universal principles and
  engineering skills receive both universal and engineering principles,
  automatically, on every sync run

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a non-engineering multi-agent skill (research-market, ideate-product,
     manage-roadmap, write-stories, plan-sales, plan-hiring,
     draft-investor-update), when `sync-shared-content.sh` runs, then only the
     `<!-- BEGIN SHARED: universal-principles -->` block is written into the
     skill's principles marker region.
  2. Given an engineering multi-agent skill (write-spec, plan-implementation,
     build-implementation, review-quality, run-task, plan-product,
     build-product), when `sync-shared-content.sh` runs, then both the universal
     and engineering principles blocks are written into the skill's principles
     marker region in order (universal first, engineering second).
  3. Given a single-agent skill (setup-project, wizard-guide), when
     `sync-shared-content.sh` runs, then the skill is skipped exactly as before
     — no change to existing skip logic.
  4. Given an unknown/unclassified skill name, when `sync-shared-content.sh`
     runs, then the script treats it as engineering (safe default: more
     principles, not fewer), logs a `WARN` line naming the skill and the default
     applied, and continues without error.
  5. Given the sync is run twice on the same repo state, then the output is
     byte-identical to the first run (idempotent).
  6. Given the sync completes, when `bash scripts/validate.sh` is run, then all
     B-series checks pass.

- **Edge Cases**:
  - Pipeline skills: `plan-product` and `build-product` orchestrate engineering
    sub-agents; classify them as engineering so they receive the full principles
    block.
  - `run-task` is generic but its agents may implement code; classify as
    engineering per the roadmap spec.
  - `write-stories` does not write code but produces artifacts consumed by
    engineering skills; the roadmap excludes it from the engineering list (it is
    not in "write-spec, plan-implementation, build-implementation,
    review-quality, run-task"). Classify as non-engineering. Confirm with
    Story 4.
  - Skill classification must be maintained as a hardcoded list (not derived
    from `type:` field or directory heuristics) since there is no existing
    metadata field for engineering vs. non-engineering.
  - Marker names in target SKILL.md files must be updated to match the new
    sub-block marker names (`universal-principles`, `engineering-principles`)
    before or during sync. The sync script should handle the transition: if a
    skill still has the old `principles` markers, emit `WARN` and skip rather
    than silently corrupt the file.

- **Notes**: The classification list in the script should be clearly annotated
  with a comment explaining the criteria, making it easy for future skill
  authors to classify new skills correctly.

---

### Story 3: Update B-Series Validators for Dual-Block Awareness

- **As a** developer running `bash scripts/validate.sh`
- **I want** the B1 and B3 validators to check the correct principles block(s)
  per skill type — universal-only for non-engineering skills, universal +
  engineering for engineering skills
- **So that** drift is caught accurately and engineering skills aren't falsely
  flagged for missing engineering principles, nor non-engineering skills falsely
  flagged for having them

- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a non-engineering skill whose
     `<!-- BEGIN SHARED: universal-principles -->` block matches the
     authoritative source, when B1 runs, then the check passes for that skill.
  2. Given a non-engineering skill that incorrectly contains an
     `<!-- BEGIN SHARED: engineering-principles -->` block, when B1 runs, then
     the check fails with a message indicating the engineering block should not
     be present in a non-engineering skill.
  3. Given an engineering skill whose both `universal-principles` and
     `engineering-principles` blocks match authoritative source, when B1 runs,
     then the check passes.
  4. Given an engineering skill missing the `engineering-principles` block, when
     B1 runs, then the check fails with a clear message identifying the missing
     block and the fix command (`bash scripts/sync-shared-content.sh`).
  5. Given a single-agent skill, when B1 runs, then the skill is skipped as
     before — no change to existing skip logic.
  6. Given any `<!-- BEGIN SHARED: universal-principles -->` or
     `<!-- BEGIN SHARED: engineering-principles -->` marker, when B3 runs, then
     the authoritative source comment must appear on the immediately following
     line; a missing or incorrect comment causes a B3 fail.
  7. Given `bash scripts/validate.sh` is run on a fully synced repo, then all 12
     validators pass (0 failures).

- **Edge Cases**:
  - Old markers: If a skill still contains the old
    `<!-- BEGIN SHARED: principles -->` marker (not yet migrated), B3 must flag
    it as unexpected and indicate the migration fix, rather than silently
    passing.
  - B2 (protocol-drift) is not affected by this story — communication-protocol
    markers and skeptic-name normalization are unchanged.
  - The B1 check currently uses byte-identity comparison. With the split,
    non-engineering skills will only contain the universal block — the
    comparison must be made against the universal block extracted from the
    authoritative source, not the full principles file. The validator must
    extract the correct sub-block for comparison.
  - Unclassified skills: Same safe default as Story 2 — treat as engineering in
    the validator, log a warning.

- **Notes**: The skill classification list in the validator must stay in sync
  with the list in the sync script. Consider extracting it to a shared variable
  or sourced file to avoid duplication drift between the two scripts.

---

### Story 4: Document Engineering vs Non-Engineering Skill Classification

- **As a** skill author adding a new skill to the conclave plugin
- **I want** the classification of existing skills (engineering vs.
  non-engineering) to be documented in a single canonical location — either
  CLAUDE.md or a comment block in both the sync script and validator
- **So that** I know where to add my new skill's classification without reading
  both scripts and risking them falling out of sync

- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given a new skill author reading CLAUDE.md or the sync script header
     comments, when they look for where to classify a new skill, then they find
     an explicit, human-readable list of which skills are engineering and which
     are non-engineering, along with the classification criteria.
  2. Given the authoritative classification list, when a new skill is added to
     the plugins directory, then the list contains an entry for that skill
     before a sync is run (enforced by a `WARN` in the sync script per Story 2
     AC4, not by a hard failure).
  3. Given the list in CLAUDE.md (if updated there), when the sync script and B1
     validator are compared, then both reference the same canonical skill names
     — no silent divergence.
  4. Given the classification criteria, when applied to the 14 existing
     multi-agent skills, then the result matches the authoritative
     classification defined in this roadmap item: engineering = write-spec,
     plan-implementation, build-implementation, review-quality, run-task,
     plan-product, build-product; non-engineering = research-market,
     ideate-product, manage-roadmap, write-stories, plan-sales, plan-hiring,
     draft-investor-update.

- **Edge Cases**:
  - `write-stories` is borderline (produces artifacts for engineers) but its own
    agents do not write code. Keep non-engineering per the roadmap spec. The
    documentation should note this reasoning explicitly.
  - `run-task` is generic but receives engineering principles as a safe default.
    Document this explicitly.
  - Future business skills (any new additions beyond plan-sales, plan-hiring,
    draft-investor-update) should default to non-engineering unless they
    explicitly generate code artifacts.

- **Notes**: The simplest implementation is a well-annotated comment block in
  both scripts (sync + validator) rather than a shared sourced file — the
  project convention is standalone shell scripts, and introducing a sourced
  config file adds complexity. CLAUDE.md should contain the canonical prose
  table.

---

## Non-Functional Requirements

- **Idempotency**: `sync-shared-content.sh` must remain idempotent after all
  changes. Running it twice on an already-synced repo must produce no file
  modifications.
- **Backward compatibility during migration**: Skills not yet migrated to new
  markers must produce `WARN` output (not hard failures) to allow a staged
  rollout.
- **Validator performance**: No meaningful runtime increase — B1 now checks one
  or two blocks per skill (same O(n) complexity).
- **Zero validator regressions**: The 12/12 pass count must be maintained. No
  existing passing check may start failing as a side effect of this work.

## Out of Scope

- Changing which principles appear in either block (content changes to the
  principles themselves are a separate concern).
- Adding new principles beyond the current 12.
- Changing the Communication Protocol (`communication-protocol.md`) — the
  skeptic-name substitution logic is untouched.
- Updating the `tier1-test` PoC skill — it has no shared content markers and is
  excluded from sync/validation.
- Automated detection of skill type from frontmatter (requires adding a new
  `category:` field to all skill SKILL.md files — out of scope for this item).
