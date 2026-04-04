---
title: "CONTINUE.md Disaster Recovery Protocol"
status: "approved"
priority: "P2"
category: "quality-reliability"
approved_by: "product-skeptic-b7e2 (Wren Cinderglass)"
created: "2026-04-03"
updated: "2026-04-04"
---

# CONTINUE.md Disaster Recovery Protocol — Technical Specification

## Summary

Pipeline skills (plan-product, build-product) continuously update a `docs/CONTINUE.md` file during execution. The file
is a human-readable, fixed-schema recovery brief that aggregates pipeline state into a single document. When a chat
session crashes, a fresh session reads CONTINUE.md to determine the exact resume command, which stages completed, which
agents were mid-task, and the specific action to take for recovery. CONTINUE.md is advisory — agent checkpoint files and
artifact frontmatter remain ground truth.

## Problem

A session crash during a multi-stage, multi-agent pipeline run (up to 5 stages, 9+ agents) loses all orchestration
context. Per-agent checkpoint files exist but are scattered across `docs/progress/` with no aggregated view. The human
operator must manually reconstruct pipeline state from multiple files to resume — error-prone and stressful. Seven
specific pain points identified:

| Code | Severity | Description                                                                      |
| ---- | -------- | -------------------------------------------------------------------------------- |
| P1   | CRITICAL | No exact resume command — operator must guess the invocation                     |
| P2   | HIGH     | Original invocation flags not recorded — resumed session gets different behavior |
| P3   | HIGH     | Parallel agent status ambiguous — unclear which agents completed vs. crashed     |
| P4   | HIGH     | Checkpoint filenames not surfaced — operator must know naming conventions        |
| P5   | MEDIUM   | Mid-skeptic-review crash — resume must route draft to skeptic, not re-run writer |
| P6   | MEDIUM   | CONTINUE.md update frequency undefined — file goes stale                         |
| P7   | LOW      | No artifact integrity signal — draft artifacts mistaken for complete ones        |

## Solution

Three complementary design ideas combined into a single deliverable:

### 1. Mission Brief (Idea 1) — Fixed-Schema CONTINUE.md

YAML frontmatter with 9 mandatory fields. Four-to-six markdown sections in fixed order. Team Lead updates after each
stage gate. Addresses P1 (exact resume command in fenced code block), P2 (flags recorded verbatim), P6 (update frequency
mandated).

**Frontmatter Schema** (all fields mandatory):

| Field         | Type     | Mutable | Description                                          |
| ------------- | -------- | ------- | ---------------------------------------------------- |
| `skill`       | string   | No      | `plan-product` or `build-product`                    |
| `topic`       | string   | No      | Invocation topic, verbatim                           |
| `run_id`      | string   | No      | Unique session identifier (e.g., `b7e2`)             |
| `team`        | string   | No      | Team name with run_id suffix                         |
| `stage`       | integer  | Yes     | Current active stage (0 at init, N during execution) |
| `status`      | enum     | Yes     | `in_progress` or `complete`                          |
| `flags`       | string   | No      | Verbatim flags or `"(none — all defaults)"`          |
| `heartbeat`   | ISO-8601 | Yes     | Updated on every write                               |
| `last_action` | string   | Yes     | One-sentence description of last action              |

**Mandatory Sections** (fixed order):

1. What We're Building — static mission description
2. Current State — dynamic summary (stage, status, team, invocation)
3. Recovery Instructions — self-sufficient steps with copy-pasteable resume command
4. Stage Map — saga-pattern stage tracking (see below)
5. Checkpoint Index — materialized view of agent progress files (see below)
6. Team Roster — optional, for human readability

### 2. Materialized Checkpoint View (Idea 5) — Checkpoint Index

CONTINUE.md always lists every agent's checkpoint file path with their exact frontmatter `status` value. One row per
agent in the entire pipeline. Addresses P3 (parallel agent status explicit) and P4 (exact file paths surfaced).

| Column | Description                                                                                                                              |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Agent  | Role name (e.g., `market-researcher`)                                                                                                    |
| File   | Exact relative path, backtick-wrapped                                                                                                    |
| Status | Value from progress file frontmatter: `complete`, `awaiting_review`, `in_progress`, `not yet created`, `missing — inspect file manually` |

### 3. Saga Stage Map (Idea 4) — Idempotent Recovery Gates

Stage Map table with three statuses and compensating actions per stage. Extends existing FOUND/NOT_FOUND artifact
detection with PARTIAL semantics. Addresses P5 (mid-skeptic crash anchor) and P7 (draft artifact detection).

| Column              | Description                          |
| ------------------- | ------------------------------------ |
| Stage               | Number and name: `1 (Research)`      |
| Status              | `COMPLETE`, `PARTIAL`, or `PENDING`  |
| Artifact Path       | Exact relative path or empty         |
| Compensating Action | Self-sufficient recovery instruction |

**Status transitions**: PENDING → PARTIAL (stage-begin) → COMPLETE (gate-close). COMPLETE is terminal.

**Compensating action templates** (fixed patterns):

- COMPLETE: `Skip — artifact verified at [path]`
- PENDING (unblocked): `Run Stage N from scratch`
- PENDING (blocked): `Blocked on Stage N — run after Stage N completes`
- PARTIAL (all agents done, gate not closed): `All agents complete — verify outputs and close gate manually`
- PARTIAL (writer done, skeptic crashed):
  `{writer} draft at awaiting_review — spawn {skeptic} with {path}; do not re-run {writer}`
