# Project Conventions

## What This Is

A Claude Code plugin marketplace (`wizards`) containing the `conclave` plugin — **25 user-facing skills** (no longer
ships an internal PoC — `tier1-test` deleted in 4.0.0) that spawn coordinated AI agent teams for planning, building, and
reviewing SaaS features.

**Two major rounds of work documented:**

- April 2026 — Opus 4.7 realignment (3.0.0): `docs/architecture/conclave-realignment-opus-4-7.md`
- April 2026 — Council of Wizards flow evaluation (4.0.0): `docs/architecture/conclave-flow-evaluation-v1.md`

## Tech Stack

- Shell scripts (bash) for sync tooling
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
      # Granular skills (independently invocable)
      research-market/SKILL.md       # Market research (Hub-and-Spoke, Lead-as-Skeptic)
      ideate-product/SKILL.md        # Product ideation (Hub-and-Spoke, Lead-as-Skeptic)
      manage-roadmap/SKILL.md        # Roadmap management (Hub-and-Spoke, Lead-as-Skeptic)
      write-stories/SKILL.md         # User stories (Hub-and-Spoke, dedicated skeptic)
      write-spec/SKILL.md            # Technical specs (Hub-and-Spoke, dedicated skeptic)
      plan-implementation/SKILL.md   # Implementation planning (Hub-and-Spoke, dedicated skeptic)
      build-implementation/SKILL.md  # Code implementation (Hub-and-Spoke, dedicated skeptic)
      review-quality/SKILL.md        # Quality & ops (Hub-and-Spoke, dedicated skeptic)
      run-task/SKILL.md              # Ad-hoc tasks (Dynamic Hub-and-Spoke)
      refine-code/SKILL.md           # Code cleanup & refactoring (Hub-and-Spoke, dedicated skeptic)
      craft-laravel/SKILL.md         # Laravel engineering (Hub-and-Spoke, dedicated skeptic, fork-join)
      unearth-specification/SKILL.md # Code archaeology & spec extraction (Hub-and-Spoke, dedicated skeptic, fork-join)
      review-pr/SKILL.md             # PR code review (Hub-and-Spoke, fork-join, 9 parallel reviewers + skeptic)
      profile-competitor/SKILL.md    # Single-competitor deep-dive dossier (fork-join, 4 parallel researchers + skeptic)
      # Pipeline skills (multi-stage with own Agent Teams)
      plan-product/SKILL.md          # Planning pipeline: research → ideation → roadmap → stories → spec
      build-product/SKILL.md         # Implementation pipeline: planning → build → quality review
      # Utility / Single-Agent
      setup-project/SKILL.md         # Project bootstrap (Single-Agent)
      wizard-guide/SKILL.md          # Skill ecosystem guide (Single-Agent)
      # Business skills
      draft-investor-update/SKILL.md # Investor updates (Pipeline)
      plan-sales/SKILL.md            # Sales strategy (Collaborative Analysis)
      plan-hiring/SKILL.md           # Hiring plans (Structured Debate)
    shared/                          # Authoritative shared content (synced into team SKILL.md files)
      principles.md                  # Universal + Engineering Principles
      communication-protocol.md      # Communication Protocol block
      skeptic-protocol.md            # Skeptic verdicts (APPROVED|REJECTED|ESCALATE), escalation cap, verification spot-check
      orchestrator-preamble.md       # IMPORTANT do-not-delegate + Bootstrap Check + Threshold Check (4.0.0)
      argument-grammar.md            # Canonical argument-hint grammar + global flag table + subcommand vocabulary
      personas/                      # Persona files (lead, skeptic, domain-expert, evaluator, assessor — ~100 files)
      catalogs/                      # Framework pattern catalogs (e.g., laravel-patterns.md)
  scripts/
    sync-shared-content.sh           # Syncs shared/ content to all multi-agent SKILL.md files
  docs/
    roadmap/                         # Prioritized backlog (_index.md + per-item files)
    specs/                           # Feature specifications (per-feature dirs)
    progress/                        # Agent progress checkpoints and session summaries
    architecture/                    # ADRs and design docs
    stack-hints/                     # Framework-specific agent guidance (laravel.md)
    research/                        # Market research artifacts
    ideas/                           # Product ideation artifacts
    continues/                       # Per-feature pipeline-recovery briefs (4.0.0; was docs/CONTINUE.md)
    continues/_archive/              # Completed/abandoned recovery briefs
    templates/artifacts/             # Artifact schema templates (now includes technical-spec.md)
