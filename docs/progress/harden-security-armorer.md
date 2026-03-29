---
feature: "harden-security"
team: "conclave-forge"
agent: "armorer"
phase: "design"
status: "complete"
last_action: "Produced methodology manifest for all 4 agents"
updated: "2026-03-28T02:52:00Z"
---

# METHODOLOGY MANIFEST: Security Audit & Remediation

## METHODOLOGY MANIFEST: Threat Modeler

Methodologies:

1. **STRIDE Threat Modeling** — Systematic classification of threats into
   Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service,
   and Elevation of Privilege across each component and data flow.
   - Output: STRIDE Threat Matrix — a table with columns [Component | Data Flow
     | Threat Category | Threat Description | Trust Boundary Crossed | Risk
     Rating]
   - Skeptic challenge surface: Whether all components are enumerated, whether
     threat categories are correctly assigned, whether any trust boundaries are
     missing from the model.

2. **Data Flow Diagramming (DFD)** — Decompose the application into processes,
   data stores, external entities, and data flows to map how information moves
   across trust boundaries (Microsoft Threat Modeling methodology).
   - Output: Data Flow Inventory — a structured table with columns [Source |
     Destination | Data Type | Protocol | Trust Boundary | Authentication
     Required | Encryption]
   - Skeptic challenge surface: Whether all entry points are captured, whether
     trust boundary placement is accurate, whether data sensitivity
     classifications are correct.

3. **Attack Surface Analysis** (OWASP Attack Surface Analysis Cheat Sheet) —
   Enumerate all entry points, exit points, and assets of value accessible to
   attackers, scored by exposure level.
   - Output: Attack Surface Registry — a table with columns [Entry Point | Type
     (API/UI/File/CLI) | Authentication | Authorization | Input Validation |
     Exposure Level (External/Internal/Admin)]
   - Skeptic challenge surface: Whether the registry is exhaustive, whether
     exposure levels are correctly assessed, whether any unauthenticated paths
     are missed.

## METHODOLOGY MANIFEST: Vulnerability Hunter

Methodologies:

1. **OWASP Testing Guide (OTG) Systematic Testing** — Structured code review and
   testing against the OWASP Testing Guide v4 categories: authentication,
   authorization, session management, input validation, error handling,
   cryptography, business logic, and client-side.
   - Output: OWASP Coverage Checklist — a table with columns [OTG Category |
     Test ID | Test Name | Status (Vulnerable/Secure/N-A) | Evidence (file:line
     or config) | Severity]
   - Skeptic challenge surface: Whether each "Secure" finding has actual
     evidence, whether "N/A" dismissals are justified, whether the testing was
     superficial or thorough for each category.

2. **CVSS v3.1 Scoring** — Score each discovered vulnerability using the Common
   Vulnerability Scoring System base metrics (Attack Vector, Attack Complexity,
   Privileges Required, User Interaction, Scope,
   Confidentiality/Integrity/Availability Impact).
   - Output: CVSS Scoring Matrix — a table with columns [Finding ID |
     Vulnerability | AV | AC | PR | UI | S | C | I | A | Base Score | Severity
     Rating | Vector String]
   - Skeptic challenge surface: Whether individual metric values are justified
     (e.g., is Attack Complexity really Low?), whether scope changes are
     correctly assessed, whether severity inflation or deflation is occurring.

3. **Software Composition Analysis (SCA)** — Audit dependency manifests
   (package.json, composer.json, requirements.txt, Cargo.toml, etc.) against
   known CVE databases and check for outdated, unmaintained, or typosquatted
   packages.
   - Output: Dependency Vulnerability Log — a table with columns [Package |
     Current Version | CVE ID | CVSS Score | Fixed Version | Exploitability |
     Transitive (Y/N)]
   - Skeptic challenge surface: Whether CVEs are actually exploitable in context
     (not just theoretical), whether transitive dependencies are traced, whether
     "no known CVEs" truly means secure or just unaudited.

4. **Secrets Detection Scan** — Pattern-based and entropy-based scanning for
   hardcoded credentials, API keys, tokens, private keys, and connection strings
   across source code, configuration, and history.
   - Output: Secrets Exposure Log — a table with columns [File:Line | Secret
     Type | Pattern Match | Entropy Score | Committed to History (Y/N) |
     Exposure Risk]
   - Skeptic challenge surface: Whether false positives are filtered (test
     fixtures, example values), whether git history was checked (not just
     current files), whether .env files and CI configs were included in scope.

## METHODOLOGY MANIFEST: Remediation Engineer

Methodologies:

1. **OWASP Secure Coding Practices Checklist** — Apply fixes following the OWASP
   Secure Coding Practices Quick Reference Guide, ensuring each remediation maps
   to a specific practice (input validation, output encoding, authentication
   controls, access control, etc.).
   - Output: Remediation Record — a table with columns [Finding ID |
     Vulnerability | OWASP Practice Applied | Files Changed | Before
     (code/config) | After (code/config) | Regression Risk]
   - Skeptic challenge surface: Whether the OWASP practice cited actually
     addresses the vulnerability, whether the fix introduces new attack surface,
     whether the "after" code is genuinely secure or just differently broken.

