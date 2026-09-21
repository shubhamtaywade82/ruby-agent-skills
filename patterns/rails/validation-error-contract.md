# Validation Error Contract

## Problem
Validation Error Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- errors cross UI, API, service, job, or logging boundaries.

## Do not use when
- human-readable prose is treated as an undocumented machine protocol;
- sensitive internal details are exposed.

## Repository inspection
- errors usage;
- API serializers;
- forms;
- locale files;
- tests/client consumers.

## Implementation procedure
1. Identify consumer contract.
2. Preserve stable attribute/type/detail identity.
3. Localize at presentation boundaries.
4. Avoid coupling clients to prose.
5. Add regression tests for the shape.

## Failure modes
- wording changes break clients;
- base errors are serialized incorrectly;
- sensitive information leaks.

## Testing
- attribute/type/details;
- full-message rendering when needed;
- API JSON;
- localization.

## Review checklist
- [ ] machine identity is stable
- [ ] presentation is separate
- [ ] no sensitive data leaks

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
