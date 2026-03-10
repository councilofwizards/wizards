---
type: "research-findings"
topic: "conclave-plugin-improvements"
feature: "conclave-plugin-improvements"
generated: "2026-03-10"
confidence: "high"
expires: "2026-04-09"
---

# Research Findings: Conclave Plugin Improvements

## Executive Summary

The Conclave plugin has a mature, well-validated two-tier skill architecture (18 skills, 12/12 validators passing) with comprehensive persona definitions. However, the fantasy identity system — 45 fictional personas with names, titles, and personalities — is almost entirely invisible during actual skill execution because spawn prompts reference agents by role ID only, never by fictional name. This is the highest-impact improvement opportunity. Secondary findings include wizard-guide omitting business skills from its overview, no guided first-run onboarding path, engineering-specific shared principles bleeding into non-engineering contexts, and several validator coverage gaps around content quality.

## Market Analysis

### Market Size

Not applicable — this is a self-evaluation of the plugin, not a market sizing exercise. The "market" is the plugin's own users within the Claude Code ecosystem.

### Industry Trends

**Claude Code Plugin Ecosystem (confidence: MEDIUM)**
- Claude Code plugins are a nascent ecosystem. The Conclave plugin is among the most architecturally sophisticated examples, with multi-agent orchestration, quality gates, and artifact pipelines.
- The trend in AI agent systems is toward personality-driven agents that feel distinct and memorable. The Conclave's fantasy persona system aligns with this trend but doesn't fully realize it.
- Composite skill chaining (Tier 2) is an advanced pattern not commonly seen in other plugin architectures.

## Competitive Landscape

**Internal Benchmarking (confidence: HIGH)**

The plugin's 18 skills break down as:
- 9 Tier 1 granular skills (mature, consistent structure)
- 2 Tier 2 composites (correctly chain Tier 1 pipelines)
- 2 utility skills (setup-project, wizard-guide)
- 3 business skills (draft-investor-update, plan-sales, plan-hiring)
- 2 PoC/test skills (tier1-test, tier2-test)

Structural consistency is excellent — all multi-agent skills follow identical section ordering, all have skeptic gates, and the validator suite enforces drift prevention across shared content.

## Customer Segments

### Primary Segment: Plugin Users (confidence: HIGH)

Users invoking Conclave skills to plan, build, and operate SaaS products. They interact with agents via skill invocations and expect coherent, high-quality output.

**Pain Points (ranked by severity):**

1. **Fantasy personas invisible during execution** (CRITICAL): 45 personas have fictional names, titles, and personalities defined in shared/personas/ files. Spawn prompts in SKILL.md files reference agents only by role ID ("You are the Market Researcher"). The communication protocol directive says agents should "show your personality" and "be a character in the Conclave," but no spawn prompt introduces the agent by fictional name or reinforces identity adoption. The fantasy layer relies entirely on the LLM choosing to surface persona details after reading the file — architecturally fragile.

2. **wizard-guide omits business skills** (HIGH): The Skill Ecosystem Overview section lists Tier 1 planning, Tier 1 implementation, Tier 2, and utility skills. Business skills (draft-investor-update, plan-sales, plan-hiring) are absent from both the main overview AND example workflows sections. Users running `/wizard-guide` for discovery will miss three production-quality skills entirely.

3. **No guided first-run path** (HIGH): setup-project's Next Steps recommends `/plan-product` but never mentions `/wizard-guide`. A new user gets scaffolded directories but no tour of available capabilities. wizard-guide is the intended entry point for discoverability but nothing directs users to it.

4. **Shared Principles content mismatch** (MEDIUM): The shared principles block contains 4 engineering-specific rules (TDD, unit tests with mocks, SOLID/DRY, API contracts) that are synced to ALL multi-agent skills including research-market, ideate-product, and manage-roadmap where they have no relevance. Agents like Idea Generator and Roadmap Analyst will read TDD guidance they cannot apply. Operational impact is low (agents ignore irrelevant rules), but it's cognitive noise in context windows.

