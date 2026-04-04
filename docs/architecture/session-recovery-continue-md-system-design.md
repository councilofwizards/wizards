## System Architecture: CONTINUE.md Disaster Recovery Protocol

### Overview

CONTINUE.md is a continuously-updated, human-readable recovery brief that the Team Lead writes and maintains during
every pipeline skill run. It aggregates per-agent checkpoint state into a single file at `docs/CONTINUE.md`. This
document defines where and how the CONTINUE.md protocol integrates with existing SKILL.md files.

This is not a runtime system. All "components" are sections of prose in SKILL.md files that instruct the Team Lead
agent. The "interfaces" are file reads and writes. The "integration points" are specific locations in existing SKILL.md
sections where new instructions are inserted.

---

### Component Diagram

The system has four logical components, all implemented as SKILL.md prose:

```
┌─────────────────────────────────────────────────────────┐
│                    SKILL.md (Team Lead)                  │
│                                                          │
│  ┌──────────────┐   ┌───────────────┐   ┌────────────┐  │
│  │  Initializer  │──▶│ Stage Updater │──▶│  Finalizer │  │
│  │  (session     │   │ (stage-begin, │   │  (pipeline │  │
│  │   startup)    │   │  gate-close)  │   │  complete) │  │
│  └──────────────┘   └───────────────┘   └────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────────┐│
│  │              Recovery Router                         ││
│  │  (Determine Mode — reads CONTINUE.md on re-invoke)  ││
│  └──────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
   ┌───────────┐    ┌──────────────────┐   ┌─────────────┐
   │ CONTINUE  │    │ Agent Checkpoint │   │  Artifact   │
   │   .md     │    │ Files (progress/)│   │  Files      │
   └───────────┘    └──────────────────┘   └─────────────┘
```

**Initializer**: Creates `docs/CONTINUE.md` before any agent is spawned. Captures skill, topic, run_id, team, flags, and
the resume command. Stages with FOUND artifacts are set to COMPLETE; remaining stages start as PENDING. Checkpoint Index
lists all agents as "not yet created."

**Stage Updater**: Updates `docs/CONTINUE.md` at exactly two points per stage — stage-begin (PENDING→PARTIAL) and
gate-close (PARTIAL→COMPLETE). Reads agent checkpoint files to populate the Checkpoint Index.

**Finalizer**: Writes the final CONTINUE.md update with `status: complete` after the last stage gate closes. Runs before
the existing Pipeline Completion steps (cost summary, session summary).

**Recovery Router**: On re-invocation, reads `docs/CONTINUE.md` in the Determine Mode section. Uses Stage Map and
Checkpoint Index to route recovery — skip COMPLETE stages, resume PARTIAL stages per compensating actions, run PENDING
stages normally.

---

### SKILL.md Integration Points

Each component maps to a specific insertion point in the existing SKILL.md structure. Both `plan-product/SKILL.md` and
`build-product/SKILL.md` receive the same structural changes, adapted for their stage counts.

#### 1. Initializer — New subsection in Checkpoint Protocol

**Location**: `## Checkpoint Protocol` section, as a new `### CONTINUE.md Protocol` subsection after the existing
`### When to Checkpoint` subsection.

**Why here**: The Checkpoint Protocol section owns all state-persistence instructions. CONTINUE.md is a pipeline-level
checkpoint. Placing it here maintains the single-responsibility principle — all persistence instructions live in one
section.

**Content**: Defines the CONTINUE.md schema (frontmatter fields, mandatory sections), the initial write trigger, and the
full-rewrite rule. References the DBA's schema definition for the exact format.

**What it instructs**:

1. Before spawning any agent (before Step 1 of "Spawn the Team"), create `docs/CONTINUE.md` with:
   - Full YAML frontmatter (skill, topic, run_id, team, stage, status, flags, heartbeat, last_action)
   - Six mandatory sections with initial content (What We're Building, Current State, Recovery Instructions, Stage Map,
     Checkpoint Index, Team Roster)
   - Stage Map with FOUND-artifact stages as COMPLETE, remaining stages as PENDING
   - Empty Checkpoint Index (no agents spawned yet)
   - Recovery Instructions with the resume command
2. If `docs/CONTINUE.md` already exists, overwrite it — the new run_id distinguishes runs.
3. CONTINUE.md is always rewritten in full, never appended.

#### 2. Stage Updater — New instructions in Orchestration Flow

**Location**: Two insertion points within `## Orchestration Flow`:

**(a) Per-stage instructions** — At the beginning of each stage section (Stage 1, Stage 2, etc.), after the skip check
and before agent spawning:

> After confirming this stage will run (not skipped), update `docs/CONTINUE.md` **before spawning agents**:
>
> - Set frontmatter `stage` to this stage number, `heartbeat` to now, `last_action` to "Stage N beginning"
> - Set this stage's Stage Map row to PARTIAL
> - Populate Checkpoint Index with agents to be spawned for this stage at initial status ("not yet created")
> - Rewrite the full file
> - Then spawn agents for this stage

This is the **stage-begin** update. It fires before agent spawning (not after) — if the session crashes between the
update and agent spawn, the Checkpoint Index shows "not yet created" and the compensating action is "re-spawn from
scratch." This is the safest ordering.

**(b) Between Stages subsection** — In the existing `### Between Stages` section, add a step before "Report progress to
the user":

> Update `docs/CONTINUE.md`:
>
> - Set the completed stage's Stage Map row to COMPLETE with the artifact path
> - Set the Compensating Action to "Skip — artifact verified at [path]"
> - Set frontmatter `stage` to the next stage number (N+1), or N if this is the final stage
> - Refresh `heartbeat` and `last_action`
> - Re-read all agent checkpoint files and refresh the Checkpoint Index
> - Rewrite the full file

This is the **gate-close** update.

**Why per-stage and Between Stages, not a single location**: The stage-begin update must happen inside each stage's
execution block (after the skip check). The gate-close update is uniform across stages and belongs in Between Stages.
This separation matches the existing code structure — stages have individual sections, but Between Stages is shared.

#### 3. Finalizer — New step in Pipeline Completion

**Location**: `### Pipeline Completion` section, as the **first** step (before cost summary).

**Content**:

> 0. Update `docs/CONTINUE.md`: set `status: complete`, all stages COMPLETE, `heartbeat` to now, `last_action` to
>    "Pipeline complete". Rewrite the full file.

**Why first**: If the session crashes during Pipeline Completion (while writing cost summary or session summary),
CONTINUE.md already reflects pipeline completion. The cost summary and session summary are non-critical — they don't
affect recovery.

#### 4. Recovery Router — Extension to Determine Mode

**Location**: `## Determine Mode` section, in the **Empty/no args** case.

**Current behavior** (plan-product):

> First, scan `docs/progress/` for checkpoint files with `team: "plan-product"` and `status` of `in_progress`,
> `blocked`, or `awaiting_review`. If found, resume from the last checkpoint...

**New behavior** — insert a CONTINUE.md check **before** the existing checkpoint scan:

> 1. Check if `docs/CONTINUE.md` exists.
> 2. If it exists, read its frontmatter: a. If `status: complete` — pipeline already finished. Report "Pipeline
>    complete" and exit. b. If `status: in_progress`:
>    - Read the Stage Map. For each stage:
>      - **COMPLETE**: Skip (existing artifact detection will confirm).
>      - **PARTIAL**: Read the Compensating Action. Follow it to resume this stage.
>      - **PENDING**: Run normally when reached.
>    - Read the Checkpoint Index. For agents with `status: awaiting_review`, route existing output to the skeptic. For
>      agents with `status: in_progress`, re-spawn with checkpoint file as context.
>    - Use the `flags` field to restore original invocation flags.
>    - Proceed with existing artifact detection as confirmation (CONTINUE.md is the routing hint; artifact frontmatter
>      is ground truth).
> 3. If `docs/CONTINUE.md` does not exist, fall through to existing behavior (checkpoint scan, then artifact detection,
>    then Stage 1 from scratch).

**Why before the checkpoint scan**: CONTINUE.md provides pipeline-level context (which stage, which agents, what flags)
that individual checkpoint files lack. Reading CONTINUE.md first gives the Team Lead a complete picture before diving
into per-agent files. The existing checkpoint scan becomes a fallback for the case where CONTINUE.md doesn't exist
(pre-protocol sessions, or crash before initialization).

#### 5. Failure Recovery — Extension

**Location**: `## Failure Recovery` section, add a new bullet after "Partial pipeline":

> - **CONTINUE.md recovery**: If a session crashes, `docs/CONTINUE.md` contains the pipeline's last known state. A fresh
>   session reads CONTINUE.md in Determine Mode (see above) to route recovery. CONTINUE.md is a recovery hint — agent
>   checkpoint files and artifact frontmatter remain ground truth. If CONTINUE.md and ground truth diverge, trust ground
>   truth.

**Why a separate bullet**: This is a distinct failure mode (session crash) with a distinct recovery mechanism
(CONTINUE.md). It complements, not replaces, the existing "Partial pipeline" bullet which describes artifact detection.

---

### Update Protocol — Trigger Sequence

The Team Lead updates `docs/CONTINUE.md` at exactly these points, in this order:

| #   | Trigger                       | When                                                                 | Stage Map Change                                                                  | Frontmatter Changes                                                                                                                            |
| --- | ----------------------------- | -------------------------------------------------------------------- | --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Session init**              | Before any agent spawn, after flag parsing and artifact detection    | FOUND-artifact stages → COMPLETE (with artifact path); remaining stages → PENDING | `stage: 0` (fresh run) or first non-COMPLETE stage number (resumed run with skipped stages), `status: in_progress`, `heartbeat`, `last_action` |
| 2   | **Stage-begin**               | Before spawning agents for stage N                                   | Stage N → PARTIAL                                                                 | `stage: N`, `heartbeat`, `last_action`                                                                                                         |
| 3   | **Gate-close**                | After skeptic approval for stage N, before spawning stage N+1 agents | Stage N → COMPLETE                                                                | `stage: N+1` (or `N` if final stage), `heartbeat`, `last_action`                                                                               |
| 4   | _(Repeat 2-3 for each stage)_ |                                                                      |                                                                                   |                                                                                                                                                |
| 5   | **Pipeline complete**         | After final gate closes, before cost summary                         | All stages COMPLETE                                                               | `status: complete`, `heartbeat`, `last_action`                                                                                                 |

**Skipped stages**: Stages skipped by artifact detection are set to COMPLETE in the Stage Map at session init (trigger
1), with artifact path filled and Compensating Action "Skip — artifact verified at [path]". They receive no stage-begin
or gate-close updates.

**Atomic writes**: Every update rewrites the entire file. No appends. A partial write (crash mid-write) leaves a corrupt
file, which is treated the same as a missing file — fall back to existing checkpoint-based recovery.

**No mid-stage updates**: CONTINUE.md is NOT updated between stage-begin and gate-close. Per-agent status changes are
captured in individual checkpoint files. The Checkpoint Index is a snapshot taken at each CONTINUE.md update, not a live
feed. This keeps the update frequency bounded (2 per stage + init + completion).

---

### Recovery Protocol — Read and Route

When a fresh session invokes a pipeline skill with no arguments (or with the resume command from CONTINUE.md):

```
1. READ docs/CONTINUE.md
   ├── Does not exist → Fall through to existing behavior (no regression)
   ├── status: complete → Report "Pipeline complete", exit
   └── status: in_progress → Continue to step 2

2. RESTORE FLAGS from CONTINUE.md frontmatter
   └── Parse `flags` field, apply to current session (--full, --complexity, etc.)

3. SCAN STAGE MAP top-to-bottom
   ├── COMPLETE → Skip (confirm via artifact detection)
   ├── PENDING  → Run when reached (normal execution)
   └── PARTIAL  → Read Compensating Action, execute it:
                   ├── All agents complete per Checkpoint Index
                   │   → Verify outputs, close gate manually, proceed
                   ├── Agent at awaiting_review
                   │   → Route existing output to skeptic (don't re-spawn writer)
                   ├── Agent at in_progress
                   │   → Re-spawn agent with checkpoint file as context
                   └── No agents started (just spawned)
                       → Re-spawn stage from scratch

4. CONFIRM with artifact detection
   └── Existing artifact detection runs as normal — CONTINUE.md routing is
       advisory, artifact frontmatter is ground truth. If they conflict,
       trust artifact frontmatter.

5. EXECUTE pipeline from the first non-COMPLETE stage
```

**Integration with existing artifact detection**: CONTINUE.md does not replace artifact detection. It enhances it by
providing mid-stage granularity (which agent, what status) that artifact detection cannot see. The flow is: CONTINUE.md
provides the routing hint → artifact detection confirms → execution proceeds. If CONTINUE.md says Stage 3 is COMPLETE
but artifact detection says NOT_FOUND, re-run Stage 3 (ground truth wins).

---

### Interface Definitions

#### CONTINUE.md ← Team Lead (Write Interface)

The Team Lead writes `docs/CONTINUE.md` using the Write tool. The file format is defined by the DBA's data model. The
Team Lead's responsibilities at each trigger:

```
initialize(skill, topic, flags, team, stages[], artifact_detection_results[]) → CONTINUE.md
  - Generates run_id (team name suffix or timestamp-based unique ID)
  - Builds resume command from skill + topic + flags
  - Creates Stage Map: FOUND-artifact stages → COMPLETE with artifact path; remaining → PENDING
  - Sets `stage` to 0 for fresh runs, or the first non-COMPLETE stage number for resumed runs
    (when artifact detection pre-completes stages)
  - Checkpoint Index lists all agents as "not yet created"

update_stage_begin(stage_number, agents[]) → CONTINUE.md
  - Reads current CONTINUE.md
  - Sets stage to PARTIAL in Stage Map
  - Populates Checkpoint Index entries for agents in this stage
  - Reads each agent's checkpoint file (if exists) for current status
  - Rewrites entire file

update_gate_close(stage_number, artifact_path) → CONTINUE.md
  - Reads current CONTINUE.md
  - Sets stage to COMPLETE in Stage Map
  - Sets Compensating Action to "Skip — artifact verified at [path]"
  - Sets frontmatter `stage` to N+1 (or N if final stage) — points to next active stage
  - Re-reads ALL agent checkpoint files, refreshes Checkpoint Index
  - Rewrites entire file

finalize() → CONTINUE.md
  - Sets status to complete
  - All stages should already be COMPLETE
  - Rewrites entire file
```

