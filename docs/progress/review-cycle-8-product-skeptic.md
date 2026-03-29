---
feature: "review-cycle-8"
team: "plan-product"
agent: "product-skeptic"
phase: "review-complete"
status: "complete"
last_action: "Reviewed researcher and architect findings for RC8"
updated: "2026-02-19"
---

# Review Cycle 8 — Product Skeptic Review

## REVIEW: Researcher Findings + Architect Assessment (Review Cycle 8)

**Verdict: APPROVED with 5 corrections and 2 conditions.**

Both reports are substantive, well-evidenced, and internally consistent with
each other. The researcher's expanded Section 8 (opportunities analysis) adds
real value. The architect's build-time injection design is architecturally
sound. However, both agents repeat a threshold interpretation error I flagged in
RC6, the architect has one stale recommendation, and the P2-08 roadmap file
needs a dependency update.

---

## A. Evidence Quality

### Researcher

| Section                         | Quality  | Notes                                                       |
| ------------------------------- | -------- | ----------------------------------------------------------- |
| P3-14 commit verification       | STRONG   | Hard evidence: commit hash, git status, validator output    |
| Structured Debate not validated | STRONG   | Negative evidence (glob returned nothing) is the right test |
| P2-07 file accuracy             | STRONG   | Direct file read confirms "6 multi-agent, 7 total"          |
| P2-08 prerequisites             | STRONG   | 2/2 validated business skills correctly identified          |
| P3 backlog triage               | MODERATE | Subjective rankings (researcher flagged this honestly)      |
| RC7 action sequence             | STRONG   | 3/6 complete, evidence chain for each item                  |
| Section 8 (opportunities)       | STRONG   | Substantive, actionable, with effort/value assessments      |

### Architect

| Section                       | Quality | Notes                                                       |
| ----------------------------- | ------- | ----------------------------------------------------------- |
| Build-time injection analysis | STRONG  | Three options evaluated, rejections well-reasoned           |
| Claude Code constraint claim  | STRONG  | Correct — SKILL.md is static markdown, no include mechanism |
| P2-08 boundary analysis       | STRONG  | Domain split justified, pattern split correctly rejected    |
| P2-07→P2-08 dependency        | STRONG  | Binding constraint argument is logically sound              |
| Risk register                 | GOOD    | Identifies real risks with concrete mitigations             |

**Overall evidence quality: HIGH for both agents.**

---

## B. Consistency Check

Both agents agree on all material facts:

| Claim                                   | Researcher | Architect                        | Match? |
| --------------------------------------- | ---------- | -------------------------------- | ------ |
| Total skill count                       | 7          | 7                                | YES    |
| Multi-agent with shared content         | 6          | 6                                | YES    |
| P2-07 is 1 skill from trigger           | Yes        | Yes                              | YES    |
| Structured Debate not validated         | Yes        | "not yet validated by execution" | YES    |
| P2-08 prerequisites met (2/2)           | Yes        | N/A (not their scope)            | N/A    |
| P2-07 must precede P2-08                | Yes        | Yes                              | YES    |
| RC7 actions 3/6 done                    | Yes        | N/A (not their scope)            | N/A    |
| Pattern classification (5 patterns)     | Matches    | Matches                          | YES    |
| Business skills larger than engineering | 2.7x noted | Table confirms                   | YES    |

**No contradictions between the two reports.**

---

## C. Corrections

### Correction 1: ADR-002 Threshold — Both Agents Repeat a Known Error

**CRITICAL.** I flagged this in RC6. Both agents ignore the correction.

ADR-002 line 55-57 says: **"When the skill count exceeds 8, revisit this
approach."**

"Exceeds 8" means **>8**, not **>=8**. The trigger fires at the **9th** skill,
not the 8th.

The researcher writes: "ADR-002 extraction threshold: **8 skills**" and then in
the same sentence quotes "When the skill count exceeds 8" — this is internally
contradictory. Exceeds 8 ≠ 8.

