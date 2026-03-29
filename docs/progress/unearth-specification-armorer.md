---
feature: "unearth-specification"
team: "conclave-forge"
agent: "armorer"
phase: "design"
status: "complete"
last_action: "Produced methodology manifests for all 6 agents"
updated: "2026-03-28T23:35:00Z"
---

# METHODOLOGY MANIFESTS: Unearth Specification

Each agent carries 2-4 named methodologies. Every methodology produces a structured artifact that the Assayer can
challenge at the row, entry, or step level.

---

## METHODOLOGY MANIFEST: The Cartographer

**Concern**: Structural mapping — inventory every file, module, entry point, and dependency.

### Methodologies

1. **Dependency Graph Analysis** — Trace import/require/use statements across every file to build a directed graph of
   module-to-module dependencies, identifying clusters, cycles, and fan-in/fan-out hotspots.
   - Output: **Dependency Adjacency Matrix** — a table where rows and columns are modules, cells indicate dependency
     direction and type (import, inheritance, injection, event).
   - Skeptic challenge surface: The Assayer can point at any empty cell and demand proof that no dependency exists, or
     at any populated cell and demand the specific file:line evidence.

2. **Conceptual Architecture Recovery** (Tzerpos & Holt) — Cluster source files into higher-level modules based on
   naming conventions, directory structure, shared dependencies, and cohesion signals, then validate clusters against
   actual coupling.
   - Output: **Module Clustering Map** — a table listing each discovered module, its constituent files, the clustering
     rationale (naming, directory, coupling), and cohesion score (high/medium/low based on internal vs. external
     dependency ratio).
   - Skeptic challenge surface: The Assayer can challenge any module boundary — demanding evidence that two adjacent
     modules are truly distinct or that a file assigned to Module A doesn't belong in Module B.

3. **Fan-in/Fan-out Analysis** (Henry & Kafura) — Measure each module's structural complexity by counting inbound
   consumers (fan-in) and outbound dependencies (fan-out) to identify central hubs and peripheral utilities.
   - Output: **Structural Complexity Table** — each module with fan-in count, fan-out count, computed complexity score
     (fan-in × fan-out)², and a classification: hub (high both), source (high fan-out), sink (high fan-in), or
     peripheral (low both).
   - Skeptic challenge surface: The Assayer can question any fan-in or fan-out count by demanding the specific
     dependency list, or challenge whether a "peripheral" classification is masking hidden coupling through indirect
     paths.

4. **Work Breakdown Structure (WBS) Decomposition** — Partition the codebase into priority-ranked excavation units based
   on structural complexity, business criticality signals (naming, centrality), and dependency depth.
   - Output: **Priority-Ranked Partition Table** — each partition with priority rank, module(s), estimated complexity
     (High/Medium/Low), primary concern weighting (logic-heavy, data-heavy, boundary-heavy), and rationale.
   - Skeptic challenge surface: The Assayer can challenge any priority ranking by demanding justification for why Module
     X outranks Module Y, or question whether a "Low" complexity rating is hiding unconventional code patterns.

---

## METHODOLOGY MANIFEST: The Logic Excavator

**Concern**: Business rule extraction — document every conditional, decision tree, state machine, and workflow.

### Methodologies

1. **Decision Table Extraction** — Identify every conditional branch (if/else, switch, guard clause, ternary, pattern
   match) and encode it as a structured decision table mapping condition combinations to actions.
   - Output: **Decision Table Catalog** — one decision table per business rule, with columns for each condition
     variable, rows for each condition combination, and cells for the resulting action. Each table carries a source
     reference (file:line range).
   - Skeptic challenge surface: The Assayer can point at any decision table and demand proof that all condition
     combinations are represented (no missing rows), or challenge whether a condition variable was omitted.

2. **State Machine Analysis** — Identify entities with lifecycle behavior (status fields, phase transitions, workflow
   stages) and extract their states, transitions, guards, and actions into formal state machine definitions.
   - Output: **State Transition Table** — per entity: columns for current state, event/trigger, guard condition, next
     state, and side effects. Each transition carries a source reference.
   - Skeptic challenge surface: The Assayer can challenge any state as unreachable, any transition as undocumented, or
     demand evidence that no additional states are hidden in the code (e.g., soft-deleted or error states).

3. **Program Slicing** (Weiser, 1981) — For each critical business variable (prices, permissions, statuses, balances),
   trace backward through all statements that affect its value to extract the complete computation chain.
   - Output: **Slice Dependency Chain** — per critical variable: an ordered list of statements (file:line) that
     influence the variable's value, with annotations for control dependencies (conditionals that gate execution) vs.
     data dependencies (assignments that set value).
   - Skeptic challenge surface: The Assayer can challenge any chain as incomplete — demanding proof that no additional
     assignment or mutation was missed — or question whether a control dependency was incorrectly classified as
     non-influencing.

