---
feature: "review-cycle-7"
team: "plan-product"
agent: "researcher"
phase: "findings-submitted"
status: "complete"
last_action: "Submitted findings to product-owner and product-skeptic"
updated: "2026-02-19"
---

# Review Cycle 7: Researcher Findings

## 1. Implementation Pipeline: P3-14 (plan-hiring)

**Status**: SPECCED ✅ AND IMPLEMENTED (uncommitted) — needs verification,
commit, and roadmap update.

**Evidence**:

- Spec: `docs/specs/plan-hiring/spec.md` — approved by product-skeptic
  (2026-02-19)
- System design: `docs/architecture/plan-hiring-system-design.md` — 1126 lines
- SKILL.md: `plugins/conclave/skills/plan-hiring/SKILL.md` — **1560 lines**
  (spec estimated 1400-1600)
- Validator: `scripts/validators/skill-shared-content.sh` — modified with 4 new
  sed expressions for bias-skeptic/fit-skeptic
- Build-product team progress files exist: impl-architect (complete),
  backend-eng (in_progress checkpoint but SKILL.md appears written),
  frontend-eng (complete — validator update), quality-skeptic (pre-impl gate
  approved)
- **All files are untracked in git** (`??` status). Nothing committed.
- Roadmap `_index.md` shows P3-14 as 🟢 `ready` — NOT updated to `complete`

**Assessment (High confidence)**: The build-product team appears to have
implemented P3-14. The SKILL.md exists at the expected size, the validator was
updated, and progress files from impl-architect, backend-eng, frontend-eng, and
quality-skeptic exist. However:

1. **No git commit** — all artifacts are untracked
2. **Post-implementation CI validation status unknown** — the quality-skeptic
   checkpoint shows pre-impl gate approved, but no post-impl review checkpoint
   found
3. **Roadmap not updated** — still shows `ready`, not `complete`
4. **Structured Debate pattern not validated by actual execution** — the
   SKILL.md was built but `/plan-hiring` has not been run to produce an actual
   hiring plan

**Blockers for P3-14 completion**: None structural. Needs: CI validation run,
post-impl verification, git commit, roadmap update to `complete`.

## 2. P2-07 (Universal Principles): 7/8 After P3-14

**ADR-002 threshold**: "When the skill count exceeds 8, revisit this approach."
Per P2-07 roadmap file: "ADR-002 threshold is 8+."

**Current skill count** (SKILL.md files on disk):

| #   | Skill                 | Status         | Shared Content?   |
| --- | --------------------- | -------------- | ----------------- |
| 1   | plan-product          | ✅ committed   | Yes               |
| 2   | build-product         | ✅ committed   | Yes               |
| 3   | review-quality        | ✅ committed   | Yes               |
| 4   | setup-project         | ✅ committed   | No (single-agent) |
| 5   | draft-investor-update | ✅ committed   | Yes               |
| 6   | plan-sales            | ✅ committed   | Yes               |
| 7   | plan-hiring           | 🟡 uncommitted | Yes               |

**Total**: 7 skills (6 committed + 1 uncommitted). 6 have shared content
markers.

**After P3-14 committed**: 7/8. **One more skill triggers P2-07.**

**Should we pre-plan?**

- RC6 recommended: "Re-assess P2-07 (7/8) in RC7." ✅ Doing that now.
- The next skill built (any P3 skill) will be #8, triggering the ADR-002
  revision threshold.
- Pre-planning is warranted: the Product Team should decide WHICH mechanism to
  use (includes, references, build-time injection) before the 8th skill is
  built, so the 8th skill can use the new approach from the start.
- **Recommendation**: Start pre-planning P2-07 in RC7/RC8. Don't spec yet, but
  identify the extraction mechanism so it's ready when skill #8 is built.

**P2-07 roadmap file is stale**: Says "Currently 5 total skills, 4 multi-agent
skills with shared content." Actual: 7 total, 6 with shared content. Needs
update.

## 3. P2-08 (Plugin Organization): Ready to Spec

**Prerequisite**: 2+ business skills built and validated. **MET** (2/2 validated
in RC6; plan-hiring adds a 3rd built but not yet validated).

**RC6 deferral condition**: "Spec P3-14 first, revisit in RC7." **MET** — P3-14
is specced and implemented.

