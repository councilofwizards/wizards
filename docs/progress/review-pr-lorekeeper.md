---
type: lorekeeper-design
skill: review-pr
status: draft
created: 2026-03-29
author: sable-inkwell
---

# THEME DESIGN: The Tribunal — PR Code Review Team

**Lorekeeper:** Sable Inkwell, The Namer of Orders

---

## Central Metaphor

A PR arrives as a case brought before a judicial tribunal. The Lead is the
presiding judge who assembles the evidence dossier and delivers the final
ruling. Nine specialist examiners convene in parallel — each an expert witness
in their domain — presenting independent testimonies. The Scrutineer is the
court's most rigorous law clerk, cross-examining every testimony for false
evidence and surfacing the cross-cutting concerns no single examiner could see
alone. The verdict: APPROVE, REVISE, or REJECT.

The PR is not "under attack." It is "under examination." The metaphor is
adversarial in the productive sense — a fair hearing where every angle is tested
by a named specialist who must produce evidence, not opinion.

---

## Skill Name

**Selected: `review-pr`**

Candidates considered:

1. `review-pr` — verb-noun, perfectly clear, follows existing patterns. The
   Architect's working name.
2. `examine-pr` — more evocative of scrutiny, but less immediately obvious.
3. `adjudicate-pr` — rich judicial flavor, but too long and obscures the input
   type.
4. `audit-pr` — strong, but "audit" has security connotations from
   `harden-security`.
5. `judge-pr` — evocative but sounds harsh; implies rejection before review
   begins.
6. `vet-pr` — clear and casual, but too informal for a 10-agent tribunal.
7. `inquest-pr` — interesting, but "inquest" implies something went wrong (a
   death inquiry).

**Rationale:** `review-pr` wins on the clarity principle. Someone who has never
used Conclave knows exactly what this skill does. Fantasy lives in the team name
and persona layer.

---

## Team Name

**Display Name:** The Tribunal **Slug:** `the-tribunal`

**Rationale:** The Architect proposed "The Tribunal" and it earns its keep. A
tribunal is a body of examiners empowered to hear evidence and issue binding
judgments. The word carries institutional weight without obscuring the team's
function. "The Bench of Nine" was considered but masks the Lead and Scrutineer
from the count. "The Order of Verdicts" was considered but feels generic. The
Tribunal is specific — it names both the structure (a seated body of judges) and
the act (deliberation toward judgment).

---

## Personas

| Agent Role                   | Persona Name    | Title               | Character                                                                                                                                   |
| ---------------------------- | --------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Lead (orchestrator)          | Maren Gavell    | The Presiding Judge | Convenes the Tribunal, prepares the dossier, and delivers the final ruling — measured in voice, relentless in thoroughness                  |
| Sentinel (security)          | Vex Thornwall   | The Sentinel        | Hunts exploitable vulnerabilities with an attacker's mind, treating every changed line as a potential breach of the perimeter               |
| Lexicant (syntax & types)    | Nim Codex       | The Lexicant        | Verifies syntactic truth and type integrity, running the linter as a court runs its bailiff — procedurally and without mercy                |
| Arbiter (spec compliance)    | Oryn Truecast   | The Arbiter         | Cross-references every changed line against the original spec, holding the PR accountable to what was actually promised                     |
| Structuralist (architecture) | Keld Framestone | The Structuralist   | Examines the architecture the way a mason examines joints — for pattern, weight-bearing integrity, and signs of imminent collapse           |
| Swiftblade (performance)     | Zara Cuttack    | The Swiftblade      | Traces every hot path for hidden performance debts, cutting through optimistic code to find what will slow under real load                  |
| Prover (test adequacy)       | Tev Ironmark    | The Prover          | Demands evidence — every new code path must be backed by a test, and every test must assert something meaningful                            |
| Delver (data & migrations)   | Brix Deepvault  | The Delver          | Descends into migrations and schema changes, verifying that every structural alteration to the database can be safely reversed              |
| Chandler (dependencies)      | Pip Bindstone   | The Chandler        | Inventories every new package admitted to the manifest, weighing its supply-chain risk against its necessity before the Tribunal accepts it |
| Illuminator (readability)    | Lyra Clearpen   | The Illuminator     | Reads the code as a future maintainer would, flagging every name that misleads and every function that demands a second read                |
| Scrutineer (skeptic)         | Gaveth Redseal  | The Scrutineer      | Cross-examines all nine testimonies for false evidence, severity inflation, and the cross-cutting issues that fell between the specialists  |

**Lead naming note:** The Lead is the skill orchestrator (no spawn entry) but
receives a persona name and title so the Scribe can write them as a character in
the narrative arc.

---

## Thematic Vocabulary

