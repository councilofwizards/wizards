---
type: "user-stories"
feature: "triage-incident"
status: "approved"
source_roadmap_item: "docs/roadmap/P3-04-triage-incident.md"
approved_by: "Wren Cinderglass, Siege Inspector"
created: "2026-03-27"
updated: "2026-03-27"
---

# User Stories: Incident Triage Skill (P3-04)

## Epic Summary

Create `triage-incident` as a new multi-agent conclave skill for structured production incident response. The skill
provides severity assessment, root cause analysis, response coordination, and post-incident documentation through a
dedicated agent team. A Triage Skeptic reviews all findings before the incident report is finalized, preventing rushed
or under-evidenced conclusions from becoming the record.

## Stories

---

### Story 1: SKILL.md Scaffolding and Frontmatter

- **As a** skill author creating the incident triage skill
- **I want** a valid `plugins/conclave/skills/triage-incident/SKILL.md` with correct frontmatter, required sections, and
  shared content markers
- **So that** the skill is discoverable by the plugin cache, passes all validators, and follows the established skill
  structure for multi-agent engineering skills
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the skill directory, when created, then `plugins/conclave/skills/triage-incident/SKILL.md` exists with YAML
     frontmatter containing: `name: triage-incident`, a `description` field summarizing incident triage, an
     `argument-hint` documenting supported invocation patterns, and `tier: 1`
  2. Given the SKILL.md, when inspected for required multi-agent sections, then it contains all 12 required multi-agent
     sections: `## Setup`, `## Write Safety`, `## Checkpoint Protocol`, `## Determine Mode`, `## Lightweight Mode`,
     `## Spawn the Team`, `## Orchestration Flow`, `## Critical Rules`, `## Failure Recovery`, `## Teammates to Spawn`,
     `## Shared Principles` (containing both universal-principles and engineering-principles marker blocks), and
     `## Communication Protocol`
  3. Given the shared content markers, when `bash scripts/sync-shared-content.sh` is run, then the Shared Principles and
     Communication Protocol blocks are populated from `plugins/conclave/shared/` with the skill's Skeptic name
     substituted correctly in the Communication Protocol
  4. Given `bash scripts/validate.sh`, when run after the SKILL.md is created and synced, then all 12/12 validators pass
  5. Given the skill-classification in `scripts/sync-shared-content.sh` and
     `scripts/validators/skill-shared-content.sh`, when `triage-incident` is added, then it is classified as
     `engineering` so both Engineering Principles and Universal Principles blocks are injected

- **Edge Cases**:
  - SKILL.md created without running sync script: B-series validators will flag shared content drift; sync must be run
    before committing
  - Skill name `triage-incident` not yet in the validator's known-skill list: validators default to `engineering`
    classification with a WARN log — confirm no drift after classification is added explicitly

- **Notes**: The shared content markers must be placed in the correct order: universal-principles block first,
  engineering-principles block second, communication-protocol block last. Review
  `plugins/conclave/skills/review-quality/SKILL.md` as the canonical reference for an engineering multi-agent skill
  structure.

---

### Story 2: Severity Assessment Agent

- **As a** team running a production incident
- **I want** a dedicated Severity Assessor agent that classifies incident severity using a structured framework
- **So that** response priority and escalation decisions are based on consistent criteria rather than individual
  judgment under pressure
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given a skill invocation with an incident description, when the Severity Assessor is spawned, then it classifies
     the incident using a four-tier severity framework: `SEV-1` (total outage / data loss), `SEV-2` (major degradation /
     large user impact), `SEV-3` (partial degradation / limited user impact), `SEV-4` (minor issue / cosmetic or
     low-frequency)
  2. Given the Severity Assessor's output, when inspected, then it includes: the severity tier with a one-sentence
     rationale, estimated user impact (number or percentage of users affected if determinable), and a recommended
     response timeline (e.g., immediate escalation, 1-hour response, next business day)
  3. Given severity `SEV-1` or `SEV-2`, when the Severity Assessor sends its classification to the Triage Lead, then it
     also sends a broadcast to the full team: "SEV-[N] DECLARED: [incident summary]. Immediate escalation required."
  4. Given the Severity Assessor's spawn prompt, when inspected, then it includes the instruction to checkpoint its
     findings to `docs/progress/{incident-id}-severity-assessor.md` after classification is complete
  5. Given the Triage Skeptic gate (Story 5), when the Severity Assessor's classification is reviewed, then the Skeptic
     may escalate the severity tier (but not downgrade it without evidence) — severity escalations during review are
     binding; downgrades require evidence from the Severity Assessor

