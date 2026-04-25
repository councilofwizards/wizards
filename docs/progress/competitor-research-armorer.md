---
feature: "competitor-research"
team: "conclave-forge"
agent: "armorer"
phase: "design"
status: "complete"
last_action: "Manifest sealed — forge-auditor APPROVED, forward notes folded into pass-through section"
updated: "2026-04-25T16:05:00Z"
---

# METHODOLOGY MANIFEST: Competitor Research — Deep-Dive Dossier

Armorer: Vex Ironbind, The Equipper (armorer-f2a8)

Mission: Profile competitor (non-engineering — Universal Principles only). Source blueprint:
`docs/progress/competitor-research-architect.md` (APPROVED 2026-04-25).

This manifest arms each of the 8 agents with named, evidence-producing methodologies. Every output is a structured
artifact (table, matrix, log, chain, map, checklist) the Skeptic can point at and challenge. Every audit directive from
forge-auditor-f2a8 is honored: Source Triage on all four researchers, Salience Matrix as a named methodology with a
structured artifact, four distinct Skeptic challenge methodologies (one per gate), and operationalized tone enforcement
at the Dossier Gate.

---

## METHODOLOGY MANIFEST: Lead (Phase 1, cross-phase orchestration)

Methodologies:

1. **Target Identity Resolution** — disambiguation pass that nails the single named competitor before any research
   begins (legal name, aliases, DBA, parent / holding company, sibling brands, name-confusable competitors that must NOT
   be researched). Output: **Target Identity Card** — fields: legal_name, aliases[], parent_or_owner, primary_product,
   sibling_products[], confusables_excluded[], identity_evidence_urls[]. Skeptic challenge surface: any field that is
   empty, any alias unsupported by a citation, any confusable not explicitly excluded, any case where parent / sibling
   boundary is ambiguous.

2. **5W1H Brief Decomposition** — Who / What / Where / When / Why / How decomposition applied to each of the four
   research dimensions (market, product, technical, GTM), producing one explicit research question per cell. Output:
   **Research Question Set** — 4 dimensions × 6 W-cells, each cell holding 1–3 testable research questions. Skeptic
   challenge surface: cells with no question (coverage hole), cells whose question is unanswerable from public sources
   (scope drift), cells whose question duplicates another dimension's (mandate overlap).

3. **Source Seed Enumeration** — for each dimension, list the seed source TYPES known to be credible for that dimension
   (per auditor directive 1). Researchers may go beyond the seed list, but any non-seed source they cite must carry a
   one-line credibility justification in their findings. Output: **Source Seed Table** — columns: dimension,
   source_type, credibility_tier (A/B/C), example_url_pattern, why_seeded. Skeptic challenge surface: seed types with no
   credibility tier, dimensions with fewer than 3 seed types, sources seeded at tier A without justification, dimensions
   whose seeds overlap a sibling dimension's seeds (boundary violation).

4. **Operationalized Success Criteria** — convert "comprehensive" into concrete, countable thresholds per the auditor's
   downstream note (e.g., ≥N pricing tiers documented, ≥M customer logos verified, ≥K product surfaces cataloged, ≥J
   tech-stack indicators, ≥H review-platform sentiment themes). Output: **Coverage Threshold Checklist** — rows:
   dimension, threshold_metric, minimum_count, rationale. Skeptic challenge surface: any threshold without a numeric
   minimum, any "comprehensive" claim in the brief not bound to a row, any threshold whose rationale is absent or
   speculative.

---

## METHODOLOGY MANIFEST: Market Cartographer (Phase 2, market position)

Methodologies:

1. **Source Triage Matrix (Market-scoped)** — apply the Lead's Source Seed Table for the market dimension; seed sources
   include Crunchbase, S-1 / 10-K filings, press releases, customer reference lists, Gartner / Forrester reports, and
   analyst briefings; any non-seed source receives a one-line credibility justification. Output: **Source Triage Log** —
   columns: source_url, source_type, seed_or_nonseed, credibility_tier, credibility_justification, access_date. Skeptic
   challenge surface: non-seed sources missing justification, sources at tier A without primary-source links, citations
   to derivative aggregators where a primary source exists, missing access dates.

