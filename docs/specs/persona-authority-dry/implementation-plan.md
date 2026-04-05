---
type: "implementation-plan"
feature: "persona-authority-dry"
status: "approved"
source_spec: "docs/specs/persona-authority-dry/spec.md"
approved_by: "plan-skeptic (Voss Grimthorn), implementation-coordinator (Lead-as-Skeptic)"
sprint-contract: "docs/specs/persona-authority-dry/sprint-contract.md"
created: "2026-04-04"
updated: "2026-04-04"
---

# Implementation Plan: Persona File Authority — DRY Spawn Prompts (P3-32)

## Overview

Refactor 22 multi-agent SKILL.md files to use thin spawn prompts (~15 lines each) that reference authoritative persona
files instead of duplicating agent-intrinsic content inline. This involves: (1) a new P-series bash validator for
persona file reference integrity and schema completeness, (2) persona file schema expansion where needed, (3) audit-slop
PoC migration, (4) 4+ additional skill migrations, (5) CLAUDE.md documentation updates, (6) Forge/Scribe template
updates, and (7) migration metrics tracking.

## File Changes

| #   | Action | File Path                                                  | Description                                                                                                                                                                                                                                                                                                                                                                         | Traces to                     |
| --- | ------ | ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| 1   | create | `scripts/validators/persona-references.sh`                 | New P-series validator: P1 (persona file reference integrity) and P2 (persona file schema completeness by archetype)                                                                                                                                                                                                                                                                | Story 4, Spec §4              |
| 2   | modify | `scripts/validate.sh`                                      | Add `run_validator "persona-references.sh"` line after existing validators                                                                                                                                                                                                                                                                                                          | Story 4, Spec §4              |
| 3   | modify | `plugins/conclave/shared/personas/doubt-augur.md`          | Add `<!-- non-overridable -->` comment after `## Critical Rules` heading. Content diff: compare spawn prompt content against persona file, migrate any spawn-prompt-only content to persona file.                                                                                                                                                                                   | Story 1 AC5, Spec §1          |
| 4   | modify | `plugins/conclave/shared/personas/pattern-augur.md`        | Same as #3: `<!-- non-overridable -->` + content diff + migrate spawn-prompt-only content.                                                                                                                                                                                                                                                                                          | Story 1 AC5, Spec §1          |
| 5   | modify | `plugins/conclave/shared/personas/breach-augur.md`         | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 6   | modify | `plugins/conclave/shared/personas/provenance-augur.md`     | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 7   | modify | `plugins/conclave/shared/personas/flow-augur.md`           | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 8   | modify | `plugins/conclave/shared/personas/waste-augur.md`          | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 9   | modify | `plugins/conclave/shared/personas/speed-augur.md`          | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 10  | modify | `plugins/conclave/shared/personas/proof-augur.md`          | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 11  | modify | `plugins/conclave/shared/personas/charter-augur.md`        | Same as #3.                                                                                                                                                                                                                                                                                                                                                                         | Story 1 AC5, Spec §1          |
| 12  | modify | `plugins/conclave/shared/personas/chief-augur.md`          | Same as #3. Chief Augur is archetype `lead` — Responsibilities and Output Format are optional per spec.                                                                                                                                                                                                                                                                             | Story 1 AC5, Spec §1          |
| 13  | modify | `plugins/conclave/skills/audit-slop/SKILL.md`              | PoC: Replace all 9 verbose spawn prompts (Doubt Augur through Charter Augur) with thin format (~15 lines each). Current spawn section: 976 lines → target: ~135 lines. Total file: 1,639 → target: ≤984 lines. Prerequisite: #3-12 content diffs completed so no content is lost.                                                                                                   | Story 2, Story 5, Spec §2, §5 |
| 14  | modify | `plugins/conclave/skills/review-pr/SKILL.md`               | Migration #2: Replace all 9 spawned-teammate verbose spawn prompts with thin format (lead excluded — executes SKILL.md directly). Current spawn section: 944 lines. Total file: 1,592 lines. Content diff required per agent before thinning.                                                                                                                                       | Story 6, Spec §5              |
| 15  | modify | `plugins/conclave/skills/harden-security/SKILL.md`         | Migration #3: Thin all spawn prompts.                                                                                                                                                                                                                                                                                                                                               | Story 6, Spec §5              |
| 16  | modify | `plugins/conclave/skills/squash-bugs/SKILL.md`             | Migration #4: Thin all spawn prompts.                                                                                                                                                                                                                                                                                                                                               | Story 6, Spec §5              |
| 17  | modify | `plugins/conclave/skills/refine-code/SKILL.md`             | Migration #5: Thin all spawn prompts.                                                                                                                                                                                                                                                                                                                                               | Story 6, Spec §5              |
| 18  | modify | `plugins/conclave/skills/create-conclave-team/SKILL.md`    | Update Scribe's SPAWN PROMPT TEMPLATE (lines ~918-945) to thin format. Add PERSONA FILE GENERATION instruction block.                                                                                                                                                                                                                                                               | Story 7, Spec §6              |
| 19  | modify | `CLAUDE.md`                                                | Add `### Override Convention` subsection under `## Skill Architecture`. Add `### Persona File Schema` reference.                                                                                                                                                                                                                                                                    | Story 3, Spec §3              |
| 20  | create | `docs/progress/persona-authority-dry-migration-metrics.md` | Migration metrics tracking file with before/after line counts per skill. This single file serves both Story 5 AC6 (PoC results) and Story 6 (full rollout tracking). Story 5 AC6 references a `poc-results.md` name — we use `migration-metrics.md` instead to avoid creating a separate PoC-only file that duplicates the same table. The PoC row is the first entry in this file. | Story 5 AC6, Story 6, Spec §5 |

