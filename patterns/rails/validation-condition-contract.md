# Conditional Validation Contract

## Problem
Conditional Validation Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- a validation is valid only for a clear predicate.

## Do not use when
- the predicate is a workflow or authorization decision;
- interacting if/unless branches make the model unreadable.

## Repository inspection
- predicate methods;
- state attributes;
- if/unless/allow_nil/allow_blank;
- context interaction;
- truth-table tests.

## Implementation procedure
1. Use a named predicate for non-trivial conditions.
2. Separate conditions from permissions.
3. Define nil/blank behavior independently.
4. Test all branches and boundary transitions.

## Failure modes
- validation silently disappears because a predicate changed;
- blank/nil skips more rules than intended;
- condition encodes authorization.

## Testing
- every condition branch;
- nil/blank;
- create/update/context combinations.

## Review checklist
- [ ] predicate is focused
- [ ] truth table is covered
- [ ] nil/blank semantics are intentional

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
