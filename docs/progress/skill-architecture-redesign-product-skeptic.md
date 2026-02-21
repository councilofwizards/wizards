---
feature: "skill-architecture-redesign"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Re-review of revised architecture. All blocking and structural issues resolved. Verdict: APPROVED."
updated: "2026-02-21T16:00:00Z"
---

# Skill Architecture Redesign -- Product Skeptic Review (Revised)

## Review Summary

REVIEW: Two-tier skill architecture design v2 (revised architect checkpoint + revised ADR-004)
Verdict: **APPROVED**

All 3 blocking issues, all 5 structural issues, and all 4 advisory notes from the initial review have been addressed. Two items deserve continued vigilance during implementation (noted below), but none block approval.

---

## Issue-by-Issue Resolution Assessment

### Blocking Issues -- All Resolved

**B1: Tier 2 invocation mechanism (was BLOCKING, now RESOLVED)**

The architect identified the Skill tool as the invocation mechanism with explicit syntax: `Skill(skill: "conclave:write-spec", args: "feature-name")`. The design now specifies:
- Context persistence: Tier 2 lead's context persists across Skill tool calls.
- Checkpoint coexistence: Tier 1 uses `{feature}-{role}.md`, Tier 2 uses `{feature}-{tier2-skill}-lead.md`. No collision.
- Phase 0 proof-of-concept: Must validate all four properties (invocation works, context persists, artifacts readable, checkpoints don't collide) before proceeding.
- Documented fallback: If Phase 0 fails, Tier 2 becomes monolithic skills with modular internal prompts.

This is the correct approach. The mechanism is specified, the PoC gates further investment, and the fallback prevents a dead-end. **Resolved.**

One note for implementation: the Skill tool invocation syntax `Skill(skill: "conclave:write-spec", args: "feature-name")` uses a plugin-qualified name. Phase 0 must test this exact syntax, not a shorthand. If the Skill tool requires `"write-spec"` without the `conclave:` prefix, or uses a different argument format, the SKILL.md instructions need to match the actual tool behavior exactly.

**B2: discover-product (was BLOCKING, now RESOLVED)**

Removed from the design. Skill count reduced from 13 to 12 (8 Tier 1 + 2 Tier 2 + 2 Utility). The ADR's "Alternatives Considered" section documents the rejection with correct rationale: achievable via Tier 1 direct invocation or plan-product's artifact detection. Architecture supports adding it later. **Resolved.**

**B3: Validator migration interleaving (was BLOCKING, now RESOLVED)**

Every migration phase now includes specific validator updates with `bash scripts/validate.sh` as a gate at each phase boundary. Phase-by-phase breakdown:
- Phase 0: No validator changes (PoC only).
- Phase 1: A1 (new frontmatter), A4/B-series (shared content extraction), F-series stub.
- Phase 2: A2, A3, F-series for 5 new Tier 1 skills.
- Phase 3: A2, A3, F-series for 2 new Tier 1 skills.
- Phase 4: A2, A3 for Tier 2 composite patterns (different required sections, Skill tool syntax instead of spawn blocks).
- Phase 5: A2, A3 for utility skill patterns.

No deferred "Phase 6 cleanup." Validation passes at every boundary. **Resolved.**

---

### Structural Issues -- All Resolved

**S4: Artifact detection logic (was too coarse, now RESOLVED)**

The architect added a precise, formal artifact detection algorithm with five checks: file existence, type field validation, feature/topic field matching, staleness (research-findings only, using frontmatter `expires` field not mtime), and status-awareness (draft artifacts don't satisfy detection). Four named return states: FOUND, STALE, INCOMPLETE, NOT_FOUND.

Key properties are correct: feature-scoped, type-validated, status-aware. The algorithm prevents the false-skip scenarios I raised (feature-X research satisfying feature-Y, mtime unreliability). **Resolved.**

**S5: Failure propagation (was undefined, now RESOLVED)**

Two-path model defined:
- Path A (standalone): Current behavior unchanged. Skeptic deadlock after 3 rejections escalates to user.
- Path B (inside composite): Skeptic deadlock produces checkpoint with `status: "escalated"`. Tier 2 lead reads this and has three options: re-invoke with guidance (max 1), skip if non-critical, or escalate to user.
- Maximum nesting depth: Tier 2 -> Tier 1 only. No recursive invocation.
- Failure signal mechanism: checkpoint with `status: "escalated"` and `escalation_reason`.

This is well-specified. The max-1-retry limit prevents infinite loops. The checkpoint-based signaling is consistent with the existing checkpoint infrastructure. The nesting depth limit is important and correctly stated. **Resolved.**

**S6: P2-07 hard dependency (was deferred to Phase 6, now RESOLVED)**

P2-07 is now explicitly in Phase 1 with a concrete mechanism: sync script that reads from `plugins/conclave/shared/` authoritative sources and replaces content between existing `<!-- BEGIN SHARED: X -->` markers. This preserves SKILL.md self-containment (shared content remains inline) while automating synchronization. The `<!-- INCLUDE -->` directive approach from v1 is gone -- correctly abandoned since Claude Code doesn't process include directives.

The sync script approach is clever: it uses the existing marker infrastructure from ADR-002, just inverts the workflow from "manual edit + CI drift detection" to "automated sync + CI verification." B-series validators continue to work unchanged in purpose (verify content identity), just with more files. **Resolved.**

**S7: run-task type contradiction (was contradictory, now RESOLVED)**

Explicitly stated as multi-agent with dynamic team composition. The `type: single-agent` reference is removed. ADR Part 1 describes it as "generic multi-agent ad-hoc team with dynamic composition." Architect document specifies "Frontmatter type: Default (multi-agent). No `type: single-agent` flag." **Resolved.**

**S8: idea-generator archetype (was Builder, now RESOLVED)**

Retyped from Builder to Scout. Rationale documented: "Idea generation is a creative divergent task -- the Scout archetype's mandate to 'present options with trade-offs, recommendations, confidence levels' aligns better than the Builder's 'produce the simplest thing that works.'" Sonnet retained with documented quality trade-off and escape hatch: "If ideation quality proves insufficient with Sonnet, the --light flag pattern can be inverted: standard mode uses Opus for idea-generator, --light uses Sonnet." **Resolved.**

---

### Advisory Notes -- All Addressed

**A9: Concurrent Tier 2 invocation (now documented)**

Documented in both the architect checkpoint and ADR Part 1: "Concurrent invocation of the same Tier 1 skill by multiple Tier 2 composites is unsupported and may produce artifact conflicts. This is acceptable for the initial design -- users should not run composites simultaneously." **Addressed.**

**A10: Archetype-to-behavioral-prompt requirement (now in ADR)**

ADR Part 6 states: "Each SKILL.md must translate archetype assignments into specific behavioral instructions in the spawn prompts. Listing 'Scout' in an architecture table is a design aid; the SKILL.md's actual agent prompt is the implementation." Architect document includes this as Design Principle #8. **Addressed.**

**A11: setup-project changes (now specified)**

New directories listed: `docs/research/`, `docs/ideas/`, `docs/templates/`, `docs/templates/artifacts/`. New template files: research-findings.md, product-ideas.md, user-stories.md, implementation-plan.md. CLAUDE.md template updates: Project Structure section and Workflow section with new skill references. **Addressed.**

**A12: ideate-product / manage-roadmap merge consideration (kept separate with justification)**

The architect provides a specific rationale: "ideate-product and manage-roadmap serve different purposes invoked at different frequencies. ideate-product runs when exploring new feature space -- creative, divergent work. manage-roadmap runs for reprioritization, dependency analysis, and status updates -- analytical, convergent work. The standalone manage-roadmap use case (invoked via plan-product's 'reprioritize' argument or directly) is the most frequent lightweight invocation pattern. Merging would force the roadmap reprioritization path to load ideation prompts and agent definitions unnecessarily, recreating the context-waste problem this architecture solves."

This justification is sound. The context-waste argument is the core motivation of the architecture, and a merge would undermine it for the most common lightweight use case. I accept this decision. **Addressed.**

**A13: Skill discovery mechanism (now documented)**

ADR Part 8 and architect document both state: "Claude Code discovers skills via directory-based scanning: it looks for SKILL.md files at `plugins/{plugin}/skills/{skill-name}/SKILL.md`. Adding a new skill directory with a valid SKILL.md is sufficient for discovery. The plugin manifest does not enumerate skills and does not need updating." **Addressed.**

---

## Items Requiring Continued Vigilance During Implementation

These are not blocking issues. They are risks that the design correctly acknowledges but which need attention during execution:

1. **Phase 0 PoC is a genuine gate.** The entire Tier 2 layer depends on the Skill tool behaving as specified. If Phase 0 reveals unexpected behavior (e.g., context loss between Skill tool calls, checkpoint collisions, or the tool not supporting plugin-qualified names), the fallback design changes the implementation significantly. The team should not begin Phase 1 until Phase 0 passes cleanly.

2. **Product-ideas artifact may prove unnecessary.** The product-ideas artifact exists solely as a handoff between ideate-product and manage-roadmap. If in practice ideate-product and manage-roadmap are always invoked sequentially (via plan-product composite), the product-ideas file becomes bureaucratic overhead. Monitor whether this artifact provides value in practice or if it should be folded into the ideation skill's internal process. This is not a design flaw -- the architecture correctly defines the artifact -- but it may be optimized away post-launch.

3. **The 12-to-16 skill jump is substantial.** The plugin goes from 7 total skills to 16 (12 new engineering + 3 existing business + setup-project). The shared content sync script and validator interleaving mitigate maintenance risk, but the team should track how much time is spent on cross-skill synchronization. If it exceeds expectations, the ADR-002 extraction threshold decision was correct but the sync mechanism may need further automation.

---

## Verdict

**APPROVED.**

The revised architecture resolves all blocking issues, all structural issues, and all advisory notes from the initial review. The Tier 1/Tier 2 decomposition is the right pattern for the stated problems. The artifact contract system with consumer-owns-template is well-designed. The migration plan is incremental with validation gates at every phase boundary. The Phase 0 PoC correctly gates the highest-risk assumption. The failure propagation model is specified with appropriate depth limits.

The design is ready to proceed to Phase 0 (proof of concept).
