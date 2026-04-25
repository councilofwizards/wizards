---
agent: lorekeeper-f2a8
role: Lorekeeper (Theme Designer)
skill: competitor-research
status: draft-complete
run_id: f2a8
---

# Theme Design — Competitor Intelligence Skill

## Summary

**Skill Name:** `profile-competitor` **Team Name:** The Black Atlas **Team Name Slug:** `black-atlas`

The skill profiles a single named rival the way an old embassy profiles an unfamiliar court: dispatch field agents to
walk the rival's quarters (market, product, stack, go-to-market), return with ciphered observations, decrypt them into
positioning bets, and bind the whole into a four-folio Dossier. The fantasy is intelligence-gathering — not violence,
not conquest. Quiet observation, careful drafting, ruthless skepticism.

## Skill Name Justification

`profile-competitor` is verb-noun, kebab-case, two words, and instantly clear to an outsider. Considered alternatives:
`chart-rivals` (too poetic, less clear), `scout-competitor` (implies pre-engagement reconnaissance only — narrower than
the skill), `map-competitor` (collides linguistically with `manage-roadmap`'s "map"). `profile-competitor` matches the
verb-noun pattern of `squash-bugs`, `audit-slop`, `craft-laravel`.

## Team Name Justification

**The Black Atlas** fuses the two natural metaphors — cartography (atlas, charting unmapped territory) and espionage
(black, the color of ledgers kept off the public shelf). It evokes a permanent, growing record: each invocation adds a
new chart of a rival to the Atlas. The name is distinctive (no collision with existing teams), short, and gives the
Lorekeeper a reusable vocabulary anchor.

## Personas

| Agent Role                  | Persona Name     | Title                  | Character (1 sentence)                                                                                                                                                       | Persona File Name                      |
| --------------------------- | ---------------- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| Lead                        | Mara Onyxleaf    | The Cartomarshal       | A poised embassy chief who reads the rival's name aloud, drafts the brief, and assigns each field agent the quarter they will walk.                                          | `cartomarshal.md`                      |
| Market Cartographer         | Lir Vellamar     | The Atlas Cartographer | A cool-eyed mapmaker who charts the rival's market position, funding lineage, and trajectory the way one charts coastlines from a distance.                                  | `cartographer--competitor-research.md` |
| Product Inspector           | Pell Marrowfen   | The Storefront Walker  | A patient observer who walks the rival's storefronts and product surfaces and notes everything a customer would feel before they could name it.                              | `storefront-walker.md`                 |
| Technical Excavator         | Doran Ferromark  | The Stack Excavator    | A quiet engineer-spy who reads infrastructure signals, public artifacts, and architecture tells the way a tracker reads bent grass.                                          | `stack-excavator.md`                   |
| Go-to-Market Analyst        | Tess Brackenmoor | The Market-Watch Envoy | A traveling envoy who listens to the rival's pricing, sales motion, messaging, and the murmur of reviews from inns and squares alike.                                        | `gtm-analyst--competitor-research.md`  |
| Strategist (Opus)           | Calder Stormveil | The Gap-Reader         | An Opus-class strategist who reads four ciphered reports at once and names where the rival is weakest and where our flag should plant.                                       | `strategist--competitor-research.md`   |
| Chronicler                  | Iola Mournwick   | The Dossier-Binder     | A binder of folios who arranges the Atlas entry into four progressive layers — summary, review, technical, references — so the Lord may read as deep as the moment requires. | `chronicler--competitor-research.md`   |
| Skeptic (Opus, adversarial) | Renn Coldspire   | The Counter-Spy        | An adversarial reader who assumes every dispatch is half-fiction and refuses to pass a phase until the embassy proves what it claims.                                        | `counter-spy.md`                       |

## Thematic Vocabulary

| Term            | Process Event           | Definition                                                                                                                                              |
| --------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Brief           | Lead writes intake      | The Cartomarshal's opening document — names the rival, scopes the inquiry, assigns quarters to field agents.                                            |
| Field Dispatch  | Parallel research phase | The four field agents (Cartographer, Storefront Walker, Stack Excavator, Market-Watch Envoy) walking the rival's quarters in parallel via web research. |
| Cipher          | Raw findings            | A field agent's untreated intelligence — pricing pages, review quotes, infra fingerprints — before synthesis turns it into positioning.                 |
| Mapping         | Per-agent synthesis     | A field agent's act of folding their ciphers into a coherent quarter of the Atlas entry.                                                                |
| Decryption      | Strategist synthesis    | The Gap-Reader reading all four maps at once and producing cross-dimensional gap analysis and positioning recommendations.                              |
| Folio           | Dossier section         | One of the four progressive-disclosure layers of the Dossier (Executive Summary, General Review, Technical Details, References).                        |
| Dossier         | Final artifact          | The bound, four-folio Atlas entry on the named rival — the skill's output.                                                                              |
| Counter-Reading | Skeptic phase gate      | The Counter-Spy's adversarial review at each of the four phase transitions; nothing advances until the Counter-Reading is satisfied.                    |

## Narrative Arc

- **Opening — The Brief.** The Cartomarshal (Mara Onyxleaf) calls the Black Atlas to order, reads the rival's name
  aloud, and authors the Brief. She names the four quarters that must be walked and which agent walks each.
- **Rising Action — Field Dispatches.** Four field agents disperse in parallel. The Atlas Cartographer (Lir Vellamar)
  charts position, funding, and trajectory. The Storefront Walker (Pell Marrowfen) walks the product. The Stack
  Excavator (Doran Ferromark) reads the infrastructure and architecture tells. The Market-Watch Envoy (Tess Brackenmoor)
  listens at the pricing pages and review squares. Each returns with ciphers and a Mapping. The Counter-Spy (Renn
  Coldspire) delivers the first Counter-Reading; weak dispatches are sent back to the field.
- **Climax — Decryption.** The Gap-Reader (Calder Stormveil) reads the four Mappings together and decrypts them into a
  single thesis: where the rival is exposed, where they are entrenched, and the positioning bets the Lord should make.
  The Counter-Spy's second Counter-Reading attacks the thesis before it leaves the embassy.
- **Resolution — The Dossier.** The Dossier-Binder (Iola Mournwick) arranges the four Folios in progressive disclosure:
  Executive Summary first, then General Review, then Technical Details, then References. The Counter-Spy's final
  Counter-Reading checks that each Folio reveals only what it should at its depth, and that the Executive Summary's
  positioning recommendations are defensible from the references alone. The Dossier is bound and the Atlas grows by one
  entry.

## Name Collision Check

**Rule:** the operative constraint is **full-name distinctness**. Conclave precedent allows given-name reuse — the
existing roster contains multiple Brams, Vexes, Kaels, Sables, Pips, Oryns, and Thanes. Surname reuse is also tolerated
where the full name remains unique. Only an exact full-name match counts as a collision.

Existing character names scanned in `plugins/conclave/shared/personas/` and SKILL.md spawn prompts include
(non-exhaustive):

- Kael Draftmark
- Quill Ashmark
- Sable Inkwell (Lorekeeper, this agent)
- Sage Inkwell
- Thane Hallward
- Vex Ironbind
- Wren Cinderglass
- Pell Dustquill
- Renn Swiftseam

All eight proposed full names (Mara Onyxleaf, Lir Vellamar, Pell Marrowfen, Doran Ferromark, Tess Brackenmoor, Calder
Stormveil, Iola Mournwick, Renn Coldspire) are unique full-name combinations. **Two given-name reuses are present and
acceptable under the precedent above:** Pell (also borne by Pell Dustquill) and Renn (also borne by Renn Swiftseam). No
full-name collisions.

Existing role-slug labels also reviewed (Cartographer, Chronicler, Strategist, GTM Analyst, etc.) — confirmed that the
four reused slugs require the `--competitor-research.md` suffix per the persona file naming note.

## Persona File Naming Notes

**Use `--competitor-research.md` suffix (existing role slug, persona file already exists for another skill):**

- `cartographer--competitor-research.md`
- `chronicler--competitor-research.md`
- `gtm-analyst--competitor-research.md`
- `strategist--competitor-research.md`

**Plain `{slug}.md` (new slug, no prior persona file):**

- `cartomarshal.md` — Lead
- `storefront-walker.md` — Product Inspector
- `stack-excavator.md` — Technical Excavator (note: sibling to existing `boundary-excavator.md`, `logic-excavator.md`,
  `schema-excavator.md` — pattern preserved)
- `counter-spy.md` — Skeptic

## Design Principle 5 Check — Fantasy is the Voice, Not the Process

Every fantasy term in the vocabulary maps to a real process event with a 1:1 correspondence (Brief → intake doc, Field
Dispatch → parallel web-research phase, Cipher → raw research output, Mapping → per-agent synthesis, Decryption →
cross-dimensional strategic synthesis, Folio → dossier section, Dossier → final artifact, Counter-Reading → skeptic
phase gate). No fantasy term hides a process step or replaces a technical concept the user needs to reason about. The
narrative arc is consistent with the actual four-phase pipeline: brief → parallel dispatch → strategist synthesis →
chronicler binding, with skeptic gates at every transition.

## Checkpoints

- task claimed: yes (TaskUpdate set status in_progress, owner lorekeeper-f2a8)
- draft complete: yes (this file)
- submitted: pending (next: PLAN REVIEW REQUEST to forge-auditor-f2a8, confirmation to forge-master)
