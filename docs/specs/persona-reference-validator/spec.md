---
title: "Persona Reference Validator Specification"
status: "approved"
priority: "P3"
category: "quality-reliability"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Persona Reference Validator Specification

## Summary

Add a G2 validator (`scripts/validators/skill-persona-refs.sh`) that checks every spawn prompt in multi-agent SKILL.md files for three invariants: (1) a persona file read instruction is present, (2) the referenced persona file exists on disk, (3) the fictional name in the prompt matches the persona file's `fictional_name` frontmatter field. This prevents silent regression of the persona system activated in P2-09.

## Problem

P2-09 injected fictional persona names and persona file read instructions into spawn prompts across all 14 multi-agent skills. However, no validator guards against regression. A future SKILL.md edit could remove a read instruction, reference a non-existent persona file, misspell a fictional name, or add a new spawn prompt without persona grounding — and `bash scripts/validate.sh` would continue reporting green. The persona system is now a structural invariant that needs automated enforcement.

## Solution

### Validator Script: `scripts/validators/skill-persona-refs.sh`

A ~100-150 line bash script following existing validator conventions:

```bash
#!/usr/bin/env bash
# Category G: Persona reference integrity
# Usage: skill-persona-refs.sh <repo_root>
set -euo pipefail
```

**Input**: All `plugins/*/skills/*/SKILL.md` files (same find pattern as other validators).

**Skip logic**: Skip files with `type: single-agent` in frontmatter (consistent with A3/A4/B-series).

**Parsing approach**:
1. Locate the `## Teammate Spawn Prompts` section (or `## Teammates to Spawn`) in each SKILL.md
2. Within that section, identify spawn prompt code blocks (content between triple-backtick fences)
3. For each code block, extract the persona file path from the read instruction pattern
4. Validate the three invariants

### Check G2a: Persona Read Instruction Present

For each spawn prompt code block in each multi-agent SKILL.md:
- Search for a line containing `plugins/conclave/shared/personas/` (literal string match)
- Extract the referenced persona file path (e.g., `plugins/conclave/shared/personas/story-writer.md`)
- If not found, check for the **deferred persona assignment pattern**: if the spawn prompt contains the literal string `read the persona file assigned by the Team Lead`, treat G2a as PASS for that prompt and skip G2b/G2c (the persona path is resolved at runtime by the Team Lead, not hardcoded in the SKILL.md). This pattern is used by run-task's template prompts (Engineer, Researcher, Skeptic) where the Team Lead dynamically assigns personas.
- If neither pattern is found: `[FAIL] G2/persona-refs: {skill} — {agent}: missing persona read instruction in spawn prompt`

### Check G2b: Persona File Exists

For each persona file path extracted in G2a:
- Check if `$REPO_ROOT/{path}` exists as a file
- If not found: `[FAIL] G2/persona-refs: {skill} — {agent}: persona file not found: {path}`
- If file not found, skip G2c for this entry (avoid double failure)

### Check G2c: Fictional Name Match

For each persona file that exists (passed G2b):
- Extract `fictional_name` from the persona file's YAML frontmatter: `grep -m1 "^fictional_name:" "$file" | sed 's/fictional_name:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}/\1/'`
- If `fictional_name` field is missing: `[WARN] G2/persona-refs: {skill} — {agent}: persona file missing fictional_name field — skipping name check` (not a failure)
- If `fictional_name` is found, search for the exact string (literal match via `grep -F`) in the spawn prompt code block
- If not found: `[FAIL] G2/persona-refs: {skill} — {agent}: fictional name mismatch — expected "{name}" (from {persona-file}), not found in spawn prompt`

### Agent Role Name Extraction

The agent role name for error messages is extracted from the H3 heading (`### {Role Name}`) that precedes each spawn prompt block in the `## Teammate Spawn Prompts` section. This matches how A3 identifies spawn entries.

### Summary Output

After checking all spawn prompts:
- `[PASS] G2/persona-refs: All spawn prompts have valid persona references ({N} prompts checked across {M} skills)`
- Or individual FAIL/WARN lines followed by a failure count

Exit code: 0 if no FAIL (WARN is non-blocking), 1 if any FAIL.

### validate.sh Integration

Add to `scripts/validate.sh` after the existing `run_validator "split-readiness.sh"` line:

```bash
run_validator "skill-persona-refs.sh"
```

## Constraints

1. The validator is read-only — it must not modify any files
2. Single-agent skills are skipped (consistent with A3/A4/B-series)
3. The validator uses `REPO_ROOT` argument for all file paths — no hardcoded absolute paths
4. WARN is non-blocking (exit 0); only FAIL causes non-zero exit
5. All 14 multi-agent skills must pass on a clean repo — the validator enforces an existing invariant, not a new requirement
6. Runtime must stay under 5 seconds for the full suite

## Out of Scope

- Validating the Team Lead's persona read instruction in `## Setup` sections
- Enforcing that persona file `id` frontmatter matches the filename
- Linting persona file content beyond `fictional_name` extraction
- Auto-fixing missing references or name mismatches
- Updating any SKILL.md files (P2-09 already complete)

## Files to Modify

| File | Change |
|------|--------|
| `scripts/validators/skill-persona-refs.sh` | New — G2 persona reference validator (~100-150 lines) |
| `scripts/validate.sh` | Add `run_validator "skill-persona-refs.sh"` |

## Success Criteria

1. `scripts/validators/skill-persona-refs.sh` exists and is executable
2. Running `bash scripts/validate.sh` on a clean repo produces a G2 PASS line with zero failures
3. Removing a persona read instruction from any spawn prompt causes a G2 FAIL naming the skill and agent
4. Changing a persona file path to a non-existent file causes a G2 FAIL naming the missing file
5. Changing a fictional name in a spawn prompt to not match the persona file causes a G2 FAIL showing expected vs. found
6. A persona file missing the `fictional_name` field causes a G2 WARN (not FAIL)
7. Single-agent skills (setup-project, wizard-guide, tier1-test) are skipped by the validator
8. The validator checks all spawn prompts in pipeline skills (plan-product, build-product) which have multiple agents across stages
9. run-task's template prompts (which use deferred persona assignment via "read the persona file assigned by the Team Lead") are recognized as valid and do not cause failures
