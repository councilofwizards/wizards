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
