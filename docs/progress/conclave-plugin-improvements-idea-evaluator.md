---
type: progress-checkpoint
agent: idea-evaluator
persona: Morwen Greystone, Transmutation Judge
skill: ideate-product
topic: conclave-plugin-improvements
session: 2026-03-10
---

# Idea Evaluator Progress: Conclave Plugin Improvements

## Checkpoints

- [x] Task claimed — reading research-findings and idea-generator output
- [x] Evaluation started
- [x] Evaluations ready
- [x] Evaluations submitted to Team Lead

---

## Evaluation Methodology

**Scoring**: Priority Score = Impact × (4 - Effort)
- Effort: Small=1, Medium=2, Large=3
- Impact: Low=1, Medium=2, High=3
- Score range: 1 (Low impact, Large effort) to 9 (High impact, Small effort)

**Additional filters applied per plugin context:**
1. Does the idea address a HIGH-confidence research finding?
2. Is the effort realistic for a markdown/shell-script codebase (no app runtime)?
3. Does it improve user experience proportional to cost?
4. Does it risk breaking the 12/12 validator suite?
5. For fantasy/thematic ideas: does it deepen immersion users actually experience, or is it cosmetic?

---

## EVALUATION: Conclave Plugin Improvements

### Idea 1: Persona Name Injection in Spawn Prompts

- **Confidence**: H — Research grep confirmed zero fictional name references across all SKILL.md files. The problem is structural and verified, not speculative. Communication protocol already instructs agents to "be a character" — the wire is just missing.
- **Priority score**: High impact (3) × (4 - Small effort (1)) = **9/9**
- **Effort challenge**: The generator says "~40+ spawn prompts." This is accurate and correct — it's still Small effort because each edit is identical in pattern. The sync script cannot handle this; it must be done per-file. However, the edit is mechanical, not architectural.
- **Risks**:
  - LLMs may ignore the instruction in long prompts where it gets buried. Mitigation: place the introduction instruction first in each spawn prompt.
  - Persona file names must match exactly — any typo creates a broken reference. Idea 11 (validator) mitigates this downstream.
  - No regression risk for validators (spawn prompt content is not structurally validated currently).
- **Recommendation**: **Pursue** — Highest-scoring idea. Activates the entire persona investment with line-level changes. The research-findings call this CRITICAL and the evidence is airtight.

---

### Idea 2: Business Skills Section in wizard-guide

- **Confidence**: H — Research fully read wizard-guide SKILL.md and confirmed business skills are absent from both the overview AND example workflows sections. Three production-quality skills are invisible at the primary discovery point. No ambiguity.
- **Priority score**: High impact (3) × (4 - Small effort (1)) = **9/9**
- **Effort challenge**: Correctly scoped as Small. One section addition. No validator risk — skill-structure validators do not check content of overview sections.
- **Risks**:
  - If wizard-guide has a strict section-ordering enforced by validators, an insertion could fail A2. LOW risk — A2 checks for required section presence, not order of optional sections.
  - Minor: the generator's note says "brief descriptions and example use cases" — this is additive scope, not a risk.
- **Recommendation**: **Pursue** — Tied for top score. Three complete skills become discoverable with a section addition. The ROI is extreme. Should be done alongside Idea 3 in the same edit pass.

---

### Idea 3: wizard-guide Mention in setup-project Next Steps

- **Confidence**: H — Research confirmed setup-project Next Steps lists only `/plan-product`. Full read of setup-project SKILL.md. The first-run path gap is verified.
- **Priority score**: High impact (3) × (4 - Small effort (1)) = **9/9**
- **Effort challenge**: One bullet point. Cannot be more Small.
- **Risks**:
  - Minimal. The only concern is ordering — the generator suggests making this Step 1 before `/plan-product`. This is a judgment call; the user may prefer to see plan-product first. However, the user instruction "get a tour first" is sound pedagogically.
  - No validator risk.
- **Recommendation**: **Pursue** — Tied for top score. Unlocks the discovery funnel with a single bullet point. Bundle with Idea 2 for a single setup-project + wizard-guide edit pass.

---

### Idea 5: Persona Identity Reinforcement in Communication Protocol

