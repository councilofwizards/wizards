---
type: "implementation-plan"
feature: "persona-system-activation"
status: "approved"
source_spec: "docs/specs/persona-system-activation/spec.md"
approved_by:
  "Hale Blackthorn, War Auditor; Dax Ironhand, Battle Planner (Lead-as-Skeptic)"
created: "2026-03-10"
updated: "2026-03-10"
---

# Implementation Plan: Persona System Activation

## Overview

Inject fictional persona names and titles into 33 spawn prompts across 11
multi-agent SKILL.md files, add a sign-off convention to the shared
communication protocol, and fix the placeholder skeptic names in the
authoritative source and its sync/validation toolchain. Six steps in strict
dependency order. All changes are markdown edits and shell script modifications
— no application code.

## File Changes

| Action | File Path                                                | Description                                                                                                                                                                                                            |
| ------ | -------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| modify | `plugins/conclave/shared/communication-protocol.md`      | Add sign-off line in Message Format section (Story 3). Change `product-skeptic`/`Product Skeptic` to `{skill-skeptic}`/`{Skill Skeptic}` in "Plan ready for review" row with inline comment after last pipe (Story 4). |
| modify | `scripts/sync-shared-content.sh`                         | Update AUTH_SKEPTIC_SLUG/DISPLAY to `{skill-skeptic}`/`{Skill Skeptic}`. Update fallback defaults in `extract_skeptic_names`.                                                                                          |
| modify | `scripts/validators/skill-shared-content.sh`             | Add `{skill-skeptic}` and `{Skill Skeptic}` patterns to `normalize_skeptic_names`.                                                                                                                                     |
| modify | `plugins/conclave/skills/research-market/SKILL.md`       | 2 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/ideate-product/SKILL.md`        | 2 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/manage-roadmap/SKILL.md`        | 1 spawn prompt identity line + intro instruction                                                                                                                                                                       |
| modify | `plugins/conclave/skills/write-stories/SKILL.md`         | 2 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/write-spec/SKILL.md`            | 3 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/plan-implementation/SKILL.md`   | 2 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/build-implementation/SKILL.md`  | 3 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/review-quality/SKILL.md`        | 4 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/draft-investor-update/SKILL.md` | 4 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/plan-sales/SKILL.md`            | 5 spawn prompt identity lines + intro instructions                                                                                                                                                                     |
| modify | `plugins/conclave/skills/plan-hiring/SKILL.md`           | 5 spawn prompt identity lines + intro instructions                                                                                                                                                                     |

**Total: 14 files modified. 0 files created. 0 files deleted.**

## Interface Definitions

N/A — all changes are to markdown content and shell scripts. No application
interfaces, type signatures, or API contracts.

## Dependency Order

Strict sequential execution. Each step depends on the previous.

### Step 1: Edit `plugins/conclave/shared/communication-protocol.md`

Two changes in one file, applied together (Stories 3 + 4). Do NOT run sync
between them.

**Change 1a — Sign-off convention (Story 3):**

Insert the following line after "Keep messages structured so they can be parsed
quickly by context-constrained agents:" (line 39), before the blank line and
fenced code block:

```
When addressing the user, sign messages with your persona name and title.
```

Result: line 39 stays, new line 40 is the sign-off instruction, then blank line,
then the fenced code block.

**Change 1b — Placeholder fix (Story 4):**

Replace line 31:

```
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")`     | Product Skeptic     |
```

With (comment placed AFTER the last pipe delimiter, not inside the cell):

```
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")`     | {Skill Skeptic}     |<!-- substituted by sync-shared-content.sh per skill -->
```

**Critical**: The `<!-- comment -->` goes after the final `|`, placing it in awk
field $5. This keeps `extract_skeptic_names` field $4 extraction clean and
preserves sync idempotency.

### Step 2: Edit `scripts/sync-shared-content.sh`

Four changes:

**2a — AUTH_SKEPTIC_SLUG (line 173):**

```bash
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
```

**2b — AUTH_SKEPTIC_DISPLAY (line 174):**

```bash
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"
```

**2c — Fallback slug defaults in `extract_skeptic_names`:**

```bash
# Line 97: echo "product-skeptic"  →  echo "{skill-skeptic}"
# Line 107: echo "${slug:-product-skeptic}"  →  echo "${slug:-{skill-skeptic}}"
```

**2d — Fallback display defaults in `extract_skeptic_names`:**

```bash
# Line 98: echo "Product Skeptic"  →  echo "{Skill Skeptic}"
# Line 108: echo "${display:-Product Skeptic}"  →  echo "${display:-{Skill Skeptic}}"
```

**Note on sed safety:** The sync script's sed on lines 209/212 uses
`$AUTH_SKEPTIC_SLUG` and `$AUTH_SKEPTIC_DISPLAY` as search patterns. `{` and `}`
are literal in sed `s///` basic replacement syntax (not special in BRE without
backslash). No changes needed to the sed substitution lines.

### Step 3: Edit `scripts/validators/skill-shared-content.sh`

