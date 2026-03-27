---
type: "skeptic-review"
feature: "Batch Plan-Product: P2-07, P2-10, P2-12"
status: "in-progress"
created: "2026-03-27"
updated: "2026-03-27"
---

# Skeptic Reviews — Batch Plan-Product

## P2-10: Skill Discoverability Improvements — Stories

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/progress/skill-discoverability-story-writer.md`
**Roadmap**: `docs/roadmap/P2-10-skill-discoverability.md`

### Verdict: APPROVED

All five stories are well-structured, INVEST-compliant, and properly scoped against the roadmap item. Minor observations below — none are blocking.

### Story-by-Story Assessment

**Story 1 (Business Skills Section)** — Strong. AC 4 (fix stale tier labels in the same pass) is a smart catch — the roadmap doesn't mention it, but shipping a wizard-guide update that still says "Tier 1/Tier 2" when ADR-004 killed that architecture would be embarrassing. Correctly scoped as a natural cleanup within the edit pass.

**Story 2 (wizard-guide in setup-project)** — Clean. Verified that `--dry-run` and `--force` are real modes in setup-project SKILL.md, so AC 3 and the edge cases are grounded, not hallucinated. The "before `/plan-product`" ordering constraint is explicit and testable.

**Story 3 (Lore Preamble)** — Good. The word count criteria are measurable (80–120 target, 150 hard cap). The edge case guidance for `list`, `explain`, and `recommend` modes is thoughtful — preamble in default mode only, omit elsewhere. The tone guardrail ("evocative but not cryptic") gives the implementer enough latitude without leaving it undefined.

**Story 4 (Persona Spotlight)** — Solid. AC 2 (cross-reference against actual agent roles) prevents invented personas. The hard cap at 5 is clear. The note about choosing structurally stable roles (Lead, Skeptic, Builder) over skill-specific names is good future-proofing guidance.

**Story 5 (Pushy Descriptions)** — Appropriately scoped as could-have. The "trigger when" pattern is concrete and the 3-line length cap prevents bloat. The note about updating business skill descriptions first (most likely to be missed) is correct prioritization. This is additive to the roadmap but doesn't distort the core scope.

### Cross-Cutting Observations

- **Scope alignment**: Stories 1–4 map 1:1 to the roadmap's four bundled changes. Story 5 is an addition justified by harness best practices. No roadmap scope is missing.
- **Out of Scope section**: Correctly constrains edits to wizard-guide and setup-project SKILL.md files only. No validator logic changes needed (both are single-agent, excluded from B-series).
- **Non-Functional Requirements**: Accurate — shared content sync is irrelevant for these two skills.
- **Testability**: Every story has a validator pass as a final AC. Stories 1, 3, and 4 have mode-specific behavior (list vs. default) that will need manual verification since wizard-guide is agent-rendered.

### What I Checked

1. INVEST compliance for each story (Independent, Negotiable, Valuable, Estimable, Small, Testable)
2. Coverage of all 4 roadmap bundled changes
3. Accuracy of technical claims (dry-run mode exists, tier labels are stale, single-agent exclusion from B-series)
4. Edge cases are grounded in real skill behavior, not hypothetical
5. Acceptance criteria are specific and measurable

---

## P2-07: Role-Based Principles Split — Stories

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/progress/principles-split-story-writer.md`
**Roadmap**: `docs/roadmap/P2-07-universal-principles.md`

### Verdict: APPROVED (Round 2)

Round 1 rejected for `write-stories` misclassified as engineering in Story 2 AC2. Fix confirmed: `write-stories` moved to AC1 non-engineering list, removed from AC2 engineering list. Classification now consistent across Story 2 ACs, Story 2 edge cases, and Story 4 AC4.

### Story-by-Story Assessment

**Story 1 (Split Principles File)** — Solid. The two-sub-block approach (universal-principles + engineering-principles within a single file) is cleaner than two separate files. AC3 correctly addresses the fate of the outer `principles` wrapper. The principle numbering checks out: verified against `plugins/conclave/shared/principles.md` — items 1–3 + 9–12 = universal (7 items), items 4–8 = engineering (5 items). Matches roadmap exactly.

