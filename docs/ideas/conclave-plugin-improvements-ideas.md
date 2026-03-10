---
type: "product-ideas"
topic: "conclave-plugin-improvements"
generated: "2026-03-10"
source_research: "docs/research/conclave-plugin-improvements-research.md"
---

# Product Ideas: Conclave Plugin Improvements

## Ideas

### Idea 1: Persona Name Injection in Spawn Prompts
- **Description**: Add a character introduction line to every spawn prompt across all 12 multi-agent SKILL.md files. Currently spawn prompts say "You are the Market Researcher on the Market Research Team." Change to "You are Lyssa Moonwhisper, Oracle of the People's Voice — the Customer Researcher on the Market Research Team." Also add instruction: "When communicating with the user, introduce yourself by your name and title. You are a character in the Conclave, not a process."
- **User Need**: Pain point #1 (CRITICAL) — 46 personas with fictional names/titles/personalities exist but are invisible during execution
- **Evidence**: Grep confirmed zero fictional name matches in any SKILL.md file (research artifact, confidence: HIGH)
- **Estimated Effort**: small (line-level edits per spawn prompt, ~40+ prompts across 12 files)
- **Estimated Impact**: high (activates the entire fantasy persona system)
- **Confidence**: H — directly addresses highest-severity research finding with mechanical fix
- **Priority Score**: 9

### Idea 2: Business Skills Section in wizard-guide
- **Description**: Add a "Business Skills" section to wizard-guide's Skill Ecosystem Overview listing draft-investor-update, plan-sales, and plan-hiring with descriptions. Also add business workflow examples to the Common Workflows section.
- **User Need**: Pain point #2 (HIGH) — three production-quality skills invisible at primary discovery point
- **Evidence**: Full read of wizard-guide SKILL.md confirmed business skills absent from overview (research artifact, confidence: HIGH)
- **Estimated Effort**: small (one new section + workflow examples)
- **Estimated Impact**: high (three complete skills become discoverable)
- **Confidence**: H — straightforward content addition
- **Priority Score**: 9

### Idea 3: wizard-guide Mention in setup-project Next Steps
- **Description**: Add a bullet to setup-project's Step 6 Next Steps: "Run `/wizard-guide` to explore all available skills and find the right one for your task." Place it before the existing `/plan-product` recommendation.
- **User Need**: Pain point #3 (HIGH) — new users get scaffolded directories but no tour of capabilities
- **Evidence**: Full read of setup-project Next Steps confirmed no wizard-guide mention (research artifact, confidence: HIGH)
- **Estimated Effort**: small (one bullet point)
- **Estimated Impact**: high (unlocks the discovery funnel for every new user)
- **Confidence**: H — one-line fix for a confirmed gap
- **Priority Score**: 9

### Idea 4: Persona Identity Reinforcement in Communication Protocol
- **Description**: Add a sign-off convention to the shared communication protocol's Message Format section: "When addressing the user, sign messages with your persona name and title." This creates structural enforcement of persona presence rather than relying on LLM inference.
- **User Need**: Pain point #1 extension — reinforces persona visibility beyond the initial introduction
- **Evidence**: Communication protocol's "Voice & Tone" section already directs persona-forward user communication but lacks structural enforcement (research artifact, confidence: HIGH)
- **Estimated Effort**: small (one addition to communication-protocol.md + sync)
- **Estimated Impact**: high (sustained persona presence in every user-facing message)
- **Confidence**: H — structural reinforcement more reliable than LLM volition
- **Priority Score**: 9

### Idea 5: Persona Reference Validator (G-series)
- **Description**: New validator script (skill-persona-refs.sh) that checks: (1) every spawn prompt contains a "read plugins/conclave/shared/personas/{id}.md" instruction, (2) the referenced persona file exists, (3) spawn prompts contain a fictional name string matching the persona file's fictional_name frontmatter field. Prevents persona system regression after Idea #1 is implemented.
- **User Need**: Developer pain point — no automated guard against persona layer breaking
- **Evidence**: Research confirmed validators check structural fields but not content quality (research artifact, confidence: HIGH)
- **Estimated Effort**: medium (new validator script + CI integration)
- **Estimated Impact**: high (structural guarantee against regression)
- **Confidence**: H — directly prevents confirmed gap; must sequence AFTER Idea #1
- **Priority Score**: 6

