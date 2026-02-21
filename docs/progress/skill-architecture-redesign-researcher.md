---
feature: "skill-architecture-redesign"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed full research brief covering all 7 skills, artifact catalog, shared content, orchestration patterns, and redesign requirements"
updated: "2026-02-21T12:00:00Z"
---

# Skill Architecture Redesign -- Research Brief

## 1. Current Team Compositions

### plan-product (Hub-and-Spoke)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | product-owner | (caller) | Orchestrates, writes final spec, updates roadmap |
| Researcher | researcher | opus | Investigates problem space, reads codebase, reports findings |
| Software Architect | architect | opus | Designs system architecture, writes ADRs, defines component boundaries |
| DBA | dba | opus | Designs data model, schemas, migrations |
| Product Skeptic | product-skeptic | opus | Reviews ALL outputs, challenges assumptions, approves/rejects |
**Lightweight mode**: Researcher and Architect downgraded to sonnet; DBA not spawned; Skeptic always opus.

### build-product (Hub-and-Spoke)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | tech-lead | (caller) | Orchestrates, reviews, writes final summaries |
| Implementation Architect | impl-architect | opus | Translates spec into implementation plan, defines interfaces |
| Backend Engineer | backend-eng | sonnet | Server-side code, TDD, API endpoints |
| Frontend Engineer | frontend-eng | sonnet | Client-side code, TDD, component development |
| Quality Skeptic | quality-skeptic | opus | Pre-impl gate (plan+contracts) and post-impl gate (code review) |
**Lightweight mode**: Impl Architect downgraded to sonnet; engineers unchanged; Skeptic always opus.

### review-quality (Hub-and-Spoke)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | qa-lead | (caller) | Orchestrates, synthesizes findings |
| Test Engineer | test-eng | sonnet | Test suites, coverage analysis, regression plans |
| DevOps Engineer | devops-eng | sonnet | Infrastructure, deployment, CI/CD review |
| Security Auditor | security-auditor | opus | OWASP Top 10 audit, vulnerability assessment |
| Ops Skeptic | ops-skeptic | opus | Challenges all findings, demands evidence |
**Note**: Agents spawned conditionally per mode (security, performance, deploy, regression). Ops Skeptic always spawned.
**Lightweight mode**: No changes -- already minimal.

### setup-project (Single-Agent)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Single Agent | (caller) | (caller) | Deterministic 6-step pipeline: detect state, detect stack, scaffold dirs, generate CLAUDE.md, generate roadmap, print summary |
**No team, no skeptic, no checkpoint protocol.** Type: `single-agent` in frontmatter.

### draft-investor-update (Pipeline)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | lead | (caller) | Orchestrates pipeline stages, writes final output |
| Researcher | researcher | opus | Gathers metrics/milestones from project artifacts |
| Drafter | drafter | sonnet | Composes investor update from Research Dossier |
| Accuracy Skeptic | accuracy-skeptic | opus | Verifies all factual claims against evidence |
| Narrative Skeptic | narrative-skeptic | opus | Detects spin, omissions, inconsistency |
**Dual-skeptic model.** Both must approve. Max 3 revision cycles.
**Lightweight mode**: Researcher downgraded to sonnet; Drafter unchanged; both Skeptics always opus.

### plan-sales (Collaborative Analysis)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | lead | (caller) | Orchestrates phases, writes synthesis directly (NOT delegate mode in Phase 3) |
| Market Analyst | market-analyst | opus | Market sizing, competitive landscape, industry trends |
| Product Strategist | product-strategist | opus | Value proposition, differentiation, product-market fit |
| GTM Analyst | gtm-analyst | opus | Go-to-market channels, pricing, customer acquisition |
| Accuracy Skeptic | accuracy-skeptic | opus | Verifies claims against evidence |
| Strategy Skeptic | strategy-skeptic | opus | Challenges strategic assumptions, evaluates alternatives |
**5 agents + lead.** Dual-skeptic model. Lead writes synthesis directly.
**Lightweight mode**: 3 analysts downgraded to sonnet; both Skeptics always opus.

### plan-hiring (Structured Debate)
| Agent | Name | Model | Role |
|-------|------|-------|------|
| Team Lead | lead | (caller) | Orchestrates debate, writes synthesis directly (NOT delegate mode in Phase 4) |
| Researcher | researcher | opus | Neutral evidence gathering for shared evidence base |
| Growth Advocate | growth-advocate | opus | Argues FOR hiring with evidence |
| Resource Optimizer | resource-optimizer | opus | Argues for efficiency and alternatives |
| Bias Skeptic | bias-skeptic | opus | Fairness, inclusive language, legal compliance |
| Fit Skeptic | fit-skeptic | opus | Role necessity, budget alignment, strategic fit |
**5 agents + lead.** Dual-skeptic, 3-message cross-examination rounds.
**Lightweight mode**: Debate agents (Growth Advocate, Resource Optimizer) downgraded to sonnet; Researcher and both Skeptics always opus.

