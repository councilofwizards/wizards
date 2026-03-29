---
title: "Role-Based Principles Split — Architecture Spec"
type: "progress-checkpoint"
feature: "Role-Based Principles Split"
agent: "Kael Stoneheart (Architect)"
status: "complete"
created: "2026-03-27"
updated: "2026-03-27"
source_roadmap_item: "docs/roadmap/P2-07-universal-principles.md"
source_stories: "docs/progress/principles-split-story-writer.md"
---

# Role-Based Principles Split — Architecture Spec

## Summary

Split `plugins/conclave/shared/principles.md` into two named sub-blocks (`universal-principles` and
`engineering-principles`), update the sync script to inject the correct block(s) per skill type, update B-series
validators for dual-block awareness, migrate all 14 multi-agent SKILL.md files to the new markers, and add a canonical
classification table to `CLAUDE.md`.

---

## Problem

The current `principles.md` has a single block with 12 principles. Items 4–8 (Minimal/clean solutions, TDD, SOLID/DRY,
Unit tests with mocks, Contracts are sacred) are engineering-specific. They are synced identically to all 14 multi-agent
skills, including 7 non-engineering skills (research-market, ideate-product, manage-roadmap, write-stories, plan-sales,
plan-hiring, draft-investor-update) whose agents cannot apply TDD or mock guidance. Low operational impact but creates
cognitive noise in context windows.

---

## Solution

### 1. Split `plugins/conclave/shared/principles.md`

Retire the outer `<!-- BEGIN SHARED: principles -->` wrapper. Replace with two named sub-blocks in the same file. The
file header notes the retirement.

**New file structure:**

```
<!-- NOTE: The outer `principles` wrapper has been retired as of P2-07.
     Content is split into two named sub-blocks for role-based injection.
     See scripts/sync-shared-content.sh for the engineering/non-engineering
     classification list. -->

<!-- BEGIN SHARED: universal-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
## Shared Principles

These principles apply to **every agent on every team**. They are included in
every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** ...
2. **Communicate constantly via the `SendMessage` tool** ...
3. **No assumptions.** ...

### ESSENTIAL — Quality Standards

9. **Document decisions, not just code.** ...
10. **Delegate mode for leads.** ...

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** ...
12. **Use Sonnet for execution agents, Opus for reasoning agents.** ...
<!-- END SHARED: universal-principles -->

<!-- BEGIN SHARED: engineering-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
## Engineering Principles

These principles apply to engineering skills only (write-spec,
plan-implementation, build-implementation, review-quality, run-task,
plan-product, build-product).

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** ...
5. **TDD by default.** ...
6. **SOLID and DRY.** ...
7. **Unit tests with mocks preferred.** ...

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** ...
<!-- END SHARED: engineering-principles -->
```

**Principle-to-block mapping (verbatim from existing principles.md):**

| Item | Section heading | Block       |
| ---- | --------------- | ----------- |
| 1    | CRITICAL        | universal   |
| 2    | CRITICAL        | universal   |
| 3    | CRITICAL        | universal   |
| 4    | IMPORTANT       | engineering |
| 5    | IMPORTANT       | engineering |
| 6    | IMPORTANT       | engineering |
| 7    | IMPORTANT       | engineering |
| 8    | ESSENTIAL       | engineering |
| 9    | ESSENTIAL       | universal   |
| 10   | ESSENTIAL       | universal   |
| 11   | NICE-TO-HAVE    | universal   |
| 12   | NICE-TO-HAVE    | universal   |

The section headings (CRITICAL, IMPORTANT, ESSENTIAL, NICE-TO-HAVE) are redistributed across the two blocks — the
engineering block re-uses IMPORTANT and ESSENTIAL headings only for its items. Universal block keeps all four heading
levels minus IMPORTANT.

---

### 2. Skill Classification

**Engineering skills** (receive both blocks):

- write-spec
- plan-implementation
- build-implementation
- review-quality
- run-task
- plan-product
- build-product

**Non-engineering skills** (receive universal block only):

- research-market
- ideate-product
- manage-roadmap
- write-stories
- plan-sales
- plan-hiring
- draft-investor-update

**Single-agent skills** (skipped — unchanged):

- setup-project
- wizard-guide

**Classification rationale:**

- `write-stories` produces artifacts for engineers but its own agents do not write code. Non-engineering.
- `run-task` is generic but may execute implementation work. Engineering (safe default: more principles, not fewer).
- `plan-product` and `build-product` orchestrate engineering sub-agents. Engineering.
- Future business skills (beyond the 3 current ones) default to non-engineering unless they generate code artifacts.
- Unknown/unclassified skills: treat as engineering at runtime, emit `WARN`.

