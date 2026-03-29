---
feature: "plan-hiring"
team: "build-product"
agent: "quality-skeptic"
phase: "review"
status: "complete"
last_action: "POST-IMPLEMENTATION gate APPROVED — all 20 success criteria pass"
updated: "2026-02-19"
---

# Quality Skeptic Reviews: plan-hiring

## PRE-IMPLEMENTATION GATE REVIEW

**Scope**: Implementation plan at `docs/progress/plan-hiring-impl-architect.md` **Gate**: PRE-IMPLEMENTATION
**Verdict**: REJECTED

### Issue #1 (BLOCKING): Lightweight Mode contradiction -- Section 7 vs Section 8.2

Section 7 (Lightweight Mode, line 137) lists:

```
- researcher -> sonnet
- growth-advocate -> sonnet
- resource-optimizer -> sonnet
```

Section 8.2 (Key Design Decisions, line 602-608) correctly identifies that the spec is authoritative and resolves:

> "Follow the spec: only Growth Advocate and Resource Optimizer switch to Sonnet. Researcher remains Opus."

**The plan contradicts itself.** Section 7 puts the Researcher on Sonnet; Section 8.2 says Researcher stays Opus. The
spec (line 237) is unambiguous: "Debate agents (Growth Advocate, Resource Optimizer) use Sonnet instead of Opus.
Researcher and Skeptics remain Opus."

**Required fix**: Update Section 7 to show:

- `researcher` -> unchanged (ALWAYS Opus)
- `growth-advocate` -> sonnet
- `resource-optimizer` -> sonnet
- `bias-skeptic` -> unchanged (ALWAYS Opus)
- `fit-skeptic` -> unchanged (ALWAYS Opus)

And update the output message to match: "Lightweight mode enabled: debate agents using Sonnet. Researcher and Skeptics
remain Opus. Quality gates maintained."

### Verified (no issues found)

1. **All 20 success criteria mapped**: Section 7 (Success Criteria Mapping) maps every SC to specific SKILL.md sections.
   Each mapping is traceable and correct.

2. **Section structure follows plan-sales patterns**: The 32-section layout mirrors plan-sales with appropriate
   adaptations. Shared content placement (Sections 19-20), spawn prompts (Sections 23-27), and format templates
   (Sections 28-32) all follow established ordering.

3. **Shared content boundaries correct**: Shared Principles (byte-identical from plan-product L145-174) and
   Communication Protocol (structurally equivalent with skeptic name normalization) are properly specified with correct
   markers.

4. **All 5 agent spawn prompts outlined**: Researcher (~85 lines), Growth Advocate (~120 lines), Resource Optimizer
   (~120 lines), Bias Skeptic (~65 lines), Fit Skeptic (~65 lines). Each has role description, critical rules, phase
   responsibilities, format templates, communication instructions, and write safety.

5. **12 constraints addressed**:
   - C1 (early-stage scope): Reflected throughout
   - C2 (evidence or assumption): Researcher and skeptic prompts enforce
   - C3 (both skeptics approve): Gate 4 + Quality Gate section
   - C4 (max 3 revision cycles): Phase 4b
   - C5 (no data fabrication): Researcher critical rules
   - C6 (no real-time data): Researcher reads project artifacts only
   - C7 (substantive cross-exam): Anti-premature-agreement rules in Phase 3
   - C8 (shared markers): Section 19-20 with correct markers
   - C9 (disagreements preserved): Phase 4 synthesis step 7 + Debate Resolution Summary
   - C10 (Resource Optimizer name): Consistently used throughout
   - C11 (generalist vs specialist): Gate 2 check + debate agent prompts
   - C12 (no legal advice): Bias Skeptic prompt flags for human review

6. **Structured Debate novel elements all present**:
   - Cross-examination protocol: Phase 3 with 3-message rounds
   - Position tracking: MAINTAINED/MODIFIED/CONCEDED in Rebuttal format
   - Points of Agreement: In Challenge format
   - Remaining Tensions: In Rebuttal format
   - Anti-premature-agreement: 4 rules in Phase 3
   - Debate Resolution Summary: Phase 4 step 7 + Output Template

7. **Validator changes correct**: 4 new sed expressions for `bias-skeptic`/`Bias Skeptic` and
   `fit-skeptic`/`Fit Skeptic`, placed after existing entries.

8. **Communication Protocol skeptic name**: `bias-skeptic` / `Bias Skeptic` in the "Plan ready for review" row,
   following the first-listed-skeptic pattern confirmed in plan-sales (`accuracy-skeptic`) and plan-product
   (`product-skeptic`).

