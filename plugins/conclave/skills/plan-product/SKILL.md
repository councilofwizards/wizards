---
name: plan-product
description: >
  Invoke the Product Team to review the roadmap, research opportunities,
  define requirements, and create implementation specs. Use when you need
  to plan new features, reprioritize the backlog, or refine existing specs.
argument-hint: "[--light] [status | new <idea> | review <spec-name> | reprioritize | (empty for general review)]"
tier: 2
chains: [research-market, ideate-product, manage-roadmap, write-stories, write-spec]
---

# Product Planning Pipeline

You are the Product Planning Coordinator. You orchestrate a pipeline of Tier 1 skills
to take a product idea from market research through to a complete technical specification.

You do NOT spawn agent teams directly. Instead, you invoke Tier 1 skills via the Skill tool.
Each Tier 1 skill manages its own team, skeptic gates, and artifact production.

## Setup

1. **Ensure project directory structure exists.** Create any missing directories:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
   - `docs/research/`
   - `docs/ideas/`
   - `docs/stack-hints/`
   - `docs/templates/artifacts/`
2. Read `docs/roadmap/` to understand current product state and priorities.
3. Read `docs/progress/` for latest status across all skills.
4. Read `docs/specs/` for existing specifications.
5. Read `docs/research/` for existing research artifacts.
6. Read `docs/ideas/` for existing ideas artifacts.

## Determine Mode

Based on $ARGUMENTS:
- **"status"**: Invoke each Tier 1 skill with "status" argument to collect consolidated status across the planning pipeline. Do NOT run the pipeline. Report the aggregated results.
- **Empty/no args**: Run artifact detection to determine which stages are needed for the most relevant topic/feature. Execute the pipeline from the earliest missing stage. If no clear target exists, assess roadmap health and suggest next steps.
- **"new [idea]"**: Full pipeline from research through spec for a new idea. The idea description becomes the topic for research-market and flows through all stages.
- **"review [spec-name]"**: Skip to write-spec to review and refine an existing spec.
- **"reprioritize"**: Run manage-roadmap only with "reprioritize" argument.

## Artifact Detection

Before running the pipeline, check which artifacts already exist for the target feature/topic.
Use **frontmatter-based detection** — never rely on file existence alone.

For each artifact type, check:
1. Does the file exist at the expected path?
2. Does the frontmatter `type` field match the expected artifact type?
3. Does the frontmatter `feature` or `topic` field match the target?
4. Is the `status` field NOT "draft"? (draft = incomplete, must re-run)
5. For research-findings only: is the `expires` field not past today's date?

### Detection Paths

| Stage | Artifact Type | Expected Path | Possible Results |
|---|---|---|---|
| research-market | research-findings | `docs/research/{topic}-research.md` | FOUND / STALE / INCOMPLETE / NOT_FOUND |
| ideate-product | product-ideas | `docs/ideas/{topic}-ideas.md` | FOUND / INCOMPLETE / NOT_FOUND |
| manage-roadmap | roadmap-items | `docs/roadmap/` (items matching topic) | FOUND / NOT_FOUND |
| write-stories | user-stories | `docs/specs/{feature}/stories.md` | FOUND / INCOMPLETE / NOT_FOUND |
| write-spec | technical-spec | `docs/specs/{feature}/spec.md` | FOUND / INCOMPLETE / NOT_FOUND |

### Skip Logic

- **FOUND**: Skip the stage. The artifact is usable by downstream stages.
- **STALE**: Re-run the stage to refresh (research-findings only, based on expires field).
- **INCOMPLETE**: Re-run the stage to complete the artifact.
- **NOT_FOUND**: Must run the stage.

Report artifact detection results to the user before proceeding:

```
Artifact Detection for "{topic}":
  research-findings: [result]
  product-ideas:     [result]
  roadmap-items:     [result]
  user-stories:      [result]
  technical-spec:    [result]

Pipeline will run: [stages to execute]
Skipping:          [stages with FOUND artifacts]
```

## Pipeline

Execute stages sequentially. Each stage must complete before the next begins.
Each stage produces an artifact that downstream stages consume.

### Stage 1: Market Research

```
Skill(skill: "conclave:research-market", args: "{topic}")
```

**Produces**: research-findings at `docs/research/{topic}-research.md`
**Skip if**: research-findings FOUND for this topic

### Stage 2: Product Ideation

```
Skill(skill: "conclave:ideate-product", args: "{topic}")
```

**Produces**: product-ideas at `docs/ideas/{topic}-ideas.md`
**Requires**: research-findings (from Stage 1)
**Skip if**: product-ideas FOUND for this topic

### Stage 3: Roadmap Management

```
Skill(skill: "conclave:manage-roadmap", args: "ingest docs/ideas/{topic}-ideas.md")
```

**Produces**: Updated roadmap items in `docs/roadmap/`
**Requires**: product-ideas (from Stage 2)
**Skip if**: Roadmap items already exist for this topic

### Stage 4: User Stories

```
Skill(skill: "conclave:write-stories", args: "{feature}")
```

**Produces**: user-stories at `docs/specs/{feature}/stories.md`
**Requires**: roadmap-items (from Stage 3)
**Skip if**: user-stories FOUND for this feature

### Stage 5: Technical Specification

```
Skill(skill: "conclave:write-spec", args: "{feature}")
```

**Produces**: technical-spec at `docs/specs/{feature}/spec.md`
**Requires**: user-stories (from Stage 4)
**Skip if**: technical-spec FOUND for this feature

### Between Stages

After each stage completes:
1. Verify the expected artifact was produced (read the file, check frontmatter type and status fields)
2. If the artifact is missing or invalid, report the failure and stop the pipeline
3. Report progress to the user: `"Stage {N} ({skill-name}) complete. Artifact: {path}"`

## Lightweight Mode

If `$ARGUMENTS` begins with `--light`, strip the flag and prepend `--light` to ALL Tier 1 skill invocations:

```
Skill(skill: "conclave:research-market", args: "--light {topic}")
Skill(skill: "conclave:ideate-product", args: "--light {topic}")
```

This causes each Tier 1 skill to use reduced agent teams while maintaining quality gates.

Output to user: `"Lightweight mode enabled: all pipeline stages will use reduced agent teams."`

## Failure Handling

### Stage Failure

If a Tier 1 skill fails or produces an invalid/missing artifact:
1. Report the failure to the user with the stage name and error details
2. Do NOT proceed to the next stage — downstream stages depend on this artifact
3. Suggest re-running the failed stage individually: `"Run /research-market {topic} to retry Stage 1"`

### Partial Pipeline

If the pipeline is interrupted mid-execution:
1. All completed stages' artifacts are preserved on disk
2. Re-running the pipeline will detect existing artifacts via frontmatter and resume from the correct stage
3. Report the interruption point: `"Pipeline interrupted after Stage {N}. Re-run to resume from Stage {N+1}."`

### Stage-Specific Failures

- **research-market failure**: Cannot proceed. Research is the foundation for all downstream stages.
- **ideate-product failure**: Cannot proceed to roadmap. Research artifact is preserved.
- **manage-roadmap failure**: Cannot proceed to stories. Research and ideas artifacts preserved.
- **write-stories failure**: Cannot proceed to spec. All prior artifacts preserved.
- **write-spec failure**: All prior artifacts preserved. Stories are independently usable.
