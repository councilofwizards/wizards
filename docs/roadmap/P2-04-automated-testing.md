---
title: "Automated Testing Pipeline"
status: "not_started"
priority: "P2"
category: "quality-reliability"
effort: "large"
impact: "high"
dependencies: []
created: "2026-02-14"
updated: "2026-02-14"
---

# Automated Testing Pipeline

## Problem

The plugin has no automated tests. Skill files are complex markdown documents with precise formatting, cross-references, and behavioral contracts. Manual testing (invoking skills and watching agents) is slow and expensive. There's no way to catch regressions when editing SKILL.md files.

## Proposed Solution

1. **Structural validation**: A script that parses SKILL.md files and validates:
   - YAML frontmatter is well-formed
   - All referenced teammate names match spawn definitions
   - Status conventions are consistent across skills
   - Required sections (Setup, Spawn, Quality Gate, Recovery) are present
2. **Contract tests**: Verify that the three skills reference the same shared principles, communication protocol, and status conventions.
3. **CI integration**: Run validation on every commit via GitHub Actions.

## Architectural Considerations

- Tests operate on markdown files, not running code. A simple Node.js or Python script with YAML/markdown parsing is sufficient.
- Must not require Claude API access to run — tests validate structure, not agent behavior.
- The roadmap file format (ADR-001) should also be validated by these tests.

## Success Criteria

- A PR that breaks SKILL.md structure (e.g., removes the Quality Gate section) fails CI.
- A PR that introduces inconsistency between skills (e.g., different status conventions) fails CI.
