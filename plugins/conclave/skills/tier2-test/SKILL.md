---
name: tier2-test
description: >
  Phase 0 PoC: Minimal Tier 2 composite skill that invokes tier1-test
  via the Skill tool, then verifies the artifact was produced.
tier: 2
chains:
  - tier1-test
type: single-agent
---

# Tier 2 Test Skill (Composite)

You are executing a minimal Tier 2 composite skill for proof-of-concept testing.

## Context Persistence Test

Before invoking the Tier 1 skill, remember this value: **CONTEXT_TOKEN=phoenix-42**

You will check whether you still remember this value after the Tier 1 invocation completes.

## Step 1: Invoke Tier 1 Skill

Use the Skill tool to invoke the tier1-test skill:

```
Skill(skill: "conclave:tier1-test", args: "invoked-by-tier2")
```

Wait for it to complete before proceeding.

## Step 2: Verify Artifact

After tier1-test completes, read the file `docs/research/poc-tier1-output.md`.

Check:
1. Does the file exist?
2. Does the frontmatter contain `tier1_executed: true`?
3. Does the body contain `Arguments received: invoked-by-tier2`?

## Step 3: Verify Context Persistence

Do you still remember the CONTEXT_TOKEN from before the Tier 1 invocation?

## Step 4: Report Results

Output a structured report to the user:

```
PHASE 0 PoC RESULTS
====================
Test 1 - Skill tool invocation:    [PASS/FAIL] - Could tier2-test invoke tier1-test via Skill tool?
Test 2 - Artifact produced:        [PASS/FAIL] - Does docs/research/poc-tier1-output.md exist with correct content?
Test 3 - Context persistence:      [PASS/FAIL] - Is CONTEXT_TOKEN still "phoenix-42"?
Test 4 - Arguments passed:         [PASS/FAIL] - Did tier1-test receive "invoked-by-tier2"?

OVERALL: [PASS/FAIL]
```

That is your entire job. Do not do anything else.
