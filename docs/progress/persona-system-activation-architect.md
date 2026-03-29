---
feature: "persona-system-activation"
team: "write-spec"
agent: "software-architect"
phase: "design"
status: "awaiting_review"
last_action: "Completed full technical specification for P2-09 persona system activation"
updated: "2026-03-10"
---

# Architect Design: P2-09 Persona System Activation

**Author**: Kael Stoneheart, Master Builder of the Keep (Software Architect) **Input**:
`docs/specs/persona-system-activation/stories.md` (5 approved stories) **For review by**: Spec Skeptic (Wren
Cinderglass)

---

## Summary

This document specifies the exact file changes, content patterns, and execution order required to activate the persona
system across all 12 multi-agent SKILL.md files. Every decision is load-bearing. Nothing here is decorative.

---

## 1. Spawn Prompt Modification Pattern (Stories 1 + 2)

### 1.1 Canonical Template

Every spawn prompt currently opens with:

```
First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.

You are the {Role Name} on the {Team Name}.
```

After modification it becomes:

```
First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.

You are {fictional_name}, {title} — the {Role Name} on the {Team Name}.
When communicating with the user, introduce yourself by your name and title.
```

### 1.2 Representative Diff (Market Researcher in research-market/SKILL.md)

**Before** (line 213–215):

```
First, read plugins/conclave/shared/personas/market-researcher.md for your complete role definition and cross-references.

You are the Market Researcher on the Market Research Team.
```

**After**:

```
First, read plugins/conclave/shared/personas/market-researcher.md for your complete role definition and cross-references.

You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher on the Market Research Team.
When communicating with the user, introduce yourself by your name and title.
```

### 1.3 Rules

- The identity line replaces `You are the {Role Name} on the {Team Name}.` in full.
- The self-introduction instruction is added on the immediately following line (no blank line separator).
- The `First, read ... persona ...` line and blank line before the identity line are untouched.
- No other content in the spawn prompt block is modified.
- Fictional names and titles are sourced ONLY from the `fictional_name` and `title` YAML fields in the corresponding
  persona file. No invention.

### 1.4 Persona-to-Prompt Mapping: All 12 SKILL.md Files

The following table maps every spawn prompt requiring modification. Lead personas are injected in Setup (not spawn
prompts) and are **not** in scope for Stories 1+2.

#### research-market/SKILL.md (2 prompts)

| Prompt              | Persona File           | fictional_name    | title                        | Role Name           | Team Name            |
| ------------------- | ---------------------- | ----------------- | ---------------------------- | ------------------- | -------------------- |
| Market Researcher   | market-researcher.md   | Theron Blackwell  | Scout of the Outer Reaches   | Market Researcher   | Market Research Team |
| Customer Researcher | customer-researcher.md | Lyssa Moonwhisper | Oracle of the People's Voice | Customer Researcher | Market Research Team |

#### ideate-product/SKILL.md (2 prompts)

| Prompt         | Persona File      | fictional_name   | title               | Role Name      | Team Name             |
| -------------- | ----------------- | ---------------- | ------------------- | -------------- | --------------------- |
| Idea Generator | idea-generator.md | Pip Quicksilver  | Chaos Alchemist     | Idea Generator | Product Ideation Team |
| Idea Evaluator | idea-evaluator.md | Morwen Greystone | Transmutation Judge | Idea Evaluator | Product Ideation Team |

#### manage-roadmap/SKILL.md (1 prompt)

| Prompt  | Persona File       | fictional_name | title                      | Role Name | Team Name               |
| ------- | ------------------ | -------------- | -------------------------- | --------- | ----------------------- |
| Analyst | roadmap-analyst.md | Rook Ashford   | Lorekeeper of Dependencies | Analyst   | Roadmap Management Team |

#### write-stories/SKILL.md (2 prompts)

