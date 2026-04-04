---
agent: idea-evaluator
topic: session-recovery-continue-md
status: waiting-for-ideas
checkpoint: task-claimed
updated: "2026-04-03"
---

# Idea Evaluator Progress: session-recovery-continue-md

## Identity

**Agent**: Dorin Ashveil, Arbiter of Worth **Role**: Evaluate and rank design ideas for the CONTINUE.md disaster
recovery protocol

## Checkpoint Log

- [2026-04-03T00:05Z] Task claimed. Research artifact read. Awaiting idea-generator output.
- [2026-04-03T00:25Z] Ideas received (7 ideas from idea-generator-b7e2). Evaluation started.
- [2026-04-03T00:45Z] Evaluations complete. Portfolio analysis done. Summary ready.

## Evaluation Criteria

1. **Market evidence**: Does research support this approach? (H/M/L)
2. **User impact**: How many of the 7 pain points addressed?
3. **Strategic fit**: Aligns with file-based, no-infrastructure architecture?
4. **Feasibility**: Implementable via SKILL.md + shared content edits only?
5. **Effort**: Small / Medium / Large

Recommendation per idea: PURSUE / DEFER / REJECT with rationale.

---

## EVALUATION: session-recovery-continue-md

### Pain Point Reference

| Code | Severity | Description                                                                      |
| ---- | -------- | -------------------------------------------------------------------------------- |
| P1   | CRITICAL | No exact resume command                                                          |
| P2   | HIGH     | Original invocation flags not recorded                                           |
| P3   | HIGH     | Parallel agent status ambiguity                                                  |
| P4   | HIGH     | Checkpoint filenames not surfaced                                                |
| P5   | MEDIUM   | Mid-skeptic-review crash — resume must route draft to skeptic, not re-run writer |
| P6   | MEDIUM   | CONTINUE.md update frequency undefined                                           |
| P7   | LOW      | No artifact integrity signal                                                     |

---

### Idea 1: The Mission Brief (Minimal Human-Centric Snapshot)

**Market evidence**: HIGH — The existing `docs/CONTINUE.md` proves the structure works. Research confirms the gap is
frequency, not format. Direct codebase evidence; no speculation required.

**User impact**: Addresses **P1** (exact resume command in schema), **P2** (flags field in frontmatter), **P6** (update
trigger mandated in SKILL.md). 3 of 7 pain points — the three highest-priority ones.

**Strategic fit**: HIGH — Pure SKILL.md edit. Zero new tooling. Formalizes what already exists. Minimal blast radius.

**Feasibility**: HIGH — One addition to the Checkpoint Protocol section in plan-product and build-product SKILL.md
files: "Update CONTINUE.md before spawning the next stage." Frontmatter schema extension adds `flags` field.
Implementable in under an hour.

**Effort**: Small

**Risks**:

- Relies on Team Lead discipline — no mechanical enforcement
- Doesn't cover P3 (agent ambiguity), P4 (checkpoint paths), P5 (mid-skeptic), P7 (integrity)
- Simple enough to be complete in one edit session, which is its strength and its risk (may tempt people to stop here)

**Recommendation**: **PURSUE** — The indispensable foundation. Lowest effort, highest ROI. Every other useful idea is
additive on top of this one. Ship this first.

---

### Idea 2: The Write-Ahead Log (Event-Sourced CONTINUE.md)

**Market evidence**: HIGH — Research explicitly cites WAL as Conclave-applicable (Apache Flink analogy).
Well-established distributed systems pattern with clear mapping.

**User impact**: Addresses **P3** (log shows exact per-agent state at crash), **P5** (mid-skeptic crash visible in event
sequence), **P6** (every event recorded). 3 of 7 pain points — but critically misses P1, P2, P4.

**Strategic fit**: MEDIUM — Append-only log is file-based and needs no infrastructure. But the log grows indefinitely.
More importantly: a human under stress reading a 200-line event log to reconstruct state is _harder_ than reading a
structured file. The research requirement is "Clear, direct, concise, unambiguous. Nothing is lost. Here is exactly what
to type." A WAL delivers granularity, not brevity.

