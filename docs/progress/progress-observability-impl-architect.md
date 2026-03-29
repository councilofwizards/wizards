---
feature: "progress-observability"
team: "build-product"
agent: "impl-architect"
phase: "planning"
status: "complete"
last_action: "Plan approved by quality-skeptic. Ready for implementation."
updated: "2026-02-18T00:00:00Z"
---

## Progress Notes

- [00:00] Claimed task #1, read spec, all 3 SKILL.md files, validator pattern,
  validate.sh, existing checkpoint files
- [00:01] Analyzed exact text in Determine Mode and Orchestration Flow sections
  of each SKILL.md
- [00:02] Produced implementation plan with exact old_string/new_string edit
  pairs

---

# P2-03 Progress Observability -- Implementation Plan

## Overview

This plan implements the P2-03 Progress Observability spec. The changes are:

1. **Status mode** (3 SKILL.md files): Add `"status"` as a new argument mode in
   the Determine Mode section of each skill, plus update the `argument-hint`
   frontmatter
2. **End-of-session summary** (3 SKILL.md files): Add/align an end-of-session
   summary step in each skill's Orchestration Flow
3. **Checkpoint validator** (1 new script): Create
   `scripts/validators/progress-checkpoint.sh`
4. **Validation pipeline** (1 edit): Add
   `run_validator "progress-checkpoint.sh"` to `scripts/validate.sh`

Total: 10 edits across 4 existing files + 1 new file creation.

---

## Dependency Graph

```
1. scripts/validators/progress-checkpoint.sh (CREATE) -- no dependencies
2. scripts/validate.sh (EDIT) -- depends on #1
3. plan-product/SKILL.md (2 EDITs) -- no dependencies
4. build-product/SKILL.md (2 EDITs) -- no dependencies
5. review-quality/SKILL.md (2 EDITs) -- no dependencies
```

Files #1-#2 (validator) and #3-#5 (SKILL.md edits) are independent tracks that
can be done in parallel.

---

## Existing Patterns to Follow

| Pattern                           | Reference File                                  | Notes                                                                             |
| --------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------- |
| Bash validator structure          | `scripts/validators/spec-frontmatter.sh`        | `fail()`, `pass()`, `get_field()`, `field_present()`, `has_frontmatter()` helpers |
| Validator pipeline integration    | `scripts/validate.sh`                           | `run_validator "name.sh"` pattern                                                 |
| Determine Mode bullet format      | All 3 SKILL.md files                            | Bold mode name, colon, description                                                |
| Orchestration Flow numbered steps | All 3 SKILL.md files                            | `N. **Role**: Action description`                                                 |
| Checkpoint YAML frontmatter       | `docs/progress/content-dedup-impl-architect.md` | 7 fields: feature, team, agent, phase, status, last_action, updated               |
| argument-hint format              | All 3 SKILL.md frontmatter                      | Pipe-delimited options in brackets                                                |

---

## File 1: plugins/conclave/skills/plan-product/SKILL.md

### Edit 1.1 -- Update argument-hint to include "status"

**Rationale**: The `argument-hint` in frontmatter tells the user what arguments
are available. Must include `status`.

**old_string**:

```
argument-hint: "[--light] [new <idea> | review <spec-name> | reprioritize | (empty for general review)]"
```

**new_string**:

```
argument-hint: "[--light] [status | new <idea> | review <spec-name> | reprioritize | (empty for general review)]"
```

### Edit 1.2 -- Add "status" mode to Determine Mode section

**Rationale**: Add the status argument handler as the first bullet in the mode
list, before the existing empty/no args handler. The status mode is checked
first so it short-circuits before checkpoint scanning or agent spawning.

**old_string**:

```
Based on $ARGUMENTS:
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "plan-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, proceed with a general review cycle. Assess roadmap health, identify gaps, reprioritize.
- **"new [idea]"**: Research and spec a new feature.
- **"review [name]"**: Deep review of an existing spec.
- **"reprioritize"**: Full roadmap reassessment with evidence.
```

**new_string**:

```
Based on $ARGUMENTS:
- **"status"**: Read all checkpoint files for this skill and generate a consolidated status report. Do NOT spawn any agents. Read `docs/progress/` files with `team: "plan-product"` in their frontmatter, parse their YAML metadata, and output a formatted status summary. If no checkpoint files exist for this skill, report "No active or recent sessions found."
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "plan-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, proceed with a general review cycle. Assess roadmap health, identify gaps, reprioritize.
- **"new [idea]"**: Research and spec a new feature.
- **"review [name]"**: Deep review of an existing spec.
- **"reprioritize"**: Full roadmap reassessment with evidence.
```

### Edit 1.3 -- Add end-of-session summary step to Orchestration Flow

**Rationale**: Add step 8 requiring the team lead to write
`docs/progress/{feature}-summary.md` on session completion or interruption.

**old_string**:

```
7. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

## Quality Gate
```

**new_string**:

```
7. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
8. **Team Lead only**: Write end-of-session summary to `docs/progress/{feature}-summary.md` using the format from `docs/progress/_template.md`. Include: what was accomplished, what remains, blockers encountered, and whether the feature is complete or in-progress. If the session is interrupted before completion, still write a partial summary noting the interruption point.

## Quality Gate
```

---

## File 2: plugins/conclave/skills/build-product/SKILL.md

### Edit 2.1 -- Update argument-hint to include "status"

**old_string**:

```
argument-hint: "[--light] [<spec-name> | review | (empty for next item)]"
```

**new_string**:

```
argument-hint: "[--light] [status | <spec-name> | review | (empty for next item)]"
```

### Edit 2.2 -- Add "status" mode to Determine Mode section

**old_string**:

```
Based on $ARGUMENTS:
- **Empty/no args**: Scan `docs/progress/` for checkpoint files with `team: "build-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context and pick up where they left off. If no incomplete checkpoints exist, pick next ready roadmap item.
- **"[spec-name]"**: Implement the named spec.
- **"review"**: Review current implementation status and identify blockers.
```

**new_string**:

```
Based on $ARGUMENTS:
- **"status"**: Read all checkpoint files for this skill and generate a consolidated status report. Do NOT spawn any agents. Read `docs/progress/` files with `team: "build-product"` in their frontmatter, parse their YAML metadata, and output a formatted status summary. If no checkpoint files exist for this skill, report "No active or recent sessions found."
- **Empty/no args**: Scan `docs/progress/` for checkpoint files with `team: "build-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context and pick up where they left off. If no incomplete checkpoints exist, pick next ready roadmap item.
- **"[spec-name]"**: Implement the named spec.
- **"review"**: Review current implementation status and identify blockers.
```

### Edit 2.3 -- Align existing summary step wording in Orchestration Flow

**Rationale**: build-product already has a summary step (step 7), but its
wording doesn't mention the template or interruption handling. Align with the
standardized convention from the spec.

**old_string**:

```
7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md`
8. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
```

**new_string**:

```
7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md` using the format from `docs/progress/_template.md`. Include: what was accomplished, what remains, blockers encountered, and whether the feature is complete or in-progress. If the session is interrupted before completion, still write a partial summary noting the interruption point.
8. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
```

---

## File 3: plugins/conclave/skills/review-quality/SKILL.md

### Edit 3.1 -- Update argument-hint to include "status"

**old_string**:

```
argument-hint: "[--light] [security <scope> | performance <scope> | deploy <feature> | regression]"
```

**new_string**:

```
argument-hint: "[--light] [status | security <scope> | performance <scope> | deploy <feature> | regression]"
```

### Edit 3.2 -- Add "status" mode to Determine Mode section

**old_string**:

```
Based on $ARGUMENTS:
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "review-quality"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, perform a general quality assessment of the most recently implemented feature. Spawn test-eng + ops-skeptic. Check `docs/progress/` for the latest completed implementation.
- **"security [scope]"**: Security audit of a feature or module. Spawn security-auditor + ops-skeptic.
- **"performance [scope]"**: Performance analysis and load testing plan. Spawn test-eng + ops-skeptic.
- **"deploy [feature]"**: Deployment readiness check. Spawn devops-eng + security-auditor + ops-skeptic.
- **"regression"**: Full regression test sweep. Spawn test-eng + ops-skeptic.
```

**new_string**:

```
Based on $ARGUMENTS:
- **"status"**: Read all checkpoint files for this skill and generate a consolidated status report. Do NOT spawn any agents. Read `docs/progress/` files with `team: "review-quality"` in their frontmatter, parse their YAML metadata, and output a formatted status summary. If no checkpoint files exist for this skill, report "No active or recent sessions found."
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "review-quality"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, perform a general quality assessment of the most recently implemented feature. Spawn test-eng + ops-skeptic. Check `docs/progress/` for the latest completed implementation.
- **"security [scope]"**: Security audit of a feature or module. Spawn security-auditor + ops-skeptic.
- **"performance [scope]"**: Performance analysis and load testing plan. Spawn test-eng + ops-skeptic.
- **"deploy [feature]"**: Deployment readiness check. Spawn devops-eng + security-auditor + ops-skeptic.
- **"regression"**: Full regression test sweep. Spawn test-eng + ops-skeptic.
```

### Edit 3.3 -- Add end-of-session summary step to Orchestration Flow

**Rationale**: review-quality step 7 writes `{feature}-quality.md` (a quality
report, not a session summary). Keep that step and add step 9 for the session
summary.

**old_string**:

```
8. **QA Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
```

**new_string**:

```
8. **QA Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
9. **QA Lead only**: Write end-of-session summary to `docs/progress/{feature}-summary.md` using the format from `docs/progress/_template.md`. Include: what was accomplished, what remains, blockers encountered, and whether the feature is complete or in-progress. If the session is interrupted before completion, still write a partial summary noting the interruption point.
```

---

## File 4: scripts/validators/progress-checkpoint.sh (NEW)

Create this file with the following content. Follows the pattern established by
`scripts/validators/spec-frontmatter.sh`.

