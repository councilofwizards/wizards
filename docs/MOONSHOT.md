# MOONSHOT: Asynchronous Agent Swarm Architecture

> Status: Exploratory research. No implementation planned yet. Date: 2026-04-04

## The Vision

Replace batch-synchronous phase-gated orchestration with a streaming pipeline where independent Claude Code instances
operate as autonomous workers coordinated through a shared work queue. Instead of "everyone finishes Phase N before
Phase N+1 starts," work items flow continuously through stages, and agents pull from queues independently.

A planning pipeline produces specs. Engineers consume them as they appear. Reviewers gate completed work as it arrives.
Nothing waits. Nothing sits idle. Scale by opening more terminals.

## Terminology

Several established paradigms describe aspects of this architecture:

- **Pipeline parallelism**: Different stages process different items concurrently — like CPU instruction pipelining.
  Stage 2 works on Item A while Stage 1 works on Item B. Distinct from _data parallelism_ (the current model, where N
  reviewers all work the same stage on the same item).
- **Asynchronous producer-consumer**: Architects produce specs into a queue, engineers consume them as available.
  Decouples production rate from consumption rate.
- **Kanban flow**: Work items move through columns (Planned, Specced, Building, Reviewing), and workers pull from their
  column's queue rather than being pushed work in lockstep.
- **Work-stealing**: Idle workers claim the next available item from a shared queue. No central dispatcher assigns work
  — agents are self-scheduling.
- **Swarming** (from agile): Agents converge on whatever's ready, rather than waiting for a synchronized phase gate.

The contrast with the current conclave architecture: current skills use **batch-synchronous phases** — all agents finish
Phase N before anyone starts Phase N+1. This moonshot proposes **streaming pipeline execution** — work items flow
continuously through stages, and agents pull from queues independently.

---

## Part 1: Claude Code Harness Capabilities

### What Exists Today

#### Agent Teams (TeamCreate + Agent with team_name)

- `TeamCreate` creates a namespace that acts as the coordination hub.
- `Agent` with `team_name` spawns a separate Claude Code process as a teammate.
- Each teammate is a fully independent Claude Code session with its own context window.
- Agents run in parallel when spawned concurrently. The review-pr skill already runs 9 parallel agents successfully.
- No documented hard limit on concurrent agents. Practical constraints are token cost and coordination overhead.
  Recommended: 3-5 teammates for most workflows.

#### Background Agents (run_in_background)

- `run_in_background: true` launches a subagent that executes independently; the parent does not block.
- The parent can launch more background agents while others are running.
- **Critical limitation**: Background agents cannot write or edit files. All permission prompts are auto-denied.
  Background agents are safe only for read-only research, monitoring, and dev servers.

#### SendMessage (Inter-Agent Communication)

- Agents send messages via `SendMessage` with two modes: direct (point-to-point) and broadcast (all teammates).
- Messages are stored as JSON files in the team's inbox directory.
- Delivery is automatic — agents don't need to poll for messages.
- Any teammate can message any other teammate by name (peer-to-peer, not just lead-to-agent).
- Not a pub/sub event bus — no guaranteed ordering, no topic subscriptions.

#### TaskCreate / TaskGet / TaskUpdate (Work Coordination)

- Tasks are JSON files with fields: ID, subject, description, status (pending/in_progress/ completed/deleted), owner,
  dependency edges.
- All operations persist to disk immediately.
- Tasks support dependency graphs — a pending task with unresolved dependencies cannot be claimed until prerequisites
  complete.
- File locking prevents race conditions when multiple agents try to claim the same task.
- Can serve as a primitive work queue within a single Agent Teams session.

#### Filesystem Coordination

- Agents in the same worktree see each other's file writes on the next tool call (near-instant, not real-time
  mid-execution).
- Two agents editing the same file leads to overwrites — one agent's edits will be lost.
- Role-scoped file ownership (each agent writes only to its own files) prevents conflicts.
- This is the existing pattern in all conclave skills.

#### Other Primitives

- `/loop` skill: Runs a prompt or skill on a recurring interval (e.g., `/loop 5m /foo`). Defaults to 10 minutes.
- `CronCreate`: Schedules remote triggers that execute on a cron schedule.
- `gh` CLI: Full GitHub API access for issues, PRs, labels, assignments.
- `isolation: worktree`: Gives an agent an isolated copy of the repository. Agents in separate worktrees cannot see each
  other's file writes.

