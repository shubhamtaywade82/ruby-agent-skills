---
name: zero-downtime-release
description: Coordinate compatible application, schema, worker, and traffic transitions during a rolling deployment.
family: rails
---

# Zero-Downtime Release

## Problem
Multiple application versions and long-lived workers can coexist during deployment.

## Use when
Releasing Rails applications behind rolling or restart-based process management.

## Implementation procedure
1. Identify old/new application overlap.
2. Expand schema first when required.
3. Deploy backward-compatible application code.
4. Restart web processes using the supported restart mode.
5. Update workers only when queued-job compatibility is preserved.
6. Verify readiness before routing traffic.
7. Contract old schema in a later release.
8. Define rollback behavior.

## Failure modes
- new code requires unexpanded schema
- old workers cannot deserialize new job payloads
- phased restart used with incompatible preload or plugin configuration
- rollback points at code that cannot understand current schema

## Testing
Validate intermediate release states and readiness behavior.

## Review checklist
- overlap documented
- schema compatibility proven
- job compatibility proven
- readiness gate exists
- rollback boundary explicit


## Repository inspection

Inspect runtime/version, repository conventions, the owning boundary, neighboring implementations, and applicable tests before applying the pattern.


## Related skills

- rails-testing
- ruby-tdd-refactoring
- rails-architecture
## Do not use when

Do not use when the deployment is single-version, non-rolling, and the schema/process transition has no compatibility overlap.
