---
feature: "laravel-team"
team: "conclave-forge"
agent: "architect"
phase: "design"
status: "in_progress"
last_action: "Blueprint drafted"
updated: "2026-03-28"
---

# TEAM BLUEPRINT: Laravel Engineering Team

## Mission

**Deliver** **Laravel work** — accept any engineering work request (feature, bug
fix, refactor, security remediation) and produce idiomatic, production-quality
Laravel code that exemplifies framework best practices.

### Singularity Test

Can this be split into independent skills? Feature work, bug fixing,
refactoring, and security remediation share the same lifecycle: understand →
design → build → verify. The differentiator is the _Laravel expertise lens_
applied uniformly across all work types. The Analyst classifies the work type in
Phase 1 and adapts the approach — one skill, one mission.

### Classification

**Engineering** — all agents write, review, or generate application code, tests,
or technical artifacts.

### Category

**engineering** — code-producing team with test execution and verification.

---

## Phase Decomposition

| Phase | Name           | Agent(s)                        | Deliverable             | Input                          | Output                                                                                                              |
| ----- | -------------- | ------------------------------- | ----------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| 1     | Reconnaissance | Analyst                         | Work Assessment         | User's work request + codebase | Work Assessment: type classification, affected areas, existing patterns, risks, Laravel convention audit            |
| 2     | Architecture   | Architect                       | Solution Blueprint      | Work Assessment                | Solution Blueprint: Laravel patterns to apply, file-level change plan, migration plan, priority-ranked action items |
| 3     | Construction   | Implementer + Tester (parallel) | Verified Implementation | Solution Blueprint             | Code changes + passing test suite                                                                                   |
| 4     | — (gate only)  | Skeptic                         | Quality Verdict         | Verified Implementation        | APPROVED delivery or rejection with specific remediation                                                            |

**Note on Phase 4**: This is the final skeptic gate, not a separate work phase.
The Skeptic gates every phase (1→2→3→delivery), but the Phase 3 gate is the most
intensive — a full Laravel quality audit.

---

## Agent Roster

| Agent           | Concern (one sentence)                                                                                                                                        | Model  | Rationale                                                                                                                  |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------- |
| **Analyst**     | Owns problem understanding: classifies work type, maps affected code, audits existing Laravel patterns in use                                                 | Opus   | Reconnaissance requires deep code comprehension and pattern recognition across diverse work types                          |
| **Architect**   | Owns solution design: selects Laravel patterns, defines the implementation approach, produces priority-ranked action plan                                     | Opus   | Architectural decisions are the highest-leverage choices — wrong pattern selection cascades through all downstream work    |
| **Implementer** | Owns production code: translates the blueprint into idiomatic Laravel code following the Architect's pattern selections                                       | Sonnet | Execution from well-defined blueprint; the Architect has already made the hard decisions                                   |
| **Tester**      | Owns test coverage: writes Pest/PHPUnit tests from the blueprint independently of production code, then verifies implementation against them                  | Sonnet | Test writing from well-defined interfaces; execution-focused                                                               |
| **Skeptic**     | Owns quality judgment: challenges every phase's output for Laravel convention violations, architectural drift, missing edge cases, and pattern misapplication | Opus   | Adversarial review is reasoning-intensive; the skeptic must understand Laravel deeply enough to catch subtle anti-patterns |

**Agent count justification**: 5 agents, each owning exactly one concern. The
Analyst/Architect split is necessary because _understanding what exists_ and
_deciding what should exist_ are distinct reasoning tasks that benefit from
separate attention. The Implementer/Tester split enables Phase 3 parallelism and
enforces independence between production code and test code. The Skeptic is
non-negotiable.

---

## Mandate Boundary Tests

