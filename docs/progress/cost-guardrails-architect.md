---
feature: "cost-guardrails"
team: "plan-product"
agent: "architect"
phase: "design"
status: "complete"
last_action: "Wrote final spec and updated roadmap status"
updated: "2026-02-14T17:25:00Z"
---

## Progress Notes

- [17:21] Claimed task #2, read all SKILL.md files, roadmap item, and README
- [17:23] Messaged researcher for findings; reviewed $ARGUMENTS parsing patterns
- [17:25] Drafted architecture design (below) based on direct codebase analysis
- [17:30] Received researcher findings (task #1 complete). Revised: Security
  Auditor must NOT be downgraded (aligned with researcher). Kept conservative
  agent reductions over researcher's more aggressive proposals.
- [17:35] Incorporated researcher's supplemental cost ratio data (Opus ~5x
  Sonnet). Added quantified savings to design.
- [17:40] Fixed blocking issues from team-lead relay. (1) build-product: Impl
  Architect downgraded to Sonnet instead of removed. (2) review-quality deploy:
  Security Auditor kept.
- [17:45] Received Skeptic's full review. All 3 blocking issues already fixed in
  current version. Addressing 3 non-blocking issues: savings expectations, file
  naming conflicts, --light warning message.

---

# Cost Guardrails Architecture Design

## 1. Overview

Cost guardrails give users two levers: **visibility** (know what you're
spending) and **control** (spend less when appropriate). The design adds a
`--light` flag to all three skills that reduces agent count and/or downgrades
models, plus a cost summary written after every invocation.

### Cost Baseline (from researcher)

Opus is approximately **5x more expensive** than Sonnet per token (based on
public API pricing: Opus $15/$75 input/output vs Sonnet $3/$15). Actual Claude
Code costs may vary by subscription/plan, but the 5x ratio is a reasonable
approximation for relative savings calculations.

This means downgrading one agent from Opus to Sonnet saves roughly the
equivalent of 0.8 Opus agents. Removing an Opus agent entirely saves 1.0
Opus-equivalent. These are the two levers lightweight mode uses.

## 2. The `--light` Flag

### 2.1 Argument Handling

The `--light` flag is a **prefix modifier**, not a mode. It combines with
existing arguments:

```
/plan-product --light new user authentication
/build-product --light billing-system
/review-quality --light security auth-module
```

**Parsing rule**: In each SKILL.md's "Determine Mode" section, add a step before
mode detection:

> **Check for `--light` flag.** If `$ARGUMENTS` begins with `--light`, strip it
> from `$ARGUMENTS` and enable lightweight mode. In lightweight mode, apply the
> agent reductions defined in the "Lightweight Mode" section below. All other
> behavior (mode detection, orchestration flow, quality gates) remains
> identical.

This is simple string prefix matching. No complex argument parsing needed. The
Team Lead strips `--light` and processes the remaining arguments normally.

**Lightweight mode announcement**: When `--light` is detected, the Team Lead
outputs a brief message before spawning agents: "Lightweight mode enabled:
reduced agent team. Quality gates maintained. Suitable for exploratory/draft
work." This sets user expectations and makes the trade-off visible. For
`review-quality`, where lightweight mode has no effect, the message should note:
"Lightweight mode: no changes applied. This skill is already at minimum viable
configuration."

### 2.2 Per-Skill Lightweight Mode Definitions

#### `/plan-product` — Standard vs. Lightweight

| Agent                | Standard | Lightweight             |
| -------------------- | -------- | ----------------------- |
| Product Owner (lead) | Opus     | Opus                    |
| Researcher           | Opus     | **Sonnet**              |
| Software Architect   | Opus     | **Sonnet**              |
| DBA                  | Opus     | **REMOVED**             |
| Product Skeptic      | Opus     | Opus (NEVER downgraded) |

**Rationale**: The DBA is the least critical for exploratory/draft planning. The
Architect can handle basic data model considerations in lightweight mode.
Researcher and Architect are downgraded to Sonnet because their outputs are
reviewed by the Skeptic anyway — the quality gate catches problems. The DBA is
removed entirely rather than downgraded because a Sonnet-level DBA would produce
low-confidence data models that still consume a full context window.

**Lightweight agent count**: 4 agents (was 5). Opus count: 2 (was 5).
**Estimated cost reduction**: ~56% (5.0 Opus-equiv units down to ~2.4, using 1
Opus = 1 unit, 1 Sonnet = 0.2 units).

