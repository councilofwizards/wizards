---
title: "Content Deduplication"
status: "approved"
priority: "P2"
category: "core-framework"
approved_by: "product-skeptic"
created: "2026-02-18"
updated: "2026-02-18"
---

# Content Deduplication Specification

## Summary

Add HTML comment markers around the Shared Principles and Communication Protocol
sections in all 3 SKILL.md files, normalize cosmetic inconsistencies, and define
a CI-validation contract (implemented by P2-04) that enforces content
consistency. This is "validated duplication" -- the content remains in each file
for self-containment, but drift is automatically detected. Designate
`plan-product/SKILL.md` as the authoritative source for shared content.

## Problem

Three SKILL.md files contain ~126 duplicated lines across two sections:

1. **Shared Principles** (~27 lines): 12 numbered principles in 4 tiers. Nearly
   identical across all 3 files, with one cosmetic inconsistency (plan-product
   uses single quotes while the others use double quotes).

2. **Communication Protocol** (~34 lines of shared content): Tool mapping note,
   "When to Message" table (11 rows), "Message Format" template. Structurally
   identical but with intentional per-skill variation -- the "Plan ready for
   review" table row references different skeptic names per skill
   (`product-skeptic`, `quality-skeptic`, `ops-skeptic`). Additionally,
   `build-product` has a unique "Contract Negotiation Pattern" subsection (~56
   lines) not present in the other skills.

This duplication creates two problems:

- **Maintenance drift risk**: Any change to shared principles requires editing 3
  files identically. The cosmetic inconsistencies already present (quote style,
  horizontal rules, table formatting) demonstrate that manual synchronization is
  unreliable.
- **Scaling pressure**: As the skill catalog expands beyond 3 skills, the
  duplication compounds. At 8+ skills, validated duplication should be revisited
  in favor of shared-file extraction (see ADR-002 decision trigger).

Token cost impact is modest (~2,520 redundant tokens per invocation with 5
agents) and is NOT the primary motivation. The primary motivation is
maintainability and correctness.

## Solution

### 1. Add Section Markers

Add HTML comment markers around shared sections in each SKILL.md:

```markdown
<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->

## Shared Principles

... (content) ...

<!-- END SHARED: principles -->

<!-- BEGIN SHARED: communication-protocol -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->

## Communication Protocol

... (shared content) ...

<!-- END SHARED: communication-protocol -->

<!-- BEGIN SKILL-SPECIFIC: communication-extras -->

... (per-skill content like Contract Negotiation Pattern) ...

<!-- END SKILL-SPECIFIC: communication-extras -->
```

Markers serve two purposes:

1. **CI validation (P2-04)**: Validation scripts extract content between
   matching markers and compare across files.
2. **Developer guidance**: Markers signal "this content must match in all
   SKILL.md files."

### 2. Normalize Cosmetic Inconsistencies

Before adding markers, normalize existing inconsistencies so shared sections are
byte-identical:

| Inconsistency    | Current State                                                       | Normalized To                               |
| ---------------- | ------------------------------------------------------------------- | ------------------------------------------- |
| Quote style      | plan-product uses `'message'`, others use `"message"`               | Double quotes (`"message"`) everywhere      |
| Horizontal rule  | plan-product lacks `---` between Principles and Protocol            | Add `---` to plan-product (matching others) |
| Table formatting | plan-product uses `\|col1\|col2\|`, others use `\| col1 \| col2 \|` | Padded format everywhere                    |

### 3. Designate Authoritative Source

`plan-product/SKILL.md` is the authoritative source for shared content. When
editing Shared Principles or Communication Protocol:

1. Edit plan-product first
2. Copy the changed content to build-product and review-quality
3. CI (P2-04) catches any drift

This convention is documented in the marker comments.

### 4. Handle Per-Skill Variations

The Communication Protocol has one intentional variation: the skeptic name in
the "Plan ready for review" table row. This is handled by:

- CI validates structural equivalence for the Communication Protocol (same rows,
  same columns), NOT byte-identity
- The skeptic name column is allowed to vary per skill
- Byte-identity is required only for the Shared Principles section

