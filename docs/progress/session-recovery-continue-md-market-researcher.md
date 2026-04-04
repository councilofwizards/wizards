---
feature: "session-recovery-continue-md"
team: "plan-product-b7e2"
agent: "market-researcher-b7e2"
phase: "research"
status: "complete"
last_action: "Findings compiled and submitted to Team Lead"
updated: "2026-04-03T00:00:00Z"
---

## Progress Notes

- [00:00] Task claimed. Began codebase research.
- [00:05] Read plan-product/SKILL.md and build-product/SKILL.md — extracted checkpoint protocol, failure recovery
  sections.
- [00:10] Read docs/CONTINUE.md (current), docs/progress/\_template.md, docs/roadmap/P1-02-state-persistence.md, sample
  progress checkpoint file.
- [00:20] Web searches completed: competitive AI frameworks, LangGraph checkpointing, distributed systems patterns,
  Claude Code session recovery issues.
- [00:30] Findings compiled and written. Submitting to Team Lead.

---

# RESEARCH FINDINGS: Session Recovery Mechanisms for AI Agent Orchestration

**Summary**: The Conclave plugin has a functional per-agent checkpoint system (docs/progress/ files with YAML
frontmatter) and pipeline-level resume logic, but lacks a continuously-updated, human-readable "mission brief" document
that lets a fresh session reconstruct the full orchestration context without first knowing which skill was running.
CONTINUE.md fills precisely this gap — no competitor solves it the same way, but LangGraph's thread-based state
persistence and Apache Flink's snapshot recovery offer strong design analogues.

---

## Key Facts

### Conclave's Existing Checkpoint Infrastructure

- **[HIGH]** Per-agent checkpoints: Every agent writes a progress file at `docs/progress/{topic}-{role}.md` with YAML
  frontmatter: `feature`, `team`, `agent`, `phase`, `status` (in_progress | blocked | awaiting_review | complete),
  `last_action`, `updated`. Plus a chronological Progress Notes log.
- **[HIGH]** Pipeline-level resume: When `plan-product` or `build-product` is invoked with no args, it scans
  `docs/progress/` for checkpoint files with matching `team` and `status` of `in_progress/blocked/awaiting_review`. If
  found, it re-spawns affected agents with checkpoint content as context.
- **[HIGH]** Artifact detection as recovery: Both pipeline skills use artifact frontmatter detection to skip completed
  stages. A stage with a valid artifact on disk is considered done — idempotent resumption.
- **[HIGH]** Three checkpoint frequencies: `every-step` (default), `milestones-only`, `final-only`. Coarser frequency
  means coarser recovery resolution.
- **[HIGH]** Context exhaustion recovery (existing): Team Lead reads the crashing agent's checkpoint file, re-spawns
  agent with checkpoint content as context. Protocol documented in Failure Recovery sections.
- **[HIGH]** P1-02 (State Persistence & Checkpoints) is **complete** — the checkpoint system was implemented and
  validated.

### Current CONTINUE.md (docs/CONTINUE.md — existing file)

- **[HIGH]** CONTINUE.md was written ONCE at session start by the Team Lead (this session). It contains: current state,
  completed/in-progress/not-started tasks, recovery instructions (4 steps), artifact locations table, team roster.
- **[HIGH]** Recovery instructions in current file: (1) Read context files, (2) Check agent progress files, (3) Invoke
  `/conclave:plan-product`, (4) Verify continuity post-resume.
- **[MEDIUM]** The current CONTINUE.md is a **static snapshot**, not continuously updated. If the session crashes
  mid-Stage 2, CONTINUE.md still shows "Stage 1 in progress" — stale guidance.
- **[HIGH]** This staleness is the core gap: CONTINUE.md needs to be updated at every significant state change by the
  Team Lead, not just written once at start.

### Gaps in Current System

- **[HIGH]** No single document bridges the gap between machine-readable per-agent checkpoints and the human operator
  who needs to know: "which skill was running, at what stage, and what exactly to do to resume."
- **[HIGH]** Pipeline resume works only if: (a) user re-invokes the correct skill, (b) checkpoint files exist with the
  right `team` field. If the user doesn't know which skill was running, auto-resume fails.
- **[MEDIUM]** Per-agent progress files are role-scoped — no aggregated view of the full pipeline state exists unless
  the Team Lead synthesizes it.
- **[MEDIUM]** SCAFFOLD comment in SKILL.md acknowledges recovery relies on "frequent checkpoints enable recovery" — but
  does not address the human-operator case where the skill itself cannot be re-invoked intelligently.
- **[LOW]** Cost summary files exist (`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`) but are
  post-session summaries, not mid-session recovery aids.

### Competitive Landscape

