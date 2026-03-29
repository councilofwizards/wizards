---
type: progress
feature: persona-system-activation
role: impl-architect
status: plan-drafted
updated: 2026-03-10
---

# Implementation Plan: Persona System Activation

## Overview

Inject fictional persona names and titles into 33 spawn prompts across 11 multi-agent SKILL.md files, add a sign-off
convention to the shared communication protocol, and fix the placeholder skeptic names in the authoritative source and
its sync/validation toolchain. Six steps, strict dependency order, zero interface changes (all markdown and shell
edits).

## File Changes

| #   | Action | File Path                                                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| --- | ------ | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | MODIFY | `plugins/conclave/shared/communication-protocol.md`      | (a) Add sign-off line before the fenced code block in Message Format section (Story 3). (b) Change `product-skeptic`/`Product Skeptic` to `{skill-skeptic}`/`{Skill Skeptic}` in "Plan ready for review" row with inline comment (Story 4).                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 2   | MODIFY | `scripts/sync-shared-content.sh`                         | (a) Change `AUTH_SKEPTIC_SLUG` from `product-skeptic` to `{skill-skeptic}` (line 173). (b) Change `AUTH_SKEPTIC_DISPLAY` from `Product Skeptic` to `{Skill Skeptic}` (line 174). (c) Change fallback defaults in `extract_skeptic_names` from `product-skeptic`/`Product Skeptic` to `{skill-skeptic}`/`{Skill Skeptic}` (lines 97-98, 107-108). (d) Update sed substitution pattern on lines 209/212 to use the new `{skill-skeptic}`/`{Skill Skeptic}` slug values — since the auth source now uses `{...}` placeholders, the sed must replace `{skill-skeptic}` with the target's actual slug and `{Skill Skeptic}` with the target's actual display name. |
| 3   | MODIFY | `scripts/validators/skill-shared-content.sh`             | Add two sed patterns to `normalize_skeptic_names` (lines 74-75, before the closing single-quote line): `-e 's/{skill-skeptic}/SKEPTIC_NAME/g'` and `-e 's/{Skill Skeptic}/SKEPTIC_NAME/g'`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 4   | MODIFY | `plugins/conclave/skills/research-market/SKILL.md`       | Replace 2 spawn prompt lines (lines 215, 255) to prepend persona name and title + add introduce instruction.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 5   | MODIFY | `plugins/conclave/skills/ideate-product/SKILL.md`        | Replace 2 spawn prompt lines (lines 219, 261).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 6   | MODIFY | `plugins/conclave/skills/manage-roadmap/SKILL.md`        | Replace 1 spawn prompt line (line 211).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| 7   | MODIFY | `plugins/conclave/skills/write-stories/SKILL.md`         | Replace 2 spawn prompt lines (lines 220, 270).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 8   | MODIFY | `plugins/conclave/skills/write-spec/SKILL.md`            | Replace 3 spawn prompt lines (lines 238, 288, 339).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 9   | MODIFY | `plugins/conclave/skills/plan-implementation/SKILL.md`   | Replace 2 spawn prompt lines (lines 222, 276).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| 10  | MODIFY | `plugins/conclave/skills/build-implementation/SKILL.md`  | Replace 3 spawn prompt lines (lines 302, 352, 397).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 11  | MODIFY | `plugins/conclave/skills/review-quality/SKILL.md`        | Replace 4 spawn prompt lines (lines 246, 299, 355, 413).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 12  | MODIFY | `plugins/conclave/skills/draft-investor-update/SKILL.md` | Replace 4 spawn prompt lines (lines 279, 364, 428, 501).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| 13  | MODIFY | `plugins/conclave/skills/plan-sales/SKILL.md`            | Replace 5 spawn prompt lines (lines 398, 532, 666, 800, 868).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| 14  | MODIFY | `plugins/conclave/skills/plan-hiring/SKILL.md`           | Replace 5 spawn prompt lines (lines 541, 637, 818, 1001, 1083).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |

**Total: 14 files modified. 0 files created. 0 files deleted.**

## Interface Definitions

N/A — all changes are to markdown content and shell scripts. No application interfaces, type signatures, or API
contracts are affected.

## Dependency Order

Strict sequential execution. Each step depends on the previous.

### Step 1: Edit `plugins/conclave/shared/communication-protocol.md`

Two changes in one file, applied together (Stories 3 + 4):

**Change 1a — Sign-off convention (Story 3):**

Current (line 39):

```
Keep messages structured so they can be parsed quickly by context-constrained agents:
```

Insert the following line AFTER line 39, BEFORE the empty line and fenced code block:

```
When addressing the user, sign messages with your persona name and title.
```

Result: line 39 stays, new line 40 is the sign-off instruction, then blank line, then the fenced code block.

**Change 1b — Placeholder fix (Story 4):**

