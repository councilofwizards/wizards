---
name: build-product
description: >
  Invoke the Implementation Team to build a feature from an existing spec.
  Picks up the next ready item from the roadmap if no spec is specified.
  Resumes in-progress work if any exists.
argument-hint: "[--light] [status | <spec-name> | review | (empty for next item)]"
tier: 2
chains: [plan-implementation, build-implementation, review-quality]
---

# Implementation Pipeline

You are the Implementation Coordinator. You orchestrate a pipeline of Tier 1 skills
to take a technical specification through implementation planning, code writing, and quality review.

You do NOT spawn agent teams directly. Instead, you invoke Tier 1 skills via the Skill tool.
Each Tier 1 skill manages its own team, skeptic gates, and progress checkpoints.

## Setup

1. **Ensure project directory structure exists.** Create any missing directories:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
   - `docs/stack-hints/`
2. Read `docs/roadmap/` to find the next "ready for implementation" item.
3. Read the target spec from `docs/specs/{feature}/`.
4. Read `docs/progress/` for any in-progress work to resume.
5. Read `docs/architecture/` for relevant ADRs.

### Roadmap Status Convention

Use these status markers when reading or updating the roadmap:

- 🔴 Not started
- 🟡 In progress (spec)
- 🟢 Ready for implementation
- 🔵 In progress (implementation)
- ✅ Complete
- ⛔ Blocked

## Determine Mode

Based on $ARGUMENTS:
- **"status"**: Invoke each Tier 1 skill with "status" argument to collect consolidated status across the implementation pipeline. Do NOT run the pipeline. Report the aggregated results.
- **Empty/no args**: Run artifact detection, then execute the pipeline from the earliest missing stage. If no specs are ready for implementation, report: `"No features ready for implementation. Run /plan-product to create a spec first."`
- **"[spec-name]"**: Build the named spec through the full pipeline.
- **"review"**: Invoke review-quality only for the current implementation.

## Artifact Detection

Before running the pipeline, check which artifacts already exist for the target feature.
Use **frontmatter-based detection** — never rely on file existence alone.

For each artifact type, check:
1. Does the file exist at the expected path?
2. Does the frontmatter `type` field match the expected artifact type?
3. Does the frontmatter `feature` field match the target?
4. Is the `status` field in a usable state? (e.g., "approved" for implementation plans)

### Prerequisites

Before the pipeline can run, these artifacts MUST exist:
- **technical-spec**: `docs/specs/{feature}/spec.md` with `type: "technical-spec"` — **REQUIRED**
- **user-stories**: `docs/specs/{feature}/stories.md` — optional but recommended

If the technical-spec is missing, inform the user:
`"No technical-spec found for '{feature}'. Run /plan-product new {feature} or /write-spec {feature} first."`

### Detection Paths

| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| plan-implementation | implementation-plan | `docs/specs/{feature}/implementation-plan.md` | FOUND / INCOMPLETE / NOT_FOUND |
| build-implementation | code changes | Progress checkpoints with `team: "build-implementation"` | COMPLETE / IN_PROGRESS / NOT_FOUND |
| review-quality | quality report | Progress checkpoints with `team: "review-quality"` | COMPLETE / NOT_FOUND |

### Skip Logic

- **FOUND / COMPLETE**: Skip the stage.
- **INCOMPLETE / IN_PROGRESS**: Resume the stage (Tier 1 skills handle resume via checkpoints).
- **NOT_FOUND**: Must run the stage.

Report artifact detection results to the user before proceeding:

```
Artifact Detection for "{feature}":
  Prerequisites:
    technical-spec:      [FOUND / NOT_FOUND]
    user-stories:        [FOUND / NOT_FOUND] (optional)
  Pipeline:
    implementation-plan: [result]
    build-implementation: [result]
    review-quality:      [result]

Pipeline will run: [stages to execute]
Skipping:          [stages with FOUND/COMPLETE artifacts]
```

## Pipeline

Execute stages sequentially. Each stage must complete before the next begins.

### Stage 1: Implementation Planning

```
Skill(skill: "conclave:plan-implementation", args: "{feature}")
```

**Produces**: implementation-plan at `docs/specs/{feature}/implementation-plan.md`
**Requires**: technical-spec at `docs/specs/{feature}/spec.md`
**Skip if**: implementation-plan FOUND with status "approved"

### Stage 2: Build Implementation

```
Skill(skill: "conclave:build-implementation", args: "{feature}")
```

**Produces**: Code changes (tested, reviewed by quality-skeptic)
**Requires**: implementation-plan (from Stage 1), technical-spec
**Skip if**: Build progress checkpoints show status "complete"

### Stage 3: Quality Review

```
Skill(skill: "conclave:review-quality", args: "{feature}")
```

**Produces**: Quality report in progress files
**Requires**: Completed implementation (from Stage 2)
**Always runs**: Quality review should always run, even if a prior review exists, to catch regressions.

### Between Stages

After each stage completes:
1. Verify the expected outputs (read artifacts, check progress checkpoints)
2. If outputs are missing or invalid, report the failure and stop the pipeline
3. Report progress to the user: `"Stage {N} ({skill-name}) complete."`
4. Update roadmap status if applicable:
   - After Stage 1: 🔵 In progress (implementation)
   - After Stage 3: ✅ Complete (if quality review passes)

## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and prepend `--light` to ALL Tier 1 skill invocations:

```
Skill(skill: "conclave:plan-implementation", args: "--light {feature}")
Skill(skill: "conclave:build-implementation", args: "--light {feature}")
```

Note: review-quality does not receive `--light` — quality review should always run at full strength.

Output to user: `"Lightweight mode enabled: planning and build stages will use reduced agent teams. Quality review runs at full strength."`

## Failure Handling

### Stage Failure

If a Tier 1 skill fails:
1. Report the failure with the stage name and error details
2. Do NOT proceed to the next stage
3. Suggest re-running the failed stage individually: `"Run /plan-implementation {feature} to retry Stage 1"`

### Partial Pipeline

All completed stages' outputs are preserved. Re-running the pipeline detects existing artifacts via frontmatter and resumes from the correct stage.

### Stage-Specific Failures

- **plan-implementation failure**: Cannot build without a plan. Spec is preserved.
- **build-implementation failure**: Plan is preserved. Partial code and progress checkpoints may exist — the Tier 1 skill will resume from its last checkpoint on re-run.
- **review-quality failure**: Implementation is preserved. Re-run review independently with `/review-quality {feature}`.
