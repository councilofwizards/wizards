#!/usr/bin/env bash
# Category C: Roadmap file frontmatter validation per ADR-001 schema.
# Usage: bash scripts/validators/roadmap-frontmatter.sh <repo-root>
set -uo pipefail

REPO_ROOT="${1:?Usage: $0 <repo-root>}"
ROADMAP_DIR="$REPO_ROOT/docs/roadmap"

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

VALID_STATUSES="not_started spec_in_progress ready impl_in_progress complete blocked"
VALID_EFFORTS="small medium large"
VALID_IMPACTS="low medium high"

total_files=0
c1_fails=0
c2_fails=0

while IFS= read -r file; do
    [ -z "$file" ] && continue
    total_files=$((total_files + 1))

    rel_file="${file#"$REPO_ROOT/"}"
    filename=$(basename "$file")

    # --- C1: Required Fields ---

    if ! has_frontmatter "$file"; then
        fail "C1/frontmatter" "Missing YAML frontmatter block" \
            "$rel_file" \
            "File starts with --- and contains a closing ---" \
            "File does not start with --- or has no closing ---" \
            "Add YAML frontmatter block (--- ... ---) at the top of the file"
        c1_fails=$((c1_fails + 1))
        c2_fails=$((c2_fails + 1))
        continue
    fi

    file_ok=true

    # title
    title=$(get_field "$file" "title")
    if [ -z "$title" ]; then
        fail "C1/title" "Missing or empty required field \"title\"" \
            "$rel_file" \
            "Non-empty title field in frontmatter" \
            "Field \"title\" is absent or empty" \
            "Add a non-empty title field: title: \"Your Feature Name\""
        file_ok=false
    fi

    # status
    status=$(get_field "$file" "status")
    if [ -z "$status" ]; then
        fail "C1/status" "Missing required field \"status\"" \
            "$rel_file" \
            "status field with one of: $VALID_STATUSES" \
            "Field \"status\" is absent or empty" \
            "Add status field with a valid value: not_started | spec_in_progress | ready | impl_in_progress | complete | blocked"
        file_ok=false
    else
        valid=false
        for s in $VALID_STATUSES; do
            [ "$status" = "$s" ] && valid=true && break
        done
        if ! $valid; then
            fail "C1/status" "Invalid status value \"$status\"" \
                "$rel_file" \
                "One of: $VALID_STATUSES" \
                "\"$status\"" \
                "Change status to one of the valid values: not_started | spec_in_progress | ready | impl_in_progress | complete | blocked"
            file_ok=false
        fi
    fi

    # priority
    priority=$(get_field "$file" "priority")
    if [ -z "$priority" ]; then
        fail "C1/priority" "Missing required field \"priority\"" \
            "$rel_file" \
            "priority field matching pattern P[1-3]" \
            "Field \"priority\" is absent or empty" \
            "Add priority field with value P1, P2, or P3"
        file_ok=false
    elif ! echo "$priority" | grep -qE '^P[1-3]$'; then
        fail "C1/priority" "Invalid priority value \"$priority\"" \
            "$rel_file" \
            "Pattern P[1-3] (e.g., P1, P2, P3)" \
            "\"$priority\"" \
            "Change priority to P1, P2, or P3"
        file_ok=false
    fi

    # category
    category=$(get_field "$file" "category")
    if [ -z "$category" ]; then
        fail "C1/category" "Missing or empty required field \"category\"" \
            "$rel_file" \
            "Non-empty category field in frontmatter" \
            "Field \"category\" is absent or empty" \
            "Add a non-empty category field (e.g., core-framework, quality-reliability, developer-experience)"
        file_ok=false
    fi

    # effort
    effort=$(get_field "$file" "effort")
    if [ -z "$effort" ]; then
        fail "C1/effort" "Missing required field \"effort\"" \
            "$rel_file" \
            "effort field with one of: $VALID_EFFORTS" \
            "Field \"effort\" is absent or empty" \
            "Add effort field with value: small | medium | large"
        file_ok=false
    else
        valid=false
        for e in $VALID_EFFORTS; do
            [ "$effort" = "$e" ] && valid=true && break
        done
        if ! $valid; then
            fail "C1/effort" "Invalid effort value \"$effort\"" \
                "$rel_file" \
                "One of: $VALID_EFFORTS" \
                "\"$effort\"" \
                "Change effort to: small | medium | large"
            file_ok=false
        fi
    fi

    # impact
    impact=$(get_field "$file" "impact")
    if [ -z "$impact" ]; then
        fail "C1/impact" "Missing required field \"impact\"" \
            "$rel_file" \
            "impact field with one of: $VALID_IMPACTS" \
            "Field \"impact\" is absent or empty" \
            "Add impact field with value: low | medium | high"
        file_ok=false
    else
        valid=false
        for i in $VALID_IMPACTS; do
            [ "$impact" = "$i" ] && valid=true && break
        done
        if ! $valid; then
            fail "C1/impact" "Invalid impact value \"$impact\"" \
                "$rel_file" \
                "One of: $VALID_IMPACTS" \
                "\"$impact\"" \
                "Change impact to: low | medium | high"
            file_ok=false
        fi
    fi

    # dependencies (must be present; may be empty array [])
    if ! field_present "$file" "dependencies"; then
        fail "C1/dependencies" "Missing required field \"dependencies\"" \
            "$rel_file" \
            "dependencies field present (may be empty array [])" \
            "Field \"dependencies\" is absent" \
            "Add dependencies field: dependencies: [] (or list of slug strings)"
        file_ok=false
    fi

    # created date
    created=$(get_field "$file" "created")
    if [ -z "$created" ]; then
        fail "C1/created" "Missing required field \"created\"" \
            "$rel_file" \
            "created field matching pattern YYYY-MM-DD" \
            "Field \"created\" is absent or empty" \
            "Add created field with a date: created: \"YYYY-MM-DD\""
        file_ok=false
    elif ! echo "$created" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        fail "C1/created" "Invalid created date format \"$created\"" \
            "$rel_file" \
            "Pattern YYYY-MM-DD (e.g., 2026-02-18)" \
            "\"$created\"" \
            "Change created to ISO date format: YYYY-MM-DD"
        file_ok=false
    fi

    # updated date
    updated=$(get_field "$file" "updated")
    if [ -z "$updated" ]; then
        fail "C1/updated" "Missing required field \"updated\"" \
            "$rel_file" \
            "updated field matching pattern YYYY-MM-DD" \
            "Field \"updated\" is absent or empty" \
            "Add updated field with a date: updated: \"YYYY-MM-DD\""
        file_ok=false
    elif ! echo "$updated" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
        fail "C1/updated" "Invalid updated date format \"$updated\"" \
            "$rel_file" \
            "Pattern YYYY-MM-DD (e.g., 2026-02-18)" \
            "\"$updated\"" \
            "Change updated to ISO date format: YYYY-MM-DD"
        file_ok=false
    fi

    $file_ok || c1_fails=$((c1_fails + 1))

    # --- C2: Filename Convention ---
    filename_ok=true

    if ! echo "$filename" | grep -qE '^P[1-3]-[0-9]{2}-.+\.md$'; then
        fail "C2/filename" "Filename does not match required pattern" \
            "$rel_file" \
            "Pattern P[1-3]-[0-9][0-9]-<slug>.md (e.g., P2-04-automated-testing.md)" \
            "Filename: \"$filename\"" \
            "Rename file to match pattern: P{priority}-{NN}-{slug}.md"
        filename_ok=false
    else
        # Check priority in filename matches priority in frontmatter
        file_priority=$(echo "$filename" | sed 's/^\(P[1-3]\)-.*/\1/')
        fm_priority=$(get_field "$file" "priority")
        if [ -n "$fm_priority" ] && [ "$file_priority" != "$fm_priority" ]; then
            fail "C2/priority-match" "Priority in filename does not match frontmatter priority field" \
                "$rel_file" \
                "Filename priority \"$file_priority\" matches frontmatter priority \"$fm_priority\"" \
                "Filename priority: \"$file_priority\", frontmatter priority: \"$fm_priority\"" \
                "Either rename the file to match the frontmatter priority, or update the frontmatter priority field"
            filename_ok=false
        fi
    fi

    $filename_ok || c2_fails=$((c2_fails + 1))

done < <(find "$ROADMAP_DIR" -maxdepth 1 -name "*.md" ! -name "_index.md" -type f | sort)

if [ "$total_files" -eq 0 ]; then
    pass "C/no-files" "No roadmap files found to validate (skipping)"
else
    [ "$c1_fails" -eq 0 ] && pass "C1/required-fields" "All roadmap files have valid required frontmatter fields ($total_files files checked)"
    [ "$c2_fails" -eq 0 ] && pass "C2/filename-convention" "All roadmap filenames match required pattern and priority ($total_files files checked)"
fi

echo ""
echo "Roadmap frontmatter validation: $passed passed, $failed failed"
[ "$failed" -eq 0 ]
exit $?