### Idea 6: Conclave Lore Preamble in wizard-guide
- **Description**: Add a ~100-word narrative preamble to wizard-guide that sets the world stage before listing skills. Something like: "Welcome to the Conclave — a council of specialized wizards, artificers, and strategists who collaborate to plan, build, and operate your product. Each team is led by a named character with a distinct personality..."
- **User Need**: Novel — deepens fantasy immersion at the primary user entry point
- **Evidence**: Research found "Conclave" name present as brand but not as in-world institution agents reference (confidence: MEDIUM)
- **Estimated Effort**: small (~100 words of narrative)
- **Estimated Impact**: medium (sets tone for all subsequent interactions)
- **Confidence**: M — impact depends on user receptiveness to fantasy framing
- **Priority Score**: 6

### Idea 7: Persona Spotlight in wizard-guide
- **Description**: Add a "Meet the Council" section to wizard-guide introducing 4-5 key personas by fictional name, title, and one-line personality. E.g., "Eldara Voss, Archmage of Divination — leads market research with calm omniscience." Cap at 5 personas to avoid overwhelming; choose one per major team archetype.
- **User Need**: Novel — makes personas concrete before first skill invocation
- **Evidence**: Research found persona layer is cosmetically defined but never surfaced to users pre-execution (confidence: HIGH)
- **Estimated Effort**: small (one curated section)
- **Estimated Impact**: medium (primes users to expect named characters)
- **Confidence**: M — enhances immersion but real impact comes from Ideas #1 and #4
- **Priority Score**: 6

### Idea 8: Cross-Skill Artifact Continuity Badges
- **Description**: In Tier 2 composite SKILL.md files (plan-product, build-product), add narrative flavor text to artifact detection skip messages. Instead of "Stage 1 skipped — artifact found," use "The Archives of the Conclave already hold research findings for this topic (found: docs/research/{topic}-research.md). Proceeding to ideation." Makes pipeline progression feel like a narrative, not a log.
- **User Need**: Novel — adds fantasy immersion to Tier 2 pipeline orchestration
- **Evidence**: Research found fantasy theme does not influence skill invocation language or artifact file paths (confidence: MEDIUM)
- **Estimated Effort**: small (flavor text additions to 2 Tier 2 SKILL.md files)
- **Estimated Impact**: medium (user-visible during every pipeline run)
- **Confidence**: M — depends on user appreciation of narrative framing
- **Priority Score**: 6

### Idea 9: Persona System ADR (ADR-005)
- **Description**: Write ADR-005 documenting the persona system: why 46 personas, the fictional identity strategy, the cross-reference structure, the dual communication style (terse agent-to-agent, personality-forward agent-to-user), and the fantasy theme rationale. Write AFTER Ideas #1 and #4 are implemented so the ADR reflects the completed system.
- **User Need**: Developer pain point — largest undocumented architectural decision
- **Evidence**: Research confirmed no ADR exists for the persona system (confidence: HIGH)
- **Estimated Effort**: small (one markdown file following ADR template)
- **Estimated Impact**: medium (essential for contributor onboarding and future maintenance)
- **Confidence**: H — straightforward documentation of existing decisions
- **Priority Score**: 6

