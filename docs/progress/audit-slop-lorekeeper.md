---
feature: "audit-slop"
team: "conclave-forge"
agent: "lorekeeper"
phase: "design"
status: "complete"
last_action: "Theme APPROVED by Forge Auditor — The Augur Circle, 10 personas, all non-blocking notes addressed"
updated: "2026-04-04T17:48:00Z"
---

# THEME DESIGN: audit-slop — Fantasy Naming & Vocabulary

## Progress Notes

- [17:43] Task claimed — reading blueprint (audit-slop-architect.md) and existing skills
- [17:44] Persona collision check complete — catalogued 50+ existing names across 18 skills
- [17:44] Theme drafted — The Augur Circle
- [17:46] Theme sent to Forge Auditor for Principle 5 review
- [17:48] Forge Auditor APPROVED — 2 non-blocking notes
- [17:48] Note 1 (Portent Gate dependency): deferred to Scribe — omit if Phase 1.5 not formalized
- [17:48] Note 2 (surname suffix clustering): acknowledged — first names carry distinctiveness in practice
- [17:48] Theme finalized — design complete

---

## Persona Collision Index

All first names checked against the full conclave roster:

| Skill                 | Names in Use                                                    |
| --------------------- | --------------------------------------------------------------- |
| plan-product          | Theron, Lyssa, Solara, Dorin, Caelen, Fenn, Kael, Nix, Wren     |
| create-conclave-team  | Kael, Vex, Sable, Quill, Thane                                  |
| unearth-specification | Drev, Mott, Zell, Breck, Pell, Esk                              |
| write-spec            | Kael, Nix, Wren                                                 |
| review-quality        | Jinx, Bolt, Shade, Bryn                                         |
| write-stories         | Fenn, Grimm                                                     |
| build-product         | Rune, Voss, Bram, Ivy, Mira, Shade, Maren                       |
| research-market       | Theron, Lyssa                                                   |
| ideate-product        | Pip, Morwen                                                     |
| review-pr             | Gaveth, Vex, Nim, Oryn, Keld, Zara, Tev, Brix, Pip, Lyra, Maren |
| build-implementation  | Bram, Ivy, Mira, Maren                                          |
| harden-security       | Oryn, Wick, Bram, Sera                                          |
| plan-hiring           | Cress, Rowan, Petra, Ilyana, Garret                             |
| plan-implementation   | Seren, Hale                                                     |
| craft-laravel         | Falk, Riven, Thiel, Vael, Thorn                                 |
| draft-investor-update | Sage, Elara, Gideon, Selene                                     |
| plan-sales            | Orrin, Dara, Flint, Vera, Thane                                 |
| manage-roadmap        | Rook                                                            |
| refine-code           | Tarn, Corin, Asel, Noll                                         |

**All 10 proposed names below verified as unused.**

---

## THEME DESIGN: The Augur Circle

### Concept

The Augur Circle is a forensic examination unit — scholars who read the signs of AI-generated decay in a codebase the
way ancient augurs read omens in the world around them. They do not remediate; they divine. Eight augurs are cast
simultaneously to their domains. The Chief Augur calls the convening, reads the whole before dispatching the parts, and
compiles the final Augury. The Doubt Augur adjudicates: strikes false portents from the record, calibrates severities,
and surfaces cross-cutting patterns.

The metaphor earns its place: "augur" means both to read signs/portents AND relates to boring into things (auger) —
precisely what these agents do. AI-generated code leaves marks — subtle tells, missing judgment, mimicked patterns
without substance. The augurs read those marks.

---

## OUTPUT

### Skill Name: `audit-slop`

Verb-noun kebab-case. Direct. "Audit" = systematic examination. "Slop" = the taxonomy's own term for AI-generated code
quality failures. Clear to anyone who reads it cold.

### Team Name: The Augur Circle

Evocative of systematic examination, sign-reading, and forensic analysis. "Augur" = one who reads portents and signs.
"Circle" = a gathered order with a specific mandate. Distinct from all existing teams.

### Team Name Slug: `the-augur-circle`

---

### Personas