**Story 2 (Sync Script Update)** — Good design decisions. The hardcoded classification list is the right call — no frontmatter field exists for this, and inventing one is correctly out-of-scoped. The safe default (unknown = engineering, WARN) is correct. Pipeline skills (plan-product, build-product) classified as engineering is a defensible scope expansion beyond the roadmap's 5 named skills — they orchestrate engineering agents. The staged migration (old markers get WARN, not hard fail) is smart. Round 2 fix confirmed: `write-stories` correctly in non-engineering list.

**Story 3 (B-Series Validator Update)** — Strong. AC2 (flag engineering block in non-engineering skill) catches the reverse drift direction. AC7 (old markers flagged as unexpected) handles the migration path. The note about extracting the classification list to a shared variable to prevent duplication drift between sync script and validator is excellent guidance.

**Story 4 (Classification Documentation)** — Appropriately scoped as should-have. The explicit classification table in AC4 is the canonical reference and correctly matches the roadmap. The edge case notes (write-stories reasoning, run-task safe default, future business skill default) are well-documented.

### Cross-Cutting Observations

- **Scope alignment**: Stories 1–3 map to the three deliverables in the roadmap (split file, sync update, validator update). Story 4 is additive documentation. No roadmap scope is missing.
- **NFRs**: Idempotency, staged migration, zero regressions — all correct.
- **Out of Scope**: Correctly excludes content changes to principles themselves, Communication Protocol changes, and automated frontmatter-based detection.

### Resolution

Round 1 blocking issue resolved. `write-stories` classification now consistent across all stories.

---

## P2-12: QA Agent for Live Testing — Stories

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/progress/qa-agent-story-writer.md`
**Roadmap**: `docs/roadmap/P2-12-qa-agent-live-testing.md`

### Verdict: APPROVED (Round 2)

Round 1 rejected for NFR "Write safety" contradicting Story 2 (prohibited QA agent from writing test files). Fix confirmed: NFR now permits writes to progress file and project test directory, while still prohibiting writes to application source, spec, contract, and other agent progress files.

### Story-by-Story Assessment

**Story 1 (QA Spawn in build-implementation)** — Strong. The `--light` mode decision (QA gate is NOT removable) is correct — live testing is a quality gate, not optional. Opus model for the evaluation role matches the Sonnet/Opus principle (#12). The orchestration placement (after quality-skeptic, before Lead sign-off) matches the roadmap's "Integration point" specification exactly.

**Story 2 (Playwright Test Writing)** — Well-designed. The fallback hierarchy (sprint contract → stories → spec) is practical and handles the P2-11 soft dependency gracefully. AC2's behavioral test naming requirement ("user can complete checkout" not "POST /api/checkout returns 200") enforces the roadmap's "user-facing behaviors" mandate. The edge case for implementation-framed AC rewriting is smart. The INCONCLUSIVE handling for non-Playwright-testable criteria (background jobs) is pragmatic.

**Story 3 (Test Execution & Verdict)** — Clean. The tri-state verdict (APPROVED / REJECTED / BLOCKED) is well-defined. BLOCKED for infrastructure failures vs. REJECTED for test failures is the right distinction. The flaky test retry (up to 2 re-runs) is practical. AC6 (re-run only failing tests) is a nice efficiency touch. The "no conditional approval" rule prevents negotiation around failures.

**Story 4 (build-product Integration)** — Solid. The checkpoint state extension (`qa-testing` as a new phase value) is correctly scoped. The resumption logic (skip if approved, resume fix cycle if rejected, run fresh if not started) covers all states. The stage-skip edge case (planning skipped, QA still runs) prevents accidental bypass.

**Story 5 (Sprint Contract Integration)** — Appropriately should-have. Contract-wins-over-spec conflict resolution is correct (contract is the negotiated DoD). The fallback for unsigned/draft contracts is graceful. AC5 (no contract = proceed silently) prevents false blockers on projects without P2-11.

**Story 6 (Persona Definition)** — Appropriately could-have. Verified that `plugins/conclave/shared/personas/` exists and contains 44 persona files — the convention is established. The graceful degradation (AC5: inline prompt if no persona file) is correct. The role separation reinforcement in AC3 (persona explicitly lists what QA ignores: code style, architecture) is a nice defense-in-depth.

### Cross-Cutting Observations

- **Roadmap coverage**: All 5 success criteria are covered. Stories 1+4 = spawn definitions. Stories 2+3 = writes and executes tests. Stories 1+6 = distinct role. Story 3 = evaluates execution not diffs. Multiple stories reference validator compliance.
- **Role separation table**: The roadmap's 4-column role separation table is faithfully encoded across Stories 1, 2, 3, and 6.
- **Design decisions**: QA non-removable in --light mode, opus model, APPROVED/REJECTED/BLOCKED verdict, post-skeptic/pre-Lead ordering — all sound.

### Resolution

Round 1 blocking issue resolved. NFR write safety now consistent with Story 2's test file writing requirement.

---

## P2-07: Role-Based Principles Split — Spec

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/progress/principles-split-architect.md`
**Stories**: `docs/progress/principles-split-story-writer.md`
**Roadmap**: `docs/roadmap/P2-07-universal-principles.md`