## 2. Artifact Catalog

### Artifacts Produced by Skills

| Artifact Type | Location Pattern | Format | Produced By | Consumed By |
|---------------|-----------------|--------|-------------|-------------|
| Feature Spec | `docs/specs/{feature}/spec.md` | Markdown + YAML frontmatter (title, status, priority, category, approved_by, created, updated) | plan-product (Team Lead aggregates) | build-product (reads spec to implement) |
| API Contract | `docs/specs/{feature}/api-contract.md` | Markdown (endpoints, methods, request/response shapes) | build-product (backend-eng + frontend-eng co-author) | build-product engineers (implement against) |
| Roadmap Item | `docs/roadmap/{id}-{name}.md` | Markdown + YAML frontmatter (status, priority, category, effort, impact, dependencies) | plan-product (Team Lead writes) | All skills (read for context) |
| Roadmap Index | `docs/roadmap/_index.md` | Markdown (navigational aid with categories, prioritization framework, status legend) | setup-project (creates), plan-product (updates) | All skills (read for context) |
| ADR | `docs/architecture/{feature}-{topic}.md` | Markdown + YAML frontmatter (title, status, created, updated, superseded_by) | plan-product (Architect writes) | build-product, review-quality (read for context) |
| System Design | `docs/architecture/{feature}-system-design.md` | Markdown | plan-product (Architect writes) | build-product (reads for context) |
| Data Model | `docs/architecture/{feature}-data-model.md` | Markdown | plan-product (DBA writes) | build-product (reads for context) |
| Agent Checkpoint | `docs/progress/{feature}-{role}.md` | Markdown + YAML frontmatter (feature, team, agent, phase, status, last_action, updated) | All agents (individual files) | Team Leads (read for session recovery) |
| Session Summary | `docs/progress/{feature}-summary.md` | Markdown + YAML frontmatter (feature, status, completed) | Team Leads (end-of-session) | All skills (read for context) |
| Cost Summary | `docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md` | Markdown | Team Leads | User (cost tracking) |
| Quality Report | `docs/progress/{feature}-quality.md` | Markdown | review-quality (QA Lead synthesizes) | User |
| Investor Update | `docs/investor-updates/{date}-investor-update.md` | Markdown + YAML frontmatter (type, period, generated, confidence, review_status, approved_by) | draft-investor-update (Team Lead finalizes) | User, future investor updates (consistency reference) |
| User Data (Investor) | `docs/investor-updates/_user-data.md` | Markdown (template for financial metrics, team, asks) | User fills in; draft-investor-update creates template on first run | draft-investor-update Researcher |
| Sales Strategy | `docs/sales-plans/{date}-sales-strategy.md` | Markdown + YAML frontmatter (type, period, generated, confidence, review_status, approved_by) | plan-sales (Team Lead synthesizes) | User |
| User Data (Sales) | `docs/sales-plans/_user-data.md` | Markdown (template for product, market, current sales, pricing, constraints) | User fills in; plan-sales creates template on first run | plan-sales analysts |
| Hiring Plan | `docs/hiring-plans/{date}-hiring-plan.md` | Markdown + YAML frontmatter (type, period, generated, confidence, review_status, approved_by) | plan-hiring (Team Lead synthesizes) | User |
| User Data (Hiring) | `docs/hiring-plans/_user-data.md` | Markdown (template for team, budget, growth targets, roles, culture) | User fills in; plan-hiring creates template on first run | plan-hiring Researcher |
| Stack Hint | `docs/stack-hints/{stack}.md` | Markdown | setup-project (copies bundled hints) | plan-product, build-product, review-quality (prepend to spawn prompts) |
| Templates | `docs/specs/_template.md`, `docs/progress/_template.md`, `docs/architecture/_template.md` | Markdown + YAML frontmatter | setup-project (creates) | All skills (reference format) |

### Intermediate Artifacts (Agent-to-Agent, Not Persisted to Disk)

