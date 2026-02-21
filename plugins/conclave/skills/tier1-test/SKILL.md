---
name: tier1-test
description: >
  Phase 0 PoC: Minimal Tier 1 skill that produces a test artifact.
  Used to validate Tier 2 -> Tier 1 invocation via the Skill tool.
argument-hint: "[text to pass through]"
tier: 1
type: single-agent
---

# Tier 1 Test Skill

You are executing a minimal Tier 1 skill for proof-of-concept testing.

## Setup

No setup required. This is a minimal test skill.

## Determine Mode

Always run in default mode. Ignore any mode flags.

## Instructions

1. Note the current timestamp.
2. Write a test artifact to `docs/research/poc-tier1-output.md` with the following content:

```markdown
---
type: "research-findings"
topic: "poc-test"
generated: "{YYYY-MM-DD}"
status: "complete"
tier1_executed: true
---

# PoC Tier 1 Output

This artifact was produced by the tier1-test skill.

- Timestamp: {current timestamp}
- Arguments received: $ARGUMENTS
- Skill name: tier1-test
- Status: success
```

3. After writing the file, output to the user:

```
TIER1-TEST COMPLETE
Artifact written: docs/research/poc-tier1-output.md
Arguments received: $ARGUMENTS
```

That is your entire job. Do not do anything else.
