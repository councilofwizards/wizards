---
title: "PoC Deprecation Banner Specification"
status: "approved"
priority: "P3"
category: "developer-experience"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# PoC Deprecation Banner Specification

## Summary

Add a `status: internal` frontmatter field and a visible deprecation banner to
`tier1-test/SKILL.md` so the PoC test skill is immediately identifiable as
non-production internal scaffolding. Two-line edit to one file. `tier2-test` was
removed and is not in scope.

## Problem

`tier1-test` is a Phase 0 PoC skill that appears alongside production skills in
skill discovery. Its description mentions "PoC" and "test artifact" but gives no
explicit warning that it's internal scaffolding. A user browsing available
skills might invoke it expecting useful output.

## Solution

### Frontmatter Addition

Add to `plugins/conclave/skills/tier1-test/SKILL.md` frontmatter:

```yaml
status: internal
```

This field is not currently required or validated by A1. It serves as a
machine-readable signal for future discovery filtering and as documentation for
contributors.

### Banner Addition

Add immediately after the frontmatter closing `---`, before any existing
content:

```markdown
> **INTERNAL SKILL**: This is internal test scaffolding used for PoC validation.
> It is not intended for end-user invocation and produces no meaningful output.
```

### Validator Compatibility

- A1 checks required fields (`name`, `description`, `argument-hint`, `category`)
  and validates specific field values (`tier`, `category`). It does not validate
  `status` as a field. Adding `status: internal` will not trigger any failure.
- If a future validator adds `status` value enforcement, `internal` should be
  included as an allowed value. The implementer should check for pending
  validator work that might conflict.

## Constraints

1. Only `tier1-test/SKILL.md` is modified — no other files
2. `tier2-test` was removed and must not be referenced
3. All validators must pass after the edit
4. The existing `description` field is not changed — the banner supplements it

## Out of Scope

- Removing tier1-test from the codebase
- Adding skill discovery filtering for `status: internal`
- Modifying validators to enforce status field values
- Any changes to other skills or test files

## Files to Modify

| File                                          | Change                                                                       |
| --------------------------------------------- | ---------------------------------------------------------------------------- |
| `plugins/conclave/skills/tier1-test/SKILL.md` | Add `status: internal` to frontmatter + deprecation banner after frontmatter |

## Success Criteria

1. `tier1-test/SKILL.md` frontmatter contains `status: internal`
2. A visible banner appears as the first content after frontmatter
3. `bash scripts/validate.sh` passes with no new failures
4. No references to `tier2-test` anywhere in the changes