## Interface Definitions

### P1 Validator: Persona File Reference Integrity

```bash
# Input: REPO_ROOT (positional arg $1)
# Scans: All SKILL.md files under plugins/conclave/skills/*/
# For each spawn prompt code block in ## Teammate Spawn Prompts:
#   Extracts: First line matching pattern "First, read {path} for your complete role definition"
#   Validates: File exists at REPO_ROOT/{extracted_path}
# Output format:
#   [PASS] P1/persona-reference: All spawn prompt persona file references resolve ({N} references in {M} skills)
#   [FAIL] P1/persona-reference: spawn prompt references missing persona file: {path}
#     File: {skill_path}
#     Expected: File exists at {REPO_ROOT}/{persona_path}
#     Found: File not found
#     Fix: Create the persona file or correct the path in the spawn prompt
# Exit: 0 if all pass, 1 if any fail
# Note: Only checks spawn prompts that contain the "First, read" directive.
#       Pre-migration prompts without this directive are silently skipped (backward compat).
```

### P2 Validator: Persona File Schema Completeness

```bash
# Input: REPO_ROOT (positional arg $1)
# Scans: All .md files in plugins/conclave/shared/personas/
# For each persona file:
#   Extracts YAML frontmatter fields: name, id, model, archetype
#   Validates required frontmatter: name, id, model, archetype must all be present
#   Based on archetype value, checks for required sections (## headings):
#
#   Archetype-section requirement matrix:
#     | Section                          | assessor | skeptic  | domain-expert | team-lead | lead     | evaluator |
#     |----------------------------------|----------|----------|---------------|-----------|----------|-----------|
#     | ## Identity                      | required | required | required      | required  | required | required  |
#     | ## Role                          | required | required | required      | required  | required | required  |
#     | ## Critical Rules                | required | required | required      | required  | required | required  |
#     | ## Responsibilities or Methodology | required | required | required    | required  | optional | required  |
#     | ## Output Format                 | required | required | required      | required  | optional | required  |
#     | ## Write Safety                  | required | required | required      | required  | required | required  |
#     | ## Cross-References              | required | required | required      | required  | required | required  |
#
#   Notes on archetypes:
#     - `team-lead` (12 files): Leads who execute SKILL.md directly. All sections required because
#       these files also contain methodology/output format used when the lead is spawned on a
#       pipeline team. Distinct from `lead` (1 file: chief-augur) which has optional Responsibilities/Output.
#     - `evaluator` (1 file: qa-agent): Specialist who evaluates built artifacts. All sections required.
#     - `lead` (1 file: chief-augur): Executes SKILL.md directly; orchestration logic lives in SKILL.md,
#       so Responsibilities and Output Format are optional in the persona file.
#     - `coordinator` archetype: Not present in any repo files. If encountered, treated as alias
#       for `team-lead` (same requirement matrix).
#     - Responsibilities heading check: P2 accepts EITHER `## Responsibilities` OR `## Methodology`
#       (or both). 40 persona files use `## Methodology`, 56 use `## Responsibilities`, many have both.
#       The validator passes if at least one of these headings is present when the section is required.
#
# Output format:
#   [PASS] P2/persona-schema: All persona files have required sections for their archetype ({N} files checked)
#   [FAIL] P2/persona-schema: {file} missing required frontmatter field "{field}"
#   [FAIL] P2/persona-schema: {file} missing required section "## {section}" for archetype "{archetype}"
#   [WARN] P2/persona-schema: {file} missing optional section "## {section}" for archetype "{archetype}"
# Exit: 0 if no FAILs (WARNs are non-blocking), 1 if any FAIL
```

### Thin Spawn Prompt Template Contract

```
# Every thin spawn prompt follows this structure (all fields required unless marked optional):
# Line 1: First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.
# Line 2: (blank)
# Line 3: You are {Fantasy Name}, {Title} — the {Role} on the {Team Name}.
# Line 4: When communicating with the user, introduce yourself by your name and title.
# Line 5: (blank)
# Lines 6+: Invocation-specific context sections in this order:
#   TEAMMATES: {roster with run-ID suffixes}
#   SCOPE: {what this invocation is about}
#   PHASE ASSIGNMENT: {which phases this agent handles}
#   FILES TO READ: {invocation-specific paths}
#   COMMUNICATION: {routing directives}
#   WRITE SAFETY: {scope-specific paths + checkpoint triggers}
#   SKILL-SPECIFIC OVERRIDES: (optional — omit entirely if no overrides)
# Target: ≤20 lines (not counting SKILL-SPECIFIC OVERRIDES section)
```

### Migration Metrics File Schema

```markdown
---
feature: "persona-authority-dry"
type: "migration-metrics"
updated: "YYYY-MM-DD"
---

