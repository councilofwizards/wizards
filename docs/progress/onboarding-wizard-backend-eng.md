---
date: 2026-02-19
agent: backend-eng
task: Modify skill-structure.sh for single-agent support
status: complete
---

## Summary

Modified `/Users/zacharymowrey/code/councilofwizards/wizards/scripts/validators/skill-structure.sh` to support
`type: single-agent` SKILL.md files.

## Changes Made

**File:** `scripts/validators/skill-structure.sh`

After extracting YAML frontmatter, added detection of `type: single-agent` field:

```bash
is_single_agent=0
if printf '%s\n' "$fm_content" | grep -q "^type:[[:space:]]*single-agent"; then
    is_single_agent=1
fi
```

### A1 (Frontmatter)

No change — same required fields (name, description, argument-hint) for both types.

### A2 (Required Sections)

Single-agent path: only `## Setup` and `## Determine Mode` required. Multi-agent path: all 10+ sections unchanged.

### A3 (Spawn Definitions)

Single-agent: skip entirely (`a3_pass++`). Multi-agent: existing behavior unchanged.

### A4 (Shared Content Markers)

Single-agent: skip entirely (`a4_pass++`). Multi-agent: existing behavior unchanged.

## TDD Approach

1. Created fixture at `/tmp/test-skill-structure/plugins/test-plugin/skills/setup-project/SKILL.md` with
   `type: single-agent`
2. Confirmed it FAILED before changes (A2/A3/A4 failures)
3. Implemented changes
4. Confirmed fixture now PASSES all A1–A4 checks
5. Confirmed all 3 existing multi-agent SKILL.md files still pass full validation suite (11/11)

## Validation Result

```
Validation complete: 11 passed, 0 failed
```
