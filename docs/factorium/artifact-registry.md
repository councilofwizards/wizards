# Artifact Schema Registry

Canonical schemas for every artifact in the Factorium pipeline. Producing stages validate outgoing artifacts against
these schemas. Consuming stages validate incoming artifacts before starting work. Gremlin uses this as the completeness
checklist during audit.

---

## Artifact Index

| ID     | Name                    | Producer  | Consumers                    | Path Pattern                                             |
| ------ | ----------------------- | --------- | ---------------------------- | -------------------------------------------------------- |
| ART-01 | Idea                    | Dreamer   | Assayer                      | GitHub Issue body                                        |
| ART-02 | Research Summary        | Assayer   | Planner, Gremlin             | GitHub Issue comment                                     |
| ART-03 | Product Requirements    | Planner   | Architect, Engineer, Gremlin | `docs/factorium/ideas/{slug}/product-requirements.md`    |
| ART-04 | Product Stories         | Planner   | Architect, Engineer, Gremlin | `docs/factorium/ideas/{slug}/product-stories.md`         |
| ART-05 | Product Metrics         | Planner   | Architect, Engineer, Gremlin | `docs/factorium/ideas/{slug}/product-metrics.md`         |
| ART-06 | Product Edge Cases      | Planner   | Architect, Engineer, Gremlin | `docs/factorium/ideas/{slug}/product-edge-cases.md`      |
| ART-07 | Architecture Design     | Architect | Engineer, Gremlin            | `docs/factorium/ideas/{slug}/architecture-design.md`     |
| ART-08 | Architecture Schema     | Architect | Engineer, Gremlin            | `docs/factorium/ideas/{slug}/architecture-schema.md`     |
| ART-09 | Architecture Contracts  | Architect | Engineer, Gremlin            | `docs/factorium/ideas/{slug}/architecture-contracts.md`  |
| ART-10 | Architecture Security   | Architect | Engineer, Gremlin            | `docs/factorium/ideas/{slug}/architecture-security.md`   |
| ART-11 | Architecture Work Plan  | Architect | Engineer, Gremlin            | `docs/factorium/ideas/{slug}/architecture-workplan.md`   |
| ART-12 | Engineering Notes       | Engineer  | Gremlin                      | `docs/factorium/ideas/{slug}/engineering-notes.md`       |
| ART-13 | Engineering Test Report | Engineer  | Gremlin                      | `docs/factorium/ideas/{slug}/engineering-test-report.md` |
| ART-14 | Pull Request            | Engineer  | Gremlin                      | GitHub PR                                                |
| ART-15 | Review Verdict          | Gremlin   | Necromancer (if rejected)    | GitHub Issue comment                                     |

---

## Artifact Definitions

### ART-01: Idea

**Producer:** Dreamer | **Format:** GitHub Issue body

**Required content:**

- Single paragraph, 2-5 sentences
- User-focused problem statement
- Expected outcome for the user

**Completeness criteria:**

- Describes a user problem, not an implementation
- No technical details, architecture decisions, or stack references
- Actionable — an Assayer can research feasibility from this alone

**Validation rules:**

- Reject if contains code, schema, or file path references
- Reject if exceeds one paragraph

---

### ART-02: Research Summary

**Producer:** Assayer | **Format:** GitHub Issue comment

**Required content:**

- 6-dimension score table (1-5 each): Feasibility, Market Fit, Strategic Alignment, Revenue Potential, Technical Risk,
  Effort
- Evidence section per dimension (citations, data, analysis)
- Adversary verdict: APPROVE / REJECT / CONDITIONAL with justification

**Completeness criteria:**

- All 6 dimensions scored with supporting evidence
- Adversary reviewed without access to assessor rationales (Iron Law 01)
- Final verdict rendered

**Validation rules:**

- Reject if any dimension lacks evidence
- Reject if adversary verdict missing
- Reject if scores present without per-dimension justification

---

### ART-03: Product Requirements (`product-requirements.md`)

**Producer:** Planner | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Business Goals` — measurable objectives tied to the idea
- `## Functional Requirements` — FR-NNN numbered list
- `## Non-Functional Requirements` — NFR-NNN numbered list
- `## Out of Scope` — explicit exclusions
- `## Open Questions` — unresolved items (each tagged `[BLOCKING]` or `[ADVISORY]`)

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every FR has acceptance criteria
- Every NFR has measurable threshold
- No `[BLOCKING]` open questions remain

**Validation rules:**

- Reject if FR-NNN or NFR-NNN numbering has gaps or duplicates
- Reject if any FR lacks acceptance criteria
- Reject if `[BLOCKING]` items present

---

### ART-04: Product Stories (`product-stories.md`)

**Producer:** Planner | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Personas` — named user archetypes with goals
- `## User Stories` — US-NNN with GIVEN/WHEN/THEN acceptance criteria
- `## Story Map` — activity > task > story hierarchy
- `## Coverage Matrix` — FR-NNN to US-NNN mapping

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every FR-NNN from ART-03 mapped to at least one US-NNN
- Every US-NNN has GIVEN/WHEN/THEN
- Every story references a persona