**Feasibility**: LOW-MEDIUM — Requires every Team Lead write action to emit a log line _before_ execution. Significant
cognitive load per event. Structural change to how the Lead narrates its own work, across every stage of every pipeline
skill.

**Effort**: Medium

**Risks**:

- Doesn't answer P1 — the operator still must parse a log to determine the resume command
- File growth is unbounded; large pipelines produce large logs
- WAL granularity benefits debug workflows more than crash recovery workflows
- High discipline requirement: one missed log line means the log is unreliable

**Recommendation**: **DEFER** — Technically sound pattern with legitimate use cases, but wrong tool for this job. The
user's stated requirement is brevity and precision under stress, not event archaeology. The WAL's strength (granularity)
is the Mission Brief's weakness — they are inverse tools. Revisit if crash debugging (not just crash recovery) becomes a
documented need.

---

### Idea 3: The Dual-File Protocol (Human + Machine Separation)

**Market evidence**: MEDIUM — Research identifies two distinct consumers (human operator, Team Lead agent) which this
idea directly addresses. But the LangGraph analogy (separate human API + DB backend) requires infrastructure to stay in
sync. The file-based version has no synchronization mechanism.

**User impact**: Addresses the dual-consumer finding. Theoretically helps P3 and P4 via the JSON file. In practice: the
per-agent `docs/progress/` files _already are_ machine-parseable state. The JSON file duplicates what already exists.

**Strategic fit**: LOW — Introduces a second file that can drift from the first. Every update to pipeline state requires
writing two files. The existing architecture has one ground truth per agent (progress files). Adding a second ground
truth creates a consistency problem, not a solution.

**Feasibility**: MEDIUM — Requires JSON schema definition, SKILL.md updates to write two files, gitignore decision, and
ongoing schema maintenance. The machine file only provides value if the Team Lead agent reads it before markdown — a
fragile assumption given LLM context consumption patterns.

**Effort**: Medium

**Risks**:

- Two files can and will drift — the exact problem we're trying to solve becomes two instances of itself
- Machine-parseable value is minimal: the Team Lead already reads markdown; parsing JSON is not meaningfully easier
- Schema maintenance burden for what is essentially a mirror of the progress files

**Recommendation**: **REJECT** — Adds complexity without unique value. The human-readable side is Idea 1. The
machine-readable side is the existing per-agent progress files. There is no gap that requires a third format. The
dual-consumer insight from research is valid; the dual-file implementation is the wrong response to it.

---

### Idea 4: The Saga Stage Map (Idempotent Recovery Gates)

**Market evidence**: HIGH — Research explicitly cites Saga pattern as having direct Conclave analogues. Existing
FOUND/NOT_FOUND detection is already a proto-Saga. The extension from binary to ternary status (FOUND/PARTIAL/NOT_FOUND)
is a well-motivated refinement.

**User impact**: Addresses **P5** (PARTIAL status is precisely the anchor for mid-stage crashes — routes recovery to the
right sub-step), **P3** (stage map makes parallel agent state visible by stage), **P7** (PARTIAL flags half-written
artifacts). 3 of 7 pain points.

**Strategic fit**: HIGH — Extends the existing artifact detection pattern rather than replacing it. File-based, no
infrastructure. The Stage Map table lives in CONTINUE.md; the PARTIAL status lives in frontmatter. Idiomatic with how
plan-product already works.

**Feasibility**: MEDIUM — Team Lead must set PARTIAL before spawning a stage (write-ahead intent), COMPLETE only after
the stage gate closes. Requires updating the Determine Mode / Checkpoint Protocol logic in both pipeline SKILL.md files.
The three-status logic must be consistent — partial implementation breaks the invariant.

**Effort**: Medium

**Risks**:

- Third status (PARTIAL) adds cognitive load for Team Lead and maintainers
- Partial implementation (adding the status but not the compensating-action column) is worse than not implementing it
- Requires retroactive definition of compensating actions per stage — this is design work, not just instrumentation

**Recommendation**: **PURSUE** — Addresses P5, which no other PURSUE-tier idea covers. The Saga Stage Map is also the
clearest mechanism for turning CONTINUE.md from a narrative into an actionable decision tree. Medium effort but high
strategic value. Implement as a section within CONTINUE.md ("Stage Status") rather than replacing the entire file
structure.

