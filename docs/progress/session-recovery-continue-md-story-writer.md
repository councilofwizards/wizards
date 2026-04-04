---
skill: plan-product
topic: session-recovery-continue-md
agent: story-writer-b7e2
stage: 4
status: complete
checkpoint: "approved"
updated: "2026-04-03T00:25:00Z"
---

# Progress: Story Writer — CONTINUE.md Disaster Recovery Protocol

## Agent

Fenn Quillsong, Chronicler of Deeds Unwritten (story-writer-b7e2)

## Assignment

Write user stories for P2-14: CONTINUE.md Disaster Recovery Protocol. Design target: Ideas 1 + 5 + 4 combined. Five
stories covering all 7 pain points.

## Checkpoints

| Time                 | Status              | Notes                                                                                                                                                             |
| -------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-04-03T00:05:00Z | task-claimed        | Context read: roadmap item, ideas, research, template, existing CONTINUE.md                                                                                       |
| 2026-04-03T00:10:00Z | drafts-ready        | All 5 stories drafted; routed to product-skeptic for review                                                                                                       |
| 2026-04-03T00:15:00Z | feedback-received   | REJECTED: 3 issues — mid-stage update trigger missing (CRITICAL), Story 3/5 boundary (MODERATE), Story 4 missing COMPLETE/PENDING compensating actions (MODERATE) |
| 2026-04-03T00:20:00Z | revisions-submitted | All 3 issues addressed; minor AC-6 staleness guidance improved                                                                                                    |
| 2026-04-03T00:25:00Z | approved            | product-skeptic-b7e2 approved round 2; all 3 issues resolved; stories ready for spec                                                                              |

## Output

Revised draft artifact below. Final artifact written by Team Lead to:
`docs/specs/session-recovery-continue-md/stories.md`

## Revision Log

**Round 1 feedback (product-skeptic-b7e2):**

- CRITICAL: No mid-stage update trigger — stage-begin update required so Checkpoint Index and Stage Map reflect
  mid-stage crashes
- MODERATE: Story 3 ACs 4-5 conflated display with recovery routing — moved routing to Story 5
- MODERATE: Story 4 missing compensating actions for COMPLETE and PENDING statuses
- Minor (non-blocking): Story 5 AC-6 "judge" is vague — tightened to run_id comparison as authoritative staleness check

**Changes made:**

- Story 2: Added AC-1 (stage-begin update trigger); renumbered existing ACs
- Story 3: Rewrote ACs 4-5 as display-only criteria
- Story 4: Added ACs 7-8 for COMPLETE and PENDING compensating actions
- Story 5: Added ACs 7-8 (routing behavior from old Story 3 ACs 4-5); revised AC-6 staleness guidance

---

# DRAFT (REVISED): User Stories — CONTINUE.md Disaster Recovery Protocol

---

type: "user-stories" feature: "CONTINUE.md Disaster Recovery Protocol" status: "draft" source_roadmap_item:
"docs/roadmap/P2-14-continue-md-disaster-recovery.md" approved_by: "" created: "2026-04-03" updated: "2026-04-03"

---

## Epic Summary

Pipeline skills (plan-product, build-product) produce and continuously update a `docs/CONTINUE.md` file during every
run. The file is a human-readable, fixed-schema recovery brief that tells a fresh session exactly what stage was
reached, which agents completed, where all artifacts and checkpoint files are, and the exact command to type to resume.
It combines a Mission Brief (Idea 1), a Materialized Checkpoint View (Idea 5), and a Saga Stage Map (Idea 4) — covering
all seven identified pain points.

## Stories

---

### Story 1: CONTINUE.md Schema and Initial Write

- **As a** Team Lead agent starting a pipeline skill run,
- **I want** to create `docs/CONTINUE.md` with a fixed, valid schema at session initialization,
- **So that** if the session crashes before any stage completes, a fresh session has the exact information needed to
  restart from Stage 1 with the correct topic and flags.

- **Priority**: must-have
- **Pain points addressed**: P1 (exact resume command), P2 (flags recorded)