The P2-07 roadmap file says: "ADR-002 sets the extraction threshold at 8 skills"
and "One more multi-agent skill triggers the threshold." Both are incorrect per
the literal ADR-002 language.

The architect writes: "One more multi-agent skill triggers extraction" — same
error.

**Impact on recommendations: NONE.** Pre-planning at 7 skills is prudent
regardless of whether the trigger is at 8 or 9. Both agents' recommendation to
pre-plan NOW is correct. But the P2-07 roadmap file must be corrected, and
agents should stop misquoting ADR-002.

**Fix**: Update P2-07 trigger condition to: "Per ADR-002: 'When the skill count
exceeds 8, revisit this approach.' Exceeds means >8. The trigger fires at the
9th skill. Current count: 7 total. Pre-planning at 7 is prudent per RC5
recommendation to plan ahead of the trigger."

### Correction 2: Architect's P2-07 "Update Roadmap File" Recommendation Is Stale

The architect's Section 6, Immediate Action #2 says: "Update P2-07 roadmap file
| Stale: says '4 multi-agent skills' but actual is 6."

The researcher verified in Section 3 that this was **already done in RC7 Action
#3**. P2-07 now reads "6 multi-agent skills." The architect did not cross-check
the researcher's finding on this point.

**Fix**: Remove this from the architect's action list. It's already complete.

### Correction 3: P2-08 Frontmatter Missing P2-07 Dependency

Both agents (and RC7) establish that P2-08 depends on P2-07. But the P2-08
roadmap file's frontmatter says `dependencies: []`. This should be updated to
reflect the agreed dependency.

**Fix**: Update `docs/roadmap/P2-08-plugin-organization.md` frontmatter to
`dependencies: ["universal-shared-principles"]` or similar.

### Correction 4: ADR-002 "skill count" Ambiguity Remains Unresolved

ADR-002 says "skill count" without specifying whether this means total skills or
multi-agent skills with shared content. The contextual clue is line 57: "editing
8+ files for a single principle change" — this refers to files that carry shared
content, which is multi-agent skills only (setup-project has no shared content).

The P2-07 file conflates total skills (7) with the trigger for shared content
extraction. If the trigger is about editing burden, only the 6 multi-agent files
matter. The 9th total skill might be another single-agent skill that doesn't
change the shared content editing burden at all.

**Practical impact**: At 6 multi-agent skills, we're well into "pre-planning is
warranted" territory regardless. But the ambiguity should be resolved in
ADR-003.

**Fix**: ADR-003 should explicitly define the counting methodology: "The
threshold counts multi-agent skills carrying shared content markers, not total
skills."

### Correction 5: Researcher's P3 Backlog Is Missing P3-08 and P3-09

The roadmap index jumps from P3-07 to P3-10. The researcher's triage lists 15
not-started items but doesn't mention P3-08 or P3-09. If these IDs were
intentionally skipped (reserved or merged), that should be documented. If they
exist somewhere, the researcher missed them.

**Fix**: Confirm whether P3-08 and P3-09 exist or were intentionally skipped.
Document the gap either way.

---

## D. P2-07 Timing Assessment

The architect's build-time injection recommendation is **correct and
well-designed**.

**Key validations:**

1. Claude Code's SKILL.md is static markdown with no include/import mechanism —
   confirmed by the architect and consistent with my understanding.
2. Options A (includes) and B (references) correctly rejected — they break
   self-containment.
3. Build-time injection preserves the core property: at runtime, every SKILL.md
   is a complete, standalone document.
4. Existing HTML comment markers serve as injection boundaries — no new markers
   needed.
5. Frontmatter-based skeptic name substitution is elegant — reuses the existing
   per-skill variation mechanism.

**One concern**: The architect proposes frontmatter fields (`review-skeptic`,
`review-skeptic-display`) but doesn't verify whether Claude Code's skill loading
ignores unknown frontmatter fields or chokes on them. This MUST be tested before
ADR-003 is finalized.

