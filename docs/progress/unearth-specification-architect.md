---
feature: "unearth-specification"
team: "conclave-forge"
agent: "architect"
phase: "design"
status: "complete"
last_action: "Produced team blueprint for unearth-specification skill"
updated: "2026-03-28T23:25:00Z"
---

# TEAM BLUEPRINT: Exhaustive Codebase Specification Extraction

## Mission

**Unearth Specification** — systematically excavate an existing codebase to produce a complete, structured, LLM-readable
specification of all business logic, data models, decision flows, architectural layers, and integration boundaries.

**Mission verb-noun**: Unearth specification.

## Classification

**Engineering** — The output is a set of technical specifications describing system behavior, data models, and
architectural decisions. Per classification rules: agents produce "technical specifications" → engineering. Agents read
and analyze code at depth, requiring engineering context in shared principles.

## Category

`engineering` — The skill analyzes code and produces technical specification artifacts.

## Phase Decomposition

| Phase | Name                | Agent(s)                                                          | Deliverable              | Input                                     | Output                                                                                                            |
| ----- | ------------------- | ----------------------------------------------------------------- | ------------------------ | ----------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 1     | Survey              | The Cartographer                                                  | Structural Map           | Raw codebase                              | Module inventory with dependency graph, tech stack profile, and priority-ranked partition assignments for Phase 2 |
| 1     | (Gate)              | The Assayer                                                       | Survey Verdict           | Structural Map                            | Approved/revised Structural Map with completeness assessment                                                      |
| 2     | Excavate (parallel) | The Logic Excavator, The Schema Excavator, The Boundary Excavator | Excavation Reports (3)   | Approved Structural Map + codebase        | Per-concern raw documentation: business rules, data models, integrations                                          |
| 2     | (Gate)              | The Assayer                                                       | Excavation Verdict       | All 3 Excavation Reports + Structural Map | Approved reports with coverage gap list (if any gaps: agents re-excavate targeted areas)                          |
| 3     | Chronicle           | The Chronicler                                                    | Specification Collection | Approved Excavation Reports               | Templated, cross-referenced, LLM-readable specification documents                                                 |
| 3     | (Gate)              | The Assayer                                                       | Final Verdict            | Specification Collection + Structural Map | Approved specification with completeness certificate                                                              |

## Agent Roster

| Agent                  | Concern (one sentence)                                                                                                                                                | Model  | Rationale                                                                                                                                                                                 |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| The Cartographer       | Structural mapping — inventories every file, module, entry point, and dependency to produce the dig-site map that partitions all subsequent work.                     | Opus   | Must reason about architecture, identify module boundaries in messy codebases, and make partitioning decisions that determine excavation quality.                                         |
| The Logic Excavator    | Business rule extraction — documents every conditional, decision tree, state machine, branching matrix, and workflow embedded in code.                                | Opus   | Business logic analysis is the hardest reasoning task: tracing control flow through poorly-organized code, inferring intent from implementation, and recognizing implicit state machines. |
| The Schema Excavator   | Data model extraction — documents every entity, relationship, constraint, migration, validation rule, and data transformation.                                        | Sonnet | Data model extraction is more structured: schemas, migrations, and model definitions follow recognizable patterns. Works from well-defined partition in the Structural Map.               |
| The Boundary Excavator | Integration extraction — documents every API endpoint, external service call, event/message bus, file I/O, queue, and system boundary.                                | Sonnet | Integration mapping follows recognizable patterns (HTTP clients, queue dispatches, event listeners). Works from well-defined partition in the Structural Map.                             |
| The Chronicler         | Synthesis and templating — consolidates raw excavation reports into a unified, cross-referenced, LLM-readable specification collection using consistent templates.    | Sonnet | Execution-oriented: applies templates to well-defined inputs. The hard reasoning (extraction and analysis) is already done by the excavators.                                             |
| The Assayer            | Completeness verification — adversarially validates that every module in the Structural Map is covered, every concern is documented, and no specification gap exists. | Opus   | Skeptic is always Opus. Must cross-reference the Structural Map against all excavation reports to find gaps, and must challenge the Chronicler's synthesis for accuracy.                  |

