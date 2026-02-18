---
feature: "p1-02-state-persistence"
role: "impl-architect"
status: "plan-pending-review"
created: "2026-02-14"
---

# P1-02: State Persistence & Checkpoints — Implementation Plan

## Summary

This plan adds structured checkpoints and a resume protocol to all 3 SKILL.md files, building on P1-01's role-scoped file naming. The existing `docs/progress/{feature}-{role}.md` files become structured checkpoint files with YAML frontmatter. Changes include:

1. New **Checkpoint Protocol** section in each SKILL.md (after Write Safety, before Determine Mode) — defines the checkpoint file format and general rules
2. Updated **Determine Mode** sections with a resume protocol — scan for incomplete checkpoints before starting fresh
3. Updated **Failure Recovery** context exhaustion — leverage existing checkpoints instead of manual summarization
4. **Checkpoint trigger lines** added to spawn prompt WRITE SAFETY blocks for all working agents
5. New **CHECKPOINTS** block for impl-architect (which lacks a WRITE SAFETY block)

**Total edits: 18** across 3 files. No new files created.

---

## Design Decisions

1. **Checkpoint files ARE the role-scoped progress files.** P1-01 established `docs/progress/{feature}-{role}.md` as each agent's file. P1-02 simply defines a structured format (YAML frontmatter + progress notes) for those same files. No new file paths needed.

2. **Minimal per-prompt additions.** Instead of duplicating the full checkpoint format in every spawn prompt, the Checkpoint Protocol section defines the format once per SKILL.md. Each spawn prompt gets only a single "Checkpoint after:" trigger line listing role-specific events.

3. **Skeptic roles excluded from checkpoint triggers.** Skeptics communicate via messages and their work is reactive (review when asked). If their context is lost, the team lead re-requests the review. Adding checkpoints to skeptics adds cost for marginal value.

4. **Context exhaustion now leverages checkpoints.** Previously, the lead had to manually summarize state. Now the checkpoint file already contains the state — the lead just reads it and passes it to the re-spawned agent.

5. **Resume is opportunistic, not mandatory.** The resume protocol checks for incomplete checkpoints. If none exist, the skill proceeds normally. This means checkpoints enhance resilience without changing the happy path.

6. **Team-scoped checkpoint scanning.** Each skill scans for checkpoints matching its own `team` field (`plan-product`, `build-product`, or `review-quality`). This prevents cross-skill checkpoint interference.

---

## File 1: plugins/conclave/skills/plan-product/SKILL.md (6 edits)

### Edit A: Add Checkpoint Protocol section after Write Safety

**old_string:**
```
- **Architecture files**: Each agent writes to files scoped to their concern (e.g., `docs/architecture/{feature}-data-model.md` for DBA, `docs/architecture/{feature}-system-design.md` for Architect).

## Determine Mode
```

**new_string:**
```
- **Architecture files**: Each agent writes to files scoped to their concern (e.g., `docs/architecture/{feature}-data-model.md` for DBA, `docs/architecture/{feature}-system-design.md` for Architect).

## Checkpoint Protocol

Agents MUST write a checkpoint to their role-scoped progress file (`docs/progress/{feature}-{role}.md`) after each significant state change. This enables session recovery if context is lost.

### Checkpoint File Format

```yaml
---
feature: "feature-name"
team: "plan-product"
agent: "role-name"
phase: "research"         # research | design | review | complete
status: "in_progress"     # in_progress | blocked | awaiting_review | complete
last_action: "Brief description of last completed action"
updated: "ISO-8601 timestamp"
---

## Progress Notes

- [HH:MM] Action taken
- [HH:MM] Next action taken
```

### When to Checkpoint

Agents write a checkpoint after:
- Claiming a task (phase: current phase, status: in_progress)
- Completing a deliverable (status: awaiting_review)
- Receiving review feedback (status: in_progress, note the feedback)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)

The Team Lead reads checkpoint files to understand team state during recovery.

## Determine Mode
```

### Edit B: Update Determine Mode with resume protocol

**old_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: General review cycle. Assess roadmap health, identify gaps, reprioritize.
- **"new [idea]"**: Research and spec a new feature.
```

**new_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "plan-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, proceed with a general review cycle. Assess roadmap health, identify gaps, reprioritize.
- **"new [idea]"**: Research and spec a new feature.
```

### Edit C: Update context exhaustion in Failure Recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should read the agent's checkpoint file at `docs/progress/{feature}-{role}.md`, then re-spawn the agent with the checkpoint content as context to resume from the last known state.
```

### Edit D: Add checkpoint trigger to Researcher WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-researcher.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### Software Architect
```

**new_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-researcher.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
- Checkpoint after: task claimed, research started, findings ready, findings submitted, review feedback received
```

### Software Architect
```

