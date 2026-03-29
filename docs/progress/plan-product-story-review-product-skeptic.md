---
team: "plan-product"
agent: "product-skeptic"
phase: "stories"
status: "complete"
verdict: "approved"
batches_reviewed: 3
batches_approved: 3
batches_rejected: 0
revision_rounds: 1
created: "2026-03-27"
updated: "2026-03-27"
---

# Skeptic Review: User Story Batches

## Batch 1: P3 Engineering Skills (5 features, 31 stories) — REJECTED

### Critical Issue: Missing Required A2 Sections in All Scaffolding Stories

All 5 features (P3-01, P3-04, P3-05, P3-06, P3-07) have the same defect in Story
1 (SKILL.md Scaffolding) AC2:

The required sections enumeration is **missing 3 sections** that the A2
validator (`scripts/validators/skill-structure.sh` lines 149-160) explicitly
checks:

1. **`## Lightweight Mode`** — completely absent from all 5 stories' section
   lists
2. **`## Shared Principles`** — not listed as a section heading; stories
   reference "shared content marker blocks" instead, but the A2 validator checks
   for the `## Shared Principles` section heading independently of the A4 marker
   check
3. **`## Communication Protocol`** — same issue as `## Shared Principles`

**Evidence**: Every existing multi-agent skill (14/14) contains all three
sections. The A2 validator requires them. An implementer following the stories'
AC2 literally would produce a SKILL.md missing these sections and fail
validation.

**Impact**: Each story also has an AC stating "all 12/12 validators pass" — this
creates an internal contradiction. The explicit section list is the
implementer's specification; it must be correct.

### Per-Feature Notes

- **P3-01 (custom-agent-roles)**: 6 stories, well-structured. Story 1 AC2
  section list defect as above. Stories 2-6 are thorough — Skeptic
  non-customizability guard (Story 5) is excellent. No other issues.
- **P3-04 (triage-incident)**: 6 stories. Story 1 AC2 defect as above. Stories
  2-6 are strong — severity framework, 5-Whys RCA methodology, and Skeptic gate
  are well-specified with proper edge cases.
- **P3-05 (review-debt)**: 6 stories. Story 1 AC2 defect as above. Story 3
  (prioritization) has a well-designed feature-conflict multiplier formula. No
  other issues.
- **P3-06 (design-api)**: 6 stories. Story 1 AC2 defect as above. Good coverage
  of REST, GraphQL, and gRPC protocols in edge cases. No other issues.
- **P3-07 (plan-migration)**: 7 stories. Story 1 AC2 defect as above. Story 7
  AC4 correctly identifies the need for a new artifact template at
  `docs/templates/artifacts/migration-plan.md` and F-series validator
  registration — this is the only engineering skill requiring a new artifact
  template, and it's properly called out.

### Fix Required

For ALL 5 features, update Story 1 AC2 to enumerate the complete required
section list:

```
## Setup, ## Write Safety, ## Checkpoint Protocol, ## Determine Mode, ## Lightweight Mode,
## Spawn the Team, ## Orchestration Flow, ## Critical Rules, ## Failure Recovery,
## Teammates to Spawn, ## Shared Principles, ## Communication Protocol
```

Plus note that shared content markers (universal-principles,
engineering-principles, communication-protocol) live within the
`## Shared Principles` and `## Communication Protocol` sections.

---

## Batch 2: P3 Business Skills (3 features, 19 stories) — REJECTED

### Critical Issue: Same Missing Sections, More Severe

All 3 features (P3-11, P3-12, P3-15) have the same defect in Story 1 AC3, but
worse than Batch 1 — the business stories omit **all three** required sections
(`## Lightweight Mode`, `## Shared Principles`, `## Communication Protocol`)
from their explicit enumeration. They list 9 sections when 12 are required.

**Evidence**: `plugins/conclave/skills/plan-sales/SKILL.md` (the reference skill
these stories cite) contains `## Lightweight Mode` at line 92, plus
`## Shared Principles` and `## Communication Protocol`. The stories reference
plan-sales as the template but don't reproduce its full section list.

### Per-Feature Notes

- **P3-11 (plan-marketing)**: 6 stories. Story 1 AC3 defect as above. Stories
  2-6 are well-structured — the Collaborative Analysis pattern, dual-skeptic
  gate, and cross-reference phase are clearly specified. Story 4 (output
  artifact) has excellent mandatory business quality sections.
- **P3-12 (plan-finance)**: 7 stories. Story 1 AC3 defect as above. Story 5
  (Accuracy Skeptic checklist) and Story 6 (Risk Skeptic checklist) are
  excellent — the finance-specific checklists are distinct from
  draft-investor-update's accuracy checklist. Multi-scenario output (Story 4) is
  well-specified with proper assumption traceability.
- **P3-15 (plan-customer-success)**: 6 stories. Story 1 AC3 defect as above.
  Hub-and-Spoke pattern is correctly distinguished from Collaborative Analysis.
  Pre-launch adaptation edge cases throughout are a strong addition.

### Fix Required

For ALL 3 features, update Story 1 AC3 to add the missing sections:

```
## Setup, ## Write Safety, ## Checkpoint Protocol, ## Determine Mode, ## Lightweight Mode,
## Spawn the Team, ## Orchestration Flow, ## Quality Gate, ## Failure Recovery,
## Teammate Spawn Prompts, ## Shared Principles, ## Communication Protocol
```

---

## Batch 3: P3 Harness Improvements (6 features, 13 stories) — APPROVED

### Verdict: APPROVED

No new SKILL.md files are created (all stories modify existing skills), so the
missing-section-in-scaffolding issue does not apply. Stories are
well-structured, reference correct file paths, and maintain proper
Given/When/Then format throughout.

### Notes

- **P3-26** (3 stories): Configurable iteration limits — clean, well-scoped.
  Story 26-2 correctly lists all 14 multi-agent skills and handles
  per-deliverable counter semantics.
- **P3-27 + P3-28** (4 stories): Complexity classifier + Lead-as-Skeptic
  consistency — correctly batched due to shared file modification. Stage routing
  table for Simple/Standard/Complex is well-defined with proper artifact
  detection interaction.
- **P3-29** (3 stories): Evaluator tuning — defensive reading contract mirrors
  P2-12/P2-13 conventions correctly. Post-mortem rating (Story 29-2) is
  appropriately opt-in and low-friction.
- **P3-30** (2 stories): Checkpoint frequency — three frequency modes are
  well-specified. Edge case for `blocked` status always checkpointing under
  `final-only` mode is correctly called out.
- **P3-31** (2 stories): SCAFFOLD comments — documentation-only, no behavioral
  change. Convention format is well-defined with proper placement guidance.

**Minor observation**: The frontmatter `source_roadmap_item` references only
`docs/roadmap/P3-26-configurable-iteration-limits.md` despite covering P3-26
through P3-31. The template's single-value field makes this a template
limitation, not a story defect. Consider adding a `source_roadmap_items`
(plural) convention if multi-item story files become common.
