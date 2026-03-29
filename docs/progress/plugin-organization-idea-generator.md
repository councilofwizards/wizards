---
type: "progress"
topic: "plugin-organization"
role: "idea-generator"
agent: "Solara Brightforge"
task: "P2-08 Plugin Organization — Ideation"
generated: "2026-03-27"
status: "complete"
---

# Plugin Organization — Ideas (Solara Brightforge)

## IDEAS: Plugin Organization (P2-08)

---

### IDEA 1: Category Metadata in Skill Frontmatter + Plugin Manifest

**Evidence**: Research finding — "Internal reorganization via category metadata is the dominant strategy: low cost, zero
infrastructure risk" (Executive Summary). php-tomes precedent: 10 skills organized by topic without splits (Competitive
Landscape).

**Problem Solved**: Skills are undifferentiated in the plugin manifest. Engineering teams must visually parse all 17 to
find relevant skills. No machine-readable taxonomy exists to enable filtering, grouping, or future automated split.

**Scope**: incremental

**Notes**:

- Add `category: engineering | business | utility` and
  `domain: planning | build | ops | sales | hiring | communications` to each SKILL.md frontmatter
- Add matching category declarations in plugin.json
- No sync scripts, validators, or SKILL.md body changes required
- Creates the taxonomy that all future ideas (and a clean eventual split) depend on
- Could add A-series validator check: YAML frontmatter must include `category` field
- **Risk**: near-zero. Additive only.

---

### IDEA 2: Parameterized Shared Content Infrastructure

**Evidence**: Research finding — "Three infrastructure layers hardcode `plugins/conclave/shared/` paths" (Technical
Analysis). "All three break simultaneously if skills move to a new plugin directory."

**Problem Solved**: The hardcoded `SHARED_DIR` variable in sync-shared-content.sh and skill-shared-content.sh is the
primary technical blocker to any future split. Right now splitting costs a full infra rewrite.

**Scope**: incremental

**Notes**:

- Refactor `sync-shared-content.sh` and `validators/skill-shared-content.sh` to accept `SHARED_DIR` as an env variable
  or CLI argument with `plugins/conclave/shared/` as the default
- Zero behavior change today; massive optionality unlock for future splits
- Could be done in a single PR — ~20 lines of bash
- Pairs with Idea 6 (shared-layer abstraction) as a prerequisite
- **Risk**: near-zero if default behavior preserved

---

### IDEA 3: Progressive Disclosure in wizard-guide (Role-Gated Skill Menu)

**Evidence**: Research finding — "Founders/Operators (non-technical) find engineering terminology confusing.
wizard-guide already separates business from engineering." (Customer Segments). "Pain today: LOW — wizard-guide already
provides domain separation."

**Problem Solved**: Users who open wizard-guide see a flat all-17-skills landscape. Non-technical founders hit TDD and
API contract language immediately. The UX problem exists now at 17 skills and gets worse at 27+.

**Scope**: incremental

**Notes**:

- Add a "What's your role?" opening prompt to wizard-guide: Technical Founder / Engineering Team / Founder/Operator
- Route to a curated subset of skills based on answer, with an "show all" escape hatch
- Solves the "too many skills" UX problem without any structural changes
- Doesn't require splitting; works in the single plugin forever
- Could add a "recommend next skill" flow: "You ran plan-product — ready for build-product?"
- **Risk**: wizard-guide is single-agent and already works; this is additive UX polish

---

### IDEA 4: Virtual Plugin Boundaries via Skill ID Namespacing

**Evidence**: Research finding — "Adding plugins is structurally trivial (3 lines in marketplace.json). The marketplace
already supports multi-plugin installs." (Industry Trends). Option 1 boundary problem: planning skills orphaned by naive
engineering/business split.

**Problem Solved**: Users and docs want to refer to "business skills" or "engineering skills" as a coherent group, but
there's no declared boundary — it's tribal knowledge. Namespacing makes the boundary explicit without requiring a real
split.

**Scope**: incremental

**Notes**:

- Add skill ID prefixes in SKILL.md frontmatter: `id: biz/plan-sales`, `id: eng/build-implementation`,
  `id: util/wizard-guide`
- No filesystem moves, no plugin.json changes, no sync changes
- "Virtual" split: users and docs reference `biz/*` or `eng/*` cleanly
- Creates a migration path: when a real split happens, the new plugin directory matches the existing namespace
- Alternative: use tags instead of prefixes (`tags: [business, planning]`) — more flexible, searchable
- **Risk**: low; purely additive metadata

---

### IDEA 5: Shared Persona Layer Extracted to Standalone Module

**Evidence**: Research finding — "40+ shared persona files serve both engineering and business skills. Key cross-domain
personas: research-director, product-strategist, roadmap-analyst. A domain split requires either persona duplication
(drift risk) or a new shared abstraction layer." (Persona Coupling)

**Problem Solved**: Personas are the hidden coupling that survives the validator refactor (Idea 2). Even if infra is
decoupled, a real split still means duplicating 40+ persona files or inventing a shared abstraction. Solving this now
removes the last hard blocker to a clean split.

