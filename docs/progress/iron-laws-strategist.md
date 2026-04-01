---
feature: "iron-laws"
team: "the-crucible-accord"
agent: "strategist"
phase: "planning"
status: "complete"
last_action: "Execution plan produced — 16 operations sequenced across 3 tiers"
updated: "2026-04-01T13:00:00Z"
---

# Iron Laws Execution Plan — The Sequence

Corin Brightseam, Keeper of the Sequence — ordered execution plan for enshrining the 16 Iron Laws across all 24 conclave
skills.

---

## 1. Implementation Strategy Summary

| Law                             | Approach                                      | Rationale                                                                                                            |
| ------------------------------- | --------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| 01. Strip Rationales            | C (SKILL-SPECIFIC)                            | Design tension: blanket stripping harms security/debate skills. Must be per-skill.                                   |
| 02. Halt on Ambiguity           | B (AMENDMENT)                                 | Strengthen Principle #3 with explicit halt language.                                                                 |
| 03. Scope Is a Contract         | A (NEW SHARED PRINCIPLE)                      | No existing principle covers scope contracts or self-expansion prohibition.                                          |
| 04. No Secrets in Context       | A (NEW SHARED PRINCIPLE)                      | Zero coverage. CRITICAL tier.                                                                                        |
| 05. Interrogate Before Iterate  | B (AMENDMENT) + C (SKILL-SPECIFIC)            | Amend Principle #1 for general coverage; building skills need explicit pre-build validation gates.                   |
| 06. Spec Before Build           | E (NO-CHANGE)                                 | 83% compliant. run-task is the only gap — acceptable given its dynamic nature.                                       |
| 07. Subagents Isolate Context   | E (NO-CHANGE)                                 | 100% compliant.                                                                                                      |
| 08. Scripts Handle Determinism  | E (ARCHITECTURAL)                             | Platform constraint — markdown prompts can't invoke scripts. Document as known limitation.                           |
| 09. State Travels Explicitly    | B (AMENDMENT)                                 | Minor amendment to Principle #2: explicit "no inherited knowledge" language.                                         |
| 10. Work in Reversible Steps    | A (NEW ENGINEERING PRINCIPLE)                 | No existing principle requires committable state after each step.                                                    |
| 11. Match Agent to Task         | E (NO-CHANGE)                                 | 100% compliant.                                                                                                      |
| 12. Every Phase Needs Adversary | B (AMENDMENT)                                 | Strengthen Principle #1 to document Lead-as-Skeptic as an acknowledged tradeoff, not a gap.                          |
| 13. Testing Pyramid             | E (NO-CHANGE)                                 | 83% compliant. Covered by Principles #5 and #7.                                                                      |
| 14. Humans Validate Tests       | A (NEW SHARED PRINCIPLE) + C (SKILL-SPECIFIC) | New principle for human test review; building skills need explicit gates. Requires human design decision.            |
| 15. Log Every Decision          | B (AMENDMENT)                                 | Strengthen Principle #9 with action-level logging requirement.                                                       |
| 16. Human Is Architect          | A (NEW SHARED PRINCIPLE) + C (SKILL-SPECIFIC) | New CRITICAL principle; building/planning skills need explicit human approval gates. Requires human design decision. |

### Approach Legend

- **A**: New shared principle in `plugins/conclave/shared/principles.md` → sync propagates to all skills
- **B**: Amendment to existing principle in `plugins/conclave/shared/principles.md` → sync propagates
- **C**: Skill-specific changes (spawn prompts, gates, review flows) — must be done per-skill
- **D**: New shared content block (not used — Iron Laws fit within existing principle blocks)
- **E**: No change / architectural constraint / already satisfied

---

## 2. Dependency Analysis

### Foundation Chain

