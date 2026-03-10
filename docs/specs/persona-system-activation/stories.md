---
type: "user-stories"
feature: "persona-system-activation"
status: "approved"
source_roadmap_item: "docs/roadmap/P2-09-persona-system-activation.md"
approved_by: "Grimm Holloway, Keeper of the INVEST Creed"
created: "2026-03-10"
updated: "2026-03-10"
---

# User Stories: Persona System Activation (P2-09)

## Epic Summary

The Conclave plugin has 45+ fictional personas with names, titles, and personalities — but spawn prompts reference agents by role ID only, leaving the fantasy identity layer architecturally dormant. This epic activates the persona system by injecting fictional names into every spawn prompt, reinforcing identity adoption through a sign-off convention in the shared communication protocol, and cleaning up a misleading placeholder in the same protocol file.

---

## Stories

### Story 1: Fictional Name Injection in Spawn Prompts

- **As a** user invoking a Conclave skill
- **I want** each spawned agent to introduce themselves by their fictional name and title
- **So that** the Conclave's fantasy persona layer is alive during execution — I am meeting Theron Blackwell, Scout of the Outer Reaches, not a generic "Market Researcher"
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given any of the 12 multi-agent SKILL.md files, when a spawn prompt is read, then the opening identity line includes both the agent's fictional name and title from their corresponding persona file (e.g., "You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher on the Market Research Team.")
  2. Given a spawn prompt that has been updated, when the spawned agent first addresses the user, then the agent introduces themselves using the fictional name and title stated in their spawn prompt
  3. Given the 12 multi-agent SKILL.md files, when all are audited, then every spawn prompt (estimated 40+) contains the fictional_name and title values drawn from the corresponding persona file's YAML frontmatter
  4. Given a skill that has a dedicated skeptic role, when the skeptic's spawn prompt is read, then it also contains the skeptic's fictional name and title from their persona file
- **Edge Cases**:
  - Business skills (draft-investor-update, plan-sales, plan-hiring) have their own persona files with different naming conventions (e.g., `accuracy-skeptic--draft-investor-update.md`): all three must be updated, not just engineering Tier 1 skills
  - A persona file's `fictional_name` or `title` field is empty or missing: treat as a blocker — do not inject a blank string; surface the gap as a data error to be fixed
  - run-task spawns dynamic agents from generic archetypes with no persona file assignments: this skill is explicitly out of scope for Story 1 (see Out of Scope)
- **Notes**: Fictional names and titles must be sourced from the `fictional_name` and `title` YAML fields in `plugins/conclave/shared/personas/{id}.md`. Do not invent names. The format is: "You are {fictional_name}, {title} — the {Role Name} on the {Team Name}."

---

### Story 2: Spawn Prompt Self-Introduction Instruction

- **As a** user receiving output from a Conclave agent
- **I want** agents to be explicitly instructed to introduce themselves by name when addressing me
- **So that** the persona introduction is structurally enforced, not dependent on the LLM inferring intent from a persona file reference
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given any updated spawn prompt, when it is read, then it contains an explicit instruction such as "When communicating with the user, introduce yourself by your name and title."
  2. Given the instruction is present in a spawn prompt, when the spawned agent first responds to the user, then the response begins with or prominently includes the agent's fictional name and title
  3. Given all 12 multi-agent SKILL.md files post-update, when each spawn prompt is audited, then 100% contain the self-introduction instruction
- **Edge Cases**:
  - An agent only communicates agent-to-agent and never addresses the user directly: the instruction should still be present — future invocations may change agent roles, and consistency is more maintainable than conditional presence
  - The self-introduction instruction conflicts with a skill-specific persona instruction: the spawn prompt's explicit instruction takes precedence; do not remove skill-specific nuances
- **Notes**: Story 1 (fictional name line) and Story 2 (introduction instruction) are tightly coupled and should be implemented together in a single editing pass per SKILL.md. They are separated here for INVEST clarity.

---

### Story 3: Communication Protocol Sign-Off Convention

- **As a** user receiving messages from Conclave agents
- **I want** agents to sign their user-facing messages with their persona name and title
- **So that** every message from the Conclave is stamped with a character's identity — reinforcing immersion across the entire session, not just at first introduction
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given `plugins/conclave/shared/communication-protocol.md`, when the Message Format section is read, then it contains a sign-off convention instruction: "When addressing the user, sign messages with your persona name and title."
  2. Given `sync-shared-content.sh` is run after the edit, when all 12 multi-agent SKILL.md files are checked, then each contains the updated Message Format section with the sign-off convention
  3. Given a SKILL.md that has been synced, when its shared content markers are inspected, then the content between `<!-- BEGIN SHARED: communication-protocol -->` and `<!-- END SHARED: communication-protocol -->` matches the authoritative source (B1 validator passes)
  4. Given the B-series validators are run after sync, when all checks complete, then B1, B2, and B3 all pass (0 drift errors)
- **Edge Cases**:
  - The sign-off convention is added inside the Message Format code block vs. outside it: the instruction is prose guidance and must be placed as a sentence in the Message Format section, not inside the fenced code block (which is reserved for structural message formatting)
  - A skill with `type: single-agent` or `tier: 2` is included in sync: the sync script and B-series validators already skip these — confirm exclusions still hold after the edit
