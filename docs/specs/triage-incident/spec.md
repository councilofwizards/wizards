---
title: "Incident Triage Skill Specification"
status: "approved"
priority: "P3"
category: "new-skills"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# Incident Triage Skill Specification

## Summary

Create `triage-incident` as a new multi-agent engineering skill for structured
production incident response. A Severity Assessor classifies impact, a Root
Cause Analyst applies 5-Whys methodology, and a Triage Skeptic challenges all
findings before the incident report is published. The skill supports live
triage, post-mortem analysis, and status reporting modes.

## Problem

Production incidents currently lack structured response within the conclave
ecosystem. Teams handle incident response ad-hoc — severity classifications are
inconsistent, root cause analyses vary in rigor, and post-incident documentation
is often incomplete or delayed. There is no skill that provides a standardized
triage workflow with the same quality-gate rigor (mandatory Skeptic review) that
the plugin enforces for planning and implementation. The `review-quality` skill
handles operational readiness checks but does not address active incident
response or post-mortem analysis.

## Solution

### 1. SKILL.md Structure

**File**: `plugins/conclave/skills/triage-incident/SKILL.md`

**Frontmatter**:

```yaml
---
name: triage-incident
description: >
  Structured production incident triage: severity assessment, root cause
  analysis, response coordination, and post-incident documentation through a
  dedicated agent team with mandatory Skeptic review.
argument-hint:
  "[--light] [status | --post-mortem <incident-id> | <incident-description>]"
tier: 1
---
```

**Required sections** (all 12 multi-agent engineering sections):

1. `## Setup` — Read incident description from arguments, scan `docs/progress/`
   for existing incident reports, detect project stack, load stack hints, read
   persona file (`plugins/conclave/shared/personas/triage-lead.md`). Prioritize
   minimal context reading for time-sensitivity — do NOT read all roadmap and
   spec files.
2. `## Write Safety` — Each agent writes only to
   `docs/progress/{incident-id}-{role}.md`. Only the Triage Lead writes the
   aggregated incident report.
3. `## Checkpoint Protocol` — Standard format with `team: "triage-incident"`,
   `phase: "triage" | "rca" | "review" | "complete"`.
4. `## Determine Mode` — See Section 3 below.
5. `## Lightweight Mode` — Acknowledged, no changes. All agents needed for valid
   assessment.
6. `## Spawn the Team` — TeamCreate with `team_name: "triage-incident"`, then
   TaskCreate, then Agent spawns.
7. `## Orchestration Flow` — See Section 4 below.
8. `## Critical Rules` — See Section 5 below.
9. `## Failure Recovery` — Standard: unresponsive agent re-spawn, 3-rejection
   deadlock escalation, context exhaustion re-spawn from checkpoint.
10. `## Teammates to Spawn` — Full spawn prompts for each agent.
11. `## Shared Principles` — Both `universal-principles` and
    `engineering-principles` marker blocks.
12. `## Communication Protocol` — Standard protocol with `triage-skeptic`
    substituted in the Skeptic routing row.

### 2. Agent Team Composition

| Agent              | Name                | Model | Role                                                          | Spawned For               |
| ------------------ | ------------------- | ----- | ------------------------------------------------------------- | ------------------------- |
| Severity Assessor  | `severity-assessor` | opus  | Classify incident severity using 4-tier framework             | live triage, post-mortem  |
| Root Cause Analyst | `rca-analyst`       | opus  | Structured RCA using 5-Whys methodology                       | live triage, post-mortem  |
| Triage Skeptic     | `triage-skeptic`    | opus  | Challenge severity and RCA findings before report publication | all modes (except status) |

**Lead**: Triage Lead (the orchestrating agent, not spawned).

### 3. Invocation Modes (Determine Mode)

- **No arguments / incident description**: Full live triage. Spawn
  severity-assessor + rca-analyst + triage-skeptic. Produce incident report.
- **`--post-mortem <incident-id>`**: Read existing report at
  `docs/progress/{incident-id}-incident-report.md`. Run retrospective RCA.
  Update report with `status: "post-mortem"`. If no report found, return error:
  "No incident report found for `{incident-id}`. Run without flags to start a
  new triage."
- **`status`**: Read all `docs/progress/*-incident-report.md` files, parse
  frontmatter, output formatted status table (incident ID, severity, status,
  created). No agents spawned.
- **`--light`**: Acknowledged, no team composition changes.

### 4. Orchestration Flow

1. Triage Lead reads incident description and any available context (logs, error
   messages, recent deploys mentioned by user)
2. Triage Lead creates tasks and spawns Severity Assessor + RCA Analyst in
   parallel
3. **Severity Assessor** classifies using 4-tier framework:
   - `SEV-1`: Total outage / data loss — immediate escalation
   - `SEV-2`: Major degradation / large user impact — immediate escalation
   - `SEV-3`: Partial degradation / limited user impact — 1-hour response
   - `SEV-4`: Minor issue / cosmetic or low-frequency — next business day
   - Output: severity tier, one-sentence rationale, estimated user impact,
     recommended response timeline
   - SEV-1/SEV-2: broadcast to full team with "SEV-[N] DECLARED" header
4. **RCA Analyst** applies 5-Whys methodology:
   - Distinguishes: immediate cause → contributing factors → root cause
   - Each cause supported by evidence or marked `[UNVERIFIED]` / `[HYPOTHESIS]`
   - Checks whether recent deployments are contributing factors
   - Output includes `Confidence` field: High / Medium / Low