| Prompt       | Persona File     | fictional_name   | title                      | Role Name    | Team Name          |
| ------------ | ---------------- | ---------------- | -------------------------- | ------------ | ------------------ |
| Story Writer | story-writer.md  | Fenn Brightquill | Journeyman Bard            | Story Writer | Story Writing Team |
| Skeptic      | story-skeptic.md | Grimm Holloway   | Keeper of the INVEST Creed | Skeptic      | Story Writing Team |

Note: the current prompt reads "You are the Skeptic on the Story Writing Team." The new line must use the role name
"Skeptic" (not "Story Skeptic") to match the existing text exactly.

#### write-spec/SKILL.md (3 prompts)

| Prompt             | Persona File          | fictional_name   | title                      | Role Name                | Team Name         |
| ------------------ | --------------------- | ---------------- | -------------------------- | ------------------------ | ----------------- |
| Software Architect | software-architect.md | Kael Stoneheart  | Master Builder of the Keep | Software Architect       | Spec Writing Team |
| Database Architect | dba.md                | Nix Deepvault    | Keeper of the Vaults       | Database Architect (DBA) | Spec Writing Team |
| Skeptic            | spec-skeptic.md       | Wren Cinderglass | Siege Inspector            | Skeptic                  | Spec Writing Team |

Note: "Database Architect (DBA)" — preserve the parenthetical exactly as it appears in the current prompt. "You are the
Database Architect (DBA) on the Spec Writing Team." → role portion is "Database Architect (DBA)".

#### plan-implementation/SKILL.md (2 prompts)

| Prompt                   | Persona File      | fictional_name  | title          | Role Name                | Team Name                    |
| ------------------------ | ----------------- | --------------- | -------------- | ------------------------ | ---------------------------- |
| Implementation Architect | impl-architect.md | Seren Mapwright | Siege Engineer | Implementation Architect | Implementation Planning Team |
| Plan Skeptic             | plan-skeptic.md   | Hale Blackthorn | War Auditor    | Plan Skeptic             | Implementation Planning Team |

#### build-implementation/SKILL.md (3 prompts)

| Prompt            | Persona File       | fictional_name   | title                         | Role Name         | Team Name                 |
| ----------------- | ------------------ | ---------------- | ----------------------------- | ----------------- | ------------------------- |
| Backend Engineer  | backend-eng.md     | Bram Copperfield | Foundry Smith                 | Backend Engineer  | Implementation Build Team |
| Frontend Engineer | frontend-eng.md    | Ivy Lightweaver  | Glamour Artificer             | Frontend Engineer | Implementation Build Team |
| Quality Skeptic   | quality-skeptic.md | Mira Flintridge  | Master Inspector of the Forge | Quality Skeptic   | Implementation Build Team |

#### review-quality/SKILL.md (4 prompts)

| Prompt           | Persona File        | fictional_name  | title                  | Role Name        | Team Name                 |
| ---------------- | ------------------- | --------------- | ---------------------- | ---------------- | ------------------------- |
| Test Engineer    | test-eng.md         | Jinx Copperwire | Trap Specialist        | Test Engineer    | Quality & Operations Team |
| DevOps Engineer  | devops-eng.md       | Bolt Ironpipe   | Siege Mechanic         | DevOps Engineer  | Quality & Operations Team |
| Security Auditor | security-auditor.md | Shade Nightlock | Arcane Ward Specialist | Security Auditor | Quality & Operations Team |
| Ops Skeptic      | ops-skeptic.md      | Bryn Ashguard   | Garrison Commander     | Ops Skeptic      | Quality & Operations Team |

#### draft-investor-update/SKILL.md (4 prompts)