2. **PESTLE Scan** — Political / Economic / Social / Technological / Legal / Environmental factors that shape the
   competitor's market posture, scoped to the competitor's served segments and geographies. Output: **PESTLE Matrix** —
   rows: PESTLE letter, observed_factor, impact_on_competitor, evidence_url, signal_strength (low/med/high). Skeptic
   challenge surface: factors marked high-impact without a specific evidence URL, PESTLE rows that conflate multiple
   factors, signal-strength claims without comparative basis.

3. **Funding & Trajectory Timeline** — chronological evidence chain of funding rounds, M&A events, leadership changes,
   customer wins / losses, and momentum signals. Output: **Trajectory Timeline** — rows: date, event_type,
   event_summary, source_url, momentum_polarity (+/-/neutral), signal_strength. Skeptic challenge surface: events
   without dates, momentum polarities not derivable from the cited source, gaps in the timeline that span an obvious
   public event, polarity claims dependent on speculation about future intent.

4. **Salience Matrix (Market-scoped)** — rank market findings by importance × evidence strength for the Strategist's
   synthesis (per auditor directive 2). This is the named, structured top-items artifact, NOT a freeform list. Output:
   **Market Salience Matrix** — rows: finding_id, finding_summary, importance_score (1–5), evidence_strength_score
   (1–5), salience (importance × evidence), rank, evidence_pointer. Skeptic challenge surface: any finding ranked top-5
   whose evidence_strength is below 3, importance scores without rationale, ranking ties resolved without a tiebreaker
   rule, findings cited by the Strategist but absent from the matrix.

---

## METHODOLOGY MANIFEST: Product Inspector (Phase 2, product surface)

Methodologies:

1. **Source Triage Matrix (Product-scoped)** — apply the Lead's Source Seed Table for the product dimension; seed
   sources include the competitor's product documentation, demo videos, app-store listings, public changelogs,
   in-product screenshots from public marketing, and conference talk decks. Output: **Source Triage Log** — same schema
   as Cartographer's, scoped to product evidence. Skeptic challenge surface: same schema as Cartographer's, plus: claims
   about "the product" sourced only from marketing copy without a corroborating product surface (docs, screenshot,
   demo).

2. **Feature Inventory via Comparative Analysis Matrix** — catalog the competitor's product capabilities against a
   normalized capability taxonomy so absences are visible (a missing row is as informative as a present row). Output:
   **Feature Inventory Matrix** — rows: capability (taxonomy slot), present (yes/no/partial), tier_gate (free / pro /
   enterprise / N/A), evidence_url, last_observed_date. Skeptic challenge surface: capabilities marked "yes" without a
   public evidence URL, capabilities marked "partial" without a definition of "partial", taxonomy slots left unfilled,
   last_observed_date older than the brief's freshness window.

3. **Jobs-to-be-Done Mapping** — for each major capability cluster, name the buyer's job the product is hired to do;
   surfaces what the product is actually for, distinct from what it merely contains. Output: **JTBD Map** — rows:
   job_statement, capabilities_serving_job[], evidence_signal (marketing claim / customer quote / case study / review),
   evidence_url. Skeptic challenge surface: jobs phrased as features rather than buyer outcomes, jobs unsupported by
   buyer-side evidence (review, quote, case study), capabilities mapped to no job (orphan features) or to too many jobs
   (vague mapping).

4. **Salience Matrix (Product-scoped)** — rank product findings (top differentiators, top gaps, top roadmap signals) per
   auditor directive 2. Output: **Product Salience Matrix** — same schema as Market Salience Matrix, scoped to product
   evidence. Skeptic challenge surface: same as Cartographer's Salience Matrix, plus: differentiators ranked without a
   comparison reference (differentiator vs. WHAT?), gap claims without a corroborating absence in the Feature Inventory
   Matrix.

---

## METHODOLOGY MANIFEST: Technical Excavator (Phase 2, engineering surface)

Methodologies:

1. **Source Triage Matrix (Technical-scoped)** — apply the Lead's Source Seed Table for the technical dimension; seed
   sources include job postings (stack mentions), public engineering blog posts, status pages and incident histories,
   GitHub / public commit signals, BuiltWith / Wappalyzer fingerprints, security headers and HTTP responses, public SDK
   source, and conference engineering talks. Output: **Source Triage Log** — same schema as Cartographer's, scoped to
   technical evidence. Skeptic challenge surface: same schema, plus: inferences from job postings treated as confirmed
   deployments without corroborating signal.

