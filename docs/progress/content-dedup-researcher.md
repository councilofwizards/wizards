---
feature: "content-dedup"
team: "plan-product"
agent: "researcher"
phase: "research"
status: "complete"
last_action: "Completed deep investigation of P2-05 implementation options"
updated: "2026-02-18T13:00:00Z"
---

# Research Findings: P2-05 Content Deduplication — Implementation Options

## Summary

Investigated CLAUDE.md loading behavior, plugin context mechanisms, portability tradeoffs, token costs, and three
implementation options. The sections are NOT perfectly identical across skills -- there are intentional per-skill
variations (skeptic names in message routing table, quote style differences, and a build-product-only contract
negotiation section). This complicates all extraction approaches. Recommend **Option B (plugin-scoped shared file)**
with a runtime read step, not Option A (CLAUDE.md), because CLAUDE.md pollutes non-skill sessions and the plugin system
supports co-located files.

## 1. CLAUDE.md Loading Behavior

### How It Works (verified against official docs)

Claude Code loads CLAUDE.md files hierarchically:

- **Global**: `~/.claude/CLAUDE.md` -- loaded into every session across all projects
- **Project**: `./CLAUDE.md` or `./.claude/CLAUDE.md` -- loaded at launch for every session in the project
- **Local**: `./CLAUDE.local.md` -- personal per-project, gitignored
- **Modular rules**: `.claude/rules/*.md` -- automatically loaded as project memory, all `.md` files recursively
- **Auto memory**: `~/.claude/projects/<project>/memory/` -- Claude's own notes
- **Child directories**: CLAUDE.md files in subdirectories load on-demand when Claude reads files in those dirs

**Import syntax**: CLAUDE.md files support `@path/to/file` imports. Imported files can recursively import more files
(max depth 5).

