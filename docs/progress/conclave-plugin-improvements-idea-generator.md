---
type: progress-checkpoint
agent: idea-generator
persona: Pip Quicksilver, Chaos Alchemist
skill: ideate-product
topic: conclave-plugin-improvements
session: 2026-03-10
---

# Idea Generator Progress: Conclave Plugin Improvements

## Checkpoints

- [x] Task claimed — reading research-findings and roadmap
- [x] Ideation started — analyzing 11 pain points + roadmap gaps
- [x] Ideas ready
- [x] Ideas submitted to Team Lead

---

## Ideas

IDEAS: Conclave Plugin Improvements

### Immediate Fixes (Low Effort, High Impact)

**1. Persona Name Injection in Spawn Prompts**

- Description: Add a single sentence to every spawn prompt's opening: "Introduce yourself to the user as [Fictional
  Name], [Title]." This activates the entire fantasy persona system that was built but never wired. 45 characters have
  names and personalities; zero spawn prompts reference them.
- User need: Pain point #1 (CRITICAL) — Fantasy personas invisible during execution
- Evidence: Research confirms grep of all SKILL.md files found zero fictional name references. Communication protocol
  says "be a character in the Conclave" but nothing forces agents to adopt the identity.
- Estimated effort: Small (line-level edit per spawn prompt, ~40+ prompts)
- Estimated impact: High (transforms the entire UX from generic AI tool to immersive fantasy council)
- Type: Incremental fix

**2. Business Skills Section in wizard-guide**

- Description: Add a dedicated "Business Skills" section to wizard-guide's Skill Ecosystem Overview listing
  draft-investor-update, plan-sales, and plan-hiring with brief descriptions and example use cases. Currently three
  production-quality skills are completely invisible to users doing discovery.
- User need: Pain point #2 (HIGH) — wizard-guide omits business skills from overview
- Evidence: Research confirmed full read of wizard-guide SKILL.md shows business skills absent from both overview AND
  example workflows sections.
- Estimated effort: Small (one section addition)
- Estimated impact: High (three complete skills become discoverable)
- Type: Incremental fix

**3. wizard-guide Mention in setup-project Next Steps**

- Description: Add `/wizard-guide` as Step 1 (before `/plan-product`) in setup-project's Next Steps. Frame it as "get
  your tour of all 18 skills before diving in." The entire wizard-guide skill was built for discovery, but the natural
  entry point (setup-project) never mentions it.
- User need: Pain point #3 (HIGH) — No guided first-run path
- Evidence: Research confirmed setup-project Next Steps lists only `/plan-product`. New users are scaffolded but not
  oriented.
- Estimated effort: Small (one bullet point)
- Estimated impact: High (unlocks the discovery funnel for all skills including business ones)
- Type: Incremental fix

### Persona System Deepening

**4. Persona-Aware run-task Dynamic Agent Assignment**

- Description: Create four generic Conclave character persona files for the run-task archetypes (Engineer → "Gareth
  Ironwright, Forge Artificer", Researcher → "Lyra Dustfingers, Lore Dredger", Writer → "Cassia Inkwell, Scroll Weaver",
  Skeptic → "Doran Thornwick, Devil's Advocate"). Wire these into run-task spawn prompts so even ad-hoc agents are named
  Conclave characters.
- User need: Pain point #8 (MEDIUM) — run-task agents have no persona grounding
- Evidence: Research confirmed run-task is the only skill where the fantasy system breaks down entirely. Generic
  archetypes spawn with no fictional identity.
- Estimated effort: Medium (4 new persona files + run-task spawn prompt edits)
- Estimated impact: Medium (thematic coherence restored for the utility skill used most flexibly)
- Type: Incremental fix

**5. Persona Identity Reinforcement in Communication Protocol**

