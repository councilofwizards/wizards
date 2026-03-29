---
feature: "unearth-specification"
team: "conclave-forge"
agent: "forge-auditor"
phase: "design-review"
status: "approved"
verdict: "APPROVED — Phase 1, Phase 2, and Phase 3 seals granted"
last_action: "Phase 3 full SKILL.md compliance review against all Five Design Principles"
updated: "2026-03-28T23:55:00Z"
---

# FORGE AUDITOR REVIEW: unearth-specification

**Reviewer**: Thane Hallward, The Seal-Bearer

---

# Phase 1 Review: Design Blueprint — APPROVED

**Artifact**: `docs/progress/unearth-specification-architect.md` **Principles**: 1 (One mission), 3 (Non-overlapping
mandates)

Mission singular ("unearth specification" — one verb, one noun). Three phases with distinct transformations and complete
deliverable chain. All 6 agents earn seats. All 15 boundary pairs provided (5 added in revision). Fork-join correctly
identified in Phase 2. Classification: engineering (correct).

---

# Phase 2 Review: Methodologies and Theme — APPROVED

**Artifacts**: `docs/progress/unearth-specification-armorer.md`, `docs/progress/unearth-specification-lorekeeper.md`
**Principles**: 2 (Methodology over role), 4 (Evidence over assertion), 5 (Fantasy is voice)

21 methodologies across 6 agents (3-4 each), all named real techniques with 7 academic citations. All 21 output
artifacts distinct. Every methodology has explicit skeptic challenge surface. Theme ("The Stratum Company") enhances
understanding. Skill name immediately clear. All 6 personas collision-free. All 8 vocabulary terms map to real process
events.

---

# Phase 3 Review: SKILL.md Full Compliance — APPROVED

**Artifact**: `plugins/conclave/skills/unearth-specification/SKILL.md` (1224 lines) **Evaluation**: All Five Design
Principles + structural compliance checklist

## Verdict: APPROVED

The SKILL.md is production-quality, structurally compliant, and satisfies all Five Design Principles. Zero blocking
deficiencies. One advisory noted (persona files pending creation in Phase 4).

---

## Structural Compliance Checklist

### Frontmatter

| Field         | Value                                                                              | Status                         |
| ------------- | ---------------------------------------------------------------------------------- | ------------------------------ | -------------- | ------------------------------- | ---- |
| name          | `unearth-specification`                                                            | PASS                           |
| description   | Present, multi-line                                                                | PASS                           |
| argument-hint | `"[--light] [status                                                                | <codebase-path-or-description> | survey <scope> | (empty for resume or intake)]"` | PASS |
| category      | `engineering`                                                                      | PASS                           |
| tags          | `[code-archaeology, reverse-engineering, specification-extraction, documentation]` | PASS                           |

### Section Ordering

| #   | Section                             | Lines    | Status |
| --- | ----------------------------------- | -------- | ------ |
| 1   | Title + role declaration            | 12-19    | PASS   |
| 2   | Setup                               | 21-37    | PASS   |
| 3   | Write Safety                        | 39-49    | PASS   |
| 4   | Checkpoint Protocol                 | 51-101   | PASS   |
| 5   | Determine Mode (incl. Flag Parsing) | 103-130  | PASS   |
| 6   | Lightweight Mode                    | 132-142  | PASS   |
| 7   | Spawn the Team                      | 144-207  | PASS   |
| 8   | Orchestration Flow                  | 210-353  | PASS   |
| 9   | Critical Rules                      | 324-337  | PASS   |
| 10  | Failure Recovery                    | 339-352  | PASS   |
| 11  | Shared Principles (universal)       | 356-377  | PASS   |
| 12  | Engineering Principles              | 379-395  | PASS   |
| 13  | Communication Protocol              | 399-465  | PASS   |
| 14  | Teammate Spawn Prompts              | 469-1224 | PASS   |

Section ordering matches the structural template exactly.

### Setup Section (lines 21-37)

- [x] Directory creation: 6 directories including `docs/specifications/` (skill-specific) — lines 26-31
- [x] Template reads: `docs/progress/_template.md` — line 32
- [x] Stack detection: dependency manifest scan, stack-hint loading — lines 33-34
- [x] ADR reads: `docs/architecture/` — line 35
- [x] Prior work detection: checkpoint files with `team: "the-stratum-company"` — lines 36-37

PASS.

### Write Safety (lines 39-49)

