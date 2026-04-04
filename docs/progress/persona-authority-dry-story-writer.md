---
feature: "persona-authority-dry-refactor"
team: "product-planning-team"
agent: "story-writer"
phase: "complete"
status: "complete"
last_action: "Checkpoint: stories approved by product-skeptic, work complete"
updated: "2026-04-04T19:45:00Z"
---

## Progress Notes

- [19:00] Task claimed — drafting P3-32 user stories
- [19:05] Context gathered: roadmap item, persona file format (ops-skeptic.md), spawn prompt format (audit-slop
  SKILL.md), artifact template
- [19:10] Drafting started — 7 stories across scope areas
- [19:20] Drafts complete — checkpointing, sending to team lead
- [19:30] REJECTED by product-skeptic — 4 issues: factual error in S1 Notes (audit-slop persona files already
  comprehensive), contradiction in S3 AC2 (override semantics), vague testability in S5 AC5, factual error in S5 edge
  case 3 (all augur persona files exist)
- [19:35] Revision started — fixing all 4 issues
- [19:40] Revisions complete — re-sending to team lead for routing back to product-skeptic
- [19:45] APPROVED by product-skeptic — all 4 issues resolved, stories ready for spec

---

# User Stories: Persona File Authority — DRY Spawn Prompts (P3-32)

---

type: "user-stories" feature: "persona-authority-dry-refactor" status: "draft" source_roadmap_item:
"docs/roadmap/P3-32-persona-authority-dry-refactor.md" approved_by: "" created: "2026-04-04" updated: "2026-04-04"

---

## Epic Summary

Move agent-intrinsic content (identity, methodologies, output formats, critical rules, write safety) from inline
SKILL.md spawn prompts into authoritative persona files at `plugins/conclave/shared/personas/`. Spawn prompts become
thin invocation-context injectors. Expected 40-60% total line reduction across 22 multi-agent skills.

## Stories

### Story 1: Expand Persona File Schema to Include All Agent-Intrinsic Content

- **As a** skill maintainer
- **I want** persona files to contain all agent-intrinsic content (identity, communication style, role, critical rules,
  responsibilities, methodology with procedure steps, output format templates, write safety, cross-references)
- **So that** I have one authoritative source to update when an agent's behavior changes, without touching every
  SKILL.md that spawns it
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given an existing persona file (e.g., `ops-skeptic.md`), when compared against the expanded required schema, then
     any currently missing sections are identified — the schema defines which sections are required vs optional
  2. Given a persona file following the expanded schema, when a skill maintainer reads it, then the file is sufficient
     to understand the agent's complete behavior without reading any SKILL.md
  3. Given a persona file that omits an optional section (e.g., Methodology for a dynamic lead agent), when a validator
     checks it, then it reports a warning, not an error — required vs optional sections are documented in CLAUDE.md
  4. Given any persona file in `plugins/conclave/shared/personas/`, when the validator runs, then all required sections
     are present (no missing Identity, Role, Critical Rules, or Output Format blocks)
  5. Given an existing persona file and its corresponding spawn prompts across all skills that use that agent, when
     compared line-by-line, then any content present in a spawn prompt but absent from the persona file is identified
     and migrated to the persona file before that spawn prompt is thinned
- **Edge Cases**:
  - Agent with phase-dependent output formats (e.g., Doubt Augur has 3 distinct output formats for Brief Gate,
    Adjudication, and Advisory): schema must support multiple named output format blocks without conflating them
  - Agent with no fixed methodology (e.g., a lead agent whose procedure is entirely in the SKILL.md orchestration):
    Methodology section is optional in schema, must not be required by validator for lead roles
  - Persona file for a single-agent skill (none exist currently, but possible): schema must remain coherent if there is
    no teammate roster or skeptic relationship