### Edit E: Add checkpoint trigger to Architect WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write architecture docs to files scoped to your concern (e.g., docs/architecture/{feature}-system-design.md)
- Write progress notes ONLY to docs/progress/{feature}-architect.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### DBA
```

**new_string:**
```
WRITE SAFETY:
- Write architecture docs to files scoped to your concern (e.g., docs/architecture/{feature}-system-design.md)
- Write progress notes ONLY to docs/progress/{feature}-architect.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
- Checkpoint after: task claimed, design started, ADR drafted, review requested, review feedback received, design finalized
```

### DBA
```

### Edit F: Add checkpoint trigger to DBA WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write data model docs to files scoped to your concern (e.g., docs/architecture/{feature}-data-model.md)
- Write progress notes ONLY to docs/progress/{feature}-dba.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
```

### Product Skeptic
```

**new_string:**
```
WRITE SAFETY:
- Write data model docs to files scoped to your concern (e.g., docs/architecture/{feature}-data-model.md)
- Write progress notes ONLY to docs/progress/{feature}-dba.md
- NEVER write to shared files — only the Team Lead writes to shared/index files
- Checkpoint after: task claimed, data model started, model drafted, review requested, review feedback received, model finalized
```

### Product Skeptic
```

---

## File 2: plugins/conclave/skills/build-product/SKILL.md (6 edits)

### Edit G: Add Checkpoint Protocol section after Write Safety

**old_string:**
```
- **Spec/contract files**: Only the Team Lead writes to `docs/specs/{feature}/` files. Exception: backend-eng and frontend-eng may co-author `docs/specs/{feature}/api-contract.md` during sequential contract negotiation (not concurrent writes).

## Determine Mode
```

**new_string:**
```
- **Spec/contract files**: Only the Team Lead writes to `docs/specs/{feature}/` files. Exception: backend-eng and frontend-eng may co-author `docs/specs/{feature}/api-contract.md` during sequential contract negotiation (not concurrent writes).

## Checkpoint Protocol

Agents MUST write a checkpoint to their role-scoped progress file (`docs/progress/{feature}-{role}.md`) after each significant state change. This enables session recovery if context is lost.

### Checkpoint File Format

```yaml
---
feature: "feature-name"
team: "build-product"
agent: "role-name"
phase: "implementation"   # planning | contract-negotiation | implementation | testing | review | complete
status: "in_progress"     # in_progress | blocked | awaiting_review | complete
last_action: "Brief description of last completed action"
updated: "ISO-8601 timestamp"
---

## Progress Notes

- [HH:MM] Action taken
- [HH:MM] Next action taken
```

### When to Checkpoint

Agents write a checkpoint after:
- Claiming a task (phase: current phase, status: in_progress)
- Completing a deliverable (status: awaiting_review)
- Receiving review feedback (status: in_progress, note the feedback)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)

The Team Lead reads checkpoint files to understand team state during recovery.

## Determine Mode
```

### Edit H: Update Determine Mode with resume protocol

**old_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: Check for in-progress work first. If none, pick next ready roadmap item.
- **"[spec-name]"**: Implement the named spec.
```

**new_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: Scan `docs/progress/` for checkpoint files with `team: "build-product"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context and pick up where they left off. If no incomplete checkpoints exist, pick next ready roadmap item.
- **"[spec-name]"**: Implement the named spec.
```

### Edit I: Update context exhaustion in Failure Recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should read the agent's checkpoint file at `docs/progress/{feature}-{role}.md`, then re-spawn the agent with the checkpoint content as context to resume from the last known state.
```

### Edit J: Add CHECKPOINTS to impl-architect spawn prompt

**old_string:**
```
- Answer technical questions from engineers promptly
- Route your plan to the Quality Skeptic for approval
```

### Backend Engineer
```

**new_string:**
```
- Answer technical questions from engineers promptly
- Route your plan to the Quality Skeptic for approval

CHECKPOINTS:
- Write checkpoints to docs/progress/{feature}-impl-architect.md after each significant state change
- Use the checkpoint file format defined in the Checkpoint Protocol section
- Checkpoint after: task claimed, plan drafted, review requested, review feedback received, plan finalized
```

### Backend Engineer
```

### Edit K: Add checkpoint trigger to Backend Engineer WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-backend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries

TEST STRATEGY:
```

**new_string:**
```
WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-backend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries
- Checkpoint after: task claimed, contract proposed, contract agreed, implementation started, endpoint ready, tests passing

TEST STRATEGY:
```

### Edit L: Add checkpoint trigger to Frontend Engineer WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-frontend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries

TEST STRATEGY:
```

**new_string:**
```
WRITE SAFETY:
- Write your progress notes ONLY to docs/progress/{feature}-frontend-eng.md
- NEVER write to files owned by other agents or shared index files
- Only the Team Lead writes to shared files like roadmap entries or aggregated summaries
- Checkpoint after: task claimed, contract reviewed, implementation started, component ready, tests passing

