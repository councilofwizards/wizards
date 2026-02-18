#!/usr/bin/env bash
# Category A: SKILL.md structural validation
# Usage: skill-structure.sh <repo_root>
set -euo pipefail

REPO_ROOT="${1:?REPO_ROOT argument required}"

passed=0
failed=0

# A1: YAML Frontmatter
a1_pass=0
a1_fail=0

# A2: Required Sections
a2_pass=0
a2_fail=0

# A3: Spawn Definitions
a3_pass=0
a3_fail=0

# A4: Shared Content Markers
a4_pass=0
a4_fail=0

skill_files=()
while IFS= read -r -d '' f; do
    skill_files+=("$f")
done < <(find "$REPO_ROOT/plugins" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

if [ "${#skill_files[@]}" -eq 0 ]; then
    echo "[FAIL] A1/frontmatter: No SKILL.md files found"
    echo "  File: $REPO_ROOT/plugins"
    echo "  Expected: At least one file matching plugins/*/skills/*/SKILL.md"
    echo "  Found: No matching files"
    echo "  Fix: Ensure plugin skill files exist at plugins/<plugin>/skills/<skill>/SKILL.md"
    exit 1
fi

for filepath in "${skill_files[@]}"; do
    # Derive skill name from parent directory
    skill_dir="$(basename "$(dirname "$filepath")")"

    # -------------------------------------------------------------------------
    # A1: YAML Frontmatter
    # -------------------------------------------------------------------------
    line1="$(sed -n '1p' "$filepath")"
    if [ "$line1" != "---" ]; then
        echo "[FAIL] A1/frontmatter: File does not start with YAML frontmatter delimiter"
        echo "  File: $filepath"
        echo "  Expected: Line 1 is \"---\""
        echo "  Found: \"$line1\""
        echo "  Fix: Add \"---\" as the very first line of the file to open YAML frontmatter"
        a1_fail=$((a1_fail + 1))
        continue
    fi

    # Find the closing --- (second occurrence)
    fm_end=0
    while IFS= read -r line; do
        lineno="${line%%	*}"
        content="${line#*	}"
        if [ "$lineno" -gt 1 ] && [ "$content" = "---" ]; then
            fm_end="$lineno"
            break
        fi
    done < <(grep -n "^---$" "$filepath" | awk -F: '{print $1"\t"$2}')

    if [ "$fm_end" -eq 0 ]; then
        echo "[FAIL] A1/frontmatter: YAML frontmatter block is not closed"
        echo "  File: $filepath"
        echo "  Expected: A second \"---\" line closing the frontmatter block"
        echo "  Found: No closing \"---\" after line 1"
        echo "  Fix: Add a closing \"---\" line after the YAML frontmatter fields"
        a1_fail=$((a1_fail + 1))
        continue
    fi

    # Extract frontmatter content (lines 2 to fm_end-1)
    fm_content="$(sed -n "2,$((fm_end - 1))p" "$filepath")"

    # Check required fields: name, description, argument-hint
    for field in name description argument-hint; do
        if ! printf '%s\n' "$fm_content" | grep -q "^${field}:"; then
            echo "[FAIL] A1/frontmatter: Missing required field \"$field\""
            echo "  File: $filepath"
            echo "  Expected: YAML frontmatter contains \"$field\" field"
            echo "  Found: Field not present in frontmatter block (lines 1-$fm_end)"
            echo "  Fix: Add \"$field:\" field to the YAML frontmatter"
            a1_fail=$((a1_fail + 1))
        fi
    done

    # Check name value matches parent directory
    name_value="$(printf '%s\n' "$fm_content" | grep "^name:" | head -1 | sed 's/^name:[[:space:]]*//')"
    if [ -n "$name_value" ] && [ "$name_value" != "$skill_dir" ]; then
        echo "[FAIL] A1/frontmatter: \"name\" field value does not match parent directory"
        echo "  File: $filepath"
        echo "  Expected: name: $skill_dir"
        echo "  Found: name: $name_value"
        echo "  Fix: Change the \"name\" field value to \"$skill_dir\" to match the parent directory name"
        a1_fail=$((a1_fail + 1))
    fi

    # Track A1 pass for this file if no failures added
    a1_pass=$((a1_pass + 1))

    # -------------------------------------------------------------------------
    # A2: Required Sections
    # -------------------------------------------------------------------------
    file_content="$(cat "$filepath")"
    a2_file_fail=0

    # Required exact-match sections
    required_sections=(
        "## Setup"
        "## Write Safety"
        "## Checkpoint Protocol"
        "## Determine Mode"
        "## Lightweight Mode"
        "## Spawn the Team"
        "## Orchestration Flow"
        "## Failure Recovery"
        "## Shared Principles"
        "## Communication Protocol"
    )

    for section in "${required_sections[@]}"; do
        if ! printf '%s\n' "$file_content" | grep -qF "$section"; then
            echo "[FAIL] A2/required-sections: Missing required section"
            echo "  File: $filepath"
            echo "  Expected: Section heading \"$section\" present in file"
            echo "  Found: Section heading not found"
            echo "  Fix: Add \"$section\" heading to the file"
            a2_fail=$((a2_fail + 1))
            a2_file_fail=$((a2_file_fail + 1))
        fi
    done

    # At least one of: ## Critical Rules OR ## Quality Gate
    if ! printf '%s\n' "$file_content" | grep -qF "## Critical Rules" && \
       ! printf '%s\n' "$file_content" | grep -qF "## Quality Gate"; then
        echo "[FAIL] A2/required-sections: Missing required section (need at least one)"
        echo "  File: $filepath"
        echo "  Expected: At least one of \"## Critical Rules\" or \"## Quality Gate\""
        echo "  Found: Neither section heading present in file"
        echo "  Fix: Add either \"## Critical Rules\" or \"## Quality Gate\" section to the file"
        a2_fail=$((a2_fail + 1))
        a2_file_fail=$((a2_file_fail + 1))
    fi

    # At least one of: ## Teammate Spawn Prompts OR ## Teammates to Spawn
    if ! printf '%s\n' "$file_content" | grep -qF "## Teammate Spawn Prompts" && \
       ! printf '%s\n' "$file_content" | grep -qF "## Teammates to Spawn"; then
        echo "[FAIL] A2/required-sections: Missing required section (need at least one)"
        echo "  File: $filepath"
        echo "  Expected: At least one of \"## Teammate Spawn Prompts\" or \"## Teammates to Spawn\""
        echo "  Found: Neither section heading present in file"
        echo "  Fix: Add either \"## Teammate Spawn Prompts\" or \"## Teammates to Spawn\" section to the file"
        a2_fail=$((a2_fail + 1))
        a2_file_fail=$((a2_file_fail + 1))
    fi

    if [ "$a2_file_fail" -eq 0 ]; then
        a2_pass=$((a2_pass + 1))
    fi

    # -------------------------------------------------------------------------
    # A3: Spawn Definitions (H3 entries under ## Spawn the Team)
    # -------------------------------------------------------------------------
    # Extract the Spawn the Team section: from "## Spawn the Team" to next "## "
    spawn_section="$(awk '/^## Spawn the Team/{found=1; next} found && /^## /{exit} found{print}' "$filepath")"

    if [ -z "$spawn_section" ]; then
        # No spawn section content — already caught by A2 if heading missing
        a3_pass=$((a3_pass + 1))
    else
        a3_file_fail=0
        current_h3=""
        has_name=0
        has_model=0
        has_subagent=0

        _spawn_fail_count=0
        check_spawn_entry() {
            local h3="$1" hname="$2" hmodel="$3" hsubagent="$4" fpath="$5"
            _spawn_fail_count=0
            if [ "$hname" -eq 0 ]; then
                echo "[FAIL] A3/spawn-definitions: Spawn entry missing \"**Name**:\" field"
                echo "  File: $fpath"
                echo "  Expected: H3 entry \"$h3\" contains a \"**Name**:\" field with backtick-quoted agent name"
                echo "  Found: No \"**Name**:\" field in spawn entry"
                echo "  Fix: Add \"- **Name**: \`agent-name\`\" to the spawn entry"
                _spawn_fail_count=$((_spawn_fail_count + 1))
            fi
            if [ "$hmodel" -eq 0 ]; then
                echo "[FAIL] A3/spawn-definitions: Spawn entry missing \"**Model**:\" field"
                echo "  File: $fpath"
                echo "  Expected: H3 entry \"$h3\" contains a \"**Model**:\" field with value \"opus\" or \"sonnet\""
                echo "  Found: No \"**Model**:\" field in spawn entry"
                echo "  Fix: Add \"- **Model**: opus\" or \"- **Model**: sonnet\" to the spawn entry"
                _spawn_fail_count=$((_spawn_fail_count + 1))
            fi
            if [ "$hsubagent" -eq 0 ]; then
                echo "[FAIL] A3/spawn-definitions: Spawn entry missing \"**Subagent type**:\" field"
                echo "  File: $fpath"
                echo "  Expected: H3 entry \"$h3\" contains a \"**Subagent type**:\" field"
                echo "  Found: No \"**Subagent type**:\" field in spawn entry"
                echo "  Fix: Add \"- **Subagent type**: general-purpose\" to the spawn entry"
                _spawn_fail_count=$((_spawn_fail_count + 1))
            fi
        }

        while IFS= read -r line; do
            if printf '%s\n' "$line" | grep -q "^### "; then
                # Check previous H3 entry if any
                if [ -n "$current_h3" ]; then
                    check_spawn_entry "$current_h3" "$has_name" "$has_model" "$has_subagent" "$filepath"
                    if [ "$_spawn_fail_count" -gt 0 ]; then
                        a3_file_fail=$((a3_file_fail + _spawn_fail_count))
                    fi
                fi
                current_h3="$line"
                has_name=0
                has_model=0
                has_subagent=0
            fi
            if printf '%s\n' "$line" | grep -q '\*\*Name\*\*:.*`'; then
                has_name=1
            fi
            if printf '%s\n' "$line" | grep -qiE '\*\*Model\*\*:[[:space:]]*(opus|sonnet)'; then
                has_model=1
            fi
            if printf '%s\n' "$line" | grep -q '\*\*Subagent type\*\*:'; then
                has_subagent=1
            fi
        done <<< "$spawn_section"

        # Check the last H3 entry
        if [ -n "$current_h3" ]; then
            check_spawn_entry "$current_h3" "$has_name" "$has_model" "$has_subagent" "$filepath"
            if [ "$_spawn_fail_count" -gt 0 ]; then
                a3_file_fail=$((a3_file_fail + _spawn_fail_count))
            fi
        fi

        if [ "$a3_file_fail" -eq 0 ]; then
            a3_pass=$((a3_pass + 1))
        else
            a3_fail=$((a3_fail + a3_file_fail))
        fi
    fi

    # -------------------------------------------------------------------------
    # A4: Shared Content Markers
    # -------------------------------------------------------------------------
    a4_file_fail=0

    for shared_name in "principles" "communication-protocol"; do
        begin_marker="<!-- BEGIN SHARED: $shared_name -->"
        end_marker="<!-- END SHARED: $shared_name -->"

        begin_line="$(grep -n "$(printf '%s\n' "$begin_marker" | sed 's/[\/&]/\\&/g')" "$filepath" | head -1 | cut -d: -f1)" || true
        end_line="$(grep -n "$(printf '%s\n' "$end_marker" | sed 's/[\/&]/\\&/g')" "$filepath" | head -1 | cut -d: -f1)" || true

        if [ -z "$begin_line" ] && [ -z "$end_line" ]; then
            echo "[FAIL] A4/shared-markers: Missing both BEGIN and END markers for \"$shared_name\""
            echo "  File: $filepath"
            echo "  Expected: Both \"$begin_marker\" and \"$end_marker\" present"
            echo "  Found: Neither marker found"
            echo "  Fix: Add the shared content block with proper BEGIN/END markers"
            a4_file_fail=$((a4_file_fail + 1))
        elif [ -z "$begin_line" ]; then
            echo "[FAIL] A4/shared-markers: Missing BEGIN marker for \"$shared_name\""
            echo "  File: $filepath"
            echo "  Expected: \"$begin_marker\" present in file"
            echo "  Found: BEGIN marker not found (END marker present at line $end_line)"
            echo "  Fix: Add \"$begin_marker\" before the shared content block"
            a4_file_fail=$((a4_file_fail + 1))
        elif [ -z "$end_line" ]; then
            echo "[FAIL] A4/shared-markers: Missing END marker for \"$shared_name\""
            echo "  File: $filepath"
            echo "  Expected: \"$end_marker\" present in file"
            echo "  Found: END marker not found (BEGIN marker present at line $begin_line)"
            echo "  Fix: Add \"$end_marker\" after the shared content block"
            a4_file_fail=$((a4_file_fail + 1))
        elif [ "$begin_line" -ge "$end_line" ]; then
            echo "[FAIL] A4/shared-markers: Marker ordering error for \"$shared_name\""
            echo "  File: $filepath"
            echo "  Expected: BEGIN marker appears before END marker"
            echo "  Found: BEGIN at line $begin_line, END at line $end_line (END is not after BEGIN)"
            echo "  Fix: Ensure \"$begin_marker\" appears before \"$end_marker\""
            a4_file_fail=$((a4_file_fail + 1))
        fi
    done

    if [ "$a4_file_fail" -eq 0 ]; then
        a4_pass=$((a4_pass + 1))
    else
        a4_fail=$((a4_fail + a4_file_fail))
    fi
done

file_count="${#skill_files[@]}"

# Print A1 summary
if [ "$a1_fail" -eq 0 ]; then
    echo "[PASS] A1/frontmatter: All SKILL.md files have valid YAML frontmatter ($file_count files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# Print A2 summary
if [ "$a2_fail" -eq 0 ]; then
    echo "[PASS] A2/required-sections: All SKILL.md files have all required sections ($file_count files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# Print A3 summary
if [ "$a3_fail" -eq 0 ]; then
    echo "[PASS] A3/spawn-definitions: All spawn definitions have required fields ($file_count files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# Print A4 summary
if [ "$a4_fail" -eq 0 ]; then
    echo "[PASS] A4/shared-markers: All SKILL.md files have properly paired shared content markers ($file_count files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