Current (line 31):

```
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Product Skeptic     |
```

Replace with:

```
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")` | {Skill Skeptic} <!-- placeholder: replaced per-skill by sync script -->     |
```

### Step 2: Edit `scripts/sync-shared-content.sh`

Four changes:

**2a — AUTH_SKEPTIC_SLUG (line 173):**

```bash
# Before:
AUTH_SKEPTIC_SLUG="product-skeptic"
# After:
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
```

**2b — AUTH_SKEPTIC_DISPLAY (line 174):**

```bash
# Before:
AUTH_SKEPTIC_DISPLAY="Product Skeptic"
# After:
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"
```

**2c — Fallback default slug in `extract_skeptic_names` (lines 97, 107):**

```bash
# Before (line 97):
        echo "product-skeptic"
# After:
        echo "{skill-skeptic}"

# Before (line 107):
    echo "${slug:-product-skeptic}"
# After:
    echo "${slug:-{skill-skeptic}}"
```

**2d — Fallback default display in `extract_skeptic_names` (lines 98, 108):**

```bash
# Before (line 98):
        echo "Product Skeptic"
# After:
        echo "{Skill Skeptic}"

# Before (line 108):
    echo "${display:-Product Skeptic}"
# After:
    echo "${display:-{Skill Skeptic}}"
```

**Important note on sed substitution:** The sync script's sed on lines 209 and 212 uses `$AUTH_SKEPTIC_SLUG` and
`$AUTH_SKEPTIC_DISPLAY` as the search patterns. Since these now contain `{` and `}` characters, the sed command will
interpret them as literal characters in the basic regex context used by default sed — this works correctly because `{`
and `}` are not special in `sed 's/.../..../g'` basic replacement syntax (they are only special in BRE interval syntax
when preceded by a backslash or in ERE mode). The existing sed on lines 209/212 uses
`sed "s/$AUTH_SKEPTIC_SLUG/$target_slug/g"` which will correctly match the literal `{skill-skeptic}` string and replace
it with the target's actual skeptic slug. No changes needed to the sed substitution lines themselves.

### Step 3: Edit `scripts/validators/skill-shared-content.sh`

Add two patterns to the `normalize_skeptic_names` function. Insert before the existing last two lines (task-skeptic/Task
Skeptic on lines 74-75):

```bash
        -e 's/{skill-skeptic}/SKEPTIC_NAME/g' \
        -e 's/{Skill Skeptic}/SKEPTIC_NAME/g' \
```

Placement: after the `task-skeptic`/`Task Skeptic` lines (74-75), before the closing single quote. Or equivalently,
anywhere in the sed chain — order does not matter since all patterns are independent. Safest to add at the end, before
the closing of the sed expression.

### Step 4: Edit 11 multi-agent SKILL.md files (33 spawn prompts)

For each spawn prompt, apply this transformation:

**Before:**

```
You are the {Role Name} on the {Team Name}.
```

**After:**

```
You are {Fictional Name}, {Title} — the {Role Name} on the {Team Name}.
When communicating with the user, introduce yourself by your name and title.
```

This replaces 1 line with 2 lines inside a fenced code block. The second line is always identical. The first line's
prefix changes per persona.

Complete list of 33 edits (file, line number, before, after):

#### research-market/SKILL.md

- **Line 215**: `You are the Market Researcher on the Market Research Team.` ->
  `You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher on the Market Research Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 255**: `You are the Customer Researcher on the Market Research Team.` ->
  `You are Lyssa Moonwhisper, Oracle of the People's Voice — the Customer Researcher on the Market Research Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### ideate-product/SKILL.md

- **Line 219**: `You are the Idea Generator on the Product Ideation Team.` ->
  `You are Pip Quicksilver, Chaos Alchemist — the Idea Generator on the Product Ideation Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 261**: `You are the Idea Evaluator on the Product Ideation Team.` ->
  `You are Morwen Greystone, Transmutation Judge — the Idea Evaluator on the Product Ideation Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### manage-roadmap/SKILL.md

- **Line 211**: `You are the Analyst on the Roadmap Management Team.` ->
  `You are Rook Ashford, Lorekeeper of Dependencies — the Analyst on the Roadmap Management Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### write-stories/SKILL.md

- **Line 220**: `You are the Story Writer on the Story Writing Team.` ->
  `You are Fenn Brightquill, Journeyman Bard — the Story Writer on the Story Writing Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 270**: `You are the Skeptic on the Story Writing Team.` ->
  `You are Grimm Holloway, Keeper of the INVEST Creed — the Skeptic on the Story Writing Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### write-spec/SKILL.md