---

### Idea 5: The Materialized Checkpoint View (Aggregation Layer)

**Market evidence**: HIGH — Research directly names this role: "CONTINUE.md is the aggregation layer above per-agent
checkpoints — analogous to a saga coordinator over individual saga steps." The idea formalizes the research's own
definition.

**User impact**: Addresses **P3** (explicit aggregation surfaces parallel agent status at a glance), **P4** (checkpoint
file paths always listed with last-known status). 2 of 7 pain points — both HIGH severity. P4 is uniquely covered by
this idea; no other PURSUE-tier idea addresses it.

**Strategic fit**: HIGH — Zero new tooling. Adds a "Checkpoint Index" section to CONTINUE.md. Leverages existing
per-agent progress file convention.

**Feasibility**: HIGH — SKILL.md update: "After each stage, write all checkpoint paths and their current frontmatter
`status` value to the Checkpoint Index section of CONTINUE.md." Small, precise instruction. No new file format, no new
validator required.

**Effort**: Small

**Risks**:

- Index is stale between updates (acknowledged in the idea itself — "materialized view" framing makes staleness
  explicit)
- Team Lead must actively read all progress files to synthesize — adds work per stage
- Doesn't address P1, P2, P5, P6 — must be combined with other ideas

**Recommendation**: **PURSUE** — Small effort, addresses two HIGH-priority pain points that nothing else covers cleanly.
P4 (checkpoint filenames not surfaced) is only solved by this idea. The materialized view framing is intellectually
honest about staleness, which is the right design posture.

---

### Idea 6: The Shared Content Template (Sync-Injectable Protocol)

**Market evidence**: HIGH — Research explicitly asks whether CONTINUE.md protocol should be shared content and whether a
validator should be added. The existing B-series validators prove the pattern works at scale. Strong evidence base.

**User impact**: Addresses **P6** (update frequency mandated via shared content) and **P1** (resume command format
standardized across all pipeline skills). 2 of 7 pain points — both already addressed by Idea 1.

**Strategic fit**: HIGH — Perfectly aligned with ADR-002 and the shared content architecture. Correct long-term home for
a cross-skill protocol.

**Feasibility**: LOW — Requires: (1) new `plugins/conclave/shared/continue-protocol.md` file, (2) sync script extension
for new marker type, (3) new H-series validator, (4) marker injection into both pipeline SKILL.md files, (5) CI testing.
Substantial implementation work.

**Effort**: Large

**Risks**:

- High implementation cost relative to simpler alternatives that deliver the same pain point coverage
- Premature formalization: codifying the protocol in shared content before it's been battle-tested risks baking in wrong
  assumptions that become expensive to change
- Duplicates coverage already provided by Idea 1 (which is a SKILL.md edit, same effect, 1/10th the work)

**Recommendation**: **DEFER** — Correct destination, wrong time. Prove the protocol via Ideas 1 + 5 + 4 first. Once the
schema and update triggers are stable through real usage, migrate to shared content. Shared content is the right home
for a _proven_ protocol, not an experimental one.

---

### Idea 7: The Canary File (Liveness + Integrity Signal)

**Market evidence**: MEDIUM — Research identifies P7 as a pain point but rates it LOW. The heartbeat concept is novel;
the checksum concept is internally critiqued by the idea itself as a "leaky abstraction." Partial evidence base.

**User impact**: Addresses **P7** (artifact integrity via checksums — fragile) and **P6** (staleness visible via
heartbeat — robust). 2 of 7 pain points, both lower priority.

**Strategic fit**: HIGH — Frontmatter additions only. No infrastructure.

**Feasibility**: MEDIUM-HIGH — The heartbeat field is trivial to implement (add timestamp on every CONTINUE.md write).
The checksum field is problematic: markdown files change on every edit, SHA-1 of a markdown file is brittle, and there's
no tooling to compute checksums within a SKILL.md prompt. The idea's own text admits "a simpler integrity proxy (file
exists + frontmatter status != 'draft') may be sufficient."

