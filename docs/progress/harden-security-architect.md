---
feature: "harden-security"
team: "conclave-forge"
agent: "architect"
phase: "design"
status: "complete"
last_action: "Produced team blueprint for harden-security skill"
updated: "2026-03-28T02:50:00Z"
---

# TEAM BLUEPRINT: Security Audit & Remediation

## Mission

**Harden security** — Conduct comprehensive security analysis and produce
actionable remediation for application codebases.

**Verb**: Harden | **Noun**: Security

**Singularity test**: Could "audit security" and "remediate security" be
independent skills? Auditing without remediation is useful (the user explicitly
wants an audit-only mode), but remediation without an audit is meaningless — you
can't fix what you haven't found. These are sequential phases of one mission,
not two independent missions. One skill, three phases.

## Classification

**Engineering** — The Remediation Engineer writes and modifies application code,
security configurations, and infrastructure files. The Vulnerability Hunter
reads and analyzes code for exploitable patterns. Even in audit-only mode, the
analysis is deeply technical. Engineering classification ensures all agents
receive both Universal and Engineering Principles.

## Phase Decomposition

| Phase | Name           | Agent                | Deliverable          | Input                           | Output                                                                                        |
| ----- | -------------- | -------------------- | -------------------- | ------------------------------- | --------------------------------------------------------------------------------------------- |
| 1     | Reconnaissance | Threat Modeler       | Threat Model         | Codebase + stack hints          | `threat-model.md` — attack surface map, trust boundaries, STRIDE analysis, data flow diagrams |
| 2     | Assessment     | Vulnerability Hunter | Vulnerability Report | Threat Model + codebase         | `vulnerability-report.md` — severity-ranked findings, evidence, reproduction steps            |
| 3     | Remediation    | Remediation Engineer | Remediation Record   | Vulnerability Report + codebase | `remediation-record.md` — fixes applied, before/after, residual risk notes                    |

**Phase 3 is conditional** — the Lead skips Phase 3 when the user requests
audit-only mode. The final artifact in audit-only mode is the Vulnerability
Report from Phase 2.

**Skeptic gates every phase transition.** The Compliance Warden reviews each
deliverable before the next phase begins.

## Deliverable Chain

```
[codebase + stack-hints] → Phase 1 (Reconnaissance) → [threat-model.md]
    → Skeptic Gate 1 →
[threat-model.md + codebase] → Phase 2 (Assessment) → [vulnerability-report.md]
    → Skeptic Gate 2 →
[vulnerability-report.md + codebase] → Phase 3 (Remediation) → [remediation-record.md]
    → Skeptic Gate 3 → [final output]
```

**Chain validation**: OUTPUT(1) = threat-model.md feeds INPUT(2). OUTPUT(2) =
vulnerability-report.md feeds INPUT(3). No gaps.

## Agent Roster

| Agent                           | Concern (one sentence)                                                                                                                          | Model  | Rationale                                                                                                                                                     |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Threat Modeler**              | Owns attack surface mapping — identifies _where_ the codebase is exposed via STRIDE analysis of data flows, trust boundaries, and entry points. | Sonnet | Structured methodology (STRIDE) with well-defined output format; does not require deep reasoning over ambiguous code patterns.                                |
| **Vulnerability Hunter**        | Owns vulnerability detection — identifies _what_ specific exploitable weaknesses exist in the code, dependencies, and configuration.            | Opus   | Requires deep code analysis, pattern recognition across files, and judgment about exploitability. The most reasoning-intensive role.                          |
| **Remediation Engineer**        | Owns fix implementation — transforms findings into secure code changes following framework best practices and stack hints.                      | Opus   | Writes production code that must be correct, secure, and non-breaking. Needs strong reasoning to avoid introducing new vulnerabilities while fixing old ones. |
| **Compliance Warden** (Skeptic) | Owns validation — challenges false positives, verifies fix completeness, and ensures findings represent real risk, not security theater.        | Opus   | Skeptic must match or exceed the reasoning capability of the agents it reviews. Gates every phase.                                                            |

**Agent count justification**: 4 agents (3 specialists + 1 skeptic). Each owns
exactly one concern. The Threat Modeler could theoretically merge with the
Vulnerability Hunter, but their methodologies are fundamentally different —
STRIDE is a top-down architectural analysis while vulnerability hunting is
bottom-up code-level scanning. Keeping them separate produces better coverage:
the Threat Modeler's output _guides_ the Vulnerability Hunter's search, creating
a directed assessment rather than a blind scan.

## Mandate Boundary Tests

