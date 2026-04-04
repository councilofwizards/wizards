---
feature: "session-recovery-continue-md"
team: "plan-product-b7e2"
agent: "idea-generator-b7e2"
phase: "ideation"
status: "awaiting_review"
last_action:
  "7 design ideas written to docs/progress/session-recovery-continue-md-idea-generator.md. Submitted to Team Lead."
updated: "2026-04-03T00:20:00Z"
---

## Progress Notes

- [00:05] Task claimed. Read research artifact and current CONTINUE.md. Ideation starting.
- [00:10] Ideation underway. 7 ideas drafted, writing to output file.
- [00:20] All 7 ideas complete. Awaiting review from Team Lead / Idea Evaluator.

---

IDEAS: CONTINUE.md Disaster Recovery Protocol

## Idea 1: The Mission Brief (Minimal Human-Centric Snapshot)

**Type**: Incremental improvement on current state

**Description**: CONTINUE.md is a terse, structured one-pager owned exclusively by the Team Lead. Fixed schema: YAML
frontmatter (`skill`, `topic`, `run_id`, `stage`, `status`, `flags`, `last_action`, `updated`) + four mandatory
sections: "What We're Building," "Current State," "Recovery Instructions," "Artifact Locations." Team Lead updates it at
one specific trigger: **after each stage gate closes** (not after every agent message). Update frequency is mandated in
SKILL.md as: "Update CONTINUE.md before spawning the next stage."

- **User need**: P1-CRITICAL (no exact resume command), P2-HIGH (original flags lost), P6-MEDIUM (update frequency
  undefined)
- **Evidence**: Current `docs/CONTINUE.md` already demonstrates this structure — it exists and works but the update
  mandate is missing from SKILL.md's Checkpoint Protocol. Research confirms the gap is frequency, not structure.
- **Estimated effort**: S
- **Estimated impact**: L
- **Key trade-off**: Simplest possible solution. Relies on Team Lead discipline — no mechanical enforcement. But the
  existing CONTINUE.md proves the format works; the only missing piece is codifying _when_ to update.

---

## Idea 2: The Write-Ahead Log (Event-Sourced CONTINUE.md)

**Type**: Novel — borrows from distributed systems

**Description**: CONTINUE.md is an append-only event log. Every significant pipeline event is written _before_ it
executes (Write-Ahead Log pattern). Each entry: `[ISO-timestamp] [STAGE] [AGENT] [EVENT] — [details]`. Recovery reads
the log top-to-bottom and derives current state from the last entries. No frontmatter state to keep synchronized — state
is derived from the log.

Example log entries:

```
[2026-04-03T00:01:00Z] STAGE:1 LEAD spawning market-researcher-b7e2
[2026-04-03T00:02:00Z] STAGE:1 market-researcher-b7e2 started — writing to docs/progress/...market-researcher.md
[2026-04-03T00:15:00Z] STAGE:1 market-researcher-b7e2 complete — artifact: docs/research/...research.md
[2026-04-03T00:16:00Z] STAGE:1 LEAD skeptic-review started
[2026-04-03T00:17:00Z] STAGE:1 LEAD skeptic-review approved — advancing to stage 2
[2026-04-03T00:18:00Z] STAGE:2 LEAD spawning idea-generator-b7e2
```

Recovery: read the last 20 lines of CONTINUE.md to know exactly where the crash happened, down to the sub-stage.

- **User need**: P3-HIGH (parallel agent ambiguity), P5-MEDIUM (mid-skeptic-review crash), P6-MEDIUM (frequency
  undefined — here every event is recorded)
- **Evidence**: Research explicitly cites Write-Ahead Log as a Conclave-applicable distributed systems pattern. Apache
  Flink restarts from the last recorded checkpoint, not the beginning.
- **Estimated effort**: M
- **Estimated impact**: XL
- **Key trade-off**: Highest recovery granularity of any idea. File grows indefinitely on long runs. Requires the Team
  Lead to write one log line per event rather than update a structured block.

---

## Idea 3: The Dual-File Protocol (Human + Machine Separation)

