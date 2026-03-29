---
feature: "batch-build"
status: "complete"
completed: "2026-03-27"
---

# Quality Skeptic Reviews — Batch Build

## P2-10: Skill Discoverability — APPROVED

**Files reviewed:**

- `plugins/conclave/skills/wizard-guide/SKILL.md`
- `plugins/conclave/skills/setup-project/SKILL.md`

**Success Criteria Checklist:**

1. **Conclave preamble present (80-150 words)** — PASS. `## The Conclave` section at lines 40-51, 109 words (within
   range).
2. **Meet the Council with 5 personas** — PASS. `## Meet the Council` at lines 53-65 with exactly 5 personas (Eldara
   Voss, Seren Mapwright, Vance Hammerfall, Mira Flintridge, Bram Copperfield), each with name, title, and one-line
   description.
3. **Business Skills section, no tier labels** — PASS. Business Skills section at lines 90-94 lists all three skills
   (draft-investor-update, plan-sales, plan-hiring). No "Tier 1" or "Tier 2" labels anywhere in the Skill Ecosystem
   Overview.
4. **List mode: reference table, no preamble** — PASS. Determine Mode "list" bullet explicitly states "No narrative, no
   lore preamble, no persona spotlight" and "Include all 16 skills".
5. **Explain mode: no preamble/spotlight** — PASS. Preamble and spotlight are rendered in overview mode only per
   Determine Mode "Empty/no args" rule: "Omit preamble and spotlight in list mode and explain mode."
6. **Business workflow in Common Workflows** — PASS. "Business operations" block at lines 127-132 with all three
   business skills.
7. **wizard-guide in setup-project Next Steps as item 2** — PASS. Line 234:
   `2. Run /wizard-guide to explore all available skills and find the right one for your task` — before `/plan-product`
   (item 3). Single Next Steps block serves all modes (normal, --force, --dry-run).
8. **All validators pass** — PASS. Zero conclave-specific validator failures. All 211 failures are from
   `plugins/php-tomes/` (pre-existing, unrelated).

**Minor note:** Line 18 references "tier" in the Setup section's frontmatter field list
(`name, description, argument-hint, tier, type, chains`). This is in Setup instructions (telling the agent what metadata
to read), not in the Skill Ecosystem Overview, so it does not violate constraint 7. No action needed.

**Verdict: APPROVED** — All 8 success criteria met. No regressions.

## P2-07: Role-Based Principles Split — APPROVED

**Files reviewed:**

- `plugins/conclave/shared/principles.md`
- `scripts/sync-shared-content.sh`
- `scripts/validators/skill-shared-content.sh`
- `scripts/validators/skill-structure.sh` (A4 update)
- `CLAUDE.md` (Skill Classification section)
- All 14 multi-agent SKILL.md files (marker spot-checks on all 14)

**Success Criteria Checklist:**

1. **principles.md has two named sub-blocks** — PASS. `universal-principles` (items 1-3, 9-12) and
   `engineering-principles` (items 4-8). Old outer `principles` wrapper absent. File header note present.
2. **Non-engineering skills (7) have only universal-principles** — PASS. All 7 verified: research-market,
   ideate-product, manage-roadmap, write-stories, plan-sales, plan-hiring, draft-investor-update. None contain
   `engineering-principles` markers.
3. **Engineering skills (7) have both blocks, universal first** — PASS. All 7 verified: write-spec, plan-implementation,
   build-implementation, review-quality, run-task, plan-product, build-product. Each has `universal-principles` followed
   by `engineering-principles`.
4. **Single-agent skills (2) unchanged** — PASS. setup-project and wizard-guide have no principles markers (as
   expected).
5. **Sync is idempotent** — PASS. Two consecutive `sync-shared-content.sh` runs produce identical files (verified via
   md5 comparison).
6. **All validators pass** — PASS. Zero conclave-specific failures in B1, B2, or B3. A4 updated to check
   `universal-principles` instead of old `principles`. All php-tomes failures are pre-existing.
7. **B1 flags engineering block in non-engineering skill** — PASS. B1 code at lines 217-224 explicitly checks
   `has_engineering_block = true` for non-engineering skills and fails.
8. **B1 flags missing engineering block in engineering skill** — PASS. B1 code at lines 201-216 checks both
   classification and block presence.
9. **B3 flags old `principles` marker** — PASS. B3 code at lines 297-304 uses `"BEGIN SHARED: principles -->$"`
   (end-anchored) to catch the retired marker without matching `universal-principles` or `engineering-principles`.
10. **CLAUDE.md contains classification table** — PASS. Section at lines 96-111 with canonical table, `write-stories`
    rationale (non-engineering), `run-task` rationale (engineering), and guidance for unknown skills.

**Additional verification:**

