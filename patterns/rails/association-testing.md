---
name: association-testing
description: Use when testing Active Record association cardinality, mutation, lifecycle, inverse, through, polymorphic, or dependent behavior.
family: testing
---

# Association Testing

## Problem

Association declarations can pass basic tests while relationship lifecycle, join mutation, dependency, or authorization semantics remain untested.

## Use when

- changing an association
- changing dependent behavior
- adding through/polymorphic relationships
- changing inverse/autosave behavior.

## Do not use when

- the task is solely a schema migration with no association behavior change.

## Repository inspection

Inspect existing association specs, factories/fixtures, foreign-key constraints, and integration consumers.

## Implementation procedure

1. State the relationship contract.
2. Test both directions when bidirectional.
3. Test mutation and deletion semantics.
4. Add security/tenant cases where relationships cross boundaries.
5. Add query/loading coverage only where it is contractual.

## Failure modes

- testing only that methods exist
- omitting deletion or join behavior
- relying on fixtures that cannot represent invalid relationships
- asserting implementation-specific internals instead of behavior.

## Testing

Cover applicable cardinality, mutation, inverse, through, polymorphic, autosave, dependent, counter/touch, and loading behavior.

## Review checklist

- [ ] relationship contract is tested
- [ ] negative cases exist
- [ ] lifecycle behavior is tested
- [ ] security boundaries are covered
- [ ] tests are deterministic

## Related skills

rails-associations, rails-active-record, rails-database-engineering, rails-security, rails-test-engineering
