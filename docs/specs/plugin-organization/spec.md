---
title: "Plugin Organization — Internal Taxonomy & Infrastructure Specification"
status: "approved"
priority: "P2"
category: "core-framework"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Plugin Organization — Internal Taxonomy & Infrastructure Specification

## Summary

Add machine-readable category and tag metadata to all 17 SKILL.md files, write ADR-005 codifying the split readiness
decision framework with an automated validator gate, parameterize the shared content infrastructure to remove hardcoded
paths, and add progressive disclosure to wizard-guide. These changes create an internal taxonomy that scales to 27+
skills and enables a clean domain split when business skills reach critical mass, without imposing any split cost today.

## Problem

The conclave plugin houses 17 skills in a single plugin with no machine-readable taxonomy. As the catalog grows toward
27+ skills at P3 completion, users will face discovery friction. Research confirms a domain split is premature (3
business skills, primary user segment uses both domains), but the shared content infrastructure hardcodes paths that
would make a future split expensive. The split decision and its prerequisites are undocumented institutional knowledge.

## Solution

### Sub-task 1: Category Metadata + Skill Discovery Tags

**SKILL.md frontmatter additions** — add to all 17 files:

```yaml
# New fields added after existing frontmatter
category: "engineering" # engineering | business | planning | utility
tags: ["implementation", "code-generation"] # optional, lowercase-kebab
```

**Category assignments:**

| Category      | Skills                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------ |
| `engineering` | write-spec, plan-implementation, build-implementation, review-quality, run-task, plan-product, build-product |
| `business`    | plan-sales, plan-hiring, draft-investor-update                                                               |
| `planning`    | research-market, ideate-product, manage-roadmap, write-stories                                               |
| `utility`     | setup-project, wizard-guide, tier1-test                                                                      |

The `planning` category resolves the boundary problem identified in research — these skills serve both engineering
pipelines and standalone use.

**plugin.json update** — add `category` field to each skill entry in `plugins/conclave/.claude-plugin/plugin.json`.

**A1 validator update** — add `category` to the list of recognized frontmatter fields in
`scripts/validators/skill-structure.sh`. `category` is required; `tags` is optional.

**CLAUDE.md update** — update the Skill Classification table to show the 4-category taxonomy alongside the existing
shared-content classification (engineering vs. non-engineering).

### Sub-task 2: Split Readiness ADR (ADR-005) + Automated Gate

**ADR-005** at `docs/architecture/ADR-005-split-readiness.md`:

- **Status**: Accepted
- **Context**: Research found split premature at 3 business skills. Shared content coupling (sync scripts, validators,
  personas) makes splitting expensive.
- **Decision**: Keep single plugin. Revisit when business-category skills reach 7 AND parameterized shared content infra
  is complete AND shared persona extraction is complete.
- **Consequences**: Internal taxonomy provides organization at scale. Automated gate prevents the threshold from being
  crossed silently. Deferred items (persona extraction) become active when trigger conditions are met.

**Automated validator gate** — add to an existing validator or create a new script:

```bash
# Count implemented business skills
biz_count=$(grep -rl 'category:.*business' plugins/conclave/skills/*/SKILL.md 2>/dev/null | wc -l)
if [ "$biz_count" -ge 7 ]; then
  echo "WARN: Business skill count ($biz_count) has reached split readiness threshold. Review ADR-005."
fi
```

This emits WARN, not FAIL. Advisory signal only.

### Sub-task 3: Parameterized Shared Content Infrastructure

**scripts/sync-shared-content.sh** — change:

```bash
# Before
SHARED_DIR="plugins/conclave/shared"

# After
SHARED_DIR="${CONCLAVE_SHARED_DIR:-plugins/conclave/shared}"
```

**scripts/validators/skill-shared-content.sh** — same change:

```bash
# Before
SHARED_DIR="plugins/conclave/shared"

# After
SHARED_DIR="${CONCLAVE_SHARED_DIR:-plugins/conclave/shared}"
```

Both scripts: add early validation that `SHARED_DIR` exists and is a directory. Exit with clear error if not.