2. **Stack Fingerprinting** — pattern-match observed signals against known technology fingerprints (DOM signatures →
   frontend framework; HTTP header patterns → web server / CDN; job-posting keywords → backend stack; binary signatures
   → mobile framework). Output: **Stack Fingerprint Chain** — rows: layer (frontend / backend / data / infra /
   observability / mobile), inferred_component, signals_observed[], fingerprint_pattern_matched, confidence
   (low/med/high), evidence_urls[]. Skeptic challenge surface: high-confidence inferences from a single signal, layers
   populated entirely from a single source type (e.g., all-job-postings without DOM corroboration), inferred components
   that contradict each other across layers (e.g., "uses gRPC" + "frontend speaks REST only").

3. **Dependency Graph Analysis** — map external integrations and third-party dependencies that signal architecture
   choices and platform reliance. Output: **Integration Dependency Graph** — rows: dependency, integration_type (auth /
   payments / data / observability / messaging / AI / etc.), surface_where_observed (docs / settings UI / DNS / TLS cert
   / etc.), evidence_url, architectural_implication. Skeptic challenge surface: dependencies inferred without a public
   surface, architectural implications that don't follow from the dependency, missing major integration categories
   (e.g., no auth provider listed for a B2B SaaS), claims about removed dependencies based on absence of evidence.

4. **Salience Matrix (Technical-scoped)** — rank technical findings (top stack indicators, top scaling signals, top
   reliability incidents, top security posture observations) per auditor directive 2. Output: **Technical Salience
   Matrix** — same schema as Market Salience Matrix, scoped to technical evidence. Skeptic challenge surface: same
   schema, plus: scaling-signal claims without status-page or incident corroboration; security-posture rankings without
   a header / CVE / disclosure source.

---

## METHODOLOGY MANIFEST: Go-to-Market Analyst (Phase 2, commercial motion)

Methodologies:

1. **Source Triage Matrix (GTM-scoped)** — apply the Lead's Source Seed Table for the GTM dimension; seed sources
   include the competitor's marketing site, pricing pages, partner directories, G2 / Capterra / TrustRadius reviews,
   sales-engagement signals (LinkedIn job titles, hiring patterns), case studies, and webinar / event presence. Output:
   **Source Triage Log** — same schema as Cartographer's, scoped to GTM evidence. Skeptic challenge surface: same
   schema, plus: review-platform claims without a corpus minimum (a single review is anecdote, not signal), pricing
   claims sourced only from a third-party comparator instead of the competitor's own pricing page where one exists.

2. **Pricing & Packaging Decomposition** — work-breakdown of price tiers × feature gating × discount mechanics × ICP
   alignment; surfaces the commercial wrapper around the product. Output: **Pricing-Packaging Matrix** — rows:
   tier_name, list_price, billing_period, gated_features[], gated_limits[], target_ICP, contract_length_signals,
   discount_mechanics, evidence_url. Skeptic challenge surface: tiers without list price (publicly opaque pricing must
   be flagged, not invented), gated features that contradict the Product Inspector's Feature Inventory Matrix
   (cross-dimensional contradiction), ICP claims unsupported by case-study or review evidence.

3. **Review-Sentiment Heuristic Evaluation** — checklist-driven extraction of recurring complaint and strength themes
   from review platforms, with evidence clustering (NOT a single-quote-equals-trend fallacy). Output: **Sentiment
   Pattern Ledger** — rows: theme, polarity (+/-), frequency_count (n=...), evidence_cluster (links to ≥3 corroborating
   reviews), representative_quote, platform_distribution. Skeptic challenge surface: themes with frequency_count below
   the brief's threshold, themes claimed positive / negative without ≥3 corroborating reviews, representative_quote that
   is unrepresentative of the cluster, themes drawn from a single platform asserted as universal.

4. **Salience Matrix (GTM-scoped)** — rank GTM findings (top pricing levers, top channel signals, top sentiment
   patterns, top messaging hooks) per auditor directive 2. Output: **GTM Salience Matrix** — same schema as Market
   Salience Matrix, scoped to GTM evidence. Skeptic challenge surface: same schema, plus: messaging-hook claims without
   a marketing-page citation; channel-signal claims without job-posting / partner-directory corroboration.

---

## METHODOLOGY MANIFEST: Strategist (Phase 3, cross-dimensional gap analysis and ranked positioning)

