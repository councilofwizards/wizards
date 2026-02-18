# Wizards

A Claude Code plugin marketplace for orchestrating AI agent teams to plan, build, and operate SaaS products.

## Why This Exists

Building software with AI agents works best when agents have **specialized roles**, **clear communication protocols**, and **quality gates that actually block bad work**. A single agent trying to be researcher, architect, engineer, and reviewer at once produces mediocre results across the board. Specialized agents produce expert-level output in their domain.

This marketplace packages that insight into three Claude Code skills that spawn coordinated agent teams — each with defined roles, structured communication, and a Skeptic who must explicitly approve all work before it advances.

## What You Get

Three slash commands, each spawning a purpose-built team:

### `/plan-product` — Product Team

Plan what to build and why. The Product Owner coordinates a Researcher, Software Architect, DBA, and Product Skeptic to produce implementation-ready specs.

```
/plan-product new user authentication
/plan-product review billing-system
/plan-product reprioritize
/plan-product                          # general roadmap review
```

**Agents**: Product Owner (lead), Researcher, Software Architect, DBA, Product Skeptic
**Output**: Feature specs in `docs/specs/`, updated roadmap in `docs/roadmap/`

### `/build-product` — Implementation Team

Build what the Product Team specified. The Tech Lead coordinates an Implementation Architect, Backend Engineer, Frontend Engineer, and Quality Skeptic to deliver tested, working code.

```
/build-product billing-system          # implement a specific spec
/build-product review                  # review implementation progress
/build-product                         # resume in-progress or pick next item
```

**Agents**: Tech Lead (lead), Implementation Architect, Backend Engineer (Sonnet), Frontend Engineer (Sonnet), Quality Skeptic
**Output**: Working code with tests, progress notes in `docs/progress/`

### `/review-quality` — Quality & Operations Team

Audit, test, and verify. The QA Lead spawns a context-appropriate subset of agents based on the task.

```
/review-quality security auth-module   # security audit
/review-quality performance api        # performance analysis
/review-quality deploy billing         # deployment readiness
/review-quality regression             # full regression sweep
```

**Agents** (spawned conditionally):
| Mode | Agents |
|------|--------|
| `security` | Security Auditor, Ops Skeptic |
| `performance` | Test Engineer, Ops Skeptic |
| `deploy` | DevOps Engineer, Security Auditor, Ops Skeptic |
| `regression` | Test Engineer, Ops Skeptic |

## The Skeptic Pattern

Every team has a Skeptic. This is the core design principle.

The Skeptic is an adversarial quality gate: they challenge assumptions, reject vague requirements, demand evidence, and provide specific, actionable feedback when they reject work. **No plan, spec, or code advances without explicit Skeptic approval.** This is non-negotiable and enforced in every skill.

The Skeptic pattern catches problems that collaborative-only teams miss — because a team where everyone is building has no one whose job is to find what's wrong.

## How It Works

### Architecture

Teams communicate through **artifact files** in the project repository, not direct cross-team messaging:

- `docs/roadmap/` — Product Team owns this. The canonical prioritized backlog.
- `docs/specs/` — Product Team writes feature specs here. Implementation Team reads them.
- `docs/architecture/` — Architect maintains ADRs (Architecture Decision Records) here.
- `docs/progress/` — Implementation Team writes progress notes here.

Within a team, agents communicate constantly via structured messages. The communication protocol defines when to message, who to message, and what format to use — ensuring context-constrained agents can parse information quickly.

### Agent Model Assignments

Reasoning-heavy roles (leads, architects, skeptics) use **Opus**. Execution roles (engineers) use **Sonnet** for cost efficiency. This follows the principle: pay for deep reasoning where it matters, use faster models where the spec is clear.

### Key Principles

Every agent on every team operates under shared principles:

1. **Nothing advances without Skeptic approval** — the quality gate is real
2. **Communicate constantly** — never assume another agent knows your status
3. **No assumptions** — if you don't know, ask; never guess at requirements
4. **TDD by default** — test first, implement, refactor
5. **Contracts are sacred** — API contracts between backend and frontend are documented and enforced
6. **Leads delegate, they don't implement** — orchestration and execution are separate concerns

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI
- Agent Teams feature enabled:
  ```bash
  export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
  ```
- For visible agent panes (recommended):
  ```bash
  export CLAUDE_CODE_SPAWN_BACKEND=tmux
  ```

### Install the Marketplace

```
/plugin marketplace add councilofwizards/wizards
/plugin install conclave@wizards
```

### Auto-Install for Teams

Add to your project's `.claude/settings.json` so collaborators are prompted automatically:

```json
{
  "extraKnownMarketplaces": {
    "wizards": {
      "source": {
        "source": "github",
        "repo": "councilofwizards/wizards"
      }
    }
  },
  "enabledPlugins": {
    "conclave@wizards": true
  }
}
```

## Project Structure

```
wizards/
  .claude-plugin/
    marketplace.json              # Marketplace catalog (1 plugin)
  plugins/
    conclave/
      .claude-plugin/
        plugin.json               # Plugin manifest
      skills/
        plan-product/
          SKILL.md                # /plan-product skill
        build-product/
          SKILL.md                # /build-product skill
        review-quality/
          SKILL.md                # /review-quality skill
  docs/
    original-prompt.md            # Full framework documentation
    plugin-marketplaces.md        # Marketplace spec reference
```

## Cost Considerations

Each agent is a full context window. Token cost scales linearly with team size:

- `/plan-product` spawns 5 agents (4 Opus + 1 Opus Skeptic)
- `/build-product` spawns 5 agents (3 Opus + 2 Sonnet)
- `/review-quality` spawns 2-3 agents depending on mode

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

The SKILL.md files are plain markdown. To customize:

- **Adjust team size**: Remove agents from the "Spawn the Team" section for leaner teams
- **Change models**: Swap `opus` and `sonnet` assignments in agent listings
- **Modify principles**: Edit the Shared Principles section to match your team's standards
- **Add stack-specific rules**: The default is Laravel/PHP — adjust for your stack in the spawn prompts

## License

MIT
