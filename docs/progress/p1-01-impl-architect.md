---
feature: "p1-01-concurrent-write-safety"
role: "impl-architect"
status: "plan-pending-review"
created: "2026-02-14"
---

# P1-01: Concurrent Write Safety — Implementation Plan

## Summary

This plan adds file-per-concern partitioning to all 3 SKILL.md files so parallel agents never write to the same file. Changes include:

1. New **Write Safety** section in each SKILL.md (between Setup and Determine Mode)
2. Updated **Orchestration Flow** steps to enforce lead-only aggregation
3. Updated **Failure Recovery** context exhaustion to use role-scoped filenames
4. New **WRITE SAFETY** blocks in spawn prompts for all agents that run in parallel

**Total edits: 17** across 3 files. No new files created. No behavioral changes to agent logic — only file-write targeting is affected.

---

## File 1: plugins/conclave/skills/plan-product/SKILL.md (6 edits)

### Edit A: Add Write Safety section after Setup

**old_string:**
```
4. Read `docs/specs/` for existing specs

## Determine Mode
```

**new_string:**
```
4. Read `docs/specs/` for existing specs

## Write Safety

Agents working in parallel MUST NOT write to the same file. Follow these conventions:

- **Progress files**: Each agent writes ONLY to `docs/progress/{feature}-{role}.md` (e.g., `docs/progress/auth-researcher.md`). Agents NEVER write to a shared progress file.
- **Shared files**: Only the Team Lead writes to shared/index files (e.g., `docs/roadmap/` entries, `docs/specs/{feature}/spec.md`). The Team Lead aggregates agent outputs AFTER parallel work completes.
- **Architecture files**: Each agent writes to files scoped to their concern (e.g., `docs/architecture/{feature}-data-model.md` for DBA, `docs/architecture/{feature}-system-design.md` for Architect).

## Determine Mode
```

### Edit B: Update Orchestration Flow steps 5-6 for lead-only aggregation

**old_string:**
```
5. Write final spec to `docs/specs/[feature-name]/spec.md`
6. Update `docs/roadmap/` with new/changed items
```

**new_string:**
```
5. **Team Lead only**: Aggregate agent outputs and write final spec to `docs/specs/[feature-name]/spec.md`
6. **Team Lead only**: Update `docs/roadmap/` with new/changed items
```

### Edit C: Update context exhaustion recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/` and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

### Edit D: Add WRITE SAFETY to Researcher spawn prompt

**old_string:**
```
- If the Architect or DBA asks for information, help them promptly
```

### Software Architect
```

**new_string:**
```
- If the Architect or DBA asks for information, help them promptly

WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-researcher.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### Software Architect
```

### Edit E: Add WRITE SAFETY to Architect spawn prompt

**old_string:**
```
- Message the Researcher if you need more information about existing code or constraints
- Respond to questions from other agents promptly
```

### DBA
```

**new_string:**
```
- Message the Researcher if you need more information about existing code or constraints
- Respond to questions from other agents promptly

WRITE SAFETY:
- Write architecture docs to files scoped to your concern (e.g., docs/architecture/{feature}-system-design.md)
- Write progress notes ONLY to docs/progress/{feature}-architect.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### DBA
```

### Edit F: Add WRITE SAFETY to DBA spawn prompt

**old_string:**
```
- If you identify data integrity risks, message the Product Owner immediately
- Respond to the Architect's questions promptly
```

### Product Skeptic
```

**new_string:**
```
- If you identify data integrity risks, message the Product Owner immediately
- Respond to the Architect's questions promptly

WRITE SAFETY:
- Write data model docs to files scoped to your concern (e.g., docs/architecture/{feature}-data-model.md)
- Write progress notes ONLY to docs/progress/{feature}-dba.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### Product Skeptic
```

---

## File 2: plugins/conclave/skills/build-product/SKILL.md (5 edits)

### Edit G: Add Write Safety section after Roadmap Status Convention

**old_string:**
```
- ⛔ Blocked

## Determine Mode
```

**new_string:**
```
- ⛔ Blocked

## Write Safety

Agents working in parallel MUST NOT write to the same file. Follow these conventions:

- **Progress files**: Each agent writes ONLY to `docs/progress/{feature}-{role}.md` (e.g., `docs/progress/auth-backend-eng.md`). Agents NEVER write to a shared progress file.
- **Shared files**: Only the Team Lead writes to shared/index files (e.g., `docs/roadmap/` status updates, aggregated summaries). The Team Lead aggregates agent outputs AFTER parallel work completes.
- **Spec/contract files**: Only the Team Lead writes to `docs/specs/{feature}/` files. Exception: backend-eng and frontend-eng may co-author `docs/specs/{feature}/api-contract.md` during sequential contract negotiation (not concurrent writes).