**Type**: Novel — separates concerns explicitly

**Description**: Two files with a clear division of labor:

- `docs/CONTINUE.md` — human-readable narrative for the operator under stress. Bullet points, plain English, exact
  resume command at the top.
- `docs/CONTINUE.json` (or `.continue-state.json`, gitignored) — machine-parseable state for the Team Lead agent on
  re-invocation. Structured JSON:
  `{ "run_id", "stage", "agents": [{name, status, checkpoint_path}], "artifacts": [{stage, path, status}], "flags": {} }`.

On re-invocation, the Team Lead reads `.continue-state.json` first (structured, no ambiguity), then surfaces CONTINUE.md
to the human for confirmation. Human gets prose; agent gets structured data.

- **User need**: Research identifies two distinct consumers — "Primary: Solo Developer/Founder" (reads under stress,
  needs brevity) and "Secondary: Team Lead Agent" (needs machine-parseable, uses checkpoints as ground truth).
- **Evidence**: LangGraph uses pluggable persistence backends (SQLite, Postgres, Redis) for machine-readable state while
  providing a separate human-facing API. The dual-consumer finding from customer research maps directly.
- **Estimated effort**: M
- **Estimated impact**: L
- **Key trade-off**: Two files to maintain = two files that can drift. The machine file is only valuable if the Team
  Lead agent actually reads it first. Adds schema maintenance burden. Simpler alternatives may suffice.

---

## Idea 4: The Saga Stage Map (Idempotent Recovery Gates)

**Type**: Novel — brings Saga pattern to CONTINUE.md

**Description**: CONTINUE.md models the pipeline as a Saga: a sequence of stages, each with a well-defined status and a
_compensating action_ if it fails partway. The core section is a "Stage Map":

```
| Stage | Status    | Artifact Path                  | Compensating Action                          |
|-------|-----------|--------------------------------|----------------------------------------------|
| 1     | COMPLETE  | docs/research/...research.md   | Re-run stage 1 (artifact missing or draft)   |
| 2     | PARTIAL   | docs/ideas/...ideas.md         | Re-spawn idea-generator with checkpoint       |
| 3     | PENDING   | —                              | Blocked on stage 2                           |
```

"PARTIAL" is a new status meaning: "an agent ran, wrote a checkpoint, but the stage gate never closed." Recovery
instructions differ by status — COMPLETE stages are skipped, PARTIAL stages get targeted re-spawns (not full reruns),
PENDING stages are untouched.