- **Notes**: For audit-slop augurs (doubt-augur, pattern-augur, breach-augur, etc.), persona files are already
  comprehensive — they contain methodology and output format blocks. The PoC work is removing duplication from spawn
  prompts, not expanding those persona files. For skills outside audit-slop, persona files may have gaps (e.g.,
  ops-skeptic.md has role and critical rules but no Methodology section) — Story 1's schema expansion work applies
  there. AC5 ensures no spawn-prompt-only content is lost during any thinning operation.

---

### Story 2: Define and Implement Thin Spawn Prompt Format

- **As a** skill maintainer
- **I want** spawn prompts to be thin invocation-context injectors containing only: persona file read instruction,
  teammate roster with run-ID suffixes, scope/topic, phase assignments, paths to read, and an optional SKILL-SPECIFIC
  OVERRIDES section
- **So that** a spawn prompt can be read and understood in under 20 lines, and updating an agent's universal behavior
  requires editing only the persona file
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given a migrated thin spawn prompt, when measured, then it is ≤20 lines (not counting the SKILL-SPECIFIC OVERRIDES
     section if present)
  2. Given a thin spawn prompt, when a skill user (agent) reads it, then the FIRST line is a directive to read the
     persona file (e.g., `First, read plugins/conclave/shared/personas/{id}.md for your complete role definition.`)
  3. Given a thin spawn prompt, when compared to its pre-migration counterpart, then all duplicated
     identity/methodology/output-format content has been removed from the spawn prompt and lives only in the persona
     file
  4. Given the audit-slop PoC after migration, when the total line count of SKILL.md is measured, then it is ≤60% of the
     pre-migration count (target: ~900 spawn-prompt lines → ~135 lines)
  5. Given a thin spawn prompt, when read without the persona file, then the invocation context (teammates, scope,
     phase) is still parseable — the prompt is not gibberish on its own
