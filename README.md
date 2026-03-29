# Wizards

A Claude Code plugin marketplace for orchestrating AI agent teams to plan, build, and operate SaaS products.

## Why This Exists

Building software with AI agents works best when agents have **specialized roles**, **clear communication protocols**,
and **quality gates that actually block bad work**. A single agent trying to be researcher, architect, engineer, and
reviewer at once produces mediocre results across the board. Specialized agents produce expert-level output in their
domain.

This marketplace packages that insight into seven Claude Code skills that spawn coordinated agent teams — each with
defined roles, structured communication, and a Skeptic who must explicitly approve all work before it advances.

## What You Get

Seven slash commands across three categories:

### Engineering Skills

#### `/plan-product` — Product Team

Plan what to build and why. The Product Owner coordinates a Researcher, Software Architect, DBA, and Product Skeptic to
produce implementation-ready specs.

```
/plan-product new user authentication
/plan-product review billing-system
/plan-product reprioritize
/plan-product                          # general roadmap review
```

**Agents**: Product Owner (lead), Researcher, Software Architect, DBA, Product Skeptic **Output**: Feature specs in
`docs/specs/`, updated roadmap in `docs/roadmap/` **Pattern**: Hub-and-Spoke

#### `/build-product` — Implementation Team

Build what the Product Team specified. The Tech Lead coordinates an Implementation Architect, Backend Engineer, Frontend
Engineer, and Quality Skeptic to deliver tested, working code.

```
/build-product billing-system          # implement a specific spec
/build-product review                  # review implementation progress
/build-product                         # resume in-progress or pick next item
```

**Agents**: Tech Lead (lead), Implementation Architect, Backend Engineer (Sonnet), Frontend Engineer (Sonnet), Quality
Skeptic **Output**: Working code with tests, progress notes in `docs/progress/` **Pattern**: Hub-and-Spoke

#### `/review-quality` — Quality & Operations Team

Audit, test, and verify. The QA Lead spawns a context-appropriate subset of agents based on the task.

```
/review-quality security auth-module   # security audit
/review-quality performance api        # performance analysis
/review-quality deploy billing         # deployment readiness
/review-quality regression             # full regression sweep
```

**Agents** (spawned conditionally): | Mode | Agents | |------|--------| | `security` | Security Auditor, Ops Skeptic | |
`performance` | Test Engineer, Ops Skeptic | | `deploy` | DevOps Engineer, Security Auditor, Ops Skeptic | |
`regression` | Test Engineer, Ops Skeptic |

**Pattern**: Hub-and-Spoke

#### `/setup-project` — Project Bootstrap

One-shot setup that detects your tech stack, scaffolds the `docs/` directory structure, generates `CLAUDE.md`, and
creates a starter roadmap. No team — runs as a single agent.

```
/setup-project                         # detect stack, scaffold everything
/setup-project --force                 # overwrite existing files
/setup-project --dry-run               # preview without changes
```

**Pattern**: Single-Agent (no team, no skeptic)

### Business Skills

#### `/draft-investor-update` — Investor Update Team

Draft investor updates from project data. Gathers metrics and milestones from the roadmap, progress files, and specs,
then drafts, reviews, and refines through dual-skeptic validation.

```
/draft-investor-update                 # current period update
/draft-investor-update Q4-2025         # specific period
/draft-investor-update status          # check progress
```

**Agents**: Team Lead, Research Analyst (Sonnet), Update Drafter (Sonnet), Accuracy Skeptic, Narrative Skeptic
**Output**: Polished investor update in `docs/investor-updates/` **Pattern**: Pipeline (Research → Draft → Review →
Finalize)

#### `/plan-sales` — Sales Strategy Team

Assess sales strategy for early-stage startups. Parallel analysis agents research market, product positioning, and
go-to-market, then cross-reference and challenge each other's findings before dual-skeptic validation.

```
/plan-sales                            # new assessment
/plan-sales status                     # check progress
```

**Agents**: Team Lead, Market Analyst, Product Strategist, GTM Specialist, Accuracy Skeptic, Strategy Skeptic
**Output**: Sales strategy assessment in `docs/sales-plans/` **Pattern**: Collaborative Analysis (parallel research →
cross-referencing → synthesis → dual-skeptic)

#### `/plan-hiring` — Hiring Plan Team

Develop a hiring plan for early-stage startups. Debate agents argue for growth vs. efficiency, cross-examine each
other's cases, then dual-skeptic validation ensures fairness and strategic fit.

```
/plan-hiring                           # new hiring plan
/plan-hiring status                    # check progress
```

**Agents**: Team Lead, Context Researcher, Growth Advocate, Efficiency Advocate, Bias Skeptic, Strategy Skeptic
**Output**: Hiring plan in `docs/hiring-plans/` **Pattern**: Structured Debate (neutral research → case building →
cross-examination → synthesis → dual-skeptic)

## The Skeptic Pattern

Every multi-agent team has a Skeptic. This is the core design principle.

The Skeptic is an adversarial quality gate: they challenge assumptions, reject vague requirements, demand evidence, and
provide specific, actionable feedback when they reject work. **No plan, spec, or code advances without explicit Skeptic
approval.** This is non-negotiable and enforced in every skill.