### Verdict: APPROVED

Comprehensive, implementable spec. Every story AC maps to a concrete code change. No contradictions, no missing coverage, no hand-waving.

### Section-by-Section Assessment

**1. Principles File Split** — The two-sub-block structure is clean. Principle-to-block mapping table is explicit and matches the roadmap (items 1–3, 9–12 = universal; items 4–8 = engineering). Section headings are correctly redistributed: ESSENTIAL appears in both blocks (item 8 in engineering, items 9–10 in universal) which preserves the original heading semantics. Original item numbering preserved (universal shows 1,2,3,9,10,11,12 — skips 4–8) enabling cross-reference. File header note documents the wrapper retirement clearly.

**2. Skill Classification** — Matches Story 4 AC4 exactly: 7 engineering, 7 non-engineering, 2 single-agent. Rationale for edge cases (write-stories, run-task, pipeline skills, future defaults) is documented inline. No surprises.

**3. Sync Script Changes** — Well-specified. `extract_block` for dual reads, `is_engineering_skill` / `is_known_skill` helpers, transition guard (old marker → WARN + skip), unknown skill WARN. The injection logic correctly handles the engineering check: `is_engineering_skill || !is_known_skill` covers both classified engineering and unknown-defaults-to-engineering. Communication protocol logic explicitly untouched.

**4. B-Series Validator Changes** — B1 covers all 5 failure modes (missing universal, drifted universal, engineering-in-non-engineering, missing-engineering-in-engineering, old marker). B3's old-marker regex `BEGIN SHARED: principles -->$` is correct — verified it matches only `<!-- BEGIN SHARED: principles -->` and not the new `universal-principles` or `engineering-principles` markers (the "BEGIN SHARED: " is not immediately followed by "principles" in new markers). B2 correctly untouched.

**5. SKILL.md Migration** — All 14 multi-agent skills listed with correct treatment: 7 get universal-only placeholder, 7 get both placeholders. Authoritative source comment included in placeholders. Migration runs before sync — correct ordering.

**6. CLAUDE.md Update** — Canonical table with rationale for write-stories and run-task. Guidance for new skill authors. Matches Story 4 requirements.

### Implementation Order Verification

Steps 1–4 (structure changes) → Step 5 (sync populates content) → Step 6 (validate) → Step 7 (docs). Dependencies are correct: sync requires both the source file split AND the target marker migration AND the updated sync script. The validator update must precede validation but can be concurrent with sync script changes.

### Constraints

All 10 constraints are sound. Particularly: #1 (no content changes), #2 (no reordering), #6 (classification lists duplicated by convention, not sourced — matches project pattern of standalone shell scripts), #7 (idempotency), #8 (12/12 validators).

