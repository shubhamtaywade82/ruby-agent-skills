# Rails Best-Practice Review

## Problem
A Rails code-quality analyzer reports findings, or a change needs a systematic Rails architecture review.

## Use when
- performing a Rails quality review
- interpreting rails_best_practices output
- reviewing routes, models, controllers, views, helpers, or migrations
- deciding whether a warning requires a change

## Do not use when
- the task is pure Ruby
- a more specific repository pattern completely covers the concern

## Repository inspection
Inspect Rails/Ruby versions, relevant files, tests, schema/migrations, routes, existing patterns, and rails_best_practices configuration.

## Procedure
1. Inspect the analyzer finding.
2. Map it to the underlying design concern.
3. Check repository conventions and contract.
4. Determine whether it is correctness, maintainability, performance/integrity, outdated, or intentional.
5. Select the smallest justified change.
6. Add/update focused tests.
7. Re-run the analyzer or document why it is not applicable.
8. Inspect the final diff.

## Failure modes
- blindly fixing every warning
- introducing deprecated Rails APIs
- moving logic merely to satisfy a linter
- deleting methods without checking dynamic callers
- adding abstractions without a real responsibility
- suppressing findings without justification

## Testing
Test observable behavior affected by the finding. For route/controller/model changes, use the repository's appropriate request/model/integration coverage.

## Review checklist
- [ ] finding understood
- [ ] modern Rails compatibility checked
- [ ] contract preserved
- [ ] fix justified
- [ ] no unnecessary abstraction
- [ ] tests updated
- [ ] analyzer re-run or exception documented

## Related skills
- rails-best-practices
- rails-architecture
- rails-routing
- rails-controllers
- rails-activerecord
- rails-views
- rails-testing