| Agent A              | Agent B              | Boundary Statement                                                                                                                              |
| -------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Threat Modeler       | Vulnerability Hunter | Threat Modeler maps _where_ attacks could occur (architecture-level); Vulnerability Hunter finds _what_ specific exploits exist (code-level).   |
| Threat Modeler       | Remediation Engineer | Threat Modeler identifies exposure points; Remediation Engineer writes code to close them.                                                      |
| Threat Modeler       | Compliance Warden    | Threat Modeler produces the threat model; Compliance Warden challenges whether the model is complete and accurate.                              |
| Vulnerability Hunter | Remediation Engineer | Vulnerability Hunter reports findings with evidence; Remediation Engineer implements fixes for those findings.                                  |
| Vulnerability Hunter | Compliance Warden    | Vulnerability Hunter asserts vulnerabilities exist; Compliance Warden challenges whether they are real, exploitable, and correctly prioritized. |
| Remediation Engineer | Compliance Warden    | Remediation Engineer produces fixes; Compliance Warden verifies fixes are complete, non-breaking, and not security theater.                     |

All six pairwise boundaries stated in one sentence each. No overlaps detected.

## Skeptic Gate Details

| Gate   | Phase Reviewed | What the Compliance Warden Checks                                                                                                                                       |
| ------ | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gate 1 | Reconnaissance | Is the threat model complete? Are trust boundaries correctly identified? Are any attack surfaces missing? Is STRIDE applied rigorously or superficially?                |
| Gate 2 | Assessment     | Are findings real or false positives? Is severity ranking justified? Are reproduction steps concrete? Did the Hunter cover the surfaces identified in the threat model? |
| Gate 3 | Remediation    | Do fixes actually close the vulnerability? Could fixes introduce new issues? Are fixes complete (not superficial patches)? Do fixes follow framework best practices?    |

## Key Behaviors

- **Stack-hint loading**: Lead reads `docs/stack-hints/{stack}.md` during setup
  and prepends guidance to all agent spawn prompts. Framework-specific checks
  (Laravel mass assignment, FastAPI auth injection, etc.) are informed by stack
  hints, not hardcoded.
- **Severity taxonomy**: Critical / High / Medium / Low / Info — used
  consistently in the vulnerability report.
- **Audit-only mode**: User can invoke with `--audit-only` or equivalent flag.
  Lead skips Phase 3 entirely. Final deliverable is the vulnerability report.
- **OWASP Top 10 coverage**: Vulnerability Hunter's methodology includes
  systematic OWASP Top 10 checks as a minimum baseline, augmented by
  threat-model-directed analysis.
- **Dependency audit**: Vulnerability Hunter checks dependency manifests for
  known CVEs.
- **Secrets detection**: Vulnerability Hunter scans for hardcoded credentials,
  API keys, and secrets.

## Primary Artifact: Security Audit Report

The Lead synthesizes all phase outputs into a final `security-audit-report.md`
artifact. This is the primary deliverable — a structured report combining:

- Threat model summary (from Phase 1)
- Vulnerability findings ranked by severity (from Phase 2)
- Remediation actions taken and residual risk (from Phase 3, if applicable)

An artifact template should be created at
`docs/templates/artifacts/security-audit-report.md`.

## Design Rationale

- **Why 3 phases**: Maps to the natural security workflow — understand the
  system (recon), find weaknesses (assess), fix them (remediate). Fewer phases
  would conflate analysis with remediation. More phases would add unnecessary
  gates without improving quality.
- **Why 4 agents**: The minimum set where each agent owns exactly one
  non-overlapping concern. Merging Threat Modeler and Vulnerability Hunter would
  lose the top-down/bottom-up coverage benefit. Adding a "Dependency Auditor"
  was considered but rejected — dependency auditing is one technique within the
  Vulnerability Hunter's concern, not a separate concern.
- **Why conditional Phase 3**: Security audits are valuable even without
  remediation (e.g., for reporting, compliance, or manual fix planning). Forcing
  remediation would limit the skill's utility.
- **Alternative rejected — separate audit and remediation skills**: Considered
  splitting into `audit-security` and `remediate-security`. Rejected because
  remediation without an audit is meaningless, and the threat model +
  vulnerability report from the audit directly feeds remediation. Splitting
  would force artifact hand-off between skills with no benefit.
- **Alternative rejected — 5-agent team with separate Dependency Auditor**:
  Dependencies are one attack vector among many; giving them their own agent
  would be disproportionate and would blur the boundary with the Vulnerability
  Hunter.

## Fantasy Theme Direction

**Fortress/Warden theme** — The team guards the codebase like a citadel. Agents
are ward-casters, sentinels, and menders who inspect the keep's defenses.

Suggested fantasy names (for Lorekeeper to refine):

- Team: **The Wardbound** or **Sentinels of the Sealed Keep**
- Threat Modeler: **Wardkeeper** — maps the arcane wards and identifies where
  the fortress walls are thin
- Vulnerability Hunter: **Sentinel** — patrols the ramparts, finding breaches
  and weak points
- Remediation Engineer: **Mender** — seals breaches and reinforces the wards
- Compliance Warden: **Warden** — the final authority who tests every ward and
  challenges every claim of security
- Lead: **Castellan** — commander of the keep's defense

## Argument Hint

```
"[--audit-only] [--light] [status | full <scope> | audit <scope> | remediate <scope>]"
```

## Category & Tags

- **Category**: `engineering`
- **Tags**:
  `[security, audit, remediation, vulnerability-assessment, threat-modeling]`
