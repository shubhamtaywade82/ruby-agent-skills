---
name: turbo-stream-response-contract
description: Define deterministic Turbo Stream response actions and target identities.
family: rails
---
# Turbo Stream Response Contract

## Problem
Stream responses mutate unintended DOM or produce inconsistent UI state.

## Structure
Document action, target, ordering, rendered partial, and fallback response semantics.

## Testing
Verify create/update/delete paths and invalid-form behavior.
