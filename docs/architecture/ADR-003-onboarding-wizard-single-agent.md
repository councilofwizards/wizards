---
title: "Onboarding Wizard: Single-Agent Skill with File-Existence Idempotency"
status: "accepted"
created: "2026-02-19"
updated: "2026-02-19"
superseded_by: ""
---

# ADR-003: Onboarding Wizard: Single-Agent Skill with File-Existence Idempotency

## Status

Accepted

## Context

The onboarding wizard (`/setup-project`) needs to bootstrap a project for the conclave plugin by detecting the tech
stack, scaffolding the `docs/` directory structure, generating a `CLAUDE.md`, and creating a starter roadmap. The
roadmap item (P3-02) explicitly states "no multi-agent team needed — single agent" and requires the skill to be
idempotent.

Key forces:

1. **Simplicity over generality.** The task is deterministic: read filesystem state, create missing artifacts. There is
   no subjective judgment, no adversarial review needed, no concurrent work.
2. **Cost efficiency.** Multi-agent skills spawn 4-5 Opus-level agents. For a setup utility that runs once per project,
   this cost is unjustifiable.
3. **Speed.** Users expect setup to complete in under 5 minutes. Multi-agent coordination adds latency without adding
   value.
4. **Idempotency.** Running the skill twice must not destroy existing work. This is critical because users may run
   `/setup-project` on a project that already has partial documentation.
5. **No persistent state infrastructure.** The conclave plugin operates on markdown files. There is no database, no
   state store, no session management. Any state tracking must use the filesystem.

## Decision

### Part 1: Single-Agent Architecture

`/setup-project` is a single-agent skill — no team spawning, no skeptic gate, no checkpoint protocol. The SKILL.md
contains the full execution logic as a sequential pipeline that the invoking agent follows directly.

This departs from the multi-agent pattern used by `plan-product`, `build-product`, and `review-quality`. The departure
is justified because:

- **No subjective output.** The skill creates a directory structure and templates. There is nothing for a skeptic to
  challenge — the output is either correct (directories exist, files are valid markdown) or not.
- **No parallel work.** All steps are sequential and depend on the previous step's output (state detection drives
  everything else). Parallelism would add complexity without benefit.
- **No research phase.** Tech stack detection is a filesystem scan, not a research task requiring an Opus-level
  researcher.

### Part 2: File-Existence Idempotency

The skill uses file-existence checks as its idempotency mechanism. Before writing any artifact, it checks whether the
target file/directory already exists:

- **If missing:** Create it.
- **If exists (non-CLAUDE.md):** Skip silently.
- **If CLAUDE.md exists:** Do not overwrite. Read existing content, inform the user, and suggest additions they can
  manually incorporate.

This is chosen over two alternatives:

1. **Marker file approach** (e.g., `docs/.setup-complete`): A hidden marker file that indicates setup has been run. This
   fails when users delete individual artifacts — the marker says "complete" but artifacts are missing. It also adds a
   non-obvious hidden dependency.
2. **Content-hash approach** (track hashes of generated files to detect changes): Over-engineered for this use case.
   Adds complexity to detect whether a file was modified by the user vs. by a previous setup run. The simpler "exists or
   not" check is sufficient because the skill never needs to update previously generated content.

### Part 3: CLAUDE.md Special Handling

`CLAUDE.md` receives special treatment because it is the most likely artifact to be user-modified. Unlike templates and
directory structures (which users rarely touch), `CLAUDE.md` is a living document that users customize. Overwriting it
would destroy their work.

The skill's behavior when `CLAUDE.md` exists:

1. Read the existing content
2. Generate the content it would have written
3. Diff the two (conceptually — present as a list of suggested additions)
4. Present suggestions to the user
5. Only modify if the user explicitly approves

### Part 4: No Persistent State

The skill requires no persistent state beyond the files it creates. No checkpoint files, no progress tracking, no
setup-status markers.

Rationale:

- The skill runs to completion in one pass (typically under 30 seconds of agent time)
- If interrupted, the user simply re-runs it — idempotency ensures no harm
- There is no multi-agent coordination that would need checkpoint-based recovery
- The files themselves are the state — their existence (or absence) is all the skill needs to know

## Alternatives Considered

### Multi-agent with researcher + skeptic

A scaled-down team: researcher detects the stack, architect generates the scaffolding, skeptic reviews. Rejected because
the task is too simple to justify the overhead. Stack detection is a file scan, not research. Scaffolding is
deterministic, not architectural. There is nothing meaningful for a skeptic to review.

### Interactive wizard (multi-step prompting)

A conversational skill that asks the user questions step-by-step: "What is your tech stack?", "What categories do you
want in your roadmap?", etc. Rejected because auto-detection is faster and less burdensome. The skill should detect what
it can and only ask when genuinely ambiguous (e.g., multiple manifests found). The goal is under 5 minutes from install
to first `/plan-product`.

### Template-only approach (no detection)

Simply copy a fixed set of templates without any project-specific customization. Rejected because the value of
`/setup-project` over manual setup is precisely the customization — stack-specific CLAUDE.md content, tailored roadmap
categories, and framework-aware guidance.

## Consequences

- **Positive**: Minimal cost — single agent, no Opus team spawn.
- **Positive**: Fast execution — no inter-agent communication latency.
- **Positive**: Simple SKILL.md — the entire skill fits in a single markdown file with no team spawning logic.
- **Positive**: Self-healing idempotency — re-running after deleting an artifact recreates just that artifact.
- **Positive**: Safe for existing projects — CLAUDE.md is never overwritten without user consent.
- **Negative**: No quality gate — if the detection logic produces bad output (wrong stack, bad categories), there is no
  skeptic to catch it. Mitigated by keeping detection simple and asking the user to confirm ambiguous cases.
- **Negative**: No recovery mechanism — if the agent crashes mid-execution, partial state may exist. Mitigated by
  idempotency: re-running completes the missing artifacts.
- **Negative**: Sets a precedent for skills without skeptic review. Must be clear in documentation that this exception
  is specific to deterministic utility skills, not a general pattern. P3-03 (Architecture & Contribution Guide) is the
  next likely candidate for this single-agent pattern, as it is also a documentation-generation utility with
  deterministic output.
