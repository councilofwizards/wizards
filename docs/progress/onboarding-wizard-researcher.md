---
feature: "onboarding-wizard"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action:
  "Research approved by Skeptic. All findings verified. Three clarifications
  noted."
updated: "2026-02-19T00:00:00Z"
---

## Progress Notes

- [00:00] Claimed task #1
- [00:01] Read all 3 existing SKILL.md files (plan-product, build-product,
  review-quality)
- [00:02] Read P3-02 roadmap item, roadmap index, spec template, architecture
  template
- [00:03] Read plugin.json, marketplace.json, README, plugin-marketplaces docs
- [00:04] Read stack-hints/laravel.md, business-skill-design-guidelines.md
- [00:05] Read CI validation scripts (validate.sh, skill-structure.sh)
- [00:06] Read P1-03 stack-generalization (dependency), P2-02
  skill-composability
- [00:07] Read content-deduplication spec for format reference
- [00:08] Verified no CLAUDE.md exists in repo
- [00:09] Compiled findings and sent to PO and Skeptic
- [00:10] Skeptic APPROVED findings. Three clarifications noted:
  1. Open question #2 resolved: should be "create-only" (not augment existing
     roadmap)
  2. Only ONE stack hint (laravel.md) currently exists -- skill must handle
     missing hints gracefully
  3. Template files sourcing question -- templates exist in repo but need
     bundling strategy for fresh projects

## Key Research Findings

### 1. Existing Skill Structure Requirements

The `skill-structure.sh` validator enforces that ALL files matching
`plugins/*/skills/*/SKILL.md` must have:

- YAML frontmatter with `name`, `description`, `argument-hint`
- Required sections: Setup, Write Safety, Checkpoint Protocol, Determine Mode,
  Lightweight Mode, Spawn the Team, Orchestration Flow, Failure Recovery, Shared
  Principles, Communication Protocol
- Spawn definitions with Name, Model, Subagent type fields
- Shared content markers (BEGIN/END SHARED for principles and
  communication-protocol)

This is a CRITICAL constraint: the setup-project skill is envisioned as a
single-agent utility, but the validator demands multi-agent scaffolding
sections.

### 2. What a New User Needs to Do (Current State)

From the README:

1. Set env vars: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, optionally
   `CLAUDE_CODE_SPAWN_BACKEND=tmux`
2. Install marketplace: `/plugin marketplace add councilofwizards/wizards`
3. Install plugin: `/plugin install conclave@wizards`
4. Understand the 3 skills and their arguments
5. Have the `docs/` directory structure ready (roadmap, specs, progress,
   architecture, stack-hints)
6. Have a roadmap `_index.md` with project categories
7. Optionally have stack hints for their tech stack

### 3. What setup-project Should Detect

- Tech stack (from package.json, composer.json, Gemfile, go.mod,
  requirements.txt, Cargo.toml, pom.xml)
- Existing docs/ directory (to not overwrite)
- Existing CLAUDE.md (to not overwrite)
- Existing roadmap items (to not duplicate)
- Project name and description (from manifest files or git remote)

### 4. Single-Agent vs Multi-Agent Assessment

Single-agent is correct. Rationale:

- No adversarial review needed -- this is scaffolding, not decision-making
- No parallel work streams -- steps are sequential
- No contracts to negotiate
- The Skeptic pattern adds overhead without value for deterministic file
  generation

### 5. Idempotency Requirements

- Must check for existing dirs before creating
- Must check for existing files before writing (never overwrite)
- Should offer to augment existing roadmap with missing categories
- Running twice should produce identical state (no duplicates, no overwrites)
- Should report what was created vs what was skipped

### 6. Dependencies

- P1-03 Stack Generalization (COMPLETE): The stack detection logic already
  exists in all 3 SKILL.md Setup sections. setup-project should reuse the same
  detection approach.
- No hard dependencies on incomplete items
- Soft relationship with P2-07 Universal Shared Principles (not started) -- if
  shared principles are extracted to a shared file, setup-project would need
  updating

### 7. Validator Conflict (Critical Finding)

The CI validator at `scripts/validators/skill-structure.sh` requires ALL
SKILL.md files to have multi-agent sections. A single-agent skill would fail
validation. Three options:

- A: Adapt the validator to exempt single-agent skills (e.g., based on a
  frontmatter flag)
- B: Include all required sections in setup-project SKILL.md but make them
  minimal/not-applicable stubs
- C: Place setup-project in a different plugin that doesn't have the same
  validation rules