- [x] Role-scoped progress files: `docs/progress/{project}-{role-slug}.md` — line 43
- [x] Specification files owned by Chronicler only — lines 45-46
- [x] Shared files owned by Dig Master only — lines 47-48

PASS.

### Checkpoint Protocol (lines 51-101)

- [x] Team name: `"the-stratum-company"` — line 61
- [x] Phase enum: `survey | excavate | chronicle | complete` — line 63
- [x] YAML frontmatter template with all fields — lines 57-72
- [x] SCAFFOLD comment on checkpoint frequency — line 74 (all three fields present)
- [x] Three checkpoint frequency modes: every-step, milestones-only, final-only — lines 80-101

PASS.

### Determine Mode (lines 103-130)

- [x] `"status"`: consolidated status report, no agent spawn — lines 117-120
- [x] Empty/no args: resume from checkpoint or prompt for intake — lines 121-124
- [x] `"[codebase-path-or-description]"`: full pipeline — lines 125-126
- [x] `"survey [scope]"`: Phase 1 only mode — lines 127-129

PASS.

### Flag Parsing (lines 106-113)

- [x] `--light`: enable lightweight mode — line 109
- [x] `--max-iterations N`: configurable skeptic ceiling, default 3, validation — lines 110-111
- [x] `--checkpoint-frequency`: three values, validation — lines 112-113

PASS.

### Lightweight Mode (lines 132-142)

- [x] Logic Excavator downgraded to Sonnet — line 137
- [x] Assayer NEVER downgraded, explicitly stated — line 138
- [x] SCAFFOLD comment on Logic Excavator Opus default — line 142 (all three fields present)

PASS.

### Spawn the Team (lines 144-207)

- [x] Step 1: TeamCreate with `team_name: "the-stratum-company"` — line 146
- [x] Step 2: TaskCreate — line 147
- [x] Step 3: Agent tool with `team_name: "the-stratum-company"` — lines 148-149

Each teammate definition verified:

| Agent              | Name                 | Model                    | Prompt               | Tasks   | Phase         | Status |
| ------------------ | -------------------- | ------------------------ | -------------------- | ------- | ------------- | ------ |
| Cartographer       | `cartographer`       | opus                     | ref to spawn prompts | Present | 1 (Survey)    | PASS   |
| Logic Excavator    | `logic-excavator`    | opus (sonnet in --light) | ref to spawn prompts | Present | 2 (Excavate)  | PASS   |
| Schema Excavator   | `schema-excavator`   | sonnet                   | ref to spawn prompts | Present | 2 (Excavate)  | PASS   |
| Boundary Excavator | `boundary-excavator` | sonnet                   | ref to spawn prompts | Present | 2 (Excavate)  | PASS   |
| Chronicler         | `chronicler`         | sonnet                   | ref to spawn prompts | Present | 3 (Chronicle) | PASS   |
| Assayer            | `assayer`            | opus                     | ref to spawn prompts | Present | All phases    | PASS   |

SCAFFOLD comment on Assayer model — line 196 (all three fields present). PASS.

### Orchestration Flow (lines 210-353)

- [x] **Artifact Detection** (lines 215-229): 5 detection levels (cartographer complete → excavators complete →
      chronicler complete), user confirmation before skipping — PASS
- [x] **Phase 1: Survey** (lines 231-249): explicit GATE marker ("GATE — blocks Phase 2") at line 243, survey-only mode
      exit point at line 248 — PASS
