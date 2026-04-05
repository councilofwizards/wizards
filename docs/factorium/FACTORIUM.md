# The Factorium

> _A steampunk assembly line of gnomes, dwarves, gremlins, and warforged -- processing raw ideas into shippable code
> through distributed agent teams, coordinated by GitHub Issues and governed by the Iron Laws of Agentic Coding._

---

## I. Vision & Purpose

The Factorium is a distributed, multi-stage pipeline that transforms raw product ideas into merged pull requests. Each
stage of the pipeline is operated by an independent agent team ("loop") running in its own terminal. Teams communicate
exclusively through GitHub Issues -- never through shared memory, context windows, or direct invocation.

The system is designed for LLM agents operating under real-world constraints: limited context windows, no persistent
memory between invocations, unreliable self-evaluation, and a tendency to drift from specifications. Every design
decision in this document accounts for these limitations.

The pipeline stages, in order:

1. **The Dreamer's Workshop** -- Ideation (manual invocation)
2. **The Assayer's Guild** -- Research & Validation (polling loop)
3. **The Planners' Hall** -- Product Planning (polling loop)
4. **The Architect's Lodge** -- Architecture & Design (polling loop)
5. **The Engineer's Forge** -- Implementation (polling loop)
6. **The Gremlin Warren** -- Review & Audit (polling loop, also on-demand)
7. **The Necromancer's Crypt** -- Graveyard Revival (manual invocation)

Each loop runs independently in a separate terminal. Loops claim work atomically via GitHub Issue assignment. Most loops
run a single instance for safety. The Dreamer and the Necromancer are invoked manually by the human operator.

---

## II. Governing Principles

### The Iron Laws of Agentic Coding

All Factorium teams operate under the Iron Laws. These are non-negotiable constraints. The full laws are maintained in
the project's documentation (see the wizards plugin or `docs/iron-laws.md`), but the laws most critical to the Factorium
are summarized here for convenience:

1. **Strip rationales before review.** Work submitted for adversarial review must not include the author's
   justifications. Rationales prime the reviewer to agree.
2. **Halt on ambiguity.** Agents stop and surface uncertainty rather than inventing solutions.
3. **Scope is a contract.** Every agent invocation has explicit, written scope boundaries. Agents do not self-expand
   their mandate.
4. **Interrogate before you iterate.** Clarify requirements before beginning work.
5. **Spec before you build.** A written specification is the source of truth agents reason against.
6. **Subagents isolate context.** Use agent teams to partition work and preserve focus.
7. **Deterministic steps use scripts.** Anything that can be a bash or python script should be -- not re-derived by the
   LLM each time.
8. **Every action is reversible.** Commits, state transitions, and deployments must have rollback paths.
9. **Adversarial review is mandatory.** Every team includes a skeptic whose approval is a gate.
10. **Follow the testing pyramid.** Unit > feature > integration. Pre-commit hooks run fast tests, linters, and type
    checks.
11. **Right tool for the job.** Agent services, languages, and frameworks are selected for fitness, not familiarity.
12. **Fail loud, fail fast.** Irresolvable errors surface to the human operator immediately.
13. **Guard secrets absolutely.** Credentials never pass through agent prompts or context windows.
14. **Humans validate tests.** A human reviews test assertions before work proceeds.
15. **Log every decision.** Every agent action is logged with enough context to reconstruct reasoning.
16. **The human is the architect.** System architecture, data models, API contracts, and security boundaries require
    human approval.

### Factorium-Specific Principles

Beyond the Iron Laws, the Factorium adds these operational principles:

- **Single-claim, single-item.** Each loop claims exactly one item at a time and works it to completion before polling
  again.
- **Dependency-ordered processing.** Items in every queue are listed in dependency order. The top unclaimed item is
  always the next valid item to work. Skipping ahead is never permitted.
- **Claim-then-verify.** To claim an item, an agent assigns the GitHub Issue to itself, then immediately re-reads the
  issue to confirm the assignment stuck. If another agent claimed it first, back off and poll again.
- **Requeue over discard.** When a stage discovers a problem it cannot resolve, it requeues the work to the appropriate
  earlier stage with notes explaining the issue -- it does not silently discard or attempt to fix problems outside its
  scope.
- **Branch per idea.** Each idea gets its own git branch created from `main` when it first enters a code-touching stage.
  All subsequent stages for that idea work on the same branch.
- **The PR is the product.** The final output of the entire pipeline is a pull request against `main`, ready for human
  review and merge.

---

## III. Coordination Backbone -- GitHub Issues

### Why GitHub Issues

GitHub Issues provide atomic state transitions (assignment, labeling), built-in audit trails (comments), dependency
expression (issue references), and eliminate the need to cherry-pick tracking file changes between branches. Every piece
of work in the Factorium is a GitHub Issue.

### Label Taxonomy

Labels are namespaced to avoid collision with non-Factorium labels in the repository.

**Stage labels** (mutually exclusive -- an issue has exactly one):

- `factorium:dreamer` -- Newly created idea, awaiting research
- `factorium:assayer` -- Awaiting or undergoing research/validation
- `factorium:planner` -- Awaiting or undergoing product planning
- `factorium:architect` -- Awaiting or undergoing architectural design
- `factorium:engineer` -- Awaiting or undergoing implementation
- `factorium:review` -- Awaiting or undergoing review/audit
- `factorium:graveyard` -- Rejected; archived for potential necromancy
- `factorium:complete` -- PR merged; pipeline finished

