---
feature: "persona-system-activation"
team: "build-implementation"
type: "cost-summary"
created: "2026-03-10"
---

# Cost Summary: build-implementation — persona-system-activation

## Agents Spawned

| Agent                       | Model  | Role                                                       |
| --------------------------- | ------ | ---------------------------------------------------------- |
| quality-skeptic (pre-impl)  | opus   | Pre-implementation review — APPROVED                       |
| backend-eng                 | sonnet | Steps 1-3 (infrastructure) + 6 SKILL.md files (12 prompts) |
| frontend-eng                | sonnet | 5 SKILL.md files (21 prompts)                              |
| quality-skeptic (post-impl) | opus   | Post-implementation review — APPROVED                      |

## Issues Discovered During Implementation

1. **Bash parameter expansion bug**: `${slug:-{skill-skeptic}}` produces
   trailing `}` when the variable is set, because bash closes the `${...}` at
   the first `}` after the default word. Fixed with intermediate variables:
   `local default_slug='{skill-skeptic}'; echo "${slug:-$default_slug}"`

2. **Corrupted sync recovery**: First sync ran before the bash bug was caught,
   corrupting all 12 SKILL.md protocol blocks with trailing `}` in skeptic
   names. Recovery required making `extract_skeptic_names` more robust: broader
   slug regex, brace stripping from display, placeholder filtering, and slug
   derivation from display name.

## Key Decisions

1. Used intermediate variables for bash parameter expansion defaults — standard
   pattern for defaults containing braces
2. Made `extract_skeptic_names` resilient to corrupted input — derives slug from
   display name when slug extraction fails
3. Fixed 3 pre-existing validator failures in frontmatter (roadmap effort value,
   progress team name, progress status)
