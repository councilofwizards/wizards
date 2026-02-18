---
feature: "cost-guardrails"
team: "build-product"
agent: "impl-architect"
phase: "planning"
status: "awaiting_review"
last_action: "Implementation plan drafted with exact edit locations"
updated: "2026-02-14T18:00:00Z"
---

# Cost Guardrails — Implementation Plan

## Overview

4 files to modify. 10 total edits. No new files created (cost summary files are runtime artifacts).

---

## Edit Order

1. plan-product/SKILL.md (3 edits: argument-hint, lightweight mode section, cost summary step)
2. build-product/SKILL.md (3 edits: argument-hint, lightweight mode section, cost summary step)
3. review-quality/SKILL.md (3 edits: argument-hint, lightweight mode section, cost summary step)
4. README.md (1 edit: lightweight mode subsection)

---

## File 1: `plugins/conclave/skills/plan-product/SKILL.md`

### Edit 1A — Update argument-hint (line 7)

**Old text:**
```
argument-hint: "[new <idea> | review <spec-name> | reprioritize | (empty for general review)]"
```

**New text:**
```
argument-hint: "[--light] [new <idea> | review <spec-name> | reprioritize | (empty for general review)]"
```

### Edit 1B — Add Lightweight Mode section after "Determine Mode"

Insert AFTER the end of the "Determine Mode" section (after line 76: `- **"reprioritize"**: Full roadmap reassessment with evidence.`) and BEFORE the "Spawn the Team" section (line 78: `## Spawn the Team`).

**Old text (surrounding context):**
```
- **"reprioritize"**: Full roadmap reassessment with evidence.

## Spawn the Team
```

**New text:**
```
- **"reprioritize"**: Full roadmap reassessment with evidence.

## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight mode:
- Output to user: "Lightweight mode enabled: reduced agent team. Quality gates maintained. Suitable for exploratory/draft work."
- Researcher: spawn with model **sonnet** instead of opus
- Software Architect: spawn with model **sonnet** instead of opus
- DBA: do NOT spawn
- Product Skeptic: unchanged (ALWAYS Opus)
- All orchestration flow, quality gates, and communication protocols remain identical

## Spawn the Team
```

### Edit 1C — Add cost summary step to Orchestration Flow

Insert after step 6 (line 118: `6. **Team Lead only**: Update `docs/roadmap/` with new/changed items`) in the Orchestration Flow section.

**Old text:**
```
6. **Team Lead only**: Update `docs/roadmap/` with new/changed items

## Quality Gate
```

**New text:**
```
6. **Team Lead only**: Update `docs/roadmap/` with new/changed items
7. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

## Quality Gate
```

---

## File 2: `plugins/conclave/skills/build-product/SKILL.md`

### Edit 2A — Update argument-hint (line 7)

**Old text:**
```
argument-hint: "[<spec-name> | review | (empty for next item)]"
```

**New text:**
```
argument-hint: "[--light] [<spec-name> | review | (empty for next item)]"
```

### Edit 2B — Add Lightweight Mode section after "Determine Mode"

Insert AFTER the end of the "Determine Mode" section (after line 87: `- **"review"**: Review current implementation status and identify blockers.`) and BEFORE the "Spawn the Team" section (line 89: `## Spawn the Team`).

**Old text (surrounding context):**
```
- **"review"**: Review current implementation status and identify blockers.

## Spawn the Team
```

**New text:**
```
- **"review"**: Review current implementation status and identify blockers.

## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight mode:
- Output to user: "Lightweight mode enabled: reduced agent team. Quality gates maintained. Suitable for exploratory/draft work."
- Impl Architect: spawn with model **sonnet** instead of opus
- Backend Engineer, Frontend Engineer: unchanged (already Sonnet)
- Quality Skeptic: unchanged (ALWAYS Opus)
- All orchestration flow, quality gates, and communication protocols remain identical

## Spawn the Team
```

### Edit 2C — Add cost summary step to Orchestration Flow

