---
feature: "review-cycle-2"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Reviewed researcher and architect findings; APPROVED P3-02 recommendation with conditions"
updated: "2026-02-18"
---

# Product Skeptic Review Cycle 2: Post-P2-03 Feature Selection

## Verdict: APPROVED (with conditions)

Both the researcher and architect recommend P3-02 (Onboarding Wizard) as the next feature to spec. After independent verification of their claims against the codebase, roadmap, and ADR-002, I concur that P3-02 is the correct next item. However, I have specific conditions and one significant disagreement on the secondary recommendation.

---

## Evaluation Against Review Criteria

### 1. Is the recommendation evidence-based or just opinion?

**YES -- both assessments are well-grounded in codebase evidence.**

Verified claims:
- P2-02 showstopper (skill-to-skill invocation): Both agents cite this. I verified the SKILL.md files -- skills are invoked by user slash commands. No mechanism exists for programmatic chaining. This is a real blocker, not speculation.
- P2-07 prematurity per ADR-002: Verified. ADR-002 explicitly states "When the skill count exceeds 8, revisit this approach." Current count is 3. The 8-skill trigger is real and documented.
- P2-08 deferral: Verified. The _index.md explicitly says "Defer plugin organization until 2+ business skills are built and validated." Zero business skills exist.
- P3-02 roadmap file: Verified. It exists at `docs/roadmap/P3-02-onboarding-wizard.md` with problem statement, proposed solution, and success criteria. Other P3 items (P3-04 through P3-22) have no roadmap files -- confirmed via filesystem.
- Only 3 P3 roadmap files exist (P3-01, P3-02, P3-03): Verified.
- Business skill design guidelines exist: Verified at `docs/architecture/business-skill-design-guidelines.md`.

**One unverified claim**: The architect states P3-02 "would be the first single-agent skill" and calls this "architecturally significant." This is true (all 3 existing skills spawn multi-agent teams), but the significance is overstated. A single-agent skill is a simpler case of the existing pattern -- it is a SKILL.md without team spawning, not a new architectural paradigm. The business-skill design guidelines document already implicitly supports non-team patterns. This is an observation, not a reason to build or not build P3-02.

### 2. Is the recommended feature genuinely highest value, or just easiest?

**P3-02 is both easiest AND high value, but the "high value" claim needs qualification.**

The researcher says P3-02 "reduces the #1 adoption barrier." The architect says it "directly reduces onboarding friction that is the primary barrier to new user adoption." Neither agent provides evidence that onboarding friction is actually the #1 adoption barrier. There is no user feedback mechanism (the researcher correctly flags this as Gap 3 in their report). This is an inference, not a fact.

That said, the inference is reasonable. The P3-02 roadmap item itself describes the problem: "New users must read the README, understand the three skills, set environment variables, and figure out the plan -> build -> review workflow." This is a real friction point even if we cannot quantify it as "#1."

**The more interesting question is whether P3-02 is highest value or just safest.** The researcher raises this tension explicitly in their Risk #4: "P3-02 is useful but doesn't advance the P2-07/P2-08 prerequisites." A business skill pathfinder would have higher strategic value because it unblocks two deferred P2 items and validates the business-skill design guidelines. P3-02 is a dead-end in terms of strategic sequencing -- it doesn't teach us anything about multi-domain expansion.

However, I accept the sequencing argument: P3-02 is Small effort, zero risk, and can be completed in one cycle. A business skill is Medium effort with unknown risks (first business skill, untested design guidelines). Doing the safe small thing first, then the riskier medium thing, is sound prioritization. The key condition is that the team MUST NOT treat P3-02 as an excuse to further delay business skills.

### 3. Are risks adequately identified?

**YES for P3-02. PARTIALLY for the secondary recommendations.**

P3-02 risks are minimal and well-documented by both agents: idempotency requirement (straightforward), no dependencies, no architectural novelty. I agree with the near-zero risk assessment.

