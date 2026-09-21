---
name: validation-boundary
description: Use when deciding where a Rails invariant should be enforced across model validation and database integrity.
family: rails
---

# Validation Boundary Contract

## Problem
Validation Boundary Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- a rule could live in a model, controller, service, or database;
- a change risks duplicating one invariant across layers.

## Do not use when
- the real boundary is authorization, transaction orchestration, or external integration;
- the database already owns an authoritative invariant.

## Repository inspection
- model/object;
- schema constraints and indexes;
- request/form/API boundary;
- service/job/event entry points;
- existing tests.

## Implementation procedure
1. State the invariant in domain terms.
2. Identify who must enforce it under concurrency and alternate writers.
3. Keep user-facing model validation where appropriate.
4. Add database constraints for authoritative cross-writer invariants.
5. Remove conflicting duplicate rules.
6. Test every reachable enforcement boundary.

## Failure modes
- validation becomes authorization;
- validation disagrees with database semantics;
- alternate writers bypass the only protection.

## Testing
- valid and invalid model state;
- database conflict behavior;
- bypass writer behavior where relevant.

## Review checklist
- [ ] invariant owner is named
- [ ] database enforcement is evaluated
- [ ] authorization is separate
- [ ] alternate writers are considered

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