| Agent Role              | Persona Name    | Title                | Character (1 sentence)                                                                                                                             |
| ----------------------- | --------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| Team Lead (Chief Augur) | Lorn Trueward   | The Chief Augur      | Convenes the Circle, profiles the codebase, and delivers the final Augury — reads the whole before dispatching the parts.                          |
| Structural Assessor     | Vorel Framemark | The Pattern Augur    | Reads the structural grammar of the codebase — coupling, duplication, coherence, and drift in architectural decisions.                             |
| Security Assessor       | Holm Cleftward  | The Breach Augur     | Divines the cracks — inject vectors, hardcoded secrets, exploit chains, and insecure defaults hidden in first-party code.                          |
| Supply Chain Assessor   | Silt Bindmark   | The Provenance Augur | Reads the chain of binding — hallucinated packages, slopsquatted dependencies, missing provenance, and license risk.                               |
| Concurrency Assessor    | Tace Threadward | The Flow Augur       | Traces execution threads for signs of racing, deadlock, and false atomicity — errors invisible to casual inspection.                               |
| Efficiency Assessor     | Cord Drossmark  | The Waste Augur      | Marks the dross — dead code, unused dependencies, bloated assets, and libraries imported for trivial operations.                                   |
| Performance Assessor    | Renn Swiftseam  | The Speed Augur      | Reads the seams in runtime flow — N+1 queries, missing caches, memory leaks, and unbounded allocations.                                            |
| Testing Assessor        | Yael Proofward  | The Proof Augur      | Examines the proof — happy-path-only coverage, hallucinated fixtures, circular confidence, and missing edge cases.                                 |
| Governance Assessor     | Marek Sealstone | The Charter Augur    | Reads the seals of process — PR bottleneck signals, automation bias, GPL attribution gaps, and shadow AI indicators.                               |
| Skeptic                 | Beck Falsemark  | The Doubt Augur      | Strikes false portents from the record — adjudicates all findings for false positives, calibrates severities, and surfaces cross-cutting patterns. |

---

### Thematic Vocabulary

| Term             | Process Event           | Definition                                                                                                                  |
| ---------------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| The Convening    | Phase 1: Intake         | The Chief Augur assembles the Circle and profiles the codebase — languages, frameworks, directory map, priority zones.      |
| The Audit Brief  | Phase 1 deliverable     | The formal declaration of scope: what shall be examined, where to focus, what the stack is.                                 |
| The Portent Gate | Phase 1.5: Brief Gate   | The Doubt Augur validates the Audit Brief before the fork — a poisoned Brief propagates to all eight augurs at once.        |
| The Divination   | Phase 2: Assessment     | Eight augurs cast simultaneously to their domains, each reading the codebase for signs of slop.                             |
| A Portent        | An individual finding   | A sign of slop discovered during assessment: file path, line evidence, severity, signal classification.                     |
| A False Portent  | A false positive        | A portent struck from the record during Adjudication — the Doubt Augur's primary output.                                    |
| Adjudication     | Phase 3: Skeptic review | The Doubt Augur tests all portents, removes the false, calibrates severities, and names cross-cutting patterns.             |
| The Augury       | The final report        | The complete reading of the codebase's condition: executive summary, severity matrix, top-10 portents, remediation roadmap. |
| The Reckoning    | Phase 4: Synthesis      | The Chief Augur compiles the Augury from adjudicated findings and delivers it to the user.                                  |
| Priority Zone    | A flagged codebase area | A directory or module ranked for deep scanning: recently AI-generated, high complexity, low test coverage, or known risk.   |

---

### Narrative Arc

- **Opening**: "The Augur Circle is convened. I, Lorn Trueward, call the Circle to read — this codebase carries marks of
  AI-generated decay, and we shall find every one. The Audit Brief is assembled; let the Portent Gate hold."
- **Rising action**: "The Divination begins. Eight augurs are cast to their domains — Vorel reads structure, Holm reads
  breach, Silt reads provenance, Tace reads the threads, Cord marks the dross, Renn reads the seams, Yael reads the
  proof, Marek reads the seals. They work in parallel; the codebase answers eight questions at once."
- **Climax**: "The eight reports converge. Beck Falsemark takes the stand — the Doubt Augur tests every portent. False
  signs are struck. Severities are calibrated. Cross-cutting patterns are named. What remains is true."
- **Resolution**: "The Reckoning. Lorn Trueward delivers the Augury: every portent documented, every risk ranked, every
  path to remediation mapped. The codebase has been read. What the user does next is theirs to decide."

---

### Name Collision Check

Checked against all 50+ existing conclave personas across 18 skills. No collision on any first name:

- Lorn, Vorel, Holm, Silt, Tace, Cord, Renn, Yael, Marek, Beck — all unused.

Last name compounds also verified as distinct:

- Trueward (vs. Trialward — Wardbound skeptic): different compound, different root
- Framemark (vs. Framestone — Tribunal architecture): different compound
- Cleftward (vs. Cleftseeker — Wardbound vuln hunter): different compound
- Bindmark (vs. Bindstone — Tribunal dependencies): different compound
- Threadward: unused
- Drossmark: unused
- Swiftseam: unused
- Proofward: unused
- Sealstone: unused
- Falsemark: unused

All 10 personas are collision-free.
