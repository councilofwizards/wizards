---
feature: "review-cycle-4"
team: "plan-product"
agent: "architect"
phase: "assessment"
status: "complete"
last_action: "Technical assessment of blocked P2 items and next feature candidates"
updated: "2026-02-19"
---

# Technical Assessment: Review Cycle 4

## Blocked P2 Items Assessment

### P2-02: Skill Composability — STILL BLOCKED

**Question**: Has the platform gap been resolved? Can Claude Code skills invoke other skills?

**Finding**: No. The P2-02 spec (docs/roadmap/P2-02-skill-composability.md) describes a `/run-workflow` skill that chains existing skills (plan -> build -> review). This requires skill-to-skill invocation — one skill programmatically invoking another skill. After reviewing all SKILL.md files and the plugin.json structure, there is no mechanism for this:

- Skills are invoked via `/command-name` by the user, not by other skills
- The `plugin.json` file is a simple metadata manifest with no inter-skill routing
- No SKILL.md references invoking another skill
- The Claude Code agent SDK provides `SendMessage` for agent-to-agent communication within a skill, but not skill-to-skill invocation across skill boundaries

**Evidence**: The 5 existing SKILL.md files all follow a pattern where the user invokes them directly. No skill reads another skill's SKILL.md or delegates to another skill. The handoff protocol described in P2-02 ("structured handoff format that one skill writes and the next skill reads") could work at the file level (one skill writes to `docs/specs/`, the next reads from there), but the orchestration — spawning the next skill in sequence — has no platform support.

**Recommendation**: P2-02 remains blocked. This is a Claude Code platform capability, not something we can build within the plugin system. Revisit when Claude Code supports skill chaining or plugin-to-plugin invocation.

### P2-07: Universal Shared Principles — APPROACHING THRESHOLD BUT NOT MET

**Question**: Have we hit the 3/8 threshold?

**Skill Count**: 5 SKILL.md files exist:
1. `/plan-product` (multi-agent, Hub-and-Spoke)
2. `/build-product` (multi-agent, Hub-and-Spoke)
3. `/review-quality` (multi-agent, Hub-and-Spoke)
4. `/setup-project` (single-agent)
5. `/draft-investor-update` (multi-agent, Pipeline)

**Shared content status**: 4 of 5 skills have shared content markers (`BEGIN SHARED: principles` and `BEGIN SHARED: communication-protocol`). The 5th (`/setup-project`) is single-agent and correctly excluded — it has no team to coordinate, so shared principles and communication protocol are irrelevant.

**Threshold calculation**: ADR-002 says "when the skill count exceeds 8, revisit this approach." The roadmap index references the "3/8 threshold" in context. There are currently 5 skills total, but only 4 multi-agent skills that carry shared content. We are at 4/8 for multi-agent skills — past 3/8 but well below the 8-skill extraction threshold.

**Current pain**: Editing shared content requires updating 4 files (plan-product, build-product, review-quality, draft-investor-update). The validator catches drift, so correctness is not at risk. But the next multi-agent skill added will make it 5 files.

**Recommendation**: P2-07 is NOT yet justified. ADR-002 explicitly sets the trigger at 8 skills. At 4 multi-agent skills, the maintenance burden is manageable with CI validation. However, we should note that the threshold is approaching — each new multi-agent skill increases the edit burden linearly. Consider re-evaluating when we reach 6 multi-agent skills rather than waiting for 8.

### P2-08: Plugin Organization — PREREQUISITE NOT YET MET

**Question**: Do we have 2+ business skills?

**Finding**: We have exactly 1 business skill (`/draft-investor-update`). The prerequisite in the roadmap index states "Defer plugin organization until 2+ business skills are built and validated."

**Current plugin structure**: All 5 skills live in `plugins/conclave/skills/`. There is a single plugin (`conclave`) with a simple `plugin.json`. The structure is flat and manageable at the current scale.

**Recommendation**: P2-08 remains deferred. Building a second business skill would meet this prerequisite and provide the real-world data needed to make informed plugin boundary decisions. Until then, reorganization is premature.

## Next Feature Candidates Assessment

### Candidate 1: Second Business Skill (advances P2-08)

Building a second business skill would unblock P2-08 and provide more data for the P2-07 threshold decision. From the business skills backlog:

**Strongest candidates by architectural simplicity**:

| Skill | Pattern | Complexity | Why |
|-------|---------|------------|-----|
| `/build-sales-collateral` (P3-16) | Pipeline | Low-Medium | Same Pipeline pattern as investor update. Sequential: Research -> Draft -> Review. Validates pattern reuse. |
| `/build-content` (P3-17) | Pipeline | Low-Medium | Same Pipeline pattern. Content production is structurally similar to investor updates. |
| `/plan-customer-success` (P3-15) | Collaborative Analysis | Medium | New pattern (Collaborative Analysis). Would validate a second consensus pattern. |
| `/plan-sales` (P3-10) | Collaborative Analysis | Medium | New pattern. Research-heavy, but involves market data the project may not have. |

**Architectural recommendation**: `/build-sales-collateral` or `/build-content` would be the lowest-risk choices because they reuse the Pipeline pattern already proven by `/draft-investor-update`. This validates that the pattern is genuinely reusable, not just a one-off. However, if the goal is to validate more of the business skill design guidelines, a Collaborative Analysis skill like `/plan-customer-success` would cover more ground.

### Candidate 2: P3-03 Architecture & Contribution Guide

**Complexity**: Small. ADR-003 already identifies this as "the next likely candidate for the single-agent pattern." It is a documentation-generation utility with deterministic output.

**Architectural significance**: Low — it reuses the single-agent pattern from `/setup-project` with no new patterns.

**Value**: Moderate. Having a contribution guide enables external contributors to add skills and stack hints. But this is primarily a documentation task, not an architectural advancement.

### Candidate 3: Engineering Skills (P3-04 through P3-07)

These are interesting but none have roadmap item files yet (P3-04, P3-05, P3-06, P3-07 are listed in _index.md but no individual files exist). They would need spec work from scratch.

**P3-04 (Incident Triage)**: Uses Hub-and-Spoke with dual-skeptic (Quality + Ops). Structurally similar to existing engineering skills but with the dual-skeptic pattern from investor updates. Medium complexity.

**P3-06 (API Design)**: Uses Hub-and-Spoke with dual-skeptic (Consistency + Consumer Advocate). Another dual-skeptic variation. Medium complexity.

### Candidate 4: P3-01 Custom Agent Roles

**Complexity**: Large. This changes the core framework — skills would need to read role definitions at startup and compose teams dynamically. It touches every multi-agent SKILL.md.

**Recommendation**: Too early. We need more skills (and thus more role diversity) to understand the actual customization needs before designing a generic role system.

## Architectural Implications Summary

| Candidate | Patterns Validated | P2 Items Advanced | Risk | Effort |
|-----------|-------------------|-------------------|------|--------|
| 2nd business skill (Pipeline) | Pipeline reuse | P2-08 (2/2 business skills) | Low | Small-Medium |
| 2nd business skill (Collab. Analysis) | New consensus pattern | P2-08 (2/2 business skills) | Medium | Medium |
| P3-03 Contribution Guide | Single-agent reuse | None | Very Low | Small |
| Engineering skill (P3-04/06) | Dual-skeptic in eng. context | None directly | Medium | Medium |
| P3-01 Custom Agent Roles | Framework extension | None | High | Large |

## Recommendation

**Primary recommendation**: Build a second business skill using the Pipeline pattern. `/build-sales-collateral` (P3-16) is the strongest candidate:
- Reuses the Pipeline pattern, validating it was well-designed (not just investor-update-specific)
- Unblocks P2-08 (plugin organization) with 2 business skills
- Builds toward the P2-07 threshold (adds skill #6)
- Lower risk than a Collaborative Analysis skill because the Pipeline pattern is already proven
- Structurally similar to investor update: Research -> Draft -> Review, with dual-skeptic gate

**Secondary recommendation**: If the team wants pattern diversity over risk reduction, `/plan-customer-success` (P3-15) using the Collaborative Analysis pattern would validate a second consensus-building approach. Higher risk, higher learning.

**Not recommended**: P3-03 (low architectural value), P3-01 (premature), P2-02 (still blocked by platform).

## ADR Review

| ADR | Impact on This Decision |
|-----|------------------------|
| ADR-001 (Roadmap Structure) | No impact. Well-established pattern. |
| ADR-002 (Content Deduplication) | Sets the 8-skill extraction threshold. At 5 skills (4 with shared content), we are not there yet. Each new multi-agent skill adds to the maintenance burden. |
| ADR-003 (Single-Agent Pattern) | Established the precedent for single-agent utility skills. Only relevant if P3-03 is selected. |
| Business Skill Design Guidelines | Defines Pipeline, Collaborative Analysis, and Structured Debate patterns with skeptic assignments. The next business skill should follow these guidelines. |
