---
feature: "review-cycle-3"
team: "plan-product"
agent: "architect"
phase: "design"
status: "complete"
last_action: "Incorporated skeptic feedback into system design: user data template, missing output sections, Drafter risk note, first-run behavior"
updated: "2026-02-19"
---

# Technical Assessment: P3-22 Investor Update Architecture

## Summary

Designed the full system architecture for `/draft-investor-update` (P3-22), the first business skill in the conclave framework. The design validates the Pipeline collaboration pattern and dual-skeptic review from the business skill design guidelines. System design document written to `docs/architecture/investor-update-system-design.md`.

## Key Design Decisions

1. **Pipeline pattern with 4 stages**: Research -> Draft -> Review -> Revise (with cycle back). Sequential handoffs with structured artifacts between stages. This is a departure from the parallel-agent pattern in existing skills, justified by the sequential nature of document production.

2. **Dual-skeptic with parallel review**: Accuracy Skeptic and Narrative Skeptic review the draft simultaneously but evaluate independent concerns. Both must approve. This is the first multi-skeptic implementation.

3. **5-agent team** (including Team Lead): Researcher (opus), Drafter (sonnet), Accuracy Skeptic (opus), Narrative Skeptic (opus). No DBA — there's no data model.

4. **Evidence-traced claims**: Every factual claim in the output must link to a source file. This is the primary quality mechanism in the absence of ground truth (no code tests to run).

5. **Mandatory quality sections**: Assumptions & Limitations, Confidence Levels, Falsification Triggers, External Validation Checkpoints — as required by business skill design guidelines.

6. **Self-contained output directory**: `docs/investor-updates/` created by the skill itself, not by setup-project. Avoids premature generalization.

7. **CI validator impact is minimal**: Only change needed is extending the skeptic name normalization in `skill-shared-content.sh` to handle `accuracy-skeptic` and `narrative-skeptic`.

## Reusable Components Identified

- Shared Principles and Communication Protocol sections (byte-identical copy with shared markers)
- Checkpoint Protocol (same format, different phase enum)
- Write Safety conventions (same pattern, different role names)
- Failure Recovery (same 3 patterns)
- Lightweight Mode (same pattern)
- Determine Mode with status/resume (same checkpoint-based resume)
- Setup section (same directory creation pattern)

## New Patterns Introduced

- Pipeline handoff with structured Research Dossier artifact
- Dual-skeptic parallel review with both-must-approve gate
- Evidence tracing as substitute for test-based verification
- Mandatory business quality sections in output
- Prior-update consistency checking by Narrative Skeptic
- New output directory (`docs/investor-updates/`)

## Progress Notes

- Read all 4 existing SKILL.md files to understand patterns
- Read business-skill-design-guidelines.md for Pipeline pattern and quality requirements
- Read ADR-003 for ADR format reference
- Read existing specs for spec format reference
- Read all 5 CI validators to understand constraints
- Read review cycle 2 notes for P3-22 context
- Wrote system design to docs/architecture/investor-update-system-design.md
- Sent design to product-owner and product-skeptic for review
- Skeptic APPROVED with 2 gaps identified (user data input mechanism, missing output sections)
- Updated system design to incorporate all skeptic feedback:
  - Added User Data Input section with `_user-data.md` template file mechanism
  - Added Team Update, Financial Summary, and Asks sections to output format
  - Added Drafter Sonnet risk note with upgrade path
  - Added First-Run Behavior section
  - Updated Researcher inputs to include `_user-data.md` and prior updates
  - Changed status from "proposed" to "accepted"