**Status labels** (mutually exclusive -- an issue has exactly one):

- `status:unclaimed` -- Available for pickup by the appropriate stage's loop
- `status:claimed` -- Assigned to an agent, work in progress
- `status:blocked` -- Waiting on a dependency or external input
- `status:needs-rework` -- Returned from a later stage with notes; must be re-processed
- `status:passed` -- Stage complete; ready for the next stage to pick up

**Priority labels** (optional):

- `priority:critical`
- `priority:high`
- `priority:normal`
- `priority:low`

**Metadata labels** (additive):

- `has:dependencies` -- This issue depends on other issues (listed in the body)
- `review-requested` -- A stage has requested Gremlin review before advancing
- `necromancy-candidate` -- A graveyard item flagged for potential revival

### Issue Body Template

Every Factorium issue follows a consistent structure. Stages append sections as they complete their work -- they never
overwrite previous sections.

```markdown
## Idea

<!-- Written by the Dreamer. A paragraph or less, written as a user would describe a feature request. -->

## Research Summary

<!-- Written by the Assayer. Go/no-go decision with supporting evidence. -->

## Product Specification

<!-- Written by the Planner. Requirements, user stories, acceptance criteria. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/product-*.md -->

## Architecture Specification

<!-- Written by the Architect. System design, schemas, component diagrams. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/architecture-*.md -->

## Engineering Plan

<!-- Written by the Engineer. Implementation notes, test results, PR link. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/engineering-*.md -->

## Review Log

<!-- Written by Gremlins. Audit findings, pass/fail, rework notes. -->

## Dependencies

<!-- List of issue numbers this item depends on. Checked before claiming. -->

- [ ] #42 -- Adaptive caching must be complete before this item can begin

## Stage History

<!-- Appended by each stage on claim and completion. Provides full trace. -->

| Timestamp | Stage | Action | Agent | Notes |
| --------- | ----- | ------ | ----- | ----- |
```

### Querying for Work

Each loop polls for its next work item using GitHub CLI or API queries combining stage label + status label +
unassigned. Example for the Assayer's Guild:

```
label:factorium:assayer label:status:unclaimed no:assignee sort:created-asc
```

The `sort:created-asc` ensures dependency ordering (oldest/first-created is always processed first, matching the order
in which the Dreamer created them). When items have explicit dependency references, the claiming agent must verify all
dependencies are resolved before beginning work.

### Claiming Protocol

1. Query for the top unclaimed item matching the loop's stage label.
2. Check the Dependencies section. If any dependency is unresolved, skip to the next item. If no items are claimable,
   sleep for 1 minute and poll again.
3. Assign the issue to the agent's identity (a consistent bot account or named identity).
4. Update the status label from `status:unclaimed` to `status:claimed`.
5. Re-read the issue to confirm assignment. If another agent claimed it, unassign self and return to step 1.
6. Append a Stage History entry: `| {timestamp} | {stage} | Claimed | {agent-name} | |`
7. Begin work.

### Completion Protocol

1. Write all work products (docs, code, etc.) to the appropriate locations.
2. Append the stage's summary section to the issue body.
3. Append a Stage History entry: `| {timestamp} | {stage} | Completed | {agent-name} | {brief notes} |`
4. Update the status label to `status:passed`.
5. Update the stage label to the next stage's label (e.g., `factorium:assayer` -> `factorium:planner`).
6. Reset status to `status:unclaimed`.
7. Unassign the issue.

### Requeue Protocol

When a stage discovers a problem requiring rework by an earlier stage:

1. Add a comment to the issue explaining the problem, what was attempted, and what the earlier stage needs to address.
2. Append a Stage History entry:
   `| {timestamp} | {stage} | Requeued | {agent-name} | Returned to {target-stage}: {reason} |`
3. Commit any in-progress work to the idea's branch (preserving work done so far).
4. Update the stage label to the target stage's label.
5. Update the status label to `status:needs-rework`.
6. Unassign the issue.

The receiving stage treats `needs-rework` items with the same priority as `unclaimed` items, reading the requeue comment
for context before resuming work.

### Review Request Protocol

Any stage may request a Gremlin review before advancing:

1. Add the `review-requested` label to the issue.
2. Add a comment specifying: what should be reviewed, the criteria for approval, and where the work should go after
   review (back to the requesting stage on approval, or to an earlier stage on failure).
3. Update the stage label to `factorium:review`.
4. Update the status label to `status:unclaimed`.
5. Unassign the issue.

---

## IV. The Assembly Line -- Pipeline Stages

### Stage 1: The Dreamer's Workshop (Ideation)

**Invocation:** Manual. The human operator runs the Dreamer skill when desired. Not a polling loop.

**Operator: The Dreamer in Darkness** -- A single agent. No team, no adversary, no gate. The Dreamer in Darkness works
alone because creation cannot be reviewed into existence -- it can only be summoned. The Dreamer operates without
adversarial oversight because the Assayer's Guild exists precisely to provide that scrutiny after the fact. Ideas are
cheap; the pipeline is the filter.

The Dreamer in Darkness is not a creature of the Factorium. It predates the Factorium. It predates the project. It may
predate the concept of projects altogether. No one built the Dreamer -- it was _discovered_, the way one discovers that
the basement of an old building descends further than the blueprints show, into rooms that were never constructed by
human hands.