- **Notes**: Edit only `plugins/conclave/shared/communication-protocol.md`. Never edit the synced copies in SKILL.md files directly. Run `bash scripts/sync-shared-content.sh` immediately after editing.

---

### Story 4: Communication Protocol Placeholder Fix

- **As a** plugin developer maintaining the communication protocol
- **I want** the "plan ready for review" row in the protocol to use a generic `{skill-skeptic}` placeholder instead of the literal "product-skeptic"
- **So that** the authoritative source file is not misleading — the sync script substitutes the per-skill skeptic name, and the source should make this substitution pattern explicit
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given `plugins/conclave/shared/communication-protocol.md`, when the When to Message table is read, then the "Plan ready for review" row contains `{skill-skeptic}` (not "product-skeptic") as the recipient placeholder
  2. Given an inline comment is added, when the table row is read, then it includes a comment explaining that `{skill-skeptic}` is substituted by `sync-shared-content.sh` with the per-skill skeptic name
  3. Given `sync-shared-content.sh` is run after the edit, when the 12 multi-agent SKILL.md files are checked, then per-skill skeptic names are still correctly substituted (sync behavior is not broken by the placeholder change)
  4. Given the full validator suite is run post-sync, when all 12 checks complete, then all 12/12 validators pass
- **Edge Cases**:
  - The sync script's substitution logic is keyed on "product-skeptic" as a literal string: if the normalizer in `skill-shared-content.sh` or the sync script itself pattern-matches "product-skeptic", changing the source to `{skill-skeptic}` could break substitution — verify the sync script's substitution input before editing
  - The placeholder change is done in the same edit pass as Story 3: this is the intended implementation path; confirm both edits are applied before running sync
- **Notes**: This is a maintenance quality fix, not a user-visible change. It can and should be batched with Story 3 in a single edit to `communication-protocol.md` followed by one sync run. The inline comment format should be an HTML comment on the same line or immediately following the table row.

---

### Story 5: Validator Green After All Changes

- **As a** plugin developer
- **I want** all 12/12 validators to pass after the persona activation changes are applied
- **So that** the validation suite continues to enforce structural integrity and shared content drift does not regress
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given all changes from Stories 1-4 are applied, when `bash scripts/validate.sh` is run, then the output shows 12/12 checks passing with no errors or warnings
  2. Given the A-series validators check spawn prompt structure, when they run against updated SKILL.md files, then added persona name lines and self-introduction instructions do not violate A1-A4 checks
  3. Given the B-series validators check shared content drift, when they run after sync, then B1 (no principles drift), B2 (no protocol drift), and B3 (authoritative source check) all pass
  4. Given the sync script runs shared content substitution, when it completes, then all per-skill skeptic names in the protocol are correctly substituted in their respective SKILL.md files (not replaced with the literal `{skill-skeptic}`)
- **Edge Cases**:
  - A spawn prompt edit accidentally modifies a section delimiter or shared content marker: A1 (frontmatter) or A4 (marker presence) would fail — verify markers are untouched after editing spawn prompt blocks
  - The placeholder fix in Story 4 breaks sync substitution, causing B2 drift in one or more SKILL.md files: this must be caught before commit; run `bash scripts/validate.sh` as the final step of the implementation
- **Notes**: This story is a quality gate, not a separate deliverable. Implementation of Stories 1-4 must satisfy these criteria before the feature is considered complete.

---

## Non-Functional Requirements

- **Consistency**: Fictional name and title values in spawn prompts must exactly match the `fictional_name` and `title` fields in the corresponding persona YAML frontmatter. No creative reinterpretation.
- **Maintainability**: Shared protocol changes must follow the established pattern: edit in `shared/`, sync via script, never edit synced copies directly. This ensures future sync runs do not overwrite manual edits.
- **No runtime impact**: This is a plugin/tooling project with no application runtime. All changes are markdown edits and shell script runs. No performance, security, or latency requirements apply.
- **Validator compliance**: All 12/12 validators must pass at completion. No new validator categories need to be created for this feature.
- **Atomicity of sync**: Stories 3 and 4 edit the same file (`communication-protocol.md`). Both edits must be applied before running sync to avoid two sync runs that could cause intermediate drift states.

---

## Out of Scope

- **run-task persona grounding**: The `run-task` skill dynamically composes agents from generic archetypes with no persona file assignments. Activating personas for run-task requires a separate design (persona files for the four generic archetypes). This is documented as a future roadmap item and is explicitly excluded from P2-09.
- **New persona file creation**: P2-09 activates existing personas. If any persona file is missing `fictional_name` or `title` fields, fixing the persona file is a prerequisite blocker, not in-scope work.
- **Communication protocol structural changes**: Only the sign-off convention addition and the placeholder fix are in scope. Restructuring the protocol, adding new message types, or modifying the When to Message table beyond the placeholder fix are excluded.
- **Validator additions**: No new validator rules are added for persona name presence in spawn prompts. Validator coverage gaps (e.g., checking that spawn prompts contain a persona name) are a separate P3 concern.
- **Tier 2 composite skills**: `plan-product` and `build-product` are skipped by shared content sync and have no spawn prompts of their own — no changes needed.
- **Single-agent utility skills**: `setup-project` and `wizard-guide` have no team spawns — no changes needed.
