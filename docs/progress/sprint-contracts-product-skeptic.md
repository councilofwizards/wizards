---
feature: "sprint-contracts"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Spec review — REJECTED with 1 required fix, 2 advisory notes"
updated: "2026-03-27T15:00:00Z"
---

# Product Skeptic Review: P2-11 Sprint Contracts

**Reviewer**: Wren Cinderglass, Siege Inspector

---

## Spec Review — Round 2 Verdict: APPROVED

All fixes from Round 1 addressed:

- RF-1: Section 4c rewritten — contract negotiation now at step 3, before
  plan-skeptic review gate. Matches Section 2b ordering.
- AN-1: Section 3c now includes explicit prompt assembly order (guidance →
  contract → role prompt).
- AN-2: Section 4c notes signed-by names vary by context with explanatory
  paragraph.

No new issues. Spec is internally consistent and complete against approved
stories.

---

## Spec Review — Round 1 Verdict (historical): REJECTED — 1 required fix, 2 advisory notes

### Required Fix

**RF-1: Section 4c places contract negotiation AFTER plan approval — contradicts
Section 2b and Story 2 AC 4**

In plan-implementation (Section 2b), the contract negotiation is step 3 — AFTER
impl-architect produces the plan but BEFORE plan-skeptic reviews it. This is
correct: the contract defines what plan-skeptic evaluates against, so it must
exist before the evaluation.

In build-product (Section 4c), the contract negotiation is step 5b — AFTER
"Iterate until plan-skeptic approves." The plan is already approved. The
contract criteria were never used during plan review. This breaks Story 2 AC 4:
"plan conformance is checked against contract criteria, not only against the
spec."

The whole point of Sprint Contracts is that evaluation happens against
pre-negotiated criteria. If the contract is negotiated after the plan is already
approved, the plan review is still operating on vague spec-level criteria —
exactly the problem P2-11 is designed to solve.

**Fix**: Move Section 4c's contract negotiation to match Section 2b's ordering.
In build-product's Stage 1:

```
1. Share the technical spec, user stories, and ADRs with impl-architect and plan-skeptic
2. Spawn impl-architect to produce the implementation plan
3. **Contract Negotiation** (same protocol as Section 2b)
4. plan-skeptic reviews the plan against the spec AND the sprint contract (GATE)
5. If plan-skeptic rejects, send specific feedback and have impl-architect revise
6. Iterate until plan-skeptic approves
7. Lead-as-Skeptic review
8. Write final plan (with sprint-contract frontmatter link)
9. Report
```

The step "5b after approval" must become step 3, before the plan-skeptic review
gate.

### Advisory Notes

**AN-1: Section 3c injection ordering could be clearer**

Section 3b says "Append to the Quality Skeptic prompt" (evaluation instructions
go at the end of the role prompt). Section 3c says "Inject [contract content]
after any guidance block and before the Quality Skeptic's role prompt." Net
effect: contract data comes before the role prompt, evaluation instructions are
appended to the role prompt. This is workable but the two sections describe
placement from different reference points. Consider adding a single sentence
clarifying the full injection order: guidance → contract content → role prompt
(with evaluation instructions appended).

**AN-2: Section 4c edge case — quality-skeptic as fallback signer changes
signed-by semantics**

When Stage 1 is skipped and plan-skeptic isn't spawned, Section 4c suggests
"plan-skeptic (or quality-skeptic if plan-skeptic is not spawned in Stage 2)"
for contract negotiation. This means `signed-by` would contain
`["implementation-coordinator", "quality-skeptic"]` instead of
`["planning-lead", "plan-skeptic"]`. The template's Signatures section shows
"Planning Lead" and "Plan Skeptic" placeholders. This isn't wrong — the
`signed-by` field is a list, not a fixed schema — but the spec should explicitly
note that signer names vary by skill and execution path, so implementers don't
treat the template placeholders as normative.

---

### What's Strong

- The template design (Section 1) is clean. Including the Amendment Log
  proactively is the right call — zero cost, forward-compatible.
- Section 2b's contract negotiation protocol is tight: propose → review →
  iterate → sign. Resumption guard prevents re-negotiation. Good.
- Section 3b's SPRINT CONTRACT EVALUATION block is well-structured.
  PASS/FAIL/INCONCLUSIVE verdicts with one-sentence rationale give the right
  granularity.
- Section 4b's artifact detection extension is well-integrated —
  SIGNED/UNSIGNED/NOT_FOUND maps cleanly to skip/re-negotiate/negotiate.
- Section 5's validator update is minimal and correct.
- Section 6's defensive reading table is thorough and consistent with
  build-implementation's existing pattern.
- Section 7 correctly defers Story 6 while preserving forward compatibility.
- Success criteria (11 items) cover all roadmap requirements and stories.
- The spec is prompt-only — no application code, no shared content changes.
  Correct scope.

---

## Stories Review — Round 2 Verdict (historical): APPROVED

All 2 required fixes and 3 advisory notes from Round 1 addressed. No new issues
found.

---

## Stories Review — Round 1 Verdict (historical): REJECTED — 2 required fixes, 3 advisory notes

---

## Required Fixes (must address before approval)

### RF-1: Story 1 must include F-series validator update

Story 1 AC 6 says "all 12/12 validators pass," but this is trivially true — the
F-series validator (`scripts/validators/artifact-templates.sh`) only checks
templates in its hardcoded `expected_templates` list. Adding
`sprint-contract.md` to `docs/templates/artifacts/` without adding it to that
list means the template will **never be validated**.