### What Does Not Exist (Gaps)

| Missing Primitive           | Impact                                                                                                  | Possible Workaround                                                                                                    |
| --------------------------- | ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| Persistent/looping agents   | Agents are single-shot. A worker can't sit idle waiting, then wake up when work appears.                | Lead re-spawns agents, or agents self-drain a task list in one invocation, or `/loop` provides external re-invocation. |
| Event-driven triggers       | No "when a file appears, wake Agent X." Only polling.                                                   | Agents poll checkpoint files, or the lead polls and dispatches, or `/loop` provides periodic polling.                  |
| Shared mutable state        | No atomic read-modify-write across agents. TaskCreate has file locking, but custom state doesn't.       | Convention-based file ownership, or external coordination (GitHub Issues, shared directory with atomic rename).        |
| Dynamic team scaling        | Can't add agents to a running team mid-execution based on queue depth.                                  | Pre-spawn a fixed pool, or have the lead spawn new agents when it detects queue growth.                                |
| Cross-instance coordination | Agent Teams are scoped to one Claude Code session. Separate CLI instances don't share a team namespace. | File-based or GitHub-based coordination between independent instances.                                                 |

---

## Part 2: Architecture Options

### Architecture A: Single-Instance Swarm (Agent Teams)

One Claude Code instance acts as lead/scheduler. It spawns and manages all agents via Agent Teams.

```
┌─────────────────────────────────────────────────┐
│  Lead (Scheduler Loop)                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │Architect │  │Architect │  │ Planner  │      │
│  │  Agent   │  │  Agent   │  │  Agent   │      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
│       │              │              │            │
│       ▼              ▼              ▼            │
│  ┌─────────────────────────────────────────┐    │
│  │         Task Queue (TaskCreate)         │    │
│  └─────────────────────────────────────────┘    │
│       │              │              │            │
│       ▼              ▼              ▼            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │Engineer  │  │Engineer  │  │Engineer  │      │
│  │  Agent   │  │  Agent   │  │  Agent   │      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
│       │              │              │            │
│       ▼              ▼              ▼            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │Reviewer  │  │Reviewer  │  │Reviewer  │      │
│  │  Agent   │  │  Agent   │  │  Agent   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
└─────────────────────────────────────────────────┘
```

**How it works:**

1. Lead maintains a task queue via TaskCreate.
2. Spawns producer agents (planners, architects) that create work items.
3. As producers complete items, lead spawns consumer agents (engineers) to claim them.
4. As engineers complete, lead spawns reviewers.
5. Lead loops: poll task list, spawn agents for ready work, wait for completions, repeat.

**Strengths:**

- Uses existing Agent Teams primitives directly.
- TaskCreate dependency tracking handles ordering.
- File locking on task claims prevents double-work.
- All within one session — simpler to reason about.

**Weaknesses:**

- **Lead is a bottleneck.** Its context window fills with coordination overhead, not useful work. With 12+ agents, the
  lead spends most tokens on orchestration.
- **Single point of failure.** If the lead's context degrades or the session dies, everything stops.
- **No true asynchrony between stages.** The lead must explicitly decide when to spawn the next wave of agents. It's
  still phase-gated, just with smaller phases.
- **Background write limitation.** Agents that need to write files must run in foreground, meaning the lead blocks on
  them. This limits true concurrency.

**Verdict:** Incremental improvement over current batch-synchronous model. Not a paradigm shift.

---

### Architecture B: Multi-Instance with Shared Filesystem

Multiple independent Claude Code instances coordinate through a shared directory outside any repository.

```
~/work-queue/                          (shared, outside any repo)
  ready/
    item-001-auth-api.md
    item-002-dashboard.md
  claimed/
    item-003-billing.md
  in-progress/
    item-004-notifications.md
  review/
    item-005-search.md
  done/
    item-006-onboarding.md

Terminal 1 ── Producer Instance ─────── own repo clone, own test domain
Terminal 2 ── Worker A Instance ─────── own repo clone, own test domain
Terminal 3 ── Worker B Instance ─────── own repo clone, own test domain
Terminal 4 ── Reviewer Instance ─────── own repo clone, own test domain
```

**How it works:**

