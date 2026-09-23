---
name: react-state-effects
description: Use for React state ownership, reducers, context, refs, effects, event handling, subscriptions, and lifecycle behavior.
---

# React State and Effects

## Purpose
Model UI state explicitly and use effects primarily for synchronization with external systems.

## Activate when
- adding state hooks or reducers;
- fixing stale closures, effect dependencies, or repeated effects;
- deciding where state should live;
- managing subscriptions, timers, or async synchronization.

## Repository inspection
Inspect state ownership, provider scope, reducer conventions, effect patterns, async cancellation, and existing lifecycle assumptions.

## Decision rules
- Keep derived values derived instead of storing redundant state.
- Prefer event handlers for user-triggered state transitions.
- Use effects for external synchronization and imperative systems.
- Treat effect cleanup as part of correctness.
- Keep context scoped to genuinely cross-cutting data.
- Prefer reducers when transitions are coupled or numerous.
- Avoid effect chains that only transform one React state value into another.

## Implementation procedure
1. Draw the state transition graph.
2. Identify the source of truth.
3. Separate events from synchronization.
4. Add cleanup and cancellation where needed.
5. Audit dependencies against referenced values.
6. Test rapid updates, unmounts, and stale async work.

## Anti-patterns / failure modes
- effects used for pure derivation;
- missing cleanup;
- stale async responses winning races;
- context used as a global event bus;
- dependency suppression used to silence lint.

## Verification
Exercise mount/unmount, repeated updates, race conditions, and user event sequences. Run hooks/component tests plus typecheck and lint.

## Source foundation
- React useEffect: https://react.dev/reference/react/useEffect
- React useState: https://react.dev/reference/react/useState
- React useReducer: https://react.dev/reference/react/useReducer