**Agent count justification**: 6 agents. The Cartographer earns its seat by owning the structural survey that no
excavator can do (they need the map before they can dig). The three Excavators each own a non-overlapping analytical
lens (logic, data, boundaries) and run in parallel — merging any two would eliminate parallelism and conflate distinct
expertise. The Chronicler owns synthesis — a concern no excavator holds (they produce raw reports, not templated
specifications). The Assayer is non-negotiable.

## Mandate Boundary Tests

| Agent A            | Agent B            | Boundary Statement                                                                                                                                                                                                                                                            |
| ------------------ | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cartographer       | Logic Excavator    | The Cartographer maps WHERE things are (file/module/dependency structure); the Logic Excavator documents WHAT the business rules DO within those locations.                                                                                                                   |
| Cartographer       | Schema Excavator   | The Cartographer identifies that a data layer exists and which files compose it; the Schema Excavator documents the entities, relationships, and constraints within that layer.                                                                                               |
| Cartographer       | Boundary Excavator | The Cartographer identifies that external integrations exist and where they connect; the Boundary Excavator documents the protocols, contracts, and behaviors of those integrations.                                                                                          |
| Logic Excavator    | Schema Excavator   | The Logic Excavator documents how code makes decisions (conditionals, workflows, state transitions); the Schema Excavator documents what data structures those decisions operate on.                                                                                          |
| Logic Excavator    | Boundary Excavator | The Logic Excavator documents internal business rules and control flow; the Boundary Excavator documents where the system talks to external systems and what crosses the boundary.                                                                                            |
| Schema Excavator   | Boundary Excavator | The Schema Excavator documents internal data structures and their relationships; the Boundary Excavator documents external data contracts (API schemas, message formats, import/export formats).                                                                              |
| Chronicler         | Assayer            | The Chronicler PRODUCES the templated specification collection; the Assayer EVALUATES it for completeness and accuracy against the source material.                                                                                                                           |
| Chronicler         | Logic Excavator    | The Chronicler organizes and templates raw findings; the Logic Excavator produces the raw findings about business rules. The Chronicler never reads code — only excavation reports.                                                                                           |
| Cartographer       | Chronicler         | The Cartographer produces the structural inventory used as the completeness baseline; the Chronicler uses that inventory as the organizational skeleton for the specification collection.                                                                                     |
| Cartographer       | Assayer            | The Cartographer produces the structural map; the Assayer uses it as the ground-truth checklist to verify excavation and chronicle completeness.                                                                                                                              |
| Logic Excavator    | Assayer            | The Logic Excavator extracts business rule findings from code; the Assayer verifies those findings are complete against the Structural Map's module inventory and challenges whether implicit logic was missed.                                                               |
| Schema Excavator   | Assayer            | The Schema Excavator extracts data model findings from code; the Assayer verifies every entity and relationship is accounted for and challenges whether undocumented constraints or migrations were overlooked.                                                               |
| Boundary Excavator | Assayer            | The Boundary Excavator extracts integration findings from code; the Assayer verifies every external dependency and API surface is documented and challenges whether hidden side-channels or implicit couplings were missed.                                                   |
| Schema Excavator   | Chronicler         | The Schema Excavator produces raw data model findings per module; the Chronicler templates those findings into the data-model documents and cross-references them with business rules and integrations that depend on the same entities.                                      |
| Boundary Excavator | Chronicler         | The Boundary Excavator produces raw integration findings per module; the Chronicler templates those findings into integration documents and consolidates them into the system-wide integration map with cross-references to the data contracts and business rules they serve. |

## Deliverable Chain