Add two new `-e` lines to `normalize_skeptic_names` after line 75
(`'Task Skeptic'`), continuing the backslash chain, before the function's
closing on line 76:

```bash
        -e 's/{skill-skeptic}/SKEPTIC_NAME/g' \
        -e 's/{Skill Skeptic}/SKEPTIC_NAME/g' \
```

These ensure the B2 normalizer treats `{skill-skeptic}` in the authoritative
source the same as per-skill substituted names in SKILL.md files.

### Step 4: Edit 11 multi-agent SKILL.md files (33 spawn prompts)

**Important: Within each file, apply edits bottom-up (highest line number first)
to prevent line drift.**

For each spawn prompt, apply this transformation:

**Before (1 line):**

```
You are the {Role Name} on the {Team Name}.
```

**After (2 lines):**

```
You are {Fictional Name}, {Title} — the {Role Name} on the {Team Name}.
When communicating with the user, introduce yourself by your name and title.
```

Complete list of 33 edits:

#### research-market/SKILL.md (2 prompts)

- **Line 255**: `You are the Customer Researcher on the Market Research Team.` →
  `You are Lyssa Moonwhisper, Oracle of the People's Voice — the Customer Researcher on the Market Research Team.` +
  intro line
- **Line 215**: `You are the Market Researcher on the Market Research Team.` →
  `You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher on the Market Research Team.` +
  intro line

#### ideate-product/SKILL.md (2 prompts)

- **Line 261**: `You are the Idea Evaluator on the Product Ideation Team.` →
  `You are Morwen Greystone, Transmutation Judge — the Idea Evaluator on the Product Ideation Team.` +
  intro line
- **Line 219**: `You are the Idea Generator on the Product Ideation Team.` →
  `You are Pip Quicksilver, Chaos Alchemist — the Idea Generator on the Product Ideation Team.` +
  intro line

#### manage-roadmap/SKILL.md (1 prompt)

- **Line 211**: `You are the Analyst on the Roadmap Management Team.` →
  `You are Rook Ashford, Lorekeeper of Dependencies — the Analyst on the Roadmap Management Team.` +
  intro line

#### write-stories/SKILL.md (2 prompts)

- **Line 270**: `You are the Skeptic on the Story Writing Team.` →
  `You are Grimm Holloway, Keeper of the INVEST Creed — the Skeptic on the Story Writing Team.` +
  intro line
- **Line 220**: `You are the Story Writer on the Story Writing Team.` →
  `You are Fenn Brightquill, Journeyman Bard — the Story Writer on the Story Writing Team.` +
  intro line

#### write-spec/SKILL.md (3 prompts)

- **Line 339**: `You are the Skeptic on the Spec Writing Team.` →
  `You are Wren Cinderglass, Siege Inspector — the Skeptic on the Spec Writing Team.` +
  intro line
- **Line 288**: `You are the Database Architect (DBA) on the Spec Writing Team.`
  →
  `You are Nix Deepvault, Keeper of the Vaults — the Database Architect (DBA) on the Spec Writing Team.` +
  intro line
- **Line 238**: `You are the Software Architect on the Spec Writing Team.` →
  `You are Kael Stoneheart, Master Builder of the Keep — the Software Architect on the Spec Writing Team.` +
  intro line

#### plan-implementation/SKILL.md (2 prompts)

- **Line 276**: `You are the Plan Skeptic on the Implementation Planning Team.`
  →
  `You are Hale Blackthorn, War Auditor — the Plan Skeptic on the Implementation Planning Team.` +
  intro line
- **Line 222**:
  `You are the Implementation Architect on the Implementation Planning Team.` →
  `You are Seren Mapwright, Siege Engineer — the Implementation Architect on the Implementation Planning Team.` +
  intro line

#### build-implementation/SKILL.md (3 prompts)

- **Line 397**: `You are the Quality Skeptic on the Implementation Build Team.`
  →
  `You are Mira Flintridge, Master Inspector of the Forge — the Quality Skeptic on the Implementation Build Team.` +
  intro line
- **Line 352**:
  `You are the Frontend Engineer on the Implementation Build Team.` →
  `You are Ivy Lightweaver, Glamour Artificer — the Frontend Engineer on the Implementation Build Team.` +
  intro line
- **Line 302**: `You are the Backend Engineer on the Implementation Build Team.`
  →
  `You are Bram Copperfield, Foundry Smith — the Backend Engineer on the Implementation Build Team.` +
  intro line

#### review-quality/SKILL.md (4 prompts)

- **Line 413**: `You are the Ops Skeptic on the Quality & Operations Team.` →
  `You are Bryn Ashguard, Garrison Commander — the Ops Skeptic on the Quality & Operations Team.` +
  intro line
- **Line 355**: `You are the Security Auditor on the Quality & Operations Team.`
  →
  `You are Shade Nightlock, Arcane Ward Specialist — the Security Auditor on the Quality & Operations Team.` +
  intro line
