---
title: "CONTINUE.md Disaster Recovery Protocol"
status: "not_started"
priority: "P2"
category: "quality-reliability"
effort: "Small-Medium"
impact: "High"
dependencies:
  - "P1-02 (complete)"
  - "P2-03 (complete)"
  - "P3-30 (complete)"
created: "2026-04-03"
updated: "2026-04-03"
---

# P2-14: CONTINUE.md Disaster Recovery Protocol

## Summary

Add a continuously-updated `docs/CONTINUE.md` file to all pipeline skills (plan-product, build-product) that the Team
Lead writes and maintains during execution. When a chat session crashes, this file tells a fresh session exactly how to
resume: which skill was running, at what stage, which agents completed, which artifacts exist, what flags were used, and
the exact command to type.

## Motivation

A session crash during a 5-stage, 9-agent plan-product run currently loses all orchestration context. Per-agent
checkpoint files exist (P1-02) but are scattered and machine-oriented. No single human-readable document aggregates
pipeline state into an actionable recovery brief. Users must manually reconstruct state from multiple progress files —
error-prone and stressful.

## Design Target

Combination of three evaluated ideas (from plan-product Stage 2 ideation):

1. **Mission Brief** (Idea 1): Fixed-schema CONTINUE.md with YAML frontmatter (skill, topic, run_id, stage, status,
   flags, heartbeat) and four mandatory sections. Team Lead updates after each stage gate closes. Covers P1-CRITICAL
   (exact resume command), P2-HIGH (flags recorded), P6-MEDIUM (update frequency defined).

2. **Materialized Checkpoint View** (Idea 5): CONTINUE.md always lists all checkpoint file paths with their exact
   frontmatter status. Agent checkpoints are ground truth; CONTINUE.md is the index. Covers P3-HIGH (parallel agent
   status), P4-HIGH (checkpoint filenames surfaced).

3. **Saga Stage Map** (Idea 4): Stage Map table with COMPLETE/PARTIAL/PENDING statuses and compensating actions per
   stage. Extends existing FOUND/NOT_FOUND artifact detection. Covers P5-MEDIUM (mid-skeptic crash recovery), P7-LOW
   (artifact integrity via PARTIAL status).

## Implementation Scope

- Edit `plugins/conclave/skills/plan-product/SKILL.md` — add CONTINUE.md update protocol to Checkpoint Protocol section,
  define schema, mandate update triggers
- Edit `plugins/conclave/skills/build-product/SKILL.md` — same changes adapted for 3-stage pipeline
- Define CONTINUE.md schema (frontmatter + sections + Stage Map + Checkpoint Index)
- No new validators, no new tooling, no runtime changes. All changes are SKILL.md prose.

## Success Criteria

1. After every stage gate, CONTINUE.md reflects the true pipeline state (stage, agent statuses, artifact locations)
2. A fresh session reading only CONTINUE.md can determine the exact resume command including topic and flags
3. All 7 pain points (P1-P7) from customer research are addressed
4. CONTINUE.md is self-sufficient: a reader with zero prior context can resume the pipeline

## Research & Ideation Artifacts

- Research: `docs/research/session-recovery-continue-md-research.md`
- Ideas: `docs/ideas/session-recovery-continue-md-ideas.md`
