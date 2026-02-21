#!/usr/bin/env bash
# Sync shared content blocks from the authoritative source files in
# plugins/conclave/shared/ to all multi-agent SKILL.md files.
#
# This is P2-07: shared content extraction. The authoritative source for
# each shared block lives in plugins/conclave/shared/ as standalone files,
# not inside any individual SKILL.md.
#
# Usage: sync-shared-content.sh [repo_root]
#   repo_root defaults to the parent of the directory containing this script.
#
# What it does:
#   1. Reads the Shared Principles block from plugins/conclave/shared/principles.md
#   2. Reads the Communication Protocol block from plugins/conclave/shared/communication-protocol.md
#   3. For each multi-agent SKILL.md, replaces the content between markers
#   4. Preserves per-skill skeptic names in the Communication Protocol
#
# Safety:
#   - Only modifies content between <!-- BEGIN SHARED --> and <!-- END SHARED --> markers
#   - Content before/after markers is untouched
#   - Idempotent — running multiple times produces the same result
#   - Run scripts/validate.sh after to confirm all checks pass

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Authoritative source files
SHARED_DIR="$REPO_ROOT/plugins/conclave/shared"
PRINCIPLES_SOURCE="$SHARED_DIR/principles.md"
PROTOCOL_SOURCE="$SHARED_DIR/communication-protocol.md"

if [ ! -f "$PRINCIPLES_SOURCE" ]; then
    echo "ERROR: $PRINCIPLES_SOURCE not found. Cannot sync."
    exit 1
fi
if [ ! -f "$PROTOCOL_SOURCE" ]; then
    echo "ERROR: $PROTOCOL_SOURCE not found. Cannot sync."
    exit 1
fi

# Find all SKILL.md files
skill_files=()
while IFS= read -r -d '' f; do
    skill_files+=("$f")
