---
feature: "conclave-plugin-improvements"
team: "research-market"
agent: "research-director"
phase: "review"
status: "complete"
last_action:
  "Lead-as-Skeptic review complete. Corrections and confirmations documented.
  Ready for synthesis."
updated: "2026-03-10T00:00:00Z"
---

## Lead-as-Skeptic Review: Conclave Plugin Architecture Research

Reviewed by: Eldara Voss (Research Director) Sources: market-researcher
checkpoint, customer-researcher checkpoint, direct file verification

---

## VERDICT: CONDITIONALLY APPROVED

Both researchers produced substantive findings with high evidence quality.
Several corrections needed before synthesis. No findings fabricated. No blocking
issues.

---

## Corrections Required Before Synthesis

### C1: Persona count discrepancy

- market-researcher: 46 personas
- customer-researcher: 45 personas
- Verified: `Glob` returns 46 files. CORRECT count is 46.
- Action: Use 46 in synthesis.

### C2: B2 normalizer finding overstated

- market-researcher flagged "should be confirmed passing" for bias-skeptic and
  fit-skeptic
- Verified: The normalizer DOES include both `bias-skeptic/Bias Skeptic` and
  `fit-skeptic/Fit Skeptic`
- This is NOT a gap. It is handled correctly.
- Action: Remove from gap list in synthesis. Do not list as a concern.

### C3: Skill naming inconsistency claim overstated

- customer-researcher described "two inconsistent naming patterns: verb-noun vs
  noun-verb"
- Verified: ALL 18 skill names follow verb-noun (research-market, plan-product,
  build-implementation, etc.)
- The real inconsistency is specificity variation within the verb-noun pattern:
  "build-product" (abstract) vs "build-implementation" (specific). This is a
  weaker observation.
- Action: Reframe as "specificity variation within consistent verb-noun pattern"
  rather than "two inconsistent patterns."

### C4: P3 not-started count incorrect

- customer-researcher: "12 unstubbed business skills"
- Verified: P3 has 15 not-started items total. Of those, 9 are business-skills
  category, 5 are new-skills (engineering), 1 is documentation.
- The "12" figure is wrong. The "business skills only" framing misses the
  engineering skill gap.
- Action: Correct to "15 not-started P3 items: 9 business-skills, 5 engineering
  new-skills, 1 documentation."

---

## Confirmed Valid Findings (no challenge)

### From market-researcher:

- tier1-test dual `tier: 1` + `type: single-agent` declaration: CONFIRMED GAP
- Shared Principles engineering rules in non-engineering skills: CONFIRMED
  DESIGN SMELL
- Validators do not check spawn prompt content: CONFIRMED GAP
- Validators do not check persona file existence: CONFIRMED GAP
- No ADR for persona system: CONFIRMED MISSING
- No ADR for run-task design: CONFIRMED MISSING
- PoC skills in production directory: CONFIRMED USER CONFUSION VECTOR
- manage-roadmap single-agent team: CONFIRMED LEAN (by design per ADR-004,
  Lead-as-Skeptic compensates)
- wizard-guide has no checkpoint/resume: CONFIRMED (by design — conversational
  only)

### From customer-researcher:

- Fantasy names not surfaced in spawn prompts: CONFIRMED
- wizard-guide omits business skills from Skill Ecosystem Overview: CONFIRMED
  GAP
- Cross-references accurate in sampled personas: CONFIRMED

---

## Additional Findings from Skeptic Review (not in either researcher's report)

### S1: P3 engineering skills gap is as significant as business skills gap

5 not-started engineering skills: triage-incident, review-debt, design-api,
plan-migration, custom-agent-roles. These represent substantial gaps in the
plugin's engineering utility surface. The customer-researcher's focus on
business skills missed this.

### S2: wizard-guide Skill Ecosystem Overview omission has a compounding effect

Business skills are excluded from the Overview AND the example workflows. A new
user following wizard-guide would never discover /draft-investor-update,
/plan-sales, or /plan-hiring. These three skills are fully implemented but
invisible to guided users.

### S3: manage-roadmap is the only Tier 1 planning skill without artifact detection via Tier 2

In the plan-product pipeline, manage-roadmap's "skip" detection is based on
"Roadmap items already exist for this topic" — a weaker check than the
type/feature/status frontmatter checks used for other stages. This is a
potential false-skip risk where existing roadmap items from a different topic
could satisfy the check.

### S4: run-task has no dedicated persona for its dynamic agents

The Engineer Template, Researcher Template, and Skeptic Template in
run-task/SKILL.md are generic placeholders with `{Customize based on...}`
instructions. No persona files are assigned. The team coordinator reads
task-coordinator.md but the spawned agents have no persona grounding. This is
the only skill where the persona system breaks down.

---

## Summary for Synthesis

ARCHITECTURE STATUS: Mature, consistent, production-ready structural foundation.

TOP GAPS (actionable):

1. wizard-guide omits business skills — easy fix, high user impact
2. PoC skills in production directory — should be hidden or removed
3. Validators don't check persona file references — medium effort, prevents
   silent degradation
4. Shared Principles have implementation-phase bias — low urgency but a design
   debt
5. tier1-test dual-field inconsistency — trivial fix
6. No ADR for persona system — documentation gap, low urgency

TOP STRENGTHS:

1. Skeptic gate coverage: 100% of multi-agent skills have skeptic gates
2. Structural validator coverage: comprehensive for what they check
3. Shared content system: well-engineered, drift-proof
4. Tier 2 artifact detection: feature-scoped, type-validated, staleness-aware
5. Persona consistency: 46 personas all follow identical structure