- **Edge Cases**:
  - Spawn prompt for the team lead (Chief Augur, Strategist, etc.): the lead executes the SKILL.md directly, has no
    separate spawn prompt. Thin format applies only to spawned teammate prompts, not to the lead's orchestration
    instructions.
  - Agent model override within a thin spawn prompt (e.g., `--light` mode changes breach-augur's model at runtime): the
    override mechanism must accommodate model changes without re-embedding the agent's full identity
  - Persona file referenced in spawn prompt does not exist on disk: skill must fail at spawn time with a clear error
    ("persona file not found: {path}"), not silently launch a context-blind agent
- **Notes**: The current audit-slop Doubt Augur spawn prompt is ~115 lines. Post-migration it should be ~15 lines plus
  any overrides. The persona file read directive is the critical first instruction — agents that skip file reads are
  already unreliable in the current architecture, so this is not a new risk.

---

### Story 3: Establish and Document the Override Convention

- **As a** skill maintainer
- **I want** a documented SKILL-SPECIFIC OVERRIDES convention that allows spawn prompts to supersede specific persona
  file content without forking the persona file
- **So that** I can customize an agent's behavior for a particular skill's mandate boundaries without creating divergent
  persona files for each usage
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given a spawn prompt with a `SKILL-SPECIFIC OVERRIDES:` section, when an agent reads both the persona file and the
     spawn prompt, then the override content takes explicit precedence over any conflicting content in the persona file
  2. Given the override convention documented in CLAUDE.md, when a maintainer reads it, then they can determine: what
     can be overridden (mandate boundaries, phase assignments, output format variants), what cannot (Critical Rules and
     any section explicitly marked non-overridable in the persona file), and how conflicts are resolved (spawn prompt
     wins for overridable content; non-overridable sections are exempt from override regardless of what the spawn prompt
     states)
  3. Given a spawn prompt with no SKILL-SPECIFIC OVERRIDES section, when an agent executes, then it follows the persona
     file entirely — the absence of overrides is not ambiguous
  4. Given a spawn prompt with an empty SKILL-SPECIFIC OVERRIDES section, when an agent reads it, then it interprets
     this as "no overrides" and applies the persona file in full — empty section must not be read as "suppress all
     persona content"
  5. Given two skills that both spawn the same agent type (e.g., a skeptic), when each has different SKILL-SPECIFIC
     OVERRIDES, then each override applies only within its own skill's spawn — no cross-contamination between skills
- **Edge Cases**:
  - Override that contradicts a Critical Rule in the persona file (e.g., "bypass skeptic gate for speed"): the
    convention must explicitly state whether Critical Rules can be overridden; the recommended answer is NO — if a
    Critical Rule needs changing, change the persona file, don't override it silently
  - Override that extends the output format (adds a section) vs replaces it (swaps the format): convention must
    distinguish additive from replacement overrides to prevent ambiguity
  - Skill maintainer adds an override for a field that doesn't exist in the persona file (e.g., a new field): override
    still applies (additive), persona file is not violated
- **Notes**: This is a human-readable convention enforced by code review, not by a validator. CLAUDE.md is the
  enforcement surface. The override section header must be consistent (`SKILL-SPECIFIC OVERRIDES:`) so a future
  validator could detect and reason about it. Critical Rules should be marked in persona files with a
  `<!-- non-overridable -->` comment or equivalent signal.

---

### Story 4: Update Validators to Follow Persona File References

- **As a** skill maintainer running `bash scripts/validate.sh`
- **I want** validators to follow persona file references in thin spawn prompts and verify that referenced persona files
  exist and contain required sections
- **So that** migrated skills pass validation and missing/broken persona file references are caught before commit
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given a thin spawn prompt that begins with `First, read plugins/conclave/shared/personas/{id}.md`, when the A3
     validator processes it, then it extracts the persona file path and confirms the file exists
  2. Given a spawn prompt that references a non-existent persona file, when validation runs, then it fails with a
     specific error: `[A3] FAIL: spawn prompt references missing persona file: plugins/conclave/shared/personas/{id}.md`
  3. Given a persona file that is missing a required section (e.g., no Output Format), when the B-series or a new
     P-series validator checks it, then it fails with the section name and file path in the error
  4. Given a spawn prompt with a `SKILL-SPECIFIC OVERRIDES:` section, when validation runs, then overrides do not
     trigger false-positive failures for "missing methodology" or "missing output format" in the spawn prompt itself —
     validators know to look at the persona file for those
  5. Given a pre-migration SKILL.md with full spawn prompts (no persona file references), when validation runs, then it
     still passes — backward compatibility is maintained during the incremental rollout
- **Edge Cases**:
  - Validator runs on a partially migrated skill where some agents have thin prompts and others have full prompts: mixed
    state must pass validation during the rollout window
  - Persona file path in spawn prompt uses wrong casing or path separator: validator should normalize paths before
    checking existence
  - New skill added with a thin spawn prompt but the persona file hasn't been created yet: validator must clearly
    identify this as a missing-persona error, not a spawn-prompt formatting error
- **Notes**: This may be a new validator rule (e.g., A3.1 or a new P-series) rather than a modification of existing A3.
  The existing A3 checks Name + Model fields in spawn entries. The new check is about persona file reference integrity.
  Consider whether to extend A3 or introduce P-series (Persona) validators. The B-series already validates drift in
  shared principles — P-series would validate persona file schema completeness.

---

### Story 5: Migrate audit-slop as Proof of Concept

- **As a** skill maintainer
- **I want** the audit-slop skill migrated to thin spawn prompts with all agent-intrinsic content moved to persona files
- **So that** the refactoring approach is validated end-to-end on a real skill before committing to the full rollout
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given the audit-slop SKILL.md after migration, when all 8 assessment augur spawn prompts are measured, then each is
     ≤20 lines
  2. Given the audit-slop SKILL.md after migration, when total line count is measured, then it is ≤60% of the
     pre-migration line count (pre-migration: ~1,640 lines; target: ≤984 lines)
  3. Given the migrated audit-slop skill, when `bash scripts/validate.sh` is run, then all validators pass with no new
     failures
  4. Given each migrated augur's persona file, when read in isolation, then it fully describes the agent's identity,
     methodology, and output format without requiring the SKILL.md for comprehension
  5. Given the audit-slop skill is invoked after migration, when a full audit is run on a test scope, then: (a) each
     agent produces output matching the structure defined in their persona file's Output Format section, (b) each agent
     writes exclusively to the write-safety paths defined in their persona file, (c) each agent applies all
     methodologies listed in their persona file's Responsibilities section (verifiable by inspecting output file
     headings and tables), and (d) the Doubt Augur gates at Phase 1.5 and Phase 3 as specified in its persona file —
     both gates fire and produce their defined output formats
  6. Given the migration is complete, when line count reduction is measured and documented, then the result is recorded
     in `docs/progress/persona-authority-dry-poc-results.md` with before/after metrics