---

### 3. Changes to `scripts/sync-shared-content.sh`

**Add classification arrays** (annotated with criteria):

```bash
# Engineering skills receive both universal-principles and engineering-principles.
# Non-engineering skills receive only universal-principles.
# Classification criteria: engineering = the skill's agents write or review code.
# Unknown skills default to engineering (safe default: more principles, not fewer).
#
# To classify a new skill: add it to one of the two arrays below.
# Also update the matching list in scripts/validators/skill-shared-content.sh.
ENGINEERING_SKILLS=(
    write-spec
    plan-implementation
    build-implementation
    review-quality
    run-task
    plan-product
    build-product
)

NON_ENGINEERING_SKILLS=(
    research-market
    ideate-product
    manage-roadmap
    write-stories
    plan-sales
    plan-hiring
    draft-investor-update
)
```

**Add helper: `is_engineering_skill`**

```bash
is_engineering_skill() {
    local name="$1"
    for s in "${ENGINEERING_SKILLS[@]}"; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}

is_known_skill() {
    local name="$1"
    for s in "${ENGINEERING_SKILLS[@]}" "${NON_ENGINEERING_SKILLS[@]}"; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}
```

**Update auth block reads.** Replace the single `auth_principles` read with two targeted reads using `extract_block`:

```bash
auth_universal="$(extract_block "$PRINCIPLES_SOURCE" \
    "<!-- BEGIN SHARED: universal-principles -->" \
    "<!-- END SHARED: universal-principles -->")"

auth_engineering="$(extract_block "$PRINCIPLES_SOURCE" \
    "<!-- BEGIN SHARED: engineering-principles -->" \
    "<!-- END SHARED: engineering-principles -->")"

if [ -z "$auth_universal" ] || [ -z "$auth_engineering" ]; then
    echo "ERROR: $PRINCIPLES_SOURCE missing universal-principles or engineering-principles sub-blocks"
    exit 1
fi
```

**Update marker existence checks.** Replace the single `principles` marker check with checks for `universal-principles`
(required for all multi-agent skills). For engineering skills also check for `engineering-principles`. If a skill still
has the old `<!-- BEGIN SHARED: principles -->` marker, emit WARN and skip:

```bash
# Transition guard: old marker not yet migrated
if grep -q "<!-- BEGIN SHARED: principles -->" "$filepath"; then
    echo "  WARN  $skill_name: Still has old 'principles' markers — migrate to universal-principles / engineering-principles, then re-run sync"
    skipped=$((skipped + 1))
    continue
fi

if ! grep -q "<!-- BEGIN SHARED: universal-principles -->" "$filepath"; then
    echo "  WARN  $skill_name: Missing universal-principles markers, skipping"
    skipped=$((skipped + 1))
    continue
fi
```

**Unknown skill WARN:**

```bash
if ! is_known_skill "$skill_name"; then
    echo "  WARN  $skill_name: Unclassified skill — defaulting to engineering (both blocks). Add to classification list in this script."
fi
```

**Block injection logic** (replaces current single `replace_block` call for principles):

```bash
# Always inject universal-principles
replace_block "$filepath" \
    "<!-- BEGIN SHARED: universal-principles -->" \
    "<!-- END SHARED: universal-principles -->" \
    "$auth_universal"

# Inject engineering-principles for engineering skills only
if is_engineering_skill "$skill_name" || ! is_known_skill "$skill_name"; then
    if grep -q "<!-- BEGIN SHARED: engineering-principles -->" "$filepath"; then
        replace_block "$filepath" \
            "<!-- BEGIN SHARED: engineering-principles -->" \
            "<!-- END SHARED: engineering-principles -->" \
            "$auth_engineering"
    else
        echo "  WARN  $skill_name: Classified as engineering but missing engineering-principles markers"
    fi
fi
```

**No changes** to communication-protocol sync logic, skeptic substitution, or single-agent skip logic.

---

### 4. Changes to `scripts/validators/skill-shared-content.sh`

#### B1: Shared Principles — dual-block awareness

Replace the current single-block B1 check with:

1. Extract `auth_universal_block` and `auth_engineering_block` from source.
2. Add the same `ENGINEERING_SKILLS` / `NON_ENGINEERING_SKILLS` arrays and helpers (copy from sync script — kept in sync
   by convention, not sourced file, per project pattern).