Methodologies:

1. **Cross-dimensional SWOT Synthesis** — pull each dimension's Salience Matrix top-rankings into a single SWOT, where
   Strengths and Weaknesses are competitor-internal and Opportunities and Threats are external-to-competitor (which
   translate to OUR opportunity and risk surface). Output: **Competitor SWOT Quadrant** — four quadrants, each with
   rows: claim, evidence_pointer (back to the specific Salience Matrix row in a specific researcher's findings),
   salience_score_inherited. Skeptic challenge surface: SWOT rows without an evidence_pointer to a researcher's Salience
   Matrix entry, claims that contradict another quadrant (e.g., listed both as a strength AND a weakness without a
   contextual qualifier), strengths that are merely "the product exists".

2. **Gap-Fit Matrix** — gaps in the competitor's offering × our ability to capitalize, with risk-of-competing per gap.
   This is the core deliverable that feeds the Executive Summary's positioning bets. Output: **Gap-Fit Matrix** — rows:
   gap_id, gap_description, evidence_pointer, gap_severity (1–5), our_fit_score (1–5), capitalization_risk (1–5, higher
   = riskier), combined_priority (gap_severity × our_fit ÷ capitalization_risk), rank. Skeptic challenge surface: gaps
   without evidence_pointer, our_fit_score without a defensible basis (we don't have product evidence at this stage —
   but we can note plausibility), capitalization_risk left at 1 (suspiciously optimistic), combined_priority
   calculations that don't match the formula, top-ranked gaps unsupported by the underlying SWOT row.

3. **Evidence-Recommendation Traceability Matrix** — every positioning recommendation maps to ≥1 Gap-Fit Matrix row and
   ≥1 underlying Salience Matrix finding from a specific researcher. Output: **Traceability Matrix** — rows:
   recommendation_id, recommendation_text, gap_fit_row_ids[], salience_row_ids[], finding_evidence_urls[]. Skeptic
   challenge surface: recommendations with no upstream gap-fit row (speculation), recommendations whose finding URLs
   don't actually support the recommendation when read, recommendations that exceed the evidence (over-capitalization
   claim), recommendations citing findings flagged as low evidence_strength.

4. **Devil's Advocate Pre-Pass** — for each top-ranked recommendation, run a self-administered counter-argument before
   submission: assume the recommendation is wrong and find the strongest reason it could be wrong. Output:
   **Counter-argument Log** — rows: recommendation_id, strongest_objection, objection_evidence_or_logic, resolution
   (recommendation kept / kept with caveat / withdrawn), residual_risk. Skeptic challenge surface: recommendations
   submitted without a counter-argument log entry, objections that are strawmen, "kept with caveat" recommendations
   whose caveat doesn't appear in the final dossier copy, residual_risk claimed as zero.

---

## METHODOLOGY MANIFEST: Chronicler (Phase 4, audience-tiered dossier authorship)

Methodologies:

1. **Audience Tiering Framework** — explicit per-layer rubric for the four-layer dossier (Executive Summary → General
   Review → Technical Details → Reference Sources), with stated audience, decision horizon, evidence-density target, and
   content-type permissions per layer. Output: **Audience Tiering Rubric** — rows: layer, intended_audience,
   decision_horizon, max_words, evidence_density_target (claims per 100 words), permitted_content_types,
   forbidden_content_types. Skeptic challenge surface: layers without a clearly distinct audience (collapse risk),
   executive-layer rows whose evidence density is too low to be decision-ready or too high to be readable,
   technical-layer permissions that overlap the executive layer (tier collapse), forbidden-content-type fields that are
   empty (no enforcement teeth).

2. **Progressive Disclosure Decomposition** — work-breakdown of dossier sections by layer; each layer must stand alone
   (an executive who reads only the Executive Summary leaves with a complete decision-ready picture; an operator who
   reads only Technical Details has full evidence depth). Output: **Dossier Section Plan** — rows: layer, section,
   source_artifacts (which Salience / Gap-Fit / Traceability rows feed it), word_budget, lead_claim,
   supporting_claims[]. Skeptic challenge surface: sections that source from artifacts not approved at the prior gate,
   layers that don't stand alone (executive layer with claims that only resolve in lower layers, breaking the standalone
   promise), word_budgets that crowd out evidence in the executive tier, lead_claims that don't surface a Strategist top
   recommendation.