### What I Checked

1. Every story AC has a corresponding spec section with implementation detail
2. Skill classification matches stories AND roadmap
3. B3 regex correctness (old marker detection without false positives on new markers)
4. Section heading redistribution preserves semantic meaning
5. Implementation order respects dependencies
6. Files-to-modify list is complete (16 files + CLAUDE.md = 17 total)
7. No content changes to principles wording (structure only)

---

## P2-10: Skill Discoverability Improvements — Spec

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/specs/skill-discoverability/spec.md`
**Stories**: `docs/progress/skill-discoverability-story-writer.md`
**Roadmap**: `docs/roadmap/P2-10-skill-discoverability.md`

### Verdict: APPROVED

Clean, actionable spec with before/after diffs for every change. All story ACs mapped. Personas verified against real files.

### Change-by-Change Assessment

**Change 1 (Business Skills Section + Tier Cleanup)** — Covers Story 1 ACs 1–5. The four-category restructure (Granular, Pipeline, Business, Utility) replaces stale Tier 1/Tier 2 labels (confirmed stale on wizard-guide lines 30, 41, 55). Business workflow examples added to Common Workflows. All 3 business skills listed with accurate descriptions.

**Change 2 (Determine Mode Fixes)** — Correctly updates mode behaviors: "two tiers" → "grouped by category", adds business skills to recommend mode, adds suppression rule for preamble/spotlight in list and explain modes. This is the mechanism that enforces Story 3 AC4 and Story 4 AC4.

**Change 3 (Lore Preamble)** — 107 words, within 80–150 target. Tone is evocative but not cryptic — "Invoke a skill. The Council assembles." anchors the fantasy framing to what the tool does. Suppressed in list/explain modes per Story 3 edge cases.

**Change 4 (Persona Spotlight)** — 5 personas, all verified against actual files:
- Eldara Voss → `shared/personas/research-director.md` (confirmed)
- Seren Mapwright → `plan-implementation/SKILL.md:258` (confirmed)
- Vance Hammerfall → `shared/personas/tech-lead.md` (confirmed)
- Mira Flintridge → `build-implementation/SKILL.md:461` + `build-product/SKILL.md:656` (confirmed)
- Bram Copperfield → `build-implementation/SKILL.md:364` + `build-product/SKILL.md:559` (confirmed)

Archetypes cover all three pipeline phases (research → plan → build). Skeptic (Mira) prominently included per Constraint #6. Footer line directing users to `/wizard-guide explain <skill-name>` is a nice touch.

**Change 5 (setup-project Next Steps)** — Single-line insertion before `/plan-product`. Renumbers existing items. Applies to all modes (normal, --force, --dry-run) — no logic change needed.

### Story 5 (Pushy Descriptions) Deferral

Correctly deferred. The stories' Out of Scope section says "Updating any file other than wizard-guide and setup-project SKILL.md files" — and Story 5 requires editing business skill SKILL.md frontmatter. Clean scope boundary.

### What I Checked

1. All 5 persona names verified against actual SKILL.md and persona files — none invented
2. Tier labels confirmed stale in current wizard-guide
3. Before/after diffs are concrete and implementable
4. Story 5 deferral justified by stories' own Out of Scope section
5. Determine Mode updates enforce preamble/spotlight suppression in correct modes
6. Files to Modify limited to wizard-guide and setup-project only
7. Success criteria are measurable (word counts, persona counts, mode behaviors)

---

## P2-12: QA Agent for Live Testing — Spec

**Reviewer**: Wren Cinderglass, Siege Inspector
**Artifact**: `docs/progress/qa-agent-architect.md`
**Stories**: `docs/progress/qa-agent-story-writer.md`
**Roadmap**: `docs/roadmap/P2-12-qa-agent-live-testing.md`

### Verdict: APPROVED

Thorough spec. The spawn prompt is exceptionally detailed — a QA agent could run from this prompt alone. Every story AC is addressed. One non-blocking observation.

### Section-by-Section Assessment

**1. QA Agent Spawn Definition** — Name `qa-agent`, Model `opus`. Role separation enforcement is explicit: 4 prohibited behaviors and 6 permitted behaviors. Opus justified as evaluation role matching Sonnet/Opus principle (#12) and existing Skeptic treatment. Matches Story 1 ACs 1–3.

**2. QA Agent Spawn Prompt** — This is the spec's strongest section. The prompt is production-ready:
- Test design process with fallback hierarchy (contract → stories → spec → BLOCKED)
- Sprint contract traceability matrix format
- Playwright-specific execution steps (dependency detection, app startup, health check, test run)
- Flaky test retry (up to 2 re-runs)
- Structured verdict format with concrete failure details
- Re-run behavior (only failing tests unless scope expanded)
- Write safety embedded in the prompt itself
- Covers Story 2 (all ACs), Story 3 (all ACs), Story 5 (ACs 1–5), and Story 6 edge case (role separation in prompt)

**3. Orchestration Flow — build-implementation** — QA gate inserted as new step 6, between quality-skeptic review (step 5) and progress writing (step 7). Step numbering shifts correctly. Deadlock protocol (max 3 rejections → escalate) matches existing Skeptic pattern. Matches Story 1 AC4.

**4. Orchestration Flow — build-product** — QA gate inserted as Stage 2 step 7. Artifact detection table extended with QA row: APPROVED/REJECTED/NOT_FOUND handling for resumption. Checkpoint detection logic is clear. Matches Story 4 ACs 1–3.

**5. QA Verdict Format** — APPROVED/REJECTED/BLOCKED tri-state. BLOCKED vs REJECTED distinction well-defined (infrastructure failure vs behavioral failure). No conditional approvals. Matches Story 3 ACs 4–5.

**6. Sprint Contract Integration** — Same injection pattern as Quality Skeptic. Fallback hierarchy documented with 5 levels (signed contract → draft warning → stories → spec → BLOCKED). Contract-spec conflict resolution: contract wins (negotiated DoD). Matches Story 5 ACs 1–5.

**7. Persona File** — Maren Greystone, Inspector of Carried Paths. Core values match Story 6 AC2. Ignored concerns match Story 6 AC3. Cross-references listed. Graceful degradation if file absent (Story 6 AC5). Persona convention matches existing `plugins/conclave/shared/personas/` directory (44 files confirmed earlier).

**8. Checkpoint Phase Extension** — `qa-testing` added as distinct phase value. Checkpoint states after 4 milestones. Phase distinguished from `testing` (engineers) and `review` (Skeptic). Matches Story 4 AC note about phase extension.

**9. Lightweight Mode** — QA preserved at Opus. Consistent with existing Skeptic/plan-skeptic treatment. Matches Stories 1 and 4 edge cases.

**10. Contract Injection** — Injection into QA agent mirrors Quality Skeptic injection. Prompt assembly order: guidance → contract → role prompt. Conditional injection text updated to reference both quality-skeptic and qa-agent.

### Non-Blocking Observation

The summary says "Five files modified, one file created" but the Files to Modify table shows 2 files modified + 1 file created + 2 files explicitly "No change expected." The summary count is inaccurate (should be "Two files modified, one file created"). The table is correct and is the implementation reference — no implementer would misread this. Not blocking.

### What I Checked

1. Every story AC mapped to a specific spec section
2. Spawn prompt covers all 6 stories' behavioral requirements in a single coherent document
3. Orchestration flow insertion points correct (after Skeptic, before progress writing)
4. Write safety in prompt matches corrected NFR from story review (progress file + test directory)
5. Deadlock protocol (3 rejection cycles) matches existing Skeptic pattern
6. Constraint #10 consistent with corrected story NFR
7. Artifact detection table handles all 3 resumption states (approved/rejected/not found)
8. Lightweight mode treatment consistent with existing evaluation role precedent
9. No new validators needed — existing A3 covers Name + Model fields
10. Persona file follows established convention (44 existing files in shared/personas/)