**Timing**: Both agents correctly identify that pre-planning should happen NOW
(before skill #8 enters spec). This is consistent with RC5's recommendation to
"pre-plan at 7" and RC7's action sequence. The fact that the ADR-002 trigger is
technically at 9, not 8, doesn't change this — pre-planning with adequate lead
time is better than scrambling at the trigger point.

---

## E. P2-08 Readiness

The architect's domain split recommendation is **sound but premature to
implement**.

- Prerequisites met: 2/2 validated business skills (draft-investor-update +
  plan-sales).
- Domain boundary is clear: 4 engineering + 3 business.
- Pattern-based split correctly rejected (5 groups for 7 skills is
  over-partitioned).
- **Option 3 (internal reorganization)** should be the default unless
  operational pain is demonstrated. The architect flags this as "acceptable as
  interim" but I'd strengthen it: it should be the **first choice** unless
  Claude Code can't discover skills in subdirectories. Investigate that question
  before defaulting to a multi-plugin split.

**Key question unresolved by the architect**: Does Claude Code scan nested
directories under `skills/`? If yes, Option 3 is strictly superior (no
cross-plugin shared content management needed). If no, the domain split adds
complexity for unclear benefit at 7 skills. This must be investigated as part of
P2-08 spec work.

---

## F. New Features / Scripts / Cross-Skill Utilities

The researcher addressed this well in Section 8. The architect did not address
it (acceptable — it wasn't in their task scope).

### My Assessment of Researcher's Proposals

**Tier 1 — Do immediately (before next skill build):**

| Proposal                   | Value | Skeptic Assessment                                                                                                                                |
| -------------------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Shared content sync script | HIGH  | **YES.** This is the P2-07 precursor. Solves the immediate pain of editing 6 files. Should be the first thing built regardless of ADR-003 timing. |
| README update              | HIGH  | **YES.** User-facing documentation gap. Anyone discovering the project sees 3/7 skills. Low effort, high impact.                                  |

**Tier 2 — Do soon (can be P3 items or standalone tasks):**

| Proposal                   | Value       | Skeptic Assessment                                                                                                                                                                                                           |
| -------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Skill scaffolding script   | MEDIUM-HIGH | **YES, but after P2-07 design.** The scaffolding script should generate SKILL.md with the P2-07 mechanism in mind (e.g., running the build script post-scaffold). Building it before P2-07 design means rebuilding it after. |
| Cost aggregation script    | MEDIUM      | **YES.** 18 cost files with no aggregation is a missed opportunity. Small effort.                                                                                                                                            |
| Stale checkpoint validator | MEDIUM      | **YES.** RC7 flagged the stale backend-eng checkpoint. A validator check catches this class of error.                                                                                                                        |

**Tier 3 — Defer:**

| Proposal                    | Value      | Skeptic Assessment                                                                                                                 |
| --------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Roadmap dashboard script    | LOW-MEDIUM | **DEFER.** The manual index works. Auto-generating it is nice-to-have.                                                             |
| Output format standardizer  | MEDIUM     | **DEFER.** Depends on P2-07 mechanism. Don't design output extraction before the shared content extraction pattern is established. |
| User data template registry | LOW        | **DEFER.** Part of P2-08 scope. Premature now.                                                                                     |
| Additional stack hints      | MEDIUM     | **DEFER.** Nice for adoption but we're not at the adoption optimization phase.                                                     |

### Net-New Skill Assessment

The researcher proposes 4 new skill concepts. My assessment:

| Skill                   | Researcher's Assessment           | Skeptic's Assessment                                                                                     |
| ----------------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `/retrospective`        | Highest value, self-dogfooding    | **AGREE.** High value. But: triggers P2-07. Only build after extraction mechanism is designed.           |
| `/plan-infrastructure`  | High for technical startups       | **MODERATE.** Overlaps with plan-product's architecture/technology discussions. Differentiation unclear. |
| `/competitive-analysis` | Medium, overlap with plan-product | **LOW.** The researcher correctly identifies the overlap. Not worth a dedicated skill.                   |
| `/design-system`        | Medium, more for larger teams     | **LOW.** Niche audience. Not a priority for a startup-focused framework.                                 |

### Ideas the Researcher Missed

1. **Skill regression test harness.** We have no way to test that SKILL.md
   changes don't break agent behavior. A harness that invokes a skill with a
   canned scenario and validates output structure would catch regressions. This
   is more valuable than any individual new skill.

2. **Cost budget enforcement script.** The researcher proposes cost aggregation,
   but the real value is enforcement: a pre-flight check that estimates session
   cost and warns if it exceeds a per-skill budget. This would make P2-01 (Cost
   Guardrails) more actionable.

3. **Skill diff report.** When reviewing a SKILL.md change (e.g., PR review), a
   script that shows only the non-shared-content diff would help reviewers focus
   on what actually changed. Shared content changes are already validated by
   B1/B2/B3.

---

## G. Stale Data

| Item                    | Issue                                                                                                                                         | Severity            |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| README.md               | Lists 3/7 skills. Missing setup-project, draft-investor-update, plan-sales, plan-hiring. Project structure section wrong. Cost section wrong. | HIGH (user-facing)  |
| P2-07 trigger wording   | Says "threshold at 8 skills" — should be "exceeds 8" per ADR-002 (trigger at 9)                                                               | MEDIUM              |
| P2-08 frontmatter       | `dependencies: []` should include P2-07                                                                                                       | MEDIUM              |
| P2-05 problem statement | Says "3 skills" — stale but P2-05 is complete, so low impact                                                                                  | LOW                 |
| ADR-002 context section | Says "Three SKILL.md files" — historical, accurate at time of writing                                                                         | LOW (informational) |
| P3-08 and P3-09         | Missing from roadmap index. Intentional skip or error?                                                                                        | LOW                 |

---

## H. Recommended Action Sequence (Updated from RC7)

Based on both reports, RC7 sequence progress, and the PO's request for new
feature/script ideas:

### Immediate (this cycle or next):

1. **Fix P2-07 trigger wording** — Correct the "threshold at 8" to accurately
   reflect ADR-002's "exceeds 8" language. Clarify counting methodology (total
   vs multi-agent).
2. **Update P2-08 dependencies** — Add P2-07 as a dependency in frontmatter.
3. **Update README** — Reflect all 7 skills, correct project structure, update
   cost section.
4. **Build shared content sync script** — `scripts/sync-shared-content.sh`. This
   is the P2-07 precursor and solves current manual editing pain immediately.
   Small effort, high value.
5. **Draft ADR-003 for P2-07 build-time injection** — Per architect's design.
   Resolve: (a) frontmatter extension compatibility with Claude Code, (b)
   counting methodology, (c) source file location.

### Before next skill build:

6. **Validate Structured Debate** — Run `/plan-hiring` with a real scenario.
   This is RC7 Action #2 and is still undone.
7. **Build cost aggregation script** — `scripts/cost-report.sh`. Small effort.
8. **Add stale checkpoint validator** — Extend progress-checkpoint.sh to flag
   `in_progress` checkpoints older than N days.

### After ADR-003 is finalized:

9. **Build skill scaffolding script** — Generates skeleton SKILL.md with P2-07
   mechanism support.
10. **Spec P2-08** — With P2-07 extraction mechanism designed. Investigate
    Claude Code nested directory discovery first.
11. **Spec next P3 skill** — P3-11 (plan-marketing) or P3-04 (triage-incident),
    depending on business vs engineering priority. Either triggers P2-07
    implementation.

---

## Conditions for Approval

1. **Correction 1 must be actioned**: P2-07 roadmap file must correctly
   represent the ADR-002 trigger language. Agents must stop saying "threshold at
   8" when ADR-002 says "exceeds 8."

2. **ADR-003 must resolve the counting methodology**: Before any agent
   references the P2-07 threshold again, we need a clear definition of whether
   "skill count" means total skills or multi-agent skills with shared content.

These are documentation corrections, not blocking issues for the cycle. The
findings and recommendations from both agents are sound and actionable.

---

**APPROVED** with the 5 corrections and 2 conditions above.

---

## Addendum: Architect Expanded Sections (7-11)

The architect submitted Sections 7-11 after my initial review. Assessment
follows.

### Section 7: Cross-Skill Structural Extraction

**Assessment: STRONG. The most architecturally significant new finding in RC8.**

The architect identifies 4 additional SKILL.md sections that are near-identical
across all 6 multi-agent skills: Setup (base steps), Write Safety, Checkpoint
Protocol, and Failure Recovery. Line-number references make claims verifiable.

The recommendation — design P2-07's build-time injection to accommodate
parameterized templates, not just verbatim content injection — is sound. This
means the build script needs variable substitution (team name, output directory,
skeptic count, phase list) from frontmatter, not just copy-paste between
markers.

**One pushback**: Don't scope-creep P2-07. The immediate P2-07 deliverable
should be principles + communication-protocol extraction (the two
already-tracked shared sections). The 4 additional candidates go into a P2-07
Phase 2 or a separate item. The mechanism should _accommodate_ them but the
first implementation should not attempt to extract them. The architect says this
("doesn't change the P2-07 immediate scope") but I want it stated as a hard
constraint, not a suggestion.

### Section 8: Helper Scripts

| Script                                   | Architect's Claim                                          | My Assessment                                                                                                                                                                                                  |
| ---------------------------------------- | ---------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scaffold-skill.sh` (8b)                 | Reduces copy-paste problem                                 | **DEFER to after P2-07 design.** Both agents propose this. Both are right about the value. But the format is still evolving (researcher also flagged this risk). Build after extraction mechanism is designed. |
| F-series output validator (8c)           | Catches structural drift in business skill output sections | **LOW PRIORITY.** We have 3 business skills with no reported output format drift. The validator would catch a problem that hasn't manifested. Build when we have 5+ business skills.                           |
| G-series stale checkpoint validator (8d) | Addresses RC7 finding directly                             | **APPROVED.** G2 (cross-team comparison) and G3 (contradictory state) are better checks than simple mtime-based staleness. This directly addresses a real problem found in RC7. Small effort, clear value.     |

### Section 9: Cross-Skill Utilities

**9a (Shared User Data Pattern)**: Agree with architect's "low urgency at 3
business skills." Defer to P2-08 scope.

**9b (Stack Hints)**: Both agents flag this. I maintain DEFER — only matters if
external adoption is a goal.

**9c (Project CLAUDE.md): NEW FINDING. HIGH PRIORITY.**

This is the most actionable catch in the expanded analysis. The project
generates CLAUDE.md for user projects via setup-project but doesn't have one
itself. This means every Claude Code session on this repo starts cold with no
project context — no knowledge of the validator commands, skill structure,
shared content conventions, or ADR decisions.

**This should be item #1 on the immediate action list.** Small effort, high
ongoing value, no dependencies. I'm adding it to my recommended action sequence.

### Section 10: Net-New Skills

Both agents independently rank `/run-retro` (researcher: `/retrospective`) as
the highest-priority net-new skill. Convergence increases confidence. The SDLC
loop argument (plan → build → review → **reflect**) is compelling.

`/audit-deps` is a reasonable new concept the researcher didn't propose. Supply
chain quality is a real gap.

`/write-docs` and `/plan-sprint` are lower priority. Agree with deferral.

### Updated Action Sequence (Revised)

**Immediate (this cycle or next):**

1. **Create project CLAUDE.md** — NEW, from architect's Section 9c. No
   dependencies, small effort, high ongoing value.
2. Fix P2-07 trigger wording
3. Update P2-08 dependencies
4. Update README
5. Build shared content sync script
6. Draft ADR-003 for P2-07 build-time injection — must accommodate parameterized
   templates for future extraction (per architect's Section 7), but Phase 1
   scope is principles + communication-protocol only.

**Before next skill build:**

7. Validate Structured Debate
8. Build cost aggregation script
9. Build G-series stale checkpoint validator

**After ADR-003:**

10. Scaffolding script
11. Spec P2-08
12. Spec next P3 skill (or `/run-retro` if the team agrees it outranks existing
    P3 stubs)
