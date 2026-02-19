---
feature: "sales-strategy"
team: "plan-sales"
agent: "backend-eng"
phase: "complete"
status: "complete"
last_action: "Wrote plugins/conclave/skills/plan-sales/SKILL.md -- all 18 sections complete"
updated: "2026-02-19T14:00:00Z"
---

## Progress Notes

- [14:00] Read all reference files: impl-architect plan, spec, system design, plan-product/SKILL.md, draft-investor-update/SKILL.md
- [14:00] Created plugins/conclave/skills/plan-sales/ directory
- [14:00] Wrote complete SKILL.md with all 18 sections:
  1. YAML frontmatter (name, description, argument-hint)
  2. Main heading -- Collaborative Analysis with explicit Phase 3 NOT delegate mode statement
  3. Setup -- standard directories + docs/sales-plans/, first-run convenience, data dependency warning
  4. Write Safety -- plan-sales-{role} scoped files
  5. Checkpoint Protocol -- phase enum: research | cross-reference | synthesis | review | revision | complete
  6. Determine Mode -- status + empty/resume only (no period arg)
  7. Lightweight Mode -- 3 analysis agents sonnet; 2 skeptics remain opus
  8. Spawn the Team -- 5 agents (market-analyst, product-strategist, gtm-analyst, accuracy-skeptic, strategy-skeptic)
  9. Orchestration Flow -- full 5-phase Collaborative Analysis with ASCII diagram (copied from system design lines 82-142)
  10. Quality Gate -- dual-skeptic, both must approve
  11. Failure Recovery -- standard 3 patterns
  12. Shared Principles -- BYTE-IDENTICAL from plan-product/SKILL.md lines 145-174 including markers
  13. Communication Protocol -- copied from plan-product/SKILL.md lines 178-213, with product-skeptic -> accuracy-skeptic substitution in "Plan ready for review" row only
  14. Teammate Spawn Prompts -- full detailed prompts for all 5 roles
  15. Output Template -- full sales strategy assessment template from system design lines 366-489
  16. User Data Template -- full user-provided data template from system design lines 501-547
  17. Domain Brief Format -- structured format from system design lines 173-200
  18. Cross-Reference Report Format -- structured format from system design lines 228-267
- [14:00] Verified shared content: Shared Principles block byte-identical to plan-product/SKILL.md
- [14:00] Verified Communication Protocol: only change is "product-skeptic" -> "accuracy-skeptic" in Plan ready for review row
- [14:00] Wrote checkpoint to docs/progress/plan-sales-backend-eng.md
- [14:00] Messaging team-lead

## Key Decisions

- Phase 3 explicitly states "NOT delegate mode" in both main heading and orchestration flow section
- Phase 2 quality check for empty cross-references is explicit in orchestration flow
- Context management guidance for section-by-section synthesis included in Phase 3
- Disagreement preservation stated in Phase 2 orchestration instructions
- All spawn prompts include full Domain Brief and Cross-Reference Report formats inline
- Shared content blocks use exact markers from plan-product/SKILL.md