1. Producer instance runs the planning pipeline (research, ideation, spec). As each spec is ready, it writes a work item
   file to `~/work-queue/ready/`.
2. Worker instances poll `ready/` for items. To claim one, they rename (move) it to `claimed/`. Filesystem rename is
   atomic on macOS APFS — first mover wins, second gets an error.
3. Worker moves the item to `in-progress/`, builds the feature in its own repo clone, runs tests against its own domain,
   commits, pushes a branch, then moves the item to `review/`.
4. Reviewer instance polls `review/`, picks up items, runs review-pr against the branch, and either moves to `done/`
   (approved) or back to `ready/` with feedback appended.

**Claim mechanism — atomic rename:**

```bash
mv ~/work-queue/ready/item-001-auth-api.md ~/work-queue/claimed/item-001-auth-api.md
# If two workers race, one succeeds and one gets "No such file" — safe.
```

**Strengths:**

- **No lead bottleneck.** Each instance is fully autonomous with its own context window.
- **True isolation.** Each worker has its own repo clone and test environment. No write conflicts, no file contention on
  application code.
- **Horizontally scalable.** Add workers by opening more terminals. Remove them by closing terminals.
- **Fault tolerant.** If Worker A dies, its in-progress item can be reclaimed (move back to `ready/` after a timeout).
- **Zero git overhead on coordination.** The queue is just a filesystem directory. No push/pull cycle for claiming work.

**Weaknesses:**

- **Local-only.** The shared directory exists on one machine. Can't distribute across machines without something like
  NFS or syncthing.
- **No audit trail.** File moves don't leave history. You'd need to add logging.
- **Worker context bootstrapping.** Each worker needs enough context to build a feature from a spec file alone. The work
  item must be self-contained.
- **Rename atomicity through Claude Code.** The Bash tool adds a layer over direct filesystem calls. Needs testing to
  confirm the `mv` command preserves atomicity guarantees.
- **No remote visibility.** Can't check the queue from your phone or another machine.

**Verdict:** Clean, simple, fast. Best for solo-developer local workflows where you want maximum throughput from one
machine.

---

### Architecture C: Multi-Instance with GitHub Issues as Queue

Multiple independent Claude Code instances coordinate through GitHub Issues. The GitHub API provides atomic operations,
audit trails, and remote visibility.

```
GitHub Issues (label: work-queue)
  ┌─────────────────────────────────────────────────┐
  │ #42 Build: auth API          [ready]            │
  │ #43 Build: user dashboard    [ready]            │
  │ #44 Build: billing webhook   [claimed] @worker-a│
  │ #45 Build: notifications     [in-progress]      │
  │ #46 Build: search            [needs-review]     │
  │ #47 Build: onboarding        [done]             │
  └─────────────────────────────────────────────────┘

Terminal 1 ── Producer ─── creates issues with [ready] label
Terminal 2 ── Worker A ─── claims by self-assigning, removes [ready], adds [claimed]
Terminal 3 ── Worker B ─── same pattern, grabs whatever's unassigned
Terminal 4 ── Reviewer ─── polls [needs-review], reviews PR, moves to [done] or back
```

**How it works:**

1. Producer runs the planning pipeline. For each completed spec, it creates a GitHub Issue:
   ```bash
   gh issue create \
     --title "Build: auth API" \
     --label "work-queue,ready" \
     --body "$(cat spec-content.md)"
   ```
2. Worker polls for unclaimed work:
   ```bash
   gh issue list --label "work-queue,ready" --no-assignee --limit 1 --json number,title
   ```
3. Worker claims by self-assigning and updating labels:
   ```bash
   gh issue edit 42 --add-label "claimed" --remove-label "ready" --add-assignee "@me"
   ```
4. Worker builds in its own repo clone, pushes a branch, creates a PR linked to the issue:
   ```bash
   gh pr create --title "Build: auth API" --body "Closes #42"
   ```
5. Reviewer polls for PRs needing review:
   ```bash
   gh pr list --label "needs-review" --json number,title,url
   ```
6. Reviewer runs review, then either approves (label `done`, close issue) or requests changes (label back to `ready`,
   comment with feedback, unassign).

**Strengths:**

- **Atomic operations.** GitHub's API handles concurrent assignment — no filesystem races, no git merge conflicts on
  queue state.
- **Built-in state machine.** Labels replace directory-based status tracking. Easy to add new states (blocked,
  needs-clarification, high-priority).
