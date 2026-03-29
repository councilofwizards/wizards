---
type: "user-stories"
feature: "plugin-organization"
status: "approved"
source_roadmap_item: "docs/roadmap/P2-08-plugin-organization.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Plugin Organization — Internal Taxonomy & Infrastructure (P2-08)

## Epic Summary

Add machine-readable taxonomy metadata to all skills, write ADR-005 documenting split readiness criteria, parameterize
the shared content infrastructure to remove hard-coded paths, and add progressive disclosure to wizard-guide. These
changes create an internal organization system that scales to 27+ skills and enables a clean domain split when business
skills reach critical mass (7-10), without imposing any split cost today.

## Stories

---

### Story 1: Category Metadata + Skill Discovery Tags in Frontmatter

- **As a** skill author or plugin maintainer
- **I want** every SKILL.md to have `category` and `tags` fields in its YAML frontmatter
- **So that** skills are classified by a machine-readable taxonomy that tooling (wizard-guide, validators, future
  install filters) can consume
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given any of the 17 SKILL.md files in `plugins/conclave/skills/*/SKILL.md`, when its frontmatter is inspected, then
     it contains a `category` field with one of: `engineering`, `business`, `utility`, `planning`
  2. Given any of the 17 SKILL.md files, when its frontmatter is inspected, then it contains a `tags` field that is a
     YAML array of lowercase-kebab strings (e.g., `tags: [planning, research, market-analysis]`)
  3. Given the `plugins/conclave/.claude-plugin/plugin.json` manifest, when inspected, then each skill entry includes a
     `category` field matching its SKILL.md `category` value
  4. Given the A1 (frontmatter) validator at `scripts/validators/skill-structure.sh`, when updated to recognize
     `category` and `tags` as valid fields, then it does not flag them as unknown; `category` is required, `tags` is
     optional
  5. Given `bash scripts/validate.sh`, when run after all frontmatter additions, then all 12/12 validators pass
  6. Given the category assignments, when reviewed against the classification table in CLAUDE.md, then they are
     consistent with and refine the existing classification, splitting the "Non-engineering" classification into
     `business` and `planning` categories: engineering skills get `engineering`, business skills get `business`,
     setup-project and wizard-guide get `utility`, research-market/ideate-product/manage-roadmap/write-stories get
     `planning`
  7. Given CLAUDE.md's Skill Classification table, when this story is complete, then the table is updated to show the
     4-category taxonomy (`engineering`, `business`, `planning`, `utility`) alongside the existing shared-content
     classification (engineering vs. non-engineering for sync/validator purposes)

- **Edge Cases**:
  - SKILL.md with `category` not in the allowed set: A1 validator flags as invalid
  - SKILL.md with `tags: []` (empty array): valid — tags are optional content
  - SKILL.md with no `tags` field at all: valid — field is optional
  - tier1-test (PoC skill): assigned `category: utility` — it's a test fixture, not a user-facing skill

- **Notes**: The `planning` category covers skills that serve both engineering pipelines and standalone use
  (research-market, ideate-product, manage-roadmap, write-stories). This resolves the boundary problem identified in
  research — these skills aren't purely engineering or business.

---

### Story 2: Split Readiness ADR (ADR-005) + Automated Gate

- **As a** future maintainer deciding whether to split the conclave plugin
- **I want** an ADR documenting the split decision framework and an automated validator that alerts when the threshold
  is crossed
- **So that** the team doesn't re-research the split question from scratch, and the trigger conditions are enforced by
  CI
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `docs/architecture/ADR-005-split-readiness.md`, when written, then it follows the existing ADR template at
     `docs/architecture/_template.md` and documents: the research conclusion (split premature at 3 business skills), the
     threshold (7-10 business skills), the prerequisites (parameterized infra + persona extraction), and the trigger
     conditions
  2. Given ADR-005, when its Decision section is inspected, then it states: "Keep single plugin. Revisit when
     business-category skills reach 7 AND parameterized shared content infra is complete AND shared persona extraction
     is complete."
  3. Given ADR-005, when its Consequences section is inspected, then it lists: what happens if the threshold is reached
     (split investigation triggered), what happens if prerequisites aren't met (block split until they are), and what
     deferred items become active (Idea 5 — persona extraction)
  4. Given a new bash validator or addition to an existing validator, when `plugins/conclave/skills/*/SKILL.md` files
     are scanned and 7+ have `category: business` in their YAML frontmatter, then the validator emits a WARN: "Business
     skill count (N) has reached split readiness threshold. Review ADR-005." (Note: this counts implemented skills, not
     roadmap items — there are already 12+ business roadmap items but only 3 implemented business skills today)
  5. Given `bash scripts/validate.sh`, when run, then all validators pass (the new check emits WARN, not FAIL)
  6. Given the previous ADR numbering, when ADR-005 is created, then P3-23 (Persona System ADR) uses ADR-006 — no
     numbering collision

