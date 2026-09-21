# Validation Testing Contract

## Problem
Validation Testing Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- validation changes or a regression need durable boundary-level coverage.

## Do not use when
- broad snapshots are the only evidence;
- tests assert internal implementation instead of observable behavior.

## Repository inspection
- test conventions;
- factories/fixtures;
- database constraint helpers;
- API/form contracts.

## Implementation procedure
1. Test the smallest owning boundary.
2. Cover valid, invalid, and boundary cases.
3. Add context/condition cases when relevant.
4. Assert stable error identity.
5. Add database conflict tests for authoritative invariants.

## Failure modes
- only valid? is tested while persistence differs;
- brittle message-only assertions;
- concurrent/database behavior is omitted.

## Testing
- valid/invalid/boundary;
- create/update/context;
- error details;
- database conflict;
- API/form representation.

## Review checklist
- [ ] owning boundary is tested
- [ ] bypass behavior is covered
- [ ] assertions are stable
- [ ] database enforcement is verified when required

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
