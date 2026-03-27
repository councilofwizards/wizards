---
title: "Checkpoint Frequency Configurability"
status: not_started
priority: P3
category: developer-experience
effort: Small
impact: Low
dependencies:
  - P1-02 (complete)
created: 2026-03-27
updated: 2026-03-27
---

# P3-30: Checkpoint Frequency Configurability

## Summary

Add a `--checkpoint-frequency [every-step|milestones-only|final-only]` flag to multi-agent skills. Default: `every-step` (current behavior unchanged). Allows reducing checkpoint overhead for short-running skills where cross-session resumption is unlikely.

## Motivation

Anthropic's harness design paper found that Opus 4.6 can run coherently for 2+ hours with automatic compaction. Per-action checkpoints may add unnecessary I/O for short skills. However, checkpoints are cheap (small markdown writes) and their cross-session value remains high, so this is a polish item.

## Scope

- Flag parsed at skill entry, adjusts checkpoint instructions in spawn prompts
- Three modes: every-step (default), milestones-only (stage boundaries), final-only (completion summary)

## Design Assumption

> This item compensates for potential context anxiety on long runs. Test whether it's needed at all on Opus-class models before implementing — the overhead may be negligible.