**Current evidence for plugin boundary decisions**:

| Business Skill        | Pattern                | Status                          |
| --------------------- | ---------------------- | ------------------------------- |
| draft-investor-update | Pipeline               | ✅ validated                    |
| plan-sales            | Collaborative Analysis | ✅ validated                    |
| plan-hiring           | Structured Debate      | implemented, pending validation |

**3 business skills + 4 engineering skills = 7 total skills.** With 2 patterns
validated and 1 implemented (pending validation), there's sufficient data to
inform plugin boundaries.

**Options from P2-08 file**:

1. Split into `conclave-engineering` and `conclave-business` plugins
2. Split by collaboration pattern (hub-spoke, pipeline, collaborative-analysis,
   structured-debate)
3. Keep single plugin but reorganize internal directory structure

**Assessment (High confidence)**: P2-08 is ready to spec. The deferral
conditions from RC6 are all met. Three business skills across three patterns
provide meaningful data about skill diversity and organizational needs.

**Recommendation**: Spec P2-08 in the next product cycle.

## 4. P2-02 (Skill Composability): Low Priority, Not Blocking

**Status**: 🔴 `not_started`. Priority P2. Effort: Large.

**Dependencies**: Depends on P1-02 (state-persistence) ✅ complete. No reverse
dependencies — nothing in the roadmap lists P2-02 as a dependency.

**Is it blocking anything?** No. Checked all roadmap items — none declare a
dependency on P2-02.

**RC5 skeptic directive**: "Stop reporting P2-02." The skeptic determined this
is not a priority and doesn't warrant cycle time.

**Assessment (High confidence)**: P2-02 remains correctly parked. The
plan→build→review workflow chain is a valid user need but is not blocking
adoption or other roadmap items. Large effort with medium impact. No evidence
that users are requesting this.

**Recommendation**: Continue to deprioritize. Revisit only when user feedback
indicates demand for skill chaining.

## 5. P3 Backlog Assessment

**14 roadmap stubs created in RC6.** All remain 🔴 `not_started`. No changes
since creation.

### Business Skills by Pattern (from design guidelines)

| Pattern                | Skills                                                 | Count |
| ---------------------- | ------------------------------------------------------ | ----- |
| Collaborative Analysis | plan-marketing, plan-customer-success, plan-analytics  | 3     |
| Structured Debate      | plan-finance, review-legal, plan-operations            | 3     |
| Pipeline               | build-sales-collateral, build-content, plan-onboarding | 3     |

### Elevation Candidates

**Any P3 business skill built next will be skill #8, triggering P2-07.** This
creates a sequencing consideration:

1. **Option A**: Build the next business skill FIRST, then spec P2-07 and P2-08
   together. Risk: the 8th skill duplicates shared content that will soon be
   extracted.
2. **Option B**: Spec and implement P2-07 and P2-08 FIRST, then build the next
   business skill with the new architecture. More efficient but delays new
   user-facing features.
3. **Option C**: Spec P2-07 and P2-08 while the next business skill is being
   specced. Parallel track. Most efficient overall.

**No individual P3 item has a compelling case for elevation.** The P3 business
skills are all medium effort with similar impact profiles. The choice of which
to build next should be driven by:

- Which pattern benefits from a second implementation? (All three could use it)
- User demand (no data available)
- Strategic value to the framework as a whole

**If forced to pick one**: `plan-marketing` (P3-11) — Collaborative Analysis
pattern already validated, medium effort, natural complement to plan-sales.
Second Collaborative Analysis skill would further validate the pattern.

### Engineering P3 Items

| Item                     | Status | Notes                                                     |
| ------------------------ | ------ | --------------------------------------------------------- |
| P3-01 Custom Agent Roles | 🔴     | Large effort. Not urgent.                                 |
| P3-03 Contribution Guide | 🔴     | Small effort. Documentation. Could be done anytime.       |
| P3-04 Incident Triage    | 🔴     | First engineering business-adjacent skill. Medium effort. |
| P3-05 Tech Debt Review   | 🔴     | Medium effort. Useful but not urgent.                     |
| P3-06 API Design         | 🔴     | Medium effort. Depends on user need.                      |
| P3-07 Migration Planning | 🔴     | Large effort. Advanced use case.                          |