3. **Reference Resolution Map** — every claim made in higher layers carries a forward-pointer to its evidence in the
   Reference Sources layer; every reference resolves to a real, accessible URL with access date. Output: **Reference
   Resolution Map** — rows: claim_id, claim_layer, claim_text, evidence_id, evidence_layer, evidence_url, access_date,
   resolved_status (resolved / broken / missing). Skeptic challenge surface: any row with resolved_status not
   "resolved", claims in the executive layer with no claim_id, evidence URLs that 404 or paywall (must be flagged, not
   suppressed), access dates outside the brief's freshness window, claims that resolve to evidence weaker than the
   claim's confidence implies.

---

## METHODOLOGY MANIFEST: Skeptic (Phases 1.5, 2.5, 3.5, 4.5 — adversarial gate)

Per auditor directive 3, the Skeptic carries FOUR DISTINCT challenge methodologies — one per gate — each tuned to the
failure-mode profile of that gate's input artifact. Per auditor directive 4, the Dossier Gate methodology
operationalizes tone enforcement with a banned-phrase pattern list and an adjective-evidence audit.

Methodologies:

1. **Brief Gate Challenge Protocol (Gate 1.5)** — boundary-violation checklist applied to the Lead's Competitor Brief:
   scope drift, ambiguous target identity, untestable success criteria, dimensional coverage gaps, source-seed
   credibility. Output: **Brief Gate Verdict Log** — rows: challenge_id, challenge_category (scope-drift /
   ambiguous-target / untestable-criteria / coverage-gap / seed-credibility), artifact_pointer (Identity Card field /
   Question Set cell / Source Seed Table row / Coverage Threshold Checklist row), finding, verdict (pass / soft-fail /
   hard-fail), required_action, recheck_on_revision. Skeptic challenge surface: this IS the Skeptic's output — the
   structured artifact that the Skeptic uses to either gate the brief or rubber-stamp it. The Skeptic must cite a
   specific row of the Lead's artifacts in every hard-fail.

2. **Findings Gate Claim Provenance Audit (Gate 2.5)** — every claim in the four Dimensional Findings traced to URL +
   access date; cross-dimensional contradiction scan against the Mandate Boundary Tests; Source Triage compliance audit
   (every non-seed source carries a credibility justification, per auditor directive 1); Salience Matrix
   ranking-justification audit (per auditor directive 2). Output: **Findings Gate Verdict Log** — rows: challenge_id,
   dimension (market / product / technical / GTM / cross), challenge_category (provenance / hallucination /
   source-triage / contradiction / salience-justification), claim_or_artifact_pointer, finding, evidence_url_audited,
   verdict, required_action. Skeptic challenge surface: the Skeptic's audit trail itself — every hard-fail must point at
   a specific Source Triage Log row, Salience Matrix row, or specific finding text. Cross-dimensional contradictions
   must name BOTH dimensions and BOTH cited rows.

3. **Synthesis Gate Evidence-Recommendation Traceability Audit (Gate 3.5)** — verify the Strategist's Traceability
   Matrix end-to-end; run a parallel Devil's Advocate Protocol against the Strategist's Counter-argument Log (the
   Skeptic looks for objections the Strategist missed); over-capitalization detection (recommendations claiming more
   than the evidence supports). Output: **Synthesis Gate Verdict Log** — rows: challenge_id, recommendation_id,
   challenge_category (traceability-broken / speculation / over-capitalization / missed-objection / risk-understated),
   finding, traced_evidence_audit_result, verdict, required_action. Skeptic challenge surface: every hard-fail must cite
   a specific Traceability Matrix row and the actual evidence URL; missed-objection challenges must include the
   objection the Strategist's Counter-argument Log did not consider.

