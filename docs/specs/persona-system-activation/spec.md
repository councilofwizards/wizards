---
title: "Persona System Activation"
status: "approved"
priority: "P2"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-10"
updated: "2026-03-10"
---

# Persona System Activation Specification

## Summary

Activate the Conclave's dormant persona system by injecting fictional names and titles into all 33 spawn prompts across
11 multi-agent SKILL.md files, adding a sign-off convention to the shared communication protocol, and fixing a
misleading placeholder in the protocol's "Plan ready for review" row. Three coordinated changes that bring the fantasy
identity layer from architecturally dormant to structurally enforced.

## Problem

The Conclave has 45+ fictional personas with names, titles, and personalities defined in
`plugins/conclave/shared/personas/`. However, spawn prompts in all 12 multi-agent SKILL.md files reference agents only
by role ID ("You are the Market Researcher"), never by fictional name. The communication protocol directs agents to
"show your personality" but provides no structural enforcement — persona adoption relies entirely on LLM inference after
reading a persona file. The fantasy persona layer is the largest investment in the plugin's identity system and is
completely invisible during execution.

**Evidence**: Grep confirmed zero fictional name matches in any SKILL.md spawn prompt (research finding #1, CRITICAL
severity).

## Solution

### 1. Spawn Prompt Modification (Stories 1 + 2)

#### Template Pattern

Every spawn prompt currently opens with:

```
First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.

You are the {Role Name} on the {Team Name}.
```

After modification:

```
First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.

You are {fictional_name}, {title} — the {Role Name} on the {Team Name}.
When communicating with the user, introduce yourself by your name and title.
```

#### Rules

- The identity line replaces `You are the {Role Name} on the {Team Name}.` in full
- The self-introduction instruction is added on the immediately following line (no blank line separator)
- The `First, read ... persona ...` line and blank line before the identity line are untouched
- Fictional names and titles are sourced ONLY from persona file YAML `fictional_name` and `title` fields

#### Complete Prompt Mapping (33 prompts across 11 files)

| Skill                 | Prompts | Agents                                                                                                                                                                     |
| --------------------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| research-market       | 2       | Market Researcher (Theron Blackwell), Customer Researcher (Lyssa Moonwhisper)                                                                                              |
| ideate-product        | 2       | Idea Generator (Pip Quicksilver), Idea Evaluator (Morwen Greystone)                                                                                                        |
| manage-roadmap        | 1       | Analyst (Rook Ashford)                                                                                                                                                     |
| write-stories         | 2       | Story Writer (Fenn Brightquill), Skeptic (Grimm Holloway)                                                                                                                  |
| write-spec            | 3       | Software Architect (Kael Stoneheart), DBA (Nix Deepvault), Skeptic (Wren Cinderglass)                                                                                      |
| plan-implementation   | 2       | Implementation Architect (Seren Mapwright), Plan Skeptic (Hale Blackthorn)                                                                                                 |
| build-implementation  | 3       | Backend Engineer (Bram Copperfield), Frontend Engineer (Ivy Lightweaver), Quality Skeptic (Mira Flintridge)                                                                |
| review-quality        | 4       | Test Engineer (Jinx Copperwire), DevOps Engineer (Bolt Ironpipe), Security Auditor (Shade Nightlock), Ops Skeptic (Bryn Ashguard)                                          |
| draft-investor-update | 4       | Researcher (Sage Inkwell), Drafter (Elara Quillmark), Accuracy Skeptic (Gideon Factstone), Narrative Skeptic (Selene Mirrorshade)                                          |
| plan-sales            | 5       | Market Analyst (Orrin Farsight), Product Strategist (Dara Truecoin), GTM Analyst (Flint Roadwarden), Accuracy Skeptic (Vera Truthbind), Strategy Skeptic (Thane Ironjudge) |
| plan-hiring           | 5       | Researcher (Cress Ledgerborn), Growth Advocate (Rowan Emberheart), Resource Optimizer (Petra Flintmark), Bias Skeptic (Ilyana Sunweave), Fit Skeptic (Garret Scalewise)    |

**Note**: Lead personas (research-director, ideation-director, etc.) are loaded in Setup steps via `Read` — they are the
orchestrating agent, not spawned teammates. No spawn prompt changes needed for leads.

### 2. Communication Protocol Sign-Off Convention (Story 3)

**File**: `plugins/conclave/shared/communication-protocol.md`

Add the sign-off convention as prose text in the Message Format section, **before** the fenced code block:

```markdown
### Message Format

Keep messages structured so they can be parsed quickly by context-constrained agents:

When addressing the user, sign messages with your persona name and title.
```

[TYPE]: [BRIEF_SUBJECT] Details: [1-3 sentences max] Action needed: [yes/no, and what] Blocking: [task number if
applicable]

```

```

### 3. Placeholder Fix (Story 4)

#### Sync Script Analysis

The sync script (`scripts/sync-shared-content.sh`) uses `AUTH_SKEPTIC_SLUG="product-skeptic"` (line 173) as the sed
search pattern for substitution. It reads the authoritative source file and replaces every occurrence of
"product-skeptic" with the per-skill skeptic slug. Changing the source to `{skill-skeptic}` without updating the sync
script would silently break substitution — all 12 SKILL.md files would receive the literal placeholder, causing B2
drift.

