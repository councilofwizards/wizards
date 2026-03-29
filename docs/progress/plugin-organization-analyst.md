---
type: "progress-checkpoint"
skill: "plan-product"
stage: "roadmap-analysis"
agent: "Caelen Greymark, Cartographer of the Path Forward (Analyst)"
created: "2026-03-27"
status: "complete"
---

# Roadmap Analysis: Plugin Organization (P2-08)

## ROADMAP ANALYSIS: Plugin Organization

---

## Recommended Structure

**Keep P2-08 as a single roadmap item.** Do not split into sub-items.

Rationale: All 4 PURSUE ideas are "small" effort (totaling roughly 1-2 days of work). Creating 4 separate roadmap
entries would fragment a tightly sequenced, thematically unified scope change. Instead, update P2-08 with:

- Revised title: "Plugin Organization — Internal Taxonomy & Infrastructure"
- Revised effort: Small (was Medium — original framing assumed a split; no split is happening)
- Revised impact: High (was Medium — taxonomy is foundational to all future discoverability work)
- Updated description reflecting the 4 PURSUE ideas as sequenced sub-tasks
- Explicit "no split" resolution: the question of splitting is deferred to ADR-005 trigger conditions, not this item

---

## Items

### Sub-task 1: Category Metadata + Skill Discovery Tags (Ideas 1 + 7)

- **Scope**: Add `category` and `domain` fields to SKILL.md frontmatter (17 files) and plugin.json schema. Add
  `tags: []` array to frontmatter. Update wizard-guide to surface skills by tag.
- **Effort**: Small (~17 frontmatter edits + plugin.json + wizard-guide update)
- **Impact**: High — foundational taxonomy prerequisite for everything else in this scope
- **Priority**: P2 (first in sequence)
- **Dependencies**: None blocking. P2-10 (Skill Discoverability) is ✅ complete — this extends it.

### Sub-task 2: Split Readiness ADR + Automated Gate (Idea 6)

- **Scope**: Write ADR-005 documenting the 7-10 business skill threshold and prerequisites for a domain split. Add a
  bash validator that emits WARN when threshold is crossed.
- **Effort**: Small (~half-day: ADR document + ~15 lines of bash)
- **Impact**: High — prevents costly re-analysis at P3 completion; codifies institutional knowledge
- **Priority**: P2 (second in sequence, after taxonomy establishes category vocabulary)
- **Dependencies**: Sub-task 1 (taxonomy defines the category vocabulary the ADR references)
- **⚠️ CONFLICT — see Conflicts section**: P3-23 currently claims "ADR-005 (Persona System ADR)". Numbering must be
  resolved.

### Sub-task 3: Parameterized Shared Content Infrastructure (Idea 2)

- **Scope**: Refactor `SHARED_DIR` hardcodes in `sync-shared-content.sh` and `skill-shared-content.sh` to accept env var
  or CLI argument. Removes the primary technical blocker to any future plugin split.
- **Effort**: Small (~20 lines of bash)
- **Impact**: High — removes the #1 coupling blocker; enables future multi-plugin architecture without breaking current
  workflow
- **Priority**: P2 (third in sequence — depends on ADR-005 establishing "what a split would look like")
- **Dependencies**: Sub-task 2 (ADR-005 defines the infra contract the parameterization must satisfy)

### Sub-task 4: Progressive Disclosure in wizard-guide (Idea 3)

- **Scope**: Add role-gated opening prompt (Technical Founder / Engineering Team / Founder-Operator) routing users to
  curated skill subsets. Single SKILL.md edit.
- **Effort**: Small (1 file edit)
- **Impact**: Medium — improves UX for non-bridge user segments without structural changes
- **Priority**: P2 (can run in parallel with Sub-tasks 2-3; only dependency is Sub-task 1 adding tags)
- **Dependencies**: Sub-task 1 (tags must exist before wizard-guide can route by them)

### Deferred: Shared Persona Layer Extraction (Idea 5)

- **Scope**: Move cross-domain personas to repo-root location. Medium effort, requires ADR-005 trigger conditions to
  fire.
- **Effort**: Medium (file moves + path updates across all SKILL.md spawn prompts)
- **Impact**: Medium — only valuable when split is imminent
- **Priority**: P3 (becomes a prerequisite in ADR-005, not a current action item)
- **Dependencies**: ADR-005 trigger conditions (7-10 business skills), P3-23 (Persona System ADR), P2-09 ✅

