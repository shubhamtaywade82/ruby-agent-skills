---
name: turbo-morph-identity
description: Preserve stable DOM identity and client state when Turbo morphing or refresh is used.
family: rails
---
# Turbo Morph Identity

## Problem
Morphing unexpectedly resets inputs, dialogs, or Stimulus state.

## Structure
Define stable IDs and explicit boundaries for state that must survive refresh.

## Testing
Assert preservation of focused/input/client state that the feature contract requires.

## Do not use when
A targeted Frame or Stream update is sufficient and morphing adds unnecessary complexity.

## Repository inspection
Inspect stable DOM IDs, form/input state, Stimulus controllers, and Turbo version support.

## Implementation procedure
Identify state that must survive, preserve IDs, define morph boundaries, and verify controller lifecycle behavior.

## Failure modes
Lost focus, reset inputs, duplicated controllers, and unstable target identity.

## Testing
Exercise refresh/morph with representative client state.

## Review checklist
State ownership and DOM identity are explicit.

## Related skills
rails-hotwire, rails-action-view, rails-test-engineering
