# Review Checklist

Use this as a depth-raising prompt, not a mechanical requirement to discuss every item on every PR. Concentrate on the categories the change actually touches.

## How to use this checklist

- Apply it per category; a model-only change may not need a database review.
- Use it to raise scrutiny, not manufacture findings.
- Re-read it periodically until questions become review habits.

## Specification and architecture

- [ ] The PR/file satisfies every relevant acceptance criterion.
- [ ] All changed public interfaces and callers have been considered.
- [ ] The change does not introduce unrelated scope or break compatibility.

## Ruby and Rails correctness

- [ ] Nil, empty, invalid, and boundary cases have been considered where relevant.
- [ ] Model, controller, service, and job responsibilities are correctly placed.
- [ ] Exception handling preserves useful failure semantics.

## Database and transactions

- [ ] Durable invariants are enforced at the correct authoritative boundary.
- [ ] Concurrent writes cannot bypass critical uniqueness or consistency rules.
- [ ] Migrations, indexes, callbacks, and bulk operations preserve intended semantics during rolling deployment.

## Security and authorization

- [ ] Every affected resource access enforces the appropriate authorization.
- [ ] Tenant scope comes from a trusted source.
- [ ] Untrusted input, HTML, SQL, URLs, uploads, and secrets are handled safely.

## Tests and verification

- [ ] Tests assert observable behavior, not only implementation details.
- [ ] Negative cases, failure paths, and regressions are covered where relevant.
- [ ] Only checks that actually ran are reported as verified.

## Reliability and performance

- [ ] Retries, timeouts, duplicate events, and partial failures are safe where applicable.
- [ ] Queries and loading behavior fit the expected workload.
- [ ] Logging helps diagnosis without exposing sensitive data.

## Client and delivery contracts

- [ ] Rails responses and frontend expectations remain compatible.
- [ ] Client error states and authorization behavior are correct where applicable.
- [ ] Dependency, CI, build, release, and deployment changes preserve security and rollback safety.

## Maintainability

- [ ] Names, responsibilities, and abstractions clarify the implementation.
- [ ] New dependencies and flexibility have a concrete justification.
- [ ] No unnecessary code has been added or important guarantees removed.

## The seven questions that make the difference

| Dimension | Question |
|---|---|
| Behavior | What exact input or state transition would expose a defect? |
| Architecture | Which component owns this invariant, and can another execution path bypass it? |
| Persistence | Does the database enforce the invariant under concurrent writes, not just validation? |
| Testing | If the implementation were subtly wrong, what test should fail? |
| Security | Which actor controls this input, and what happens if they deliberately misuse it? |
| Operations | What happens during a timeout, retry, partial failure, rolling deployment, or duplicate event? |
| Simplicity | Is the abstraction solving a demonstrated problem, or a hypothetical future requirement? |

## Calibration

Raise review depth for authentication/authorization, tenant isolation, migrations and data changes, public APIs, background jobs, external integrations, concurrency, and deployment infrastructure. Apply lighter scrutiny to documentation-only changes and cosmetic refactors, while still checking their real scope.
