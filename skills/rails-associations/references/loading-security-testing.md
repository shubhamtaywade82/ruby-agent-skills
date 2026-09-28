# Loading, security and tenant isolation, performance, and testing

Reference for the `rails-associations` skill. Load it on demand when a change alters association loading, crosses tenant or authorization boundaries, has capacity impact, or needs association tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Loading and inverse-aware performance

Association traversal is a frequent source of N+1 queries.

Before optimizing:

1. identify the actual traversal path
2. inspect whether inverse recognition removes duplicate loads
3. choose preload/includes/eager_load only for the demonstrated path
4. use strict loading where accidental lazy loading should be prohibited
5. measure query count and object allocation.

Do not solve an N+1 by globally preloading every association.

## Security and tenant isolation

Associations do not authorize access.

Review:

- tenant ownership across both sides
- cross-tenant foreign keys
- polymorphic targets
- through joins
- collection assignment
- direct ID-based association creation
- unscoped association access.

A valid association can still cross a security boundary.

Authorization belongs to rails-security or the application's policy boundary. Database ownership/integrity belongs to rails-database-engineering.

## Performance and capacity

Association design affects:

- query count
- row cardinality
- object allocation
- write amplification
- delete fan-out
- callback execution
- asynchronous job volume.

Measure before changing association shape for performance.

Large collections should use bounded query/batch behavior rather than materializing every associated record. Compose with rails-active-record and rails-performance.

## Testing

Test the relationship contract, not merely that Rails accepts the declaration.

Where applicable test:

- cardinality
- required/optional belongs_to
- foreign-key integrity
- uniqueness for has_one semantics
- collection build/create/add/remove/clear
- through join creation/removal
- polymorphic allowed types
- inverse behavior
- autosave success/failure
- dependent destroy/delete/restrict/nullify
- counter cache and touch behavior
- association callbacks
- tenant/authorization boundaries
- representative loading/N+1 paths.

Prefer behavior tests over brittle assertions on generated method names.
