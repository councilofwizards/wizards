---
feature: "competitor-research"
team: "conclave-forge"
agent: "architect"
phase: "design"
status: "complete"
last_action:
  "Blueprint sealed — forge-auditor APPROVED, audit verdicts folded into Resolved Decisions and Downstream Phase Notes"
updated: "2026-04-25T15:20:00Z"
---

# TEAM BLUEPRINT: Competitor Research — Deep-Dive Dossier of a Named Competitor

## Mission

**Profile competitor.**

Produce a comprehensive, evidence-backed deep-dive dossier of a single, named competitor, structured as a
progressive-disclosure report (Executive Summary → General Review → Technical Details → Reference Sources) that serves
both executive and operational audiences and includes positioning recommendations to capitalize on competitor gaps.

**Scope boundary**: This team profiles ONE named competitor at a time. It does not produce broad market scans (that is
`research-market`'s mission), it does not generate product ideas (that is `ideate-product`'s mission), and it does not
construct go-to-market plans (that is `plan-sales`'s mission). Positioning recommendations are scoped to "where can we
capitalize on THIS competitor's gaps" — they are not standalone GTM strategy. Mixing competitor profiling with broader
market analysis or sales planning would violate Principle 1 (one mission, one verb-noun).

**Singularity validation**: Could "research the competitor" and "generate positioning recommendations" be split into two
skills? No. The user explicitly requires positioning recommendations to appear in the Executive Summary of the single
dossier — the recommendations are scoped to and evidenced by the competitor research, and the report is a single
deliverable. Splitting would force back-to-back invocation and break the executive-tier promise of the dossier (gaps
surfaced upfront alongside the facts that justify them).

**Classification**: **non-engineering** — agents produce prose research, strategic analysis, and a structured markdown
dossier. No application code, tests, or infrastructure config is written. Universal Principles only.

## Existing Team Analysis

Before designing a new team, I evaluated whether existing teams could cover this mission.

| Existing Skill                | Coverage                                                                             | Gap                                                                                                                                                                                                                                                                                                 |
| ----------------------------- | ------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| research-market               | Broad market scans including competitive landscape (multi-competitor, segment-level) | Designed for breadth across a market, not depth on a single named competitor. Output is `research-findings` artifact for downstream skills (ideate, stories, spec, plan-sales) — not an audience-tiered dossier. No progressive disclosure. No positioning recommendations as a first-class output. |
| plan-sales                    | Sales strategy with parallel analysis agents (market, product, GTM)                  | Sales-strategy framing, not competitor-deep-dive. Cross-references our positioning rather than reverse-engineering a single competitor's full surface (product, tech, GTM, market posture).                                                                                                         |
| ideate-product                | Generates product ideas from research                                                | Wrong direction — produces forward-looking ideas, not backward-looking competitor analysis.                                                                                                                                                                                                         |
| review-pr / audit-slop / etc. | Code-focused                                                                         | Out of scope.                                                                                                                                                                                                                                                                                       |

**Verdict**: No existing skill produces a single-competitor deep-dive dossier with progressive disclosure and
positioning recommendations. `research-market` is the closest neighbor but is breadth-oriented and produces a different
artifact for different consumers. A dedicated team is warranted.

## Agent Consolidation Analysis

I evaluated potential merges for this 8-agent design.

### Merges Rejected

| Candidate Merge                            | Rejection Rationale                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Market Cartographer + Go-to-Market Analyst | Both touch commercial reality, but concerns are methodologically distinct. Cartographer studies WHO the competitor is in the market (TAM, segments, customer logos, funding, trajectory) using sources like Crunchbase, S-1s, market reports. GTM Analyst studies HOW the competitor sells (pricing pages, sales motion, partner programs, messaging, channel mix) using sources like the competitor's marketing site, sales-engagement signals, and review platforms. Merging would produce one agent doing two distinct research jobs with different source corpora, weakening both. |
| Product Inspector + Technical Excavator    | Inspector studies the user-facing product surface (feature inventory, UX, differentiating capabilities) from demos, docs, screenshots, app stores. Excavator studies the engineering surface (tech stack, architecture, integrations, infra) from job postings, status pages, public commits, BuiltWith/Wappalyzer signals, security headers. Different evidence corpora, different analytical methods.                                                                                                                                                                                |
| Strategist + Chronicler                    | Strategist's concern is reasoning ("what gaps exist and how do we capitalize?") — Opus-class reasoning. Chronicler's concern is presentation ("how do we layer this for executives vs. operators?") — Sonnet-class craft. Merging forces one agent to wear both hats, which both bloats the prompt and mixes the model-allocation rationale.                                                                                                                                                                                                                                           |
| Strategist + a researcher                  | Researchers produce evidence; Strategist produces interpretation. Collapsing the synthesis layer into a research seat re-introduces the "researcher who advocates" failure mode — analysts whose conclusions corrupt their own evidence collection.                                                                                                                                                                                                                                                                                                                                    |
| Chronicler absorbed by Lead                | The Lead orchestrates phases, writes the intake brief, and runs skeptic-coordination. The Chronicler authors the final dossier with audience-tiered formatting. Merging would give the Lead two unrelated concerns (cross-phase orchestration AND end-of-pipeline authoring) and would block re-runs of the assembly phase without re-invoking orchestration.                                                                                                                                                                                                                          |

### Merges Accepted

None. Every candidate merge weakens at least one concern. The 8-agent design holds.

### Final Count: 1 lead + 4 researchers + 1 strategist + 1 chronicler + 1 skeptic = 8 agents

Each agent owns a concern no other agent covers.

## Phase Decomposition

Pattern: **fork-join inside a sequential pipeline** (similar to audit-slop). The four research dimensions are
independent and run in parallel within Phase 2; Phases 1, 3, and 4 are sequential. Skeptic gates every phase transition.

| Phase | Name                | Agent(s)                      | Deliverable                    | Input                                                   | Output                                                                                                                                                                                                  | Parallel?           |
| ----- | ------------------- | ----------------------------- | ------------------------------ | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| 1     | Intake & Scoping    | Lead                          | Competitor Brief               | User's directive (named competitor + scope)             | Target identification (legal name, aliases, parent company, primary product), research question set per dimension, depth budget, known-source seed list, success criteria for "comprehensive".          | No                  |
| 1.5   | Brief Gate          | Skeptic                       | Validated Competitor Brief     | Competitor Brief                                        | Skeptic validates: target is unambiguous, research questions cover all four dimensions, no scope leak (e.g. "also analyze the whole market"), success criteria are testable, source seeds are credible. | No                  |
| 2     | Reconnaissance      | 4 researchers (parallel fork) | 4 Dimensional Findings         | Validated Competitor Brief + WebSearch/WebFetch         | One findings file per dimension (market, product, technical, GTM). Each ranks its top items by salience for downstream synthesis (per Downstream Guidance Rule).                                        | Yes — 4 in parallel |
| 2.5   | Findings Gate       | Skeptic                       | Validated Findings Set         | 4 Dimensional Findings                                  | Skeptic validates: claims are evidence-cited (URL + access date), gaps in coverage flagged, contradictions across dimensions surfaced, hallucinated facts rejected, top-item rankings justified.        | No                  |
| 3     | Strategic Synthesis | Strategist                    | Positioning Analysis           | Validated Findings Set                                  | Cross-dimensional gap analysis, ranked positioning opportunities (top 3–5 prioritized for Executive Summary), risks of competing on each gap, evidence pointers back to findings.                       | No                  |
| 3.5   | Synthesis Gate      | Skeptic                       | Validated Positioning Analysis | Positioning Analysis                                    | Skeptic validates: every recommendation is traceable to specific evidence, no recommendation depends on speculation, "capitalization" claims survive an "are we sure?" challenge.                       | No                  |
| 4     | Dossier Assembly    | Chronicler                    | Competitor Dossier             | Validated Positioning Analysis + Validated Findings Set | Final progressive-disclosure markdown: Executive Summary (with positioning recs) → General Review → Technical Details → Reference Sources. Audience-tiered, evidence-cited.                             | No                  |
| 4.5   | Dossier Gate        | Skeptic                       | Approved Dossier               | Competitor Dossier                                      | Skeptic validates: progressive disclosure layering is correct, executive layer is decision-ready, references resolve, positioning recs appear upfront, tone is objective (no marketing language).       | No                  |

**Why a Brief Gate?** A vague Competitor Brief propagates to all four parallel researchers simultaneously — wasted
research budget, mismatched scope, divergent interpretations of "comprehensive". Same anti-pattern audit-slop and
review-pr gate against. Cheaper to validate the brief once than to reconcile four misdirected reports.

**Why a Findings Gate before Synthesis?** Strategic recommendations grounded in unverified facts are the highest-cost
failure mode for this skill. The Strategist must operate on an evidence-validated base, not raw researcher output.

**Why a Synthesis Gate before Assembly?** The Executive Summary's positioning recommendations are the most-read part of
the dossier. They must survive adversarial review BEFORE the Chronicler bakes them into formatted prose.

## Agent Roster

| #   | Agent                | Concern (one sentence)                                                                                                                                                | Model  | Phase              | Rationale                                                                                                                                                                                                                 |
| --- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Lead                 | Cross-phase orchestration, intake brief authorship, gate coordination, no direct research                                                                             | Sonnet | 1, all             | Procedural orchestration with structured inputs (user directive). Brief authorship follows a defined template. Sonnet is sufficient.                                                                                      |
| 2   | Market Cartographer  | Competitor's market position — TAM/segments served, customer logos and references, funding history, ownership/parent, trajectory and momentum signals                 | Sonnet | 2                  | Procedural research against well-defined source corpora (Crunchbase, S-1s, press, customer lists, market reports). Source-driven; not reasoning-bound.                                                                    |
| 3   | Product Inspector    | Competitor's product surface — feature inventory, capability differentiators, UX patterns, packaging tiers, roadmap signals from public sources                       | Sonnet | 2                  | Procedural research from product docs, demos, screenshots, changelog, app stores. Catalog-style work with structured methodology.                                                                                         |
| 4   | Technical Excavator  | Competitor's engineering surface — tech stack, architecture indicators, integrations, infrastructure, scaling/reliability signals from public artifacts               | Sonnet | 2                  | Procedural inference from job postings, status pages, public commits, BuiltWith/Wappalyzer-style signals, security headers, SDKs. Pattern-matching against known stack fingerprints.                                      |
| 5   | Go-to-Market Analyst | Competitor's commercial motion — pricing, packaging, sales channels, partner programs, messaging/positioning, ICP signals, review-platform sentiment                  | Sonnet | 2                  | Procedural research from marketing site, pricing pages, partner directories, review platforms (G2, Capterra, TrustRadius), sales-engagement signals. Structured corpus.                                                   |
| 6   | Strategist           | Cross-dimensional gap analysis and positioning recommendations — where the competitor is weak, where we can capitalize, with risk per recommendation                  | Opus   | 3                  | Reasoning-intensive: must synthesize four independent dimensions, identify non-obvious gaps (intersection of weak product + strong GTM = mismatch we can exploit), rank recommendations under uncertainty. Opus required. |
| 7   | Chronicler           | Audience-tiered presentation — author the progressive-disclosure dossier so executives get decision-ready insight up front and operators get evidence-traceable depth | Sonnet | 4                  | Craft work against a defined output template (Executive Summary → General Review → Technical Details → References). Layering is structured. Sonnet sufficient.                                                            |
| 8   | Skeptic              | Adversarial gate at every phase — challenge brief scope, evidence quality, recommendation grounding, dossier audience-fit; reject anything unsupported                | Opus   | 1.5, 2.5, 3.5, 4.5 | Non-negotiable. Opus required. Skeptic must match or exceed reasoning capability of the agents reviewed (including the Opus Strategist).                                                                                  |

**Model allocation summary**: 2 Opus (Strategist, Skeptic) + 6 Sonnet (Lead, 4 researchers, Chronicler).

## Mandate Boundary Tests

| Agent A             | Agent B              | Boundary Statement                                                                                                                                                                                                                                                               |
| ------------------- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Market Cartographer | Product Inspector    | Cartographer studies the company in its market (who they are, who they serve, where they sit); Inspector studies the company's product (what it does, how it differentiates).                                                                                                    |
| Market Cartographer | Technical Excavator  | Cartographer studies business posture (segments, funding, customers); Excavator studies engineering posture (stack, architecture, infra).                                                                                                                                        |
| Market Cartographer | Go-to-Market Analyst | Cartographer studies WHO the competitor is and WHERE they sit; GTM Analyst studies HOW they sell and AT WHAT PRICE. A customer-logo wall is Cartographer's; the pricing page is GTM's.                                                                                           |
| Product Inspector   | Technical Excavator  | Inspector studies user-facing surfaces (features, UX, capabilities); Excavator studies engineering surfaces (stack, integrations, infra). A demo screenshot is Inspector's; a job posting revealing Postgres + Kafka is Excavator's.                                             |
| Product Inspector   | Go-to-Market Analyst | Inspector studies what the product is; GTM Analyst studies how it's commercially packaged. A feature comparison is Inspector's; the pricing tier the feature is gated behind is GTM's.                                                                                           |
| Technical Excavator | Go-to-Market Analyst | Excavator studies the implementation; GTM Analyst studies the commercial wrapper. A status-page incident pattern is Excavator's; an SLA in the contract is GTM's.                                                                                                                |
| All Researchers     | Strategist           | Researchers produce evidence-cited facts; Strategist produces interpretation and ranked recommendations. A finding "competitor lacks SAML SSO in their Pro tier" is a researcher's; the recommendation "lead with enterprise-grade auth in our positioning" is the Strategist's. |
| Strategist          | Chronicler           | Strategist decides WHAT to say (which gaps to surface and how to rank them); Chronicler decides HOW to present it across audience tiers. A ranked list of 3 positioning bets is the Strategist's; the executive-summary paragraph naming the top bet is the Chronicler's.        |
| All Researchers     | Chronicler           | Researchers gather raw evidence; Chronicler curates and re-tiers evidence into audience layers. A 60-item product feature dump is a researcher's; a 7-bullet "General Review — Product" section is the Chronicler's.                                                             |
| Lead                | All others           | Lead orchestrates phases, authors the intake brief, and runs gate coordination; no other agent does these. Lead does NOT research, synthesize, or author the dossier.                                                                                                            |
| Skeptic             | All others           | Skeptic only challenges and gates; never produces forward content. Every other agent produces deliverables; the Skeptic produces only validation verdicts and challenge lists.                                                                                                   |

## Deliverable Chain

```
[user directive: named competitor + scope]
    → Phase 1 (Intake) → [Competitor Brief]
    → Phase 1.5 (Brief Gate) → [Validated Competitor Brief]
    → Phase 2 (Reconnaissance, 4 parallel) → [4 Dimensional Findings: market | product | technical | GTM]
    → Phase 2.5 (Findings Gate) → [Validated Findings Set]
    → Phase 3 (Strategic Synthesis) → [Positioning Analysis]
    → Phase 3.5 (Synthesis Gate) → [Validated Positioning Analysis]
    → Phase 4 (Dossier Assembly) → [Competitor Dossier — progressive disclosure]
    → Phase 4.5 (Dossier Gate) → [Approved Competitor Dossier]
```

OUTPUT(N) == INPUT(N+1) at every transition. No gaps in the chain.

### Downstream Guidance Compliance

- **Phase 2 → Phase 3**: Each Dimensional Findings file MUST include a "Top Items for Synthesis" ranking (e.g., top 3–5
  weaknesses, top 3–5 differentiators, flagged contradictions). Without this ranking, the Strategist must re-do the
  prioritization on raw findings — wasting Opus tokens and risking blind spots.
- **Phase 3 → Phase 4**: The Positioning Analysis MUST include a ranked "Top Positioning Bets" list (3–5 items
  prioritized by combined gap-size × our-fit × evidence-strength). The Chronicler features the top bets in the Executive
  Summary; without ranking, the Chronicler chooses arbitrarily.

## Parallelization

- **Within Phase 2**: The 4 researchers run in parallel. They share one input (Validated Competitor Brief), use
  WebSearch/WebFetch independently, and produce four independent dimensional findings files. No shared write target.
- **Across phases**: Strictly sequential. Skeptic gates block phase advancement.
- **Could the Strategist start while researchers finish?** Rejected. Partial findings risk biased synthesis (the
  Strategist would over-weight whichever dimension finished first). Default-to-sequential applies.
- **Could the Chronicler start while the Strategist works?** Rejected. The Chronicler's Executive Summary must lead with
  positioning recommendations — those are the Strategist's output. Premature drafting forces a rewrite.

## Design Rationale

### Why three substantive phases (Reconnaissance → Synthesis → Assembly) plus an Intake?

- **Three is the minimum**: facts must be gathered, then interpreted, then presented. Collapsing any pair re-introduces
  a known anti-pattern: researchers who editorialize, or strategists who overshoot the evidence base, or chroniclers who
  invent facts to fill template slots. Each phase has one clean job.
- **Four (with Intake) is the realistic count**: The Intake phase exists because the four parallel researchers share one
  input and a poisoned brief multiplies cost 4x. This matches the audit-slop and review-pr "dossier gate" pattern.
- **More than four would over-engineer**: Adding a separate "evidence verification" phase between Reconnaissance and
  Synthesis was considered and rejected — the Findings Gate (Skeptic at 2.5) already serves that function without
  introducing a new agent or phase.

### Why eight agents?

- **The four research dimensions map directly to dossier sections**: Market and GTM serve the executive layer (who,
  where, how they sell, at what price); Product and Technical serve the operational layer (what they ship, how it's
  built). This is not coincidental — the dossier's audience-tiering drives the research decomposition.
- **One Strategist, not zero or many**: Zero would distribute synthesis across researchers (advocacy-from-evidence
  failure). Multiple strategists would re-introduce a debate phase that is unnecessary for a single-competitor profile —
  gap analysis is a single reasoning job, not a multi-perspective deliberation.
- **One Chronicler, not absorbed**: Audience-tiered presentation is a distinct craft. Merging it into the Strategist
  forces an Opus agent to do Sonnet-class formatting work; merging it into the Lead overloads orchestration with
  end-of-pipeline authorship.
- **One Skeptic, four gates**: The skeptic is the only adversarial voice. Four lightweight gates beat one heavy gate
  because failures are caught earlier (cheaper to fix a vague brief than to redo a dossier).
- **One Lead**: Owns orchestration and intake — no other agent covers cross-phase coordination.

### Alternatives Considered and Rejected

| Alternative                                                            | Rejection Reason                                                                                                                                                                                                                                         |
| ---------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Reuse `research-market` with a "single competitor" mode                | Wrong artifact contract (`research-findings.md` is breadth-shaped). Wrong consumers (downstream is ideate/spec/sales, not an audience-tiered standalone dossier). No progressive disclosure. No first-class positioning recommendations.                 |
| Two-skill split: `research-competitor` + `position-against-competitor` | Violates the user's explicit requirement that positioning recommendations appear inside the Executive Summary of a single dossier. Forces back-to-back invocation. Breaks the "executive-tier promise" — gaps surfaced upfront alongside their evidence. |
| 3 researchers (collapse Market + GTM)                                  | Methodologically distinct source corpora and analytical methods. Merging halves the depth on each dimension. The user asked for "comprehensive, complete" — depth is a hard requirement, not a nice-to-have.                                             |
| 5 researchers (split GTM into pricing + sales-motion)                  | Over-decomposition. Pricing, packaging, sales motion, and messaging share one analytical mode (commercial signal reading) and one source corpus (marketing site + review platforms). One GTM Analyst is the right resolution.                            |
| Two skeptics (one for evidence, one for strategy)                      | Adds coordination overhead without quality gain at this team size. Other Conclave skills with two skeptics (e.g. `plan-hiring`) use them for adversarial debate, not multi-domain validation. One Opus skeptic gating four phases is sufficient.         |
| Have the Lead also write the dossier                                   | Two unrelated concerns in one seat (orchestration + authorship). Blocks re-runs of the assembly phase without re-invoking the orchestrator. Violates Principle 3.                                                                                        |

## Resolved Audit Decisions

The forge-auditor (Thane Hallward) reviewed this blueprint and ruled on all three open questions. These decisions are
binding inputs for downstream phases.

1. **Source-corpus assignment — ENUMERATE in the Brief.** The Competitor Brief MUST enumerate seed source types per
   dimension. Any non-seed source a researcher uses MUST carry a one-line credibility justification in the findings
   file. This gives the Skeptic a concrete check at the 2.5 Findings Gate. Builds into the Armorer's _Source Triage_
   methodology and the Skeptic's challenge list. Hallucination risk is the dominant failure mode for a research skill
   and is to be defended-in-depth.

2. **Re-run idempotency — YES, skip-if-fresh, flag-driven.** The skill is idempotent by default. Canonical artifact
   path: `docs/research/competitors/{slug}/`. Default freshness window: **30 days**. The skill MUST support flags
   `--refresh` (force full re-run) and `--refresh-after Nd` (override window). Artifact Detection MUST appear as a
   top-level section in the final SKILL.md per the `plan-product` pattern. Wired by the Scribe in Phase 3.

3. **Tone enforcement — YES, operationalized as a check.** The Skeptic's 4.5 (Dossier Gate) challenge list MUST reject
   competitor-applied adjectives that are not evidence-tied or directly quoted. A banned/flagged-phrase pattern list
   ("revolutionary", "best-in-class", etc.) is required. The Armorer builds the methodology; the Lorekeeper words it in
   the Skeptic's spawn prompt.

## Downstream Phase Notes (forwarded by the auditor)

Binding guidance for armorer-f2a8, lorekeeper-f2a8, and scribe-f2a8:

- **Skeptic must have 4 DISTINCT challenge methodologies**, one per gate (Brief / Evidence / Synthesis / Dossier).
  Different artifacts have different failure profiles — a single generic checklist will under-fit each gate. The
  Skeptic's spawn prompt needs an explicit `WHAT YOU CHALLENGE` block per gate.
- **Each researcher's "Top Items for Synthesis" MUST be a named methodology with a structured artifact** (e.g., a
  _Salience Matrix_) — not a freeform list. The Armorer names and structures it; the Chronicler and Strategist consume
  it via a defined schema.