---

## Dependency Analysis

### Intra-P2-08 Sequence

```
Sub-task 1 (taxonomy) → Sub-task 2 (ADR-005) → Sub-task 3 (infra parameterization)
                      ↘ Sub-task 4 (wizard-guide progressive disclosure)
```

Sub-task 4 can begin as soon as Sub-task 1 lands. Sub-task 3 should wait for Sub-task 2 so the bash parameterization
aligns with the split model described in the ADR.

### Cross-Roadmap Dependencies

| Existing Item                          | Relationship            | Notes                                                                                                                                                 |
| -------------------------------------- | ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| P2-07 Role-Based Principles Split (✅) | Predecessor             | P2-07 established the shared content architecture that Sub-task 3 now parameterizes. No action needed — just confirming dependency is satisfied.      |
| P2-09 Persona System Activation (✅)   | Predecessor             | Persona system is stable before we touch wizard-guide (Sub-task 4) or persona extraction (Idea 5 deferred). Clean.                                    |
| P2-10 Skill Discoverability (✅)       | Predecessor / Extension | Sub-tasks 1+4 extend what P2-10 built in wizard-guide. Must not regress P2-10 improvements.                                                           |
| P3-08 Persona Reference Validator (🔴) | Soft successor          | P3-08 validates fictional names in spawn prompts. Any persona restructuring in Idea 5 (P3-gated) must happen before P3-08 runs against the new paths. |
| P3-23 Persona System ADR (🔴)          | **CONFLICT**            | P3-23 is currently labeled "ADR-005". Idea 6 (Sub-task 2) also targets ADR-005. Numbering collision — see Conflicts.                                  |
| P3-24 run-task Persona Archetypes (🔴) | Successor               | Follows P2-09 and P3-23. Not affected by P2-08 directly, but Idea 5 (persona extraction) must complete before P3-24 references are stable.            |

---

## Conflicts

### CONFLICT 1 (Critical): ADR-005 Numbering Collision

**The problem**: The roadmap index lists `P3-23-persona-system-adr.md` as "Persona System ADR (ADR-005)". The ideation
team recommends Sub-task 2 create "ADR-005 — Split Readiness ADR + Automated Gate".

Both claim ADR-005. Current ADR inventory: ADR-001 through ADR-004 exist. ADR-005 is the next available slot.

**Resolution recommendation**: P2-08 Sub-task 2 (Split Readiness) is P2 priority and will execute before P3-23
(not_started). It should claim ADR-005. P3-23 (Persona System ADR) should be renumbered to ADR-006 to avoid collision.

**Action required**: Team Lead must update P3-23 frontmatter to rename "ADR-005" → "ADR-006" when writing roadmap items
for this sprint.

### CONFLICT 2 (Minor): P2-08 Effort Overestimate

**The problem**: Current P2-08 frontmatter says `effort: medium`. All 4 PURSUE ideas are "small". The original "medium"
estimate anticipated a potential split decision and infra overhaul. The actual scope is much narrower.

**Resolution**: Update effort to `small` when revising P2-08. This affects roadmap burn-down estimates but has no
blocking implications.

### CONFLICT 3 (Minor): wizard-guide Double-Touch Risk

**The problem**: P2-10 (Skill Discoverability, ✅) already modified wizard-guide. Sub-task 1 (tags) and Sub-task 4
(progressive disclosure) both touch it again. If implemented as separate PRs, merge conflicts are likely.

**Resolution**: Batch Sub-task 1 wizard-guide changes and Sub-task 4 into a single implementation pass. Note this in the
P2-08 implementation guidance.

---

## Summary Recommendations for Team Lead

1. **Update P2-08** with revised title, effort (small), impact (high), and the 4-sub-task scope. Mark status
   `spec_in_progress`.
2. **Resolve ADR numbering**: Update P3-23 to claim ADR-006, freeing ADR-005 for the Split Readiness ADR.
3. **Sequence**: Implement Sub-task 1 first (it unblocks all others). Sub-task 4 can run in parallel with 2-3 once
   Sub-task 1 lands.
4. **No new P3 items needed**: Idea 5 (persona extraction) is already captured implicitly in P3-23 and P3-24. The
   ADR-005 will formally list it as a prerequisite. No separate P3 entry required.
5. **Idea 4 (virtual namespacing) and Idea 8 (split pilot) are closed**: REJECT and DEFER decisions are final per the
   ideation team. No roadmap entries.
