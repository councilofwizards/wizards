---
feature: "P2-10 Skill Discoverability Improvements"
status: "complete"
completed: "2026-03-27"
---

# P2-10: Skill Discoverability Improvements — Build Engineer Progress

## Summary

Implemented all 5 changes from the spec across 2 files: wizard-guide SKILL.md received the lore preamble, persona spotlight, business skills section, tier label cleanup, Determine Mode fixes, and Common Workflows additions. setup-project SKILL.md received the /wizard-guide mention in Step 6 Next Steps.

## Changes

### plugins/conclave/skills/wizard-guide/SKILL.md

1. **Determine Mode — empty/no args**: Replaced "two tiers" language with category-grouped overview; added preamble/spotlight suppression rule for list/explain modes.
2. **Determine Mode — list mode**: Replaced "tier" with "category"; added suppression of preamble and spotlight; updated skill count to 16.
3. **Determine Mode — recommend mode**: Added 3 business skill examples (draft-investor-update, plan-sales, plan-hiring); removed "Tier 1 skills" reference.
4. **Added `## The Conclave` lore preamble**: ~107 words, inserted before `## Skill Ecosystem Overview`.
5. **Added `## Meet the Council` persona spotlight**: 5 personas (Eldara Voss, Seren Mapwright, Vance Hammerfall, Mira Flintridge, Bram Copperfield) in a table, inserted after `## The Conclave`.
6. **Skill Ecosystem Overview**: Removed "Tier 1" / "Tier 2" / "chains:" labels; restructured into 4 named groups: Granular Skills, Pipeline Skills, Business Skills, Utility Skills. Updated numbering to 16 skills.
7. **Common Workflows**: Added "Business operations" code block with all 3 business skills.

### plugins/conclave/skills/setup-project/SKILL.md

1. **Step 6 Next Steps**: Inserted `/wizard-guide` bullet as item 2 before `/plan-product`; renumbered items 2–3 to 3–4.

## Files Modified

- `plugins/conclave/skills/wizard-guide/SKILL.md` — lore preamble, persona spotlight, business skills, tier label cleanup, Determine Mode fixes, business workflows
- `plugins/conclave/skills/setup-project/SKILL.md` — /wizard-guide mention in Step 6 Next Steps

## Verification

- Neither wizard-guide nor setup-project appear in validator failures after edits.
- Pre-existing failures in php-tomes and untracked docs files are unrelated to this feature.
- All 8 success criteria from spec are satisfied:
  1. `## The Conclave` preamble present (107 words, within 80–150 target)
  2. `## Meet the Council` present with exactly 5 personas, each with name/title/description
  3. Business Skills section lists all 3 skills; no "Tier 1" / "Tier 2" labels remain
  4. Determine Mode list mode suppresses preamble/spotlight; business skills included
  5. Determine Mode explain mode suppresses preamble/spotlight
  6. Common Workflows includes business operations block
  7. setup-project Step 6 item 2 is /wizard-guide, before /plan-product (item 3)
  8. Validators: no new failures introduced by these edits
