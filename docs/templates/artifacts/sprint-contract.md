---
type: "sprint-contract"
feature: ""
next_action: "" # set on signing to "/conclave:build-implementation <feature>" or "/conclave:build-product <feature>"
status: "draft" # draft | negotiating | signed | superseded
# NOTE: sprint-contract uses its own state vocabulary (signed = the binding state). Other artifacts use
# draft → reviewed → approved → consumed. This is intentional — "signed" matches the legal-contract metaphor and is
# unambiguous against the 4-state vocabulary used elsewhere.
signed-by: [] # e.g. ["planning-lead", "plan-skeptic"] or ["implementation-coordinator", "quality-skeptic"]
created: ""
updated: ""
---

# Sprint Contract: {Feature}

## Acceptance Criteria

<!-- Each criterion is a numbered, pass/fail-evaluable item. Derive from spec success criteria and user story ACs. -->

1. {Criterion description} | Pass/Fail: [ ]
2. {Criterion description} | Pass/Fail: [ ]

## Out of Scope

<!-- Explicit exclusions. What this contract does NOT cover. Prevents scope creep during evaluation. -->

- {Exclusion}

## Performance Targets

<!-- Optional. Measurable performance requirements. Leave as placeholder if none apply. -->

<!-- No performance targets defined for this feature. -->

## Signatures

<!-- Both Lead and Skeptic must sign before the contract is considered binding. -->

- **Planning Lead**: \***\*\_\_\*\*** (date: **\_\_**)
- **Plan Skeptic**: \***\*\_\_\*\*** (date: **\_\_**)

## Amendment Log

<!-- Appended on first amendment. Each entry records what changed, why, and who approved. -->

<!-- No amendments. -->