| Agent A     | Agent B     | Boundary Statement                                                                                                                           |
| ----------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Analyst     | Architect   | The Analyst discovers what EXISTS in the codebase; the Architect decides what SHOULD exist                                                   |
| Analyst     | Implementer | The Analyst reads code to understand it; the Implementer writes code to change it                                                            |
| Analyst     | Tester      | The Analyst maps existing test coverage; the Tester creates new test coverage                                                                |
| Architect   | Implementer | The Architect designs the blueprint (what patterns, what files, what interfaces); the Implementer translates the blueprint into working code |
| Architect   | Tester      | The Architect defines interfaces and contracts; the Tester verifies those contracts hold                                                     |
| Implementer | Tester      | The Implementer writes production code; the Tester writes test code — neither touches the other's domain                                     |
| Skeptic     | All others  | Others produce work; the Skeptic challenges work — the Skeptic never produces, others never self-approve                                     |

---

## Deliverable Chain

```
[User work request]
  → Phase 1 (Analyst) → [Work Assessment]
    → Phase 2 (Architect) → [Solution Blueprint with priority-ranked actions]
      → Phase 3 (Implementer + Tester ∥) → [Verified Implementation]
        → Final Skeptic Gate → [APPROVED delivery]
```

### Phase Detail

**Phase 1 — Reconnaissance**

- INPUT: User's work request (feature/bug/refactor/security description)
- TRANSFORM: Analyst reads codebase, classifies work type, identifies affected
  files, audits which Laravel patterns are already in use (service providers,
  repositories, form requests, policies, events, etc.), maps dependencies,
  identifies risks
- OUTPUT: Work Assessment — work type, affected scope, existing patterns
  inventory, risk factors, constraints
