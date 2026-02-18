#!/usr/bin/env bash
# Category D: Spec file frontmatter validation per docs/specs/_template.md schema.
# Usage: bash scripts/validators/spec-frontmatter.sh <repo-root>
set -uo pipefail

REPO_ROOT="${1:?Usage: $0 <repo-root>}"
SPECS_DIR="$REPO_ROOT/docs/specs"

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

# Check whether a field key is present in frontmatter (even if value is empty)
field_present() {
    local file="$1" field="$2"
    awk '/^---$/{if(fm==1){exit} fm=1; next} fm==1{print}' "$file" \
        | grep -qE "^${field}:"
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

VALID_STATUSES="draft ready_for_review approved ready_for_implementation"

total_files=0
d1_fails=0

while IFS= read -r file; do
    [ -z "$file" ] && continue
    total_files=$((total_files + 1))

    rel_file="${file#"$REPO_ROOT/"}"
    file_ok=true

    # Check frontmatter exists first
    if ! has_frontmatter "$file"; then
        fail "D1/frontmatter" "Missing YAML frontmatter block" \
            "$rel_file" \
            "File starts with --- and contains a closing ---" \
            "File does not start with --- or has no closing ---" \
            "Add YAML frontmatter block (--- ... ---) at the top of the file per docs/specs/_template.md"
        d1_fails=$((d1_fails + 1))
        continue
    fi

    # title
    title=$(get_field "$file" "title")
    if [ -z "$title" ]; then
        fail "D1/title" "Missing or empty required field \"title\"" \
            "$rel_file" \
            "Non-empty title field in frontmatter" \
            "Field \"title\" is absent or empty" \
            "Add a non-empty title field: title: \"Your Spec Title\""
        file_ok=false
    fi

    # status
    status=$(get_field "$file" "status")
    if [ -z "$status" ]; then
        fail "D1/status" "Missing required field \"status\"" \
            "$rel_file" \
            "status field with one of: $VALID_STATUSES" \
            "Field \"status\" is absent or empty" \
            "Add status field with a valid value: draft | ready_for_review | approved | ready_for_implementation"
        file_ok=false
    else
        valid=false
        for s in $VALID_STATUSES; do
            [ "$status" = "$s" ] && valid=true && break
        done
        if ! $valid; then
            fail "D1/status" "Invalid status value \"$status\"" \
                "$rel_file" \
                "One of: $VALID_STATUSES" \
                "\"$status\"" \
                "Change status to one of the valid values: draft | ready_for_review | approved | ready_for_implementation"
            file_ok=false
        fi
    fi

    # priority
    priority=$(get_field "$file" "priority")
    if [ -z "$priority" ]; then
        fail "D1/priority" "Missing required field \"priority\"" \
            "$rel_file" \
            "priority field matching pattern P[1-3]" \
            "Field \"priority\" is absent or empty" \
            "Add priority field with value P1, P2, or P3"
        file_ok=false
    elif ! echo "$priority" | grep -qE '^P[1-3]$'; then
        fail "D1/priority" "Invalid priority value \"$priority\"" \
            "$rel_file" \
            "Pattern P[1-3] (e.g., P1, P2, P3)" \
            "\"$priority\"" \
            "Change priority to P1, P2, or P3"
        file_ok=false
    fi

    # category
    category=$(get_field "$file" "category")
    if [ -z "$category" ]; then
        fail "D1/category" "Missing or empty required field \"category\"" \
            "$rel_file" \
            "Non-empty category field in frontmatter" \
            "Field \"category\" is absent or empty" \
            "Add a non-empty category field (e.g., core-framework, quality-reliability, developer-experience)"
        file_ok=false
    fi

    # approved_by (must be present; may be empty string for drafts)
    if ! field_present "$file" "approved_by"; then
        fail "D1/approved_by" "Missing required field \"approved_by\"" \
            "$rel_file" \
            "approved_by field present (may be empty string for drafts)" \
            "Field \"approved_by\" is absent" \
            "Add approved_by field: approved_by: \"\" (empty for drafts) or approved_by: \"agent-name\""
        file_ok=false
    fi

    # created date
    created=$(get_field "$file" "created")
    if [ -z "$created" ]; then
        fail "D1/created" "Missing required field \"created\"" \
            "$rel_file" \
            "created field matching pattern YYYY-MM-DD" \
            "Field \"created\" is absent or empty" \
            "Add created field with a date: created: \"YYYY-MM-DD\""
        file_ok=false
    elif ! echo "$created" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        fail "D1/created" "Invalid created date format \"$created\"" \
            "$rel_file" \
            "Pattern YYYY-MM-DD (e.g., 2026-02-18)" \
            "\"$created\"" \
            "Change created to ISO date format: YYYY-MM-DD"
        file_ok=false
    fi

    # updated date
    updated=$(get_field "$file" "updated")
    if [ -z "$updated" ]; then
        fail "D1/updated" "Missing required field \"updated\"" \
            "$rel_file" \
            "updated field matching pattern YYYY-MM-DD" \
            "Field \"updated\" is absent or empty" \
            "Add updated field with a date: updated: \"YYYY-MM-DD\""
        file_ok=false
    elif ! echo "$updated" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        fail "D1/updated" "Invalid updated date format \"$updated\"" \
            "$rel_file" \
            "Pattern YYYY-MM-DD (e.g., 2026-02-18)" \
            "\"$updated\"" \
            "Change updated to ISO date format: YYYY-MM-DD"
        file_ok=false
    fi

    $file_ok || d1_fails=$((d1_fails + 1))

done < <(find "$SPECS_DIR" -mindepth 2 -maxdepth 2 -name "spec.md" -type f | sort)

if [ "$total_files" -eq 0 ]; then
    pass "D/no-files" "No spec files found to validate (skipping)"
else
    [ "$d1_fails" -eq 0 ] && pass "D1/required-fields" "All spec files have valid required frontmatter fields ($total_files files checked)"
fi

echo ""
echo "Spec frontmatter validation: $passed passed, $failed failed"
[ "$failed" -eq 0 ]
exit $?
