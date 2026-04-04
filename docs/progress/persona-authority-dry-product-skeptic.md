---
feature: "persona-authority-dry-refactor"
team: "product-planning-team"
agent: "product-skeptic"
phase: "complete"
status: "complete"
last_action: "APPROVED spec — all 7 stories covered, 1 non-blocking note on P1 backward compat text."
updated: "2026-04-04"
---

## Progress Notes

- Read P3-32 roadmap item — understood scope: move agent-intrinsic content from inline spawn prompts to persona files,
  thin spawn prompts to ~10-15 lines
- Read ops-skeptic.md — understood current persona file schema (frontmatter: name, id, model, archetype, skill, team,
  fictional_name, title; body: Identity, Role, Critical Rules, Responsibilities, Output Format, Write Safety,
  Cross-References)
- Read audit-slop SKILL.md header — confirmed ~1,640 line skill with ~900 lines of spawn prompts, validating the
  motivation for DRY refactor
- Noted 57 persona files already exist in shared/personas/ — this refactor has prior art to build on
- Standing by for story-writer to submit stories for review
- Received 7 stories for review from story-writer
- Verified claims against codebase: read doubt-augur.md, pattern-augur.md, software-architect.md, audit-slop SKILL.md
  spawn prompts
- Confirmed all 10 augur persona files exist (story claimed some might not)
- Confirmed persona files already contain methodology + output format (story claimed they were missing)
- REJECTED: 4 issues — 2 factual errors (persona completeness, file existence), 1 contradiction (override semantics), 1
  testability gap (behavioral equivalence)
- Sent detailed fixes to story-writer-e7b1 and team lead
- Received revised stories (revision 2) — verified all 4 fixes
- APPROVED stories: factual errors corrected, contradiction resolved, testability gap closed
- Standing by for Stage 5 spec review from architect
- Received spec for review — docs/specs/persona-authority-dry/spec.md
- Verified all 7 stories covered: schema, thin format, overrides, validators, PoC, rollout, Forge
- Verified internal consistency: schema matches validator checks, override convention consistent with non-overridable
  markers
- Found 1 non-blocking issue: P1 backward compat text falsely claims pre-migration prompts lack `First, read` directive
  — grepped and confirmed all 100 spawn prompts across 21 skills already have it
- APPROVED spec with non-blocking note to architect
- All review duties complete
