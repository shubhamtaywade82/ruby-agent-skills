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

## Do not use when
A normal HTML response already expresses the required interaction.

## Repository inspection
Inspect stream templates, target IDs, controller formats, partials, and fallback responses.

## Implementation procedure
Define action and target, render the smallest partial, preserve status semantics, and keep target identity stable.

## Failure modes
Wrong target, malformed stream, duplicate mutation, and missing fallback behavior.

## Testing
Test each stream action and invalid-form path.

## Review checklist
Action, target, partial, status, and fallback are deterministic.

## Related skills
rails-hotwire, rails-action-controller, rails-action-view

## Use when

Use this pattern when the described Hotwire interaction is an explicit part of the page contract and its lifecycle needs dedicated guidance.