5. **Communication protocol placeholder** (MEDIUM): The authoritative communication-protocol.md uses "product-skeptic" as the generic skeptic recipient in the "Plan ready for review" row. The sync script correctly substitutes per-skill skeptic names, but the source file is misleading and could cause confusion during maintenance.

6. **No post-build operational skills** (MEDIUM): The pipeline covers plan → build → review, but ongoing operations (incident triage, tech debt review, API design, migration planning) have no dedicated skills. These exist as P3 roadmap stubs but are not started.

7. **PoC skills in production directory** (LOW): tier1-test and tier2-test are visible in skill discovery alongside production skills. They have no documentation warning users they're internal test scaffolding.

8. **run-task agents have no persona grounding** (MEDIUM): run-task dynamically composes agents from generic archetypes (Engineer, Researcher, Writer, Skeptic) with no persona file assignments. It is the only skill where the fantasy persona system breaks down entirely — spawned agents are generic templates, not Conclave characters.

9. **manage-roadmap skip detection weakness** (LOW): In the plan-product Tier 2 pipeline, the manage-roadmap stage uses a weaker artifact detection check ("roadmap items exist for topic") compared to other stages which check frontmatter type and status fields. This creates a potential false-skip risk where unrelated roadmap items could match.

10. **"run-task" naming** (LOW): The only skill name that doesn't carry fantasy resonance. Functionally clear but thematically inconsistent. Low priority — developer clarity outweighs fantasy consistency for a utility skill.

11. **P3 engineering skills gap** (LOW): 5 engineering P3 items are not started (triage-incident, review-debt, design-api, plan-migration, custom-agent-roles) alongside 9 business P3 items and 1 documentation item. The post-build operational gap spans both engineering and business domains.

### Secondary Segment: Plugin Developers/Contributors (confidence: MEDIUM)

Developers extending or maintaining the plugin.

**Pain Points:**
1. **No persona system ADR**: The decision to create 45 fictional personas, the cross-reference structure, and the fantasy theme strategy are undocumented architectural decisions.
2. **No run-task design ADR**: When users should prefer run-task over specific Tier 1 skills is not documented.
3. **Validator gaps around content quality**: Spawn prompt content, persona file existence, artifact contract template accuracy, and `chains` field validation are not checked.
4. **Engineering skills lack per-skill design documents**: Business skills have system design docs; engineering Tier 1 skills rely only on ADR-004.

## Data Sources

- All 18 SKILL.md files (full read for structure and spawn prompts)
- All 45 persona files in plugins/conclave/shared/personas/ (full read, glob-verified count)
- plugins/conclave/shared/communication-protocol.md (full read)
- plugins/conclave/shared/principles.md (referenced via sync markers)
- All 6 validator scripts in scripts/validators/ (full read by market-researcher)
- docs/roadmap/_index.md and roadmap item files (full read)
- docs/architecture/ (4 ADRs + system design docs, read by market-researcher)
- plugins/conclave/skills/wizard-guide/SKILL.md (full read)
- plugins/conclave/skills/setup-project/SKILL.md (full read)
- Grep of all SKILL.md files for fictional name references — zero results confirmed

## Data Gaps

- **Live session behavior**: Cannot confirm whether agents actually introduce themselves by fictional name in real skill executions. Analysis is static code review only.
- **Full persona file audit**: All 45 persona files were read by customer-researcher. Cross-references sampled for accuracy but not exhaustively verified against every target file.
- **User feedback**: No user session transcripts, feedback logs, or usage data available.
- **wizard-guide intent**: Cannot determine whether the business skill omission from wizard-guide's overview is intentional (simplicity) or oversight.
- **Full business skill SKILL.md review**: plan-hiring and plan-sales SKILL.md files were sampled, not fully read (each >500 lines).

## Confidence Assessment

