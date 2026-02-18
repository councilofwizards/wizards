---
feature: "automated-testing"
status: "complete"
completed: "2026-02-18"
---

# P2-04: Automated Testing Pipeline -- Implementation Complete

## Summary

Built a complete automated CI validation pipeline using bash scripts with standard Unix tools. Validates SKILL.md structure, shared content consistency (per P2-05), roadmap frontmatter (per ADR-001), and spec frontmatter. Runs in GitHub Actions on every push/PR to main with no external dependencies. All 10 validation checks pass on the current repo.

## Files Created

| File | Category | Description |
|------|----------|-------------|
| `scripts/validate.sh` | Entry point | Runs all 4 validators, aggregates [PASS]/[FAIL] counts, exits non-zero on any failure |
| `scripts/validators/skill-structure.sh` | A: SKILL.md Structure | A1 frontmatter, A2 required sections, A3 spawn definitions, A4 shared markers |
| `scripts/validators/skill-shared-content.sh` | B: Shared Content | B1 principles byte-identity, B2 protocol structural equivalence (skeptic name normalization), B3 authoritative source comments |
| `scripts/validators/roadmap-frontmatter.sh` | C: Roadmap Frontmatter | C1 required fields (9 fields, enum validation), C2 filename convention + priority match |
| `scripts/validators/spec-frontmatter.sh` | D: Spec Frontmatter | D1 required fields (7 fields, enum validation) |
| `.github/workflows/validate.yml` | CI | GitHub Actions workflow, triggers on push/PR to main |

## Files Modified

| File | Change |
|------|--------|
| `docs/specs/project-bootstrap/spec.md` | Added missing YAML frontmatter (pre-dated the template standard) |
| `docs/roadmap/P2-04-automated-testing.md` | Status: not_started -> ready -> impl_in_progress -> complete |
| `docs/roadmap/_index.md` | P2-04 emoji: 🔴 -> 🟢 -> 🔵 -> ✅ |

## Validation Results

```
[PASS] A1/frontmatter (3 files)    [PASS] B1/principles-drift (3 files)
[PASS] A2/required-sections (3)     [PASS] B2/protocol-drift (3 files)
[PASS] A3/spawn-definitions (3)     [PASS] B3/authoritative-source (3 files)
[PASS] A4/shared-markers (3)        [PASS] C1/required-fields (13 files)
                                    [PASS] C2/filename-convention (13 files)
                                    [PASS] D1/required-fields (5 files)

Total: 10 passed, 0 failed
```

## Spec Phase (plan-product)

- Rejected once (2 blocking issues: B2 incomplete skeptic names, A2 ambiguous section requirements)
- Approved on second submission with all 6 skeptic name patterns and unambiguous section lists

## Implementation Phase (build-product)

- **impl-architect**: Created detailed implementation plan covering all 6 files with pseudocode and execution order
- **quality-skeptic**: Pre-implementation review APPROVED with 3 non-blocking observations (process substitution, sub-check IDs in PASS, diff handling)
- **backend-eng**: Implemented validate.sh, skill-structure.sh, skill-shared-content.sh
- **frontend-eng**: Implemented roadmap-frontmatter.sh, spec-frontmatter.sh, validate.yml; fixed project-bootstrap/spec.md missing frontmatter; fixed bash 3.2 incompatibility
- **quality-skeptic**: Post-implementation review APPROVED (team lead stepped in due to agent unresponsiveness)

## Key Design Decisions

- Pure bash + coreutils: no Node.js/Python as originally considered in roadmap item
- Bash 3.2 compatible: no mapfile, no associative arrays (macOS stock bash)
- Process substitution `< <(...)` instead of pipe `| while` for variable scoping
- Skeptic name normalization handles all 6 variants (3 slugs + 3 display names)
