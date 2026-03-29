---
feature: "conclave-plugin-improvements"
team: "research-market"
agent: "market-researcher"
phase: "research"
status: "complete"
last_action: "Completed full architectural investigation; findings compiled and submitted to Team Lead"
updated: "2026-03-10T00:00:00Z"
---

## Progress Notes

- [00:00] Task claimed — investigating Conclave plugin internal architecture
- [00:10] Read all 18 SKILL.md files across Tier 1, Tier 2, utility, business, and PoC categories
- [00:20] Read all 6 validators (A-F series)
- [00:30] Read 10+ persona files across teams
- [00:40] Read ADR-004 (two-tier architecture) and ADR-002 (content deduplication)
- [00:50] Compiled findings and submitted to Team Lead

## Key Findings Summary

### Skill Architecture

- 18 skills: 9 Tier 1, 2 Tier 2, 2 utility, 3 business, 2 PoC
- Structural consistency is HIGH across all 9 Tier 1 multi-agent skills
- Tier 2 composites correctly avoid shared content markers and spawn definitions
- Single-agent skills correctly omit those sections too
- Business skills (plan-hiring, plan-sales, draft-investor-update) are structurally different by design — larger, with
  embedded output templates

### Gaps Identified

1. B2 normalizer only handles 13 skeptic name pairs; bias-skeptic and fit-skeptic (plan-hiring) are present in
   normalizer but communication protocol for plan-hiring references them — should be confirmed passing
2. tier1-test has both `tier: 1` AND `type: single-agent` — an unusual combination not documented in ADR-004
3. Shared Principles contain engineering-specific rules (TDD, unit tests, API contracts) that don't apply to
   business/planning skills — medium relevance mismatch
4. Validators do NOT check: spawn prompt quality, artifact contract conformance at runtime, or persona cross-reference
   accuracy
5. No ADR exists for persona system design decisions

### Persona System

- 46 personas found — all consistently structured with YAML frontmatter, Identity, Role, Critical Rules,
  Responsibilities, Output Format, Write Safety, Cross-References sections
- Fantasy theme applied consistently (names, titles all have a fantasy aesthetic)
- Agent-to-agent communication style is identical across ALL personas (verbatim: "Direct, terse, businesslike...")
- Cross-references appear accurate in the personas sampled
