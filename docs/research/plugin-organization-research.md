---
type: "research-findings"
topic: "plugin-organization"
feature: "plugin-organization"
generated: "2026-03-27"
confidence: "high"
expires: "2026-04-26"
---

# Research Findings: Plugin Organization (P2-08)

## Executive Summary

The conclave plugin currently houses 17 skills in a single plugin. Research into
splitting options reveals that **the shared content architecture creates strong
cross-skill coupling** that makes domain-based splitting non-trivial and
high-risk. At current scale (3 business skills, 14 engineering/utility), a split
is premature — the primary user segment (technical founders using both domains)
would experience increased friction with no corresponding benefit. **Internal
reorganization via category metadata** is the dominant strategy: low cost, zero
infrastructure risk, and it creates the taxonomy needed for a clean split when
business skills reach critical mass (7-10 skills, projected at P3 completion).

## Market Analysis

### Market Size

Not applicable — this is an internal architecture decision for the conclave
plugin. The "market" is the plugin's user base within the Claude Code ecosystem.

### Industry Trends

- **Plugin ecosystem maturity** (confidence: MEDIUM): Claude Code plugins are
  nascent. The marketplace already supports multi-plugin installs (conclave +
  php-tomes coexist). Adding plugins is structurally trivial (3 lines in
  marketplace.json).
- **Monorepo vs. multi-package**: Industry trend favors monorepo with internal
  boundaries over premature package splits. Category metadata follows this
  pattern.

## Competitive Landscape

- **php-tomes**: 10 skills in a single plugin, organized by topic (laravel,
  testing, security, etc.). No domain split despite covering distinct concerns.
  Validates single-plugin-with-taxonomy approach.
- **No other Claude Code plugins** with comparable multi-agent orchestration
  exist for comparison.

## Technical Analysis

### Current Architecture Coupling

Three infrastructure layers hardcode `plugins/conclave/shared/` paths:

| Layer              | File                                         | Coupling Point                                                        |
| ------------------ | -------------------------------------------- | --------------------------------------------------------------------- |
| Sync script        | `scripts/sync-shared-content.sh`             | `SHARED_DIR` variable                                                 |
| B-series validator | `scripts/validators/skill-shared-content.sh` | `SHARED_DIR` variable                                                 |
| SKILL.md files     | All 14 multi-agent skills                    | `<!-- Authoritative source: plugins/conclave/shared/... -->` comments |

All three break simultaneously if skills move to a new plugin directory.
B-series validators are conclave-specific; A, C, D, E, F series are already
multi-plugin safe.

### Persona Coupling

40+ shared persona files in `plugins/conclave/shared/personas/` serve both
engineering and business skills. Key cross-domain personas: research-director,
product-strategist, roadmap-analyst. A domain split requires either persona
duplication (drift risk) or a new shared abstraction layer.

### Option Analysis

| Option            | Description                                  | Effort | Risk                                        | Benefit                                   |
| ----------------- | -------------------------------------------- | ------ | ------------------------------------------- | ----------------------------------------- |
| 1. Domain split   | `conclave-engineering` + `conclave-business` | High   | High (shared content, personas, validators) | Selective install                         |
| 2. Pattern split  | By collaboration pattern                     | High   | High (same infra cost)                      | Low (patterns are implementation details) |
| 3. Internal reorg | Category metadata + taxonomy documentation   | Low    | Zero                                        | Clean taxonomy, enables future split      |

**Option 1 boundary problem**: Planning skills (research-market, ideate-product,
manage-roadmap, write-stories) serve engineering pipelines but aren't
engineering themselves. A naive engineering/business split orphans them.

## Customer Segments

### Segment 1: Engineering Teams (CTOs, tech leads, developers)

- Use 14 engineering + utility skills
- Would never touch business skills
- Pain today: LOW — 3 business skills are minimal noise

### Segment 2: Founders/Operators (non-technical)

- Use 3 business skills only
- Find engineering terminology (TDD, API contracts) confusing
- Pain today: LOW — wizard-guide already separates business from engineering

### Segment 3: Technical Founders (bridge users) — PRIMARY SEGMENT

- Use all 17 skills across both domains
- A split INCREASES friction for this segment
- Likely the dominant user type in the current ecosystem

### Pain Points (ranked by severity)

1. **MEDIUM (future)**: When P3 completes, 14+ business skills buried in a 27+
   skill list
2. **LOW (today)**: 3 business skills are barely noticeable noise
3. **LOW**: Version coupling forces joint version bumps
4. **NEGLIGIBLE**: wizard-guide already provides domain separation

## Data Sources

- `.claude-plugin/marketplace.json` — marketplace structure
- `plugins/conclave/.claude-plugin/plugin.json` — plugin manifest
- `plugins/conclave/skills/` — all 17 skill directories
- `plugins/conclave/shared/` — shared content (principles, protocol, personas)
- `scripts/sync-shared-content.sh` — sync infrastructure
- `scripts/validators/` — all 6 validators
- `docs/roadmap/_index.md` — P3 item inventory
- Existing business skill SKILL.md files (plan-sales, plan-hiring,
  draft-investor-update)
- Existing engineering skill SKILL.md files (build-implementation,
  review-quality)

## Data Gaps

- No usage telemetry (which skills are co-invoked, frequency)
- No user feedback on install granularity preferences
- P3 items not yet classified by final domain distribution
- Unknown whether plugin-level install granularity matters to users

## Confidence Assessment

| Section                       | Confidence | Rationale                                               |
| ----------------------------- | ---------- | ------------------------------------------------------- |
| Technical coupling analysis   | High       | Direct code inspection of all 3 infrastructure layers   |
| Option analysis               | High       | All options evaluated against concrete code paths       |
| Customer segments             | Medium     | Inferred from skill content analysis, no real user data |
| Timing recommendation         | Medium     | Depends on P3 execution pace and domain distribution    |
| Split threshold (7-10 skills) | Low        | No comparable ecosystem data; educated estimate         |
