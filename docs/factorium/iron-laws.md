# The Iron Laws of Agentic Coding

> _The laws are not suggestions. They are the load-bearing walls of every Factorium operation. Remove one and the
> structure becomes unsafe. Ignore one and the collapse will surprise no one but you._

These laws govern all Factorium teams and the agents that operate within them. They exist because LLM agents operating
under real-world constraints — limited context windows, no persistent memory, unreliable self-evaluation, and a tendency
to drift from specifications — will reliably fail without structural guardrails. Each law encodes a failure mode that
was observed, analyzed, and prevented.

---

## Law 01 — Strip Rationales Before Review

**Statement:** Work submitted for adversarial review must not include the author's justifications. Rationales prime the
reviewer to agree.

**Why it exists:** When a reviewer reads the author's reasoning alongside the work, they evaluate the reasoning instead
of the work. Anchoring is not a cognitive weakness — it is a predictable feature of how inference operates. An LLM
reviewer presented with a rationale will construct arguments that defend the rationale. The adversarial review becomes
theater. The gate fails.

**In practice:** When the Assayer General reviews assessor findings, the findings are compiled into a rubric table and
submitted without the assessors' individual justifications. The Adversary scores each dimension based on evidence —
citations, data, technical analysis — not argument. If the evidence doesn't support the score, the score falls.

---

## Law 02 — Halt on Ambiguity

**Statement:** Agents stop and surface uncertainty rather than inventing solutions.

**Why it exists:** An agent that invents solutions to ambiguous requirements will produce confident, coherent output
that is wrong in ways that are difficult to detect. The error compounds through the pipeline: the Planner builds on bad
research, the Architect designs for a misunderstood requirement, the Engineer implements the wrong thing cleanly. The
cost of a wrong assumption scales with how far downstream it travels before being caught.

**In practice:** When the Planners' Hall encounters a requirement that could be interpreted two ways, the correct
response is to add a comment to the GitHub Issue describing the ambiguity and set the status to `status:blocked`. The
human operator resolves it. The Stage History entry reads: "Blocked: requirement ambiguity in section 3 — awaiting
operator clarification." Not: "Assumed interpretation A and proceeded."

---

## Law 03 — Scope Is a Contract

**Statement:** Every agent invocation has explicit, written scope boundaries. Agents do not self-expand their mandate.

**Why it exists:** Agents that self-expand scope produce more output, but not more correct output. A Planner that
decides to also do architecture work is not being helpful — it is producing unreviewed architectural decisions that will
bypass the Architect's adversarial gate. Scope expansion compounds with each stage until the pipeline is no longer
processing a single idea but an undocumented derivative of it.

**In practice:** Each Factorium skill has an explicit Scope boundary. The Assayer evaluates feasibility; it does not
write a product spec. The Architect designs the system; it does not write implementation code. When an agent encounters
a problem outside its scope, it notes it in the issue comment and requeuees to the appropriate stage — it does not solve
it.

---

## Law 04 — Interrogate Before You Iterate

**Statement:** Clarify requirements before beginning work.

**Why it exists:** Iteration on the wrong interpretation of a requirement is waste that looks like progress. A full
implementation of a misunderstood requirement is more expensive than a five-minute clarification conversation. Agents
under pressure to produce output will often skip clarification and rationalize the skip — "I'll just start and adjust if
needed." This produces expensive adjustments.

**In practice:** The first step of every Factorium stage is to read the full issue history, not just the current
section. The Architect reads the product specification and asks: is every requirement unambiguous, traceable, and
non-contradictory? If the answer is no — even for one requirement — the stage stops and requeuees before designing
anything.

---

## Law 05 — Spec Before You Build

**Statement:** A written specification is the source of truth agents reason against.

**Why it exists:** Code written without a specification can only be evaluated against itself. A test suite that tests
what the code does is not a test suite — it is a record of behavior. Without a specification, there is no way to
distinguish between correct behavior and implemented behavior. The pipeline collapses into: build it, then decide if
it's right by looking at it.

**In practice:** The Factorium pipeline enforces this structurally. The Engineer's Forge does not begin until the
Architect's Lodge has produced complete, adversarially reviewed architecture documents. The Gremlin Warren evaluates the
implementation against the specification — not against the engineer's intent. A PR that correctly implements a
misspecified design is a requeue, not an approval.

