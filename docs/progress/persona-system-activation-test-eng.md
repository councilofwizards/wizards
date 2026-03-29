---
feature: "persona-system-activation"
team: "review-quality"
agent: "test-eng"
phase: "review"
status: "complete"
last_action: "All 6 test suites executed. 5 PASS, 1 PASS WITH NOTES. No blockers."
updated: "2026-03-10T14:00:00Z"
---

## Test Report — Persona System Activation (P2-09)

**Tester:** Jinx Copperwire, Trap Specialist — Test Engineer, Quality & Operations Team **Date:** 2026-03-10
**Feature:** P2-09 — Persona System Activation (33 spawn prompt edits across 11 SKILL.md files)

---

## T1: Persona Name Accuracy — PASS

Spot-checked 12 persona name/title pairs across engineering skills, business skills, and 4+ agent skills.

| Skill                 | Persona File                               | Persona YAML                                         | Spawn Prompt                                                                           | Match |
| --------------------- | ------------------------------------------ | ---------------------------------------------------- | -------------------------------------------------------------------------------------- | ----- |
| research-market       | market-researcher.md                       | `Theron Blackwell` / `Scout of the Outer Reaches`    | "You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher..."      | PASS  |
| research-market       | customer-researcher.md                     | `Lyssa Moonwhisper` / `Oracle of the People's Voice` | "You are Lyssa Moonwhisper, Oracle of the People's Voice — the Customer Researcher..." | PASS  |
| ideate-product        | idea-generator.md                          | `Pip Quicksilver` / `Chaos Alchemist`                | "You are Pip Quicksilver, Chaos Alchemist — the Idea Generator..."                     | PASS  |
| ideate-product        | idea-evaluator.md                          | `Morwen Greystone` / `Transmutation Judge`           | "You are Morwen Greystone, Transmutation Judge — the Idea Evaluator..."                | PASS  |
| build-implementation  | backend-eng.md                             | `Bram Copperfield` / `Foundry Smith`                 | "You are Bram Copperfield, Foundry Smith — the Backend Engineer..."                    | PASS  |
| build-implementation  | quality-skeptic.md                         | `Mira Flintridge` / `Master Inspector of the Forge`  | "You are Mira Flintridge, Master Inspector of the Forge — the Quality Skeptic..."      | PASS  |
| review-quality        | test-eng.md                                | `Jinx Copperwire` / `Trap Specialist`                | "You are Jinx Copperwire, Trap Specialist — the Test Engineer..."                      | PASS  |
| write-spec            | software-architect.md                      | `Kael Stoneheart` / `Master Builder of the Keep`     | "You are Kael Stoneheart, Master Builder of the Keep — the Software Architect..."      | PASS  |
| write-spec            | spec-skeptic.md                            | `Wren Cinderglass` / `Siege Inspector`               | "You are Wren Cinderglass, Siege Inspector — the Skeptic..."                           | PASS  |
| draft-investor-update | accuracy-skeptic--draft-investor-update.md | `Gideon Factstone` / `Truth Warden of the Archives`  | "You are Gideon Factstone, Truth Warden of the Archives — the Accuracy Skeptic..."     | PASS  |
| plan-sales            | gtm-analyst.md                             | `Flint Roadwarden` / `Caravan Master`                | "You are Flint Roadwarden, Caravan Master — the GTM Analyst..."                        | PASS  |
| plan-hiring           | researcher--plan-hiring.md                 | `Cress Ledgerborn` / `Census Keeper`                 | "You are Cress Ledgerborn, Census Keeper — the Researcher..."                          | PASS  |

**Result:** All 12 spot-checked name/title pairs match the persona YAML frontmatter exactly. No mismatches found.

---

## T2: Spawn Prompt Structure — PASS

Verified structure in 5 files: research-market, build-implementation, draft-investor-update, plan-sales, plan-hiring.

Pattern verified in each:

1. `First, read plugins/conclave/shared/personas/{id}.md for your complete role definition and cross-references.` —
   UNTOUCHED (read-line present and correct)
2. Blank line after the read line — PRESENT
3. Identity line with em dash (—): `You are {Name}, {Title} — the {Role} on the {Team}.` — CORRECT EM DASH used
4. Self-intro instruction on the NEXT line (no blank line between):
   `When communicating with the user, introduce yourself by your name and title.` — CORRECT, no blank line between
   identity and self-intro
