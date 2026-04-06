# Stage Acceptance Criteria

Centralized gate criteria for Factorium stages 2-6. Adversaries reference this document as the authoritative source for
APPROVE/REJECT decisions. One gate, one truth.

---

## Stage 2 — Assayer (Research Validation)

**Adversary:** Vorric Blackassay (Assayer General)

### Entry Criteria

- **SA-01** Idea issue exists with `factorium:assayer` label.
- **SA-02** Assessor findings compiled into rubric table.
- **SA-03** Rationales stripped from submission. _(Iron Law 01)_

### Acceptance Criteria

| ID    | Condition                                          | Verdict        |
| ----- | -------------------------------------------------- | -------------- |
| SA-04 | Avg score >= 3.5, no dimension = 1                 | Go             |
| SA-05 | Avg score >= 3.0, no dimension = 1, conditions set | Conditional Go |
| SA-06 | Avg score < 3.0, or any dimension = 1              | No-Go          |

- **SA-07** Adversary independently scores all dimensions from evidence only.
- **SA-08** Conditional Go requires explicit conditions documented in issue comment.

### Rejection Triggers

- **SA-09** Any dimension score = 1.
- **SA-10** Avg score < 3.0.
- **SA-11** Adversary veto (overrides numeric thresholds).
- **SA-12** Rationales present in submission (automatic reject, re-strip required).

### Requeue Targets

| Trigger          | Target           |
| ---------------- | ---------------- |
| Low scores       | Stage 2 (rework) |
| Missing research | Stage 2 (rework) |
| Fundamental flaw | Graveyard        |

### Max Rejection Cycles

3 cycles. Escalate on 4th.

### Advancement Action

- Branch created from main.
- Issue labeled `factorium:planner`.
- Stage History entry written.

---

## Stage 3 — Planner (Product Specification)

**Adversary:** Seld Revenmark (Skeptic of Scope)

### Entry Criteria

- **SA-13** Issue has `factorium:planner` label.
- **SA-14** Assayer verdict = Go or Conditional Go.
- **SA-15** Branch exists.

### Acceptance Criteria

- **SA-16** 4 product docs complete: requirements, user stories, success metrics, edge cases.
- **SA-17** Internal consistency across all 4 docs.
- **SA-18** Every FR traces to >= 1 US; every US traces to >= 1 FR.
- **SA-19** No untestable requirements. Every requirement has a verification method.
- **SA-20** No scope creep beyond original idea boundaries.
- **SA-21** Open questions resolved or explicitly escalated with `status:blocked`.

### Rejection Triggers

- **SA-22** Missing or incomplete product doc.
- **SA-23** Broken traceability (orphan FR or US).
- **SA-24** Untestable requirement present.
- **SA-25** Scope expanded beyond assayed idea without operator approval.
- **SA-26** Unresolved ambiguity not escalated. _(Iron Law 02)_

### Requeue Targets

| Trigger                   | Target             |
| ------------------------- | ------------------ |
| Doc quality issues        | Stage 3 (rework)   |
| Scope creep               | Stage 3 (rework)   |
| Idea fundamentally flawed | Stage 2 (re-assay) |

### Max Rejection Cycles

3 cycles. Escalate on 4th.

### Advancement Action

- Issue labeled `factorium:architect`.
- Stage History entry written.

---

## Stage 4 — Architect (Technical Design)

**Adversary:** Drevna Ironbreak (Stress Tester)

### Entry Criteria

- **SA-27** Issue has `factorium:architect` label.
- **SA-28** 4 product docs approved by Planner adversary.

### Acceptance Criteria

- **SA-29** 5 architecture docs complete: system design, schema, API contracts, security model, work plan.
- **SA-30** Internal consistency across all 5 docs.
- **SA-31** Every FR has corresponding architectural artifact.
- **SA-32** Every API endpoint defines error responses (4xx, 5xx).
- **SA-33** Every migration has rollback path. _(Iron Law 08)_
- **SA-34** Every STRIDE threat has documented mitigation.
- **SA-35** Work units truly independent and parallelizable.

### Rejection Triggers

- **SA-36** Missing or incomplete architecture doc.
- **SA-37** FR without architectural coverage.
- **SA-38** API endpoint missing error responses.
- **SA-39** Migration without rollback path.
- **SA-40** Unmitigated STRIDE threat.
- **SA-41** Work units with hidden dependencies (not parallelizable).

### Requeue Targets

| Trigger                      | Target            |
| ---------------------------- | ----------------- |
| Design quality issues        | Stage 4 (rework)  |
| Requirement misunderstanding | Stage 3 (re-plan) |
| Scope gap in product docs    | Stage 3 (re-plan) |

