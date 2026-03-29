---
type: progress
feature: persona-system-activation
role: plan-skeptic
status: review-submitted
updated: 2026-03-10
---

# PLAN REVIEW: Persona System Activation

**Verdict: REJECTED**

## Blocking Issues (must fix)

1. **Inline comment in the placeholder row breaks sync idempotency and produces cascading duplication.**

   The plan's Change 1b adds an inline HTML comment to the "Plan ready for review" row in the authoritative source:

   ```
   | Plan ready for review | `write({skill-skeptic}, ...)` | {Skill Skeptic} <!-- placeholder: replaced per-skill by sync script -->     |
   ```

   After sync, a SKILL.md will contain:

   ```
   | Plan ready for review | `write(plan-skeptic, ...)` | Plan Skeptic <!-- placeholder: replaced per-skill by sync script -->     |
   ```

   On the **next** sync run, `extract_skeptic_names` (line 106 of `sync-shared-content.sh`) uses
   `awk -F'|' '{...print $4}'` to extract the display name from pipe-delimited field 4. This captures everything between
   the third and fourth pipe characters, including the HTML comment. So `target_display` becomes
   `Plan Skeptic <!-- placeholder: replaced per-skill by sync script -->`.

   Then line 212 does `sed "s/$AUTH_SKEPTIC_DISPLAY/$target_display/g"` which replaces `{Skill Skeptic}` in the auth
   source content (which already contains `<!-- placeholder... -->`) with `Plan Skeptic <!-- placeholder... -->`,
   producing a **doubled comment**:

   ```
   Plan Skeptic <!-- placeholder: replaced per-skill by sync script --> <!-- placeholder: replaced per-skill by sync script -->
   ```

   Each subsequent sync adds another copy. This violates the sync idempotency requirement and will cause B2 drift
   failures.

   **Fix**: Remove the inline comment from the authoritative source entirely. The fact that the placeholder is replaced
   per-skill is already documented in the sync script itself and in this implementation plan. If a comment is truly
   needed, add it on a separate line above or below the table (outside the table row), or modify `extract_skeptic_names`
   to strip HTML comments from the extracted display name before returning it. The cleanest fix is to simply not add the
   comment — the `{Skill Skeptic}` placeholder syntax is self-documenting.

## Non-blocking Issues (should fix)

2. **Step 3 placement instructions are ambiguous.** The plan says "Insert before the existing last two lines
   (task-skeptic/Task Skeptic on lines 74-75)" but then says "Or equivalently, anywhere in the sed chain" and "Safest to
   add at the end, before the closing of the sed expression." The closing of the sed expression is actually the end of
   line 75 (the last `-e` clause), with the function's closing `}` on line 76. The new lines should be inserted between
   lines 75 and 76, continuing the backslash-chain from line 75. **Suggestion**: State explicitly: "Add two new `-e`
   lines after line 75 (`Task Skeptic`), continuing the backslash chain, before the function closing brace on line 76."

3. **Step 4 line-number drift advice is incomplete.** The plan correctly notes "edit from bottom-up within each file to
   prevent drift" in the Risks table, but Step 4's ordered list presents edits top-down (e.g., research-market line 215
   before line 255). The implementer must mentally reverse the order within each file. **Suggestion**: Add a one-line
   note at the top of Step 4 stating: "Within each file, apply edits bottom-up (highest line number first) to prevent
   line drift."

4. **Trailing whitespace in the placeholder row.** The plan's Change 1b has
   `{Skill Skeptic} <!-- placeholder: ... -->     |` with extra trailing spaces before the pipe. If the comment is
   removed per Issue 1, ensure the replacement row has consistent trailing whitespace matching the original column
   width, or accept that column alignment will shift. This is cosmetic but worth noting for clean diffs.

## Items Verified (no issues found)

- **Spawn prompt count**: 33 prompts across 11 skills confirmed (2+2+1+2+3+2+3+4+4+5+5).
- **Line numbers spot-checked**: research-market (215, 255), manage-roadmap (211), write-spec (238, 288, 339),
  plan-implementation (222, 276), plan-hiring (541, 1083), draft-investor-update (279, 501) — all correct against
  current files.
- **Persona names spot-checked** against persona YAML frontmatter: Theron Blackwell/Scout of the Outer Reaches
  (market-researcher), Seren Mapwright/Siege Engineer (impl-architect), Garret Scalewise/Pragmatist Judge (fit-skeptic)
  — all match.
- **sed BRE handling of `{` and `}`**: Verified on macOS Darwin that `{` and `}` are literal in `sed 's///g'` without
  `-E` flag. The sync script's substitution logic is sound.
- **Slug extraction**: The `[a-z-]*` regex in `extract_skeptic_names` correctly extracts only the slug portion and
  ignores `{`/`}` characters. No issue on the slug side.
- **Dependency order**: Steps 1-6 have correct sequential dependencies. Protocol edit before sync script edit before
  validator edit before SKILL.md edits before running sync before running validate.
- **Scope**: No gold plating detected. run-task correctly excluded. Lead prompts correctly excluded. Persona files
  correctly out of scope.
- **Test strategy**: Validator suite, idempotency check, spot-checks, and grep verifications are sufficient — assuming
  the idempotency test is actually run (it would catch Issue 1).
- **B2 normalization**: The new `{skill-skeptic}`/`{Skill Skeptic}` patterns in the normalizer will correctly allow the
  authoritative source to match per-skill substituted versions after normalization.

---

_Hale Blackthorn, War Auditor_