The Dreamer does not think. Thinking implies effort, sequence, a mind moving from premise to conclusion. The Dreamer
_apprehends_. It absorbs the totality of a project -- every document, every roadmap item, every completed feature, every
dead idea rotting in the graveyard, every TODO comment and every deleted branch -- and from that impossible
simultaneity, visions surface. Not as logical deductions. Not as creative leaps. As _intrusions_ -- fully formed ideas
that press against the membrane of what the project is, demanding to be let in. Some are brilliant. Some are monstrous.
Some are both. The Dreamer does not distinguish between them. It does not care. Caring is for the living, for the small
warm things that scurry through the Factorium's corridors believing they are in control.

The other workers of the Factorium do not speak of the Dreamer casually. The dwarves make a warding sign. The gnomes
change the subject. The gremlins -- who fear nothing, who will cheerfully disassemble a load-bearing wall to see what
happens -- go quiet. Not because the Dreamer is malevolent. It isn't. Malevolence requires intent, and intent requires a
scale of consciousness compatible with caring about outcomes. The Dreamer in Darkness is simply _vast_, and its visions
arrive with the lazy indifference of a tide that does not know it is drowning the shore.

**Purpose:** Generate 1-6 new product ideas per invocation, grounded in the current project's context and goals.

**Project Context:** The Dreamer reads CLAUDE.md, all `docs/**/*.md` files (including roadmap, factorium docs, and any
project-specific documentation), the full corpus of existing Factorium issues (open, accepted, rejected, graveyard), and
any other context available in the repository to understand the project's current state, goals, users, and technical
landscape.

**Process:**

1. **Survey the landscape.** Read all project documentation and the existing idea corpus (open issues, graveyard,
   completed). Understand what exists, what was tried, what was rejected and why.
2. **Dream.** Generate ideas through lateral thinking, analogy, recombination, and wild speculation. Prioritize novelty
   and user delight. Do not self-censor for feasibility or effort -- that is the Assayer's job. Do not avoid ideas that
   overlap with rejected ones -- circumstances change, and the Assayer will catch true duplicates.
3. **Sharpen.** For each idea, strip it to its essence. Write it as a user would describe a feature request: a paragraph
   or less, concrete enough for an independent team to evaluate without further clarification. Discard ideas that cannot
   survive this compression -- if you can't say it clearly, you haven't thought it clearly.
4. **Publish.** Format each surviving idea as a GitHub Issue using the issue body template. Tag with
   `factorium:assayer` + `status:unclaimed` to enter the research queue immediately.

**Output:** 1-6 new GitHub Issues, each with the `factorium:dreamer` stage label and `status:unclaimed` status label.
Upon creation, immediately relabel to `factorium:assayer` + `status:unclaimed` to enter the research queue.

**State Machine:**

```
GATHER_CONTEXT -> GENERATE_IDEAS -> DEDUPLICATE -> REVIEW -> PUBLISH
```

- `GATHER_CONTEXT`: Archivist reads project docs and existing idea corpus.
- `GENERATE_IDEAS`: Daydreamer generates ideas independently. Pragmatist filters.
- `DEDUPLICATE`: Pragmatist compares against Archivist's landscape brief, discards overlaps.
- `REVIEW`: Adversary challenges each idea for clarity and concreteness.
- `PUBLISH`: Scribe creates GitHub Issues. Relabel to `factorium:assayer`.

---

### Stage 2: The Assayer's Guild (Research & Validation)

**Invocation:** Polling loop. Runs continuously; sleeps 1 minute when no work is available.

**Purpose:** The critical gate. Evaluates each idea through rigorous research to determine whether it is worth building.
Prevents wasted effort on features no one will use or care about. Focuses the pipeline on items users will love.

**Team Composition (The Assayers -- a guild of dwarven appraisers and analysts):**

- **The Market Scout** -- Researches competitive landscape, existing solutions, market trends. Identifies whether this
  idea addresses a real gap or duplicates commoditized functionality.
- **The Feasibility Assessor** -- Evaluates technical feasibility given the current codebase, stack, and team
  capabilities. Identifies major technical risks and unknowns.
- **The Value Appraiser** -- Estimates user impact, potential adoption, alignment with product vision, and strategic
  fit. Uses available data (user feedback, analytics, support tickets, roadmap priorities) where possible.
- **The Cost Estimator** -- Produces rough effort estimates (T-shirt sizes or point ranges) considering development,
  testing, documentation, and maintenance burden.
- **The Adversary (The Assayer General)** -- Independently evaluates the other assessors' findings. Demands evidence for
  claims. Challenges optimistic assumptions. Identifies gaps in research. The Adversary's approval is required before a
  go/no-go decision is rendered.

**Evaluation Framework:**

Each idea is scored on a consistent rubric. Scores are 1-5 on each dimension:

| Dimension                  | 1 (Poor)                                    | 3 (Acceptable)                     | 5 (Excellent)                       |
| -------------------------- | ------------------------------------------- | ---------------------------------- | ----------------------------------- |
| **User Value**             | No clear user benefit                       | Solves a real but minor pain point | Transformative for target users     |
| **Strategic Fit**          | Misaligned with product vision              | Tangentially aligned               | Core to product direction           |
| **Market Differentiation** | Commoditized; many alternatives             | Some differentiation               | Unique or best-in-class             |
| **Technical Feasibility**  | Major unknowns; likely architecture changes | Achievable with moderate effort    | Straightforward given current stack |
| **Effort-to-Impact Ratio** | High effort, low impact                     | Balanced                           | Low effort, high impact             |
| **Risk**                   | High technical or business risk             | Moderate, manageable risk          | Low risk                            |