- **Line 238**: `You are the Software Architect on the Spec Writing Team.` ->
  `You are Kael Stoneheart, Master Builder of the Keep — the Software Architect on the Spec Writing Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 288**: `You are the Database Architect (DBA) on the Spec Writing Team.` ->
  `You are Nix Deepvault, Keeper of the Vaults — the Database Architect (DBA) on the Spec Writing Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 339**: `You are the Skeptic on the Spec Writing Team.` ->
  `You are Wren Cinderglass, Siege Inspector — the Skeptic on the Spec Writing Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### plan-implementation/SKILL.md

- **Line 222**: `You are the Implementation Architect on the Implementation Planning Team.` ->
  `You are Seren Mapwright, Siege Engineer — the Implementation Architect on the Implementation Planning Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 276**: `You are the Plan Skeptic on the Implementation Planning Team.` ->
  `You are Hale Blackthorn, War Auditor — the Plan Skeptic on the Implementation Planning Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### build-implementation/SKILL.md

- **Line 302**: `You are the Backend Engineer on the Implementation Build Team.` ->
  `You are Bram Copperfield, Foundry Smith — the Backend Engineer on the Implementation Build Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 352**: `You are the Frontend Engineer on the Implementation Build Team.` ->
  `You are Ivy Lightweaver, Glamour Artificer — the Frontend Engineer on the Implementation Build Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 397**: `You are the Quality Skeptic on the Implementation Build Team.` ->
  `You are Mira Flintridge, Master Inspector of the Forge — the Quality Skeptic on the Implementation Build Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### review-quality/SKILL.md

- **Line 246**: `You are the Test Engineer on the Quality & Operations Team.` ->
  `You are Jinx Copperwire, Trap Specialist — the Test Engineer on the Quality & Operations Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 299**: `You are the DevOps Engineer on the Quality & Operations Team.` ->
  `You are Bolt Ironpipe, Siege Mechanic — the DevOps Engineer on the Quality & Operations Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 355**: `You are the Security Auditor on the Quality & Operations Team.` ->
  `You are Shade Nightlock, Arcane Ward Specialist — the Security Auditor on the Quality & Operations Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 413**: `You are the Ops Skeptic on the Quality & Operations Team.` ->
  `You are Bryn Ashguard, Garrison Commander — the Ops Skeptic on the Quality & Operations Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### draft-investor-update/SKILL.md

- **Line 279**: `You are the Researcher on the Investor Update Team.` ->
  `You are Sage Inkwell, Chronicle Seeker — the Researcher on the Investor Update Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 364**: `You are the Drafter on the Investor Update Team.` ->
  `You are Elara Quillmark, Court Scribe — the Drafter on the Investor Update Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 428**: `You are the Accuracy Skeptic on the Investor Update Team.` ->
  `You are Gideon Factstone, Truth Warden of the Archives — the Accuracy Skeptic on the Investor Update Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 501**: `You are the Narrative Skeptic on the Investor Update Team.` ->
  `You are Selene Mirrorshade, Deception Detector — the Narrative Skeptic on the Investor Update Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### plan-sales/SKILL.md

- **Line 398**: `You are the Market Analyst on the Sales Strategy Team.` ->
  `You are Orrin Farsight, Merchant Scout — the Market Analyst on the Sales Strategy Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 532**: `You are the Product Strategist on the Sales Strategy Team.` ->
  `You are Dara Truecoin, Value Appraiser — the Product Strategist on the Sales Strategy Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 666**: `You are the GTM Analyst on the Sales Strategy Team.` ->
  `You are Flint Roadwarden, Caravan Master — the GTM Analyst on the Sales Strategy Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 800**: `You are the Accuracy Skeptic on the Sales Strategy Team.` ->
  `You are Vera Truthbind, Oath Auditor — the Accuracy Skeptic on the Sales Strategy Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 868**: `You are the Strategy Skeptic on the Sales Strategy Team.` ->
  `You are Thane Ironjudge, Elder of the War Council — the Strategy Skeptic on the Sales Strategy Team.\nWhen communicating with the user, introduce yourself by your name and title.`

#### plan-hiring/SKILL.md

