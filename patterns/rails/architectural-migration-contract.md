---
name: architectural-migration-contract
description: Architectural Migration Contract
family: architecture
---
# Architectural Migration Contract

## Problem
Large architectural rewrites create prolonged dual systems and unclear rollback.

## Use when
Migrating responsibility between modules, engines, services, or data owners.

## Do not use when
A small local refactor with no staged compatibility concern.

## Repository inspection
Inspect old/new paths, traffic/workload, schema ownership, feature flags, rollback, and cleanup conditions.

## Implementation procedure
Use incremental target introduction, bounded migration, compatibility period, verification, cutover, and removal.

## Failure modes
Dual-write divergence, orphaned paths, migration dead ends, irreversible cutover.

## Testing
Test each migration stage and rollback/recovery conditions.

## Review checklist
[ ] stages [ ] compatibility [ ] verification [ ] cutover [ ] cleanup

## Related skills
rails-staff-principal-architecture, rails-release-engineering