**Validation rules:**

- Reject if coverage matrix has unmapped FR-NNN entries
- Reject if any US-NNN lacks GIVEN/WHEN/THEN
- Reject if US-NNN numbering has gaps or duplicates

---

### ART-05: Product Metrics (`product-metrics.md`)

**Producer:** Planner | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## KPIs` — primary success metrics with targets and measurement method
- `## Secondary Metrics` — supporting indicators
- `## Guardrails` — metrics that must not degrade (with thresholds)
- `## Anti-Metrics` — metrics explicitly not optimized for, with rationale
- `## Measurement Plan` — collection method, frequency, tooling per metric

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- At least one KPI with numeric target
- Every guardrail has a threshold
- Measurement plan covers all KPIs and guardrails

**Validation rules:**

- Reject if KPIs lack measurable targets
- Reject if guardrails lack thresholds
- Reject if measurement plan omits any KPI

---

### ART-06: Product Edge Cases (`product-edge-cases.md`)

**Producer:** Planner | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Boundary Conditions` — input limits, extremes, empty states
- `## Failure Modes` — network, storage, dependency failures
- `## Concurrency` — race conditions, duplicate submissions, stale reads
- `## Accessibility` — WCAG compliance, screen reader, keyboard nav
- `## Internationalization` — encoding, locale, RTL, date/number formats
- `## Security` — injection, privilege escalation, data leakage scenarios
- `## Missing Requirements` — gaps discovered during edge case analysis

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every section has at least one entry
- Security section references OWASP Top 10 categories where applicable
- Missing requirements fed back to ART-03 as open questions

**Validation rules:**

- Reject if any section empty
- Reject if missing requirements not cross-referenced to ART-03

---

### ART-07: Architecture Design (`architecture-design.md`)

**Producer:** Architect | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Component Inventory` — named components with responsibility, technology, boundaries
- `## Data Flows` — request/response paths through components
- `## Integration Points` — external systems, APIs, services
- `## Decisions` — ADR-style records (context, decision, consequences)
- `## Constraints` — technical, regulatory, infrastructure limits

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every FR-NNN from ART-03 traceable to at least one component
- Every integration point has failure handling defined
- Every decision has consequences documented

**Validation rules:**

- Reject if components reference undefined integration points
- Reject if any decision lacks consequences section

---

### ART-08: Architecture Schema (`architecture-schema.md`)

**Producer:** Architect | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Models` — entities, attributes, types, relationships
- `## Migrations` — ordered list with up and rollback SQL/logic
- `## Indexes` — per-table index definitions with justification
- `## Backward Compatibility` — impact on existing data, migration strategy
- `## Data Contracts` — shared data structures between components

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every model has primary key and timestamps
- Every migration has rollback
- Indexes justified by query patterns from ART-09

**Validation rules:**

- Reject if any migration lacks rollback
- Reject if models reference undefined relationships

---

### ART-09: Architecture Contracts (`architecture-contracts.md`)

**Producer:** Architect | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Endpoints` — method, path, request/response schema, status codes, auth
- `## Interfaces` — internal service contracts (method signatures, types)
- `## Versioning` — API versioning strategy
- `## Integration Contracts` — external API schemas, webhook payloads
- `## Testability` — contract testing strategy, mock definitions

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every endpoint has request schema, response schema, and error codes
- Every interface method has input/output types
- Versioning strategy defined before any endpoint

**Validation rules:**

- Reject if any endpoint lacks error response schema
- Reject if interfaces use untyped parameters

---

### ART-10: Architecture Security (`architecture-security.md`)

**Producer:** Architect | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Threat Model` — STRIDE analysis per component
- `## Authentication` — auth flow, token management, session handling
- `## Authorization` — permission model, role hierarchy, resource-level checks
- `## Data Protection` — encryption at rest/transit, PII handling, retention
- `## Input Validation` — validation rules per endpoint/input surface
- `## Security Acceptance Criteria` — testable security requirements per FR

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- STRIDE applied to every component in ART-07
- Every endpoint from ART-09 has auth and validation defined
- Security ACs map to FR-NNN from ART-03

**Validation rules:**

- Reject if any component lacks STRIDE analysis
- Reject if endpoints missing auth specification
- Reject if security ACs not traceable to FRs

---

### ART-11: Architecture Work Plan (`architecture-workplan.md`)

**Producer:** Architect | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Work Units` — WU-NNN inventory with scope, inputs, outputs, estimated effort
- `## Dependency Graph` — WU-NNN dependencies (blocks/blocked-by)
- `## Parallelization Map` — which WUs can execute concurrently
- `## Completion Criteria` — per-WU definition of done

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every FR-NNN traceable to at least one WU-NNN
- No circular dependencies in the graph
- Parallelization map consistent with dependency graph

**Validation rules:**

- Reject if WU-NNN numbering has gaps or duplicates
- Reject if dependency graph contains cycles
- Reject if parallelized WUs have unresolved dependencies between them

---

