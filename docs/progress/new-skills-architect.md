---
feature: "new-skills-assessment"
team: "plan-product"
agent: "architect"
phase: "complete"
status: "complete"
last_action:
  "Assessment approved by Skeptic. Incorporated feedback: 3 plugins (not 4),
  revision trigger tied to cross-plugin edits (not skill count)."
updated: "2026-02-18T18:30:00Z"
---

# Architectural Assessment: Scaling to 20+ Skills Across Business Domains

## Overview

Assessment of the architectural implications of expanding the Council of Wizards
from 3 engineering skills to 20+ skills spanning 9 business domains. This
analysis covers framework scalability, quality gate patterns, collaboration
models, plugin organization, and shared principles adaptation.

The Researcher's analysis (docs/progress/new-skills-researcher.md) proposes 15
new skills across Sales, Marketing, Finance, HR, Legal, Customer Success,
Operations, Data/Analytics, and Engineering Ops. This assessment evaluates
whether the current framework can support them.

---

## 1. Framework Scalability: Can SKILL.md Scale to 20 Skills?

### What Scales Well

The SKILL.md pattern has strong inherent scalability properties:

**Per-skill isolation**: Each SKILL.md is self-contained. Adding skill #20 has
zero impact on skills #1-19. There is no shared state, no shared runtime, no
registration mechanism that grows with skill count. This is the single most
important architectural property and it holds.

**Claude Code plugin system**: The plugin manifest (`plugin.json`) lists skills
as directory entries. Adding a skill means adding a directory with a SKILL.md
file. No code changes, no schema migrations, no build steps.

**Agent spawning**: Each skill spawns its own independent team. Skill A's agents
never interact with Skill B's agents. No coordination overhead between skills.

**Checkpoint protocol**: Role-scoped checkpoint files
(`docs/progress/{feature}-{role}.md`) are namespaced by feature. Twenty skills
writing checkpoints create more files but no conflicts.

**Verdict**: The core SKILL.md pattern scales to 20+ skills WITHOUT
modification.

### What Breaks or Degrades

**1. Shared Principles duplication (P2-05 concern)**

With 3 skills, ~126 duplicated lines are manageable. With 20 skills, that
becomes ~840 duplicated lines of Shared Principles and Communication Protocol.
The P2-05 validated duplication approach (Option C) still technically works --
CI validates all 20 copies match -- but the maintenance burden changes
qualitatively:

- Editing a shared principle requires updating 20 files instead of 3
- A single missed file in a manual update creates a CI failure
- The cognitive overhead of "remember to update all files" grows linearly

**Impact**: P2-05's Option C remains correct for the near term (3-8 skills), but
the architecture should plan for a transition point. When the skill count
exceeds ~8, revisit extraction to a shared file mechanism. At that scale, the
portability cost of extraction is justified because most users will install
curated plugin bundles, not copy individual SKILL.md files.

**Recommendation**: Proceed with Option C now. Add a decision trigger in
ADR-002: "Revisit when skill count exceeds 8."