# Persona Authority DRY — Migration Metrics

| Skill      | Pre-Migration Lines | Post-Migration Lines | Reduction | Reduction %        | Agents Migrated                           | Date |
| ---------- | ------------------- | -------------------- | --------- | ------------------ | ----------------------------------------- | ---- |
| audit-slop | 1639                | TBD                  | TBD       | TBD                | 9                                         | TBD  |
| review-pr  | 1592                | TBD                  | TBD       | TBD                | 9 (spawned teammates only; lead excluded) | TBD  |
| ...        |                     |                      |           |                    |                                           |      |
| **Total**  |                     |                      |           | **target: 40-60%** |                                           |      |
```

### CLAUDE.md Override Convention Section

```markdown
### Override Convention

Spawn prompts may include a `SKILL-SPECIFIC OVERRIDES:` section that supersedes persona file content.

- **Overridable**: Responsibilities, Output Format, Write Safety, Files to Read
- **Non-overridable**: Critical Rules (marked `<!-- non-overridable -->` in persona files)
- **Override types**: `ADD:` (additive — new content) or `REPLACE:` (replaces a named section)
- **No section = full persona**: Absence of overrides means the persona file applies completely
- **Enforcement**: Code review only (no validator). The `SKILL-SPECIFIC OVERRIDES:` header is consistent for future
  automated detection.
