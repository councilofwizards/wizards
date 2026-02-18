---
title: "Automated Testing Pipeline"
status: "ready_for_implementation"
priority: "P2"
category: "quality-reliability"
approved_by: "product-skeptic"
created: "2026-02-18"
updated: "2026-02-18"
---

# Automated Testing Pipeline Specification

## Summary

Add a CI validation pipeline that structurally validates SKILL.md files, roadmap frontmatter, spec frontmatter, and shared content consistency across skills. The pipeline uses bash scripts with standard Unix tools, runs in GitHub Actions on every push and PR, and completes in under 30 seconds with no external dependencies.

## Problem

The Council of Wizards plugin has no automated validation. SKILL.md files are complex markdown documents with YAML frontmatter, required sections, spawn definitions, shared content blocks (Shared Principles, Communication Protocol), and cross-file consistency requirements. Problems that should be caught automatically:

1. **Structural regressions**: A SKILL.md edit could remove a required section (e.g., Failure Recovery), break YAML frontmatter, or delete a spawn definition. Nothing catches this today.
2. **Shared content drift**: P2-05 established `<!-- BEGIN SHARED -->` markers and byte-identity requirements for Shared Principles across 3 files. Without CI, drift is discovered only when a human manually diffs the files.
3. **Roadmap metadata corruption**: ADR-001 defines a strict frontmatter schema for roadmap files (status enum, priority format, required fields). Invalid metadata breaks agent parsing during `/plan-product` and `/build-product`.
4. **Spec frontmatter inconsistency**: Spec files follow `docs/specs/_template.md` but nothing enforces the schema.

Manual validation is unreliable and scales poorly. As the skill catalog grows, so does the surface area for silent regressions.

## Solution

### 1. Script Architecture

A single entry-point script (`scripts/validate.sh`) that dispatches to focused validation modules. Each module validates one concern and can run independently.

```
scripts/
  validate.sh                    # Entry point: runs all validators, aggregates results
  validators/
    skill-structure.sh           # SKILL.md structural validation
    skill-shared-content.sh      # Shared content deduplication checks (P2-05)
    roadmap-frontmatter.sh       # Roadmap file frontmatter validation (ADR-001)
    spec-frontmatter.sh          # Spec file frontmatter validation
```

**Language choice: Bash with standard Unix tools** (`grep`, `sed`, `awk`, `diff`, `sort`).

Rationale:
- No runtime dependencies to install (bash, grep, sed, awk are available on every CI runner and developer machine)
- The project has no `package.json`, `requirements.txt`, or any build system -- adding Node.js or Python for file-content grep checks would be over-engineering
- Validation logic is pattern matching on text files, which is exactly what shell tools are designed for
- Keeps CI fast (no dependency installation step)

### 2. Test Categories

#### Category A: SKILL.md Structural Validation (`skill-structure.sh`)

For each file matching `plugins/*/skills/*/SKILL.md`:

**A1. YAML Frontmatter**
- File starts with `---` on line 1
- Frontmatter block is closed by a second `---`
- Required fields present: `name`, `description`, `argument-hint`
- `name` value matches the parent directory name (e.g., `plan-product/SKILL.md` must have `name: plan-product`)

**A2. Required Sections**
Each SKILL.md must contain all of the following H2 headings. Where alternatives are listed, the file must contain **at least one of** the listed variants.

Required (exact match):
- `## Setup`
- `## Write Safety`
- `## Checkpoint Protocol`
- `## Determine Mode`
- `## Lightweight Mode`
- `## Spawn the Team`
- `## Orchestration Flow`
- `## Failure Recovery`
- `## Shared Principles` (inside shared markers)
- `## Communication Protocol` (inside shared markers)

Required (at least one of the listed variants):
- At least one of: `## Critical Rules` OR `## Quality Gate`
- At least one of: `## Teammate Spawn Prompts` OR `## Teammates to Spawn`

**A3. Spawn Definitions**
- Each H3 under "Spawn the Team" (or equivalent) must contain:
  - A `**Name**:` field with a backtick-quoted agent name
  - A `**Model**:` field with value `opus` or `sonnet`
  - A `**Subagent type**:` field with a valid type (e.g., `general-purpose`)

**A4. Shared Content Markers**
- File contains `<!-- BEGIN SHARED: principles -->` and `<!-- END SHARED: principles -->`
- File contains `<!-- BEGIN SHARED: communication-protocol -->` and `<!-- END SHARED: communication-protocol -->`
- Begin/end markers are properly paired (begin before end, no nesting)

#### Category B: Shared Content Deduplication (`skill-shared-content.sh`)

Implements the CI validation contract defined in P2-05 spec, Section 5.

**B1. Shared Principles -- Byte Identity**
1. Find all files matching `plugins/*/skills/*/SKILL.md`
2. For each file, extract content between `<!-- BEGIN SHARED: principles -->` and `<!-- END SHARED: principles -->` (inclusive of markers)
3. Compare all extracted blocks -- must be byte-identical
4. On failure, output a unified diff showing exactly which file diverged and what changed