No changes to SKILL.md `<!-- Authoritative source: ... -->` comments — they document the canonical location which
remains `plugins/conclave/shared/` until an actual split.

### Sub-task 4: Progressive Disclosure in wizard-guide

**plugins/conclave/skills/wizard-guide/SKILL.md** — add role selection prompt at the start of the skill's response
logic:

```
When the user invokes this skill, first ask:
"What best describes your role?"
1. **Technical Founder** — I wear both hats, show me everything
2. **Engineering Team** — I build software, show me engineering skills
3. **Business / Operations** — I run the business, show me business skills

Based on selection, filter the Skill Ecosystem Overview:
- Technical Founder: show all skills (current behavior)
- Engineering Team: show engineering + planning + utility skills
- Business / Operations: show business + utility skills

Always include "Ask me about any skill by name to see details" — no skill is hidden, just de-emphasized.
```

The filter reads `category` from SKILL.md frontmatter (Sub-task 1 dependency).

## Constraints

1. Default behavior is unchanged when no env vars are set and no role is selected
2. All 12/12 validators must pass after every sub-task
3. ADR-005 must be self-contained — reviewable by someone with no prior context
4. The automated gate emits WARN, never FAIL
5. Category assignments must be consistent with the shared-content classification (engineering vs. non-engineering) used
   by sync/validator scripts — `engineering` category maps to engineering classification; `business`, `planning`, and
   `utility` map to non-engineering classification

## Out of Scope

- Actual plugin splitting (deferred per research — revisit when ADR-005 trigger conditions are met)
- Persona extraction to shared layer (Idea 5 — deferred, captured in ADR-005 as trigger prerequisite)
- Virtual namespacing (Idea 4 — redundant with category metadata)
- Changes to marketplace.json structure
- Install-time filtering by category (no evidence of user demand)

## Files to Modify

| File                                            | Change                                                                            |
| ----------------------------------------------- | --------------------------------------------------------------------------------- |
| `plugins/conclave/skills/*/SKILL.md` (17 files) | Add `category` and `tags` frontmatter fields                                      |
| `plugins/conclave/.claude-plugin/plugin.json`   | Add `category` field to each skill entry                                          |
| `scripts/validators/skill-structure.sh`         | Recognize `category` (required) and `tags` (optional) as valid frontmatter fields |
| `scripts/validators/skill-shared-content.sh`    | Parameterize `SHARED_DIR` with env var fallback                                   |
| `scripts/sync-shared-content.sh`                | Parameterize `SHARED_DIR` with env var fallback                                   |
| `docs/architecture/ADR-005-split-readiness.md`  | New file — split readiness ADR                                                    |
| `plugins/conclave/skills/wizard-guide/SKILL.md` | Add role selection prompt and category-based filtering                            |
| `CLAUDE.md`                                     | Update Skill Classification table with 4-category taxonomy                        |
| `docs/roadmap/P3-23-persona-system-adr.md`      | Already updated: ADR-005 → ADR-006                                                |
| `docs/roadmap/_index.md`                        | Already updated: P2-08 title, effort, status; P3-23 ADR number                    |
| Validator script (new or existing)              | Add business skill count WARN gate                                                |

## Success Criteria

1. All 17 SKILL.md files have `category` field in frontmatter with correct assignment per the category table
2. `plugins/conclave/.claude-plugin/plugin.json` includes `category` for each skill
3. A1 validator recognizes `category` and `tags` without flagging them as unknown fields
4. ADR-005 exists at `docs/architecture/ADR-005-split-readiness.md` and follows the ADR template
5. `bash scripts/validate.sh` emits no WARN about business skill count (currently 3 < 7)
6. `CONCLAVE_SHARED_DIR` env var is respected by both sync script and B-series validator
7. Running `bash scripts/validate.sh` with default config (no env vars) produces identical results to pre-change
8. wizard-guide presents role-appropriate skill subsets when role is selected
9. All 12/12 validators pass
10. CLAUDE.md Skill Classification table reflects the 4-category taxonomy
