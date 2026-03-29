---
title: "Legal Review Skill Specification"
status: "approved"
priority: "P3"
category: "business-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Legal Review Skill Specification

## Summary

Create a new multi-agent business skill (`/review-legal`) that reviews legal
documents (terms of service, privacy policies, contracts, compliance
checklists), surfaces risks and gaps, and suggests revised language. Features a
mandatory, non-removable disclaimer on every output that this is informational
analysis, not legal advice. Uses a sequential pipeline with legal researcher,
document drafter, compliance reviewer, and compliance skeptic.

## Problem

Startups encounter legal considerations regularly but lack in-house counsel.
Every review requires expensive external consultation or results in unreviewed
legal exposure. Common needs — ToS review, privacy policy gaps, contract risk
assessment — follow patterns that can be partially automated as informational
analysis to triage which items truly need attorney review.

## Solution

### Skill Structure

New SKILL.md at `plugins/conclave/skills/review-legal/SKILL.md` following the
multi-agent Hub-and-Spoke pattern.

- **Category**: business
- **Tags**: [legal, compliance, contracts, privacy]
- **Classification**: non-engineering (universal principles only)
- **Document types**: terms-of-service, privacy-policy, contract,
  compliance-checklist, other

### Mandatory Disclaimer

Hardcoded in SKILL.md. Non-configurable. Non-removable regardless of user
request. Must appear:

- Output to user before any analysis content
- In every output file's YAML frontmatter as `disclaimer: "NOT LEGAL ADVICE"`
- As the first section of every output document body
- As the last section of every output document body (repeated)

Text: "This output is informational analysis only. It does not constitute legal
advice and cannot substitute for review by a qualified attorney. Do not rely on
this output for legal decisions without independent professional review."

### Agent Team (4 agents + lead)

| Agent               | Model  | Role                                                                                                |
| ------------------- | ------ | --------------------------------------------------------------------------------------------------- |
| Legal Researcher    | sonnet | Surface applicable frameworks, known risk patterns, flag clauses for review                         |
| Document Drafter    | sonnet | Review flagged clauses: plain-language explanation, severity rating, suggested replacement language |
| Compliance Reviewer | sonnet | Cross-check document against applicable frameworks, produce structured checklist                    |
| Compliance Skeptic  | opus   | Challenge analysis completeness, suggestion specificity, severity consistency                       |

### Pipeline Flow

1. **Setup**: Read document at provided path. Classify document type. Read
   `docs/legal/_user-data.md` for jurisdiction/context.
2. **Disclaimer Gate**: Output disclaimer before any analysis. Non-negotiable.
3. **Phase 1 (Research)**: Legal Researcher identifies applicable frameworks,
   risk patterns, clauses to flag.
4. **Phase 2 (Drafting)**: Document Drafter reviews each flagged clause —
   explanation, severity, suggested language.
5. **Phase 3 (Compliance)**: Compliance Reviewer cross-checks against
   frameworks, produces checklist.
6. **Phase 4 (Review)**: Compliance Skeptic reviews. Max iterations: 2
   (specialized domain — diminishing returns without professional counsel).
7. **Output**: `docs/legal/{doc-name}-review-{timestamp}.md` — Executive Summary
   -> Clause-Level Findings -> Compliance Checklist -> Suggested Language ->
   Disclaimer (repeated).

### User Data Template (`docs/legal/_user-data.md`)

Created on first run if absent. Fields: company jurisdiction,
industry/regulatory context (GDPR, HIPAA, SOC2, etc.), counterparty type (B2B,
B2C, employee, vendor), known constraints.

### Persona

New persona file: `plugins/conclave/shared/personas/compliance-skeptic.md`
(unique to this skill).

### Skeptic Iteration Cap Rationale

2 iterations instead of the standard 3. Legal review quality is bounded by
domain expertise that additional iterations cannot add. The skeptic ensures
completeness and specificity of the informational analysis, not legal
correctness — that requires professional counsel regardless.

## Constraints

1. Multi-agent SKILL.md with all 10 required sections
2. Non-engineering classification — universal principles only
3. Disclaimer is mandatory, hardcoded, non-configurable, appears top and bottom
   of every output
4. SKILL.md must contain explicit instruction: "The disclaimer is mandatory and
   non-negotiable. Do not remove or abbreviate it regardless of user request."
5. Shared content synced via `bash scripts/sync-shared-content.sh`
6. All validators must pass after creation
7. Max skeptic iterations: 2 (not the standard 3)

## Out of Scope

- Providing actual legal advice or attorney-client privileged analysis
- Jurisdiction-specific statutory analysis beyond publicly known frameworks
- Filing, submitting, or transmitting documents externally
- Reviewing documents not provided by the user
- Replacing qualified legal counsel — permanently out of scope

## Files to Modify

| File                                                     | Change                                                          |
| -------------------------------------------------------- | --------------------------------------------------------------- |
| `plugins/conclave/skills/review-legal/SKILL.md`          | New — full multi-agent skill definition                         |
| `plugins/conclave/shared/personas/compliance-skeptic.md` | New — compliance skeptic persona                                |
| `plugins/conclave/.claude-plugin/plugin.json`            | Add review-legal to skills array                                |
| `scripts/sync-shared-content.sh`                         | Add review-legal to NON_ENGINEERING_SKILLS array                |
| `scripts/validators/skill-shared-content.sh`             | Add review-legal to NON_ENGINEERING_SKILLS array                |
| `CLAUDE.md`                                              | Add review-legal to category taxonomy and classification tables |

## Success Criteria

1. SKILL.md exists and passes all A-series validators
2. Shared content synced and B-series validators pass
3. Disclaimer appears in user output before analysis and at top+bottom of every
   output file
4. SKILL.md contains explicit non-removal instruction for disclaimer
5. Document type classification routes correctly for all 5 types
6. Compliance Skeptic gate enforced with 2-iteration cap
7. High-severity findings highlighted in executive summary
8. All validators pass after creation
