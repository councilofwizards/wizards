---
type: "user-stories"
feature: "custom-agent-roles"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-01-custom-agent-roles.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Custom Agent Roles (P3-01)

## Epic Summary

Allow project owners to define custom agent roles without editing SKILL.md files. Skills read available roles from a project-level config at startup and compose teams from the available pool. Starter role templates cover common archetypes (Data Engineer, ML Engineer, Mobile Engineer). The Skeptic role remains mandatory and non-customizable regardless of team composition.

## Stories

---

### Story 1: Role Definition File Schema

- **As a** project owner who needs non-standard agents on my team
- **I want** a stable, documented schema for defining custom agent roles in YAML files
- **So that** I can describe a role once and have it read consistently by any skill that supports custom role composition
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the repository, when a custom role file is defined, then it lives at `docs/agents/{role-id}.md` and contains YAML frontmatter with required fields: `id` (slug, lowercase-kebab), `name` (display name), `model` (`sonnet` | `opus`), `archetype` (`domain-expert` | `reviewer` | `coordinator`), and a `description` field (one-line summary)
  2. Given a custom role file's body, when inspected, then it contains a `## Role` section describing the agent's responsibilities, a `## Critical Rules` section listing non-negotiable behaviors, and a `## Tasks` section listing the agent's default task types
  3. Given a role file with `archetype: reviewer`, when inspected, then the `## Critical Rules` section must include at least one rule about explicitly approving or rejecting submitted work (the Skeptic behavioral contract)
  4. Given a role file with `id` that is `plan-skeptic`, `ops-skeptic`, `story-skeptic`, `spec-skeptic`, or any value ending in `-skeptic`, when skill composition reads it, then the role is treated as an additional Skeptic-type role (not a replacement for the built-in Skeptic)
  5. Given docs/agents/ does not exist in a project, when any skill runs, then the skill proceeds with its built-in default roles and no error is raised
  6. Given a role file with missing required frontmatter fields, when a skill attempts to read it, then the skill logs a warning naming the file and the missing fields, skips that role, and continues with built-in defaults

- **Edge Cases**:
  - Role file with `id` matching a built-in role (e.g., `id: backend-eng`): custom role overrides the built-in for that session; skill logs a notice — "Custom role `backend-eng` loaded from docs/agents/; overrides built-in"
  - Role file is an empty file: treated as malformed; skill logs a warning and skips it
  - `docs/agents/` directory exists but is empty: skill proceeds with built-in defaults, no warning
  - `model` value is neither `sonnet` nor `opus`: role file treated as malformed; skill logs a warning specifying the invalid model value

- **Notes**: The `docs/agents/` location follows the pattern established by `docs/stack-hints/` (per-project guidance files placed in docs/ for skill reading). Using YAML frontmatter + markdown body mirrors the existing persona file format in `plugins/conclave/shared/personas/`, making the schema familiar to skill authors.

---

### Story 2: Role Discovery at Skill Startup

- **As a** skill lead running any multi-agent conclave skill
- **I want** the skill to scan `docs/agents/` for custom role files during Setup and make them available for team composition
- **So that** custom roles are loaded once at the start of the session rather than per-team-spawn, keeping startup deterministic
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a skill's Setup section, when execution begins, then a new setup step reads all `*.md` files in `docs/agents/` (if the directory exists), parses their YAML frontmatter, and builds an in-session role registry
  2. Given the role registry is built, when the skill lead reaches the Spawn the Team step, then it consults the registry to determine whether any built-in roles should be supplemented or overridden by custom roles
  3. Given multiple custom role files in `docs/agents/`, when the registry is built, then all valid files are loaded; invalid files (missing frontmatter, malformed YAML) are skipped with a per-file warning logged to the user
  4. Given a custom role that overrides a built-in role (same `id`), when the team is composed, then the custom role's `name`, `model`, and prompt are used in place of the built-in; the override is logged to the user at startup
  5. Given `docs/agents/` does not exist or is unreadable, when setup runs, then the skill proceeds with built-in defaults; no error is raised and discovery is treated as returning an empty registry
  6. Given `bash scripts/validate.sh`, when run after any SKILL.md changes to add the discovery step, then all 12/12 validators still pass

- **Edge Cases**:
  - `docs/agents/` is a file rather than a directory: skill logs a warning — "docs/agents/ is not a directory; custom role loading skipped" — and proceeds with defaults
  - Custom role file has valid frontmatter but an empty `## Role` section: role is loaded with the description as its only context; skill logs a notice that the role body is sparse
  - Discovery finds 10+ role files: all are loaded; no upper limit on the registry size, but skills only spawn roles they explicitly select (see Story 3)
  - Skill is a single-agent skill (setup-project, wizard-guide): discovery step is skipped entirely — single-agent skills do not compose teams

- **Notes**: Discovery is a read-only setup step. It does not modify any files. The role registry is an in-memory construct for the session only. Skills that do not support custom role composition (single-agent skills) must skip this step. The A2 validator path for single-agent skills (checks `Setup` + `Determine Mode`) must not be affected.

