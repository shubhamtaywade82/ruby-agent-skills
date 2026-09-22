---
name: encrypted-data-migration-contract
description: Encrypted Data Migration Contract
family: rails
---
# Encrypted Data Migration Contract

## Problem
Converting existing plaintext data can create partial encryption, downtime, irreversible loss, or mixed-format ambiguity.

## Use when
Migrating an existing persisted field to or between encrypted formats.

## Do not use when
A brand-new field with no existing data.

## Repository inspection
Inspect row counts, nullability, indexes, write paths, deployment sequencing, backups, and rollback capabilities.

## Implementation procedure
Use expand/transform/verify/cutover sequencing; make the transformation resumable and observable; preserve recovery evidence.

## Failure modes
Partial conversion, dual-write drift, lost plaintext before verification, or rollback impossibility.

## Testing
Test on realistic fixtures and execute a representative migration/verification flow.

## Review checklist
[ ] expand first [ ] transform resumable [ ] verify [ ] recovery evidence [ ] cutover

## Related skills
rails-encryption-credentials-engineering, rails-database-engineering, rails-reliability-engineering