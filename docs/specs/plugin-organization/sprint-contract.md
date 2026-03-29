---
type: "sprint-contract"
feature: "plugin-organization"
status: "signed"
signed-by: ["implementation-coordinator", "quality-skeptic"]
created: "2026-03-27"
updated: "2026-03-27"
---

# Sprint Contract: Plugin Organization (P2-08)

## Acceptance Criteria

1. All 17 SKILL.md files have a `category` field in YAML frontmatter with value from: engineering, business, planning,
   utility — matching the category table in the spec | Pass/Fail: [ ]
2. All 17 SKILL.md files have a `tags` field in YAML frontmatter (array of lowercase-kebab strings) | Pass/Fail: [ ]
3. `plugins/conclave/.claude-plugin/plugin.json` is restructured to include a `skills` array where each entry has `name`
   and `category` fields for all 17 skills | Pass/Fail: [ ]
4. A1 validator (`scripts/validators/skill-structure.sh`) adds `category` to required frontmatter fields and validates
   its value is one of: engineering, business, planning, utility. Tags field is not validated (A1 already ignores
   unrecognized fields). | Pass/Fail: [ ]
5. ADR-005 exists at `docs/architecture/ADR-005-split-readiness.md`, follows the ADR template, and documents: threshold
   (7 business skills), prerequisites (parameterized infra + persona extraction), trigger conditions | Pass/Fail: [ ]
6. New validator `scripts/validators/split-readiness.sh` (G-series) counts skills with `category: business` in SKILL.md
   frontmatter and emits WARN (not FAIL) when count reaches 7+. Added to `scripts/validate.sh`. | Pass/Fail: [ ]
7. `CONCLAVE_SHARED_DIR` env var is respected by both `scripts/sync-shared-content.sh` and
   `scripts/validators/skill-shared-content.sh` with fallback to default path `plugins/conclave/shared` | Pass/Fail: [ ]
8. Setting `CONCLAVE_SHARED_DIR` to a non-existent path causes a clear error exit from both scripts. Empty string
   treated as unset (uses default). | Pass/Fail: [ ]
9. wizard-guide SKILL.md prompt instructions updated with role selection flow: Technical Founder (all skills),
   Engineering Team (engineering+planning+utility), Business/Operations (business+utility). This is a SKILL.md content
   change, not runtime code. | Pass/Fail: [ ]
10. `bash scripts/validate.sh` passes all validators after all changes (with default config, no env vars) | Pass/Fail: [
    ]
11. CLAUDE.md adds a second table showing the 4-category taxonomy (engineering, business, planning, utility) with skill
    assignments. Existing shared-content classification table (engineering vs. non-engineering) is preserved unchanged.
    | Pass/Fail: [ ]
12. Category assignments are consistent with shared-content classification: `engineering` category maps to engineering
    classification; `business`, `planning`, `utility` categories map to non-engineering classification. | Pass/Fail: [ ]
13. wizard-guide without role selection defaults to showing all skills (current behavior preserved). | Pass/Fail: [ ]

## Out of Scope

- Actual plugin splitting
- Persona extraction
- Virtual namespacing
- Changes to marketplace.json structure
- Install-time filtering by category

## Performance Targets

<!-- No performance targets defined for this feature. -->

## Signatures

- **Implementation Coordinator**: Implementation Coordinator (date: 2026-03-27)
- **Quality Skeptic**: Mira Flintridge (date: 2026-03-27)

## Amendment Log

<!-- No amendments. -->
