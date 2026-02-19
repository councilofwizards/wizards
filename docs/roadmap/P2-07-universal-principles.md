---
title: "Universal Shared Principles"
status: "not_started"
priority: "P2"
category: "core-framework"
effort: "Medium"
impact: "medium"
dependencies: ["content-deduplication"]
created: "2026-02-19"
updated: "2026-02-19"
---

# Universal Shared Principles

## Problem

The shared content system (HTML markers + CI drift validator from P2-05) works well for keeping Shared Principles and Communication Protocol in sync across skills. However, each multi-agent SKILL.md carries a full copy of these sections. As the skill count grows, editing shared content requires updating every multi-agent SKILL.md file.

Currently 4 multi-agent skills carry shared content. ADR-002 sets the extraction threshold at 8 skills.

## Proposed Solution

Extract shared principles and communication protocol into authoritative source files that SKILL.md files reference rather than duplicate. The exact mechanism (includes, references, or build-time injection) depends on Claude Code plugin capabilities at the time of implementation.

## Trigger Condition

Per ADR-002: "When the skill count exceeds 8, revisit this approach." Current count: 5 total skills, 4 multi-agent skills with shared content.

## Success Criteria

- Shared content is defined in exactly one place
- All multi-agent skills reference the authoritative source
- CI validator confirms consistency
- Adding a new skill does not require copying shared content