#### CONTINUE.md → Team Lead (Read Interface)

The Team Lead reads `docs/CONTINUE.md` in Determine Mode on re-invocation:

```
read_continue() → { status, stage, flags, stage_map[], checkpoint_index[] }
  - Parse YAML frontmatter for status, stage, flags, run_id
  - Parse Stage Map table for per-stage status and compensating actions
  - Parse Checkpoint Index table for per-agent status and file paths
  - Return structured data for routing decisions
```

#### Agent Checkpoint Files → CONTINUE.md (Read-Only)

CONTINUE.md reads agent checkpoint files but never writes them. Agent checkpoint files are ground truth. The Checkpoint
Index in CONTINUE.md is a snapshot, not a live view.

```
read_checkpoint(path) → { status, last_action, phase }
  - Read YAML frontmatter from docs/progress/{topic}-{role}.md
  - Extract status field value
  - If file doesn't exist: status = "not yet created"
  - If file exists but no status field: status = "missing — inspect file manually"
```

---

### Files to Modify

| File                                             | Change                                                           | Scope                                                                             |
| ------------------------------------------------ | ---------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add `### CONTINUE.md Protocol` subsection to Checkpoint Protocol | ~40 lines of new prose defining schema reference, init trigger, full-rewrite rule |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add stage-begin CONTINUE.md update to each of Stages 1-5         | ~3 lines per stage (15 lines total), after skip check                             |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add gate-close CONTINUE.md update to Between Stages              | ~5 lines, new step before "Report progress"                                       |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add CONTINUE.md finalization step to Pipeline Completion         | ~3 lines, new step 0                                                              |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Extend Determine Mode (Empty/no args) with CONTINUE.md check     | ~15 lines, inserted before existing checkpoint scan                               |
| `plugins/conclave/skills/plan-product/SKILL.md`  | Add CONTINUE.md recovery bullet to Failure Recovery              | ~4 lines, new bullet                                                              |
| `plugins/conclave/skills/build-product/SKILL.md` | Same six changes as plan-product, adapted for 3 stages           | Same line counts, adjusted stage names/numbers                                    |

**No other files change.** No validators, no shared content, no templates, no tooling.

---

### ADR: CONTINUE.md as Advisory Layer over Ground Truth

**Context**: CONTINUE.md aggregates state from multiple source-of-truth files (agent checkpoints, artifact frontmatter).
This creates a potential conflict: CONTINUE.md could show stale data if it wasn't updated before a crash.

**Decision**: CONTINUE.md is always advisory. When CONTINUE.md and ground truth (artifact frontmatter, agent checkpoint
files) conflict, ground truth wins. CONTINUE.md provides routing hints and the resume command. It does not replace
artifact detection or checkpoint-based recovery — it enhances them with pipeline-level context.

**Rationale**: Making CONTINUE.md authoritative would create a single point of failure. If the Team Lead crashes between
an agent completing and the CONTINUE.md update, an authoritative CONTINUE.md would incorrectly report the agent as
incomplete. By keeping it advisory, the existing recovery mechanisms remain as fallbacks.

**Consequences**:

- **Positive**: No regression risk. Existing artifact detection and checkpoint recovery continue to work unchanged.
  CONTINUE.md adds value without removing safety nets.
- **Positive**: Simpler mental model. "CONTINUE.md helps you find things faster; checkpoint files are always right."
- **Negative**: Recovery may read both CONTINUE.md and individual checkpoint files, which is slightly more work than a
  single authoritative source. Acceptable given the safety benefit.

---

### Migration Plan

This is a SKILL.md prose edit — there is no incremental migration. The implementation is:

1. Define the CONTINUE.md file format (DBA's data model — coordinate with DBA)
2. Add the `### CONTINUE.md Protocol` subsection to both skills' Checkpoint Protocol sections
3. Add stage-begin updates to each stage section in Orchestration Flow
4. Add gate-close update to Between Stages
5. Add finalization step to Pipeline Completion
6. Extend Determine Mode with CONTINUE.md-first routing
7. Add Failure Recovery bullet
8. Validate both SKILL.md files pass all existing validators

Steps 2-7 can be done in a single edit pass per SKILL.md file. No feature flags. No backward compatibility concerns —
sessions that started before CONTINUE.md was added simply won't have a CONTINUE.md file, and the Determine Mode
extension falls through to existing behavior.
