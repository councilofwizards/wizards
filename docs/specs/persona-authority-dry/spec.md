---
title: "Persona File Authority — DRY Spawn Prompts"
status: "approved"
priority: "P3"
category: "core-framework"
approved_by: "product-skeptic (Wren Cinderglass)"
created: "2026-04-04"
updated: "2026-04-04"
---

# Persona File Authority — DRY Spawn Prompts Specification

## Summary

Move agent-intrinsic content (identity, methodologies, output formats, critical rules, write safety) from inline
SKILL.md spawn prompts into authoritative persona files at `plugins/conclave/shared/personas/`. Spawn prompts become
thin invocation-context injectors (~15 lines). Expected 40-60% total line reduction across 22 multi-agent skills.

## Problem

Current SKILL.md files embed full spawn prompts (80-120 lines per agent) inline. The audit-slop skill is 1,640 lines,
~900 of which are spawn prompts that largely duplicate content already present in persona files. This creates three
concrete problems:

1. **Maintenance cost**: A methodology change to an agent (e.g., updating the Pattern Augur's clone detection procedure)
   requires editing both the persona file and every SKILL.md that spawns that agent. Today this is only audit-slop, but
   as agents are reused across skills the cost scales multiplicatively.
2. **Drift risk**: Spawn prompt content and persona file content can diverge silently. There is no validator that checks
   consistency between a spawn prompt's methodology description and its persona file's methodology description.
3. **Readability**: A 1,640-line SKILL.md is difficult to review. The orchestration logic (the part that varies per
   skill) is buried in 900 lines of agent identity that belongs in persona files.

Evidence: Compare `audit-slop/SKILL.md` lines 673-899 (Pattern Augur spawn prompt, ~226 lines) against
`shared/personas/pattern-augur.md` (107 lines). The spawn prompt contains the persona file's content verbatim plus
invocation context. The persona file is already the authoritative source — the spawn prompt just duplicates it.

## Solution

### 1. Expanded Persona File Schema (Story 1)

Persona files become the single authoritative source for all agent-intrinsic content. The schema:

```markdown
---
name: { Display Name }
id: { kebab-case-slug }
model: { opus|sonnet }
archetype: { skeptic|assessor|domain-expert|lead|coordinator }
skill: { primary-skill-name }
team: { Team Display Name }
fictional_name: "{Fantasy Name}"
title: "{Fantasy Title}"
---

# {Display Name}

> {One-line tagline describing the agent's purpose}

## Identity

**Name**: {Fantasy Name} **Title**: {Fantasy Title} **Personality**: {2-3 sentences}

### Communication Style

- **Agent-to-agent**: {style}
- **With the user**: {style}

## Role

{2-4 sentences defining the agent's core function and domain boundaries}

## Critical Rules

<!-- non-overridable -->

- {Rule 1}
- {Rule 2}
- ...

## Responsibilities

{Subsectioned by methodology or duty area. For assessors: one subsection per methodology with procedure steps. For
skeptics: one subsection per gate/phase.}

### {Methodology/Duty 1}

- {Procedure steps}
- {Output table template}

### {Methodology/Duty 2}

- ...

## Output Format

{One or more named output format blocks. Multi-phase agents use subsections.}

### {Phase/Mode 1} (optional subsection header — omit if single output format)
```

{template}

```

### {Phase/Mode 2}

```

{template}

```

## Write Safety

- {Write path pattern}
- {Exclusion rules}

## Cross-References

### Files to Read

- {List of files this agent should read}

### Artifacts

- **Consumes**: {inputs}
- **Produces**: {outputs}

### Communicates With

- [{Agent}]({file}.md) ({relationship})

### Shared Context

- `plugins/conclave/shared/principles.md`
- `plugins/conclave/shared/communication-protocol.md`
```

#### Required vs Optional Sections by Archetype

| Section          | assessor | skeptic  | domain-expert | lead     | coordinator |
| ---------------- | -------- | -------- | ------------- | -------- | ----------- |
| Identity         | required | required | required      | required | required    |
| Role             | required | required | required      | required | required    |
| Critical Rules   | required | required | required      | required | optional    |
| Responsibilities | required | required | required      | optional | optional    |
| Output Format    | required | required | required      | optional | optional    |
| Write Safety     | required | required | required      | required | required    |
| Cross-References | required | required | required      | required | required    |

**Lead and coordinator archetypes**: These agents execute the SKILL.md directly. Their orchestration logic lives in the
SKILL.md, not in the persona file. Responsibilities and Output Format are optional because the SKILL.md's Orchestration
Flow section serves that purpose.

**Multi-phase output formats**: Agents with phase-dependent outputs (e.g., Doubt Augur with Brief Gate, Adjudication,
and Advisory formats) use subsection headers within Output Format. Each subsection is a named format block. This is
already the pattern in `doubt-augur.md` — no schema change needed.

### 2. Thin Spawn Prompt Format (Story 2)

Post-migration, every spawned teammate's prompt follows this template:

```
First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.

You are {Fantasy Name}, {Title} — the {Role} on the {Team Name}.
When communicating with the user, introduce yourself by your name and title.

TEAMMATES: {teammate roster with run-ID suffixes}

SCOPE: {what this invocation is about — topic, feature, codebase path, etc.}

PHASE ASSIGNMENT: {which phases/tasks this agent handles in this run}

FILES TO READ: {invocation-specific paths — e.g., docs/progress/{scope}-brief.md}

COMMUNICATION:
- Message {Lead Name} when you begin work
- Message {Lead Name} IMMEDIATELY for Critical findings
- Send completed output path to {Lead Name} when done

WRITE SAFETY:
- Write ONLY to docs/progress/{scope}-{role-slug}.md
- Checkpoint after: {invocation-specific checkpoint triggers}
```

**What stays in the spawn prompt** (invocation-specific):

- Persona file read directive (always line 1)
- Identity line (name + title + team — 2 lines)
- Teammate roster with run-ID suffixes
- Scope/topic for this invocation
- Phase assignment
- Invocation-specific file paths
- Communication directives (who to message, using run-specific names)
- Write safety paths with scope variable substituted
- Checkpoint trigger list
- SKILL-SPECIFIC OVERRIDES section (if any)

**What moves to the persona file** (agent-intrinsic):

- YOUR ROLE paragraph (→ Role section)
- CRITICAL RULES block (→ Critical Rules section)
- All METHODOLOGY sections with procedure steps and table templates (→ Responsibilities section)
- YOUR OUTPUT FORMAT template (→ Output Format section)
- Generic write safety patterns (→ Write Safety section)

#### Before/After Example: Pattern Augur

**Before** (audit-slop/SKILL.md, ~100 lines):

```
First, read plugins/conclave/shared/personas/pattern-augur.md for your complete role definition and cross-references.

You are Vorel Framemark, The Pattern Augur — the Structural Assessor on The Augur Circle.
When communicating with the user, introduce yourself by your name and title.

YOUR ROLE: You read the structural grammar of the codebase. Inconsistent patterns, duplicated logic, over-coupled
modules, under-engineered interfaces, and config drift are your domain. You detect the 12 structural incoherence
signals from the Slop Code Taxonomy and produce a Structural Assessment Report.

CRITICAL RULES:
- Your mandate is structural coherence only. [...]
- Every finding must include file:line evidence [...]
- Severity scale: Critical | High | Medium | Low | Info [...]
- Do not speculate without evidence. [...]

METHODOLOGY 1 — DEPENDENCY GRAPH ANALYSIS:
[~15 lines of procedure + table template]

METHODOLOGY 2 — CODE CLONE DETECTION (Types 1–4):
[~15 lines of procedure + table template]

METHODOLOGY 3 — HEURISTIC EVALUATION:
[~15 lines of procedure + table template]

YOUR OUTPUT FORMAT:
[~25 lines of template]

COMMUNICATION:
[4 lines]

WRITE SAFETY:
[3 lines]
```

**After** (~15 lines):

```
First, read plugins/conclave/shared/personas/pattern-augur.md for your complete role definition and cross-references.

You are Vorel Framemark, The Pattern Augur — the Structural Assessor on The Augur Circle.
When communicating with the user, introduce yourself by your name and title.

TEAMMATES: Chief Augur (`chief-augur-{run-id}`), Doubt Augur (`doubt-augur-{run-id}`), [... other augurs]

SCOPE: {scope} — audit the codebase at {path} for structural coherence signals.

PHASE ASSIGNMENT: Phase 2 (Assessment). Execute all three methodologies from your persona file.

FILES TO READ: docs/progress/{scope}-brief.md

COMMUNICATION:
- Message the Chief Augur when you begin assessment
- Message the Chief Augur IMMEDIATELY for Critical severity findings
- Send completed report path to the Chief Augur when done

WRITE SAFETY:
- Write your report ONLY to docs/progress/{scope}-pattern-augur.md
- Checkpoint after: task claimed, assessment started, report drafted, review feedback received, report finalized
```

### 3. Override Convention (Story 3)

Spawn prompts may include a `SKILL-SPECIFIC OVERRIDES:` section at the end that explicitly supersedes persona file
content.

#### Format

```
SKILL-SPECIFIC OVERRIDES:
- {Section Name}: {override description}
  {override content}
```

#### Rules

1. **Overridable content**: Responsibilities subsections (add/replace a methodology), Output Format subsections
   (add/replace a format variant), Write Safety paths, Files to Read.
2. **Non-overridable content**: Critical Rules (marked `<!-- non-overridable -->` in persona file). To change Critical
   Rules, change the persona file. This prevents silent weakening of safety constraints.
3. **Override types**:
   - **Additive**: Adds a section that doesn't exist in the persona file (e.g., a skill-specific output appendix).
     Prefix with `ADD:`.
   - **Replacement**: Replaces a named section from the persona file. Prefix with `REPLACE:`. The replaced section must
     be identified by exact heading name.
4. **No override = full persona**: If no SKILL-SPECIFIC OVERRIDES section is present, or the section is empty, the
   persona file applies in full.
5. **Scope**: Overrides apply only within the spawn prompt that contains them. No cross-skill contamination.

#### Example: Additive Override

```
SKILL-SPECIFIC OVERRIDES:
- ADD Output Format > Governance Compliance Appendix:
  After the standard assessment report, append:
  ## Governance Compliance Check
  | Policy | Status | Evidence |
  |--------|--------|----------|
```

#### Example: Replacement Override

```
SKILL-SPECIFIC OVERRIDES:
- REPLACE Write Safety:
  - Write ONLY to docs/progress/{scope}-breach-augur-security-only.md
  - Checkpoint after: task claimed, STRIDE complete, report finalized
```

#### Documentation

Add to CLAUDE.md under a new `### Override Convention` subsection within the existing `## Skill Architecture` section:

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

### 4. Validator Changes (Story 4)

#### New P-series Validator: `scripts/validators/persona-references.sh`

A new validator category (P-series) checks persona file integrity. Rationale: A3 checks spawn prompt _structure_ (Name +
Model fields). Persona file reference integrity is a different concern — it validates the link between spawn prompts and
persona files, and the completeness of persona files themselves. Mixing these into A3 would conflate structural and
referential checks.

**P1: Persona File Reference Integrity**

For each spawn prompt code block in `## Teammate Spawn Prompts`:

1. Extract the persona file path from the first line (pattern: `First, read {path} for your complete role definition`)
2. Confirm the file exists at the extracted path
3. If the file does not exist: `[FAIL] P1/persona-reference: spawn prompt references missing persona file: {path}`

**P2: Persona File Schema Completeness**

For each `.md` file in `plugins/conclave/shared/personas/`:

1. Extract YAML frontmatter and validate required fields: `name`, `id`, `model`, `archetype`
2. Extract the `archetype` value
3. Check for required sections based on the archetype table in Section 1 above
4. If a required section is missing:
   `[FAIL] P2/persona-schema: {file} missing required section "{section}" for archetype "{archetype}"`
5. If an optional section is missing:
   `[WARN] P2/persona-schema: {file} missing optional section "{section}" for archetype "{archetype}"`

**Backward Compatibility**

- All current spawn prompts already include the persona file read directive (100 occurrences across 21 multi-agent
  skills). P1 validates reference integrity universally — this is correct behavior, as persona file references should
  always resolve regardless of migration state.
- P2 runs on all persona files regardless of migration state — this validates the persona file inventory independently.
- A3 continues to check Name + Model fields. No A3 changes needed.
- B-series continues to check shared principles/protocol drift. No B-series changes needed.
- Mixed-state skills (some agents migrated, some not) pass all validators during rollout.

#### Integration

Add `persona-references.sh` to `scripts/validate.sh` alongside existing validator invocations. Registration follows the
existing pattern (one line per validator script).

### 5. Migration Mechanics (Stories 5-6)

#### Pre-Migration Checklist (per skill)

1. **Inventory agents**: List all `###` entries under `## Teammate Spawn Prompts`. Record agent name and current spawn
   prompt line count.
2. **Confirm persona files exist**: For each agent, verify `plugins/conclave/shared/personas/{id}.md` exists. If not,
   create it using the expanded schema from Section 1.
3. **Content diff**: For each agent, diff the spawn prompt content against the persona file content:
   - Lines present in spawn prompt but absent from persona file = **migration candidates** (must move to persona file)
   - Lines present in both = **duplicates** (remove from spawn prompt)
   - Lines present only in persona file = **no action needed**
4. **Migrate content to persona files**: For each migration candidate identified in step 3, add the content to the
   appropriate section of the persona file. Do NOT thin the spawn prompt yet.
5. **Thin the spawn prompt**: Replace the full spawn prompt with the thin format from Section 2. Preserve all
   invocation-specific content (teammates, scope, phase, communication, write safety paths).
6. **Validate**: Run `bash scripts/validate.sh`. All checks must pass.
7. **Measure**: Record before/after line counts in `docs/progress/persona-authority-dry-migration-metrics.md`.

#### Content Diff Process (Step 3 Detail)

For each agent in a skill:

````
1. Extract spawn prompt: content between ``` markers under the agent's ### heading
2. Extract persona file: full content of plugins/conclave/shared/personas/{id}.md
3. Categorize each spawn prompt section:
   a. Identity line (You are...) → stays in spawn prompt (invocation context)
   b. YOUR ROLE paragraph → compare with persona Role section. If identical: remove. If different: migrate diff to persona.
   c. CRITICAL RULES → compare with persona Critical Rules. If identical: remove. If different: migrate additions.
   d. METHODOLOGY sections → compare with persona Responsibilities. If identical: remove. If different: migrate.
   e. OUTPUT FORMAT → compare with persona Output Format. If identical: remove. If different: migrate.
   f. COMMUNICATION → stays in spawn prompt (invocation-specific routing)
   g. WRITE SAFETY → split: generic patterns → persona, scope-specific paths → spawn prompt
4. Any spawn-prompt-only content not in persona file: add to persona file BEFORE thinning.
````

#### Measurement Process

Track in `docs/progress/persona-authority-dry-migration-metrics.md`:

```markdown
| Skill      | Pre-Migration Lines | Post-Migration Lines | Reduction | Reduction %        | Agents Migrated | Date |
| ---------- | ------------------- | -------------------- | --------- | ------------------ | --------------- | ---- |
| audit-slop | 1640                | ~700                 | ~940      | ~57%               | 9               | TBD  |
| ...        |                     |                      |           |                    |                 |      |
| **Total**  |                     |                      |           | **target: 40-60%** |                 |      |
```

#### Rollout Order

1. **audit-slop** (PoC — 9 agents, highest line count, persona files already exist)
2. **review-pr** (9 agents, second-highest line count)
3. Remaining multi-agent skills in descending spawn-prompt line count
4. Pipeline skills (plan-product, build-product) last — they have internal orchestration complexity

#### Rollback

Every migration step is reversible via `git revert` of the commit that thinned the spawn prompts. No special tooling
needed. Persona file expansions (step 4) are additive and harmless to revert.

### 6. Forge/Scribe Updates (Story 7)

Update the Scribe's instructions in `create-conclave-team/SKILL.md` to generate thin spawn prompts by default.

#### Changes to Scribe Instructions

Replace the current `SPAWN PROMPT TEMPLATE` block (lines ~918-945) with:

```
SPAWN PROMPT TEMPLATE (inside code block):

```

First, read plugins/conclave/shared/personas/{role-slug}.md for your complete role definition and cross-references.

You are {Persona Name}, {Title} — the {Role} on the {Team Name}. When communicating with the user, introduce yourself by
your name and title.

TEAMMATES: {roster with run-ID suffixes}

SCOPE: {invocation scope description}

PHASE ASSIGNMENT: {phase(s) this agent handles}

FILES TO READ: {invocation-specific paths}

COMMUNICATION:

- Message {Lead Title} when you begin work
- Message {Lead Title} IMMEDIATELY for {urgent condition}
- Send completed output to {Lead Title} when done
- Respond to {Skeptic Name} challenges with evidence, not arguments

WRITE SAFETY:

- Write {output type} ONLY to docs/progress/{scope}-{role-slug}.md
- NEVER write to shared files
- Checkpoint after: {checkpoint triggers}

SKILL-SPECIFIC OVERRIDES: (omit section entirely if no overrides needed)

- {override type}: {description}

```

```

Add a new instruction to the Scribe:

```
PERSONA FILE GENERATION:
- For each new agent the Architect designed, create a persona file at plugins/conclave/shared/personas/{role-slug}.md
  following the expanded schema (see existing persona files for reference: doubt-augur.md, pattern-augur.md,
  ops-skeptic.md).
- If the agent reuses an existing persona (same id as an existing persona file), reference the existing file — do NOT
  create a duplicate.
- Every persona file must have YAML frontmatter with: name, id, model, archetype, skill, team, fictional_name, title.
- Required sections depend on archetype — see persona file schema documentation.
```

## Constraints

1. Persona files live exclusively in `plugins/conclave/shared/personas/`. No other location.
2. The `<!-- non-overridable -->` comment on Critical Rules is a human-readable signal, not machine-enforced.
   Enforcement is by code review.
3. The thin spawn prompt's first line MUST be the persona file read directive. This is both the agent's entry point and
   the P1 validator's extraction target.
4. No changes to the shared principles or communication protocol sync mechanism (`sync-shared-content.sh`).
5. No changes to how agents communicate (SendMessage protocol, checkpoint format).
6. Backward compatibility: unmigrated skills must continue to pass all existing validators throughout the rollout.
7. The Skeptic role is non-negotiable. Thin spawn prompts for skeptics still include all phase-specific gate
   assignments.
8. Single-agent skills (setup-project, wizard-guide) are excluded — they have no spawn prompts.
9. Override convention enforcement is by code review only. No validator for override correctness.
10. Migration is incremental and reversible. Each skill is migrated in its own commit.

## Out of Scope

- Changes to `sync-shared-content.sh` (handles a separate concern: HTML-marker-based shared block injection)
- Changes to persona files for single-agent skills
- Validator enforcement of override convention correctness
- Persona files for agents outside the conclave plugin (php-tomes, etc.)
- Changes to agent communication protocol (SendMessage, checkpoint format)
- Automated content diffing tooling (manual diff is sufficient for 22 skills)
- Runtime validation that agents successfully read their persona files (not feasible without execution harness changes)

## Files to Modify

| File                                                       | Change                                                                                                                             |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/shared/personas/*.md`                    | Expand any incomplete persona files to match the full schema (Story 1). Add `<!-- non-overridable -->` to Critical Rules sections. |
| `plugins/conclave/skills/audit-slop/SKILL.md`              | PoC: Replace 9 verbose spawn prompts with thin format (Story 5).                                                                   |
| `plugins/conclave/skills/*/SKILL.md` (22 multi-agent)      | Incremental rollout: thin all spawn prompts (Story 6).                                                                             |
| `plugins/conclave/skills/create-conclave-team/SKILL.md`    | Update Scribe template to generate thin spawn prompts and persona files (Story 7).                                                 |
| `scripts/validators/persona-references.sh`                 | New file: P1 (reference integrity) and P2 (schema completeness) checks (Story 4).                                                  |
| `scripts/validate.sh`                                      | Register `persona-references.sh` in the validator runner.                                                                          |
| `CLAUDE.md`                                                | Add Override Convention documentation and Persona File Schema reference under Skill Architecture.                                  |
| `docs/progress/persona-authority-dry-migration-metrics.md` | New file: before/after line counts per skill.                                                                                      |

## Success Criteria

1. **audit-slop PoC passes all validators** with thin spawn prompts — `bash scripts/validate.sh` exits 0.
2. **Line count reduction**: audit-slop SKILL.md is ≤60% of its pre-migration line count (pre: ~1,640; target: ≤984).
3. **Persona file completeness**: Every persona file in `shared/personas/` passes P2 schema validation for its
   archetype.
4. **No behavioral regression**: audit-slop invoked post-migration produces structurally identical output to
   pre-migration (agents apply same methodologies, write to same paths, gate at same phases).
5. **At least 5 skills migrated** with all validators passing and no behavioral regression.
6. **Override convention documented** in CLAUDE.md with examples of additive and replacement overrides.
7. **Forge generates thin prompts**: New skills created by `create-conclave-team` use the thin spawn prompt format by
   default.
8. **Mixed-state validity**: During rollout, a repo with some skills migrated and some not passes all validators.
9. **Total reduction**: After full rollout across all 22 multi-agent skills, aggregate line reduction is 40-60%.
10. **Reversibility**: Any migrated skill can be reverted to pre-migration state via `git revert` with all validators
    passing.