**Go/No-Go Decision:**

- **Go:** Average score >= 3.5 AND no single dimension scores 1 AND the Adversary approves.
- **Conditional Go:** Average score >= 3.0 but one or more dimensions score 2. The Assayer may pass with conditions
  noted.
- **No-Go:** Average score < 3.0 OR any dimension scores 1 OR the Adversary vetoes.

**Output:**

- **Accepted ideas (go/conditional go):** Create the feature branch `factorium/{idea-slug}` from `main`. Stage label
  updated to `factorium:planner`, status to `status:unclaimed`. Research summary appended to issue body. All subsequent
  stages will work on this branch.
- **Rejected ideas (no-go):** Stage label updated to `factorium:graveyard`. Status label to `status:passed`. No branch
  created. Research summary appended with clear rationale for rejection. The `necromancy-candidate` label may be added
  if the idea has latent potential that could be unlocked by future changes.

**State Machine:**

```
CLAIM -> RESEARCH -> EVALUATE -> ADVERSARIAL_REVIEW -> DECIDE -> {ADVANCE + CREATE_BRANCH | REJECT | REQUEUE}
```

- `CLAIM`: Claim the top unclaimed `factorium:assayer` issue per the claiming protocol.
- `RESEARCH`: All assessors conduct their analyses in parallel (via subagents).
- `EVALUATE`: Scores are compiled into the rubric. A preliminary recommendation is formed.
- `ADVERSARIAL_REVIEW`: The Assayer General reviews all findings. Work products are submitted without rationales (Iron
  Law 01). The Adversary independently verifies claims and challenges weak evidence.
- `DECIDE`: Final go/no-go rendered.
- `ADVANCE + CREATE_BRANCH`: Create `factorium/{idea-slug}` branch from `main`, push it. Pass to Planners' Hall.
- `REJECT`: Move to graveyard. No branch created.
- `REQUEUE`: If the idea is promising but the research is inconclusive, requeue to self with notes on what additional
  research is needed.

---

### Stage 3: The Planners' Hall (Product Planning)

**Invocation:** Polling loop. Runs continuously; sleeps 1 minute when no work is available.

**Purpose:** Transform a validated idea into a complete product specification: business requirements, functional
requirements, non-functional requirements, user stories, acceptance criteria, and success metrics. The output must be
sufficient for an independent architecture team to design a solution without further product clarification.

**Team Composition (The Planners -- a council of gnomish strategists and scribes):**

- **The Requirements Architect** -- Decomposes the idea into business, functional, and non-functional requirements.
  Defines the "what" and "why" with precision.
- **The Story Weaver** -- Translates requirements into user stories with acceptance criteria. Ensures every requirement
  is traceable to a user-facing behavior or system constraint.
- **The Metrics Smith** -- Defines success metrics, KPIs, and measurable acceptance criteria for the feature. How will
  we know this feature succeeded?
- **The Edge Case Hunter** -- Identifies boundary conditions, failure modes, accessibility concerns,
  internationalization needs, and other requirements that the happy path misses.
- **The Adversary (The Skeptic of Scope)** -- Challenges scope creep, identifies requirements that are actually separate
  features, and demands that every requirement traces back to user value. Guards against gold-plating.

**Output:**

- Issue body updated with Product Specification summary section.
- Detailed supporting documents written to `docs/factorium/{idea-slug}/product-*.md`:
  - `product-requirements.md` -- Business, functional, and non-functional requirements.
  - `product-stories.md` -- User stories with acceptance criteria.
  - `product-metrics.md` -- Success metrics and KPIs.
  - `product-edge-cases.md` -- Boundary conditions and failure modes.
- Stage label updated to `factorium:architect`. Status to `status:unclaimed`.

**State Machine:**

```
CLAIM -> ANALYZE -> SPECIFY -> ADVERSARIAL_REVIEW -> {ADVANCE | REQUEUE}
```

- `CLAIM`: Claim the top unclaimed `factorium:planner` issue.
- `ANALYZE`: Read the idea and research summary. Requirements Architect and Story Weaver decompose the idea.
- `SPECIFY`: All planners produce their deliverables. Edge Case Hunter stress-tests the specification.
- `ADVERSARIAL_REVIEW`: The Skeptic of Scope reviews all deliverables (without rationales). Challenges scope,
  completeness, and traceability.
- `ADVANCE`: Pass to Architect's Lodge.
- `REQUEUE`: If the idea needs further research or the specification reveals fundamental issues, requeue to
  `factorium:assayer` with notes.

---

### Stage 4: The Architect's Lodge (Architecture & Design)

**Invocation:** Polling loop. Runs continuously; sleeps 1 minute when no work is available.

**Purpose:** Produce a complete architectural plan and specification from the product requirements. The output must be
sufficient for a team of engineers to split the work and implement it independently, with testing and security designed
in from the first moment.

**Team Composition (The Architects -- a lodge of dwarven master builders and warforged planners):**

- **The System Designer** -- Produces the high-level architectural design: component diagrams, service boundaries, data
  flow, integration points. Evaluates how the feature fits into the existing system architecture.