**B2. Communication Protocol -- Structural Equivalence**
1. Extract content between `<!-- BEGIN SHARED: communication-protocol -->` and `<!-- END SHARED: communication-protocol -->` markers
2. Normalize all 6 skeptic name variations before comparison. The Communication Protocol table has two columns that vary per skill -- the `write()` call in the Action column and the plain-text name in the Target column. Replace all of the following with the placeholder `SKEPTIC_NAME`:
   - Backtick-quoted slug forms: `product-skeptic`, `quality-skeptic`, `ops-skeptic`
   - Plain-text display-name forms: `Product Skeptic`, `Quality Skeptic`, `Ops Skeptic`
3. After normalization, compare blocks -- must be byte-identical
4. On failure, output a diff showing what diverged (with the normalization applied, so intentional skeptic-name variation is not flagged)

**B3. Authoritative Source Marker**
- Every `<!-- BEGIN SHARED: ... -->` marker must be followed by `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->`

#### Category C: Roadmap Frontmatter Validation (`roadmap-frontmatter.sh`)

For each `.md` file in `docs/roadmap/` (excluding `_index.md`):

**C1. Required Fields**
All fields from ADR-001 must be present:
- `title` (non-empty string)
- `status` (one of: `not_started`, `spec_in_progress`, `ready`, `impl_in_progress`, `complete`, `blocked`)
- `priority` (matches pattern `P[1-3]`)
- `category` (non-empty string)
- `effort` (one of: `small`, `medium`, `large`)
- `impact` (one of: `low`, `medium`, `high`)
- `dependencies` (present, array -- may be empty `[]`)
- `created` (matches `YYYY-MM-DD` pattern)
- `updated` (matches `YYYY-MM-DD` pattern)

**C2. Filename Convention**
- Filename matches pattern `P[1-3]-[0-9][0-9]-*.md` (e.g., `P2-04-automated-testing.md`)
- Priority in filename matches `priority` field in frontmatter

#### Category D: Spec Frontmatter Validation (`spec-frontmatter.sh`)

For each `spec.md` file in `docs/specs/*/`:

**D1. Required Fields**
Per `docs/specs/_template.md`:
- `title` (non-empty string)
- `status` (one of: `draft`, `ready_for_review`, `approved`, `ready_for_implementation`)
- `priority` (matches pattern `P[1-3]`)
- `category` (non-empty string)
- `approved_by` (present -- may be empty string for drafts)
- `created` (matches `YYYY-MM-DD` pattern)
- `updated` (matches `YYYY-MM-DD` pattern)

### 3. Error Reporting Format

Every validation failure produces a structured, actionable error message:

```
[FAIL] <category>/<check-id>: <what failed>
  File: <path/to/file>
  Expected: <what was expected>
  Found: <what was actually found>
  Fix: <specific action to resolve>
```

Example:
```
[FAIL] A1/frontmatter: Missing required field "argument-hint"
  File: plugins/conclave/skills/plan-product/SKILL.md
  Expected: YAML frontmatter contains "argument-hint" field
  Found: Field not present in frontmatter block (lines 1-8)
  Fix: Add "argument-hint:" field to the YAML frontmatter

[FAIL] B1/principles-drift: Shared Principles content differs
  File: plugins/conclave/skills/review-quality/SKILL.md
  Expected: Byte-identical to plugins/conclave/skills/plan-product/SKILL.md (authoritative source)
  Found: Content differs (see diff below)
  Fix: Copy Shared Principles from plan-product/SKILL.md to review-quality/SKILL.md
  --- plan-product/SKILL.md (authoritative)
  +++ review-quality/SKILL.md
  @@ -5,7 +5,7 @@
  -4. **Minimal, clean solutions.** Write the least code...
  +4. **Minimal clean solutions.** Write the least code...
```

Passing checks produce a single-line summary:
```
[PASS] A1/frontmatter: All SKILL.md files have valid YAML frontmatter (3 files checked)
```

The entry-point script (`validate.sh`) prints a final summary:
```
Validation complete: 12 passed, 0 failed
```
Or on failure:
```
Validation complete: 10 passed, 2 failed
```
And exits with code 1 if any check failed, code 0 if all passed.

### 4. GitHub Actions Workflow

```yaml
# .github/workflows/validate.yml
name: Validate Plugin Structure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run validation
        run: bash scripts/validate.sh
```

No dependency installation step. No caching. No matrix builds. The workflow checks out the code and runs the script. Target: completes in under 10 seconds (validation is text processing on a handful of small files).

### 5. Entry-Point Script Design

`scripts/validate.sh` orchestrates all validators:

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

passed=0
failed=0

