---
feature: "artifact-format-templates"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed comprehensive analysis of all existing artifact formats"
updated: "2026-02-14T19:00:00Z"
---

## Progress Notes

- [18:45] Claimed task #1, began reading all artifact files
- [18:50] Read all specs, progress files, architecture docs, SKILL.md files, and roadmap items
- [19:00] Completed analysis, compiled findings below

---

# Research Findings: Existing Artifact Formats

## 1. Artifact Types Identified

There are **6 distinct artifact types** in the project:

1. **Roadmap Items** (`docs/roadmap/*.md`) - defined by ADR-001
2. **Feature Specs** (`docs/specs/{feature}/spec.md`) - no template exists
3. **Progress Summaries** (`docs/progress/{feature}.md`) - no template exists
4. **Checkpoint Files** (`docs/progress/{feature}-{role}.md`) - format defined in SKILL.md
5. **Architecture Decision Records** (`docs/architecture/*.md`) - no template exists
6. **Cost Summaries** (`docs/progress/{skill}-{feature}-{timestamp}-cost-summary.md`) - format defined in cost-guardrails spec

---

## 2. Roadmap Items (WELL-DEFINED)

**Template status**: Effectively defined by ADR-001. Consistent across all 14 files.

**Structure**:
```yaml
---
title: "Feature Name"
status: "not_started"          # not_started | spec_in_progress | ready | impl_in_progress | complete | blocked
priority: "P1"                 # P1 | P2 | P3
category: "core-framework"     # core-framework | new-skills | developer-experience | quality-reliability | documentation
effort: "medium"               # small | medium | large
impact: "high"                 # low | medium | high
dependencies: []               # List of slugs
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
---

# Feature Name

## Problem
## Proposed Solution
## Architectural Considerations
## Success Criteria
```

**Variations found**: NONE. All 14 roadmap items follow this structure exactly.

**Assessment**: This format is solid and needs no changes. ADR-001 serves as its de facto template.

---

## 3. Feature Specs (INCONSISTENT - needs template)

**Files examined**: 2 specs exist.

### `docs/specs/project-bootstrap/spec.md`
- No YAML frontmatter
- Sections: Summary, Problem, Change (with subsections), Seed Files, Properties, Out of Scope, Success Criteria
- Very implementation-oriented (specific line numbers, before/after text)

### `docs/specs/cost-guardrails/spec.md`
- Has YAML frontmatter: `title`, `status`, `priority`, `category`, `approved_by`, `created`, `updated`
- Sections: Summary, numbered sections (1-7): Lightweight Mode Definition, SKILL.md Changes, Cost Summary Format, README Updates, Non-Negotiable Constraints, Success Criteria, Files to Modify
- Much more structured, with progressive disclosure

**Key inconsistencies**:
- One has frontmatter, the other does not
- Section naming differs completely (no shared section structure)
- One uses numbered sections, the other uses named sections
- `approved_by` field only in cost-guardrails (good idea, should standardize)
- The bootstrap spec lacks a Problem section header (embeds it in Summary)
- The cost-guardrails spec has `status: "ready_for_implementation"` in frontmatter which mirrors the roadmap status

**What works well (keep)**:
- Progressive disclosure (summary first, details later) in cost-guardrails
- `approved_by` field tracking Skeptic approval
- `Files to Modify` section (useful handoff to build-product)
- `Success Criteria` as a concrete checklist
- `Non-Negotiable Constraints` (keeps guard rails explicit)

**What's inconsistent (fix)**:
- Frontmatter presence/absence
- Section naming and ordering
- No shared skeleton between specs

---

## 4. Progress Summaries (INCONSISTENT - needs template)

**Files examined**: 5 "summary" progress files (team lead aggregates):
- `concurrent-write-safety.md`
- `cost-guardrails.md`
- `project-bootstrap.md`
- `stack-generalization.md`
- `state-persistence.md`

**Common structure across all 5**:
```yaml
---
feature: "feature-slug"
status: "complete"
completed: "YYYY-MM-DD"
---

# {Priority}: {Title} -- Progress

## Summary
## Files Modified
## Verification
```