### 5. CI Validation Contract (Implemented by P2-04)

The validation script (specified here, built in P2-04) will:

1. Find all SKILL.md files matching `plugins/*/skills/*/SKILL.md`
2. Extract content between `<!-- BEGIN SHARED: principles -->` and
   `<!-- END SHARED: principles -->` markers
3. Compare extracted Shared Principles content across all files -- must be
   byte-identical
4. Extract content between `<!-- BEGIN SHARED: communication-protocol -->`
   markers
5. Compare structural equivalence for Communication Protocol: same headings,
   same table rows (skeptic name column may vary), same message format template
6. Report drift with a diff showing exactly what diverged

### 6. ADR-002 Decision Trigger

When the skill count exceeds 8, revisit the validated duplication approach. At
that scale:

- Editing 8+ files for a single principle change is burdensome
- Plugin-scoped shared files with degraded portability become justified
- The markers make future extraction straightforward (content between markers
  moves to the shared file)

## Constraints

1. **SKILL.md files remain self-contained.** Each SKILL.md must function in
   isolation without reading external shared files. This is the core
   architectural property that makes skills portable.
2. **No changes to agent behavior.** Agents read the same content they read
   today. Markers are HTML comments -- invisible in the content agents process.
3. **No SKILL.md bloat.** Markers add 4-6 lines per file (comments only). No
   content is added or removed.
4. **Per-skill variations are preserved.** The skeptic name in the Communication
   Protocol table row remains skill-specific.
5. **Validation is defined here, built in P2-04.** This spec defines WHAT is
   validated. The P2-04 spec defines HOW (script language, CI configuration,
   error reporting).

## Out of Scope

- **Extracting shared content to external files** -- deferred until skill count
  exceeds 8 (per ADR-002 decision trigger)
- **CLAUDE.md extraction** -- rejected due to context pollution and ownership
  conflict (see Researcher findings)
- **Checkpoint file normalization** -- historical checkpoint files with `role`
  instead of `agent` are not retroactively fixed
- **Content changes** -- this spec normalizes formatting, not content. Principle
  wording changes are a separate effort
- **P2-04 implementation** -- CI scripts, GitHub Actions workflow, and
  validation tooling are out of scope

## Files to Modify

| File                                              | Change                                                                                                                                                                    |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/plan-product/SKILL.md`   | Add markers around Shared Principles and Communication Protocol. Normalize quote style to double quotes. Add `---` separator. Normalize table formatting to padded style. |
| `plugins/conclave/skills/build-product/SKILL.md`  | Add markers around Shared Principles, Communication Protocol, and Contract Negotiation Pattern (as SKILL-SPECIFIC).                                                       |
| `plugins/conclave/skills/review-quality/SKILL.md` | Add markers around Shared Principles and Communication Protocol.                                                                                                          |

## Files to Create

| File                                                          | Content                                                                                                        |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `docs/architecture/ADR-002-content-deduplication-strategy.md` | ADR documenting the validated duplication decision, alternatives considered, and the 8-skill revision trigger. |

## Success Criteria

1. All 3 SKILL.md files contain `<!-- BEGIN SHARED: principles -->` and
   `<!-- END SHARED: principles -->` markers around their Shared Principles
   section.
2. All 3 SKILL.md files contain `<!-- BEGIN SHARED: communication-protocol -->`
   and `<!-- END SHARED: communication-protocol -->` markers around their
   Communication Protocol section.
3. The content between `principles` markers is byte-identical across all 3 files
   after normalization.
4. The content between `communication-protocol` markers is structurally
   identical across all 3 files (same headings, same table rows; skeptic name
   column may vary).
5. `plan-product/SKILL.md` is designated as the authoritative source in marker
   comments.
6. Quote style is normalized to double quotes in all 3 files.
7. Table formatting is normalized to padded format in all 3 files.
8. `build-product/SKILL.md` has
   `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` markers around its
   Contract Negotiation Pattern.
9. ADR-002 exists at
   `docs/architecture/ADR-002-content-deduplication-strategy.md` with the
   8-skill revision trigger documented.
10. No agent behavior changes -- skills function identically before and after.
