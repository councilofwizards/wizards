---
feature: "persona-system-activation"
team: "write-spec"
agent: "spec-skeptic"
phase: "review"
status: "complete"
last_action: "Reviewed architect design for P2-09 persona system activation"
updated: "2026-03-10"
---

# Spec Skeptic Review: P2-09 Persona System Activation

**Reviewer**: Wren Cinderglass, Siege Inspector (Spec Skeptic) **Document
reviewed**: `docs/progress/persona-system-activation-architect.md` **Stories
reference**: `docs/specs/persona-system-activation/stories.md` (5 approved
stories)

---

## REVIEW: Architect Design for P2-09 Persona System Activation

### Verdict: APPROVED (with mandatory fix)

---

### Story Coverage Assessment

| Story                                  | Covered? | Notes                                                                                                                                                                                                                                           |
| -------------------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Story 1: Fictional Name Injection      | YES      | Template pattern is correct. All 33 prompts across 11 skills mapped with persona file, fictional_name, title, role name, team name. Verified grep count: 34 occurrences of the old pattern across 12 files; minus 1 for run-task = 33. Matches. |
| Story 2: Self-Introduction Instruction | YES      | Instruction "When communicating with the user, introduce yourself by your name and title." placed on the line after the identity line. Tightly coupled with Story 1 as intended.                                                                |
| Story 3: Sign-Off Convention           | YES      | Prose sentence placed before the fenced code block in Message Format section. Correct per edge case guidance. Sync propagation addressed.                                                                                                       |
| Story 4: Placeholder Fix               | YES      | Three-file change identified (communication-protocol.md, sync-shared-content.sh, skill-shared-content.sh). Sync-breaking risk identified and mitigated.                                                                                         |
| Story 5: Validator Green               | YES      | Execution order specified. 7 verification commands provided. 12/12 pass requirement stated.                                                                                                                                                     |

### Issues Found

**Issue 1 (MANDATORY FIX — clarity, not correctness): Self-contradictory
paragraph in Section 3.2**

Lines 318-323 of the architect document read:

> "The B2 normalizer in skill-shared-content.sh does NOT need changes. [...]
> This would cause B2 drift unless the normalizer is updated."

The paragraph starts by asserting no change is needed, then concludes the
opposite. The architect corrects this immediately in the "Additional required
change" paragraph that follows, so the final specification IS correct — the
normalizer DOES get updated with `{skill-skeptic}` and `{Skill Skeptic}`
entries. However, the contradictory lead sentence is dangerous: an implementer
scanning bold text could read "does NOT need changes" and skip the update,
causing B2 failures across all 12 skills.

**Required fix**: Remove or rewrite the contradictory paragraph (lines 318-323).
Replace with a single clear statement: "The B2 normalizer in
`skill-shared-content.sh` MUST be updated to normalize `{skill-skeptic}` and
`{Skill Skeptic}` to SKEPTIC_NAME, since the authoritative source now contains
the placeholder while SKILL.md files contain the substituted per-skill values."

### Observations (non-blocking)

**Observation 1: Inline HTML comment on table row (Story 4)**

The proposed format for the placeholder row is:

```
| Plan ready for review | `write({skill-skeptic}, ...)` | {Skill Skeptic} |<!-- substituted by ... -->
```

The HTML comment is appended after the final `|` of the table row. In strict
CommonMark, content after the closing `|` of a table row is ignored, so the
comment is invisible to renderers. This is fine for the purpose (a developer
hint), but some markdown linters may flag it. Non-blocking — just noting it for
the implementer's awareness.

**Observation 2: sed and curly braces**

The architect correctly notes that `{` and `}` are not special in sed's basic
regex when unescaped. This is true for both GNU sed and macOS BSD sed in BRE
mode. The sync script does not use `-E` (extended regex), so no collision.
Verified.

**Observation 3: Lead persona exclusion rationale**

The architect states lead personas are loaded in Setup steps via `Read` and do
not need spawn prompt changes. This is correct — leads are the orchestrating
agent itself, not spawned teammates. The 33-prompt count excludes leads. This
matches the stories' scope (spawn prompts only).

**Observation 4: run-task exclusion**

The architect correctly identifies run-task's single skeptic prompt (line 274,
"You are the Skeptic on the Ad-Hoc Task Team") as out of scope. Grep confirms
this is the only occurrence in run-task. The V2 verification command correctly
expects run-task as the sole remaining match for the old pattern.

**Observation 5: Fallback default changes in sync script**

The architect proposes changing fallback defaults in `extract_skeptic_names`
(lines 97-98, 107-108) from `product-skeptic`/`Product Skeptic` to
`{skill-skeptic}`/`{Skill Skeptic}`. These fallbacks fire only when no "Plan
ready for review" row exists in a SKILL.md. After sync, all 12 multi-agent
SKILL.md files will have the row with their per-skill slug, so the fallback
never fires in practice. The change is cosmetic consistency — not load-bearing.
Non-blocking.

### Verification of Key Claims

- **33 prompts across 11 files**: VERIFIED. Grep found 34 occurrences of
  `You are the .* on the .* Team` across 12 SKILL.md files. Minus 1 for run-task
  = 33.
- **Sync substitution logic**: VERIFIED. `AUTH_SKEPTIC_SLUG` on line 173 is the
  sed search pattern. Changing source and search pattern in lockstep preserves
  substitution behavior.
- **B2 normalizer update needed**: VERIFIED. Without the `{skill-skeptic}`
  entry, the normalized source would retain the literal placeholder while
  normalized SKILL.md files would have SKEPTIC_NAME, causing drift on every
  comparison.
- **Execution order**: VERIFIED. Edit source files first, then sync, then
  validate. No intermediate sync between Stories 3 and 4 edits. Correct.

---

**Summary**: The design is thorough, complete, and feasible. Every story and
acceptance criterion is addressed. The sync-breaking risk in Story 4 — which I
flagged before seeing the spec — was independently identified and correctly
mitigated by the architect. The only mandatory fix is removing the
self-contradictory paragraph in Section 3.2 to prevent implementer confusion.
Once that paragraph is rewritten, this spec is ready for implementation.
