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

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Authoritative source files
SHARED_DIR="${CONCLAVE_SHARED_DIR:-$REPO_ROOT/plugins/conclave/shared}"
if [ -n "${CONCLAVE_SHARED_DIR:-}" ] && [ ! -d "$SHARED_DIR" ]; then
    echo "ERROR: CONCLAVE_SHARED_DIR is set to '$SHARED_DIR' but the directory does not exist."
    exit 1
fi
PRINCIPLES_SOURCE="$SHARED_DIR/principles.md"
PROTOCOL_SOURCE="$SHARED_DIR/communication-protocol.md"
PREAMBLE_SOURCE="$SHARED_DIR/orchestrator-preamble.md"

# Engineering skills receive both universal-principles and engineering-principles.
# Non-engineering skills receive only universal-principles.
# Classification criteria: engineering = the skill's agents write or review code.
# Unknown skills default to engineering (safe default: more principles, not fewer).
#
# To classify a new skill: add it to one of the two arrays below.
ENGINEERING_SKILLS=(
    craft-laravel
    create-conclave-team
    harden-security
    squash-bugs
    write-spec
    plan-implementation
    build-implementation
    review-quality
    run-task
    plan-product
    build-product
    refine-code
    unearth-specification
    review-pr
    audit-slop
)

NON_ENGINEERING_SKILLS=(
    research-market
    ideate-product
    manage-roadmap
    write-stories
    plan-sales
    plan-hiring
    draft-investor-update
    profile-competitor
)

is_engineering_skill() {
    local name="$1"
    for s in "${ENGINEERING_SKILLS[@]}"; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}

is_known_skill() {
    local name="$1"
    for s in "${ENGINEERING_SKILLS[@]}" "${NON_ENGINEERING_SKILLS[@]}"; do
        [ "$s" = "$name" ] && return 0
    done
    return 1
}

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
done < <(find "$REPO_ROOT/plugins/conclave" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

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
        echo "{skill-skeptic}"
        echo "{Skill Skeptic}"
        return
    fi
    # Extract slug: write(SLUG, "PLAN REVIEW...) — handles optional {/} around slug
    local slug
    slug="$(printf '%s' "$row" | sed -n 's/.*write([{]*\([a-z-]*\)[}]*,.*/\1/p')"
    # Filter out placeholder value (sans braces)
    if [ "$slug" = "skill-skeptic" ]; then slug=""; fi
    # Extract display name: | Display Name | — strip stray braces
    local display
    display="$(printf '%s' "$row" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/,"",$4); gsub(/[{}]/,"",$4); print $4}')"
    # Filter out placeholder display
    if [ "$display" = "Skill Skeptic" ]; then display=""; fi
    # If slug is empty but display is valid, derive slug from display
    if [ -z "$slug" ] && [ -n "$display" ]; then
        slug="$(printf '%s' "$display" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    fi
    local default_slug='{skill-skeptic}'
    local default_display='{Skill Skeptic}'
    echo "${slug:-$default_slug}"
    echo "${display:-$default_display}"
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
auth_universal="$(extract_block "$PRINCIPLES_SOURCE" \
    "<!-- BEGIN SHARED: universal-principles -->" \
    "<!-- END SHARED: universal-principles -->")"

auth_engineering="$(extract_block "$PRINCIPLES_SOURCE" \
    "<!-- BEGIN SHARED: engineering-principles -->" \
    "<!-- END SHARED: engineering-principles -->")"

if [ -z "$auth_universal" ] || [ -z "$auth_engineering" ]; then
    echo "ERROR: $PRINCIPLES_SOURCE missing universal-principles or engineering-principles sub-blocks"
    exit 1
fi

auth_protocol="$(cat "$PROTOCOL_SOURCE")"

if [ -z "$auth_protocol" ]; then
    echo "ERROR: $PROTOCOL_SOURCE is empty"
    exit 1
fi

auth_preamble="$(cat "$PREAMBLE_SOURCE")"

if [ -z "$auth_preamble" ]; then
    echo "ERROR: $PREAMBLE_SOURCE is empty"
    exit 1
fi

# ===== Coverage checks (run before sync; abort on errors) =====
coverage_errors=0

# Coverage check 1: every persona file referenced by any SKILL.md must exist on disk
echo "Coverage check 1: persona references..."
referenced_personas="$(grep -ohE 'plugins/conclave/shared/personas/[a-z][a-z0-9-]*\.md' "${skill_files[@]}" 2>/dev/null | sort -u)"
while IFS= read -r persona_path; do
    [ -z "$persona_path" ] && continue
    full_path="$REPO_ROOT/$persona_path"
    if [ ! -f "$full_path" ]; then
        echo "  ERROR  Referenced persona file does not exist: $persona_path"
        coverage_errors=$((coverage_errors + 1))
    fi
done <<< "$referenced_personas"

# Coverage check 2: every classification array entry must correspond to an existing skill directory
echo "Coverage check 2: deleted-skill detection..."
all_classified=("${ENGINEERING_SKILLS[@]}" "${NON_ENGINEERING_SKILLS[@]}")
for s in "${all_classified[@]}"; do
    if [ ! -f "$REPO_ROOT/plugins/conclave/skills/$s/SKILL.md" ]; then
        echo "  ERROR  Classification array references missing skill directory: $s"
        coverage_errors=$((coverage_errors + 1))
    fi
done

# Coverage check 3: every multi-agent skill on disk must be classified (warning only)
echo "Coverage check 3: classification coverage..."
for filepath in "${skill_files[@]}"; do
    skill_name="$(basename "$(dirname "$filepath")")"
    if should_skip_sync "$filepath"; then
        continue
    fi
    if ! is_known_skill "$skill_name"; then
        echo "  WARN   Skill not in classification arrays: $skill_name (defaulting to engineering)"
    fi
done

# Coverage check 4: every persona id must be unique
echo "Coverage check 4: persona id uniqueness..."
dup_ids="$(awk -F: '/^id:/ {gsub(/[" ]/,"",$2); print $2}' "$REPO_ROOT/plugins/conclave/shared/personas/"*.md 2>/dev/null | sort | uniq -c | awk '$1>1 {print $2}')"
if [ -n "$dup_ids" ]; then
    echo "  ERROR  Duplicate persona ids found:"
    echo "$dup_ids" | sed 's/^/         /'
    coverage_errors=$((coverage_errors + 1))
