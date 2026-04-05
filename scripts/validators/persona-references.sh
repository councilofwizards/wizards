#!/usr/bin/env bash
# Category P: Persona file reference and schema validation
# Usage: persona-references.sh <repo_root>
set -euo pipefail

REPO_ROOT="${1:?REPO_ROOT argument required}"

passed=0
failed=0

# -------------------------------------------------------------------------
# P1: Persona File Reference Integrity
# Scans spawn prompts for "First, read {path}" directives and validates
# that the referenced persona file exists.
# -------------------------------------------------------------------------
p1_fail=0
p1_ref_count=0
p1_skill_count=0

skill_files=()
while IFS= read -r -d '' f; do
    skill_files+=("$f")
done < <(find "$REPO_ROOT/plugins/conclave" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

for filepath in "${skill_files[@]}"; do
    # Extract the Teammate Spawn Prompts section
    spawn_section="$(awk '/^## Teammate Spawn Prompts/{found=1; next} found && /^## /{exit} found{print}' "$filepath")"
    [ -z "$spawn_section" ] && continue

    skill_had_ref=0

    # Find all code blocks within spawn prompts, look for "First, read" directive
    in_block=0
    while IFS= read -r line; do
        if printf '%s\n' "$line" | grep -q '^\`\`\`'; then
            if [ "$in_block" -eq 0 ]; then
                in_block=1
            else
                in_block=0
            fi
            continue
        fi

        if [ "$in_block" -eq 1 ]; then
            # Check for: First, read {path} for your complete role definition
            if printf '%s\n' "$line" | grep -qE '^First, read .+ for your complete role definition'; then
                # Extract the path
                persona_path="$(printf '%s\n' "$line" | sed 's/^First, read \([^ ]*\) for your complete role definition.*/\1/')"

                # Skip template placeholders (path contains spaces = not a real file path)
                if printf '%s\n' "$persona_path" | grep -q ' '; then
                    continue
                fi

                p1_ref_count=$((p1_ref_count + 1))
                skill_had_ref=1

                if [ ! -f "$REPO_ROOT/$persona_path" ]; then
                    echo "[FAIL] P1/persona-reference: spawn prompt references missing persona file: $persona_path"
                    echo "  File: $filepath"
                    echo "  Expected: File exists at $REPO_ROOT/$persona_path"
                    echo "  Found: File not found"
                    echo "  Fix: Create the persona file or correct the path in the spawn prompt"
                    p1_fail=$((p1_fail + 1))
                fi
            fi
        fi
    done <<< "$spawn_section"

    [ "$skill_had_ref" -eq 1 ] && p1_skill_count=$((p1_skill_count + 1))
done

if [ "$p1_fail" -eq 0 ]; then
    echo "[PASS] P1/persona-reference: All spawn prompt persona file references resolve ($p1_ref_count references in $p1_skill_count skills)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

# -------------------------------------------------------------------------
# P2: Persona File Schema Completeness
# Checks every persona file in plugins/conclave/shared/personas/ for
# required frontmatter fields and required sections per archetype.
# -------------------------------------------------------------------------
p2_fail=0
p2_warn=0
p2_file_count=0

PERSONAS_DIR="$REPO_ROOT/plugins/conclave/shared/personas"

if [ ! -d "$PERSONAS_DIR" ]; then
    echo "[PASS] P2/persona-schema: No personas directory found — skipping ($PERSONAS_DIR)"
    passed=$((passed + 1))
    if [ "$failed" -gt 0 ]; then exit 1; fi
    exit 0
fi

persona_files=()
while IFS= read -r -d '' f; do
    persona_files+=("$f")
done < <(find "$PERSONAS_DIR" -maxdepth 1 -name "*.md" -print0 2>/dev/null | sort -z)

if [ "${#persona_files[@]}" -eq 0 ]; then
    echo "[PASS] P2/persona-schema: No persona files found to check (0 files checked)"
    passed=$((passed + 1))
    if [ "$failed" -gt 0 ]; then exit 1; fi
    exit 0
fi

# Helper: check if a section heading exists in file content
has_section() {
    local content="$1"
    local heading="$2"
    printf '%s\n' "$content" | grep -qE "^## ${heading}$"
}

for persona_file in "${persona_files[@]}"; do
    p2_file_count=$((p2_file_count + 1))
    fname="$(basename "$persona_file")"

    # Read file content
    content="$(cat "$persona_file")"

    # ---- Extract YAML frontmatter ----
    line1="$(sed -n '1p' "$persona_file")"
    if [ "$line1" != "---" ]; then
        echo "[FAIL] P2/persona-schema: $fname missing YAML frontmatter (no opening ---)"
        p2_fail=$((p2_fail + 1))
        continue
    fi

    fm_end=0
    while IFS= read -r line; do
        lineno="${line%%	*}"
        linecontent="${line#*	}"
        if [ "$lineno" -gt 1 ] && [ "$linecontent" = "---" ]; then
            fm_end="$lineno"
            break
        fi
    done < <(grep -n "^---$" "$persona_file" | awk -F: '{print $1"\t"$2}')

    if [ "$fm_end" -eq 0 ]; then
        echo "[FAIL] P2/persona-schema: $fname YAML frontmatter not closed"
        p2_fail=$((p2_fail + 1))
        continue
    fi

    fm_content="$(sed -n "2,$((fm_end - 1))p" "$persona_file")"

    # Check required frontmatter fields
    fm_ok=1
    for field in name id model archetype; do
        if ! printf '%s\n' "$fm_content" | grep -q "^${field}:"; then
            echo "[FAIL] P2/persona-schema: $fname missing required frontmatter field \"$field\""
            p2_fail=$((p2_fail + 1))
            fm_ok=0
        fi
    done
    [ "$fm_ok" -eq 0 ] && continue

    # Extract archetype value
    archetype="$(printf '%s\n' "$fm_content" | grep "^archetype:" | head -1 | sed 's/^archetype:[[:space:]]*//')"

    # Normalize coordinator → team-lead
    if [ "$archetype" = "coordinator" ]; then
        archetype="team-lead"
    fi

    # Determine which sections are required/optional for this archetype
    # All archetypes require: Identity, Role, Critical Rules, Write Safety, Cross-References
    # assessor, skeptic, domain-expert, team-lead, evaluator: also require Responsibilities/Methodology + Output Format
    # lead: Responsibilities/Methodology and Output Format are optional

    file_fail=0

    # Always required sections
    for section in "Identity" "Role" "Critical Rules" "Write Safety" "Cross-References"; do
        if ! has_section "$content" "$section"; then
            echo "[FAIL] P2/persona-schema: $fname missing required section \"## $section\" for archetype \"$archetype\""
            p2_fail=$((p2_fail + 1))
            file_fail=$((file_fail + 1))
        fi
    done

    # Responsibilities or Methodology (accept either heading)
    case "$archetype" in
        assessor|skeptic|domain-expert|team-lead|evaluator)
            if ! has_section "$content" "Responsibilities" && ! has_section "$content" "Methodology"; then
                echo "[FAIL] P2/persona-schema: $fname missing required section \"## Responsibilities\" or \"## Methodology\" for archetype \"$archetype\""
                p2_fail=$((p2_fail + 1))
                file_fail=$((file_fail + 1))
            fi
            if ! has_section "$content" "Output Format"; then
                echo "[FAIL] P2/persona-schema: $fname missing required section \"## Output Format\" for archetype \"$archetype\""
                p2_fail=$((p2_fail + 1))
                file_fail=$((file_fail + 1))
            fi
            ;;
        lead)
            # Optional for lead archetype — emit WARN, not FAIL
            if ! has_section "$content" "Responsibilities" && ! has_section "$content" "Methodology"; then
                echo "[WARN] P2/persona-schema: $fname missing optional section \"## Responsibilities\" or \"## Methodology\" for archetype \"$archetype\""
                p2_warn=$((p2_warn + 1))
            fi
            if ! has_section "$content" "Output Format"; then
                echo "[WARN] P2/persona-schema: $fname missing optional section \"## Output Format\" for archetype \"$archetype\""
                p2_warn=$((p2_warn + 1))
            fi
            ;;
        *)
            # Unknown archetype — treat as assessor (all required) with a warning
            echo "[WARN] P2/persona-schema: $fname has unknown archetype \"$archetype\" — validating as assessor (all sections required)"
            p2_warn=$((p2_warn + 1))
            if ! has_section "$content" "Responsibilities" && ! has_section "$content" "Methodology"; then
                echo "[FAIL] P2/persona-schema: $fname missing required section \"## Responsibilities\" or \"## Methodology\" for archetype \"$archetype\""
                p2_fail=$((p2_fail + 1))
                file_fail=$((file_fail + 1))
            fi
            if ! has_section "$content" "Output Format"; then
                echo "[FAIL] P2/persona-schema: $fname missing required section \"## Output Format\" for archetype \"$archetype\""
                p2_fail=$((p2_fail + 1))
                file_fail=$((file_fail + 1))
            fi
            ;;
    esac
done

if [ "$p2_fail" -eq 0 ]; then
    echo "[PASS] P2/persona-schema: All persona files have required sections for their archetype ($p2_file_count files checked)"
    passed=$((passed + 1))
else
    failed=$((failed + 1))
fi

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
