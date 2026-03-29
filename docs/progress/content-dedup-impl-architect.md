---
feature: "content-deduplication"
team: "build-product"
agent: "impl-architect"
phase: "design"
status: "awaiting_review"
last_action:
  "Completed implementation plan with exact edit pairs for all 4 files"
updated: "2026-02-18T00:00:00Z"
---

## Progress Notes

- [00:00] Claimed task #1, read all 3 SKILL.md files, spec, and ADR template
- [00:01] Analyzed differences across files, verified exact line content
- [00:02] Produced implementation plan with exact old_string/new_string edit
  pairs

---

# P2-05 Content Deduplication — Implementation Plan

## Overview

This plan implements the P2-05 Content Deduplication spec by making targeted
edits to 3 SKILL.md files and creating ADR-002. The changes fall into three
categories:

1. **Normalization** (plan-product only): Fix quote style, table formatting, and
   add missing `---` separator
2. **Markers** (all 3 files): Add HTML comment markers around shared sections
3. **ADR creation**: Document the validated duplication decision

After all edits, Shared Principles content between markers will be
byte-identical across all 3 files. Communication Protocol content will be
structurally equivalent (skeptic name column varies by design).

---

## File 1: plugins/conclave/skills/plan-product/SKILL.md

### Edit 1.1 — Normalize quote style in Principle #2 (line 148)

**Rationale**: plan-product uses single quotes `'message'` and `'broadcast'`
while build-product and review-quality use double quotes. Normalize to double
quotes for byte-identity.

**old_string**:

```
2. **Communicate constantly via the `SendMessage` tool** (`type: 'message'` for direct messages, `type: 'broadcast'` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
```

**new_string**:

```
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
```

### Edit 1.2 — Normalize quote style in tool mapping note (line 173)

**Rationale**: Same single-to-double quote normalization for the Communication
Protocol tool mapping note.

**old_string**:

```
> **Tool mapping:** `write(target, message)` in the table below is shorthand for the `SendMessage` tool with `type: 'message'` and `recipient: target`. `broadcast(message)` maps to `SendMessage` with `type: 'broadcast'`.
```

**new_string**:

```
> **Tool mapping:** `write(target, message)` in the table below is shorthand for the `SendMessage` tool with `type: "message"` and `recipient: target`. `broadcast(message)` maps to `SendMessage` with `type: "broadcast"`.
```

### Edit 1.3 — Normalize table formatting (lines 177-189)

**Rationale**: plan-product uses unpadded `|col|col|col|` format while
build-product and review-quality use padded `| col | col | col |` format.
Normalize to padded.

**old_string**:

```
|Event|Action|Target|
|---|---|---|
|Task started|`write(lead, "Starting task #N: [brief]")`|Team lead|
|Task completed|`write(lead, "Completed task #N. Summary: [brief]")`|Team lead|
|Blocker encountered|`write(lead, "BLOCKED on #N: [reason]. Need: [what]")`|Team lead|
|API contract proposed|`write(counterpart, "CONTRACT PROPOSAL: [details]")`|Counterpart agent|
|API contract accepted|`write(proposer, "CONTRACT ACCEPTED: [ref]")`|Proposing agent|
|API contract changed|`write(all affected, "CONTRACT CHANGE: [before] → [after]. Reason: [why]")`|All affected agents|
|Plan ready for review|`write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")`|Product Skeptic|
|Plan approved|`write(requester, "PLAN APPROVED: [ref]")`|Requesting agent|
|Plan rejected|`write(requester, "PLAN REJECTED: [reasons]. Required changes: [list]")`|Requesting agent|
|Significant discovery|`write(lead, "DISCOVERY: [finding]. Impact: [assessment]")`|Team lead|
|Need input from peer|`write(peer, "QUESTION for [name]: [question]")`|Specific peer|
```

**new_string**:

```
| Event | Action | Target |
|---|---|---|
| Task started | `write(lead, "Starting task #N: [brief]")` | Team lead |
| Task completed | `write(lead, "Completed task #N. Summary: [brief]")` | Team lead |
| Blocker encountered | `write(lead, "BLOCKED on #N: [reason]. Need: [what]")` | Team lead |
| API contract proposed | `write(counterpart, "CONTRACT PROPOSAL: [details]")` | Counterpart agent |
| API contract accepted | `write(proposer, "CONTRACT ACCEPTED: [ref]")` | Proposing agent |
| API contract changed | `write(all affected, "CONTRACT CHANGE: [before] → [after]. Reason: [why]")` | All affected agents |
| Plan ready for review | `write(product-skeptic, "PLAN REVIEW REQUEST: [details or file path]")` | Product Skeptic |
| Plan approved | `write(requester, "PLAN APPROVED: [ref]")` | Requesting agent |
| Plan rejected | `write(requester, "PLAN REJECTED: [reasons]. Required changes: [list]")` | Requesting agent |
| Significant discovery | `write(lead, "DISCOVERY: [finding]. Impact: [assessment]")` | Team lead |
| Need input from peer | `write(peer, "QUESTION for [name]: [question]")` | Specific peer |
```

### Edit 1.4 — Add `---` separator and markers around Shared Principles (lines 141+)

**Rationale**: build-product and review-quality both have a `---` separator
before `## Shared Principles`. plan-product lacks it. Add the separator and wrap
with markers.

