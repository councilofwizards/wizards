---
feature: "artifact-format-templates"
team: "build-product"
agent: "impl-architect"
phase: "planning"
status: "awaiting_review"
last_action: "Implementation plan drafted, sent to quality-skeptic for review"
updated: "2026-02-14T00:00:00Z"
---

# P2-06 Artifact Format Templates -- Implementation Plan

## Overview

This is a pure documentation feature. Create 3 template files and add 1 new Setup step to each of the 3 SKILL.md files. No code, no APIs, no tests.

**Source spec**: `docs/specs/artifact-format-templates/spec.md`

---

## Part 1: Files to Create

### 1A. `docs/specs/_template.md`

Create this file with the exact content from spec Section 1:

```markdown
---
title: ""
status: "draft"                  # draft | ready_for_review | approved | ready_for_implementation
priority: ""                     # P1 | P2 | P3
category: ""                     # core-framework | new-skills | developer-experience | quality-reliability | documentation
approved_by: ""                  # agent or role that approved
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
---

# {Title} Specification

## Summary

<!-- 1-3 sentences. A reader who stops here should understand WHAT this does and WHY. -->

## Problem

<!-- What's broken, missing, or suboptimal? Include evidence — references to code, user reports, or agent behavior. -->

## Solution

<!-- The proposed change. Structure with subsections as needed. For SKILL.md changes, show before/after diffs. For new systems, describe components and their interactions. -->

## Constraints

<!-- Non-negotiable rules, boundaries, or invariants. Numbered list. -->

## Out of Scope

<!-- What this spec explicitly does NOT cover. Prevents scope creep during implementation. -->

## Files to Modify

<!-- Table or list of files changed, with brief description of each change. -->

| File | Change |
|------|--------|

## Success Criteria

<!-- Numbered, testable statements. Each criterion should be verifiable by a human or automated test. -->
```

### 1B. `docs/progress/_template.md`

Create this file with the exact content from spec Section 2:

```markdown
---
feature: ""
status: "complete"               # in_progress | complete
completed: ""                    # YYYY-MM-DD (when status is complete)
---

# {Priority}: {Title} -- Progress

## Summary

<!-- 1-3 sentences describing what was done and why. -->

## Changes

<!-- Subsections for each logical group of changes, if the work is complex enough to warrant them. For simple features, a single paragraph is sufficient. -->

## Files Modified

<!-- List of files changed, with brief description of each change. -->

- `path/to/file.md` -- Description of change

## Files Created

<!-- Only include this section if new files were created. Omit entirely if not applicable. -->

- `path/to/new-file.md` -- Description

## Verification

<!-- How was quality confirmed? Reference Skeptic approvals, test results, success criteria checks. -->
```

### 1C. `docs/architecture/_template.md`

Create this file with the exact content from spec Section 3:

```markdown
---
title: ""
status: "proposed"               # proposed | accepted | deprecated | superseded
created: ""                      # YYYY-MM-DD
updated: ""                      # YYYY-MM-DD
superseded_by: ""                # ADR number, if applicable
---

# ADR-{NNN}: {Title}

## Status

{Proposed | Accepted | Deprecated | Superseded by ADR-NNN}

## Context

<!-- What forces are at play? What problem does this address? What constraints exist? -->

## Decision

<!-- What was decided and why. Include enough detail for someone unfamiliar with the discussion to understand the rationale. Use subsections if the decision has multiple parts. -->

## Alternatives Considered

<!-- What else was evaluated? Why was each rejected? Brief — 2-3 sentences per alternative. -->

### {Alternative 1 name}

{Description and reason for rejection.}

## Consequences

<!-- What are the results of this decision? List positives and negatives explicitly. -->

- **Positive**: ...
- **Negative**: ...
```

---

## Part 2: Files to Modify

Each SKILL.md gets one new step inserted as Step 2 in its Setup section, after the existing Step 1 (directory creation) and before the existing Step 2 (detect stack). All subsequent steps are renumbered.

### 2A. `plugins/agent-teams/skills/plan-product/SKILL.md`

**Location**: Setup section, lines 17-26.

