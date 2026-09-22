---
name: active-storage-purge
description: Design safe Active Storage deletion, purge, and unattached-blob cleanup with bounded retention and reconciliation.
family: rails
---

# Active Storage Purge

## Problem

Deleting an attachment relationship and deleting the physical object are separate lifecycle operations.

## Use when

- removing files;
- implementing purge jobs;
- cleaning unattached direct uploads;
- changing retention behavior.

## Do not use when

- files must be retained permanently by policy and no cleanup is needed.

## Repository inspection

Inspect domain deletion semantics, purge jobs, Active Job queues, retention requirements, staged-upload workflows, object lifecycle policies, and metrics.

## Implementation procedure

1. Define retention policy.
2. Separate logical removal from physical purge.
3. Choose synchronous versus asynchronous cleanup.
4. Bound purge concurrency.
5. Define orphan-age threshold.
6. Add reconciliation metrics.
7. Test deletion failure and retry behavior.

## Failure modes

- destructive purge before business retention is satisfied;
- purging legitimate staged uploads;
- unbounded purge jobs;
- assuming object deletion succeeded because the database row disappeared;
- no reconciliation for storage drift.

## Testing

Test attachment removal, purge, storage failure, retry, orphan thresholds, and safe no-op behavior.

## Review checklist

- [ ] retention
- [ ] logical vs physical delete
- [ ] async semantics
- [ ] orphan threshold
- [ ] reconciliation
- [ ] failure handling

## Related skills

rails-active-storage, rails-active-job, rails-reliability-engineering, rails-database-engineering