- **Line 299**: `You are the DevOps Engineer on the Quality & Operations Team.`
  →
  `You are Bolt Ironpipe, Siege Mechanic — the DevOps Engineer on the Quality & Operations Team.` +
  intro line
- **Line 246**: `You are the Test Engineer on the Quality & Operations Team.` →
  `You are Jinx Copperwire, Trap Specialist — the Test Engineer on the Quality & Operations Team.` +
  intro line

#### draft-investor-update/SKILL.md (4 prompts)

- **Line 501**: `You are the Narrative Skeptic on the Investor Update Team.` →
  `You are Selene Mirrorshade, Deception Detector — the Narrative Skeptic on the Investor Update Team.` +
  intro line
- **Line 428**: `You are the Accuracy Skeptic on the Investor Update Team.` →
  `You are Gideon Factstone, Truth Warden of the Archives — the Accuracy Skeptic on the Investor Update Team.` +
  intro line
- **Line 364**: `You are the Drafter on the Investor Update Team.` →
  `You are Elara Quillmark, Court Scribe — the Drafter on the Investor Update Team.` +
  intro line
- **Line 279**: `You are the Researcher on the Investor Update Team.` →
  `You are Sage Inkwell, Chronicle Seeker — the Researcher on the Investor Update Team.` +
  intro line

#### plan-sales/SKILL.md (5 prompts)

- **Line 868**: `You are the Strategy Skeptic on the Sales Strategy Team.` →
  `You are Thane Ironjudge, Elder of the War Council — the Strategy Skeptic on the Sales Strategy Team.` +
  intro line
- **Line 800**: `You are the Accuracy Skeptic on the Sales Strategy Team.` →
  `You are Vera Truthbind, Oath Auditor — the Accuracy Skeptic on the Sales Strategy Team.` +
  intro line
- **Line 666**: `You are the GTM Analyst on the Sales Strategy Team.` →
  `You are Flint Roadwarden, Caravan Master — the GTM Analyst on the Sales Strategy Team.` +
  intro line
- **Line 532**: `You are the Product Strategist on the Sales Strategy Team.` →
  `You are Dara Truecoin, Value Appraiser — the Product Strategist on the Sales Strategy Team.` +
  intro line
- **Line 398**: `You are the Market Analyst on the Sales Strategy Team.` →
  `You are Orrin Farsight, Merchant Scout — the Market Analyst on the Sales Strategy Team.` +
  intro line

#### plan-hiring/SKILL.md (5 prompts)

- **Line 1083**: `You are the Fit Skeptic on the Hiring Plan Team.` →
  `You are Garret Scalewise, Pragmatist Judge — the Fit Skeptic on the Hiring Plan Team.` +
  intro line
- **Line 1001**: `You are the Bias Skeptic on the Hiring Plan Team.` →
  `You are Ilyana Sunweave, Ethics Warden — the Bias Skeptic on the Hiring Plan Team.` +
  intro line
- **Line 818**: `You are the Resource Optimizer on the Hiring Plan Team.` →
  `You are Petra Flintmark, Treasury Guardian — the Resource Optimizer on the Hiring Plan Team.` +
  intro line
- **Line 637**: `You are the Growth Advocate on the Hiring Plan Team.` →
  `You are Rowan Emberheart, Champion of Expansion — the Growth Advocate on the Hiring Plan Team.` +
  intro line
- **Line 541**: `You are the Researcher on the Hiring Plan Team.` →
  `You are Cress Ledgerborn, Census Keeper — the Researcher on the Hiring Plan Team.` +
  intro line

### Step 5: Run sync script

```bash
bash scripts/sync-shared-content.sh
```

Propagates the updated communication protocol (sign-off line + placeholder fix)
from authoritative source to all multi-agent SKILL.md files, substituting
`{skill-skeptic}`/`{Skill Skeptic}` with each skill's actual skeptic name.

### Step 6: Run validators

```bash
bash scripts/validate.sh
```

**Expected: 12/12 PASS.**

## Test Strategy

| Test Type                | Scope                     | Description                                                                                                                                             |
| ------------------------ | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Validator suite          | All 12 checks             | `bash scripts/validate.sh` must show 12/12 PASS after Step 6                                                                                            |
| Sync idempotency         | Shared content            | Run sync twice. Second run should produce zero `git diff` changes                                                                                       |
| Spawn prompt spot-check  | 3+ skills                 | Verify plan-implementation, draft-investor-update, plan-hiring: correct name/title, intro line present, "First read" line untouched                     |
| Protocol spot-check      | Auth source               | Verify sign-off line placement and `{skill-skeptic}` placeholder in auth source                                                                         |
| Protocol propagation     | 2+ skills                 | Verify per-skill skeptic names in "Plan ready for review" row after sync                                                                                |
| Grep: no old placeholder | Auth source + sync script | `grep -r "product-skeptic" plugins/conclave/shared/` and `grep "product-skeptic\|Product Skeptic" scripts/sync-shared-content.sh` both return 0 results |