5. Rest of spawn prompt content untouched — CONFIRMED (YOUR ROLE, CRITICAL RULES etc. intact)

Sample verified (research-market, market-researcher spawn, lines 219–231):

```
First, read plugins/conclave/shared/personas/market-researcher.md for your complete role definition and cross-references.

You are Theron Blackwell, Scout of the Outer Reaches — the Market Researcher on the Market Research Team.
When communicating with the user, introduce yourself by your name and title.

YOUR ROLE: Investigate the competitive landscape, market size, and industry trends.
```

**Result:** All 5 files conform to the required structure. Em dash used consistently. Self-intro immediately follows
identity line.

---

## T3: Sync Script Robustness — PASS

Reviewed `scripts/sync-shared-content.sh` — `extract_skeptic_names` function (lines 92–119).

**Clean slugs:** `sed -n 's/.*write([{]*\([a-z-]*\)[}]*,.*/\1/p'` — strips optional `{`/`}` around slug, returns bare
slug. Handles e.g. `write(quality-skeptic,` → `quality-skeptic`. PASS.

**Corrupted `}` slugs:** The `[{]*...[}]*` pattern tolerates extra braces on either side. PASS.

**Placeholder values filtered:** `if [ "$slug" = "skill-skeptic" ]; then slug=""; fi` — filtered out when stripped
placeholder equals `skill-skeptic`. Similarly `if [ "$display" = "Skill Skeptic" ]; then display=""; fi`. PASS.

**Intermediate variables for parameter expansion:** Lines 115–118 use:

```bash
local default_slug='{skill-skeptic}'
local default_display='{Skill Skeptic}'
echo "${slug:-$default_slug}"
echo "${display:-$default_display}"
```

The `{`/`}` characters are safely held in intermediate variables (`default_slug`, `default_display`) and expanded via
`${var:-default}`. This avoids the shell parsing `{skill-skeptic}` as a literal braces pattern. PASS.

**AUTH_SKEPTIC_SLUG / AUTH_SKEPTIC_DISPLAY:** Lines 183–184:

```bash
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"
```

Both correctly set to the placeholder values. PASS.

**sed substitution (lines 219, 222):** The substitution `sed "s/$AUTH_SKEPTIC_SLUG/$target_slug/g"` expands to
`sed "s/{skill-skeptic}/target-slug/g"`. The `{` and `}` are literal characters in basic regex; sed does not interpret
them as quantifiers in this context (they require `\{`/`\}` for ERE quantifiers in GNU sed, or the `-E` flag). No
escaping issue. PASS.

**Result:** All four robustness scenarios verified. No bash bugs found.

---

## T4: Protocol Content — PASS

Reviewed `plugins/conclave/shared/communication-protocol.md` (lines 1–49).

**Sign-off line position:** Line 40 reads `When addressing the user, sign messages with your persona name and title.` —
correctly placed after "Keep messages structured so they can be parsed quickly by context-constrained agents:" (line 39)
and before the code block opening (line 42). PASS.

**Plan ready for review row:** Line 31:

```
| Plan ready for review | `write({skill-skeptic}, "PLAN REVIEW REQUEST: [details or file path]")`     | {Skill Skeptic}     |<!-- substituted by sync-shared-content.sh per skill -->
```

Uses `{skill-skeptic}` in the write() call and `{Skill Skeptic}` as display name. HTML comment is after the last pipe.
PASS.

**No literal `product-skeptic` / `Product Skeptic`:** `grep` against the file returns no matches. PASS.

**Result:** Protocol content is correct. Sign-off line position confirmed. No placeholder leakage.

---

## T5: Validator Coverage — PASS

Reviewed `scripts/validators/skill-shared-content.sh` — `normalize_skeptic_names` function (lines 50–78).

The function includes both placeholder patterns as the final two substitutions (lines 76–77):

```bash
-e 's/{skill-skeptic}/SKEPTIC_NAME/g' \
-e 's/{Skill Skeptic}/SKEPTIC_NAME/g'
```

These appear at the end of the 13-pair normalization chain. The authoritative source file uses `{skill-skeptic}` and
`{Skill Skeptic}`, so they will normalize to `SKEPTIC_NAME` — matching the per-skill files that have already been
substituted with real skeptic names (which are also normalized). PASS.

