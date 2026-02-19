#!/usr/bin/env bash
# Category B: Shared content deduplication checks
# Usage: skill-shared-content.sh <repo_root>
set -euo pipefail

REPO_ROOT="${1:?REPO_ROOT argument required}"

passed=0
failed=0

skill_files=()
while IFS= read -r -d '' f; do
    skill_files+=("$f")
done < <(find "$REPO_ROOT/plugins" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

# Determine the authoritative source file (plan-product/SKILL.md per spec)
authoritative_source=""
for f in "${skill_files[@]}"; do
    if [ "$(basename "$(dirname "$f")")" = "plan-product" ]; then
        authoritative_source="$f"
        break
    fi
done
# Fall back to first file if plan-product is not found
if [ -z "$authoritative_source" ] && [ "${#skill_files[@]}" -gt 0 ]; then
    authoritative_source="${skill_files[0]}"
fi

if [ "${#skill_files[@]}" -eq 0 ]; then
    echo "[PASS] B1/principles-drift: No SKILL.md files found to compare (0 files checked)"
    echo "[PASS] B2/protocol-drift: No SKILL.md files found to compare (0 files checked)"
    echo "[PASS] B3/authoritative-source: No SKILL.md files found to check (0 files checked)"
    exit 0
fi

# Helper: extract content between two markers (inclusive)
extract_block() {
    local file="$1"
    local begin_marker="$2"
    local end_marker="$3"
    awk -v begin="$begin_marker" -v end="$end_marker" '
        $0 == begin { found=1 }
        found { print }
        $0 == end && found { exit }
    ' "$file"
}

# Helper: normalize skeptic names for B2 comparison
# Replaces all 6 variants (backtick slugs standalone or inside write() calls,
# and plain-text display names) with SKEPTIC_NAME before comparison.
normalize_skeptic_names() {
    sed \
        -e 's/product-skeptic/SKEPTIC_NAME/g' \
        -e 's/quality-skeptic/SKEPTIC_NAME/g' \
        -e 's/ops-skeptic/SKEPTIC_NAME/g' \
        -e 's/accuracy-skeptic/SKEPTIC_NAME/g' \
        -e 's/narrative-skeptic/SKEPTIC_NAME/g' \
        -e 's/Product Skeptic/SKEPTIC_NAME/g' \
        -e 's/Quality Skeptic/SKEPTIC_NAME/g' \
        -e 's/Ops Skeptic/SKEPTIC_NAME/g' \
        -e 's/Accuracy Skeptic/SKEPTIC_NAME/g' \
        -e 's/Narrative Skeptic/SKEPTIC_NAME/g' \
        -e 's/strategy-skeptic/SKEPTIC_NAME/g' \
        -e 's/Strategy Skeptic/SKEPTIC_NAME/g'
}

# Build lookup of single-agent skill files (skip shared content checks for these)
single_agent_files=()
for f in "${skill_files[@]}"; do
    fm_end=0
    while IFS= read -r line; do
        lineno="${line%%	*}"
        content="${line#*	}"
        if [ "$lineno" -gt 1 ] && [ "$content" = "---" ]; then
            fm_end="$lineno"
            break
        fi
    done < <(grep -n "^---$" "$f" | awk -F: '{print $1"\t"$2}')
    if [ "$fm_end" -gt 0 ]; then
        fm_content="$(sed -n "2,$((fm_end - 1))p" "$f")"
        if printf '%s\n' "$fm_content" | grep -q "^type:[[:space:]]*single-agent"; then
            single_agent_files+=("$f")
        fi
    fi
done

is_single_agent_file() {
    local target="$1"
    for f in "${single_agent_files[@]}"; do
        [ "$f" = "$target" ] && return 0
    done
    return 1
}

# -------------------------------------------------------------------------
# B1: Shared Principles — byte identity
# -------------------------------------------------------------------------
b1_fail=0

auth_principles_block=""
if [ -n "$authoritative_source" ]; then
    auth_principles_block="$(extract_block "$authoritative_source" "<!-- BEGIN SHARED: principles -->" "<!-- END SHARED: principles -->")"
fi

for filepath in "${skill_files[@]}"; do
    is_single_agent_file "$filepath" && continue

    block="$(extract_block "$filepath" "<!-- BEGIN SHARED: principles -->" "<!-- END SHARED: principles -->")"
    if [ -z "$block" ]; then
        echo "[FAIL] B1/principles-drift: Could not extract Shared Principles block"
        echo "  File: $filepath"
        echo "  Expected: Content between <!-- BEGIN SHARED: principles --> and <!-- END SHARED: principles -->"
        echo "  Found: No content extracted (markers may be missing or mismatched)"
        echo "  Fix: Ensure the file has properly paired <!-- BEGIN SHARED: principles --> and <!-- END SHARED: principles --> markers with content between them"
        b1_fail=$((b1_fail + 1))
        continue
    fi

    # Skip comparison if this is the authoritative source itself
    [ "$filepath" = "$authoritative_source" ] && continue

    if [ "$block" != "$auth_principles_block" ]; then
        diff_output="$(diff \
            <(printf '%s\n' "$auth_principles_block") \
            <(printf '%s\n' "$block") \
            || true)"
        echo "[FAIL] B1/principles-drift: Shared Principles content differs"
        echo "  File: $filepath"
        echo "  Expected: Byte-identical to $authoritative_source (authoritative source)"
        echo "  Found: Content differs (see diff below)"
        echo "  Fix: Copy Shared Principles block from $authoritative_source to $filepath"
        printf '%s\n' "$diff_output" | sed "s|^---|  --- $(basename "$(dirname "$authoritative_source")")/SKILL.md (authoritative)|" | sed "s|^+++|  +++ $(basename "$(dirname "$filepath")")/SKILL.md|" | sed 's/^/  /'
        b1_fail=$((b1_fail + 1))
    fi
done

if [ "$b1_fail" -eq 0 ]; then
    echo "[PASS] B1/principles-drift: Shared Principles blocks are byte-identical across all skills (${#skill_files[@]} files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# -------------------------------------------------------------------------
# B2: Communication Protocol — structural equivalence (with normalization)
# -------------------------------------------------------------------------
b2_fail=0

auth_protocol_block=""
auth_protocol_normalized=""
if [ -n "$authoritative_source" ]; then
    auth_protocol_block="$(extract_block "$authoritative_source" "<!-- BEGIN SHARED: communication-protocol -->" "<!-- END SHARED: communication-protocol -->")"
    auth_protocol_normalized="$(printf '%s\n' "$auth_protocol_block" | normalize_skeptic_names)"
fi

for filepath in "${skill_files[@]}"; do
    is_single_agent_file "$filepath" && continue

    block="$(extract_block "$filepath" "<!-- BEGIN SHARED: communication-protocol -->" "<!-- END SHARED: communication-protocol -->")"
    if [ -z "$block" ]; then
        echo "[FAIL] B2/protocol-drift: Could not extract Communication Protocol block"
        echo "  File: $filepath"
        echo "  Expected: Content between <!-- BEGIN SHARED: communication-protocol --> and <!-- END SHARED: communication-protocol -->"
        echo "  Found: No content extracted (markers may be missing or mismatched)"
        echo "  Fix: Ensure the file has properly paired communication-protocol markers with content between them"
        b2_fail=$((b2_fail + 1))
        continue
    fi

    # Skip comparison if this is the authoritative source itself
    [ "$filepath" = "$authoritative_source" ] && continue

    normalized="$(printf '%s\n' "$block" | normalize_skeptic_names)"

    if [ "$normalized" != "$auth_protocol_normalized" ]; then
        diff_output="$(diff \
            <(printf '%s\n' "$auth_protocol_normalized") \
            <(printf '%s\n' "$normalized") \
            || true)"
        echo "[FAIL] B2/protocol-drift: Communication Protocol structure differs (after skeptic-name normalization)"
        echo "  File: $filepath"
        echo "  Expected: Structurally equivalent to $authoritative_source (after normalizing all skeptic name variants)"
        echo "  Found: Content differs after normalization (see diff below)"
        echo "  Fix: Sync Communication Protocol structure from $authoritative_source to $filepath (skeptic names like quality-skeptic vs product-skeptic are intentional and not flagged)"
        printf '%s\n' "$diff_output" | sed "s|^---|  --- $(basename "$(dirname "$authoritative_source")")/SKILL.md (normalized)|" | sed "s|^+++|  +++ $(basename "$(dirname "$filepath")")/SKILL.md (normalized)|" | sed 's/^/  /'
        b2_fail=$((b2_fail + 1))
    fi
done

if [ "$b2_fail" -eq 0 ]; then
    echo "[PASS] B2/protocol-drift: Communication Protocol blocks are structurally equivalent across all skills (${#skill_files[@]} files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# -------------------------------------------------------------------------
# B3: Authoritative Source Marker
# Every <!-- BEGIN SHARED: ... --> must be immediately followed by the authoritative source comment
# -------------------------------------------------------------------------
b3_fail=0

for filepath in "${skill_files[@]}"; do
    # Find all BEGIN SHARED lines and check the next line
    while IFS= read -r match; do
        lineno="${match%%	*}"
        next_lineno=$((lineno + 1))
        next_line="$(sed -n "${next_lineno}p" "$filepath")"
        expected_comment="<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->"
        if [ "$next_line" != "$expected_comment" ]; then
            marker_content="$(sed -n "${lineno}p" "$filepath")"
            echo "[FAIL] B3/authoritative-source: BEGIN SHARED marker not followed by authoritative source comment"
            echo "  File: $filepath"
            echo "  Expected: Line $next_lineno is \"$expected_comment\""
            echo "  Found: \"$next_line\""
            echo "  Fix: Add \"$expected_comment\" on the line immediately after \"$marker_content\""
            b3_fail=$((b3_fail + 1))
        fi
    done < <(grep -n "<!-- BEGIN SHARED:" "$filepath" | awk -F: '{print $1"\t"$2}')
done

if [ "$b3_fail" -eq 0 ]; then
    echo "[PASS] B3/authoritative-source: All BEGIN SHARED markers are followed by authoritative source comment (${#skill_files[@]} files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
