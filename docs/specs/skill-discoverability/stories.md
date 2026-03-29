---
type: "user-stories"
feature: "P2-10 Skill Discoverability Improvements"
status: "approved"
source_roadmap_item: "docs/roadmap/P2-10-skill-discoverability.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P2-10 Skill Discoverability Improvements

## Epic Summary

Three production-quality business skills are invisible at the primary discovery point (`/wizard-guide`), and new users
completing `/setup-project` are never told `/wizard-guide` exists. This epic adds a business skills section, a
wizard-guide mention in setup-project's next steps, a narrative preamble, and a persona spotlight — four focused edits
to close the discoverability gap and set expectations for the fantasy-themed experience.

---

## Stories

### Story 1: Business Skills Section in wizard-guide

- **As a** new user exploring the conclave ecosystem via `/wizard-guide`
- **I want** to see `draft-investor-update`, `plan-sales`, and `plan-hiring` listed alongside engineering skills
- **So that** I can discover and invoke business skills without needing to already know they exist
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/wizard-guide` with no arguments, when the Skill Ecosystem Overview is rendered, then a "Business
     Skills" section appears listing all three business skills (`draft-investor-update`, `plan-sales`, `plan-hiring`)
     with one-line descriptions.
  2. Given the Business Skills section exists, when I read each entry, then the description accurately reflects what the
     skill does (investor updates, sales strategy, hiring plans).
  3. Given the Common Workflows section exists, when I scroll it, then at least one business workflow example appears
     (e.g., "Drafting an investor update: `/draft-investor-update`").
  4. Given the Skill Ecosystem Overview uses tier labels, when a developer reads the file, then tier labels are
     reconciled with the current single-tier architecture (ADR-004) — the "Tier 1/Tier 2" framing is replaced or removed
     so the listing is not factually misleading.
  5. Given I run `bash scripts/validate.sh` after the edit, then all 12 validators pass with no new failures.
- **Edge Cases**:
  - Future business skills added: the section heading and structure should accommodate additional entries without
    restructuring.
  - User invokes `/wizard-guide list`: business skills must appear in the reference table, not just the narrative
    overview.
  - User invokes `/wizard-guide recommend investor update`: the skill should recommend `draft-investor-update` — the
    description must contain enough signal to surface on a business-goal query.
- **Notes**: The current `wizard-guide` overview still labels skills as "Tier 1" and "Tier 2" — which is outdated per
  ADR-004. Implementer should fix tier labels in the same pass to avoid shipping internally inconsistent documentation.
  Business skills go in their own section (not folded into granular/pipeline groupings) to keep the category distinction
  clear.

---

### Story 2: wizard-guide Mention in setup-project Next Steps

- **As a** user who just ran `/setup-project` for the first time
- **I want** the Next Steps to recommend `/wizard-guide` before jumping straight to `/plan-product`
- **So that** I understand the full skill landscape before committing to a workflow
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I run `/setup-project` and it completes successfully, when Step 6 prints the "Next Steps" block, then the
     first or second bullet reads:
     `Run /wizard-guide to explore all available skills and find the right one for your task.`
  2. Given the `/wizard-guide` bullet is added, when the Next Steps list is read in order, then the `/wizard-guide`
     bullet appears _before_ the `/plan-product` recommendation (not after).
  3. Given I run `/setup-project --dry-run`, when the dry-run output is shown, then the Next Steps block in the dry-run
     summary also includes the `/wizard-guide` bullet in the correct position.
  4. Given I run `bash scripts/validate.sh` after the edit, then all 12 validators pass with no new failures.
- **Edge Cases**:
  - `--force` mode: Next Steps wording must be identical to normal mode — the bullet should not be conditional on any
    flag.
  - Future next-steps additions: the wizard-guide bullet should remain the first "where to go next" recommendation. New
    bullets for specific setup steps (e.g., editing CLAUDE.md) may precede it only if they are about completing setup,
    not starting product work.
- **Notes**: The SKILL.md embeds the Next Steps block as a literal string inside Step 6. The edit is a single-line
  insertion. No logic change is needed — this is content only.

---

### Story 3: Conclave Lore Preamble in wizard-guide

- **As a** user invoking `/wizard-guide` for the first time
- **I want** the response to open with a short narrative passage that establishes the world and the Conclave's purpose
- **So that** the fantasy framing feels intentional and coherent rather than appearing only at execution time when
  agents introduce themselves
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given I invoke `/wizard-guide` with no arguments, when the overview is rendered, then it begins with a narrative
     preamble of approximately 80–120 words before any skill listings.
  2. Given the preamble is rendered, when I read it, then it names "the Conclave", references the purpose of the agents
     (planning, building, reviewing), and sets a tone consistent with the fantasy-world framing used in agent personas.
  3. Given the preamble is rendered, when I count the words, then the preamble is no longer than 150 words — it sets the
     stage but does not delay getting to the skill listings.
  4. Given I invoke `/wizard-guide list`, when the concise reference table is rendered, then the lore preamble is
     omitted — list mode is terse by design and the preamble would be noise.
  5. Given I run `bash scripts/validate.sh` after the edit, then all 12 validators pass with no new failures.
- **Edge Cases**:
  - `/wizard-guide explain <skill>`: lore preamble should be omitted in explain mode — the user asked for a specific
    skill, not a world overview.
  - `/wizard-guide recommend <goal>`: preamble may be included briefly or omitted at the implementer's discretion; the
    recommendation itself must not be delayed by it.
  - Tone: the preamble must not be so "in-character" that it confuses new users about what the tool actually does. The
    narrative should be evocative but not cryptic — a user who skips it should lose flavor, not information.
- **Notes**: The lore preamble belongs in the `SKILL.md` as static content in the "Skill Ecosystem Overview" section (or
  as a new introductory section just above it). It is agent-rendered Markdown, not code — write it as you want it to
  read.

---

### Story 4: Persona Spotlight ("Meet the Council") in wizard-guide

- **As a** user about to invoke a skill for the first time
- **I want** a brief introduction to 4–5 key Conclave personas before I see skill listings
- **So that** I understand who I'm working with and what each persona is responsible for, which sets accurate
  expectations for agent behavior during execution
- **Priority**: should-have
- **Acceptance Criteria**:
  1. Given I invoke `/wizard-guide` with no arguments, when the overview is rendered, then a "Meet the Council" section
     appears introducing 4–5 personas, each with: fictional name, title, and a one-line personality or specialty
     description.
  2. Given the personas are listed, when I cross-reference them with agents defined in the multi-agent SKILL.md files,
     then each persona matches an agent role that actually appears at runtime (no invented personas).
  3. Given the persona list exists, when I count entries, then there are no fewer than 4 and no more than 5 personas —
     enough to be representative without being exhaustive.
  4. Given I invoke `/wizard-guide list`, when the reference table is rendered, then the persona spotlight is omitted
     (same rule as the lore preamble).
  5. Given I run `bash scripts/validate.sh` after the edit, then all 12 validators pass with no new failures.
- **Edge Cases**:
  - Persona identity drift: if agent names in SKILL.md files change in the future, the persona spotlight will go stale.
    The implementer should pick personas that are structurally stable (Lead, Skeptic, Builder, etc.) rather than
    skill-specific names.
  - Persona count: capping at 5 is a hard ceiling, not a suggestion. If the implementer is tempted to add a 6th, they
    should instead make one of the existing 5 entries richer.
  - User asks "who is Fenn Quillsong?": wizard-guide should be able to handle this via the `explain` or conversational
    path; the spotlight cards are an intro, not the full lore reference.
- **Notes**: Suitable candidates for the 4–5 spots include the Lead (orchestrator), the Skeptic (challenger), a
  Builder/Implementer role, a Planner/Architect role, and optionally a Researcher or Chronicler. Prefer roles that
  appear across multiple skills over roles that appear in only one.

---

### Story 5: Pushy Skill Descriptions for Reliable Triggering

- **As a** user working in a project that has the conclave plugin installed
- **I want** skill descriptions to enumerate concrete escalation signals that indicate when each skill should be invoked
- **So that** Claude can surface the right skill proactively when I describe a task, without me needing to know the
  skill name
- **Priority**: could-have
- **Acceptance Criteria**:
  1. Given a multi-agent skill with a one-line description, when the implementer reviews the description, then it
     includes at least one "trigger when" signal beyond the basic skill summary (e.g., "Trigger when adding a new
     feature, accepting a roadmap item for implementation, or picking up an approved spec").
  2. Given I describe a task using natural language (e.g., "I want to write stories for this roadmap item"), when Claude
     evaluates available skills, then the relevant skill's description contains enough signal to match the intent
     without relying on the user knowing the skill name.
  3. Given the updated descriptions are reviewed for length, when read in the marketplace catalog, then no single
     description exceeds 3 lines — pushy does not mean verbose.
  4. Given I run `bash scripts/validate.sh` after edits, then all 12 validators pass with no new failures.
- **Edge Cases**:
  - Over-triggering: descriptions that are too broad will cause Claude to suggest the skill for tasks it cannot handle.
    Each trigger signal should be specific enough to distinguish the skill from its neighbors.
  - Business skills: `draft-investor-update`, `plan-sales`, `plan-hiring` are the most likely to be missed; their
    descriptions should be updated first. Engineering skills are generally well-triggered already.
  - Marketplace catalog vs. SKILL.md: the `description` field in SKILL.md frontmatter is what Claude reads for
    triggering decisions. Ensure the frontmatter `description` (not just the body text) contains the trigger signals.
- **Notes**: "Pushy" here means proactively enumerating escalation conditions, not being verbose. A good pattern: "[what
  it does]. Use when [signal 1], [signal 2], or [signal 3]." This story is lower priority than Stories 1–4 because it's
  a quality-of-life improvement for returning users, while Stories 1–4 unblock first-time discovery.

---

## Non-Functional Requirements

- All changes are content-only (Markdown edits to SKILL.md files). No validator logic changes required.
- `bash scripts/validate.sh` must pass (12/12) after all changes.
- Shared content sync is not required — wizard-guide and setup-project are both `type: single-agent` and are excluded
  from B-series checks and `sync-shared-content.sh`.
- Lore preamble and persona spotlight must render correctly in both terminal Markdown and GitHub Markdown preview.

## Out of Scope

- Adding new skills to the plugin.
- Changing agent behavior or runtime persona names inside multi-agent skills.
- Automated skill suggestion / intent matching infrastructure (beyond description text improvements).
- Updating any file other than `plugins/conclave/skills/wizard-guide/SKILL.md` and
  `plugins/conclave/skills/setup-project/SKILL.md`.