```

## Dependency Order

1. **`scripts/validators/persona-references.sh`** — no dependencies. Must exist before any migration step so validators
   can be run after each change.
2. **`scripts/validate.sh`** — depends on #1. Register the new validator.
3. **Persona file work** (files #3-12) — Content diff each spawn prompt against its persona file, migrate any
   spawn-prompt-only content to the persona file, and add `<!-- non-overridable -->` to Critical Rules. No dependencies
   on #1-2, but must complete before spawn prompt thinning (#5). Can be done in parallel with #1-2.
4. **`docs/progress/persona-authority-dry-migration-metrics.md`** — no dependencies. Create early to record
   pre-migration baselines.
5. **`plugins/conclave/skills/audit-slop/SKILL.md` PoC migration** (#13) — depends on #1-2 (validator must exist to
   validate), #3-12 (persona files annotated), #4 (metrics file ready for recording). This is the critical path — all
   subsequent migrations depend on PoC success.
6. **Validate audit-slop**: Run `bash scripts/validate.sh` after #5. All checks must pass. This gates all further work.
7. **`CLAUDE.md` override convention documentation** (#19) — depends on PoC success (#5-6) to confirm the convention
   works in practice. **Must complete before migrations #14-17 begin**, so engineers have the override convention
   reference available during migration work.
8. **Additional SKILL.md migrations** (#14-17: review-pr, harden-security, squash-bugs, refine-code) — depends on #5-6
   (PoC proven) AND #19 (convention documented). Each migration is independent of the others and can be done in
   parallel; each must pass `bash scripts/validate.sh` independently. Each requires content diff per agent before
   thinning (Story 1 AC5) and may require persona file expansion if spawn-prompt-only content is found.
9. **`create-conclave-team/SKILL.md` Scribe update** (#18) — depends on #19 (override convention documented) and #14-17
   (at least one non-PoC migration proven). Lower priority — Forge only needs updating after migration pattern is
   validated across multiple skills.

### Dependency Graph (DAG)

```
#1 persona-references.sh ──→ #2 validate.sh registration ──┐
                                                            ├──→ #5 audit-slop PoC ──→ #6 validate
#3-12 persona annotations (content diff + non-overridable) ─┘                              │
                                                                                            ↓
#4 metrics file ──→ #5 (record baselines)                                       #19 CLAUDE.md (override docs)
                                                                                            │
                                                                                            ↓
                                                                        #14 review-pr ─────→ validate
                                                                        #15 harden-security → validate
                                                                        #16 squash-bugs ────→ validate
                                                                        #17 refine-code ────→ validate
                                                                                            │
                                                                                            ↓
                                                                        #18 Scribe update ──→ validate
```

### Parallel Execution Groups

- **Group A** (can run in parallel): #1, #3-12, #4
- **Group B** (sequential after A): #2 (depends on #1)
- **Group C** (sequential after A+B): #5 (audit-slop PoC), then #6 (validate)
- **Group C.5** (sequential after C): #19 (CLAUDE.md override convention docs)
- **Group D** (parallel after C.5): #14, #15, #16, #17
- **Group E** (after D): #18

## Test Strategy

| Test Type             | Scope                      | Description                                                                                                                                                                                                                              |
| --------------------- | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Validator unit        | `persona-references.sh` P1 | Run validator on current repo state (all spawn prompts already have persona file read directives). Expect: all P1 checks pass, no regressions.                                                                                           |
| Validator unit        | `persona-references.sh` P2 | Run validator on current persona files. Expect: all required sections present for each archetype. Identify any gaps before migration begins.                                                                                             |
| Validator negative    | `persona-references.sh` P1 | Temporarily edit one spawn prompt to reference a non-existent persona file. Run validator. Expect: FAIL with specific error message identifying the missing file. Revert edit.                                                           |
| Validator negative    | `persona-references.sh` P2 | Temporarily remove a required section from a persona file. Run validator. Expect: FAIL identifying the missing section and archetype. Revert edit.                                                                                       |
| Validator integration | `validate.sh`              | Run full validator suite after registering persona-references.sh. Expect: all existing checks still pass, new P-series checks appear in output.                                                                                          |
| Backward compat       | All validators             | After persona file annotations (#3-12) but before any spawn prompt thinning: run `bash scripts/validate.sh`. Expect: 0 failures. Confirms annotations don't break anything.                                                              |
| PoC migration         | `audit-slop/SKILL.md`      | After thinning all 9 spawn prompts: (a) run `bash scripts/validate.sh` — expect 0 failures; (b) measure total line count — expect ≤984; (c) measure spawn section lines — expect ~135 (9 agents × ~15 lines).                            |
| PoC behavioral        | `audit-slop`               | Invoke the skill on a test scope. Verify: each agent reads its persona file (check first action), produces output matching persona file Output Format, writes to correct write-safety paths, Doubt Augur gates at Phase 1.5 and Phase 3. |
| Incremental migration | Each migrated skill        | After each skill migration (#14-17): run `bash scripts/validate.sh`. Expect: 0 failures. Mixed state (some migrated, some not) must pass.                                                                                                |
| Metrics validation    | Migration metrics file     | After each migration: verify before/after line counts are recorded accurately. Final aggregate should approach 40-60% reduction across migrated skills.                                                                                  |
| Scribe update         | `create-conclave-team`     | After Scribe template update (#18): review the template to confirm it matches the thin spawn prompt format. Run `bash scripts/validate.sh`.                                                                                              |

### Pre-Migration Content Diff Procedure (per skill, per agent)

Before thinning any spawn prompt, perform this content diff:

1. Extract spawn prompt content (between ``` markers under the agent's ### heading)
2. Extract corresponding persona file content
3. Categorize each spawn prompt section:
   - Identity line ("You are...") → stays (invocation context)
   - YOUR ROLE paragraph → compare with persona `## Role`. If identical: remove. If different: migrate diff to persona.
   - CRITICAL RULES → compare with persona `## Critical Rules`. If identical: remove. If different: migrate additions.
   - METHODOLOGY sections → compare with persona `## Responsibilities`. If identical: remove. If different: migrate.
   - OUTPUT FORMAT → compare with persona `## Output Format`. If identical: remove. If different: migrate.
   - COMMUNICATION → stays (invocation-specific routing)
   - WRITE SAFETY → split: generic patterns → persona, scope-specific paths → spawn prompt
