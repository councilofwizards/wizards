# P1-00: Project Bootstrap & Initialization — Implementation Spec

## Summary

Add a directory-creation check as Step 1 in each skill's Setup section so the plugin works on first install. Three files modified, ~5 lines added per file. No structural changes.

## Problem

All three skills (`plan-product`, `build-product`, `review-quality`) instruct agents to read from `docs/roadmap/`, `docs/specs/`, `docs/progress/`, and `docs/architecture/`. On a fresh install, none of these directories exist. First-run invocations fail or produce disoriented agents.

## Change

Insert a new Step 1 in each SKILL.md's `## Setup` section before the existing read steps. Renumber existing steps. The inserted text is **identical across all three files**.

### Text to Insert

```markdown
1. **Ensure project directory structure exists.** Create any missing directories. For each empty directory, ensure a `.gitkeep` file exists so git tracks it:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
```

## Files to Modify

### 1. `plugins/agent-teams/skills/plan-product/SKILL.md`

**Before** (lines 15–19):
```markdown
## Setup

1. Read `docs/roadmap/` to understand current state
2. Read `docs/progress/` for latest implementation status
3. Read `docs/specs/` for existing specs
```

**After:**
```markdown
## Setup

1. **Ensure project directory structure exists.** Create any missing directories. For each empty directory, ensure a `.gitkeep` file exists so git tracks it:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
2. Read `docs/roadmap/` to understand current state
3. Read `docs/progress/` for latest implementation status
4. Read `docs/specs/` for existing specs
```

### 2. `plugins/agent-teams/skills/build-product/SKILL.md`

**Before** (lines 15–20):
```markdown
## Setup

1. Read `docs/roadmap/` to find the next "ready for implementation" item
2. Read the target spec from `docs/specs/[feature-name]/`
3. Read `docs/progress/` for any in-progress work to resume
4. Read `docs/architecture/` for relevant ADRs
```

**After:**
```markdown
## Setup

1. **Ensure project directory structure exists.** Create any missing directories. For each empty directory, ensure a `.gitkeep` file exists so git tracks it:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
2. Read `docs/roadmap/` to find the next "ready for implementation" item
3. Read the target spec from `docs/specs/[feature-name]/`
4. Read `docs/progress/` for any in-progress work to resume
5. Read `docs/architecture/` for relevant ADRs
```

### 3. `plugins/agent-teams/skills/review-quality/SKILL.md`

**Before** (lines 15–20):
```markdown
## Setup

1. Read `docs/roadmap/` to understand what features are in play
2. Read `docs/specs/` for the target feature's spec and API contracts
3. Read `docs/progress/` for implementation status and known issues
4. Read `docs/architecture/` for relevant ADRs and system design
```

**After:**
```markdown
## Setup

1. **Ensure project directory structure exists.** Create any missing directories. For each empty directory, ensure a `.gitkeep` file exists so git tracks it:
   - `docs/roadmap/`
   - `docs/specs/`
   - `docs/progress/`
   - `docs/architecture/`
2. Read `docs/roadmap/` to understand what features are in play
3. Read `docs/specs/` for the target feature's spec and API contracts
4. Read `docs/progress/` for implementation status and known issues
5. Read `docs/architecture/` for relevant ADRs and system design
```

## Seed Files

None beyond `.gitkeep`. No `_index.md`, no template content, no structured state files. Empty directories with `.gitkeep` are the correct initial state for a fresh project.

## Properties

- **Idempotent**: `mkdir -p` semantics. `.gitkeep` only created in empty directories. Running on an existing project is a no-op.
- **Zero dependencies**: No other features need to exist first.
- **Purely additive**: Only adds lines; no existing lines modified beyond renumbering.
- **Consistent**: Same canonical directory list, same wording, same position (Step 1) in all 3 skills.
- **Git-safe**: Empty directories survive `git clone` via `.gitkeep`.

## Out of Scope

- Interactive setup wizard (deferred to P3-02 Onboarding Wizard)
- CLAUDE.md generation
- Stack detection
- Configurable paths
- Graceful handling of empty directories by agents (workflow concern, not bootstrap)

## Success Criteria

1. A user installs the plugin and runs `/plan-product` on a project with no `docs/` directory. The skill creates the directory structure and proceeds normally.
2. A user runs `/build-product` on a project where `docs/` exists but `docs/architecture/` is missing. The missing directory is created; existing directories are untouched.
3. Running any skill on an already-initialized project produces no changes to the directory structure (idempotent).
4. After the bootstrap step runs on an empty project, `git status` shows the 4 directories tracked via `.gitkeep` files.
5. The skill's normal flow is not disrupted — directory creation is silent and immediate.
