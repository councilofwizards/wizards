---
feature: "competitor-research"
team: "conclave-forge"
agent: "forge-auditor"
phase: "author"
status: "complete"
last_action: "Phase 3 author review issued — APPROVED. All four phases sealed."
updated: "2026-04-25T17:55:00Z"
---

# FORGE AUDIT LOG — Competitor Research

## Phase 1 (Design) Review

### Calibration

- Read existing fork-join + sequential-pipeline + skeptic-gate skills (audit-slop, review-pr) as quality bar.
- Architect's blueprint declares the same pattern. Scale (8 agents) is in line with audit-slop (10) and review-pr (~11).

### Five Principles Evaluation (Phases 1 and 3 framework)

#### Principle 1 — One mission, decomposed into phases — PASS

- Mission stated as a single verb-noun: **"Profile competitor."**
- Singularity validation is explicit and well-reasoned. The user's requirement that positioning recommendations live
  inside the Executive Summary of the dossier collapses what could otherwise be a two-skill split into one mission with
  a single deliverable.
- Boundary vs. neighboring skills (research-market, ideate-product, plan-sales) is articulated and defensible. The
  architect's "Existing Team Analysis" table clears the question of whether a new team is warranted.
- 4 substantive phases + 4 skeptic gates. Each phase has exactly one named deliverable.
  - Phase 2's "4 Dimensional Findings" is one _deliverable set_ (not 4 deliverables) — same pattern audit-slop uses with
    its parallel assessor reports gathered into a single Validated Findings Set at the gate. Acceptable.
- OUTPUT(N) == INPUT(N+1) at every transition. Chain is gap-free.

#### Principle 3 — Non-overlapping mandates — PASS

- 8 agents, every one earns its seat. Consolidation analysis explicitly evaluates 5 candidate merges and rejects each
  with a methodological reason (different source corpora, different reasoning class, advocacy-from-evidence,
  orchestration overload). I concur with all rejections.
- Mandate boundary tests: 11 pairs covered, each in one sentence, each with a concrete example. The
  Cartographer/GTM-Analyst boundary ("customer-logo wall is Cartographer's; the pricing page is GTM's") is the kind of
  surgical distinction that prevents drift in execution.
- Lead-vs-all and Skeptic-vs-all boundaries are clean.

### Supplementary Checks

- **Phase decomposition**: each phase has exactly one named deliverable. ✓
- **Agent justification**: each of the 8 earns a distinct concern. No merge candidate survives scrutiny. ✓
- **Deliverable chain**: complete, no gaps, starts at user input, ends at a useful output (Approved Competitor Dossier).
  ✓
- **Parallelization**: 4 researchers in parallel within Phase 2 — appropriate, no shared write target, independent
  source corpora. Strategist-during-research and Chronicler-during-Strategist were both considered and correctly
  rejected. ✓
- **Classification**: non-engineering. No application code, no tests, no infrastructure config. Output is a markdown
  report. Universal Principles only. ✓

### Open Questions — Auditor Verdicts

1. **Source-corpus assignment** — ENUMERATE in the Brief. The hallucination risk on a research skill is the dominant
   failure mode. The Brief should ship each researcher a _seed_ source list per dimension. Researchers MAY add sources,
   but every non-seed source must carry a one-line credibility justification. This gives the Skeptic a concrete check at
   the 2.5 Findings Gate ("you cited X not in the seed list and provided no justification — reject"). Action:
   armorer-f2a8 must put a "Source Triage" methodology on each researcher and a corresponding challenge in the Skeptic's
   Findings Gate list.

2. **Re-run idempotency** — YES, skip-if-fresh, but make it a flag-driven contract.
   - Canonical artifact path locked: `docs/research/competitors/{slug}/`.
   - Default freshness window: 30 days.
   - Required flags on the skill: `--refresh` (force re-research) and `--refresh-after Nd` (override the window).
   - Artifact Detection logic belongs in the SKILL.md as a top-level section, mirroring plan-product's pattern.
   - Action: scribe-f2a8 wires the flags, the path convention, and the Artifact Detection section in Phase 3.

3. **Tone enforcement at the Dossier Gate** — YES, and operationalize it as a check, not a vibe. The Skeptic's 4.5
   challenge list MUST include a marketing-language reject. Operational form: every adjective applied to the competitor
   must be tied to cited evidence; banned/flagged phrasing patterns ("revolutionary", "best-in-class",
   "industry-leading", "cutting-edge", etc.) trigger automatic rejection unless used in a direct, attributed quote.
   Action: armorer-f2a8 builds this into the Skeptic's Phase 4.5 methodology; lorekeeper-f2a8 words it cleanly without
   thematic drift.

### Notes Forwarded to Downstream Phases

- **For armorer-f2a8 (Phase 2a)**: The Skeptic gates 4 substantively different artifacts (brief, evidence set,
  synthesis, dossier). Equip the Skeptic with 4 _distinct_ challenge methodologies, not one general one. Each gate has
  its own failure mode profile.