- **Edge Cases**:
  - Incident description is ambiguous (no clear scope): Severity Assessor requests clarification from the Triage Lead
    before classifying; does not guess
  - Incident affects internal tooling only (no end users): classified SEV-4 unless the tooling is on the critical path
    for a live user-facing service, in which case escalate to SEV-3
  - Severity changes during active triage (incident worsens): Severity Assessor may revise its classification;
    broadcasts the revision with a `SEVERITY ESCALATION` prefix
  - User provides a severity in the invocation arguments: Severity Assessor notes the user-provided severity, assesses
    independently, and flags any discrepancy with a `SEVERITY MISMATCH` notice

- **Notes**: The four-tier framework mirrors common industry standards (Google, PagerDuty SRE severity models). The
  Severity Assessor uses `opus` model to ensure careful reasoning under high-stakes conditions. Agent name:
  `severity-assessor`.

---

### Story 3: Root Cause Analysis Agent

- **As a** team investigating a production incident
- **I want** a Root Cause Analyst agent that applies structured RCA methodology to identify contributing factors
- **So that** the team understands the failure mode and can address causes rather than just symptoms
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the incident description and any available evidence (logs, error messages, recent deploy activity), when the
     Root Cause Analyst is spawned, then it produces a structured RCA using the 5-Whys method, documenting each "Why"
     step and its supporting evidence
  2. Given the RCA output, when inspected, then it distinguishes between: `immediate cause` (the direct trigger),
     `contributing factors` (conditions that allowed the trigger to have impact), and `root cause` (the underlying
     systemic issue)
  3. Given the RCA output, when inspected, then each cause and factor is supported by at least one piece of evidence
     (log excerpt, code reference, deploy timestamp, metric anomaly) — unsupported assertions are flagged with
     `[UNVERIFIED]`
  4. Given an incident involving a recent deployment, when the Root Cause Analyst assesses the timeline, then it
     explicitly checks whether the deployment is a contributing factor and documents its conclusion either way
  5. Given the Root Cause Analyst's findings, when sent to the Triage Lead, then the message includes a `Confidence`
     field rated `High`, `Medium`, or `Low` based on evidence availability — `Low` confidence prompts the Triage Lead to
     note that further investigation is needed
  6. Given the Root Cause Analyst's spawn prompt, when inspected, then it includes the instruction to checkpoint
     findings to `docs/progress/{incident-id}-rca.md`

- **Edge Cases**:
  - No logs or evidence are available (incident description only): Root Cause Analyst produces a hypothesis-based RCA,
    clearly labelling all items as `[HYPOTHESIS]` and recommending evidence collection steps
  - Multiple plausible root causes identified: all candidates are documented with their supporting evidence; the most
    likely candidate is ranked first with justification
  - Root cause is in an external dependency (third-party service): document as `external-dependency` cause type;
    recommend incident escalation to the dependency owner
  - User invokes triage on a past incident (post-mortem mode): Root Cause Analyst adapts its analysis to retrospective
    evidence, noting it as a post-mortem analysis in the report

- **Notes**: The Root Cause Analyst uses `opus` model for deep reasoning. The 5-Whys method is the minimum methodology;
  the analyst may use fishbone diagrams or fault tree analysis patterns in its written output when the incident warrants
  it. Agent name: `rca-analyst`.

---

### Story 4: Incident Report Artifact