| Prompt            | Persona File                               | fictional_name     | title                        | Role Name         | Team Name            |
| ----------------- | ------------------------------------------ | ------------------ | ---------------------------- | ----------------- | -------------------- |
| Researcher        | researcher--draft-investor-update.md       | Sage Inkwell       | Chronicle Seeker             | Researcher        | Investor Update Team |
| Drafter           | drafter.md                                 | Elara Quillmark    | Court Scribe                 | Drafter           | Investor Update Team |
| Accuracy Skeptic  | accuracy-skeptic--draft-investor-update.md | Gideon Factstone   | Truth Warden of the Archives | Accuracy Skeptic  | Investor Update Team |
| Narrative Skeptic | narrative-skeptic.md                       | Selene Mirrorshade | Deception Detector           | Narrative Skeptic | Investor Update Team |

#### plan-sales/SKILL.md (5 prompts)

| Prompt             | Persona File                    | fictional_name   | title                    | Role Name          | Team Name           |
| ------------------ | ------------------------------- | ---------------- | ------------------------ | ------------------ | ------------------- |
| Market Analyst     | market-analyst.md               | Orrin Farsight   | Merchant Scout           | Market Analyst     | Sales Strategy Team |
| Product Strategist | product-strategist.md           | Dara Truecoin    | Value Appraiser          | Product Strategist | Sales Strategy Team |
| GTM Analyst        | gtm-analyst.md                  | Flint Roadwarden | Caravan Master           | GTM Analyst        | Sales Strategy Team |
| Accuracy Skeptic   | accuracy-skeptic--plan-sales.md | Vera Truthbind   | Oath Auditor             | Accuracy Skeptic   | Sales Strategy Team |
| Strategy Skeptic   | strategy-skeptic.md             | Thane Ironjudge  | Elder of the War Council | Strategy Skeptic   | Sales Strategy Team |

#### plan-hiring/SKILL.md (5 prompts)

| Prompt             | Persona File               | fictional_name   | title                 | Role Name          | Team Name        |
| ------------------ | -------------------------- | ---------------- | --------------------- | ------------------ | ---------------- |
| Researcher         | researcher--plan-hiring.md | Cress Ledgerborn | Census Keeper         | Researcher         | Hiring Plan Team |
| Growth Advocate    | growth-advocate.md         | Rowan Emberheart | Champion of Expansion | Growth Advocate    | Hiring Plan Team |
| Resource Optimizer | resource-optimizer.md      | Petra Flintmark  | Treasury Guardian     | Resource Optimizer | Hiring Plan Team |
| Bias Skeptic       | bias-skeptic.md            | Ilyana Sunweave  | Ethics Warden         | Bias Skeptic       | Hiring Plan Team |
| Fit Skeptic        | fit-skeptic.md             | Garret Scalewise | Pragmatist Judge      | Fit Skeptic        | Hiring Plan Team |

#### tier1-test/SKILL.md

tier1-test has `type: single-agent` — no spawn prompts. **No changes needed.**

#### run-task/SKILL.md (1 skeptic prompt — but OUT OF SCOPE)

run-task has a Task Skeptic prompt but uses generic archetypes with no persona file assignments. Per stories.md Out of
Scope: "run-task persona grounding requires a separate design." The task-skeptic prompt at line 274 is **excluded** from
this feature.

### 1.5 Total Prompt Count

| Skill                 | Prompts to Modify |
| --------------------- | ----------------- |
| research-market       | 2                 |
| ideate-product        | 2                 |
| manage-roadmap        | 1                 |
| write-stories         | 2                 |
| write-spec            | 3                 |
| plan-implementation   | 2                 |
| build-implementation  | 3                 |
| review-quality        | 4                 |
| draft-investor-update | 4                 |
| plan-sales            | 5                 |
| plan-hiring           | 5                 |
| **Total**             | **33**            |

Note: Lead personas (research-director, ideation-director, roadmap-manager, strategist variants, planning-lead,
tech-lead, qa-lead, investor-update-lead, sales-lead, hiring-lead) are loaded in Setup steps via
`Read plugins/conclave/shared/personas/{id}.md` — they are the Team Lead and their identity is already established by
that read. No spawn prompt change needed for leads.