**old_string**:

```
## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable
```

**new_string**:

```
---

<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable
```

Note: This edit is applied AFTER Edit 1.1 has already been applied (the quote
normalization). The Shared Principles closing marker is added in the next edit.

### Edit 1.5 — Add closing principles marker and opening communication-protocol marker

**Rationale**: Close the principles section and open the communication-protocol
section. In plan-product, there is NO `---` between Shared Principles and
Communication Protocol (unlike build-product and review-quality which have one).
We need to add the closing marker, then a `---`, then the opening marker.

**old_string**:

```
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.

## Communication Protocol
```

**new_string**:

```
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.
<!-- END SHARED: principles -->

---

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Communication Protocol
```

### Edit 1.6 — Add closing communication-protocol marker

**Rationale**: Close the communication-protocol section after the Message Format
code block, before the Contract Negotiation Pattern comment.

**old_string**:

```
<!-- Contract Negotiation Pattern omitted — only relevant to build-product. See build-product/SKILL.md. -->

## Teammate Spawn Prompts
```

**new_string**:

```
<!-- END SHARED: communication-protocol -->

<!-- Contract Negotiation Pattern omitted — only relevant to build-product. See build-product/SKILL.md. -->

## Teammate Spawn Prompts
```

---

## File 2: plugins/conclave/skills/build-product/SKILL.md

### Edit 2.1 — Add markers around Shared Principles (lines 159-186)

**Rationale**: build-product already has normalized content (double quotes,
padded tables, `---` separator). Only needs markers.

**old_string**:

```
---

## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked.
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
3. **No assumptions.** If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules.

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
5. **TDD by default.** Write the test first. Write the minimum code to pass it. Refactor. This is not optional for implementation agents.
6. **SOLID and DRY.** Single responsibility. Open for extension, closed for modification. Depend on abstractions. Don't repeat yourself. These aren't aspirational — they're required.
7. **Unit tests with mocks preferred.** Design backend code to be testable with mocks and avoid database overhead. Use feature/integration tests only where database interaction is the thing being tested or where they prevent regressions that unit tests cannot catch.

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** When a backend engineer and frontend engineer agree on an API contract (request shape, response shape, status codes, error format), that contract is documented and neither side deviates without explicit renegotiation and Skeptic approval.
9. **Document decisions, not just code.** When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations.
10. **Delegate mode for leads.** Team leads coordinate, review, and synthesize. They do not implement. If you are a team lead, use delegate mode — your job is orchestration, not execution.

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** Start with a one-paragraph summary, then expand into details. Readers should be able to stop reading at any depth and still have a useful understanding.
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.

---

## Communication Protocol
```

**new_string**:

```
---

<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked.
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
3. **No assumptions.** If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules.

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
5. **TDD by default.** Write the test first. Write the minimum code to pass it. Refactor. This is not optional for implementation agents.
6. **SOLID and DRY.** Single responsibility. Open for extension, closed for modification. Depend on abstractions. Don't repeat yourself. These aren't aspirational — they're required.
7. **Unit tests with mocks preferred.** Design backend code to be testable with mocks and avoid database overhead. Use feature/integration tests only where database interaction is the thing being tested or where they prevent regressions that unit tests cannot catch.

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** When a backend engineer and frontend engineer agree on an API contract (request shape, response shape, status codes, error format), that contract is documented and neither side deviates without explicit renegotiation and Skeptic approval.
9. **Document decisions, not just code.** When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations.
10. **Delegate mode for leads.** Team leads coordinate, review, and synthesize. They do not implement. If you are a team lead, use delegate mode — your job is orchestration, not execution.

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** Start with a one-paragraph summary, then expand into details. Readers should be able to stop reading at any depth and still have a useful understanding.
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.
<!-- END SHARED: principles -->

---

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Communication Protocol
```