3. For each non-single-agent skill: a. Check `universal-principles` block exists and matches auth. Fail if missing or
   drifted. b. Check `engineering-principles` block is NOT present for non-engineering skills. Fail if found. c. For
   engineering skills: check `engineering-principles` block exists and matches auth. Fail if missing or drifted. d. If
   old `principles` marker found: fail with migration message.

**Failure messages:**

- Missing universal block:
  `"[FAIL] B1/principles-drift: Missing universal-principles block in {skill}. Fix: update markers, then run bash scripts/sync-shared-content.sh"`
- Drifted universal block:
  `"[FAIL] B1/principles-drift: universal-principles content differs in {skill}. Fix: bash scripts/sync-shared-content.sh"`
- Engineering block in non-engineering skill:
  `"[FAIL] B1/principles-drift: engineering-principles block found in non-engineering skill {skill}. Fix: remove the engineering-principles block and re-sync."`
- Missing engineering block in engineering skill:
  `"[FAIL] B1/principles-drift: engineering-principles block missing in engineering skill {skill}. Fix: add markers and run bash scripts/sync-shared-content.sh"`
- Old marker present:
  `"[FAIL] B1/principles-drift: old 'principles' marker found in {skill} — migrate to universal-principles / engineering-principles markers. Fix: update markers, then run bash scripts/sync-shared-content.sh"`

#### B3: Authoritative Source Marker

Current B3 uses `grep -q "principles"` substring match on the marker line to determine expected authoritative source
comment. This already matches `universal-principles` and `engineering-principles` (both contain the substring
"principles"), so the authoritative source comment expectation is correct for new markers.

**Additional change:** when B3 encounters `<!-- BEGIN SHARED: principles -->` (the old marker), it must flag it as
unexpected:

```bash
# Flag retired outer-principles marker
if printf '%s' "$marker_content" | grep -q "BEGIN SHARED: principles -->$"; then
    echo "[FAIL] B3/authoritative-source: Retired 'principles' marker found"
    echo "  File: $filepath"
    echo "  Fix: Replace with universal-principles / engineering-principles markers"
    b3_fail=$((b3_fail + 1))
    continue
fi
```

The pattern `BEGIN SHARED: principles -->$` (anchored at end) matches the old `<!-- BEGIN SHARED: principles -->`
exactly and does NOT match `universal-principles` or `engineering-principles`.

**B2**: No changes. Communication protocol is unaffected.

---

### 5. SKILL.md Migration (all 14 multi-agent skills)

Each of the 14 multi-agent SKILL.md files must have their principles marker region updated before the sync script can
populate them.

**Non-engineering skills** (7): Replace the single `principles` block region with a `universal-principles` placeholder:

```
<!-- BEGIN SHARED: universal-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
<!-- END SHARED: universal-principles -->
```

**Engineering skills** (7): Replace the single `principles` block region with both placeholder blocks in sequence:

```
<!-- BEGIN SHARED: universal-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
<!-- END SHARED: universal-principles -->

<!-- BEGIN SHARED: engineering-principles -->
<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->
<!-- END SHARED: engineering-principles -->
```

After SKILL.md marker migration, run `bash scripts/sync-shared-content.sh` to populate content.

---

### 6. `CLAUDE.md` Documentation Update

Add a **Skill Classification** section under "Shared Content Architecture" (or immediately before it) with the canonical
table:

```markdown
## Skill Classification

Skills are classified as engineering or non-engineering for shared content injection. Engineering skills receive both
Universal Principles and Engineering Principles blocks. Non-engineering skills receive only the Universal Principles
block. Single-agent skills are skipped entirely.

| Classification         | Skills                                                                                                         |
| ---------------------- | -------------------------------------------------------------------------------------------------------------- |
| Engineering            | write-spec, plan-implementation, build-implementation, review-quality, run-task, plan-product, build-product   |
| Non-engineering        | research-market, ideate-product, manage-roadmap, write-stories, plan-sales, plan-hiring, draft-investor-update |
| Single-agent (skipped) | setup-project, wizard-guide                                                                                    |

**`write-stories`**: non-engineering — its agents produce story artifacts but do not write code. **`run-task`**:
engineering — generic agents may implement code; engineering is the safe default. **Unknown skills**: default to
engineering at sync/validation time with a `WARN` log. Add to the list in both `sync-shared-content.sh` and
`skill-shared-content.sh`.
```

---

## Constraints

