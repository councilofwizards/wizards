---
type: "research-findings"
topic: "session-recovery-continue-md"
feature: "CONTINUE.md disaster recovery protocol"
generated: "2026-04-03"
confidence: "high"
expires: "2026-05-03"
---

# Research Findings: Session Recovery via CONTINUE.md

## Executive Summary

The Conclave plugin has a solid per-agent checkpoint system (P1-02, complete) and pipeline-level resume via artifact
detection. The core gap: no continuously-updated, human-readable document bridges per-agent checkpoints and the human
operator who needs to resume after a session crash. CONTINUE.md fills this gap as the aggregation layer above per-agent
checkpoints — analogous to a saga coordinator over individual saga steps. External validation: Claude Code community is
actively requesting this pattern (issue #27419), and LangGraph's StateSnapshot is the closest competitive analogue.

## Market Analysis

### Market Size

- **TAM**: All users of AI agent orchestration frameworks who run long-running, multi-agent pipelines (LangGraph,
  CrewAI, AutoGen, Claude Code plugins). Confidence: medium.
- **SAM**: Claude Code plugin users running multi-agent skills (Conclave users). Confidence: high — this is our direct
  user base.
- **SOM**: Solo developers/founders using Conclave pipeline skills (plan-product, build-product) where session crashes
  risk hours of accumulated work. Confidence: high.

### Industry Trends

- **Stateful agent orchestration is the frontier.** LangGraph dominates with per-superstep snapshots, pluggable backends
  (SQLite, Postgres, Redis), automatic thread_id-based resume, and time-travel debugging. This is the quality bar.
- **Most frameworks ignore it.** CrewAI has no checkpointing. OpenAI Swarm is stateless by design. AutoGPT is legacy.
  The gap is wide — most AI agent frameworks assume sessions complete in one run.
- **Claude Code community demand is real.** GitHub issues #27419 and #40286 request graceful context exhaustion handoff
  — users want a handoff document written before context dies, usable to bootstrap a new session. CONTINUE.md is exactly
  this pattern, implemented at the plugin level.
- **Distributed systems patterns map directly.** Apache Flink (restart from last checkpoint, not beginning), Saga
  pattern (idempotent compensating steps), Event Sourcing (state from event log), Write-Ahead Log (log intent before
  execution) all have direct Conclave analogues.

## Competitive Landscape

| Framework              | Session Recovery | Approach                                                      | Strength                                      | Weakness                                  |
| ---------------------- | ---------------- | ------------------------------------------------------------- | --------------------------------------------- | ----------------------------------------- |
| LangGraph              | Full             | Per-superstep snapshots, thread_id resume, pluggable backends | Automatic, granular, production-grade         | Requires infrastructure (DB backend)      |
| CrewAI                 | None             | No built-in checkpointing                                     | —                                             | Users must build their own                |
| AutoGen (AG2)          | Partial          | Event-driven runtime, async-first                             | Good architecture                             | Checkpointing docs limited                |
| OpenAI Swarm           | None             | Stateless by design                                           | Simple                                        | Not designed for long sessions            |
| Conclave (current)     | Partial          | Per-agent files, artifact detection, pipeline resume          | Works, file-based, no infra needed            | No aggregated human-readable recovery doc |
| Conclave + CONTINUE.md | Full             | Above + continuously-updated mission brief                    | Self-sufficient, zero-infra, human-actionable | Requires Team Lead discipline             |

## Customer Segments

### Primary: Solo Developer/Founder

- Runs 5-stage, 9+ agent pipeline skills
- Session crashes risk hours of accumulated work
- Needs: exact resume command, zero ambiguity, "nothing is lost" confidence
- Reads CONTINUE.md under stress — brevity and precision matter more than completeness

### Secondary: Team Lead Agent (automated consumer)

- Reads CONTINUE.md on re-invocation to reconstruct pipeline state
- Needs: machine-parseable frontmatter + human-readable body
- Uses checkpoint files as ground truth, CONTINUE.md as index/summary

## Data Sources

- `plugins/conclave/skills/plan-product/SKILL.md` — Checkpoint Protocol, Failure Recovery, Determine Mode
- `plugins/conclave/skills/build-product/SKILL.md` — Checkpoint Protocol, Failure Recovery
- `docs/roadmap/P1-02-state-persistence.md` — History of state persistence implementation
- `docs/progress/` — Real checkpoint files from prior sessions
- `docs/CONTINUE.md` — Current session's initial CONTINUE.md (static snapshot)
- Web search: LangGraph docs, CrewAI docs, Claude Code GitHub issues #27419, #40286

## Data Gaps

- Crash frequency: No data on how often sessions crash vs. complete successfully
- Recovery success rate: No evidence of successful mid-session recovery using existing checkpoints
- AutoGen v0.4 checkpointing: Limited documentation found
- Update frequency trade-off: No empirical data on optimal CONTINUE.md update cadence
- Git tracking: Unknown whether CONTINUE.md should be committed or gitignored

## Confidence Assessment

| Section                       | Confidence                        | Rationale                                                                |
| ----------------------------- | --------------------------------- | ------------------------------------------------------------------------ |
| Existing infrastructure       | High                              | Direct codebase evidence from SKILL.md files and progress files          |
| Core gap identification       | High                              | Both researchers independently identified the same gap                   |
| Competitive landscape         | High (LangGraph), Medium (others) | LangGraph well-documented; others less so                                |
| Customer pain points          | High                              | 7 pain points backed by codebase evidence + user's explicit requirements |
| Distributed systems analogues | High                              | Well-established patterns with clear Conclave mappings                   |
| Design recommendations        | Medium                            | Inferred from evidence, not yet validated by implementation              |

---

## Appendix: Customer Pain Points (from Customer Researcher)

1. **P1 CRITICAL**: No exact resume command — must include full command with topic and flags
2. **P2 HIGH**: Original invocation flags not recorded — `--full`, `--complexity`, `--checkpoint-frequency` lost
3. **P3 HIGH**: Parallel agent status ambiguity — which agent finished, which was mid-task
4. **P4 HIGH**: Checkpoint filenames not surfaced — exact paths needed, not glob patterns
5. **P5 MEDIUM**: Mid-skeptic-review crash — resume must route existing draft to skeptic, not re-run writer
6. **P6 MEDIUM**: CONTINUE.md update frequency undefined — must mandate updates after each stage
7. **P7 LOW**: No artifact integrity signal — verify `status != "draft"` before trusting FOUND detection