The B2 normalizer in `scripts/validators/skill-shared-content.sh` MUST also be updated to normalize `{skill-skeptic}`
and `{Skill Skeptic}` to `SKEPTIC_NAME`. Without this, the normalized source (containing the placeholder) would differ
from normalized SKILL.md files (containing per-skill slugs), causing false-positive drift detection on every comparison.

#### Required Changes

**File 1**: `plugins/conclave/shared/communication-protocol.md`

Change the "Plan ready for review" row from:

```
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Product Skeptic |
```

To:

```
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")` | {Skill Skeptic} |<!-- substituted by sync-shared-content.sh per skill -->
```

**File 2**: `scripts/sync-shared-content.sh`

Update lines 173-174:

```bash
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"
```

Update fallback defaults in `extract_skeptic_names` (lines 97-98, 107-108) from `product-skeptic`/`Product Skeptic` to
`{skill-skeptic}`/`{Skill Skeptic}`.

**File 3**: `scripts/validators/skill-shared-content.sh`

Add to `normalize_skeptic_names`:

```bash
-e 's/{skill-skeptic}/SKEPTIC_NAME/g' \
-e 's/{Skill Skeptic}/SKEPTIC_NAME/g' \
```

### 4. Execution Order (Story 5)

Order is non-negotiable:

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
        - Apply identity line + self-introduction instruction to each of 33 spawn prompts
        - Do NOT edit shared content markers or content outside spawn prompt blocks

Step 5: bash scripts/sync-shared-content.sh
        - Pushes Stories 3+4 changes to all 12 SKILL.md files

Step 6: bash scripts/validate.sh
        - Must show 12/12 PASS before committing
```

## Constraints

1. Shared content markers (`<!-- BEGIN SHARED: ... -->` / `<!-- END SHARED: ... -->`) must not be modified, moved, or
   have content inserted between marker and authoritative source comment
2. YAML frontmatter in any SKILL.md is untouched
3. Lead orchestration sections (Setup, Determine Mode, Spawn the Team, etc.) are untouched — only content inside spawn
   prompt fenced code blocks is modified
4. The `First, read ... persona ...` line at the start of each spawn prompt is untouched
5. B2 normalizer patterns for existing skeptic names are untouched — only additions
6. Fictional names and titles must exactly match persona file YAML frontmatter — no invention or reinterpretation

## Out of Scope

- **run-task**: Dynamic archetype agents have no persona file assignments. Separate roadmap item P3-24.
- **New persona files**: P2-09 activates existing personas only. Missing `fictional_name` or `title` fields are
  prerequisite blockers.
- **Protocol structural changes**: Only sign-off convention and placeholder fix. No new message types or table
  restructuring.
- **New validators**: No G-series persona validators. Separate roadmap item P3-08.
- **Tier 2 composites**: plan-product and build-product have no spawn prompts — skipped by sync.
- **Single-agent utilities**: setup-project and wizard-guide have no teams — no changes.

## Files to Modify

| File                                                     | Change                                                                                  | Stories |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------- | ------- |
| `plugins/conclave/shared/communication-protocol.md`      | Add sign-off sentence; change `product-skeptic` → `{skill-skeptic}` with inline comment | 3, 4    |
| `scripts/sync-shared-content.sh`                         | Update AUTH_SKEPTIC_SLUG, AUTH_SKEPTIC_DISPLAY, and fallback defaults                   | 4       |
| `scripts/validators/skill-shared-content.sh`             | Add `{skill-skeptic}` and `{Skill Skeptic}` to normalize_skeptic_names                  | 4       |
| `plugins/conclave/skills/research-market/SKILL.md`       | 2 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/ideate-product/SKILL.md`        | 2 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/manage-roadmap/SKILL.md`        | 1 spawn prompt identity line + intro instruction                                        | 1, 2    |
| `plugins/conclave/skills/write-stories/SKILL.md`         | 2 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/write-spec/SKILL.md`            | 3 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/plan-implementation/SKILL.md`   | 2 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/build-implementation/SKILL.md`  | 3 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/review-quality/SKILL.md`        | 4 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/draft-investor-update/SKILL.md` | 4 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/plan-sales/SKILL.md`            | 5 spawn prompt identity lines + intro instructions                                      | 1, 2    |
| `plugins/conclave/skills/plan-hiring/SKILL.md`           | 5 spawn prompt identity lines + intro instructions                                      | 1, 2    |

**Post-sync**: All 12 multi-agent SKILL.md files receive the updated Communication Protocol block. Sync overwrites
shared content sections only; spawn prompt changes are outside shared content markers and untouched by sync.

## Success Criteria

1. Every spawn prompt in the 11 modified SKILL.md files contains the agent's `fictional_name` and `title` from their
   persona file, in the format: "You are {name}, {title} — the {Role} on the {Team}."
2. Every spawn prompt contains the instruction: "When communicating with the user, introduce yourself by your name and
   title."
3. The communication protocol Message Format section contains the sign-off convention: "When addressing the user, sign
   messages with your persona name and title."
4. The protocol "Plan ready for review" row uses `{skill-skeptic}` / `{Skill Skeptic}` placeholders with inline comment
5. No literal `product-skeptic` or `Product Skeptic` remains in the authoritative `communication-protocol.md`
6. Per-skill skeptic names are correctly substituted in all 12 SKILL.md files after sync (e.g., `quality-skeptic` in
   build-implementation, not `{skill-skeptic}`)
7. `bash scripts/validate.sh` shows 12/12 checks PASS with exit code 0