TEST STRATEGY:
```

---

## File 3: plugins/conclave/skills/review-quality/SKILL.md (6 edits)

### Edit M: Add Checkpoint Protocol section after Write Safety

**old_string:**
```
- **Shared files**: Only the QA Lead writes to shared/aggregated files. The QA Lead synthesizes agent outputs AFTER parallel work completes.

## Determine Mode
```

**new_string:**
```
- **Shared files**: Only the QA Lead writes to shared/aggregated files. The QA Lead synthesizes agent outputs AFTER parallel work completes.

## Checkpoint Protocol

Agents MUST write a checkpoint to their role-scoped progress file (`docs/progress/{feature}-{role}.md`) after each significant state change. This enables session recovery if context is lost.

### Checkpoint File Format

```yaml
---
feature: "feature-name"
team: "review-quality"
agent: "role-name"
phase: "testing"          # testing | auditing | review | complete
status: "in_progress"     # in_progress | blocked | awaiting_review | complete
last_action: "Brief description of last completed action"
updated: "ISO-8601 timestamp"
---

## Progress Notes

- [HH:MM] Action taken
- [HH:MM] Next action taken
```

### When to Checkpoint

Agents write a checkpoint after:
- Claiming a task (phase: current phase, status: in_progress)
- Completing a deliverable (status: awaiting_review)
- Receiving review feedback (status: in_progress, note the feedback)
- Being blocked (status: blocked, note what's needed)
- Completing their work (status: complete)

The QA Lead reads checkpoint files to understand team state during recovery.

## Determine Mode
```

### Edit N: Update Determine Mode with resume protocol

**old_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: Perform a general quality assessment of the most recently implemented feature. Spawn test-eng + ops-skeptic. Check `docs/progress/` for the latest completed implementation.
```

**new_string:**
```
Based on $ARGUMENTS:
- **Empty/no args**: First, scan `docs/progress/` for checkpoint files with `team: "review-quality"` and `status` of `in_progress`, `blocked`, or `awaiting_review`. If found, **resume from the last checkpoint** — re-spawn the relevant agents with their checkpoint content as context. If no incomplete checkpoints exist, perform a general quality assessment of the most recently implemented feature. Spawn test-eng + ops-skeptic. Check `docs/progress/` for the latest completed implementation.
```

### Edit O: Update context exhaustion in Failure Recovery

**old_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should summarize the current state to `docs/progress/{feature}-{role}.md` (using the agent's role name) and re-spawn the agent with the summary as context.
```

**new_string:**
```
- **Context exhaustion**: If any agent's responses become degraded (repetitive, losing context), the Team Lead should read the agent's checkpoint file at `docs/progress/{feature}-{role}.md`, then re-spawn the agent with the checkpoint content as context to resume from the last known state.
```

### Edit P: Add checkpoint trigger to Test Engineer WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-test-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### DevOps Engineer
```

**new_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-test-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
- Checkpoint after: task claimed, testing started, findings ready, findings submitted, review feedback received
```

### DevOps Engineer
```

### Edit Q: Add checkpoint trigger to DevOps Engineer WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-devops-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### Security Auditor
```

**new_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-devops-eng.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
- Checkpoint after: task claimed, review started, findings ready, findings submitted, review feedback received
```

### Security Auditor
```

### Edit R: Add checkpoint trigger to Security Auditor WRITE SAFETY

**old_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-security-auditor.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
```

### Ops Skeptic
```

**new_string:**
```
WRITE SAFETY:
- Write your findings ONLY to docs/progress/{feature}-security-auditor.md
- NEVER write to shared files — only the QA Lead writes to shared/aggregated files
- Checkpoint after: task claimed, audit started, findings ready, findings submitted, review feedback received
```

### Ops Skeptic
```

---

## Interaction with P1-01 and P1-03

- **P1-01 (Concurrent Write Safety)**: Already applied. This plan builds directly on P1-01's role-scoped naming and WRITE SAFETY blocks. Edits D-F, K-L, P-R extend existing WRITE SAFETY blocks with checkpoint trigger lines. Edit J adds a new CHECKPOINTS block to impl-architect (which P1-01 correctly excluded from WRITE SAFETY). All old_strings verified against current file state with P1-01 applied.

- **P1-03 (Stack Generalization)**: Not yet applied. P1-02 and P1-03 touch different sections — P1-02 modifies Checkpoint Protocol, Determine Mode, Failure Recovery, and WRITE SAFETY blocks, while P1-03 modifies Setup steps, Shared Principle #4, and framework-specific spawn prompt text. No conflicts. Can be implemented in either order — the engineer should re-read files before applying.

## Success Criteria Verification

Per the roadmap:
- **"A session interrupted mid-work can be resumed by re-invoking the same skill."** — The resume protocol in Determine Mode scans for incomplete checkpoints and re-spawns agents. ✅
- **"The resumed session picks up from the last checkpoint, not from scratch."** — Agents checkpoint after every significant state change. The lead passes checkpoint content as context when re-spawning. ✅
