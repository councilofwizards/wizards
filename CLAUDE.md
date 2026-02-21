# Project Conventions

## What This Is

A Claude Code plugin marketplace (`wizards`) containing the `conclave` plugin — 18 skills organized in a two-tier architecture (ADR-004) that spawn coordinated AI agent teams for planning, building, and operating SaaS products.

## Tech Stack

- Shell scripts (bash) for validators and CI
- Markdown (SKILL.md files) for skill definitions — Claude Code reads these as static markdown
- YAML frontmatter for metadata in roadmap, spec, progress, and architecture files
- No application runtime — this is a plugin/tooling project, not a web app

## Project Structure

```
wizards/
  .claude-plugin/marketplace.json    # Marketplace catalog
  plugins/conclave/
    .claude-plugin/plugin.json       # Plugin manifest (v1.0.0)
    skills/
      # Tier 1: Granular skills (invoked directly or chained by Tier 2)
      research-market/SKILL.md       # Market research (Hub-and-Spoke, Lead-as-Skeptic)
      ideate-product/SKILL.md        # Product ideation (Hub-and-Spoke, Lead-as-Skeptic)
      manage-roadmap/SKILL.md        # Roadmap management (Hub-and-Spoke, Lead-as-Skeptic)
      write-stories/SKILL.md         # User stories (Hub-and-Spoke, dedicated skeptic)
      write-spec/SKILL.md            # Technical specs (Hub-and-Spoke, dedicated skeptic)
      plan-implementation/SKILL.md   # Implementation planning (Hub-and-Spoke, dedicated skeptic)
      build-implementation/SKILL.md  # Code implementation (Hub-and-Spoke, dedicated skeptic)
      review-quality/SKILL.md        # Quality & ops (Hub-and-Spoke, dedicated skeptic)
      run-task/SKILL.md              # Ad-hoc tasks (Dynamic Hub-and-Spoke)
      # Tier 2: Composite skills (chain Tier 1 via Skill tool)
      plan-product/SKILL.md          # Planning pipeline (chains 5 Tier 1 skills)
      build-product/SKILL.md         # Implementation pipeline (chains 3 Tier 1 skills)
      # Utility / Single-Agent
      setup-project/SKILL.md         # Project bootstrap (Single-Agent)
      wizard-guide/SKILL.md          # Skill ecosystem guide (Single-Agent)
      # Business skills (unchanged)
      draft-investor-update/SKILL.md # Investor updates (Pipeline)
      plan-sales/SKILL.md            # Sales strategy (Collaborative Analysis)
      plan-hiring/SKILL.md           # Hiring plans (Structured Debate)
      # PoC / Test
      tier1-test/SKILL.md            # Phase 0 PoC Tier 1 test skill
      tier2-test/SKILL.md            # Phase 0 PoC Tier 2 test skill
    shared/                          # Authoritative shared content
      principles.md                  # Shared Principles block
      communication-protocol.md      # Communication Protocol block
  scripts/
    validate.sh                      # Runs all validators
    sync-shared-content.sh           # Syncs shared/ content to all multi-agent SKILL.md files
    validators/
      skill-structure.sh             # A1-A4: frontmatter, sections, spawn defs, markers
      skill-shared-content.sh        # B1-B3: principles drift, protocol drift, authoritative source
      roadmap-frontmatter.sh         # C1-C2: roadmap file conventions
      spec-frontmatter.sh            # D1: spec file conventions
      progress-checkpoint.sh         # E1: checkpoint file conventions
      artifact-templates.sh          # F1: artifact template existence and frontmatter
  docs/
    roadmap/                         # Prioritized backlog (_index.md + per-item files)
    specs/                           # Feature specifications (per-feature dirs)
    progress/                        # Agent progress checkpoints and session summaries
    architecture/                    # ADRs and design docs
    stack-hints/                     # Framework-specific agent guidance (laravel.md)
    research/                        # Market research artifacts
    ideas/                           # Product ideation artifacts
    templates/artifacts/             # Artifact schema templates for skill pipelines
```

## Two-Tier Architecture