- **Confidence**: H — The research confirms the communication protocol is the structural enforcement layer. Adding a signoff rule here is more reliable than Idea 1 alone because it applies to every message, not just the introduction. The sync mechanism already works.
- **Priority score**: High impact (3) × (4 - Small effort (1)) = **9/9**
- **Effort challenge**: One line in communication-protocol.md plus a sync run. The sync script is already proven — it's the authoritative mechanism for this kind of change.
- **Risks**:
  - Signoff on every message may create noise in long skill executions with many agent-to-agent messages. Mitigation: scope the rule to "messages to the user" only, which the idea already specifies.
  - B-series validators will detect drift if the sync isn't run after the change. This is the expected enforcement flow, not a risk.
  - If the LLM treats this as boilerplate and adds it mechanically without integrating it, the result feels artificial. Unavoidable at this layer; structural enforcement still beats relying on LLM volition.
- **Recommendation**: **Pursue** — Complements Idea 1. Together, they create introduction + sustained presence. Idea 1 handles first impression; Idea 5 handles persistence. Do both.

---

### Idea 11: Validator: Spawn Prompt Persona Reference Check

- **Confidence**: H — Research confirmed current validators have no spawn prompt content checks. The persona invisibility problem existed undetected because structural validators cannot catch content quality issues.
- **Priority score**: High impact (3) × (4 - Medium effort (2)) = **6/9**
- **Effort challenge**: Writing a new G-series validator (shell script) is medium effort but well within the established pattern — the codebase has 6 validator scripts already. The effort estimate is accurate.
- **Risks**:
  - If Idea 1 is not implemented first, this validator will immediately fail on all current SKILL.md files. Sequencing dependency: implement Idea 1 before or simultaneously with Idea 11.
  - False positives if the check is too strict (e.g., requiring exact persona file paths vs. just fictional name text). Requires careful implementation.
  - Adds to CI validation time. LOW — shell validators are fast.
- **Recommendation**: **Pursue** — Structural guarantee that the persona fix from Idea 1 doesn't regress. Essential if Idea 1 is merged. Sequence after Idea 1.

---

### Idea 7: Role-Based Principles Split (Engineering vs Universal)

- **Confidence**: H — Research confirmed via byte-identical B1 validator that engineering-specific rules (TDD, unit tests, SOLID/DRY) are synced to ALL multi-agent skills. The problem is architecturally real.
- **Priority score**: Medium impact (2) × (4 - Medium effort (2)) = **4/9**
- **Effort challenge**: The generator estimates Medium — this is correct but slightly optimistic. The sync script would need conditional logic per skill type, and the B-series validators would need updates to understand the two-block structure. Not Large, but Medium is the floor.
- **Risks**:
  - **Regression risk** is the most significant concern here. The B1/B2 validators currently check for byte-identical shared content. Changing to two blocks changes what "correct" looks like and requires updating skill-shared-content.sh to handle the new structure without false drift alerts.
  - Risk of introducing the split incorrectly: what's "universal" vs "engineering-only" requires judgment. Misclassification bleeds the problem into a different form.
  - Operational impact is genuinely low (agents ignore irrelevant rules). The fix improves correctness but user-facing benefit is marginal.
- **Recommendation**: **Pursue** — The evidence is strong and the codebase has the infrastructure to do this safely. However, the validator update work means this is a full sprint item, not a quick fix. Do after the high-9-score ideas.

---

### Idea 12: Business Tier 2 Composite: /run-business-ops

- **Confidence**: M — The three business skills exist and are confirmed production-quality. The Tier 2 composite pattern is established. However, research notes business skills were "sampled, not fully read" — the artifact contract between them (does plan-sales produce something ideate-product consumes?) is unverified.
- **Priority score**: High impact (3) × (4 - Medium effort (2)) = **6/9**
- **Effort challenge**: The generator says Medium. This is correct if the business skills already have compatible artifact outputs. If artifact contracts need to be designed and implemented, this slides toward Large. The research data gap on business skill internals is a real risk.
- **Risks**:
  - **Unknown artifact compatibility**: plan-sales → plan-hiring → draft-investor-update may not have artifact contracts. Adding them retroactively to three >500-line SKILL.md files is significant effort.
  - The composite pattern requires artifact detection logic for skip-detection. Without reading the business skill SKILL.md files fully, the effort could double.
  - The research finding is MEDIUM confidence on this point specifically.
- **Recommendation**: **Pursue with caveat** — High potential value but requires a discovery spike: read all three business SKILL.md files fully and confirm whether artifact contracts exist or need to be built. If contracts exist, pursue immediately. If not, re-scope to a multi-sprint item.

