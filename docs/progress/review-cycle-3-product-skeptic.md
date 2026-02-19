---
feature: "review-cycle-3"
team: "plan-product"
agent: "product-skeptic"
phase: "review"
status: "complete"
last_action: "Completed review of researcher findings and architect system design for P3-22"
updated: "2026-02-19"
---

# Product Skeptic Review: P3-22 Investor Update Skill

## Review 1: Researcher Findings

REVIEW: Research findings on P3-22 as next feature candidate (docs/progress/review-cycle-3-researcher.md)
Verdict: APPROVED

### Assessment

The researcher's evidence is sufficient. The validation logic is sound:

1. **P3-22 as next feature**: The delta table (Section 1) is the right approach. Nothing changed since Cycle 2 except P3-02 completing. All P2 blockers remain. No new candidates were added. The only thing that could challenge P3-22 would be a new P1/P2 item appearing or a P2 blocker resolving -- neither happened. The researcher's HIGH confidence is justified.

2. **P3-22 over P3-10 resolution**: In Cycle 2, the researcher initially favored P3-10 (/plan-sales). They now concur with P3-22 and provide 4 concrete reasons. The strongest is #1 (investor update structure is more constrained and verifiable) and #3 (Pipeline is closest to existing architecture). These are evidence-based arguments, not vibes. This satisfies me.

3. **Problem space analysis**: Thorough. The standard update structure table (Section 2) maps every section to a data source in the project. The distinction between auto-detectable data and user-required data is critical and well-drawn. The 6 key challenges are correctly identified, with accuracy risk appropriately ranked highest.

4. **Framework pattern analysis**: The reusable-vs-new table (Section 3) is exactly what the spec needs. The researcher identified 6 genuinely new patterns. The pipeline stages are well-defined. The agent team composition is reasonable.

5. **Risks and open questions**: 8 risks, 7 open questions. All are substantive. No padding. The severity assessments are reasonable -- accuracy hallucination at HIGH, the rest at MEDIUM or LOW.

### Notes

- The open questions are well-formulated with clear options. These need resolution in the spec (see my resolutions below).
- The researcher correctly identifies that P3-22 is the definitive test of the business-skill design guidelines. This means we should expect to learn from it and potentially revise those guidelines afterward. The spec should acknowledge this explicitly.
- Minor: the cost note in Section 3 says "3 Opus agents + 1 Sonnet agent" but the team has 4 agents total (Researcher, Drafter, Accuracy Skeptic, Narrative Skeptic) plus the Team Lead. The Team Lead is the invoking agent (Opus), so the actual cost is 3 Opus spawned + 1 Sonnet spawned = 4 spawned agents. The count is correct for spawned agents but the phrasing could be clearer.

---

## Review 2: Architect System Design

REVIEW: Investor Update system design (docs/architecture/investor-update-system-design.md)
Verdict: APPROVED

### Assessment

This is a well-structured system design that correctly implements the Pipeline pattern from the business-skill design guidelines. I evaluated it against 5 criteria:

#### 1. Is the Pipeline pattern justified?

Yes. The architect correctly identifies that Pipeline is the simplest new collaboration pattern to implement (Section: Architecture Classification). The argument that sequential handoffs map naturally to "gather data -> write -> review -> revise" is sound. The alternatives (Collaborative Analysis, Structured Debate) would be over-engineering for a document-production skill. The comparison table (Pipeline vs. existing orchestration) is useful and accurate.

#### 2. Is the dual-skeptic design well-defined?

Yes. The non-overlapping scopes are cleanly drawn:
- Accuracy Skeptic: 6-item checklist focused on factual verification (numbers, milestones, timelines, blocker severity, plus business quality checklist)
- Narrative Skeptic: 6-item checklist focused on framing (spin, omission, prior-update consistency, balance, audience, plus business quality checklist)

Both receive the draft AND the research dossier. Parallel review with independent verdicts. Both-must-approve gate. This is correct.

The one subtlety worth watching: items 5-6 on the Accuracy Skeptic checklist and items 5-6 on the Narrative Skeptic checklist both reference the business skill quality checklist from the design guidelines. There is overlap here ("Are projections grounded in stated evidence, not optimism?" appears in both). This is acceptable because both skeptics should verify it from their respective angles, but the spec should make clear this is intentional overlap, not accidental duplication.

#### 3. Is the "quality without ground truth" strategy adequate?

Yes. The 7-layer mitigation (source attribution, confidence grading, gap acknowledgment, dual-skeptic specialization, external validation checkpoints, falsification triggers, prior-update consistency) is thorough. The "What This Cannot Prevent" section is honest and well-bounded -- garbage in/garbage out, unknown unknowns, and strategic judgment are correct limitations.

