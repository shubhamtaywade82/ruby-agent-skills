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