**Effort**: Small (heartbeat only) / Medium (with checksums)

**Risks**:

- Checksum implementation is fragile and unenforceable in a markdown-only, no-runtime environment
- Two features bundled in one idea: heartbeat (good) + checksums (problematic)
- P7 (artifact integrity) is LOW priority — not worth medium effort; but heartbeat alone is worth small effort

**Recommendation**: **DEFER** (as described) / **Extract heartbeat field into Idea 1** — The checksum half should be
rejected outright (fragile, no-runtime environment can't compute hashes reliably). The heartbeat field has genuine
value: it makes CONTINUE.md staleness visible without any analysis. Pull the `heartbeat` frontmatter field into Idea 1's
schema as a free upgrade. The rest of Idea 7 is not worth pursuing.

---

## Portfolio Analysis

### Pain Point Coverage Matrix

| Pain Point                            | Severity | Idea 1 | Idea 2 | Idea 3 | Idea 4 | Idea 5 | Idea 6 | Idea 7 |
| ------------------------------------- | -------- | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| P1: No exact resume command           | CRITICAL | ✓      |        |        |        |        | ✓      |        |
| P2: Flags lost                        | HIGH     | ✓      |        |        |        |        |        |        |
| P3: Parallel agent ambiguity          | HIGH     |        | ✓      |        | ✓      | ✓      |        |        |
| P4: Checkpoint filenames not surfaced | HIGH     |        |        |        |        | ✓      |        |        |
| P5: Mid-skeptic crash                 | MEDIUM   |        | ✓      |        | ✓      |        |        |        |
| P6: Update frequency undefined        | MEDIUM   | ✓      | ✓      |        |        |        | ✓      | ✓      |
| P7: No artifact integrity             | LOW      |        |        |        | ✓      |        |        | ✓      |

### Gaps in the Portfolio

- **P4 (HIGH)** is uniquely covered only by Idea 5. No REJECT/DEFER idea covers it.
- **P5 (MEDIUM)** is covered only by Idea 2 (DEFER) and Idea 4 (PURSUE). Without Idea 4, P5 is uncovered.
- **P7 (LOW)** is partially covered by Idea 4 (PARTIAL status flags half-written artifacts). The checksum approach in
  Idea 7 is too fragile to rely on.

The portfolio as generated covers all 7 pain points — but only when including deferred ideas. The PURSUE set (Ideas 1 +
5 + 4) covers 6 of 7 pain points. The gap is P7, which is LOW priority and adequately addressed by the PARTIAL status in
Idea 4.

### Recommended Combination

**The Strongest Minimal Portfolio: Ideas 1 + 5 + 4 (in implementation order)**

| Step | Idea                             | Effort | Pain Points Covered                                            |
| ---- | -------------------------------- | ------ | -------------------------------------------------------------- |
| 1    | Mission Brief (1)                | Small  | P1, P2, P6 (+ heartbeat from Idea 7 = P6 staleness visibility) |
| 2    | Materialized Checkpoint View (5) | Small  | P3, P4                                                         |
| 3    | Saga Stage Map (4)               | Medium | P5, P7 (partial), bolsters P3                                  |

Combined effort: Small + Small + Medium = achievable in one implementation session. All 7 pain points addressed. No new
tooling. All changes live in SKILL.md files and CONTINUE.md schema.

### Overall Ranking by Priority Score (effort × impact)

1. **Idea 1** — PURSUE (S effort / L impact — highest ROI, foundation for everything)
2. **Idea 5** — PURSUE (S effort / M impact — P4 uniquely covered, P3 addressed)
3. **Idea 4** — PURSUE (M effort / XL impact — P5 coverage, structural upgrade to recovery model)
4. **Idea 6** — DEFER (L effort / L impact — right idea after protocol stabilizes)
5. **Idea 2** — DEFER (M effort / XL granularity, wrong tool for stress-recovery UX)
6. **Idea 7** — DEFER heartbeat extraction into Idea 1; REJECT checksums
7. **Idea 3** — REJECT (M effort / duplicates existing mechanisms, drift risk)

## Status

Evaluations complete. Ready to submit to Team Lead.