| Artifact | Format | Producer | Consumer | Skill |
|----------|--------|----------|----------|-------|
| Research Findings | Structured message | Researcher | Product Owner + Skeptic | plan-product |
| Research Dossier | Structured message (12 sections) | Researcher | Team Lead -> Drafter -> Skeptics | draft-investor-update |
| Domain Brief | Structured message (7 sections) | Market Analyst, Product Strategist, GTM Analyst | Team Lead -> cross-referencing peers -> Skeptics | plan-sales |
| Cross-Reference Report | Structured message (6 sections) | All 3 analysts | Team Lead (synthesis input) | plan-sales |
| Hiring Context Brief | Structured message (7 sections) | Researcher | Team Lead -> debate agents | plan-hiring |
| Debate Case | Structured message (8 sections) | Growth Advocate, Resource Optimizer | Team Lead -> cross-examination | plan-hiring |
| Challenge/Response/Rebuttal | Structured messages (3 per round) | Debate agents (orchestrated by Lead) | Team Lead (synthesis input) | plan-hiring |
| Contract Proposal/Acceptance | Direct messages | backend-eng, frontend-eng | Each other + Skeptic | build-product |
| Implementation Plan | Team message | impl-architect | All agents | build-product |
| Review Verdicts | Structured messages (APPROVED/REJECTED + issues) | All Skeptics | Requesting agent + Lead | All multi-agent skills |

## 3. Shared Content Dependencies

### Current Mechanism

Two blocks of shared content are duplicated in every multi-agent SKILL.md (6 of 7 skills; setup-project excluded):

**Shared Principles** (~30 lines):
- 12 numbered principles in 4 tiers: CRITICAL (3), IMPORTANT (4), ESSENTIAL (3), NICE-TO-HAVE (2)
- Wrapped in `<!-- BEGIN SHARED: principles -->` / `<!-- END SHARED: principles -->`
- **Byte-identical** across all 6 skills (B1 check)

**Communication Protocol** (~30 lines):
- Tool mapping note, "When to Message" table (11 rows), "Message Format" template
- Wrapped in `<!-- BEGIN SHARED: communication-protocol -->` / `<!-- END SHARED: communication-protocol -->`
- **Structurally equivalent** with normalization: skeptic name varies per skill (B2 check)
  - plan-product: `product-skeptic` / `Product Skeptic`
  - build-product: `quality-skeptic` / `Quality Skeptic`
  - review-quality: `ops-skeptic` / `Ops Skeptic`
  - draft-investor-update: `accuracy-skeptic` / `Accuracy Skeptic`
  - plan-sales: `accuracy-skeptic` / `Accuracy Skeptic`
  - plan-hiring: `bias-skeptic` / `Bias Skeptic`

**Authoritative Source**: `plan-product/SKILL.md` (B3 check -- every `BEGIN SHARED` marker must be followed by the authoritative source comment).

### Validators

- **B1/principles-drift**: Extracts principles block from all skills, compares byte-for-byte to plan-product's block
- **B2/protocol-drift**: Extracts protocol block, normalizes 16 skeptic name variants to `SKEPTIC_NAME`, compares
- **B3/authoritative-source**: Checks that every `<!-- BEGIN SHARED: ... -->` line is followed immediately by `<!-- Authoritative source: plan-product/SKILL.md. Keep in sync across all skills. -->`

### Skill-Specific Extensions

- build-product has `<!-- BEGIN SKILL-SPECIFIC: communication-extras -->` / `<!-- END SKILL-SPECIFIC: communication-extras -->` wrapping the Contract Negotiation Pattern (unique to build-product)
- All other skills have a comment noting the omission: `<!-- Contract Negotiation Pattern omitted ... -->`

### ADR-002 (Content Deduplication Strategy)

- Decision: **Validated duplication** with HTML markers; keep content in each SKILL.md for self-containment
- Extraction trigger: **When skill count exceeds 8** -- revisit to extract to plugin-scoped shared file
- Currently at 7 skills (6 multi-agent). Already approaching the 8-skill trigger.

## 4. Orchestration Patterns

### Hub-and-Spoke (plan-product, build-product, review-quality)

**Structure**: Team Lead creates tasks, agents work in parallel on separate concerns, all outputs routed through Skeptic gate.

**Flow**: Setup -> Determine Mode -> Spawn -> Parallel work -> Skeptic review -> Iterate -> Lead aggregates -> Final output

**Key traits**:
- Agents work independently on different aspects (researcher on research, architect on design, etc.)
- Single skeptic gate (one Skeptic approves/rejects)
- Lead is always in delegate mode
- Lightweight mode available (downgrade reasoning agents to sonnet, skip DBA)
- Session resume from checkpoints

**Shared sections across all Hub-and-Spoke skills**:
- Setup (detect dirs, read templates, detect stack, read docs)
- Write Safety (role-scoped progress files, lead writes shared files)
- Checkpoint Protocol (YAML frontmatter + progress notes)
- Determine Mode (status, empty/resume, specific args)
- Lightweight Mode
- Failure Recovery (unresponsive agent, skeptic deadlock at 3 rejections, context exhaustion)