```
[Messy Codebase]
  → Phase 1: Survey
    → [Structural Map: module inventory, dependency graph, tech stack, partition assignments]
    → Assayer Gate
  → Phase 2: Excavate (fork-join, 3 parallel agents)
    → [Logic Report: business rules, decision trees, state machines, workflows]
    → [Schema Report: entities, relationships, constraints, migrations, validations]
    → [Boundary Report: APIs, events, external services, I/O, queues]
    → Assayer Gate (coverage verification against Structural Map)
  → Phase 3: Chronicle
    → [Specification Collection: templated, cross-referenced documents]
    → Assayer Gate (final completeness certificate)
  → [FINAL: Complete Specification Collection]
```

## Parallelization Analysis

### Phase 2 is a fork-join

The three Excavators run **fully in parallel**. Their mandates are orthogonal concerns (logic, data, boundaries) applied
across the same codebase. They share the same input (Structural Map + codebase access) but produce independent outputs.
No excavator depends on another excavator's findings.

**Fork point**: After Assayer approves the Structural Map (end of Phase 1). **Join point**: Before Assayer reviews
excavation coverage (start of Phase 2 gate).

### Sequential dependencies

- Phase 1 → Phase 2: Excavators need the approved Structural Map to know what to excavate and to follow the partition
  priority ranking.
- Phase 2 → Phase 3: The Chronicler needs all three excavation reports to produce cross-referenced templates.
- Phase 3 → Final Gate: The Assayer needs the completed Specification Collection.

### No partial-start opportunities

Phase 2 agents cannot start before Phase 1 completes because the Structural Map defines their work scope and priority
order. Phase 3 cannot start before all Phase 2 agents complete because the Chronicler must cross-reference all three
concern lenses to produce coherent templates (e.g., a feature's business rules reference its data model and its
integration points).

## Output Artifact Structure

The Specification Collection is a **directory of documents**, not a monolithic file. Structure:

```
docs/specifications/{project-name}/
  _index.md                          # Master index: table of contents, tech stack summary, key findings
  structural-map.md                  # Phase 1 output: module inventory, dependency graph
  modules/
    {module-name}/
      overview.md                    # Module purpose, entry points, dependencies
      business-rules.md              # Decision trees, conditionals, state machines, workflows
      data-model.md                  # Entities, relationships, constraints, validations
      integrations.md                # APIs, events, external services, I/O
  cross-cutting/
    authentication.md                # Cross-cutting: auth patterns across modules
    error-handling.md                # Cross-cutting: error handling patterns
    {concern}.md                     # Other cross-cutting concerns as discovered
  data-dictionary.md                 # Consolidated entity/relationship reference
  integration-map.md                 # Consolidated external dependency reference
  backward-compatibility-notes.md   # Data import considerations, format dependencies
```

### Document Templates

Each document type follows a consistent template with YAML frontmatter for LLM parseability:

**Module Business Rules Template:**

```yaml
---
module: "{module-name}"
type: "business-rules"
concern: "logic"
completeness: "exhaustive" # exhaustive | partial (with gaps listed)
---
```

**Module Data Model Template:**

```yaml
---
module: "{module-name}"
type: "data-model"
concern: "schema"
entity_count: N
relationship_count: N
---
```

**Module Integration Template:**

```yaml
---
module: "{module-name}"
type: "integration"
concern: "boundary"
external_dependencies: ["list", "of", "services"]
---
```

## Downstream Guidance Compliance

The Cartographer's Structural Map (Phase 1 output) MUST include a **priority-ranked partition table**:

```markdown
## Partition Assignments

| Priority | Module/Area  | Complexity | Rationale                                      |
| -------- | ------------ | ---------- | ---------------------------------------------- |
| 1        | core/billing | High       | Central business logic, most decision branches |
| 2        | core/auth    | High       | Security-critical, complex state machine       |
| 3        | api/v2       | Medium     | Primary integration surface                    |
| ...      | ...          | ...        | ...                                            |
```

