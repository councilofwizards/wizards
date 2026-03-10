---
type: "progress-checkpoint"
skill: "manage-roadmap"
session: "conclave-plugin-improvements"
phase: "analyst"
status: "complete"
date: "2026-03-10"
agent: "Rook Ashford, Lorekeeper of Dependencies"
---

# Roadmap Analyst Report: Conclave Plugin Improvements

**Analyst**: Rook Ashford, Lorekeeper of Dependencies
**Date**: 2026-03-10
**Input**: docs/ideas/conclave-plugin-improvements-ideas.md (14 pursued ideas)
**Research**: docs/research/conclave-plugin-improvements-research.md

---

## Methodology

For each of the 14 ideas, I determined:
1. Whether an existing roadmap item covers the same ground
2. Whether a net-new roadmap item is required
3. Dependencies on existing items and cross-dependencies between new items
4. Recommended priority tier (P2 vs P3)

---

## Idea-by-Idea Mapping

### Idea 1: Persona Name Injection in Spawn Prompts
- **Priority Score**: 9 (high impact, small effort)
- **Mapping**: NO existing roadmap item. No current item tracks adding fictional names to spawn prompts. This is structurally distinct from P3-01 (Custom Agent Roles), which is about user-defined roles, not the persona identity injection system.
- **Verdict**: NET-NEW roadmap item required.
- **Recommended ID**: P2-09 (ranks as P2 — high impact, small effort, activates an entire architectural layer)
- **Dependencies**:
  - Requires the 45+ persona files in `plugins/conclave/shared/personas/` to be correct and complete (already done — confirmed by research)
  - Must precede Idea 5 (Persona Reference Validator) — the validator enforces what this idea implements
  - Must precede Idea 9 (Persona System ADR) — the ADR should document the completed system, not a broken one
- **Notes**: This is the highest-impact, lowest-effort change in the entire set. The entire persona system — 45 files, fictional names, personalities — was built but never wired into spawn prompts. This is not a feature addition, it is completing a previously built feature.

---

### Idea 2: Business Skills Section in wizard-guide
- **Priority Score**: 9 (high impact, small effort)
- **Mapping**: NO existing roadmap item. P3-02 (Onboarding Wizard) is complete (status: complete) and covers `setup-project`. wizard-guide content completeness was never tracked.
- **Verdict**: NET-NEW roadmap item required.
- **Recommended ID**: P2-10
- **Dependencies**:
  - No blocking dependencies. Business skills (plan-sales, plan-hiring, draft-investor-update) are already complete.
  - Logically pairs with Idea 3 (setup-project → wizard-guide link) — both improve discoverability. Recommend implementing together.
- **Notes**: Three production-quality skills are invisible at the primary discovery point. This is a documentation gap, not a feature gap. Small effort, high payoff.

---

### Idea 3: wizard-guide Mention in setup-project Next Steps
- **Priority Score**: 9 (high impact, small effort)
- **Mapping**: NO existing roadmap item. P3-02 is complete but covers initial setup, not the post-setup discovery funnel.
- **Verdict**: NET-NEW roadmap item required. However, this is a single bullet point — it SHOULD be bundled with Idea 2 rather than tracked separately. Together they form a coherent "skill discoverability" improvement.
- **Recommended ID**: Bundle with Idea 2 under P2-10 (Skill Discoverability Improvements)
- **Dependencies**: None. Requires no other item to complete first.

---

### Idea 4: Persona Identity Reinforcement in Communication Protocol
- **Priority Score**: 9 (high impact, small effort)
- **Mapping**: NO existing roadmap item. This edits `plugins/conclave/shared/communication-protocol.md`, which is managed by the shared content system (P2-05, complete), but the specific content change is not tracked.
- **Verdict**: NET-NEW roadmap item. However, this MUST be bundled with Idea 10 (Communication Protocol Placeholder Fix) since both edit the same file in the same sync pass.
- **Recommended ID**: Bundle with Idea 10 as part of a "Persona System Activation" item (P2-09). See Idea 1.
- **Dependencies**:
  - Pairs with Idea 1 (same theme: persona visibility)
  - Must precede Idea 5 (Persona Reference Validator, which validates what this enforces)
  - Triggers a `sync-shared-content.sh` run — all 12 multi-agent SKILL.md files will be updated

---

