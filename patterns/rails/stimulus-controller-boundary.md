---
name: stimulus-controller-boundary
description: Keep a Stimulus controller focused on one browser interaction responsibility.
family: rails
---
# Stimulus Controller Boundary

## Problem
A controller becomes a hidden application service or global coordinator.

## Structure
Own one cohesive browser behavior with explicit actions, targets, values, and lifecycle.

## Testing
Test public behavior and important lifecycle transitions.

## Do not use when
A native HTML mechanism or a single declarative attribute already solves the behavior.

## Repository inspection
Inspect controller registration, related targets/values, lifecycle hooks, and JS tests.

## Implementation procedure
Define one responsibility, explicit inputs, public actions, and bounded external dependencies.

## Failure modes
God controllers, hidden domain logic, global state, and lifecycle leaks.

## Testing
Test public controller behavior and important reconnect/disconnect paths.

## Review checklist
The controller is cohesive and server responsibilities remain server-side.

## Related skills
rails-hotwire, ruby-clean-code, rails-test-engineering

## Use when

Use this pattern when the named behavior is an intentional part of the browser interaction contract.
