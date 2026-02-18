> **HISTORICAL**: This was the original build plan. The final implementation deviates significantly (1 plugin instead of 3, renamed skills). See README.md for the current architecture. Preserved for design decision context.

# Implementation Plan: Plugin Marketplace

## Overview

Build the `councilofwizards/wizards` Claude Code plugin marketplace. Three plugins package the Agent Teams framework (from `docs/original-prompt.md`) into installable Claude Code plugins following the marketplace spec (from `docs/plugin-marketplaces.md`).

## Decisions Made

- **Scope**: Laravel SaaS specific — keep all stack references from original-prompt.md
- **Model assignments**: Opus for reasoning roles (leads, architects, skeptics), Sonnet for execution roles (engineers) — per Principle #12
- **Quality team**: Fully synthesized spawn prompts matching appendix style
- **DRY**: Each SKILL.md is fully self-contained (shared principles + comms protocol duplicated in each)

---

## Agent Team Design

### Agents (3)

| Agent | Role | Model | Tasks |
|-------|------|-------|-------|
| **forger** | Builds marketplace scaffold + /product plugin | opus | #1, #2 |
| **scribe** | Writes /implement + /quality plugins | opus | #3, #4 |
| **skeptic** | Adversarial quality gate — reviews everything against source docs | opus | #5 (blocked by #1-4) |

### Workflow

```
forger ──┬──► Task #1 (scaffold) ──► Task #2 (/product SKILL.md) ──┐
         │                                                          ├──► skeptic reviews all (Task #5)
scribe ──┴──► Task #3 (/implement SKILL.md) ──► Task #4 (/quality) ┘
```

Forger and Scribe work in parallel. Skeptic waits for all 4 tasks, then does line-by-line review against source docs. Nothing ships without Skeptic APPROVED verdict.

### Key Instruction: tmux Focus

**IMPORTANT**: When spawning agents, DO NOT TYPE in the terminal until all agents have started. The tmux pane creation steals keyboard focus, and keystrokes bleed into the new panes, breaking the agent startup commands. Wait 5-10 seconds after spawning before typing anything.

---

## Files to Create

### 1. Marketplace Manifest

**Path**: `.claude-plugin/marketplace.json`

```json
{
  "name": "wizards",
  "owner": {
    "name": "Zachary Mowrey"
  },
  "metadata": {
    "description": "Curated Claude Code plugins for orchestrating AI agent teams to plan, build, and operate SaaS products",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "product-team",
      "source": "./plugins/product-team",
      "description": "Invoke the Product Team for roadmap, research, specs, and planning"
    },
    {
      "name": "impl-team",
      "source": "./plugins/impl-team",
      "description": "Invoke the Implementation Team to build features from specs"
    },
    {
      "name": "quality-team",
      "source": "./plugins/quality-team",
      "description": "Invoke the Quality & Operations Team for audits and testing"
    }
  ]
}
```

### 2. Plugin Manifests

**Path**: `plugins/product-team/.claude-plugin/plugin.json`
```json
{
  "name": "product-team",
  "description": "Invoke the Product Team for roadmap, research, specs, and planning",
  "version": "1.0.0"
}
```

**Path**: `plugins/impl-team/.claude-plugin/plugin.json`
```json
{
  "name": "impl-team",
  "description": "Invoke the Implementation Team to build features from specs",
  "version": "1.0.0"
}
```

**Path**: `plugins/quality-team/.claude-plugin/plugin.json`
```json
{
  "name": "quality-team",
  "description": "Invoke the Quality & Operations Team for audits and testing",
  "version": "1.0.0"
}
```

### 3. Skill Files

**Path**: `plugins/product-team/skills/product/SKILL.md`
- Frontmatter from original-prompt.md lines ~414-423
- Orchestration body from lines ~424-483
- ALL 5 spawn prompts from Appendix — VERBATIM:
  - Product Owner (lines ~707-737)
  - Researcher (lines ~742-777)
  - Software Architect (lines ~782-814)
  - DBA (lines ~820-852)
  - Product Skeptic (lines ~858-894)
- Shared Principles (lines ~69-96) — all 12
- Communication Protocol (lines ~99-139)
- Model assignments: all Opus