---

### Idea 17: Cross-Skill Artifact Continuity Badge

- **Confidence**: M — The research describes silent skip detection as a usability issue, but this is an inference from architecture review rather than direct user feedback. The problem is real; severity is uncertain.
- **Priority score**: Medium impact (2) × (4 - Small effort (1)) = **6/9**
- **Effort challenge**: Correctly scoped as Small. Adding narrative text to Tier 2 SKILL.md skip-detection prompts is a mechanical change with no validator risk.
- **Risks**:
  - If the narrative message is too long, it adds noise to an already long Tier 2 SKILL.md. Mitigation: keep it to one sentence.
  - The "Lore Archives" framing assumes users understand the in-universe metaphor. New users may be confused. Mitigation: include functional context ("Previous research found, proceeding from those findings").
  - LOW regression risk — this is text in prompt instructions, not structural changes.
- **Recommendation**: **Pursue** — Low effort, medium payoff. Good transparency + immersion simultaneously. Bundle with the Tier 2 composite work.

---

### Idea 10: Persona System ADR

- **Confidence**: H — Research confirmed ADR-001 through ADR-004 exist but the persona architecture decision is undocumented. The codebase convention is to document significant decisions as ADRs.
- **Priority score**: Medium impact (2) × (4 - Small effort (1)) = **6/9**
- **Effort challenge**: Correctly scoped as Small. Writing an ADR is a documentation task following an established template. The architectural facts are already known (45 personas, cross-reference structure, fantasy theme).
- **Risks**:
  - Risk of documenting incomplete or aspirational state. If Idea 1 is not yet implemented when ADR-005 is written, the ADR should describe both what exists and what should exist (the activation fix). Care required in framing.
  - No validator risk — ADRs are not validated by the current suite.
- **Recommendation**: **Pursue** — Protects the architectural investment. Write it after Ideas 1 and 5 are implemented so the ADR documents the completed system, not a broken one.

---

### Idea 4: Persona-Aware run-task Dynamic Agent Assignment

- **Confidence**: H — Research confirmed run-task is the only skill where the fantasy system breaks down entirely. The problem is verified.
- **Priority score**: Medium impact (2) × (4 - Medium effort (2)) = **4/9**
- **Effort challenge**: The generator says Medium (4 new persona files + run-task spawn prompt edits). This is accurate. Creating persona files is not hard but each one requires thoughtful naming and personality to be consistent with the 45 existing characters.
- **Risks**:
  - The four archetype names proposed (Gareth Ironwright, Lyra Dustfingers, etc.) are invented by the generator and not from the existing persona system. They must be validated against the 45 existing personas to avoid naming conflicts and ensure thematic consistency.
  - If these four personas are added, they should be subject to the same persona system conventions and the future Idea 11 validator.
  - Moderate risk: run-task is explicitly designed for *dynamic* composition. Adding fixed persona names to dynamic agents is conceptually coherent but requires careful implementation to avoid the names feeling arbitrary for unexpected task types.
- **Recommendation**: **Pursue** — After Ideas 1, 5, and 11 establish the persona infrastructure. This is a natural follow-on once the main persona fix is in place.

---

### Idea 18: Contribution Guide Skill: /wizard-guide --dev or contribution-guide

- **Confidence**: H — P3-03 is a confirmed roadmap item (not_started). Research identified this as a gap. The implementation path is clear.
- **Priority score**: Medium impact (2) × (4 - Medium effort (2)) = **4/9**
- **Effort challenge**: The generator says Small-Medium. For a new utility SKILL.md, Medium is the right floor. The content (persona file structure, sync script usage, validator suite, ADR conventions) is substantial. A companion skill is better than --dev mode on wizard-guide; mixing concerns in one skill creates complexity.
- **Risks**:
  - As a single-agent utility skill, it bypasses most validator checks (A3/A4 skip single-agent). LOW structural risk.
  - Risk of the guide going stale as the codebase evolves. Mitigation: link to authoritative files rather than duplicating content.
  - The idea of extending wizard-guide with a --dev flag is an anti-pattern for this skill type — SKILL.md files have no runtime flag handling. A separate SKILL.md is the clean implementation.
- **Recommendation**: **Pursue** — Implements an existing roadmap item. Create a standalone contribution-guide skill, not a wizard-guide extension.