```bash
#!/usr/bin/env bash
# Category E: Progress checkpoint file frontmatter validation.
# Validates that checkpoint files in docs/progress/ with a "team" field
# have all required checkpoint fields per the Checkpoint Protocol.
# Usage: bash scripts/validators/progress-checkpoint.sh <repo-root>
set -uo pipefail

REPO_ROOT="${1:?Usage: $0 <repo-root>}"
PROGRESS_DIR="$REPO_ROOT/docs/progress"

passed=0
failed=0

fail() {
    local check_id="$1" what_failed="$2" file="$3" expected="$4" found="$5" fix="$6"
    echo "[FAIL] $check_id: $what_failed"
    echo "  File: $file"
    echo "  Expected: $expected"
    echo "  Found: $found"
    echo "  Fix: $fix"
    failed=$((failed + 1))
}

pass() {
    local check_id="$1" msg="$2"
    echo "[PASS] $check_id: $msg"
    passed=$((passed + 1))
}

# Extract a frontmatter field value (returns empty string if field absent or empty)
get_field() {
    local file="$1" field="$2"
    awk '/^---$/{if(fm==1){exit} fm=1; next} fm==1{print}' "$file" \
        | grep -E "^${field}:" \
        | head -1 \
        | sed "s/^${field}:[[:space:]]*//" \
        | sed 's/^"//' | sed 's/"$//' \
        | sed "s/^'//" | sed "s/'$//"
}

# Check if frontmatter block exists (file starts with --- and has closing ---)
has_frontmatter() {
    local file="$1"
    local first_line
    first_line=$(head -1 "$file")
    if [ "$first_line" != "---" ]; then
        return 1
    fi
    awk 'NR>1 && /^---$/{found=1; exit} END{exit !found}' "$file"
}

VALID_TEAMS="plan-product build-product review-quality"
VALID_STATUSES="in_progress blocked awaiting_review complete"

total_files=0
e1_fails=0

if [ ! -d "$PROGRESS_DIR" ]; then
    pass "E/no-dir" "No docs/progress/ directory found (skipping)"
    echo ""
    echo "Progress checkpoint validation: $passed passed, $failed failed"
    exit 0
fi

while IFS= read -r file; do
    [ -z "$file" ] && continue

    # Skip template, summary, and cost-summary files
    basename_file=$(basename "$file")
    case "$basename_file" in
        _template.md|*-summary.md|*-cost-summary.md)
            continue
            ;;
    esac

    # Skip files without frontmatter
    has_frontmatter "$file" || continue

    # Skip files without a "team" field (not checkpoint files)
    team=$(get_field "$file" "team")
    [ -z "$team" ] && continue

    # This is a checkpoint file -- validate it
    total_files=$((total_files + 1))
    rel_file="${file#"$REPO_ROOT/"}"
    file_ok=true

    # Validate team value
    valid_team=false
    for t in $VALID_TEAMS; do
        [ "$team" = "$t" ] && valid_team=true && break
    done
    if ! $valid_team; then
        fail "E1/team" "Invalid team value \"$team\"" \
            "$rel_file" \
            "One of: $VALID_TEAMS" \
            "\"$team\"" \
            "Change team to one of the valid values: plan-product | build-product | review-quality"
        file_ok=false
    fi

    # feature
    feature=$(get_field "$file" "feature")
    if [ -z "$feature" ]; then
        fail "E1/feature" "Missing or empty required field \"feature\"" \
            "$rel_file" \
            "Non-empty feature field in frontmatter" \
            "Field \"feature\" is absent or empty" \
            "Add a non-empty feature field: feature: \"feature-name\""
        file_ok=false
    fi

    # agent
    agent=$(get_field "$file" "agent")
    if [ -z "$agent" ]; then
        fail "E1/agent" "Missing or empty required field \"agent\"" \
            "$rel_file" \
            "Non-empty agent field in frontmatter" \
            "Field \"agent\" is absent or empty" \
            "Add a non-empty agent field: agent: \"role-name\""
        file_ok=false
    fi

    # phase
    phase=$(get_field "$file" "phase")
    if [ -z "$phase" ]; then
        fail "E1/phase" "Missing or empty required field \"phase\"" \
            "$rel_file" \
            "Non-empty phase field in frontmatter" \
            "Field \"phase\" is absent or empty" \
            "Add a non-empty phase field: phase: \"current-phase\""
        file_ok=false
    fi

    # status
    status=$(get_field "$file" "status")
    if [ -z "$status" ]; then
        fail "E1/status" "Missing or empty required field \"status\"" \
            "$rel_file" \
            "status field with one of: $VALID_STATUSES" \
            "Field \"status\" is absent or empty" \
            "Add status field with a valid value: in_progress | blocked | awaiting_review | complete"
        file_ok=false
    else
        valid_status=false
        for s in $VALID_STATUSES; do
            [ "$status" = "$s" ] && valid_status=true && break
        done
        if ! $valid_status; then
            fail "E1/status" "Invalid status value \"$status\"" \
                "$rel_file" \
                "One of: $VALID_STATUSES" \
                "\"$status\"" \
                "Change status to one of the valid values: in_progress | blocked | awaiting_review | complete"
            file_ok=false
        fi
    fi

    # last_action
    last_action=$(get_field "$file" "last_action")
    if [ -z "$last_action" ]; then
        fail "E1/last_action" "Missing or empty required field \"last_action\"" \
            "$rel_file" \
            "Non-empty last_action field in frontmatter" \
            "Field \"last_action\" is absent or empty" \
            "Add a non-empty last_action field: last_action: \"Brief description\""
        file_ok=false
    fi

    # updated
    updated=$(get_field "$file" "updated")
    if [ -z "$updated" ]; then
        fail "E1/updated" "Missing or empty required field \"updated\"" \
            "$rel_file" \
            "Non-empty updated field in frontmatter" \
            "Field \"updated\" is absent or empty" \
            "Add a non-empty updated field: updated: \"ISO-8601 timestamp\""
        file_ok=false
    fi

    $file_ok || e1_fails=$((e1_fails + 1))

done < <(find "$PROGRESS_DIR" -maxdepth 1 -name "*.md" -type f | sort)

if [ "$total_files" -eq 0 ]; then
    pass "E/no-files" "No checkpoint files found to validate (skipping)"
else
    [ "$e1_fails" -eq 0 ] && pass "E1/required-fields" "All checkpoint files have valid required frontmatter fields ($total_files files checked)"
fi

echo ""
echo "Progress checkpoint validation: $passed passed, $failed failed"
[ "$failed" -eq 0 ]
exit $?
```

---

## File 5: scripts/validate.sh

### Edit 5.1 -- Add progress-checkpoint validator to pipeline

**Rationale**: Integrate the new Category E validator into the existing
validation pipeline.

