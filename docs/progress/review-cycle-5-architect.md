---
feature: "review-cycle-5"
team: "plan-product"
agent: "architect"
phase: "complete"
status: "complete"
last_action: "Completed deep technical architecture assessment for review cycle 5 with validator testing"
updated: "2026-02-19"
---

# Review Cycle 5 — Technical Architecture Assessment

## 1. Architecture Debt Assessment

### ADR Status Review

| ADR | Status | Current Health | Action Needed |
|-----|--------|---------------|---------------|
| ADR-001 (Roadmap File Structure) | Proposed (never formalized) | Sound but status stale | Update status to "Accepted"; add frontmatter block |
| ADR-002 (Content Deduplication) | Accepted | Healthy. 8-skill trigger approaching (6/8 after plan-sales). | Monitor. Pre-plan extraction at 7. |
| ADR-003 (Onboarding Wizard Single-Agent) | Accepted | Healthy. Correct precedent for utility skills. | No action. |

### Architectural Debt Items

1. **ADR-001 status never formalized.** Body says "Proposed" but it is the de facto standard. Should be "Accepted" with frontmatter matching ADR-002/003 format.

2. **ADR-002 8-skill trigger approaching.** Currently 5 skills. With plan-sales = 6. Two more additions hit 8 and trigger shared content extraction. Pre-plan the extraction strategy at 7 to avoid reactive architecture.

3. **Roadmap data integrity debt persists.** `_index.md` lists 31 items; only 17 have individual `.md` files. The roadmap validator covers only ~55% of items. RC4 flagged this; still unresolved.

### Architecture Documents — All 9 are healthy. No revisions needed.

## 2. CI/Validator Health — CRITICAL FINDINGS

### Validator Test Results (ran all 5 validators against current codebase)

| Validator | Result | Issue |
|-----------|--------|-------|
| `skill-structure.sh` | **FLAKY** | Intermittent A2 failures on large files. 1 of 3 runs failed. |
| `skill-shared-content.sh` | PASSING | Needs `strategy-skeptic` before plan-sales. |
| `roadmap-frontmatter.sh` | **FAILING (4 errors)** | Effort value casing: `"Medium"` vs `"medium"`, `"Small-Medium"` not a valid enum. |
| `spec-frontmatter.sh` | PASSING | All 9 specs pass. |
| `progress-checkpoint.sh` | **FAILING (1 error)** | `team: "draft-investor-update"` not in hard-coded VALID_TEAMS enum. |

### FLAKY VALIDATOR — skill-structure.sh (HIGHEST PRIORITY)

**Root cause identified**: The A2 section check loads entire file content into a shell variable via `file_content="$(cat "$filepath")"`, then searches via `printf '%s\n' "$file_content" | grep -qF "$section"`. For files exceeding ~30KB (draft-investor-update is 35KB), `printf` intermittently truncates the shell variable argument.

**Evidence**: Ran the validator 3 times consecutively. Run 1: PASS. Run 2: FAIL (draft-investor-update missing "## Orchestration Flow" — confirmed present in file). Run 3: PASS.

**Fix**: Replace `printf '%s\n' "$file_content" | grep -qF "$section"` with `grep -qF "$section" "$filepath"` — grep directly on the file, eliminating the shell variable intermediary. This is a 1-line change per occurrence in the loop.

**Severity**: HIGH. Flaky CI erodes trust and blocks builds unpredictably. As SKILL.md files grow (business skills tend to be larger due to output templates), this will become more frequent.

### FAILING — roadmap-frontmatter.sh (4 errors)

Files with wrong effort values:
- `P2-07-universal-principles.md`: `effort: "Medium"` (should be `"medium"`)
- `P2-08-plugin-organization.md`: `effort: "Medium"` (should be `"medium"`)
- `P3-10-plan-sales.md`: `effort: "Medium"` (should be `"medium"`)
- `P3-22-draft-investor-update.md`: `effort: "Small-Medium"` (not a valid enum; should be `"medium"`)