**2. Directory sprawl in docs/**

The current convention uses `docs/progress/`, `docs/specs/`,
`docs/architecture/` as flat directories. With 20 skills producing artifacts
across sessions, the file count in `docs/progress/` will grow substantially.
With 5 agents per skill producing checkpoints, a single planning cycle across 5
skills generates ~25 checkpoint files.

**Impact**: LOW. Flat directories with naming conventions
(`{feature}-{role}.md`) remain navigable. No structural change needed yet. If it
becomes a problem, subdirectories (`docs/progress/{feature}/`) are a
backward-compatible extension.

**3. Output directory proliferation**

The Researcher proposes domain-specific output directories: `docs/sales/`,
`docs/marketing/`, `docs/finance/`, etc. This is architecturally sound -- it
follows the existing pattern of `docs/specs/` and `docs/roadmap/` -- but the
Setup section of each SKILL.md needs to know which directories to create and
read.

**Impact**: LOW. Each skill's Setup section is already skill-specific. Adding
domain directories is a per-skill concern, not a framework concern.

### Scalability Verdict

**The framework scales to 20 skills with zero structural changes.** The only
pressure point is shared content duplication (P2-05), which has a known
migration path. Everything else -- agent spawning, checkpoint protocol, write
safety, failure recovery, quality gates -- is inherently per-skill and scales
linearly.

---

## 2. Multi-Skeptic Pattern

### Current Pattern

Each team has exactly ONE Skeptic agent who serves as the quality gate. The
orchestration flow has a single gate point ("Skeptic must approve before X
advances"). The failure recovery protocol assumes a single 3-rejection limit.

### Proposed Change

Some teams may benefit from multiple negative personas. Examples from the
Researcher's analysis:

- Finance team: Financial Skeptic (challenges assumptions) + Regulatory
  Compliance reviewer
- Legal team: Legal Skeptic (challenges completeness) + Ethical/Bias reviewer
- Strategy team: Strategy Skeptic (challenges evidence) + Financial feasibility
  reviewer

### Architectural Assessment

**The current pattern supports multiple skeptics with minimal modification.**
Here's why:

The Skeptic pattern is not a framework primitive -- it's a SKILL.md convention.
Each skill defines its own team composition and orchestration flow. A skill can
define two skeptics by:

1. Spawning two negative-role agents (e.g., `finance-skeptic` and
   `compliance-reviewer`)
2. Defining the orchestration flow with two gate points (sequential or parallel)
3. Specifying the escalation protocol for each

**Sequential multi-skeptic** (recommended for most cases):

```
Agent produces work → Skeptic A reviews → If approved → Skeptic B reviews → If approved → Advance
```

- Simple extension of current flow
- Each skeptic has independent 3-rejection escalation
- Total worst case: 6 rejection cycles before escalation

**Parallel multi-skeptic** (for independent concerns):

```
Agent produces work → Skeptic A reviews (concern X) ─┐
                    → Skeptic B reviews (concern Y) ─┤→ Both must approve → Advance
```

- Both skeptics review simultaneously
- Blocks on the stricter reviewer
- More efficient but requires conflict resolution if skeptics disagree

### Required Changes

**SKILL.md changes (per skill, not framework)**:

- Spawn prompt for each skeptic defines their specific domain of concern
- Orchestration flow section specifies sequential vs. parallel gate
- Failure recovery specifies which skeptic's rejection count triggers escalation
- Communication protocol routes review requests to the correct skeptic

**Shared Principles changes**: NONE. Principle #1 ("No agent proceeds past
planning without Skeptic sign-off") uses the generic term "Skeptic." It does not
assume a single skeptic. The principle holds whether there are 1 or 3 skeptics.

**Communication Protocol changes**: MINIMAL. The "Plan ready for review" row
currently references a single skeptic name. With multiple skeptics, this row
needs to reference both, or the skill's orchestration flow handles routing
explicitly.

### Recommendation

**Do NOT add multi-skeptic as a framework pattern.** Keep it as a per-skill
design choice. Skills that need multiple skeptics define them in their own
SKILL.md. Skills that need one skeptic continue unchanged. The framework does
not need to know or care.

**Create a guidance note** (not an ADR) that documents the sequential and
parallel multi-skeptic patterns as reusable design templates for new skill
authors.

---

## 3. Collaboration Model: Hub-and-Spoke vs. Peer-to-Peer

### Current Model

The Communication Protocol defines a hub-and-spoke model in practice:

- Most messages route through the team lead (task started, completed, blocked,
  discovery)
- Peer-to-peer exists for specific cases (contract negotiation between
  backend-eng and frontend-eng, questions to specific peers)
- The orchestration flow is centralized: the lead creates tasks, routes work,
  aggregates outputs

### What the PO Wants

Highly collaborative teams with extensive peer-to-peer communication. Not just
hub-and-spoke through the lead.

### Architectural Assessment

**The Communication Protocol already supports peer-to-peer.** The "When to
Message" table includes:

- `write(counterpart, "CONTRACT PROPOSAL: ...")` -- direct peer-to-peer
- `write(peer, "QUESTION for [name]: ...")` -- direct peer-to-peer
- The `SendMessage` tool supports any-to-any messaging

The bottleneck is not the protocol -- it's the orchestration flow instructions
in each SKILL.md. The current skills define the lead as the central coordinator,
and agents message the lead for most events.

**For business-domain skills with more collaborative workflows**, the SKILL.md
can define different orchestration patterns:

**Pattern A: Collaborative Analysis** (good for strategy, finance, marketing)

```
Lead assigns investigation areas → Agents research in parallel →
Agents share findings DIRECTLY with each other (peer-to-peer) →
Agents synthesize collaboratively → Lead aggregates final output →
Skeptic reviews
```

**Pattern B: Structured Debate** (good for strategic decisions)

```
Lead frames the question →
Agent A argues position X, Agent B argues position Y →
Agents debate directly (peer-to-peer) →
Skeptic evaluates arguments →
Lead synthesizes decision
```

**Pattern C: Pipeline** (good for content production)

```
Research agent produces findings →
Passes directly to creation agent →
Creation agent produces draft →
Passes directly to review agent →
Lead orchestrates and handles exceptions
```

### Required Changes

**Communication Protocol changes**: NONE needed. The protocol already supports
peer-to-peer. The table just happens to emphasize lead-centric events because
the current skills use hub-and-spoke.

**SKILL.md changes (per skill)**: Each skill defines its own orchestration flow.
Business-domain skills can use Pattern A, B, or C above without changing the
framework. The orchestration flow section is already per-skill.

**One addition to Shared Principles**: Consider adding a principle about peer
communication quality:

> **When communicating with peers, be specific and actionable.** Share findings
> with enough context for the recipient to act without re-reading your sources.
> Include: what you found, why it matters, and what you need from them.

This is OPTIONAL and should be evaluated by the Skeptic. The existing Principle
#2 ("Communicate constantly via SendMessage") covers the obligation to
communicate. The addition would cover the quality of communication.

### Recommendation

**No framework changes needed.** Peer-to-peer collaboration is a per-skill
orchestration design choice, not a framework constraint. New skills define their
orchestration flow (Patterns A/B/C above) in their SKILL.md.

**Create a "Collaboration Patterns" reference document** for new skill authors,
documenting hub-and-spoke, collaborative analysis, structured debate, and
pipeline patterns with guidance on when to use each.

---

## 4. Plugin Organization

### The Question

Should 20 skills live in one `conclave` plugin or be split into domain-specific
plugins?

### The Researcher's Proposal

9 domain-specific plugins:

- `conclave` (engineering), `conclave-sales`, `conclave-marketing`,
  `conclave-finance`, `conclave-people`, `conclave-legal`, `conclave-strategy`,
  `conclave-eng-ops`, `conclave-cs`

### Architectural Assessment

**Plugin structure in Claude Code** (from the existing codebase):

```
.claude-plugin/marketplace.json    # Marketplace: lists available plugins
plugins/
  conclave/
    .claude-plugin/plugin.json     # Plugin manifest
    skills/
      plan-product/SKILL.md
      build-product/SKILL.md
      review-quality/SKILL.md
```

Adding a new plugin means:

1. New directory under `plugins/` with its own `.claude-plugin/plugin.json`
2. Adding it to the marketplace manifest
3. Each plugin is independently installable

### Arguments For Domain-Split (9 Plugins)

1. **Selective installation**: A marketer installs `conclave-marketing` only. No
   unnecessary engineering skills in their context.
2. **Independent versioning**: Marketing skills can iterate without touching
   engineering skills.
3. **Clearer ownership**: Each plugin has a coherent domain scope.
4. **Smaller SKILL.md context**: Users only load the skills relevant to their
   work.

### Arguments Against Domain-Split (9 Plugins)

1. **Maintenance overhead**: 9 plugins means 9 `plugin.json` files, 9 entries in
   the marketplace manifest, and potentially 9 copies of shared principles (if
   using validated duplication).
2. **Cross-domain skills**: Some skills reference outputs from other domains.
   `/build-sales-collateral` consumes strategy from `/plan-sales`. If they're in
   different plugins, the handoff is implicit (via `docs/` files) rather than
   explicit.
3. **User confusion**: A founder who wants "everything" must install 9 plugins.
   A single `conclave-business` plugin is simpler.
4. **Single-skill plugins**: `conclave-legal` has ONE skill (`review-legal`).
   `conclave-cs` has ONE skill. A plugin per skill is over-granular.

### Recommended Approach: 3-4 Plugins

Split by USER PERSONA, not by business function:

| Plugin                | Skills                                                                                                                       | Target User                     |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------------- |
| `conclave` (existing) | plan-product, build-product, review-quality, triage-incident, assess-debt, design-api, plan-migration                        | Engineers and CTOs              |
| `conclave-business`   | plan-sales, plan-marketing, plan-finance, plan-strategy, plan-customer-success, plan-analytics, plan-operations, plan-hiring | Founders and business operators |
| `conclave-content`    | build-sales-collateral, build-content, draft-investor-update                                                                 | Content producers               |
| `conclave-compliance` | review-legal, plan-onboarding                                                                                                | Legal/HR/compliance             |

**Rationale**:

- 4 plugins vs. 9 reduces maintenance overhead by 55%
- Persona-based grouping means users install 1-2 plugins, not 5-6
- No single-skill plugins
- Cross-domain handoffs within a plugin (e.g., plan-sales and plan-marketing in
  the same plugin) are easier to document
- Engineering ops skills (triage-incident, assess-debt, etc.) belong with the
  existing engineering plugin since they share the codebase context

**Alternative considered**: 2 plugins (`conclave` for engineering,
`conclave-business` for everything else). Simpler, but the content-production
and compliance skills serve different personas than strategy/planning skills.
3-4 plugins is the sweet spot.

### Shared Principles Across Plugins

With multi-plugin architecture, the validated duplication (P2-05 Option C)
applies within each plugin. Across plugins, a different mechanism is needed:

- **Within a plugin**: All SKILL.md files in that plugin share principles with
  CI-validated duplication
- **Across plugins**: Each plugin carries its own copy of shared principles
  (engineering or business variant). The marketplace-level CI validates
  cross-plugin consistency for the universal principles (#1-3, #9-12).

This is a natural extension of the P2-05 design and requires no architectural
changes.

---

## 5. Shared Principles Adaptation

### Current State

12 principles in 4 tiers:

- CRITICAL (#1-3): Skeptic approval, communication, no assumptions
- IMPORTANT (#4-7): Minimal solutions, TDD, SOLID/DRY, unit tests with mocks
- ESSENTIAL (#8-10): Contracts sacred, document decisions, delegate mode
- NICE-TO-HAVE (#11-12): Progressive disclosure, model selection guidance

### The Researcher's Proposal

Replace 5 engineering-specific principles (#4-8) with business equivalents:

| #   | Engineering              | Business                          |
| --- | ------------------------ | --------------------------------- |
| 4   | Minimal, clean solutions | Concise, actionable outputs       |
| 5   | TDD by default           | Evidence-driven analysis          |
| 6   | SOLID and DRY            | Structured, non-redundant outputs |
| 7   | Unit tests with mocks    | Assumptions explicitly stated     |
| 8   | Contracts are sacred     | Commitments are tracked           |

### Architectural Assessment

**Two separate principle sets is the wrong abstraction.** Here's why:

1. **Maintenance divergence**: Two sets will drift independently. Changes to
   universal principles (#1-3, #9-12) must be applied to both sets. This is the
   same duplication problem P2-05 solves, but worse because the sets are
   semantically different.

2. **Mixed-domain skills**: Future skills may span domains (e.g., a technical
   due diligence skill needs both engineering and business principles). Which
   set applies?

3. **Cognitive overhead**: Skill authors must know which principle set to use.
   New contributors must learn two sets. This is unnecessary complexity.

### Recommended Approach: One Universal Set with Domain Appendices

**Structure**:

```
UNIVERSAL PRINCIPLES (apply to ALL skills):
  #1  Skeptic approval required
  #2  Communicate constantly
  #3  No assumptions
  #4  Concise, focused outputs (generalized from "minimal solutions")
  #5  Evidence-based work product (generalized from "TDD")
  #6  Structured, non-redundant outputs (generalized from "SOLID/DRY")
  #7  Document decisions
  #8  Delegate mode for leads
  #9  Progressive disclosure
  #10 Model selection guidance

DOMAIN APPENDIX (included per-skill):
  Engineering: TDD mandatory, SOLID/DRY, unit tests with mocks, API contracts sacred
  Business: Assumptions stated, claims cited, commitments tracked
```

**How it works in SKILL.md**:

- The Shared Principles section contains the 10 universal principles
- Each skill appends its domain-specific appendix after the universal section
- The domain appendix is per-skill (not shared across skills), so duplication is
  not a concern

**Benefits**:

- Universal principles are shared and CI-validated (P2-05 Option C)
- Domain principles are per-skill, so no duplication to manage
- Mixed-domain skills include both appendices
- The universal set is smaller (10 items vs. 12), reducing token cost slightly

### Principle Generalization Details

| Current # | Current (Engineering)    | Proposed Universal                                                                                                                                                                     | Domain Appendix                                                                                                                                    |
| --------- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1         | Skeptic approval         | Skeptic approval (unchanged)                                                                                                                                                           | --                                                                                                                                                 |
| 2         | Communicate constantly   | Communicate constantly (unchanged)                                                                                                                                                     | --                                                                                                                                                 |
| 3         | No assumptions           | No assumptions (unchanged)                                                                                                                                                             | --                                                                                                                                                 |
| 4         | Minimal, clean solutions | **Concise, focused outputs.** Produce the minimum output that correctly addresses the problem. No filler, no padding, no unnecessary complexity.                                       | Engineering: "Write the least code that works. Prefer framework tools." / Business: "Actionable recommendations only. No boilerplate analysis."    |
| 5         | TDD by default           | **Evidence before conclusions.** Every claim, recommendation, or design decision must be grounded in evidence: data, research, code analysis, or cited sources.                        | Engineering: "TDD mandatory. Test first, implement, refactor." / Business: "Every projection lists its assumptions. Every claim cites its source." |
| 6         | SOLID and DRY            | **Structured, non-redundant.** Organize outputs with clear hierarchy. Don't repeat points. Each section has a single focus.                                                            | Engineering: "SOLID principles. Single responsibility. DRY." / Business: "Clear section hierarchy. No repeated conclusions."                       |
| 7         | Unit tests with mocks    | (Merged into domain appendix)                                                                                                                                                          | Engineering: "Unit tests with mocks preferred." / Business: "Assumptions explicitly enumerated."                                                   |
| 8         | Contracts sacred         | **Commitments are explicit.** When agents agree on deliverables, interfaces, or outputs, that agreement is documented and honored. Changes require renegotiation and Skeptic approval. | Engineering: "API contracts sacred." / Business: "Plan commitments tracked."                                                                       |
| 9         | Document decisions       | Document decisions (unchanged)                                                                                                                                                         | --                                                                                                                                                 |
| 10        | Delegate mode            | Delegate mode (unchanged)                                                                                                                                                              | --                                                                                                                                                 |
| 11        | Progressive disclosure   | Progressive disclosure (unchanged)                                                                                                                                                     | --                                                                                                                                                 |
| 12        | Model selection          | Model selection (unchanged)                                                                                                                                                            | --                                                                                                                                                 |

---

## Summary of Recommendations

### Framework Changes: NONE Required

The existing framework (SKILL.md structure, agent spawning, Skeptic pattern,
checkpoint protocol, communication protocol, write safety, failure recovery)
supports 20+ skills without modification. Every new skill is a new SKILL.md file
-- the framework doesn't need to know about it.

### Per-Skill Design Choices (Not Framework Changes)

| Concern                    | Approach                                   | Where Defined              |
| -------------------------- | ------------------------------------------ | -------------------------- |
| Multi-skeptic              | Sequential or parallel gate, per skill     | Each skill's SKILL.md      |
| Peer-to-peer collaboration | Orchestration flow patterns (A/B/C)        | Each skill's SKILL.md      |
| Domain-specific outputs    | Output directory conventions               | Each skill's Setup section |
| Domain principles          | Domain appendix after universal principles | Each skill's SKILL.md      |

### Infrastructure Changes (Recommended)

| Change                                       | Rationale                                           | When                             |
| -------------------------------------------- | --------------------------------------------------- | -------------------------------- |
| 3-4 plugin split (persona-based)             | Selective installation, manageable maintenance      | Before launching business skills |
| Universal principles (10 items)              | Replaces engineering-only set, supports all domains | Part of P2-05 implementation     |
| Collaboration patterns reference doc         | Helps new skill authors design orchestration flows  | Before first business skill      |
| Multi-skeptic patterns reference doc         | Helps skills that need multiple quality gates       | Before first multi-skeptic skill |
| P2-05 Option C revision trigger at 8+ skills | Validated duplication becomes burdensome at scale   | When skill count exceeds 8       |

### Key Architectural Insight

The Council of Wizards framework is a **pattern library, not a platform**. Its
value is in the reusable patterns (Skeptic gate, checkpoint protocol,
communication protocol, write safety), not in shared runtime or infrastructure.
This is why it scales: each skill is a standalone application of the patterns,
packaged as a markdown file. Adding skills is additive, not multiplicative. The
framework's complexity does not grow with skill count.

The only scaling pressure is shared content management (P2-05), which has a
known solution at each scale tier:

- 3-8 skills: Validated duplication with CI (Option C)
- 8-15 skills: Plugin-scoped shared files with degraded portability
- 15+ skills: Plugin-scoped shared files + universal-only CLAUDE.md injection

This graduated approach avoids over-engineering now while providing a clear
migration path.