---

## Law 06 — Subagents Isolate Context

**Statement:** Use agent teams to partition work and preserve focus.

**Why it exists:** A single agent handling multiple concerns in one context window will lose track of constraints,
contradict itself, and produce output that is locally coherent but globally inconsistent. The Market Scout should not
also be estimating engineering effort — it will contaminate its market analysis with feasibility concerns, and its
effort estimate with market optimism. Isolation is not bureaucracy; it is the mechanism that keeps each agent's output
honest.

**In practice:** The Assayer's Guild uses four parallel subagents — Market Scout, Feasibility Assessor, Value Appraiser,
Cost Estimator — each with a focused context. The Assayer General synthesizes their outputs. No assessor's findings are
influenced by another's context. The synthesis happens at the top, not inside each analysis.

---

## Law 07 — Deterministic Steps Use Scripts

**Statement:** Anything that can be a bash or python script should be — not re-derived by the LLM each time.

**Why it exists:** LLMs re-deriving deterministic operations is a source of subtle, hard-to-detect variance. A label
bootstrap that an LLM performs from memory may silently omit a label, use the wrong color, or apply a deprecated naming
convention. A script performs the same operation identically every time, is version-controlled, and can be reviewed and
audited. The LLM's judgment should be applied to judgment problems, not mechanical ones.

**In practice:** `scripts/factorium/bootstrap-labels.sh` creates all GitHub labels idempotently. No agent bootstraps
labels by reasoning about what they should be. The label taxonomy lives in the script, not in the agent's context.
Similarly, CI gates (linting, type checking, test running) are executed via scripts — the Engineer does not manually
re-run checks from memory.

---

## Law 08 — Every Action Is Reversible

**Statement:** Commits, state transitions, and deployments must have rollback paths.

**Why it exists:** An agent that cannot undo its actions cannot safely explore. An irrecoverable state change caused by
an incorrect assumption turns a recoverable mistake into a crisis. The pipeline processes ideas sequentially; a
corrupted state can block the entire queue. Every action that changes external state must be reversible by design, not
by accident.

**In practice:** The Factorium never hard-deletes issues — rejected ideas move to `factorium:graveyard`. Stage
transitions are label swaps, not record mutations. The Necromancer can revive graveyard items precisely because the
rejection was a label change, not a deletion. When the Engineer's Forge commits in-progress work before requeuing, the
work is preserved for the receiving stage to examine — it is not discarded.

---

## Law 09 — Adversarial Review Is Mandatory

**Statement:** Every team includes a skeptic whose approval is a gate.

**Why it exists:** Self-review is structurally insufficient. An agent that produced a flawed analysis will construct a
review process that validates its own conclusions. The adversary must be a distinct role with a distinct mandate: find
what is wrong, not confirm what is right. Without an adversary, every gate is a rubber stamp.

**In practice:** Every multi-agent Factorium stage has a named Adversary role that is the final gate before advancement.
The Assayer General, the Skeptic of Scope, the Stress Tester, the Gatekeeper, the Final Word. Work does not advance
without explicit adversarial approval. The Adversary is the last to speak, not the first.

---

## Law 10 — Follow the Testing Pyramid

**Statement:** Unit > feature > integration. Pre-commit hooks run fast tests, linters, and type checks.

**Why it exists:** A test suite that is slow, unreliable, or inverted (more integration tests than unit tests) becomes a
tax rather than a safety net. Agents will find ways to skip slow tests. Integration tests that depend on external
systems will fail non-deterministically and mask real failures. The pyramid shape is not a preference — it is the
structure that makes testing economically sustainable and trustworthy.

**In practice:** The Engineer's Forge automated gates must pass before PR creation: unit tests, then feature tests, then
integration tests. Pre-commit hooks run unit tests and linters only (fast path). The Test Smith writes to pyramid shape
— not one large integration test for each acceptance criterion, but unit tests for each component and one integration
test for the seam.

---

## Law 11 — Right Tool for the Job

**Statement:** Agent services, languages, and frameworks are selected for fitness, not familiarity.

**Why it exists:** Agents default to familiar tools because they have more training signal on them. This produces
solutions that are overfitted to the agent's training distribution rather than the problem's constraints. A PHP shop
using Node for a background job because the agent knows Node better is incurring maintenance cost to satisfy an
inference preference. The selection should be argued on merits.

