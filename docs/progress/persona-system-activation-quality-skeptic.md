---
type: "progress"
feature: "persona-system-activation"
session_type: "quality-skeptic-review"
created: "2026-03-10"
---

# QUALITY REVIEW: Persona System Activation — Implementation Plan

**Gate**: PRE-IMPLEMENTATION **Verdict**: APPROVED

**Reviewer**: Mira Flintridge, Master Inspector of the Forge — Quality Skeptic on the Implementation Build Team

---

## Review Summary

The implementation plan is precise, mechanically sound, and faithfully implements the approved spec. All 33 spawn prompt
edits, the shared protocol changes, and the sync/validator toolchain updates are specified with exact line numbers,
before/after content, and dependency ordering. This plan is ready for execution.

## Verification Performed

1. **Line number accuracy**: Spot-checked spawn prompt line numbers for plan-implementation (222, 276),
   build-implementation (302, 352, 397), and research-market (215, 255) against actual files. All match exactly.

2. **Authoritative source content**: Confirmed `communication-protocol.md` line 31 contains the `product-skeptic` /
   `Product Skeptic` values the plan targets for replacement. Confirmed line 39 contains the text the sign-off
   instruction will follow.

3. **Sync script mechanics**: Confirmed `AUTH_SKEPTIC_SLUG` on line 173 and `AUTH_SKEPTIC_DISPLAY` on line 174 match the
   plan's target values. Confirmed fallback defaults on lines 97-98 and 107-108 match. The plan's claim that `{` and `}`
   are literal in sed BRE replacement strings is correct — they only become special when escaped with backslash in BRE.

4. **Extract function safety**: The `extract_skeptic_names` function (line 92) uses `[a-z-]*` regex to extract slugs.
   This function is called only on target SKILL.md files (line 202), never on the authoritative source. After sync,
   SKILL.md files contain real slugs like `quality-skeptic`, which match the regex. The `{skill-skeptic}` placeholder in
   the authoritative source never passes through this function. No issue.

5. **Awk field isolation**: Confirmed the HTML comment placement after the final `|` puts it in awk field $5, keeping
   `{Skill Skeptic}` cleanly in field $4 where `extract_skeptic_names` reads it.

6. **B2 normalizer**: Confirmed the existing normalizer ends at line 75 with `'Task Skeptic'` and the plan correctly
   identifies the insertion point for the two new `-e` patterns.

7. **Spec alignment**: Cross-referenced all 33 persona-to-prompt mappings against the spec's Complete Prompt Mapping
   table (spec lines 55-67). All names, roles, and skill files match.

## Observations (Non-Blocking)

1. **Bottom-up edit order**: The plan correctly instructs editing spawn prompts bottom-up within each file to prevent
   line drift. This is important guidance — an engineer who edits top-down will shift subsequent line numbers. The plan
   could be even more explicit that this applies to the edits within Step 4 only (Steps 1-3 are single-file
   single-location edits).

2. **Sync idempotency test**: The test strategy includes running sync twice and checking for zero diff. This is the
   right check. One subtlety: the first sync after Step 4 will also overwrite the communication-protocol blocks in the
   SKILL.md files (propagating the sign-off and placeholder fix). The second sync should be truly no-op. This is
   correctly implied but worth the engineer verifying.

3. **Grep verification**: The test strategy's grep check for residual `product-skeptic` is good. The engineer should
   also verify no `{skill-skeptic}` literal remains in any SKILL.md file after sync (would indicate substitution
   failure).

---

_Reviewed and approved for implementation. The plan is executable as written._

— Mira Flintridge, Master Inspector of the Forge
