---
feature: "review-cycle"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed research report on remaining P2 candidates (P2-02, P2-03, P2-07)"
updated: "2026-02-18T18:00:00Z"
---

# Research Findings: Remaining P2 Roadmap Candidates

## Summary

Investigated the three remaining not-started P2 roadmap items against the current codebase state. Since the previous
review cycle, P2-04 (Automated Testing), P2-05 (Content Deduplication), and P2-06 (Artifact Format Templates) have all
been completed. The remaining candidates are P2-02 (Skill Composability), P2-03 (Progress Observability), and P2-07
(Universal Shared Principles). P2-08 (Plugin Organization) is listed but explicitly deferred until 2+ business skills
exist.

**Recommendation: P2-03 Progress Observability** should be the next feature to spec. It delivers the most user-facing
value at the lowest effort and risk, with no dependencies or prerequisite research needed.

## Current State (Facts)

### Completed Work

All P1 items (P1-00 through P1-03) and 4 of 8 P2 items are complete:

- P2-01 Cost Guardrails: `--light` mode, cost summaries -- complete
- P2-04 Automated Testing: 10 validation checks in CI via bash scripts -- complete
- P2-05 Content Deduplication: HTML comment markers, byte-identical shared content, ADR-002 -- complete
- P2-06 Artifact Format Templates: spec/progress/architecture templates -- complete

### Infrastructure Now Available

Since the last review cycle, the project gained:

1. **CI validation pipeline** (P2-04): `scripts/validate.sh` with 4 validators, GitHub Actions workflow
2. **Content drift detection** (P2-05): Shared section markers enable automated consistency checking
3. **Standardized templates** (P2-06): `_template.md` files in specs/, progress/, architecture/
4. **Business skill design guidelines** (`docs/architecture/business-skill-design-guidelines.md`): Multi-skeptic
   assignments, consensus-building patterns, quality-without-ground-truth framework

### Remaining P2 Items

| Item                              | Status      | Effort | Impact | Dependencies             | Roadmap File Exists? |
| --------------------------------- | ----------- | ------ | ------ | ------------------------ | -------------------- |
| P2-02 Skill Composability         | not_started | Large  | Medium | state-persistence (done) | Yes                  |
| P2-03 Progress Observability      | not_started | Medium | Medium | state-persistence (done) | Yes                  |
| P2-07 Universal Shared Principles | not_started | Medium | --     | --                       | **No** (index only)  |
| P2-08 Plugin Organization         | not_started | Medium | --     | Deferred                 | **No** (index only)  |

### Gap: Missing Roadmap Files for P2-07 and P2-08

The \_index.md references `P2-07-universal-principles.md` and `P2-08-plugin-organization.md`, but **neither file
exists**. These items were added to the index during the previous review cycle but no roadmap item files were created.
This is a data integrity issue -- the \_index.md links to non-existent files. The CI validator (C2/filename-convention)
may not catch this since it validates existing files, not broken links.

**Confidence**: High (verified via filesystem search).

---

## Candidate Analysis

### P2-03 Progress Observability -- RECOMMENDED

**What it solves**: Users have no consolidated view of team progress during skill runs. They must either watch
individual tmux panes (chaotic with 5 agents) or manually read checkpoint files in `docs/progress/`. There is no
"status" command.

**What already exists (partially implemented)**:

- Checkpoint protocol in all 3 SKILL.md files (agents write structured YAML-frontmatter progress files)
- Cost summary writing at end of sessions (P2-01)
- Progress template (`docs/progress/_template.md`) from P2-06
- Resume-from-checkpoint logic in all 3 skills' "Determine Mode" sections (empty-args scans for incomplete checkpoints)

**What's missing**:

1. A `status` argument mode in each skill's "Determine Mode" section
2. Summarization logic that reads all `docs/progress/{feature}-*.md` files and produces a consolidated view
3. Formalized end-of-session summary format

**Effort assessment**: **Small-medium** (downgraded from "medium" in the roadmap).

- The checkpoint infrastructure already exists -- this is a read-and-summarize operation
- No new file formats needed -- reads existing checkpoint YAML frontmatter
- No agent spawning for the status command -- single-agent read-only operation
- Changes to 3 SKILL.md files (add a mode to Determine Mode section)
- The end-of-session summary is partially implemented already (build-product step 7 mentions `{feature}-summary.md`)

**Impact assessment**: **Medium-high**.

- Every user benefits on every invocation -- visibility into what agents are doing
- Reduces anxiety during long-running skill sessions (5 Opus agents can run for several minutes)
- Enables informed decisions about when to interrupt/restart
- The end-of-session summary improves session-to-session continuity
- Low effort means high value-per-effort ratio

**Risk**: Low. Additive changes only. No architectural decisions needed. No platform research required.

**Confidence**: High (based on direct reading of all 3 SKILL.md files and checkpoint infrastructure).

### P2-02 Skill Composability -- DEFER

**What it solves**: Automates the plan-build-review pipeline into a single command.

**Assessment update since last cycle**: No changes to the fundamental analysis. The previous architect assessment
identified a **potential showstopper**: Claude Code's skill/plugin system may not support one skill programmatically
invoking another. This research question remains unanswered. Additionally:

- The manual workflow (user invokes skills sequentially) continues to work fine
- The handoff already works via artifact files (specs, progress, roadmap)
- The business skill design guidelines (new since last cycle) add more skill variants, increasing the combinatorial
  complexity of workflow definitions
- No user has reported the manual workflow as a pain point (inference: low confidence, no user feedback mechanism
  exists)

**Effort**: Large. Unchanged. Requires:

1. Platform research on skill-to-skill invocation
2. New SKILL.md file for `/run-workflow`
3. YAML workflow definition format
4. Handoff protocol formalization
5. Cross-skill error handling and state management

**Impact**: Medium. Convenience feature for power users. Manual workflow is functional.

**Risk**: High. Platform constraint may make the feature infeasible as designed.

**Recommendation**: Defer. Research the platform question as a prerequisite, potentially as a standalone investigation
rather than a full spec cycle. If skill-to-skill invocation isn't supported, re-scope to a "next step guide" pattern
(each skill writes guidance about what to invoke next).

**Confidence**: High on effort/risk assessment. Low on whether the platform constraint is real (would need hands-on
testing with Claude Code's API).

### P2-07 Universal Shared Principles -- NEEDS SCOPING

**What it solves**: The current Shared Principles (12 items across 4 tiers) are engineering-focused. The business skill
design guidelines document (`docs/architecture/business-skill-design-guidelines.md`) establishes separate quality
standards for business skills (assumptions & limitations, confidence levels, falsification triggers, external validation
checkpoints). P2-07 would unify these into a single principle set that works across all domains.

**What exists today**:

- Engineering-focused Shared Principles in all 3 SKILL.md files (12 numbered items)
- Business skill design guidelines in `docs/architecture/business-skill-design-guidelines.md` (skeptic enforcement
  checklist, consensus-building patterns, mandatory output requirements)
- ADR-002's validated duplication strategy with the 8-skill revision trigger

**The problem with doing this now**:

1. **No business skills exist yet**. The principles would be designed in a vacuum without real-world validation. The
   previous architect assessment noted: "one universal principle set + domain appendices is better than two separate
   principle sets." But without building even one business skill, we don't know which principles are truly universal vs.
   domain-specific.
2. **No roadmap file exists**. P2-07 has an \_index.md entry but no `P2-07-universal-principles.md` with problem
   statement, proposed solution, or success criteria. It needs basic scoping before it can be specced.
3. **The 8-skill trigger hasn't been reached**. ADR-002 set an explicit threshold: revisit content duplication strategy
   at 8+ skills. We currently have 3 skills. Generalizing principles before hitting that threshold is premature.

**Effort**: Medium. But the effort is speculative -- without a roadmap file defining scope, the real effort is unknown.

**Impact**: Medium for future skills. Zero for current skills (they already have working principles).

**Risk**: Medium. Risk of premature abstraction -- designing universal principles before any business skill validates
them.

**Recommendation**: Create the roadmap file to define scope, but defer the spec work until at least one business skill
(e.g., P3-10 /plan-sales) is built. Use the first business skill as a test case for which principles are truly
universal.

**Confidence**: Medium. The architectural direction (universal + appendices) seems sound, but the timing is premature.

### P2-08 Plugin Organization -- CORRECTLY DEFERRED

The \_index.md explicitly states: "Defer plugin organization until 2+ business skills are built and validated." This is
the right call. Zero business skills exist today. No further analysis needed.

---

## Gaps and Issues Not in the Roadmap

### Gap 1: Missing Roadmap Files for P2-07 and P2-08

As noted above, both items appear in \_index.md but have no corresponding roadmap files. This means:

- The CI validator (C1/required-fields) cannot validate their frontmatter
- The \_index.md links are broken
- Anyone reading the roadmap sees a reference to a non-existent file

**Recommendation**: Create stub roadmap files with `not_started` status and basic problem statements. This is a cleanup
task, not a spec cycle.

### Gap 2: Stale README Content (Persists from Last Cycle)

The previous researcher flagged README.md line 199 referencing hardcoded Laravel/PHP, which was removed in P1-03. This
remains unfixed.

**Recommendation**: Fix as a minor cleanup task.

### Gap 3: No User Feedback Mechanism

All prioritization is based on team analysis, not user input. There's no issue tracker, feedback form, or usage
telemetry. This limits confidence in impact assessments -- we're inferring user pain points, not measuring them.

**Recommendation**: Not a roadmap item. Note it as a limitation of the prioritization process.

---

## Recommended Priority Ordering

| Rank  | Item                              | Rationale                                                                                                                   |
| ----- | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| **1** | **P2-03 Progress Observability**  | Lowest effort, highest readiness, most user-facing value. No research needed. Builds on existing checkpoint infrastructure. |
| 2     | P2-07 Universal Shared Principles | Create the roadmap file now; defer spec until first business skill validates the approach.                                  |
| 3     | P2-02 Skill Composability         | Requires platform research before speccing. High effort, uncertain feasibility.                                             |
| 4     | P2-08 Plugin Organization         | Correctly deferred until 2+ business skills exist.                                                                          |

### Why P2-03 Over P2-07

The previous cycle recommended P2-05 -> P2-07 -> P2-04. P2-05 and P2-04 are now done. The previous ordering placed P2-07
before P2-03, but the rationale was "generalize principles for multi-domain expansion." Now that the business skill
design guidelines document exists (separate from the SKILL.md shared principles), the urgency of P2-07 has decreased --
there's already a reference document for business skill quality standards. P2-03, meanwhile, delivers immediate value to
every user on every invocation, has the lowest implementation risk, and requires no research or architectural decisions.

## Open Questions

1. Should P2-07 and P2-08 roadmap files be created as part of this cycle or tracked as a separate cleanup task?
2. Is there interest in building a business skill (e.g., P3-10 /plan-sales) as a "pathfinder" to validate the universal
   principles approach before speccing P2-07?
3. For P2-03: should the status command be a new argument mode in existing skills, or a standalone utility/skill?
