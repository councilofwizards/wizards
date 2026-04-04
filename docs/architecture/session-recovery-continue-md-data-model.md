---
type: "data-model"
feature: "session-recovery-continue-md"
status: "draft"
author: "dba-b7e2 (Nix Deepvault)"
created: "2026-04-03"
updated: "2026-04-03"
---

# Data Model: CONTINUE.md Disaster Recovery Protocol

## Overview

CONTINUE.md is a fixed-schema, human-readable recovery brief at the fixed path `docs/CONTINUE.md`. It is a materialized
view over pipeline state — agent progress files are ground truth; CONTINUE.md is the index. The file is always rewritten
in full (atomic writes, never appended). Format: YAML frontmatter + markdown body.

---

## 1. YAML Frontmatter Schema

Every field is mandatory. No optional fields — a missing field means the file is invalid.

| Field         | Type              | Allowed Values                                          | Set When                                                                             | Updated When                                             |
| ------------- | ----------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------- |
| `skill`       | string            | `plan-product`, `build-product`                         | Session initialization (Story 1)                                                     | Never — immutable for the run                            |
| `topic`       | string            | Free text (the invocation topic)                        | Session initialization                                                               | Never — immutable for the run                            |
| `run_id`      | string            | Unique session identifier (e.g., `b7e2`)                | Session initialization                                                               | Never — immutable for the run                            |
| `team`        | string            | Team name (e.g., `plan-product-b7e2`)                   | Session initialization                                                               | Never — immutable for the run                            |
| `stage`       | integer           | `0` through `N` (N = number of pipeline stages)         | Session initialization (set to first non-skipped stage, or `0` if init is pre-stage) | Every CONTINUE.md update — reflects current active stage |
| `status`      | enum              | `in_progress`, `complete`                               | Session initialization (`in_progress`)                                               | Set to `complete` when all stages are COMPLETE           |
| `flags`       | string            | Verbatim invocation flags, or `"(none — all defaults)"` | Session initialization                                                               | Never — immutable for the run                            |
| `heartbeat`   | string (ISO-8601) | e.g., `2026-04-03T00:10:00Z`                            | Session initialization                                                               | Every CONTINUE.md update — current timestamp             |
| `last_action` | string            | One-sentence description of what just happened          | Session initialization                                                               | Every CONTINUE.md update                                 |

### Immutability Rules

Five fields are immutable after initialization: `skill`, `topic`, `run_id`, `team`, `flags`. These define the identity
of the run. If any of these need to change, it's a new run — overwrite CONTINUE.md with a new `run_id`.

Four fields are mutable: `stage`, `status`, `heartbeat`, `last_action`. These are refreshed on every write.

### Stage Field Semantics

`stage` reflects the **current active stage** — the stage that is either in progress or about to begin.

- At session initialization (before any stage begins): `stage: 0` if no stages were skipped, or the number of the first
  non-skipped stage if artifact detection pre-completed earlier stages.
- When Stage N begins (stage-begin trigger): `stage: N`.
- When Stage N's gate closes and Stage N+1 has not yet begun: `stage` is updated to `N+1` (the next stage to run).
- When all stages are COMPLETE: `stage` equals `N` (the final stage number) and `status` is `complete`.

`stage: 0` is a transient state that exists only between session initialization and the first stage-begin update. It
signals "CONTINUE.md exists but no stage is active yet."

### Flags Field Semantics

- User invoked with flags (e.g., `--full`): `flags: "--full"`
- User invoked with multiple flags: `flags: "--full --complexity high"`
- User invoked with no flags: `flags: "(none — all defaults)"`
- User invoked with unknown flags: record verbatim without validation

---

## 2. Section Schema

The markdown body contains five mandatory sections plus one optional section, in this fixed order. No reordering.

### Section 1: What We're Building

**Purpose**: Static mission description. Does not change after initialization.

**Format**:

```markdown
## What We're Building

{1-3 sentence description of the feature being built. Include the design approach and roadmap item reference.}
```

**Rules**:

