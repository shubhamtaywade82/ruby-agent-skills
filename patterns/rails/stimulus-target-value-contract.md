---
name: stimulus-target-value-contract
description: Use explicit Stimulus targets and values as a stable controller/view interface.
family: rails
---
# Stimulus Target and Value Contract

## Problem
Controller code relies on scattered selectors and implicit DOM formats.

## Structure
Define named targets and values and validate assumptions at the controller boundary.

## Failure modes
Renamed DOM nodes, missing targets, and implicit string formats.

## Testing
Cover required/missing targets and representative value changes.