- **Audit trail for free.** Every label change, assignment, and comment is timestamped and attributed. Full history on
  each issue.
- **Remote-native.** Works across machines. Check the queue from your phone. Share with collaborators.
- **Human-visible dashboard.** The Issues tab is a real-time view of the swarm's state. Filter by label, sort by
  priority, manually intervene at any time.
- **Comments as coordination channel.** Workers post progress updates, reviewers post feedback, producers post
  clarifications — all threaded on the issue.
- **Already in the toolkit.** `gh` CLI is first-class in Claude Code. No new infrastructure.
- **Natural PR flow.** Workers produce PRs linked to issues. The existing review-pr skill can review them. GitHub's
  merge machinery handles the rest.

**Weaknesses:**

- **API rate limits.** GitHub API has rate limits (5,000 requests/hour for authenticated users). Frequent polling by
  multiple workers could approach this. Mitigation: poll every 2-3 minutes, not continuously.
- **Latency.** GitHub API calls are slower than local filesystem operations. Claiming an item takes a network round-trip
  instead of a local rename.
- **Issue body size limits.** GitHub Issues have a 65,536-character body limit. Large specs may need to reference a file
  in the repo rather than embedding the full content.
- **Label-based state is informal.** Nothing prevents a human (or buggy worker) from putting an issue in an invalid
  state (e.g., both `ready` and `claimed` labels). Needs conventions.
- **Requires a GitHub repo.** Not suitable for fully local/offline workflows.

**Verdict:** The most robust option. Best for workflows that benefit from visibility, auditability, and the option to
scale across machines or add human participants.

---

### Architecture D: Hybrid (GitHub Issues + Local Clones + Spec Files in Repo)

Combines the coordination strength of GitHub Issues with the context richness of spec files committed to the repository.

```
GitHub Issues ─── coordination, state, assignment
Repository ────── specs, implementation, reviews
Local Clones ──── isolation per worker

Producer writes specs to repo AND creates issues referencing them:
  Issue #42: "Build: auth API"
    Body: "Spec: docs/specs/auth-api/spec.md (commit abc123)"
    Labels: [work-queue, ready]

Worker clones repo, finds assigned issue, reads spec from referenced path, builds.
```

**How it works:**

1. Producer runs the planning pipeline. Commits spec files to the repo. Creates a GitHub Issue per spec that references
   the file path and commit SHA.
2. Workers poll for unassigned issues, claim one, then `git pull` their clone to get the latest specs.
3. Workers read the spec from the referenced file path, build the feature, push a branch, create a PR linked to the
   issue.
4. Reviewers review the PR (not just the issue). On approval, the PR is merged and the issue is closed.

**Why the commit SHA matters:** The spec might evolve after the issue is created (producer continues planning). The SHA
pins the worker to a specific version of the spec. If the spec is updated, the producer can comment on the issue with
the new SHA.

**Strengths:**

- All the GitHub Issues strengths (atomic coordination, audit trail, remote visibility).
- Specs live in version control with full history. Richer than what fits in an issue body.
- Workers get structured, validated specs (YAML frontmatter, acceptance criteria) not just free-text issue descriptions.
- Natural integration with existing conclave artifact contracts.

**Weaknesses:**

- More moving parts. Producer must commit specs AND create issues. Workers must pull AND check issues.
- Git pull before each work item adds latency and potential merge conflicts on the worker's clone (though only on the
  specs directory, not application code).

**Verdict:** The best long-term architecture if specs are complex and benefit from version control. The most
infrastructure, but also the most capable.

---

## Part 3: Cross-Cutting Concerns

### Worker Looping Strategies

Agents are single-shot by design. Four approaches to create continuous workers:

| Strategy               | Mechanism                                                           | Pros                                                            | Cons                                                                     |
| ---------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `/loop` skill          | External re-invocation on interval                                  | Simple, already exists, configurable interval                   | Each iteration is a fresh context — no memory of previous work           |
| Prompt-based self-loop | "After completing a work item, check for more. Repeat until empty." | Maintains context across items — can learn from previous builds | Context window degrades over many iterations; eventually loses coherence |
| `CronCreate`           | Scheduled remote trigger                                            | Stateless, survives terminal closure, cloud-native              | Each invocation is fully independent; no local state                     |
| Manual re-invocation   | User runs the worker skill again when items pile up                 | Most controlled, zero overhead                                  | Requires human attention; defeats the automation purpose                 |