- **User need**: P5-MEDIUM (mid-skeptic crash leaves no anchor — Saga's "PARTIAL" status is exactly this anchor), P7-LOW
  (artifact integrity — PARTIAL status flags half-written artifacts)
- **Evidence**: Research explicitly cites the Saga pattern as having direct Conclave analogues. Existing artifact
  detection already implements FOUND/NOT_FOUND — Saga extends this to FOUND/PARTIAL/NOT_FOUND.
- **Estimated effort**: M
- **Estimated impact**: XL
- **Key trade-off**: Introduces a third artifact status ("PARTIAL") that must be consistently set and read. Requires
  Team Lead to set PARTIAL before spawning a stage and COMPLETE only after the stage gate closes. More complex than
  binary FOUND/NOT_FOUND but maps cleanly to real failure modes.

---

## Idea 5: The Materialized Checkpoint View (Aggregation Layer)

**Type**: Incremental — formalizes existing per-agent checkpoint pattern

**Description**: CONTINUE.md is explicitly defined as a _materialized view_ over all agent progress files. The Team Lead
reads all `docs/progress/{topic}-{role}.md` files at stage completion and synthesizes a single aggregated summary into
CONTINUE.md. CONTINUE.md never contains unique information — everything in it is derivable from the agent progress
files. Its value is aggregation and legibility.

This formalizes the Team Lead's role as "checkpoint aggregator" and makes the protocol explicit: agent checkpoints are
the ground truth; CONTINUE.md is the index. Recovery workflow: read CONTINUE.md to find which progress files to read
next; progress files contain the detail.

New convention: CONTINUE.md always lists all checkpoint file paths (not just "check if exists") with their exact
frontmatter `status` value at last aggregation.

- **User need**: P3-HIGH (parallel agent ambiguity — now explicit in the aggregation), P4-HIGH (checkpoint filenames not
  surfaced — here they're always listed with their last-known status)
- **Evidence**: Research calls CONTINUE.md "the aggregation layer above per-agent checkpoints — analogous to a saga
  coordinator over individual saga steps." This idea makes that analogy literal.
- **Estimated effort**: S
- **Estimated impact**: M
- **Key trade-off**: CONTINUE.md can be stale relative to agent progress files (P6). The materialized view framing makes
  the staleness _explicit and acceptable_ — operators know to read the source files for ground truth.

---

## Idea 6: The Shared Content Template (Sync-Injectable Protocol)

**Type**: Novel — leverages the existing shared content architecture

**Description**: Define the CONTINUE.md _protocol_ (not the file itself) as shared content in
`plugins/conclave/shared/continue-protocol.md`. The sync script injects a "CONTINUE.md Update Protocol" section into all
pipeline skill SKILL.md files (plan-product, build-product) via markers: `<!-- BEGIN SHARED: continue-protocol -->` /
`<!-- END SHARED: continue-protocol -->`.

The protocol section specifies:

1. Exact CONTINUE.md schema (frontmatter fields, mandatory sections)
2. Precise update triggers ("update CONTINUE.md before spawning next stage, before skeptic review, before shutdown")
3. Recovery workflow steps (read order, resume command template)

Add a new H-series validator: `continue-protocol.sh` — checks that pipeline skill SKILL.md files contain the shared
marker and that their CONTINUE.md update triggers match the canonical list.

- **User need**: P6-MEDIUM (update frequency undefined), P1-CRITICAL (resume command format standardized across all
  pipeline skills)
- **Evidence**: Research asks explicitly: "Should CONTINUE.md be a template in shared content (like principles.md)?
  Should there be a CONTINUE.md validator in the A-series or a new series?" This idea answers both questions yes. The
  existing shared content architecture (ADR-002, B-series validators) proves the pattern works at scale.
- **Estimated effort**: L
- **Estimated impact**: L
- **Key trade-off**: Requires the sync script and a new validator. High implementation cost relative to simpler ideas.
  But it's the only idea that guarantees consistency across future pipeline skills without per-skill maintenance. Best
  option if the skill count grows.

---

## Idea 7: The Canary File (Liveness + Integrity Signal)

**Type**: Novel — adds observability to the recovery protocol

**Description**: CONTINUE.md gains two new frontmatter fields:

- `heartbeat`: ISO-8601 timestamp updated every time Team Lead writes to CONTINUE.md. Age of heartbeat at crash time
  tells the operator how stale the file is (minutes vs. hours).
- `artifact_checksums`: a map of artifact paths to their SHA-1 (or content-length proxy for markdown) at last
  checkpoint: `{ "docs/research/...md": "a3f9b1c" }`.

Recovery workflow gains a "Verify Integrity" step: before trusting an artifact as FOUND, cross-check its current content
hash against `artifact_checksums`. Mismatch = artifact was modified after CONTINUE.md was written = re-verify manually
before trusting pipeline stage skip.

Separately: if heartbeat age > 30 minutes, CONTINUE.md is declared "stale" and the operator is warned.

- **User need**: P7-LOW (no artifact integrity signal — checksums solve this directly), P6-MEDIUM (update frequency —
  heartbeat makes staleness visible)
- **Evidence**: Research identifies "artifact integrity" as pain point P7 and cites LangGraph's "time-travel debugging"
  as a quality bar. Checksums are the file-system analogue of LangGraph's per-superstep snapshots enabling state
  verification.
- **Estimated effort**: S
- **Estimated impact**: M
- **Key trade-off**: Checksums are a leaky abstraction — markdown files change on every edit, making stable checksums
  hard. A simpler integrity proxy (file exists + frontmatter `status != "draft"`) may be sufficient and more robust. The
  canary value (heartbeat) is more defensible than the checksum value.