**Path**: `plugins/impl-team/skills/implement/SKILL.md`
- Frontmatter from original-prompt.md lines ~489-497
- Orchestration body from lines ~498-564
- ALL 5 spawn prompts from Appendix — VERBATIM:
  - Tech Lead (lines ~900-929)
  - Implementation Architect (lines ~935-959)
  - Backend Engineer (lines ~965-1002)
  - Frontend Engineer (lines ~1007-1040)
  - Quality Skeptic (lines ~1045-1095)
- Backend ↔ Frontend contract negotiation pattern (lines ~331-371)
- Shared Principles (lines ~69-96) — all 12
- Communication Protocol (lines ~99-139)
- Both quality gates (pre-implementation + post-implementation)
- Model assignments: Tech Lead=Opus, Impl Architect=Opus, Backend Eng=Sonnet, Frontend Eng=Sonnet, Quality Skeptic=Opus

**Path**: `plugins/quality-team/skills/quality/SKILL.md`
- Frontmatter from original-prompt.md lines ~570-577
- Orchestration body from lines ~578-594
- 4 SYNTHESIZED spawn prompts (not in appendix — write in same style):
  - Test Engineer (Sonnet) — comprehensive test suites, edge cases, regression
  - DevOps Engineer (Sonnet) — infrastructure, deployment, CI/CD, env parity
  - Security Auditor (Opus) — injection, XSS, CSRF, auth bypass, mass assignment
  - Ops Skeptic (Opus) — challenges production readiness claims, demands evidence
- Conditional team composition:
  - security → security-auditor + ops-skeptic
  - performance → test-eng + ops-skeptic
  - deploy → devops-eng + security-auditor + ops-skeptic
  - regression → test-eng + ops-skeptic
- Shared Principles (lines ~69-96) — all 12
- Communication Protocol (lines ~99-139)
- Quality gate: Ops Skeptic approves all outputs

---

## Final Directory Structure

```
wizards/
  .claude-plugin/
    marketplace.json
  plugins/
    product-team/
      .claude-plugin/
        plugin.json
      skills/
        product/
          SKILL.md
    impl-team/
      .claude-plugin/
        plugin.json
      skills/
        implement/
          SKILL.md
    quality-team/
      .claude-plugin/
        plugin.json
      skills/
        quality/
          SKILL.md
  docs/
    original-prompt.md
    plugin-marketplaces.md
    implementation-plan.md
```

---

## Skeptic Review Checklist

The Skeptic must verify ALL of the following before approving:

- [ ] Directory layout matches plugin-marketplaces.md spec exactly
- [ ] marketplace.json has all required fields (name, owner, plugins)
- [ ] marketplace name "wizards" not in reserved names list
- [ ] All plugin.json files have required fields (name, description, version)
- [ ] Plugin names match between marketplace.json and plugin.json
- [ ] Source paths in marketplace.json point to real directories
- [ ] Each SKILL.md has correct frontmatter (name, description, argument-hint)
- [ ] Product team: all 5 spawn prompts VERBATIM from appendix
- [ ] Implement team: all 5 spawn prompts VERBATIM from appendix
- [ ] Quality team: 4 synthesized spawn prompts consistent in style
- [ ] All 12 shared principles present in each SKILL.md
- [ ] Communication protocol complete in each SKILL.md
- [ ] Contract negotiation pattern present in /implement SKILL.md
- [ ] Quality gates correct in each skill
- [ ] Model assignments correct (Opus for reasoning, Sonnet for execution)
- [ ] No fabricated content (except quality team spawn prompts, which are synthesized)
- [ ] No missing content from source docs
- [ ] Consistent formatting across all three plugins

---

## How to Execute

1. Start a fresh Claude Code session
2. Say: "Read docs/implementation-plan.md and execute it. Spin up the agent team as described. IMPORTANT: after you spawn agents, do NOT type anything for 10 seconds — tmux pane creation steals keyboard focus."
3. Wait for all agents to start before interacting
4. The Skeptic will automatically begin review once builders finish
5. Address any Skeptic rejections
6. Once Skeptic approves: commit and push