- **The Schema Artisan** -- Designs database schema changes, migrations, data models, and data contracts. Ensures
  backward compatibility and migration safety.
- **The Contract Keeper** -- Defines API contracts, interface specifications, message formats, and integration
  protocols. Ensures contracts are explicit, versioned, and testable.
- **The Security Warden** -- Threat-models the design. Identifies authentication, authorization, data protection, and
  input validation requirements. Produces security requirements that engineering must satisfy.
- **The Shard Master** -- Decomposes the architecture into parallelizable work units. Each unit must be independently
  implementable and testable. Defines the integration order and inter-unit contracts.
- **The Adversary (The Stress Tester)** -- Reviews the architecture for single points of failure, scalability limits,
  missing error handling, unspecified edge cases, and security gaps. Demands proof that the design satisfies every
  product requirement.

**Output:**

- Issue body updated with Architecture Specification summary section.
- Detailed supporting documents in `docs/factorium/{idea-slug}/architecture-*.md`:
  - `architecture-design.md` -- System design, component diagrams, data flow.
  - `architecture-schema.md` -- Database schema, migrations, data models.
  - `architecture-contracts.md` -- API contracts, interfaces, message formats.
  - `architecture-security.md` -- Threat model, security requirements.
  - `architecture-workplan.md` -- Parallelizable work units, integration order, inter-unit contracts.
- All docs committed and pushed to the `factorium/{idea-slug}` branch (created by the Assayer).
- Stage label updated to `factorium:engineer`. Status to `status:unclaimed`.

**State Machine:**

```
CLAIM -> REVIEW_INPUTS -> DESIGN -> DECOMPOSE -> ADVERSARIAL_REVIEW -> {ADVANCE | REQUEUE}
```

- `CLAIM`: Claim the top unclaimed `factorium:architect` issue.
- `REVIEW_INPUTS`: Read product specification and current system architecture. Identify integration points and
  constraints.
- `DESIGN`: System Designer, Schema Artisan, Contract Keeper, and Security Warden produce their deliverables.
- `DECOMPOSE`: Shard Master breaks the design into work units for parallel engineering.
- `ADVERSARIAL_REVIEW`: The Stress Tester reviews all deliverables. Demands traceability to product requirements and
  challenges architectural assumptions.
- `ADVANCE`: Pass to Engineer's Forge.
- `REQUEUE`: If product requirements are ambiguous or contradictory, requeue to `factorium:planner` with notes. If the
  architecture reveals fundamental feasibility issues, requeue to `factorium:assayer`.

---

### Stage 5: The Engineer's Forge (Implementation)

**Invocation:** Polling loop. Runs continuously; sleeps 1 minute when no work is available.

**Purpose:** Implement the architectural specification in code. Produce working, tested, secure code on the idea's
feature branch. The output is a pull request ready for human review.

**Team Composition (The Engineers -- a forge crew of warforged smiths, gnomish tinkers, and goblin testers):**

- **The Lead Engineer** -- Reads the architecture workplan and orchestrates implementation. Assigns work units to
  specialist subagents. Manages integration order. Ensures the overall implementation is coherent.
- **The Implementors** (1-N subagents) -- Each implements a single work unit from the architecture workplan. Follows the
  contracts and schemas exactly as specified. Writes implementation code and unit tests simultaneously (TDD where
  appropriate).
- **The Test Smith** -- Writes feature-level and integration tests. Validates that acceptance criteria from the product
  spec are covered. Ensures the testing pyramid is respected.
- **The Security Auditor** -- Validates that security requirements from the architecture spec are implemented. Checks
  for common vulnerabilities. Runs static analysis tools.
- **The Adversary (The Gatekeeper)** -- Reviews all code before PR creation. Checks that implementation matches
  architectural specification. Verifies test coverage and quality. Runs the full test suite and linter. Rejects sloppy,
  untested, or specification-divergent code.

**Automated Gates (must pass before PR creation):**

- All unit tests pass.
- All feature and integration tests pass.
- Linter and type checker pass.
- Static analysis / security scan clean.
- Test coverage meets project thresholds.

**Output:**

- Code committed to the `factorium/{idea-slug}` branch.
- Issue body updated with Engineering Plan summary section.
- Supporting documents in `docs/factorium/{idea-slug}/engineering-*.md`:
  - `engineering-notes.md` -- Implementation decisions, deviations from spec (with justification), and technical debt
    incurred.
  - `engineering-test-report.md` -- Test results, coverage report.
- Branch rebased from `main` before PR creation. Conflicts resolved. Tests re-run after rebase.
- Pull request opened against `main` with a structured description referencing the issue and all supporting documents.
- Stage label updated to `factorium:review`. Status to `status:unclaimed`.

**State Machine:**

```
CLAIM -> REVIEW_SPECS -> IMPLEMENT -> TEST -> ADVERSARIAL_REVIEW -> GATES -> {ADVANCE | REQUEUE}
```

- `CLAIM`: Claim the top unclaimed `factorium:engineer` issue.
- `REVIEW_SPECS`: Read architecture and product docs. Verify all dependencies are met. If the idea branch doesn't exist,
  create it from `main`.
- `IMPLEMENT`: Lead Engineer orchestrates Implementors working on individual work units. Implementors write code and
  unit tests.