The researcher identifies a risk I want to emphasize: **"Scope of 'next item' is ambiguous"** (Risk #3). The project has always followed P1 -> P2 -> P3 priority ordering. Starting a P3 item while P2 items remain (even if blocked) sets a precedent. The researcher says this "may be fine" but should be "explicit." I agree. The decision to skip blocked P2 items in favor of unblocked P3 items must be stated as a policy, not treated as an exception.

### 4. Is the priority ordering justified?

**PARTIALLY. The primary recommendation is justified. The secondary recommendations diverge and neither is fully justified.**

**Where the agents agree**: P3-02 first. Remaining P2 items deferred. Both provide consistent reasoning.

**Where the agents disagree**: The secondary recommendation.
- Researcher recommends P3-10 /plan-sales (Collaborative Analysis pattern, "plan-*" skill closest to existing plan-product)
- Architect recommends P3-22 /draft-investor-update (Pipeline pattern, simplest output structure, self-dogfooding potential)

This disagreement is significant because it affects how we validate the business-skill design guidelines. The researcher's logic is "pick the closest to what we already have" (plan-sales is a plan-* skill using Collaborative Analysis). The architect's logic is "pick the simplest output" (investor update has a well-defined structure and primarily reads existing project data).

**My assessment**: The architect's P3-22 argument is stronger on one dimension -- output verifiability. An investor update has a constrained, well-known format. Sales plans are fuzzier. However, the researcher's P3-10 argument is stronger on the strategic dimension -- Collaborative Analysis is the most common pattern among business skills (used by 4 skills), so validating it first has more leverage than validating Pipeline (used by 4 skills but architecturally closer to what we already do).

This disagreement does not need resolution now. P3-02 comes first regardless. The team can revisit the business skill pathfinder question after P3-02 is complete.

### 5. Are there blind spots the team is missing?

**YES. Two blind spots.**

**Blind spot 1: P3-02 scope is underspecified and risks scope creep.**

The P3-02 roadmap item says the skill should "detect the project's tech stack," "create the docs/ directory structure," "generate starter docs/roadmap/_index.md with project-specific categories," "write a CLAUDE.md with project conventions," and "explain the workflow and next steps."

That last bullet -- "explain the workflow and next steps" -- is vague. What does it mean? Write a markdown guide? Output instructions to the user? Generate a tutorial? The spec must tightly scope this or it will balloon. The first four bullets are concrete file operations. The fifth is open-ended.

Additionally, "generate starter docs/roadmap/_index.md with project-specific categories" implies the skill needs to understand the project well enough to create meaningful categories. This requires non-trivial intelligence from a single agent -- scanning the codebase, inferring domain categories, generating a relevant roadmap structure. This is NOT a trivial setup utility if done well. The spec must decide: is this a templated scaffold (fast, dumb, good enough) or an intelligent setup (slow, smart, scope risk)?

**Blind spot 2: The roadmap data integrity issue is being carried forward without a fix again.**

Both agents flag the missing roadmap files for P2-07, P2-08, and P3-04 through P3-22. This was flagged in Cycle 1. It remains unfixed. The researcher recommends creating stubs as a "cleanup task." The architect does not address it. This is now two review cycles where the team identifies the problem and proposes a non-specific fix. If it matters, assign it. If it does not matter, stop flagging it.

---

## Conditions for Approval

1. **The spec for P3-02 must tightly scope "explain the workflow and next steps."** No open-ended tutorial generation. Define exactly what artifact this produces and how.

2. **The spec must explicitly decide: templated scaffold or intelligent setup.** If P3-02 is truly Small effort, it should be a templated scaffold with sensible defaults. If it attempts intelligent stack analysis with project-specific roadmap generation, the effort estimate is wrong and should be Medium.

3. **The team must explicitly state the precedent**: blocked P2 items do not block progress on unblocked P3 items. This is a prioritization policy, not a one-time exception.

4. **The secondary recommendation (business skill pathfinder) must be resolved before or during the P3-02 spec cycle**, not deferred again. The team should exit this cycle knowing whether P3-10 or P3-22 (or something else) comes after P3-02. Both agents made arguments; the spec cycle should produce a decision.

5. **The roadmap data integrity issue must be assigned or explicitly deprioritized.** No more cycles of "this is a problem, someone should fix it." Either create the stub files as part of P3-02 housekeeping, or state in writing that missing roadmap files for unstarted items are acceptable and stop flagging them.

---

## Summary

| Criterion | Assessment |
|-----------|------------|
| Evidence-based | Yes -- both agents verified claims against codebase |
| Highest value vs. easiest | P3-02 is both easiest and high value, though highest strategic value is a business skill |
| Risks identified | Yes for P3-02, partially for secondary |
| Priority ordering justified | Primary yes, secondary disagreement unresolved |
| Blind spots | P3-02 scope underspecified; roadmap data integrity still unfixed |

**APPROVED**: P3-02 Onboarding Wizard as next spec cycle, subject to the 5 conditions above.