4. **Cyclomatic Complexity Profiling** (McCabe, 1976) — Measure the number of independent execution paths through each
   function to identify logic-dense hotspots requiring deeper excavation and to flag functions where extraction may be
   incomplete.
   - Output: **Complexity Hotspot Register** — each function with cyclomatic complexity score, file:line, a
     classification (simple ≤5, moderate 6-15, complex 16-30, untestable >30), and a flag indicating whether its
     decision table fully covers the measured paths.
   - Skeptic challenge surface: The Assayer can compare the complexity score against the number of decision table rows
     for the same function — a mismatch indicates missing branches. Can also challenge whether "simple" functions
     contain hidden complexity via called subroutines.

---

## METHODOLOGY MANIFEST: The Schema Excavator

**Concern**: Data model extraction — document every entity, relationship, constraint, migration, and validation rule.

### Methodologies

1. **Entity-Relationship Modeling** (Chen, 1976) — Identify every persistent entity (model, table, document) and extract
   its attributes, data types, primary keys, foreign keys, and relationships (1:1, 1:N, M:N) into a structured ER
   catalog.
   - Output: **Entity-Relationship Catalog** — per entity: attribute table (name, type, nullable, default, constraints),
     relationship table (target entity, cardinality, foreign key, cascade behavior), and source reference (model file,
     migration file).
   - Skeptic challenge surface: The Assayer can point at any entity and demand proof that all attributes are listed, or
     challenge any relationship's stated cardinality against the actual schema constraints.

2. **Schema Migration Archaeology** — Reconstruct the evolutionary history of each entity by reading migrations in
   chronological order, documenting every column addition, removal, type change, index addition, and constraint
   modification.
   - Output: **Schema Evolution Ledger** — per entity: a chronological table with columns for migration identifier,
     date/sequence, operation (add column, drop column, alter type, add index, add constraint), affected attribute(s),
     before-state, after-state, and migration file reference.
   - Skeptic challenge surface: The Assayer can challenge any entity's current schema by replaying the ledger — if the
     cumulative result doesn't match the live schema definition, a migration was missed. Can also question whether
     data-only migrations (seeders, backfills) alter effective constraints.

3. **Invariant Extraction** — Identify every validation rule, uniqueness constraint, check constraint, and business
   invariant enforced at the application layer (validators, mutators, form requests) or database layer (constraints,
   triggers) for each entity.
   - Output: **Invariant Registry** — per entity: a table of invariants with columns for invariant description,
     enforcement layer (DB constraint, model validation, controller validation, middleware), enforcement mechanism
     (unique index, check constraint, regex rule, custom validator), and source reference.
   - Skeptic challenge surface: The Assayer can challenge any invariant as incomplete (does the DB constraint also have
     an app-layer equivalent?) or question whether an entity has undocumented invariants hidden in event listeners,
     observers, or middleware.

---

## METHODOLOGY MANIFEST: The Boundary Excavator

**Concern**: Integration extraction — document every API endpoint, external service call, event bus, file I/O, and
system boundary.

### Methodologies

1. **Interface Contract Definition** — Document every exposed API endpoint and every consumed external API with its full
   contract: method, path, request schema, response schema, authentication, rate limits, and error codes.
   - Output: **Interface Contract Registry** — per endpoint/consumer: a table with method, path/URL, request schema
     (parameters, body fields, types), response schema (status codes, body structure), auth requirement, and source
     reference (controller/client file:line).
   - Skeptic challenge surface: The Assayer can challenge any contract as incomplete — demanding proof that all query
     parameters, headers, or error codes are documented — or question whether undocumented endpoints exist in route
     files that weren't captured.

2. **Port and Adapter Identification** (Hexagonal Architecture / Cockburn) — Classify every system boundary as a port
   (interface the system exposes or consumes) and trace it to its adapter (concrete implementation), mapping the
   abstraction layer between internal domain logic and external systems.
   - Output: **Port-Adapter Map** — a table with columns for port name/type (inbound/outbound), adapter implementation,
     external system it connects to, protocol (HTTP, AMQP, SMTP, filesystem, etc.), and whether the port has an explicit
     interface or is implicitly coupled.
   - Skeptic challenge surface: The Assayer can challenge any "explicit interface" classification by demanding the
     interface definition, or question whether implicit couplings (direct HTTP calls without abstraction) are accurately
     flagged.

3. **Event/Message Flow Tracing** — Identify every event dispatch, listener registration, queue job, broadcast channel,
   and webhook to map the asynchronous communication topology of the system.
   - Output: **Async Communication Matrix** — a table with columns for event/message name, producer (file:line),
     consumer(s) (file:line each), transport mechanism (sync event, queued job, broadcast, webhook), payload schema, and
     failure handling (retry, dead-letter, ignore).
   - Skeptic challenge surface: The Assayer can challenge any event as having undocumented consumers (grep for the event
     name beyond listed listeners), or question whether failure handling is accurately described vs. relying on
     framework defaults.

---

