---
name: active-storage-boundary
description: Define the ownership, cardinality, lifecycle, and access contract for a Rails Active Storage attachment.
family: rails
---

# Active Storage Boundary

## Problem

An attachment becomes fragile when ownership, storage, and deletion semantics are implicit across models, controllers, jobs, and storage providers.

## Use when

- adding or changing Active Storage attachments;
- deciding one-to-one versus collection semantics;
- changing replacement/deletion behavior.

## Do not use when

- the feature does not use Active Storage.

## Repository inspection

Inspect attachment declarations, domain ownership, tenant rules, validations, storage services, routes, purge jobs, and tests.

## Implementation procedure

1. Identify the domain owner.
2. Define cardinality.
3. Define allowed file contract.
4. Define replacement/additive semantics.
5. Define access authorization.
6. Define retention and purge behavior.
7. Define processing/variant behavior.
8. Test the lifecycle.

## Failure modes

- blob lookup used as authorization;
- ambiguous replacement semantics;
- orphaned blobs;
- deletion without retention review;
- attachment state inconsistent with domain state.

## Testing

Test attach, replace/add, access, remove, purge, and authorization behavior.

## Review checklist

- [ ] owner
- [ ] cardinality
- [ ] authorization
- [ ] validation
- [ ] retention
- [ ] purge semantics

## Related skills

rails-active-storage, rails-security, rails-database-engineering, rails-testing
