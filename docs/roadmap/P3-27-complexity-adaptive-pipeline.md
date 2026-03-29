---
title: "Complexity-Adaptive Pipeline"
status: complete
priority: P3
category: core-framework
effort: Medium
impact: Medium
dependencies: []
created: 2026-03-27
updated: 2026-03-27
---

# P3-27: Complexity-Adaptive Pipeline

## Summary

Add a complexity classifier at pipeline entry points (plan-product, build-product) that routes tasks to appropriate
pipeline depths. Simple tasks skip directly to implementation; complex tasks get additional skeptic checkpoints.

## Motivation

Anthropic's harness design paper emphasizes that pipeline complexity should match task complexity. Currently, a simple
bug fix enters the same pipeline as a greenfield feature. Existing artifact detection provides a partial fast-path (skip
stages with existing artifacts), but there's no explicit "this is small enough to go direct" classification.

## Scope

- Complexity classifier prompt at plan-product and build-product entry
- Three tiers: Simple (skip to build-implementation), Standard (normal pipeline), Complex (full pipeline + additional
  checkpoints)
- Classification criteria documented in SKILL.md

> **Batching note**: Modifies the same SKILL.md files as P3-28 (Lead-as-Skeptic Fix). Recommend implementing together.
