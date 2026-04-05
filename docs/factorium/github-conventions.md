# Factorium GitHub Conventions

Reference document for all GitHub Issue conventions used by the Factorium pipeline. Skills read this file to understand
label taxonomy, issue structure, query patterns, and state transition protocols.

## Label Taxonomy

Labels are namespaced with `factorium:` or `status:` to avoid collision with non-Factorium labels.

### Stage Labels (mutually exclusive)

An issue has exactly one stage label at any time.

| Label                 | Description                                 | Color   |
| --------------------- | ------------------------------------------- | ------- |
| `factorium:dreamer`   | Newly created idea, awaiting research       | #7B68EE |
| `factorium:assayer`   | Awaiting or undergoing research/validation  | #DAA520 |
| `factorium:planner`   | Awaiting or undergoing product planning     | #3CB371 |
| `factorium:architect` | Awaiting or undergoing architectural design | #4682B4 |
| `factorium:engineer`  | Awaiting or undergoing implementation       | #CD853F |
| `factorium:review`    | Awaiting or undergoing review/audit         | #DC143C |
| `factorium:graveyard` | Rejected; archived for potential necromancy | #696969 |
| `factorium:complete`  | PR merged; pipeline finished                | #228B22 |

### Status Labels (mutually exclusive)

An issue has exactly one status label at any time.

| Label                 | Description                                   | Color   |
| --------------------- | --------------------------------------------- | ------- |
| `status:unclaimed`    | Available for pickup by the appropriate stage | #EDEDED |
| `status:claimed`      | Assigned to an agent, work in progress        | #0075CA |
| `status:blocked`      | Waiting on a dependency or external input     | #E4E669 |
| `status:needs-rework` | Returned from a later stage with rework notes | #FFA500 |
| `status:passed`       | Stage complete; ready for the next stage      | #0E8A16 |

### Priority Labels (optional)

| Label               | Color   |
| ------------------- | ------- |
| `priority:critical` | #B60205 |
| `priority:high`     | #D93F0B |
| `priority:normal`   | #FBCA04 |
| `priority:low`      | #C2E0C6 |

### Metadata Labels (additive)

| Label                  | Description                                    | Color   |
| ---------------------- | ---------------------------------------------- | ------- |
| `has:dependencies`     | This issue depends on other issues             | #BFD4F2 |
| `review-requested`     | A stage has requested Gremlin review           | #FF69B4 |
| `necromancy-candidate` | A graveyard item flagged for potential revival | #4B0082 |

## Bootstrap

Run `bash scripts/factorium/bootstrap-labels.sh` to create all labels in the repository. The script is idempotent --
re-running it updates existing labels without duplicating them.

## Issue Body Template

Every Factorium issue follows this structure. Stages append sections -- they never overwrite previous sections.

```markdown
## Idea

<!-- Written by the Dreamer. A paragraph or less. -->

## Research Summary

<!-- Written by the Assayer. Go/no-go decision with evidence. -->

## Product Specification

<!-- Written by the Planner. Requirements, stories, acceptance criteria. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/product-*.md -->

## Architecture Specification

<!-- Written by the Architect. System design, schemas, contracts. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/architecture-*.md -->

## Engineering Plan

<!-- Written by the Engineer. Implementation notes, test results, PR link. -->
<!-- Detailed docs: docs/factorium/{idea-slug}/engineering-*.md -->

## Review Log

<!-- Written by Gremlins. Audit findings, pass/fail, rework notes. -->

## Dependencies

<!-- Checkbox list of issue numbers. Checked before claiming. -->

- [ ] #N -- Description of dependency

## Stage History

<!-- Appended by each stage on claim and completion. -->

| Timestamp | Stage | Action | Agent | Notes |
| --------- | ----- | ------ | ----- | ----- |
```

## Query Patterns

Each polling loop queries for its next work item using this pattern:

```
label:{stage-label} label:status:unclaimed no:assignee sort:created-asc
```

Examples:

- Assayer: `label:factorium:assayer label:status:unclaimed no:assignee sort:created-asc`
- Planner: `label:factorium:planner label:status:unclaimed no:assignee sort:created-asc`
- Rework: `label:factorium:{stage} label:status:needs-rework no:assignee sort:created-asc`

The `sort:created-asc` ensures dependency ordering -- oldest items are processed first.

## State Transition Protocols

### Claiming Protocol

1. Query for the top unclaimed item matching the loop's stage label.
2. Check Dependencies section. If any dependency is unresolved (issue not `factorium:complete`), skip to the next item.
3. Assign the issue to the agent's identity.
4. Replace `status:unclaimed` with `status:claimed`.
5. Re-read the issue to confirm assignment. If another agent claimed it, unassign and retry.
6. Append Stage History entry: `| {timestamp} | {stage} | Claimed | {agent} | |`

### Completion Protocol

1. Write all work products to appropriate locations.
2. Append the stage's summary section to the issue body.
3. Append Stage History entry: `| {timestamp} | {stage} | Completed | {agent} | {notes} |`
4. Replace `status:claimed` with `status:passed`.
5. Replace the current stage label with the next stage's label.
6. Replace `status:passed` with `status:unclaimed`.
7. Unassign the issue.

### Requeue Protocol

1. Add a comment explaining the problem and what the earlier stage needs to address.
2. Append Stage History entry: `| {timestamp} | {stage} | Requeued | {agent} | Returned to {target}: {reason} |`
3. Commit any in-progress work to the idea's branch.
4. Replace the current stage label with the target stage's label.
5. Replace current status with `status:needs-rework`.
6. Unassign the issue.

### Review Request Protocol

1. Add `review-requested` label.
2. Add comment specifying: what to review, approval criteria, routing on pass/fail.
3. Replace current stage label with `factorium:review`.
4. Replace current status with `status:unclaimed`.
5. Unassign the issue.

## Git Branching

- Branch per idea: `factorium/{idea-slug}` from `main`
- Created by the Assayer's Guild on go/conditional-go decisions. No-go ideas never get a branch.
- All subsequent stages (Planner, Architect, Engineer, Gremlin) check out the feature branch, commit their work, push.
- Product docs, architecture docs, and code all live on the feature branch — not on `main`.
- Engineer rebases from `main` before opening the PR.
- PR opened by the Engineer's Forge against `main`.
- Human review and merge after Gremlin approval. Feature branch deleted after merge.

## Worktrees

Each terminal runs in its own git worktree (see FACTORIUM.md § Worktree Model). Stages check out the idea's feature
branch in their worktree when claiming an issue. Setup: `git worktree add .worktrees/{stage} main`
