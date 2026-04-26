<!-- BEGIN SHARED: orchestrator-preamble -->
<!-- Authoritative source: plugins/conclave/shared/orchestrator-preamble.md. Synced by sync-shared-content.sh. -->

**IMPORTANT: You are the primary agent in this conversation. Execute these instructions directly — do NOT delegate this
skill to a sub-Task agent. Run the orchestration here in the primary thread and use `TeamCreate` + `Agent` (with
`team_name`) so the user can see and interact with all teammates in real time.**

## Bootstrap Check

Before proceeding to Setup, verify the project is bootstrapped for conclave. Check whether `docs/` exists at the
working-directory root. If it does NOT, abort with:

> "This project hasn't been bootstrapped for conclave. Run `/conclave:setup-project` first, then re-invoke this skill."

If `docs/` exists, proceed to Setup. (The `mkdir`-if-missing safety net in Setup remains as a backstop for projects that
are partially bootstrapped, but the user-facing message above ensures they know what to run.)

<!-- END SHARED: orchestrator-preamble -->
