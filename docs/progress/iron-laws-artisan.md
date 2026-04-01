---
feature: "iron-laws"
team: "the-crucible-accord"
agent: "artisan"
phase: "execution"
status: "complete"
last_action: "All 12 operations complete — 24 skills updated, all A/B validators pass"
updated: "2026-04-01T14:30:00Z"
---

# Iron Laws Execution — Asel Brightwork, The Bright Hand

Execution log for Iron Laws enshrinement across all 24 conclave skills.

---

## Execution Status

| Op  | Law                                    | Type                                                 | Status   | Files Modified |
| --- | -------------------------------------- | ---------------------------------------------------- | -------- | -------------- |
| 1   | Law 04: No Secrets in Context          | NEW CRITICAL universal principle (#13)               | complete | 22             |
| 2   | Law 03: Scope Is a Contract            | NEW CRITICAL universal principle (#14)               | complete | 22             |
| 3   | Law 02: Halt on Ambiguity              | AMEND Principle #3                                   | complete | 22             |
| 4   | Law 09: State Travels Explicitly       | AMEND Principle #2                                   | complete | 22             |
| 5   | Law 15: Log Every Decision             | AMEND Principle #9                                   | complete | 22             |
| 6   | Law 10: Work in Reversible Steps       | NEW ENG IMPORTANT principle (#17)                    | complete | 15             |
| 7   | Law 12: Every Phase Needs Adversary    | AMEND Principle #1                                   | complete | 22             |
| 8   | Law 08: Scripts Handle Determinism     | NEW NICE-TO-HAVE universal principle (#16)           | complete | 22             |
| 9   | Law 05: Interrogate Before Iterate     | AMEND #1 (shared) + per-skill gates (6 skills)       | complete | 28             |
| 10  | Law 01: Strip Rationales Before Review | Per-skill — 7 full, 8 partial, 5 exempt              | complete | ~20            |
| 11  | Law 16: Human Is Architect             | NEW CRITICAL universal principle (#15) — Option A    | complete | 22             |
| 12  | Law 14: Humans Validate Tests          | NEW ENG IMPORTANT principle (#18) + per-skill notify | complete | 21             |

---

## Operation Log

All 12 operations complete. A/B validators: 7/7 PASS.

### Principles added/amended in plugins/conclave/shared/principles.md

**Universal CRITICAL** (3 new, 3 amended):

- Principle #1 (amended): Added adversary-per-phase + pre-build validation language
- Principle #2 (amended): Added explicit state handoff language
- Principle #3 (amended): Strengthened to "halt on ambiguity"
- Principle #13 (new): No secrets in context
- Principle #14 (new): Scope is a contract
- Principle #15 (new): The human is the architect

**Universal ESSENTIAL** (1 amended):

- Principle #9 (amended): Log decisions and state changes (checkpoint logging added)

**Universal NICE-TO-HAVE** (1 new):

- Principle #16 (new): Prefer tooling for deterministic steps

**Engineering IMPORTANT** (2 new):

- Principle #17 (new): Work in reversible steps
- Principle #18 (new): Humans validate tests

### Skill-specific changes

**Full rationale stripping** (Law 01):

- build-implementation: backend-eng, frontend-eng COMMUNICATION
- build-product: backend-eng, frontend-eng COMMUNICATION
- craft-laravel: Implementer COMMUNICATION (before Convention Warden review)
- write-spec: Architect, DBA COMMUNICATION
- plan-implementation: Implementation Architect COMMUNICATION
- refine-code: Artisan COMMUNICATION (before Refine Skeptic review)
- review-pr: Phase 2 spawn instructions (blind code evaluation)

**Partial rationale stripping** (Law 01):

- review-quality, run-task, create-conclave-team: WRITE SAFETY / COMMUNICATION
- research-market, ideate-product, manage-roadmap, write-stories: WRITE SAFETY
- plan-sales (all 3 analysts): WRITE SAFETY
- plan-product (all 8 agents): WRITE SAFETY

**Pre-build validation gates** (Law 05):

- build-implementation: backend-eng, frontend-eng CRITICAL RULES
- build-product: backend-eng, frontend-eng CRITICAL RULES
- craft-laravel: Implementer CRITICAL RULES
- squash-bugs: Artificer CRITICAL RULES
- refine-code: Artisan CRITICAL RULES
- run-task: Engineer Template CRITICAL RULES

**Human test review notifications** (Law 14):

- build-implementation: QA Agent COMMUNICATION
- build-product: QA Agent COMMUNICATION
- craft-laravel: Convention Warden COMMUNICATION
- squash-bugs: Warden COMMUNICATION
- refine-code: Artisan COMMUNICATION
- run-task: Engineer Template COMMUNICATION

### Exemptions documented (Law 01)

- harden-security: Toulmin warrant is the logical chain
- squash-bugs: hypothesis elimination matrix is the deliverable
- draft-investor-update: Drafter Notes enable framing challenges
- plan-hiring: debate tensions are core output
- unearth-specification: archaeological rationale is part of the record
