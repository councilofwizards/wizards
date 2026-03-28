#!/usr/bin/env bash
# Category G: Split readiness gate
# Usage: split-readiness.sh <repo_root>
set -euo pipefail

REPO_ROOT="${1:?REPO_ROOT argument required}"

passed=0
failed=0

# G1: Business skill count threshold
# Advisory WARN only — does not cause validation failure
biz_count=0
while IFS= read -r -d '' f; do
    # Extract frontmatter
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
        if printf '%s\n' "$fm_content" | grep -q "^category:[[:space:]]*business"; then
            biz_count=$((biz_count + 1))
        fi
    fi
done < <(find "$REPO_ROOT/plugins/conclave" -path "*/skills/*/SKILL.md" -print0 2>/dev/null | sort -z)

if [ "$biz_count" -ge 7 ]; then
    echo "[WARN] G1/split-readiness: Business skill count ($biz_count) has reached split readiness threshold. Review ADR-005."
fi

echo "[PASS] G1/split-readiness: Business skill count check complete ($biz_count business skills found)"
passed=$((passed + 1))

exit 0