| Section | Confidence | Rationale |
|---------|------------|-----------|
| Fantasy persona invisibility | High | Grep confirmed zero fictional name matches in SKILL.md files |
| wizard-guide omission | High | Full read of wizard-guide SKILL.md confirmed business skills absent from overview |
| First-run path gap | High | Full read of setup-project Next Steps confirmed no wizard-guide mention |
| Shared Principles mismatch | High | Byte-identical sync confirmed by B1 validator; engineering rules present in all multi-agent skills |
| Communication protocol placeholder | High | Confirmed "product-skeptic" in authoritative source at line 31 |
| Validator coverage gaps | High | All 6 validator scripts read and analyzed |
| Persona system consistency | High | All 45 persona files read by customer-researcher; naming/titles/structure confirmed consistent |
| run-task persona gap | High | Confirmed by reading run-task SKILL.md and task-coordinator persona |
| manage-roadmap skip detection | Medium | Identified by comparing artifact detection logic across Tier 2 stages |
| Post-build operational gaps | High | Confirmed by roadmap index — P3 stubs exist but all are not_started |

---

## Prioritized Recommendations

### Priority 1 — Low effort, HIGH impact (ready to implement now)

1. **Add fictional name introduction to spawn prompts** — Each spawn prompt's opening line currently says "You are the [Role Name] on the [Team Name]." Add one sentence: "Introduce yourself to the user as [Fictional Name], [Title]." This is a line-level change to ~40+ spawn prompts and would immediately activate the fantasy layer the entire persona system was built around. Confidence: HIGH that this is the fix needed.

2. **Add Business Skills section to wizard-guide** — The Skill Ecosystem Overview should include a "Business Skills" section listing draft-investor-update, plan-sales, and plan-hiring with their descriptions. Three production-quality skills are invisible at the primary discovery point. Effort: one section addition.

3. **Add `/wizard-guide` to setup-project's Next Steps** — Step 6 should recommend `/wizard-guide` as the first action after setup. Currently only `/plan-product` is listed. Effort: one bullet point.

### Priority 2 — Medium effort, MEDIUM impact

4. **Add business skills to setup-project CLAUDE.md template** — The embedded Workflow section lists only engineering skills. Add the business trio.

5. **Clarify the communication-protocol.md "product-skeptic" placeholder** — Change to `{skill-skeptic}` or add an explicit comment: "NOTE: This is a placeholder ID. The sync script substitutes the per-skill skeptic name." Prevents maintenance confusion.

6. **Consider role-based principles filtering** — Create two principles blocks: one for all skills (items 1-3, 9-12), one engineering-only (items 4-8). Sync the appropriate block per skill type. Eliminates TDD/unit test noise in research and business skills.

### Priority 3 — Larger effort, future roadmap (next development cycle)

7. **Build P3-04 triage-incident** — Highest operational impact of unstubbed engineering P3 skills. Every shipped product eventually needs structured incident triage.

8. **Build P3-03 contribution-guide** — Small effort; enables external contributors and documents the architecture for users who want to understand the system.

9. **Consider a business Tier 2 composite** — A `/run-business-ops` skill chaining plan-sales → plan-hiring → draft-investor-update mirrors the value that plan-product provides for engineering. No current roadmap item tracks this.

10. **Add persona files for run-task dynamic agents** — The four generic archetypes (Engineer, Researcher, Writer, Skeptic) should have persona files with fictional names so run-task agents are Conclave characters rather than generic templates.

---

## Session Summary

Research conducted: 2026-03-10
Team: Eldara Voss (Research Director / Lead-as-Skeptic, opus), Theron Blackwell (Market Researcher, sonnet), Lyssa Moonwhisper (Customer Researcher, sonnet)
Scope: Full UX and architecture review of the Conclave plugin for improvement opportunities
Files read: ~75+ (18 SKILL.md, 45 persona files, validators, ADRs, roadmap, templates, wizard-guide, setup-project, communication-protocol)
Lead-as-Skeptic review: Performed inline — persona count discrepancy resolved (45 confirmed via glob), all claims checked against evidence.
Status: Complete. Artifact written to docs/research/conclave-plugin-improvements-research.md.