- Classification arrays in sync script and validator are identical (7 engineering, 7 non-engineering).
- `is_engineering_skill()` and `is_known_skill()` helpers present in both scripts.
- Unknown skill defaults to engineering with WARN (sync line 248-250, validator line 201).
- Transition guard in sync script catches old markers and skips (lines 252-257).
- Principle wording unchanged — only structural split, no content edits.
- B2 (communication-protocol) untouched.

**Verdict: APPROVED** — All 10 success criteria met. Sync is idempotent, validators enforce classification, no
regressions.

## P2-12: QA Agent for Live Testing — APPROVED

**Files reviewed:**

- `plugins/conclave/shared/personas/qa-agent.md` (CREATED)
- `plugins/conclave/skills/build-implementation/SKILL.md`
- `plugins/conclave/skills/build-product/SKILL.md`

**Success Criteria Checklist:**

1. **build-implementation qa-agent spawn def (A3 compliant)** — PASS. Lines 165-169: Name `qa-agent`, Model `opus`. A3
   validator passes (28 files checked).
2. **build-product qa-agent spawn def (A3 compliant)** — PASS. Lines 200-202: Name `qa-agent`, Model `opus`. A3
   validator passes.
3. **Spawn prompt: Playwright tests against running app, not code review** — PASS. Both skills: "writing and executing
   Playwright e2e tests against the RUNNING application. You test user-facing behavior, not code quality."
4. **Spawn prompt: prohibits reading source code, reviewing diffs, commenting on style** — PASS. Both prompts contain
   explicit "YOU DO NOT" block: no source code reading, no diffs, no code style comments, no conditional approvals.
5. **build-implementation QA gate after step 5, before progress writing** — PASS. Orchestration Flow: step 5 = Quality
   Skeptic POST-IMPLEMENTATION, step 6 = QA Agent verifies (QA GATE), step 7 = agents write progress.
6. **build-product Stage 2 QA gate after step 6, before progress writing** — PASS. Stage 2: step 6 = Quality Skeptic
   POST-IMPLEMENTATION, step 7 = QA Agent verifies (QA GATE), step 8 = agents write progress.
7. **Verdict format: APPROVED/REJECTED/BLOCKED with structured reporting** — PASS. Full verdict format in both spawn
   prompts with test results table, failure assertions+suggestions, INCONCLUSIVE handling, and BLOCKED resolution
   details. No conditional approvals.
8. **Sprint contract injection matches Quality Skeptic pattern** — PASS. build-implementation Step 5: "inject it into
   the Quality Skeptic's AND QA Agent's prompts." build-product Step 2b: same. Assembly order (guidance → contract →
   role prompt) documented in both skills.
9. **Persona file exists with character, values, role separation** — PASS.
   `plugins/conclave/shared/personas/qa-agent.md`: Maren Greystone, Inspector of Carried Paths. Core values (user
   experience fidelity, behavioral correctness, non-negotiability). Explicit role separation table (Quality Skeptic vs
   QA Agent). Cross-references to sprint-contract, stories, spec, stack-hints.
10. **Checkpoint phase: qa-testing** — PASS. build-implementation line 92 and build-product line 66 both include
    `qa-testing` in the phase enum comment, distinct from `testing` and `review`.
11. **--light mode preserves QA at Opus** — PASS. build-implementation line 129: "QA Agent: unchanged (ALWAYS Opus) — QA
    gate is non-negotiable". build-product line 155: "qa-agent: unchanged (ALWAYS Opus) — QA gate is non-negotiable".
12. **Fallback hierarchy in spawn prompt** — PASS. Both prompts: priority order (a) sprint contract, (b) user stories,
    (c) technical spec. If none available → BLOCKED with "no test source material".
13. **All 12/12 validators pass** — PASS. A3 passes with new spawn definitions. Zero conclave-specific failures across
    all validators.
14. **Shared content files unmodified by P2-12** — PASS. `communication-protocol.md` has no diff. `principles.md` diff
    is from P2-07 only. Persona file is new (not shared content).

**Additional verification:**

- QA deadlock protocol in both skills: 3 rejection cycles, then escalate to human operator (matching Skeptic deadlock
  pattern).
- build-product artifact detection table includes QA row: `agent: "qa-agent"`, `phase: "qa-testing"` with
  APPROVED/REJECTED/NOT_FOUND outcomes.
- build-product QA gate checks artifact detection for resume: existing APPROVED checkpoint → skip QA.
- Write safety enforced in both prompts: test directory + `docs/progress/{feature}-qa-agent.md` only.
- Persona file frontmatter follows existing convention (name, id, model, archetype, skill, team, fictional_name, title).

**Verdict: APPROVED** — All 14 success criteria met. QA gate correctly positioned, role separation enforced, no
regressions.