### Max Rejection Cycles

3 cycles. Escalate on 4th.

### Advancement Action

- Issue labeled `factorium:engineer`.
- Stage History entry written.

---

## Stage 5 — Engineer (Implementation)

**Adversary:** Stonewall Gatewick (Gatekeeper)

### Entry Criteria

- **SA-42** Issue has `factorium:engineer` label.
- **SA-43** 5 architecture docs approved by Architect adversary.
- **SA-44** Work units defined and assigned.

### Acceptance Criteria

- **SA-45** All work units implemented per architecture spec.
- **SA-46** All automated gates pass: unit tests, feature tests, linter, type checker, static analysis.
- **SA-47** Critical-path test assertions validated by human. _(Iron Law 14)_
- **SA-48** Security audit findings addressed (zero critical/high open).
- **SA-49** PR opened against target branch.

### Rejection Triggers

- **SA-50** Work unit incomplete or diverges from architecture spec.
- **SA-51** Any automated gate failing.
- **SA-52** Unaddressed critical/high security finding.
- **SA-53** No PR opened.
- **SA-54** Implementation deviates from spec without documented rationale.

### Requeue Targets

| Trigger                      | Target              |
| ---------------------------- | ------------------- |
| Implementation defects       | Stage 5 (rework)    |
| Architecture spec inadequate | Stage 4 (re-design) |
| Requirement gap discovered   | Stage 3 (re-plan)   |

### Max Rejection Cycles

3 cycles. Escalate on 4th.

### Advancement Action

- Issue labeled `factorium:review`.
- Stage History entry written.

---

## Stage 6 — Gremlin (Final Review)

**Adversary:** Edda the Final Word

### Entry Criteria

- **SA-55** Issue has `factorium:review` label.
- **SA-56** All automated gates passing.
- **SA-57** PR open and ready for review.

### Acceptance Criteria

- **SA-58** Inspector: every requirement MET. No critical PARTIAL or UNMET.
- **SA-59** Chaos: all failure modes covered by tests or explicitly accepted.
- **SA-60** Standards: conventions met, docs complete, commits clean.
- **SA-61** Final Word: APPROVE or REJECT. No hedging, no conditional approvals.

### Rejection Triggers

- **SA-62** Any requirement UNMET.
- **SA-63** Critical requirement PARTIAL.
- **SA-64** Untested failure mode not explicitly accepted.
- **SA-65** Convention violation.
- **SA-66** Final Word issues REJECT (overrides sub-reviewer approvals).

### Requeue Targets

| Trigger                     | Target              |
| --------------------------- | ------------------- |
| Implementation defects      | Stage 5 (rework)    |
| Design flaw discovered      | Stage 4 (re-design) |
| Requirement gap discovered  | Stage 3 (re-plan)   |
| Standards/convention issues | Stage 5 (rework)    |

### Max Rejection Cycles

3 cycles. Escalate on 4th.

### Advancement Action

- Issue labeled `factorium:complete`, `status:passed`.
- PR review approval submitted.
- Stage History entry written.

---

## Requeue Matrix

All valid requeue paths across the pipeline.

| From Stage  | To Stage  | Trigger                                      |
| ----------- | --------- | -------------------------------------------- |
| 2 Assayer   | 2         | Low scores, missing research                 |
| 2 Assayer   | Graveyard | Fundamental flaw, 3x reject exhaustion       |
| 3 Planner   | 3         | Doc quality, scope creep, traceability gaps  |
| 3 Planner   | 2         | Idea fundamentally flawed on deeper analysis |
| 4 Architect | 4         | Design quality, missing coverage             |
| 4 Architect | 3         | Requirement misunderstanding, scope gap      |
| 5 Engineer  | 5         | Implementation defects, gate failures        |
| 5 Engineer  | 4         | Architecture spec inadequate                 |
| 5 Engineer  | 3         | Requirement gap discovered                   |
| 6 Gremlin   | 5         | Implementation defects, convention issues    |
| 6 Gremlin   | 4         | Design flaw discovered                       |
| 6 Gremlin   | 3         | Requirement gap discovered                   |

---

## Escalation Protocol

Triggers when any stage reaches max rejection cycles (3 REJECT-rework loops).

1. Agent adds comment to GitHub Issue: rejection history, blockers, attempted fixes.
2. Issue labeled `status:blocked`.
3. Pipeline halts for that idea. Other ideas unaffected.
4. Human operator resolves and removes `status:blocked` to resume.
5. Rejection counter resets after human intervention.
