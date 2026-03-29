---
checkpoint: complete
task: 3
agent: frontend-eng
date: 2026-02-19
---

# plan-hiring: Frontend Eng Progress

## Task Summary

Extended `normalize_skeptic_names()` in
`scripts/validators/skill-shared-content.sh` with 4 new sed expressions for the
Bias Skeptic and Fit Skeptic types introduced by the plan-hiring skill.

## Changes Made

**File:** `scripts/validators/skill-shared-content.sh`

Added 4 new sed expressions to the `normalize_skeptic_names()` function (lines
65-68):

```bash
-e 's/bias-skeptic/SKEPTIC_NAME/g' \
-e 's/Bias Skeptic/SKEPTIC_NAME/g' \
-e 's/fit-skeptic/SKEPTIC_NAME/g' \
-e 's/Fit Skeptic/SKEPTIC_NAME/g'
```

These follow the exact same pattern as the existing entries (slug form and
display name form), appended after the `Strategy Skeptic` entries.

## Status

Complete. No test failures expected — this is a purely additive change that
extends normalization coverage without modifying existing behavior.
