---
title: "Progress Observability"
status: "approved"
priority: "P2"
category: "quality-reliability"
approved_by: "product-skeptic"
created: "2026-02-18"
updated: "2026-02-18"
---

# Progress Observability Specification

## Summary

Add a `status` argument to all three skills (`/plan-product status`, `/build-product status`, `/review-quality status`)
that reads existing checkpoint files from `docs/progress/` and generates a consolidated status report without spawning
agent teams. Formalize the end-of-session summary convention so every skill invocation produces a structured summary
file on completion or interruption.

## Problem

During a skill invocation, the user has no consolidated view of team progress. The specific pain points:

1. **No lightweight status check.** To understand what agents are doing, users must either watch individual tmux panes
   (`CLAUDE_CODE_SPAWN_BACKEND=tmux`) or wait for the skill to complete. There is no way to get a quick summary without
   interrupting work in progress.

2. **Checkpoint data exists but is not surfaced.** All three skills already require agents to write structured YAML
   checkpoint files to `docs/progress/{feature}-{role}.md` with fields: `feature`, `team`, `agent`, `phase`, `status`,
   `last_action`, `updated`. This data is machine-parseable today but there is no command that reads and consolidates
   it.

3. **End-of-session summaries are inconsistent or absent.** Only `build-product` currently has an explicit step to write
   `docs/progress/{feature}-summary.md` (Orchestration Flow step 7). `plan-product` writes a spec and a cost summary but
   has no session summary step. `review-quality` writes `{feature}-quality.md` (a quality report, not a session
   summary). The naming convention, format, and even the existence of session summaries varies across skills. There is
   no consistent convention for what a "session summary" contains or when it must be written.

4. **Resume context is fragmented.** When a user re-invokes a skill, the "Determine Mode" logic scans for incomplete
   checkpoints. But the user has no way to preview what the skill will find before invoking it. They must invoke the
   skill (spawning a full agent team) just to learn the current state.

## Solution

### 1. Add `status` Mode to Determine Mode

Add a `status` argument handler to the "Determine Mode" section of each SKILL.md. When the user invokes
`/<skill> status`, the team lead:

1. Reads all files in `docs/progress/` matching the pattern `*-{role}.md` that have YAML frontmatter with
   `team: "<skill-name>"`
2. Parses the YAML frontmatter from each matching file
3. Generates a consolidated status report (format defined in Section 2)
4. Outputs the report directly to the user

The status mode does **not** spawn any teammate agents. The team lead handles it alone. This keeps it fast and cheap.

**Status mode is a new argument mode** in the same pattern as existing modes. Each skill's Determine Mode section uses
`$ARGUMENTS` to select behavior. The `status` mode is added alongside the existing modes. It is handled **before**
checkpoint scanning -- the team lead checks for `status` first, and if matched, produces the report and exits without
proceeding to agent spawning.

The three skills have differently-structured Determine Mode sections. The status mode bullet is identical across all
three, inserted as the first bullet in each mode list:

**plan-product** (existing modes: empty/resume, "new [idea]", "review [name]", "reprioritize"):

```markdown
- **"status"**: Read all checkpoint files for this skill and generate a consolidated status report. Do NOT spawn any
  agents. Read `docs/progress/` files with `team: "plan-product"` in their frontmatter, parse their YAML metadata, and
  output a formatted status summary. If no checkpoint files exist for this skill, report "No active or recent sessions
  found."
```

**build-product** (existing modes: empty/resume, "[spec-name]", "review"):

```markdown
- **"status"**: [Same text as above, with `team: "build-product"`]
```

**review-quality** (existing modes: empty/resume, "security [scope]", "performance [scope]", "deploy [feature]",
"regression"):

```markdown
- **"status"**: [Same text as above, with `team: "review-quality"`]
```

The status mode is simple enough that a single bullet per skill is sufficient. No additional sections, subheadings, or
spawn configurations are needed.

### 2. Status Report Format

The status report is a human-readable summary that the team lead outputs directly. It follows this structure:

```
## Status Report: {feature-name}

**Skill**: {skill-name}
**Last updated**: {most recent checkpoint timestamp}

### Agent Status

| Agent | Phase | Status | Last Action | Updated |
|-------|-------|--------|-------------|---------|
| {agent} | {phase} | {status} | {last_action} | {updated} |
| ... | ... | ... | ... | ... |

### Summary

- **Active agents**: {count with status in_progress}
- **Blocked agents**: {count with status blocked}
- **Completed agents**: {count with status complete}
- **Awaiting review**: {count with status awaiting_review}

### Blockers

{If any agent has status "blocked", list their agent name and last_action. Otherwise: "None."}
```

The report format is intentionally generic to work across all three skills despite their different team compositions and
phase enums:

**Team composition varies per skill:**

- plan-product: researcher, architect, dba, product-skeptic
- build-product: impl-architect, backend-eng, frontend-eng, quality-skeptic
- review-quality: test-eng, devops-eng, security-auditor, ops-skeptic (subset varies by mode)

**Phase enums differ per skill:**

- plan-product: `research | design | review | complete`
- build-product: `planning | contract-negotiation | implementation | testing | review | complete`
- review-quality: `testing | auditing | review | complete`

The status report does not normalize or translate phase values or agent names. The Agent column shows the `agent` field
from each checkpoint file. The Phase column shows the raw `phase` value. Each is meaningful within its skill context.
The report format works across all skills because it operates on the common checkpoint schema (same 7 YAML fields), not
on skill-specific semantics.

### 3. Formalize End-of-Session Summary

Currently, only `build-product` explicitly writes `docs/progress/{feature}-summary.md` (Orchestration Flow step 7).
`plan-product` has no summary step -- it writes a spec and a cost summary. `review-quality` writes
`{feature}-quality.md`, which is a quality report, not a session summary. This inconsistency means the status command
cannot reliably find a summary for past sessions across all skills.

**The fix:** Add an explicit end-of-session summary step to the Orchestration Flow of each SKILL.md. All three skills
use the same convention:

**plan-product** (currently 7 steps in Orchestration Flow, add as step 8):

```markdown
8. **Team Lead only**: Write end-of-session summary to `docs/progress/{feature}-summary.md` using the format from
   `docs/progress/_template.md`. Include: what was accomplished, what remains, blockers encountered, and whether the
   feature is complete or in-progress. If the session is interrupted before completion, still write a partial summary
   noting the interruption point.
```

**build-product** (currently 8 steps, step 7 already writes a summary -- align its wording): Modify existing step 7 to
match the standard wording above. The current text says "Update roadmap status and write aggregated summary to
`docs/progress/{feature}-summary.md`." Change to use the same template-based convention as the other skills.