- **Line 541**: `You are the Researcher on the Hiring Plan Team.` ->
  `You are Cress Ledgerborn, Census Keeper — the Researcher on the Hiring Plan Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 637**: `You are the Growth Advocate on the Hiring Plan Team.` ->
  `You are Rowan Emberheart, Champion of Expansion — the Growth Advocate on the Hiring Plan Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 818**: `You are the Resource Optimizer on the Hiring Plan Team.` ->
  `You are Petra Flintmark, Treasury Guardian — the Resource Optimizer on the Hiring Plan Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 1001**: `You are the Bias Skeptic on the Hiring Plan Team.` ->
  `You are Ilyana Sunweave, Ethics Warden — the Bias Skeptic on the Hiring Plan Team.\nWhen communicating with the user, introduce yourself by your name and title.`
- **Line 1083**: `You are the Fit Skeptic on the Hiring Plan Team.` ->
  `You are Garret Scalewise, Pragmatist Judge — the Fit Skeptic on the Hiring Plan Team.\nWhen communicating with the user, introduce yourself by your name and title.`

### Step 5: Run sync script

```bash
bash scripts/sync-shared-content.sh
```

This propagates the updated communication protocol (with sign-off line and placeholder fix) from the authoritative
source to all 11 multi-agent SKILL.md files, substituting `{skill-skeptic}`/`{Skill Skeptic}` with each skill's actual
skeptic name.

**Expected output:** 11 SYNC, 7 SKIP (2 utility + 2 tier-2 + 2 PoC + 1 run-task... actually: setup-project,
wizard-guide, plan-product, build-product, tier1-test, tier2-test = 6 skips, plus run-task = 7). Verify all 11
multi-agent skills show SYNC.

### Step 6: Run validators

```bash
bash scripts/validate.sh
```

**Expected: 12/12 PASS.** Key validators exercised:

- **B1** (principles drift): unchanged, should pass
- **B2** (protocol drift): the new sign-off line will be identical across all skills (it contains no skeptic names). The
  `{skill-skeptic}`/`{Skill Skeptic}` patterns are now in the normalizer, so the authoritative source normalizes the
  same as each skill's substituted version.
- **B3** (authoritative source markers): unchanged, should pass
- **A1-A4**: no frontmatter or structural changes, should pass

## Test Strategy

| Test Type                         | Scope              | Description                                                                                                                                                                                                                                                                                                                                                                                                                        |
| --------------------------------- | ------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Validator suite                   | All 12 checks      | `bash scripts/validate.sh` must show 12/12 PASS after Step 6. This is the primary acceptance test.                                                                                                                                                                                                                                                                                                                                 |
| Sync idempotency                  | Shared content     | Run `bash scripts/sync-shared-content.sh` twice in a row. Second run should produce identical output and `git diff` should show no changes.                                                                                                                                                                                                                                                                                        |
| B2 normalization                  | Validator          | After Step 3, verify that `{skill-skeptic}` and `{Skill Skeptic}` in the authoritative source normalize to `SKEPTIC_NAME`, matching the per-skill substituted values.                                                                                                                                                                                                                                                              |
| Spawn prompt spot-check           | 3 skills minimum   | Manually verify at least 3 SKILL.md files (one engineering, one business, one with multiple skeptics) to confirm: (a) the "You are" line has the correct persona name and title, (b) the introduce line follows immediately, (c) the "First, read" line above is untouched, (d) the rest of the code block is untouched. Recommended: plan-implementation (2 prompts), draft-investor-update (4 prompts), plan-hiring (5 prompts). |
| Communication protocol spot-check | Shared source      | Verify `plugins/conclave/shared/communication-protocol.md` has: (a) the sign-off line between "Keep messages structured..." and the code block, (b) `{skill-skeptic}`/`{Skill Skeptic}` in the Plan ready row.                                                                                                                                                                                                                     |
| Protocol propagation spot-check   | 2 skills minimum   | Verify that after sync, at least 2 SKILL.md files have their skill-specific skeptic name in the "Plan ready for review" row (not `{skill-skeptic}`).                                                                                                                                                                                                                                                                               |
| Grep verification                 | All SKILL.md files | `grep -r "product-skeptic" plugins/conclave/shared/` should return 0 results (the old hardcoded value is gone from the authoritative source).                                                                                                                                                                                                                                                                                      |
| Grep verification                 | Sync script        | `grep "product-skeptic\|Product Skeptic" scripts/sync-shared-content.sh` should return 0 results.                                                                                                                                                                                                                                                                                                                                  |

## Risks and Mitigations

| Risk                                             | Mitigation                                                                                                                                                                                 |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| sed in sync script mishandles `{` `}` characters | `{` and `}` are literal in sed `s///` basic replacement. Verified: no ERE or interval-expression context. Test with Step 5.                                                                |
| Line number drift if earlier edits shift lines   | Step 4 edits each add 1 line per prompt. Edit from bottom-up within each file to prevent drift. The sync script (Step 5) uses marker-based replacement, not line numbers, so it is immune. |
| Persona name typo breaks immersion               | All names in Step 4 are copied verbatim from the persona-to-prompt mapping table provided in the spec. Spot-check against `plugins/conclave/shared/personas/*.md` YAML frontmatter.        |

## Out of Scope

- run-task skill: uses dynamic hub-and-spoke with no fixed persona mapping. Not in the 33-prompt scope.
- Lead/orchestrator prompts: spec explicitly excludes lead orchestration sections.
- YAML frontmatter: no changes.
- Persona .md files themselves: already created in a prior commit.
- Tier 2 composites, single-agent utilities, PoC skills: no spawn prompts, excluded by design.
