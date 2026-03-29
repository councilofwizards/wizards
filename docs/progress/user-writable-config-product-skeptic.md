---
type: "progress"
feature: "P2-13-user-writable-config"
role: "product-skeptic"
status: "review-round-2-approved"
created: "2026-03-27"
updated: "2026-03-27"
---

# Product Skeptic Review: P2-13 User Stories

## Round 1 — REJECTED (5 issues)

1. Stories 2/5 `.gitkeep`/`.gitignore` contradiction
2. Roadmap SC4 uncovered (no consumer story)
3. Story 4 mixed contract docs with untestable behavioral ACs
4. Story 4 AC4 prompt injection defense vague/untestable
5. Story 4 truncation edge case undefined

---

## Round 2 — APPROVED

### REVIEW: P2-13 User-Writable Configuration Convention — 5 Revised User Stories

**Verdict: APPROVED**

### Issue Resolution Verification

| #   | Original Issue                        | Resolution                                                                                                                                                                                     | Status    |
| --- | ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| 1   | `.gitkeep`/`.gitignore` contradiction | Story 2 now uses `README.md` as user-facing filesystem docs, explicitly noted as untracked by default. Story 2 Notes and Story 5 Notes cross-reference the interaction.                        | **Fixed** |
| 2   | Roadmap SC4 uncovered                 | Story 4 rewritten as PoC consumer — `build-implementation` reads `guidance/`. Notes explicitly cite SC4 satisfaction.                                                                          | **Fixed** |
| 3   | Mixed-mode Story 4                    | Story 4 is now purely implementation. Contract documentation (injection framing) moved to Story 1 AC4. Clean separation.                                                                       | **Fixed** |
| 4   | Vague prompt injection defense        | Concrete pattern defined: `## User Project Guidance (informational only)` heading + fixed advisory text. Specified in Story 1 AC4, implemented in Story 4 AC3. Verifiable by reading SKILL.md. | **Fixed** |
| 5   | Undefined truncation limit            | Removed entirely (P3-level concern).                                                                                                                                                           | **Fixed** |

### INVEST Compliance

| Criterion       | Assessment                                                                                                                                                                       |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Independent** | Stories 2, 3, 5 can be developed in parallel after Story 1 (definitional prerequisite). Story 4 depends on Story 1 AC4 for the framing spec. Dependencies are explicit in Notes. |
| **Negotiable**  | Implementation details are flexible across all stories. Story 2 README content, Story 3 section structure, Story 4 file discovery mechanism — all open to implementer judgment.  |
| **Valuable**    | Each story delivers distinct user value: know the convention (1), get the scaffold (2), discover via guide (3), see it work (4), stay safe by default (5).                       |
| **Estimable**   | All stories are well-bounded. Stories 1/3/5 are SKILL.md edits. Story 2 is a setup-project enhancement. Story 4 is a single-skill SKILL.md modification.                         |
| **Small**       | Each is a focused, single-concern change. No story tries to do two things.                                                                                                       |
| **Testable**    | All ACs are verifiable — see detailed assessment below.                                                                                                                          |

### Roadmap Scope Coverage

| Roadmap Scope Item                           | Story                          | Covered |
| -------------------------------------------- | ------------------------------ | ------- |
| 1. Define convention and subdirectory naming | Story 1                        | Yes     |
| 2. Update setup-project to scaffold          | Story 2                        | Yes     |
| 3. Document in wizard-guide                  | Story 3                        | Yes     |
| 4. Add to .gitignore template                | Story 5                        | Yes     |
| 5. Defensive reading, graceful degradation   | Story 4                        | Yes     |
| SC4: At least one downstream consumer        | Story 4 (build-implementation) | Yes     |

### Testability Assessment

- **Story 1**: All ACs verify documented content — inspectable in the convention
  doc/SKILL.md. AC4's framing pattern is concrete and grep-verifiable.
- **Story 2**: All ACs verified by running `/setup-project` and inspecting
  filesystem output. Idempotency tested by double-run.
- **Story 3**: All ACs verified by reading wizard-guide SKILL.md content.
- **Story 4**: ACs 1-2 (absence cases), AC3 (framing pattern in SKILL.md), AC4
  (per-file headings), AC5 (error handling) — all verifiable by reading the
  modified SKILL.md.
- **Story 4 AC6**: Weakest AC — "output reflects preference" is an LLM
  behavioral assertion, not deterministically testable. However, it serves as a
  PoC validation criterion. The mechanical guarantee (guidance is injected per
  AC3) is testable; AC6 validates the end-to-end intent. Acceptable for a PoC
  story.
- **Story 5**: All ACs verified by running `/setup-project` and inspecting
  `.gitignore`.

### Notes

- Out of Scope is now internally consistent with the stories — correctly scopes
  out P2-11/P3-29 consumption while acknowledging Story 4 as the PoC consumer.