```
Law 04 (No Secrets)        ─── independent, CRITICAL, universal
Law 03 (Scope Is Contract) ─── independent, enables Law 02 (halt requires knowing your scope)
Law 02 (Halt on Ambiguity) ─── depends on Law 03 (agents must know their scope to recognize out-of-scope ambiguity)
Law 09 (State Travels)     ─── independent, minor amendment
Law 15 (Log Every Decision)─── independent, minor amendment
Law 10 (Reversible Steps)  ─── independent, engineering only
Law 12 (Adversary)         ─── independent, minor amendment
Law 05 (Interrogate)       ─── depends on Law 02 (halt-on-ambiguity enables the interrogation pattern)
Law 16 (Human Is Architect)─── independent, but requires human design decision
Law 14 (Humans Validate)   ─── depends on Law 16 (human authority principle must exist first)
Law 01 (Strip Rationales)  ─── depends on Law 12 (adversary pattern must be documented before modifying review flows)
Law 08 (Scripts/Determinism)─── independent, documentation only
Law 06, 07, 11, 13         ─── no change needed
```

### Ordering Principles

1. **Shared content first**: Amendments and new principles propagate via sync — maximum coverage per operation.
2. **CRITICAL principles before ESSENTIAL**: Law 04 (secrets) and Law 03 (scope) are foundational safety.
3. **Independent laws before dependent**: Law 03 before Law 02. Law 12 before Law 01. Law 16 before Law 14.
4. **No-change laws last**: Laws 06, 07, 08, 11, 13 require no operations — documented for completeness.

---

## 3. Prioritized Operation Sequence

---

### Operation 1: Law 04 — No Secrets in Context

**Implementation approach**: A (NEW SHARED PRINCIPLE) **Applicability**: ALL (24 skills) **Current compliance**: 0
COMPLIANT, 0 PARTIAL, 24 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync); 3 single-agent skills
unaffected (no shared content injection)

#### Changes required:

1. Add new CRITICAL principle to `plugins/conclave/shared/principles.md` in the `universal-principles` block:
   ```
   N. **No secrets in context.** Credentials, API keys, tokens, and PII must never appear in agent
      prompts, messages, checkpoint files, or artifact outputs. If you encounter a secret in source
      code or configuration, flag it to your lead without including the secret value in your message.
      Use file paths and line numbers to reference secrets, never the values themselves.
   ```
2. Run `bash scripts/sync-shared-content.sh` to propagate to all 21 multi-agent skills.
3. Run `bash scripts/validate.sh` to verify.

#### Preconditions:

- `plugins/conclave/shared/principles.md` exists and has valid marker structure
- Sync script is operational

#### Postconditions:

- New principle appears in all 21 multi-agent SKILL.md files within `universal-principles` block
- All validators pass (A-series, B-series)
- No functional change to skill behavior beyond principle injection

#### Rollback boundary:

- Revert the single commit touching `plugins/conclave/shared/principles.md` + all synced SKILL.md files

#### Estimated scope:

- Files modified: 22 (1 shared + 21 SKILL.md)
- Lines changed: ~70 (3-4 lines × 22 files)

#### Risk assessment:

- **Low risk.** Additive change only. No existing content modified. Sync is idempotent.
- Principle numbering: must choose a number that fits the existing sequence (current: 1-3 CRITICAL, 9-10 ESSENTIAL,
  11-12 NICE-TO-HAVE). This should be principle #N in CRITICAL tier, renumbering not required if inserted as the next
  available number.

---

### Operation 2: Law 03 — Scope Is a Contract

**Implementation approach**: A (NEW SHARED PRINCIPLE) **Applicability**: ALL (24 skills) **Current compliance**: 0
COMPLIANT, 24 PARTIAL, 0 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync)

#### Changes required:

1. Add new CRITICAL principle to `plugins/conclave/shared/principles.md` in the `universal-principles` block:
   ```
   N. **Scope is a contract.** Every agent operates within its stated mandate. If you discover work
      that falls outside your assigned scope, report it to your lead — do not self-expand. Scope
      changes require explicit Team Lead approval. When in doubt about whether something is in scope,
      treat it as out of scope and escalate.
   ```
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operation 1 complete (principles.md already has the new secrets principle — avoids merge conflicts)

#### Postconditions:

- Scope contract principle in all 21 multi-agent skills
- All validators pass

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 22
- Lines changed: ~70

#### Risk assessment:

- **Low risk.** Additive. No existing content modified.
- Design note: "Team Lead approval" (not human approval) is intentional for this principle — Law 16 separately handles
  human authority over architecture.

---

### Operation 3: Law 02 — Halt on Ambiguity