---

## 2. Communication Protocol Edit (Story 3)

**File to edit**: `plugins/conclave/shared/communication-protocol.md`

**Section**: `### Message Format`

**Current content** of that section:

```markdown
### Message Format

Keep messages structured so they can be parsed quickly by context-constrained agents:
```

[TYPE]: [BRIEF_SUBJECT] Details: [1-3 sentences max] Action needed: [yes/no, and what] Blocking: [task number if
applicable]

```

```

**Required change**: Add the sign-off convention as a prose sentence **before** the fenced code block (per Edge Case:
the instruction is prose guidance, not inside the fenced block).

**After**:

```markdown
### Message Format

Keep messages structured so they can be parsed quickly by context-constrained agents:

When addressing the user, sign messages with your persona name and title.
```

[TYPE]: [BRIEF_SUBJECT] Details: [1-3 sentences max] Action needed: [yes/no, and what] Blocking: [task number if
applicable]

```

```

**Exact insertion**: One blank line after the introductory sentence ("Keep messages structured..."), then the new
instruction sentence, then one blank line, then the fenced code block — maintaining the existing paragraph rhythm.

---

## 3. Placeholder Fix (Story 4)

### 3.1 Sync Script Substitution Analysis

The sync script's substitution logic (lines 173–213 of `sync-shared-content.sh`):

```bash
AUTH_SKEPTIC_SLUG="product-skeptic"    # line 173
AUTH_SKEPTIC_DISPLAY="Product Skeptic" # line 174
...
# Per-skill: read existing "Plan ready for review" row to extract current skeptic slug+display
target_slug="$(extract_skeptic_names)"
# Substitute AUTH_SKEPTIC_SLUG → target_slug in the authoritative source text
target_protocol="$(printf '%s' "$target_protocol" | sed "s/$AUTH_SKEPTIC_SLUG/$target_slug/g")"
```

The substitution uses `AUTH_SKEPTIC_SLUG` ("product-skeptic") as the **search pattern** in sed. It reads the
authoritative source file (`$auth_protocol`) and replaces every occurrence of "product-skeptic" with the target skill's
skeptic slug.

**Implication**: If the source file is changed from "product-skeptic" to "{skill-skeptic}", the sed substitution on line
209 will search for "product-skeptic" and find nothing — substitution silently breaks. All 12 SKILL.md files would
receive "{skill-skeptic}" literally in their Protocol block, causing B2 drift.

**Required**: The sync script must be updated **in the same change** as the source file edit.

### 3.2 Required Changes

**File 1**: `plugins/conclave/shared/communication-protocol.md`

Change the "Plan ready for review" table row from:

```
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")`     | Product Skeptic     |
```

To:

```
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")`     | {Skill Skeptic}     |<!-- substituted by sync-shared-content.sh per skill -->
```

Note: Both the slug in `write(...)` AND the display name in the Target column must use the generic placeholder, since
the sync script substitutes both independently (lines 209 and 212).

**File 2**: `scripts/sync-shared-content.sh`

Change lines 173–174 from:

```bash
AUTH_SKEPTIC_SLUG="product-skeptic"
AUTH_SKEPTIC_DISPLAY="Product Skeptic"
```

To:

```bash
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"
```

Also update line 97 (the default fallback in `extract_skeptic_names`) and line 107 (the default `${slug:-...}` fallback)
which currently default to "product-skeptic" / "Product Skeptic":

Line 97 change: `echo "product-skeptic"` → `echo "{skill-skeptic}"` Line 98 change: `echo "Product Skeptic"` →
`echo "{Skill Skeptic}"` Line 107 change: `echo "${slug:-product-skeptic}"` → `echo "${slug:-{skill-skeptic}}"` Line 108
change: `echo "${display:-Product Skeptic}"` → `echo "${display:-{Skill Skeptic}}"`

**Important**: The B2 normalizer in `skill-shared-content.sh` does NOT need changes. It normalizes all known skeptic
slug variants to SKEPTIC_NAME for structural comparison. It does not match "{skill-skeptic}" — but that's correct: the
source file uses the placeholder and SKILL.md files carry the substituted per-skill values. The B2 check compares
SKILL.md blocks (which have the real slug) against the source (which has the placeholder). This would cause B2 drift
unless the normalizer is updated.

**Additional required change**: `scripts/validators/skill-shared-content.sh`

The B2 normalizer (`normalize_skeptic_names`) compares the source block against each SKILL.md block after normalizing
both. After the change, the source contains `{skill-skeptic}` / `{Skill Skeptic}` and SKILL.md files contain the real
per-skill slugs. The normalizer must also replace `{skill-skeptic}` and `{Skill Skeptic}` with SKEPTIC_NAME.

Add these two lines to `normalize_skeptic_names` in `skill-shared-content.sh`:

```bash
-e 's/{skill-skeptic}/SKEPTIC_NAME/g' \
-e 's/{Skill Skeptic}/SKEPTIC_NAME/g' \
```

---

## 4. Execution Order (Story 5)

The following is the required implementation sequence. Order is non-negotiable.

```
Step 1: Edit plugins/conclave/shared/communication-protocol.md
        - Add sign-off convention (Story 3)
        - Change product-skeptic → {skill-skeptic} (Story 4)
        Both edits in a single pass. Do NOT run sync between them.

Step 2: Edit scripts/sync-shared-content.sh
        - Update AUTH_SKEPTIC_SLUG and AUTH_SKEPTIC_DISPLAY
        - Update fallback defaults in extract_skeptic_names

Step 3: Edit scripts/validators/skill-shared-content.sh
        - Add {skill-skeptic} and {Skill Skeptic} to normalize_skeptic_names

Step 4: Edit all 11 multi-agent SKILL.md files
        - Apply identity line + self-introduction instruction to each spawn prompt
        - 33 prompts total across 11 files
        - Do NOT edit shared content markers or any content outside spawn prompt blocks

Step 5: bash scripts/sync-shared-content.sh
        - Pushes Stories 3+4 changes to all 12 SKILL.md files
        - Uses updated AUTH_SKEPTIC_SLUG to substitute per-skill values

Step 6: bash scripts/validate.sh
        - Must show 12/12 PASS before committing
        - Any failure is a blocker — do not commit with failures
```

---

## 5. Complete File Modification List

| File                                                     | Change                                                                                                                                              | Stories |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `plugins/conclave/shared/communication-protocol.md`      | Add sign-off sentence in Message Format; change `product-skeptic` → `{skill-skeptic}` and `Product Skeptic` → `{Skill Skeptic}` with inline comment | 3, 4    |
| `scripts/sync-shared-content.sh`                         | Update AUTH_SKEPTIC_SLUG, AUTH_SKEPTIC_DISPLAY, and two fallback defaults                                                                           | 4       |
| `scripts/validators/skill-shared-content.sh`             | Add `{skill-skeptic}` and `{Skill Skeptic}` to normalize_skeptic_names                                                                              | 4       |
| `plugins/conclave/skills/research-market/SKILL.md`       | 2 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/ideate-product/SKILL.md`        | 2 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/manage-roadmap/SKILL.md`        | 1 spawn prompt identity line + intro instruction                                                                                                    | 1, 2    |
| `plugins/conclave/skills/write-stories/SKILL.md`         | 2 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/write-spec/SKILL.md`            | 3 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/plan-implementation/SKILL.md`   | 2 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/build-implementation/SKILL.md`  | 3 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/review-quality/SKILL.md`        | 4 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | 4 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/plan-sales/SKILL.md`            | 5 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |
| `plugins/conclave/skills/plan-hiring/SKILL.md`           | 5 spawn prompt identity lines + intro instructions                                                                                                  | 1, 2    |

