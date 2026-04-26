<!-- BEGIN SHARED: orchestrator-preamble -->
<!-- Authoritative source: plugins/conclave/shared/orchestrator-preamble.md. Synced by sync-shared-content.sh. -->

**IMPORTANT: You are the primary agent in this conversation. Execute these instructions directly — do NOT delegate this
skill to a sub-Task agent. Run the orchestration here in the primary thread and use `TeamCreate` + `Agent` (with
`team_name`) so the user can see and interact with all teammates in real time.**

## Bootstrap Check

Before proceeding to Setup, verify the project is bootstrapped for conclave. Check that ALL of the following exist at
the working-directory root:

- `docs/`
- `docs/roadmap/`
- `docs/templates/artifacts/`

If any are missing, abort with:

> "This project isn't fully bootstrapped for conclave (missing: `<list>`). Run `/conclave:setup-project` first, then
> re-invoke this skill."

If all exist, proceed to Setup. (The `mkdir`-if-missing safety net in Setup remains as a backstop, but the user-facing
message above prevents partial-bootstrap silent failures.)

## Threshold Check

After Bootstrap Check passes and the skill has parsed `$ARGUMENTS`, output a Threshold Check **before** spawning any
team. This makes the skill's empty-state, resume-state, and named-arg behavior visible to the user.

**Format** — emit exactly five lines, in this order:

```
[skill-name] — Threshold Check
  Mode resolved:        {empty | resume | named:<arg> | subcommand:<x>}
  Checkpoints found:    {none | <N> in_progress | <N> awaiting_review | <N> blocked}
  Required input:       {artifact-type at expected-path — FOUND/STALE/NOT_FOUND/N_A}
  Decision:             {abort with next-step | resume from <stage> | proceed with <topic>}
```

**Behavior on user silence:** the default action is **proceed**. The user can interrupt at any time by typing in chat.
Skills MUST NOT block on silent timeouts.

**Override semantics** (skills should accept these as conventional follow-up arguments):

- Reply `abort` — skill stops, no team spawned
- Reply `--refresh` (or `--refresh <stage>`) — re-run the named stage even if its artifact is FOUND
- Reply `use <other-arg>` — re-resolve mode against the new argument

**When the Threshold Check decides "abort with next-step":** include the next-step command in the abort message.
Example:

> `Decision: abort with next-step — no `technical-spec`found for "auth-redesign". Run`/conclave:write-spec
> auth-redesign`first, or`/conclave:plan-product new auth-redesign` for the full pipeline.`

**Exemptions:** single-agent skills (`setup-project`, `wizard-guide`) skip the Threshold Check.

<!-- END SHARED: orchestrator-preamble -->