- **Edge Cases**:
  - Doubt Augur has 3 distinct phases with different output formats and methodologies — moving these to the persona file
    may exceed a readable single file; consider whether multi-phase agents need subsectioned Output Format blocks
  - audit-slop uses dynamic model selection (breach-augur and flow-augur downgraded in --light mode): thin spawn prompt
    must still support runtime model override — this is invocation-specific, not persona-intrinsic, and belongs in spawn
    prompt
  - All 10 augur persona files exist (`breach-augur.md`, `charter-augur.md`, `chief-augur.md`, `doubt-augur.md`,
    `flow-augur.md`, `pattern-augur.md`, `proof-augur.md`, `provenance-augur.md`, `speed-augur.md`, `waste-augur.md`),
    but existing persona file content may be out of sync with spawn prompt content — before thinning any spawn prompt, a
    line-by-line diff between spawn prompt content and the corresponding persona file must be performed to identify
    spawn-prompt-only content that needs to be migrated to the persona file first; thinning before this check risks
    silently deleting agent behavior
- **Notes**: The PoC also validates that agents correctly read their persona files when spawned (behavioral regression
  test). If any agent behaves differently post-migration, the persona file content is incomplete and needs adjustment
  before rollout.

---

### Story 6: Document and Execute Incremental Rollout to All Multi-Agent Skills

- **As a** skill maintainer
- **I want** a documented, step-by-step migration guide for converting each multi-agent skill to thin spawn prompts
- **So that** the rollout is reversible, low-risk, and any skill maintainer can migrate a skill independently without
  introducing regressions
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given the migration guide in CLAUDE.md (or a linked `docs/architecture/` file), when a skill maintainer reads it,
     then they can migrate a single skill following a checklist: identify agents, confirm persona files exist (or create
     them), move content, write thin prompts, validate, record reduction metrics
  2. Given a skill is migrated following the guide, when `bash scripts/validate.sh` runs, then it passes — the guide
     includes running validation as a required step before committing
  3. Given skills are migrated incrementally (one at a time), when partial migration state exists (some skills migrated,
     some not), then all validators pass for both states simultaneously
  4. Given the rollout is complete across all 22 multi-agent skills, when total line reduction is measured, then it
     falls within the 40-60% target
  5. Given a skill was migrated incorrectly (persona content missing from file), when a maintainer detects a behavioral
     regression, then they can reverse the migration for that skill by reverting the SKILL.md to the pre-migration spawn
     prompts — rollback is a git revert, no special tooling needed
- **Edge Cases**:
  - Skill that uses the same agent name as another skill but with substantially different behavior: migration reveals a
    persona file split is needed (two distinct persona files for what was superficially the "same" agent type)
  - Skill where the "agent" is actually the lead executing the SKILL.md directly (no spawn prompt): migration guide must
    explicitly state that lead-as-executor roles do not get thin spawn prompts
  - Migration priority ordering: skills with the most lines (audit-slop, review-pr with 9 agents) yield the highest
    reduction and should be migrated first — guide should recommend priority order