#### `/build-product` — Standard vs. Lightweight

| Agent             | Standard | Lightweight             |
| ----------------- | -------- | ----------------------- |
| Tech Lead (lead)  | Opus     | Opus                    |
| Impl Architect    | Opus     | **Sonnet**              |
| Backend Engineer  | Sonnet   | Sonnet                  |
| Frontend Engineer | Sonnet   | Sonnet                  |
| Quality Skeptic   | Opus     | Opus (NEVER downgraded) |

**Rationale**: The Implementation Architect is downgraded to Sonnet rather than
removed. Removing the Impl Architect would force the Tech Lead to absorb
implementation planning, violating the "leads delegate, they don't implement"
principle. A Sonnet-level Impl Architect still produces useful implementation
plans — translating an existing spec into file-by-file work items is
execution-oriented work that Sonnet handles well. The Quality Skeptic (Opus)
reviews the plan regardless, catching any gaps. Engineers stay at Sonnet
(already cost-efficient).

**Lightweight agent count**: 5 agents (unchanged). Opus count: 2 (was 3).
**Estimated cost reduction**: ~24% (3.4 Opus-equiv units down to ~2.6).
**Note**: build-product already uses Sonnet for its two execution agents, so the
savings ceiling is lower than plan-product. The only Opus agent eligible for
downgrade is the Impl Architect.

#### `/review-quality` — Standard vs. Lightweight

| Mode          | Standard Agents                                                  | Lightweight Agents |
| ------------- | ---------------------------------------------------------------- | ------------------ |
| `security`    | Security Auditor (Opus), Ops Skeptic (Opus)                      | **NO CHANGE**      |
| `performance` | Test Engineer (Sonnet), Ops Skeptic (Opus)                       | **NO CHANGE**      |
| `deploy`      | DevOps Eng (Sonnet), Security Auditor (Opus), Ops Skeptic (Opus) | **NO CHANGE**      |
| `regression`  | Test Engineer (Sonnet), Ops Skeptic (Opus)                       | **NO CHANGE**      |

**Rationale**: All `review-quality` modes are unchanged in lightweight mode. The
Security Auditor must NOT be downgraded or removed — security analysis requires
deep reasoning, and deploy is a security-critical workflow where removing the
Security Auditor would create an unacceptable gap. The skill already uses
conditional spawning and minimal agent counts; it is already the leanest of the
three skills.

**Note**: `review-quality` lightweight mode is identical to standard mode. This
is the correct outcome — the skill cannot be made cheaper without compromising
security or removing the quality gate. Users who want cheaper quality checks
should scope their invocations more narrowly (e.g., audit one module instead of
the whole app) rather than reducing agents. **Estimated cost reduction**: 0%
(already at minimum viable configuration).

## 3. Alternative Considered: More Aggressive Reductions

The Researcher proposed more aggressive lightweight configurations:

- **plan-product**: 3 agents (Lead + Researcher(Sonnet) + Skeptic). Removes both
  Architect and DBA.
- **build-product**: 3 agents (Lead + Full-Stack Eng(Sonnet) + Skeptic). Merges
  backend/frontend into one.

These were considered but rejected for the default `--light` tier:

1. **Removing architects** (from either planning or build) forces the Lead to
   absorb implementation work, violating the "leads delegate, they don't
   implement" principle. Downgrading to Sonnet is the correct lever — the
   architect still produces useful output and the Skeptic catches quality gaps.
2. **Merging backend/frontend** eliminates contract negotiation, a core quality
   mechanism. Two Sonnet engineers working in parallel with a contract is more
   valuable than one Sonnet engineer working sequentially.
3. **Removing Security Auditor from deploy** was also rejected — deploy is a
   security-critical workflow and removing the auditor creates an unacceptable
   gap.
4. **These reductions are valid for a future `--minimal` mode** if user demand
   warrants it. The current design leaves room for this extension without
   requiring redesign.

## 4. Why NOT a `--minimal` Mode (Yet)

A second tier (`--minimal`) was considered and rejected:

1. **Complexity without proportional value.** Three tiers
   (standard/light/minimal) requires more documentation, more conditional logic
   in SKILL.md files, and more user decision-making. Two tiers is the simplest
   useful design.
