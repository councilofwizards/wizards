---
type: "compact-reference"
feature: "skill-discoverability"
source_roadmap: "docs/roadmap/P2-10-skill-discoverability.md"
compacted: "2026-04-05"
---

# Skill Discoverability Improvements — Engineering Reference

## What Was Built

Lore preamble, persona spotlight, and business skills section added to wizard-guide. Skill listing restructured into 4
named category groups, removing Tier 1/Tier 2 labels. `/wizard-guide` recommendation added to setup-project Step 6.

## Entrypoints

- `plugins/conclave/skills/wizard-guide/SKILL.md` — `## The Conclave` and `## Meet the Council` sections; restructured
  Skill Ecosystem Overview
- `plugins/conclave/skills/setup-project/SKILL.md` — Step 6 Next Steps, item 2

## Files Modified/Created

- `plugins/conclave/skills/wizard-guide/SKILL.md` — lore preamble, persona spotlight (5 personas in table), business
  skills section, Skill Ecosystem Overview restructured (4 groups), business operations workflow, Determine Mode
  tier-label fixes
- `plugins/conclave/skills/setup-project/SKILL.md` — `/wizard-guide` added as Step 6 item 2; items 2-3 renumbered to 3-4

## Dependencies

- **Depends on**: nothing
- **Depended on by**: nothing

## Configuration

No configuration. Static content changes only.

## Validation

No dedicated validator. Verify by reading wizard-guide for `## The Conclave`, `## Meet the Council`, and Business Skills
section. Confirm no "Tier 1" / "Tier 2" text remains.