- Written once at initialization
- Never updated during the run
- Must reference the roadmap item identifier (e.g., "Roadmap: P2-14")

### Section 2: Current State

**Purpose**: Dynamic summary of pipeline progress. Updated on every write.

**Format**:

```markdown
## Current State

**Stage**: Stage {N} — {stage name} **Status**: {human-readable status} **Team**: {team name} **Invocation**:
`{resume command}` ({flag summary})
```

**Rules**:

- Updated on every CONTINUE.md write
- Stage name must match the Stage Map row name exactly
- Status is a human-readable sentence (e.g., "In progress — architect and dba active")
- Invocation reproduces the original command for quick reference

### Section 3: Recovery Instructions

**Purpose**: Self-sufficient instructions for a reader with zero prior context. The reader must be able to determine the
resume command and next action from this section alone, without reading any other file.

**Format**:

```markdown
## Recovery Instructions

If this chat dies, start a new session and follow these steps:

### Step 1: Read These Files (in order)

1. `docs/CONTINUE.md` — this file
2. `plugins/conclave/skills/{skill}/SKILL.md` — skill definition
3. {list of COMPLETE stage artifacts, each with path and status}

### Step 2: Check Agent Progress Files

{For each agent in the current PARTIAL stage, list their progress file path and the action to take based on their
status.}

- If status is `complete` but stage gate not closed: verify outputs, close gate manually
- If status is `awaiting_review`: route existing output to skeptic — do NOT re-spawn writer
- If status is `in_progress`: re-spawn agent with checkpoint file as context
- If status is `not yet created`: spawn agent from scratch

### Step 3: Resume Command
```

{exact resume command in fenced code block}

```

{One sentence explaining which stages auto-detection will skip.}
```

**Rules**:

- Resume command must be a single, copy-pasteable string in a fenced code block
- If topic contains spaces or special characters, wrap in quotes: `/conclave:plan-product "my topic"`
- Resume command includes all non-default flags from the `flags` frontmatter field
- No hedged language ("something like", "probably"). Every instruction is exact.
- Step 2 agent list covers only the current PARTIAL stage's agents. COMPLETE stage agents are not listed.
- If all stages are COMPLETE, Step 2 reads: "All stages complete. No agent recovery needed."

### Section 4: Stage Map

**Purpose**: Saga-pattern stage tracking with compensating actions. Self-sufficient — readable without any other file.

**Format**: Markdown table with exactly four columns.

```markdown
## Stage Map

| Stage      | Status   | Artifact Path   | Compensating Action |
| ---------- | -------- | --------------- | ------------------- |
| 1 ({name}) | {STATUS} | {path or empty} | {action}            |
| ...        | ...      | ...             | ...                 |
```

**Column definitions**: See Section 4 (Stage Map Table Format) below.

### Section 5: Checkpoint Index

**Purpose**: Materialized view of all agent progress files. One row per agent in the entire pipeline.

**Format**: Markdown table with exactly three columns.

```markdown
## Checkpoint Index

| Agent        | File              | Status         |
| ------------ | ----------------- | -------------- |
| {agent-name} | `{relative path}` | {status value} |
| ...          | ...               | ...            |
```

**Column definitions**: See Section 5 (Checkpoint Index Table Format) below.

### Section 6: Team Roster (Optional Enhancement)