- **As a** team lead finalizing a production incident
- **I want** a standard incident report artifact written to `docs/progress/{incident-id}-incident-report.md`
- **So that** there is a permanent, structured record of the incident that can inform post-mortems, process
  improvements, and future triage
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Triage Lead, when all Skeptic-approved findings are assembled, then the Triage Lead writes
     `docs/progress/{incident-id}-incident-report.md` containing: incident summary, severity tier, timeline of events,
     root cause analysis (from Story 3), contributing factors, immediate actions taken, recommended remediation steps,
     and lessons learned
  2. Given the incident report, when inspected, then it contains YAML frontmatter with fields:
     `type: "incident-report"`, `incident-id`, `severity` (SEV-1 through SEV-4), `status` (`open` | `mitigating` |
     `resolved` | `post-mortem`), `created`, `updated`
  3. Given the incident report's `## Recommended Remediation` section, when inspected, then each recommendation
     includes: a priority (`critical` | `high` | `medium` | `low`), a description, an owner role (who should implement
     it), and a suggested timeline
  4. Given the incident report's `## Timeline` section, when inspected, then events are listed in chronological order
     with timestamps (or relative times if absolute timestamps are unavailable), and each event is categorized as
     `detection`, `escalation`, `diagnosis`, `mitigation`, or `resolution`
  5. Given the incident report, when the Triage Skeptic approves it, then the report's `status` field is set to
     `resolved` or `post-mortem` (as appropriate) and the `updated` timestamp is set to the approval time
  6. Given `bash scripts/validate.sh`, when run after the skill is created, then all 12/12 validators pass — the
     incident report is a progress file, not an artifact template, and is not checked by the F-series validator

- **Edge Cases**:
  - Incident is still ongoing when triage-incident is invoked: report `status` is set to `mitigating`; the report
    documents current state and pending actions; Triage Lead notifies the user that the report is a living document
  - Multiple incident IDs in the same session (batch triage): each incident gets its own report file; the Triage Lead
    does not combine them
  - Incident ID contains spaces or special characters: Triage Lead sanitizes the ID to a slug (lowercase, hyphens only)
    before using it in the file path
  - Report written before the Skeptic review completes: report `status` is `open` until Skeptic approval; Triage Lead
    does not mark it `resolved` prematurely

- **Notes**: The incident report lives in `docs/progress/` (not `docs/specs/`) because it is an operational artifact
  rather than a planning artifact. The `type: "incident-report"` frontmatter field follows the artifact convention but
  the file is not registered in the F-series artifact template validator — it is a run output, not a schema template.

---

### Story 5: Triage Skeptic Gate

- **As a** Triage Lead finalizing an incident investigation
- **I want** a Triage Skeptic to review all severity classifications and RCA findings before the incident report is
  published
- **So that** rushed or under-evidenced conclusions do not become the permanent record, and the team's collective
  reasoning is challenged before it hardens
- **Priority**: must-have

- **Acceptance Criteria**:
  1. Given the Triage Lead's assembled findings (severity classification + RCA output), when they are submitted to the
     Triage Skeptic, then the Skeptic reviews them before the Triage Lead writes the incident report
  2. Given the Triage Skeptic's review, when inspected, then it evaluates: (a) is the severity tier justified by the
     stated user impact? (b) is the root cause supported by evidence or marked as hypothesis? (c) are the contributing
     factors plausible? (d) are the recommended remediations specific and actionable?
  3. Given a severity classification the Triage Skeptic considers too low, when the Skeptic rejects the findings, then
     the rejection message specifies the tier the Skeptic recommends and the evidence supporting escalation
  4. Given a `REJECTED` verdict from the Triage Skeptic, when the Triage Lead receives it, then the affected agents
     (Severity Assessor or RCA Analyst) revise their findings and resubmit — the deadlock protocol (3-rejection limit)
     applies as defined in `## Failure Recovery`
  5. Given an `APPROVED` verdict, when the Triage Lead proceeds, then the incident report is written with a
     `## Skeptic Review` section noting the Skeptic's conditions or observations (if any)
  6. Given the Triage Skeptic's spawn prompt, when inspected, then it includes the standard Skeptic behavioral contract:
     explicit approve/reject verdicts, specific actionable feedback on rejection, and no approval without evidence