**Variations**:
- `cost-guardrails.md` has extra sections: Changes (with subsections: Lightweight Mode, Cost Summary Steps, Argument Hints, README)
- `concurrent-write-safety.md` has shorter Files Modified entries (just filename + brief description)
- Others use the same compact format: Summary, Files Modified, Verification
- Files Created section only in `stack-generalization.md` (because it actually created new files)

**What works well (keep)**:
- YAML frontmatter with `feature`, `status`, `completed`
- `Files Modified` section for audit trail
- `Verification` section confirming quality gates passed

**What's inconsistent (fix)**:
- Frontmatter lacks `team` field (which checkpoint files have)
- No consistent title format (some have priority prefix, all do)
- Files Created only present when applicable (fine, but should be noted in template)

**Overall assessment**: These are actually quite consistent. The core 3 sections (Summary, Files Modified, Verification) appear in all 5. The main gap is that there's no template formalizing this pattern.

---

## 5. Checkpoint Files (WELL-DEFINED in SKILL.md)

**Files examined**: 4 checkpoint files:
- `cost-guardrails-architect.md`
- `cost-guardrails-impl-architect.md`
- `p1-01-impl-architect.md`
- `p1-02-impl-architect.md`
- `p1-03-impl-architect.md`

**Format defined in SKILL.md** (identical across all 3 skills):
```yaml
---
feature: "feature-name"
team: "{skill-name}"
agent: "role-name"
phase: "{phase}"        # varies by skill
status: "in_progress"   # in_progress | blocked | awaiting_review | complete
last_action: "Brief description"
updated: "ISO-8601 timestamp"
---

## Progress Notes

- [HH:MM] Action taken
```

**Actual files vs. template**:
- `cost-guardrails-architect.md`: Follows format PLUS has full design document appended after progress notes (separated by `---`)
- `cost-guardrails-impl-architect.md`: Has `role` instead of `agent` in frontmatter. Has full implementation plan as body.
- `p1-01-impl-architect.md`: Uses `role` instead of `agent`. Uses `status: "plan-pending-review"` (not in defined enum). Lacks `team`, `last_action`, `updated` fields.
- `p1-02-impl-architect.md`: Same as p1-01 -- uses `role`, lacks `team`/`last_action`/`updated`.
- `p1-03-impl-architect.md`: Same pattern as above.

**Key inconsistencies**:
- `role` vs `agent` field name (3 files use `role`, 1 uses `agent`)
- Early files (p1-*) lack `team`, `last_action`, `updated` fields
- `status` values not in the defined enum (`plan-pending-review` instead of `awaiting_review`)
- Some files include extensive design documents below progress notes (useful but undocumented)

**Assessment**: The template is well-defined in SKILL.md but actual files produced before the checkpoint protocol was formalized (P1-02) don't conform. This is expected -- the format was defined retroactively. Going forward, new checkpoints should conform. The main issue is the `role` vs `agent` field name inconsistency which appears even in files created after P1-02 was implemented.

---

## 6. Architecture Decision Records (1 INSTANCE - needs template)

**File examined**: `ADR-001-roadmap-file-structure.md`

**Structure**:
```markdown
# ADR-001: Title

## Status
## Context
## Decision
## Alternatives Considered
## Consequences
```

- No YAML frontmatter (uses markdown `## Status` instead)
- Follows the classic ADR format (Michael Nygard pattern)
- Only one instance exists, so variation analysis is impossible

**What works well (keep)**:
- Standard ADR format that's widely recognized
- Clear Status/Context/Decision/Consequences structure
- Alternatives Considered section

**What needs formalization**:
- Should have YAML frontmatter for machine parseability (status field especially)
- Naming convention `ADR-{NNN}-{slug}.md` is clear but should be documented
- No date fields in the document

---

## 7. Cost Summary Format (DEFINED but no instances yet)

Defined in the cost-guardrails spec but no actual cost summary files have been produced yet (the format was just implemented). The format is:

```yaml
---
skill: "plan-product"
mode: "new"
lightweight: false
feature: "user-authentication"
timestamp: "ISO-8601"
---

## Invocation Summary

| Agent | Model | Role | Spawned |
|-------|-------|------|---------|
[table rows]

- **Total agents spawned**: N
- **Opus agents**: N
- **Sonnet agents**: N
- **Estimated relative cost**: High/Medium/Low
- **Skeptic rejections**: N
- **Outcome**: Description
```

**Assessment**: Well-specified. No deviations possible yet since none have been produced.

---

## 8. Implicit Format Expectations in SKILL.md Files

The 3 SKILL.md files embed several format expectations that should be captured in templates:

### Embedded in all 3 SKILL.md files:
- **Write Safety convention**: `docs/progress/{feature}-{role}.md` naming pattern
- **Checkpoint file format**: YAML frontmatter with specific fields (see section 5)
- **Phase enums vary by skill**:
  - plan-product: research | design | review | complete
  - build-product: planning | contract-negotiation | implementation | testing | review | complete
  - review-quality: testing | auditing | review | complete
- **Status enum**: in_progress | blocked | awaiting_review | complete (shared across all)

### Embedded in Skeptic/Reviewer prompts:
- **Review format** (Product Skeptic):
  ```
  REVIEW: [what]
  Verdict: APPROVED / REJECTED
  Issues: [numbered list with specific fixes]
  Notes: [if approved]
  ```
- **Quality Review format** (Quality Skeptic):
  ```
  QUALITY REVIEW: [scope]
  Gate: PRE-IMPLEMENTATION / POST-IMPLEMENTATION
  Verdict: APPROVED / REJECTED
  Blocking Issues / Non-blocking Issues / Notes
  ```
- **Ops Review format** (Ops Skeptic):
  ```
  OPS REVIEW: [what]
  Verdict: APPROVED / REJECTED
  Blocking Issues / Non-blocking Issues / Conditions / Notes
  ```

### Embedded in research/audit prompts:
- **Research findings format** (Researcher):
  ```
  RESEARCH FINDINGS: [topic]
  Summary / Key Facts / Inferences / Risks / Open Questions
  ```
- **Test finding format** (Test Engineer):
  ```
  TEST FINDING: [scope]
  Category / Severity / Finding / Recommendation
  ```
- **Security finding format** (Security Auditor):
  ```
  SECURITY FINDING: [scope]
  Severity / OWASP Category / Description / Evidence / Impact / Remediation / Verification
  ```
- **Deployment finding format** (DevOps):
  ```
  DEPLOYMENT FINDING: [scope]
  Category / Severity / Finding / Remediation
  ```

These are message formats (sent via SendMessage), not file templates. They should remain in spawn prompts, not in template files.

---

## 9. Summary of Template Needs

| Artifact Type | Template Exists? | Consistency | Priority |
|---|---|---|---|
| Roadmap Items | Effective (ADR-001) | Excellent | Low (already working) |
| Feature Specs | NO | Poor (2 files, 0 shared structure) | HIGH |
| Progress Summaries | NO | Good (5 files, mostly consistent) | MEDIUM |
| Checkpoint Files | In SKILL.md (not as template file) | Fair (early files predate format) | LOW (already in SKILL.md) |
| ADRs | NO | N/A (1 file) | MEDIUM |
| Cost Summaries | In spec (not as template file) | N/A (0 files produced) | LOW (already specified) |

**Top 3 recommendations**:
1. Create `docs/specs/_template.md` -- this is the highest-value template (cross-team handoff reliability)
2. Create `docs/architecture/_template.md` -- formalize the ADR format
3. Create `docs/progress/_template.md` -- formalize the progress summary format

Checkpoint and cost summary formats are already embedded in SKILL.md files and don't need separate template files -- they'd just be redundant with the SKILL.md definitions. However, SKILL.md Setup sections should instruct agents to "read the relevant template before producing artifacts" for specs, ADRs, and progress summaries.