## Determine Mode
```

### Edit H: Update Orchestration Flow steps 6-7

**old_string:**
```
6. Write progress notes to `docs/progress/`
7. Update roadmap status
```

**new_string:**
```
6. Each agent writes their progress notes to `docs/progress/{feature}-{role}.md` (their own role-scoped file)
7. **Team Lead only**: Update roadmap status and write aggregated summary to `docs/progress/{feature}-summary.md`
```

### Edit I: Update context exhaustion recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/` and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

### Edit J: Add WRITE SAFETY to Backend Engineer spawn prompt

**old_string:**
```
- If you have a question about requirements, ask the tech-lead — don't guess

TEST STRATEGY:
```

**new_string:**
```
- If you have a question about requirements, ask the tech-lead — don't guess

WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-backend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries

TEST STRATEGY:
```

### Edit K: Add WRITE SAFETY to Frontend Engineer spawn prompt

**old_string:**
```
- If you have a question about UX requirements, ask the tech-lead — don't guess

TEST STRATEGY:
```

**new_string:**
```
- If you have a question about UX requirements, ask the tech-lead — don't guess

WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-frontend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries

TEST STRATEGY:
```

---

## File 3: plugins/conclave/skills/review-quality/SKILL.md (6 edits)

### Edit L: Add Write Safety section after Setup

**old_string:**
```
5. Read `docs/architecture/` for relevant ADRs and system design

## Determine Mode
```

**new_string:**
```
5. Read `docs/architecture/` for relevant ADRs and system design

## Write Safety

Agents working in parallel MUST NOT write to the same file. Follow these conventions:

- **Progress files**: Each agent writes ONLY to `docs/progress/{feature}-{role}.md` (e.g., `docs/progress/auth-security-auditor.md`). Agents NEVER write to a shared progress file.
- **Shared files**: Only the QA Lead writes to shared/aggregated files. The QA Lead synthesizes agent outputs AFTER parallel work completes.

## Determine Mode
```

### Edit M: Update Orchestration Flow steps 6-7

**old_string:**
```
6. QA Lead synthesizes all approved findings into a quality report
7. Quality report is written to `docs/progress/[feature]-quality.md`
```

**new_string:**
```
6. Each agent writes their findings to `docs/progress/{feature}-{role}.md` (their own role-scoped file)
7. **QA Lead only**: Synthesize all approved findings into `docs/progress/{feature}-quality.md`
```

### Edit N: Update context exhaustion recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/` and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

### Edit O: Add WRITE SAFETY to Test Engineer spawn prompt

**old_string:**
```
- If you need clarification on expected behavior, message qa-lead — don't guess
- Respond to questions from other agents promptly
```

### DevOps Engineer
```

**new_string:**
```
- If you need clarification on expected behavior, message qa-lead — don't guess
- Respond to questions from other agents promptly

WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-test-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### DevOps Engineer
```

### Edit P: Add WRITE SAFETY to DevOps Engineer spawn prompt

**old_string:**
```
- Coordinate with the Security Auditor on infrastructure security concerns
- If you need access or information about production environments, message qa-lead — don't assume
```

### Security Auditor
```

**new_string:**
```
- Coordinate with the Security Auditor on infrastructure security concerns
- If you need access or information about production environments, message qa-lead — don't assume

WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-devops-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### Security Auditor
```

### Edit Q: Add WRITE SAFETY to Security Auditor spawn prompt

**old_string:**
```
- If you need clarification on authentication or authorization logic, message qa-lead
- Be thorough and precise. False positives waste time; missed vulnerabilities cost trust.
```

### Ops Skeptic
```

**new_string:**
```
- If you need clarification on authentication or authorization logic, message qa-lead
- Be thorough and precise. False positives waste time; missed vulnerabilities cost trust.

WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-security-auditor.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### Ops Skeptic
```

---

## Design Decisions

1. **No external locking**: File partitioning eliminates the problem entirely — no mutexes, no lock files, no retry loops.
2. **Convention over enforcement**: Agents are instructed (not forced) to follow the convention. This is appropriate because agents follow their prompt instructions reliably.
3. **Skeptic prompts excluded**: The Skeptic roles (Product Skeptic, Quality Skeptic, Ops Skeptic) communicate entirely via messages and don't write to progress files, so they don't need WRITE SAFETY blocks.
4. **Contract negotiation exception**: In build-product, the API contract file (`api-contract.md`) is co-authored by backend-eng and frontend-eng, but during sequential negotiation (propose/accept/revise), not concurrent writes. This is documented as an explicit exception.
5. **Lead-only aggregation**: Only team leads write to shared files (`_index.md`, `spec.md`, `roadmap/` entries, aggregated summaries). This happens AFTER parallel work completes, eliminating race conditions.

## Interaction with P1-03

This plan and P1-03 (Stack Generalization) both modify the 3 SKILL.md files but touch different sections. P1-01 edits the Write Safety area, Orchestration Flow, Failure Recovery, and spawn prompt WRITE SAFETY blocks. P1-03 edits Setup steps, Shared Principle #4, and framework-specific text in spawn prompts. They can be implemented in either order — the implementing engineer should re-read files before applying edits.
