---
name: globalid-resolution-failure-contract
description: Global ID Resolution Failure Contract
family: rails
---
# Global ID Resolution Failure Contract

## Problem
Missing records and temporary backend failures require different operational responses.

## Use when
Resolving Global IDs in jobs or distributed workflows.

## Do not use when
A local identity lookup that cannot encounter persistence/backend failure.

## Repository inspection
Inspect locate versus fetch behavior, retry/discard policy, record lifecycle, and backend reliability.

## Implementation procedure
Distinguish malformed IDs, deleted records, and unavailable backends; map each to explicit retry/discard/reconcile behavior.

## Failure modes
Transient outages discarded as permanent failures, deleted records retried forever, generic rescue hides incidents.

## Testing
Test each failure class independently.

## Review checklist
[ ] malformed [ ] not found [ ] unavailable [ ] retry/discard

## Related skills
rails-serialization-globalid-engineering, rails-reliability-engineering, rails-active-job