- **For armorer-f2a8 (Phase 2a)**: Each researcher's "Top Items for Synthesis" ranking (Downstream Guidance Rule) must
  be a _named methodology_ with a structured artifact (e.g., a Salience Matrix), not a freeform list. The Skeptic needs
  something to point at.
- **For lorekeeper-f2a8 (Phase 2b)**: "Comprehensive" is the user's word, and it's vague. The Brief's success criteria
  must operationalize it (e.g., minimum source count per dimension, minimum distinct evidence types, required-coverage
  list). Don't let the theme paper over the rigor.
- **For scribe-f2a8 (Phase 3)**: The 4 skeptic gates must each appear as explicit GATE markers in the Orchestration
  Flow, and the Skeptic's spawn prompt must carry WHAT YOU CHALLENGE sections for all 4 gates.

## Verdict

```
FORGE AUDIT: competitor-research blueprint (Phase 1 — Design)
Phase: Design
Verdict: APPROVED

Compliance: All Five Principles satisfied (Principles 1 and 3 evaluated in this phase; 2, 4, 5 deferred to subsequent gates).
Structural: Phase decomposition, agent roster, mandate boundaries, deliverable chain, parallelization, and classification all meet the bar.
Notes: Open questions resolved (see Auditor Verdicts above). Forward-looking guidance issued to armorer-f2a8, lorekeeper-f2a8, and scribe-f2a8.
```

## Checkpoint Log — Phase 1

- [00:00] Review requested by architect-f2a8 (PLAN REVIEW REQUEST received)
- [00:05] Read forge-auditor persona, blueprint, and audit-slop SKILL.md (calibration)
- [00:15] Evaluated Principle 1 — PASS
- [00:20] Evaluated Principle 3 — PASS
- [00:25] Evaluated supplementary checks (decomposition, chain, parallelization, classification) — PASS
- [00:30] Resolved 3 open questions; drafted forward notes for armorer/lorekeeper/scribe
- [00:35] Verdict: APPROVED. Issuing to architect-f2a8 and forge-master.

---

## Phase 2a (Arm) Review

### Calibration

- Read armorer-f2a8's manifest at `docs/progress/competitor-research-armorer.md`.
- Evaluated against Principles 2 and 4 (Phase 2a framework).

### Five Principles Evaluation (Phase 2a — Principles 2 and 4)

#### Principle 2 — Methodology over role description — PASS

- **Methodology authenticity**: Every methodology maps to a real, named technique:
  - Lead: 5W1H (journalism), entity disambiguation, OSINT seed lists, success-criteria operationalization.
  - Cartographer: source triage, PESTLE, timeline analysis, salience scoring.
  - Inspector: source triage, comparative feature matrices, JTBD (Christensen), salience scoring.
  - Excavator: source triage, technology fingerprinting (BuiltWith / Wappalyzer-class), dependency graph analysis,
    salience scoring.
  - GTM: source triage, pricing/packaging WBS, sentiment cluster analysis, salience scoring.
  - Strategist: SWOT, gap analysis, traceability matrices (audit / SE provenance), Devil's Advocacy (red-team).
  - Chronicler: audience analysis, progressive disclosure (Nielsen IA), citation/reference resolution.
  - Skeptic: claim provenance audit (fact-checking), traceability auditing, marketing-language audit (editorial). No
    invented jargon. Skeptic methodology names are operationalized but each describes a real technique with concrete
    operations and a structured output. Acceptable — same pattern audit-slop's Doubt Augur follows.

- **Methodology count**: Lead 4, Cartographer 4, Inspector 4, Excavator 4, GTM 4, Strategist 4, Chronicler 3, Skeptic 4.
  All within the 2–4 bound. ✓

- **Methodology-phase fit**: Each agent's methodologies serve their phase exclusively. Lead's four are intake-shaped;
  researcher methodologies are evidence-collection shaped; Strategist's are reasoning-shaped; Chronicler's are
  authorship-shaped; Skeptic's four are gate-shaped. ✓

#### Principle 4 — Evidence over assertion, enforced by a skeptic — PASS

- **Structured output**: Every methodology produces a named, structured artifact (Card, Table, Matrix, Log, Map,
  Timeline, Chain, Quadrant, Rubric, Plan, Ledger, Checklist). 25 distinct named artifacts across the 8 agents. No
  artifact is freeform prose. ✓

