---
feature: "session-recovery-continue-md"
team: "plan-product-b7e2"
agent: "customer-researcher"
phase: "research"
status: "complete"
last_action: "Findings complete. Submitted to Team Lead."
updated: "2026-04-03T00:00:00Z"
---

## Progress Notes

- [00:00] Task claimed. Read persona file, CONTINUE.md, plan-product/SKILL.md (Checkpoint Protocol, Failure Recovery,
  Determine Mode).
- [00:10] Read build-product/SKILL.md checkpoint/recovery sections. Read docs/progress/\_template.md.
- [00:20] Scanned failure recovery sections across plan-product, build-implementation, run-task, create-conclave-team.
- [00:25] Read real session progress files: conclave-plugin-improvements-customer-researcher.md,
  plan-product-multi-track-2026-03-27-summary.md, state-persistence.md.
- [00:30] Synthesized findings. Writing to this file.

---

## CUSTOMER FINDINGS: Session Recovery User Needs

**Summary**: The primary user is a solo developer running multi-stage, multi-agent pipeline skills that can involve 9+
agents, 5 sequential stages, and hours of accumulated work. When the chat session crashes, the existing checkpoint
infrastructure captures individual agent state, but lacks a consolidated, human-actionable recovery document that
surfaces the exact resume command, original invocation flags, and parallel-agent completion status in one place.

---

## Key Facts

- **[HIGH confidence]** The user is a solo developer/founder. One verified data point from multi-track session: 15
  agents deployed, 16 roadmap items planned in a single session. Session crashes carry catastrophic context loss risk.
- **[HIGH confidence]** User's explicit requirement: "My goal is disaster recovery in case this chat dies." Verbiage
  must be "clear, direct, concise, and unambiguous."
- **[HIGH confidence]** Existing checkpoint infrastructure writes YAML-frontmatter progress files per agent per role:
  fields `feature`, `team`, `agent`, `phase`, `status`, `last_action`, `updated`, plus timestamped Progress Notes.
- **[HIGH confidence]** Determine Mode already has resume logic: scan `docs/progress/` for `team: "plan-product"` files
  with `status: in_progress|blocked|awaiting_review` and re-spawn agents from checkpoint. This is automatic on
  empty-args invocation.
- **[HIGH confidence]** Artifact detection via frontmatter runs on every invocation: FOUND/STALE/INCOMPLETE/NOT_FOUND
  per stage. Completed stages are automatically skipped.
- **[HIGH confidence]** Run IDs are appended to team and agent names (e.g., `plan-product-b7e2`). A new session
  generates a new run ID, meaning auto-resume must match on `team: plan-product` (prefix), not exact team name.
- **[HIGH confidence]** Failure Recovery sections exist in SKILL.md files but address agent-to-agent failures only
  (unresponsive agents, skeptic deadlocks, context exhaustion). They do NOT address human-initiated recovery from a dead
  chat session.
- **[HIGH confidence]** The existing CONTINUE.md (written by Team Lead at session start) already includes: phase/stage,
  completed/in-progress/not-started task list, step-by-step recovery instructions, artifact location table, and team
  roster. This is the right concept but needs gap-filling.
- **[MEDIUM confidence]** Checkpoint frequency defaults to `every-step`, meaning agents write after claiming a task,
  completing a deliverable, receiving feedback, and finishing. On a crashed session, granular checkpoints exist per
  agent.
- **[MEDIUM confidence]** Real session data (multi-track 2026-03-27) shows skeptic rejections happen regularly (e.g.,
  batch rejections on story review). A crash mid-skeptic-review is a realistic scenario.

---

## Pain Points (Ranked by Severity)

### P1 — CRITICAL: No exact resume command in CONTINUE.md