- Description: Add a line to the Communication Protocol shared block: "In every message to the user, sign off with your
  fictional name and title (e.g., '— Pip Quicksilver, Chaos Alchemist')." This creates persistent identity reinforcement
  throughout skill execution, not just at introduction. Every agent message becomes a signed dispatch from a named
  character.
- User need: Pain point #1 (CRITICAL) — Fantasy personas invisible during execution
- Evidence: Research shows persona system was designed for immersion but the architecture relies entirely on LLM
  choosing to surface it. Structural enforcement in the protocol is more reliable.
- Estimated effort: Small (one line in communication-protocol.md + sync)
- Estimated impact: High (sustained identity presence vs one-time introduction)
- Type: Novel (no existing mechanism for this)

**6. Conclave Lore Preamble in wizard-guide**

- Description: Add a short narrative preamble to wizard-guide that sets the fantasy stage: "You have summoned the
  Council of Wizards. These 45 specialists — mages, artificers, alchemists, and scribes — form the Conclave. Each skill
  summons a dedicated team from the council." Give users the world context before listing the skills. Turn discovery
  into an arrival.
- User need: Pain point #2 (HIGH) + thematic coherence opportunity
- Evidence: Research notes the fantasy theme aligns with Claude Code ecosystem trends toward personality-driven agents.
  wizard-guide is the entry point but reads like a technical catalog, not a world introduction.
- Estimated effort: Small (add ~100 words of narrative preamble)
- Estimated impact: Medium (delightful first impression; sets tone for all subsequent interactions)
- Type: Novel

### Architecture & Quality

**7. Role-Based Principles Split (Engineering vs Universal)**

- Description: Split shared/principles.md into two blocks: "universal-principles" (items applicable to all agents:
  quality thinking, clear communication, evidence-based reasoning) and "engineering-principles" (TDD, unit tests,
  SOLID/DRY, API contracts). Update sync script to apply engineering-principles only to engineering Tier 1 skills.
  Research and business skills get universal-principles only.
- User need: Pain point #4 (MEDIUM) — Shared Principles content mismatch
- Evidence: Research confirms engineering-specific rules (TDD, unit tests with mocks, SOLID/DRY) are synced to
  research-market, ideate-product, manage-roadmap where they're pure cognitive noise. Byte-identical sync confirmed by
  B1 validator means ALL multi-agent skills get the same block.
- Estimated effort: Medium (principles file restructuring + sync script update + validator update)
- Estimated impact: Medium (cleaner context windows for non-engineering agents; reduces cognitive noise)
- Type: Incremental improvement

**8. Communication Protocol Placeholder Fix + Inline Comment**

- Description: Change "product-skeptic" in the authoritative communication-protocol.md to `{skill-skeptic}` and add an
  inline HTML comment:
  `<!-- sync script substitutes the per-skill skeptic name — see scripts/sync-shared-content.sh normalizer -->`.
  Prevents future maintainers from being confused about why the source file uses a different name than what appears in
  skills.
- User need: Pain point #5 (MEDIUM) — Communication protocol "product-skeptic" placeholder
- Evidence: Research confirmed "product-skeptic" at line 31 of communication-protocol.md is a misleading artifact. Sync
  script normalizer has 13 name pairs but source reads as if product-skeptic is the actual recipient.
- Estimated effort: Small (one-line edit + comment)
- Estimated impact: Low (developer experience / maintenance clarity)
- Type: Incremental fix

**9. Stronger manage-roadmap Artifact Detection**

- Description: Upgrade manage-roadmap's skip detection in the plan-product Tier 2 pipeline to check for frontmatter
  `type: roadmap-item` and `topic:` fields matching the current topic, instead of the weaker "roadmap items exist for
  topic" string match. Aligns with artifact detection rigor in other pipeline stages.
- User need: Pain point #9 (LOW) — manage-roadmap skip detection weakness
- Evidence: Research identified this as a potential false-skip risk where unrelated roadmap items could match. Other
  Tier 2 stages check frontmatter type and status fields precisely.