---

### Idea 6: Conclave Lore Preamble in wizard-guide

- **Confidence**: M — The research notes the fantasy theme aligns with Claude Code ecosystem trends and that wizard-guide reads like a technical catalog. However, there is no direct user feedback confirming this is a pain point. It's an inference.
- **Priority score**: Medium impact (2) × (4 - Small effort (1)) = **6/9**
- **Effort challenge**: Correctly scoped as Small (~100 words of narrative). No structural impact.
- **Risks**:
  - Users who want a quick skill reference (not an immersive experience) may find the preamble friction. Mitigation: keep it brief (3-4 sentences); don't delay the skill catalog.
  - The preamble must be accurate — claiming "45 specialists" or "18 skills" creates a maintenance obligation as the plugin grows.
  - LOW regression risk.
- **Recommendation**: **Pursue** — The effort is trivial and the upside is real. Sets tone for all subsequent interactions. Bundle with Idea 2 (business skills section) and Idea 16 (persona spotlight) in a single wizard-guide enhancement pass.

---

### Idea 16: Persona Spotlight Section in wizard-guide

- **Confidence**: M — Research confirms 45 personas exist with rich personalities and zero surface exposure to users. The problem is real. The solution (wizard-guide showcase) is one option; it's not the only one.
- **Priority score**: Medium impact (2) × (4 - Small effort (1)) = **6/9**
- **Effort challenge**: Small — add one section to wizard-guide SKILL.md. The content (5-6 persona descriptions) is available in the persona files.
- **Risks**:
  - **Selection bias**: spotlighting 5-6 personas means choosing which 5-6 matter. This creates an implicit hierarchy among the 45. Mitigation: choose diversity across skills (one planning, one building, one quality, one business, one utility) rather than "most colorful."
  - wizard-guide is already growing with Idea 2 (business skills) and Idea 6 (lore preamble). Risk of the skill becoming too long and unfocused. MEDIUM risk.
  - Maintenance obligation: if personas are renamed or retired, the spotlight section needs updating.
- **Recommendation**: **Pursue with constraint** — Do it, but cap at 4-5 personas and keep descriptions to 1-2 sentences each. Bundle into the wizard-guide enhancement pass. Deprioritize slightly relative to Ideas 6 and 2 since Idea 1 (spawn prompt injection) makes personas discoverable in execution; the spotlight is a nice-to-have, not a critical gap.

---

### Idea 8: Communication Protocol Placeholder Fix + Inline Comment

- **Confidence**: H — Research confirmed "product-skeptic" at line 31 of communication-protocol.md. The problem is verified and the fix is trivially clear.
- **Priority score**: Low impact (1) × (4 - Small effort (1)) = **3/9**
- **Effort challenge**: Correctly scoped as Small (one line + comment). The sync script normalizer already handles the substitution correctly — this is purely a source file clarity issue.
- **Risks**:
  - Changing "product-skeptic" to `{skill-skeptic}` may break the sync script's normalizer if it pattern-matches on "product-skeptic" as a source key. Must verify the normalizer logic before making the change. LOW but non-zero risk.
  - The fix has zero user-facing impact — it only affects developers reading the source file.
- **Recommendation**: **Pursue** — It's a one-line fix. Do it in the same pass as any communication-protocol.md edits (e.g., Idea 5). Zero reason to leave a misleading source file.

---

### Idea 9: Stronger manage-roadmap Artifact Detection

- **Confidence**: M — Research identified this as a "potential false-skip risk" based on architectural comparison. No confirmed incident of a false skip occurring. The risk is theoretical.
- **Priority score**: Low impact (1) × (4 - Small effort (1)) = **3/9**
- **Effort challenge**: Correctly scoped as Small. Edit artifact detection logic in manage-roadmap SKILL.md. No validator risk.
- **Risks**:
  - If the artifact detection change is too strict, it could prevent valid skips — causing the Tier 2 pipeline to re-run stages unnecessarily. The current "weaker" check may be intentionally more permissive.
  - The research confidence on this specific finding is MEDIUM, not HIGH. The false-skip scenario may be theoretical.
- **Recommendation**: **Park** — Correct the issue eventually, but don't prioritize it now. The risk is theoretical, the impact is an edge-case correctness improvement, and the pipeline currently passes all 12/12 validators. Address after higher-value items.

---

### Idea 15: /council-status Skill