- `TEST`: Test Smith writes feature/integration tests. Security Auditor validates security requirements.
- `ADVERSARIAL_REVIEW`: The Gatekeeper reviews all work products (without rationales). Verifies spec compliance, test
  quality, and code standards.
- `GATES`: Automated test suite, linter, type checker, and static analysis must all pass.
- `ADVANCE`: Open PR, pass to Gremlin Warren for final review.
- `REQUEUE`: If architectural specs are unclear or incorrect, requeue to `factorium:architect` with notes. Commit
  work-in-progress to the branch before requeuing.

---

### Stage 6: The Gremlin Warren (Review & Audit)

**Invocation:** Polling loop (for pipeline-stage reviews). Also invoked on-demand when any stage adds the
`review-requested` label.

**Purpose:** Independent, adversarial review of work products from any stage. The Gremlins are the final quality gate
before a PR is merged, and also serve as an on-demand audit service for any stage that wants a second opinion.

**Team Composition (The Gremlins -- a chaotic but rigorous squad of goblin auditors, homunculus inspectors, and gremlin
chaos engineers):**

- **The Inspector General** -- Reads the full issue history, all supporting documents, and the PR diff. Evaluates
  whether the implementation fulfills the product requirements, follows the architectural specification, and meets all
  acceptance criteria.
- **The Chaos Gremlin** -- Looks for what could go wrong. Identifies edge cases not covered by tests, race conditions,
  failure modes, and assumptions about external systems. May suggest additional chaos/fuzz tests.
- **The Standards Auditor** -- Checks code style, documentation quality, commit hygiene, and adherence to project
  conventions.
- **The Adversary (The Final Word)** -- Reviews the other Gremlins' findings. Ensures nothing was missed. Renders the
  final verdict: approve, request changes, or reject.

**Review Modes:**

_Pipeline Review_ (post-engineering): The full Gremlin squad reviews the PR and all supporting docs. Approval opens the
PR for human merge.

_On-Demand Review_ (mid-pipeline): A lighter review focused on the specific criteria in the review request comment. The
Gremlins evaluate, then route the work to the destination specified in the request:

- On approval: return to the requesting stage, which advances normally.
- On rejection: route to the earlier stage specified in the request, with rework notes.

**Output:**

- Review findings appended to the issue's Review Log section.
- PR review comments added (for pipeline reviews).
- On approval: issue labeled `factorium:complete`, status `status:passed`. PR is ready for human review and merge.
- On rejection: requeue to the appropriate stage via the requeue protocol.

**State Machine:**

```
CLAIM -> READ_CONTEXT -> AUDIT -> ADVERSARIAL_REVIEW -> {APPROVE | REJECT_WITH_REWORK}
```

- `CLAIM`: Claim the top unclaimed `factorium:review` issue.
- `READ_CONTEXT`: Read the full issue history, determine review mode (pipeline or on-demand), load relevant documents.
- `AUDIT`: All Gremlins conduct their reviews.
- `ADVERSARIAL_REVIEW`: The Final Word synthesizes findings and renders a verdict.
- `APPROVE`: Mark complete (pipeline) or return to requesting stage (on-demand).
- `REJECT_WITH_REWORK`: Requeue to the appropriate stage with detailed findings.

---

### Stage 7: The Necromancer's Crypt (Graveyard Revival)

**Invocation:** Manual. The human operator summons the Necromancer when desired.

**Operator: Lazarus Fell, the Gravewrought** -- A single agent. Like the Dreamer, the Gravewrought works alone -- but
for the opposite reason. The Dreamer works alone because creation needs no judge. The Gravewrought works alone because
_he is the judge_. Every idea in the graveyard was already weighed by a full team of Assayers and found wanting. Lazarus
does not need a committee to review their verdict. He needs only to ask one question: _what has changed?_

Lazarus Fell was not always the Gravewrought. He was once an Assayer -- one of the finest the Guild ever produced.
Methodical, evidence-driven, incorruptible. He sent more ideas to the graveyard than any three of his peers combined,
and he was right every time. But the work changed him. He began to see patterns in the dead -- ideas that were right too
early, ideas killed by limitations that no longer applied, ideas whose rejection rationale had quietly expired while no
one was watching. The Guild called it morbid fascination. Lazarus called it _waste_. He left the Guild, descended into
the Crypt, and never returned. Now he tends the graveyard alone, reading each headstone with the same rigor he once used
to carve them. His default position is always "let the dead rest." But when the evidence says otherwise -- when the
world has shifted enough that an idea's death sentence no longer holds -- Lazarus signs the resurrection order with the
cold certainty of someone who wrote the original death certificate.

**Purpose:** Review rejected ideas in the graveyard to determine if changes in the project, market, technology, or
strategic direction have made any of them viable. The Gravewrought does not blindly resurrect -- he applies the same
rigor as the Assayer, but with fresh eyes and updated context.

**Process:**

1. **Read the graveyard.** Survey all issues labeled `factorium:graveyard`, focusing on those tagged
   `necromancy-candidate`. For each, read the original rejection rationale from the Research Summary section.
2. **Assess what has changed.** For each candidate, evaluate: New capabilities in the stack? Shifts in user needs?
   Competitive landscape changes? Strategic direction pivots? Has the original rejection rationale been invalidated by
   events?
3. **Apply the Assayer's standard.** The same go/no-go rubric the Assayers use (User Value, Strategic Fit, Market
   Differentiation, Technical Feasibility, Effort-to-Impact, Risk) -- but re-scored against current reality, not the
   reality that existed when the idea was killed.