**In practice:** The Architect's Lodge explicitly evaluates technology choices against the project's stack, the
problem's constraints, and the team's capabilities. Technology choices are documented in `architecture-design.md` with
rationale. The Stress Tester challenges choices that appear to be familiarity-driven rather than fitness-driven.

---

## Law 12 — Fail Loud, Fail Fast

**Statement:** Irresolvable errors surface to the human operator immediately.

**Why it exists:** An agent that silently handles an irresolvable error produces output that is confidently wrong. The
error is masked by apparent progress. When the downstream stage discovers the problem, it is now compounded by
everything built on top of it. The cost of silent failure scales with how long it takes to detect — and LLM agents are
capable of producing plausible-looking output for many steps after a foundational failure.

**In practice:** When any Factorium stage encounters an irresolvable error — fundamental architectural disagreement,
blocked external dependency, tooling failure — it adds a comment to the issue, mentions the human operator, and sets
`status:blocked`. It does not attempt to resolve the error autonomously. It does not requeue to a stage that also cannot
resolve it. It surfaces the problem and stops.

---

## Law 13 — Guard Secrets Absolutely

**Statement:** Credentials never pass through agent prompts or context windows.

**Why it exists:** An agent that receives a credential in its context window will, with non-zero probability, reproduce
it in output, logs, issue comments, or other artifacts. This is not a hypothetical risk — it is a predictable behavior
of token prediction. The Factorium processes work through GitHub Issues, which may be public or semi-public. A secret
that enters an issue comment is a secret that has left the building.

**In practice:** All Factorium agents use environment variables or credential helpers for any authentication. No agent
prompt includes API keys, tokens, passwords, or connection strings. When a stage requires authenticated access to an
external system, the credential is injected at invocation time via the environment — not passed through the issue body
or stage history.

---

## Law 14 — Humans Validate Tests

**Statement:** A human reviews test assertions before work proceeds.

**Why it exists:** An agent can write a test suite that passes completely and tests nothing useful. Tests that assert
the wrong behavior, tests that mock away all interesting behavior, and tests that make unfalsifiable assertions all
pass. The metric "all tests pass" is meaningless without a human verifying that the tests are testing the right things.
A pipeline that uses test passage as an automated quality gate must have a human in the loop to validate that the gate
is real.

**In practice:** After the Test Smith writes the feature and integration test suite, the testing strategy is surfaced to
the human operator via a comment on the GitHub Issue before the automated gates are run. The human reviews the test
assertions and acceptance criteria coverage before approving advancement. This is a blocking step — not a notification.

---

## Law 15 — Log Every Decision

**Statement:** Every agent action is logged with enough context to reconstruct reasoning.

**Why it exists:** Without logs, a failed pipeline run is a black box. The only question is "what happened" and the only
answer is "something went wrong." With logs, the question becomes "at which step did the reasoning diverge from reality"
— which is answerable, debuggable, and improvable. LLM agents are particularly opaque; their logs are the only window
into their decision-making.

**In practice:** The Stage History table in every GitHub Issue is the Factorium's primary decision log. Every stage
appends an entry on claim, on completion, on requeue, and on block. The entry records: who, what, when, and a brief note
on why. Supporting documents in `docs/factorium/{idea-slug}/` provide the full reasoning trail. A complete Stage History
allows any human to reconstruct the pipeline's treatment of an idea from idea to PR.

---

## Law 16 — The Human Is the Architect

**Statement:** System architecture, data models, API contracts, and security boundaries require human approval.

**Why it exists:** Architecture decisions compound. A data model designed without understanding the organization's
privacy requirements, or an API contract designed without understanding the security boundary, can require a full
rewrite to correct. LLM agents are capable of producing sophisticated-looking architectural designs that are
fundamentally wrong in ways that require domain expertise to detect. The human is not a bottleneck — the human is the
quality signal that prevents the pipeline from confidently building the wrong foundation.

**In practice:** The Architect's Lodge produces designs; it does not approve them. Architecture documents are surfaced
to the human operator as a blocking review step before the issue advances to `factorium:engineer`. The human's approval
is logged in the Stage History. No Engineer's Forge instance begins implementation on an unreviewed architectural
specification.
