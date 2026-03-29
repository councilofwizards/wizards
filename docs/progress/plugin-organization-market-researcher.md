---
skill: research-market
role: market-researcher
agent: Theron Blackwell
task: P2-08 Plugin Organization — Market Research
status: complete
checkpoints:
  - claimed: "2026-03-27T17:09:00Z"
  - research_started: "2026-03-27T17:10:00Z"
  - findings_ready: "2026-03-27T17:20:00Z"
  - findings_submitted: "2026-03-27T17:20:00Z"
---

# Plugin Organization — Market Research Findings

**Agent**: Theron Blackwell, Scout of the Outer Reaches **Task**: P2-08 Plugin Organization — research phase

---

## RESEARCH FINDINGS: P2-08 Plugin Organization

**Summary**: The conclave plugin's shared content architecture creates strong cross-skill coupling that makes splitting
into multiple plugins non-trivial. At 17 skills, the single-plugin model is manageable; splitting now is premature
without first knowing how many of the 15 remaining P3 items fall into each domain.

---

## Key Facts

### 1. Current Manifest Structure (Confidence: High)

- `marketplace.json` already registers **2 plugins**: `conclave` and `php-tomes`, both under `./plugins/`
- `plugin.json` is minimal: `{ name, description, version }` — no skill routing or classification
- Adding a third plugin is a 3-line addition to `marketplace.json` and a new `plugin.json` — no structural blocker
- Skills are discovered by directory convention: `plugins/{plugin}/skills/{name}/SKILL.md`

### 2. Skill Inventory — 17 skills total (Confidence: High)

| Category                                        | Skills                                                                                                       | Count |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ----- |
| Single-agent                                    | setup-project, wizard-guide, tier1-test                                                                      | 3     |
| Engineering (multi-agent)                       | write-spec, plan-implementation, build-implementation, review-quality, run-task, plan-product, build-product | 7     |
| Planning/Research (non-engineering multi-agent) | research-market, ideate-product, manage-roadmap, write-stories                                               | 4     |
| Business (multi-agent)                          | plan-sales, plan-hiring, draft-investor-update                                                               | 3     |

**Observation**: The "business" domain currently has only 3 skills. The "planning/research" group (4 skills) is
ambiguous — they serve engineering pipelines (plan-product feeds into build-product) but produce non-code artifacts.

### 3. Shared Content Dependencies — The Core Problem (Confidence: High)

The `plugins/conclave/shared/` directory contains:

- `principles.md` — universal + engineering principles (2 blocks)
- `communication-protocol.md` — skeptic communication protocol
- **40+ persona files** (market-researcher, backend-eng, spec-skeptic, etc.)

Three places hardcode the `plugins/conclave/shared/` path:

1. `scripts/sync-shared-content.sh`: `SHARED_DIR="$REPO_ROOT/plugins/conclave/shared"` (line ~30)
2. `scripts/validators/skill-shared-content.sh`: `SHARED_DIR="$REPO_ROOT/plugins/conclave/shared"` (line ~62)
3. **Every SKILL.md** contains B3 authoritative source comments like:
   `<!-- Authoritative source: plugins/conclave/shared/principles.md. Keep in sync across all skills. -->`

If skills move to a new plugin (e.g., `conclave-business`), all three layers break simultaneously.

### 4. Validator Architecture — Cross-Plugin Status (Confidence: High)

| Validator                          | Scope                                       | Cross-Plugin Safe?             |
| ---------------------------------- | ------------------------------------------- | ------------------------------ |
| A-series (skill-structure.sh)      | `find plugins/ -path "*/skills/*/SKILL.md"` | **YES** — already multi-plugin |
| B-series (skill-shared-content.sh) | Hardcoded `plugins/conclave/shared/`        | **NO** — conclave-specific     |
| C-series (roadmap-frontmatter.sh)  | `docs/roadmap/`                             | YES — project-level            |
| D-series (spec-frontmatter.sh)     | `docs/specs/`                               | YES — project-level            |
| E-series (progress-checkpoint.sh)  | `docs/progress/`                            | YES — project-level            |
| F-series (artifact-templates.sh)   | `docs/templates/artifacts/`                 | YES — project-level            |

**Only B-series requires modification for a plugin split.**

### 5. Sync Script — What Would Break (Confidence: High)

`sync-shared-content.sh` hardcodes:

- Source: `plugins/conclave/shared/` as the single authoritative location
- Hardcoded classification arrays: `ENGINEERING_SKILLS` and `NON_ENGINEERING_SKILLS` — must be updated for any new skill
  regardless of split