- **Acceptance Criteria**:
  1. Given a pipeline skill is invoked, when the Team Lead initializes the session, then `docs/CONTINUE.md` is created
     before any agent is spawned.
  2. Given CONTINUE.md is created, then its YAML frontmatter contains exactly these fields: `skill` (skill name),
     `topic` (invocation topic), `run_id` (unique session identifier), `team` (team name), `stage` (current stage
     number), `status` (`in_progress`), `flags` (verbatim invocation flags), `heartbeat` (ISO-8601 timestamp),
     `last_action` (one-sentence description of what just happened).
  3. Given the user invoked the pipeline with one or more flags (e.g., `--full`), when CONTINUE.md is written, then the
     `flags` field records those flags verbatim as they were passed.
  4. Given the user invoked with no flags, when CONTINUE.md is written, then the `flags` field reads exactly
     `"(none — all defaults)"`.
  5. Given CONTINUE.md is created, then the Recovery Instructions section contains a copy-pasteable resume command of
     the form `/conclave:{skill} {topic}` with any non-default flags appended, in a fenced code block.
  6. Given CONTINUE.md already exists from a prior run, when the Team Lead initializes a new session, then CONTINUE.md
     is overwritten — the new `run_id` distinguishes this run from prior runs.

- **Edge Cases**:
  - Topic string contains spaces or special characters: the resume command in Recovery Instructions wraps the topic in
    quotes (e.g., `/conclave:plan-product "my topic"`).
  - Team Lead crashes before CONTINUE.md is written: no CONTINUE.md exists; a fresh session falls back to the skill's
    existing "no CONTINUE.md" path (Stage 1 from scratch — existing behavior, no regression).
  - Pipeline invoked with an unknown flag: the `flags` field records it verbatim without validation; CONTINUE.md does
    not interpret flags.

- **Notes**: CONTINUE.md is always at the fixed path `docs/CONTINUE.md`. Never a dynamic path. The four mandatory
  sections are: What We're Building, Current State, Recovery Instructions, Artifact Locations. Initial Stage Map and
  Checkpoint Index may be stubs on first write — they are populated as stages begin and complete.

---

### Story 2: Stage Gate Updates

- **As a** Team Lead agent managing a running pipeline,
- **I want** to update CONTINUE.md both when a stage begins and when a stage gate closes,
- **So that** CONTINUE.md always reflects mid-stage agent state — not just inter-stage state — and a crash at any point
  during a stage leaves a snapshot accurate enough to route recovery without re-running completed agent work.

- **Priority**: must-have
- **Pain points addressed**: P3 (parallel agent status mid-stage), P5 (mid-skeptic crash recovery), P6 (update frequency
  defined)

- **Acceptance Criteria**:
  1. Given a stage's agents have been spawned and assigned their tasks, when the Team Lead records the stage-begin log
     entry, then CONTINUE.md is updated before agents begin their work — the Stage Map row for that stage changes from
     PENDING to PARTIAL, the Checkpoint Index is populated with all newly-spawned agents at their initial status, and
     `heartbeat` and `last_action` are refreshed.
  2. Given a stage's skeptic review passes and the stage gate closes, when the Team Lead writes the gate-closed log
     entry, then CONTINUE.md is updated before spawning any agent for the next stage — the Stage Map row for that stage
     changes from PARTIAL to COMPLETE, and `heartbeat` and `last_action` are refreshed.
  3. Given CONTINUE.md is updated (either at stage-begin or gate-close), then the frontmatter `stage` field reflects the
     current active stage, `heartbeat` contains the current ISO-8601 timestamp, and `last_action` contains a
     one-sentence description of what just happened.
  4. Given a stage has multiple parallel agents, when CONTINUE.md is updated to COMPLETE for that stage, then all agents
     in that stage have already been confirmed complete and their outputs have passed skeptic review.
  5. Given the skeptic rejects a draft and the stage must iterate, when CONTINUE.md is updated during that iteration,
     then the stage's Stage Map row remains PARTIAL — it is not promoted to COMPLETE until the skeptic approves.

- **Edge Cases**:
  - Team Lead crashes after a stage gate closes but before CONTINUE.md is updated to COMPLETE: the prior CONTINUE.md
    still shows that stage as PARTIAL. The Checkpoint Index will show all agents in that stage as `complete`. Recovery:
    Stage Map shows PARTIAL, but Checkpoint Index confirms all agents done — compensating action for this case (Story 4)
    directs a fresh session to verify agent statuses and close the gate manually.
  - Team Lead crashes after stage-begin update but before agents do any work: Stage Map shows PARTIAL, Checkpoint Index
    shows agents at initial status. Recovery: re-spawn agents from scratch for that stage.
  - Skeptic approval message is ambiguous: Team Lead must not update stage to COMPLETE until the skeptic's message
    explicitly approves the artifact. Hedged language ("looks mostly good") does not qualify.
  - Stage produces no artifact (edge case in future skills): Stage Map artifact path column reads `"(no artifact)"`.
    COMPLETE is based on stage gate closure alone.

