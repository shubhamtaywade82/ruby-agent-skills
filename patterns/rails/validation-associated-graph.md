# Associated Validation Graph Contract

## Problem
Associated Validation Graph Contract needs an explicit contract so validation does not drift between model logic, database integrity, and consumers.

## Use when
- associated records must be valid as part of an owned write.

## Do not use when
- the parent should not recursively validate an unbounded graph;
- unrelated associations are not part of the contract.

## Repository inspection
- association declarations;
- inverse/autosave/nested attributes;
- graph size;
- transaction behavior.

## Implementation procedure
1. Identify exact owned associated records.
2. Keep the graph narrow.
3. Coordinate inverse/autosave semantics.
4. Define parent failure behavior.
5. Avoid duplicate validation passes.
6. Test success and failure.

## Failure modes
- recursive validation loops;
- unrelated children block saves;
- partial persistence is misunderstood.

## Testing
- parent/child valid;
- child invalid;
- multiple failures;
- nested/autosave rollback behavior.

## Review checklist
- [ ] graph is bounded
- [ ] ownership is explicit
- [ ] failure propagation is tested

## Related skills
- rails-validations
- rails-active-record
- rails-database-engineering
- rails-testing
