---
title: "Onboarding Wizard Data Model Evaluation"
status: "approved"
feature: "onboarding-wizard"
author: "dba"
created: "2026-02-19"
updated: "2026-02-19"
---

# Onboarding Wizard — Data Model Evaluation

## Summary

The `/setup-project` onboarding wizard skill requires **no persistent data model**. There are no database tables,
schemas, migrations, or indexes to design. The file-system artifacts produced by the skill serve as both output and
state. This document explains why and what those file-based artifacts are.

## Context

This project is a Claude Code plugin system. Skills are `SKILL.md` markdown files that instruct AI agents. There is no
database anywhere in the system — not SQLite, not PostgreSQL, not any datastore. All persistent state across the entire
project is file-based:

- **Skill definitions**: `plugins/conclave/skills/{name}/SKILL.md`
- **Project documentation**: `docs/roadmap/`, `docs/specs/`, `docs/architecture/`
- **Session state**: `docs/progress/{feature}-{role}.md` checkpoint files (see P1-02)
- **Plugin metadata**: `.claude-plugin/plugin.json`

The `/setup-project` skill (P3-02) is a single-agent setup utility — no multi-agent team, no Skeptic, no orchestration.
It runs once per project to bootstrap the documentation structure.

## Why No Data Model Is Needed

### 1. No Database Exists in the System

The conclave plugin is a set of SKILL.md files consumed by Claude Code. The project has no application server, no API,
no ORM, no migration framework. Introducing a database for a single setup skill would be architecturally incongruent
with the entire system.

### 2. File Artifacts ARE the State

The setup-project skill produces files. The existence of those files is the state:

| Artifact                      | State It Represents         | Idempotency Check                    |
| ----------------------------- | --------------------------- | ------------------------------------ |
| `docs/` directory tree        | Project initialized         | `if directory exists, skip creation` |
| `docs/roadmap/_index.md`      | Roadmap bootstrapped        | `if file exists, do not overwrite`   |
| `CLAUDE.md`                   | Project conventions set     | `if file exists, do not overwrite`   |
| `docs/stack-hints/{stack}.md` | Stack detected and recorded | `if file exists, do not overwrite`   |

No separate state tracking is needed because the artifacts are self-describing. The skill checks for their existence
before acting — this is the idempotency requirement from P3-02.

### 3. No Session Persistence Needed

The checkpoint protocol (P1-02) exists for multi-agent skills that run long enough to exhaust context windows.
`/setup-project` is:

- **Single-agent**: No team coordination, no message passing
- **Short-lived**: Creates ~5 files and exits
- **Naturally idempotent**: Re-running detects existing files and skips them

A checkpoint file would add complexity with no recovery benefit. If the skill is interrupted mid-execution, re-running
it completes any missing files without duplicating work.

### 4. Existing Skills Confirm the Pattern

All three existing skills (`plan-product`, `build-product`, `review-quality`) use the same pattern:

- **No database**: State is files on disk
- **Checkpoint files**: Only for multi-agent orchestration recovery
- **File existence checks**: Used for idempotent setup (all three skills create `docs/` directories if missing)

The setup-project skill follows this established pattern exactly.

## File-Based Artifacts Serving as State

### Produced by `/setup-project`

1. **Directory structure**:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
   - `docs/stack-hints/`

2. **Bootstrap files**:
   - `docs/roadmap/_index.md` — starter roadmap with project-specific categories
   - `CLAUDE.md` — project conventions for Claude Code

3. **Detection artifacts** (conditional):
   - `docs/stack-hints/{detected-stack}.md` — if stack is detected from manifests

### State Transitions

```
State 0: Fresh project (no docs/, no CLAUDE.md)
  ↓ /setup-project
State 1: Initialized (docs/ tree exists, _index.md exists, CLAUDE.md exists)
  ↓ /setup-project (re-run)
State 1: Unchanged (idempotent — detects existing files, skips)
```

There are only two states: uninitialized and initialized. The transition is one-way and irreversible (short of deleting
files). No state machine, no status tracking, no database.

## Recommendation

**No data model work is required for this feature.** The DBA role has no deliverables beyond this evaluation document.

If future requirements introduce the need for tracked state (e.g., versioning of the setup process, migration between
setup versions), that should be evaluated as a separate roadmap item — not bolted onto this skill.

## Alignment

- **Architect**: **Confirmed aligned.** Independent analysis reached the same conclusion. The system design
  (docs/architecture/onboarding-wizard-system-design.md) uses file-existence as the idempotency strategy. ADR-003 Part 4
  explicitly documents the "no persistent state" decision. No component requires tracked state beyond file artifacts.
- **Product Skeptic**: **Approved.** Evaluation deemed correct, well-reasoned, with the right conclusion. Noted that
  `docs/stack-hints/{detected-stack}.md` is conditional (only `laravel.md` currently exists as a bundled hint) —
  consistent with system design, no action needed.
- **Existing patterns**: Fully consistent with how all current skills handle state.
