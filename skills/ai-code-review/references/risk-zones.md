# Repository Audit Risk Zones

Use risk-based sampling. Inspect the highest-impact boundaries first; do not claim exhaustive coverage when the repository or audit scope is too large.

## 1. Identity and access control
Routes, controllers, policies, admin actions, export/download paths, job entry points, tenant context, authentication/session lifecycle, authorization caches.

## 2. Persistence and data integrity
Models, associations, validations, migrations, schema constraints, indexes, backfills, transaction boundaries, bulk operations, soft deletes, multi-database configuration.

## 3. External and asynchronous boundaries
Jobs, scheduled tasks, provider clients, webhooks, event consumers, retries, timeouts, deduplication, idempotency, file/network/command boundaries.

## 4. Sensitive input/output
Strong parameters, serializer allowlists, HTML safety, SQL composition, redirects, user-controlled URLs, file uploads, deserialization, secret handling, logs and error reports.

## 5. Tests and regression resilience
Tests around critical invariants, authorization, failure paths, job retries, migrations, API compatibility, deterministic time/randomness, integration and request boundaries.

## 6. Architecture and changeability
Ownership of business rules, dependency direction, duplicate logic, public contracts, service boundaries, broad shared abstractions, dynamic dispatch, framework lifecycle hooks.

## 7. Performance and capacity
Hot request paths, query shape and plans, N+1, unbounded scans/collections, large imports/exports, background queues, cache keys/invalidations, connection pools, allocations.

## 8. Delivery and operations
CI/build pipelines, lockfiles and dependency updates, runtime configuration, secrets, release order, zero-downtime changes, readiness, rollback, monitoring and incident recovery.

## Audit sampling rules

- Identify entry points and protected assets before opening random files.
- For a suspected systemic pattern, inspect multiple independent instances before calling it systemic.
- Record files and risk zones sampled, excluded zones, external systems not available, and checks not run.
- Use the owning Ruby/Rails skill as the authoritative contract for a specific boundary.