These files were all created during RC4. The validator correctly enforces lowercase per ADR-001; the data is wrong.

### FAILING — progress-checkpoint.sh (1 error)

`investor-update-backend-eng.md` has `team: "draft-investor-update"` but the validator's `VALID_TEAMS` enum only contains `plan-product | build-product | review-quality`. The enum was not updated when the investor-update skill was added.

**Structural issue**: The hard-coded team enum must be updated every time a new skill is added. This should be dynamically derived from the skill directory listing, or the enum should accept any non-empty string and validate that a matching skill directory exists.

### Validator Gaps

1. **No validator for architecture documents.** 9 documents and growing. No structural checks.
2. **skill-shared-content.sh normalize function** needs `strategy-skeptic` / `Strategy Skeptic` before plan-sales implementation (already documented in plan-sales system design).

## 3. Technical Dependencies

### Critical Path

```
P3-10 (plan-sales) ─── unblocks ──→ P2-08 (Plugin Organization: 2nd business skill)
                   ─── advances ──→ P2-07 (Universal Principles: 6/8)
                   ─── validates ─→ Collaborative Analysis (3rd consensus pattern)
```

P2-02 (Skill Composability) remains indefinitely blocked by platform limitations.

### What Unlocks Most Value

1. **P3-10 (plan-sales)**: Unblocks P2-08, validates Collaborative Analysis, advances P2-07 to 6/8.
2. **P3-03 (Contribution Guide)**: Small effort, no blockers, useful for onboarding.
3. **P3-16 (build-sales-collateral)**: Natural follow-up to P3-10 (uses its output).

## 4. Framework Evolution

At 5 skills (+ plan-sales incoming), the marker-based shared content system (ADR-002) is working well. No premature extraction needed.

**Mature patterns** (stable across 4+ skills): Shared Principles, Communication Protocol, Checkpoint Protocol, Write Safety, Failure Recovery. All managed by existing markers/validators.

**Emerging patterns** (1-2 implementations): Dual-skeptic gate, Pipeline, Business quality sections. Too early to extract.

**Not yet validated**: Collaborative Analysis (plan-sales will be first). Structured Debate (no implementations yet).

**Emerging concern**: Skill-specific output directories (`docs/investor-updates/`, `docs/sales-plans/`, etc.) will proliferate as business skills are added. Consider standardizing a naming convention when 3+ custom directories exist.

## 5. Next Spec Candidate (Post plan-sales)

| Candidate | Pattern | Risk | P2-07 | Rationale |
|-----------|---------|------|-------|-----------|
| **P3-16 build-sales-collateral** | Pipeline (proven) | Low | 7/8 | Uses P3-10 output, validates skill output chaining |
| P3-14 plan-hiring | Structured Debate (new) | Medium | 7/8 | Validates final unvalidated pattern |
| P3-11 plan-marketing | Collaborative Analysis (reuse) | Low | 7/8 | Confirms CA pattern |

**Technical recommendation**: P3-16 (build-sales-collateral) — best ratio of new-value to new-risk. Reuses proven Pipeline pattern, takes P3-10 output as input (validates skill output chaining), and counts toward P2-07 threshold. P3-14 is the stronger pattern-validation choice but carries higher risk.

## Summary of Recommendations

| Priority | Recommendation | Effort |
|----------|---------------|--------|
| **HIGH** | Fix flaky skill-structure.sh (replace printf with direct grep on file) | Small |
| **HIGH** | Fix 4 roadmap files with wrong effort casing | Trivial |
| **MEDIUM** | Update progress-checkpoint.sh VALID_TEAMS to accept new skill teams | Trivial |
| **MEDIUM** | Add strategy-skeptic to skill-shared-content.sh normalize (before plan-sales) | Trivial |
| **LOW** | Formalize ADR-001 status to "Accepted" with frontmatter | Trivial |
| **LOW** | Pre-plan ADR-002 extraction strategy at skill count 7 | Small |
| **DEFERRED** | Backfill ~14 missing roadmap item files | Medium |