- **[HIGH] LangGraph**: Industry leader for stateful AI agent persistence. Every graph superstep produces a checkpoint.
  Resume is automatic: re-invoke with same `thread_id`, LangGraph loads last StateSnapshot and continues from next node.
  Partial-superstep recovery: stores writes from completed nodes at a failed superstep, so successful nodes are NOT
  re-run on resume. Pluggable backends: SQLite (local), Postgres (production), Redis (speed), CosmosDB (Azure). Also
  supports time-travel debugging and human-in-the-loop pause/resume.
- **[HIGH] CrewAI**: No built-in checkpointing for long-running workflows. Coarse error handling. Relies on user-level
  workarounds. The notable gap in the market — LangGraph dominates stateful recovery precisely because CrewAI doesn't
  support it.
- **[MEDIUM] AutoGen (AG2, v0.4)**: Event-driven, async-first architecture. Supports pluggable orchestration strategies.
  Specific checkpointing capabilities less documented — primarily focused on the event-driven runtime, not persistence.
- **[MEDIUM] OpenAI Swarm**: Lightweight, stateless by design. Intentionally does not persist state between invocations.
  Not designed for long-running session recovery.
- **[LOW] AutoGPT**: Earlier generation (2023-2024). Had file-based memory and command history, but no formal checkpoint
  protocol. Legacy.
- **[HIGH] Claude Code itself (anthropics/claude-code#27419, #40286)**: Active feature requests from users for graceful
  context exhaustion recovery. Proposed pattern: output a handoff.md or summary at context exhaustion, user manually
  appends to new session prompt. Not yet shipped as built-in behavior.

### Distributed Systems Analogues

- **[HIGH] Apache Flink checkpointing**: Periodic snapshots of full application state. On failure, Flink restarts
  operators from last checkpoint, NOT from the beginning. Stream barriers injected into data flow delineate checkpoint
  boundaries — the Conclave equivalent is stage boundaries. Exactly-once semantics via incremental snapshots.
- **[HIGH] Saga pattern**: Long-running distributed transactions split into sequential compensating steps. Each step is
  idempotent and reversible. Maps directly to Conclave's stage pipeline: if Stage 3 fails, Stages 1-2 artifacts are
  preserved; re-run resumes at Stage 3.
- **[MEDIUM] Event sourcing**: Event log is the source of truth; state is reconstructed by replaying events. The
  Conclave analogue: Progress Notes in checkpoint files are the event log; Team Lead reconstructs full pipeline state by
  reading all agent progress files.
- **[MEDIUM] Write-ahead log (WAL)**: Database pattern — write intent to durable log BEFORE executing. Maps to
  Conclave's "checkpoint after claiming a task" — the intent is logged before the work starts.

---

## Inferences

1. **CONTINUE.md should be updated by the Team Lead at every stage transition** (not just at session start). This
   transforms it from a static snapshot into a live mission brief — the Conclave equivalent of LangGraph's
   StateSnapshot.

2. **The file should be self-sufficient**: A reader with zero prior context should be able to read CONTINUE.md and know:
   what skill was running, what stage we're at, what each agent was doing, which artifacts exist, and exactly what
   commands to run to resume. The current version is close but incomplete on agent-level status.

3. **CONTINUE.md is not a replacement for per-agent checkpoints** — it's the aggregation layer above them. The same
   relationship as a saga coordinator to individual saga steps.

4. **Continuous-update protocol is the critical design decision**: The Team Lead should write CONTINUE.md after: session
   start, each stage completion, any agent failure/block, each skeptic gate outcome. Same triggers as agent-level
   checkpoints but at pipeline scope.

5. **LangGraph's thread_id maps to Conclave's topic+team fields** in checkpoint frontmatter. The gap is that LangGraph
   makes resumption automatic via thread_id; Conclave requires the human to re-invoke the right skill. CONTINUE.md
   closes this gap by telling the human exactly what to invoke.

6. **The Claude Code context exhaustion pattern (issue #27419) directly validates CONTINUE.md's value**: The community
   is asking for exactly what CONTINUE.md provides — a handoff document written before context is exhausted, usable to
   bootstrap a new session.

---

## Data Gaps

- **[GAP]** No data on how often real plan-product/build-product sessions crash mid-run vs. complete successfully. This
  would quantify the actual recovery frequency.
- **[GAP]** AutoGen (AG2) v0.4 specific checkpointing/persistence documentation was limited in search results — cannot
  confirm whether it has a formal checkpoint API comparable to LangGraph.
- **[GAP]** LangGraph time-travel debugging (replay from arbitrary past checkpoint) — unclear whether a Conclave
  analogue would be valuable or overengineered for current needs.
- **[GAP]** No data on how users currently discover that a session crashed vs. completed successfully — whether they
  check progress files, look for artifacts, or just re-invoke and let detection figure it out.
- **[GAP]** CONTINUE.md update frequency trade-off: too frequent updates add Team Lead overhead and context cost; too
  infrequent leaves stale state. No empirical data on the right cadence.
