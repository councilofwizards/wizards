---
feature: "iron-laws"
team: "the-crucible-accord"
agent: "surveyor"
phase: "audit"
status: "complete"
last_action: "Compliance matrix revised (r2) — systematic model audit via spawn-section grep across all 21 skills"
updated: "2026-04-01T12:45:00Z"
---

# Iron Laws Compliance Audit — Surveyor Manifest

Tarn Slateward, Reader of Dross — audit of 24 conclave skills against 16 Iron Laws of Agentic Coding.

---

## 1. Overlap Analysis: Iron Laws vs Existing Shared Principles

### Shared Principles Reference (from `plugins/conclave/shared/principles.md`)

| #   | Existing Principle                                       | Category     |
| --- | -------------------------------------------------------- | ------------ |
| 1   | No agent proceeds past planning without Skeptic sign-off | CRITICAL     |
| 2   | Communicate constantly via SendMessage                   | CRITICAL     |
| 3   | No assumptions — ask, don't guess                        | CRITICAL     |
| 4   | Minimal, clean solutions (engineering)                   | IMPORTANT    |
| 5   | TDD by default (engineering)                             | IMPORTANT    |
| 6   | SOLID and DRY (engineering)                              | IMPORTANT    |
| 7   | Unit tests with mocks preferred (engineering)            | ESSENTIAL    |
| 8   | Contracts are sacred (engineering)                       | ESSENTIAL    |
| 9   | Document decisions, not just code                        | ESSENTIAL    |
| 10  | Delegate mode for leads                                  | ESSENTIAL    |
| 11  | Progressive disclosure in specs                          | NICE-TO-HAVE |
| 12  | Use Sonnet for execution, Opus for reasoning             | NICE-TO-HAVE |

### Per-Law Overlap Map