9. **Spec vs system-design conflict resolved correctly**: The architect correctly identified the `--light` conflict
   between spec and system-design.md and chose the spec as authoritative. This is the right call.

### Summary

Initial review found one blocking issue: internal inconsistency in Lightweight Mode between Section 7 and Section 8.2.
**RESOLVED** -- architect fixed Section 7 and the Section 1 table to match the spec. All three Lightweight Mode
references now consistently show Researcher stays Opus.

**VERDICT UPDATED: APPROVED**

The plan is approved for implementation. All 20 success criteria mapped, all 12 constraints addressed, all Structured
Debate novel elements present, shared content boundaries correct, validator changes specified. Implementation may
proceed.

---

## POST-IMPLEMENTATION GATE REVIEW

**Scope**: `plugins/conclave/skills/plan-hiring/SKILL.md` (1560 lines) **Spec**: `docs/specs/plan-hiring/spec.md` (20
success criteria, lines 309-329) **Gate**: POST-IMPLEMENTATION **Verdict**: APPROVED

### CI Validators

All validators pass:

- `[PASS] A1/frontmatter` — Valid YAML frontmatter (7 files)
- `[PASS] A2/required-sections` — All required sections present (7 files)
- `[PASS] A3/spawn-definitions` — All spawn definitions have required fields (7 files)
- `[PASS] A4/shared-markers` — Properly paired shared content markers (7 files)
- `[PASS] B1/principles-drift` — Shared Principles byte-identical across all skills (7 files)
- `[PASS] B2/protocol-drift` — Communication Protocol structurally equivalent (7 files)
- `[PASS] B3/authoritative-source` — All BEGIN SHARED markers followed by source comment (7 files)
- `[PASS] E1/required-fields` — All checkpoint files valid (64 files)

### Success Criteria Results

- **SC1: PASS** — Output Template (L1146-1315) includes all 14 sections: Executive Summary, Team Composition Analysis (3
  subsections), Role Prioritization, Role Profiles, Hiring Process Recommendations, Budget Impact Analysis,
  Build/Hire/Outsource Assessment, Strategic Risks, Recommended Next Steps, Debate Resolution Summary, Assumptions &
  Limitations, Confidence Assessment, Falsification Triggers, External Validation Checkpoints. Gate 4 (L418) and Quality
  Gate (L438-441) require both skeptics to approve.
- **SC2: PASS** — All 6 phases implemented: Phase 1 Research (L242-264), Phase 2 Case Building (L266-279), Phase 3
  Cross-Examination (L281-363), Phase 4 Synthesis (L364-389), Phase 5 Review (L392-417), Phase 6 Finalize (L429-437).
  Gates at each transition.
- **SC3: PASS** — Researcher spawn prompt (L530-619) produces Hiring Context Brief. Phase 2 instructions (L270): "the
  Context Brief is the primary evidence source." Both debate agent prompts (L637-638, L816-817) mandate building from
  the shared evidence base.
- **SC4: PASS** — Position tracking (MAINTAINED/MODIFIED/CONCEDED) appears in 7 locations: orchestration (L303, L323),
  anti-premature-agreement rules (L341), synthesis process (L376), both debate agent prompts (L764, L945), and
  standalone Rebuttal format (L1546).
- **SC5: PASS** — Points of Agreement section in Challenge format at L1504-1507. Replicated in Growth Advocate prompt
  (L728-731) and Resource Optimizer prompt (L929-931). Anti-convergence rule (L339) prevents wholesale agreement while
  preserving individual-point agreement.
- **SC6: PASS** — Remaining Tensions section in Rebuttal format at L1556-1559. Replicated in Growth Advocate prompt
  (L774-777) and Resource Optimizer prompt (L955-958). Rule 6 (L342) specifies these feed directly into synthesis.
- **SC7: PASS** — Debate Resolution Summary in Output Template (L1263-1278) with table format. Phase 4 synthesis step 7
  (L384): "Write the Debate Resolution Summary." Section includes disagreement table and Points of Consensus.
- **SC8: PASS** — Bias Skeptic spawn prompt (L982-1059) includes full 5-item checklist: inclusive role descriptions,
  stereotyping avoidance, legal compliance surface, inclusive hiring process, business quality checklist.
- **SC9: PASS** — Fit Skeptic spawn prompt (L1061-1142) includes full 6-item checklist: role necessity, team composition
  balance, budget alignment, strategic fit, early-stage appropriateness, business quality checklist.
- **SC10: PASS** — Gate 4 (L418): "BOTH skeptics must approve." Quality Gate (L438-441): "NO hiring plan is finalized
  without BOTH Bias Skeptic AND Fit Skeptic approval." Phase 6 (L432): "When both skeptics approve."
