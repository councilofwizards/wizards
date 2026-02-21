#!/usr/bin/env bash
# Category F: Artifact template validation
# Usage: artifact-templates.sh <repo_root>
set -euo pipefail

REPO_ROOT="${1:?REPO_ROOT argument required}"

passed=0
failed=0

TEMPLATES_DIR="$REPO_ROOT/docs/templates/artifacts"

# -------------------------------------------------------------------------
# F1: Artifact templates exist with correct frontmatter
# -------------------------------------------------------------------------
f1_fail=0
f1_checked=0

# Expected artifact templates: "name:expected_type" pairs
expected_templates="research-findings:research-findings
product-ideas:product-ideas
user-stories:user-stories
implementation-plan:implementation-plan"

while IFS=: read -r template_name expected_type; do
    template_file="$TEMPLATES_DIR/${template_name}.md"
    f1_checked=$((f1_checked + 1))

    if [ ! -f "$template_file" ]; then
        echo "[FAIL] F1/artifact-templates: Missing artifact template"
        echo "  File: $template_file"
        echo "  Expected: Template file exists"
        echo "  Found: File not found"
        echo "  Fix: Create $template_file with YAML frontmatter containing type: \"$expected_type\""
        f1_fail=$((f1_fail + 1))
        continue
    fi

    # Check YAML frontmatter exists
    line1="$(sed -n '1p' "$template_file")"
    if [ "$line1" != "---" ]; then
        echo "[FAIL] F1/artifact-templates: Template missing YAML frontmatter"
        echo "  File: $template_file"
        echo "  Expected: File starts with \"---\""
        echo "  Found: \"$line1\""
        echo "  Fix: Add YAML frontmatter starting with \"---\" on line 1"
        f1_fail=$((f1_fail + 1))
        continue
    fi

    # Find closing ---
    fm_end=0
    while IFS= read -r line; do
        lineno="${line%%	*}"
        content="${line#*	}"
        if [ "$lineno" -gt 1 ] && [ "$content" = "---" ]; then
            fm_end="$lineno"
            break
        fi
    done < <(grep -n "^---$" "$template_file" | awk -F: '{print $1"\t"$2}')

    if [ "$fm_end" -eq 0 ]; then
        echo "[FAIL] F1/artifact-templates: Template frontmatter not closed"
        echo "  File: $template_file"
        echo "  Expected: Closing \"---\" after frontmatter"
        echo "  Found: No closing delimiter"
        echo "  Fix: Add closing \"---\" after frontmatter fields"
        f1_fail=$((f1_fail + 1))
        continue
    fi

    # Extract and check type field
    fm_content="$(sed -n "2,$((fm_end - 1))p" "$template_file")"
    type_value="$(printf '%s\n' "$fm_content" | grep "^type:" | head -1 | sed 's/^type:[[:space:]]*//' | sed 's/^"//;s/"$//')"

    if [ -z "$type_value" ]; then
        echo "[FAIL] F1/artifact-templates: Template missing \"type\" field"
        echo "  File: $template_file"
        echo "  Expected: Frontmatter contains type: \"$expected_type\""
        echo "  Found: No \"type\" field in frontmatter"
        echo "  Fix: Add type: \"$expected_type\" to the YAML frontmatter"
        f1_fail=$((f1_fail + 1))
    elif [ "$type_value" != "$expected_type" ]; then
        echo "[FAIL] F1/artifact-templates: Template has wrong \"type\" value"
        echo "  File: $template_file"
        echo "  Expected: type: \"$expected_type\""
        echo "  Found: type: \"$type_value\""
        echo "  Fix: Change type field to \"$expected_type\""
        f1_fail=$((f1_fail + 1))
    fi
done <<< "$expected_templates"

if [ "$f1_fail" -eq 0 ]; then
    echo "[PASS] F1/artifact-templates: All artifact templates exist with correct type fields ($f1_checked templates checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
