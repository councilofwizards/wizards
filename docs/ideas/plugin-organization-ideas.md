---
type: "product-ideas"
topic: "plugin-organization"
generated: "2026-03-27"
source_research: "docs/research/plugin-organization-research.md"
---

# Product Ideas: Plugin Organization (P2-08)

## Ideas

### Idea 1: Category Metadata in Frontmatter + Manifest

- **Description**: Add `category` (engineering | business | utility | planning)
  and `domain` (core-framework | new-skills | business-skills |
  developer-experience | quality-reliability | documentation) fields to SKILL.md
  frontmatter and plugin.json manifest. Machine-readable taxonomy enables
  downstream tooling.
- **User Need**: Scales skill discovery as catalog grows toward 27+ skills at P3
  completion
- **Evidence**: Research confirms no existing taxonomy beyond directory
  structure (confidence: High)
- **Estimated Effort**: small (~17 frontmatter edits + plugin.json schema
  update)
- **Estimated Impact**: high (foundational prerequisite for all other
  organization ideas)
- **Confidence**: H
- **Priority Score**: 9
- **Recommendation**: PURSUE — batch with Idea 7

### Idea 2: Parameterized Shared Content Infrastructure

- **Description**: Refactor `SHARED_DIR` hardcodes in
  `scripts/sync-shared-content.sh` and
  `scripts/validators/skill-shared-content.sh` to accept env var or CLI
  argument. Removes the #1 technical blocker to any future plugin split in ~20
  lines of bash.
- **User Need**: Enables future multi-plugin architecture without breaking
  current single-plugin workflow
- **Evidence**: Research identified 3 layers of hardcoded paths as the core
  coupling problem (confidence: High)
- **Estimated Effort**: small (~20 lines of bash)
- **Estimated Impact**: high (removes primary technical blocker)
- **Confidence**: H
- **Priority Score**: 9
- **Recommendation**: PURSUE

### Idea 3: Progressive Disclosure in wizard-guide

- **Description**: Add role-gated opening prompt to wizard-guide (Technical
  Founder / Engineering Team / Founder-Operator) that routes users to curated
  skill subsets. Solves the "too many skills" UX problem without any structural
  changes.
- **User Need**: Founders/Operators segment finds engineering skill descriptions
  confusing and irrelevant
- **Evidence**: Customer research identified 3 distinct segments with different
  skill needs (confidence: Medium)
- **Estimated Effort**: small (single-agent SKILL.md edit)
- **Estimated Impact**: medium (improves UX for non-bridge users)
- **Confidence**: H
- **Priority Score**: 7
- **Recommendation**: PURSUE

### Idea 4: Virtual Namespacing via Skill IDs

- **Description**: Add `id: biz/plan-sales`, `id: eng/build-implementation`
  prefixes or tags to skill manifests.
- **User Need**: Explicit domain boundaries without filesystem changes
- **Evidence**: Research shows directory-based organization insufficient at
  scale
- **Estimated Effort**: small
- **Estimated Impact**: low (redundant with Idea 1 + Idea 7)
- **Confidence**: M
- **Priority Score**: 4
- **Recommendation**: DEFER — redundant with category metadata + tags

### Idea 5: Shared Persona Layer Extraction

- **Description**: Move cross-domain personas (research-director,
  product-strategist, roadmap-analyst, etc.) to `plugins/shared-personas/` or
  equivalent repo-root location. Removes the last hard coupling blocker that
  survives the infra refactor.
- **User Need**: Enables clean plugin split without persona duplication and
  drift
- **Evidence**: Research found 40+ persona files with cross-domain usage
  (confidence: High)
- **Estimated Effort**: medium (file moves + path updates across all SKILL.md
  spawn prompts)
- **Estimated Impact**: medium (only valuable when split is imminent)
- **Confidence**: M
- **Priority Score**: 5
- **Recommendation**: DEFER — right idea, wrong time. Make it a prerequisite in
  ADR-005

### Idea 6: Split Readiness ADR + Automated Gate

- **Description**: Write ADR-005 documenting the 7-10 business skill threshold
  and prerequisites for a domain split. Add a bash validator that emits WARN
  when threshold is crossed. Prevents re-researching this question at P3
  completion.
- **User Need**: Codifies institutional knowledge so future teams don't
  re-debate the split question
- **Evidence**: Research and ideation both converge on "premature now, necessary
  later" — the trigger conditions need to be documented
- **Estimated Effort**: small (half-day: ADR document + ~15 lines of bash)
- **Estimated Impact**: high (prevents costly re-analysis and premature
  decisions)
- **Confidence**: H
- **Priority Score**: 8
- **Recommendation**: PURSUE

### Idea 7: Skill Discovery Tags

- **Description**: Add `tags: []` array to SKILL.md frontmatter for multi-value
  use-case labels (e.g., `tags: [planning, research, market-analysis]`).
  wizard-guide surfaces skills by tag. Scales gracefully to 27+ skills.
- **User Need**: Users discovering skills by use case rather than by name
- **Evidence**: Current discovery is directory-list based; wizard-guide groups
  by category but doesn't support tag-based search
- **Estimated Effort**: small (frontmatter additions + wizard-guide update)
- **Estimated Impact**: medium (better discovery UX, especially at scale)
- **Confidence**: H
- **Priority Score**: 7
- **Recommendation**: PURSUE — batch with Idea 1

### Idea 8: Incremental Split Pilot (Business Skills Only)

- **Description**: Extract 3 existing business skills into a separate
  `conclave-business` plugin to discover real costs and surface unknown
  unknowns.
- **User Need**: Validate split assumptions before committing to full split at
  scale
- **Evidence**: Research shows bridge users (primary segment) lose from split; 3
  skills don't justify overhead
- **Estimated Effort**: large (infra changes, validator rewrites, shared content
  management)
- **Estimated Impact**: low (creates friction for primary user segment with no
  corresponding benefit)
- **Confidence**: L
- **Priority Score**: 2
- **Recommendation**: REJECT — premature. Revisit only when ADR-005 trigger
  conditions are met

## Evaluation Criteria Used

Ideas scored on: shared content impact, bridge user friction, future-proofing
value, reversibility, validator compliance, and effort-to-value ratio.
Evidence-backed assessments from research artifact used for all scores.

## Rejected Ideas

- **Idea 8 (Split Pilot)**: Research is unambiguous that 3 business skills don't
  justify split overhead for bridge users (primary segment). Even as a "learning
  spike," it creates real production friction with no user benefit.
- **Idea 4 (Virtual Namespacing)**: Functionally redundant with category
  metadata (Idea 1) + tags (Idea 7). Deferred rather than rejected — could be
  reconsidered if IDs prove more natural than categories.

## Implementation Sequence

Recommended dependency chain: Idea 1+7 (taxonomy) → Idea 6 (ADR gates) → Idea 2
(infra unblock) → Idea 5 (persona extraction, P3-gated) → actual split (when
ADR-005 triggers fire)