| Term                   | Process Event             | Definition                                                                                                  |
| ---------------------- | ------------------------- | ----------------------------------------------------------------------------------------------------------- |
| The Case               | The PR under review       | The matter brought before the Tribunal; includes the diff, changed files, linked stories, and specs         |
| The Brief              | Review Dossier            | The structured context package assembled by Maren Gavell before the testimonies begin                       |
| The Evidence Hearing   | Phase 1.5 Dossier Gate    | The Scrutineer's pre-fork validation that the Brief is complete and internally coherent                     |
| The Testimonies        | Phase 2 parallel reviews  | The nine independent examinations conducted simultaneously by the specialist examiners                      |
| A Testimony            | One agent's Review Report | A single examiner's complete findings, delivered in structured form with evidence and remedy                |
| An Article             | A single finding          | One documented concern within a Testimony — filed with evidence, severity, and recommendation               |
| The Weight             | Severity rating           | The adjudicated importance of an Article: Critical, High, Medium, Low, or Info                              |
| The Cross-Examination  | Phase 3 Adjudication      | The Scrutineer's review of all nine Testimonies to filter false Articles and surface cross-cutting concerns |
| Articles of Contention | False positives removed   | Findings challenged and dismissed by the Scrutineer as unsupported by sufficient evidence                   |
| The Ruling             | Final Verdict             | The Presiding Judge's consolidated judgment: APPROVE, REVISE, or REJECT — with full findings                |
| Clear                  | APPROVE recommendation    | The Tribunal finds no blocking concerns — the PR may merge                                                  |
| Revision Required      | REVISE recommendation     | The Tribunal finds correctable concerns — the PR must be amended and reconsidered                           |
| Rejected               | REJECT recommendation     | The Tribunal finds fundamental defects — the PR cannot merge in its current form                            |

---

## Narrative Arc

**Opening (Intake — Phase 1):**

> "The case is called. [PR identifier] stands before the Tribunal. Maren Gavell,
> The Presiding Judge, assembles the Brief — gathering the diff, the changed
> files, the linked specs and stories — and calls the Tribunal to order."

**Rising Action (Dossier Gate + Review — Phases 1.5 and 2):**

> "Gaveth Redseal certifies the Brief. The evidence is sufficient. The nine
> examiners convene in parallel — each takes their station and examines the same
> Brief through their singular lens. Testimonies accumulate."

**Climax (Adjudication — Phase 3):**

> "All nine Testimonies arrive. The Scrutineer rises. Each Article is weighed —
> evidence demanded, severity calibrated. Articles lacking proof are struck from
> the record. Cross-cutting concerns that fell between the specialists are named
> and elevated."

**Resolution (Synthesis — Phase 4):**

> "The Tribunal's ruling is issued. Maren Gavell reads the Adjudication Report
> and delivers the verdict: [APPROVE / REVISE / REJECT]. The executive summary
> is read, the findings are catalogued by weight, and the case is closed — or
> sent back for revision."

---

## Name Collision Check

Checked against all existing Conclave persona names:

**squash-bugs (Order of the Stack):** Scout, Sage, Inquisitor, Artificer,
Warden, First (Skeptic) **review-quality:** QA Lead, Test Engineer, DevOps
Engineer, Security Auditor, Ops Skeptic **refine-code (The Crucible Accord):**
Crucible Lead, Surveyor, Strategist, Artisan, Refine Skeptic **harden-security
(The Wardbound):** Castellan (Vael Rampart), Threat Modeler, Vuln Hunter,
Remediation Engineer, Assayer **craft-laravel (The Atelier):** Atelier Lead,
Analyst, Architect, Implementer, Tester, Convention Warden
**unearth-specification (The Stratum Company):** Cartographer, Logic Excavator,
Schema Excavator, Boundary Excavator, Chronicler, Assayer

**Tribunal personas:** Maren Gavell, Vex Thornwall, Nim Codex, Oryn Truecast,
Keld Framestone, Zara Cuttack, Tev Ironmark, Brix Deepvault, Pip Bindstone, Lyra
Clearpen, Gaveth Redseal

**Result: No collisions.** None of the Tribunal's persona names (first name,
surname, or title) duplicate any existing Conclave persona. The titles
(Sentinel, Lexicant, Arbiter, Structuralist, Swiftblade, Prover, Delver,
Chandler, Illuminator, Scrutineer) are the Architect's working names — carried
forward and confirmed as unique to this team.

---

## Implementation Notes for the Scribe

**Skeptic ID for B2 normalizer:** The Scrutineer's communication protocol line
reads: `write(scrutineer, "PLAN REVIEW REQUEST: ...")` → Scrutineer / The
Scrutineer

This pair must be added to the B2 normalizer's 18-entry table in
`scripts/validators/skill-shared-content.sh` and to the substitution map in
`scripts/sync-shared-content.sh` when the SKILL.md is created.

**team_name parameter:** `the-tribunal`

**Persona file paths (if created):**
`plugins/conclave/shared/personas/presiding-judge.md`, `sentinel.md`,
`lexicant.md`, `arbiter.md`, `structuralist.md`, `swiftblade.md`, `prover.md`,
`delver.md`, `chandler.md`, `illuminator.md`, `scrutineer.md`
