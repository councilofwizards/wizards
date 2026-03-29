---
type: "sprint-contract"
feature: "harness-improvements"
status: "signed"
signed-by: ["implementation-coordinator", "plan-skeptic"]
created: "2026-03-27"
updated: "2026-03-27"
---

# Sprint Contract: Harness Improvements (P3-26 through P3-31)

## Acceptance Criteria

1. plan-product SKILL.md parses `--complexity=[simple|standard|complex]` and
   `--full` flags without breaking existing mode resolution | Pass/Fail: [ ]
2. plan-product classifies tasks as Simple/Standard/Complex and reports the tier
   to the user before proceeding | Pass/Fail: [ ]
3. Simple tier skips Stages 1-2 execution in plan-product; Standard tier is
   unchanged; Complex tier inserts a review checkpoint between Stages 3-4 |
   Pass/Fail: [ ]
4. `--full` spawns product-skeptic before Stage 1 and routes Stages 1-3 through
   product-skeptic gates; without `--full`, Lead-as-Skeptic unchanged |
   Pass/Fail: [ ]
5. build-product SKILL.md parses `--complexity` flag and applies tier-based
   routing to its 3-stage pipeline | Pass/Fail: [ ]
6. All 14 multi-agent SKILL.md files parse `--max-iterations N` with default 3;
   invalid values fall back to 3 with warning | Pass/Fail: [ ]
7. Every deadlock rule across all 14 skills references configurable N instead of
   hard-coded "3" | Pass/Fail: [ ]
8. wizard-guide SKILL.md contains a "Common Flags" section documenting all
   cross-skill flags | Pass/Fail: [ ]
9. All 14 multi-agent SKILL.md files parse
   `--checkpoint-frequency [every-step|milestones-only|final-only]` with default
   every-step | Pass/Fail: [ ]
10. "When to Checkpoint" sections in all 14 skills are conditional on frequency
    mode; blocked events always checkpoint regardless of frequency | Pass/Fail:
    [ ]
11. CLAUDE.md contains "SCAFFOLD Comments" convention with format, examples, and
    placement rules | Pass/Fail: [ ]
12. All 14 multi-agent SKILL.md files have minimum 3 SCAFFOLD comments
    (iteration cap, checkpoint default, Opus model); plan-product has 4th
    (Lead-as-Skeptic) | Pass/Fail: [ ]
13. No SCAFFOLD comments appear inside spawn prompt code blocks | Pass/Fail: [ ]
14. build-implementation and plan-implementation read
    `.claude/conclave/eval-examples/` with defensive reading contract; absent
    directory causes no error | Pass/Fail: [ ]
15. Pipeline completion in build-implementation, plan-product, and build-product
    includes post-mortem quality rating prompt; skip/invalid responses cause no
    blockage | Pass/Fail: [ ]
16. Skeptic spawn prompts in 4 target skills include calibration instruction
    conditional on eval examples presence | Pass/Fail: [ ]
17. `bash scripts/validate.sh` passes at the same baseline (no new failures
    introduced) after all changes | Pass/Fail: [ ]

## Out of Scope

- Automated validation of SCAFFOLD comment format (enforced by code review)
- Persisting flags as project defaults in `.claude/conclave/` config
- Evaluator tuning for single-agent skills
- `--full` flag for skills other than plan-product
- Cross-session eval example analysis

## Performance Targets

<!-- No performance targets — all changes are prompt content modifications with no runtime impact. -->

## Signatures

- **Planning Lead**: Implementation Coordinator (date: 2026-03-27)
- **Plan Skeptic**: Voss Grimthorn, Keeper of the War Table (date: 2026-03-27)

## Amendment Log

<!-- No amendments. -->