- **Notes**: The rollout order recommendation: (1) audit-slop PoC first, (2) other 9-agent skills (review-pr), (3)
  remaining multi-agent skills in descending spawn-prompt line count. Behavioral regression testing is the key risk —
  for each migrated skill, run the skill on a test case and compare outputs before and after.

---

### Story 7: Update Forge/Scribe to Generate Thin Spawn Prompts by Default

- **As a** skill author (the Scribe agent in the Forge pipeline)
- **I want** Forge instructions to direct me to generate thin spawn prompts by default and to create or reference
  persona files for each new agent I design
- **So that** new skills created by the Forge don't perpetuate the old verbose spawn prompt pattern
- **Priority**: could-have
- **Acceptance Criteria**:
  1. Given the `create-conclave-team` SKILL.md Scribe instructions after update, when I (the Scribe) generate a new
     skill, then my spawn prompts default to the thin format: persona file reference + teammate roster + scope +
     optional overrides
  2. Given I generate a new agent that has no existing persona file, when I follow Scribe instructions, then I also
     create the persona file at `plugins/conclave/shared/personas/{id}.md` as part of the skill output
  3. Given I generate a new agent that reuses an existing persona (e.g., a new skill that also has a skeptic), when I
     follow Scribe instructions, then I reference the existing persona file rather than creating a duplicate
  4. Given the `create-conclave-team` SKILL.md Scribe instructions, when they are read, then the thin spawn prompt
     format is defined by example with a template snippet showing the required sections in order
  5. Given a skill generated by the updated Scribe, when `bash scripts/validate.sh` runs on the output, then all
     validators pass including persona file reference checks
- **Edge Cases**:
  - New skill for a domain that has no analogous existing persona (e.g., a database migration specialist): Scribe must
    create a net-new persona file from scratch; instructions must define the full schema to fill, not just reference an
    example
  - Skill with agent that has highly unusual output format requirements: Scribe must use SKILL-SPECIFIC OVERRIDES rather
    than distorting the persona file for the special case
  - Scribe generates a lead-as-executor skill (no spawn prompts): instructions must distinguish this pattern and not
    require thin spawn prompt format where there are no spawn prompts
- **Notes**: This story is blocked on Story 1 (expanded persona schema) and Story 3 (override convention) being
  finalized first — the Scribe needs a stable schema to write to. Lower priority than the migration stories; Forge
  output should only change after the migration pattern is proven. The Scribe currently generates large spawn prompts as
  part of its output template; this update changes that template.

---

## Non-Functional Requirements

- **Readability**: A migrated SKILL.md must be faster to scan than its pre-migration counterpart. Spawn prompts should
  be readable in 30 seconds; persona files in 2 minutes.
- **Auditability**: Reviewing a skill's agent behavior requires reading at most 2 files: the SKILL.md spawn prompt
  (invocation context) and the persona file (agent behavior). This must not become 3+ files.
- **Validator performance**: Adding persona file reference checks must not increase total validation time by more than
  10% (validators already scan all SKILL.md files; persona file checks are additional file reads).
- **Reversibility**: Every migration step is reversible via git revert. No migration step produces irreversible state
  changes.
- **Backward compatibility**: During incremental rollout, unmigrated skills must continue to pass all existing
  validators. No validator change may break currently-passing skills.

## Out of Scope

- Changes to the shared principles or communication protocol sync mechanism (sync-shared-content.sh handles a separate
  concern — HTML-marker-based injection into SKILL.md files — which is unaffected by persona file authority)
- Changes to persona files for single-agent skills (setup-project, wizard-guide) — they have no spawn prompts and are
  explicitly excluded
- Enforcement of the override convention by a validator (Story 3 override convention is enforced by code review only; no
  validator for override correctness is in scope)
- Persona files for agents outside the conclave plugin (php-tomes, etc.)
- Any change to how agents communicate (SendMessage protocol, checkpoint format) — this is a spawn prompt content
  refactor, not a communication refactor