5. Both agents send findings to Triage Lead
6. **Triage Skeptic gate** (BLOCKS report publication):
   - Reviews: (a) severity justified by stated impact? (b) root cause supported
     by evidence? (c) contributing factors plausible? (d) remediations specific
     and actionable?
   - May escalate severity (not downgrade without evidence)
   - APPROVED → Triage Lead writes report with `## Skeptic Review` section
   - REJECTED → Affected agents revise and resubmit (3-rejection deadlock
     applies)
7. Triage Lead writes incident report to
   `docs/progress/{incident-id}-incident-report.md`
8. Triage Lead writes end-of-session summary

### 5. Critical Rules

- Triage Skeptic MUST approve all findings before the incident report is
  published
- Severity escalations during Skeptic review are binding; downgrades require
  evidence
- Every RCA finding must be supported by evidence or explicitly marked
  `[UNVERIFIED]` or `[HYPOTHESIS]`
- SEV-1 and SEV-2 declarations trigger immediate team-wide broadcast
- The incident report is not marked `resolved` until the Skeptic approves
- Incident IDs are sanitized to slugs (lowercase, hyphens only) before use in
  file paths

### 6. Incident Report Artifact

**File**: `docs/progress/{incident-id}-incident-report.md`

**Frontmatter**:

```yaml
---
type: "incident-report"
incident-id: ""
severity: "" # SEV-1 | SEV-2 | SEV-3 | SEV-4
status: "open" # open | mitigating | resolved | post-mortem
created: ""
updated: ""
---
```

**Sections**: `## Incident Summary`, `## Severity Assessment`, `## Timeline`
(chronological, categorized as
detection/escalation/diagnosis/mitigation/resolution), `## Root Cause Analysis`,
`## Contributing Factors`, `## Recommended Remediation` (each item: priority,
description, owner role, suggested timeline), `## Lessons Learned`,
`## Skeptic Review`.

The report lives in `docs/progress/` (operational artifact, not planning). Not
registered in the F-series validator.

### 7. Shared Content and Classification

- **Classification**: `engineering` in both `scripts/sync-shared-content.sh` and
  `scripts/validators/skill-shared-content.sh`
- **Skeptic name pair**: `triage-skeptic` / `Triage Skeptic` added to B2
  normalizer in `skill-shared-content.sh` and to the sync script's
  `extract_skeptic_names` function
- **Shared content**: Injected via sync script after SKILL.md creation. Both
  universal-principles and engineering-principles blocks.

## Constraints

1. All 12 required multi-agent engineering sections must be present
2. `triage-incident` classified as `engineering` in both sync and validation
   scripts
3. `triage-skeptic` / `Triage Skeptic` added to B2 normalizer (2 new sed
   entries)
4. Skeptic gate is non-negotiable — no report published without Skeptic approval
5. All 12/12 validators must pass after creation and sync
6. Severity classification uses exactly the 4-tier framework (SEV-1 through
   SEV-4)
7. Setup prioritizes minimal context reading — do not read all roadmap/spec
   files on every invocation

## Out of Scope

- Integration with external incident management tools (PagerDuty, OpsGenie,
  Slack)
- Automated log parsing or metric ingestion
- Automated alerting or escalation outside Claude Code
- SLA tracking or incident duration metrics
- Changes to existing skills

## Files to Modify

| File                                                    | Change                                                                                                                    |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `plugins/conclave/skills/triage-incident/SKILL.md`      | Create — full multi-agent engineering skill                                                                               |
| `scripts/sync-shared-content.sh`                        | Add `triage-incident` to engineering classification list; add `triage-skeptic` / `Triage Skeptic` to skeptic name mapping |
| `scripts/validators/skill-shared-content.sh`            | Add `triage-incident` to engineering classification list; add `triage-skeptic` / `Triage Skeptic` to B2 normalizer        |
| `plugins/conclave/shared/personas/triage-lead.md`       | Create — persona file for Triage Lead (follows existing persona format)                                                   |
| `plugins/conclave/shared/personas/severity-assessor.md` | Create — persona file for Severity Assessor                                                                               |
| `plugins/conclave/shared/personas/rca-analyst.md`       | Create — persona file for Root Cause Analyst                                                                              |
| `plugins/conclave/shared/personas/triage-skeptic.md`    | Create — persona file for Triage Skeptic                                                                                  |

## Success Criteria

1. `plugins/conclave/skills/triage-incident/SKILL.md` exists with all 12
   required multi-agent sections
2. YAML frontmatter contains `name: triage-incident`, `tier: 1`, and a
   description
3. Shared content blocks are populated correctly after running
   `bash scripts/sync-shared-content.sh`
4. Communication Protocol contains `triage-skeptic` (not `{skill-skeptic}`)
   after sync
5. `triage-incident` appears in engineering classification lists in both sync
   and validation scripts
6. `triage-skeptic` / `Triage Skeptic` appears in the B2 normalizer
7. Full triage mode spawns severity-assessor + rca-analyst + triage-skeptic
8. Post-mortem mode reads existing report and produces updated analysis
9. Status mode reads `*-incident-report.md` files and outputs a table without
   spawning agents
10. `bash scripts/validate.sh` reports 12/12 PASS