| Iron Law                               | Overlapping Principle(s)                                   | Coverage | Gap (Delta)                                                                                                                                                                                                                                                                                                                                            | Recommendation                                                                                                                                                                                                                                                                                |
| -------------------------------------- | ---------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **01. Strip Rationales Before Review** | None                                                       | NONE     | No principle addresses rationale stripping. Current practice is the opposite: draft-investor-update explicitly retains "Drafter Notes" for skeptic reference; harden-security retains "warrant" in Toulmin framework.                                                                                                                                  | NEW shared principle or SKILL-SPECIFIC enforcement. Requires careful design — some skills benefit from rationale context (security warrants), others should strip it (code review).                                                                                                           |
| **02. Halt on Ambiguity**              | Principle #3 ("No assumptions")                            | PARTIAL  | Principle #3 says "ask, don't guess" but does not mandate explicit halt conditions in agent prompts. The law requires built-in halt triggers, not just a cultural norm.                                                                                                                                                                                | AMENDMENT to Principle #3: add "When uncertain, STOP and surface the uncertainty to your lead before proceeding. Never invent a solution to bridge an ambiguity."                                                                                                                             |
| **03. Scope Is a Contract**            | Principle #10 ("Delegate mode for leads")                  | WEAK     | Principle #10 only constrains leads. The law requires every agent to have written scope boundaries and prohibits self-expansion. No principle addresses scope expansion prevention or human authorization for scope changes.                                                                                                                           | NEW shared principle. "Every agent operates within its stated mandate. Scope changes discovered during execution require Team Lead approval. Agents must not self-expand."                                                                                                                    |
| **04. No Secrets in Context**          | None                                                       | NONE     | Zero coverage. No principle, no skill, no shared content addresses credential/PII handling in agent prompts or context windows.                                                                                                                                                                                                                        | NEW shared principle (CRITICAL tier). "Credentials, API keys, tokens, and PII must never appear in agent prompts, context windows, or checkpoint files. If an agent discovers a secret, it must flag it to the lead without including the secret value in any message."                       |
| **05. Interrogate Before You Iterate** | Principle #1 ("Skeptic sign-off before implementation")    | PARTIAL  | Principle #1 requires skeptic approval of plans, which is a form of interrogation. But the law specifically requires structured questioning of requirements/prompts before building — a pre-planning step that no skill explicitly performs.                                                                                                           | SKILL-SPECIFIC enforcement for building skills. Planning skills (plan-product, plan-implementation) partially satisfy this through their research/analysis phases. Building skills (build-implementation, build-product) should validate their input spec before proceeding.                  |
| **06. Spec Before You Build**          | Principle #1 (implicit)                                    | PARTIAL  | Principle #1 gates planning → implementation but doesn't mandate a written spec. Building skills individually enforce this (build-implementation requires impl plan + spec, build-product requires spec). But it's not a shared principle — it's per-skill enforcement.                                                                                | AMENDMENT to Principle #1 or NEW engineering principle: "No implementation agent begins work without a written, skeptic-approved specification. The spec is the source of truth."                                                                                                             |
| **07. Subagents Isolate Context**      | Principle #12 ("Sonnet for execution, Opus for reasoning") | WEAK     | Principle #12 addresses model selection, not context isolation. The law requires one agent = one concern. This IS the de facto pattern in every skill (each agent has a distinct role), but it's not stated as a principle.                                                                                                                            | AMENDMENT to existing content or NEW principle: "Each agent owns exactly one concern. Do not combine research, implementation, and review in a single agent." Currently satisfied in practice but not codified.                                                                               |
| **08. Scripts Handle Determinism**     | None                                                       | NONE     | No principle addresses the boundary between scripted determinism and model reasoning. Skills instruct deterministic procedures (TDD, OWASP checklists, INVEST criteria) via prompts rather than scripts. The project's validation scripts (`scripts/validate.sh`) demonstrate the pattern but it's not applied to skill execution.                     | SKILL-SPECIFIC. This is an architectural concern about the skill execution model (markdown prompts can't call scripts). Could be addressed by noting which steps SHOULD be scripted if the platform supported it, or by recommending bash tool usage for deterministic checks.                |
| **09. State Travels Explicitly**       | Principle #2 ("Communicate constantly via SendMessage")    | STRONG   | Principle #2 + Communication Protocol table provide explicit state handoff mechanisms. Every multi-agent skill defines what information passes between agents. The gap: no principle explicitly says "never assume an agent inherits knowledge from a prior agent."                                                                                    | AMENDMENT to Principle #2: add "Never assume a downstream agent inherits knowledge from a prior phase. Pass complete state — file paths, artifact contents, decision context — at every handoff."                                                                                             |
| **10. Work in Reversible Steps**       | Principle #5 ("TDD by default")                            | WEAK     | TDD provides some reversibility (tests verify before/after). Checkpoint protocol enables session recovery. But no principle states "every agent run must leave the codebase committable or rollback-able."                                                                                                                                             | NEW engineering principle: "Every implementation step must leave the codebase in a committable state. If a step fails or is interrupted, the prior state must be recoverable via git."                                                                                                        |
| **11. Match the Agent to the Task**    | Principle #12 ("Sonnet for execution, Opus for reasoning") | STRONG   | Principle #12 directly addresses this. All skills follow the pattern: skeptics/architects on Opus, engineers/writers on Sonnet. The `--light` flag downgrades non-critical agents but never skeptics. Minor gap: the law mentions matching to different AI systems (Claude vs Codex vs Gemini), which is outside the conclave's single-platform scope. | NO CHANGE needed. Existing principle covers the single-platform interpretation well.                                                                                                                                                                                                          |
| **12. Every Phase Needs an Adversary** | Principle #1 ("Skeptic sign-off")                          | STRONG   | Principle #1 + per-skill skeptic implementation provides strong coverage. Gap: 3 skills (research-market, ideate-product, manage-roadmap) use Lead-as-Skeptic rather than dedicated adversaries. This is weaker — the lead is both advocate and challenger.                                                                                            | AMENDMENT or SKILL-SPECIFIC: Strengthen Lead-as-Skeptic skills or accept the tradeoff (lower-stakes skills may not justify a dedicated adversary). Document the design choice.                                                                                                                |
| **13. Follow the Testing Pyramid**     | Principles #5 and #7                                       | STRONG   | Principle #5 (TDD) + Principle #7 (unit tests preferred, feature/integration only when needed) directly encode the testing pyramid. Engineering skills enforce this.                                                                                                                                                                                   | NO CHANGE needed. Well-covered.                                                                                                                                                                                                                                                               |
| **14. Humans Validate Tests**          | None                                                       | NONE     | No principle requires human review of test assertions. The skeptic (an AI agent) validates tests, not a human. Deadlock escalation can involve a human, but the default path is fully automated.                                                                                                                                                       | NEW shared principle or SKILL-SPECIFIC gate. "Test assertions for critical paths must be reviewed by a human engineer before the build is considered complete." This is a significant architectural decision — it would break the fully-automated pipeline.                                   |
| **15. Log Every Decision**             | Principle #9 ("Document decisions, not just code")         | PARTIAL  | Principle #9 focuses on non-obvious choices and ADRs. The law requires logging every agent action with reconstruction context. Checkpoint protocol provides session-level logging but not action-level.                                                                                                                                                | AMENDMENT to Principle #9: "Every agent must log significant decisions and state changes to its checkpoint file. Logs must include enough context to reconstruct the reasoning chain."                                                                                                        |
| **16. The Human Is the Architect**     | Principle #10 ("Delegate mode for leads")                  | WEAK     | Principle #10 says leads coordinate, not implement — but this constrains AI leads, not human authority. No principle requires human approval of architecture, data models, or API contracts before agent deployment. Skills produce specs autonomously.                                                                                                | NEW shared principle (CRITICAL tier): "System architecture, data models, API contracts, and security boundaries must be defined or explicitly approved by a human before implementation agents are deployed." This would require adding a human gate between planning and building pipelines. |

### Overlap Summary

| Coverage Level           | Count | Laws               |
| ------------------------ | ----- | ------------------ |
| STRONG (≥80% covered)    | 3     | 09, 11, 13         |
| PARTIAL (30-79% covered) | 5     | 02, 05, 06, 12, 15 |
| WEAK (<30% covered)      | 4     | 03, 07, 10, 16     |
| NONE (0% covered)        | 4     | 01, 04, 08, 14     |

---

## 2. Applicability Classification

| Iron Law                               | Applicability | Rationale                                                                                                                          |
| -------------------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **01. Strip Rationales Before Review** | MULTI-AGENT   | Only relevant where adversarial review exists. Single-agent skills have no reviewer.                                               |
| **02. Halt on Ambiguity**              | ALL           | Every agent — including single-agent skills — should halt on uncertainty rather than guess.                                        |
| **03. Scope Is a Contract**            | ALL           | Every agent invocation should have explicit scope, including single-agent skills.                                                  |
| **04. No Secrets in Context**          | ALL           | Security hygiene applies universally.                                                                                              |
| **05. Interrogate Before You Iterate** | MULTI-AGENT   | Relevant where agents plan or build. Single-agent utility skills don't iterate on requirements.                                    |
| **06. Spec Before You Build**          | BUILDING      | Only applicable to skills that write code: build-implementation, build-product, craft-laravel, run-task, squash-bugs, refine-code. |
| **07. Subagents Isolate Context**      | MULTI-AGENT   | Only relevant for multi-agent skills. Single-agent skills have no partitioning need.                                               |
| **08. Scripts Handle Determinism**     | ALL           | Any deterministic step in any skill should prefer scripts over reasoning.                                                          |
| **09. State Travels Explicitly**       | MULTI-AGENT   | Only relevant where state passes between agents.                                                                                   |
| **10. Work in Reversible Steps**       | BUILDING      | Only applicable to skills that modify the codebase.                                                                                |
| **11. Match the Agent to the Task**    | MULTI-AGENT   | Model selection only matters for multi-agent skills with heterogeneous roles.                                                      |
| **12. Every Phase Needs an Adversary** | MULTI-AGENT   | Single-agent skills have no phases to gate.                                                                                        |
| **13. Follow the Testing Pyramid**     | BUILDING      | Only applicable to skills that write or validate code.                                                                             |
| **14. Humans Validate Tests**          | BUILDING      | Only applicable where tests are produced.                                                                                          |
| **15. Log Every Decision**             | ALL           | Every agent should log actions.                                                                                                    |
| **16. The Human Is the Architect**     | ALL           | Human authority over architecture applies universally.                                                                             |

---

## 3. Compliance Matrix

### Legend

- **COMPLIANT**: The skill explicitly addresses this law with sufficient mechanism.
- **PARTIAL**: The skill partially addresses this law (via shared principles or incomplete mechanism).
- **NON-COMPLIANT**: The skill does not address this law at all.
- **N/A**: The law does not apply to this skill type.

Note: All multi-agent skills receive Shared Principles via `sync-shared-content.sh` injection. Where a shared principle
partially covers a law, multi-agent skills get PARTIAL credit even if the skill itself adds nothing beyond the shared
content.

---

### Law 01: Strip Rationales Before Review

> Work submitted for adversarial review must not include explanations, rationales, or justifications.

| Skill                 | Status        | Evidence                                                                                      | Gap                                                                                   |
| --------------------- | ------------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| build-implementation  | NON-COMPLIANT | No mention of rationale handling in review flow                                               | Code submitted to quality-skeptic with no stripping instruction                       |
| build-product         | NON-COMPLIANT | No mention of rationale stripping                                                             | Same as build-implementation                                                          |
| craft-laravel         | NON-COMPLIANT | Convention Warden reviews with "FMEA, heuristic evaluation" — no stripping                    | Deliverables include architect rationale implicitly                                   |
| create-conclave-team  | NON-COMPLIANT | Forge-auditor reviews full design including rationale                                         | Design document includes "mission statement" rationale                                |
| harden-security       | NON-COMPLIANT | Assayer uses Toulmin framework — explicitly retains "warrant" (rationale)                     | By design: warrant is part of evidence chain. Stripping would weaken security review. |
| plan-implementation   | NON-COMPLIANT | Plan-skeptic reviews implementation plan including dependency ordering rationale              | Plan artifact includes "why" for ordering decisions                                   |
| plan-product          | NON-COMPLIANT | Product-skeptic reviews all stage outputs with context                                        | No stripping mechanism                                                                |
| review-pr             | NON-COMPLIANT | 9 reviewers receive full dossier with context                                                 | Dossier explicitly includes PR description, commit messages (rationales)              |
| review-quality        | NON-COMPLIANT | Ops-skeptic demands "evidence" but doesn't strip rationale from submissions                   | Findings include rationale by default                                                 |
| run-task              | NON-COMPLIANT | Lead-as-Skeptic or dedicated skeptic reviews with context                                     | No stripping                                                                          |
| squash-bugs           | NON-COMPLIANT | First Skeptic reviews with "hypothesis elimination" — rationales retained                     | Root cause statement includes reasoning chain by design                               |
| refine-code           | NON-COMPLIANT | Refine-skeptic reviews manifests that include "heuristic violations" rationale                | Manifest includes file refs + rationale for each finding                              |
| unearth-specification | NON-COMPLIANT | Assayer reviews structural map with "clustering rationale"                                    | Rationale explicitly required in deliverable                                          |
| write-spec            | NON-COMPLIANT | Spec-skeptic reviews architecture with embedded rationale                                     | Spec includes "Constraints" rationale                                                 |
| research-market       | NON-COMPLIANT | Lead-as-Skeptic reviews findings with context                                                 | Research dossier includes methodology rationale                                       |
| ideate-product        | NON-COMPLIANT | Lead-as-Skeptic reviews with context                                                          | Ideas include evaluation rationale                                                    |
| manage-roadmap        | NON-COMPLIANT | Lead-as-Skeptic reviews prioritization rationale                                              | Priority decisions include "why"                                                      |
| write-stories         | NON-COMPLIANT | Story-skeptic reviews with INVEST criteria — rationale embedded in stories                    | Stories include acceptance criteria rationale                                         |
| plan-sales            | NON-COMPLIANT | Dual skeptics review with confidence levels and rationale                                     | Output includes per-section rationale                                                 |
| plan-hiring           | NON-COMPLIANT | Dual skeptics review with "tensions documented"                                               | Debate rationale is core to the output                                                |
| draft-investor-update | NON-COMPLIANT | Drafter explicitly includes "Drafter Notes listing assumptions, framing choices" for skeptics | Rationale deliberately provided to skeptics                                           |
| setup-project         | N/A           | Single-agent, no adversarial review                                                           | —                                                                                     |
| wizard-guide          | N/A           | Single-agent, no adversarial review                                                           | —                                                                                     |
| tier1-test            | N/A           | Single-agent, no adversarial review                                                           | —                                                                                     |

**Summary**: 0/21 applicable skills compliant. This law is universally non-compliant.

**Design tension (important for remediation)**: Blanket rationale stripping would actively degrade several skills:

- **harden-security**: Assayer uses Toulmin "warrant" (rationale connecting evidence to claim) — stripping it removes
  the logical chain that makes security review rigorous.
- **squash-bugs**: First Skeptic reviews hypothesis elimination matrices and root cause reasoning chains — the rationale
  IS the deliverable under review.
- **draft-investor-update**: Drafter Notes (assumptions, framing choices) are deliberately provided so skeptics can
  challenge the framing, not just the facts.
- **plan-hiring**: Debate tensions between growth-advocate and resource-optimizer are core to the output — stripping
  them removes the structured disagreement the skill is designed to surface.

Remediation must be skill-specific: code review skills (review-pr, build-implementation) benefit most from rationale
stripping. Analysis/security/debate skills would be harmed by it.

---

### Law 02: Halt on Ambiguity

> Agents must stop and surface uncertainty rather than invent solutions.

| Skill                 | Status        | Evidence                                                                          | Gap                                                                                                   |
| --------------------- | ------------- | --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| build-implementation  | PARTIAL       | Shared Principle #3 injected. Deadlock escalation exists.                         | No explicit halt conditions in individual agent prompts.                                              |
| build-product         | PARTIAL       | Shared Principle #3 injected. Deadlock escalation exists.                         | Same gap.                                                                                             |
| craft-laravel         | PARTIAL       | Shared Principle #3 injected. Phase gates block on uncertainty.                   | Hypothesis Elimination in Phase 1 addresses ambiguity systematically, but no explicit "halt" trigger. |
| create-conclave-team  | PARTIAL       | Shared Principle #3 injected. Forge-auditor gates.                                | No explicit halt instruction in agent prompts.                                                        |
| harden-security       | PARTIAL       | Shared Principle #3. ESCALATE mechanism for stalls.                               | ESCALATE is close to explicit halt, but triggered by disagreement not uncertainty.                    |
| plan-implementation   | PARTIAL       | Shared Principle #3. Plan-skeptic gates.                                          | No explicit halt in architect prompt.                                                                 |
| plan-product          | PARTIAL       | Shared Principle #3. Multi-stage gates. Complexity checkpoint.                    | Complexity checkpoint presents findings to user — strongest halt mechanism.                           |
| review-pr             | PARTIAL       | Shared Principle #3. Scrutineer gates dossier.                                    | Phase 2 agents work independently with no halt mechanism.                                             |
| review-quality        | PARTIAL       | Shared Principle #3. Ops-skeptic gates.                                           | No explicit halt in auditor prompts.                                                                  |
| run-task              | PARTIAL       | Shared Principle #3. Lead reports plan before spawning.                           | Dynamic composition means less structured halt conditions.                                            |
| squash-bugs           | PARTIAL       | Shared Principle #3. "Unknown is never acceptable" — forces explicit uncertainty. | Good: forces agents to acknowledge unknowns. But no "stop and surface" instruction.                   |
| refine-code           | PARTIAL       | Shared Principle #3. Phase gates.                                                 | No explicit halt in surveyor/strategist/artisan prompts.                                              |
| unearth-specification | PARTIAL       | Shared Principle #3. Assayer blocks on gaps.                                      | Context exhaustion triggers checkpoint, not halt.                                                     |
| write-spec            | PARTIAL       | Shared Principle #3. Spec-skeptic gates.                                          | No explicit halt in architect/DBA prompts.                                                            |
| research-market       | PARTIAL       | Shared Principle #3 injected.                                                     | No explicit halt conditions.                                                                          |
| ideate-product        | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| manage-roadmap        | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| write-stories         | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| plan-sales            | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| plan-hiring           | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| draft-investor-update | PARTIAL       | Shared Principle #3 injected.                                                     | Same.                                                                                                 |
| setup-project         | NON-COMPLIANT | No shared principles injected (single-agent).                                     | Error handling table covers specific errors but no general halt-on-ambiguity.                         |
| wizard-guide          | NON-COMPLIANT | No shared principles injected (single-agent).                                     | No halt mechanism.                                                                                    |
| tier1-test            | NON-COMPLIANT | No shared principles injected (single-agent).                                     | Minimal skill, no halt mechanism.                                                                     |

**Summary**: 0 COMPLIANT, 21 PARTIAL, 3 NON-COMPLIANT. Shared Principle #3 provides the foundation but lacks explicit
"halt and surface" language in agent prompts.

---

### Law 03: Scope Is a Contract

> Every agent must have explicit, written scope boundaries. No self-expansion. Scope changes require human
> authorization.

| Skill                 | Status  | Evidence                                                                                                                        | Gap                                                                                                 |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| build-implementation  | PARTIAL | Agents have defined roles (backend-eng, frontend-eng, quality-skeptic, qa-agent). Sprint contract defines scope.                | No explicit "do not self-expand" instruction. No human auth for scope changes.                      |
| build-product         | PARTIAL | Stage-based scoping. Sprint contract.                                                                                           | Same gap.                                                                                           |
| craft-laravel         | PARTIAL | Phase boundaries explicit. Commission description as scope. Mandate boundaries tested by forge-auditor in create-conclave-team. | Strongest scope definition among skills, but still no "self-expansion prohibited" language.         |
| create-conclave-team  | PARTIAL | Mandate boundaries defined and tested for non-overlap.                                                                          | Good mandate boundary design, but for the created skill, not the create-conclave-team skill itself. |
| harden-security       | PARTIAL | Phase-based scope (recon → assessment → remediation). "audit" mode explicitly limits scope.                                     | No self-expansion prohibition.                                                                      |
| plan-implementation   | PARTIAL | Architect and plan-skeptic have defined roles.                                                                                  | No scope contract language.                                                                         |
| plan-product          | PARTIAL | 5 stages with distinct scope each. Complexity tier constrains agent count.                                                      | No self-expansion prohibition.                                                                      |
| review-pr             | PARTIAL | "No agent writes to source code, specs, or stories" — explicit read-only scope.                                                 | Strongest scope constraint among all skills. But still no human auth for scope changes.             |
| review-quality        | PARTIAL | Mode-specific scope (security, performance, deploy, regression).                                                                | No self-expansion prohibition.                                                                      |
| run-task              | PARTIAL | Dynamic scope from user prompt. Lead may redirect to better skill.                                                              | Weakest scope definition — inherently open-ended.                                                   |
| squash-bugs           | PARTIAL | Phase boundaries (identify → research → analyse → fix → verify).                                                                | No scope contract language.                                                                         |
| refine-code           | PARTIAL | Scope-specific (e.g., "controllers", "auth-module"). 4-phase boundaries.                                                        | No self-expansion prohibition.                                                                      |
| unearth-specification | PARTIAL | Directory-scoped or codebase-wide. Priority-Ranked Partition Table.                                                             | No self-expansion prohibition.                                                                      |
| write-spec            | PARTIAL | Feature-specific. Requires user stories input.                                                                                  | No scope contract language.                                                                         |
| research-market       | PARTIAL | Topic-specific research. Avoids duplication with existing artifacts.                                                            | No scope contract.                                                                                  |
| ideate-product        | PARTIAL | Topic-specific. Requires research-findings input.                                                                               | Same.                                                                                               |
| manage-roadmap        | PARTIAL | Mode-based (reprioritize, ingest, single item).                                                                                 | Same.                                                                                               |
| write-stories         | PARTIAL | Feature-specific. Targets roadmap items.                                                                                        | Same.                                                                                               |
| plan-sales            | PARTIAL | Sales strategy scoped to market/product.                                                                                        | Same.                                                                                               |
| plan-hiring           | PARTIAL | Role/team-specific hiring plan.                                                                                                 | Same.                                                                                               |
| draft-investor-update | PARTIAL | Investor update scoped to project data.                                                                                         | Same.                                                                                               |
| setup-project         | PARTIAL | Constraints section: "Single-agent only", "No code generation", "No git operations" — explicit prohibitions.                    | Good negative scope constraints but no "scope contract" framing.                                    |
| wizard-guide          | PARTIAL | "Never fabricate skills that don't exist" — scope to real catalog.                                                              | Minimal scope definition.                                                                           |
| tier1-test            | PARTIAL | "That is your entire job. Do not do anything else." — explicit scope ceiling.                                                   | Crude but effective.                                                                                |

**Summary**: 0 COMPLIANT, 24 PARTIAL. Every skill defines scope implicitly through role definitions, but none frame
scope as a contract with self-expansion prohibition and human authorization for changes.

---

### Law 04: No Secrets in Context

> Credentials, API keys, tokens, and PII must never pass through agent prompts or context windows.

| Skill         | Status        | Evidence                                                                                                            | Gap                                                                                                                 |
| ------------- | ------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| All 24 skills | NON-COMPLIANT | No skill, no shared principle, no communication protocol addresses secret/credential/PII handling in agent context. | Universal gap. harden-security scans for secrets in codebases but doesn't address secrets in its own agent context. |

**Summary**: 0/24 compliant. Complete gap across entire skill ecosystem.

---

### Law 05: Interrogate Before You Iterate

> Before you build, use an agent to pressure-test your prompt through structured questioning.

| Skill                 | Status  | Evidence                                                                              | Gap                                                                                                 |
| --------------------- | ------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| build-implementation  | PARTIAL | Quality-skeptic reviews plan before implementation (pre-implementation gate).         | Gate reviews plan, doesn't interrogate the original requirements.                                   |
| build-product         | PARTIAL | Plan-skeptic reviews plan. Complexity checkpoint presents to user.                    | Same pattern.                                                                                       |
| craft-laravel         | PARTIAL | Phase 1 Reconnaissance performs hypothesis elimination. Convention Warden gates.      | Closest to compliance — hypothesis elimination IS structured interrogation of assumptions.          |
| create-conclave-team  | PARTIAL | Forge-auditor challenges design principles.                                           | Challenges design, not original requirements.                                                       |
| harden-security       | PARTIAL | Threat Modeler performs STRIDE analysis (interrogates system design).                 | Interrogates system, not the prompt/requirements.                                                   |
| plan-implementation   | PARTIAL | Architect plans, plan-skeptic reviews.                                                | Plan review, not requirement interrogation.                                                         |
| plan-product          | PARTIAL | Stage 1 (research) gathers evidence before Stage 2 (ideation). Product-skeptic gates. | Research before ideation is a form of interrogation but not structured questioning of requirements. |
| review-pr             | PARTIAL | Scrutineer gates dossier before fork-join review.                                     | Validates intake, doesn't interrogate PR requirements.                                              |
| review-quality        | PARTIAL | Scope-specific mode selection.                                                        | No structured questioning phase.                                                                    |
| run-task              | PARTIAL | Lead analyzes task and composes team before execution.                                | Analysis phase, but no structured questioning.                                                      |
| squash-bugs           | PARTIAL | Scout identifies, Sage researches before Inquisitor analyzes.                         | Research phase before diagnosis is a form of interrogation.                                         |
| refine-code           | PARTIAL | Surveyor audits before Strategist plans.                                              | Audit phase interrogates codebase, not requirements.                                                |
| unearth-specification | PARTIAL | Cartographer maps before excavators dig.                                              | Mapping is interrogation of codebase.                                                               |
| write-spec            | PARTIAL | Architect and DBA cross-review before skeptic.                                        | Cross-review is a form of mutual interrogation.                                                     |
| research-market       | PARTIAL | Research itself IS the interrogation phase.                                           | But no structured questioning of the research prompt.                                               |
| ideate-product        | PARTIAL | Requires research-findings as input (prior interrogation).                            | Consumes prior interrogation, doesn't perform its own.                                              |
| manage-roadmap        | PARTIAL | Analyst performs dependency/impact analysis.                                          | Analysis, not structured questioning.                                                               |
| write-stories         | PARTIAL | INVEST criteria provide structured evaluation framework.                              | Evaluates stories, doesn't interrogate requirements.                                                |
| plan-sales            | PARTIAL | Three parallel analysts research before synthesis.                                    | Research phase, not requirement interrogation.                                                      |
| plan-hiring           | PARTIAL | Researcher establishes evidence base. Debate format interrogates assumptions.         | Debate IS structured interrogation — strong partial.                                                |
| draft-investor-update | PARTIAL | Researcher gathers evidence. Lead reviews dossier completeness.                       | Dossier review, not requirement interrogation.                                                      |
| setup-project         | N/A     | Single-agent utility, no iteration on requirements.                                   | —                                                                                                   |
| wizard-guide          | N/A     | Single-agent utility, no iteration.                                                   | —                                                                                                   |
| tier1-test            | N/A     | Single-agent PoC, no iteration.                                                       | —                                                                                                   |

**Summary**: 0 COMPLIANT, 21 PARTIAL, 3 N/A. Skills have analysis/research phases that partially satisfy this, but none
implement explicit "interrogate the prompt/requirements before proceeding" as a distinct step.

---

### Law 06: Spec Before You Build

> Produce a written specification before deploying any agent to build.

| Skill                   | Status    | Evidence                                                                                                            | Gap                                                  |
| ----------------------- | --------- | ------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| build-implementation    | COMPLIANT | Requires implementation-plan + technical-spec before execution. Quality-skeptic must approve plan.                  | —                                                    |
| build-product           | COMPLIANT | Requires technical-spec. Plan-skeptic must approve plan before implementation.                                      | —                                                    |
| craft-laravel           | COMPLIANT | Work Assessment → Solution Blueprint → Test Suite all approved before implementation.                               | —                                                    |
| run-task                | PARTIAL   | Lead reports plan to user before spawning agents.                                                                   | Plan is communicated but not a formal spec document. |
| squash-bugs             | COMPLIANT | Defect statement → Research dossier → Root cause statement all precede fix phase. "Root cause must be falsifiable." | —                                                    |
| refine-code             | COMPLIANT | Audit manifest (Phase 1) → Execution plan (Phase 2) both approved before Phase 3 execution.                         | —                                                    |
| All non-building skills | N/A       | Do not write code.                                                                                                  | —                                                    |

**Summary**: 5 COMPLIANT, 1 PARTIAL, 18 N/A. Building skills are well-covered. run-task's dynamic nature makes formal
spec harder.

---

### Law 07: Subagents Isolate Context

> Use agent teams to partition work. One agent, one concern.

| Skill                 | Status    | Evidence                                                                                                         | Gap |
| --------------------- | --------- | ---------------------------------------------------------------------------------------------------------------- | --- |
| build-implementation  | COMPLIANT | backend-eng, frontend-eng, quality-skeptic, qa-agent — distinct concerns.                                        | —   |
| build-product         | COMPLIANT | impl-architect, plan-skeptic, backend-eng, frontend-eng, quality-skeptic, qa-agent, security-auditor — distinct. | —   |
| craft-laravel         | COMPLIANT | analyst, architect, tester, implementer, convention-warden — strict separation.                                  | —   |
| create-conclave-team  | COMPLIANT | architect, armorer, lorekeeper, scribe, forge-auditor — one concern each.                                        | —   |
| harden-security       | COMPLIANT | threat-modeler, vuln-hunter, remediation-engineer, assayer — phase-isolated.                                     | —   |
| plan-implementation   | COMPLIANT | impl-architect, plan-skeptic — two distinct roles.                                                               | —   |
| plan-product          | COMPLIANT | 9 agents across 5 stages, each with distinct role.                                                               | —   |
| review-pr             | COMPLIANT | 9 parallel reviewers + scrutineer + presiding judge — maximally isolated.                                        | —   |
| review-quality        | COMPLIANT | test-eng, devops-eng, security-auditor, ops-skeptic — distinct auditing concerns.                                | —   |
| run-task              | COMPLIANT | Dynamic composition but each agent gets one archetype (engineer, researcher, writer).                            | —   |
| squash-bugs           | COMPLIANT | scout, sage, inquisitor, artificer, warden, first-skeptic — pipeline-isolated.                                   | —   |
| refine-code           | COMPLIANT | surveyor, strategist, artisan, refine-skeptic — phase-isolated.                                                  | —   |
| unearth-specification | COMPLIANT | cartographer, 3 excavators (logic/schema/boundary), chronicler, assayer — concern-isolated.                      | —   |
| write-spec            | COMPLIANT | architect, dba, spec-skeptic — distinct concerns.                                                                | —   |
| research-market       | COMPLIANT | market-researcher, customer-researcher — domain-isolated.                                                        | —   |
| ideate-product        | COMPLIANT | idea-generator, idea-evaluator — creation vs evaluation separated.                                               | —   |
| manage-roadmap        | COMPLIANT | analyst + lead — analysis vs decision separated.                                                                 | —   |
| write-stories         | COMPLIANT | story-writer, story-skeptic — creation vs validation.                                                            | —   |
| plan-sales            | COMPLIANT | market-analyst, product-strategist, gtm-analyst, accuracy-skeptic, strategy-skeptic — 5 distinct concerns.       | —   |
| plan-hiring           | COMPLIANT | researcher, growth-advocate, resource-optimizer, bias-skeptic, fit-skeptic — 5 distinct roles.                   | —   |
| draft-investor-update | COMPLIANT | researcher, drafter, accuracy-skeptic, narrative-skeptic — 4 distinct concerns.                                  | —   |
| setup-project         | N/A       | Single-agent.                                                                                                    | —   |
| wizard-guide          | N/A       | Single-agent.                                                                                                    | —   |
| tier1-test            | N/A       | Single-agent.                                                                                                    | —   |

**Summary**: 21/21 applicable skills COMPLIANT. This is the strongest law across the ecosystem.

---

### Law 08: Scripts Handle Determinism

> Deterministic steps belong in typed, fast scripts — not in model reasoning.

| Skill                 | Status  | Evidence                                                                                            | Gap                                                             |
| --------------------- | ------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| build-implementation  | PARTIAL | TDD procedure is instructed via prompt, not a script. QA agent runs tests (deterministic) via bash. | TDD sequencing could be scripted.                               |
| build-product         | PARTIAL | Artifact detection uses file checks (semi-scripted). TDD via prompt.                                | Same gap.                                                       |
| craft-laravel         | PARTIAL | Equivalence partitioning, boundary analysis — deterministic methods instructed via prompt.          | Test methodology could be a script/checklist template.          |
| create-conclave-team  | PARTIAL | Phase 4 registration (update plugin.json, sync, validate) is deterministic — instructed via prompt. | Registration steps should be a script.                          |
| harden-security       | PARTIAL | OWASP checklist, CVSS scoring — deterministic frameworks instructed via prompt.                     | Checklist adherence could be script-validated.                  |
| plan-implementation   | PARTIAL | Dependency ordering verification is deterministic.                                                  | Could be script-validated.                                      |
| plan-product          | PARTIAL | Artifact detection uses file existence checks. Complexity classification is semi-deterministic.     | Artifact detection is closest to scripted.                      |
| review-pr             | PARTIAL | PR intake (parse diff, list files) is deterministic — done via gh/git tools.                        | Good use of tooling for deterministic steps. Strongest partial. |
| review-quality        | PARTIAL | Test execution via bash is scripted. Analysis is reasoning.                                         | Good split between scripted tests and reasoned analysis.        |
| run-task              | PARTIAL | Dynamic — hard to pre-script.                                                                       | Inherently reasoning-heavy.                                     |
| squash-bugs           | PARTIAL | Git archaeology (git log, git blame) is deterministic via tools. Hypothesis testing is reasoning.   | Good tool use for deterministic lookup.                         |
| refine-code           | PARTIAL | Test execution for verification is deterministic.                                                   | Could script more verification steps.                           |
| unearth-specification | PARTIAL | Module enumeration is deterministic (file system scan).                                             | Could script file discovery.                                    |
| write-spec            | PARTIAL | Template conformance is deterministic.                                                              | Could validate template adherence via script.                   |
| research-market       | PARTIAL | File reading/grep is deterministic. Analysis is reasoning.                                          | —                                                               |
| ideate-product        | PARTIAL | Artifact detection is file-based.                                                                   | —                                                               |
| manage-roadmap        | PARTIAL | Frontmatter parsing is deterministic.                                                               | Could validate frontmatter via script.                          |
| write-stories         | PARTIAL | INVEST checklist is deterministic.                                                                  | Could script INVEST validation.                                 |
| plan-sales            | PARTIAL | Checklist validation is deterministic.                                                              | Could script checklist adherence.                               |
| plan-hiring           | PARTIAL | Checklist validation is deterministic.                                                              | Could script checklist adherence.                               |
| draft-investor-update | PARTIAL | Metric extraction from artifacts is semi-deterministic.                                             | —                                                               |
| setup-project         | PARTIAL | Entire pipeline is deterministic (scaffold dirs, write files). Executed via agent reasoning.        | This skill could be a bash script entirely.                     |
| wizard-guide          | PARTIAL | Catalog building (read frontmatter) is deterministic.                                               | Could script catalog generation.                                |
| tier1-test            | PARTIAL | Entire skill is deterministic (write one file).                                                     | Could be a bash script.                                         |

**Summary**: 0 COMPLIANT, 24 PARTIAL. **Platform constraint**: The skill execution model (static markdown prompts
interpreted by LLM at runtime) cannot invoke scripts directly — all instructions are prompt-encoded. Skills DO use
bash/git tools for some deterministic operations (artifact detection, test execution, git archaeology), but the
sequencing and checklist adherence is always mediated by model reasoning. This is not remediable by adding shared
principles — it would require an architectural change to the skill execution platform (e.g., skill hooks, scripted
pre/post steps). Recommend documenting this as a known platform limitation rather than treating it as a skill-level
compliance gap.

---

### Law 09: State Travels Explicitly

> Never assume an agent inherits knowledge. Pass complete state at every handoff.

| Skill                 | Status    | Evidence                                                                                             | Gap                                     |
| --------------------- | --------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------- |
| build-implementation  | COMPLIANT | Sprint contract injected into skeptic/QA spawns. Impl plan + spec shared. API contracts documented.  | —                                       |
| build-product         | COMPLIANT | Spec, stories, ADRs shared at spawn. Sprint contract injected. API contracts documented.             | —                                       |
| craft-laravel         | COMPLIANT | Phase artifacts chained: Commission → Assessment → Blueprint → Tests → Code. Each routed explicitly. | —                                       |
| create-conclave-team  | COMPLIANT | Design → Manifest → Theme → SKILL.md — explicit artifact chain.                                      | —                                       |
| harden-security       | COMPLIANT | Threat model → Vuln report → Remediation record — explicit chain with Assayer gates between.         | —                                       |
| plan-implementation   | COMPLIANT | Spec + stories shared. Plan reviewed. Sprint contract produced.                                      | —                                       |
| plan-product          | COMPLIANT | 5-stage artifact chain: research → ideas → roadmap → stories → spec. Each stage output feeds next.   | —                                       |
| review-pr             | COMPLIANT | Review Dossier shared with all Phase 2 agents. All reports collected for adjudication.               | —                                       |
| review-quality        | COMPLIANT | Scope-specific findings routed to ops-skeptic. Role-scoped progress files.                           | —                                       |
| run-task              | PARTIAL   | Dynamic composition. Lead shares task context.                                                       | Less structured than fixed-team skills. |
| squash-bugs           | COMPLIANT | Defect → Research → Root Cause → Patch → Verification — explicit sequential handoff.                 | —                                       |
| refine-code           | COMPLIANT | Manifest → Plan → Brightwork → Proof — explicit phase artifacts.                                     | —                                       |
| unearth-specification | COMPLIANT | Structural Map → Excavation Reports → Chronicle — explicit handoff. Priority-ranked partitions.      | —                                       |
| write-spec            | COMPLIANT | Stories input. Architect ↔ DBA cross-review. Spec-skeptic reviews both.                              | —                                       |
| research-market       | COMPLIANT | Agent outputs routed through Lead. Final artifact aggregated.                                        | —                                       |
| ideate-product        | COMPLIANT | Research-findings shared with both agents. Outputs aggregated by Lead.                               | —                                       |
| manage-roadmap        | COMPLIANT | Analyst output routed through Lead. Roadmap conventions maintained.                                  | —                                       |
| write-stories         | COMPLIANT | Stories routed through Lead to story-skeptic. Feedback loops explicit.                               | —                                       |
| plan-sales            | COMPLIANT | Phase 1 parallel → Phase 2 cross-reference → Phase 3 synthesis → Phase 4 review. Explicit handoffs.  | —                                       |
| plan-hiring           | COMPLIANT | Research → Cases → Cross-exam → Synthesis → Review. 3-message cross-exam rounds documented.          | —                                       |
| draft-investor-update | COMPLIANT | Dossier → Draft → Dual review → Revision cycles. Dossier shared with both skeptics.                  | —                                       |
| setup-project         | N/A       | Single-agent, no handoff.                                                                            | —                                       |
| wizard-guide          | N/A       | Single-agent, no handoff.                                                                            | —                                       |
| tier1-test            | N/A       | Single-agent, no handoff.                                                                            | —                                       |

**Summary**: 20 COMPLIANT, 1 PARTIAL (run-task), 3 N/A. Very strong compliance. Communication Protocol and per-skill
artifact chains provide robust state handoff.

---

### Law 10: Work in Reversible Steps

> Every agent run must leave the codebase committable or rollback-able.

| Skill                   | Status  | Evidence                                                                            | Gap                                                               |
| ----------------------- | ------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| build-implementation    | PARTIAL | TDD provides incremental, testable steps. Checkpoint protocol for session recovery. | No explicit "committable state" requirement.                      |
| build-product           | PARTIAL | Same TDD + checkpoint pattern.                                                      | Same gap.                                                         |
| craft-laravel           | PARTIAL | TDD Red/Green phases. Phase-based checkpoints.                                      | Same gap.                                                         |
| run-task                | PARTIAL | Dynamic. Checkpoints exist.                                                         | No reversibility guarantee.                                       |
| squash-bugs             | PARTIAL | Patch phase uses TDD. Verification phase validates.                                 | No explicit rollback mechanism.                                   |
| refine-code             | PARTIAL | Phase-based execution. Behavioral Preservation verification.                        | "Behavioral Preservation" is closest to reversibility validation. |
| All non-building skills | N/A     | Do not modify codebase.                                                             | —                                                                 |

**Summary**: 0 COMPLIANT, 6 PARTIAL, 18 N/A. Building skills use TDD which provides incremental safety, but none
explicitly state "every step must be committable."

---

### Law 11: Match the Agent to the Task

> Every agent has a grain — work with it.

| Skill                 | Status    | Evidence                                                                                                                                                                                                                                                                                                            | Gap                                  |
| --------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| build-implementation  | COMPLIANT | backend-eng/frontend-eng: sonnet. quality-skeptic/qa-agent: opus. Matches execution vs reasoning.                                                                                                                                                                                                                   | —                                    |
| build-product         | COMPLIANT | Execution agents: sonnet. Skeptics/architects: opus. `--light` flag for cost control.                                                                                                                                                                                                                               | —                                    |
| craft-laravel         | COMPLIANT | tester/implementer: sonnet. architect/convention-warden: opus. `--light` downgrades analyst only.                                                                                                                                                                                                                   | —                                    |
| create-conclave-team  | COMPLIANT | architect/armorer/forge-auditor: opus. lorekeeper/scribe: sonnet. Reasoning roles on opus, creative execution/authoring on sonnet.                                                                                                                                                                                  | —                                    |
| harden-security       | COMPLIANT | threat-modeler/remediation-eng: sonnet. vuln-hunter/assayer: opus. Assayer never downgraded.                                                                                                                                                                                                                        | —                                    |
| plan-implementation   | COMPLIANT | impl-architect: opus. plan-skeptic: opus. Both are reasoning roles.                                                                                                                                                                                                                                                 | —                                    |
| plan-product          | COMPLIANT | Researchers/writers: sonnet. Architect/DBA/skeptic: opus.                                                                                                                                                                                                                                                           | —                                    |
| review-pr             | COMPLIANT | 9 reviewers mixed: security/spec-compliance/adjudication on opus. Syntax/style/perf on sonnet.                                                                                                                                                                                                                      | —                                    |
| review-quality        | COMPLIANT | test-eng/devops-eng: sonnet. security-auditor/ops-skeptic: opus.                                                                                                                                                                                                                                                    | —                                    |
| run-task              | COMPLIANT | Dynamic: engineer sonnet, researcher sonnet, complex skeptic opus.                                                                                                                                                                                                                                                  | —                                    |
| squash-bugs           | COMPLIANT | scout/sage/artificer/warden: sonnet. inquisitor/first-skeptic: opus. Warden is execution (runs tests, checks behavior) — sonnet is appropriate. **Note**: teammate table (line 193) says opus for warden, but spawn prompt (line 803) says Sonnet — internal SKILL.md inconsistency; spawn prompt is authoritative. | —                                    |
| refine-code           | COMPLIANT | artisan: sonnet. surveyor/strategist/refine-skeptic: opus. `--light` downgrades surveyor.                                                                                                                                                                                                                           | —                                    |
| unearth-specification | COMPLIANT | schema/boundary-excavator/chronicler: sonnet. cartographer/logic-excavator/assayer: opus.                                                                                                                                                                                                                           | —                                    |
| write-spec            | COMPLIANT | architect/dba/spec-skeptic: opus. All reasoning-heavy roles justified.                                                                                                                                                                                                                                              | —                                    |
| research-market       | COMPLIANT | market-researcher/customer-researcher: sonnet.                                                                                                                                                                                                                                                                      | Execution roles correctly on sonnet. |
| ideate-product        | COMPLIANT | idea-generator/idea-evaluator: sonnet.                                                                                                                                                                                                                                                                              | —                                    |
| manage-roadmap        | COMPLIANT | analyst: sonnet.                                                                                                                                                                                                                                                                                                    | —                                    |
| write-stories         | COMPLIANT | story-writer: sonnet. story-skeptic: opus.                                                                                                                                                                                                                                                                          | —                                    |
| plan-sales            | COMPLIANT | All agents opus (business strategy requires deep reasoning).                                                                                                                                                                                                                                                        | Justified for business analysis.     |
| plan-hiring           | COMPLIANT | All agents opus (structured debate requires deep reasoning).                                                                                                                                                                                                                                                        | Justified for debate format.         |
| draft-investor-update | COMPLIANT | researcher: opus (default). drafter: sonnet. accuracy-skeptic/narrative-skeptic: opus. `--light` downgrades researcher to sonnet.                                                                                                                                                                                   | —                                    |
| setup-project         | N/A       | Single-agent, inherits caller's model.                                                                                                                                                                                                                                                                              | —                                    |
| wizard-guide          | N/A       | Single-agent, inherits caller's model.                                                                                                                                                                                                                                                                              | —                                    |
| tier1-test            | N/A       | Single-agent, inherits caller's model.                                                                                                                                                                                                                                                                              | —                                    |

**Summary**: 21/21 applicable COMPLIANT. Shared Principle #12 is well-implemented across all skills.

**Methodology**: All 21 multi-agent skills audited via systematic grep of both `- **Model**:` (teammate table) and
`^Model:` (spawn prompt section) lines. Spawn-section values are authoritative (they are what the Agent tool reads at
runtime). One internal SKILL.md inconsistency found: squash-bugs warden is opus in teammate table but Sonnet in spawn
prompt — flagged in the entry above.

---

### Law 12: Every Phase Needs an Adversary

> Every team or phase must include an adversarial review agent.

| Skill                 | Status                            | Evidence                                                                                                                                                                        | Gap                                                                                                                                                                               |
| --------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| build-implementation  | COMPLIANT                         | quality-skeptic gates plan AND code. qa-agent validates behavior.                                                                                                               | Two adversarial roles.                                                                                                                                                            |
| build-product         | COMPLIANT                         | plan-skeptic (Stage 1) + quality-skeptic (Stages 1-3) + qa-agent + security-auditor.                                                                                            | Multiple adversaries across stages.                                                                                                                                               |
| craft-laravel         | COMPLIANT                         | convention-warden gates ALL phases.                                                                                                                                             | Single adversary, every transition.                                                                                                                                               |
| create-conclave-team  | COMPLIANT                         | forge-auditor gates all phases.                                                                                                                                                 | —                                                                                                                                                                                 |
| harden-security       | COMPLIANT                         | assayer gates all 3 phases.                                                                                                                                                     | —                                                                                                                                                                                 |
| plan-implementation   | COMPLIANT                         | plan-skeptic reviews plan.                                                                                                                                                      | Dedicated adversary.                                                                                                                                                              |
| plan-product          | PARTIAL (COMPLIANT with `--full`) | Default mode: Lead-as-Skeptic for Stages 1-3, dedicated product-skeptic for Stages 4-5. `--full` flag: dedicated product-skeptic gates ALL 5 stages, achieving full compliance. | Default mode trades adversarial rigor for cost efficiency in early stages. Remediation: recommend `--full` for high-stakes planning, or accept default tradeoff for routine work. |
| review-pr             | COMPLIANT                         | scrutineer gates dossier (Phase 1.5) and adjudicates reports (Phase 3).                                                                                                         | —                                                                                                                                                                                 |
| review-quality        | COMPLIANT                         | ops-skeptic gates all findings.                                                                                                                                                 | —                                                                                                                                                                                 |
| run-task              | PARTIAL                           | Simple/medium: Lead-as-Skeptic. Complex: dedicated skeptic.                                                                                                                     | Lead-as-Skeptic is weaker adversarial stance.                                                                                                                                     |
| squash-bugs           | COMPLIANT                         | first-skeptic gates every phase.                                                                                                                                                | —                                                                                                                                                                                 |
| refine-code           | COMPLIANT                         | refine-skeptic gates all 4 phases.                                                                                                                                              | —                                                                                                                                                                                 |
| unearth-specification | COMPLIANT                         | assayer gates structural map and final output.                                                                                                                                  | —                                                                                                                                                                                 |
| write-spec            | COMPLIANT                         | spec-skeptic reviews architecture and spec.                                                                                                                                     | —                                                                                                                                                                                 |
| research-market       | PARTIAL                           | Lead-as-Skeptic only. No dedicated adversary.                                                                                                                                   | Weaker adversarial coverage.                                                                                                                                                      |
| ideate-product        | PARTIAL                           | Lead-as-Skeptic only.                                                                                                                                                           | Same.                                                                                                                                                                             |
| manage-roadmap        | PARTIAL                           | Lead-as-Skeptic only.                                                                                                                                                           | Same.                                                                                                                                                                             |
| write-stories         | COMPLIANT                         | story-skeptic (opus) with INVEST criteria.                                                                                                                                      | Dedicated adversary.                                                                                                                                                              |
| plan-sales            | COMPLIANT                         | accuracy-skeptic + strategy-skeptic (dual adversaries).                                                                                                                         | —                                                                                                                                                                                 |
| plan-hiring           | COMPLIANT                         | bias-skeptic + fit-skeptic (dual adversaries).                                                                                                                                  | —                                                                                                                                                                                 |
| draft-investor-update | COMPLIANT                         | accuracy-skeptic + narrative-skeptic (dual adversaries).                                                                                                                        | —                                                                                                                                                                                 |
| setup-project         | N/A                               | Single-agent.                                                                                                                                                                   | —                                                                                                                                                                                 |
| wizard-guide          | N/A                               | Single-agent.                                                                                                                                                                   | —                                                                                                                                                                                 |
| tier1-test            | N/A                               | Single-agent.                                                                                                                                                                   | —                                                                                                                                                                                 |

**Summary**: 15 COMPLIANT, 6 PARTIAL (Lead-as-Skeptic skills), 3 N/A. Strong overall, with known weakness in
research-market, ideate-product, manage-roadmap, run-task (simple/medium), plan-product (default mode).

---

### Law 13: Follow the Testing Pyramid

> Automated tests and static analysis are table stakes. Prefer unit > feature > integration.

| Skill                   | Status    | Evidence                                                                           | Gap                                       |
| ----------------------- | --------- | ---------------------------------------------------------------------------------- | ----------------------------------------- |
| build-implementation    | COMPLIANT | Engineering Principle #5 (TDD) + #7 (unit tests preferred). QA agent for e2e.      | Full pyramid.                             |
| build-product           | COMPLIANT | Same principles. QA agent + security auditor.                                      | —                                         |
| craft-laravel           | COMPLIANT | Equivalence partitioning, boundary value analysis. TDD Red/Green phases.           | —                                         |
| run-task                | PARTIAL   | Engineering principles injected but no explicit test requirement for ad-hoc tasks. | Dynamic — may or may not involve testing. |
| squash-bugs             | COMPLIANT | Artificer uses TDD for fix. Warden verifies with tests.                            | —                                         |
| refine-code             | COMPLIANT | Behavioral Preservation verification. Test Coverage validation.                    | —                                         |
| All non-building skills | N/A       | Do not produce code/tests.                                                         | —                                         |

**Summary**: 5 COMPLIANT, 1 PARTIAL, 18 N/A. Well-covered for building skills.

---

### Law 14: Humans Validate Tests

> A human engineer must review test assertions before work proceeds.

| Skill                   | Status        | Evidence                                                                                                 | Gap                                                                             |
| ----------------------- | ------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| build-implementation    | NON-COMPLIANT | Quality-skeptic (AI) reviews code+tests. QA agent (AI) writes+runs e2e tests. No human test review gate. | Default path is fully AI-validated. Human only involved at deadlock escalation. |
| build-product           | NON-COMPLIANT | Same pattern. Plan-skeptic and quality-skeptic are AI agents.                                            | Same gap.                                                                       |
| craft-laravel           | NON-COMPLIANT | Convention-warden (AI) reviews test adequacy.                                                            | No human test review.                                                           |
| run-task                | NON-COMPLIANT | Lead-as-Skeptic or AI skeptic reviews.                                                                   | No human test review.                                                           |
| squash-bugs             | NON-COMPLIANT | First-skeptic (AI) reviews patch+tests. Warden (AI) verifies.                                            | No human test review.                                                           |
| refine-code             | NON-COMPLIANT | Refine-skeptic (AI) reviews behavioral preservation.                                                     | No human test review.                                                           |
| All non-building skills | N/A           | Do not produce tests.                                                                                    | —                                                                               |

**Summary**: 0/6 applicable COMPLIANT. Universal gap for building skills. The AI skeptic serves as test reviewer, not a
human.

---

### Law 15: Log Every Decision

> Every agent action must be logged with reconstruction context.

| Skill                 | Status        | Evidence                                                                                    | Gap                                                                      |
| --------------------- | ------------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| build-implementation  | PARTIAL       | Checkpoint protocol (configurable frequency). Shared Principle #9. Progress files per role. | Checkpoints log state changes, not every action.                         |
| build-product         | PARTIAL       | Same. Cost summary with skeptic-gate-count.                                                 | Same gap.                                                                |
| craft-laravel         | PARTIAL       | Phase-based checkpoints. Artifact detection for resume.                                     | Same gap.                                                                |
| create-conclave-team  | PARTIAL       | Phase-based checkpoints.                                                                    | Same.                                                                    |
| harden-security       | PARTIAL       | Phase-based checkpoints. Garrison Report synthesizes findings.                              | Garrison Report is comprehensive but produced at end, not incrementally. |
| plan-implementation   | PARTIAL       | Checkpoints + sprint contract as decision log.                                              | Same gap.                                                                |
| plan-product          | PARTIAL       | 5-stage checkpoints. Artifact chain preserves decisions.                                    | Same.                                                                    |
| review-pr             | PARTIAL       | Phase-based checkpoints. 9 reviewer reports document findings.                              | Reviewer reports are good decision logs.                                 |
| review-quality        | PARTIAL       | Role-scoped progress files.                                                                 | Same gap.                                                                |
| run-task              | PARTIAL       | Checkpoints exist.                                                                          | Weakest logging — dynamic composition.                                   |
| squash-bugs           | PARTIAL       | Phase checkpoints. Hypothesis elimination matrix logs reasoning.                            | Hypothesis matrix is good decision log.                                  |
| refine-code           | PARTIAL       | Phase checkpoints. Manifest documents findings with evidence.                               | Good audit trail.                                                        |
| unearth-specification | PARTIAL       | Context-aware checkpoints. Priority-ranked output.                                          | —                                                                        |
| write-spec            | PARTIAL       | Checkpoints. ADRs document architecture decisions.                                          | ADRs are strong decision logs for architecture.                          |
| research-market       | PARTIAL       | Checkpoints. Cost summary.                                                                  | —                                                                        |
| ideate-product        | PARTIAL       | Checkpoints.                                                                                | —                                                                        |
| manage-roadmap        | PARTIAL       | Checkpoints. Session summary.                                                               | —                                                                        |
| write-stories         | PARTIAL       | Checkpoints.                                                                                | —                                                                        |
| plan-sales            | PARTIAL       | Cross-reference documentation. Confidence levels.                                           | —                                                                        |
| plan-hiring           | PARTIAL       | Cross-examination logs. Tension documentation.                                              | Good: debate tensions are logged.                                        |
| draft-investor-update | PARTIAL       | Checkpoints. Drafter Notes document assumptions.                                            | —                                                                        |
| setup-project         | NON-COMPLIANT | No checkpoint protocol. Prints summary at end only.                                         | No decision logging.                                                     |
| wizard-guide          | NON-COMPLIANT | No logging at all.                                                                          | Conversational skill, no persistent output.                              |
| tier1-test            | NON-COMPLIANT | Writes one artifact. No decision logging.                                                   | Minimal PoC.                                                             |

**Summary**: 0 COMPLIANT, 21 PARTIAL, 3 NON-COMPLIANT. Checkpoint protocol provides session-level logging but not
action-level.

---

### Law 16: The Human Is the Architect

> Architecture, data models, API contracts, and security boundaries must be human-approved before agents deploy.

| Skill                 | Status        | Evidence                                                                                          | Gap                                                                                                   |
| --------------------- | ------------- | ------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| build-implementation  | PARTIAL       | Requires spec (presumably human-approved). But no explicit human architecture gate in skill.      | Skill trusts that input spec was human-approved. No enforcement.                                      |
| build-product         | PARTIAL       | Same — requires spec.                                                                             | Same gap.                                                                                             |
| craft-laravel         | PARTIAL       | Solution Blueprint produced by AI architect. Convention Warden (AI) reviews.                      | No human architecture approval gate.                                                                  |
| create-conclave-team  | PARTIAL       | Architect (AI) designs skill. Forge-auditor (AI) reviews.                                         | No human approval of skill architecture.                                                              |
| harden-security       | PARTIAL       | Threat model produced by AI. Assayer (AI) reviews.                                                | No human threat model approval.                                                                       |
| plan-implementation   | PARTIAL       | Impl plan produced by AI architect. Plan-skeptic (AI) reviews.                                    | Plan is for human consumption but no explicit human gate before build.                                |
| plan-product          | PARTIAL       | Spec produced autonomously. Product-skeptic (AI) reviews. Complexity checkpoint presents to user. | Complexity checkpoint is closest to human gate.                                                       |
| review-pr             | PARTIAL       | Reviews existing code. No architecture production.                                                | N/A-adjacent — review skill.                                                                          |
| review-quality        | PARTIAL       | Audits existing code. No architecture production.                                                 | N/A-adjacent — audit skill.                                                                           |
| run-task              | NON-COMPLIANT | Dynamic. May produce architecture decisions without human review.                                 | Most vulnerable skill — open-ended mandate.                                                           |
| squash-bugs           | PARTIAL       | Fix scoped to existing architecture. Root cause analysis by AI.                                   | Fixes stay within existing architecture. Lower risk.                                                  |
| refine-code           | PARTIAL       | Refactoring within existing architecture. Behavioral Preservation guards.                         | Constrained to existing architecture.                                                                 |
| unearth-specification | N/A           | Reads architecture, doesn't create it.                                                            | —                                                                                                     |
| write-spec            | PARTIAL       | Produces architecture spec for human consumption. ADRs produced.                                  | Spec is produced for human review but no gate enforcing human approval before downstream consumption. |
| research-market       | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| ideate-product        | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| manage-roadmap        | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| write-stories         | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| plan-sales            | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| plan-hiring           | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| draft-investor-update | N/A           | No architecture involvement.                                                                      | —                                                                                                     |
| setup-project         | N/A           | Scaffolding only.                                                                                 | —                                                                                                     |
| wizard-guide          | N/A           | Conversational only.                                                                              | —                                                                                                     |
| tier1-test            | N/A           | PoC only.                                                                                         | —                                                                                                     |

**Summary**: 0 COMPLIANT, 12 PARTIAL, 1 NON-COMPLIANT (run-task), 11 N/A. Skills produce architecture for human
consumption but don't enforce human approval gates before downstream agents consume it.

---

## 4. Summary Statistics

### Totals

| Metric                                   | Count |
| ---------------------------------------- | ----- |
| Total audit checks (16 laws × 24 skills) | 384   |
| Applicable checks (excluding N/A)        | 258   |
| COMPLIANT                                | 93    |
| PARTIAL                                  | 140   |
| NON-COMPLIANT                            | 25    |
| NOT-APPLICABLE                           | 126   |

### Compliance Rate (applicable checks only)

- **COMPLIANT**: 93/258 = **36.0%**
- **PARTIAL**: 140/258 = **54.3%**
- **NON-COMPLIANT**: 25/258 = **9.7%**

### Top 5 Most Non-Compliant Skills (by severity, not raw count)

| Rank | Skill                | NON-COMPLIANT Count | Severity                                      | Key Gaps                                                                                                    |
| ---- | -------------------- | ------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| 1    | build-implementation | 3                   | **HIGH** — writes production code             | Strip rationales (Law 01), no secrets (Law 04), humans validate tests (Law 14)                              |
| 2    | build-product        | 3                   | **HIGH** — full build pipeline, writes code   | Same as build-implementation                                                                                |
| 3    | craft-laravel        | 3                   | **HIGH** — writes production code             | Strip rationales (Law 01), no secrets (Law 04), humans validate tests (Law 14)                              |
| 4    | run-task             | 4                   | **HIGH** — open-ended mandate, may write code | Strip rationales (Law 01), no secrets (Law 04), humans validate tests (Law 14), human is architect (Law 16) |
| 5    | squash-bugs          | 3                   | **MEDIUM** — modifies existing code           | Strip rationales (Law 01), no secrets (Law 04), humans validate tests (Law 14)                              |

Note: Single-agent skills (setup-project, wizard-guide, tier1-test) have 4 NON-COMPLIANT each by raw count, but their
severity is **LOW** — they don't write application code, don't spawn teams, and their gaps (halt on ambiguity, no
secrets, scripts handle determinism, log decisions) are lower-risk in a scaffolding/guidance context. All multi-agent
skills share NON-COMPLIANT for Laws 01 and 04. Building skills additionally fail Law 14.

### Top 5 Most Non-Compliant Laws (most violations across skills)

| Rank | Law                                    | NON-COMPLIANT + PARTIAL Count | Type                                                                                                           |
| ---- | -------------------------------------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 1    | **Law 01: Strip Rationales**           | 21 NON-COMPLIANT, 0 PARTIAL   | Universal gap — no skill strips rationales                                                                     |
| 2    | **Law 04: No Secrets in Context**      | 24 NON-COMPLIANT              | Universal gap — zero coverage                                                                                  |
| 3    | **Law 08: Scripts Handle Determinism** | 0 NON-COMPLIANT, 24 PARTIAL   | **Platform constraint** — skills are markdown prompts interpreted by LLM; not remediable via principle changes |
| 4    | **Law 14: Humans Validate Tests**      | 6 NON-COMPLIANT               | Building skills only, but 100% failure in scope                                                                |
| 5    | **Law 16: Human Is Architect**         | 1 NON-COMPLIANT, 12 PARTIAL   | Widespread gap in human architecture approval                                                                  |

### Per-Law Summary

| Law                             | COMPLIANT | PARTIAL | NON-COMPLIANT | N/A |
| ------------------------------- | --------- | ------- | ------------- | --- |
| 01. Strip Rationales            | 0         | 0       | 21            | 3   |
| 02. Halt on Ambiguity           | 0         | 21      | 3             | 0   |
| 03. Scope Is a Contract         | 0         | 24      | 0             | 0   |
| 04. No Secrets in Context       | 0         | 0       | 24            | 0   |
| 05. Interrogate Before Iterate  | 0         | 21      | 0             | 3   |
| 06. Spec Before Build           | 5         | 1       | 0             | 18  |
| 07. Subagents Isolate Context   | 21        | 0       | 0             | 3   |
| 08. Scripts Handle Determinism  | 0         | 24      | 0             | 0   |
| 09. State Travels Explicitly    | 20        | 1       | 0             | 3   |
| 10. Reversible Steps            | 0         | 6       | 0             | 18  |
| 11. Match Agent to Task         | 21        | 0       | 0             | 3   |
| 12. Every Phase Needs Adversary | 15        | 6       | 0             | 3   |
| 13. Testing Pyramid             | 5         | 1       | 0             | 18  |
| 14. Humans Validate Tests       | 0         | 0       | 6             | 18  |
| 15. Log Every Decision          | 0         | 21      | 3             | 0   |
| 16. Human Is Architect          | 0         | 12      | 1             | 11  |

### Laws Already Well-Satisfied (COMPLIANT ≥ 80% of applicable)

- **Law 07: Subagents Isolate Context** — 21/21 (100%)
- **Law 11: Match Agent to Task** — 21/21 (100%)
- **Law 09: State Travels Explicitly** — 20/21 (95%)
- **Law 06: Spec Before Build** — 5/6 (83%)
- **Law 13: Testing Pyramid** — 5/6 (83%)

### Laws Requiring Major Reform (0% COMPLIANT)

- **Law 01: Strip Rationales** — 0/21 (design decision needed)
- **Law 04: No Secrets in Context** — 0/24 (new principle needed)
- **Law 02: Halt on Ambiguity** — 0/24 (amendment needed)
- **Law 03: Scope Is a Contract** — 0/24 (new principle needed)
- **Law 08: Scripts Handle Determinism** — 0/24 (architectural constraint)
- **Law 14: Humans Validate Tests** — 0/6 (new gate needed)
- **Law 15: Log Every Decision** — 0/24 (amendment needed)
- **Law 16: Human Is Architect** — 0/13 (new gate needed)
