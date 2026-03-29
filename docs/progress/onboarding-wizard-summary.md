---
feature: "onboarding-wizard"
status: "complete"
completed: "2026-02-19"
---

# P3-02: Onboarding Wizard Skill -- Progress

## Summary

Implemented the `/setup-project` single-agent skill that bootstraps projects for the conclave plugin. The skill detects
tech stacks, scaffolds `docs/` directory structure, generates `CLAUDE.md` and roadmap index, and guides users to their
next steps. Also adapted the CI validators to support single-agent skills — a new category in the framework.

## Changes

### Validator Adaptation

Modified two CI validators to support `type: single-agent` SKILL.md files:

- **skill-structure.sh**: Single-agent skills only require `## Setup` and `## Determine Mode` sections. Multi-agent
  sections (Spawn the Team, Orchestration Flow, etc.) are skipped. A1 frontmatter checks still apply.
- **skill-shared-content.sh**: Single-agent skills are excluded from B1/B2/B3 shared content drift comparisons since
  they don't contain shared principles or communication protocol blocks.

### New Skill

Created `plugins/conclave/skills/setup-project/SKILL.md` — the first single-agent skill in the framework. Implements a
6-step sequential pipeline:

1. Detect existing state (file-existence checks for idempotency)
2. Detect tech stack (10+ manifest types, framework-level detection)
3. Scaffold docs/ directory structure (5 dirs, .gitkeep, 3 templates, stack hints)
4. Generate CLAUDE.md (suggest-only if exists, never silent overwrite)
5. Generate docs/roadmap/\_index.md (project-type category tailoring)
6. Print summary and next steps

Supports `--force` (overwrite scaffolding, still prompts for CLAUDE.md) and `--dry-run` (output only, no writes).

## Files Modified

- `scripts/validators/skill-structure.sh` -- Added `type: single-agent` frontmatter support to skip multi-agent section
  checks
- `scripts/validators/skill-shared-content.sh` -- Excluded single-agent skills from shared content drift comparisons

## Files Created

- `plugins/conclave/skills/setup-project/SKILL.md` -- New single-agent setup utility skill

## Verification

- Quality Skeptic pre-implementation gate: APPROVED (plan covers all 10 success criteria)
- Quality Skeptic post-implementation gate: APPROVED (all criteria met, validators pass, templates byte-identical)
- Full CI validation: 11 passed, 0 failed (4 SKILL.md files checked)
- All 10 success criteria verified against implementation
- Embedded templates confirmed byte-identical to source files