### Idea 5: Persona Reference Validator (G-series)
- **Priority Score**: 6 (high impact, medium effort)
- **Mapping**: Partially overlaps with P2-04 (Automated Testing Pipeline, complete). P2-04 implemented structural validators (A-F series). A new G-series validator extends the same infrastructure but covers persona content quality — not currently tracked.
- **Verdict**: NET-NEW roadmap item required.
- **Recommended ID**: P3-08 (P3 because it's a developer-experience guard, not a user-facing feature)
- **Dependencies**:
  - HARD DEPENDENCY on Idea 1 (P2-09): The validator checks that spawn prompts contain fictional names. If Idea 1 is not implemented first, the validator will fail on all 12 files from day one. Must sequence strictly after P2-09.
  - Depends on P2-04 (complete) for validator infrastructure pattern to follow.
  - Implicitly depends on persona files in `plugins/conclave/shared/personas/` being stable (already true).
- **Notes**: Correct sequencing is critical here. I will be irritable if someone tries to implement the validator before the spawn prompts are fixed.

---

### Idea 6: Conclave Lore Preamble in wizard-guide
- **Priority Score**: 6 (medium impact, small effort)
- **Mapping**: NO existing roadmap item. Related to wizard-guide content but distinct from Idea 2 (business skills listing).
- **Verdict**: NET-NEW roadmap item. However, this should be BUNDLED with Idea 2 and Idea 3 under the same discoverability/immersion item (P2-10), since all three edit wizard-guide in a single pass.
- **Dependencies**: None blocking. Should be done in same edit pass as Idea 2.

---

### Idea 7: Persona Spotlight in wizard-guide
- **Priority Score**: 6 (medium impact, small effort)
- **Mapping**: NO existing roadmap item.
- **Verdict**: Bundle with Ideas 2, 3, and 6 under P2-10. All four ideas touch wizard-guide content and should be a single coherent edit.
- **Dependencies**: Logically sequenced AFTER Idea 1 (P2-09) — the personas introduced in the spotlight should be consistent with how they actually introduce themselves during skill execution.

---

### Idea 8: Cross-Skill Artifact Continuity Badges
- **Priority Score**: 6 (medium impact, small effort)
- **Mapping**: NO existing roadmap item. Tier 2 skills (plan-product, build-product) are complete but no item tracks adding narrative flavor to pipeline skip messages.
- **Verdict**: NET-NEW roadmap item required.
- **Recommended ID**: P3-09
- **Dependencies**:
  - No blocking dependencies. Can be done independently.
  - Logically sequenced after Idea 1 for thematic consistency — flavor text should align with how personas communicate.

---

### Idea 9: Persona System ADR (ADR-005)
- **Priority Score**: 6 (medium impact, small effort)
- **Mapping**: NO existing roadmap item. P3-03 (Contribution Guide) is not started and mentions contributors, but ADR-005 is an architectural decision record, not a contribution guide.
- **Verdict**: NET-NEW roadmap item required.
- **Recommended ID**: P3-10-persona-adr (note: P3-10 is taken by plan-sales — use P3-08 sequence after validator)

CORRECTION: P3-08 would be the Persona Validator, so ADR-005 needs a new slot. Assign P3-09 to Artifact Continuity Badges (Idea 8) and P3-10 is already plan-sales. The next available slot after existing P3 items is P3-23 (business section maxes at P3-22).

**Revised ID assignments**:
- P3-08: Persona Reference Validator (Idea 5)
- P3-09: Artifact Continuity Badges (Idea 8)
- P3-23: Persona System ADR / ADR-005 (Idea 9)

- **Dependencies**:
  - HARD DEPENDENCY on Idea 1 (P2-09): ADR must document the completed persona system, not the broken one. Write AFTER spawn prompts are fixed.
  - Soft dependency on Idea 5 (P3-08): ADR should mention the validator as part of the architectural enforcement story.
  - Logically pairs with P3-03 (Contribution Guide) — together they form the complete developer documentation layer.

---

### Idea 10: Communication Protocol Placeholder Fix
- **Priority Score**: 3 (bundle — do not track separately)
- **Mapping**: NO existing roadmap item.
- **Verdict**: Bundle with Idea 4 (same file edit). Do NOT create a separate roadmap item. One-line change, tracked as part of the Persona System Activation item.
- **Dependencies**: Same as Idea 4.

---

### Idea 11: Role-Based Principles Split
- **Priority Score**: 4 (medium impact, medium-large effort)
- **Mapping**: PARTIAL OVERLAP with P2-07 (Universal Shared Principles, not_started). P2-07 focuses on extraction mechanism (authoritative source files). The current system (P2-07) was actually implemented as part of P2-05 (shared/ directory + sync script). P2-07 as written is now partially superseded by the implemented shared content architecture.

  However, Idea 11 is a DIFFERENT scope: it's about SPLITTING the single principles block into universal vs. engineering-specific, then injecting the appropriate block per skill type. P2-07 does not cover this split — it covers the general extraction mechanism.

- **Verdict**: Idea 11 should UPDATE P2-07's scope to include the principles split, or become a new item that extends P2-07. Given that P2-07 is not_started and its original problem statement (single source of truth) is already solved by the shared/ architecture, P2-07 should be REVISED to capture the role-based split as its primary deliverable.
- **Recommended action**: Revise P2-07 to reflect the role-based principles split as the remaining work. Its original goal (authoritative source) is done.
- **Dependencies**:
  - Extends the existing shared content system (P2-05, complete)
  - Requires sync script logic changes and B-series validator updates — significant scope
  - No hard dependencies on persona ideas

---

### Idea 12: Persona-Aware run-task Dynamic Archetypes
- **Priority Score**: 4 (medium impact, medium effort)
- **Mapping**: PARTIAL OVERLAP with P3-01 (Custom Agent Roles, not_started). P3-01 covers user-defined roles in project config. Idea 12 covers a different scope: creating fixed persona files for run-task's four built-in archetypes (Engineer, Researcher, Writer, Skeptic) so they have fictional names within the Conclave identity system.

  These are NOT the same. P3-01 = user customization. Idea 12 = completing the persona system for run-task's internal archetypes.

- **Verdict**: NET-NEW roadmap item required. Do NOT collapse into P3-01.
- **Recommended ID**: P3-24
- **Dependencies**:
  - Logically follows Idea 1 (P2-09) — spawn prompt persona injection pattern established there should be applied to run-task archetypes
  - run-task's 4 archetype persona files must not conflict with existing 45+ persona files (name uniqueness constraint)
  - Soft dependency on Idea 5 (P3-08 Persona Validator) — once validator exists, run-task archetypes should pass it

---

### Idea 13: Contribution Guide Skill
- **Priority Score**: 4 (medium impact, medium effort)
- **Mapping**: DIRECT OVERLAP with P3-03 (Architecture & Contribution Guide, not_started). The ideas artifact explicitly calls this out as implementing P3-03.
- **Verdict**: Maps to P3-03. No new roadmap item needed. Idea 13 IS P3-03 with added implementation detail (could be wizard-guide --dev mode or standalone skill).
- **Dependencies**:
  - No hard dependencies
  - Logically sequenced AFTER Idea 9 / P3-23 (Persona System ADR) — contribution guide should reference the completed ADR-005
  - Logically sequenced AFTER Idea 1 (P2-09) — guide should document the completed persona injection pattern

---

### Idea 14: PoC Skills Deprecation Banner
- **Priority Score**: 3 (low impact, small effort)
- **Mapping**: NO existing roadmap item. The PoC skills (tier1-test, tier2-test) have no tracked maintenance item.
- **Verdict**: NET-NEW roadmap item, but LOW priority. Small effort, low impact.
- **Recommended ID**: P3-25
- **Dependencies**: None. Completely standalone.

---

## Net-New Items Summary

| New Item | Covers Ideas | Priority | Effort |
|----------|-------------|----------|--------|
| P2-09: Persona System Activation | 1, 4, 10 (bundled) | P2 | Small-Medium |
| P2-10: Skill Discoverability Improvements | 2, 3, 6, 7 (bundled) | P2 | Small |
| P3-08: Persona Reference Validator | 5 | P3 | Medium |
| P3-09: Artifact Continuity Badges | 8 | P3 | Small |
| P3-23: Persona System ADR (ADR-005) | 9 | P3 | Small |
| P3-24: run-task Persona Archetypes | 12 | P3 | Medium |
| P3-25: PoC Skills Deprecation Banner | 14 | P3 | Small |

## Existing Items That Map to Ideas

| Existing Item | Idea | Action Required |
|--------------|------|----------------|
| P2-07 (Universal Shared Principles) | 11 | REVISE: update scope to role-based split (original goal is already complete) |
| P3-03 (Contribution Guide) | 13 | NO CHANGE: Idea 13 implements P3-03 directly |

---

## Dependency Graph

```
Idea 1 (P2-09: Persona Activation)
  ├── MUST precede: Idea 5 (P3-08: Persona Validator)
  ├── MUST precede: Idea 9 (P3-23: Persona ADR)
  ├── SHOULD precede: Idea 12 (P3-24: run-task Personas)
  ├── SHOULD precede: Idea 7 (bundled P2-10: Persona Spotlight)
  └── SHOULD precede: Idea 13 (P3-03: Contribution Guide)

Idea 4 (bundled into P2-09)
  └── Same deps as Idea 1

Ideas 2, 3, 6, 7 (P2-10: Discoverability)
  └── No blocking deps; logically after P2-09 for persona spotlight consistency

Idea 5 (P3-08: Persona Validator)
  └── HARD depends on P2-09

Idea 8 (P3-09: Artifact Continuity Badges)
  └── No blocking deps

Idea 9 (P3-23: Persona ADR)
  └── HARD depends on P2-09; soft depends on P3-08

Idea 11 (P2-07 revision)
  └── No blocking deps; standalone

Idea 12 (P3-24: run-task Personas)
  └── Logically after P2-09

Idea 13 (P3-03: Contribution Guide)
  └── Logically after P2-09 and P3-23

Idea 14 (P3-25: PoC Banner)
  └── No deps
```

---

## Implementation Sequence Recommendation

**Wave 1 (do together — small edits, high payoff):**
1. P2-09: Persona System Activation (Ideas 1 + 4 + 10) — spawn prompts + communication protocol
2. P2-10: Skill Discoverability Improvements (Ideas 2 + 3 + 6 + 7) — wizard-guide + setup-project

Wave 1 items have zero blocking dependencies and collectively resolve the two CRITICAL and two HIGH pain points from the research. They should be the first implementation wave.

**Wave 2 (after Wave 1):**
3. P3-23: Persona System ADR (Idea 9) — documents the now-completed persona architecture
4. P2-07 revised: Role-Based Principles Split (Idea 11) — independent, but fits naturally here

**Wave 3 (after Wave 2):**
5. P3-08: Persona Reference Validator (Idea 5) — guards against regression of Wave 1 work
6. P3-24: run-task Persona Archetypes (Idea 12) — completes persona coverage

**Wave 4 (low priority, independent):**
7. P3-09: Artifact Continuity Badges (Idea 8)
8. P3-03: Contribution Guide (Idea 13) — after ADR-005 is written
9. P3-25: PoC Skills Deprecation Banner (Idea 14)

---

## Critical Dependency Warnings

1. **P3-08 must not be implemented before P2-09.** The Persona Reference Validator will fail on all 12 SKILL.md files if spawn prompts don't contain fictional names yet. Implementing the validator first creates a red CI that can only be fixed by implementing the feature it guards. Do not let anyone reverse this sequence.

2. **P2-07 needs a scope revision before implementation.** Its original problem statement (shared content extraction) was already solved by the shared/ directory architecture. Implementing P2-07 as-written would build something that already exists. The remaining work is the principles SPLIT, not the extraction.

3. **P3-24 (run-task personas) requires name uniqueness auditing.** The 4 new archetype persona files must not duplicate any of the 45+ existing persona names. This is a pre-implementation check, not a blocking dependency, but it must happen before writing the files.

4. **Ideas 2 and 7 (wizard-guide edits) should be in one pass.** Business Skills section + Lore Preamble + Persona Spotlight are all wizard-guide content. Three separate PRs would create unnecessary merge risk. Bundle them under P2-10 and edit wizard-guide once.

---

## Priority Recommendations

| Item | Recommended Priority | Rationale |
|------|---------------------|-----------|
| P2-09: Persona System Activation | **P2** | Activates an entire built-but-dormant architectural layer; small effort |
| P2-10: Skill Discoverability | **P2** | Three production skills invisible at primary entry point; one-pass fix |
| P3-08: Persona Validator | **P3** | Developer tool; value realized after P2-09 lands |
| P3-09: Artifact Continuity Badges | **P3** | Polish; no pain point, just immersion |
| P3-23: Persona ADR | **P3** | Documentation; important but not urgent |
| P2-07 (revised): Role-Based Principles Split | **P2** (retain) | Already P2; revised scope more actionable than original |
| P3-24: run-task Personas | **P3** | Completes persona system; lower urgency than core activation |
| P3-03: Contribution Guide | **P3** (retain) | Developer audience; lower urgency |
| P3-25: PoC Banner | **P3** | Low impact; low effort; do it while editing those files |

---

## Status

Analysis complete. Ready for Team Lead review and skeptic gate.
