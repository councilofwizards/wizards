#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

passed=0
failed=0
output=""

run_validator() {
    local name="$1"
    local script="$SCRIPT_DIR/validators/$name"
    local result
    result="$(bash "$script" "$REPO_ROOT")" || true
    output="$output$result"$'\n'
    local p f
    p="$(printf '%s\n' "$result" | grep -c '^\[PASS\]' || true)"
    f="$(printf '%s\n' "$result" | grep -c '^\[FAIL\]' || true)"
    passed=$((passed + p))
    failed=$((failed + f))
}

run_validator "skill-structure.sh"
run_validator "skill-shared-content.sh"
run_validator "roadmap-frontmatter.sh"
run_validator "spec-frontmatter.sh"
run_validator "progress-checkpoint.sh"
run_validator "artifact-templates.sh"

printf '%s\n' "$output"

echo "---"
echo "Validation complete: $passed passed, $failed failed"

if [ "$failed" -gt 0 ]; then
    exit 1
fi
exit 0
