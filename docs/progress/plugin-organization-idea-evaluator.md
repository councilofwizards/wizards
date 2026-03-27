---
feature: "plugin-organization"
team: "plan-product"
agent: "idea-evaluator"
phase: "ideation"
status: "complete"
last_action: "Evaluations complete — submitted to Team Lead"
updated: "2026-03-27T17:35:00Z"
---

## Progress Notes

- [17:22] Task claimed — P2-08 Idea Evaluation assigned
- [17:23] Read role definition (idea-evaluator.md persona)
- [17:23] Read research artifact (docs/research/plugin-organization-research.md)
- [17:24] Read customer-researcher and market-researcher progress files
- [17:25] Idea generator output not yet available — evaluation framework prepared
- [17:30] Idea generator output available — 8 ideas from Solara Brightforge
- [17:35] Evaluations complete — all 8 ideas evaluated and ranked

---

## Evaluation Framework

### Evidence Base

**Core constraints** (all HIGH confidence from direct code inspection):
1. B-series validators hardcode `plugins/conclave/shared/` — splitting skills breaks them immediately
2. 40+ persona files have cross-domain dependencies — splitting shared/ requires duplication or abstraction
3. Sync script source is conclave-specific; target discovery is already multi-plugin safe
4. A/C/D/E/F-series validators are multi-plugin safe — only B-series is at risk
5. 3 business skills today: insufficient to justify split overhead for bridge users
6. P3 trajectory (10+ business skills) is the real architectural forcing function

**Primary segment at risk**: Bridge users / Technical Founders — a split increases their friction.

---

## Evaluations

---

### EVALUATION: Idea 1 — Category Metadata in Skill Frontmatter + Plugin Manifest

**Market Evidence**: STRONG — research directly states "internal reorganization via category metadata is the dominant strategy." php-tomes precedent validates single-plugin-with-taxonomy. Machine-readable taxonomy is a prerequisite for every other idea in this set.

**User Impact**: NEUTRAL-POSITIVE — invisible to users today; enables better tooling for all segments later. Bridge users unaffected. Engineers and founders gain eventual filtered views.

**Strategic Fit**: HIGH — this is the foundational taxonomy that future ideas (and the eventual clean split) depend on. Without it, category-based routing, tags, and split readiness checks have no authoritative basis.

**Feasibility**: HIGH — purely additive frontmatter to 17 SKILL.md files + plugin.json. No sync script, no validator, no shared content changes required. Optional A-series check can enforce the field if desired.

**Effort**: Very Low — ~17 frontmatter edits + plugin.json update. One PR, one hour.

**Recommendation**: PURSUE

**Rationale**: Zero risk, foundational value. Every other idea in this set either depends on or is strengthened by having a machine-readable category taxonomy. This should be the first implementation.

---

### EVALUATION: Idea 2 — Parameterized Shared Content Infrastructure

**Market Evidence**: STRONG — research identifies the hardcoded `SHARED_DIR` variable as the primary technical blocker. "All three break simultaneously if skills move to a new plugin." This idea directly removes that constraint.

**User Impact**: NONE — zero user-facing change. Default behavior preserved.

**Strategic Fit**: HIGH — removes the #1 infrastructure blocker to any future split. Without this, every split option costs a full infra rewrite. With this, the split cost drops to a config change.

**Feasibility**: HIGH — refactoring `SHARED_DIR` to an env variable with a default in two bash scripts is ~20 lines of code. B-series validator and sync script both follow the same pattern; the change is mechanical and self-contained.

**Effort**: Very Low — ~20 lines of bash across 2 files. Single PR.

**Recommendation**: PURSUE

**Rationale**: Extreme value-to-effort ratio. Converts "future split = expensive infra rewrite" to "future split = update one env variable." Should be done now while the codebase is small and the change is trivial.

---

### EVALUATION: Idea 3 — Progressive Disclosure in wizard-guide (Role-Gated Skill Menu)

**Market Evidence**: MODERATE — research confirms Founders/Operators find engineering terminology confusing, and wizard-guide already separates business from engineering. Pain is LOW today but projected to grow to MEDIUM at P3 scale (27+ skills).

**User Impact**: POSITIVE for all segments — engineers skip business noise, founders skip engineering jargon, bridge users retain full access via "show all" escape hatch. No segment is harmed.

**Strategic Fit**: MEDIUM — solves the UX discovery problem without any structural changes. Doesn't address split architecture, but reduces urgency of a split for purely UX reasons.

