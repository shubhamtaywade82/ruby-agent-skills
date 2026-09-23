---
name: react-context-scope
description: Limit context to genuinely shared cross-cutting state.
family: react-typescript
---

# React Context Scope

## Problem
Many distant descendants need the same stable dependency and prop flow is materially noisy.

## Use when
Only one or two nearby layers need the value.

## Do not use when
Do not activate simply when Only one or two nearby layers need the value. 

## Repository inspection
Inspect provider nesting, update frequency, and consumer count.

## Implementation procedure
Scope the provider narrowly, keep the value stable where useful, and preserve explicit ownership.

## Failure modes
Global context for server data, mutable event buses, and giant all-purpose providers.

## Testing
Test provider absence, default behavior, updates, and isolation between providers.

## Review checklist
Does context solve reachability rather than conceal architecture?

## Related skills
react-state-effects,react-architecture