- Uses `find plugins/ -path "*/skills/*/SKILL.md"` to discover targets — **already multi-plugin capable for target
  discovery**

So: source reading is conclave-specific, target writing is already multi-plugin aware.

### 6. Persona Files — Shared Across Skill Types (Confidence: High)

40+ persona files in `shared/personas/`. Cross-skill persona usage:

- `market-researcher.md` is used by `research-market` (granular) and `plan-product` (pipeline engineering)
- `backend-eng.md`, `frontend-eng.md`, `dba.md`, `test-eng.md`, `qa-lead.md`, `tech-lead.md` — used by engineering
  skills
- `gtm-analyst.md`, `sales-lead.md`, `hiring-lead.md`, `drafter.md` — used by business skills
- `research-director.md`, `roadmap-analyst.md`, `product-strategist.md` — used by both domains

If split: shared personas must either be duplicated (drift risk) or extracted to a `conclave-shared` package (new
abstraction, install complexity).

### 7. Option Analysis (Confidence: Medium)

**Option 1: Split by domain (conclave-engineering / conclave-business)**

- **What breaks**: B-series validators, sync script, all B3 source comments in SKILL.md files, persona file references
- **Boundary problem**: research-market, ideate-product, manage-roadmap, write-stories are consumed by engineering
  pipelines (plan-product) but produce non-code artifacts — forced into one or the other creates incorrect
  categorization
- **Effort**: High (validators + sync script + 40+ SKILL.md source comments + shared/ reorganization)
- **Benefit**: Users can install only the business or engineering skill set

**Option 2: Split by collaboration pattern**

- **What breaks**: Same as Option 1
- **Boundary problem**: Collaboration pattern (hub-spoke, pipeline, debate, collaborative-analysis) is an implementation
  detail, not a user-facing concept. Would confuse users.
- **Effort**: High (same as Option 1)
- **Benefit**: Minimal — internal classification is already handled by `type:` frontmatter field

**Option 3: Keep single plugin, reorganize internal directory structure**

- **What breaks**: Nothing — validators already work, sync already works
- **How to implement**: Add skill category metadata to frontmatter (e.g.,
  `category: engineering|business|utility|planning`), or introduce skill subdirectories
- **Effort**: Low — frontmatter addition only; validators may need minor F-series extension
- **Benefit**: Clean taxonomy without infrastructure risk; P3 growth can be classified incrementally

### 8. P3 Roadmap Context (Confidence: Medium)

15 P3 items not started. CLAUDE.md describes them as "across engineering, business, and documentation categories." The
final split ratio is unknown. A premature domain split now risks needing re-split when P3 items land.

---

## Inferences

1. **The shared content architecture was designed for a single plugin** — it's clean and works well within that
   constraint. The B3 hardcoded paths in every SKILL.md are the deepest coupling point.

2. **php-tomes proves multi-plugin works** — the marketplace already handles two plugins. The pattern scales. But
   php-tomes has no shared content dependencies on conclave, which is the key difference.

3. **3 business skills is not enough to justify a plugin split** — the threshold for organizational overhead to pay off
   is likely 7-10 skills per domain. At 3, the friction of split maintenance exceeds the benefit.

4. **Option 3 (internal reorganization) is a reversible first step** — adding `category:` metadata to frontmatter
   creates a clean taxonomy now and enables an eventual split with lower migration cost later.

---

## Data Gaps

- No user behavior data: which skills are invoked together most often? (Would validate grouping by usage pattern)
- No information on whether marketplace supports skill namespacing or filtering by category — could make Option 3 more
  discoverable without a split
- P3 roadmap items not detailed enough to classify all 15 by domain
- No information on how Claude Code plugin installation works for end users — unknown if per-plugin install granularity
  is actually useful to users

---

## Summary Assessment

| Option                     | Infrastructure Risk | Effort | Benefit | Reversibility |
| -------------------------- | ------------------- | ------ | ------- | ------------- |
| 1. Domain split            | High                | High   | Medium  | Low           |
| 2. Pattern split           | High                | High   | Low     | Low           |
| 3. Internal reorganization | None                | Low    | Medium  | High          |

**Recommendation**: Option 3 is the dominant choice at current scale. Add `category:` metadata to frontmatter and
document taxonomy. Revisit domain split when either (a) P3 lands and business skills reach 7+, or (b) user feedback
shows install granularity is a pain point.