The architect has identified the central risk correctly: circular evidence. The system reads markdown files written by AI agents in previous sessions, and those files may themselves contain optimistic framing. The mitigation (source attribution + external validation checkpoints) is the right approach -- make the evidence chain auditable by humans rather than trying to verify it autonomously.

#### 4. Are CI validator impacts correctly assessed?

Yes, with one required correction. The architect correctly identifies that:
- `skill-structure.sh` works as-is (standard multi-agent sections)
- `skill-shared-content.sh` needs the normalize function extended for `accuracy-skeptic` and `narrative-skeptic`
- Other validators are not affected

**However**, the architect's normalize function extension is incomplete. Looking at the actual validator code (scripts/validators/skill-shared-content.sh, lines 51-58), the current function replaces 6 variants (3 slug forms + 3 display forms). The architect proposes adding 4 new entries (2 slugs + 2 display names). This is correct and additive. But the Communication Protocol section in the SKILL.md will reference both skeptic names (since there are two). The normalize function replaces all variants with a single `SKEPTIC_NAME` token. If the Communication Protocol section lists both `accuracy-skeptic` and `narrative-skeptic` on the same line or in the same context, they will both normalize to `SKEPTIC_NAME`, which is the same behavior as existing skills that reference their single skeptic name in multiple places. This should work correctly. No issue here -- I was checking for an edge case that does not exist.

#### 5. Is the output format complete and appropriate?

Yes. The template (lines 230-304) includes all mandatory business-skill sections (Assumptions & Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints). The main body sections (Executive Summary, Key Metrics, Milestones Completed, Current Focus, Challenges & Risks, Outlook) map to the standard investor update structure identified by the researcher.

Two observations:
- The output format does NOT include "Team Update," "Financial Update," or "Asks" sections, which the researcher identified as standard investor update components. This is a deliberate choice (these require user-provided data). The format should handle this explicitly -- either include these sections with "[Requires user input]" placeholders, or document that they are excluded by design. The researcher recommended including all sections with "[Requires input]" markers. I agree with the researcher. Investors expect these sections. Their absence could make the output feel incomplete.
- The YAML frontmatter includes `approved_by` listing both skeptics. This is a good provenance feature.

### Notes

- The Research Dossier is a message, not a file. This is a conscious choice and it is correct -- intermediate artifacts that exist only within a single session do not need persistence. If the session crashes mid-pipeline, the Researcher re-runs (cheaper than persisting and resuming mid-draft).
- The 3-revision-cycle maximum before escalation is consistent with existing skills' Skeptic deadlock recovery pattern.
- The Non-Goals section is well-scoped. No email integration, no financial modeling, no template customization at runtime. These are good boundaries.
- The argument format (`status | <period> | --light`) is clean. Defaulting to "infer period from latest progress files" for empty args is pragmatic.

---

## Review 3: Cross-Cutting Analysis

### Do the researcher's open questions get answered by the architecture?

| # | Open Question | Answered? | Resolution |
|---|---|---|---|
| 1 | User data input mechanism | Partially | The architecture's Non-Goals say "no real-time data gathering" and the Arguments section only supports period/status/--light. The design does NOT specify how financial/team data gets into the system. **This is a gap.** |
| 2 | Output location | Yes | `docs/investor-updates/{date}-investor-update.md`. Created by the skill itself (not setup-project). |
| 3 | Period specification | Yes | Via `<period>` argument or auto-inferred from progress file timestamps. |
| 4 | Prior update consistency | Yes | Narrative Skeptic checks `docs/investor-updates/` for prior updates. Graceful degradation on first run (no prior to compare). |
| 5 | Mandatory vs. optional sections | Partially | The output format includes the "business quality" sections but drops the user-data sections (Team, Financial, Asks). See my note above. |
| 6 | Multi-Skeptic review flow | Yes | Parallel review, independent verdicts, both-must-approve. |
| 7 | Shared content synchronization | Yes | Standard shared markers with CI drift validator. Skeptic name normalization extension identified. |

### Gap: User Data Input Mechanism (Open Question #1)

This is the most significant unresolved question. The researcher identified 4 options (arguments, interactive prompt, template file, combination). The architect's design sidesteps this -- the Non-Goals exclude "real-time data gathering" and the pipeline reads project files, but there is no mechanism for the user to inject financial metrics, team updates, or investor asks.

**My resolution**: Use option (c) from the researcher's list -- a template file at `docs/investor-updates/_user-data.md` that the user populates before running the skill. Rationale:

1. Arguments (`--mrr 50000 --runway 14`) are too fragile for structured data and would make the argument-hint unwieldy.
2. Interactive prompts are not well-supported in the Claude Code agent spawning model -- subagents cannot easily prompt the user mid-pipeline.
3. A template file is persistent, editable, and can be version-controlled. The user fills it in once and updates it each period.
4. The Researcher reads this file alongside project data. If the file is missing or incomplete, the output uses "[Requires user input]" placeholders.

The spec must define this template file format. The Researcher stage should explicitly include `docs/investor-updates/_user-data.md` in its read list.

### Gap: Missing Sections in Output Format

The output format should include ALL standard investor update sections, even those that depend on user data. Following the researcher's recommendation (Open Question #5), sections without data should show "[Requires user input -- see docs/investor-updates/_user-data.md]" rather than being absent. This makes the output usable as a checklist of what the user still needs to provide.

Add to the output format:
- `## Team Update` (after Challenges & Risks)
- `## Financial Summary` (after Team Update)
- `## Asks` (after Financial Summary)

### No Overlooked Candidates

I verified the roadmap (_index.md) against both deliverables. The full candidate set is:
- P2-02 (Skill Composability): Blocked. Correct to defer.
- P2-07 (Universal Shared Principles): 4/8 skills. Premature per ADR-002. Correct to defer.
- P2-08 (Plugin Organization): 0 business skills. Correct to defer.
- P3-01 through P3-07 (engineering skills): All not_started, all P3. No strategic urgency over P3-22.
- P3-10 through P3-21 (business skills): All not_started. P3-22 was selected over P3-10 with good rationale.

No candidate was overlooked. P3-22 is the right choice.

### Risks Not Identified by Either Agent

1. **Drafter as Sonnet risk**: The Drafter is the only Sonnet agent, and it writes the entire investor update body. If the research dossier is complex (many milestones, nuanced blockers), a Sonnet model may produce lower-quality prose that requires multiple revision cycles. The existing plan-product/build-product skills use Sonnet for execution with well-defined inputs, but "write a compelling investor narrative from structured findings" is a harder task than "write code from a spec." The spec should note this risk and suggest that if revision cycles consistently fail, the Drafter can be upgraded to Opus at higher cost.

2. **Date parsing fragility**: The design infers the update period from YAML frontmatter `updated` timestamps in progress files. These timestamps are written by agents and may be inconsistent (some use ISO-8601 date, some use full datetime, some may be missing). The Researcher should validate timestamp formats during the research stage and flag inconsistencies in the Data Gaps section of the dossier.

3. **First-run cold start**: On a project's first investor update, there are no prior updates for the Narrative Skeptic to check consistency against, and there may be no `_user-data.md` file. The skill should handle this gracefully -- both the Narrative Skeptic (skip consistency checks) and the Researcher (skip user data file, flag everything as requiring input) need explicit first-run behavior.

---

## Open Question Resolutions

For the spec author, here are my resolutions on all 7 open questions:

| # | Question | Resolution | Rationale |
|---|---|---|---|
| 1 | User data input mechanism | **(c) Template file** at `docs/investor-updates/_user-data.md` | Persistent, version-controlled, editable. Does not require interactive prompts or unwieldy CLI arguments. Graceful degradation when missing. |
| 2 | Output location | `docs/investor-updates/{date}-investor-update.md` | Per architect's design. Skill creates directory in Setup. |
| 3 | Period specification | **Optional argument** with auto-inference fallback. No requirement to specify. | Per architect's design. If unspecified, infer from latest progress files. If specified, use explicit range. Do not refuse to run without a period. |
| 4 | Prior update consistency | **(b) Yes, if they exist.** Graceful degradation on first run. | Narrative Skeptic reads `docs/investor-updates/` and uses prior updates for consistency checking. On first run, skip this check. |
| 5 | Mandatory vs. optional sections | **All sections always present.** User-data sections show "[Requires user input]" placeholder when data is unavailable. | Completeness serves the user better. A visible gap is better than a silently missing section. |
| 6 | Multi-Skeptic review flow | **Parallel review.** Both skeptics receive the draft simultaneously. | Per architect's design. Faster than sequential. Non-overlapping scopes prevent conflicts. |
| 7 | Shared content synchronization | **Standard shared markers** + extend normalize function in `skill-shared-content.sh`. | Per architect's CI validator impact analysis. Small, additive change. |

---

## Final Verdict

Both deliverables are approved. The research is thorough and the architecture is sound. The spec can proceed with the following mandatory inclusions:

1. Define the `_user-data.md` template file format and add it to the Researcher's read list.
2. Add Team Update, Financial Summary, and Asks sections to the output format with "[Requires user input]" fallback.
3. Note the Sonnet Drafter risk and provide an upgrade path.
4. Document first-run behavior (no prior updates, no user data file).
5. Apply my open question resolutions as stated above.