**Implementation approach**: B (AMENDMENT to Principle #3) **Applicability**: ALL (24 skills) **Current compliance**: 0
COMPLIANT, 21 PARTIAL, 3 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync)

#### Changes required:

1. Amend Principle #3 in `plugins/conclave/shared/principles.md`:
   - **Current**:
     `"No assumptions. If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules."`
   - **New**:
     `"No assumptions — halt on ambiguity. If you encounter unclear requirements, ambiguous instructions, or missing information, STOP and surface the uncertainty to your lead before proceeding. Never guess at requirements, API contracts, data shapes, or business rules. Never invent a solution to bridge an ambiguity. The correct response to 'I'm not sure' is a message to your lead, not a best guess."`
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-2 complete (avoid concurrent edits to principles.md)

#### Postconditions:

- Amended Principle #3 in all 21 multi-agent skills
- All validators pass

#### Rollback boundary:

- Revert the single commit (original Principle #3 text restored)

#### Estimated scope:

- Files modified: 22
- Lines changed: ~44 (2 lines modified × 22 files)

#### Risk assessment:

- **Low risk.** Non-breaking amendment. Adds specificity, doesn't remove existing guidance.
- Agent behavior impact: agents may halt more often on edge cases. This is the desired effect.

---

### Operation 4: Law 09 — State Travels Explicitly

**Implementation approach**: B (AMENDMENT to Principle #2) **Applicability**: MULTI-AGENT (21 skills) **Current
compliance**: 20 COMPLIANT, 1 PARTIAL, 0 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync)

#### Changes required:

1. Amend Principle #2 in `plugins/conclave/shared/principles.md`:
   - **Current**:
     `"Communicate constantly via the SendMessage tool (...) Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately."`
   - **Append**:
     `"Never assume a downstream agent inherits knowledge from a prior phase. Pass complete state — file paths, artifact contents, decision context — at every handoff."`
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-3 complete

#### Postconditions:

- Amended Principle #2 in all 21 multi-agent skills
- All validators pass

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 22
- Lines changed: ~44

#### Risk assessment:

- **Very low risk.** Minor additive amendment. 95% already compliant. Codifies existing practice.

---

### Operation 5: Law 15 — Log Every Decision

**Implementation approach**: B (AMENDMENT to Principle #9) **Applicability**: ALL (24 skills) **Current compliance**: 0
COMPLIANT, 21 PARTIAL, 3 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync)

#### Changes required:

1. Amend Principle #9 in `plugins/conclave/shared/principles.md`:
   - **Current**:
     `"Document decisions, not just code. When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations."`
   - **New**:
     `"Log decisions and state changes. When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations. Log significant decisions, rejected alternatives, and state transitions to your checkpoint file so the reasoning chain can be reconstructed."`
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-4 complete

#### Postconditions:

- Amended Principle #9 in all 21 multi-agent skills
- All validators pass

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 22
- Lines changed: ~44

#### Risk assessment:

- **Low risk.** Additive amendment. Extends existing documentation principle to include checkpoint logging.

---

### Operation 6: Law 10 — Work in Reversible Steps

**Implementation approach**: A (NEW ENGINEERING PRINCIPLE) **Applicability**: BUILDING (6 skills) **Current
compliance**: 0 COMPLIANT, 6 PARTIAL, 0 NON-COMPLIANT (18 N/A) **Skills affected**: 14 engineering skills (via sync into
`engineering-principles` block)

#### Changes required:

1. Add new IMPORTANT principle to `plugins/conclave/shared/principles.md` in the `engineering-principles` block:
   ```
   N. **Work in reversible steps.** Every implementation step must leave the codebase in a
      committable, test-passing state. If a step fails or is interrupted, the prior state must be
      recoverable via git. Commit after each meaningful unit of work. Never leave the codebase in
      a broken intermediate state.
   ```
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-5 complete

#### Postconditions:

- New engineering principle in all 14 engineering SKILL.md files
- Non-engineering skills unaffected
- All validators pass

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 15 (1 shared + 14 engineering SKILL.md)
- Lines changed: ~50

#### Risk assessment:

- **Low risk.** Additive. Engineering-only injection means non-engineering skills untouched.
- Complements existing TDD principle (#5) — TDD ensures correctness per step, this ensures recoverability.

---

### Operation 7: Law 12 — Every Phase Needs an Adversary

**Implementation approach**: B (AMENDMENT to Principle #1) **Applicability**: MULTI-AGENT (21 skills) **Current
compliance**: 15 COMPLIANT, 6 PARTIAL, 0 NON-COMPLIANT **Skills affected**: All 21 multi-agent skills (via sync)

#### Changes required:

1. Amend Principle #1 in `plugins/conclave/shared/principles.md`:
   - **Current**:
     `"No agent proceeds past planning without Skeptic sign-off. The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked."`
   - **New**:
     `"No agent proceeds past planning without Skeptic sign-off. The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked. Every phase that produces a deliverable must have an adversarial review — either a dedicated Skeptic or Lead-as-Skeptic for lower-stakes phases."`
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-6 complete

#### Postconditions:

- Amended Principle #1 codifies the adversary-per-phase requirement
- Lead-as-Skeptic acknowledged as valid for lower-stakes phases (research-market, ideate-product, manage-roadmap)
- All validators pass

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 22
- Lines changed: ~44

#### Risk assessment:

- **Low risk.** Codifies existing practice. Lead-as-Skeptic is acknowledged rather than deprecated.
- The 6 PARTIAL skills (research-market, ideate-product, manage-roadmap, run-task simple/medium, plan-product default)
  continue using Lead-as-Skeptic. This is a deliberate design choice, not a gap.

---

### Operation 8: Law 05 — Interrogate Before You Iterate

**Implementation approach**: B (AMENDMENT to Principle #1) + C (SKILL-SPECIFIC for building skills) **Applicability**:
MULTI-AGENT (21 skills) **Current compliance**: 0 COMPLIANT, 21 PARTIAL, 0 NON-COMPLIANT (3 N/A) **Skills affected**:
All 21 multi-agent (shared amendment); 6 building skills (skill-specific gates)

#### Changes required:

**Part A — Shared amendment** (propagates via sync):

1. Add a sentence to Principle #1 (already amended in Operation 7):
   - Append:
     `"Before building, agents must validate that their input specification is complete and unambiguous — surface gaps to the lead before proceeding."`
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

**Part B — Skill-specific gates** (per-skill spawn prompt edits): 4. For each building skill, add an explicit "Validate
Inputs" instruction to the first implementation agent's spawn prompt:

- `build-implementation`: Add to backend-eng and frontend-eng prompts: "Before writing code, review the implementation
  plan and spec for completeness. If any requirement is ambiguous or any dependency is unresolved, message the lead with
  the specific gap before proceeding."
- `build-product`: Same pattern for implementation agents.
- `craft-laravel`: Already partially satisfied (Phase 1 Reconnaissance). Add explicit requirement to validate commission
  completeness.
- `squash-bugs`: Already partially satisfied (hypothesis elimination). Add explicit requirement to validate defect
  statement completeness.
- `refine-code`: Already partially satisfied (Surveyor audit). Add explicit requirement to validate scope definition
  completeness.
- `run-task`: Add to dynamic agent prompts: "Before executing, confirm you understand the full scope. If anything is
  unclear, message the lead."

#### Preconditions:

- Operation 7 complete (Principle #1 already amended)

#### Postconditions:

- Shared principle covers general interrogation requirement
- Building skills have explicit pre-implementation validation gates
- All validators pass

#### Rollback boundary:

- Part A: revert shared content commit
- Part B: revert skill-specific commits (one per skill, or batched)

#### Estimated scope:

- Files modified: 28 (22 via sync + 6 skill-specific edits)
- Lines changed: ~120

#### Risk assessment:

- **Medium risk.** Part A is low-risk (shared content). Part B modifies spawn prompts — must not break A3 validator
  (Name + Model fields). Test each skill edit individually.
- Agent behavior impact: implementation agents may surface more pre-build questions. This is desired.

---

### Operation 9: Law 16 — The Human Is the Architect

**Implementation approach**: A (NEW SHARED PRINCIPLE) + C (SKILL-SPECIFIC) **Applicability**: ALL (but primarily 13
applicable skills) **Current compliance**: 0 COMPLIANT, 12 PARTIAL, 1 NON-COMPLIANT, 11 N/A **Skills affected**: All 21
multi-agent (new principle via sync); architecture-producing skills need specific gates

#### ⚠️ DESIGN DECISION REQUIRED (see Section 5)

#### Changes required:

**Part A — New shared principle** (propagates via sync):

1. Add new CRITICAL principle to `plugins/conclave/shared/principles.md` in `universal-principles` block:
   ```
   N. **The human is the architect.** System architecture, data models, API contracts, and security
      boundaries must be defined or explicitly approved by a human before implementation agents are
      deployed. Agents produce architectural proposals for human review — they do not make final
      architectural decisions autonomously.
   ```
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

**Part B — Skill-specific gates** (requires human design decision): 4. Determine which skills need explicit human
approval gates and where. Candidates:

- `write-spec`: Add human approval gate between spec production and downstream consumption
- `plan-implementation`: Add human approval gate before build-implementation consumes the plan
- `plan-product`: Complexity checkpoint already presents to user — may be sufficient
- `build-product`: Validate that input spec was human-approved (trust chain)
- `run-task`: Add human approval for any architectural decisions (highest risk skill)

#### Preconditions:

- Operations 1-8 complete
- Human design decision on which skills need explicit gates (see Section 5)

#### Postconditions:

- Human authority principle in all 21 multi-agent skills
- Selected skills have explicit human approval gates

#### Rollback boundary:

- Part A: revert shared content commit
- Part B: revert skill-specific commits

#### Estimated scope:

- Part A: 22 files, ~70 lines
- Part B: 3-5 files, ~50 lines (depends on design decision)

#### Risk assessment:

- **Medium-high risk.** Part A is safe. Part B changes workflow — adding human gates to previously automated pipelines
  may break the user experience if not carefully placed.
- Must not add gates that make skills unusable in fully-automated contexts.

---

### Operation 10: Law 14 — Humans Validate Tests

**Implementation approach**: A (NEW ENGINEERING PRINCIPLE) + C (SKILL-SPECIFIC) **Applicability**: BUILDING (6 skills)
**Current compliance**: 0 COMPLIANT, 0 PARTIAL, 6 NON-COMPLIANT (18 N/A) **Skills affected**: 6 building skills

#### ⚠️ DESIGN DECISION REQUIRED (see Section 5)

#### Changes required:

**Part A — New engineering principle**:

1. Add to `plugins/conclave/shared/principles.md` in `engineering-principles` block:
   ```
   N. **Humans validate tests.** Test assertions for critical paths must be flagged for human review.
      After writing tests, notify the user with a summary of what is being tested and what assertions
      were chosen. Do not consider the implementation complete until the user has acknowledged the
      test strategy.
   ```
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

**Part B — Skill-specific gates**: 4. For each building skill, add a test review notification to the test-producing
agent:

- `build-implementation`: QA agent notifies user with test summary before marking complete
- `build-product`: Same
- `craft-laravel`: Convention Warden includes test review in final gate
- `squash-bugs`: Warden notifies user with regression test summary
- `refine-code`: Artisan notifies user with behavioral preservation test summary
- `run-task`: Dynamic — if tests written, notify user

#### Preconditions:

- Operation 9 complete (Law 16 establishes human authority principle)
- Human design decision on gate strength (see Section 5)

#### Postconditions:

- Human test review principle in all 14 engineering skills
- Building skills actively notify users about test assertions

#### Rollback boundary:

- Revert shared content + skill-specific commits

#### Estimated scope:

- Part A: 15 files, ~50 lines
- Part B: 6 files, ~60 lines

#### Risk assessment:

- **Medium risk.** Adds a notification step, not a blocking gate. This is a deliberate choice — a blocking gate would
  prevent automated pipelines. A notification ensures human awareness without halting execution.
- Design choice: "notify and flag" vs. "block until approved" — recommend notify-and-flag to preserve pipeline
  automation.

---

### Operation 11: Law 01 — Strip Rationales Before Review

**Implementation approach**: C (SKILL-SPECIFIC) **Applicability**: MULTI-AGENT (21 skills, but with exemptions)
**Current compliance**: 0 COMPLIANT, 0 PARTIAL, 21 NON-COMPLIANT **Skills affected**: Selective — see exemption list
below

#### ⚠️ DESIGN DECISION REQUIRED (see Section 5)

#### Changes required:

**Exempt skills** (rationale stripping would degrade review quality):

- `harden-security`: Toulmin warrant is integral to security review chain
- `squash-bugs`: Hypothesis elimination matrix IS the deliverable
- `draft-investor-update`: Drafter Notes enable skeptics to challenge framing
- `plan-hiring`: Structured debate tensions are core output
- `unearth-specification`: Clustering rationale is part of the archaeological record

**Apply stripping** (code/artifact review benefits from blind review):

- `build-implementation`: Add to agents submitting work for skeptic review: "When submitting code for review, include
  the code and test results only. Do not include explanations of why you made specific choices — let the code speak for
  itself."
- `build-product`: Same pattern
- `craft-laravel`: Add stripping instruction before Convention Warden review
- `review-pr`: Already reviews code without author rationale (PR description is metadata, not inline rationale) — may
  already be effectively compliant
- `write-spec`: Add stripping instruction before spec-skeptic review
- `plan-implementation`: Add stripping instruction before plan-skeptic review
- `refine-code`: Add stripping instruction before refine-skeptic review

**Partial stripping** (submit deliverable + summary, not reasoning chain):

- `create-conclave-team`, `review-quality`, `run-task`, `plan-product`: Strip detailed reasoning from review
  submissions, retain deliverable structure
- `research-market`, `ideate-product`, `manage-roadmap`, `write-stories`, `plan-sales`: Lead-as-Skeptic skills —
  stripping less critical but apply where practical

#### Preconditions:

- Operation 7 complete (adversary pattern codified)
- Human design decision on exemption list (see Section 5)

#### Postconditions:

- Non-exempt skills include rationale stripping instructions in review submission flows
- Exempt skills documented as intentional exceptions
- All validators pass

#### Rollback boundary:

- Revert skill-specific commits (per-skill or batched)

#### Estimated scope:

- Files modified: ~16 skills
- Lines changed: ~160 (2-4 lines per affected spawn prompt per skill)

#### Risk assessment:

- **Medium risk.** Modifies spawn prompts. Must not break A3 validator.
- Behavioral risk: overly aggressive stripping could cause skeptics to request more context, increasing rejection
  cycles. Start with code-review skills where the benefit is clearest.

---

### Operation 12: Law 08 — Scripts Handle Determinism

**Implementation approach**: E (ARCHITECTURAL — document only) **Applicability**: ALL (24 skills) **Current
compliance**: 0 COMPLIANT, 24 PARTIAL **Skills affected**: None (documentation only)

#### Changes required:

1. Add a note to `plugins/conclave/shared/principles.md` as a comment or a NICE-TO-HAVE principle:
   ```
   N. **Prefer tooling for deterministic steps.** When a task is deterministic (file existence checks,
      test execution, linting, validation), use bash tools or scripts rather than reasoning through
      the answer. Reserve model reasoning for judgment calls, creative work, and ambiguous situations.
   ```
2. Run `bash scripts/sync-shared-content.sh`
3. Run `bash scripts/validate.sh`

#### Preconditions:

- Operations 1-11 complete

#### Postconditions:

- Guidance principle in all multi-agent skills
- No behavioral gates or structural changes

#### Rollback boundary:

- Revert the single commit

#### Estimated scope:

- Files modified: 22
- Lines changed: ~70

#### Risk assessment:

- **Very low risk.** Advisory principle. No enforcement mechanism. Acknowledges platform constraint while pointing in
  the right direction.

---

### Operation 13: Law 06 — Spec Before You Build (NO-CHANGE)

**Implementation approach**: E (NO-CHANGE) **Current compliance**: 5/6 COMPLIANT, 1 PARTIAL (run-task)

#### Action: None required.

- 83% compliant. run-task's dynamic nature makes formal spec impractical.
- run-task's existing behavior (lead reports plan to user before spawning) is acceptable.
- Document in this plan as intentionally accepted.

---

### Operation 14: Law 07 — Subagents Isolate Context (NO-CHANGE)

**Implementation approach**: E (NO-CHANGE) **Current compliance**: 21/21 COMPLIANT (100%)

#### Action: None required.

---

### Operation 15: Law 11 — Match the Agent to the Task (NO-CHANGE)

**Implementation approach**: E (NO-CHANGE) **Current compliance**: 21/21 COMPLIANT (100%)

#### Action: None required.

- Note: squash-bugs has an internal inconsistency (warden listed as opus in teammate table, Sonnet in spawn prompt).
  Spawn prompt is authoritative. The Artisan may fix this cosmetic inconsistency during execution if convenient.

---

### Operation 16: Law 13 — Follow the Testing Pyramid (NO-CHANGE)

**Implementation approach**: E (NO-CHANGE) **Current compliance**: 5/6 COMPLIANT, 1 PARTIAL (run-task)

#### Action: None required.

- Well-covered by Engineering Principles #5 and #7. run-task's dynamic nature is an acceptable gap.

---

## 4. Execution Order Summary

### Tier 1 — Foundation (Shared Content Changes)

Operations that edit `plugins/conclave/shared/principles.md` and propagate via sync. Each operation is one commit, one
sync, one validate.

| Order | Operation | Law                         | Type                       | Why This Order                                                                 |
| ----- | --------- | --------------------------- | -------------------------- | ------------------------------------------------------------------------------ |
| 1     | Op 1      | Law 04: No Secrets          | NEW CRITICAL principle     | Zero coverage, universal, no dependencies. Safety-critical — do first.         |
| 2     | Op 2      | Law 03: Scope Is Contract   | NEW CRITICAL principle     | Zero coverage, universal. Foundation for Law 02 (halt requires knowing scope). |
| 3     | Op 3      | Law 02: Halt on Ambiguity   | AMEND Principle #3         | Depends on Law 03 (scope). Strengthens existing principle.                     |
| 4     | Op 4      | Law 09: State Travels       | AMEND Principle #2         | Independent. Minor. 95% already compliant.                                     |
| 5     | Op 5      | Law 15: Log Decisions       | AMEND Principle #9         | Independent. Extends documentation principle.                                  |
| 6     | Op 6      | Law 10: Reversible Steps    | NEW ENG principle          | Independent. Engineering-only.                                                 |
| 7     | Op 7      | Law 12: Adversary Per Phase | AMEND Principle #1         | Independent. Codifies existing pattern.                                        |
| 8     | Op 12     | Law 08: Scripts/Determinism | NEW NICE-TO-HAVE principle | Independent. Advisory only. Low priority.                                      |

**After Tier 1**: 8 operations complete. All shared content changes done. Sync propagated. All 21 multi-agent skills
updated with 4 new principles and 4 amended principles.

### Tier 2 — Hardening (Skill-Specific Enforcement)

Operations that modify individual SKILL.md spawn prompts or gates. Each operation touches specific skills.

| Order | Operation | Law                                | Type                      | Why This Order                                                 |
| ----- | --------- | ---------------------------------- | ------------------------- | -------------------------------------------------------------- |
| 9     | Op 8      | Law 05: Interrogate Before Iterate | AMEND #1 + per-skill      | Depends on Tier 1 amendments to Principle #1.                  |
| 10    | Op 11     | Law 01: Strip Rationales           | Per-skill with exemptions | Depends on Op 7 (adversary pattern). Requires design decision. |

### Tier 3 — Architectural (Human Design Decisions Needed)

Operations that add human gates to previously automated pipelines. Cannot proceed without human operator decisions.

| Order | Operation | Law                           | Type                     | Why This Order                                         |
| ----- | --------- | ----------------------------- | ------------------------ | ------------------------------------------------------ |
| 11    | Op 9      | Law 16: Human Is Architect    | NEW CRITICAL + per-skill | Requires decision on which skills get human gates.     |
| 12    | Op 10     | Law 14: Humans Validate Tests | NEW ENG + per-skill      | Depends on Law 16. Requires decision on gate strength. |

### No-Change (Documented)

| Law                         | Status         | Action |
| --------------------------- | -------------- | ------ |
| Law 06: Spec Before Build   | 83% compliant  | None   |
| Law 07: Subagents Isolate   | 100% compliant | None   |
| Law 11: Match Agent to Task | 100% compliant | None   |
| Law 13: Testing Pyramid     | 83% compliant  | None   |

---

## 5. Design Decisions Required

The following decisions must be made by the human operator before the Artisan can execute the corresponding operations.
The Artisan should not proceed with these operations until answers are provided.

### Decision 1: Law 01 — Rationale Stripping Exemptions

**Question**: Which skills should be exempt from rationale stripping?

**Recommended exemptions** (rationale IS the deliverable or is essential to review quality):

- `harden-security` — Toulmin warrant is the logical chain
- `squash-bugs` — hypothesis elimination matrix is the deliverable
- `draft-investor-update` — Drafter Notes enable framing challenges
- `plan-hiring` — debate tensions are core output
- `unearth-specification` — archaeological rationale is part of the record

**Apply stripping to**: `build-implementation`, `build-product`, `craft-laravel`, `write-spec`, `plan-implementation`,
`refine-code`, `review-pr`

**Partial stripping for**: remaining multi-agent skills (Lead-as-Skeptic skills, create-conclave-team, review-quality,
run-task, plan-product)

**Decision needed**: Accept recommended exemption list, or modify?

### Decision 2: Law 14 — Human Test Validation Gate Strength

**Question**: Should human test review be a **blocking gate** (pipeline halts until human approves tests) or a
**notification** (pipeline continues, user is flagged for review)?

**Recommendation**: Notification (non-blocking). Rationale: blocking gates would break automated pipeline use cases. The
notification ensures human awareness without halting execution. Users who want blocking behavior can invoke skills
interactively.

**Decision needed**: Blocking gate or notification?

### Decision 3: Law 16 — Human Architecture Approval Scope

**Question**: Which skills need an explicit human approval gate for architecture, and where in the pipeline should it
go?

**Options**:

- **Option A (Minimal)**: Add advisory language only (the new shared principle). Trust that users invoke planning skills
  interactively and review outputs. No structural gates.
- **Option B (Targeted)**: Add a human checkpoint to `plan-product` (already has complexity checkpoint), `write-spec`,
  and `plan-implementation`. These are the architecture-producing skills. Building skills trust that their input was
  human-reviewed.
- **Option C (Comprehensive)**: Add human approval gates to all architecture-producing and architecture-consuming
  skills. Maximum safety, maximum friction.

**Recommendation**: Option B (Targeted). The planning skills produce architecture; the building skills consume it. Gate
the producers, trust the consumers.

**Decision needed**: Option A, B, or C?

---

## Validation Strategy

After each operation:

1. `bash scripts/sync-shared-content.sh` (if shared content changed)
2. `bash scripts/validate.sh` — all 12 validators must pass
3. Visual inspection of one representative skill to confirm injection
4. Git commit with descriptive message referencing the law number

After all operations:

1. Full validator run
2. Diff review of `plugins/conclave/shared/principles.md` — final state should contain all new/amended principles
3. Spot-check 3 engineering + 3 non-engineering skills for correct block injection
4. Verify sync script still handles skeptic name substitution correctly

---

## Appendix: Principle Numbering Plan

Current principles.md numbering: 1, 2, 3 (CRITICAL) | 9, 10 (ESSENTIAL) | 11, 12 (NICE-TO-HAVE) | 4, 5, 6, 7
(ENGINEERING IMPORTANT) | 8 (ENGINEERING ESSENTIAL)

Note: numbering is non-sequential (gaps exist: 4-8 are engineering, 9-12 are universal). New principles should be
inserted at the end of their tier within the appropriate block.

**Proposed new principle slots**:

Universal CRITICAL (after current #3):

- New #13: No secrets in context (Law 04)
- New #14: Scope is a contract (Law 03)
- New #15: The human is the architect (Law 16)

Universal ESSENTIAL (after current #10):

- (No new principles in this tier)

Universal NICE-TO-HAVE (after current #12):

- New #16: Prefer tooling for deterministic steps (Law 08)

Engineering IMPORTANT (after current #7):

- New #17: Work in reversible steps (Law 10)
- New #18: Humans validate tests (Law 14)

Note: exact numbering to be finalized by the Artisan based on readability. The numbers are reference IDs, not priority
ranks — the tier headings (CRITICAL/ESSENTIAL/NICE-TO-HAVE/IMPORTANT) convey priority.
