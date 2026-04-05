#!/usr/bin/env bash
set -euo pipefail

# Bootstrap Factorium labels in the GitHub repository.
# Usage: bash scripts/factorium/bootstrap-labels.sh [owner/repo]
# If no repo is provided, uses the current git remote.

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"

echo "Bootstrapping Factorium labels for $REPO..."

create_label() {
    local name="$1"
    local color="$2"
    local description="$3"
    if gh label create "$name" --repo "$REPO" --color "$color" --description "$description" 2>/dev/null; then
        echo "[CREATED] $name"
    else
        # Label already exists — update it
        gh label edit "$name" --repo "$REPO" --color "$color" --description "$description" 2>/dev/null
        echo "[EXISTS]  $name (updated)"
    fi
}

echo ""
echo "=== Stage Labels (mutually exclusive) ==="
create_label "factorium:dreamer"   "7B68EE" "Factorium: newly created idea, awaiting research"
create_label "factorium:assayer"   "DAA520" "Factorium: awaiting or undergoing research/validation"
create_label "factorium:planner"   "3CB371" "Factorium: awaiting or undergoing product planning"
create_label "factorium:architect" "4682B4" "Factorium: awaiting or undergoing architectural design"
create_label "factorium:engineer"  "CD853F" "Factorium: awaiting or undergoing implementation"
create_label "factorium:review"    "DC143C" "Factorium: awaiting or undergoing review/audit"
create_label "factorium:graveyard" "696969" "Factorium: rejected; archived for potential necromancy"
create_label "factorium:complete"  "228B22" "Factorium: PR merged; pipeline finished"

echo ""
echo "=== Status Labels (mutually exclusive) ==="
create_label "status:unclaimed"    "EDEDED" "Available for pickup by the appropriate stage"
create_label "status:claimed"      "0075CA" "Assigned to an agent, work in progress"
create_label "status:blocked"      "E4E669" "Waiting on a dependency or external input"
create_label "status:needs-rework" "FFA500" "Returned from a later stage with rework notes"
create_label "status:passed"       "0E8A16" "Stage complete; ready for the next stage"

echo ""
echo "=== Priority Labels (optional) ==="
create_label "priority:critical"   "B60205" "Critical priority"
create_label "priority:high"       "D93F0B" "High priority"
create_label "priority:normal"     "FBCA04" "Normal priority"
create_label "priority:low"        "C2E0C6" "Low priority"

echo ""
echo "=== Metadata Labels (additive) ==="
create_label "has:dependencies"       "BFD4F2" "This issue depends on other issues"
create_label "review-requested"       "FF69B4" "A stage has requested Gremlin review before advancing"
create_label "necromancy-candidate"   "4B0082" "A graveyard item flagged for potential revival"

echo ""
echo "Done. All Factorium labels are ready."