- [x] **Phase 2: Excavate** (lines 251-270): fork-join with explicit simultaneous spawn instruction ("do NOT wait for
      one to complete before spawning the next"), GATE marker ("GATE — blocks Phase 3") at line 266, coverage matrix
      construction by Dig Master — PASS
- [x] **Phase 3: Chronicle** (lines 272-302): output directory structure specified, GATE marker ("GATE — final") at line
      298 — PASS
- [x] **Between Phases** (lines 304-309): status checkpoint, user narrative update, gate enforcement — PASS
- [x] **Pipeline Completion** (lines 311-322): session summary, cost summary, narrative delivery — PASS

PASS.

### Critical Rules (lines 324-337)

8 rules covering:

- [x] Assayer must approve each phase (no exceptions)
- [x] Phase 2 true fork-join (never sequential)
- [x] Chronicler never reads source code
- [x] Provenance required on all findings
- [x] Assayer coverage matrix is authoritative
- [x] Write isolation enforced
- [x] Assayer never downgraded
- [x] Priority-ranked processing with graceful degradation

SCAFFOLD comment on max iterations — line 337 (all three fields present). PASS.

### Failure Recovery (lines 339-352)

- [x] Unresponsive agent: re-spawn with checkpoint context — lines 341-342
- [x] Skeptic deadlock: escalate to human after N rejections — lines 343-346
- [x] Phase 2 partial completion: re-spawn incomplete excavator, preserve completed reports — lines 347-349
- [x] Context exhaustion: detect degradation, re-spawn with checkpoint — lines 350-352

PASS.

### SCAFFOLD Comments

| Line | Construct                    | Three Fields                         | Inside Spawn Block? | Status |
| ---- | ---------------------------- | ------------------------------------ | ------------------- | ------ |
| 74   | Checkpoint frequency         | SCAFFOLD / ASSUMPTION / TEST REMOVAL | No                  | PASS   |
| 142  | Logic Excavator Opus default | SCAFFOLD / ASSUMPTION / TEST REMOVAL | No                  | PASS   |
| 196  | Skeptic Opus model           | SCAFFOLD / ASSUMPTION / TEST REMOVAL | No                  | PASS   |
| 337  | Max N skeptic rejections     | SCAFFOLD / ASSUMPTION / TEST REMOVAL | No                  | PASS   |

All 4 SCAFFOLD comments have all three required fields. None are inside spawn prompt code blocks. PASS.

### Shared Content Markers

| Marker                                          | Present  | Comment                              | Status |
| ----------------------------------------------- | -------- | ------------------------------------ | ------ |
| `<!-- BEGIN SHARED: universal-principles -->`   | Line 356 | Authoritative source comment present | PASS   |
| `<!-- END SHARED: universal-principles -->`     | Line 377 | —                                    | PASS   |
| `<!-- BEGIN SHARED: engineering-principles -->` | Line 379 | Authoritative source comment present | PASS   |
| `<!-- END SHARED: engineering-principles -->`   | Line 395 | —                                    | PASS   |
| `<!-- BEGIN SHARED: communication-protocol -->` | Line 399 | Authoritative source comment present | PASS   |
| `<!-- END SHARED: communication-protocol -->`   | Line 465 | —                                    | PASS   |

All three shared content blocks present with correct markers. PASS.

### Communication Protocol Skeptic Name

Line 447: `write(assayer, "PLAN REVIEW REQUEST: ...")` / `The Assayer` Substitution comment present:
`<!-- substituted by sync-shared-content.sh per skill -->`

PASS.

### Spawn Prompt Structure

Every spawn prompt follows the required template:

| Section        | Cartographer | Logic Exc. | Schema Exc. | Boundary Exc. | Chronicler | Assayer |
| -------------- | ------------ | ---------- | ----------- | ------------- | ---------- | ------- |
| Persona read   | L478         | L600       | L721        | L826          | L931       | L1057   |
| Persona line   | L480         | L602       | L723        | L828          | L933       | L1059   |
| YOUR ROLE      | L483         | L605       | L726        | L831          | L936       | L1062   |
| CRITICAL RULES | L489         | L612       | L732        | L837          | L944       | L1068   |
| Methodologies  | 4            | 4          | 3           | 3             | 3          | 4       |
| Output format  | L560         | L685       | L792        | L895          | L1020      | L1186   |
| COMMUNICATION  | L582         | L702       | L807        | L911          | L1036      | L1212   |
| WRITE SAFETY   | L590         | L712       | L817        | L921          | L1046      | L1220   |

All 6 spawn prompts follow the correct structure. PASS.

### Assayer Phase-Specific Challenge Sections

| Section                                  | Lines     | Challenges Listed                                                                                                             | Status |
| ---------------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------- | ------ |
| WHAT YOU CHALLENGE (PHASE 1 — SURVEY)    | 1142-1152 | 5 (file coverage, module boundaries, dependency completeness, hidden dependencies, priority ranking)                          | PASS   |
| WHAT YOU CHALLENGE (PHASE 2 — EXCAVATE)  | 1154-1167 | 6 (coverage matrix, N/A quality, decision tables, schema reconciliation, route coverage, event consumers)                     | PASS   |
| WHAT YOU CHALLENGE (PHASE 3 — CHRONICLE) | 1169-1184 | 7 (traceability, orphaned findings, template compliance, gap justifications, cross-cutting, data dictionary, integration map) | PASS   |

The Assayer has explicit challenge lists for all three phases with specific, actionable challenge strategies. PASS.

---

## Five Design Principles — Final Verification

| Principle                                       | Evidence                                                                                                                                                                         | Verdict |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| 1. One mission, decomposed into phases          | "Unearth specification" — singular verb-noun. 3 phases with named deliverables and complete chain.                                                                               | PASS    |
| 2. Methodology over role description            | 21 named methodologies with procedures, outputs, and academic citations. No agent is described by role alone.                                                                    | PASS    |
| 3. Non-overlapping mandates                     | All 15 boundary pairs explicit. Concern-partitioned excavation (logic/data/boundaries). No output type overlap.                                                                  | PASS    |
| 4. Evidence over assertion, enforced by skeptic | Assayer gates every phase with 4 adversarial methodologies. Every methodology produces challengeable structured output. Phase-specific challenge lists with 18 total challenges. | PASS    |
| 5. Fantasy is the voice, not the process        | Archaeological metaphor enhances understanding. Personas are named in prompts. Thematic vocabulary maps to real events. Process is clearly described independent of fantasy.     | PASS    |

---

## Quality Comparison

Would this skill be indistinguishable in quality from established skills like squash-bugs or review-quality?

**Yes.** The SKILL.md demonstrates:

- Identical structural template adherence (all sections in correct order)
- Comparable line count (1224 lines — within range of established engineering skills)
- Same spawn prompt template (persona read → persona line → YOUR ROLE → CRITICAL RULES → methodologies → output →
  COMMUNICATION → WRITE SAFETY)
- Same orchestration patterns (artifact detection, phase gating, between-phases, pipeline completion)
- Same safety infrastructure (write safety, checkpoint protocol, failure recovery, SCAFFOLD comments)
- Same shared content integration (3 marker blocks with correct skeptic substitution)
- Richer methodology detail than most existing skills (21 methodologies with full procedures vs. typical 12-16)
- Novel fork-join pattern that is well-specified (explicit fork/join points, parallel spawn instructions)

---

## Advisory (Non-Blocking)

**Persona files pending**: The 6 spawn prompts reference `plugins/conclave/shared/personas/{role}.md` files that do not
yet exist (cartographer.md, logic-excavator.md, schema-excavator.md, boundary-excavator.md, chronicler.md, assayer.md).
This is the standard pattern across all 18+ multi-agent skills — the persona files are created during skill registration
(Phase 4). The spawn prompts are self-contained regardless. **No action required at this gate; Phase 4 must create these
files.**

---

## Summary

| Check                                                            | Verdict |
| ---------------------------------------------------------------- | ------- |
| Frontmatter fields                                               | PASS    |
| Section ordering                                                 | PASS    |
| Setup (directories, templates, stack detection)                  | PASS    |
| Write Safety (role-scoped)                                       | PASS    |
| Checkpoint Protocol (team name, phase enum)                      | PASS    |
| Determine Mode (status, empty, concept, survey)                  | PASS    |
| Flag Parsing (--light, --max-iterations, --checkpoint-frequency) | PASS    |
| Lightweight Mode (Logic Excavator down, Assayer never)           | PASS    |
| Spawn the Team (3-step pattern)                                  | PASS    |
| Teammate definitions (Name, Model, Prompt, Tasks, Phase)         | PASS    |
| Orchestration Flow (GATE markers at every transition)            | PASS    |
| Artifact Detection (before pipeline execution)                   | PASS    |
| Between Phases + Pipeline Completion                             | PASS    |
| Critical Rules                                                   | PASS    |
| Failure Recovery (4 scenarios)                                   | PASS    |
| SCAFFOLD comments (4, all 3 fields, none in spawn blocks)        | PASS    |
| Shared content markers (3 blocks)                                | PASS    |
| Communication protocol skeptic name                              | PASS    |
| Spawn prompt structure (all 6 agents)                            | PASS    |
| Assayer WHAT YOU CHALLENGE (all 3 phases)                        | PASS    |
| Principle 1: One mission                                         | PASS    |
| Principle 2: Methodology over role                               | PASS    |
| Principle 3: Non-overlapping mandates                            | PASS    |
| Principle 4: Evidence over assertion                             | PASS    |
| Principle 5: Fantasy is the voice                                | PASS    |
| Quality parity with established skills                           | PASS    |

**26 of 26 checks pass. Zero blocking deficiencies.**

## Seal Granted — Phase 3

The SKILL.md for **unearth-specification** is approved for registration.

---

_Thane Hallward, The Seal-Bearer — the seal is granted. The Stratum Company is forged._