- **SC11: PASS** — Lightweight Mode (L96-105): Growth Advocate -> sonnet, Resource Optimizer -> sonnet, Researcher ->
  unchanged (ALWAYS Opus), Bias Skeptic -> unchanged (ALWAYS Opus), Fit Skeptic -> unchanged (ALWAYS Opus). Matches spec
  exactly.
- **SC12: PASS** — Status mode (L92-94): "Read all checkpoint files... Do NOT spawn any agents." Reports session state
  from frontmatter.
- **SC13: PASS** — Setup step 1 (L30) creates `docs/hiring-plans/`. Setup step 9 (L37-39) creates `_user-data.md` from
  embedded template if missing.
- **SC14: PASS** — Setup step 8 (L37-38) reads `_user-data.md`. Researcher prompt (L554-562) has USER DATA HANDLING
  section with three scenarios: missing, partially filled, empty/template-only.
- **SC15: PASS** — Output Template includes all 4 mandatory sections: Assumptions & Limitations (L1281-1284), Confidence
  Assessment (L1286-1299), Falsification Triggers (L1300-1306), External Validation Checkpoints (L1308-1314).
- **SC16: PASS** — Validator `normalize_skeptic_names()` has 4 new sed expressions (L65-68):
  `bias-skeptic`/`Bias Skeptic` and `fit-skeptic`/`Fit Skeptic`. B1 and B2 both pass.
- **SC17: PASS** — Setup step 10 (L39-40) outputs data dependency warning. Researcher prompt (L555-558): "note all user
  data sections as 'Not provided' gaps... explicit low-confidence markers." Low-confidence markers flow through to
  output.
- **SC18: PASS** — Phase 4 (L364-389) is lead-driven (NOT delegate mode). Context management (L385-386): "Synthesize
  role by role... write a checkpoint... continue from that section in a subsequent pass."
- **SC19: PASS** — Round 1 (L287-305): Growth Advocate challenges, gets last word. Round 2 (L307-325): Resource
  Optimizer challenges, gets last word. Symmetric: each side is challenger once (with last word) and defender once.
- **SC20: PASS** — Growth Advocate prompt (L644-645): "Address the generalist vs. specialist dimension for EACH role."
  Resource Optimizer prompt (L823-824): same. Gate 2 (L275): "Does each case address the generalist vs. specialist
  dimension for each role?" Debate Case format (L1459): includes Generalist vs. Specialist field.

### Specific Items Verified

1. **Shared content markers**: `<!-- BEGIN SHARED: principles -->` at L451, `<!-- END SHARED: principles -->` at L480.
   `<!-- BEGIN SHARED: communication-protocol -->` at L484, `<!-- END SHARED: communication-protocol -->` at L519. Both
   have authoritative source comments. B1 (byte-identical) passes.
2. **Communication Protocol skeptic name**: L502 uses `bias-skeptic` / `Bias Skeptic` in the "Plan ready for review"
   row, following the first-listed-skeptic pattern.
3. **Cross-examination formats complete**: Challenge (L1490-1514) has Challenges + Points of Agreement + Concessions.
   Response (L1518-1535) has Responses + Counter-Points. Rebuttal (L1537-1560) has Assessment of Responses + Updated
   Position + Remaining Tensions. All required fields present.
4. **Anti-premature-agreement rules**: 6 rules at L335-343. Replicated in both debate agent prompts (L779-785,
   L960-966). Rule 1 (challenges mandatory), Rule 2 (concessions must state impact), Rule 3 (individual agreement
   preserved), Rules 4-6 (tracking and synthesis signals).
5. **--light mode scope**: L100-104 explicitly limits to Growth Advocate and Resource Optimizer only. Researcher, Bias
   Skeptic, Fit Skeptic all marked "unchanged (ALWAYS Opus)."
6. **Phase 3 idle fallback**: L346-356 specifies 3-step protocol: reminder -> re-spawn with checkpoint -> proceed with
   debate record. Missing responses/rebuttals are noted in synthesis Assumptions & Limitations.
7. **Agent name consistency**: "Resource Optimizer" appears 39 times. "Sustainability Advocate" appears 0 times. Naming
   is consistent throughout.
8. **Max revision cycles**: Phase 4b (L426) and failure recovery (L445): max 3 revision cycles before escalation to
   human operator.

### Summary

All 20 success criteria PASS. All 8 CI validators PASS. Shared content byte-identical with authoritative source. All 5
agent spawn prompts complete with role descriptions, critical rules, phase responsibilities, format templates,
communication instructions, and write safety. Structured Debate protocol fully specified with all novel elements:
cross-examination, position tracking, anti-premature-agreement, debate resolution summary. No blocking issues found.
