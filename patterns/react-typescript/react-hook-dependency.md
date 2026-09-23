---
name: react-hook-dependency
description: Treat hook dependencies as part of the correctness contract.
family: react-typescript
---

# React Hook Dependency

## Problem
A hook captures props, state, callbacks, or external values across renders.

## Use when
The repository uses a different well-defined hook abstraction that owns dependency semantics.

## Do not use when
Do not activate simply when The repository uses a different well-defined hook abstraction that owns dependency semantics. 

## Repository inspection
Inspect referenced values, stable identities, cleanup, and lint configuration.

## Implementation procedure
List captured values, stabilize only necessary identities, and keep dependencies truthful.

## Failure modes
Suppressing dependency lint, accidental infinite loops, and stale closures.

## Testing
Test rerender sequences and changing dependencies.

## Review checklist
Would the hook still be correct if every dependency changed on the next render?

## Related skills
react-state-effects