Business skills use **dual-skeptic** validation — one skeptic for factual accuracy, another for strategic coherence.

The Skeptic pattern catches problems that collaborative-only teams miss — because a team where everyone is building has
no one whose job is to find what's wrong.

## Collaboration Patterns

Skills use different orchestration patterns depending on the problem type:

| Pattern                    | When to Use                                           | Skills                                      |
| -------------------------- | ----------------------------------------------------- | ------------------------------------------- |
| **Hub-and-Spoke**          | Agents work on separate concerns, lead orchestrates   | plan-product, build-product, review-quality |
| **Pipeline**               | Sequential stages with quality gates between each     | draft-investor-update                       |
| **Collaborative Analysis** | Parallel independent research, then cross-referencing | plan-sales                                  |
| **Structured Debate**      | Opposing positions, cross-examination, synthesis      | plan-hiring                                 |
| **Single-Agent**           | Deterministic setup tasks, no team needed             | setup-project                               |

## How It Works

### Architecture

Teams communicate through **artifact files** in the project repository, not direct cross-team messaging:

- `docs/roadmap/` — Product Team owns this. The canonical prioritized backlog.
- `docs/specs/` — Product Team writes feature specs here. Implementation Team reads them.
- `docs/architecture/` — Architect maintains ADRs (Architecture Decision Records) here.
- `docs/progress/` — All teams write progress checkpoints here.

Within a team, agents communicate constantly via structured messages. The communication protocol defines when to
message, who to message, and what format to use — ensuring context-constrained agents can parse information quickly.

### Agent Model Assignments

Reasoning-heavy roles (leads, architects, skeptics) use **Opus**. Execution roles (engineers) use **Sonnet** for cost
efficiency. This follows the principle: pay for deep reasoning where it matters, use faster models where the spec is
clear.

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
        plan-product/SKILL.md     # Product planning (Hub-and-Spoke)
        build-product/SKILL.md    # Implementation (Hub-and-Spoke)
        review-quality/SKILL.md   # Quality & ops (Hub-and-Spoke)
        setup-project/SKILL.md    # Project bootstrap (Single-Agent)
        draft-investor-update/SKILL.md  # Investor updates (Pipeline)
        plan-sales/SKILL.md       # Sales strategy (Collaborative Analysis)
        plan-hiring/SKILL.md      # Hiring plans (Structured Debate)
  scripts/
    validate.sh                   # CI validation runner
    validators/                   # 5 validator scripts (A-E series)
  docs/
    roadmap/                      # Prioritized backlog
    specs/                        # Feature specifications
    progress/                     # Agent checkpoints and session summaries
    architecture/                 # ADRs and design docs
    stack-hints/                  # Framework-specific agent guidance
```

## Cost Considerations

Each agent is a full context window. Token cost scales linearly with team size:

| Skill                    | Agents | Models                              | Approximate Cost Profile |
| ------------------------ | ------ | ----------------------------------- | ------------------------ |
| `/plan-product`          | 5      | 4 Opus + 1 Opus Skeptic             | Higher (all reasoning)   |
| `/build-product`         | 5      | 3 Opus + 2 Sonnet                   | Moderate (mixed)         |
| `/review-quality`        | 2-3    | Opus                                | Moderate (smaller team)  |
| `/setup-project`         | 1      | Opus                                | Low (single agent)       |
| `/draft-investor-update` | 5      | 2 Opus + 2 Sonnet + 1 Opus Skeptic  | Moderate                 |
| `/plan-sales`            | 6      | 3 Opus + 1 Sonnet + 2 Opus Skeptics | Higher (dual-skeptic)    |
| `/plan-hiring`           | 6      | 3 Opus + 1 Sonnet + 2 Opus Skeptics | Higher (dual-skeptic)    |

Start with one team at a time. Use `/plan-product` to scope work cheaply in plan mode, then hand specs to
`/build-product` for parallel implementation.

### Lightweight Mode

Add `--light` to any multi-agent skill invocation for reduced cost:

- Downgrades some reasoning agents from Opus to Sonnet
- The Skeptic is **NEVER** downgraded — quality gates remain at full strength
- The Security Auditor is **NEVER** downgraded or removed

Examples:

- `/plan-product --light new billing` — draft-quality planning at reduced cost
- `/build-product --light auth` — build with Sonnet-level implementation architect

Use lightweight mode for exploratory/draft work. Use standard mode for production-critical planning and implementation.

## Customization

The SKILL.md files are plain markdown. To customize:

- **Adjust team size**: Remove agents from the "Spawn the Team" section for leaner teams
- **Change models**: Swap `opus` and `sonnet` assignments in agent listings
- **Modify principles**: Edit the Shared Principles section (in `plan-product/SKILL.md` — it's the authoritative source)
- **Add stack-specific rules**: Create a file at `docs/stack-hints/{stack}.md` (see `docs/stack-hints/laravel.md` for an
  example)
- **Bootstrap a new project**: Run `/setup-project` to auto-detect your stack and scaffold the docs structure

## Validation

Run the CI validator suite to check all skill files, roadmap items, specs, and progress checkpoints:

```bash
bash scripts/validate.sh
```

This runs 5 validator scripts covering structural integrity, shared content drift, frontmatter conventions, and
checkpoint format.

## License

MIT