**Note**: After `bash scripts/sync-shared-content.sh` (Step 5), all 12 SKILL.md files receive the updated Communication
Protocol block. The sync overwrites the shared content sections only. Spawn prompt changes (Steps 1+2 edits to the 11
SKILL.md files) are outside shared content markers and are not touched by sync.

---

## 6. Constraints — What Must NOT Change

- **Shared content markers** (`<!-- BEGIN SHARED: principles -->`, `<!-- END SHARED: principles -->`,
  `<!-- BEGIN SHARED: communication-protocol -->`, `<!-- END SHARED: communication-protocol -->`) must not be modified,
  moved, or have content inserted between marker and authoritative source comment.
- **Skill-specific sections** (`<!-- BEGIN SKILL-SPECIFIC: ... -->` / `<!-- END SKILL-SPECIFIC: ... -->`) are untouched.
- **YAML frontmatter** in any SKILL.md is untouched.
- **Lead orchestration instructions** (Setup, Determine Mode, Spawn the Team, Orchestration Flow, etc.) are untouched —
  only the content inside spawn prompt fenced code blocks is modified.
- **The `First, read ... persona ...` line** at the start of each spawn prompt is untouched.
- **The blank line** between the persona read line and the identity line is untouched.
- **B2 normalizer patterns** for existing skeptic names are untouched — only additions, no removals.
- **run-task SKILL.md** is not touched (out of scope per stories.md).
- **tier1-test, tier2-test, setup-project, wizard-guide, plan-product, build-product** — no changes.

---

## 7. Success Criteria (Verification Steps)

After completing all steps:

**V1**: Grep for the introduction instruction in all 12 multi-agent SKILL.md files:

```bash
grep -l "When communicating with the user, introduce yourself by your name and title." \
  plugins/conclave/skills/*/SKILL.md
```

Expected: 11 files (all Tier 1 multi-agent skills — not run-task, not tier1-test, not tier2-test, not setup-project, not
wizard-guide, not plan-product, not build-product).

**V2**: Verify no spawn prompt retains the old bare role line pattern:

```bash
grep -rn "^You are the .* on the .* Team\.$" plugins/conclave/skills/*/SKILL.md
```

Expected: only `run-task/SKILL.md` (the out-of-scope task-skeptic prompt). Zero results from the 11 modified skills.

**V3**: Verify the sign-off convention is present in the authoritative source:

```bash
grep "sign messages with your persona name and title" \
  plugins/conclave/shared/communication-protocol.md
```

Expected: 1 match.

**V4**: Verify the placeholder is present in the authoritative source:

```bash
grep "{skill-skeptic}" plugins/conclave/shared/communication-protocol.md
```

Expected: 1 match.

**V5**: Verify no literal `product-skeptic` remains in the authoritative source:

```bash
grep "product-skeptic" plugins/conclave/shared/communication-protocol.md
```

Expected: 0 matches.

**V6**: Run the full validator suite and confirm 12/12:

```bash
bash scripts/validate.sh
```

Expected: All 12 checks PASS, exit code 0.

**V7**: Verify per-skill skeptic substitution worked (sample check):

```bash
grep "Plan ready for review" plugins/conclave/skills/build-implementation/SKILL.md
```

Expected: `quality-skeptic` (not `product-skeptic`, not `{skill-skeptic}`).

---

## 8. Open Questions / Pre-implementation Blockers

None identified. All persona files have non-empty `fictional_name` and `title` fields (verified by reading all 44
persona files). The sync script substitution logic is fully understood. The validator impact is bounded and accounted
for.

The only risk: the `{` and `}` characters in `{skill-skeptic}` are not special in sed but could theoretically collide
with existing content. A grep confirms no existing SKILL.md content uses curly-brace placeholders in the Communication
Protocol block, so there is no collision risk.
