---
type: "roadmap-item"
title: ""
topic: "" # the planning topic this item belongs to (matches the topic field in product-ideas)
source_ideas: "" # path to product-ideas artifact this item was derived from
next_action: "" # static map: when status=approved, set to "/conclave:write-stories <feature>"; downstream skills set their own
status: "draft" # draft | reviewed | approved | consumed | in_progress | complete | live | retired
priority: "" # P1 | P2 | P3
category: "" # project-defined; e.g. "auth" | "billing" | "platform" | "growth". This is YOUR project's taxonomy, not the conclave's.
effort: "" # small | medium | large
impact: "" # low | medium | high
dependencies: [] # list of roadmap-item titles or IDs this item depends on
approved_by: "" # skeptic role that approved
created: "" # YYYY-MM-DD
updated: "" # YYYY-MM-DD
---

# {Title}

## Description

<!-- 1-3 sentences. What is this item, and what user/system value does it deliver? -->

## Rationale

<!-- Why this is on the roadmap. Reference research-findings, ideas, or strategic goals. -->

## Acceptance Criteria

<!-- Numbered, testable statements. Used by write-stories to derive user-story acceptance criteria. -->

## Dependencies

<!-- Other roadmap items, infrastructure, or external decisions this item requires. -->

## Out of Scope

<!-- What this item explicitly does NOT cover. Prevents scope creep during downstream planning. -->

## Lifecycle Notes

<!-- Optional. Track post-deploy state transitions:
     - status: live (date) — feature shipped to production on YYYY-MM-DD; tracked at <link>
     - status: retired (date) — feature removed YYYY-MM-DD; reason: <reason>
     The conclave does not automate these transitions. The user marks them manually after deploy / removal. -->