### Idea 10: Communication Protocol Placeholder Fix
- **Description**: Change "product-skeptic" to "{skill-skeptic}" with an inline comment explaining the sync script substitutes per-skill. Bundled with Idea #4 (same file edit pass).
- **User Need**: Pain point #5 (MEDIUM) — authoritative source file is misleading
- **Evidence**: Research confirmed "product-skeptic" at line 31 of communication-protocol.md (confidence: HIGH)
- **Estimated Effort**: small (one-line edit, bundled with #4)
- **Estimated Impact**: low (maintenance clarity only)
- **Confidence**: H — trivial fix
- **Priority Score**: 3 (bundle with #4, don't track separately)

### Idea 11: Role-Based Principles Split
- **Description**: Split shared principles.md into universal principles (applies to all skills) and engineering principles (TDD, mocks, SOLID, contracts — applies only to implementation skills). Update sync script to inject the appropriate block per skill type. Update B-series validators for dual-block awareness.
- **User Need**: Pain point #4 (MEDIUM) — engineering rules in non-engineering contexts create cognitive noise
- **Evidence**: Research confirmed engineering-specific principles synced to all multi-agent skills (confidence: HIGH)
- **Estimated Effort**: medium-large (principles split + sync script logic + B-series validator updates)
- **Estimated Impact**: medium (reduces context window noise for non-engineering agents)
- **Confidence**: M — architecturally correct but operational impact is low (agents ignore irrelevant rules)
- **Priority Score**: 4

### Idea 12: Persona-Aware run-task Dynamic Archetypes
- **Description**: Create 4 new persona files for run-task's generic archetypes (Engineer, Researcher, Writer, Skeptic) with fictional names and the standard Identity/Communication Style sections. Update run-task SKILL.md spawn templates to reference these persona files.
- **User Need**: Pain point #8 (MEDIUM) — run-task is the only skill where persona system breaks down
- **Evidence**: Research confirmed run-task spawns generic templates with no persona grounding (confidence: HIGH)
- **Estimated Effort**: medium (4 new persona files + spawn prompt updates)
- **Estimated Impact**: medium (completes persona coverage across all skills)
- **Confidence**: M — proposed names need validation against existing 46 personas for conflicts
- **Priority Score**: 4

### Idea 13: Contribution Guide Skill
- **Description**: Implement P3-03 as a single-agent skill explaining how to add new skills, create personas, run the sync script, use validators, and follow the two-tier architecture. Could be a mode of wizard-guide (--dev) or a standalone skill.
- **User Need**: Roadmap item P3-03 — documentation gap for contributors
- **Evidence**: Research confirmed engineering skills lack per-skill design documents and no contribution guide exists (confidence: HIGH)
- **Estimated Effort**: medium (new SKILL.md with comprehensive developer guidance)
- **Estimated Impact**: medium (enables community contribution)
- **Confidence**: M — value depends on whether external contributors exist
- **Priority Score**: 4

### Idea 14: PoC Skills Deprecation Banner
- **Description**: Add a deprecation/internal-only banner to tier1-test and tier2-test SKILL.md frontmatter and first line of content. E.g., a `status: internal` frontmatter field and "This is an internal test skill used for PoC validation. Not intended for production use." Do NOT restructure directories.
- **User Need**: Pain point #7 (LOW) — PoC skills visible in discovery alongside production skills
- **Evidence**: Research confirmed PoC skills in production directory with no user-facing documentation (confidence: HIGH)
- **Estimated Effort**: small (frontmatter + banner in 2 files)
- **Estimated Impact**: low (minor user confusion prevention)
- **Confidence**: H — trivial change
- **Priority Score**: 3

## Evaluation Criteria Used

Ideas scored using Priority Score = Impact × (4 - Effort), where:
- Impact: high=3, medium=2, low=1
- Effort: small=1, medium=2, medium-large=2.5, large=3

All ideas evaluated against:
1. Evidence strength from research-findings artifact (HIGH confidence = stronger case)
2. Feasibility given codebase characteristics (markdown + shell scripts, no app runtime)
3. Regression risk to 12/12 validator suite
4. User-experienced impact vs. internal-only impact
5. Implementation bundling efficiency

## Rejected Ideas

### Rename run-task to conjure-task or invoke-task
- **Reason**: Breaking change risk for users with configured workflows. "run-task" is descriptively clear; fantasy alternatives reduce clarity. Research assessed LOW priority. Net-negative change.
- **Evidence**: Pain point #10 rated LOW by research. No user confusion reported.

### /council-status Skill
- **Reason**: Creative but addresses no confirmed pain point. No research evidence of user need for in-universe status reports. Park for P4 consideration if fantasy immersion ideas (#1, #4, #6, #7, #8) are well-received.
- **Evidence**: Novel idea with no corresponding research finding.

### Business Tier 2 Composite (/run-business-ops)
- **Reason**: The three business skills (plan-sales, plan-hiring, draft-investor-update) serve fundamentally different purposes and don't form a natural sequential pipeline. A forced composite risks being artificial. Needs discovery spike to confirm artifact contracts exist before committing. Parked pending spike.
- **Evidence**: Research identified the gap but Lead-as-Skeptic review challenged pipeline coherence.
