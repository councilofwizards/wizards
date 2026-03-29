---
type: "story-review"
feature: "P2-09 Persona System Activation"
status: "complete"
reviewer: "Grimm Holloway, Keeper of the INVEST Creed"
verdict: "APPROVED"
created: "2026-03-10"
updated: "2026-03-10"
---

# Story Skeptic Review: Persona System Activation (P2-09)

## Review Summary

REVIEW: Stories 1-5 for P2-09 Persona System Activation Verdict: APPROVED Stories reviewed: 5/5

---

## Per-Story INVEST Assessment

### Story 1: Fictional Name Injection in Spawn Prompts — PASS

| Criterion   | Verdict | Notes                                                                                                                          |
| ----------- | ------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Independent | PASS    | Can be delivered without Stories 2-4 (names appear in prompts regardless of sign-off or placeholder)                           |
| Negotiable  | PASS    | Specifies the contract ("fictional name and title from persona YAML") without dictating implementation order or tooling        |
| Valuable    | PASS    | "So that" clause is concrete — meeting Theron Blackwell vs. a generic "Market Researcher"                                      |
| Estimable   | PASS    | Scope is well-bounded: ~40+ spawn prompts across 12 files, one-line change per prompt, source data in persona YAML frontmatter |
| Small       | PASS    | Repetitive edits to a known pattern. Effort is proportional to file count, not complexity                                      |
| Testable    | PASS    | AC1 and AC3 are grep-auditable; AC4 covers skeptic roles explicitly                                                            |

**SMART AC Review:**

- AC1: Specific (names exact format), Measurable (grep for pattern), Achievable, Relevant. PASS.
- AC2: Measurable only if "first addresses the user" is observable. This is an LLM behavioral outcome, not a structural
  check. Acceptable for a markdown plugin — there is no automated test for agent runtime behavior. PASS with note.
- AC3: "Every spawn prompt (estimated 40+)" — the word "estimated" is acceptable; the exact count depends on auditing
  all files. PASS.
- AC4: Explicit skeptic coverage. Good — prevents the most common oversight. PASS.

**Edge cases:** Business skill persona file naming convention called out. run-task exclusion explicit. Missing
frontmatter fields treated as blockers. All three are correct and well-scoped.

---

### Story 2: Spawn Prompt Self-Introduction Instruction — PASS

| Criterion   | Verdict | Notes                                                                                                                         |
| ----------- | ------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Independent | PASS    | The instruction is a separate line from the name injection. Could be delivered alone (though coupled implementation is noted) |
| Negotiable  | PASS    | "Such as" language on the instruction wording leaves room for implementation judgment                                         |
| Valuable    | PASS    | Addresses the architectural fragility called out in the research — structural enforcement vs. LLM inference                   |
| Estimable   | PASS    | Same file set as Story 1, one additional line per prompt                                                                      |
| Small       | PASS    | Trivially small per-prompt addition                                                                                           |
| Testable    | PASS    | AC1 and AC3 are grep-auditable (100% presence check)                                                                          |

**SMART AC Review:**

- AC1: "Such as" gives flexibility while being specific enough. PASS.
- AC2: Same LLM behavioral outcome caveat as Story 1 AC2. Acceptable. PASS.
- AC3: "100% contain" is unambiguous. PASS.

**Edge cases:** Agent-to-agent-only agents still get the instruction for consistency — correct architectural choice.
Conflict resolution rule (spawn prompt takes precedence) is clear. PASS.

---

### Story 3: Communication Protocol Sign-Off Convention — PASS

| Criterion   | Verdict | Notes                                                                                                       |
| ----------- | ------- | ----------------------------------------------------------------------------------------------------------- |
| Independent | PASS    | Protocol edit is independent of spawn prompt changes                                                        |
| Negotiable  | PASS    | Specifies the convention content but not exact placement within the section                                 |
| Valuable    | PASS    | "Reinforcing immersion across the entire session, not just at first introduction" — clear incremental value |
| Estimable   | PASS    | One edit to one file + one sync run. Validator behavior is known                                            |
| Small       | PASS    | Single sentence addition to one authoritative file                                                          |
| Testable    | PASS    | AC1 is a string presence check. AC2-AC4 are validator outputs (pass/fail)                                   |

**SMART AC Review:**

- AC1: Specific text, specific file, specific section. PASS.
- AC2: Measurable via file inspection post-sync. PASS.
- AC3: Marker content match — binary check. PASS.
- AC4: "B1, B2, and B3 all pass (0 drift errors)" — concrete threshold. PASS.

**Edge cases:** Prose vs. code block placement distinction is correct and prevents a real implementation mistake.
Single-agent/tier-2 exclusion reminder is good defensive documentation. PASS.