4. Any spawn-prompt-only content NOT in persona file: add to persona file BEFORE thinning.
5. Only thin the spawn prompt after all content is confirmed present in the persona file.

**For audit-slop specifically**: The 10 augur persona files already contain comprehensive methodology and output format
sections matching the spawn prompts. Content diff is expected to show near-100% duplication, requiring minimal persona
file expansion beyond adding `<!-- non-overridable -->` to Critical Rules.

## Migration Rollout Order

Priority is by spawn-prompt line count (highest reduction first):

1. **audit-slop** — PoC (976 spawn lines, 9 agents, all persona files exist)
2. **review-pr** — 944 spawn lines, 9+ agents
3. **harden-security** — high agent count
4. **squash-bugs** — high agent count
5. **refine-code** — moderate agent count
6. Remaining 17 multi-agent skills in descending spawn-prompt line count (future work beyond initial scope)

Each migration is one commit. Each commit must pass `bash scripts/validate.sh` independently.

## Rollback Strategy

Every migration step is reversible via `git revert` of the commit that thinned the spawn prompts. Persona file
expansions (the `<!-- non-overridable -->` annotations) are additive and harmless to revert. No special tooling needed.

## Notes for Engineers

- **Do NOT thin spawn prompts before confirming persona file content completeness.** The content diff (above) is
  mandatory — skipping it risks silently deleting agent behavior.
- **Lead agents (Chief Augur, Presiding Judge, etc.) do NOT get thin spawn prompts.** They execute the SKILL.md
  directly; their orchestration logic is in the SKILL.md, not a persona file.
- **Dynamic model selection** (e.g., `--light` mode downgrades in audit-slop) is invocation-specific and stays in the
  SKILL.md orchestration logic, not in persona files or spawn prompts.
- **Single-agent skills** (setup-project, wizard-guide) are excluded entirely — they have no spawn prompts.
- **The `<!-- non-overridable -->` comment is a human-readable signal**, not machine-enforced. Enforcement is by code
  review.
- **Heading normalization**: Existing persona files use `## Methodology` (40 files), `## Responsibilities` (56 files),
  or both. The P2 validator accepts EITHER heading when checking the Responsibilities/Methodology requirement. No rename
  of existing headings is needed — both are valid. The content diff procedure (above) maps spawn prompt `METHODOLOGY`
  sections to whichever heading the persona file uses.
- **Lead exclusion from thinning**: In every multi-agent skill, the lead agent (Chief Augur, Presiding Judge,
  Strategist, etc.) executes the SKILL.md directly and has NO separate spawn prompt. The "Agents Migrated" count in
  migration metrics counts only spawned teammates with `###` entries under `## Teammate Spawn Prompts`.