done < <(find "$REPO_ROOT/plugins" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

if [ "${#skill_files[@]}" -eq 0 ]; then
    echo "No SKILL.md files found under $REPO_ROOT/plugins"
    exit 0
fi

# Helper: extract content between two markers (inclusive of markers)
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

# Helper: detect if a file should be skipped (single-agent or tier 2 composite)
should_skip_sync() {
    local file="$1"
    local fm_end=0
    while IFS= read -r line; do
        lineno="${line%%	*}"
        if [ "$lineno" -gt 1 ]; then
            fm_end="$lineno"
            break
        fi
    done < <(grep -n "^---$" "$file" | awk -F: '{print $1"\t"$2}')
    if [ "$fm_end" -gt 0 ]; then
        local fm_content
        fm_content="$(sed -n "2,$((fm_end - 1))p" "$file")"
        if printf '%s\n' "$fm_content" | grep -q "^type:[[:space:]]*single-agent"; then
            return 0
        fi
        if printf '%s\n' "$fm_content" | grep -q "^tier:[[:space:]]*2"; then
            return 0
        fi
    fi
    return 1
}

# Helper: extract the skeptic slug and display name from a SKILL.md's existing protocol block
# Returns two lines: slug on line 1, display name on line 2
extract_skeptic_names() {
    local file="$1"
    local row
    row="$(grep "Plan ready for review" "$file" 2>/dev/null || true)"
    if [ -z "$row" ]; then
        echo "product-skeptic"
        echo "Product Skeptic"
        return
    fi
    # Extract slug: write(SLUG, "PLAN REVIEW...)
    local slug
    slug="$(printf '%s' "$row" | sed -n 's/.*write(\([a-z-]*\),.*/\1/p')"
    # Extract display name: | Display Name |
    local display
    display="$(printf '%s' "$row" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$4); print $4}')"
    echo "${slug:-product-skeptic}"
    echo "${display:-Product Skeptic}"
}

# Helper: replace content between markers in a file
# Replaces everything between begin_marker and end_marker (inclusive) with new_content
replace_block() {
    local file="$1"
    local begin_marker="$2"
    local end_marker="$3"
    local new_content="$4"

    local tmpfile
    tmpfile="$(mktemp)"

    awk -v begin="$begin_marker" -v end="$end_marker" -v replacement="$tmpfile" '
        $0 == begin {
            # Write the replacement content
            while ((getline line < replacement) > 0) print line
            close(replacement)
            skip = 1
            next
        }
        $0 == end && skip {
            skip = 0
            next
        }
        !skip { print }
    ' "$file" > "${file}.tmp"

    # Write the new content to the temp file used by awk
    printf '%s\n' "$new_content" > "$tmpfile"

    # Re-run with the actual replacement content
    awk -v begin="$begin_marker" -v end="$end_marker" -v repfile="$tmpfile" '
        $0 == begin {
            while ((getline line < repfile) > 0) print line
            close(repfile)
            skip = 1
            next
        }
        $0 == end && skip {
            skip = 0
            next
        }
        !skip { print }
    ' "$file" > "${file}.tmp"

    mv "${file}.tmp" "$file"
    rm -f "$tmpfile"
}

# Read authoritative blocks from shared/ files
auth_principles="$(cat "$PRINCIPLES_SOURCE")"
auth_protocol="$(cat "$PROTOCOL_SOURCE")"

if [ -z "$auth_principles" ]; then
    echo "ERROR: $PRINCIPLES_SOURCE is empty"
    exit 1
fi
if [ -z "$auth_protocol" ]; then
    echo "ERROR: $PROTOCOL_SOURCE is empty"
    exit 1
fi

# Authoritative skeptic names (for substitution)
AUTH_SKEPTIC_SLUG="product-skeptic"
AUTH_SKEPTIC_DISPLAY="Product Skeptic"

synced=0
skipped=0

for filepath in "${skill_files[@]}"; do
    skill_name="$(basename "$(dirname "$filepath")")"

    # Skip single-agent and tier 2 composite skills
    if should_skip_sync "$filepath"; then
        echo "  SKIP  $skill_name (no shared content)"
        skipped=$((skipped + 1))
        continue
    fi

    # Check that markers exist in the target
    if ! grep -q "<!-- BEGIN SHARED: principles -->" "$filepath"; then
        echo "  WARN  $skill_name: Missing principles markers, skipping"
        skipped=$((skipped + 1))
        continue
    fi
    if ! grep -q "<!-- BEGIN SHARED: communication-protocol -->" "$filepath"; then
        echo "  WARN  $skill_name: Missing communication-protocol markers, skipping"
        skipped=$((skipped + 1))
        continue
    fi

    # Extract the target's skeptic names BEFORE replacing content
    skeptic_info="$(extract_skeptic_names "$filepath")"
    target_slug="$(printf '%s' "$skeptic_info" | head -1)"
    target_display="$(printf '%s' "$skeptic_info" | tail -1)"

    # Build the target-specific protocol block by substituting skeptic names
    target_protocol="$auth_protocol"
    if [ "$target_slug" != "$AUTH_SKEPTIC_SLUG" ]; then
        target_protocol="$(printf '%s' "$target_protocol" | sed "s/$AUTH_SKEPTIC_SLUG/$target_slug/g")"
    fi
    if [ "$target_display" != "$AUTH_SKEPTIC_DISPLAY" ]; then
        target_protocol="$(printf '%s' "$target_protocol" | sed "s/$AUTH_SKEPTIC_DISPLAY/$target_display/g")"
    fi

    # Replace both blocks
    replace_block "$filepath" \
        "<!-- BEGIN SHARED: principles -->" \
        "<!-- END SHARED: principles -->" \
        "$auth_principles"

    replace_block "$filepath" \
        "<!-- BEGIN SHARED: communication-protocol -->" \
        "<!-- END SHARED: communication-protocol -->" \
        "$target_protocol"

    echo "  SYNC  $skill_name ($target_slug / $target_display)"
    synced=$((synced + 1))
done

echo ""
echo "Sync complete: $synced synced, $skipped skipped (of ${#skill_files[@]} total)"
echo "Run 'bash scripts/validate.sh' to verify."
