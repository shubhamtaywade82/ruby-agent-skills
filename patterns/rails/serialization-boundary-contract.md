---
name: serialization-boundary-contract
description: Serialization Boundary Contract
family: rails
---
# Serialization Boundary Contract

## Problem
Internal model shape becomes an accidental external contract when serialization ownership is implicit.

## Use when
Adding or changing a serialized representation consumed outside the owning object.

## Do not use when
Purely internal object inspection with no transport or persistence contract.

## Repository inspection
Inspect consumers, serializer or presenter code, response tests, fixtures, and model attributes.

## Implementation procedure
Define owner, schema, allowed fields, null semantics, compatibility policy, and transport boundary explicitly.

## Failure modes
Database schema leaks, accidental fields, ambiguous ownership, incompatible changes.

## Testing
Assert exact contract shape at the boundary.

## Review checklist
[ ] owner [ ] schema [ ] sensitive fields [ ] compatibility

## Related skills
rails-serialization-globalid-engineering, rails-api-integration