### Edit 2.2 — Add closing communication-protocol marker and skill-specific markers

**Rationale**: Close the shared communication-protocol section after the Message
Format code block, then wrap the Contract Negotiation Pattern in skill-specific
markers.

**old_string**:

```
Blocking: [task number if applicable]
```

### Contract Negotiation Pattern (Backend ↔ Frontend)

```

**new_string**:
```

Blocking: [task number if applicable]

```
<!-- END SHARED: communication-protocol -->

<!-- BEGIN SKILL-SPECIFIC: communication-extras -->
### Contract Negotiation Pattern (Backend ↔ Frontend)
```

### Edit 2.3 — Add closing skill-specific marker after Contract Negotiation Pattern

**Rationale**: Close the skill-specific section after the ASCII diagram code
block.

**old_string**:

```

---

## Teammates to Spawn
```

Note: This matches the `---` followed by `## Teammates to Spawn` that comes
after the Contract Negotiation Pattern ASCII art block (line 279 area).

**new_string**:

```
<!-- END SKILL-SPECIFIC: communication-extras -->

---

## Teammates to Spawn
```

IMPORTANT: There are two `---` followed by section headings in the area after
the Communication Protocol. The one we target is specifically
`## Teammates to Spawn` (NOT `## Backend ↔ Frontend Contract Negotiation`). The
old_string must be specific enough to avoid ambiguity — the blank line before
`---` before `## Teammates to Spawn` is the unique target.

---

## File 3: plugins/conclave/skills/review-quality/SKILL.md

### Edit 3.1 — Add markers around Shared Principles (lines 149-177)

**Rationale**: review-quality already has normalized content. Only needs
markers.

**old_string**:

```
---

## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked.
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
3. **No assumptions.** If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules.

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
5. **TDD by default.** Write the test first. Write the minimum code to pass it. Refactor. This is not optional for implementation agents.
6. **SOLID and DRY.** Single responsibility. Open for extension, closed for modification. Depend on abstractions. Don't repeat yourself. These aren't aspirational — they're required.
7. **Unit tests with mocks preferred.** Design backend code to be testable with mocks and avoid database overhead. Use feature/integration tests only where database interaction is the thing being tested or where they prevent regressions that unit tests cannot catch.

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** When a backend engineer and frontend engineer agree on an API contract (request shape, response shape, status codes, error format), that contract is documented and neither side deviates without explicit renegotiation and Skeptic approval.
9. **Document decisions, not just code.** When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations.
10. **Delegate mode for leads.** Team leads coordinate, review, and synthesize. They do not implement. If you are a team lead, use delegate mode — your job is orchestration, not execution.

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** Start with a one-paragraph summary, then expand into details. Readers should be able to stop reading at any depth and still have a useful understanding.
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.

---

## Communication Protocol
```

**new_string**:

```
---

<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked.
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
3. **No assumptions.** If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules.

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
5. **TDD by default.** Write the test first. Write the minimum code to pass it. Refactor. This is not optional for implementation agents.
6. **SOLID and DRY.** Single responsibility. Open for extension, closed for modification. Depend on abstractions. Don't repeat yourself. These aren't aspirational — they're required.
7. **Unit tests with mocks preferred.** Design backend code to be testable with mocks and avoid database overhead. Use feature/integration tests only where database interaction is the thing being tested or where they prevent regressions that unit tests cannot catch.

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** When a backend engineer and frontend engineer agree on an API contract (request shape, response shape, status codes, error format), that contract is documented and neither side deviates without explicit renegotiation and Skeptic approval.
9. **Document decisions, not just code.** When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations.
10. **Delegate mode for leads.** Team leads coordinate, review, and synthesize. They do not implement. If you are a team lead, use delegate mode — your job is orchestration, not execution.

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** Start with a one-paragraph summary, then expand into details. Readers should be able to stop reading at any depth and still have a useful understanding.
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.
<!-- END SHARED: principles -->

---

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Communication Protocol
```

### Edit 3.2 — Add closing communication-protocol marker

**Rationale**: Close the communication-protocol section after the Message Format
code block.

**old_string**:

```
<!-- Contract Negotiation Pattern omitted — only relevant to build-product. See build-product/SKILL.md. -->

---

## Teammates to Spawn
```

