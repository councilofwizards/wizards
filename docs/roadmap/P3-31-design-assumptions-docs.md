---
title: "Design Assumptions Documentation"
status: complete
priority: P3
category: documentation
completed: "2026-03-27"
---

# P3-31: Design Assumptions Documentation

## Summary

Added `<!-- SCAFFOLD: ... | ASSUMPTION: ... | TEST REMOVAL: ... -->` inline comments to all 14 multi-agent SKILL.md
files documenting model-capability assumptions baked into each design choice. Also added the SCAFFOLD Comments
convention to `CLAUDE.md` under Development Guidelines. Implemented as Group D of the harness-improvements batch
alongside P3-30.

## What Was Built

- `### SCAFFOLD Comments` subsection added to `CLAUDE.md` Development Guidelines (format definition, 2 examples,
  placement rules)
- SCAFFOLD comments added above Skeptic deadlock rules in all 14 skills (iteration cap assumption)
- SCAFFOLD comments added above `### When to Checkpoint` in all 14 skills (context-anxiety assumption)
- SCAFFOLD comments added above each skeptic/QA agent spawn definition in all 14 skills (Opus model assumption)
- Additional SCAFFOLD comment in `plan-product/SKILL.md` above Lead-as-Skeptic Stage 1-3 blocks

## Key Dependencies

- **Depends on**: Soft dependency on P3-03 (contribution guide provides maintainer context)
- **Implemented alongside**: P3-30 (same Group D batch; both touch all 14 skills + CLAUDE.md)
- **Files modified**: `CLAUDE.md` + all 14 multi-agent SKILL.md files
