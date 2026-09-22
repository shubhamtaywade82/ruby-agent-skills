---
name: maintenance-lock-contract
description: Maintenance Lock Contract
family: rails
---
# Maintenance Lock Contract

## Problem
Concurrent operators or schedulers can execute the same mutation simultaneously.

## Use when
Exclusive maintenance tasks or recurring jobs that cannot safely overlap.

## Do not use when
A fully idempotent operation designed for unrestricted concurrency.

## Repository inspection
Inspect existing advisory locks, Redis/DB locks, leases, job concurrency, and deployment topology.

## Implementation procedure
Choose the repository's established lock mechanism; define owner identity, timeout, and stale-lock recovery.

## Failure modes
Double execution, deadlocks, permanent locks, or false ownership.

## Testing
Test lock acquisition, contention, timeout, and cleanup.

## Review checklist
[ ] lock mechanism [ ] owner [ ] timeout [ ] stale recovery

## Related skills
rails-operational-tasks-maintenance, rails-reliability-engineering