---
feature: "harness-improvements"
team: "build-product"
agent: "build-engineer"
phase: "complete"
status: "complete"
last_action: "Implemented Group D: checkpoint frequency + SCAFFOLD comments across all 14 multi-agent SKILL.md files and CLAUDE.md"
updated: "2026-03-27T19:30:00Z"
---

## Progress Notes

- [19:00] Read spec Group D section, implementation plan, and representative skill files
- [19:05] Identified "When to Checkpoint" section pattern across all 14 files (13 with "Team Lead", 1 review-quality with "QA Lead")
- [19:10] Replaced all 14 "When to Checkpoint" sections with conditional frequency format (every-step/milestones-only/final-only)
- [19:15] Added SCAFFOLD checkpoint comment above all 14 "When to Checkpoint" sections
- [19:20] Added SCAFFOLD iteration cap comment above all 14 "## Failure Recovery" sections
- [19:25] Added SCAFFOLD Opus model comment near skeptic spawn definitions in all 14 files:
  - Dedicated skeptic skills: above skeptic spawn heading (plan-product, build-product, build-implementation, plan-implementation, write-stories, write-spec, review-quality, draft-investor-update, plan-sales, plan-hiring)
  - Lead-as-Skeptic skills: above Lead-as-Skeptic line in Orchestration Flow (research-market, ideate-product, manage-roadmap)
  - run-task: above Skeptic row in Agent Archetypes table
- [19:27] Added Lead-as-Skeptic SCAFFOLD comment in plan-product near Stage 1 review gate
- [19:28] Added SCAFFOLD Comments convention subsection to CLAUDE.md Development Guidelines
- [19:30] Verified SCAFFOLD counts: all 14 multi-agent skills ≥3, plan-product=4
- [19:30] Verified no SCAFFOLD inside code blocks (spot-checked plan-product and build-implementation)
- [19:30] Ran validate.sh — 4 PASS checks, all failures are pre-existing php-tomes/docs issues (not caused by this work)

## Verification Results

SCAFFOLD counts:
- build-implementation: 3
- build-product: 3
- draft-investor-update: 3
- ideate-product: 3
- manage-roadmap: 3
- plan-hiring: 3
- plan-implementation: 3
- plan-product: 4 (extra: Lead-as-Skeptic)
- plan-sales: 3
- research-market: 3
- review-quality: 3
- run-task: 3
- write-spec: 3
- write-stories: 3

Validator: A3/spawn-definitions PASS, B3/authoritative-source PASS, C2/filename-convention PASS, F1/artifact-templates PASS
Pre-existing failures: php-tomes A1/A2/A4/B1/B2, docs C1/D1/E1 — not caused by Group D changes
