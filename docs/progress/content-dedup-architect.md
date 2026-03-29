---
feature: "content-deduplication"
team: "plan-product"
agent: "architect"
phase: "complete"
status: "complete"
last_action:
  "Architecture design approved by Skeptic. Quote-style grep verified: only lines 148 and 173 in plan-product deviate."
updated: "2026-02-18T17:30:00Z"
---

# P2-05 Content Deduplication: Architecture Design

## 1. Problem Analysis

### Duplication Inventory

Three SKILL.md files contain duplicated content in two sections:

**Shared Principles** (~27 lines of content, identical across all 3 files):

- Lines 141-167 in plan-product/SKILL.md
- Lines 159-185 in build-product/SKILL.md
- Lines 151-177 in review-quality/SKILL.md
- Content: 12 numbered principles in 4 tiers (CRITICAL, IMPORTANT, ESSENTIAL, NICE-TO-HAVE)
- Differences: Trivially different — plan-product uses single quotes (`'message'`) in principle #2 while the other two
  use double quotes (`"message"`). This is a cosmetic inconsistency, not a semantic difference.

**Communication Protocol** (~34 lines of shared content):

- Lines 169-202 in plan-product/SKILL.md
- Lines 189-220 in build-product/SKILL.md
- Lines 181-213 in review-quality/SKILL.md
- Content: Tool mapping note, "When to Message" table (11 rows), "Message Format" template
- **Per-skill differences**: The "Plan ready for review" table row references different skeptic names:
  - plan-product: `product-skeptic`
  - build-product: `quality-skeptic`
  - review-quality: `ops-skeptic`
- **build-product only**: Has an additional "Contract Negotiation Pattern" subsection (lines 222-277, ~56 lines) and a
  comment at the end. plan-product and review-quality have a comment noting this section is omitted.

### Total Duplication

| Section                              | Lines per file | Files | Total duplicated | Truly identical          |
| ------------------------------------ | -------------- | ----- | ---------------- | ------------------------ |
| Shared Principles                    | ~27            | 3     | ~81              | Yes (modulo quote style) |
| Communication Protocol (shared part) | ~34            | 3     | ~102             | No (skeptic name varies) |
| Communication Protocol (build-only)  | ~56            | 1     | 0                | N/A (not duplicated)     |

**~126 lines** are duplicated across the 3 files. Of these, ~81 lines (Shared Principles) are truly identical. ~45 lines
(Communication Protocol) are structurally identical but have per-skill variable substitutions.

### Token Cost Impact

Each SKILL.md is read by the team lead agent, then its content is embedded in spawn prompts for each teammate. With 4-5
agents per skill:

- ~126 duplicated lines x ~5 reads per invocation = ~630 redundant line-reads
- At ~4 tokens/line average, that's ~2,520 redundant tokens per invocation
- This is non-trivial but not catastrophic. The real cost is maintenance burden, not token cost.

## 2. Design Options

### Option A: Extract to CLAUDE.md (Project-Root Context File)

**Mechanism**: Claude Code automatically loads `CLAUDE.md` from the project root into every conversation's system
prompt. This is confirmed behavior — it's the standard mechanism for project-level instructions.

**Design**:

1. Create `CLAUDE.md` in the project root with the Shared Principles content
2. Remove Shared Principles from all 3 SKILL.md files
3. Replace with a brief reference note: `> Shared Principles are loaded from CLAUDE.md at the project root.`

**Pros**:

- Single source of truth for Shared Principles
- Automatically available to all agents without explicit file reading
- Change once, apply everywhere

**Cons**:

- CLAUDE.md is loaded into ALL conversations, not just skill invocations. Non-skill Claude Code usage in this project
  gets the principles injected unnecessarily.
- Cannot extract Communication Protocol to CLAUDE.md because it has per-skill variations (different skeptic names).
- Partial extraction: Principles go to CLAUDE.md, but Communication Protocol stays duplicated. This creates two
  different content management patterns for what is currently one logical block.
- **Portability regression**: A user who copies a single SKILL.md to another project loses the Shared Principles
  entirely. The skill becomes incomplete without the external CLAUDE.md file.
- This project IS the plugin — CLAUDE.md in this repo affects the plugin development workflow, not end-user skill
  invocations. When a user installs the conclave plugin into their own project, they would need their own CLAUDE.md.

**Verdict**: CLAUDE.md extraction has a fundamental scoping problem for a plugin project. The CLAUDE.md belongs to the
consumer project, not the plugin. This option is NOT recommended.

### Option B: Extract to Plugin-Scoped Shared File

**Mechanism**: Create a shared file within the plugin directory (e.g., `plugins/conclave/shared/principles.md`). Each
SKILL.md's Setup section includes an instruction for the team lead to read this file.

**Design**:

1. Create `plugins/conclave/shared/principles.md` containing Shared Principles
2. Create `plugins/conclave/shared/communication-protocol.md` containing the Communication Protocol base template with a
   variable placeholder for the skeptic name
3. Each SKILL.md Setup adds a step: "Read `plugins/conclave/shared/principles.md` and
   `plugins/conclave/shared/communication-protocol.md`"
4. Remove duplicated sections from SKILL.md, replace with a brief inline summary plus reference

**Pros**:

- Single source of truth within the plugin boundary
- Content stays scoped to the plugin (not polluting project-root CLAUDE.md)
- Follows the existing pattern of Setup reading files from known paths

**Cons**:

- Relies on the team lead agent successfully reading the shared files and propagating content to spawn prompts. If the
  read fails silently, agents lose the principles.
- The Communication Protocol has per-skill variations (skeptic names). A shared file needs a substitution mechanism or
  per-skill overrides, adding complexity.
- Adds Setup steps and file reads to every skill invocation — marginal latency cost.
- **Portability regression**: Same as Option A. A copied SKILL.md loses shared content.

**Verdict**: Better scoping than Option A, but introduces fragility (file-read dependency) and doesn't solve the
per-skill variation problem cleanly.

### Option C: Validated Duplication (Recommended)

**Mechanism**: Keep content duplicated in all 3 SKILL.md files. Add a CI validation check (P2-04) that verifies the
duplicated sections are content-equivalent across files.

**Design**:

1. Normalize the existing minor inconsistencies (quote style) so the 3 copies of Shared Principles are byte-identical
2. Formalize the Communication Protocol structure so the shared portion is identical across files, with per-skill
   customizations clearly demarcated
3. Add markers (HTML comments) around shared sections to enable automated comparison
4. P2-04's validation script verifies that marked sections are identical across all 3 files

**Pros**:

- **Preserves self-containment**: Each SKILL.md remains fully functional in isolation. This is the core architectural
  property of the plugin.
- **No runtime fragility**: No file-read dependencies. No risk of agents losing principles due to failed reads.
- **No portability regression**: Copy a SKILL.md, it works.
- **Low implementation risk**: Changes are cosmetic (normalize inconsistencies, add markers). No structural changes to
  how skills are loaded or executed.
- **Per-skill variations handled naturally**: Each file contains its own correct skeptic name. No substitution mechanism
  needed.
- **Enables future extraction**: If Claude Code later supports plugin-scoped context injection, the markers make
  extraction straightforward.

**Cons**:

- Does not reduce token cost (content remains duplicated).
- Maintenance requires editing 3 files for shared changes. CI catches drift but doesn't prevent it.
- The "DRY violation" remains — this is intentional duplication, not accidental.

**Verdict**: RECOMMENDED. Preserves the most important architectural property (self-containment) while solving the
actual problem (maintenance drift). Token savings are modest and not worth the portability and reliability risks of
extraction.

## 3. Recommended Architecture: Validated Duplication with Markers

### 3.1 Section Markers

Add HTML comment markers around shared sections in each SKILL.md:

```markdown
<!-- BEGIN SHARED: principles -->

## Shared Principles

... (content) ...

<!-- END SHARED: principles -->

<!-- BEGIN SHARED: communication-protocol -->

## Communication Protocol

... (shared content) ...

<!-- END SHARED: communication-protocol -->

<!-- BEGIN SKILL-SPECIFIC: communication-extras -->

... (per-skill content like Contract Negotiation Pattern) ...

<!-- END SKILL-SPECIFIC: communication-extras -->
```

Markers serve two purposes:

1. **CI validation**: The P2-04 validation script extracts content between matching markers and compares across files.
2. **Developer guidance**: When editing shared content, the markers signal "this must match in all 3 files."

### 3.2 Content Normalization

Before adding markers, normalize the existing inconsistencies:

**Shared Principles**:

- Normalize plan-product's single quotes to double quotes (matching build-product and review-quality)
- Content becomes byte-identical across all 3 files

**Communication Protocol**:

- The shared portion (intro paragraph, "When to Message" table structure, "Message Format" template) is identical across
  all 3 files EXCEPT:
  - The "Plan ready for review" row references different skeptic names
  - Table formatting differs slightly (some have spaces around `|`, some don't)
- **Strategy**: Normalize table formatting. Accept that the skeptic name varies per skill — the CI check validates
  structural equivalence (same rows, same columns) rather than byte-identity for this section.

### 3.3 SKILL.md Modification Plan

For each of the 3 SKILL.md files:

**What gets added:**

- HTML comment markers around Shared Principles section (2 lines: open + close)
- HTML comment markers around Communication Protocol section (2 lines: open + close)
- HTML comment markers around skill-specific communication sections where applicable (2 lines)

**What gets modified:**

- plan-product/SKILL.md line 148: Change `'message'` to `"message"` and `'broadcast'` to `"broadcast"` (quote
  normalization in principle #2)
- plan-product/SKILL.md line 173: Change `'message'` to `"message"` and `'broadcast'` to `"broadcast"` (quote
  normalization in tool mapping note)
- plan-product/SKILL.md: Normalize table formatting to match other files (add spaces around `|` in the When to Message
  table)

**What gets removed:**

- Nothing. Content stays in place. Only markers are added and formatting is normalized.

**Net line count change per file**: +4 to +6 lines (marker comments only).

### 3.4 CI Validation Design (P2-04 Integration)

The validation script (implemented in P2-04) will:

1. Find all SKILL.md files matching `plugins/*/skills/*/SKILL.md`
2. Extract content between `<!-- BEGIN SHARED: principles -->` and `<!-- END SHARED: principles -->` markers
3. Compare extracted content across all files — must be byte-identical
4. Extract content between `<!-- BEGIN SHARED: communication-protocol -->` markers
5. Compare structural equivalence: same section headings, same table rows (allowing the skeptic name column to vary),
   same message format template
6. Report any drift with a diff showing exactly what diverged

### 3.5 Authoritative Source Convention

Even with validated duplication, developers need to know which copy is the "primary" to edit first. Convention:

- **plan-product/SKILL.md is the authoritative source** for shared content. When editing Shared Principles or
  Communication Protocol, edit plan-product first, then copy to the other two files.
- The CI check enforces this implicitly (any drift fails the build), but the convention provides workflow guidance.
- Document this convention in a comment at the top of each shared section:

```markdown
<!-- BEGIN SHARED: principles -->
<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->

## Shared Principles

...

<!-- END SHARED: principles -->
```

### 3.6 Migration Path

**For existing users**: No breaking change. SKILL.md files gain HTML comment markers (invisible in rendered markdown)
and minor formatting normalization. Agent behavior is unchanged.

**For projects that forked/customized SKILL.md**: HTML comments are additive. Customized content between markers will
cause CI failures if they diverge — this is the desired behavior (the CI check flags intentional divergence as "you've
customized this, be aware it no longer matches").

**For plugin consumers**: No action required. Skills remain self-contained.

### 3.7 Deviation Policy Alignment

The artifact format templates (P2-06) established a "reference, not enforced schema" policy. Content deduplication is
different:

- **Templates** are guidance — agents may deviate when justified.
- **Shared Principles and Communication Protocol** are **behavioral contracts** — agents must follow them exactly.
  Deviation is not acceptable.

The markers and CI validation enforce consistency at the file level (all 3 copies match). Behavioral compliance (agents
actually follow the principles) is enforced by the Skeptic at runtime, which is unchanged.

## 4. ADR Draft

See `docs/architecture/ADR-002-content-deduplication-strategy.md` (to be created during implementation).

### ADR-002: Content Deduplication Strategy

**Status**: Proposed

**Context**: Three SKILL.md files contain ~126 duplicated lines of Shared Principles and Communication Protocol. This
creates maintenance drift risk and wastes tokens. Three options were evaluated: CLAUDE.md extraction, plugin-scoped
shared file, and validated duplication.

**Decision**: Validated duplication with HTML comment markers. Content remains in all 3 SKILL.md files. CI validation
(P2-04) enforces consistency. plan-product/SKILL.md is the authoritative source.

**Rationale**: Self-containment is the most important architectural property of SKILL.md files. Each skill must function
in isolation without external file dependencies. The token savings from extraction (~2,520 tokens/invocation) do not
justify the portability and reliability risks. CI enforcement solves the actual maintenance problem.

**Alternatives rejected**:

- CLAUDE.md extraction: Scoping problem (CLAUDE.md belongs to consumer project, not plugin). Partial extraction only
  (Communication Protocol has per-skill variations).
- Plugin-scoped shared file: Runtime fragility (agents may fail to read shared file). Doesn't cleanly handle per-skill
  variations.

**Consequences**:

- Positive: Self-containment preserved. No runtime fragility. No portability regression.
- Positive: CI catches drift automatically.
- Negative: Token cost remains (but is modest at ~2,520 tokens/invocation).
- Negative: Editing shared content requires updating 3 files manually.

## 5. Open Questions

1. **Researcher input requested**: Confirmation on CLAUDE.md loading behavior for plugins. While I've proceeded with the
   design assuming CLAUDE.md is project-scoped (not plugin-scoped), the researcher's findings may reveal a plugin-scoped
   context mechanism that changes the calculus.

2. **Quote style normalization**: plan-product uses single quotes, the others use double quotes. I recommend normalizing
   to double quotes. This is a trivial change but should be confirmed as acceptable.

3. **Table formatting normalization**: plan-product uses compact table formatting (`|col1|col2|`), the others use spaced
   formatting (`| col1 | col2 |`). I recommend normalizing to spaced formatting for readability.
