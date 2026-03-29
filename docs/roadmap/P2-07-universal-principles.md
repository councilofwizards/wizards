---
title: "Role-Based Principles Split"
status: "complete"
priority: "P2"
category: "core-framework"
effort: "medium"
impact: "medium"
dependencies: ["content-deduplication"]
created: "2026-02-19"
updated: "2026-03-10"
---

# Role-Based Principles Split

## Problem

> **Note**: The original goal of this item (extracting shared content into authoritative source files) was completed as
> part of the shared content architecture: `plugins/conclave/shared/` + `scripts/sync-shared-content.sh` + B-series
> validators. The remaining work is the role-based principles split described below.

The shared principles block contains 4 engineering-specific rules (TDD, unit tests with mocks, SOLID/DRY, API contracts)
that are synced to ALL 12 multi-agent skills. Non-engineering skills (research-market, ideate-product, manage-roadmap,
plan-sales, plan-hiring, draft-investor-update) receive TDD guidance their agents cannot apply. Operational impact is
low (agents ignore irrelevant rules), but it creates cognitive noise in context windows.

## Proposed Solution

Split `plugins/conclave/shared/principles.md` into two blocks:

1. **Universal principles** (items 1-3, 9-12): Apply to all skills
2. **Engineering principles** (items 4-8: TDD, mocks, SOLID, contracts): Apply only to implementation skills
   (write-spec, plan-implementation, build-implementation, review-quality, run-task)

Update `scripts/sync-shared-content.sh` to inject the appropriate block per skill type. Update B-series validators for
dual-block awareness.

## Success Criteria

- Non-engineering skills receive only universal principles
- Engineering skills receive both universal and engineering principles
- Sync script correctly distinguishes skill types
- B-series validators updated for dual-block checking
- All validators pass after changes