**Feasibility**: HIGH — wizard-guide is a single-agent skill. Adding a role-selection prompt and routing logic is markdown-level work. No validators affected (single-agent skills are skipped by shared content checks). No sync required.

**Effort**: Low — wizard-guide SKILL.md edit only. One PR.

**Recommendation**: PURSUE

**Rationale**: Addresses the Founders/Operators UX pain point today at near-zero cost, and scales to 27+ skills without any infrastructure changes. Reduces one key argument for doing a split prematurely.

---

### EVALUATION: Idea 4 — Virtual Plugin Boundaries via Skill ID Namespacing

**Market Evidence**: MODERATE — research supports the concept of explicit boundaries, but the boundary problem is already being solved by Idea 1 (category metadata). The `id: biz/plan-sales` prefix approach is additive but largely redundant with categories.

**User Impact**: NONE — invisible to users.

**Strategic Fit**: LOW-MEDIUM — creates migration path alignment for a future split (directory structure could mirror namespace), but this value is also delivered by Idea 1. The unique value-add is the explicit naming convention that aligns code location with identifier — useful but not essential.

**Feasibility**: HIGH — additive frontmatter only. Near-zero risk.

**Effort**: Very Low — but delivers diminishing returns if Idea 1 is implemented.

**Recommendation**: DEFER

**Rationale**: Overlaps heavily with Idea 1. If category metadata is implemented, virtual namespacing adds marginal value. Fold the namespace prefix concept into Idea 1's implementation if desired; don't implement as a separate track.

---

### EVALUATION: Idea 5 — Shared Persona Layer Extracted to Standalone Module

**Market Evidence**: MODERATE — research identifies persona coupling as a genuine blocker. "A domain split requires either persona duplication (drift risk) or a new shared abstraction layer." This idea solves the right problem.

**User Impact**: NONE — invisible to users.

**Strategic Fit**: HIGH in principle — removes the last hard coupling blocker after Ideas 1+2. However, timing is wrong: P3 hasn't started, and we don't know the final distribution of cross-domain vs. domain-specific personas. Premature extraction risks over-engineering a structure before the full picture is known.

**Feasibility**: MEDIUM — moves 40+ files, requires sync script + B-series validator updates. Novel `plugins/shared-personas/` pattern not validated by current infrastructure. The A-series validator uses `find plugins/ -path "*/skills/*/SKILL.md"` and won't interfere, but sync script changes are non-trivial. Risk of breaking 12/12 validator compliance during transition.

**Effort**: Medium — 40+ persona files to categorize and move, sync script refactor, validator update. Multi-day work.

**Recommendation**: DEFER (P3-gate)

**Rationale**: High future value but premature today. The full persona dependency graph won't be clear until P3 business skills land. Doing this work now risks extracting the wrong things. Idea 6 (ADR + automated gate) will signal the right time to do this work. Make it a prerequisite in ADR-005.

---

### EVALUATION: Idea 6 — Split Readiness ADR + Automated Gate

**Market Evidence**: STRONG — research confidence on the split threshold is explicitly LOW ("No comparable ecosystem data; educated estimate"). This idea converts that low-confidence estimate into a documented, automatable decision rule. The research even flags this risk: "Depends on P3 execution pace and domain distribution."

**User Impact**: NONE — documentation and a WARN-level validator output.

**Strategic Fit**: VERY HIGH — highest value-to-effort ratio in this set. Prevents the team from re-researching P2-08 when P3 completes. Encodes the current research consensus into a durable decision artifact. Creates accountability for the trigger condition.

**Feasibility**: HIGH — ADR document + ~10 lines of bash in an existing or new validator. Existing validator pattern well-understood (already have 6 validators). Validator emits WARN (not FAIL) so 12/12 hard checks still pass.

**Effort**: Very Low — half-day work.

**Recommendation**: PURSUE

**Rationale**: Insurance policy against P3 re-work at essentially zero cost. The split threshold question will be asked again at P3 completion; this answer should not need to be derived from scratch. ADR-005 should list Ideas 2+5 as technical prerequisites for the split.

---

### EVALUATION: Idea 7 — Skill Discovery Tags + wizard-guide Search

**Market Evidence**: MODERATE — research identifies skill discovery as a growing concern at 27+ skills. php-tomes uses topic organization effectively. Tags are the data layer that scales to filtered views in future tooling.