---

### Story 3: Team Composition with Custom Roles

- **As a** skill lead composing an agent team
- **I want** to include custom roles from the registry in the spawned team alongside or instead of built-in roles
- **So that** my project's specific domain expertise is represented on the team without me modifying any SKILL.md file
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the role registry contains one or more custom roles, when the skill lead reaches the Spawn the Team step, then custom roles with `archetype: domain-expert` are eligible to be spawned as additional execution agents alongside built-in agents
  2. Given a custom role eligible for spawning, when it is spawned via the `Agent` tool, then the spawn prompt includes: (a) the role's `## Role` section as its primary task description, (b) the team's shared Shared Principles block verbatim, (c) the team's Communication Protocol block verbatim, and (d) the Write Safety rules for the current skill
  3. Given the built-in Skeptic role for the skill, when team composition runs with custom roles present, then the Skeptic is always spawned and is never replaced or omitted — custom roles supplement, they do not substitute for, the Skeptic
  4. Given a custom role with `archetype: reviewer`, when the team is composed, then the skill lead may optionally spawn it as an additional reviewer; it does not replace the built-in Skeptic but may perform a preliminary review before the Skeptic gate
  5. Given a custom role successfully spawned, when it completes work, then its output passes through the built-in Skeptic gate before being finalized — the Skeptic's approval authority is unchanged
  6. Given the team is fully composed (built-in + custom roles), when the skill completes, then `bash scripts/validate.sh` still reports 12/12 passing

- **Edge Cases**:
  - Registry contains a role with `archetype: coordinator`: skill lead may spawn it as a sub-coordinator for a specific stage; it reports to the lead, not to the user directly
  - Two custom roles define conflicting responsibilities (e.g., two data engineers with different specializations): skill lead spawns both and assigns non-overlapping tasks; no automatic deduplication
  - Custom role's `model` is `opus` but the skill author prefers Sonnet for cost efficiency: custom role's declared model takes precedence — the role definition is the contract
  - All roles in the registry are `archetype: reviewer` and none are `domain-expert`: skill lead spawns built-in execution agents; custom reviewer roles are added post-execution

- **Notes**: The Skeptic non-customizability constraint (see Story 5) makes custom roles additive only with respect to the quality gate. Custom roles that attempt to name themselves `*-skeptic` or declare `archetype: reviewer` are subject to the same review as all other roles — they still route through the built-in Skeptic for final approval.

---

### Story 4: Starter Role Templates

- **As a** project owner who wants to add a custom role but doesn't know the required format
- **I want** starter role templates for common archetypes (Data Engineer, ML Engineer, Mobile Engineer) at `docs/templates/agents/`
- **So that** I can copy and adapt a working template rather than authoring from scratch against the schema spec
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given the repository's `docs/templates/` directory, when templates are added, then three starter files exist: `docs/templates/agents/data-engineer.md`, `docs/templates/agents/ml-engineer.md`, and `docs/templates/agents/mobile-engineer.md`
  2. Given each starter template, when inspected, then it contains valid YAML frontmatter matching the Story 1 schema (all required fields populated with sensible defaults), a filled-out `## Role` section, at least 3 entries in `## Critical Rules`, and at least 3 entries in `## Tasks`
  3. Given a user who copies `docs/templates/agents/data-engineer.md` to `docs/agents/data-engineer.md` without modification, when any skill runs, then the role is loaded successfully from the registry and is eligible for team composition
  4. Given the templates, when inspected, then each template's `## Critical Rules` section includes the shared principles compliance rule: "Follow all Shared Principles and the Communication Protocol. Checkpoint progress in your role-scoped progress file. Send updates to the lead on task start, completion, and blockers."
  5. Given the F-series artifact template validator (`scripts/validators/artifact-templates.sh`), when `bash scripts/validate.sh` runs, then the validator does not flag `docs/templates/agents/` files (they are not artifact templates and should be excluded from F-series checks)

