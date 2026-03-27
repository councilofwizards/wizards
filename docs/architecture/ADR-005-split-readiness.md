---
title: "Plugin Split Readiness Gate"
status: "accepted"
created: "2026-03-27"
updated: "2026-03-27"
superseded_by: ""
---

# ADR-005: Plugin Split Readiness Gate

## Status

Accepted

## Context

Conclave houses 17 skills in a single plugin. As business-domain skills (plan-sales, plan-hiring,
draft-investor-update) grew alongside engineering and planning skills, the question arose whether to split conclave
into separate domain-specific plugins (e.g., `conclave-engineering` and `conclave-business`).

Research into the trade-offs revealed that a domain split is premature at current scale. Only 3 business skills
exist — well below any useful threshold for a standalone plugin. The shared content coupling (sync scripts,
validators, shared persona definitions) makes splitting expensive relative to the benefit. Primary users
(technical founders) use both business and engineering domains in the same workflow; a split would fragment
their toolset without providing meaningful organization that the `category` taxonomy does not already provide.

## Decision

Keep a single plugin. Revisit the split decision only when ALL THREE of the following conditions are met:

1. **Business-category skills reach 7** — enough standalone value to justify a dedicated plugin and discovery surface.
2. **Parameterized shared content infrastructure is complete** — sync scripts and validators support configurable
   shared-dir paths, enabling multiple plugins to share content without hardcoding.
3. **Shared persona extraction is complete** — wizard personas (Meet the Council) are extracted to a shared
   location rather than living inside wizard-guide alone, so they can be referenced by both plugins after a split.

An automated gate (`scripts/validators/split-readiness.sh`) issues an advisory `[WARN]` when the business skill
count reaches 7, preventing silent threshold crossing.

## Alternatives Considered

### Split now

Rejected. With only 3 business skills, a standalone business plugin would be sparse and would add infrastructure
maintenance burden (separate plugin manifests, duplicate validators, separate cache entries) without commensurate
discovery or organization benefit. The category taxonomy already provides the internal grouping that a split
would provide externally.

### Virtual namespacing (skill name prefixes)

Rejected. Redundant with the `category` metadata already present in each SKILL.md frontmatter and plugin.json.
Prefixing skill names (e.g., `biz:plan-sales`) would break existing invocations and add complexity without
providing information that category fields do not already encode.

### Never split

Rejected. A monolithic plugin does not scale past 30+ skills. Discovery friction increases, wizard-guide
becomes unwieldy, and category-based filtering cannot substitute for genuine separation of concerns when
business and engineering skill counts are both large enough to stand alone.

## Consequences

- **Positive**: Zero infrastructure risk from premature split; current development velocity is unaffected.
- **Positive**: Internal `category` taxonomy provides organization at scale without a plugin boundary.
- **Positive**: Automated gate in `split-readiness.sh` prevents the team from crossing the threshold silently.
- **Negative**: Single plugin grows large as skills are added; wizard-guide listing grows without role-based filtering.
- **Negative**: Discovery friction increases for users who only need one domain — mitigated by progressive disclosure in wizard-guide (P2-08 sub-task 4).
