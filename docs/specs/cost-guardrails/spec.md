---
title: "Cost Guardrails"
status: "ready_for_implementation"
priority: "P2"
category: "developer-experience"
approved_by: "product-skeptic"
created: "2026-02-14"
updated: "2026-02-14"
---

# Cost Guardrails Specification

## Summary

Add a `--light` flag to all three skills (`/plan-product`, `/build-product`, `/review-quality`) that reduces cost by downgrading or removing non-critical agents. After every invocation, write a cost summary file to `docs/progress/`. The Skeptic and Security Auditor are never downgraded. Quality gates, orchestration flow, and communication protocols are unchanged in lightweight mode.

## 1. Lightweight Mode Definition Per Skill

### `/plan-product`

| Agent | Standard | Lightweight |
|-------|----------|-------------|
| Product Owner (lead) | Opus | Opus |
| Researcher | Opus | **Sonnet** |
| Software Architect | Opus | **Sonnet** |
| DBA | Opus | **REMOVED** |
| Product Skeptic | Opus | Opus (NEVER downgraded) |

- **Agent count**: 5 -> 4
- **Opus count**: 5 -> 2
- **Estimated savings**: ~56%

The DBA is removed because a Sonnet-level DBA produces low-confidence data models that still consume a full context window. The Architect absorbs basic data model considerations in lightweight mode.

### `/build-product`

| Agent | Standard | Lightweight |
|-------|----------|-------------|
| Tech Lead (lead) | Opus | Opus |
| Impl Architect | Opus | **Sonnet** |
| Backend Engineer | Sonnet | Sonnet |
| Frontend Engineer | Sonnet | Sonnet |
| Quality Skeptic | Opus | Opus (NEVER downgraded) |

- **Agent count**: 5 -> 5 (unchanged)
- **Opus count**: 3 -> 2
- **Estimated savings**: ~24%

The Impl Architect is downgraded to Sonnet, not removed. Removing it would force the Tech Lead to absorb implementation planning, violating the delegate mode principle. Translating an existing spec into file-by-file work items is execution-oriented work that Sonnet handles well.

### `/review-quality`

| Mode | Standard Agents | Lightweight |
|------|----------------|-------------|
| `security` | Security Auditor (Opus), Ops Skeptic (Opus) | NO CHANGE |
| `performance` | Test Engineer (Sonnet), Ops Skeptic (Opus) | NO CHANGE |
| `deploy` | DevOps Eng (Sonnet), Security Auditor (Opus), Ops Skeptic (Opus) | NO CHANGE |
| `regression` | Test Engineer (Sonnet), Ops Skeptic (Opus) | NO CHANGE |

- **Estimated savings**: 0%

All modes are unchanged in lightweight mode. The Security Auditor must not be downgraded or removed. The skill already uses conditional spawning and minimal agent counts. Users who want cheaper quality checks should scope invocations more narrowly rather than reducing agents.

## 2. SKILL.md Changes

Each SKILL.md requires exactly two additions.

### Change 1: Lightweight Mode Section

Add after the "Determine Mode" section in each SKILL.md:

#### plan-product/SKILL.md

```markdown
## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight mode:
- Output to user: "Lightweight mode enabled: reduced agent team. Quality gates maintained. Suitable for exploratory/draft work."
- Researcher: spawn with model **sonnet** instead of opus
- Software Architect: spawn with model **sonnet** instead of opus
- DBA: do NOT spawn
- Product Skeptic: unchanged (ALWAYS Opus)
- All orchestration flow, quality gates, and communication protocols remain identical
```

#### build-product/SKILL.md

```markdown
## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight mode:
- Output to user: "Lightweight mode enabled: reduced agent team. Quality gates maintained. Suitable for exploratory/draft work."
- Impl Architect: spawn with model **sonnet** instead of opus
- Backend Engineer, Frontend Engineer: unchanged (already Sonnet)
- Quality Skeptic: unchanged (ALWAYS Opus)
- All orchestration flow, quality gates, and communication protocols remain identical
```

#### review-quality/SKILL.md

```markdown
## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag but make no changes to agent selection:
- Output to user: "Lightweight mode: no changes applied. This skill is already at minimum viable configuration."
- All agents, models, and orchestration remain identical to standard mode
```

### Change 2: Cost Summary Step

Add as the final step in the "Orchestration Flow" section of each SKILL.md:

```markdown
N. **Team Lead only**: Write cost summary to `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
```

### Argument Handling

The `--light` flag is a prefix modifier parsed before mode detection:

1. Check if `$ARGUMENTS` begins with `--light`
2. If yes: strip `--light` from `$ARGUMENTS`, set lightweight mode flag
3. Process remaining `$ARGUMENTS` for mode detection as normal
4. During agent spawning, apply lightweight mode agent/model changes

This is simple string prefix matching. No argument parser is needed.

## 3. Cost Summary Format

After every skill invocation, the Team Lead writes a cost summary file.

### File Naming

`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`

Examples:
- `plan-product-auth-20260214T1730-cost-summary.md`
- `build-product-billing-20260214T1800-cost-summary.md`
- `review-quality-general-20260214T1900-cost-summary.md`

The timestamp slug ensures no write conflicts between invocations. If the feature name is not determinable, use "general" as the feature slug.

### File Format

```yaml
---
skill: "plan-product"
mode: "new"
lightweight: false
feature: "user-authentication"
timestamp: "2026-02-14T17:30:00Z"
---

## Invocation Summary

| Agent | Model | Role | Spawned |
|-------|-------|------|---------|
| Product Owner | opus | lead | yes |
| Researcher | opus | researcher | yes |
| Software Architect | opus | architect | yes |
| DBA | opus | dba | yes |
| Product Skeptic | opus | skeptic | yes |

- **Total agents spawned**: 5
- **Opus agents**: 5
- **Sonnet agents**: 0
- **Estimated relative cost**: High (5 Opus)
- **Skeptic rejections**: 1
- **Outcome**: Spec produced at docs/specs/user-authentication/spec.md
```

### Relative Cost Labels

- **High**: 3+ Opus agents
- **Medium**: 1-2 Opus agents
- **Low**: 0 Opus agents (all Sonnet)

These labels are deliberately imprecise. Exact cost depends on conversation length, which Claude Code does not expose.

## 4. README Updates

Add a "Lightweight Mode" subsection inside the existing "Cost Considerations" section:

```markdown
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
```

Update the `argument-hint` in each SKILL.md frontmatter to include `--light`:

- plan-product: `"[--light] [new <idea> | review <spec-name> | reprioritize | (empty for general review)]"`
- build-product: `"[--light] [<spec-name> | review | (empty for next item)]"`
- review-quality: `"[--light] [security <scope> | performance <scope> | deploy <feature> | regression]"`

## 5. Non-Negotiable Constraints

1. **The Skeptic is NEVER downgraded.** All Skeptics remain Opus in all modes. This is the core quality gate.
2. **The Security Auditor is NEVER downgraded or removed.** Security analysis requires deep reasoning.
3. **`--light` does not change orchestration flow.** Same gates, same communication protocol, same checkpoint behavior. Only agent roster and model assignments change.
4. **No runtime cost tracking.** Claude Code does not expose token counts. Proxy metrics (agent count, model tier, rejection count) are the only available signals.
5. **No budget limits or caps.** The 3-rejection escalation rule remains the only automatic cost control.
6. **Standard mode is the default.** Users must explicitly opt in to lightweight mode.

## 6. Success Criteria

1. Users can add `--light` to any skill invocation and see reduced Opus agent usage for `/plan-product` and `/build-product`.
2. The `--light` flag is silently accepted (with informational message) for `/review-quality` even though it has no effect.
3. Every skill invocation produces a cost summary file in `docs/progress/` with agent counts, model tiers, and relative cost label.
4. The Skeptic remains Opus in all modes. The Security Auditor remains Opus in all modes.
5. All existing orchestration flows, quality gates, and communication protocols work identically in lightweight mode.
6. The README documents lightweight mode with per-skill savings tables.
7. Each SKILL.md's `argument-hint` includes `[--light]` as an optional prefix.

## 7. Files to Modify

| File | Change |
|------|--------|
| `plugins/conclave/skills/plan-product/SKILL.md` | Add Lightweight Mode section, cost summary step, update argument-hint |
| `plugins/conclave/skills/build-product/SKILL.md` | Add Lightweight Mode section, cost summary step, update argument-hint |
| `plugins/conclave/skills/review-quality/SKILL.md` | Add Lightweight Mode section, cost summary step, update argument-hint |
| `README.md` | Add Lightweight Mode subsection to Cost Considerations |

No new files are created (cost summary files are created at runtime by the Team Lead).