**User Impact**: POSITIVE — improves discoverability across all segments. Pairs with Idea 3 (role-gated menu) to give wizard-guide a richer navigation model.

**Strategic Fit**: MEDIUM — complements Idea 1 (category is single-value; tags are multi-value). Together they give both coarse classification and fine-grained labeling. Useful at 17 skills; essential at 27+.

**Feasibility**: HIGH — additive frontmatter + wizard-guide SKILL.md update. No sync or validator risk.

**Effort**: Low-Medium — 17 tag sets to define + wizard-guide update. Can be batched with Idea 1.

**Recommendation**: PURSUE (batch with Idea 1)

**Rationale**: Complementary to category metadata, not redundant. Categories classify domain; tags describe use cases, patterns, and co-invocation context. Implement together with Idea 1 as a single "taxonomy" PR.

---

### EVALUATION: Idea 8 — Incremental Split Pilot — Business Skills Only

**Market Evidence**: WEAK for current implementation. Research is unambiguous: "3 business skills is not enough to justify the installation friction of a split for bridge users." The pilot framing is clever, but the research already tells us the answer: the split costs more than it delivers at current scale.

**User Impact**: NEGATIVE for primary segment — bridge users (technical founders) now need 2 install steps. Research identifies this as the #1 friction concern from a split.

**Strategic Fit**: LOW for production. MEDIUM as a pure learning spike — but even as a spike, it creates real production friction that must be undone. The better learning vehicle is Idea 6 (ADR documents what we'd do) + Idea 2 (remove the infrastructure blocker so when we actually do split, it costs 20 lines of bash instead of a full rewrite).

**Feasibility**: LOW without prerequisites — B-series validators immediately fail when business skills move directories. MEDIUM after Ideas 2+5 are complete. Timing mismatch: Ideas 2+5 should precede this, but they're currently deferred/marked as future work.

**Effort**: High without prerequisites; Medium after. But in either case, the split must later be undone OR maintained — creating ongoing overhead.

**Recommendation**: REJECT (now) — revisit when P3 business skill count hits 7 AND ADR-005 trigger conditions are met.

**Rationale**: The research's primary finding is that 3 business skills don't justify split overhead for the primary user segment. Even as a "learning spike" this creates real friction. The right path is: build the infrastructure (Ideas 2+5) and document the trigger (Idea 6), then split when the count warrants it. The pilot creates the problem before we have the solution.

---

## Priority Ranking

| Rank | Idea | Recommendation | Rationale |
|------|------|----------------|-----------|
| 1 | Idea 1: Category Metadata | PURSUE | Foundational taxonomy; prerequisite for everything else |
| 2 | Idea 2: Parameterized Shared Content Infra | PURSUE | Removes #1 technical blocker; ~20 lines of bash |
| 3 | Idea 6: Split Readiness ADR + Automated Gate | PURSUE | Highest value-to-effort ratio; prevents P3 re-research |
| 4 | Idea 3: Progressive Disclosure in wizard-guide | PURSUE | Solves Founders/Operators UX pain today; zero risk |
| 5 | Idea 7: Skill Discovery Tags | PURSUE (batch with #1) | Complementary to categories; implement together |
| 6 | Idea 4: Virtual Namespacing | DEFER | Redundant with Idea 1; fold in or skip |
| 7 | Idea 5: Shared Persona Extraction | DEFER (P3-gate) | Right idea, wrong time; do after P3 domain distribution is known |
| 8 | Idea 8: Split Pilot | REJECT | Premature; harms primary segment; revisit at ADR-005 trigger |

---

## Cross-Cutting Notes

**Ideas 1 + 7 should be implemented together** as a single "skill taxonomy" PR. Both are additive frontmatter; doing them separately creates two rounds of 17-file edits.

**Ideas 2 + 5 are prerequisites for any future split**. ADR-005 (Idea 6) should list them as technical gates. Neither is urgent today, but Idea 2 is so cheap (~20 lines) that it should be done now while it's trivial.

**Idea 8 becomes viable only after**: (a) ADR-005 trigger conditions are met (7+ business skills), AND (b) Ideas 2 + 5 are complete. Until both are true, don't revisit.

**12/12 validator compliance**: All PURSUE ideas are safe. Ideas 1, 2, 3, 6, 7 are additive-only or behavior-neutral. Idea 6's automated gate emits WARN, not FAIL — hard check count unchanged.