1. Do not change any principle's wording. Content is frozen; only structure changes.
2. Do not reorder principles within or across blocks. Item 4 must remain before item 5, etc.
3. Neither sub-block may be empty.
4. The outer `principles` marker is retired — it must not appear in any SKILL.md after migration. B3 flags it.
5. The `engineering-principles` block must never appear in non-engineering skills after a successful sync. B1 enforces
   this.
6. Classification lists in sync script and validator must remain identical. They are co-located in annotated comment
   blocks — not sourced from a shared file (project convention: standalone shell scripts).
7. Sync script must remain idempotent: two consecutive runs on an already-synced repo produce no file modifications.
8. All 12 validators must pass after implementation. No existing passing check may regress.
9. B2 (communication-protocol) is untouched.
10. `tier1-test` PoC skill has no shared content markers and is excluded from sync/validation — no changes needed.

---

## Out of Scope

- Changing the content of any principle (what it says).
- Adding new principles.
- Changing the Communication Protocol or skeptic-name substitution logic.
- Automated skill-type detection from SKILL.md frontmatter (would require a new `category:` field across all skills).
- Updating `tier1-test`.

---

## Files to Modify

| File                                                     | Change                                                                                                                                                                                                                             |
| -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/shared/principles.md`                  | Retire outer wrapper; add `universal-principles` and `engineering-principles` sub-blocks with correct content. Add file header note.                                                                                               |
| `scripts/sync-shared-content.sh`                         | Add `ENGINEERING_SKILLS` / `NON_ENGINEERING_SKILLS` arrays + helpers; update auth-block reads to use `extract_block`; update marker existence checks with old-marker WARN; add dual-block injection logic; add unknown-skill WARN. |
| `scripts/validators/skill-shared-content.sh`             | Update B1 for dual-block checking (missing, drifted, wrong block in wrong skill); update B3 to flag old `principles` marker; add classification arrays matching sync script.                                                       |
| `plugins/conclave/skills/research-market/SKILL.md`       | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/ideate-product/SKILL.md`        | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/manage-roadmap/SKILL.md`        | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/write-stories/SKILL.md`         | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/plan-sales/SKILL.md`            | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/plan-hiring/SKILL.md`           | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | Replace old `principles` marker region with `universal-principles` placeholder.                                                                                                                                                    |
| `plugins/conclave/skills/write-spec/SKILL.md`            | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/plan-implementation/SKILL.md`   | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/build-implementation/SKILL.md`  | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/review-quality/SKILL.md`        | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/run-task/SKILL.md`              | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/plan-product/SKILL.md`          | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `plugins/conclave/skills/build-product/SKILL.md`         | Replace old `principles` marker region with both `universal-principles` and `engineering-principles` placeholders.                                                                                                                 |
| `CLAUDE.md`                                              | Add Skill Classification section with canonical table, rationale for edge cases (write-stories, run-task), and guidance for new skill authors.                                                                                     |

---

## Implementation Order

1. Update `principles.md` (sub-blocks).
2. Update all 14 SKILL.md files (marker replacement — placeholders only, no content yet).
3. Update `sync-shared-content.sh` (classification + dual-block injection).
4. Update `skill-shared-content.sh` (B1 dual-block + B3 old-marker check).
5. Run `bash scripts/sync-shared-content.sh` (populates SKILL.md content).
6. Run `bash scripts/validate.sh` (confirm 12/12 pass).
7. Update `CLAUDE.md` (classification table).

Steps 1–4 must complete before step 5. Steps 5–6 verify the implementation. Step 7 is documentation and can follow
independently.

---

## Success Criteria

1. `plugins/conclave/shared/principles.md` contains exactly two named sub-blocks (`universal-principles` with items 1–3,
   9–12; `engineering-principles` with items 4–8). The old outer `principles` wrapper is absent.
2. Non-engineering skills (7) contain only a `universal-principles` block.
3. Engineering skills (7) contain both `universal-principles` and `engineering-principles` blocks, universal first.
4. Single-agent skills (2) are unchanged.
5. `bash scripts/sync-shared-content.sh` runs idempotently: second run produces no file changes.
6. `bash scripts/validate.sh` passes all 12 checks (0 failures).
7. B1 fails if an engineering-principles block appears in a non-engineering skill (regression guard).
8. B1 fails if an engineering skill is missing its engineering-principles block (regression guard).
9. B3 fails if any SKILL.md contains the old `<!-- BEGIN SHARED: principles -->` marker (retirement enforced).
10. `CLAUDE.md` contains the canonical classification table with rationale for `write-stories` (non-engineering) and
    `run-task` (engineering) edge cases, and guidance on classifying new skills.