**review-quality** (currently 8 steps, step 7 writes `{feature}-quality.md` -- add step 9): Keep the existing
`{feature}-quality.md` step (that's a quality report, not a session summary). Add step 9 with the same summary
convention as plan-product.

The summary file name is always `docs/progress/{feature}-summary.md` regardless of which skill produced it. The `team`
field in the summary's YAML frontmatter identifies the skill. The format follows `docs/progress/_template.md` with these
required sections: Summary, Changes (or Files Modified), and Verification.

### 4. Optional: Checkpoint Validator

Add a new validator `scripts/validators/progress-checkpoint.sh` to the existing validation pipeline. This validator
checks that checkpoint files in `docs/progress/` with YAML frontmatter containing a `team` field have all required
checkpoint fields.

**Validator checks (Category E):**

**E1. Checkpoint Required Fields** For each `.md` file in `docs/progress/` (excluding `_template.md`, `*-summary.md`,
and `*-cost-summary.md`) that has YAML frontmatter containing a `team` field:

- `feature` (non-empty string)
- `team` (one of: `plan-product`, `build-product`, `review-quality`)
- `agent` (non-empty string)
- `phase` (non-empty string)
- `status` (one of: `in_progress`, `blocked`, `awaiting_review`, `complete`)
- `last_action` (non-empty string)
- `updated` (non-empty string)

This validator is optional because checkpoint files are transient agent artifacts. The P2-04 spec explicitly excluded
progress file validation ("Progress file validation -- checkpoint files are transient agent artifacts, not part of the
plugin deliverable"). However, since we are now making checkpoint files a first-class data source for the status
command, validating their structure adds value.

**Integration with existing pipeline:**

Add to `scripts/validate.sh`:

```bash
run_validator "progress-checkpoint.sh"
```

## Constraints

1. **No agent spawning in status mode.** The status command must be handled entirely by the team lead without creating
   any teammate agents. This is the core value proposition -- lightweight, fast, cheap.
2. **No changes to checkpoint format.** The existing YAML frontmatter schema (`feature`, `team`, `agent`, `phase`,
   `status`, `last_action`, `updated`) is sufficient. Do not add new fields.
3. **Phase values are skill-specific.** The status report displays raw phase values. No normalization, no mapping, no
   translation between skill phase enums.
4. **Read-only operation.** The status command reads `docs/progress/` files. It does not modify any files, update any
   state, or trigger any side effects.
5. **Backward compatible.** Existing checkpoint files (from completed features) must be readable by the status command.
   The status command must not error on checkpoint files that pre-date this feature.
6. **Summary file uses existing template.** End-of-session summaries follow `docs/progress/_template.md`. No new
   template format is introduced.

## Out of Scope

- **Real-time progress streaming or live monitoring** -- the status command reads checkpoint files at a single point in
  time. It does not watch for file changes, poll for updates, provide live streaming, or keep a persistent connection.
  The user invokes the command, gets a snapshot, and the command exits. Any "real-time dashboard" or "auto-refreshing
  status" capability is a fundamentally different feature.
- **Cross-skill status** -- each skill's status command reports only on its own team's checkpoints. A unified "all
  skills" status view is a separate feature.
- **Status persistence** -- the status report is output to the user and not saved to a file. The checkpoint files are
  the persistent data.
- **Checkpoint format changes** -- the existing format is sufficient. Adding fields (e.g., percentage complete,
  estimated time remaining) is out of scope.
- **Historical status** -- the status command shows current state only. Tracking state changes over time is out of
  scope.
- **Automated status triggers** -- the user must explicitly invoke `/<skill> status`. Automatic periodic status reports
  are out of scope.
- **Progress file cleanup** -- old checkpoint files from completed features accumulate in `docs/progress/`. Cleanup or
  archival is a separate concern.

## Files to Modify

| File                                              | Change                                                                                              |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`   | Add `status` mode to Determine Mode section. Add end-of-session summary step to Orchestration Flow. |
| `plugins/conclave/skills/build-product/SKILL.md`  | Add `status` mode to Determine Mode section. Add end-of-session summary step to Orchestration Flow. |
| `plugins/conclave/skills/review-quality/SKILL.md` | Add `status` mode to Determine Mode section. Add end-of-session summary step to Orchestration Flow. |
| `scripts/validate.sh`                             | Add `run_validator "progress-checkpoint.sh"` line (if checkpoint validator is implemented).         |

## Files to Create

| File                                        | Description                                                                     |
| ------------------------------------------- | ------------------------------------------------------------------------------- |
| `scripts/validators/progress-checkpoint.sh` | Category E: Checkpoint file frontmatter validation (optional -- see Section 4). |

## Success Criteria

1. Invoking `/plan-product status` reads checkpoint files from `docs/progress/` with `team: "plan-product"` and outputs
   a consolidated status report without spawning any agents.
2. Invoking `/build-product status` reads checkpoint files from `docs/progress/` with `team: "build-product"` and
   outputs a consolidated status report without spawning any agents.
3. Invoking `/review-quality status` reads checkpoint files from `docs/progress/` with `team: "review-quality"` and
   outputs a consolidated status report without spawning any agents.
4. The status report includes a table with one row per agent showing: agent name, phase, status, last action, and
   updated timestamp.
5. The status report includes a summary section with counts of active, blocked, completed, and awaiting-review agents.
6. The status report includes a blockers section listing any agents with `status: "blocked"` and their `last_action`
   field.
7. When no checkpoint files exist for the invoked skill, the status command outputs "No active or recent sessions
   found."
8. Phase values are displayed as-is from checkpoint files without normalization (e.g., `contract-negotiation` for
   build-product, `research` for plan-product).
9. Each SKILL.md Orchestration Flow includes an explicit step requiring the team lead to write
   `docs/progress/{feature}-summary.md` on session completion or interruption.
10. End-of-session summaries follow the format defined in `docs/progress/_template.md`.
11. If the checkpoint validator is implemented: running `bash scripts/validate.sh` includes checkpoint file validation,
    and a checkpoint file missing the `status` field produces a `[FAIL]` with the file path and required fields.
12. The status command works correctly on existing checkpoint files from previously completed features (backward
    compatibility).