- PARTIAL (writer revising after rejection): `Re-spawn {writer} with feedback from {skeptic} progress file`
- PARTIAL (no completions): `Re-spawn Stage N agents from scratch`
- PARTIAL (mixed states):
  `Check Checkpoint Index: re-spawn in_progress agents with checkpoints; route awaiting_review to skeptic`

### Update Protocol

| #   | Trigger           | Stage Map Change                           | Frontmatter Changes                                                |
| --- | ----------------- | ------------------------------------------ | ------------------------------------------------------------------ |
| 1   | Session init      | FOUND artifacts → COMPLETE; rest → PENDING | All fields set. `stage: 0` (fresh) or first non-COMPLETE (resumed) |
| 2   | Stage-begin       | Stage N: PENDING → PARTIAL                 | `stage: N`, `heartbeat`, `last_action`                             |
| 3   | Gate-close        | Stage N: PARTIAL → COMPLETE                | `stage: N+1` (or N if final), `heartbeat`, `last_action`           |
| 4   | Pipeline complete | All COMPLETE                               | `status: complete`, `heartbeat`, `last_action`                     |

CONTINUE.md is always rewritten in full (atomic writes, never appended). The stage-begin update fires **before** agent
spawning (safer — crash between update and spawn shows "not yet created" in Checkpoint Index).

### Recovery Protocol

On re-invocation with no args (or with the resume command):

1. Read `docs/CONTINUE.md`. If absent → fall through to existing behavior (no regression).
2. If `status: complete` → report pipeline complete, exit.
3. If `status: in_progress` → restore flags from frontmatter, scan Stage Map:
   - COMPLETE → skip (confirm via artifact detection)
   - PARTIAL → follow compensating action
   - PENDING → run normally when reached
4. Confirm with existing artifact detection (ground truth wins over CONTINUE.md).
5. Execute pipeline from first non-COMPLETE stage.

### Architectural Decision: Advisory over Ground Truth

CONTINUE.md is always advisory. When CONTINUE.md and ground truth (artifact frontmatter, agent checkpoint files)
conflict, ground truth wins. Rationale: making CONTINUE.md authoritative creates a single point of failure. If the Team
Lead crashes between an agent completing and the CONTINUE.md update, an authoritative file would incorrectly report the
agent as incomplete. The advisory model keeps existing recovery mechanisms as fallbacks.

## Constraints

1. All changes are SKILL.md prose edits. No runtime, no tooling, no validators, no hooks.
2. CONTINUE.md is advisory — artifact frontmatter and checkpoint files are ground truth.
3. Only pipeline skills (plan-product, build-product) produce CONTINUE.md. Granular and utility skills are excluded.
4. CONTINUE.md is always at `docs/CONTINUE.md`. Never a dynamic path.
5. Atomic writes only — never append. A partial write is treated as a missing file.
6. All file paths are exact relative paths from repo root. No globs.
7. All timestamps are ISO-8601.
8. No hedged language in compensating actions or recovery instructions.

## Out of Scope

- Runtime tooling (filesystem watchers, hooks, auto-generation)
- Granular or utility skills
- Git tracking policy for CONTINUE.md
- Checksum/hash-based integrity (use `status != "draft"` instead)
- Rollback of completed stages (forward recovery only)
- Multi-user or concurrent session scenarios
- Automatic re-invocation (user types the resume command)

## Files to Modify

| File                                             | Change                                                                           |
| ------------------------------------------------ | -------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add `### CONTINUE.md Protocol` subsection to Checkpoint Protocol (~40 lines)     |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add stage-begin CONTINUE.md update to each of Stages 1-5 (~3 lines per stage)    |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add gate-close CONTINUE.md update to Between Stages (~5 lines)                   |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add CONTINUE.md finalization step to Pipeline Completion (~3 lines)              |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Extend Determine Mode (Empty/no args) with CONTINUE.md-first routing (~15 lines) |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add CONTINUE.md recovery bullet to Failure Recovery (~4 lines)                   |
| `plugins/conclave/skills/build-product/SKILL.md` | Same six changes, adapted for 3 stages                                           |

**No other files change.** No validators, no shared content, no templates, no tooling.

## Success Criteria

1. After every stage gate, CONTINUE.md reflects the true pipeline state (stage, agent statuses, artifact locations)
2. A fresh session reading only CONTINUE.md can determine the exact resume command including topic and flags
3. All 7 pain points (P1-P7) are addressed by the combined design
4. CONTINUE.md is self-sufficient: a reader with zero prior context can resume the pipeline
5. Existing recovery mechanisms (artifact detection, checkpoint scanning) continue to work unchanged as fallbacks
6. The advisory-over-ground-truth invariant holds at every state transition

## Architecture Documents

- System design: `docs/architecture/session-recovery-continue-md-system-design.md`
- Data model: `docs/architecture/session-recovery-continue-md-data-model.md`

## Research & Ideation Artifacts

- Research: `docs/research/session-recovery-continue-md-research.md`
- Ideas: `docs/ideas/session-recovery-continue-md-ideas.md`
- User stories: `docs/specs/session-recovery-continue-md/stories.md`
- Roadmap item: `docs/roadmap/P2-14-continue-md-disaster-recovery.md`