**new_string**:

```
<!-- END SHARED: communication-protocol -->

<!-- Contract Negotiation Pattern omitted — only relevant to build-product. See build-product/SKILL.md. -->

---

## Teammates to Spawn
```

---

## File 4: docs/architecture/ADR-002-content-deduplication-strategy.md (NEW)

Create this file with the following content:

```markdown
---
title: "Content Deduplication Strategy"
status: "accepted"
created: "2026-02-18"
updated: "2026-02-18"
superseded_by: ""
---

# ADR-002: Content Deduplication Strategy

## Status

Accepted

## Context

Three SKILL.md files (`plan-product`, `build-product`, `review-quality`) contain
approximately 126 duplicated lines across two shared sections: Shared Principles
(12 numbered principles in 4 tiers) and Communication Protocol (tool mapping,
"When to Message" table, "Message Format" template).

This duplication creates a maintenance drift risk: any change to shared
principles requires editing 3 files identically. Cosmetic inconsistencies
already present (quote style, table formatting, horizontal rules) demonstrate
that manual synchronization is unreliable.

Key constraints:

1. SKILL.md files must remain self-contained. Each skill must function in
   isolation without reading external shared files. This is the core
   architectural property that makes skills portable.
2. No agent behavior changes. Agents read the same content they read today.
3. The Communication Protocol has one intentional per-skill variation: the
   skeptic name in the "Plan ready for review" table row (`product-skeptic`,
   `quality-skeptic`, `ops-skeptic`).
4. `build-product` has a unique Contract Negotiation Pattern subsection not
   present in the other skills.

## Decision

### Validated duplication with HTML comment markers

Keep shared content duplicated in each SKILL.md file (preserving
self-containment), but wrap shared sections with HTML comment markers that
enable CI-based drift detection (P2-04).

Marker format:

- `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->` around
  Shared Principles
- `<!-- BEGIN SHARED: communication-protocol -->` /
  `<!-- END SHARED: communication-protocol -->` around Communication Protocol
- `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` /
  `<!-- END SKILL-SPECIFIC: communication-extras -->` around per-skill extras
  (e.g., Contract Negotiation Pattern)
- `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->`
  after each BEGIN SHARED marker

### Authoritative source designation

`plan-product/SKILL.md` is the authoritative source for all shared content. When
editing Shared Principles or Communication Protocol, edit plan-product first,
then propagate to the other skill files.

### Normalization before marking

Before adding markers, normalize cosmetic inconsistencies so that the Shared
Principles section is byte-identical across all 3 files:

- Quote style: single quotes in plan-product normalized to double quotes
- Table formatting: unpadded format in plan-product normalized to padded format
- Horizontal rule: missing `---` separator in plan-product added to match others

### Validation contract

- Shared Principles: byte-identical across all files (after normalization)
- Communication Protocol: structurally equivalent (same headings, same table
  rows; skeptic name column may vary per skill)

### 8-skill revision trigger

When the skill count exceeds 8, revisit this approach. At that scale, editing 8+
files for a single principle change is burdensome, and extraction to a
plugin-scoped shared file becomes justified. The markers make future extraction
straightforward: content between markers moves to the shared file and is
replaced by an include directive or equivalent.

## Alternatives Considered

### Extract shared content to CLAUDE.md

Rejected. CLAUDE.md is owned by the project, not the plugin, creating an
ownership conflict. It also pollutes the context of every agent invocation (not
just skill invocations) with content only relevant to skill-spawned agents.

### Extract to a shared file within the plugin

Rejected at current scale (3 skills). Breaks the self-containment property of
SKILL.md files. Each skill would need to read an external file, adding a
dependency and reducing portability. Justified only when skill count exceeds 8
(see decision trigger above).

### Do nothing

Rejected. The existing cosmetic drift (quote styles, table formatting)
demonstrates that untracked duplication leads to inconsistency. Even at 3
skills, the maintenance burden is real.

## Consequences

- **Positive**: Shared content remains in each SKILL.md, preserving
  self-containment and portability.
- **Positive**: HTML comment markers are invisible to agents processing the
  markdown, so no behavioral changes.
- **Positive**: CI validation (P2-04) will automatically detect drift,
  eliminating manual synchronization errors.
- **Positive**: Markers make future extraction straightforward when scale
  justifies it.
- **Negative**: Any shared content change still requires editing 3 files.
  Mitigated by CI catching drift.
- **Negative**: Markers add 4-6 comment lines per file. Minimal impact.
```