The whole point of P2-11 is contract-based rigor. Shipping an unvalidated
artifact template undermines that premise.

**Fix**: Add a new acceptance criterion to Story 1:

> AC 7: Given the F-series validator's `expected_templates` list in
> `scripts/validators/artifact-templates.sh`, when the sprint contract template
> is created, then `sprint-contract:sprint-contract` is added to the expected
> templates list so the validator checks the template's existence and `type`
> field on every run.

### RF-2: Story 4 title and scope are misleading

The story is titled "build-product **Stage 2** Integration" but AC 1 is about
Stage 1 producing the contract, ACs 3-5 are about artifact detection (which runs
before any stage), and only AC 2 is actually about Stage 2 consumption. The
story spans Stages 1 and 2 plus the detection table.

More critically, AC 1 says Stage 1 produces a contract "via the same negotiation
flow added to plan-implementation." build-product Stage 1 does NOT invoke
plan-implementation — it replicates the logic with its own impl-architect and
plan-skeptic spawns. "Same flow" is ambiguous: does it mean "copy the prompt
changes from Story 2 into build-product's Stage 1" or "invoke
plan-implementation as a sub-skill"? The answer is the former, but the story
must say so explicitly to prevent the implementer from guessing.

**Fix**:

1. Retitle to "build-product Pipeline Integration" (it touches detection + Stage
   1 + Stage 2).
2. Rewrite AC 1 to: "Given build-product's Stage 1 (Implementation Planning),
   when it runs, then the Orchestration Flow includes the same contract
   negotiation step between impl-architect plan production and plan-skeptic
   review — mirroring the prompt changes made to plan-implementation in Story 2
   — producing a signed sprint contract at
   `docs/specs/{feature}/sprint-contract.md`."

---

## Advisory Notes (non-blocking but recommended)

### AN-1: Story 5 should explicitly note P2-13 dependency

Story 5's Notes section says "This is the standard P2-13 override convention —
no new mechanisms needed." But P2-13 is listed as a dependency in the roadmap
and its status needs verification. If P2-13 hasn't landed, the
`.claude/conclave/templates/` convention doesn't exist yet and Story 5 cannot be
implemented.

**Recommendation**: Add a note to Story 5: "This story is blocked until P2-13
(User-Writable Config) establishes the `.claude/conclave/templates/` convention.
If P2-13 is not yet complete, defer this story."

### AN-2: Story 6 extends beyond roadmap scope

The P2-11 roadmap item defines four scope points: artifact template,
plan-implementation step, build-implementation evaluation, build-product
integration, and custom overrides. Contract amendments are not listed. Story 6
introduces an Amendment Log, amendment approval protocol, and mid-implementation
contract modification — none of which appear in the roadmap.

Story 6 is correctly marked "could-have," which mitigates the risk. But the
stories document should explicitly acknowledge this is an extension beyond
P2-11's defined scope, so the spec author knows it's optional and the
implementer doesn't treat it as required.

### AN-3: Story 2 edge case — "max 3 rounds" matches existing protocol but should cross-reference

Story 2's edge case says "max 3 rounds before escalation to human operator (same
deadlock protocol as existing skeptic gates)." This matches
plan-implementation's Failure Recovery section. Good. But the story should
reference the specific section ("per the Failure Recovery > Skeptic deadlock
protocol in plan-implementation") so the implementer doesn't have to hunt for
it.

---

## INVEST Compliance Assessment

| Criterion   | Story 1 | Story 2 | Story 3                  | Story 4                  | Story 5          | Story 6                       |
| ----------- | ------- | ------- | ------------------------ | ------------------------ | ---------------- | ----------------------------- |
| Independent | PASS    | PASS    | Depends on S2 (expected) | Depends on S2 (expected) | Depends on P2-13 | Depends on S1-S3              |
| Negotiable  | PASS    | PASS    | PASS                     | PASS                     | PASS             | PASS                          |
| Valuable    | PASS    | PASS    | PASS                     | PASS                     | PASS             | Marginal — edge case coverage |
| Estimable   | PASS    | PASS    | PASS                     | PASS\*                   | PASS             | PASS                          |
| Small       | PASS    | PASS    | PASS                     | PASS\*                   | PASS             | PASS                          |
| Testable    | PASS    | PASS    | PASS                     | PASS                     | PASS             | PASS                          |

\*Story 4 estimability/size are acceptable but the scope ambiguity (RF-2) makes
it harder to estimate than it should be.

---

## What's Strong

- Stories 1-3 form a tight, well-ordered core. The acceptance criteria are
  specific and testable.
- Graceful degradation is handled consistently: no contract = current behavior,
  no crash, no warning.
- The INCONCLUSIVE verdict in Story 3 (AC 5) is practical and avoids false
  negatives for runtime-only criteria.
- Edge cases are thorough — unsigned contracts, empty criteria, resumption
  scenarios.
- Non-functional requirements section correctly protects backward compatibility
  and validator stability.
- Out of Scope section is clear and prevents creep in the right directions.

---

## Bottom Line

Fix RF-1 and RF-2. The validator gap (RF-1) is the more important of the two —
an unvalidated artifact template in a project whose entire thesis is "contracts
make evaluation rigorous" is an unforced error. RF-2 is about clarity that
prevents implementation mistakes.

Advisory notes are recommendations. Take or leave them, but AN-1 (P2-13
dependency) will bite someone if ignored.