- Estimated effort: Small (SKILL.md artifact detection logic edit)
- Estimated impact: Low (correctness improvement for edge cases)
- Type: Incremental fix

**10. Persona System ADR**

- Description: Write ADR-005 documenting the decision to create 45 fictional personas, the cross-reference file
  structure, the fantasy theme strategy, how personas relate to spawn prompts, and maintenance guidance (how to add a
  new persona). The persona system is one of the most distinctive architectural decisions in the plugin but is
  completely undocumented.
- User need: Developer pain point #1 — No persona system ADR
- Evidence: Research identified both the persona system and run-task design as undocumented decisions. ADR-001 through
  ADR-004 exist but persona architecture is absent.
- Estimated effort: Small (write one ADR document)
- Estimated impact: Medium (enables external contributors; documents design intent for future maintainers)
- Type: Novel (new artifact type for this layer)

**11. Validator: Spawn Prompt Persona Reference Check**

- Description: Add a G-series validator (skill-persona-grounding.sh) that checks: (a) every multi-agent SKILL.md spawn
  prompt contains a fictional name reference or a persona file cross-reference, (b) every persona file reference in
  spawn prompts resolves to an actual file in shared/personas/. Prevents the persona invisibility regression from
  happening again after the fix.
- User need: Pain point #1 (CRITICAL) prevention + Developer pain point #3 (validator gaps)
- Evidence: Research confirmed current validator suite has no spawn prompt content checks. The persona invisibility
  problem existed undetected because validators only check structure, not content quality.
- Estimated effort: Medium (new validator script + CI integration)
- Estimated impact: High (structural guarantee that persona layer stays wired; prevents regression)
- Type: Novel (new validator category)

### Novel / Divergent Ideas

**12. Business Tier 2 Composite: /run-business-ops**

- Description: Create a `/run-business-ops` Tier 2 composite that chains plan-sales → plan-hiring →
  draft-investor-update. Mirrors the value that `/plan-product` provides for engineering — a single invocation that
  produces a complete business operations review. The three business skills exist and are production-quality; only the
  composite glue is missing.
- User need: Pain point #6 (MEDIUM) — No post-build operational skills (extends to business domain)
- Evidence: Research recommendation #9 explicitly proposes this. The three skills exist. Tier 2 composite pattern is
  established via plan-product and build-product.
- Estimated effort: Medium (new SKILL.md + artifact contract between business skills if needed)
- Estimated impact: High (transforms three separate skills into a unified business ops pipeline)
- Type: Novel (new skill)

**13. PoC Skills Quarantine: test/ Subdirectory or Deprecation Warning**

- Description: Either move tier1-test and tier2-test to a `skills/test/` subdirectory (requires plugin discovery update)
  OR add a prominent DEPRECATION banner at the top of each SKILL.md: "INTERNAL TEST SCAFFOLD — Not for production use.
  See tier1-test/SKILL.md." Prevents users from accidentally invoking test scaffolding thinking it's a real skill.
- User need: Pain point #7 (LOW) — PoC skills in production directory
- Evidence: Research notes these are visible in skill discovery alongside production skills with no documentation
  warning. Moving them is a cleaner solution but requires discovery mechanism change.
- Estimated effort: Small (banner) or Medium (directory restructure)
- Estimated impact: Low-Medium (reduces confusion; improves production skill signal-to-noise)
- Type: Incremental fix

**14. Skill Naming Fantasy Rename: run-task → invoke-task or conjure-task**

- Description: Rename run-task to `invoke-task` (neutral but slightly more mystical) or `conjure-task` (full fantasy)
  while keeping backward-compatible alias. "Invoke" fits the Conclave metaphor — users invoke spells, which are skills.
  "Conjure" leans fully into the fantasy theme.
- User need: Pain point #10 (LOW) — "run-task" naming breaks fantasy convention
- Evidence: Research notes run-task is the only skill name without fantasy resonance. All other skills use evocative
  names (build, plan, review, ideate, manage, write).