**old_string**:

```
run_validator "spec-frontmatter.sh"
```

**new_string**:

```
run_validator "spec-frontmatter.sh"
run_validator "progress-checkpoint.sh"
```

---

## Status Report Format

The spec defines the status report format in Section 2. For reference, the team
lead should output this format when the `status` mode is triggered:

```
## Status Report: {feature-name}

**Skill**: {skill-name}
**Last updated**: {most recent checkpoint timestamp}

### Agent Status

| Agent | Phase | Status | Last Action | Updated |
|-------|-------|--------|-------------|---------|
| {agent} | {phase} | {status} | {last_action} | {updated} |
| ... | ... | ... | ... | ... |

### Summary

- **Active agents**: {count with status in_progress}
- **Blocked agents**: {count with status blocked}
- **Completed agents**: {count with status complete}
- **Awaiting review**: {count with status awaiting_review}

### Blockers

{If any agent has status "blocked", list their agent name and last_action. Otherwise: "None."}
```

This format is specified by the SKILL.md status mode bullet text. The team lead
reads checkpoint files, parses frontmatter, and renders this format. No
additional SKILL.md text is needed beyond the status mode bullet -- the team
lead generates the report format from the instructions in the bullet.

---

## Edit Execution Order

Edits can be applied in any order WITHIN a file. Edits across files are
independent.

**plan-product/SKILL.md** (3 edits):

1. Edit 1.1 (argument-hint update)
2. Edit 1.2 (status mode in Determine Mode)
3. Edit 1.3 (end-of-session summary step)

**build-product/SKILL.md** (3 edits):

1. Edit 2.1 (argument-hint update)
2. Edit 2.2 (status mode in Determine Mode)
3. Edit 2.3 (align summary step wording)

**review-quality/SKILL.md** (3 edits):

1. Edit 3.1 (argument-hint update)
2. Edit 3.2 (status mode in Determine Mode)
3. Edit 3.3 (end-of-session summary step)

**scripts/validators/progress-checkpoint.sh** (1 creation):

1. Create file with full script content

**scripts/validate.sh** (1 edit):

1. Edit 5.1 (add run_validator line)

Total: 10 edits + 1 file creation across 5 files.

---

## Integration Test Strategy

### Manual Verification

1. **Status mode invocation**: Invoke `/plan-product status`,
   `/build-product status`, `/review-quality status` and verify each produces a
   status report without spawning agents
2. **Empty state**: Clear checkpoint files for a skill and verify "No active or
   recent sessions found."
3. **Backward compatibility**: Verify status command works with existing
   checkpoint files (e.g., `content-dedup-impl-architect.md`)

### Automated Validation

1. **Validator on existing checkpoint files**: Run
   `bash scripts/validators/progress-checkpoint.sh <repo-root>` -- should pass
   on existing well-formed checkpoints
2. **Validator on malformed checkpoint**: Create a test checkpoint with missing
   `status` field and verify `[FAIL]` output
3. **Full pipeline**: Run `bash scripts/validate.sh` -- should include
   progress-checkpoint validation in output
4. **Argument-hint validation**: Existing `skill-structure.sh` validator should
   still pass after argument-hint changes

### Success Criteria Mapping

| Spec Criterion                | Implementation                                                                              |
| ----------------------------- | ------------------------------------------------------------------------------------------- |
| 1-3. Status command per skill | Edits 1.2, 2.2, 3.2 (status mode bullets)                                                   |
| 4. Agent status table         | Status report format (team lead renders from checkpoint data)                               |
| 5. Summary counts             | Status report format (Summary section)                                                      |
| 6. Blockers section           | Status report format (Blockers section)                                                     |
| 7. No checkpoints message     | Status mode bullet text: "If no checkpoint files exist..."                                  |
| 8. Raw phase values           | Status mode bullet: no normalization mentioned                                              |
| 9. Session summary step       | Edits 1.3, 2.3, 3.3                                                                         |
| 10. Template format           | Summary step text: "using the format from `docs/progress/_template.md`"                     |
| 11. Validator in pipeline     | File 4 (script) + Edit 5.1 (pipeline integration)                                           |
| 12. Backward compatibility    | Validator handles existing files; status mode reads any checkpoint with matching team field |