- **Edge Cases**:
  - Business skill count exactly 7: WARN emitted (threshold is "7+", inclusive)
  - Business skill count drops below 7 (skill removed): WARN disappears — no stale alert
  - Validator run in a repo with no `docs/roadmap/`: validator skips the check gracefully

- **Notes**: The automated gate is a WARN, not a FAIL — it's an advisory signal, not a blocker. The decision to split
  remains human-driven. ADR-005 captures institutional knowledge from this planning session so future teams have full
  context.

---

### Story 3: Parameterized Shared Content Infrastructure

- **As a** plugin maintainer preparing for a future multi-plugin architecture
- **I want** the shared content sync script and B-series validator to accept configurable paths instead of hardcoded
  `SHARED_DIR`
- **So that** a future plugin split doesn't require rewriting the sync and validation infrastructure
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given `scripts/sync-shared-content.sh`, when the `SHARED_DIR` assignment is inspected, then it reads from an
     environment variable `CONCLAVE_SHARED_DIR` with a fallback to the current hardcoded default
     (`plugins/conclave/shared`)
  2. Given `scripts/validators/skill-shared-content.sh`, when the `SHARED_DIR` assignment is inspected, then it reads
     from the same `CONCLAVE_SHARED_DIR` environment variable with the same fallback
  3. Given `CONCLAVE_SHARED_DIR` is not set, when `bash scripts/sync-shared-content.sh` is run, then behavior is
     identical to current — the default path is used and all skills sync correctly
  4. Given `CONCLAVE_SHARED_DIR=/some/other/path`, when the sync script is run, then it reads shared content from that
     path instead of the default
  5. Given `bash scripts/validate.sh`, when run with default configuration (no env var set), then all 12/12 validators
     pass — zero behavioral change from current
  6. Given the 14 multi-agent SKILL.md files containing `<!-- Authoritative source: plugins/conclave/shared/... -->`
     comments, when updated, then the comments remain accurate for the default path (no change needed unless actually
     splitting)

- **Edge Cases**:
  - `CONCLAVE_SHARED_DIR` set to a non-existent path: sync script exits with a clear error message naming the path
  - `CONCLAVE_SHARED_DIR` set to an empty string: treated as unset, fallback to default
  - CI environment with custom `CONCLAVE_SHARED_DIR`: works correctly — enables future multi-plugin CI

- **Notes**: This is ~20 lines of bash. The key pattern: `SHARED_DIR="${CONCLAVE_SHARED_DIR:-plugins/conclave/shared}"`.
  The B3 authoritative source comments in SKILL.md files do NOT need to change — they document the canonical location,
  which remains `plugins/conclave/shared/` until an actual split occurs.

---

### Story 4: Progressive Disclosure in wizard-guide

- **As a** user discovering conclave skills for the first time
- **I want** wizard-guide to ask about my role and show me relevant skills first
- **So that** I'm not overwhelmed by 17+ skills when I only need a subset
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given a user invokes `/wizard-guide`, when the skill starts, then it presents a role selection prompt with three
     options: "Technical Founder" (sees all skills), "Engineering Team" (sees engineering + planning + utility skills),
     "Business / Operations" (sees business + utility skills)
  2. Given the user selects "Engineering Team", when the skill ecosystem overview is presented, then business skills
     (plan-sales, plan-hiring, draft-investor-update, and any future business skills) are omitted from the primary
     listing but available via "Show all skills"
  3. Given the user selects "Business / Operations", when the overview is presented, then engineering-specific skills
     (build-implementation, review-quality, etc.) are omitted from the primary listing but available via "Show all
     skills"
  4. Given the user selects "Technical Founder", when the overview is presented, then all skills are shown (current
     behavior)
  5. Given wizard-guide's SKILL.md at `plugins/conclave/skills/wizard-guide/SKILL.md`, when updated, then it reads the
     `category` field from SKILL.md frontmatter (Story 1) to determine which skills belong to which role view
  6. Given `bash scripts/validate.sh`, when run after the wizard-guide SKILL.md edit, then all 12/12 validators pass

- **Edge Cases**:
  - User doesn't answer the role prompt and just asks a question: wizard-guide defaults to "Technical Founder" (show
    all) and proceeds
  - New skill added without `category` field: wizard-guide shows it in all views (safe default)
  - wizard-guide invoked with arguments (e.g., "tell me about plan-sales"): role prompt skipped, direct answer provided
    regardless of hypothetical role filter

- **Notes**: Batch implementation with Story 1 to minimize wizard-guide SKILL.md merge conflicts. The role prompt is a
  UX convenience, not a security boundary — users can always see all skills.

---

## Non-Functional Requirements

- All changes must be backward-compatible — default behavior is unchanged when no env vars are set and no role is
  selected
- Validator changes must not introduce new FAIL states for existing valid configurations
- ADR-005 must be reviewable by someone with no prior context on the split decision

## Out of Scope

- Actual plugin splitting (deferred per research findings)
- Persona extraction (Idea 5 — deferred to P3, captured in ADR-005)
- Virtual namespacing (Idea 4 — redundant with category metadata)
- Changes to marketplace.json structure (not needed for internal taxonomy)