---

### Story 4: Communication Protocol Placeholder Fix — PASS

| Criterion   | Verdict | Notes                                                                                               |
| ----------- | ------- | --------------------------------------------------------------------------------------------------- |
| Independent | PASS    | Can be delivered without Stories 1-3 (it is a maintenance fix)                                      |
| Negotiable  | PASS    | Specifies the target value but leaves comment format flexible (HTML comment, same line or adjacent) |
| Valuable    | PASS    | Value is to maintainers, not end users — correctly marked should-have                               |
| Estimable   | PASS    | One table cell edit + one comment + sync script verification                                        |
| Small       | PASS    | Smallest story in the set                                                                           |
| Testable    | PASS    | AC1-AC2 are string checks. AC3-AC4 are validator/sync outputs                                       |

**SMART AC Review:**

- AC1: Exact placeholder value specified. PASS.
- AC2: Inline comment presence. PASS.
- AC3: "Per-skill skeptic names are still correctly substituted" — measurable via diff or grep. PASS.
- AC4: "12/12 validators pass" — binary. PASS.

**Edge cases:** This is where I applied the most scrutiny. The story correctly identifies the critical risk: the sync
script at lines 173-174 and 207-213 of `sync-shared-content.sh` uses `product-skeptic` and `Product Skeptic` as literal
sed substitution anchors (`AUTH_SKEPTIC_SLUG="product-skeptic"` and `AUTH_SKEPTIC_DISPLAY="Product Skeptic"`). Changing
the source to `{skill-skeptic}` means the sync script variables must also change to `{skill-skeptic}` as the
substitution source pattern, OR the sync script must be updated to substitute the new placeholder. The edge case callout
("verify the sync script's substitution input before editing") correctly flags this. The implementer must update the
sync script's `AUTH_SKEPTIC_SLUG` and `AUTH_SKEPTIC_DISPLAY` constants to match whatever the new placeholder values are.
This is not called out as an explicit AC, but it is covered by AC3 ("sync behavior is not broken") and the edge case
note. Acceptable.

---

### Story 5: Validator Green After All Changes — PASS

| Criterion   | Verdict          | Notes                                                                     |
| ----------- | ---------------- | ------------------------------------------------------------------------- |
| Independent | PASS (as a gate) | It is a quality gate, not a deliverable — correctly documented in Notes   |
| Negotiable  | PASS             | Gate criteria are fixed (12/12 pass), which is correct for a quality gate |
| Valuable    | PASS             | Prevents regression — clear value                                         |
| Estimable   | PASS             | One command run with binary outcome                                       |
| Small       | PASS             | It is a verification step, not implementation work                        |
| Testable    | PASS             | `bash scripts/validate.sh` output is the test                             |

**SMART AC Review:**

- AC1: "12/12 checks passing with no errors or warnings" — specific, measurable. PASS.
- AC2: A-series non-violation is a structural claim. PASS.
- AC3: B1, B2, B3 enumerated. PASS.
- AC4: Per-skill skeptic name substitution check — ensures Story 4 doesn't break sync. PASS.

**Edge cases:** Marker corruption and sync breakage scenarios are both real risks for this type of work. PASS.

---

## Cross-Story Assessment

### Epic Coverage

The 5 stories fully cover the 3 bundled changes in the roadmap item:

1. Persona name injection (Stories 1 + 2)
2. Protocol sign-off convention (Story 3)
3. Placeholder fix (Story 4)
4. Validator gate (Story 5) — not in roadmap but is a correct quality gate

All 5 success criteria from the roadmap item are addressed:

- "Every spawn prompt contains the agent's fictional name and title" — Story 1 AC1, AC3
- "Every spawn prompt instructs the agent to introduce themselves" — Story 2 AC1, AC3
- "Communication protocol includes sign-off convention" — Story 3 AC1
- "Protocol placeholder uses generic {skill-skeptic} pattern" — Story 4 AC1
- "All 12/12 validators pass" — Story 5 AC1

### Out of Scope

Correctly excludes run-task, new persona file creation, protocol structural changes, new validator rules, Tier 2
composites, and single-agent utilities. All exclusions are justified and traceable to the roadmap scope.

### Non-Functional Requirements

Consistency, maintainability, no-runtime-impact, validator compliance, and sync atomicity are all correctly stated. The
sync atomicity note (Stories 3+4 before single sync run) prevents a real intermediate-state bug.

---

## Verdict: APPROVED

All 5 stories pass INVEST criteria. All acceptance criteria pass SMART review. Edge cases are thorough and grounded in
actual codebase analysis (sync script substitution logic, validator behavior, marker integrity). The story set is
complete against the roadmap item's scope and success criteria.

No issues found. Stories are ready for implementation.
