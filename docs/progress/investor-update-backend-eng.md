---
feature: "investor-update"
team: "draft-investor-update"
agent: "backend-eng"
phase: "complete"
status: "complete"
last_action: "SKILL.md written and both validators pass"
updated: "2026-02-19T00:00:00Z"
---

## Progress Notes

- [00:00] Claimed Task #2: Write SKILL.md for draft-investor-update
- [00:01] Read implementation plan at docs/progress/investor-update-impl-architect.md
- [00:02] Read authoritative source plan-product/SKILL.md for shared content blocks (lines 145-174 and 178-213)
- [00:03] Read spec at docs/specs/investor-update/spec.md for output template, user data template, pipeline stages, checklists
- [00:04] Read system design at docs/architecture/investor-update-system-design.md for Research Dossier format and pipeline diagram
- [00:05] Read build-product/SKILL.md for format and convention reference
- [00:06] Created directory plugins/conclave/skills/draft-investor-update/
- [00:07] Wrote SKILL.md with all sections A1-A18 per implementation plan
- [00:08] Ran skill-structure.sh validator: PASS (A1, A2, A3, A4 all pass, 5 files checked)
- [00:09] Ran skill-shared-content.sh validator: PASS (B1, B2, B3 all pass, 5 files checked)

## Validator Results

```
[PASS] A1/frontmatter: All SKILL.md files have valid YAML frontmatter (5 files checked)
[PASS] A2/required-sections: All SKILL.md files have all required sections (5 files checked)
[PASS] A3/spawn-definitions: All spawn definitions have required fields (5 files checked)
[PASS] A4/shared-markers: All SKILL.md files have properly paired shared content markers (5 files checked)
[PASS] B1/principles-drift: Shared Principles blocks are byte-identical across all skills (5 files checked)
[PASS] B2/protocol-drift: Communication Protocol blocks are structurally equivalent across all skills (5 files checked)
[PASS] B3/authoritative-source: All BEGIN SHARED markers are followed by authoritative source comment (5 files checked)
```

## Deliverable

`plugins/conclave/skills/draft-investor-update/SKILL.md` — created with all sections A1-A18:

- A1: YAML frontmatter (name, description, argument-hint)
- A2: Title + Lead Role (adapted from plan-product)
- A3: Setup (adapted, adds investor-updates dir and _user-data.md creation)
- A4: Write Safety (adapted role names)
- A5: Checkpoint Protocol (adapted team name: "draft-investor-update", phases: research|draft|review|revision|complete)
- A6: Determine Mode (status, empty/resume, period argument)
- A7: Lightweight Mode (Researcher->sonnet, skeptics stay opus)
- A8: Spawn the Team (4 agents: researcher, drafter, accuracy-skeptic, narrative-skeptic)
- A9: Orchestration Flow (Pipeline stages with pipeline diagram and dual-skeptic gate)
- A10: Quality Gate (both skeptics must approve, max 3 revision cycles)
- A11: Failure Recovery (adapted for dual-skeptic deadlock condition)
- A12: Shared Principles (VERBATIM copy from plan-product with markers and authoritative source comment)
- A13: Communication Protocol (copied from plan-product, product-skeptic -> accuracy-skeptic only)
- A14: Contract Negotiation comment (omitted with comment)
- A15: Teammate Spawn Prompts (4 detailed prompts: Researcher, Drafter, Accuracy Skeptic, Narrative Skeptic)
- A16: Output Template (embedded from spec)
- A17: User Data Template (embedded from system design)
- A18: Research Dossier Format (embedded from system design)

## Notes

- Shared Principles (A12): byte-identical to plan-product/SKILL.md lines 145-174 — B1 validator confirms
- Communication Protocol (A13): only change is "product-skeptic" -> "accuracy-skeptic" in Plan ready for review row — B2 validator confirms structural equivalence after normalization
- The skill-shared-content.sh validator currently handles these names via the normalize function. The frontend-eng (Task #3) is adding accuracy-skeptic/narrative-skeptic to the normalize function, but B2 already passes because the existing normalization handles the structural equivalence check correctly.
