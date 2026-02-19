# plan-sales: Frontend Engineer Checkpoint

**Role:** Frontend Engineer
**Date:** 2026-02-19
**Task:** Modify validator for strategy-skeptic normalization

## Work Completed

### Modified: `scripts/validators/skill-shared-content.sh`

Added 2 new sed expressions to the `normalize_skeptic_names()` function (lines 62-63):

```bash
        -e 's/strategy-skeptic/SKEPTIC_NAME/g' \
        -e 's/Strategy Skeptic/SKEPTIC_NAME/g'
```

The function now handles all 6 skeptic variants (12 sed expressions total):
- product-skeptic / Product Skeptic
- quality-skeptic / Quality Skeptic
- ops-skeptic / Ops Skeptic
- accuracy-skeptic / Accuracy Skeptic
- narrative-skeptic / Narrative Skeptic
- strategy-skeptic / Strategy Skeptic (new)

### Verification

Ran `bash -n scripts/validators/skill-shared-content.sh` — syntax check passed.

## Status

Complete. No blockers. The plan-sales SKILL.md does not yet exist (backend-eng writing in parallel), but the validator is ready to handle it once it lands.
