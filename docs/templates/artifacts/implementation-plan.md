---
type: "implementation-plan"
feature: ""
next_action: "" # set on approval to "/conclave:build-implementation <feature>" or "/conclave:build-product <feature>"
status: "draft" # draft | reviewed | approved | consumed
source_spec: "" # path to technical spec
sprint_contract: "" # optional: path to signed sprint contract
approved_by: ""
created: ""
updated: ""
---

# Implementation Plan: {Feature}

## Overview

<!-- 1-3 sentences: what is being built and the high-level approach -->

## File Changes

| Action | File Path | Description |
| ------ | --------- | ----------- |
| create | ...       | ...         |
| modify | ...       | ...         |

## Interface Definitions

### {Interface Name}

<!-- type signatures, API contracts, etc. -->

## Dependency Order

<!-- What must be built first, second, etc. Directed acyclic graph. -->

1. {Component A} -- no dependencies
2. {Component B} -- depends on A
3. ...

## Test Strategy

| Test Type   | Scope       | Description      |
| ----------- | ----------- | ---------------- |
| unit        | {component} | {what is tested} |
| integration | {feature}   | {what is tested} |
