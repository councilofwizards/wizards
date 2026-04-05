---
type: "compact-reference"
feature: "harness-improvements"
source_roadmap:
  "docs/roadmap/P3-26-configurable-iteration-limits.md, docs/roadmap/P3-27-complexity-adaptive-pipeline.md,
  docs/roadmap/P3-28-lead-skeptic-consistency.md, docs/roadmap/P3-29-evaluator-tuning.md,
  docs/roadmap/P3-30-checkpoint-configurability.md, docs/roadmap/P3-31-design-assumptions-docs.md"
compacted: "2026-04-05"
---

# Harness Improvements (P3-26 through P3-31) — Engineering Reference

## What Was Built

Six prompt-engineering improvements to 16 SKILL.md files and CLAUDE.md. No new validators, no new agents, no shared
content changes. All changes are markdown edits inside existing files.

## Entrypoints

- All 14 multi-agent SKILL.md files under `plugins/conclave/skills/`
- `plugins/conclave/skills/wizard-guide/SKILL.md` (Common Flags section)
- `CLAUDE.md` (SCAFFOLD Comments convention)
- `.claude/conclave/eval-examples/{skill-name}/` — user-writable calibration example directory (P3-29)
- `docs/progress/quality-log.md` — post-mortem quality ratings log (P3-29)

## Files Modified/Created

### P3-27 + P3-28 (Group A — plan-product + build-product only)

- `plugins/conclave/skills/plan-product/SKILL.md` — added `### Flag Parsing` + `### Complexity Classification` in
  Determine Mode; `### Complexity Routing` + `### Full Skeptic Mode (--full)` in Orchestration Flow; conditional skeptic
  gates in Stages 1-3; product-skeptic spawn definition updated for Stages 1-5
- `plugins/conclave/skills/build-product/SKILL.md` — added Flag Parsing + Complexity Classification in Determine Mode;
  Complexity Routing in Orchestration Flow (no `--full` flag)

### P3-26 (Group B — all 14 multi-agent skills + wizard-guide)

- All 14 multi-agent SKILL.md files — `### Flag Parsing` subsection added to `## Determine Mode`; deadlock rules updated
  from `3 times` → `N times (default 3, set via --max-iterations)`
- research-market, ideate-product, manage-roadmap — skeptic deadlock rule added to Failure Recovery (was missing)
- `plugins/conclave/skills/wizard-guide/SKILL.md` — `## Common Flags` section added (two tables: multi-agent flags +
  pipeline-only flags)

### P3-30 + P3-31 (Group D — all 14 multi-agent skills + CLAUDE.md)

- `CLAUDE.md` — `### SCAFFOLD Comments` subsection added to Development Guidelines
- All 14 multi-agent SKILL.md files — `### When to Checkpoint` replaced with conditional format (every-step /
  milestones-only / final-only); SCAFFOLD comments added above: Skeptic deadlock rules, When to Checkpoint heading, each
  skeptic/QA spawn definition
- `plugins/conclave/skills/plan-product/SKILL.md` — additional SCAFFOLD comment above Lead-as-Skeptic Stage 1-3 blocks

### P3-29 (Group C — 4 pipeline skills only)

- `plugins/conclave/skills/build-implementation/SKILL.md` — eval examples Setup step; post-mortem step in Pipeline
  Completion; `### Evaluator Calibration` in quality-skeptic spawn prompt
- `plugins/conclave/skills/plan-implementation/SKILL.md` — eval examples Setup step; plan-skeptic spawn prompt
  calibration instruction
- `plugins/conclave/skills/plan-product/SKILL.md` — post-mortem step; product-skeptic calibration instruction; eval
  examples injection when `--full`
- `plugins/conclave/skills/build-product/SKILL.md` — post-mortem step; quality-skeptic calibration instruction

## Dependencies

- **Depends on**: P1-02 (checkpoint protocol), P2-09 (complete), P2-11, P2-12, P2-13 (P3-29 only)
- **Depended on by**: Nothing directly depends on these — polish/configurability features

## Configuration

- `--max-iterations N` — skeptic rejection ceiling (default: 3), available in all 14 multi-agent skills
- `--complexity [simple|standard|complex]` — pipeline depth override, plan-product + build-product only
- `--full` — dedicated skeptics for plan-product Stages 1-3 (default: Lead-as-Skeptic)
- `--checkpoint-frequency [every-step|milestones-only|final-only]` — checkpoint cadence (default: every-step)
- `.claude/conclave/eval-examples/{skill-name}/` — user-writable calibration examples (P3-29)

## Validation

```bash
bash scripts/validate.sh

# Verify no hard-coded "3 times" remain in deadlock rules:
grep -r "rejects the same deliverable 3 times" plugins/conclave/skills/
grep -r "rejects the same tests 3 times" plugins/conclave/skills/
grep -r "Max 3 rejection cycles" plugins/conclave/skills/
# Expected: zero matches

# Verify SCAFFOLD comments are not inside code blocks (manual check)
```