```

## Skill Architecture

| Category | Skills                                                                                                                                                                                                                                                                                            | Pattern                                                                     |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Granular | research-market, ideate-product, manage-roadmap, write-stories, write-spec, plan-implementation, build-implementation, review-quality, run-task, squash-bugs, create-conclave-team, harden-security, refine-code, craft-laravel, unearth-specification, review-pr, audit-slop, profile-competitor | Agent Teams (TeamCreate + Agent with team_name) with skeptic gates          |
| Pipeline | plan-product, build-product                                                                                                                                                                                                                                                                       | Agent Teams with multi-stage orchestration; artifact detection skips stages |
| Utility  | setup-project, wizard-guide                                                                                                                                                                                                                                                                       | Single-agent, no teams                                                      |
| Business | draft-investor-update, plan-sales, plan-hiring                                                                                                                                                                                                                                                    | Agent Teams (TeamCreate + Agent with team_name) with skeptic gates          |

### Pipeline Skills

Pipeline skills spawn their own Agent Teams directly and orchestrate agents through sequential stages:

- **plan-product**: 5 stages (research → ideation → roadmap → stories → spec), 9 agents + lead
- **build-product**: 3 stages (planning → build → quality review), 6 agents + lead

Both use frontmatter-based artifact detection to skip completed stages on re-invocation.

### Override Convention (variant files)

Per-skill persona variation uses **variant filenames** with double-dash suffix:

- Base: `plugins/conclave/shared/personas/strategist.md` — id: `strategist`
- Variants: `strategist--write-spec.md` (id: `strategist-write-spec`), `strategist--write-stories.md` (id:
  `strategist-write-stories`), etc.

Each variant is a complete persona file in its own right. The `id` field MUST be unique across all persona files (the
sync-script coverage check enforces this). When a SKILL.md needs a per-skill variant of a shared role, it Reads the
variant file directly in its Setup step.

**Critical Rules** marked `<!-- non-overridable -->` in any persona file are non-negotiable for that role and any
descendants.

### Persona File Schema

Persona files live in `plugins/conclave/shared/personas/`. Required frontmatter fields: `name`, `id`, `model`,
`archetype`. The `archetype` field is one of: `assessor`, `skeptic`, `domain-expert`, `lead`, `evaluator`. (The former
`team-lead` archetype was collapsed into `lead` — they were functionally identical.) `id` MUST be unique across the
persona directory.

### Artifact Contract System

Skills produce and consume typed artifacts with YAML frontmatter. Templates at `docs/templates/artifacts/`:

- `research-findings.md` — produced by research-market / plan-product, consumed by ideate-product
- `product-ideas.md` — produced by ideate-product / plan-product, consumed by manage-roadmap
- `roadmap-item.md` — produced by manage-roadmap / plan-product Stage 3, consumed by write-stories
- `user-stories.md` — produced by write-stories / plan-product, consumed by write-spec
- `implementation-plan.md` — produced by plan-implementation / build-product, consumed by build-implementation
- `sprint-contract.md` — produced by plan-implementation / build-product Stage 1, consumed by build-implementation +
  Quality Skeptic + QA Agent (referenced by path, not inlined)

**State vocabulary (standardized April 2026)**: every artifact uses `draft → reviewed → approved → consumed`. The
roadmap-item template extends with `live` and `retired` (post-deploy lifecycle states; user marks manually after deploy
/ removal — not automated). The sprint-contract uses its own vocabulary (`draft → negotiating → signed → superseded`) —
explicit divergence documented in the template comment. Every "Lead writes final artifact" step in a pipeline must end
with: set status to `approved`, set `approved_by` to the skeptic role, set `updated` to today, set `next_action` to the
canonical successor command, then re-read and verify the frontmatter matches the next stage's detection rule.

**Forward Baton (4.0.0)**: every artifact carries `next_action` — a canonical command pointing at the successor skill
(e.g., `research-findings.md` sets `next_action: "/conclave:ideate-product {topic}"`). Every Lead's final report ends
with the same command. Users do not need to consult `wizard-guide` to know what to run next; the artifact and the report
both say it.

## Skill Classification

Skills are classified as engineering or non-engineering for shared content injection. Engineering skills receive both
Universal Principles and Engineering Principles blocks. Non-engineering skills receive only the Universal Principles
block. Single-agent skills are skipped entirely.

| Classification         | Skills                                                                                                                                                                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Engineering            | craft-laravel, create-conclave-team, harden-security, squash-bugs, write-spec, plan-implementation, build-implementation, review-quality, run-task, plan-product, build-product, refine-code, unearth-specification, review-pr, audit-slop |
| Non-engineering        | research-market, ideate-product, manage-roadmap, write-stories, plan-sales, plan-hiring, draft-investor-update, profile-competitor                                                                                                         |
| Single-agent (skipped) | setup-project, wizard-guide                                                                                                                                                                                                                |

**Note (4.0.0):** `tier1-test` was deleted. Total skills: 25 user-facing.

**`write-stories`**: non-engineering — its agents produce story artifacts but do not write code. **`run-task`**:
engineering — generic agents may implement code; engineering is the safe default. **Unknown skills**: default to
engineering at sync time with a `WARN` log. Add to the list in `sync-shared-content.sh`.

### Category Taxonomy

Skills are also classified by domain category for discovery and taxonomy purposes:

| Category      | Skills                                                                                                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `engineering` | craft-laravel, create-conclave-team, harden-security, squash-bugs, write-spec, plan-implementation, build-implementation, review-quality, run-task, plan-product, build-product, refine-code, unearth-specification, review-pr, audit-slop |
| `planning`    | research-market, ideate-product, manage-roadmap, write-stories, profile-competitor                                                                                                                                                         |
| `business`    | plan-sales, plan-hiring, draft-investor-update                                                                                                                                                                                             |
| `utility`     | setup-project, wizard-guide                                                                                                                                                                                                                |

Category-to-classification mapping: `engineering` → engineering (both principle blocks); `planning`, `business`,
`utility` → non-engineering (universal principles only).

## Shared Content Architecture

- **Authoritative source**: `plugins/conclave/shared/` owns Shared Principles, Communication Protocol, Skeptic Protocol,
  Orchestrator Preamble (Bootstrap Check + Threshold Check), Argument Grammar.
- **Sync**: Run `bash scripts/sync-shared-content.sh` to push shared/ content to all multi-agent SKILL.md files. The
  script runs 4 coverage checks before sync (persona existence, deleted-skill detection, classification coverage,
  persona-id uniqueness) and aborts on any error.
- **Markers**:
  - `<!-- BEGIN/END SHARED: universal-principles -->` — all multi-agent skills
  - `<!-- BEGIN/END SHARED: engineering-principles -->` — engineering skills only
  - `<!-- BEGIN/END SHARED: communication-protocol -->` — all multi-agent skills
  - `<!-- BEGIN/END SHARED: orchestrator-preamble -->` — all multi-agent skills (4.0.0)
- **Per-skill variation**: Skeptic name in Communication Protocol differs per skill (substituted by sync script).
- **Exclusions**: Skills with `type: single-agent` are skipped by sync.
- **Reference-only files** (NOT injected into SKILL.md, but referenced by skills via path):
  - `skeptic-protocol.md` — read by skeptic personas; cited by every "iterate up to N rounds" line
  - `argument-grammar.md` — canonical argument-hint grammar; consulted by skill authors

## Key ADRs

- **ADR-001**: Roadmap file structure (one file per item, YAML frontmatter)
- **ADR-002**: Content deduplication strategy (SUPERSEDED by P2-07 shared/ extraction; current architecture centralizes
  in `plugins/conclave/shared/` and syncs via `sync-shared-content.sh`)
- **ADR-003**: Onboarding wizard single-agent pattern
- **ADR-004**: Two-tier skill architecture (SUPERSEDED — flattened to single tier 2026-03-10)
- **ADR-005**: Plugin split readiness gate. Note: the cited `scripts/validators/split-readiness.sh` was removed with the
  rest of the validators on 2026-04-05; ADR is informational only until rewritten.

**Note on validators (deleted 2026-04-05)**: do not reference `scripts/validate.sh` or `scripts/validators/` anywhere —
that infrastructure no longer exists. Drift detection now lives in `scripts/sync-shared-content.sh` (coverage checks:
persona-existence, classification-coverage, deleted-skill detection).

## Development Guidelines

- SKILL.md files are the product. Every edit to shared content must be made in `plugins/conclave/shared/` and synced via
  `bash scripts/sync-shared-content.sh`.
- Roadmap items use frontmatter with `status`, `priority`, `category`, `effort`, `impact`, `dependencies`.
- Specs follow `docs/specs/_template.md`. Progress files follow `docs/progress/_template.md`. ADRs follow
  `docs/architecture/_template.md`.
- Business skills are larger than engineering skills due to output templates and domain-specific formats. This is
  expected.
- The Skeptic role is non-negotiable in every multi-agent skill. Never remove or weaken it.

### SCAFFOLD Comments

SKILL.md files encode assumptions about model capabilities that may become stale as models improve. Document these
assumptions with inline HTML comments using this format:

```
<!-- SCAFFOLD: [what this scaffolding does] | ASSUMPTION: [model-capability assumption] | TEST REMOVAL: [condition for testing removal] -->
```

All three fields are required. A comment missing any field is considered malformed.

Examples:

- `<!-- SCAFFOLD: Max N skeptic rejections before escalation | ASSUMPTION: models below Opus require a hard cap to prevent infinite skeptic loops | TEST REMOVAL: when pipeline consistently converges in ≤2 rejections across 10+ sessions -->`
- `<!-- SCAFFOLD: Lead performs inline skeptic review for Stages 1-3 | ASSUMPTION: Sonnet-class model sufficient for early-stage review; dedicated Opus skeptic adds cost without quality gain | TEST REMOVAL: benchmark --full vs. default quality on the same pipeline topic -->`

**Placement rules**:

- Place directly above or on the same line as the construct it documents
- NEVER place inside spawn prompt code blocks (verbatim content injected into agent context) — agents may misinterpret
  the comment as an instruction
- SCAFFOLD comment content must NOT contain `##`-prefixed lines