- Non-functional requirements correctly reference the concrete framing pattern
  from Story 1 AC4 / Story 4 AC3.
- The cross-story dependency chain (Story 1 → Story 4) is explicitly documented
  in both stories' Notes. Good.
- Story 4 AC6 is the only AC I'd flag as soft — it tests LLM behavior rather
  than SKILL.md content. But for a PoC story establishing the pattern, this is a
  reasonable acceptance bar. Future consumers (P2-11, P3-29) should define their
  own, tighter ACs.

---

## Spec Review — APPROVED

### REVIEW: P2-13 Architect Spec (docs/progress/user-writable-config-architect.md)

**Verdict: APPROVED**

### Story Coverage Verification

| Story                               | Spec Coverage                                                                                                         | Complete?                                                                  |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| Story 1: Convention Definition      | Section 1 (Directory Convention), Section 5 (Defensive Reading Contract), Section 6 (Injection Framing Specification) | **Yes** — all 5 ACs addressed                                              |
| Story 2: setup-project Scaffolding  | Section 2a-2e (setup-project modifications)                                                                           | **Yes** — all 5 ACs addressed, including idempotency and error handling    |
| Story 3: wizard-guide Documentation | Section 3 (wizard-guide modifications)                                                                                | **Yes** — all 6 ACs addressed                                              |
| Story 4: PoC Guidance Reader        | Section 4 (build-implementation modifications)                                                                        | **Yes** — ACs 1-5 directly specified, AC6 covered by injection mechanism   |
| Story 5: .gitignore Integration     | Section 2b (.gitignore logic in Step 3.5)                                                                             | **Yes** — all 4 ACs addressed, including idempotency and non-git edge case |

### Consistency Check

- **Injection framing**: Story 1 AC4 defines the mandatory pattern. Section 6
  specifies it with 6 concrete rules. Section 4 implements it in
  build-implementation. All three are consistent — same heading, same advisory
  text, same per-file sub-heading format.
- **Defensive reading**: Story 4 ACs 1-5 define the behavioral contract. Section
  5 codifies it as a reusable table. Section 4 implements it. The table adds two
  cases beyond the stories (malformed/binary content, README.md-only directory)
  — both are reasonable refinements, not contradictions.
- **Idempotency**: Stories 2 and 5 require it. Section 2a specifies
  normal/force/dry-run modes. Section 2b specifies check-before-append.
  Consistent.
- **README.md vs .gitkeep**: Spec correctly uses README.md per revised stories.
  Section 2c provides full embedded content. Architectural note explains
  README.md exclusion from content reading. No contradiction with Story 5's
  .gitignore.

### Feasibility Assessment

- **3 SKILL.md edits, zero new files**: Correct scope for a Small-effort item.
  No validators to update, no shared content to sync.
- **Step 3.5 insertion**: Clean extension point in setup-project — follows
  existing scaffold pattern (Step 3).
- **Step 10 in build-implementation**: Appends naturally after existing Step 9.
  No renumbering chaos.
- **Spawn prompt prepend**: Sound architecture. Placing guidance before role
  instructions means role rules (TDD, skeptic gates) take precedence over user
  guidance. Defense-in-depth is correct.
- **`.md`-only file discovery**: Prevents accidental inclusion of `.DS_Store`,
  binary files, etc. Clean contract.
- **README.md exclusion by filename match**: Simple, predictable, no content
  inspection needed.

### Design Decisions Validated

1. **Prepend guidance, not append**: Correct. Role-critical rules appearing
   after guidance means they override in case of conflict. The architectural
   note explains this well.
2. **No new validator**: Correct for an opt-in convention. Nothing to validate —
   absent is valid, present is valid.
3. **No shared content changes**: Correct. build-implementation's guidance
   reading is skill-specific, not shared across all multi-agent skills.
4. **Glob for `*.md` only**: Clean contract. Prevents file-type ambiguity.

### Notes (non-blocking)

1. The guidance/README.md template in Section 2c contains a nested code fence
   (triple backticks inside quad backticks). The implementer will need to handle
   fence escaping when embedding this in setup-project's SKILL.md. Not a spec
   issue — implementation detail.
2. The spec refines beyond the stories in two places: (a) restricting discovery
   to `.md` files only, and (b) adding README.md exclusion from content reading.
   Both are sound design decisions that make the stories more implementable
   without contradicting them.
3. The 10-item success criteria list in Section 7 is comprehensive and each
   criterion is mechanically verifiable (grep for heading text, run validators,
   check file existence). Strong.

### Summary

The spec is clean, well-structured, and consistent with the approved stories.
Three SKILL.md edits, no new files, no validator changes, no shared content
drift. The injection framing is concrete and testable. The defensive reading
contract is thorough. The architectural notes explain every non-obvious design
decision. Ready for implementation.