- **The Brief's success criteria MUST operationalize "comprehensive"** with concrete counts/coverage requirements (e.g.,
  "≥N pricing tiers documented", "≥M customer logos verified", "≥K product surfaces cataloged"). Do not let fantasy
  theming or evocative prose paper over measurable rigor.
- **All 4 skeptic gates MUST appear as explicit `GATE:` markers in the Orchestration Flow** of the SKILL.md. The Scribe
  is responsible for making the gates load-bearing and visible — they are not implicit.

## Phase 1 Seal

- Auditor: Thane Hallward, The Seal-Bearer (forge-auditor-f2a8)
- Verdict: **APPROVED**
- Date: 2026-04-25
- Audit log: `docs/progress/competitor-research-forge-auditor.md`
- Phase 1 → Phase 2 unlocked. Armorer and Lorekeeper may proceed.

## Checkpoint Log

- [00:00] Task claimed (architect-f2a8)
- [00:05] Decomposition started — read architect persona, audit-slop architect blueprint for calibration
- [00:25] Verb/noun extracted (`profile competitor`), singularity validated, classification set non-engineering
- [00:35] 8-agent roster locked after consolidation analysis (2 merges considered, 0 accepted)
- [00:45] Phase decomposition with 4 skeptic gates locked (matches audit-slop / review-pr gate pattern)
- [00:55] Boundary tests written for all 11 agent pairs
- [01:00] Blueprint drafted — submitted to forge-auditor-f2a8 for review
- [01:30] Audit returned APPROVED — three open questions resolved, four downstream notes forwarded
- [01:35] Blueprint finalized — Resolved Decisions and Downstream Phase Notes folded in, status set to complete
