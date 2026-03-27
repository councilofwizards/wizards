---
title: "QA Agent for Live Testing"
status: complete
priority: P2
category: quality-reliability
effort: Large
impact: High
dependencies:
  - P2-11 (soft — more reliable with sprint contracts, not strictly blocked)
created: 2026-03-27
updated: 2026-03-27
---

# P2-12: QA Agent for Live Testing

## Summary

Add a dedicated QA agent role to `build-implementation` and `build-product` that writes and executes e2e/Playwright tests against the built application before approving. This agent is SEPARATE from the existing code/quality skeptic — different role, different concerns.

## Motivation

Anthropic's harness design paper found that live application testing by evaluators dramatically outperforms text-only code review. The existing Skeptic reviews code diffs but never runs the application. A dedicated QA agent that exercises the artifact as a user would catches a fundamentally different class of bugs — broken workflows, missing interactions, edge cases that only appear at runtime.

The paper's evaluator used Playwright to interact with live pages, providing specific feedback that drove iterative improvements. Our QA agent follows this pattern.

## Scope

- New QA agent spawn definition in `build-implementation` and `build-product` SKILL.md files
- New persona for the QA agent (distinct from code skeptic)
- QA agent responsibilities:
  - Read sprint contract acceptance criteria (from P2-11, if available)
  - Write e2e/Playwright tests that verify each acceptance criterion as user-facing behavior
  - Execute the test suite against the running application
  - Report pass/fail results with specific failure details (what failed, which file, what the fix should be)
  - APPROVE or REJECT based on test execution results, not code inspection
- Integration point: QA runs AFTER code skeptic approves code quality, BEFORE final Lead sign-off
- Test criteria framed as user-facing behaviors ("can a user complete this workflow"), not implementation checks ("does this function exist")

## Role Separation

| Concern | Code Skeptic | QA Agent |
|---------|-------------|----------|
| Reviews | Code diffs, architecture, patterns | Running application behavior |
| Method | Static analysis, code reading | Playwright/e2e test execution |
| Criteria | Code quality, SOLID, DRY | Acceptance criteria, user workflows |
| Verdict | Code is well-written | Application works correctly |

## Success Criteria

1. QA agent spawn definition exists in build-implementation and build-product
2. QA agent writes and executes Playwright/e2e tests
3. QA agent is a distinct role from code/quality skeptic
4. QA agent evaluates test execution results, not code diffs
5. All validators pass after changes
