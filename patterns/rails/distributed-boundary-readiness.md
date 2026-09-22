---
name: distributed-boundary-readiness
description: Distributed Boundary Readiness Contract
family: architecture
---
# Distributed Boundary Readiness Contract

## Problem
Extracting a component into another process without operational readiness creates a distributed monolith.

## Use when
Considering microservice or independent-process extraction.

## Do not use when
The workload is comfortably within an in-process boundary and no deployment/failure isolation need exists.

## Repository inspection
Inspect data ownership, API/message contracts, latency budget, retries, observability, deployment, secrets, failure recovery, and compatibility.

## Implementation procedure
Define stable contract, independent ownership, failure model, idempotency, rollout, and data migration before extraction.

## Failure modes
Partial failure, synchronous coupling, distributed transaction assumptions, incompatible deploys.

## Testing
Test duplicate/delayed failures, compatibility, recovery, and deployment sequencing before extraction.

## Review checklist
[ ] contract [ ] data owner [ ] failure model [ ] rollout [ ] recovery

## Related skills
rails-staff-principal-architecture, rails-distributed-systems, rails-release-engineering