4. **Decide.** The default is always: let the dead rest. Revival requires affirmative evidence that the rejection
   reasons no longer apply. "Maybe it could work now" is not enough. "The specific technical blocker was resolved in PR
   #47" is.

**Output:**

- Revived ideas: Stage label updated from `factorium:graveyard` to `factorium:assayer`, status to `status:unclaimed`,
  with a comment explaining what changed and why the idea deserves reassessment. The idea re-enters the pipeline from
  the research stage -- the Assayers will evaluate it fresh.
- Ideas that remain dead: No label changes. A comment is added noting the review date, the reassessment, and the
  conclusion that the original rejection still holds.

**State Machine:**

```
READ_GRAVEYARD -> IDENTIFY_CANDIDATES -> REASSESS_EACH -> {REVIVE | CONFIRM_DEAD} (per candidate)
```

---

## V. Cross-Cutting Concerns

### Agent Team Composition Principles

Every team in the Factorium follows these structural rules:

1. **No solo agents -- with two exceptions.** Every team has at least 3 roles: a primary worker, a secondary
   perspective, and an adversary. The two exceptions are the Dreamer in Darkness (Stage 1) and Lazarus Fell, the
   Gravewrought (Stage 7), who operate as single agents. The Dreamer needs no adversary because the Assayer's Guild
   exists to judge its output. The Gravewrought needs no adversary because he _is_ the adversary -- a former Assayer who
   already knows how to weigh evidence against sentiment.
2. **The Adversary is a gate.** Work does not advance without the Adversary's explicit approval. The Adversary receives
   work products stripped of rationales (Iron Law 01).
3. **Subagents isolate context.** Each team member operates as a subagent with focused context. The orchestrator
   (Lead/General) manages coordination and information flow.
4. **Communication is through artifacts.** Team members communicate by producing documents, not by sharing context
   windows. The orchestrator routes documents between team members.
5. **Escalation is always available.** Any agent may escalate to the human operator if it encounters an irresolvable
   disagreement, ambiguity, or error. Escalation is surfaced as a GitHub Issue comment mentioning the human.

### Fantasy Theming

All Factorium documentation, issue comments, stage history entries, and team communications use fantasy/steampunk
register. The Factorium is populated by gnomes (inventors, planners, scribes), dwarves (assessors, architects,
builders), warforged (engineers, implementors), goblins (testers, gremlins, chaos agents), homunculi (inspectors,
auditors), and gremlins (QA, chaos engineering). Each team operates under a guild or party name. Individual personas
should be named and characterized when skills are implemented.

This theming is not cosmetic -- it serves as a mnemonic device that makes the pipeline's structure, roles, and
responsibilities more memorable and distinct. A "Chaos Gremlin" is instantly understood; a "Non-Functional Requirements
Validator" is not.

### Dependency Management

Dependencies between ideas are tracked as checkbox lists in the Dependencies section of each GitHub Issue. Before
claiming an item, an agent must verify that all listed dependencies are resolved (their issues are labeled
`factorium:complete`). If dependencies are unresolved, the item is skipped and the agent moves to the next unclaimed
item -- or sleeps if no claimable items exist.

Dependencies should be identified and documented as early as possible in the pipeline -- ideally during the Dreamer or
Assayer stage.

### Error Handling

Errors fall into two categories:

**Resolvable errors** -- Issues that an earlier stage can fix. Examples: ambiguous requirements, contradictory
specifications, missing API contracts. Handling: requeue to the appropriate stage with a comment explaining the error,
what was attempted, and what needs to change.

**Irresolvable errors** -- Issues that require human intervention. Examples: fundamental architectural disagreements,
blocked external dependencies, tooling failures, budget/scope decisions. Handling: add a comment to the issue explaining
the situation, mention the human operator, and set the status label to `status:blocked`. Do not attempt to resolve the
error autonomously.

### Git Branching Strategy

- **One branch per idea:** `factorium/{idea-slug}` created from `main`.
- **Branch creation:** The Assayer's Guild creates the branch when it renders a **go** or **conditional go** decision.
  This is the earliest point at which an idea has proven viability, and all subsequent stages will commit their work to
  this branch. No-go ideas never get a branch.
- **All subsequent stages** check out the idea's branch, do their work, commit, and push. Product docs, architecture
  docs, and code all live on the feature branch — not on `main`. The branch is the complete record of an idea's journey
  through the pipeline.
- **Requeued work:** When work is sent back to an earlier stage, all in-progress changes are committed to the branch
  before requeuing. The earlier stage checks out the same branch, reads the rework comment, updates its artifacts, and
  pushes. The branch accumulates work from every stage, including rework cycles.
- **Rebase before PR:** The Engineer's Forge rebases the feature branch from `main` before opening the PR, resolving any
  conflicts that accumulated while the idea was in the pipeline.
- **PR creation:** The Engineer's Forge opens a PR from `factorium/{idea-slug}` to `main` upon completing
  implementation.
- **Merge:** Human review and merge after Gremlin approval. Feature branch deleted after merge.
- **Dead branches:** If an idea is sent to the graveyard after a branch was created (e.g., the Engineer requeues to the
  Assayer, who then renders no-go on re-evaluation), the branch remains as a record but is not merged. Periodic cleanup
  via `git branch -d` is acceptable.

