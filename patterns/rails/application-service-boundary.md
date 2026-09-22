---
name: application-service-boundary
description: Application Service Boundary Contract
family: architecture
---
# Application Service Boundary Contract

## Problem
Application services become thin wrappers or giant workflow containers when ownership is not explicit.

## Use when
Extracting a business workflow or orchestration boundary.

## Do not use when
A trivial one-object operation belongs naturally to the existing model/domain object.

## Repository inspection
Inspect controllers, models, policies, jobs, tasks, and existing services.

## Implementation procedure
Make orchestration explicit; keep domain invariants with their owner and authorize at the correct boundary.

## Failure modes
God services, pass-through services, hidden transaction ownership, duplicated authorization.

## Testing
Test orchestration plus domain invariant at their owning boundaries.

## Review checklist
[ ] orchestration [ ] invariant owner [ ] transaction owner [ ] auth boundary

## Related skills
rails-staff-principal-architecture, ruby-service-objects, rails-authorization