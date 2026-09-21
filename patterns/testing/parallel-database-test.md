---
name: parallel-database-test
description: Configure concurrent database tests without accidental transaction blocking or connection exhaustion.
family: testing
---

# Parallel Database Test

## Problem
Concurrent test transactions can conflict with Rails' implicit transactional test wrapper and database capacity.

## Use when
Testing parallel transactions, locks, race conditions, or thread-based database behavior.

## Procedure
1. Determine whether independent DB transactions are required.
2. Disable transactional tests only for the affected test case when necessary.
3. Clean up data explicitly.
4. Ensure enough DB connections for concurrent workers.
5. Use deterministic coordination primitives instead of sleeps.
6. Run the test under both the intended concurrency configuration and normal serial mode.

## Failure modes
- disabling transactional tests globally
- deadlocking on the outer test transaction
- leaking created data
- exceeding test DB connection capacity

## Testing
Exercise conflicting transactions and verify final database invariants.

## Review checklist
- transactional wrapper understood
- cleanup explicit when disabled
- connection demand understood
- synchronization deterministic