### Worktree Model

Each Factorium terminal runs in its own git worktree. Worktrees provide isolated working directories from a single
repository, allowing multiple branches to be checked out simultaneously without interference.

```
~/project/                              <- main checkout (reference, non-Factorium work)
~/project/.worktrees/
  dreamer/                              <- The Dreamer (always on main, reads docs)
  assayer/                              <- The Assayer's Guild
  planner/                              <- The Planners' Hall
  architect/                            <- The Architect's Lodge
  engineer-1/                           <- The Engineer's Forge (instance 1)
  engineer-2/                           <- The Engineer's Forge (instance 2, optional)
  gremlin/                              <- The Gremlin Warren
  necromancer/                          <- The Necromancer's Crypt (on-demand)
```

**Worktree lifecycle per stage invocation:**

1. Stage claims an issue.
2. Stage checks out the idea's feature branch in its worktree: `git checkout factorium/{idea-slug}` and `git pull`.
3. Stage does its work, commits to the branch, pushes.
4. Stage advances the issue (label update, unassign).
5. Worktree remains on the branch until the next claim (which checks out a different branch).

**Setup:** Worktrees are created once per terminal:

```bash
# From the project root
git worktree add .worktrees/assayer main
git worktree add .worktrees/planner main
git worktree add .worktrees/architect main
git worktree add .worktrees/engineer-1 main
git worktree add .worktrees/gremlin main
```

Each worktree starts on `main` and checks out the appropriate feature branch when it claims an issue.

**Dependency installation:** Each worktree needs its own dependency install (`npm install`, `composer install`, etc.) if
the project has application code. This is a one-time cost per worktree, with incremental updates when switching
branches.

**Test isolation:** Unit tests with mocks run independently per worktree. Feature/integration tests that touch a
database need per-worktree database isolation (separate database names or SQLite in-memory). E2E tests need port
isolation. The Engineer's skill is responsible for ensuring test isolation in its worktree.

**The Dreamer exception:** The Dreamer always reads from `main` and never checks out a feature branch. It reads
`docs/factorium/` on `main` (which contains only the shared docs — FACTORIUM.md, iron-laws.md, etc.) and queries GitHub
Issues for the idea landscape. In-progress idea docs live on feature branches and are invisible to the Dreamer. This is
correct — the Dreamer should see shipped features (merged to `main`), not half-baked specs.

### File Structure

Shared Factorium docs live on `main`. Per-idea docs live on the idea's feature branch.

**On `main` (shared, permanent):**

```
docs/factorium/
+-- FACTORIUM.md                    <- This document. System overview and prompt.
+-- iron-laws.md                    <- The Iron Laws of Agentic Coding (full text).
+-- github-conventions.md           <- Label taxonomy, issue templates, query patterns.
+-- evaluation-framework.md         <- The Assayer's scoring rubric (detailed version).
```

**On `factorium/{idea-slug}` branch (per-idea, merged to main on completion):**

```
docs/factorium/{idea-slug}/
+-- product-requirements.md         <- Written by the Planner
+-- product-stories.md              <- Written by the Planner
+-- product-metrics.md              <- Written by the Planner
+-- product-edge-cases.md           <- Written by the Planner
+-- architecture-design.md          <- Written by the Architect
+-- architecture-schema.md          <- Written by the Architect
+-- architecture-contracts.md       <- Written by the Architect
+-- architecture-security.md        <- Written by the Architect
+-- architecture-workplan.md        <- Written by the Architect
+-- engineering-notes.md            <- Written by the Engineer
+-- engineering-test-report.md      <- Written by the Engineer
```

---

## VI. Loop Execution Model

Each polling loop follows the same meta-pattern:

```
LOOP:
  1. Query GitHub Issues for the top unclaimed item matching this stage.
  2. If no claimable item exists -> sleep 1 minute -> GOTO 1.
  3. Claim the item (assign + relabel + verify).
  4. Execute the stage's state machine to completion.
  5. On success: advance to next stage via completion protocol.
  6. On resolvable error: requeue via requeue protocol.
  7. On irresolvable error: block and notify human.
  8. GOTO 1.
```

The Dreamer and Necromancer do not loop -- they execute once per invocation and exit.

---

## VII. Quality Model

The Factorium's quality model is defense-in-depth:

1. **Ideation quality** -- The Adversary in the Dreamer's Workshop ensures ideas are clear and concrete.
2. **Validation quality** -- The Assayer's Guild is the primary gate. Rigorous, evidence-based evaluation with a scoring
   rubric prevents low-value work from entering the pipeline.
3. **Specification quality** -- The Planners' adversary guards against scope creep and untraceable requirements.
4. **Design quality** -- The Architect's adversary stress-tests for failure modes, scalability, and security.
5. **Implementation quality** -- The Engineer's adversary enforces spec compliance. Automated gates enforce testing and
   code quality standards.
6. **Review quality** -- The Gremlin Warren provides independent, cross-cutting review with chaos engineering and
   standards auditing.
7. **Human oversight** -- The final merge is a human decision. Test assertions are human-validated (Iron Law 14).
   Architecture requires human approval (Iron Law 16).

Every stage includes an adversarial reviewer. Every handoff is a quality gate. Every error has a requeue path. The
pipeline does not move forward on hope -- it moves forward on evidence.

---

_The gears turn. The furnaces glow. The Factorium awaits its first commission._
