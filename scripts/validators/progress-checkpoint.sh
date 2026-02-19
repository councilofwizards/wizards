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

# Dynamically derive valid teams from skill directory names
# Each skill directory under plugins/*/skills/ is a valid team name
VALID_TEAMS=""
while IFS= read -r -d '' skill_dir; do
    team_name="$(basename "$skill_dir")"
    VALID_TEAMS="$VALID_TEAMS $team_name"
done < <(find "$REPO_ROOT/plugins" -mindepth 3 -maxdepth 3 -type d -path "*/skills/*" -print0 2>/dev/null | sort -z)
VALID_TEAMS="${VALID_TEAMS# }"  # trim leading space
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
            "Change team to one of the valid values: $(echo "$VALID_TEAMS" | sed 's/ / | /g')"
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