- **Confidence**: M — wizard-guide is static and setup-project is for bootstrapping. The gap is real: there is no "current state" orientation skill. However, the research does not confirm this is a user pain point — it's an inference about what could be useful.
- **Priority score**: Medium impact (2) × (4 - Medium effort (2)) = **4/9**
- **Effort challenge**: Medium. A new single-agent SKILL.md is needed, plus logic to read roadmap/progress files dynamically. The "reads current roadmap" requirement means the agent must actually traverse the file system. For a SKILL.md-based skill, this is done via Claude tool calls at runtime — it's achievable but requires careful prompting.
- **Risks**:
  - As a single-agent skill reading dynamic state, it is one of the more novel execution patterns. The output quality depends heavily on the prompt design.
  - The "in-character" framing adds a second quality dimension beyond functional correctness.
  - Risk of scope creep: "reads roadmap + progress files" could expand to reading all 18 SKILL.md files, making it a partial reimplementation of wizard-guide.
- **Recommendation**: **Park** — Creative idea with genuine appeal. But the roadmap already has prioritized items not yet started. This addresses no confirmed pain point. Revisit in P4 after the P3 backlog is further cleared.

---

### Idea 13: PoC Skills Quarantine

- **Confidence**: H — Research confirmed tier1-test and tier2-test are visible in skill discovery with no warning. The problem is verified.
- **Priority score**: Low impact (1) × (4 - Small effort (1)) = **3/9** (banner option); Low-Medium impact, Medium effort for directory restructure — don't do the restructure.
- **Effort challenge**: The banner option is correctly Small. The directory restructure option is not worth it — it requires updating the plugin discovery mechanism and creates architectural debt.
- **Risks**:
  - A deprecation banner is cosmetic only. If users can still invoke the skill, the banner is ignored.
  - The real fix is to exclude test skills from discovery, but that requires a plugin manifest change — Medium+ effort for a LOW impact problem.
  - The banner approach is low-risk but also low-effectiveness.
- **Recommendation**: **Pursue (banner only)** — Add the deprecation banner. It's three minutes of work. Don't pursue the directory restructure — the effort/impact ratio is wrong. The actual "hide from discovery" fix belongs in the plugin manifest design, which is a P2-08 (plugin organization) concern.

---

### Idea 14: Skill Naming Fantasy Rename: run-task → invoke-task or conjure-task

- **Confidence**: H — Research confirms run-task is the only skill name without fantasy resonance. The problem is real. The impact is correctly assessed as Low.
- **Priority score**: Low impact (1) × (4 - Small effort (1)) = **3/9**
- **Effort challenge**: The generator says "rename directory + update references." This is deceptively more work than it appears. A rename requires: directory rename, plugin.json update, all cross-references in SKILL.md files that mention run-task, wizard-guide, any documentation, and backward-compatibility aliasing. The effort is Small-Medium, not Small.
- **Risks**:
  - **Breaking change risk**: If any user has configured workflows or automation referencing `/run-task`, a rename breaks them. Even with an alias, this is a real migration concern.
  - The research explicitly assessed this as LOW priority with "developer clarity outweighs fantasy consistency for a utility skill."
  - The proposed names ("invoke-task", "conjure-task") are less clear about what the skill does than "run-task."
- **Recommendation**: **Reject** — The research said low priority and was right. Developer clarity beats thematic polish for a utility skill. The hidden breaking-change risk and reduced clarity make this net-negative. Not worth doing.

---

## Ranked Evaluation Summary

### Scoring Table (Priority Score = Impact × (4 - Effort))

