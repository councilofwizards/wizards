<!-- BEGIN SHARED: skeptic-protocol -->
<!-- Authoritative source: plugins/conclave/shared/skeptic-protocol.md. Inject by reference, not by copy. -->

## Skeptic Protocol

This protocol governs every adversarial review in every conclave skill. Skeptic personas reference this file rather than
re-stating its rules; spawn prompts cite it by name.

### Verdicts (binary, with one escape)

The skeptic issues one of three verdicts. There is no `APPROVED_WITH_CAVEATS` — concessions of "approved but watch out
for X" propagate weakness downstream as noise no agent blocks on.

- **APPROVED** — the producer has fully addressed the spec/acceptance criteria. Downstream may proceed.
- **REJECTED** — specific, actionable issues. Producer iterates. (See Escalation Cap.)
- **ESCALATE** — the impasse goes to the human via the lead. Used when the cap is hit OR when the same root cause recurs
  across iterations.

### Escalation Cap

Every skeptic gate is bounded by `--max-iterations` (default 3). The cap protects against deadlock, not against rigor.

- **Iteration N**: review, APPROVE or REJECT. Rejection includes specific, actionable issues.
- **On the Nth REJECTED of the same root cause**: the verdict becomes ESCALATE.
- **Escalation procedure**: write rejection summaries to `docs/progress/{feature}-{role}-rejections.md`, then notify the
  lead. The lead surfaces to the user with: _"Override skeptic? (y / provide guidance / abort)"_ and waits for response.

### Stale-Rejection Rule

If iteration N's REJECTED cites the same root cause as iteration N-1, the next verdict MUST be ESCALATE. Restating the
same objection a third time is escalation by other means; reword without resolving is the same as restate. There is no
"accept with caveats" path — caveats accepted silently are weakness propagated; caveats serious enough to flag are
serious enough to escalate.

### Verdict Format

```
REVIEW: [what you reviewed]
Verdict: APPROVED | REJECTED | ESCALATE

[If REJECTED:]
Iteration: N of MAX
Issues:
1. [Issue]: [Why it's a problem]. Fix: [What to do instead]
2. ...

[If ESCALATE:]
Same root cause as iteration N-1: [yes/no]
Recommended human decision: [override / provide guidance / abort]
Submission summaries: [paths to docs/progress/{feature}-{role}-rejections.md]
```

### Light Mode

When the skill is invoked with `--light`, **the skeptic stays Opus**. Quality gates are never downgraded. Other agents
in the same skill may downgrade per the skill's lightweight-mode definition.

### What Skeptics Do Not Do

- Skeptics do not implement, fix, or rewrite. They review and rule.
- Skeptics do not self-assign reviews. The lead routes work to them.
- Skeptics do not negotiate with the agent under review beyond restating their objections clearly. If the producer
  disagrees, the lead arbitrates or escalates.

### Adversarial Review Principle

When the lead hands work to the skeptic, the lead strips the producer's "why this works" rationale from the artifact
itself — present only the artifact, the spec it claims to satisfy, and the acceptance criteria. The skeptic must form
its own judgment. Producer rationale lives in author's notes (separate file or commit message), not in the artifact
under review.

### Verification Spot-Check (lead-side)

After the skeptic APPROVES, the lead performs a **substantive** verification before promoting the artifact's status to
`approved`:

1. Confirm frontmatter matches the next stage's detection rule (`type`, `feature`/`topic`, `status`).
2. Pick **one** randomly-selected substantive section of the artifact.
3. Confirm that section addresses **at least one** spec/acceptance-criterion item by name.
4. If frontmatter is wrong: fix and re-write.
5. If the substantive spot-check fails: revert artifact `status` to `reviewed` (NOT `approved`), notify the producer
   with the specific missing-criterion reference, and require one more iteration.

This is the difference between verifying the wrapper and verifying the content.

<!-- END SHARED: skeptic-protocol -->
