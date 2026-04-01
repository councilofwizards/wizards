---
feature: "iron-laws"
status: "complete"
completed: "2026-04-01"
---

# Iron Laws of Agentic Coding — Enshrinement Summary

## Summary

Enshrined 16 Iron Laws of Agentic Coding across all 24 conclave skills via The Crucible Accord. Added 6 new shared
principles (#13-#18) and amended 4 existing principles (#1, #2, #3, #9) in the authoritative source at
`plugins/conclave/shared/principles.md`. Applied skill-specific changes (rationale stripping, pre-build validation
gates, human test review notifications) to ~20 skills. Confirmed 4 laws already fully compliant with no changes needed.

## Changes

### Shared Principles (plugins/conclave/shared/principles.md)

**New CRITICAL principles:**

- #13: No secrets in context (Law 04)
- #14: Scope is a contract (Law 03)
- #15: The human is the architect (Law 16)

**New NICE-TO-HAVE principle:**

- #16: Prefer tooling for deterministic steps (Law 08)

**New IMPORTANT engineering principles:**

- #17: Work in reversible steps (Law 10)
- #18: Humans validate tests — notification, not blocking (Law 14)

**Amended principles:**

- #1: Added adversary-per-phase requirement + pre-build validation (Laws 12, 05)
- #2: Added explicit state handoff language (Law 09)
- #3: Strengthened to "halt on ambiguity" with explicit STOP instruction (Law 02)
- #9: Extended to include checkpoint logging for reasoning chain reconstruction (Law 15)

### Skill-Specific Changes

**Law 01 — Rationale stripping:**

- Full stripping: build-implementation, build-product, craft-laravel, write-spec, plan-implementation, refine-code,
  review-pr
- Partial stripping: review-quality, run-task, create-conclave-team, research-market, ideate-product, manage-roadmap,
  write-stories, plan-sales, plan-product
- Exempt (rationale is the deliverable): harden-security, squash-bugs, draft-investor-update, plan-hiring,
  unearth-specification

**Law 05 — Pre-build validation gates:** build-implementation, build-product, craft-laravel, squash-bugs, refine-code,
run-task

**Law 14 — Human test review notifications:** build-implementation, build-product, craft-laravel, squash-bugs,
refine-code, run-task

### No-Change Laws (already compliant)

- Law 06: Spec Before Build (83% — run-task accepted gap)
- Law 07: Subagents Isolate Context (100%)
- Law 11: Match Agent to Task (100%)
- Law 13: Follow Testing Pyramid (83% — run-task accepted gap)

## Files Modified

- `plugins/conclave/shared/principles.md` — authoritative source (6 new + 4 amended principles)
- All 21 multi-agent SKILL.md files — via sync-shared-content.sh (shared block injection)
- ~20 SKILL.md files — skill-specific spawn prompt edits (Laws 01, 05, 14)

## Verification

- A1-A4 validators: PASS (24 files)
- B1-B3 validators: PASS (no drift)
- F1, G1 validators: PASS
- 17/24 skills spot-checked by Refine Skeptic (71%)
- Phase 1 manifest reviewed with 2 rejection cycles (model assignment errors corrected)
- Phase 2 plan accepted on first review
- Phase 3 Brightwork accepted on first review
- Phase 4 Proof produced and accepted by Crucible Lead

## Notes

- Principle #1 is now dense (3 sentences) — consider splitting in future refactor
- squash-bugs has cosmetic inconsistency: warden listed as opus in teammate table, Sonnet in spawn prompt — spawn prompt
  is authoritative, not fixed
- Law 16 implemented as Option A (advisory only) — foundation in place to upgrade to targeted gates later