2. **Diminishing returns.** Lightweight mode already removes or downgrades 1-2
   agents per skill. Going further would mean removing the Skeptic
   (non-negotiable) or running with only 2 agents (lead + 1 worker), which
   eliminates parallel work and most of the value of the multi-agent pattern.
3. **If you need minimal, use Claude Code directly.** A single agent with no
   team coordination is just... Claude Code without the plugin. Users who want
   that already have it.

## 5. Cost Summary Format

After every skill invocation, the Team Lead writes a cost summary to a
uniquely-named file:
`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md` (e.g.,
`plan-product-auth-20260214T1730-cost-summary.md`). The timestamp slug ensures
no write conflicts between invocations, even for the same feature across
different skills. If the feature name isn't determinable (e.g., general review),
use "general" as the feature slug.

### Format

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

### Design Decisions

- **YAML frontmatter + markdown body**: Consistent with checkpoint files.
  Machine-parseable header, human-readable body.
- **No token counts**: Claude Code doesn't expose these. Agent count and model
  tier are the best proxies.
- **Relative cost indicator**: Simple label — "High" (3+ Opus), "Medium" (1-2
  Opus), "Low" (0 Opus, all Sonnet). This is deliberately imprecise because
  exact cost depends on conversation length, which we can't measure.
- **Skeptic rejections tracked**: Each rejection means another round of
  iteration (more tokens). This is a useful signal.
- **Unique file per invocation**: The timestamp slug in the filename ensures no
  write conflicts between invocations. Multiple invocations for the same feature
  produce separate files, creating a cost history that can be reviewed
  chronologically.

## 6. README Documentation Updates

Add a new section "Cost Management" between "Cost Considerations" and
"Customization":

```markdown
### Lightweight Mode

Add `--light` to any skill invocation for reduced cost:

| Skill             | Standard                    | Lightweight                 | Est. Savings |
| ----------------- | --------------------------- | --------------------------- | ------------ |
| `/plan-product`   | 5 agents (5 Opus)           | 4 agents (2 Opus, 2 Sonnet) | ~56%         |
| `/build-product`  | 5 agents (3 Opus, 2 Sonnet) | 5 agents (2 Opus, 3 Sonnet) | ~24%\*       |
| `/review-quality` | 2-3 agents                  | No change                   | 0%           |

Savings are approximate, based on Opus being ~5x the cost of Sonnet per token.
\*build-product already uses Sonnet for execution agents, so the savings ceiling
is lower.

The Skeptic is NEVER downgraded — quality gates remain at full strength in
lightweight mode. The Security Auditor is NEVER downgraded or removed — security
analysis requires Opus-level reasoning.

Examples:

- `/plan-product --light new billing` — draft-quality planning at reduced cost
- `/build-product --light auth` — build with Sonnet-level implementation
  architect

Use lightweight mode for exploratory/draft work. Use standard mode for
production-critical planning and implementation.
```

## 7. SKILL.md Changes (Minimal)

Each SKILL.md needs exactly two additions:

### Addition 1: Lightweight Mode Section (after "Determine Mode")

```markdown
## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and enable lightweight
mode:

- Output to user: "Lightweight mode enabled: reduced agent team. Quality gates
  maintained. Suitable for exploratory/draft work."
- [Skill-specific agent changes — see tables above]
- All orchestration flow, quality gates, and communication protocols remain
  identical
- The Skeptic is ALWAYS Opus, even in lightweight mode
```

### Addition 2: Cost Summary Step (at end of "Orchestration Flow")

```markdown
N. **Team Lead only**: Write cost summary to
`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`
```

The Team Lead already has the information needed (which agents were spawned,
which model each used, how many Skeptic rejections occurred). No new data
collection is needed.

## 8. Architectural Constraints

1. **The Skeptic is NEVER downgraded.** This is the single non-negotiable rule.
   The quality gate is the core value proposition.
2. **`--light` is advisory, not mandatory.** Users opt in. Standard mode is the
   default.
3. **No runtime cost tracking.** Claude Code doesn't expose token counts. Proxy
   metrics (agent count, model tier, rejection count) are the best available
   signals. The design does not pretend otherwise.
4. **No budget limits or caps.** Without token count access, hard limits aren't
   possible. The 3-rejection escalation rule remains the only automatic cost
   control.
5. **Lightweight mode does NOT change the orchestration flow.** Same gates, same
   communication protocol, same checkpoint behavior. Only the agent roster and
   model assignments change.