- **Notes**: The two-update-per-stage cadence — (a) stage begins, (b) gate closes — is the mandated update frequency. No
  other trigger. Per-agent status between these two points is not updated in CONTINUE.md; the Checkpoint Index is a
  snapshot at each update, not a live feed. CONTINUE.md is always rewritten in full — never appended.

---

### Story 3: Checkpoint Index

- **As a** Team Lead agent managing a running pipeline,
- **I want** CONTINUE.md to list every agent's checkpoint file path alongside its current frontmatter `status` value,
- **So that** a fresh session can identify exactly which agents completed, which were mid-task, and which have not yet
  been spawned — without scanning the filesystem.

- **Priority**: must-have
- **Pain points addressed**: P3 (parallel agent status), P4 (checkpoint filenames surfaced)

- **Acceptance Criteria**:
  1. Given CONTINUE.md is written or updated, then the Checkpoint Index section contains one row per agent in the
     pipeline, listing: agent name, exact relative path to their progress file, and current `status` from that file's
     frontmatter.
  2. Given an agent has not yet been spawned, when CONTINUE.md is written, then that agent's Checkpoint Index row reads
     `status: not yet created`.
  3. Given an agent's progress file exists and has a `status` frontmatter field, when CONTINUE.md is updated, then the
     Checkpoint Index row reflects the exact value of that field (e.g., `complete`, `awaiting_review`, `in_progress`).
  4. Given an agent's progress file shows `status: awaiting_review`, when CONTINUE.md is updated, then the Checkpoint
     Index row displays `awaiting_review` — the routing decision is not recorded here.
  5. Given an agent's progress file shows `status: in_progress`, when CONTINUE.md is updated, then the Checkpoint Index
     row displays `in_progress` and includes the checkpoint file path — re-spawn instructions are not recorded here.

- **Edge Cases**:
  - Agent's progress file exists but has no `status` frontmatter field: Checkpoint Index row reads
    `status: missing — inspect file manually`.
  - Agent's progress file path differs from the expected convention: Team Lead writes the actual path as created by the
    agent, not a guessed path.
  - Two agents share a stage and both are `in_progress` (crash during parallel execution): both rows appear in the
    Checkpoint Index with `in_progress`.
  - Agent wrote partial progress file content but the file exists: status is taken from frontmatter only; body content
    is not parsed by CONTINUE.md.

- **Notes**: The Checkpoint Index is a materialized view — CONTINUE.md reads agent progress files and summarizes their
  frontmatter `status`. Agent progress files remain the ground truth. The Checkpoint Index is regenerated on every
  CONTINUE.md update, not incrementally appended. What to _do_ with the displayed statuses is defined in Story 5
  (Recovery Workflow).

---

### Story 4: Saga Stage Map

- **As a** Team Lead agent writing CONTINUE.md,
- **I want** to include a Stage Map table with COMPLETE/PARTIAL/PENDING status and a compensating action for each stage,
- **So that** a fresh session knows precisely which stages need re-running, which need partial recovery, and exactly
  what action to take for each case — without reading any other file first.

- **Priority**: must-have
- **Pain points addressed**: P5 (mid-skeptic crash routing), P7 (artifact integrity via PARTIAL status)