| Rank | Idea | Effort | Impact | Score | Rec |
|------|------|--------|--------|-------|-----|
| 1 | #1 Persona Name Injection in Spawn Prompts | Small | High | 9 | Pursue |
| 1 | #2 Business Skills Section in wizard-guide | Small | High | 9 | Pursue |
| 1 | #3 wizard-guide in setup-project Next Steps | Small | High | 9 | Pursue |
| 1 | #5 Persona Identity Reinforcement in Protocol | Small | High | 9 | Pursue |
| 5 | #11 Validator: Spawn Prompt Persona Check | Medium | High | 6 | Pursue |
| 5 | #12 Business Tier 2: /run-business-ops | Medium | High | 6 | Pursue (with caveat) |
| 5 | #17 Cross-Skill Artifact Continuity Badge | Small | Medium | 6 | Pursue |
| 5 | #10 Persona System ADR | Small | Medium | 6 | Pursue |
| 5 | #6 Conclave Lore Preamble in wizard-guide | Small | Medium | 6 | Pursue |
| 5 | #16 Persona Spotlight in wizard-guide | Small | Medium | 6 | Pursue (constrained) |
| 11 | #7 Role-Based Principles Split | Medium | Medium | 4 | Pursue |
| 11 | #4 Persona-Aware run-task Archetypes | Medium | Medium | 4 | Pursue (after #1/#5) |
| 11 | #18 Contribution Guide Skill | Medium | Medium | 4 | Pursue |
| 11 | #15 /council-status Skill | Medium | Medium | 4 | Park |
| 15 | #8 Protocol Placeholder Fix | Small | Low | 3 | Pursue |
| 15 | #13 PoC Skills Quarantine (banner) | Small | Low | 3 | Pursue |
| 15 | #9 Stronger manage-roadmap Detection | Small | Low | 3 | Park |
| 18 | #14 Rename run-task | Small | Low | 3 | Reject |

---

## Tiered Groups

### Must-Do (Score 9, small effort, high impact, verified evidence)
1. **#1 Persona Name Injection in Spawn Prompts** — Activates 45-character system with line-level edits. CRITICAL pain point, HIGH confidence, maximum ROI.
2. **#2 Business Skills Section in wizard-guide** — Three production skills invisible at primary discovery point. One section addition.
3. **#3 wizard-guide in setup-project Next Steps** — Unlocks discovery funnel for new users. One bullet point.
4. **#5 Persona Identity Reinforcement in Communication Protocol** — Sustained persona presence vs one-time intro. Structural enforcement > LLM volition.

### Should-Do (Score 5-6, medium-effort or medium-impact items with strong evidence)
5. **#11 Validator: Spawn Prompt Persona Check** — Structural guarantee against persona regression. Sequence after #1.
6. **#12 Business Tier 2 Composite: /run-business-ops** — High potential. Requires discovery spike first to confirm artifact contracts.
7. **#17 Cross-Skill Artifact Continuity Badge** — Low effort, transparency + immersion gain. Bundle with Tier 2 work.
8. **#10 Persona System ADR** — Protects architectural investment. Write after #1/#5 are implemented.
9. **#6 Conclave Lore Preamble in wizard-guide** — Sets tone for all interactions. Bundle with wizard-guide enhancement pass (#2, #16).
10. **#16 Persona Spotlight in wizard-guide** — Makes personas concrete before first invocation. Bundle with #2 and #6; cap at 4-5 personas.

### Could-Do (Score 4, medium effort, medium impact, lower urgency)
11. **#7 Role-Based Principles Split** — Architecturally correct; requires validator updates. After higher-priority items.
12. **#4 Persona-Aware run-task Archetypes** — Natural follow-on after persona infrastructure is established (#1/#5/#11).
13. **#18 Contribution Guide Skill** — Implements existing P3-03 roadmap item. Standalone skill, not wizard-guide extension.

### Park / Reject
14. **#15 /council-status Skill** — Creative but no confirmed pain point. Park for P4.
15. **#8 Protocol Placeholder Fix** — Do in same pass as any protocol edits; too small to track separately.
16. **#13 PoC Skills Quarantine (banner only)** — Three minutes of work; do it when touching those files.
17. **#9 Stronger manage-roadmap Detection** — Theoretical risk only; park until a false-skip is observed.
18. **#14 Rename run-task** — **Reject**. Breaking change risk + reduced clarity. Research said LOW priority; the evaluation confirms it should not be done.

---

## Evaluator Notes

**Three ideas deserve bundled execution:**
- Pass 1: #1 + #5 + #8 (all spawn prompt / communication protocol changes; sync once after both)
- Pass 2: #2 + #3 + #6 + #16 (all wizard-guide + setup-project discovery changes)
- Pass 3: #11 validator (after Pass 1 so it doesn't immediately fail)

**One idea (#12) needs a discovery spike before committing:** read all three business SKILL.md files fully to determine if artifact contracts exist. If yes, it moves to Must-Do. If no, it's a multi-sprint item.

**One idea (#14) should not be done.** The research correctly flagged it as LOW. The evaluation confirms it's net-negative risk.

— Morwen Greystone, Transmutation Judge