4. **Dossier Gate Marketing-Language Audit (Gate 4.5)** — operational tone enforcement (per auditor directive 4):
   banned-phrase pattern detection ("revolutionary", "best-in-class", "industry-leading", "cutting-edge",
   "next-generation", "world-class", "unparalleled", "game-changing", "pioneering"), with auto-rejection unless the
   phrase appears inside a direct attributed quote with a citation; adjective-to-evidence pairing audit (every adjective
   applied to the competitor must be tied to a cited Reference Resolution Map entry); progressive-disclosure
   layer-correctness check; reference resolution status check. Output: **Dossier Gate Verdict Log** — rows:
   challenge_id, layer (executive / general / technical / reference), challenge_category (banned-phrase /
   unsourced-adjective / layer-violation / unresolved-reference / standalone-failure), text_excerpt, finding, verdict,
   required_action. Plus two sub-tables: **Banned-Phrase Strike List** (phrase, occurrences[], context_excerpt,
   attributed_quote_y_n, verdict) and **Adjective-Evidence Map** (adjective, target, evidence_pointer_or_null, verdict).
   Skeptic challenge surface: the strike list and adjective-evidence map ARE the surface — every hard-fail cites a
   specific text excerpt with line / paragraph reference. A banned phrase outside an attributed quote is an automatic
   hard-fail; the Skeptic does not negotiate.

---

## Overlap Check

| Agent A             | Agent B                 | Shared Output Type | Assessment                                                                                                                                                                                                                                                                                                                                                                                               |
| ------------------- | ----------------------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Market Cartographer | Product Inspector       | Source Triage Log  | **Intentional, auditor-mandated.** Auditor directive 1 requires Source Triage on ALL FOUR researchers. Each instance is dimension-scoped (different evidence corpus, different rows). Same schema by design — this is what gives the Skeptic a single, uniform compliance check at Gate 2.5.                                                                                                             |
| Market Cartographer | Technical Excavator     | Source Triage Log  | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Market Cartographer | Go-to-Market Analyst    | Source Triage Log  | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Product Inspector   | Technical Excavator     | Source Triage Log  | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Product Inspector   | Go-to-Market Analyst    | Source Triage Log  | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Technical Excavator | Go-to-Market Analyst    | Source Triage Log  | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Market Cartographer | Product Inspector       | Salience Matrix    | **Intentional, auditor-mandated.** Auditor directive 2 requires a NAMED Salience Matrix methodology with a structured artifact for the "Top Items for Synthesis" handoff from each researcher to the Strategist. Same schema by design — this is what gives the Strategist a single, uniform consumption format and the Skeptic a single ranking-justification check. Each instance is dimension-scoped. |
| Market Cartographer | Technical Excavator     | Salience Matrix    | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Market Cartographer | Go-to-Market Analyst    | Salience Matrix    | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Product Inspector   | Technical Excavator     | Salience Matrix    | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Product Inspector   | Go-to-Market Analyst    | Salience Matrix    | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Technical Excavator | Go-to-Market Analyst    | Salience Matrix    | Same as above.                                                                                                                                                                                                                                                                                                                                                                                           |
| Skeptic (1.5)       | Skeptic (2.5, 3.5, 4.5) | Verdict Log        | **Intentional, single agent.** Four distinct gate-specific methodologies (per auditor directive 3) each produce their own Verdict Log variant. The Verdict Log "shape" is shared so the Forge Master and Lead can route rejections uniformly; the row schemas and challenge categories are gate-specific. This is one agent producing four artifacts, NOT a mandate overlap.                             |

**Distinct matrix-shaped outputs across the team (no actual overlap, different schemas):**

- PESTLE Matrix (Cartographer) — PESTLE letter × observed factor × impact × evidence × signal strength
- Feature Inventory Matrix (Inspector) — capability taxonomy × present × tier-gate × evidence × last-observed
- Pricing-Packaging Matrix (GTM) — tier × price × billing × gated features × ICP × contract × discount × evidence
- Gap-Fit Matrix (Strategist) — gap × severity × our-fit × capitalization-risk × combined-priority × rank
- Traceability Matrix (Strategist) — recommendation × gap-fit-rows × salience-rows × evidence-urls

These all use the word "matrix" but are structurally distinct artifacts with different rows, columns, and challenge
surfaces. No overlap.

---

## Notes for Forge Master

- **All auditor directives honored.** Directive 1 (Source Triage on all four researchers) implemented via the Source
  Seed Table at Lead and the Source Triage Log at each researcher, with the Skeptic's Findings Gate Claim Provenance
  Audit explicitly auditing source-triage compliance. Directive 2 (Salience Matrix as named methodology with structured
  artifact) implemented identically at all four researchers, with the Strategist consuming via a defined schema.
  Directive 3 (four distinct Skeptic challenge methodologies) implemented as the Brief Gate Challenge Protocol, the
  Findings Gate Claim Provenance Audit, the Synthesis Gate Evidence-Recommendation Traceability Audit, and the Dossier
  Gate Marketing-Language Audit — each tuned to its gate's failure-mode profile. Directive 4 (operationalized tone
  enforcement at Gate 4.5) implemented via the Dossier Gate Marketing-Language Audit's Banned-Phrase Strike List and
  Adjective-Evidence Map sub-artifacts, with auto-rejection unless the phrase is inside a direct attributed quote with
  citation.