- **Acceptance Criteria**:
  1. Given CONTINUE.md is initialized, then the Stage Map contains one row per pipeline stage with columns: Stage
     (name + number), Status (COMPLETE/PARTIAL/PENDING), Artifact Path, and Compensating Action.
  2. Given a stage has not yet begun, when CONTINUE.md is written, then that stage's Status is PENDING and Artifact Path
     is empty.
  3. Given a stage's agents have been spawned but the stage gate has not yet closed, when CONTINUE.md is written, then
     that stage's Status is PARTIAL.
  4. Given a stage is COMPLETE, when the Compensating Action column is read, then it reads:
     `Skip — artifact verified at [exact relative path]`.
  5. Given a stage is PENDING and depends on a prior incomplete stage, when the Compensating Action column is read, then
     it reads: `Blocked on Stage N — run after Stage N completes` (where N is the most recent incomplete dependency).
  6. Given a stage is PARTIAL, when the Compensating Action column is read, then it contains a specific, actionable
     instruction sufficient to resume without reading any other file (e.g., "story-writer draft is at `awaiting_review`
     — spawn product-skeptic with `docs/progress/…-story-writer.md` as context; do not re-run story-writer").
  7. Given a stage is COMPLETE, when the Artifact Path column is read, then it contains the exact relative file path of
     the produced artifact, and that artifact's frontmatter `status` field is not `"draft"`.
  8. Given an artifact file exists at the Stage Map's listed path but has `status: "draft"`, when CONTINUE.md is
     updated, then that stage's Status is PARTIAL, not COMPLETE — a draft artifact is not a closed gate.

- **Edge Cases**:
  - Stage has both a writer agent and a skeptic agent, and the writer completed but the skeptic crashed: Stage Status is
    PARTIAL; Compensating Action names the skeptic specifically and references the writer's output file path.
  - Skeptic rejected the draft and the writer is mid-revision when session crashes: Stage Status is PARTIAL;
    Compensating Action says "re-spawn writer with feedback from skeptic's progress file; skeptic checkpoint contains
    rejection notes."
  - Stage produced an artifact at an unexpected path (agent deviated from convention): CONTINUE.md records the actual
    path the agent wrote, not a template path. Team Lead must inspect agent progress file for the real path.
  - Pipeline skill has a different number of stages than 5 (e.g., build-product has 3): Stage Map contains exactly as
    many rows as the skill has stages — no more, no fewer.
  - All agents in a PARTIAL stage show `complete` in the Checkpoint Index but the gate never closed (Team Lead crashed
    between agent completions and gate-close update): Compensating Action reads "All agents complete — verify outputs
    and close the stage gate manually before proceeding to Stage N+1."

- **Notes**: PARTIAL is distinct from PENDING. PENDING means the stage has not started. PARTIAL means the stage started
  (agents spawned) but the gate never closed. Compensating actions for PARTIAL must be specific enough to act on without
  reading any other file — though the Checkpoint Index provides supporting detail for agent-level status.

---

### Story 5: Recovery Workflow

- **As a** solo developer whose pipeline session crashed,
- **I want** to open `docs/CONTINUE.md` in a fresh Claude Code session and follow unambiguous instructions to resume the
  pipeline from the interrupted stage,
- **So that** I lose no more than one stage gate's worth of completed work, regardless of when the crash occurred.

- **Priority**: must-have
- **Pain points addressed**: P1 (exact resume command), P2 (flags recorded), P3 (parallel agent status), P4 (checkpoint
  filenames), P5 (mid-skeptic crash routing), P6 (update frequency), P7 (artifact integrity)

- **Acceptance Criteria**:
  1. Given a session crashed mid-pipeline, when I open a fresh session and read only `docs/CONTINUE.md`, then I can
     determine the exact resume command — including skill name, topic, and all non-default flags — from the Recovery
     Instructions section alone, without reading any other file.
  2. Given CONTINUE.md shows a stage as COMPLETE, when I run the resume command in a fresh session, then the pipeline's
     artifact detection skips that stage automatically — the Team Lead does not re-run completed stages.
  3. Given CONTINUE.md shows a stage as PARTIAL, when I follow the Compensating Action in the Stage Map, then the
     pipeline resumes from that stage without re-running any COMPLETE stage above it.
  4. Given CONTINUE.md shows `flags: "--full"`, when I read the Recovery Instructions, then the resume command includes
     `--full` explicitly — I do not have to recall the original invocation from memory.
  5. Given the Checkpoint Index shows `status: awaiting_review` for an agent, when the Team Lead resumes the pipeline,
     then it routes that agent's existing output to the skeptic — the writer agent is not re-spawned and no work is
     duplicated.
  6. Given the Checkpoint Index shows `status: in_progress` for an agent, when the Team Lead resumes the pipeline, then
     it re-spawns that agent using the checkpoint file path listed in the Checkpoint Index as context — the agent
     resumes from its last checkpoint, not from scratch.
  7. Given CONTINUE.md has a `run_id` field and a `heartbeat` timestamp, when I assess whether the snapshot applies to
     my intended session, then I compare `run_id` first: a mismatched `run_id` means the file is from a prior abandoned
     session, regardless of heartbeat age. If `run_id` matches, the `heartbeat` timestamp confirms when CONTINUE.md was
     last written; a heartbeat that predates the current session's start time indicates the Team Lead crashed before the
     most recent scheduled update.

- **Edge Cases**:
  - `docs/CONTINUE.md` does not exist (session crashed before initialization): no recovery document is available; user
    must re-run the pipeline from Stage 1. This is the existing fallback — no regression.
  - CONTINUE.md `run_id` does not match the intended session: user must not follow this file's recovery instructions for
    the new session; re-run from Stage 1 or locate the correct CONTINUE.md from git history.
  - CONTINUE.md shows a stage as PARTIAL but the artifact at the listed path has `status: approved` (manual edit or
    prior partial recovery): the Team Lead re-reads the artifact's actual frontmatter before acting — artifact
    frontmatter is ground truth over CONTINUE.md's Stage Map.
  - User runs resume command but all stages are COMPLETE: pipeline exits cleanly with a "pipeline already complete"
    message — no re-execution.
  - Session crashes inside Stage 1 before any stage gate closes: CONTINUE.md was written at initialization (Story 1) and
    updated at stage-begin (Story 2 AC-1). Stage 1 shows PARTIAL. Compensating action for Stage 1 PARTIAL is: re-spawn
    Stage 1 agents from scratch (no prior output to preserve).

- **Notes**: Story 5 is the integration story — its ACs exercise Stories 1-4 composing correctly. A CONTINUE.md that
  individually passes Stories 1-4 but fails Story 5 AC-1 is not acceptable. The whole-document human experience is the
  ultimate test.

---

## Non-Functional Requirements

- **Clarity**: Every sentence in CONTINUE.md must be clear, direct, concise, and unambiguous. No hedged language in the
  Compensating Action column. No vague verbs ("handle", "address", "deal with"). Use specific agent names, file paths,
  and status values.
- **Self-sufficiency**: The Recovery Instructions section must be self-contained. A reader with zero prior context — who
  has not read any other file — must be able to determine the resume command and the next action from Recovery
  Instructions alone.
- **Resume command format**: The exact resume command must be a single, copy-pasteable string on its own line, in a
  fenced code block. No prose wrapping it. No "something like" hedges.
- **Timestamp format**: All timestamps in CONTINUE.md must be ISO-8601 (e.g., `2026-04-03T00:10:00Z`). Human-readable
  and machine-parseable without transformation.
- **Atomic writes**: CONTINUE.md is always rewritten in full — never appended. A partial write is worse than a stale
  snapshot. Team Lead must treat the write as a single operation.
- **File path precision**: Every file path in CONTINUE.md (artifacts, checkpoint files) must be exact relative paths
  from the repository root. No glob patterns. No approximate paths. No directory references where a file path is
  required.

## Out of Scope

- **Runtime tooling**: No filesystem watchers, no automatic CONTINUE.md generation, no hooks. All behavior is SKILL.md
  prose instructing the Team Lead agent. No runtime changes.
- **Granular or utility skills**: Only pipeline skills (plan-product, build-product) produce CONTINUE.md. Granular
  skills (write-stories, run-task, etc.) and utility skills (setup-project) are excluded.
- **Git tracking policy**: Whether CONTINUE.md is committed or gitignored is not decided by this feature. CONTINUE.md is
  written to `docs/` but no git behavior is mandated.
- **Checksum or hash-based integrity**: No file hashing. Artifact integrity is signaled by `status != "draft"` in
  frontmatter — sufficient for a no-runtime, markdown-only environment.
- **Rollback of completed stages**: CONTINUE.md supports forward recovery only. Undoing or re-running a COMPLETE stage
  is out of scope.
- **Multi-user or concurrent session scenarios**: CONTINUE.md assumes a single operator and a single active session.
  Concurrent writes from multiple sessions are not supported.
- **Automatic re-invocation**: CONTINUE.md tells the user what to do. It does not automatically re-invoke the pipeline.
  The user types the resume command.
