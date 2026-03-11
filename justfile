# Wizards plugin marketplace tasks

plugin_json := "plugins/conclave/.claude-plugin/plugin.json"
marketplace_json := ".claude-plugin/marketplace.json"

# Show available recipes
default:
    @just --list

# Show the current plugin version
get +what:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{what}}" in
        version)
            version=$(grep '"version"' {{plugin_json}} | sed 's/.*"version": *"\([^"]*\)".*/\1/')
            echo "$version"
            ;;
        *)
            echo "Unknown property: {{what}}"
            echo "Available: version"
            exit 1
            ;;
    esac

# Set the plugin version: just set version 1.2.0 [--noninteractive]
set +args:
    #!/usr/bin/env bash
    set -euo pipefail

    # Parse args: first positional is the property, second is the value, flags anywhere
    property=""
    value=""
    noninteractive=0
    for arg in {{args}}; do
        case "$arg" in
            --noninteractive) noninteractive=1 ;;
            *)
                if [ -z "$property" ]; then
                    property="$arg"
                elif [ -z "$value" ]; then
                    value="$arg"
                else
                    echo "Too many arguments. Usage: just set version 1.2.0 [--noninteractive]"
                    exit 1
                fi
                ;;
        esac
    done

    if [ "$property" != "version" ]; then
        echo "Unknown property: $property"
        echo "Available: version"
        exit 1
    fi

    current=$(grep '"version"' {{plugin_json}} | sed 's/.*"version": *"\([^"]*\)".*/\1/')

    # If no value provided, prompt for it
    if [ -z "$value" ]; then
        echo ""
        echo "Current version: $current"
        echo ""
        read -rp "Enter new version: " value
    fi

    # Strip leading 'v' if present
    value="${value#v}"

    # Validate semver format
    if ! echo "$value" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "Invalid format. Version must be MAJOR.MINOR.PATCH (e.g., 1.2.0)"
        exit 1
    fi

    if [ "$value" = "$current" ]; then
        echo "Already at $current"
        exit 0
    fi

    IFS='.' read -r cur_major cur_minor cur_patch <<< "$current"
    IFS='.' read -r new_major new_minor new_patch <<< "$value"

    # Determine bump type
    if [ "$new_major" -gt "$cur_major" ]; then
        bump_type="MAJOR"
        bump_desc="Breaking change — skills may behave differently, be renamed, or removed."
    elif [ "$new_major" -eq "$cur_major" ] && [ "$new_minor" -gt "$cur_minor" ]; then
        bump_type="MINOR"
        bump_desc="New functionality — new skills, new agents, or new capabilities added. Existing skills still work as before."
    elif [ "$new_major" -eq "$cur_major" ] && [ "$new_minor" -eq "$cur_minor" ] && [ "$new_patch" -gt "$cur_patch" ]; then
        bump_type="PATCH"
        bump_desc="Bug fix or small tweak — prompt improvements, validator fixes, doc updates. No new features."
    else
        echo "New version ($value) is not higher than current ($current). Versions should go up."
        exit 1
    fi

    # Confirmation (skip with --noninteractive)
    if [ "$noninteractive" -eq 0 ]; then
        echo ""
        echo "┌─────────────────────────────────────────────────────┐"
        echo "│  Version bump: $current → $value"
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

        while true; do
            read -rp "Confirm $current → $value? [y/N] " confirm
            case "$confirm" in
                [Yy]|[Yy][Ee][Ss])
                    break
                    ;;
                [Nn]|[Nn][Oo]|"")
                    echo ""
                    read -rp "Enter new version (or ctrl-c to cancel): " value
                    value="${value#v}"
                    if ! echo "$value" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
                        echo "Invalid format. Version must be MAJOR.MINOR.PATCH (e.g., 1.2.0)"
                        exit 1
                    fi
                    continue
                    ;;
            esac
        done
    fi

    # Write version to both files
    sed -i '' "s/\"version\": *\"$current\"/\"version\": \"$value\"/" {{plugin_json}}
    sed -i '' "s/\"version\": *\"$current\"/\"version\": \"$value\"/" {{marketplace_json}}

    echo ""
    echo "Updated version to $value in:"
    echo "  {{plugin_json}}"
    echo "  {{marketplace_json}}"

    # Offer to stage (skip with --noninteractive)
    if [ "$noninteractive" -eq 0 ]; then
        echo ""
        read -rp "Stage these files for your next commit? [y/N] " stage
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
    fi

# Bump version by type: just bump version major|minor|patch [--noninteractive]
bump +args:
    #!/usr/bin/env bash
    set -euo pipefail

    property=""
    bump_type=""
    noninteractive=0
    for arg in {{args}}; do
        case "$arg" in
            --noninteractive) noninteractive=1 ;;
            *)
                if [ -z "$property" ]; then
                    property="$arg"
                elif [ -z "$bump_type" ]; then
                    bump_type="$arg"
                else
                    echo "Too many arguments. Usage: just bump version major|minor|patch [--noninteractive]"
                    exit 1
                fi
                ;;
        esac
    done

    if [ "$property" != "version" ]; then
        echo "Unknown property: $property"
        echo "Available: version"
        exit 1
    fi

    if [ -z "$bump_type" ]; then
        echo "Usage: just bump version major|minor|patch [--noninteractive]"
        exit 1
    fi

    current=$(grep '"version"' {{plugin_json}} | sed 's/.*"version": *"\([^"]*\)".*/\1/')
    IFS='.' read -r cur_major cur_minor cur_patch <<< "$current"

    case "$bump_type" in
        major) new_version="$((cur_major + 1)).0.0" ;;
        minor) new_version="${cur_major}.$((cur_minor + 1)).0" ;;
        patch) new_version="${cur_major}.${cur_minor}.$((cur_patch + 1))" ;;
        *)
            echo "Invalid bump type: $bump_type"
            echo "Must be one of: major, minor, patch"
            exit 1
            ;;
    esac

    flags=""
    if [ "$noninteractive" -eq 1 ]; then
        flags="--noninteractive"
    fi

    just set version "$new_version" $flags

# Run all validators
validate:
    bash scripts/validate.sh

# Sync shared content to all multi-agent SKILL.md files
sync:
    bash scripts/sync-shared-content.sh