**Recommendation:** `/loop` for prototyping (simple, immediate). `CronCreate` for production (resilient, stateless).
Prompt-based self-loop for short bursts (3-5 items where cross-item context helps).

### Context Window Degradation

A worker processing multiple items in one session accumulates context: previous specs, build outputs, error messages,
tool results. After 3-5 items, the context window starts compressing early messages, losing nuance.

**Mitigations:**

- Stateless workers (one item per invocation via `/loop` or `CronCreate`) sidestep this entirely.
- For self-looping workers, include a "context reset" instruction: "After completing an item, summarize what you learned
  in a checkpoint file and start the next item fresh."
- Monitor token usage per iteration. If it exceeds a threshold, the worker should stop and let a fresh invocation take
  over.

### Race Conditions by Architecture

| Architecture          | Race Condition                                          | Mitigation                                                         |
| --------------------- | ------------------------------------------------------- | ------------------------------------------------------------------ |
| A (Single-instance)   | TaskCreate file locking handles it                      | Built-in                                                           |
| B (Shared filesystem) | Two workers `mv` the same file simultaneously           | Atomic rename on APFS; loser gets ENOENT; retry with next item     |
| C (GitHub Issues)     | Two workers assign themselves to the same issue         | GitHub API is atomic on assignment; second call sees it's assigned |
| D (Hybrid)            | Same as C for coordination; git conflicts on spec pulls | Pull before each item; specs are read-only for workers             |

### Work Item Self-Sufficiency

For any architecture, the work item must contain enough context for a worker to operate without asking questions.
Minimum viable work item:

```yaml
---
title: Build auth API
priority: P1
spec_ref: docs/specs/auth-api/spec.md # or inline content
acceptance_criteria:
  - JWT-based authentication with refresh tokens
  - Rate limiting at 100 req/min per user
  - Integration tests against test database
file_targets:
  - app/Http/Controllers/AuthController.php
  - app/Services/AuthService.php
  - tests/Feature/AuthTest.php
dependencies:
  - "User model exists (item-001)"
test_domain: https://worker-a.test.example.com
branch_convention: "swarm/item-{number}-{slug}"
---
```

### Merge Strategy

When multiple workers produce PRs concurrently, merge order matters:

- **Option 1: Sequential merge with rebase.** Reviewer merges one PR at a time. Each subsequent PR must rebase onto the
  updated main. Safe but slow.
- **Option 2: Feature flags.** Workers build behind feature flags. All PRs merge independently. Flags are enabled after
  integration testing. Fast but adds flag management overhead.
- **Option 3: Integration branch.** Workers merge into a shared integration branch. After all items in a batch are
  merged, the integration branch is merged to main. Balanced approach.
- **Option 4: Stacked PRs.** Workers build in dependency order. PR 2 is based on PR 1's branch. Review and merge in
  order. Works well when dependencies are linear.

### Failure Handling

Workers can fail mid-task (context exhaustion, API errors, bad specs). Recovery protocol:

1. **Timeout detection.** If a work item has been `in-progress` for longer than a threshold (e.g., 30 minutes), it's
   considered stalled.
2. **Reclaim.** A coordinator (human or automated) moves the item back to `ready` and unassigns it.
3. **Partial work preservation.** The failed worker's branch and commits remain. The next worker can pick up from the
   branch rather than starting fresh.
4. **Feedback loop.** If an item fails twice, escalate: add a `needs-human` label and stop auto-assigning.

---

## Part 4: Recommended Prototype Path

### Phase 0: Validate Primitives

Before building a skill, manually test the critical assumptions:

1. **Atomic rename through Bash tool.** Open two Claude Code instances. Have both attempt to `mv` the same file
   simultaneously. Confirm one succeeds and one fails cleanly.
2. **`/loop` with a skill.** Run `/loop 2m` with a simple skill that reads a directory and logs what it finds. Confirm
   it re-invokes reliably.
3. **`gh` CLI claim cycle.** Manually create an issue with `gh`, have a Claude Code instance claim it via
   `gh issue edit`, confirm the state change is visible to a second instance.
4. **Cross-clone visibility.** Have one instance commit+push a spec file. Confirm another instance (in a different
   clone) can pull and read it within one polling cycle.