**BEFORE** (lines 22-26):
```
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to understand current state
4. Read `docs/progress/` for latest implementation status
5. Read `docs/specs/` for existing specs
```

**AFTER** (insert new Step 2 after line 21, renumber old Steps 2-5 to 3-6):
```
2. Read `docs/specs/_template.md`, `docs/progress/_template.md`, and `docs/architecture/_template.md` if they exist. Use these as reference formats when producing artifacts.
3. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
4. Read `docs/roadmap/` to understand current state
5. Read `docs/progress/` for latest implementation status
6. Read `docs/specs/` for existing specs
```

**Exact edit**: Replace the text starting at "2. **Detect project stack.**" through "5. Read `docs/specs/` for existing specs" with the new 5-line block above.

---

### 2B. `plugins/agent-teams/skills/build-product/SKILL.md`

**Location**: Setup section, lines 17-27.

**BEFORE** (lines 23-27):
```
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to find the next "ready for implementation" item
4. Read the target spec from `docs/specs/[feature-name]/`
5. Read `docs/progress/` for any in-progress work to resume
6. Read `docs/architecture/` for relevant ADRs
```

**AFTER** (insert new Step 2, renumber old Steps 2-6 to 3-7):
```
2. Read `docs/specs/_template.md` and `docs/progress/_template.md` if they exist. Use these as reference formats when producing artifacts.
3. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
4. Read `docs/roadmap/` to find the next "ready for implementation" item
5. Read the target spec from `docs/specs/[feature-name]/`
6. Read `docs/progress/` for any in-progress work to resume
7. Read `docs/architecture/` for relevant ADRs
```

**Exact edit**: Replace the text starting at "2. **Detect project stack.**" through "6. Read `docs/architecture/` for relevant ADRs" with the new 6-line block above.

---

### 2C. `plugins/agent-teams/skills/review-quality/SKILL.md`

**Location**: Setup section, lines 16-26.

**BEFORE** (lines 22-26):
```
2. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
3. Read `docs/roadmap/` to understand what features are in play
4. Read `docs/specs/` for the target feature's spec and API contracts
5. Read `docs/progress/` for implementation status and known issues
6. Read `docs/architecture/` for relevant ADRs and system design
```

**AFTER** (insert new Step 2, renumber old Steps 2-6 to 3-7):
```
2. Read `docs/progress/_template.md` if it exists. Use it as a reference format when writing findings.
3. **Detect project stack.** Read the project root for dependency manifests (`package.json`, `composer.json`, `Gemfile`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.) to identify the tech stack. If a matching stack hint file exists at `docs/stack-hints/{stack}.md`, read it and prepend its guidance to all spawn prompts.
4. Read `docs/roadmap/` to understand what features are in play
5. Read `docs/specs/` for the target feature's spec and API contracts
6. Read `docs/progress/` for implementation status and known issues
7. Read `docs/architecture/` for relevant ADRs and system design
```

**Exact edit**: Replace the text starting at "2. **Detect project stack.**" through "6. Read `docs/architecture/` for relevant ADRs and system design" with the new 6-line block above.

---

## Execution Checklist

1. [ ] Create `docs/specs/_template.md` (content from Part 1A)
2. [ ] Create `docs/progress/_template.md` (content from Part 1B)
3. [ ] Create `docs/architecture/_template.md` (content from Part 1C)
4. [ ] Edit `plugins/agent-teams/skills/plan-product/SKILL.md` (Part 2A)
5. [ ] Edit `plugins/agent-teams/skills/build-product/SKILL.md` (Part 2B)
6. [ ] Edit `plugins/agent-teams/skills/review-quality/SKILL.md` (Part 2C)

**Total**: 3 files created, 3 files modified. No code. No tests.

---

## Verification

After implementation, verify:
1. All 3 template files exist at their specified paths
2. Each SKILL.md Setup section has the new Step 2 with "if they exist" guard
3. Each SKILL.md has correct step renumbering (no duplicate or skipped numbers)
4. Template content matches spec Sections 1-3 exactly (no additions, no omissions)
5. No other sections of the SKILL.md files were changed