SCAFFOLD comments are documentation for skill maintainers, not end-user-visible. Enforcement is by code review.

## Current Roadmap Status

- **P1**: All 4 items complete (bootstrap, write safety, state persistence, stack generalization)
- **P2**: 7/8 complete. P2-07 (shared content extraction) done. P2-08 (plugin organization) remaining.
- **P3**: 4/19 complete. 15 items not started across engineering, business, and documentation categories.
- P2-02 (Skill Composability) is parked, superseded by ADR-004 (now also superseded).
- **Architecture**: All skills use Agent Teams directly. **25 skill directories** (`tier1-test` deleted in 4.0.0).

## 4.0.0 Behavioral Changes (Council-driven)

The Council of Wizards review (April 2026) drove these behavioral changes. They affect how agents and orchestrators
behave at runtime and warrant a major version bump:

1. **`plan-product` default skeptic mode flipped.** Dedicated product-skeptic now gates ALL five stages by default. The
   former `--full` flag is replaced by `--lite-skeptic` (opt-out for cheap iteration). The Lead-as-Skeptic on Stages 1-3
   was the largest quality concession in the codebase; it is now closed by default.
2. **No `APPROVED_WITH_CAVEATS` verdict.** Skeptics issue APPROVED, REJECTED, or ESCALATE — three states only. The prior
   "approved with caveats" was a pressure-release valve that propagated weakness as noise downstream agents never
   blocked on. Stale-rejection now forces ESCALATE; the human decides.
