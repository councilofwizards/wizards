---
title: "Investor Update Skill (/draft-investor-update)"
status: complete
priority: P3
category: business-skills
completed: "2026-02-19"
---

# P3-22: Investor Update Skill

## Summary

Implemented `/draft-investor-update`, the first business skill in the conclave framework and the pathfinder for the
Pipeline consensus pattern and dual-skeptic review model. A Researcher gathers project data from all docs directories, a
Drafter composes the investor update, and dual skeptics (Accuracy Skeptic + Narrative Skeptic) validate accuracy and
narrative quality before finalization.

## What Was Built

- `plugins/conclave/skills/draft-investor-update/SKILL.md` — Pipeline business skill
- `scripts/validators/skill-shared-content.sh` — extended `normalize_skeptic_names()` with
  `accuracy-skeptic`/`Accuracy Skeptic` and `narrative-skeptic`/`Narrative Skeptic`
- Output artifact written to `docs/investor-updates/{date}-investor-update.md`
- User data template at `docs/investor-updates/_user-data.md` (created on first run if missing)
- Supports `--light` (Sonnet for Researcher), `status`, and `<period>` arguments
- Mandatory business quality sections: Assumptions & Limitations, Confidence Assessment, Falsification Triggers,
  External Validation

## Key Dependencies

- **Depends on**: `docs/architecture/investor-update-system-design.md`, `business-skill-design-guidelines.md`
- **Depended on by**: P2-08 (Plugin Organization) prerequisite — 1st business skill (1/2 required)
- **Introduced patterns**: Pipeline handoffs, dual-skeptic parallel review, Research Dossier artifact, evidence-traced
  claims, mandatory business quality sections
