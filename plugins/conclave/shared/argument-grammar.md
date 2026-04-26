## Argument Grammar (canonical)

This file defines the unified argument grammar every conclave skill follows. Skills' `argument-hint` frontmatter and
their `## Determine Mode` sections must conform.

### Grammar

```
<primary-arg-or-empty> [subcommand <subcommand-args>] [--global-flags]
```

- **`<primary-arg>`** — the main thing the skill is about: a topic, feature name, scope, PR identifier, etc. When
  omitted, the skill enters resume-or-intake mode (see Empty-State Semantics below).
- **`[subcommand]`** — one of a fixed vocabulary (see Subcommand Vocabulary). Optional. When present, modifies the
  skill's primary verb.
- **`[--global-flags]`** — global flags applied across most multi-agent skills (see Global Flags). Optional.

### Subcommand vocabulary (fixed; do not invent new ones)

When a skill needs a sub-mode, it MUST use one of these verbs (or document a deliberate exception):

| Verb         | Meaning                                                                                       |
| ------------ | --------------------------------------------------------------------------------------------- |
| `status`     | Read checkpoints; report state; do NOT spawn the team.                                        |
| `resume`     | Explicit resume from last checkpoint. (Equivalent to empty-args + an in-progress checkpoint.) |
| `audit`      | Read-only inspection. Produces a report; makes no changes.                                    |
| `plan`       | Produce a plan artifact only; do not execute.                                                 |
| `execute`    | Run the action implied by the skill (build, fix, refactor).                                   |
| `review`     | Adversarial / verification pass on existing work.                                             |
| `ingest`     | Take an external artifact and integrate it (used by `manage-roadmap`).                        |
| `survey`     | Pre-implementation reconnaissance (used by `craft-laravel`).                                  |
| `triage`     | Sort incoming work into buckets.                                                              |
| `analyse`    | Diagnostic analysis (`squash-bugs` uses British spelling for historical reasons).             |
| `full`       | Run all stages/phases of a pipeline regardless of artifact detection.                         |
| `remediate`  | Apply fixes to issues previously identified (used by `harden-security`).                      |
| `governance` | Process-and-policy-only audit (used by `audit-slop`).                                         |

If a skill needs a verb not in this list, propose an addition rather than coining a one-off.

**Documented skill-specific extensions (not part of the canonical vocabulary; OK to use within their named skill):**

- `reprioritize` — `manage-roadmap` only
- `deploy <feature>`, `regression`, `performance <scope>` — `review-quality` only
- `list`, `recommend <goal>`, `explain <skill-name>` — `wizard-guide` only (single-agent skill, exempt)

These are grandfathered for backward compatibility. New skills should not coin one-offs; extend the canonical vocabulary
instead.

### Global flags (apply to all multi-agent skills unless noted)

| Flag                     | Values                                        | Default      | Description                                                     |
| ------------------------ | --------------------------------------------- | ------------ | --------------------------------------------------------------- |
| `--max-iterations N`     | Positive integer                              | 3            | Skeptic rejection ceiling before ESCALATE                       |
| `--checkpoint-frequency` | `every-step`, `milestones-only`, `final-only` | `every-step` | How often agents write progress checkpoints                     |
| `--light`                | (flag, no value)                              | off          | Reduce non-skeptic models for cost savings                      |
| `--refresh`              | (flag, no value)                              | off          | Force re-run of detected stages even if FOUND                   |
| `--refresh-after Nd`     | Days as integer                               | none         | Re-run a stage if its artifact's `updated` is older than N days |
| `--confirm`              | (flag, no value)                              | off          | Pause on Threshold Check; require explicit user response        |
| `--yes`                  | (flag, no value)                              | off          | Suppress all confirmation prompts (CI-safe)                     |

Pipeline skills accept additional flags documented in their own `Determine Mode` sections.

### Argument-hint format (for SKILL.md frontmatter)

Every skill's `argument-hint` MUST follow this shape:

```
"<primary-arg-or-empty> [subcommand <args>] [--global-flags]"
```

Use `<angle-brackets>` for required values. Use `[square-brackets]` for optional. Use `|` inside brackets for choices.
The phrase `(empty for X)` is forbidden — instead, document empty-state behavior in `## Determine Mode` and let the
Threshold Check (see `orchestrator-preamble.md`) handle the report.

### Empty-state semantics (uniform)

When a skill is invoked with no primary-arg and no subcommand:

1. Run Bootstrap Check (orchestrator-preamble).
2. Scan `docs/progress/` and `docs/continues/` for in-progress, awaiting_review, or blocked checkpoints.
3. Output Threshold Check (orchestrator-preamble).
4. Default action: **proceed with the resolved mode** (resume in-progress work if found, otherwise intake mode).
5. The user can interrupt at any time. Skills MUST NOT block on silent timeouts.

### Examples (canonical)

```
/conclave:plan-product new auth-redesign --full
/conclave:write-spec auth --refresh-after 7d
/conclave:build-implementation payments
/conclave:build-implementation status
/conclave:audit-slop full --light
/conclave:harden-security audit auth
/conclave:run-task "convert the email queue to use SES"
```