3. **Test Validation Gate (Iron Law #14).** `build-implementation` now pauses after writing tests and surfaces a Test
   Strategy Summary to the user. Honors `--yes` for non-interactive contexts. Fires once per stage; not on
   `build-product` (mid-pipeline gate would be catastrophic per Sentinel correction).
4. **Threshold Check on every team skill.** Before spawning a team, every team skill outputs a 5-line Threshold Check
   showing resolved mode, checkpoints found, required input availability, and decision. Default action on user silence
   is **proceed**. The user can interrupt at any time. Honors `--confirm` (require pause) and `--yes` (non-interactive).
5. **Forward Baton.** Every artifact carries `next_action`; every Lead's final report ends with `Next: /conclave:...`.
6. **CONTINUE.md scoping.** Per-feature: `docs/continues/{feature-or-topic}.md`. Completed/abandoned briefs archive to
   `docs/continues/_archive/{date}-{feature}.md`. The single global `docs/CONTINUE.md` collided on concurrent work and
   was a power-user pain point.
7. **Run-id length: 4 → 8 hex chars.** Birthday-paradox collision risk on heavy-use projects; 8 chars = 4.3B
   possibilities.
8. **Interrogator generalized to `run-task`.** Iron Law #05 enforced for ad-hoc work, not just new-skill creation.
9. **`--refresh-after Nd` flag** on `research-market` and `ideate-product`. Cheap freshness check; rejects stale
   research from compounding into stale ideas.
10. **`/wizard-guide status` mode.** New global "what's running in this project" surface.