> **Note**: Team Roster is not specified in the user stories (which define "four mandatory sections"). It is included in
> the existing `docs/CONTINUE.md` and provides operational context (agent instance names, models, stages). However, the
> Recovery Router (Architect's system design) does not read it — recovery routing uses only frontmatter, Stage Map, and
> Checkpoint Index. Agent names and models are already available in SKILL.md spawn definitions.
>
> **Decision**: Include Team Roster as an optional sixth section. The Team Lead MAY include it for human readability,
> but the recovery protocol does not depend on it. If included, it must follow the format below. If omitted, CONTINUE.md
> remains valid with five sections.

**Purpose**: Maps agent names to their models, assigned stages, and operational status. Human convenience only — not
consumed by the Recovery Router.

**Format**: Markdown table with exactly five columns.

```markdown
## Team Roster ({team name})

| Agent  | Name                     | Model   | Stage          | Status               |
| ------ | ------------------------ | ------- | -------------- | -------------------- |
| {role} | {agent-name-with-run-id} | {model} | {stage number} | {operational status} |
| ...    | ...                      | ...     | ...            | ...                  |
```

**Column definitions**:

| Column | Type   | Description                                                             |
| ------ | ------ | ----------------------------------------------------------------------- |
| Agent  | string | Human-readable role name (e.g., "Market Researcher")                    |
| Name   | string | Agent instance name with run_id suffix (e.g., `market-researcher-b7e2`) |
| Model  | string | Model used: `opus` or `sonnet`                                          |
| Stage  | string | Stage number(s) the agent participates in (e.g., `1`, `4-5`)            |
| Status | enum   | `SHUTDOWN`, `active`, `spawning`, `not yet created`                     |

**Rules**:

- One row per agent in the pipeline — same agent count as Checkpoint Index
- Status reflects operational state, not artifact state (that's in Checkpoint Index)
- Agents from completed stages show `SHUTDOWN`
- Multi-stage agents (e.g., skeptic spanning stages 4-5) show their full stage range

---

## 3. Stage Map Table Format

### Column Definitions

| Column              | Type            | Description                                                                                                                                |
| ------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Stage               | string          | Stage number and name: `{N} ({name})` — e.g., `1 (Research)`                                                                               |
| Status              | enum            | `COMPLETE`, `PARTIAL`, `PENDING`                                                                                                           |
| Artifact Path       | string or empty | Exact relative path from repo root to the produced artifact, or empty if no artifact exists yet. `"(no artifact)"` if stage produces none. |
| Compensating Action | string          | Self-sufficient instruction for recovery. No references to external files for understanding — though file paths may appear as operands.    |

### Status Enum

| Value      | Meaning                                                                                                                     | Transition In                 | Transition Out                            |
| ---------- | --------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ----------------------------------------- |
| `PENDING`  | Stage has not started. No agents spawned.                                                                                   | Initial state for all stages  | → `PARTIAL` when stage-begin update fires |
| `PARTIAL`  | Stage started (agents spawned) but gate never closed. Work may be in progress, awaiting review, or complete-but-unverified. | From `PENDING` at stage-begin | → `COMPLETE` when gate-close update fires |
| `COMPLETE` | Stage gate closed. Skeptic approved. Artifact verified (`status != "draft"`).                                               | From `PARTIAL` at gate-close  | Terminal — never reverts                  |

**Critical rule**: A stage with an artifact at `status: "draft"` is `PARTIAL`, not `COMPLETE`. Draft artifacts are not
closed gates. (Story 4, AC-8.)

**Critical rule**: `PARTIAL` is distinct from `PENDING`. PENDING = not started. PARTIAL = started but not finished.
Recovery actions differ fundamentally between the two. (Story 4, Notes.)

### Compensating Action Patterns

Each status has a fixed pattern. Compensating actions must follow these templates exactly.

#### COMPLETE

```
Skip — artifact verified at `{exact relative path}`
```

No variation. If the stage is COMPLETE, the action is always "Skip."

#### PENDING (no dependency blocked)

```
Run Stage {N} from scratch
```

Used when all prior stages are COMPLETE.

#### PENDING (dependency blocked)

```
Blocked on Stage {N} — run after Stage {N} completes
```

Where `{N}` is the most recent incomplete dependency. Used when a prior stage is not COMPLETE.

#### PARTIAL — All agents complete, gate never closed

```
All agents complete — verify outputs and close the stage gate manually before proceeding to Stage {N+1}
```

Used when Checkpoint Index shows all agents in this stage at `complete` but Stage Map shows PARTIAL (Team Lead crashed
between agent completion and gate-close update). (Story 4, Edge Case 5.)

#### PARTIAL — Writer complete, skeptic crashed

```
{writer-role} draft at `awaiting_review` — spawn {skeptic-name} with `{writer-progress-file-path}` as context; do not re-run {writer-role}
```

Used when the writer agent's checkpoint shows `complete` or `awaiting_review` but the skeptic has not reviewed. (Story
4, AC-6; Edge Case 1.)

#### PARTIAL — Writer mid-revision after skeptic rejection

```
Re-spawn {writer-role} with feedback from {skeptic-name}'s progress file at `{skeptic-progress-file-path}`; skeptic checkpoint contains rejection notes
```

Used when the skeptic rejected and the writer was mid-revision when the session crashed. (Story 4, Edge Case 2.)

#### PARTIAL — Agents mid-task (no completions yet)

```
Re-spawn Stage {N} agents from scratch — no prior output to preserve
```

Used when agents were spawned but none completed (typical for crashes early in a stage).

#### PARTIAL — Mixed agent states

```
Check Checkpoint Index below: re-spawn `in_progress` agents with their checkpoint files as context; route `awaiting_review` agents to skeptic; `complete` agents need no action
```

Used when multiple agents in a stage have different statuses.

---

## 4. Checkpoint Index Table Format

### Column Definitions

| Column | Type   | Description                                                                        |
| ------ | ------ | ---------------------------------------------------------------------------------- |
| Agent  | string | Agent role name (e.g., `market-researcher`) — the base name without run_id suffix  |
| File   | string | Exact relative path from repo root to the agent's progress file. Backtick-wrapped. |
| Status | enum   | Current `status` value from the progress file's YAML frontmatter                   |

### Status Values

| Value                             | Source                                         | Meaning                                      | Recovery Action (defined in Story 5)                     |
| --------------------------------- | ---------------------------------------------- | -------------------------------------------- | -------------------------------------------------------- |
| `complete`                        | Progress file frontmatter                      | Agent finished and output is available       | No action — work preserved                               |
| `awaiting_review`                 | Progress file frontmatter                      | Agent finished, output awaits skeptic review | Route to skeptic — do NOT re-spawn agent (Story 5, AC-5) |
| `in_progress`                     | Progress file frontmatter                      | Agent was mid-task when session crashed      | Re-spawn with checkpoint file as context (Story 5, AC-6) |
| `not yet created`                 | Absence of progress file                       | Agent has not been spawned yet               | Spawn from scratch when stage begins                     |
| `missing — inspect file manually` | Progress file exists but has no `status` field | Malformed checkpoint                         | Manual inspection required (Story 3, Edge Case 1)        |

### Rules

- One row per agent in the entire pipeline — not just the current stage
- Agent order follows pipeline stage order (Stage 1 agents first, then Stage 2, etc.)
- Status is read from frontmatter only — body content is never parsed (Story 3, Edge Case 4)
- File paths are actual paths as created by agents, not template paths (Story 3, Edge Case 2)
- Regenerated in full on every CONTINUE.md update — never incrementally appended (Story 3, Notes)

---

## 5. Pipeline Stage Definitions

The Stage Map must have exactly the right number of rows for the pipeline skill.

### plan-product (5 stages)

| Stage | Name     | Agents                                 | Artifact Path Pattern               |
| ----- | -------- | -------------------------------------- | ----------------------------------- |
| 1     | Research | market-researcher, customer-researcher | `docs/research/{topic}-research.md` |
| 2     | Ideation | idea-generator, idea-evaluator         | `docs/ideas/{topic}-ideas.md`       |
| 3     | Roadmap  | analyst                                | `docs/roadmap/{roadmap-id}.md`      |
| 4     | Stories  | story-writer                           | `docs/specs/{topic}/stories.md`     |
| 5     | Spec     | architect, dba                         | `docs/specs/{topic}/spec.md`        |

Skeptic (product-skeptic) spans multiple stages — appears in Checkpoint Index with the stage range it covers.

### build-product (3 stages)

| Stage | Name           | Agents                              | Artifact Path Pattern                       |
| ----- | -------------- | ----------------------------------- | ------------------------------------------- |
| 1     | Planning       | impl-architect, plan-skeptic        | `docs/specs/{topic}/implementation-plan.md` |
| 2     | Build          | backend-eng, frontend-eng, qa-agent | Implementation files (code)                 |
| 3     | Quality Review | security-auditor                    | `docs/progress/{topic}-security-auditor.md` |

Quality-skeptic spans all three stages (gates Stage 1, Stage 2, and Stage 3) — appears in Checkpoint Index with stage
range `1-3`.

**Note**: `{topic}` is the literal topic string from the frontmatter. Artifact path patterns are guidance — the Team
Lead records actual paths as produced by agents.

---

## 6. Validation Rules

These are rules the Team Lead must follow. They are not automated validators — they are enforced by SKILL.md prose.

### Frontmatter Validation

| Rule   | Check                                              | Severity                                             |
| ------ | -------------------------------------------------- | ---------------------------------------------------- |
| V-FM-1 | All 9 frontmatter fields present                   | Required — file is invalid without all fields        |
| V-FM-2 | `skill` is one of: `plan-product`, `build-product` | Required                                             |
| V-FM-3 | `stage` is integer between 0 and N (inclusive)     | Required                                             |
| V-FM-4 | `status` is one of: `in_progress`, `complete`      | Required                                             |
| V-FM-5 | `heartbeat` is valid ISO-8601 timestamp            | Required                                             |
| V-FM-6 | `flags` is non-empty string                        | Required — use `"(none — all defaults)"` if no flags |
| V-FM-7 | `run_id` is non-empty string                       | Required                                             |

### Stage Map Validation

| Rule   | Check                                                                                                                                                      | Severity |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| V-SM-1 | Stage Map has exactly N rows (5 for plan-product, 3 for build-product)                                                                                     | Required |
| V-SM-2 | Every Status cell is one of: `COMPLETE`, `PARTIAL`, `PENDING`                                                                                              | Required |
| V-SM-3 | No COMPLETE stage has an empty Artifact Path (unless stage produces no artifact)                                                                           | Required |
| V-SM-4 | No PARTIAL stage appears after a PENDING stage — reading top to bottom, valid order is: zero or more COMPLETE → at most one PARTIAL → zero or more PENDING | Required |
| V-SM-5 | Every PARTIAL or PENDING stage has a non-empty Compensating Action                                                                                         | Required |
| V-SM-6 | All Artifact Paths are exact relative paths from repo root (no globs, no directory-only)                                                                   | Required |
| V-SM-7 | COMPLETE artifact has `status != "draft"` in its own frontmatter                                                                                           | Required |

### Checkpoint Index Validation

| Rule   | Check                                                                                                                               | Severity |
| ------ | ----------------------------------------------------------------------------------------------------------------------------------- | -------- |
| V-CI-1 | Checkpoint Index has one row per agent in the pipeline                                                                              | Required |
| V-CI-2 | Every File cell is a backtick-wrapped relative path from repo root                                                                  | Required |
| V-CI-3 | Status values come from the defined enum (complete, awaiting_review, in_progress, not yet created, missing — inspect file manually) | Required |
| V-CI-4 | Agent order follows pipeline stage order                                                                                            | Required |

### Recovery Instructions Validation

| Rule   | Check                                                                          | Severity |
| ------ | ------------------------------------------------------------------------------ | -------- |
| V-RI-1 | Resume command is present in a fenced code block                               | Required |
| V-RI-2 | Resume command matches format: `/conclave:{skill} {topic}` with flags appended | Required |
| V-RI-3 | Topic with spaces or special characters is wrapped in quotes                   | Required |
| V-RI-4 | No hedged language in any instruction ("something like", "probably", "maybe")  | Required |

### Cross-Section Consistency

| Rule   | Check                                                                                                          | Severity |
| ------ | -------------------------------------------------------------------------------------------------------------- | -------- |
| V-XS-1 | If Team Roster is present, its agent count equals Checkpoint Index agent count                                 | Advisory |
| V-XS-2 | Stage Map row count matches pipeline's defined stage count                                                     | Required |
| V-XS-3 | Frontmatter `stage` matches the first non-COMPLETE stage in Stage Map (or `0` at init before any stage begins) | Required |
| V-XS-4 | If all Stage Map rows are COMPLETE, frontmatter `status` is `complete`                                         | Required |
| V-XS-5 | Artifact paths in Stage Map match the actual files on disk                                                     | Required |

---

## 7. Update Protocol Summary

This section summarizes when CONTINUE.md is written. The Architect's integration design defines the trigger protocol in
SKILL.md; this section defines what each write must contain.

| Trigger                              | Frontmatter Changes                                                                         | Stage Map Changes                                                                                      | Checkpoint Index Changes                                              |
| ------------------------------------ | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| **Session initialization** (Story 1) | All fields set. `stage: 0` (or first non-skipped stage), `status: in_progress`              | All stages PENDING; skipped stages (detected by artifact detection) set to COMPLETE with artifact path | All agents `not yet created` (skipped-stage agents set to `complete`) |
| **Stage-begin** (Story 2, AC-1)      | `stage` = current stage, `heartbeat` refreshed, `last_action` updated                       | Current stage → PARTIAL                                                                                | Newly spawned agents added at initial status                          |
| **Gate-close** (Story 2, AC-2)       | `stage` = next stage (or stays at N if final), `heartbeat` refreshed, `last_action` updated | Completed stage → COMPLETE                                                                             | All agents in completed stage show final status                       |
| **Pipeline complete**                | `status: complete`, `heartbeat` refreshed, `last_action: "Pipeline complete"`               | All stages COMPLETE                                                                                    | All agents show `complete`                                            |

**Atomic write rule**: CONTINUE.md is always rewritten in full. Never appended. A partial write is worse than a stale
snapshot. (NFR: Atomic writes.)

---

## 8. Reference Template

### Fresh Run (no skipped stages)

```yaml
---
skill: { plan-product|build-product }
topic: "{invocation topic}"
run_id: "{unique session identifier}"
team: "{team name}"
stage: 0
status: in_progress
flags: "{verbatim flags or (none — all defaults)}"
heartbeat: "{ISO-8601 timestamp}"
last_action: "Session initialized — CONTINUE.md created before agent spawn"
---
```

```markdown
# CONTINUE: Session Recovery — {feature description}

## What We're Building

{1-3 sentence description. Include design approach and roadmap reference.}

## Current State

**Stage**: Initializing — no stage active yet **Status**: Initializing — no agents spawned yet **Team**: {team name}
**Invocation**: `{resume command}` ({flag summary})

## Recovery Instructions

If this chat dies, start a new session and follow these steps:

### Step 1: Read These Files (in order)

1. `docs/CONTINUE.md` — this file
2. `plugins/conclave/skills/{skill}/SKILL.md` — skill definition

### Step 2: Check Agent Progress Files

No agents spawned yet. Re-run from Stage 1.

### Step 3: Resume Command
```

/conclave:{skill} {topic with quotes if needed} {flags if non-default}

```

No stages complete — pipeline starts from Stage 1.

## Stage Map

| Stage | Status | Artifact Path | Compensating Action |
|-------|--------|---------------|---------------------|
| 1 ({name}) | PENDING | | Run Stage 1 from scratch |
| 2 ({name}) | PENDING | | Blocked on Stage 1 — run after Stage 1 completes |
| ... | PENDING | | Blocked on Stage {N-1} — run after Stage {N-1} completes |

## Checkpoint Index

| Agent | File | Status |
|-------|------|--------|
| {agent-1} | `docs/progress/{topic}-{agent-1}.md` | not yet created |
| {agent-2} | `docs/progress/{topic}-{agent-2}.md` | not yet created |
| ... | ... | not yet created |

## Team Roster ({team name})

| Agent | Name | Model | Stage | Status |
|-------|------|-------|-------|--------|
| {Role 1} | {name-run_id} | {model} | {stage} | not yet created |
| {Role 2} | {name-run_id} | {model} | {stage} | not yet created |
| ... | ... | ... | ... | ... |
```

### Resumed Run (with skipped stages from artifact detection)

At session init, stages whose artifacts are already detected are set to COMPLETE immediately. Example for a plan-product
resume where Stages 1-3 are already complete:

```yaml
---
skill: plan-product
topic: "my-feature"
run_id: "a1b2"
team: "plan-product-a1b2"
stage: 4
status: in_progress
flags: "(none — all defaults)"
heartbeat: "2026-04-03T01:00:00Z"
last_action: "Session initialized — Stages 1-3 artifacts detected, resuming at Stage 4"
---
```

In this case, the Stage Map shows:

```markdown
| 1 (Research) | COMPLETE | `docs/research/my-feature-research.md` | Skip — artifact verified at
`docs/research/my-feature-research.md` | | 2 (Ideation) | COMPLETE | `docs/ideas/my-feature-ideas.md` | Skip — artifact
verified at `docs/ideas/my-feature-ideas.md` | | 3 (Roadmap) | COMPLETE | `docs/roadmap/P2-XX-my-feature.md` | Skip —
artifact verified at `docs/roadmap/P2-XX-my-feature.md` | | 4 (Stories) | PENDING | | Run Stage 4 from scratch | | 5
(Spec) | PENDING | | Blocked on Stage 4 — run after Stage 4 completes |
```

And agents from skipped stages show `complete` in the Checkpoint Index with their actual progress file paths.

---

## Design Decisions

1. **Five mandatory sections + one optional**: The stories reference "four mandatory sections" but the design target
   (Ideas 1+5+4) requires Stage Map and Checkpoint Index as distinct sections — five mandatory total. Team Roster is an
   optional sixth section for human readability; the Recovery Router does not depend on it.

2. **Status enums are UPPERCASE in Stage Map, lowercase in Checkpoint Index**: Stage Map uses COMPLETE/PARTIAL/PENDING
   (saga-pattern convention, high visibility). Checkpoint Index uses lowercase values matching progress file frontmatter
   exactly (materialized view — no transformation).

3. **Compensating Action patterns are fixed templates**: Every PARTIAL state maps to a specific template. The Team Lead
   fills in agent names and file paths, but the sentence structure is prescribed. This prevents vague or hedged actions.

4. **No `phase` field in frontmatter**: The existing CONTINUE.md has a `phase` field. This is redundant with `stage` —
   the stage number and Stage Map together provide complete phase context. Removed to avoid ambiguity.

5. **`stage` tracks the active stage, not the last completed**: If Stage 3 just closed, `stage` becomes `4`. This
   matches the recovery use case: "what stage should I resume from?" The answer is always `stage`.

6. **Immutable fields are explicitly marked**: Five fields never change after init. This prevents subtle bugs where a
   resumed session accidentally mutates the run identity.

7. **`stage: 0` at fresh init**: Aligns with Architect's integration design. The Initializer runs before any stage
   begins, so `stage: 0` signals "CONTINUE.md exists but no stage is active." This is a transient state — the first
   stage-begin update sets `stage` to 1 (or higher if stages were skipped). For resumed runs where artifact detection
   already identified completed stages, `stage` is set to the first non-skipped stage at init.

8. **Skipped stages are COMPLETE at init**: When artifact detection finds existing artifacts before CONTINUE.md is
   created, those stages are initialized as COMPLETE (not PENDING→COMPLETE). This aligns with the Architect's Recovery
   Router which expects the Stage Map to reflect true state from the first write.

9. **CONTINUE.md is advisory, not authoritative**: Per the Architect's ADR, when CONTINUE.md and ground truth (artifact
   frontmatter, agent checkpoint files) conflict, ground truth wins. CONTINUE.md provides routing hints and the resume
   command. This aligns with the materialized view framing — a view can be stale, but the underlying data is always
   correct.
