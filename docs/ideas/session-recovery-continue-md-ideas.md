---
type: "product-ideas"
topic: "session-recovery-continue-md"
generated: "2026-04-03"
source_research: "docs/research/session-recovery-continue-md-research.md"
---

# Product Ideas: CONTINUE.md Disaster Recovery Protocol

## Ideas

### Idea 1: The Mission Brief (Minimal Human-Centric Snapshot) — PURSUE

- **Description**: CONTINUE.md is a terse, structured one-pager with fixed schema. YAML frontmatter records skill,
  topic, run_id, stage, status, flags, heartbeat. Four mandatory sections: What We're Building, Current State, Recovery
  Instructions, Artifact Locations. Team Lead updates after each stage gate closes. Update frequency mandated in
  SKILL.md Checkpoint Protocol.
- **User Need**: P1-CRITICAL (exact resume command), P2-HIGH (flags recorded), P6-MEDIUM (update frequency defined)
- **Evidence**: Current docs/CONTINUE.md proves the structure works. Research confirms gap is frequency, not format.
- **Estimated Effort**: small
- **Estimated Impact**: high
- **Confidence**: H
- **Priority Score**: Highest ROI — foundation for all other ideas
- **Enhancement**: Extract `heartbeat` field from Idea 7 (ISO-8601 timestamp on every write, makes staleness visible)

### Idea 5: The Materialized Checkpoint View (Aggregation Layer) — PURSUE

- **Description**: CONTINUE.md is explicitly a materialized view over agent progress files. Always lists all checkpoint
  file paths with their exact frontmatter `status` value at last aggregation. Agent checkpoints are ground truth;
  CONTINUE.md is the index. Recovery: read CONTINUE.md to find which progress files to read next.
- **User Need**: P3-HIGH (parallel agent status explicit), P4-HIGH (checkpoint filenames always listed)
- **Evidence**: Research defines CONTINUE.md as "the aggregation layer above per-agent checkpoints — analogous to a saga
  coordinator over individual saga steps."
- **Estimated Effort**: small
- **Estimated Impact**: medium
- **Confidence**: H
- **Priority Score**: Uniquely covers P4 (checkpoint filenames)

### Idea 4: The Saga Stage Map (Idempotent Recovery Gates) — PURSUE

- **Description**: Pipeline modeled as a Saga. Stage Map table in CONTINUE.md with three statuses:
  COMPLETE/PARTIAL/PENDING. PARTIAL means "agent ran, checkpoint exists, but stage gate never closed." Each stage has a
  compensating action column (what to do to recover from PARTIAL). Extends existing FOUND/NOT_FOUND detection.
- **User Need**: P5-MEDIUM (mid-skeptic crash anchor), P7-LOW (PARTIAL flags half-written artifacts)
- **Evidence**: Research cites Saga pattern as having direct Conclave analogues. Existing artifact detection is a
  proto-Saga.
- **Estimated Effort**: medium
- **Estimated Impact**: high
- **Confidence**: H
- **Priority Score**: Only PURSUE-tier idea covering P5

## Evaluation Criteria Used

Evaluated on 5 dimensions: market evidence (H/M/L), user impact (pain points covered), strategic fit (file-based
architecture alignment), feasibility (SKILL.md-only changes), effort (S/M/L). Portfolio analysis confirmed Ideas 1 + 5 +
4 cover all 7 pain points with no new tooling.

## Rejected Ideas

### Idea 3: The Dual-File Protocol — REJECTED

Two files (CONTINUE.md + .continue-state.json) creates a second ground truth that will drift. Per-agent progress files
already serve the machine-readable role. Adds complexity without unique value.

### Idea 2: The Write-Ahead Log — DEFERRED

Append-only event log provides granularity but is wrong tool for stress-recovery UX. User needs brevity and precision,
not event archaeology. Revisit if crash debugging becomes a documented need.

### Idea 6: The Shared Content Template — DEFERRED

Correct long-term destination after protocol stabilizes. Premature to formalize before battle-testing. Prove the
protocol via Ideas 1 + 5 + 4 first, then migrate to shared content.

### Idea 7: The Canary File — DEFERRED (heartbeat extracted)

Heartbeat field extracted into Idea 1 (free value). Checksum half rejected — fragile in a no-runtime, markdown-only
environment. Simpler integrity proxy (status != "draft") is sufficient.
