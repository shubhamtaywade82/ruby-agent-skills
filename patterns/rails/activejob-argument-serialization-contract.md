---
name: activejob-argument-serialization-contract
description: Active Job Argument Serialization Contract
family: rails
---
# Active Job Argument Serialization Contract

## Problem
Job arguments fail later when queue persistence cannot represent them or when payloads depend on process-local state.

## Use when
Changing job argument types or payload shape.

## Do not use when
A job only accepts documented primitive/container types and no custom serializer is needed.

## Repository inspection
Inspect supported argument types, GlobalID usage, custom serializers, queue adapter, payload limits, and deserialization behavior.

## Implementation procedure
Prefer simple immutable arguments or GlobalID-backed records; keep payloads small and stable across deploys.

## Failure modes
Serialization errors, oversized payloads, version skew, mutable-state bugs.

## Testing
Assert enqueued arguments and execute serialization/deserialization round trips.

## Review checklist
[ ] supported types [ ] payload size [ ] deploy compatibility [ ] round trip

## Related skills
rails-serialization-globalid-engineering, rails-active-job