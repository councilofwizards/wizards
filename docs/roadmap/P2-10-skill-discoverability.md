---
title: "Skill Discoverability Improvements"
status: "complete"
priority: "P2"
category: "developer-experience"
effort: "small"
impact: "high"
dependencies: []
created: "2026-03-10"
updated: "2026-03-10"
---

# Skill Discoverability Improvements

## Problem

Three production-quality business skills (draft-investor-update, plan-sales, plan-hiring) are invisible at the primary discovery point (`/wizard-guide`). New users completing setup-project are directed to `/plan-product` but never told about `/wizard-guide`. The wizard-guide lacks narrative framing and persona introductions that would set expectations for the fantasy-themed experience.

## Proposed Solution

Four bundled changes to wizard-guide and setup-project (single edit pass):

1. **Business Skills Section in wizard-guide** (Idea 2): Add a "Business Skills" section to the Skill Ecosystem Overview listing draft-investor-update, plan-sales, and plan-hiring with descriptions. Add business workflow examples to Common Workflows.

2. **wizard-guide Mention in setup-project** (Idea 3): Add a bullet to setup-project's Step 6 Next Steps: "Run `/wizard-guide` to explore all available skills and find the right one for your task." Place before the existing `/plan-product` recommendation.

3. **Conclave Lore Preamble** (Idea 6): Add a ~100-word narrative preamble to wizard-guide that sets the world stage before listing skills.

4. **Persona Spotlight** (Idea 7): Add a "Meet the Council" section introducing 4-5 key personas by fictional name, title, and one-line personality. Cap at 5 to avoid overwhelming.

## Evidence

- Research finding #2 (HIGH severity): wizard-guide Skill Ecosystem Overview confirmed missing business skills
- Research finding #3 (HIGH severity): setup-project Next Steps confirmed no wizard-guide mention
- Research confirmed persona layer never surfaced to users pre-execution

## Success Criteria

- wizard-guide lists all 3 business skills with descriptions
- setup-project Next Steps includes wizard-guide recommendation
- wizard-guide opens with narrative preamble setting the Conclave context
- wizard-guide introduces 4-5 key personas before skill listing
- All validators pass after changes
