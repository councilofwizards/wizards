---
type: "compact-reference"
feature: "investor-update"
source_roadmap: "docs/roadmap/P3-22-draft-investor-update.md"
compacted: "2026-04-05"
---

# Investor Update — Engineering Reference

## What Was Built

`/draft-investor-update` skill using the Pipeline pattern: Researcher gathers project data into a Research Dossier,
Drafter composes the update, dual-skeptic review (Accuracy + Narrative), then finalization.

## Entrypoints

- `plugins/conclave/skills/draft-investor-update/SKILL.md` — Pipeline business skill definition
- `docs/investor-updates/_user-data.md` — user-provided financial/team/asks data (created on first run if missing)

## Files Modified/Created

- `plugins/conclave/skills/draft-investor-update/SKILL.md` — **Created**: 4-stage Pipeline skill (Stage 1: Research,
  Stage 2: Draft, Stage 3: dual-skeptic Review, Stage 4: Finalize)
- `scripts/validators/skill-shared-content.sh` — **Modified**: added `accuracy-skeptic`/`Accuracy Skeptic` and
  `narrative-skeptic`/`Narrative Skeptic` to `normalize_skeptic_names()`

## Dependencies

- **Depends on**: `docs/architecture/investor-update-system-design.md`,
  `docs/architecture/business-skill-design-guidelines.md`
- **Depended on by**: P2-08 (Plugin Organization) — 1st business skill (1/2 prerequisite)

## Configuration

- Arguments: `(empty)` (infer current period), `status`, `<period>` (e.g., "2026-02"), `--light` (Sonnet for Researcher)
- User data: `docs/investor-updates/_user-data.md` (financial metrics, team update, asks)
- Output: `docs/investor-updates/{date}-investor-update.md`
- Drafter: uses Sonnet by default; escalates to Opus if revision cycles fail
- Missing user data sections get `[Requires user input]` placeholder (never silent omission)

## Validation

```bash
bash scripts/validate.sh
# B2: normalize_skeptic_names() must include accuracy-skeptic and narrative-skeptic
```