fi

if [ "$coverage_errors" -gt 0 ]; then
    echo ""
    echo "ABORTING: $coverage_errors coverage error(s) — fix before re-running sync."
    exit 1
fi
echo "Coverage checks passed."
echo ""

# Authoritative skeptic names (for substitution)
AUTH_SKEPTIC_SLUG="{skill-skeptic}"
AUTH_SKEPTIC_DISPLAY="{Skill Skeptic}"

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

    # Warn about unknown/unclassified skills
    if ! is_known_skill "$skill_name"; then
        echo "  WARN  $skill_name: Unclassified skill — defaulting to engineering (both blocks). Add to classification list in this script."
    fi

    # Transition guard: old marker not yet migrated
    if grep -q "<!-- BEGIN SHARED: principles -->" "$filepath"; then
        echo "  WARN  $skill_name: Still has old 'principles' markers — migrate to universal-principles / engineering-principles, then re-run sync"
        skipped=$((skipped + 1))
        continue
    fi

    # Check that markers exist in the target
    if ! grep -q "<!-- BEGIN SHARED: universal-principles -->" "$filepath"; then
        echo "  WARN  $skill_name: Missing universal-principles markers, skipping"
        skipped=$((skipped + 1))
        continue
    fi
    if ! grep -q "<!-- BEGIN SHARED: communication-protocol -->" "$filepath"; then
        echo "  WARN  $skill_name: Missing communication-protocol markers, skipping"
        skipped=$((skipped + 1))
        continue
    fi

    # Inject orchestrator-preamble if markers present (added in 2.5.0)
    if grep -q "<!-- BEGIN SHARED: orchestrator-preamble -->" "$filepath"; then
        replace_block "$filepath" \
            "<!-- BEGIN SHARED: orchestrator-preamble -->" \
            "<!-- END SHARED: orchestrator-preamble -->" \
            "$auth_preamble"
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

    # Always inject universal-principles
    replace_block "$filepath" \
        "<!-- BEGIN SHARED: universal-principles -->" \
        "<!-- END SHARED: universal-principles -->" \
        "$auth_universal"

    # Inject engineering-principles for engineering skills only
    if is_engineering_skill "$skill_name" || ! is_known_skill "$skill_name"; then
        if grep -q "<!-- BEGIN SHARED: engineering-principles -->" "$filepath"; then
            replace_block "$filepath" \
                "<!-- BEGIN SHARED: engineering-principles -->" \
                "<!-- END SHARED: engineering-principles -->" \
                "$auth_engineering"
        else
            echo "  WARN  $skill_name: Classified as engineering but missing engineering-principles markers"
        fi
    fi

    replace_block "$filepath" \
        "<!-- BEGIN SHARED: communication-protocol -->" \
        "<!-- END SHARED: communication-protocol -->" \
        "$target_protocol"

    echo "  SYNC  $skill_name ($target_slug / $target_display)"
    synced=$((synced + 1))
done

echo ""
echo "Sync complete: $synced synced, $skipped skipped (of ${#skill_files[@]} total)"
