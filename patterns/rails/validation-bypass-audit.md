# Validation Bypass Audit

## Problem
Validation Bypass Audit needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- a model invariant changes and direct/bulk writers exist.

## Do not use when
- bypass APIs are banned without examining actual invariant ownership.

## Repository inspection
- direct/bulk writes;
- imports/admin tools/jobs;
- database constraints;
- repair scripts;
- tests.

## Implementation procedure
1. List write paths.
2. Mark which paths run validation.
3. Identify the authoritative invariant owner.
4. Move critical invariants to the database where needed.
5. Document intentional bypasses.
6. Test bypass paths separately.

## Failure modes
- bulk writes create invalid data;
- only web requests are protected;
- database constraints are missing.

## Testing
- representative bypass writer;
- database rejection;
- intentional maintenance/import path.

## Review checklist
- [ ] all writers considered
- [ ] authority is explicit
- [ ] critical invariants survive bypasses

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