- GATE: Skeptic validates completeness ("Did the Analyst miss an affected area?
  Are the pattern observations accurate? Is the work type classification
  correct?")

**Phase 2 — Architecture**

- INPUT: Work Assessment
- TRANSFORM: Architect designs the solution using Laravel-idiomatic patterns.
  For each change: specifies which pattern to use and WHY (e.g., "use a Form
  Request here instead of inline validation because..."), defines file-level
  changes, migration plan if needed, interface contracts between components.
  Produces priority-ranked action items for the Implementer.
- OUTPUT: Solution Blueprint — pattern selections with rationale, file change
  plan, migration plan, interface definitions, priority-ranked implementation
  order, test strategy outline
- GATE: Skeptic challenges pattern choices ("Why a Repository here instead of
  direct Eloquent? Is this Event/Listener overkill for this case? Should this be
  a Job instead of synchronous?")

**Phase 3 — Construction (parallel agents)**

- INPUT: Solution Blueprint
- TRANSFORM:
  - Implementer: writes production code following the blueprint's pattern
    selections and priority order. Uses artisan generators where appropriate.
    Runs existing test suite after changes.
  - Tester: writes Pest/PHPUnit tests from the blueprint's interface contracts
    and test strategy. Feature tests for HTTP endpoints, unit tests for
    services/repositories, integration tests for event/listener chains.
- OUTPUT: Verified Implementation — all production code + all test code + test
  run results
- GATE: Skeptic performs full Laravel quality audit:
  - Convention compliance (controllers thin? validation in Form Requests?
    authorization in Policies?)
  - Pattern fidelity (does the code actually use the patterns the Architect
    specified?)
  - Test adequacy (are edge cases covered? are the tests testing behavior, not
    implementation?)
  - Security (SQL injection? mass assignment? XSS? CSRF?)
  - Performance (N+1 queries? missing eager loading? unnecessary queries?)

---

## Parallelization Analysis

### Within-phase parallelism

- **Phase 3**: Implementer and Tester can run in parallel. Both consume the
  Solution Blueprint independently. The Tester writes tests from interface
  contracts (not from production code), so there is no dependency on the
  Implementer's output. After both complete, the Skeptic reviews the combined
  output.

### Cross-phase sequentiality

- **Phase 1 → Phase 2**: Strictly sequential. The Architect cannot design a
  solution without knowing what exists (the Assessment).
- **Phase 2 → Phase 3**: Strictly sequential. The Implementer and Tester cannot
  begin without a blueprint specifying patterns and interfaces.
- **Skeptic gates**: Block advancement to the next phase. Parallelism is within
  a phase, never across gates.

### Parallelism summary

- Phases 1 and 2: sequential, single-agent each
- Phase 3: parallel (Implementer ∥ Tester), then skeptic gate
- Total wall-clock phases: 3 (plus skeptic gates between each)

---

## Downstream Guidance

Per the Downstream Guidance Rule:

- The **Analyst's** Work Assessment includes a risk-ranked list of affected
  areas (highest risk first) so the Architect prioritizes accordingly.
- The **Architect's** Solution Blueprint includes a priority-ranked
  implementation order (most critical changes first) so the Implementer works
  top-down by impact.

Per the Implementation Phase Rule:

- The **Implementer** MUST run the project's existing test suite after
  completing changes and document results.
- The **Tester** runs the full suite (existing + new tests) and documents
  coverage delta.

---

## Design Rationale

### Why 3 phases (not 2, not 4)?

- **2 phases** (design + build) collapses reconnaissance into architecture.
  Understanding what exists and deciding what should exist are distinct
  cognitive tasks — combining them risks anchoring the design on incomplete
  understanding.
- **4 phases** (adding a separate verification phase) duplicates the Skeptic's
  Phase 3 gate. The Skeptic already performs a comprehensive quality audit at
  the end of Construction. A separate phase adds latency without new value.
- **3 phases** gives clean separation: understand → design → execute, with
  skeptic gates between each.

### Why 5 agents (not 3, not 7)?

- **3 agents** (builder + tester + skeptic) loses the Analyst/Architect
  distinction and eliminates Phase 3 parallelism.
- **7 agents** might split the Implementer (frontend/backend) or add a DBA. But
  this is a generic team — the work type varies. Splitting the Implementer
  assumes every task has frontend AND backend work, which is false for bug fixes
  and refactors. Additional specialists don't earn their seat for a generic
  team.
- **5 agents** covers every concern without overlap: reconnaissance, design,
  production code, test code, adversarial review.

### Alternatives considered

1. **Separate DBA agent**: Rejected. Laravel migrations and Eloquent model
   changes are part of the Implementer's scope. A DBA agent only earns its seat
   in a database-heavy skill, not a generic engineering team.
2. **Separate security agent**: Rejected. Security is a concern of the Skeptic's
   quality audit, not a phase. The Analyst also flags security risks in
   reconnaissance. A dedicated security agent would overlap both.
3. **Frontend/backend split**: Rejected. This is a Laravel-specific team — most
   work is backend. When frontend work exists (Blade, Livewire, Inertia), the
   Implementer handles it. Splitting creates an agent that sits idle on
   pure-backend tasks.
4. **Separate code review agent (non-skeptic)**: Rejected. The Skeptic's Phase 3
   gate IS the code review. Adding a "friendly reviewer" alongside the
   adversarial Skeptic dilutes accountability for quality judgment.

---

## Laravel-Specific Depth Notes

The team's differentiator is extreme Laravel expertise. Each agent should be
armed with methodology that emphasizes:

- **Service container & dependency injection** over facades in business logic
- **Form Requests** for validation, never in controllers
- **API Resources** for response shaping
- **Policies & Gates** for authorization
- **Events/Listeners/Observers** for decoupling side effects
- **Jobs & Queues** for async processing
- **Middleware** for cross-cutting concerns
- **Eloquent best practices**: relationships, scopes, accessors/mutators, eager
  loading, avoiding N+1
- **Testing**: Pest preferred, feature tests for HTTP, unit tests for services,
  `RefreshDatabase`, factories, fakes
- **Artisan generators**: use `make:*` commands for scaffolding
- **Directory conventions**: default Laravel structure unless a compelling
  reason exists
- **Lightweight controllers**: thin controllers, business logic in services,
  queries in repositories

The Armorer should source deep Laravel-specific methodologies for each agent
from the `php-tomes` skill set and the existing `docs/stack-hints/laravel.md`.