**Confidence**: HIGH (verified against https://code.claude.com/docs/en/memory)

### Key Implication for P2-05

A project-level CLAUDE.md (or `.claude/rules/` file) is loaded into **every Claude Code session** in the project -- not
just skill invocations. If shared principles (~50 lines, ~600-660 words) are placed there, they appear when a developer
is doing ordinary coding, debugging, or asking questions. This is the "CLAUDE.md pollution" risk the Skeptic flagged.

This is NOT a theoretical concern. The shared principles contain instructions like "TDD by default", "Communicate
constantly via SendMessage", and "No agent proceeds past planning without Skeptic sign-off" -- all of which are
meaningless or confusing outside a skill invocation context.

## 2. Plugin Context Mechanism

### Plugin Installation and Caching

**Fact**: Marketplace plugins are copied to `~/.claude/plugins/cache/` on install. They cannot reference files outside
their own directory using `../` paths. (Source: docs/plugin-marketplaces.md line 255 and official plugins-reference
docs)

**Fact**: The `--plugin-dir` flag loads plugins directly from the specified directory (no cache copy). This is for
development only.

**Fact**: Symlinks within a plugin directory ARE followed during the cache copy. This means a symlink inside the plugin
can point to an external shared file, and the content will be copied into the cache.

**Fact**: `${CLAUDE_PLUGIN_ROOT}` is available for hooks and MCP servers to reference files within the installed plugin
directory.

**Confidence**: HIGH (verified against official docs)

### Can Plugins Inject Shared Context?

**No built-in mechanism exists.** The plugin.json schema supports: name, version, description, author, homepage,
repository, license, keywords, commands, agents, skills, hooks, mcpServers, lspServers, outputStyles. There is no
`sharedContext`, `memory`, `claude-md`, or equivalent field.

However, **plugins can include files alongside SKILL.md**. The official docs show:

```
skills/
├── code-reviewer/
│   ├── SKILL.md
│   ├── reference.md (optional)
│   └── scripts/ (optional)
```

This means a SKILL.md can include a Setup step that reads a co-located file. The file path would be relative to the
SKILL.md location, which agents can resolve since they know their working context.

**Confidence**: HIGH

### CLAUDE.md Inside Plugin Directory?

**Child-directory CLAUDE.md files load on-demand** when Claude reads files in those subtrees. This means a
`plugins/conclave/CLAUDE.md` would only load when an agent reads files in that directory -- it would NOT load at session
start. This is NOT equivalent to project-root CLAUDE.md behavior.

**Confidence**: HIGH (docs explicitly state "CLAUDE.md files in child directories load on demand when Claude reads files
in those directories")

## 3. The Sections Are NOT Identical

### Critical Finding

The diff analysis reveals that the "Shared Principles" and "Communication Protocol" sections have intentional per-skill
variations:

#### Variation 1: Quote Style

- **plan-product**: Uses single quotes in code examples: `type: 'message'`
- **build-product**: Uses double quotes: `type: "message"`
- **review-quality**: Uses double quotes: `type: "message"`

This is a cosmetic inconsistency (probably accidental), not an intentional variation. Should be normalized.

#### Variation 2: Skeptic Name in Message Routing Table

- **plan-product**: `write(product-skeptic, "PLAN REVIEW REQUEST: ...")` / "Product Skeptic"
- **build-product**: `write(quality-skeptic, "PLAN REVIEW REQUEST: ...")` / "Quality Skeptic"
- **review-quality**: `write(ops-skeptic, "PLAN REVIEW REQUEST: ...")` / "Ops Skeptic"

This IS intentional. Each skill has a different skeptic role, and the communication table routes to the correct
recipient. This row cannot be extracted without parameterization.

#### Variation 3: Horizontal Rule

- **plan-product**: No `---` separator between Shared Principles and Communication Protocol
- **build-product**: Has `---` separator
- **review-quality**: Has `---` separator

Cosmetic inconsistency.

#### Variation 4: Table Formatting

- **plan-product**: Compact table format (`|Event|Action|Target|`)
- **build-product**: Padded table format (`| Event | Action | Target |`)
- **review-quality**: Padded table format (`| Event | Action | Target |`)

Cosmetic inconsistency.

#### Variation 5: Build-Product Contract Negotiation

- **build-product**: Has an additional "Contract Negotiation Pattern" section (lines 222-277) after the shared
  Communication Protocol. This is build-product-specific and correctly not duplicated in the other skills.
- **plan-product**: Has a comment
  `<!-- Contract Negotiation Pattern omitted -- only relevant to build-product. See build-product/SKILL.md. -->`
- **review-quality**: Has the same omission comment
  `<!-- Contract Negotiation Pattern omitted -- only relevant to build-product. See build-product/SKILL.md. -->`

### Impact on Deduplication

The intentional variation (Variation 2: skeptic name routing) means the Communication Protocol section cannot be
extracted verbatim as a single shared file. Options:

1. **Parameterize the skeptic name**: Extract the section with a placeholder like `{SKEPTIC_NAME}` that each skill fills
   in. But SKILL.md files are plain markdown read by LLMs -- there's no template engine.
2. **Extract only Shared Principles**: The 12 principles (lines 141-167 in plan-product) ARE identical across all 3
   skills once the quote-style inconsistency is normalized. Only the Communication Protocol has the skeptic-name
   variation.
3. **Extract both with a generic skeptic reference**: Replace `write(product-skeptic, ...)` with `write(skeptic, ...)`
   in the shared version, and let each skill's spawn prompts establish who "skeptic" is. The current spawn prompts
   already tell each agent who the skeptic is for their team.

## 4. Token Cost Analysis

### Shared Section Sizes

| Skill          | Shared Section Lines | Shared Section Words | Shared Section Bytes |
| -------------- | -------------------- | -------------------- | -------------------- |
| plan-product   | 62 (lines 141-202)   | 607                  | 4,617                |
| build-product  | 62 (lines 159-220)   | 667                  | 4,583                |
| review-quality | 62 (lines 151-212)   | 667                  | 4,575                |

**Average**: ~62 lines, ~647 words, ~4,592 bytes per skill

### Token Estimation

Using the standard approximation of ~0.75 tokens per word for English text with markdown formatting:

- **Per shared section**: ~647 words x 1.33 tokens/word = ~860 tokens (markdown has higher token density than plain
  prose due to formatting characters)
- **More conservative estimate** using bytes: ~4,592 bytes / 4 bytes per token = ~1,148 tokens

Using a middle estimate of **~1,000 tokens per shared section**:

### Per-Invocation Duplication Cost

The SKILL.md is loaded once by the team lead. Spawned agents receive it in their spawn prompt (which includes skill
context). Each agent that reads the SKILL.md pays the token cost.

| Skill             | Standard Agents          | Shared Section Tokens (per agent) | Total Shared Tokens |
| ----------------- | ------------------------ | --------------------------------- | ------------------- |
| `/plan-product`   | 5 (lead + 4 spawned)     | ~1,000                            | ~5,000              |
| `/build-product`  | 5 (lead + 4 spawned)     | ~1,000                            | ~5,000              |
| `/review-quality` | 2-4 (lead + 1-3 spawned) | ~1,000                            | ~2,000-4,000        |

**Current redundant cost per invocation**: The shared section appears in 3 copies (one per SKILL.md file in the repo),
but only ONE skill is invoked at a time. The per-invocation redundancy is within the single SKILL.md -- agents each read
the same shared content. Extraction to a shared file doesn't reduce per-agent cost; it reduces maintenance burden and
per-SKILL.md file size.

**Where extraction saves tokens**: If the shared content is in CLAUDE.md or a project-level file that agents already
have in context, the SKILL.md can omit it (~1,000 fewer tokens per SKILL.md). With 5 agents reading the SKILL.md, that's
~5,000 fewer tokens per invocation. But this saving only applies if the shared content is NOT also loaded separately --
otherwise it's loaded twice (once from CLAUDE.md, once from the reference in SKILL.md).

### Total File Size Context

| Skill          | Total File Size (bytes) | Shared Section (bytes) | Shared % |
| -------------- | ----------------------- | ---------------------- | -------- |
| plan-product   | 19,499                  | 4,617                  | 23.7%    |
| build-product  | 23,707                  | 4,583                  | 19.3%    |
| review-quality | 22,603                  | 4,575                  | 20.3%    |

The shared sections represent ~20-24% of each SKILL.md file.

## 5. Option Comparison

### Option A: Extract to CLAUDE.md (or .claude/rules/)

**Mechanism**: Move Shared Principles and/or Communication Protocol to a project-level CLAUDE.md or a
`.claude/rules/conclave-principles.md` file. Each SKILL.md removes the duplicated sections and relies on agents having
the content via the memory system.

**Pros**:

- Single authoritative location for shared content
- Every agent automatically gets it (loaded into system prompt)
- Zero duplication across SKILL.md files
- One edit to change a principle

**Cons**:

- **CLAUDE.md pollution**: ~50-62 lines of agent-team-specific instructions appear in EVERY Claude Code session, not
  just skill invocations. Instructions like "Communicate constantly via SendMessage" and "No agent proceeds past
  planning without Skeptic sign-off" are confusing/meaningless during regular coding sessions.
- **Ownership conflict**: CLAUDE.md is a USER's file. The plugin shouldn't dictate project-level CLAUDE.md content. If
  the user has their own CLAUDE.md, the plugin's content competes for space in the ~300-line recommended limit.
- **Portability regression**: SKILL.md files no longer work without the CLAUDE.md being present. A user who copies a
  SKILL.md to another project loses the shared principles entirely.
- **Plugin cache isolation**: Marketplace plugins are cached at `~/.claude/plugins/cache/`. There is no mechanism for a
  plugin to write to the user's project-level CLAUDE.md or `.claude/rules/`. The user would have to manually create this
  file.
- **Skeptic name variation**: Communication Protocol references the skill-specific skeptic name. Can't extract verbatim.

**Verdict**: REJECTED. The pollution and ownership problems are fundamental, not solvable within the spec.

### Option B: Extract to Plugin-Scoped Shared File

**Mechanism**: Create a shared file within the plugin directory (e.g., `plugins/conclave/shared/principles.md`). Each
SKILL.md's Setup section reads this file as part of initialization. Each SKILL.md still contains a brief reference and
the skill-specific Communication Protocol row.

**Pros**:

- Single authoritative location within the plugin
- No CLAUDE.md pollution -- only loaded during skill invocations
- Co-located with the skills (copied to cache together)
- Plugin system supports files alongside skills: `${CLAUDE_PLUGIN_ROOT}` references work
- The Setup section already reads template files (`docs/specs/_template.md`, etc.) -- same pattern

**Cons**:

- Requires the Setup step to read the shared file at skill invocation time
- SKILL.md is no longer fully self-contained (portability regression, same as Option A but narrower -- within the plugin
  directory)
- Plugin cache copies the entire directory, so the shared file is available. But the `${CLAUDE_PLUGIN_ROOT}` variable is
  only documented for hooks and MCP servers, not for SKILL.md content. SKILL.md is loaded by Claude Code as markdown --
  it doesn't have access to `${CLAUDE_PLUGIN_ROOT}`.
- **Path resolution problem**: When a SKILL.md says "read `../shared/principles.md`", the agent needs to resolve this
  relative to the SKILL.md location. The agent reads the SKILL.md from the plugin cache at
  `~/.claude/plugins/cache/conclave/skills/plan-product/SKILL.md`. Can it read
  `~/.claude/plugins/cache/conclave/shared/principles.md`? The agents operate in the user's working directory, not the
  plugin cache. They would need the absolute path or a way to reference plugin-relative files.

**Mitigation for path problem**: The team lead (who reads the SKILL.md) operates in the user's project directory. The
Setup section could say: "Read `plugins/conclave/shared/principles.md` if it exists." But this path is the marketplace
repo structure, not the cache structure. For plugin-installed users, this path doesn't exist in their project.

**Alternative path approach**: The SKILL.md could embed a note saying "The Shared Principles are defined in the sibling
file at the same plugin location. Use the Glob tool to find `**/shared/principles.md` within the plugin directory." This
is fragile.

**Practical approach**: For this specific project (councilofwizards/wizards), the maintainer works directly in the repo,
not via the marketplace cache. The Setup step can say "Read `plugins/conclave/shared/principles.md`". For marketplace
users, the principles would need to be discoverable. Since agents already read files from `docs/` directories (which the
user has), the shared file could live at `docs/` level instead of within the plugin.

**Verdict**: VIABLE but needs careful path design. Best option if the path resolution problem is solved.

### Option C: Validated Duplication with CI

**Mechanism**: Keep all 3 copies in SKILL.md files. Add a CI script (part of P2-04) that validates the shared sections
are identical (modulo known intentional variations like the skeptic name).

**Pros**:

- SKILL.md files remain fully self-contained (no portability regression)
- No CLAUDE.md pollution
- No path resolution problems
- Maintainer gets an error if shared sections drift
- Can be implemented as part of P2-04 (testing pipeline)
- Handles the skeptic-name variation naturally (test ignores that row)

**Cons**:

- Does NOT eliminate duplication. Still 3 copies, still ~120 redundant lines.
- Does NOT reduce per-invocation token cost
- Still requires editing 3 files for any shared principle change (but at least drift is caught)
- Defers the real fix -- validated duplication is a bandage, not a cure

**Verdict**: VIABLE as a pragmatic fallback. Solves the maintenance-burden problem but not the token-cost problem.

### Option D: Hybrid — Shared File + Inline Fallback (NEW)

**Mechanism**: Create a shared file at a project-level location that the team lead reads during Setup. If the file
exists, use it. If not, the SKILL.md retains a condensed version of the principles as a fallback. The full-length shared
section is removed from SKILL.md and replaced with a 5-line summary + reference.

**Implementation**:

1. Create `plugins/conclave/shared/principles.md` with the canonical Shared Principles
2. Create `plugins/conclave/shared/communication-protocol.md` with the canonical Communication Protocol (using a generic
   `{skeptic}` placeholder or just `skeptic` as the recipient name)
3. Each SKILL.md replaces its ~62-line shared section with:

   ```
   ## Shared Principles & Communication Protocol

   These are defined in the plugin's shared directory. The team lead reads
   them during Setup and includes them when spawning agents.

   Key non-negotiable: Nothing advances without Skeptic approval.
   Full details: See Setup step reading shared principles.
   ```

4. Each SKILL.md's Setup section adds: "Read `plugins/conclave/shared/principles.md` and
   `plugins/conclave/shared/communication-protocol.md`. Include their content when spawning agents."
5. The team lead includes the shared content in each agent's spawn prompt (already standard behavior -- spawn prompts
   are constructed by the team lead).

**For portability**: If someone copies just a SKILL.md, they get the 5-line summary with the core principle (Skeptic
approval required). They lose the full protocol. This is an acceptable degradation -- a standalone SKILL.md should still
function; it just won't have the full communication protocol baked in.

**For plugin marketplace users**: The shared files are co-located in the plugin directory and copied to the cache. The
path `plugins/conclave/shared/principles.md` would not resolve from the user's project directory. But the team lead can
use Glob to find the files: `**/shared/principles.md`. This is ONE extra file read, not a fragile path dependency.

**Pros**:

- Single authoritative location
- No CLAUDE.md pollution
- Graceful degradation for portability
- Token savings: ~57 lines removed from each SKILL.md (~850 tokens x 5 agents = ~4,250 tokens saved per invocation)
- Team lead includes shared content in spawn prompts, so agents get it whether or not they read the SKILL.md directly

**Cons**:

- Adds a Setup step and Glob lookup
- Portability is degraded (but not broken)
- Requires the team lead to merge shared content into spawn prompts (which it already conceptually does -- the SKILL.md
  says "These principles apply to every agent on every team. They are included in every spawn prompt.")
- The skeptic-name variation in Communication Protocol still needs handling (use generic "skeptic" and let spawn prompts
  specify the actual name)

**Verdict**: RECOMMENDED. Best balance of deduplication, no-pollution, and graceful degradation.

## 6. Recommendations

### Primary Recommendation: Option D (Hybrid)

Option D provides the cleanest solution:

1. Shared content lives in ONE place (`plugins/conclave/shared/`)
2. No pollution of non-skill sessions
3. SKILL.md files remain functional (with degraded detail) when copied standalone
4. Token savings of ~850 tokens per SKILL.md per agent (~4,250 tokens per plan-product invocation)

### Pre-Requisite: Normalize Cosmetic Inconsistencies

Before extraction, normalize the 3 accidental inconsistencies:

- Quote style: standardize to double quotes across all 3 files
- Horizontal rule: add or remove consistently
- Table formatting: standardize to padded format

### Skeptic Name Resolution

The Communication Protocol table has one row that varies per skill (the "Plan ready for review" row with the
skill-specific skeptic name). Options:

- **Best**: Use a generic term like `skeptic` in the shared file. Each skill's spawn prompts already tell agents who
  their skeptic is by name.
- **Alternative**: Keep that single row in each SKILL.md and extract the rest of the table.

### Sequencing

1. Normalize cosmetic inconsistencies (can be done in same PR as dedup)
2. Create shared files in `plugins/conclave/shared/`
3. Update each SKILL.md: replace 62-line shared section with 5-line summary + Setup read step
4. Verify all 3 skills still function correctly
5. (Future, P2-04): Add CI validation that shared files match the canonical content

## Open Questions

1. **Plugin cache Glob discovery**: When the plugin is installed from marketplace cache, can agents Glob for
   `**/shared/principles.md`? The agent's working directory is the user's project, but the plugin files are in
   `~/.claude/plugins/cache/`. Needs testing.
2. **Spawn prompt inclusion**: The SKILL.md says "These principles apply to every agent on every team. They are included
   in every spawn prompt." Currently, the team lead reads the SKILL.md (which includes the principles) and constructs
   spawn prompts. If the principles are in a separate file, the Setup step must explicitly include them. Is this a
   natural extension of the current Setup pattern, or does it require new orchestration logic?
3. **SKILL.md frontmatter**: Could the SKILL.md frontmatter include a reference to shared files? The current frontmatter
   schema (name, description, argument-hint, disable-model-invocation) doesn't have a field for this. Custom frontmatter
   fields might be ignored or cause errors.
