# Wizards plugin marketplace tasks

plugin_json := "plugins/conclave/.claude-plugin/plugin.json"
marketplace_json := ".claude-plugin/marketplace.json"

# Show available recipes
default:
    @just --list

# Bump the plugin version interactively
bump:
    #!/usr/bin/env bash
    set -euo pipefail

    current=$(grep '"version"' {{plugin_json}} | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    echo ""
    echo "Current version: $current"
    echo ""

    # Parse current version components
    IFS='.' read -r cur_major cur_minor cur_patch <<< "$current"

    while true; do
        read -rp "Enter new version: " new_version

        # Validate semver format
        if ! echo "$new_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
            echo ""
            echo "Invalid format. Version must be MAJOR.MINOR.PATCH (e.g., 1.2.0)"
            echo ""
            continue
        fi

        IFS='.' read -r new_major new_minor new_patch <<< "$new_version"

        # Determine what kind of bump this is
        if [ "$new_major" -gt "$cur_major" ]; then
            bump_type="MAJOR"
            bump_desc="Breaking change — skills may behave differently, be renamed, or removed."
        elif [ "$new_major" -eq "$cur_major" ] && [ "$new_minor" -gt "$cur_minor" ]; then
            bump_type="MINOR"
            bump_desc="New functionality — new skills, new agents, or new capabilities added. Existing skills still work as before."
        elif [ "$new_major" -eq "$cur_major" ] && [ "$new_minor" -eq "$cur_minor" ] && [ "$new_patch" -gt "$cur_patch" ]; then
            bump_type="PATCH"
            bump_desc="Bug fix or small tweak — prompt improvements, validator fixes, doc updates. No new features."
        elif [ "$new_version" = "$current" ]; then
            echo ""
            echo "That's the current version. Enter a different one."
            echo ""
            continue
        else
            echo ""
            echo "New version ($new_version) is lower than current ($current). Versions should go up."
            echo ""
            continue
        fi

        echo ""
        echo "┌─────────────────────────────────────────────────────┐"
        echo "│  Version bump: $current → $new_version"
        printf "│  Type: %-45s│\n" "$bump_type"
        echo "├─────────────────────────────────────────────────────┤"
        echo "│  Semver quick reference:                            │"
        printf "│    ${cur_major}.x.x → %s.x.x  MAJOR = breaking changes        │\n" "$((cur_major + 1))"
        printf "│    ${cur_major}.${cur_minor}.x → ${cur_major}.%s.x  MINOR = new features, backward ok │\n" "$((cur_minor + 1))"
        printf "│    ${cur_major}.${cur_minor}.${cur_patch} → ${cur_major}.${cur_minor}.%s  PATCH = fixes only, nothing new    │\n" "$((cur_patch + 1))"
        echo "├─────────────────────────────────────────────────────┤"
        printf "│  %-51s│\n" "$bump_desc"
        echo "└─────────────────────────────────────────────────────┘"
        echo ""

        read -rp "Confirm $current → $new_version? [y/N] " confirm
        case "$confirm" in
            [Yy]|[Yy][Ee][Ss])
                break
                ;;
            *)
                echo ""
                echo "OK, enter a different version."
                echo ""
                continue
                ;;
        esac
    done

    # Write version to both files
    sed -i '' "s/\"version\": *\"$current\"/\"version\": \"$new_version\"/" {{plugin_json}}
    sed -i '' "s/\"version\": *\"$current\"/\"version\": \"$new_version\"/" {{marketplace_json}}

    echo ""
    echo "Updated version to $new_version in:"
    echo "  {{plugin_json}}"
    echo "  {{marketplace_json}}"
    echo ""

    read -rp "Stage these files into your current commit? [y/N] " stage
    case "$stage" in
        [Yy]|[Yy][Ee][Ss])
            git add {{plugin_json}} {{marketplace_json}}
            echo ""
            echo "Staged. Version files will be included in your next commit."
            ;;
        *)
            echo ""
            echo "Not staged. Run 'git add {{plugin_json}} {{marketplace_json}}' when ready."
            ;;
    esac

# Run all validators
validate:
    bash scripts/validate.sh

# Sync shared content to all multi-agent SKILL.md files
sync:
    bash scripts/sync-shared-content.sh