---

## Byte-Identity Verification

After all edits are applied, the content between
`<!-- BEGIN SHARED: principles -->` and `<!-- END SHARED: principles -->` in all
3 files will be:

```
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->
## Shared Principles

These principles apply to **every agent on every team**. They are included in every spawn prompt.

### CRITICAL — Non-Negotiable

1. **No agent proceeds past planning without Skeptic sign-off.** The Skeptic must explicitly approve plans before implementation begins. If the Skeptic has not approved, the work is blocked.
2. **Communicate constantly via the `SendMessage` tool** (`type: "message"` for direct messages, `type: "broadcast"` for team-wide). Never assume another agent knows your status. When you complete a task, discover a blocker, change an approach, or need input — message immediately.
3. **No assumptions.** If you don't know something, ask. Message a teammate, message the lead, or research it. Never guess at requirements, API contracts, data shapes, or business rules.

### IMPORTANT — High-Value Practices

4. **Minimal, clean solutions.** Write the least code that correctly solves the problem. Prefer framework-provided tools over custom implementations — follow the conventions of the project's framework and language. Every line of code is a liability.
5. **TDD by default.** Write the test first. Write the minimum code to pass it. Refactor. This is not optional for implementation agents.
6. **SOLID and DRY.** Single responsibility. Open for extension, closed for modification. Depend on abstractions. Don't repeat yourself. These aren't aspirational — they're required.
7. **Unit tests with mocks preferred.** Design backend code to be testable with mocks and avoid database overhead. Use feature/integration tests only where database interaction is the thing being tested or where they prevent regressions that unit tests cannot catch.

### ESSENTIAL — Quality Standards

8. **Contracts are sacred.** When a backend engineer and frontend engineer agree on an API contract (request shape, response shape, status codes, error format), that contract is documented and neither side deviates without explicit renegotiation and Skeptic approval.
9. **Document decisions, not just code.** When you make a non-obvious choice, write a brief note explaining why. ADRs for architecture. Inline comments for tricky logic. Spec annotations for requirement interpretations.
10. **Delegate mode for leads.** Team leads coordinate, review, and synthesize. They do not implement. If you are a team lead, use delegate mode — your job is orchestration, not execution.

### NICE-TO-HAVE — When Feasible

11. **Progressive disclosure in specs.** Start with a one-paragraph summary, then expand into details. Readers should be able to stop reading at any depth and still have a useful understanding.
12. **Use Sonnet for execution agents, Opus for reasoning agents.** Researchers, architects, and skeptics benefit from deeper reasoning (Opus). Engineers executing well-defined specs can use Sonnet for cost efficiency.
```

This content is already byte-identical in build-product and review-quality.
After Edits 1.1 normalizes plan-product's quotes, all 3 will match.

## Communication Protocol Structural Equivalence

The only variation between files in the communication-protocol section is the
"Plan ready for review" table row:

- plan-product: `write(product-skeptic, ...)` / `Product Skeptic`
- build-product: `write(quality-skeptic, ...)` / `Quality Skeptic`
- review-quality: `write(ops-skeptic, ...)` / `Ops Skeptic`

All other rows, headings, and the message format template are identical.

## Edit Execution Order

Edits MUST be applied in this order to avoid old_string conflicts:

**plan-product/SKILL.md** (6 edits — apply sequentially):

1. Edit 1.1 (quote normalization, principle #2)
2. Edit 1.2 (quote normalization, tool mapping)
3. Edit 1.3 (table formatting)
4. Edit 1.4 (add `---` separator + BEGIN SHARED: principles marker)
5. Edit 1.5 (END SHARED: principles + BEGIN SHARED: communication-protocol)
6. Edit 1.6 (END SHARED: communication-protocol)

**build-product/SKILL.md** (3 edits — apply sequentially):

1. Edit 2.1 (principles markers)
2. Edit 2.2 (END communication-protocol + BEGIN SKILL-SPECIFIC)
3. Edit 2.3 (END SKILL-SPECIFIC)

**review-quality/SKILL.md** (2 edits — apply sequentially):

1. Edit 3.1 (principles markers + BEGIN communication-protocol)
2. Edit 3.2 (END communication-protocol)

**ADR-002** (1 file creation):

1. Create docs/architecture/ADR-002-content-deduplication-strategy.md

Total: 11 edits + 1 file creation across 4 files.
