---
title: "User-Writable Configuration Convention"
status: complete
priority: P2
category: core-framework
effort: Small
impact: High
dependencies: []
created: 2026-03-27
updated: 2026-03-27
spec: docs/specs/user-writable-config/spec.md
---

# P2-13: User-Writable Configuration Convention

## Summary

Establish `.claude/conclave/` as the standard user-writable directory for project-specific plugin configuration. Since
the plugin is installed from a marketplace (read-only cache), users need a writable location for configuration that
agents read at runtime.

## Motivation

Multiple upcoming features need a user-writable location:

- P2-11 (Sprint Contracts): custom template overrides
- P3-29 (Evaluator Tuning): few-shot calibration examples per skill
- General: project-specific agent guidance files

Without a defined convention, each feature will invent its own storage path, leading to inconsistency.

## Directory Structure

```
.claude/conclave/
  templates/              # Custom artifact template overrides
    sprint-contract.md    # (P2-11 consumer)
  eval-examples/          # Skeptic calibration examples per skill
    build-implementation.md  # (P3-29 consumer)
    write-spec.md
  guidance/               # Project-specific agent guidance
    stack-preferences.md  # e.g., "prefer Pest over PHPUnit"
```

`docs/` stays for skill outputs (artifacts, progress, specs). `.claude/conclave/` is for plugin configuration.

## Scope

1. Define the convention and subdirectory naming
2. Update `setup-project` to scaffold `.claude/conclave/` skeleton on init
3. Document in `wizard-guide` under "Project Configuration"
4. Add `.claude/conclave/` to `.gitignore` template (may contain project-sensitive config)
5. Skills read from `.claude/conclave/` defensively — graceful degradation if files absent

## Success Criteria

1. `.claude/conclave/` directory structure documented
2. setup-project scaffolds the skeleton
3. wizard-guide references it
4. At least one downstream consumer (P2-11) reads from it
5. All validators pass