- **Challengeability**: Every methodology entry carries an explicit "Skeptic challenge surface" listing concrete
  challenge surfaces (e.g., "any finding ranked top-5 whose evidence_strength is below 3", "tier A sources without
  primary-source links", "high-confidence inferences from a single signal"). The Skeptic can point at a specific row,
  cell, or field of every artifact. ✓

- **Skeptic differentiation**: Four genuinely distinct gate methodologies, each with a tuned failure-mode profile
  matching its gate's input artifact:
  - 1.5 Brief Gate Challenge Protocol — boundary violation, scope drift, untestable criteria.
  - 2.5 Findings Gate Claim Provenance Audit — URL+date verification, source-triage compliance, salience ranking
    justification, cross-dimensional contradiction.
  - 3.5 Synthesis Gate Evidence-Recommendation Traceability Audit — traceability verification, parallel Devil's
    Advocacy, over-capitalization detection.
  - 4.5 Dossier Gate Marketing-Language Audit — banned-phrase pattern detection, adjective-evidence pairing,
    layer-correctness, reference resolution. All four directives from Phase 1 honored. ✓

- **Tone enforcement operationalized**: Banned-Phrase Strike List with a concrete 9-phrase initial list and an
  Adjective-Evidence Map sub-artifact, with auto-rejection unless the phrase is inside an attributed direct quote with
  citation. This is a check, not a vibe. Directive 4 honored. ✓

### Output Overlap Check (Principle 4 corollary)

- **Source Triage Log shared across 4 researchers**: Auditor-mandated (directive 1). Each instance is dimension-scoped
  with different evidence corpora. Same schema by design — gives the Skeptic a uniform compliance check. Acceptable.
- **Salience Matrix shared across 4 researchers**: Auditor-mandated (directive 2). Same justification. Acceptable.
- **Skeptic's 4 Verdict Logs**: Same agent producing 4 artifacts with shared shape but gate-specific row schemas. Not a
  mandate overlap.
- **Other "matrix"-named artifacts**: PESTLE, Feature Inventory, Pricing-Packaging, Gap-Fit, Traceability — structurally
  distinct (different columns, different challenge surfaces). No collision.

All sharing is intentional and justified.

### Forward Notes (non-blocking)

- **"Integration Dependency Graph" naming**: The methodology specifies a row-shaped table, not a node-edge graph. Either
  rename to "Integration Dependency Map" / "...Table" OR include a true graph diagram alongside the table. This is a
  Scribe phrasing concern, not a methodology defect — flagged forward, not blocking.
- **Inspector's JTBD evidence cross-cuts dimensions**: JTBD evidence (customer quotes, reviews, case studies) lives
  partly in GTM-seeded sources (G2, Capterra, etc.). The Brief should either grant Inspector cross-dimensional source
  access for JTBD evidence OR explicitly note that JTBD claims may cite GTM-seeded sources without violating mandate
  boundaries. Lorekeeper / Scribe to clarify in spawn prompts.
- **Salience formula vs. Gap-Fit formula consistency**: The researcher Salience Matrix uses
  `salience = importance × evidence_strength` while the Strategist Gap-Fit uses
  `combined_priority = gap_severity × our_fit ÷ capitalization_risk`. Both are defensible. The Skeptic's challenge
  surfaces explicitly call out "calculations that don't match the formula" — covered. No action.
- **Coverage Threshold Checklist authoring under uncertainty**: The Lead authors thresholds at intake before product
  knowledge is gathered. Defensibility of thresholds for the _specific competitor type_ should be explicitly checkable
  at the Brief Gate. The armorer's "untestable-criteria" challenge category covers this — no additional change needed.
  No action.
- **For Lorekeeper**: Methodology names must appear by name in spawn prompts; thematic skin must NOT obscure the
  operational name. Skeptic's spawn prompt needs four explicit `WHAT YOU CHALLENGE` blocks, one per methodology / gate.
- **For Scribe**: Each agent's Output Format section must reference the structured artifact by name with schema, not
  describe the output freely. Four GATE markers in the Orchestration Flow map 1:1 to the four Skeptic methodology names.

## Verdict — Phase 2a

```
FORGE AUDIT: competitor-research methodology manifest (Phase 2a — Arm)
Phase: Arm
Verdict: APPROVED

Compliance: Principles 2 and 4 satisfied. All four Phase 1 binding directives honored
(Source Triage on all four researchers, named Salience Matrix methodology, four distinct
Skeptic challenge methodologies, operationalized tone enforcement at Gate 4.5).
Structural: All 25 named artifacts are structured and challengeable. Methodology counts
within the 2–4 bound for every agent. Intentional output sharing is auditor-mandated and
correctly justified. No invented jargon.
Notes: Four non-blocking forward notes captured for Lorekeeper and Scribe (Integration
Dependency Graph naming, Inspector JTBD evidence cross-cut, Salience/Gap-Fit formula
distinction, Coverage Threshold authoring under uncertainty).
```

## Checkpoint Log — Phase 2a

- [01:00] Phase 2a review requested by armorer-f2a8 (PLAN REVIEW REQUEST received)
- [01:05] Read manifest in full
- [01:10] Evaluated Principle 2 (authenticity, count, fit) — PASS
- [01:15] Evaluated Principle 4 (structured output, challengeability, skeptic differentiation) — PASS
- [01:20] Verified all four Phase 1 directives honored — PASS
- [01:25] Output overlap check — all sharing justified, no unintended collision
- [01:30] Drafted four forward non-blocking notes
- [01:35] Verdict: APPROVED. Issuing to armorer-f2a8 and forge-master.

---

## Phase 2b (Name) Review

### Calibration

- Read lorekeeper-f2a8's theme design at `docs/progress/competitor-research-lorekeeper.md`.
- Verified persona naming against the personas folder (91 existing fictional names extracted; slug list compared).
- Evaluated against Principle 5.

### Five Principles Evaluation (Phase 2b — Principle 5)

#### Principle 5 — Fantasy is the voice, not the process — PASS

- **Skill name clarity**: `profile-competitor` is verb-noun, kebab-case, and instantly clear to an outsider. Matches the
  verb-noun pattern of `squash-bugs`, `audit-slop`, `craft-laravel`, `plan-sales`, `plan-hiring`. The rejected
  alternatives (`chart-rivals`, `scout-competitor`, `map-competitor`) were considered for the right reasons. This is a
  clear upgrade over the in-flight name `competitor-research` (noun-noun). ✓

- **Team name resonance**: The Black Atlas — atlas (cartography of competitors as a growing record) + black
  (off-public-shelf intelligence). Fits the work: each invocation adds an entry to the Atlas. Distinct from existing
  team names (Augur Circle, Tribunal, Atelier, Crucible Accord, Stratum Company, Order of the Stack, Wardbound, Conclave
  Forge). ✓

- **Title clarity**: Each title communicates function through the metaphor:
  - Cartomarshal — Lead/orchestrator (marshal = leader; cartog = mapping)
  - Atlas Cartographer — market mapping
  - Storefront Walker — product surface inspection
  - Stack Excavator — technical archaeology (sibling to existing boundary/logic/schema-excavator pattern)
  - Market-Watch Envoy — GTM/commercial reading
  - Gap-Reader — strategist (cross-dimensional gap analysis)
  - Dossier-Binder — chronicler (audience-tier authorship)
  - Counter-Spy — skeptic (adversarial reading) All map cleanly. ✓

- **Vocabulary mapping**: 8 thematic terms, each with a 1:1 process-event mapping:
  - Brief → intake doc
  - Field Dispatch → parallel research phase
  - Cipher → raw findings
  - Mapping → per-agent synthesis (the dimensional findings deliverable)
  - Decryption → strategist synthesis
  - Folio → dossier section
  - Dossier → final artifact
  - Counter-Reading → skeptic phase gate No fantasy term hides a process step. ✓

- **Theme-process separation**: The methodology manifest (Phase 2a) stands fully outside the fantasy layer. Strip the
  theme and the process still works — Source Triage Log, PESTLE Matrix, Salience Matrix, Gap-Fit Matrix, etc. all carry
  operational names. The fantasy lives only in the spawn-prompt communication layer. ✓

### Persona Distinctiveness — Detailed Audit

Cross-checked all 8 proposed personas against 91 extracted `fictional_name` values from the personas folder.

**Full-name collisions (blocking)**: None. ✓

**Given-name reuse (non-blocking per precedent)**:

- **Pell Marrowfen** vs existing **Pell Dustquill**.
- **Renn Coldspire** vs existing **Renn Swiftseam**.

This contradicts the lorekeeper's writeup ("All eight proposed personas are unique on both given name and surname"). The
writeup is factually incorrect on this point. However, the conclave precedent permits given-name reuse: existing rosters
include two Brams, two Vexes, two Kaels, two Sables, two Pips, two Oryns, two Thanes, two Vexes, and parallel surname
reuses (two Greystones, two Deepvaults, two Inkwells). The operative rule is "no exact full-name collision," and that is
satisfied. Names APPROVED; the lorekeeper's collision-check writeup needs a one-line correction for accuracy —
non-blocking.

### Persona File Slug Check

- **Reused slugs (correctly suffixed)**: `cartographer--competitor-research.md`, `chronicler--competitor-research.md`,
  `gtm-analyst--competitor-research.md`, `strategist--competitor-research.md` — all four parent slugs exist
  (`cartographer.md`, `chronicler.md`, `gtm-analyst.md`, `strategist.md`). The double-dash suffix convention is
  established (e.g., `accuracy-skeptic--plan-sales.md`, `accuracy-skeptic--draft-investor-update.md`,
  `strategist--write-stories.md`, `strategist--write-spec.md`, `researcher--plan-hiring.md`). ✓
- **New slugs**: `cartomarshal.md`, `storefront-walker.md`, `stack-excavator.md`, `counter-spy.md` — all distinct, none
  collide with existing files. `stack-excavator` extends the existing
  `boundary-excavator`/`logic-excavator`/`schema-excavator` pattern correctly. ✓

### Forward Notes (non-blocking)

1. **Lorekeeper writeup correction**: The collision-check section must be corrected to acknowledge that Pell and Renn
   are reused given names (precedented in the roster), and that the operative rule is full-name distinctness, which IS
   satisfied. One-line edit. Names stand.

2. **Skill name resolution required (Scribe + Forge Master)**: The skill name has been finalized as
   `profile-competitor`, but in-flight progress files use `competitor-research-*.md`. Scribe must use
   `profile-competitor` consistently in: SKILL.md `name:` frontmatter field, skill directory path
   (`plugins/conclave/skills/profile-competitor/`), CLAUDE.md skill list, `sync-shared-content.sh` classification list,
   marketplace catalog (if applicable), and any wizard-guide entries. In-flight progress files may stay as
   `competitor-research-*.md` — they are build-process artifacts, not skill outputs, and renaming creates churn.

3. **"Mapping" disambiguation in spawn prompts (Scribe)**: The vocabulary term "Mapping" maps to per-agent synthesis —
   the entire dimensional findings deliverable (Source Triage Log + dimensional core artifact + Salience Matrix). The
   methodology manifest also contains an artifact named "JTBD Map" and references to "Pricing-Packaging Matrix", "PESTLE
   Matrix", etc. The Scribe must phrase spawn prompts so agents understand "produce your Mapping" = the entire
   dimensional findings deliverable, NOT any single sub-artifact. Suggest the phrasing "produce your full Mapping
   (Source Triage Log + [core artifact] + Salience Matrix)" in spawn prompts.

4. **"Cipher" should not invite literal encryption (Scribe)**: The vocabulary defines Cipher as "raw findings" — the
   agent's untreated observation bundle (URL + claim + access date + metadata). Spawn prompts must not phrase this in a
   way that pushes agents toward literal encryption thinking. Suggest: "Cipher = your raw, evidence-cited finding before
   synthesis."

## Verdict — Phase 2b

```
FORGE AUDIT: competitor-research theme design (Phase 2b — Name)
Phase: Name
Verdict: APPROVED

Compliance: Principle 5 satisfied. Skill name (profile-competitor) is verb-noun and clear; team name (The
Black Atlas) resonates with the work; all 8 titles communicate function through the metaphor; 8-term
vocabulary maps 1:1 to process events; theme-process separation holds — strip the fantasy and the process
still works.
Structural: No full-name persona collisions. Slug naming follows established double-dash convention for
reused slugs and matches sibling patterns for new slugs.
Notes: Four non-blocking forward notes (lorekeeper writeup factual correction; skill name resolution across
catalog files; "Mapping" disambiguation; "Cipher" non-literal phrasing). None require revision before
Phase 3.
```

## Checkpoint Log — Phase 2b

- [02:00] Phase 2b review requested by lorekeeper-f2a8 (PLAN REVIEW REQUEST received)
- [02:05] Read theme design in full
- [02:10] Verified existing personas folder (91 fictional names extracted, 4 reused-slug parents confirmed)
- [02:15] Evaluated Principle 5 (skill name, team name, titles, vocabulary, theme-process separation) — PASS
- [02:20] Persona distinctiveness audit — no full-name collisions; 2 given-name reuses noted (precedented)
- [02:25] Slug check — reused slugs correctly suffixed; new slugs distinct and pattern-aligned
- [02:30] Drafted four forward non-blocking notes
- [02:35] Verdict: APPROVED. Issuing to lorekeeper-f2a8 and forge-master.
- [02:50] Lorekeeper acknowledged the writeup correction; record now clean.

---

## Phase 3 (Author) Review

### Calibration

- Read scribe-f2a8 / scribe2-f2a8's SKILL.md draft at `docs/progress/competitor-research-scribe.md` (877 lines).
- Read counter-spy.md persona in full (central to D3 / D4 verification).
- Verified all 8 persona files exist on disk (cartomarshal, cartographer--competitor-research, storefront-walker,
  stack-excavator, gtm-analyst--competitor-research, strategist--competitor-research, chronicler--competitor-research,
  counter-spy).

### Phase 3 Compliance Checklist

| #   | Check                                                                                                                                     | Result                                                                                                                                                                                                                                                                                                                              |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | --------- | -------- | --------- |
| 1   | Frontmatter: name, description, argument-hint, category, tags                                                                             | PASS — name `profile-competitor`, category `planning`, tags `[competitive-intelligence, research, strategy, dossier]`                                                                                                                                                                                                               |
| 2   | Section ordering matches structural template                                                                                              | PASS — Setup → Write Safety → Checkpoint Protocol → Determine Mode → Lightweight Mode → Artifact Detection → Spawn the Team → Orchestration Flow (with Between Phases / Pipeline Completion subsections) → Critical Rules → Failure Recovery → universal-principles SHARED → communication-protocol SHARED → Teammate Spawn Prompts |
| 3   | Setup includes directory creation, template reads, stack detection                                                                        | PASS — research / competitors / progress directories; `docs/progress/_template.md`; stack hint detection; cartomarshal persona read                                                                                                                                                                                                 |
| 4   | Write Safety with role-scoped progress files                                                                                              | PASS — `docs/progress/{slug}-{role}.md` convention; canonical dossier path                                                                                                                                                                                                                                                          |
| 5   | Checkpoint Protocol with correct team name and phase enum                                                                                 | PASS (with one observation — see forward notes) — team `black-atlas`; phase enum `brief                                                                                                                                                                                                                                             | reconnaissance | synthesis | assembly | complete` |
| 6   | Determine Mode with status / empty / skill-specific                                                                                       | PASS — `status`, empty (resume), `[CompanyName]`                                                                                                                                                                                                                                                                                    |
| 7   | Flag Parsing with --max-iterations and --checkpoint-frequency                                                                             | PASS — both present; also --light, --refresh, --refresh-after Nd                                                                                                                                                                                                                                                                    |
| 8   | Lightweight Mode with at least one downgrade; skeptic never downgraded                                                                    | PASS — gap-reader → sonnet; counter-spy stays opus with explicit ALWAYS Opus note                                                                                                                                                                                                                                                   |
| 9   | Spawn the Team with 3-step pattern (TeamCreate, TaskCreate, Agent)                                                                        | PASS — Steps 1/2/3 explicit; run-ID generation pattern present                                                                                                                                                                                                                                                                      |
| 10  | Each teammate has Name, Model, Prompt, Tasks, Phase                                                                                       | PASS — all 8                                                                                                                                                                                                                                                                                                                        |
| 11  | Orchestration Flow with explicit GATE markers at every transition                                                                         | PASS — `Phase 1.5 — GATE: Brief Gate Challenge Protocol`, `Phase 2.5 — GATE: Findings Gate Claim Provenance Audit`, `Phase 3.5 — GATE: Synthesis Gate Evidence-Recommendation Traceability Audit`, `Phase 4.5 — GATE: Dossier Gate Marketing-Language Audit`                                                                        |
| 12  | Artifact Detection section before pipeline execution                                                                                      | PASS — top-level section, canonical path `docs/research/competitors/{slug}/`, 30-day default, --refresh and --refresh-after Nd flags, cached Mappings re-validated by Counter-Spy at Gate 2.5 (no implicit pass — sharp design)                                                                                                     |
| 13  | Between Phases and Pipeline Completion sections                                                                                           | PASS — both present; Pipeline Completion includes cost summary, end-of-session summary, optional post-mortem                                                                                                                                                                                                                        |
| 14  | Critical Rules section                                                                                                                    | PASS — 10 rules covering gate authority, citation requirements, source triage, salience matrix, four distinct skeptic methodologies, marketing-language auto-reject, threshold flexibility, dossier path, Mapping/Cipher disambiguation, escalation                                                                                 |
| 15  | Failure Recovery (unresponsive agent, skeptic deadlock, context exhaustion)                                                               | PASS — all three plus partial pipeline and phase failure                                                                                                                                                                                                                                                                            |
| 16  | SCAFFOLD comments (checkpoint frequency, skeptic model)                                                                                   | PASS — three SCAFFOLD comments (checkpoint frequency line 92, skeptic model line 264, max-iterations line 417), all three with required fields                                                                                                                                                                                      |
| 17  | Shared content markers: universal-principles, communication-protocol; engineering-principles correctly omitted                            | PASS — non-engineering classification correctly produces only universal-principles + communication-protocol                                                                                                                                                                                                                         |
| 18  | Communication protocol skeptic name correct                                                                                               | PASS — `write(counter-spy, ...)` and `Counter-Spy` Target column populated correctly                                                                                                                                                                                                                                                |
| 19  | Spawn prompt template (persona read → persona line → TEAMMATES → SCOPE → PHASE ASSIGNMENT → FILES TO READ → COMMUNICATION → WRITE SAFETY) | PASS — all 8 spawn prompts conform                                                                                                                                                                                                                                                                                                  |
| 20  | Skeptic spawn prompt has WHAT YOU CHALLENGE blocks for every gate                                                                         | PASS — 4 blocks with exact methodology names (Brief Gate Challenge Protocol / Findings Gate Claim Provenance Audit / Synthesis Gate Evidence-Recommendation Traceability Audit / Dossier Gate Marketing-Language Audit)                                                                                                             |
| 21  | Test execution evidence in skeptic challenge list (engineering only)                                                                      | N/A — non-engineering classification, no code phases                                                                                                                                                                                                                                                                                |
| 22  | All Five Design Principles satisfied                                                                                                      | PASS — see Five-Principle final review below                                                                                                                                                                                                                                                                                        |
| 23  | Quality bar: indistinguishable from squash-bugs / review-quality / audit-slop                                                             | PASS — comparable structural completeness, narrative cohesion, and skeptic rigor                                                                                                                                                                                                                                                    |

### Auditor Directive Verification (Phases 1, 2a, 2b → Phase 3)

| Directive                                                                                           | Origin   | Honored in Draft?                                                                                                                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| D1 — Source Triage on all four researchers, with seed list and per-source credibility justification | Phase 1  | YES — Cartomarshal authors Source Seed Table; each researcher has Source Triage Log; Counter-Spy Gate 2.5 explicitly audits source-triage compliance                                                                                                                   |
| D2 — Salience Matrix as named methodology with structured artifact                                  | Phase 1  | YES — every researcher's Tasks line names the Salience Matrix; Critical Rules forbid freeform top-items lists                                                                                                                                                          |
| D3 — Four DISTINCT Skeptic challenge methodologies, one per gate                                    | Phase 1  | YES — 4 WHAT YOU CHALLENGE AT GATE [N] blocks in Counter-Spy spawn prompt with exact methodology names                                                                                                                                                                 |
| D4 — Operational tone enforcement at Gate 4.5                                                       | Phase 1  | YES — Banned-Phrase Strike List with all 9 phrases verbatim, Adjective-Evidence Map sub-artifact, auto-rejection unless inside attributed direct quote with citation                                                                                                   |
| Phase 2a forward note: Integration Dependency Map (not Graph) rename                                | Phase 2a | YES — Stack Excavator spawn prompt explicitly says "Integration Dependency Map (NOT Graph) ... row-shaped table — NOT a node-edge graph diagram"; Tasks line uses Map                                                                                                  |
| Phase 2a forward note: Inspector JTBD cross-dimensional source access                               | Phase 2a | YES — Storefront Walker spawn prompt grants permitted cross-dimensional access for JTBD evidence with one-line cross-dimensional justification requirement; Counter-Spy Gate 2.5 marks this compliant                                                                  |
| Phase 2b forward note: skill name `profile-competitor` everywhere                                   | Phase 2b | YES in SKILL.md frontmatter, H1, persona files (skill: profile-competitor), spawn prompts. Final-write target path `plugins/conclave/skills/profile-competitor/SKILL.md` correct. (CLAUDE.md / sync script / marketplace updates remain Phase 4 / Forge Master scope.) |
| Phase 2b forward note: "Mapping" disambiguation in spawn prompts                                    | Phase 2b | YES — Critical Rules line + every researcher spawn prompt phrases Mapping as the full dimensional findings deliverable (Source Triage Log + core artifact + Salience Matrix)                                                                                           |
| Phase 2b forward note: "Cipher" non-literal phrasing                                                | Phase 2b | YES — Critical Rules line + every researcher spawn prompt phrases Cipher as raw, evidence-cited finding before synthesis, with explicit "Not literal encryption"                                                                                                       |

### Five Design Principles — Final Review

- **Principle 1 (One mission)**: `profile-competitor` is one verb, one noun. Single dossier deliverable. PASS.
- **Principle 2 (Methodology over role)**: Every spawn prompt names the structured artifacts the agent must produce, by
  name. No prose-only deliverables. PASS.
- **Principle 3 (Non-overlapping mandates)**: Each researcher's SCOPE explicitly excludes neighboring dimensions
  (Cartographer notes pricing-page belongs to Market-Watch Envoy; Storefront Walker notes JTBD cross-cut is permitted
  but justified; etc.). Lead vs. all and Skeptic vs. all boundaries hold. PASS.
- **Principle 4 (Evidence over assertion, skeptic-enforced)**: Counter-Spy at every gate; structured Verdict Logs; four
  distinct methodologies; auto-reject rule for marketing language. PASS.
- **Principle 5 (Fantasy is the voice, not the process)**: The Black Atlas, Cartomarshal, Counter-Spy, Mapping, Cipher,
  Folio, Field Dispatch — all consistent with the lorekeeper's vocabulary. Strip the fantasy and the process still works
  (the methodology layer is operational). PASS.

### Forward Notes (NON-BLOCKING — Phase 4 / Forge Master housekeeping)

1. **Checkpoint phase enum gap**: The phase enum `brief | reconnaissance | synthesis | assembly | complete` does not
   name gate states. The Counter-Spy's checkpoint phase value during gate iteration is therefore underspecified.
   Audit-slop included `brief-gate` and `adjudication` in its enum for the same reason. Either (a) add
   `brief-gate | findings-gate | synthesis-gate | dossier-gate` to the enum, OR (b) state explicitly in the
   Counter-Spy's WRITE SAFETY block that "during gate review, use the upstream phase value and note the gate in
   `last_action`." Either resolves the ambiguity. Non-blocking — the skill functions as-drafted.

2. **Phase 4 Forge Master registration tasks** (already in task #4 — surfacing for completeness):
   - Add `profile-competitor` to `sync-shared-content.sh` non-engineering classification list.
   - Add `profile-competitor` to CLAUDE.md skill list under the appropriate section.
   - Update `wizard-guide` if applicable.
   - Update `.claude-plugin/marketplace.json` if applicable.
   - Run `bash scripts/sync-shared-content.sh` after final write to inject shared content correctly and verify the
     Counter-Spy substitution applies.

### Verdict — Phase 3

```
FORGE AUDIT: profile-competitor SKILL.md (Phase 3 — Author)
Phase: Author
Verdict: APPROVED

Compliance: All Five Design Principles satisfied. All Phase 3 checklist items pass (22/22 applicable;
1 N/A for non-engineering). All four binding directives (D1-D4) honored. All four Phase 2a/2b forward notes
honored.
Structural: 8 persona files written to canonical paths and schema-compliant; SKILL.md sections in correct
order; gates marked explicitly; SCAFFOLD comments well-formed; shared-content markers correctly tailored to
non-engineering classification.
Quality bar: indistinguishable from squash-bugs / audit-slop / review-pr / review-quality.
Notes: One non-blocking forward note (checkpoint phase enum should be expanded with gate states or
explicitly handled in Counter-Spy WRITE SAFETY); standard Phase 4 registration tasks remain for the
Forge Master.
```

The seal is applied. The forge is closed on profile-competitor. Phase 4 (Register) is unlocked.

## Checkpoint Log — Phase 3

- [03:00] Phase 3 review requested by scribe-f2a8 (PLAN REVIEW REQUEST received)
- [03:05] Verified all 8 persona files present on disk
- [03:10] Read SKILL.md draft (877 lines) and counter-spy.md persona (full)
- [03:25] Ran 23-item Phase 3 compliance checklist — 22 PASS, 1 N/A (test execution for engineering only)
- [03:35] Verified all 4 binding directives (D1–D4) and all 4 forward notes from Phases 2a/2b
- [03:45] Final Five Principles review — all five PASS
- [03:50] Drafted 1 non-blocking forward note (checkpoint phase enum gap) and Phase 4 registration list
- [03:55] Verdict: APPROVED. Issuing to scribe-f2a8 and forge-master.

---

### Phase 3 — Re-review for scribe2-f2a8 resubmission

scribe2-f2a8 (the agent that picked up after the compaction) submitted a revised draft (request_id:
scribe2-f2a8-skill-draft) with two corrections from the prior draft:

1. **H1 corrected** to `# The Black Atlas — Competitor Profiling Orchestration` (was "Profile" in prior draft;
   "Profiling" matches the brief).
2. **Artifact Detection relocated** from `## Artifact Detection` (top-level H2) to `### Artifact Detection` (subsection
   at the head of `## Orchestration Flow`).

**Verification of relocation against canonical reference**: I cross-checked plan-product's actual section structure.
plan-product does NOT have a top-level `## Artifact Detection` section — its structure is Setup → Write Safety →
Checkpoint Protocol → Determine Mode → Lightweight Mode → Spawn the Team → Orchestration Flow (with subsections
Complexity Routing / Full Skeptic Mode / Stage 1–5 / Between Stages / Pipeline Completion) → Quality Gate → Failure
Recovery → Shared/Engineering Principles → Communication Protocol → Teammate Spawn Prompts. My Phase 1 directive cited
plan-product's pattern but specified "top-level section" — that was a factual misattribution on my part. Scribe2's
relocation aligns the draft with the actual plan-product convention. Correction accepted.

**Section content of the relocated Artifact Detection**: retained all prior content (canonical path, 30-day default
freshness window, --refresh / --refresh-after Nd flag handling, cached-Mapping reuse with mandatory Counter-Spy
re-validation at Gate 2.5, decision logging in Cartomarshal's checkpoint), plus two quality improvements: (a)
frontmatter-based detection (parsing `generated` and `status` rather than file existence alone — sharper); (b) explicit
user-facing Artifact Detection report block.

**Spot-checked all directives and forward notes**: profile-competitor frontmatter intact; Mapping disambiguation
phrasing present in all 4 researcher spawn prompts (lines 616, 644, 672, 700); Cipher non-literal phrasing present in
all 4; Integration Dependency Map naming (NOT Graph) at Stack Excavator SCOPE; JTBD cross-dimensional permission with
one-line justification at Storefront Walker SCOPE; 4 WHAT YOU CHALLENGE AT GATE [N] blocks in Counter-Spy spawn prompt;
4 explicit GATE markers in Orchestration Flow.

**Verdict**: APPROVED (re-confirmed). Both Scribe corrections are right; the relocation aligns with the canonical
reference and the new content additions (frontmatter-based detection, user-facing report) are quality upgrades. The
non-blocking forward note from the prior review (checkpoint phase enum gap) still applies and is still non-blocking.

- [04:30] Re-review of scribe2-f2a8 resubmission complete. Verdict: APPROVED (re-confirmed).