| Tier | Skills | Pattern |
|------|--------|---------|
| Tier 1 (granular) | research-market, ideate-product, manage-roadmap, write-stories, write-spec, plan-implementation, build-implementation, review-quality, run-task | Hub-and-Spoke with own teams and skeptic gates |
| Tier 2 (composite) | plan-product, build-product | Chain Tier 1 skills via Skill tool; artifact detection skips completed stages |
| Utility | setup-project, wizard-guide | Single-agent, no teams |
| Business | draft-investor-update, plan-sales, plan-hiring | Unchanged from pre-migration |

### Tier 2 Composite Pipelines

- **plan-product**: research-market → ideate-product → manage-roadmap → write-stories → write-spec
- **build-product**: plan-implementation → build-implementation → review-quality

### Artifact Contract System

Tier 1 skills produce and consume typed artifacts with YAML frontmatter. Templates at `docs/templates/artifacts/`:
- `research-findings.md` — produced by research-market, consumed by ideate-product
- `product-ideas.md` — produced by ideate-product, consumed by manage-roadmap
- `user-stories.md` — produced by write-stories, consumed by write-spec
- `implementation-plan.md` — produced by plan-implementation, consumed by build-implementation

## Shared Content Architecture

- **Authoritative source**: `plugins/conclave/shared/` owns Shared Principles and Communication Protocol
- **Sync**: Run `bash scripts/sync-shared-content.sh` to push shared/ content to all multi-agent SKILL.md files
- **Markers**: `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->` (and `communication-protocol`)
- **Drift detection**: `scripts/validators/skill-shared-content.sh` (B1-B3 checks)
- **Per-skill variation**: Skeptic name in Communication Protocol differs per skill (13 name pairs in normalizer)
- **Exclusions**: Skills with `type: single-agent` or `tier: 2` are skipped by shared content checks and sync

## Validation

Run all validators:
```bash
bash scripts/validate.sh
```

Check categories:
- **A-series** (skill-structure.sh): YAML frontmatter (incl. optional tier/chains), required sections (3 paths: single-agent, tier-2 composite, multi-agent), spawn definitions, shared content markers
- **B-series** (skill-shared-content.sh): Shared principles/protocol drift, authoritative source verification (reads from shared/)
- **C-series** (roadmap-frontmatter.sh): Roadmap file frontmatter and filename conventions
- **D-series** (spec-frontmatter.sh): Spec file frontmatter
- **E-series** (progress-checkpoint.sh): Checkpoint file frontmatter
- **F-series** (artifact-templates.sh): Artifact template existence and correct type fields

## Key ADRs

- **ADR-001**: Roadmap file structure (one file per item, YAML frontmatter)
- **ADR-002**: Content deduplication strategy (validated duplication with HTML markers)
- **ADR-003**: Onboarding wizard single-agent pattern
- **ADR-004**: Two-tier skill architecture (Tier 1 granular, Tier 2 composite)

## Development Guidelines

- SKILL.md files are the product. Every edit to shared content must be made in `plugins/conclave/shared/` and synced via `bash scripts/sync-shared-content.sh`.
- Run `bash scripts/validate.sh` before committing. All checks must pass.
- Roadmap items use frontmatter with `status`, `priority`, `category`, `effort`, `impact`, `dependencies`.
- Specs follow `docs/specs/_template.md`. Progress files follow `docs/progress/_template.md`. ADRs follow `docs/architecture/_template.md`.
- Business skills are larger than engineering skills due to output templates and domain-specific formats. This is expected.
- The Skeptic role is non-negotiable in every multi-agent skill. Never remove or weaken it.

## Current Roadmap Status

- **P1**: All 4 items complete (bootstrap, write safety, state persistence, stack generalization)
- **P2**: 7/8 complete. P2-07 (shared content extraction) done. P2-08 (plugin organization) remaining.
- **P3**: 4/19 complete. 15 items not started across engineering, business, and documentation categories.
- P2-02 (Skill Composability) is parked, superseded by ADR-004 two-tier architecture.
- **Two-tier migration**: ALL 6 PHASES COMPLETE (0-5). 18 skills, 12/12 validators pass.
