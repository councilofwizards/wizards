---
title: "Persona System Activation"
status: "complete"
priority: "P2"
category: "core-framework"
effort: "medium"
impact: "high"
dependencies: []
created: "2026-03-10"
updated: "2026-03-10"
---

# Persona System Activation

## Problem

The Conclave has 45+ fictional personas with names, titles, and personalities defined in `plugins/conclave/shared/personas/`. However, spawn prompts in all 12 multi-agent SKILL.md files reference agents only by role ID ("You are the Market Researcher"), never by fictional name. The communication protocol directs agents to "show your personality" but provides no structural enforcement. The fantasy persona layer — the largest investment in the plugin's identity system — is architecturally dormant.

## Proposed Solution

Three bundled changes that activate the persona system:

1. **Persona Name Injection in Spawn Prompts** (Idea 1): Add a character introduction line to every spawn prompt. Change "You are the Market Researcher on the Market Research Team" to "You are Lyssa Moonwhisper, Oracle of the People's Voice — the Customer Researcher on the Market Research Team." Add instruction: "When communicating with the user, introduce yourself by your name and title."

2. **Persona Identity Reinforcement in Communication Protocol** (Idea 4): Add a sign-off convention to the shared communication protocol's Message Format section: "When addressing the user, sign messages with your persona name and title." Update `plugins/conclave/shared/communication-protocol.md` and run `sync-shared-content.sh`.

3. **Communication Protocol Placeholder Fix** (Idea 10): Change "product-skeptic" to `{skill-skeptic}` with inline comment explaining sync script substitution. Done in the same edit pass as #2.

## Evidence

- Research finding #1 (CRITICAL severity): Grep confirmed zero fictional name matches in any SKILL.md spawn prompt
- 45+ persona files with complete fictional identities exist but are never referenced during execution
- Communication protocol's Voice & Tone section directs persona-forward communication but lacks structural enforcement

## Scope

- ~40+ spawn prompt edits across 12 multi-agent SKILL.md files
- 1 edit to `plugins/conclave/shared/communication-protocol.md` + sync
- All 12 multi-agent SKILL.md files updated via sync

## Success Criteria

- Every spawn prompt contains the agent's fictional name and title from their persona file
- Every spawn prompt instructs the agent to introduce themselves by name when addressing the user
- Communication protocol includes sign-off convention for user-facing messages
- Protocol placeholder uses generic `{skill-skeptic}` pattern
- All 12/12 validators pass after changes