Each Excavator starts with Priority 1 items in their concern area and works downward. This ensures the most critical
modules are documented first, enabling useful partial output even if a session is interrupted.

## Completeness Verification Methodology

The Assayer enforces completeness through a **coverage matrix**:

1. **Phase 1 Gate**: Every file in the codebase appears in the Structural Map. No orphan files. Module boundaries are
   justified (not arbitrary).
2. **Phase 2 Gate**: Every module in the Structural Map has at least one finding in each of the three excavation reports
   (logic, schema, boundary). Modules with zero findings in a concern must be explicitly marked "N/A — [reason]" (e.g.,
   a pure utility module may have no business rules).
3. **Phase 3 Gate**: Every module has a directory in the Specification Collection. The cross-cutting section covers
   patterns that span 3+ modules. The data dictionary includes every entity mentioned in any module's data model. The
   integration map includes every external dependency mentioned in any module's integration report.

The Assayer maintains a **coverage checklist** derived from the Structural Map and checks off each module × concern
cell.

## Design Rationale

### Why 3 phases (not 2 or 4)?

- **2 phases** (survey + document) would force a single agent to handle all three analytical lenses sequentially,
  eliminating the parallelism that makes this feasible on large codebases. A 500-file codebase with one documenter is
  impractical.
- **4+ phases** would add unnecessary sequentiality. Separating "read code" from "document findings" within an excavator
  creates artificial handoffs — the excavator reads and documents in one pass.
- **3 phases** gives us: structural understanding (Phase 1), deep parallel analysis (Phase 2), and coherent synthesis
  (Phase 3). Each phase has a distinct transformation: codebase → map, map → raw findings, raw findings → specification.

### Why 3 excavators (not 2 or 4)?

- **2 excavators** would require merging two of {logic, data, boundaries}. Logic+data merge loses the distinction
  between "what decisions are made" and "what structures support them." Data+boundaries merge loses the distinction
  between internal schemas and external contracts. Logic+boundaries merge forces the hardest analytical task (business
  rules) to share context with integration mapping.
- **4 excavators** would require splitting a concern further — e.g., separating "business rules" from "workflows" or
  "entities" from "relationships." These sub-concerns are too intertwined to parallelize safely.
- **3 excavators** map to the three fundamental questions about any system: What does it decide? (logic), What does it
  store? (data), What does it talk to? (boundaries). These are orthogonal lenses on the same code.

### Why a separate Chronicler?

The Chronicler could theoretically be eliminated if each excavator produced templated output directly. But:

- Cross-referencing requires seeing all three lenses simultaneously (a feature's business rules reference its data
  model).
- Template consistency requires a single owner — three excavators would drift on formatting.
- The Chronicler also produces the cross-cutting documents that span modules, which no single excavator owns.

### Alternatives considered and rejected

1. **Module-partitioned excavators** (each excavator gets 1/3 of the modules, documents all concerns): Rejected because
   it eliminates concern specialization. An agent documenting business rules benefits from seeing business rule patterns
   across the entire codebase, not just one partition.
2. **Two-phase pipeline** (map, then document everything in one parallel burst): Rejected because it produces raw
   findings without synthesis. The Chronicler phase is essential for cross-referencing and template consistency.
3. **Single mega-agent approach**: Rejected for obvious reasons — no parallelism, context window limitations on large
   codebases, no adversarial review.

## Handling Scale

For codebases with 500+ files:

- The Cartographer groups files into logical modules (not individual file documentation). A 500-file codebase might have
  20-40 modules, each of which becomes a unit of work for the excavators.
- Each Excavator processes modules in priority order, writing per-module findings to their progress file. If context
  limits are reached, the agent checkpoints and the Lead can re-spawn to continue.
- The fork-join structure means 3 agents work in parallel, effectively tripling throughput during the most
  time-intensive phase.
- The Chronicler processes one module at a time, producing one output document per module per concern, keeping
  individual file sizes manageable.
