---
feature: "investor-update"
team: "build-product"
agent: "quality-skeptic"
phase: "review"
status: "complete"
last_action: "Post-implementation review completed -- APPROVED"
updated: "2026-02-19T00:00:00Z"
---

# P3-22: Quality Skeptic Review

## PRE-IMPLEMENTATION GATE

QUALITY REVIEW: Implementation Plan for P3-22 (`/draft-investor-update`)
Gate: PRE-IMPLEMENTATION
Verdict: **APPROVED**

### Review Methodology

Cross-referenced the implementation plan (`docs/progress/investor-update-impl-architect.md`) against:
- Spec: `docs/specs/investor-update/spec.md` (13 success criteria, 9 constraints)
- System design: `docs/architecture/investor-update-system-design.md`
- Business skill design guidelines: `docs/architecture/business-skill-design-guidelines.md`
- Authoritative source: `plugins/conclave/skills/plan-product/SKILL.md`
- Existing patterns: `build-product/SKILL.md`, `review-quality/SKILL.md`
- CI validators: `scripts/validators/skill-structure.sh`, `scripts/validators/skill-shared-content.sh`

### Success Criteria Coverage (13/13)

| # | Criterion | Plan Coverage | Verdict |
|---|-----------|---------------|---------|
| 1 | Complete update with all sections | A16 (output template), A15-Drafter (placeholder rule), A3 (first-run setup) | PASS |
| 2 | Evidence-traced claims | A15-Researcher (dossier cites paths), A15-Drafter (trace instruction), A15-Accuracy Skeptic (checklist #1), A16 (Source column) | PASS |
| 3 | Accuracy Skeptic verifies | A15-Accuracy Skeptic (6-item checklist), A10 (Quality Gate) | PASS |
| 4 | Narrative Skeptic checks | A15-Narrative Skeptic (6-item checklist), A10 (Quality Gate) | PASS |
| 5 | Both skeptics must approve | A10 (dual requirement), A9 (Gate 2 logic) | PASS |
| 6 | --light uses Sonnet for Researcher | A7 (Lightweight Mode) | PASS |
| 7 | status reports without agents | A6 (Determine Mode "status" branch) | PASS |
| 8 | Period argument scopes research | A6 (Determine Mode "<period>" branch), A15-Researcher (temporal scoping) | PASS |
| 9 | Creates investor-updates/ and _user-data.md | A3 (Setup), A17 (embedded template) | PASS |
| 10 | Reads _user-data.md when present | A15-Researcher (reads file), A15-Drafter (includes user data) | PASS |
| 11 | All 4 mandatory quality sections | A16 (template), A15-Drafter (instructions), A15-both skeptics (checklist #6) | PASS |
| 12 | CI validator passes | A12 (verbatim principles), A13 (protocol with name adaptation), Part D (validator extension) | PASS |
| 13 | First run succeeds, Narrative Skeptic skips consistency | A15-Narrative Skeptic (first-run instruction) | PASS |

### CI Validator Compliance

**skill-structure.sh (A-checks)**:
- A1/frontmatter: `name: draft-investor-update` matches parent directory. Three required fields present. No `type: single-agent`. PASS.
- A2/required-sections: All 10 required headings mapped (Setup, Write Safety, Checkpoint Protocol, Determine Mode, Lightweight Mode, Spawn the Team, Orchestration Flow, Failure Recovery, Shared Principles, Communication Protocol). Quality Gate satisfies the "Critical Rules OR Quality Gate" requirement. Teammate Spawn Prompts satisfies the "Teammate Spawn Prompts OR Teammates to Spawn" requirement. PASS.
- A3/spawn-definitions: 4 H3 entries (Researcher, Drafter, Accuracy Skeptic, Narrative Skeptic), each with Name (backtick-quoted), Model (opus/sonnet), Subagent type. PASS.
- A4/shared-markers: Both BEGIN/END pairs for "principles" and "communication-protocol" confirmed. PASS.

**skill-shared-content.sh (B-checks)**:
- B1/principles-drift: Verbatim copy from plan-product L145-174. PASS.
- B2/protocol-drift: Only skeptic name changes (accuracy-skeptic/Accuracy Skeptic). Normalization handles it. PASS (after Part D is applied).
- B3/authoritative-source: Authoritative source comment on line after each BEGIN marker. Confirmed in plan A12 and A13. PASS.

### Shared Content Strategy

Verified against all 3 existing multi-agent skills:
- plan-product: `product-skeptic` / `Product Skeptic` (authoritative source)
- build-product: `quality-skeptic` / `Quality Skeptic`
- review-quality: `ops-skeptic` / `Ops Skeptic`
- draft-investor-update (planned): `accuracy-skeptic` / `Accuracy Skeptic`

Pattern is consistent. The plan correctly identifies that only line 196 of the Communication Protocol (the "Plan ready for review" row) changes, with both the slug and display name adapted.

### Validator Modification Assessment

Part D adds exactly 4 sed lines to `normalize_skeptic_names()`:
- `accuracy-skeptic` -> `SKEPTIC_NAME`
- `narrative-skeptic` -> `SKEPTIC_NAME`
- `Accuracy Skeptic` -> `SKEPTIC_NAME`
- `Narrative Skeptic` -> `SKEPTIC_NAME`

Placement maintains the grouping pattern (slugs first, display names second). Additive-only change. Existing skills unaffected. Correct.

### Architecture Assessment

The plan correctly implements the Pipeline pattern from the business skill design guidelines:
1. Sequential stages (Research -> Draft -> Review -> Revise -> Finalize) with explicit gates
2. Dual-skeptic parallel review with both-must-approve semantics
3. Structured handoff artifact (Research Dossier) between stages
4. Evidence tracing throughout the pipeline
5. Maximum 3 revision cycles with escalation

The orchestration flow (A9) captures all pipeline stages and gates. The Quality Gate (A10) captures the dual-skeptic requirement with the 3-cycle escalation limit.

### Notes

1. The plan is thorough and well-structured. Section-by-section sourcing with line references makes verification straightforward.
2. The dependency ordering (Part F) correctly identifies that the validator modification and SKILL.md creation can proceed in parallel, with final validation requiring both.
3. The embedded content sections (A16, A17, A18) are a good approach -- embedding the output template, user data template, and dossier format directly in the SKILL.md ensures agents have the exact formats they need.
4. The plan correctly handles the Drafter model upgrade path (noted in A15-Drafter) as specified in the spec.
5. One minor observation: The plan references "backend-eng" and "frontend-eng" in Part F, which are role names from build-product, not the actual implementation agents for this task. This is cosmetic only -- the dependency graph itself is correct.

---

## POST-IMPLEMENTATION GATE

QUALITY REVIEW: P3-22 Implementation (`/draft-investor-update`)
Gate: POST-IMPLEMENTATION
Verdict: **APPROVED**

### Review Methodology

1. Read the full SKILL.md at `plugins/conclave/skills/draft-investor-update/SKILL.md` (738 lines)
2. Ran `bash scripts/validators/skill-structure.sh` -- ALL PASS (A1, A2, A3, A4) across 5 files
3. Ran `bash scripts/validators/skill-shared-content.sh` -- ALL PASS (B1, B2, B3) across 5 files
4. Performed byte-level diff of Shared Principles block against plan-product -- zero differences
5. Performed normalized diff of Communication Protocol block against plan-product -- zero differences after skeptic name normalization
6. Verified validator modification in `scripts/validators/skill-shared-content.sh` -- 4 new sed lines correctly added
7. Verified all 13 success criteria against actual SKILL.md line numbers

### CI Validator Results (verified by running validators myself)

```
[PASS] A1/frontmatter: All SKILL.md files have valid YAML frontmatter (5 files checked)
[PASS] A2/required-sections: All SKILL.md files have all required sections (5 files checked)
[PASS] A3/spawn-definitions: All spawn definitions have required fields (5 files checked)
[PASS] A4/shared-markers: All SKILL.md files have properly paired shared content markers (5 files checked)
[PASS] B1/principles-drift: Shared Principles blocks are byte-identical across all skills (5 files checked)
[PASS] B2/protocol-drift: Communication Protocol blocks are structurally equivalent across all skills (5 files checked)
[PASS] B3/authoritative-source: All BEGIN SHARED markers are followed by authoritative source comment (5 files checked)
```

### Shared Content Verification

**Shared Principles (B1)**: Byte-identical diff between plan-product L145-174 and draft-investor-update L189-218. Zero differences. PASS.

**Communication Protocol (B2)**: After normalizing `accuracy-skeptic` -> `SKEPTIC_NAME` and `Accuracy Skeptic` -> `SKEPTIC_NAME`, zero differences vs plan-product. The only change is line 240 (`write(accuracy-skeptic, ...)` / `Accuracy Skeptic` replacing `write(product-skeptic, ...)` / `Product Skeptic`). PASS.

**Authoritative source comments (B3)**: Lines 190 and 223 both contain `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->`. PASS.

### Validator Modification Verification

File: `scripts/validators/skill-shared-content.sh` lines 56-57 and 61-62:
- Line 56: `-e 's/accuracy-skeptic/SKEPTIC_NAME/g'`
- Line 57: `-e 's/narrative-skeptic/SKEPTIC_NAME/g'`
- Line 61: `-e 's/Accuracy Skeptic/SKEPTIC_NAME/g'`
- Line 62: `-e 's/Narrative Skeptic/SKEPTIC_NAME/g'`

Placement maintains grouping pattern (slugs first, display names second). Additive-only. Existing skills unaffected. PASS.

### Success Criteria Verification (13/13) -- Against Actual SKILL.md

| # | Criterion | SKILL.md Evidence | Verdict |
|---|-----------|-------------------|---------|
| 1 | Complete update with all sections | Output Template (L561-658): all sections present including Team Update, Financial Summary, Asks with placeholder instructions. Drafter prompt (L358-370): mandate all sections. Setup (L30): first-run _user-data.md creation. | PASS |
| 2 | Evidence-traced claims | Researcher prompt (L275-276): file path citation required. Accuracy Skeptic checklist #1 (L429-431): "every number has a source." Output Template Key Metrics table (L586): Source column. | PASS |
| 3 | Accuracy Skeptic verifies | Accuracy Skeptic prompt (L427-454): 6-item checklist covering numbers, milestones, timelines, hallucinations, blocker severity, business quality. | PASS |
| 4 | Narrative Skeptic checks | Narrative Skeptic prompt (L503-532): 6-item checklist covering spin, omissions, prior-update consistency, balanced framing, audience, business quality. | PASS |
| 5 | Both skeptics must approve | Quality Gate (L179): "BOTH Accuracy Skeptic AND Narrative Skeptic approval." Orchestration Flow (L169): "BOTH skeptics must approve." | PASS |
| 6 | --light uses Sonnet for Researcher | Lightweight Mode (L85): "Researcher: spawn with model sonnet." L87-88: both Skeptics "ALWAYS Opus." | PASS |
| 7 | status reports without agents | Determine Mode (L77): "Do NOT spawn any agents." | PASS |
| 8 | Period argument scopes research | Determine Mode (L79): "[period]" branch. Researcher prompt (L291-294): temporal scoping instructions. | PASS |
| 9 | Creates investor-updates/ and _user-data.md | Setup (L23): `docs/investor-updates/` in directory list. Setup (L30): creates _user-data.md template if missing. User Data Template (L662-697): embedded template content. | PASS |
| 10 | Reads _user-data.md when present | Setup (L29): reads file. Researcher prompt (L296-299): user data handling with 3 cases (populated, partial, missing). Drafter prompt (L359-361, L366-367): integrates or uses placeholders. | PASS |
| 11 | All 4 mandatory quality sections | Output Template: Assumptions & Limitations (L622), Confidence Assessment (L628), Falsification Triggers (L639), External Validation Checkpoints (L649). Drafter prompt (L368-369): mandates inclusion. Both skeptics: checklist item 6. | PASS |
| 12 | CI validator passes | Both validators pass (verified above). Shared content byte-identical/structurally equivalent. Validator extension correct. | PASS |
| 13 | First run, Narrative Skeptic skips consistency | Narrative Skeptic prompt (L498-501): explicit first-run behavior with instruction to skip checklist item 3. | PASS |

### Code Quality Assessment

1. **Structure**: Clean, well-organized. 738 lines is reasonable for a multi-agent Pipeline skill with 4 agents. Follows existing SKILL.md conventions.
2. **Spawn prompts**: Each prompt is thorough with clear role description, critical rules, checklist, communication protocol, and write safety. Consistent format across all 4 agents.
3. **Pipeline diagram**: ASCII art diagram (L127-162) matches the system design exactly.
4. **Orchestration flow**: 11-step pipeline (L165-175) covers all stages and gates with clear gate logic.
5. **Quality gate**: Single clear statement (L179) with escalation rule. Matches spec constraint 3.
6. **Failure recovery**: All 3 standard patterns adapted correctly for dual-skeptic context (L183-185).
7. **Embedded templates**: Output Template, User Data Template, and Research Dossier Format all match their spec/system design sources.

### Spec Conformance

The SKILL.md implements all spec requirements:
- All 13 success criteria: PASS (verified above)
- All 9 constraints: Covered (all sections present, evidence tracing, dual approval, 3-cycle max, no fabrication, no real-time data, no email integration, no financial modeling, shared markers)
- Pipeline pattern: Correctly implemented per business skill design guidelines
- Dual-skeptic pattern: Both skeptics have non-overlapping 6-item checklists per spec
- Agent team: 4 agents with correct model assignments (Opus/Sonnet) per spec table

### Notes

1. Implementation faithfully follows the approved plan. No deviations from the plan were found.
2. The User Data Template in the SKILL.md (L666-697) matches the system design format rather than the spec format (which uses a markdown table for Financial Metrics). The system design format is simpler and more practical. This is an acceptable adaptation.
3. The Contract Negotiation Pattern omission comment (L259) maintains consistency with plan-product and review-quality.
4. The Drafter Notes section (L655-657) is included in the Output Template as planned -- this gives skeptics visibility into framing decisions.