The existing CONTINUE.md says "invoke `/conclave:plan-product`" but does not specify the exact topic argument.
Auto-detection works _if_ the checkpoint files are unambiguous, but multiple prior sessions may match. The user is left
guessing or re-reading checkpoint files themselves. A crash on a named topic (e.g., `session-recovery-continue-md`)
requires `/conclave:plan-product session-recovery-continue-md` — this precision is absent from the current draft.

### P2 — HIGH: Original invocation flags not recorded

If the session was started with `--full`, `--complexity=complex`, or `--checkpoint-frequency=milestones-only`, the
resuming session must use the same flags to maintain consistent behavior. The current CONTINUE.md records none of these.
A user re-invoking with default flags after a `--full` session gets a materially different pipeline.

### P3 — HIGH: Parallel agent status ambiguity

Stage 1 runs market-researcher and customer-researcher in parallel. If the session crashes with one agent complete and
one mid-task, the CONTINUE.md must clearly state _which_ agent finished and which didn't. The current format shows both
as "spawning" at session start — it doesn't reflect mid-stage completion state.

### P4 — HIGH: Checkpoint file naming is not surfaced

The recovery instructions say "read docs/progress/session-recovery-_-_.md files" but the user must know the naming
convention matches `{topic}-{role}.md`. If the topic slug contains hyphens (as it does: `session-recovery-continue-md`),
the glob pattern may not match expected files. The exact filenames should be listed explicitly.

### P5 — MEDIUM: Skeptic-mid-review crash leaves no recovery anchor

If the session crashes after the story-writer submits stories to the product-skeptic but before the skeptic responds,
there is no checkpoint from the skeptic (it wasn't active yet) and the story-writer's checkpoint says `awaiting_review`.
On resume, the CONTINUE.md should specify: re-route the existing draft directly to the product-skeptic rather than
re-running the story-writer from scratch.

### P6 — MEDIUM: Team Lead CONTINUE.md update frequency is undefined

The CONTINUE.md is written once at session start. If the Team Lead does NOT update it after each stage, the file becomes
stale. The user reading CONTINUE.md after a mid-Stage-3 crash sees Stage 1 and 2 still marked "not started" in the
artifact table. The protocol must mandate Team Lead updates to CONTINUE.md after each stage completes.

### P7 — LOW: No artifact integrity signal

After a crash mid-write, an artifact may exist on disk with `status: draft` in frontmatter. The recovery steps should
include: re-read each artifact path listed in the table and verify `status != "draft"` before trusting the "FOUND"
detection. The current CONTINUE.md does not flag this.

---

## Inferences

- **[HIGH confidence]** The user's primary fear is losing hours of accumulated work from a 5-stage pipeline. The
  emotional driver is "I don't want to start over." CONTINUE.md must project confidence: "Here is exactly what to do and
  nothing is lost."
- **[MEDIUM confidence]** The user reads CONTINUE.md under stress (after a crash). Brevity and unambiguous commands
  matter more than completeness. A numbered list of shell commands is more actionable than prose paragraphs.
- **[MEDIUM confidence]** Auto-resume (empty-args invocation scanning checkpoints) works well for in-progress agent
  state, but fails when the user needs to know _why_ a stage was incomplete — a human-readable state narrative in
  CONTINUE.md bridges that gap.
- **[LOW confidence]** The user may eventually add CONTINUE.md to `.gitignore` or treat it as ephemeral. The design
  should assume CONTINUE.md is always overwritten at session start and incrementally updated mid-session — not preserved
  across runs.

---

## Data Gaps

- No evidence of whether the user has ever successfully recovered from a mid-session crash using the existing checkpoint
  infrastructure. Cannot determine how well the auto-resume logic actually works in practice.
- No data on how often sessions crash vs. run to completion. Frequency unknown.
- No evidence of whether the user invokes skills with `--full` or `--complexity` flags. Cannot confirm which edge-case
  flag scenarios are actually relevant.
- Cannot determine whether CONTINUE.md is intended to survive git commits (i.e., is it checked in or gitignored). This
  affects whether "read CONTINUE.md" is always valid advice.