- **Edge Cases**:
  - Triage Skeptic approves the severity but rejects the RCA: Triage Lead asks only the RCA Analyst to revise; the
    Severity Assessor's output is not re-evaluated unless the revised RCA changes the severity assessment
  - No evidence is available (hypothesis-only RCA): Triage Skeptic may approve with conditions — "Approve contingent on
    evidence collection within 24 hours" — this is documented in the report
  - User overrides the Skeptic rejection (human operator escalation): Triage Lead documents the override in the incident
    report's `## Skeptic Review` section with the user's stated reason
  - Triage Skeptic is the same agent as an existing skill's Skeptic role: Triage Skeptic is a new dedicated role spawned
    only for triage-incident; it does not share identity with ops-skeptic, plan-skeptic, etc.

- **Notes**: Agent name: `triage-skeptic`. Model: `opus` — Skeptic roles always use Opus for reasoning depth. The
  Skeptic's scope is findings review only; it does not perform its own independent investigation.

---

### Story 6: Invocation Modes

- **As a** developer invoking triage-incident
- **I want** the skill to support distinct invocation modes for active incidents, post-mortem analysis, and status
  reporting
- **So that** the same skill handles both urgent in-the-moment triage and reflective post-incident review without
  requiring separate workflows
- **Priority**: should-have

- **Acceptance Criteria**:
  1. Given invocation with no arguments or with an incident description, when the skill runs, then it performs a full
     live triage: spawns Severity Assessor + RCA Analyst + Triage Skeptic and produces an incident report
  2. Given invocation with `--post-mortem` flag and an incident ID, when the skill runs, then it reads the existing
     incident report at `docs/progress/{incident-id}-incident-report.md` as context, runs a retrospective RCA focused on
     root cause and prevention, and produces an updated report with `status: "post-mortem"`
  3. Given invocation with `status`, when the skill runs, then it reads all `docs/progress/*-incident-report.md` files,
     parses their frontmatter, and outputs a formatted status table (incident ID, severity, status, created date)
     without spawning any agents
  4. Given invocation with `--light`, when the skill runs, then the flag is acknowledged and no team composition changes
     are made (incident triage has no lightweight mode — all agents are needed for a complete assessment)
  5. Given `bash scripts/validate.sh`, when run after the Determine Mode section is written, then A2 validator confirms
     the required sections are present

- **Edge Cases**:
  - `--post-mortem` invoked but no incident report file exists at the given ID: skill returns an error message to the
    user — "No incident report found for `{incident-id}`. Run without flags to start a new triage."
  - `status` invoked with no incident reports in `docs/progress/`: skill returns "No incident reports found." without
    error
  - Unknown argument provided: skill treats it as an incident description (best-effort interpretation) and proceeds with
    full triage mode

- **Notes**: The `status` mode mirrors the pattern established in `review-quality/SKILL.md` (Determine Mode: "status"
  reads checkpoint files and generates a status report without spawning agents).

---

## Non-Functional Requirements

- **Time-sensitivity**: Incident triage is often urgent. The skill's Setup section should prioritize reading the minimum
  necessary context (incident description, recent progress files) before spawning agents — do not read all roadmap and
  spec files on every invocation
- **Validator stability**: 12/12 validators must pass after the new SKILL.md is created and synced
- **Shared content compliance**: `triage-incident` must be added to the engineering classification list in both
  `sync-shared-content.sh` and `skill-shared-content.sh`
- **Graceful degradation**: If no logs or code context are available, the skill must still produce a useful output
  (hypothesis-based RCA with explicit uncertainty markers) rather than refusing to proceed

## Out of Scope

- Integration with external incident management tools (PagerDuty, OpsGenie, Slack) — skill operates on text input only
- Automated log parsing or metric ingestion — agents read evidence provided by the user or found in the project's
  `docs/progress/` files
- Automated alerting or escalation outside Claude Code — response coordination is within the agent team only
- SLA tracking or incident duration metrics — status reporting is based on report frontmatter, not real-time timers
- Changes to existing skills (review-quality, build-implementation, etc.) — triage-incident is a standalone new skill