- Estimated effort: Small (rename directory + update references)
- Estimated impact: Low (thematic polish; no functional change)
- Type: Incremental improvement

**15. Conclave "Season" Status Page Skill: /council-status**

- Description: A single-agent utility skill (`/council-status`) that reads the current roadmap, counts skills by tier,
  reports recent progress checkpoints, and presents a "Conclave Status Report" in character — as if the council is
  briefing the user on where things stand. Think: living documentation that's also in-universe.
- User need: Roadmap gap — no live status/orientation skill beyond wizard-guide
- Evidence: wizard-guide is static catalog. setup-project is bootstrapping. Neither answers "what's the current state of
  my project within the Conclave ecosystem." Research found no such discovery mechanism exists.
- Estimated effort: Medium (new SKILL.md + logic to read roadmap/progress files)
- Estimated impact: Medium (delightful orientation; makes the fantasy world feel inhabited and alive)
- Type: Novel

**16. Persona Spotlight Section in wizard-guide**

- Description: Add a "Meet the Council" section to wizard-guide that introduces 5-6 of the most colorful personas by
  name and title (e.g., "Pip Quicksilver, Chaos Alchemist — who generates the ideas; Mira Coldforge, Logic Warden — who
  tears them apart"). Makes the fantasy world concrete and memorable before users invoke their first skill.
- User need: Pain point #1 + #2 — Persona invisibility + wizard-guide enhancement opportunity
- Evidence: 45 personas exist with rich personalities but zero surface exposure to users. Research confirms the system
  was designed for immersion but never given a showcase moment.
- Estimated effort: Small (one section in wizard-guide SKILL.md)
- Estimated impact: Medium (creates anticipation for the fantasy experience; makes onboarding memorable)
- Type: Novel

**17. Cross-Skill Artifact Continuity Badge**

- Description: When a Tier 2 composite skips a stage (artifact detected), have the Lead agent report this as a narrative
  event: "The Lore Archives show previous research by [team name] — [date]. We proceed from their findings." Currently
  skip detection is silent. Making it narrative reinforces the in-universe continuity and informs users why a stage was
  skipped.
- User need: Pain point #1 (extends the persona/immersion theme) + artifact system transparency
- Evidence: Research describes Tier 2 artifact detection as functional but gives no user-facing feedback about WHY a
  stage was skipped. Users may be confused when steps appear to be skipped silently.
- Estimated effort: Small (add skip-detection narrative message to Tier 2 SKILL.md prompts)
- Estimated impact: Medium (transparency + immersion simultaneously)
- Type: Novel

**18. Contribution Guide Skill: /wizard-guide --dev**

- Description: Extend wizard-guide with a developer mode flag or create a companion `contribution-guide` utility skill
  (P3-03) that explains: how to add a new skill, persona file structure, sync script usage, validator suite, ADR
  conventions, and two-tier architecture patterns. Makes the plugin self-documenting for contributors.
- User need: Developer pain point #4 — Engineering skills lack per-skill design documents. Also addresses P3-03
  (Architecture & Contribution Guide, not_started).
- Evidence: Roadmap shows P3-03-contribution-guide.md as not_started. Research notes no ADR for persona system or
  run-task design. External contributors have no entry point.
- Estimated effort: Small-Medium (new SKILL.md or section extension)
- Estimated impact: Medium (enables community contributions; preserves architectural knowledge)
- Type: Incremental fix (implements existing roadmap item P3-03)

---

## Checkpoint: Ideas Ready

18 ideas generated spanning:

- Immediate fixes (3 ideas, all small effort, high impact)
- Persona system deepening (3 ideas)
- Architecture & quality (5 ideas)
- Novel / divergent ideas (7 ideas)

Coverage: All 11 pain points addressed. Roadmap gaps covered: P3-03 (contribution guide), new composite skill, validator
expansion, ADR-005.