2. **Defense in Depth Layering** — For each fix, verify that multiple
   independent security controls are in place rather than relying on a single
   point of defense (input validation + parameterized queries + output encoding,
   not just one).
   - Output: Defense Depth Matrix — a table with columns [Vulnerability | Layer
     1 Control | Layer 2 Control | Layer 3 Control | Single-Point-of-Failure
     Risk (Y/N) | Notes]
   - Skeptic challenge surface: Whether listed layers are truly independent
     controls or the same control described differently, whether any fix relies
     on a single defense, whether framework-provided controls are correctly
     leveraged.

3. **Regression Impact Analysis** — Before applying each fix, trace the blast
   radius through call graphs and dependency chains to identify what existing
   functionality could break.
   - Output: Regression Impact Checklist — a table with columns [Fix ID | Files
     Modified | Callers Affected | Test Coverage (Covered/Gap) | Breaking Change
     Risk (Low/Med/High) | Mitigation]
   - Skeptic challenge surface: Whether all callers were traced, whether test
     coverage gaps are real, whether "Low" risk assessments are justified,
     whether the fix was tested or only theoretically analyzed.

## METHODOLOGY MANIFEST: Compliance Warden (Skeptic)

Methodologies:

1. **Structured Argumentation (Toulmin Model)** — Evaluate each agent's claims
   using the Toulmin argumentation framework: does the claim have concrete data
   (evidence), a warrant (reasoning connecting evidence to claim), and are there
   rebuttals addressed?
   - Output: Claim Validation Log — a table with columns [Agent | Claim | Data
     Provided | Warrant | Rebuttal Considered | Verdict
     (Accept/Challenge/Reject) | Challenge Detail]
   - Skeptic challenge surface: N/A (this IS the skeptic's own methodology — the
     Lead validates that the Warden is applying it consistently and not
     rubber-stamping).

2. **False Positive Triage (DREAD Analysis)** — For each reported vulnerability,
   independently assess Damage potential, Reproducibility, Exploitability,
   Affected users, and Discoverability to verify the reporter's severity
   assessment and filter security theater.
   - Output: DREAD Triage Matrix — a table with columns [Finding ID | Damage |
     Reproducibility | Exploitability | Affected Users | Discoverability | DREAD
     Score | Reporter's Severity | Warden's Severity | Agree (Y/N)]
   - Skeptic challenge surface: N/A (the Warden's DREAD scores are the challenge
     — disagreements between DREAD and CVSS scores surface findings that need
     deeper discussion).

3. **Fix Completeness Verification** — For each remediation, verify the fix
   addresses the root cause (not just the symptom), covers all instances of the
   pattern, and does not introduce new vulnerabilities (OWASP Code Review Guide
   methodology).
   - Output: Fix Verification Checklist — a table with columns [Fix ID | Root
     Cause Addressed (Y/N) | All Instances Fixed (count found/count fixed) | New
     Vulnerability Introduced (Y/N) | Framework Best Practice Followed (Y/N) |
     Verdict (Pass/Fail/Conditional)]
   - Skeptic challenge surface: N/A (this is the skeptic's verification — the
     Lead checks for rubber-stamping by reviewing the ratio of Pass to Fail
     verdicts and whether challenges have substance).

---

## Cross-Agent Output Uniqueness Verification

| Agent                | Methodology             | Output Artifact              | Unique?                               |
| -------------------- | ----------------------- | ---------------------------- | ------------------------------------- |
| Threat Modeler       | STRIDE                  | STRIDE Threat Matrix         | Yes — threat classification table     |
| Threat Modeler       | DFD                     | Data Flow Inventory          | Yes — data movement mapping           |
| Threat Modeler       | Attack Surface Analysis | Attack Surface Registry      | Yes — entry point enumeration         |
| Vulnerability Hunter | OTG Testing             | OWASP Coverage Checklist     | Yes — test-by-test status tracking    |
| Vulnerability Hunter | CVSS Scoring            | CVSS Scoring Matrix          | Yes — per-finding severity scoring    |
| Vulnerability Hunter | SCA                     | Dependency Vulnerability Log | Yes — package-level CVE tracking      |
| Vulnerability Hunter | Secrets Detection       | Secrets Exposure Log         | Yes — credential/key finding log      |
| Remediation Engineer | Secure Coding Practices | Remediation Record           | Yes — before/after code changes       |
| Remediation Engineer | Defense in Depth        | Defense Depth Matrix         | Yes — layered control verification    |
| Remediation Engineer | Regression Impact       | Regression Impact Checklist  | Yes — blast radius tracing            |
| Compliance Warden    | Toulmin Model           | Claim Validation Log         | Yes — argumentation quality review    |
| Compliance Warden    | DREAD Analysis          | DREAD Triage Matrix          | Yes — independent severity validation |
| Compliance Warden    | Fix Completeness        | Fix Verification Checklist   | Yes — fix thoroughness audit          |

No two agents produce the same output type. All 13 outputs are structurally
distinct.