**Scope**: significant

**Notes**:

- Create `plugins/shared-personas/` at the repo root (sibling to `plugins/conclave/`)
- Move cross-domain personas there; leave skill-specific personas in their plugin
- Update sync script to pull from `plugins/shared-personas/` for cross-domain refs
- Add a new validator check: persona refs must resolve to either plugin-local or shared-personas path
- This is the architectural prep work that makes a future split from "expensive rewrite" to "copy a directory"
- **Risk**: medium — moves files, requires sync script + validator updates. But self-contained and reversible.

---

### IDEA 6: Split Readiness ADR + Automated Gate

**Evidence**: Research finding — "Timing recommendation: Medium confidence. Depends on P3 execution pace and domain
distribution." "Split threshold (7-10 skills): Low confidence. No comparable ecosystem data; educated estimate."
(Confidence Assessment)

**Problem Solved**: The split decision is currently manual and judgment-based. There's no documented trigger condition,
no checklist, and no automated signal that says "now is the time." When P3 completes and business skills hit 10+, the
team will have to re-research the same question.

**Scope**: incremental

**Notes**:

- Write ADR-005: "Plugin Split Readiness Criteria" — documents the threshold (7-10 business skills), the technical
  prerequisites (Ideas 2 + 5), and the decision process
- Add a simple bash validator or roadmap check that counts business skills and emits a WARN when threshold is crossed:
  `WARN: 8 business skills detected. Review ADR-005 for split readiness criteria.`
- Low cost to write; prevents future re-research
- Transforms a fuzzy "maybe someday" into an explicit, automated trigger
- **Risk**: near-zero; documentation + one small validator addition

---

### IDEA 7: Skill Discovery Tags + wizard-guide Search

**Evidence**: Research finding — "No usage telemetry (which skills are co-invoked, frequency). Unknown whether
plugin-level install granularity matters to users." (Data Gaps). php-tomes uses topic-based organization effectively.

**Problem Solved**: Skills are discovered by reading descriptions in wizard-guide or plugin.json. There's no way to
search by use case ("I need to do hiring"), domain ("show me business skills"), or pattern ("what skills use
Hub-and-Spoke?"). This is manageable at 17; it's a real problem at 27+.

**Scope**: incremental

**Notes**:

- Add `tags: []` array to SKILL.md frontmatter — e.g., `tags: [business, hr, planning, debate-pattern]`
- Update wizard-guide to surface skills by tag when user asks "show me X skills"
- Pairs naturally with Idea 3 (role-gated menu) and Idea 1 (category metadata)
- Tags also serve as the data layer for eventual filtered marketplace views
- A-series validator can enforce: every skill must have at least one tag
- **Risk**: near-zero; additive metadata + wizard-guide UX enhancement

---

### IDEA 8: Incremental Split Pilot — Business Skills Only

**Evidence**: Research finding — "Option 1: High effort, High risk. Version coupling forces joint version bumps."
(Option Analysis). "Business skills too few (3) to justify split overhead; threshold estimated at 7-10." (Executive
Summary)

**Problem Solved**: The split question will return at P3 completion. By piloting the split with just the 3 existing
business skills NOW (when the cost is lower and stakes are lower), the team learns the real cost of splitting, surfaces
unknown unknowns, and builds the tooling for the eventual real split.

**Scope**: significant

**Notes**:

- Create `plugins/conclave-business/` with just plan-sales, plan-hiring, draft-investor-update
- Discover what actually breaks: sync paths, validator paths, persona references, marketplace entries
- Document every friction point — this becomes the blueprint for the full split
- After the pilot, decide: merge back (if too painful) or proceed (if manageable)
- **Risk**: medium-high. This is the most invasive idea. Recommend only after Ideas 2 + 5 are complete. Best framed as a
  learning spike, not a production change.
- **Key value**: converts "split is expensive and risky" (estimated) into "split costs exactly these 12 steps" (known)

---

## Summary Table

| #   | Idea                                        | Scope       | Risk        | Unlocks                                      |
| --- | ------------------------------------------- | ----------- | ----------- | -------------------------------------------- |
| 1   | Category metadata in frontmatter + manifest | incremental | near-zero   | Machine-readable taxonomy                    |
| 2   | Parameterized shared content infra          | incremental | near-zero   | Future split without infra rewrite           |
| 3   | Progressive disclosure in wizard-guide      | incremental | near-zero   | UX fix for non-technical founders            |
| 4   | Virtual namespacing via skill IDs/tags      | incremental | near-zero   | Explicit boundaries without filesystem moves |
| 5   | Shared persona layer extraction             | significant | medium      | Removes last hard coupling blocker           |
| 6   | Split readiness ADR + automated gate        | incremental | near-zero   | Prevents re-research at P3 completion        |
| 7   | Skill discovery tags + wizard-guide search  | incremental | near-zero   | Scales to 27+ skills gracefully              |
| 8   | Incremental split pilot (business only)     | significant | medium-high | Real-world cost estimate for future split    |
