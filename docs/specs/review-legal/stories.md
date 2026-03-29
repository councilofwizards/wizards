---
type: "user-stories"
feature: "review-legal"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-18-review-legal.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: P3-18 Legal Review Skill (review-legal)

## Epic Summary

Startups encounter terms of service, privacy policies, contracts, and compliance
questions regularly, but lack in-house counsel. `/review-legal` defines a
multi-agent skill with a legal researcher, document drafter, compliance
reviewer, and skeptic that reviews a provided document, surfaces risks and gaps,
and suggests revised language — with a prominent, non-removable disclaimer on
every output that this is informational analysis, not legal advice.

## Stories

### Story 1: Document Discovery, Type Classification, and Disclaimer Gate

- **As a** startup founder with a legal document needing review
- **I want** to invoke `/review-legal [doc-path]` and have the skill classify
  the document type and surface a disclaimer before any analysis begins
- **So that** the review is scoped to the right framework and I cannot miss the
  limitation notice
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given I invoke `/review-legal docs/legal/privacy-policy.md`, when Setup
     runs, then it reads and classifies the document as one of:
     terms-of-service, privacy-policy, contract, compliance-checklist, or other.
  2. Given the document is classified, when the run begins, then a mandatory
     disclaimer is output before any analysis content.
  3. Given no path argument, when Setup runs, then the Team Lead checks
     `docs/legal/` for unreviewed documents and proposes or lists them.
  4. Given the path does not exist, when Setup runs, then it reports the missing
     path and exits without spawning agents.
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then
     all validators pass.
- **Edge Cases**:
  - Binary/non-markdown files: note inability to read and request plain-text
    version.
  - Very long documents (>5000 words): ask user whether to review full or
    specific sections.
  - `--light` flag: skip legal researcher; compliance reviewer works directly
    from document text.
- **Notes**: Disclaimer text is hardcoded in SKILL.md — non-configurable,
  non-removable. Must appear in every output file frontmatter as
  `disclaimer: "NOT LEGAL ADVICE"` and as first and last section of document
  body.

### Story 2: Multi-Agent Legal Analysis

- **As a** founder using `/review-legal`
- **I want** a legal researcher to surface relevant standards, a document
  drafter to suggest revised language, and a compliance reviewer to cross-check
  against frameworks
- **So that** the review covers risk identification, suggested fixes, and
  compliance gaps in one pass
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given disclaimer is surfaced, when Phase 1 runs, then the legal researcher
     produces: applicable frameworks, known risk patterns, and clauses flagged
     for deeper review.
  2. Given researcher findings, when Phase 2 runs, then the document drafter
     reviews each flagged clause producing: plain-language explanation, risk
     severity (high/medium/low), and suggested replacement language.
  3. Given drafter's review, when Phase 3 runs, then the compliance reviewer
     cross-checks against applicable frameworks producing a structured
     checklist.
  4. Given all agents complete, when the Team Lead aggregates, then output is:
     Executive Summary -> Clause-Level Findings (by severity) -> Compliance
     Checklist -> Suggested Language -> Disclaimer (repeated).
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then
     all validators pass.
- **Edge Cases**:
  - Jurisdiction uncertainty: default to US law, flag that findings may differ
    for other jurisdictions.
  - Conflicting findings between drafter and compliance reviewer: surface
    conflict explicitly.
  - Contract type: additionally identify missing standard provisions, one-sided
    terms, undefined terms.
- **Notes**: Sequential pipeline (researcher -> drafter -> compliance reviewer).
  `_user-data.md` includes: jurisdiction, industry/regulatory context,
  counterparty type, known constraints.

### Story 3: Skeptic Review Gate and Disclaimer-Preserved Output

- **As a** founder reading the legal review output
- **I want** a skeptic to challenge the analysis and every output to carry the
  disclaimer prominently
- **So that** the review passes adversarial quality check and the disclaimer
  cannot be overlooked
- **Priority**: must-have
- **Acceptance Criteria**:
  1. Given the aggregated review, when the skeptic reviews, then it evaluates:
     severity ratings present, suggestions specific enough to act on, compliance
     checklist covers all identified frameworks.
  2. Given issues found, when revision is needed, then agents revise. Max
     iterations: 2 (specialized domain — diminishing returns without
     professional counsel).
  3. Given approval, when the Team Lead writes to
     `docs/legal/{doc-name}-review-{timestamp}.md`, then the file has:
     disclaimer frontmatter + disclaimer block (top) + findings + disclaimer
     block (bottom).
  4. Given the output file, when a user reads it, then the disclaimer appears at
     both top and bottom — impossible to read findings without passing through
     it.
  5. Given I run `bash scripts/validate.sh` after the SKILL.md is created, then
     all validators pass.
- **Edge Cases**:
  - Max iterations without approval: write best output with
    `skeptic_approved: false`; disclaimer still present.
  - User asks to remove disclaimer: Team Lead declines — SKILL.md contains
    explicit instruction that disclaimer is mandatory and non-negotiable.
  - High-severity findings: executive summary opens with callout listing all
    high-severity items.
- **Notes**: Compliance Skeptic persona at
  `plugins/conclave/shared/personas/compliance-skeptic.md`. 2-iteration cap
  chosen because legal review quality is bounded by domain expertise that
  additional iterations cannot add — the skeptic ensures completeness and
  specificity, not legal correctness.

## Non-Functional Requirements

- Multi-agent SKILL.md with all 10 required sections.
- Non-engineering skill. Category: `business`. Tags:
  `[legal, compliance, contracts, privacy]`.
- Disclaimer is hardcoded, non-configurable, appears top and bottom of every
  output.
- Output: YAML frontmatter with type: legal-review, document-type, status:
  informational, disclaimer, skeptic_approved, jurisdiction, created.

## Out of Scope

- Providing actual legal advice or attorney-client privileged analysis.
- Jurisdiction-specific statutory analysis beyond publicly known frameworks.
- Filing or transmitting documents externally.
- Reviewing documents not provided by the user.
- Replacing qualified legal counsel.