### Phase 1: Two-Terminal Prototype

Minimal viable swarm — one producer, one consumer:

- Terminal 1: Run a simplified planning skill that writes 3 work items to GitHub Issues.
- Terminal 2: Run a worker loop that polls for issues, claims one, creates a branch, makes a trivial change (e.g.,
  creates a placeholder file), pushes, opens a PR.

Success criteria: Worker picks up all 3 items sequentially without human intervention. No race conditions (only one
worker, so none possible). PRs are created and linked to issues.

### Phase 2: Multi-Worker Race Testing

Add a second worker terminal. Both poll the same queue.

Success criteria: 3 items distributed across 2 workers without double-claims. All 3 PRs created. No conflicts.

### Phase 3: Full Pipeline

Add a reviewer terminal. Workers produce PRs, reviewer reviews them.

Success criteria: End-to-end flow from spec creation to reviewed PR, with 2+ workers operating concurrently.

### Phase 4: Skill Codification

Write the SKILL.md files:

- `swarm-producer` — a planning pipeline that outputs to the work queue.
- `swarm-worker` — a build loop that polls, claims, builds, and submits.
- `swarm-reviewer` — a review loop that polls for completed work and gates it.

These would be a new pattern category: **Swarm skills** — designed to be run as independent instances coordinated
through an external queue, not as Agent Teams within a single session.

---

## Part 5: Cost and Throughput Analysis

### Token Economics

Each concurrent Claude Code instance consumes its own token budget independently:

| Configuration                          | Concurrent Contexts          | Relative Token Cost   | Throughput Model                     |
| -------------------------------------- | ---------------------------- | --------------------- | ------------------------------------ |
| Current (batch-sync)                   | 1 lead + N agents per phase  | ~(N+1)x per phase     | Serial phases, parallel within phase |
| Architecture A (single-instance swarm) | 1 lead + N agents continuous | ~(N+1)x continuous    | Lead bottleneck limits throughput    |
| Architecture B/C/D (multi-instance)    | M independent instances      | Mx (no lead overhead) | Linear scaling, no bottleneck        |

**Key insight:** Multi-instance architectures eliminate the lead's context overhead. In a 12-agent single-instance team,
the lead might spend 40-60% of its tokens on coordination. In a multi-instance swarm, 100% of each instance's tokens go
to productive work.

### When Swarm Wins

Pipeline parallelism only outperforms batch-synchronous when:

1. **Multiple independent work items** exist to pipeline. A single feature doesn't benefit — the pipeline has throughput
   of one.
2. **Stages have similar duration.** If spec-writing takes 5 minutes but building takes 30, the pipeline is bottlenecked
   at the build stage regardless. Add more engineer instances to balance.
3. **Items are independent or weakly coupled.** Tightly coupled features that share interfaces can't be built in
   parallel without contract negotiation overhead.
4. **Token budget is not the binding constraint.** 4 concurrent instances burn 4x the tokens. If the goal is to minimize
   cost, sequential is always cheaper.

### When Batch-Sync Wins

- Single complex feature with tightly coupled components.
- Token budget is constrained.
- Human oversight is needed at each phase gate.
- The team has 3 or fewer work items.

---

## Part 6: Relationship to Current Conclave Architecture

This moonshot does not replace existing conclave skills. It layers on top of them:

- **Existing skills** remain the unit of work. A `swarm-worker` would invoke `build-implementation` or `craft-laravel`
  to actually build a feature.
- **Existing pipelines** (plan-product, build-product) remain useful for single-feature deep dives where
  batch-synchronous is the right model.
- **The swarm layer** is a new coordination tier that distributes multiple work items across multiple instances, each of
  which uses existing skills internally.

```
┌──────────────────────────────────────────────┐
│           Swarm Coordination Layer           │
│  (GitHub Issues, /loop, multi-instance)      │
├──────────────────────────────────────────────┤
│         Existing Conclave Skills             │
│  (plan-product, build-implementation, etc.)  │
├──────────────────────────────────────────────┤
│         Claude Code Harness                  │
│  (Agent Teams, TaskCreate, SendMessage)      │
└──────────────────────────────────────────────┘
```

The swarm layer answers: "Which work item should this instance do next?" The skill layer answers: "How should this
instance do it?" The harness layer answers: "What tools does this instance have?"