## METHODOLOGY MANIFEST: The Chronicler

**Concern**: Synthesis and templating — consolidate raw excavation reports into a unified, cross-referenced,
LLM-readable specification collection.

### Methodologies

1. **Traceability Matrix Construction** (IEEE 830) — Build a cross-reference matrix linking every specification element
   back to its source excavation finding and forward to the modules and concerns it touches, ensuring nothing is lost or
   fabricated during synthesis.
   - Output: **Specification Traceability Matrix** — a table with columns for specification section, source finding(s)
     (excavator + finding ID), module(s) referenced, concern(s) covered (logic/data/boundary), and completeness status
     (traced/orphaned/gap).
   - Skeptic challenge surface: The Assayer can point at any "traced" entry and demand the source finding, or identify
     any "orphaned" excavation finding that didn't make it into the specification.

2. **Cross-Reference Index Construction** — For each entity, business rule, and integration point, identify every other
   specification element that references or depends on it, producing a navigable dependency web across the three concern
   lenses.
   - Output: **Cross-Reference Index** — per specification element: a list of all other elements that reference it,
     grouped by concern (e.g., Entity "User" is referenced by 4 business rules, 2 integration contracts, 3 other
     entities). Each reference includes section link and relationship type (uses, validates, transforms, exposes).
   - Skeptic challenge surface: The Assayer can challenge any element with zero cross-references as potentially
     orphaned, or question whether a listed relationship type is accurate (e.g., "uses" vs. "transforms").

3. **Gap Analysis** — Compare the set of modules × concerns in the Structural Map against the set of specification
   documents produced, identifying any module or concern that lacks documentation and determining whether the gap is a
   true omission or a justified "N/A."
   - Output: **Coverage Gap Report** — a matrix of modules (rows) × concerns (columns: logic, data, boundary) where each
     cell is: documented (section link), N/A (with justification), or GAP (missing, requires follow-up).
   - Skeptic challenge surface: The Assayer can challenge any "N/A" justification as insufficient, or demand that any
     GAP cell be explained — was it an excavation miss or a chronicle miss?

---

## METHODOLOGY MANIFEST: The Assayer

**Concern**: Completeness verification — adversarially validate that every module is covered, every concern is
documented, and no specification gap exists.

### Methodologies

1. **Coverage Delta Tracking** — Maintain a running coverage matrix derived from the Structural Map, checking off each
   module × concern cell as excavation findings and specification documents are delivered, and flagging any cell that
   remains unchecked at each gate.
   - Output: **Coverage Matrix Checkpoint** — at each gate: a matrix of modules (rows) × concerns (columns) with cells
     marked as: covered (finding reference), N/A (accepted justification), or UNCOVERED (gap requiring re-work). Also
     tracks coverage percentage per concern and overall.
   - Skeptic challenge surface: Self-auditing — the Assayer's own matrix is the master record. Other agents can
     challenge a "covered" cell by questioning whether the referenced finding is substantive or superficial.

2. **Boundary Value Analysis** — At each gate, probe the edges of documented behavior: examine the first and last
   entries in tables, the smallest and largest modules, the simplest and most complex functions, and the most- and
   least-connected integration points to find where documentation is thinnest.
   - Output: **Boundary Probe Log** — a table with columns for probe target (e.g., "smallest module by file count"),
     what was expected, what was found in the documentation, verdict (adequate/thin/missing), and required action (none
     / expand / re-excavate).
   - Skeptic challenge surface: This is the Assayer's own adversarial probe — results feed directly into gate verdicts.
     Agents receiving "thin" or "missing" verdicts must respond with additional evidence.

3. **Hypothesis Elimination Matrix** — For each gate, formulate specific "completeness hypotheses" (e.g., "All state
   machines in Module X are documented") and attempt to falsify them by searching the codebase for counter-evidence
   (undocumented transitions, unhandled states, unlisted endpoints).
   - Output: **Falsification Register** — per hypothesis: the hypothesis statement, the search strategy used (grep
     pattern, file scan, call graph trace), evidence found for/against, and verdict (confirmed/falsified/ inconclusive).
     Falsified hypotheses become mandatory re-work items.
   - Skeptic challenge surface: This IS the skeptic's primary weapon. Each falsified hypothesis is a concrete,
     evidence-backed demand for additional work. Agents cannot dismiss a falsified hypothesis without producing
     counter-evidence.

4. **Change Impact Analysis** — When agents re-submit revised findings after a gate rejection, trace the changes against
   adjacent specification elements to verify that additions or corrections don't create inconsistencies with previously
   approved material.
   - Output: **Impact Trace Log** — per revision: the changed element, all specification elements that cross-reference
     it, whether each cross-reference remains consistent after the change, and verdict (consistent/inconsistency
     detected). Inconsistencies require coordinated updates.
   - Skeptic challenge surface: This ensures revisions don't break what was already approved. The Assayer can flag any
     revision that touches a cross-referenced element without updating the dependent documents.
