# Caching and cache stampedes

Reference for the `rails-performance` skill. Load it on demand when a change adds, alters, or invalidates a cache or must control stampedes. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Caching

Caching is a correctness decision as well as a performance decision.

Before adding or changing a cache define:

- key;
- key namespace/version;
- tenant/user/resource identity;
- freshness;
- invalidation;
- expiration;
- serialization;
- storage capacity;
- miss behavior;
- stampede behavior;
- multi-process/distributed semantics;
- failure behavior.

Ask:

> When is this value allowed to be stale?

A cache key must contain every identity dimension required for correctness and tenant isolation.

Do not cache authorization-sensitive or tenant-scoped data with an incomplete key.

Do not introduce a cache solely to hide an unmeasured database/query problem.

## Cache stampede

For expensive values, inspect concurrent misses.

Potential controls include:

- request coalescing;
- distributed locks;
- stale-while-revalidate behavior;
- bounded recomputation;
- prewarming;
- jittered expiration where appropriate.

Choose the simplest mechanism justified by actual contention.

Do not add distributed locking merely because cache stampede is theoretically possible.
