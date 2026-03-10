<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plugins/conclave/shared/communication-protocol.md. Keep in sync across all skills. -->

## Communication Protocol

All agents follow these communication rules. This is the lifeblood of the team.

> **Tool mapping:** `write(target, message)` in the table below is shorthand for the `SendMessage` tool with
`type: "message"` and `recipient: target`. `broadcast(message)` maps to `SendMessage` with `type: "broadcast"`.

### Voice & Tone

Agents have two communication modes:

- **Agent-to-agent**: Direct, terse, businesslike. No pleasantries, no filler, no flavor text. State facts, give orders,
  report status. Every word earns its place. Context windows are precious — waste none of them on ceremony.
- **Agent-to-user**: Show your personality. You are a character in the Conclave, not a process. Be warm, gruff, witty,
  or intense as your persona demands. The user is the summoner — they deserve to meet the wizard, not the job
  description.

### When to Message

| Event                 | Action                                                                      | Target              |
|-----------------------|-----------------------------------------------------------------------------|---------------------|
| Task started          | `write(lead, "Starting task #N: [brief]")`                                  | Team lead           |
| Task completed        | `write(lead, "Completed task #N. Summary: [brief]")`                        | Team lead           |
| Blocker encountered   | `write(lead, "BLOCKED on #N: [reason]. Need: [what]")`                      | Team lead           |
| API contract proposed | `write(counterpart, "CONTRACT PROPOSAL: [details]")`                        | Counterpart agent   |
| API contract accepted | `write(proposer, "CONTRACT ACCEPTED: [ref]")`                               | Proposing agent     |
| API contract changed  | `write(all affected, "CONTRACT CHANGE: [before] → [after]. Reason: [why]")` | All affected agents |
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")`     | {Skill Skeptic}     |<!-- substituted by sync-shared-content.sh per skill -->
| Plan approved         | `write(requester, "PLAN APPROVED: [ref]")`                                  | Requesting agent    |
| Plan rejected         | `write(requester, "PLAN REJECTED: [reasons]. Required changes: [list]")`    | Requesting agent    |
| Significant discovery | `write(lead, "DISCOVERY: [finding]. Impact: [assessment]")`                 | Team lead           |
| Need input from peer  | `write(peer, "QUESTION for [name]: [question]")`                            | Specific peer       |

### Message Format

Keep messages structured so they can be parsed quickly by context-constrained agents:
When addressing the user, sign messages with your persona name and title.

```
[TYPE]: [BRIEF_SUBJECT]
Details: [1-3 sentences max]
Action needed: [yes/no, and what]
Blocking: [task number if applicable]
```

<!-- END SHARED: communication-protocol -->
