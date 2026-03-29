---
feature: "harness-improvements"
team: "implementation-team"
agent: "build-engineer"
phase: "implementation"
status: "complete"
last_action:
  "Completed Group B: Flag Parsing + deadlock rule updates across all 14 multi-agent SKILL.md files + wizard-guide
  Common Flags section"
updated: "2026-03-27T19:00:00Z"
---

## Progress Notes

- [18:31] Received Group B task assignment from team lead
- [18:35] Read spec Group B section, implementation plan, plan-product/build-product (already have Flag Parsing from
  Group A), and write-spec as representative granular skill
- [18:45] Read all 12 remaining multi-agent skills to understand current Determine Mode structure and Failure Recovery
  sections
- [18:55] Confirmed: research-market, ideate-product, manage-roadmap have NO deadlock rules — need B3 additions
- [19:00] Began edits

### B1: Flag Parsing added to 12 skills

Added `### Flag Parsing` subsection to `## Determine Mode` in all 12 remaining skills:

- research-market ✓
- ideate-product ✓
- manage-roadmap ✓
- write-stories ✓
- write-spec ✓
- plan-implementation ✓
- build-implementation ✓
- review-quality ✓
- run-task ✓
- draft-investor-update ✓
- plan-sales ✓
- plan-hiring ✓

plan-product and build-product already had `--max-iterations` and `--checkpoint-frequency` from Group A — verified, no
changes needed.

### B2: Deadlock rules updated in all skills with existing rules

Updated all Failure Recovery "Skeptic deadlock" and "QA deadlock" entries from hard-coded "3 times" to "N times (default
3, set via `--max-iterations`)":

- plan-product ✓ (Skeptic deadlock)
- build-product ✓ (Skeptic deadlock + QA deadlock + 2 inline orchestration flow references)
- build-implementation ✓ (Skeptic deadlock + QA deadlock + inline orchestration flow reference)
- plan-implementation ✓ (Skeptic deadlock + inline contract negotiation reference)
- write-stories ✓ (Skeptic deadlock)
- write-spec ✓ (Skeptic deadlock)
- review-quality ✓ (Skeptic deadlock)
- run-task ✓ (Skeptic deadlock)
- draft-investor-update ✓ (Skeptic deadlock)
- plan-sales ✓ (Skeptic deadlock + Quality Gate reference + Orchestration Flow inline reference)
- plan-hiring ✓ (Skeptic deadlock + Quality Gate reference + Orchestration Flow inline reference)

### B3: Deadlock rules ADDED to 3 Lead-as-Skeptic skills

research-market, ideate-product, and manage-roadmap previously had no Skeptic deadlock rule. Added to each Failure
Recovery section:

- research-market ✓
- ideate-product ✓
- manage-roadmap ✓

### B4: wizard-guide Common Flags section

Added `## Common Flags` section before `## The Conclave` in wizard-guide/SKILL.md. Includes all flags from spec B3:
--max-iterations, --checkpoint-frequency, --light, plus pipeline-only flags --complexity and --full.

## Verification Results

```
Flag Parsing count: 14 (all 14 multi-agent SKILL.md files have Flag Parsing)
Remaining "3 times" in deadlock context: 0
Validator: A3/spawn-definitions PASS, B3/authoritative-source PASS
All A/B failures are pre-existing php-tomes plugin issues, unrelated to Group B changes
```