Insert after step 7 (line 129: `7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md``) in the Orchestration Flow section.

**Old text:**
```
7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md`

## Critical Rules
```

**New text:**
```
7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md`
8. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

## Critical Rules
```

---

## File 3: `plugins/conclave/skills/review-quality/SKILL.md`

### Edit 3A — Update argument-hint (line 6)

**Old text:**
```
argument-hint: "[security <scope> | performance <scope> | deploy <feature> | regression]"
```

**New text:**
```
argument-hint: "[--light] [security <scope> | performance <scope> | deploy <feature> | regression]"
```

### Edit 3B — Add Lightweight Mode section after "Determine Mode"

Insert AFTER the end of the "Determine Mode" section (after line 76: `- **"regression"**: Full regression test sweep. Spawn test-eng + ops-skeptic.`) and BEFORE the "Spawn the Team" section (line 78: `## Spawn the Team`).

**Old text (surrounding context):**
```
- **"regression"**: Full regression test sweep. Spawn test-eng + ops-skeptic.

## Spawn the Team
```

**New text:**
```
- **"regression"**: Full regression test sweep. Spawn test-eng + ops-skeptic.

## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag but make no changes to agent selection:
- Output to user: "Lightweight mode: no changes applied. This skill is already at minimum viable configuration."
- All agents, models, and orchestration remain identical to standard mode

## Spawn the Team
```

### Edit 3C — Add cost summary step to Orchestration Flow

Insert after step 7 (line 124: `7. **QA Lead only**: Synthesize all approved findings into `docs/progress/{feature}-quality.md``) in the Orchestration Flow section.

**Old text:**
```
7. **QA Lead only**: Synthesize all approved findings into `docs/progress/{feature}-quality.md`

## Critical Rules
```

**New text:**
```
7. **QA Lead only**: Synthesize all approved findings into `docs/progress/{feature}-quality.md`
8. **QA Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

## Critical Rules
```

---

## File 4: `README.md`

### Edit 4A — Add Lightweight Mode subsection to Cost Considerations

Insert AFTER the existing Cost Considerations paragraph (after line 168: `Start with one team at a time. Use `/plan-product` to scope work cheaply in plan mode, then hand specs to `/build-product` for parallel implementation.`) and BEFORE the "Customization" section (line 170: `## Customization`).

**Old text:**
```
Start with one team at a time. Use `/plan-product` to scope work cheaply in plan mode, then hand specs to `/build-product` for parallel implementation.

## Customization
```

**New text:**
```
Start with one team at a time. Use `/plan-product` to scope work cheaply in plan mode, then hand specs to `/build-product` for parallel implementation.

### Lightweight Mode

Add `--light` to any skill invocation for reduced cost:

| Skill | Standard | Lightweight | Est. Savings |
|-------|----------|-------------|--------------|
| `/plan-product` | 5 agents (5 Opus) | 4 agents (2 Opus, 2 Sonnet) | ~56% |
| `/build-product` | 5 agents (3 Opus, 2 Sonnet) | 5 agents (2 Opus, 3 Sonnet) | ~24%* |
| `/review-quality` | 2-3 agents | No change | 0% |

Savings are approximate, based on Opus being ~5x the cost of Sonnet per token.
*build-product already uses Sonnet for execution agents, so the savings ceiling is lower.

The Skeptic is NEVER downgraded — quality gates remain at full strength in lightweight mode.
The Security Auditor is NEVER downgraded or removed — security analysis requires Opus-level reasoning.

Examples:
- `/plan-product --light new billing` — draft-quality planning at reduced cost
- `/build-product --light auth` — build with Sonnet-level implementation architect

Use lightweight mode for exploratory/draft work. Use standard mode for production-critical planning and implementation.

## Customization
```

---

## Verification Checklist

After all edits, verify:
- [ ] Each SKILL.md frontmatter `argument-hint` starts with `[--light]`
- [ ] Each SKILL.md has a "Lightweight Mode" section between "Determine Mode" and "Spawn the Team"
- [ ] Each SKILL.md's Orchestration Flow has a final cost summary step
- [ ] README.md has a "Lightweight Mode" subsection inside "Cost Considerations"
- [ ] plan-product lightweight mode: Researcher->Sonnet, Architect->Sonnet, DBA->removed, Skeptic->unchanged
- [ ] build-product lightweight mode: Impl Architect->Sonnet, others->unchanged
- [ ] review-quality lightweight mode: no changes, informational message only
- [ ] No existing text is altered beyond the targeted insertion points