### Pipeline (draft-investor-update)

**Structure**: Sequential stages with quality gates between them.

**Flow**: Research -> Gate 1 (completeness) -> Draft -> Gate 2 (dual-skeptic) -> Revise loop -> Finalize

**Key traits**:
- Strict sequential ordering (research must complete before drafting)
- Dual-skeptic review (Accuracy + Narrative) -- both must approve
- Max 3 revision cycles before escalation
- Drafter may be upgraded from Sonnet to Opus if revision cycles fail
- Research Dossier is the key intermediate artifact

### Collaborative Analysis (plan-sales)

**Structure**: Parallel research, cross-referencing, lead synthesis, dual-skeptic.

**Flow**: Phase 1 (parallel independent research) -> Gate 1 -> Phase 2 (cross-referencing peers' briefs) -> Gate 2 -> Phase 3 (Lead writes synthesis directly) -> Gate 3 (dual-skeptic) -> Revise -> Finalize

**Key traits**:
- 3 analysts produce 3 Domain Briefs independently (Phase 1)
- Analysts cross-reference each other's briefs (Phase 2) -- 3 Cross-Reference Reports
- **Lead breaks delegate mode** to write synthesis in Phase 3 (uniquely positioned with all 6 artifacts)
- Dual-skeptic (Accuracy + Strategy)
- Disagreements preserved through cross-referencing, resolved in synthesis
- Anti-empty-cross-reference check: "no contradictions" report is automatically suspect

### Structured Debate (plan-hiring)

**Structure**: Neutral research, independent case building, cross-examination rounds, lead synthesis, dual-skeptic.

**Flow**: Phase 1 (neutral research) -> Gate 1 -> Phase 2 (parallel case building) -> Gate 2 -> Phase 3 (3-message cross-examination rounds) -> Gate 3 -> Phase 4 (Lead writes synthesis) -> Gate 4 (dual-skeptic) -> Revise -> Finalize

**Key traits**:
- Neutral Researcher establishes shared evidence base (prevents evidence-shopping)
- Two debate agents assigned opposing perspectives (Growth Advocate vs. Resource Optimizer)
- **3-message cross-examination rounds**: Challenge -> Response -> Rebuttal (challenger gets last word)
- Anti-premature-agreement rules enforced by Lead
- Position tracking: MAINTAINED / MODIFIED / CONCEDED
- **Lead breaks delegate mode** for synthesis (Phase 4)
- Dual-skeptic with non-overlapping scopes (Bias + Fit)
- Agent idle fallback protocol for cross-examination timeouts

### Single-Agent (setup-project)

**Structure**: One agent, deterministic pipeline, no team.

**Flow**: Detect state -> Detect stack -> Scaffold dirs -> Generate CLAUDE.md -> Generate roadmap -> Print summary

**Key traits**:
- `type: single-agent` in frontmatter
- No team spawning, no skeptic, no checkpoint protocol
- Idempotent (never overwrites existing files in normal mode)
- `--force` and `--dry-run` flags
- No shared content (excluded from B-series validators)

## 5. Conversation Requirements Summary

The user specified these requirements for the redesign:

### Two-Tier Architecture
- **Tier 1**: Granular skills (e.g., `/research-market`, `/ideate-product`, `/manage-roadmap`, `/write-stories`, `/write-spec`, `/build-product`)
- **Tier 2**: Composite meta-skills that invoke Tier 1 skills in sequence (e.g., `/plan-product` invokes research-market -> ideate-product -> manage-roadmap -> write-stories -> write-spec)

### Pipeline Order
`research-market` -> `ideate-product` -> `manage-roadmap` -> `write-stories` -> `write-spec` -> `build-product`

**Key insight**: Stories come BEFORE specs. Stories define the need (user-facing); specs define the solution (technical). This is a departure from the current architecture where plan-product produces specs directly.

### Consumer-Owns-Template Pattern
The consuming skill owns the artifact template/schema, not the producing skill. This means the consumer defines what it needs, and the producer fills it. Prevents producer-centric artifacts that don't serve downstream consumers.

### Smart Skeptic Placement
- **Lead-as-Skeptic** for lightweight Tier 1 skills (where a dedicated Skeptic agent would be overkill)
- **Dedicated Skeptic agent** for heavy Tier 1 skills and all Tier 2 meta-skills
- Aligns with agent-persona-performance.md guidance: "A lightweight skill might have the Lead double as Skeptic."

### Tier 2 Invocation
- Tier 2 skills invoke Tier 1 via `/skill-name` (each Tier 1 skill is independently invocable)
- `/run-task` for generic ad-hoc work
- `/wizard-guide` for help/orientation

### User's Happy Path
`/plan-product` -> `/build-product` (same as today, but now Tier 2 meta-skills)

### Agent Persona Guidance
`docs/agent-persona-performance.md` provides 5 archetypes (Strategist, Builder, Skeptic, Verifier, Scout) with model guidance. Key principles:
- Dialectical loops, not linear pipelines
- Behavioral prompts, not aspirational labels
- Skeptic needs strongest engineering (anti-sycophancy)
- Structured handoffs
- Confidence calibration

### User Stories
Should use INVEST criteria, SMART planning, and other modern techniques.

## 6. Constraints and Risks

### Validator Impacts

**High risk -- shared content markers will change fundamentally:**
- B1/B2/B3 validators assume shared content is duplicated in each SKILL.md. If the redesign extracts shared content to a common file (now justified since we'll exceed 8 skills), the B-series validators need complete rewrite.
- A4 (shared content markers) would also need updating or removal.
- A2 (required sections) hardcodes section names. New skill patterns may have different required sections.
- A3 (spawn definitions) may need updating if some Tier 1 skills are single-agent or lead-as-skeptic.

**Medium risk -- frontmatter schema changes:**
- C-series (roadmap frontmatter) and D-series (spec frontmatter) may need new fields if artifact schemas change.
- E-series (checkpoint files) reference `team:` field that maps to skill names -- these will change with new skill names.

### Shared Content Sync Changes

Currently 6 multi-agent skills share ~60 lines of content. The redesign will produce many more skills (6+ Tier 1 + 2+ Tier 2 = 8+ skills easily). Per ADR-002's trigger at >8 skills, extraction to a shared file becomes justified.

**Risk**: Moving from validated duplication to a shared file changes the self-containment property that was the original design decision. Each SKILL.md would need to reference the shared file, adding a dependency.

**Mitigation**: The markers were designed to make extraction straightforward. The shared content between markers moves to the shared file.

### Artifact Contract Changes

**Risk -- backward compatibility**: Existing projects have `docs/specs/`, `docs/roadmap/`, `docs/progress/` structures. If the redesign changes artifact locations or schemas, existing projects break.

**Risk -- new artifact types**: User stories are a new artifact type not currently in the system. Need new directory (`docs/stories/`?) and new validator category.

**Risk -- consumer-owns-template**: This is an inversion of the current pattern where the producer defines the artifact format. Changing who owns templates requires coordinating across all producer/consumer pairs.

### Tier 2 Invocation Mechanism

**Risk**: The current system has no mechanism for one skill to invoke another. Tier 2 meta-skills calling Tier 1 via `/skill-name` is a new capability that may require changes to the plugin manifest, marketplace.json, or Claude Code's skill invocation mechanism.

**Confidence**: LOW. This is the biggest unknown. How does a SKILL.md tell the caller agent to invoke another skill? Does Claude Code support this natively? Or would the meta-skill need to explicitly instruct the Lead to "run /research-market" which the Lead would then need to understand as invoking a skill?

### Scale Concerns

**Risk**: Going from 7 skills to potentially 12+ skills (6 Tier 1 + 2 Tier 2 + existing business skills) significantly increases maintenance surface. Each new SKILL.md is a large file (434-1560 lines currently).

**Risk**: Shared content maintenance at scale -- even with extraction, changes to shared principles affect all skills.

### What Might Break

1. **setup-project** -- must be updated to scaffold new directory structures (e.g., `docs/stories/`)
2. **All validators** -- need updating for new skill names, structures, and shared content strategy
3. **Existing checkpoint files** -- `team:` field references old skill names
4. **CLAUDE.md template** -- references current skill names in the Workflow section
5. **Plugin manifest** -- needs to register new skills
6. **Roadmap** -- existing roadmap items reference current skill architecture (P2-02 Skill Composability, P2-07 Universal Principles, P2-08 Plugin Organization)

### Open Questions

1. How does Tier 2 invoke Tier 1? Is this a Claude Code native capability or does the SKILL.md need to instruct the agent to use a specific tool?
2. Should business skills (plan-sales, plan-hiring, draft-investor-update) be part of this redesign or remain as-is?
3. Where do user stories live? New `docs/stories/` directory? Inside `docs/specs/{feature}/stories.md`?
4. Does the consumer-owns-template pattern apply to all artifacts or just cross-skill handoffs?
5. What happens to existing projects using the current skill structure? Migration path?