**Result:** Validator normalization covers `{skill-skeptic}` and `{Skill Skeptic}`. B2 checks will pass for both the
authoritative source and all synced skill files.

---

## T6: No Regressions — PASS

Ran `bash scripts/validate.sh` from repo root. Output:

```
[PASS] A1/frontmatter: All SKILL.md files have valid YAML frontmatter (18 files checked)
[PASS] A2/required-sections: All SKILL.md files have all required sections (18 files checked)
[PASS] A3/spawn-definitions: All spawn definitions have required fields (18 files checked)
[PASS] A4/shared-markers: All SKILL.md files have properly paired shared content markers (18 files checked)
[PASS] B1/principles-drift: Shared Principles blocks are byte-identical across all skills (18 files checked)
[PASS] B2/protocol-drift: Communication Protocol blocks are structurally equivalent across all skills (18 files checked)
[PASS] B3/authoritative-source: All BEGIN SHARED markers are followed by authoritative source comment (18 files checked)
[PASS] C1/required-fields: All roadmap files have valid required frontmatter fields (38 files checked)
[PASS] C2/filename-convention: All roadmap filenames match required pattern and priority (38 files checked)
[PASS] D1/required-fields: All spec files have valid required frontmatter fields (12 files checked)
[PASS] E1/required-fields: All checkpoint files have valid required frontmatter fields (76 files checked)
[PASS] F1/artifact-templates: All artifact templates exist with correct type fields (4 templates checked)

Validation complete: 12 passed, 0 failed
```

**Result:** 12/12 PASS. Zero regressions introduced.

---

## Observations & Notes

### Lead-as-Skeptic skills retain `product-skeptic` in protocol row

`research-market`, `ideate-product`, and `manage-roadmap` all show `product-skeptic` / `Product Skeptic` in their "Plan
ready for review" protocol row. These three skills use Lead-as-Skeptic (no dedicated skeptic agent). The sync script
reads the existing slug from the file; since these skills never had a real skeptic slug substituted, `product-skeptic`
persists as the inherited value from before the `{skill-skeptic}` placeholder system was introduced.

**Assessment:** This is a pre-existing condition unrelated to P2-09. B2 validator passes because `product-skeptic` is in
the normalization list. However, the `<!-- substituted by sync-shared-content.sh per skill -->` comment is misleading
for these files — the sync script leaves the value unchanged when it reads back `product-skeptic` (which does not equal
`AUTH_SKEPTIC_SLUG` of `{skill-skeptic}`), so it runs the sed substitution `s/{skill-skeptic}/product-skeptic/g` — a
no-op since the file already contains `product-skeptic`. Net effect: these three files perpetually retain
`product-skeptic`. This is harmless but semantically imprecise.

**Recommendation (non-blocking):** A follow-up task could clarify these rows for Lead-as-Skeptic skills (e.g., replace
with `write(lead, ...)` since the Lead is the skeptic). Not in scope for P2-09.

### `task-skeptic` has no persona file

`run-task` uses `task-skeptic` as the protocol slug, but there is no `task-skeptic.md` in `shared/personas/`. This is by
design — run-task's skeptic is dynamically spawned by the Task Coordinator based on task complexity. The persona file
for the `task-coordinator` role exists. No action required.

---

## Summary

| Test                       | Result | Notes                                                                  |
| -------------------------- | ------ | ---------------------------------------------------------------------- |
| T1: Persona Name Accuracy  | PASS   | 12/12 spot-checks match YAML frontmatter exactly                       |
| T2: Spawn Prompt Structure | PASS   | Em dash correct, self-intro on next line, read-line untouched          |
| T3: Sync Script Robustness | PASS   | Intermediate variables used correctly, sed handles `{}` safely         |
| T4: Protocol Content       | PASS   | Sign-off in correct position, no literal `product-skeptic` remains     |
| T5: Validator Coverage     | PASS   | `{skill-skeptic}` and `{Skill Skeptic}` patterns present in normalizer |
| T6: No Regressions         | PASS   | 12/12 validators pass                                                  |

**Verdict: APPROVED.** P2-09 implementation is correct and production-ready. No blocking issues found.