- **Edge Cases**:
  - User copies a template to `docs/agents/` and changes only the `id` field: valid — the role loads with the new id
  - User places a template directly in `docs/agents/` without modification (keeping the template's default `id`): valid — the template `id` is a valid slug and the role loads normally
  - `docs/templates/agents/` directory does not exist yet: this story creates it; `setup-project` does not need to scaffold it (it is part of the plugin, not a user-generated directory)

- **Notes**: Starter templates are documentation-class files. They are committed to the plugin repo alongside `docs/templates/artifacts/` templates and updated when the role schema changes. The F-series validator currently checks `docs/templates/artifacts/` only — it must not accidentally pick up `docs/templates/agents/` files as artifact templates. Confirm this before writing the templates.

---

### Story 5: Skeptic Non-Customizability Guard

- **As a** skill author or system operator
- **I want** the built-in Skeptic role to remain mandatory and non-customizable regardless of what custom roles are loaded
- **So that** every multi-agent skill retains its quality gate and no project-level configuration can accidentally or intentionally weaken it
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a custom role file with an `id` that ends in `-skeptic` (e.g., `id: quality-skeptic`), when team composition runs, then the skill logs a notice — "Custom role `quality-skeptic` has Skeptic archetype. It will be spawned as an additional reviewer. The built-in Skeptic is not replaced." — and spawns both
  2. Given the built-in Skeptic's spawn prompt in any SKILL.md, when custom role composition runs, then the Skeptic's prompt is never modified, truncated, or overridden by custom role loading
  3. Given any team composition — default, supplemented with custom domain experts, or supplemented with custom reviewers — when the Orchestration Flow runs, then the built-in Skeptic gate step is present and executed
  4. Given a custom role attempting to declare `id: ops-skeptic` (or any other built-in Skeptic id), when team composition runs, then the skill logs a warning: "Custom role `ops-skeptic` conflicts with a built-in Skeptic id. Custom role loaded under `custom-ops-skeptic` to avoid collision." — the `id` is prefixed with `custom-` and the built-in Skeptic is spawned unchanged
  5. Given the Communication Protocol injected into custom roles, when the spawn prompt is assembled, then the Skeptic routing row (`Plan ready for review → write(ops-skeptic, ...)`) is included verbatim — custom roles know to route to the built-in Skeptic, not to each other

- **Edge Cases**:
  - Project has a `docs/agents/` directory with a role file whose body attempts to redefine the Skeptic's approval authority: the file is loaded but the built-in Skeptic's own spawn prompt governs its behavior — the custom file cannot change what the Skeptic does
  - Custom role registry contains zero roles: built-in Skeptic is spawned as normal; no guard logic is triggered
  - Skill runs in `--light` mode: Skeptic guard is unchanged — the built-in Skeptic is always present regardless of mode

- **Notes**: This story codifies the invariant already stated in the roadmap item: "The Skeptic role must remain mandatory and non-customizable — it's the quality gate." Implementation is primarily documentation and enforcement logic in the team composition step of affected SKILL.md files. No new validator check is required, but the constraint should be noted in the shared principles or in wizard-guide's documentation of custom roles.

---

### Story 6: Validator Compliance for Custom Role Files

- **As a** skill author adding custom role support to a SKILL.md
- **I want** the existing validator suite to continue passing after all changes are made
- **So that** the plugin's quality guarantees are preserved and no regressions are introduced in the existing 17 skills
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given all SKILL.md changes made for Stories 1–5, when `bash scripts/validate.sh` is run, then the result is still 12/12 validators passing
  2. Given new `docs/templates/agents/` template files, when `bash scripts/validate.sh` is run, then the F-series validator (`artifact-templates.sh`) does not flag these files as missing type fields or invalid artifact templates
  3. Given any multi-agent SKILL.md file updated to include a role-discovery setup step, when the A2 validator (`skill-structure.sh`) runs, then the required section checklist is still satisfied — the discovery step is added within the existing Setup section, not as a new top-level section
  4. Given shared content markers in all modified SKILL.md files, when the B-series validator (`skill-shared-content.sh`) runs, then no drift is detected — the sync script is re-run after any SKILL.md modifications before committing
  5. Given the A3 validator check for spawn definitions (Name + Model fields), when custom roles are added to team spawn sections, then custom role spawn entries include both `Name` and `Model` fields so the validator does not flag them as incomplete

- **Edge Cases**:
  - A SKILL.md modification inadvertently introduces a new top-level section that the A2 validator does not recognize: validator flags it; the section must be merged into an existing valid section or the validator updated with explicit justification
  - Sync script run after SKILL.md modification resets manually edited content: shared content blocks are restored from shared/; non-shared edits outside the markers are preserved

- **Notes**: Run `bash scripts/validate.sh` as the final step before each story's implementation is considered complete. The validator suite is the acceptance test for structural correctness.

---

## Non-Functional Requirements

- **Backward compatibility**: Projects with no `docs/agents/` directory must experience zero behavior change after P3-01 lands. All custom role loading is opt-in via file presence.
- **Validator stability**: 12/12 validators must pass after all changes. The F-series validator must not inadvertently check `docs/templates/agents/` files.
- **Skeptic invariant**: The Skeptic quality gate is non-negotiable in every multi-agent skill. No custom role configuration may weaken, remove, or bypass it.
- **Prompt injection safety**: Custom role file content from `docs/agents/` is user-authored and injected into agent prompts. Content must be framed clearly (role's `## Role` section under a labelled heading) so agents can distinguish it from system-authoritative instructions.

## Out of Scope

- Dynamic role hot-loading mid-session (roles are loaded once at setup and do not change during a session)
- Role inheritance or composition (a custom role cannot extend a built-in role; it is a standalone definition)
- Role access control (all roles in `docs/agents/` are available to all skills; no per-skill role allowlists)
- UI or interactive tooling for role authoring — roles are plain markdown files edited by the user
- Automatic sync of custom roles to the shared personas directory — `docs/agents/` is project-local only
- Changes to the shared Skeptic persona files in `plugins/conclave/shared/personas/`