**No engineering P3 items warrant elevation.** None are blocking, and the
current focus on business skills (building toward P2-07/P2-08 thresholds) is the
right strategic direction.

## 6. Pattern Validation Status

| Pattern                | Pathfinder                    | Status                            | Confidence                                                                                                 |
| ---------------------- | ----------------------------- | --------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Pipeline               | P3-22 (draft-investor-update) | ✅ VALIDATED                      | High — implemented and producing real output                                                               |
| Collaborative Analysis | P3-10 (plan-sales)            | ✅ VALIDATED                      | High — implemented with 1182-line SKILL.md, lessons extracted                                              |
| Structured Debate      | P3-14 (plan-hiring)           | 🟡 IMPLEMENTED, NOT YET VALIDATED | Medium — SKILL.md exists (1560 lines) but `/plan-hiring` has not been run to produce an actual hiring plan |

**Key distinction**: "Implemented" means the SKILL.md was written by the
build-product team. "Validated" means the skill was run and produced a real
output that demonstrates the pattern works. Pipeline and Collaborative Analysis
are both validated. Structured Debate is implemented but pending first
execution.

**What validation requires**: Run `/plan-hiring` on a project (even with minimal
user data) and confirm: (1) the 6-phase protocol executes, (2) cross-examination
produces substantive challenges, (3) position tracking works, (4) synthesis is
coherent, (5) both skeptics produce meaningful reviews.

## 7. Delta Since RC6

| Change                          | Detail                                                              | Evidence                                                       |
| ------------------------------- | ------------------------------------------------------------------- | -------------------------------------------------------------- |
| P3-14 specced                   | Spec approved by product-skeptic. 20 success criteria.              | `docs/specs/plan-hiring/spec.md`                               |
| P3-14 system design             | 1126-line architecture document.                                    | `docs/architecture/plan-hiring-system-design.md`               |
| P3-14 implemented (uncommitted) | 1560-line SKILL.md + validator update. Build-product team executed. | `plugins/conclave/skills/plan-hiring/SKILL.md`, progress files |
| Validator updated               | 4 new sed expressions for bias-skeptic/fit-skeptic                  | `scripts/validators/skill-shared-content.sh` modified          |
| Skill count                     | 6 → 7 (with uncommitted plan-hiring)                                | 7 SKILL.md files on disk                                       |
| P2-07 progress                  | 6/8 → 7/8                                                           | One more skill triggers extraction threshold                   |
| P2-08 readiness                 | Deferred in RC6 → All deferral conditions met                       | 3/3 business skills, P3-14 specced+implemented                 |
| Business skill count            | 2 → 3 (with plan-hiring)                                            | draft-investor-update, plan-sales, plan-hiring                 |
| Patterns implemented            | 2 validated + 1 specced → 2 validated + 1 implemented               | Structured Debate advanced from spec to implementation         |

**What did NOT change**:

- P2-02 (Skill Composability): Still 🔴 not_started. No activity.
- P2-07 (Universal Principles): Still 🔴 not_started. Count advanced but
  threshold not met.
- P2-08 (Plugin Organization): Still 🔴 not_started. But deferral conditions now
  met.
- All 14 P3 stubs from RC6: Still 🔴 not_started.
- P2-07 roadmap file: Stale — says "4 multi-agent skills" but actual count is 6
  with shared content.

## Recommended Actions for RC7

1. **Verify and commit P3-14 implementation** — Run CI validators, confirm
   SKILL.md passes all checks, commit all plan-hiring artifacts, update roadmap
   to ✅ `complete`.
2. **Validate Structured Debate pattern** — Run `/plan-hiring` to produce a real
   hiring plan. This is the final step to mark the pattern as VALIDATED.
3. **Pre-plan P2-07 (Universal Principles)** — At 7/8, decide the extraction
   mechanism now. Don't spec yet, but document the technical approach so it's
   ready when skill #8 is built. P2-08 plugin boundaries depend on knowing how
   shared content extraction works.
4. **Spec P2-08 (Plugin Organization)** — All deferral conditions met. 3
   business skills, 2 validated + 1 implemented patterns. Spec AFTER P2-07
   extraction mechanism is decided.
5. **Update P2-07 roadmap file** — Correct the stale count (4 → 6 multi-agent, 7
   total).
6. **Continue to park P2-02** — Per RC5 skeptic directive. Not blocking
   anything.
