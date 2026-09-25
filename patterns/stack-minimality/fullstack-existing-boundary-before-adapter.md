---
name: fullstack-existing-boundary-before-adapter
description: Fullstack Existing Boundary Before Adapter
family: stack-minimality
---
# Fullstack Existing Boundary Before Adapter

## Problem
A new adapter can duplicate a boundary the application already owns.

## Use when
Connecting React to Rails or adding an external integration.

## Do not use when
Two incompatible external contracts genuinely need isolation or the adapter has multiple implementations.

## Repository inspection
Inspect the relevant application boundary, existing implementations, callers, dependencies, and runtime constraints before introducing a new layer.

## Implementation procedure
Trace the React client, Rails controller/service/serializer, error contract, and external provider. Extend existing boundaries when compatible.

## Failure modes
Adapter-over-adapter stacks, duplicate error normalization, and drifting client/server contracts.

## Testing
Test the API contract and the real translation boundary.

## Review checklist
[ ] repository evidence checked [ ] smallest valid boundary chosen [ ] required guarantees preserved

## Related skills
rails-api-integration, react-data-fetching, typescript-runtime-contracts, stack-minimality