run_validator() {
    local name="$1"
    local script="$SCRIPT_DIR/validators/$name"
    if bash "$script" "$REPO_ROOT"; then
        : # pass count incremented inside validators via stdout parsing
    else
        : # fail count incremented inside validators via stdout parsing
    fi
}

# Run all validators
run_validator "skill-structure.sh"
run_validator "skill-shared-content.sh"
run_validator "roadmap-frontmatter.sh"
run_validator "spec-frontmatter.sh"

# Parse output and print summary
# (actual implementation will count [PASS] and [FAIL] lines)
```

Each validator script:
1. Accepts the repo root as argument `$1`
2. Prints `[PASS]` or `[FAIL]` lines to stdout
3. Exits 0 if all its checks pass, 1 if any fail

The entry-point aggregates all output, counts results, prints the summary, and exits with the appropriate code.

**Implementation note (from skeptic review):** The `set -e` in the entry-point script must not cause early exit when a validator returns non-zero. The `run_validator` function handles this via the `if` construct, which suppresses `set -e` for the subcommand. This is intentional and correct.

## Constraints

1. **No Claude API calls.** Tests validate file structure and content consistency only. Agent behavior testing is out of scope.
2. **No external dependencies.** Scripts use only bash and standard Unix tools (`grep`, `sed`, `awk`, `diff`, `sort`, `cut`). No package managers, no language runtimes beyond what ships with `ubuntu-latest`.
3. **Under 30 seconds.** The full validation suite must complete in under 30 seconds on a GitHub Actions `ubuntu-latest` runner. Actual expected time: under 10 seconds.
4. **Actionable errors.** Every `[FAIL]` message includes the file path, what was expected, what was found, and a specific fix instruction. Developers should never need to guess what went wrong.
5. **No false positives.** Each check validates a concrete, documented requirement (from SKILL.md conventions, ADR-001, P2-05 spec, or `_template.md`). No subjective or heuristic checks.
6. **Idempotent and side-effect-free.** Validation scripts read files only. They never modify the repository.
7. **Independent validators.** Each validator script runs independently. Failure in one does not skip the others. The entry-point always runs all validators and reports all findings.

## Out of Scope

- **Agent behavior testing** -- validating that agents follow instructions requires Claude API calls and is a different problem entirely
- **Markdown rendering validation** -- we validate structure (headings, frontmatter, markers), not rendering quality
- **Content quality checks** -- we validate presence of required sections, not whether their content is good
- **Plugin.json validation** -- the plugin manifest is managed by Claude Code tooling, not by us
- **Progress file validation** -- checkpoint files are transient agent artifacts, not part of the plugin deliverable
- **CLAUDE.md validation** -- the project CLAUDE.md is not part of the plugin structure
- **Cross-repository validation** -- only files in this repository are validated
- **Auto-fix tooling** -- the pipeline reports problems; it does not fix them (auto-fix could be a follow-up)

## Files to Create

| File | Description |
|------|-------------|
| `scripts/validate.sh` | Entry-point script. Runs all validators, aggregates results, prints summary, sets exit code. |
| `scripts/validators/skill-structure.sh` | Category A: SKILL.md structural validation (frontmatter, required sections, spawn definitions, markers). |
| `scripts/validators/skill-shared-content.sh` | Category B: Shared content deduplication (byte-identity for principles, structural equivalence for communication protocol). |
| `scripts/validators/roadmap-frontmatter.sh` | Category C: Roadmap file frontmatter validation per ADR-001 schema. |
| `scripts/validators/spec-frontmatter.sh` | Category D: Spec file frontmatter validation per `_template.md` schema. |
| `.github/workflows/validate.yml` | GitHub Actions workflow: runs `scripts/validate.sh` on push to main and on PRs. |

## Files to Modify

None. This is a purely additive change.

## Success Criteria

1. Running `bash scripts/validate.sh` from the repository root validates all SKILL.md files, roadmap files, and spec files, and exits 0 when everything is valid.
2. Removing a required section (e.g., `## Failure Recovery`) from any SKILL.md causes `skill-structure.sh` to report a `[FAIL]` with the missing section name and file path.
3. Changing one word in the Shared Principles section of `review-quality/SKILL.md` (without changing `plan-product/SKILL.md`) causes `skill-shared-content.sh` to report a `[FAIL]` with a diff showing the divergence.
4. Adding a roadmap file with `status: "invalid_status"` causes `roadmap-frontmatter.sh` to report a `[FAIL]` with the invalid value and the set of valid values.
5. The GitHub Actions workflow runs on every push to `main` and every PR targeting `main`, executing `scripts/validate.sh`.
6. The full validation suite completes in under 30 seconds on a GitHub Actions `ubuntu-latest` runner.
7. Every `[FAIL]` message includes: file path, what was expected, what was found, and a specific fix action.
8. All validators run independently -- a failure in one validator does not prevent others from running.
9. The validation suite passes on the current state of the repository (all existing files are valid).
10. No external dependencies are required -- the scripts run with only bash and standard Unix tools.