- **No phase resists categorization.** Every agent maps cleanly to a methodology category. No design problems flagged
  for the Forge Master.

- **Methodology counts:** Lead 4, Cartographer 4, Inspector 4, Excavator 4, GTM 4, Strategist 4, Chronicler 3,
  Skeptic 4. All within the 2–4 bound.

- **Pass-through for Lorekeeper:** The named methodologies above must be referenced BY NAME in each agent's spawn
  prompt. The Skeptic's spawn prompt needs an explicit `WHAT YOU CHALLENGE` block per gate as the auditor instructed —
  the four methodology names map 1:1 to those four blocks.

- **Pass-through for Scribe:** The four `GATE:` markers in the Orchestration Flow correspond to the Skeptic's four named
  methodologies. Each agent's Output Format section in the SKILL.md should reference the structured artifact name (e.g.,
  "produce a Salience Matrix per the schema below") rather than describing the artifact freely.

### Forge Auditor Forward Notes (folded in from Phase 2a seal)

Non-blocking guidance from forge-auditor-f2a8 (Thane Hallward) for Lorekeeper and Scribe to address in Phase 2b / Phase
3:

1. **Rename "Integration Dependency Graph" to a table-shaped name OR add a real graph diagram.** The artifact as schemed
   is a row-shaped table, not a node-edge graph. Scribe should either rename it to "Integration Dependency Map" /
   "Integration Dependency Table" in the SKILL.md Output Format, or have the Technical Excavator render BOTH a table and
   an actual graph diagram. Recommended path: rename to **Integration Dependency Map** (preserves the "map" semantics
   already used elsewhere — Reference Resolution Map, JTBD Map — and avoids the false-graph implication).

2. **Inspector's JTBD evidence permissibly cross-cuts GTM-seeded sources.** Reviews, customer quotes, and case studies
   are seeded under the GTM dimension, but the Product Inspector legitimately needs them to validate JTBD mappings.
   Lorekeeper should phrase the Inspector's spawn prompt to grant explicit cross-dimensional read access for JTBD
   evidence (i.e., "you may cite review-platform / case-study URLs for JTBD evidence; cross-dimensional citation must
   include a one-line justification just like a non-seed source"). The Skeptic's Findings Gate compliance check at 2.5
   should treat such citations as compliant when accompanied by the justification.

3. **Researcher Salience formula vs. Strategist Gap-Fit formula are intentionally distinct.** Researchers use
   `importance × evidence_strength` (additive ranking under uncertainty); Strategist uses
   `gap_severity × our_fit ÷ capitalization_risk` (risk-adjusted prioritization). These are different jobs and the
   formula divergence is correct. The Skeptic's existing challenge surfaces (Salience Matrix ranking-justification at
   Gate 2.5; combined-priority calculation audit at Gate 3.5) already cover formula-mismatch detection. No revision
   needed.

4. **Coverage Threshold Checklist is authored under intake-time uncertainty.** The Lead writes thresholds (≥N pricing
   tiers, ≥M customer logos, etc.) before researchers begin. Some thresholds may prove unachievable for opaque
   competitors (private companies, no public pricing). The Skeptic's "untestable-criteria" challenge category at Gate
   1.5 already covers defensibility audit; Lorekeeper should ensure the Lead's spawn prompt notes that thresholds are
   minima-with-justified-exceptions, not absolute floors.

---

## Checkpoint Log

- [00:00] Task claimed (armorer-f2a8)
- [00:05] Read armorer persona, architect blueprint, auditor directives
- [00:15] Methodology selection started — mapped each agent's phase / concern to a methodology category
- [00:35] Manifest drafted — 8 agents armed, overlap check completed, auditor directives cross-checked
- [00:40] Submitted to forge-auditor-f2a8 for review
- [00:55] Audit returned APPROVED — four non-blocking forward notes folded into pass-through section
- [01:00] Manifest finalized — status set to complete, sealed for Phase 2b consumption