### ART-12: Engineering Notes (`engineering-notes.md`)

**Producer:** Engineer | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Decisions` — implementation decisions with rationale (deviations from architecture noted)
- `## Tech Debt` — known shortcuts, tagged with severity and remediation plan
- `## Work Unit Summary` — per-WU status, notes, blockers

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- Every WU-NNN from ART-11 has a summary entry
- Every architecture deviation justified
- Tech debt items have severity (low/medium/high)

**Validation rules:**

- Reject if WU-NNN coverage incomplete
- Reject if deviations lack justification

---

### ART-13: Engineering Test Report (`engineering-test-report.md`)

**Producer:** Engineer | **Format:** Markdown with YAML frontmatter

**Required sections:**

- `## Unit Test Results` — pass/fail counts, failure details
- `## Feature Test Results` — pass/fail counts, failure details
- `## Coverage` — line/branch coverage percentages
- `## Security Findings` — static analysis and CVE scan results
- `## Gate Results` — per-gate pass/fail with evidence

**Required frontmatter:** `title`, `idea`, `status`, `version`

**Completeness criteria:**

- All tests passing
- Coverage meets project threshold
- No critical/high CVEs unresolved
- All gates passed

**Validation rules:**

- Reject if any test failing
- Reject if critical/high security findings unresolved
- Reject if any gate failed

---

### ART-14: Pull Request

**Producer:** Engineer | **Format:** GitHub PR

**Required content:**

- Summary — what changed and why
- Implementation notes — key decisions, deviations from architecture
- Test coverage — what is tested, what is not and why
- Supporting docs — links to ART-12, ART-13
- Gate results table — gate name, status, evidence link

**Completeness criteria:**

- All CI checks passing
- ART-13 linked and current
- Gate results table complete

**Validation rules:**

- Reject if CI failing
- Reject if test report not linked
- Reject if gate results table missing or incomplete

---

### ART-15: Review Verdict

**Producer:** Gremlin | **Format:** GitHub Issue comment

**Required content:**

- Per-requirement verdict table — FR-NNN / NFR-NNN with MET / PARTIAL / UNMET and evidence
- Attack surface findings — vulnerabilities discovered during adversarial testing
- Standards findings — Definition of Done violations with section references
- Final verdict — PASS / FAIL / CONDITIONAL with required remediations

**Completeness criteria:**

- Every FR-NNN and NFR-NNN from ART-03 has a verdict
- Attack surface section present even if no findings
- Standards audit references Definition of Done section IDs

**Validation rules:**

- Reject if any requirement lacks verdict
- Reject if FAIL/CONDITIONAL verdict lacks remediation list
- Reject if standards findings reference nonexistent DoD sections

---

## Numbering Schemes

| Prefix  | Meaning                | Assigned by | Uniqueness scope |
| ------- | ---------------------- | ----------- | ---------------- |
| FR-NNN  | Functional Requirement | Planner     | Per idea         |
| NFR-NNN | Non-Functional Req.    | Planner     | Per idea         |
| US-NNN  | User Story             | Planner     | Per idea         |
| WU-NNN  | Work Unit              | Architect   | Per idea         |

Rules:

- Sequential, starting at 001. No gaps. No reuse of retired numbers.
- Cross-references use exact prefix (e.g., "Implements FR-003"). No abbreviation.
- Each scheme scopes to a single idea. Different ideas have independent numbering.

---

## Handoff Protocol

1. **Validate before consuming.** Receiving stage checks incoming artifact against this registry's schema. Missing
   required sections = requeue to producing stage. No exceptions.
2. **Validate before advancing.** Producing stage checks outgoing artifact before marking stage complete. Incomplete
   artifacts do not leave the stage.
3. **Blocking vs. advisory.** Issues in artifacts use inline prefixes:
   - `[BLOCKING]` — halts pipeline progression. Must resolve before handoff.
   - `[ADVISORY]` — noted for downstream awareness. Does not block.
4. **Requeue format.** Requeue comment on GitHub Issue: stage name, missing sections, specific deficiencies. Producing
   stage re-enters with requeue context.
5. **No partial handoffs.** An artifact is complete or it is not handed off. No "draft" artifacts cross stage
   boundaries.

---

## Agent Reference

| Stage       | Inbound validation                         | Outbound validation                   |
| ----------- | ------------------------------------------ | ------------------------------------- |
| Dreamer     | None (pipeline entry)                      | ART-01 schema                         |
| Assayer     | ART-01                                     | ART-02 schema                         |
| Planner     | ART-02                                     | ART-03 through ART-06 schemas         |
| Architect   | ART-03 through ART-06                      | ART-07 through ART-11 schemas         |
| Engineer    | ART-07 through ART-11                      | ART-12 through ART-14 schemas         |
| Gremlin     | ART-03 through ART-14 (full audit surface) | ART-15 schema                         |
| Necromancer | ART-15 (if FAIL)                           | None (terminal — revives or archives) |

All stages: reference artifact IDs (ART-xx) when citing requirements in comments, verdicts, and handoff notes.
