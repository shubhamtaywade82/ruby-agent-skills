# Defect Catalogue

Use this as a set of investigation prompts. A category is not evidence of a defect; every finding must have a concrete trigger and violated contract.

## Requirements and business logic

- Missing acceptance criteria or partially implemented branches.
- Incorrect state transitions, invalid status combinations, boundary/off-by-one errors.
- Wrong ordering, rounding, units, timezone, currency, or precision.
- Validation applied in the wrong context or silently bypassed.
- Scope creep or behavior that was not requested.

## Ruby and control flow

- Incorrect truthiness or Boolean operator precedence.
- Nil, empty, false, and missing values treated as equivalent when they are not.
- Accidental mutation, aliasing, shared mutable defaults, or lazy Enumerable surprises.
- Incorrect return value, swallowed exception, overly broad rescue, or lost error context.
- Hidden side effects in callbacks, constructors, predicates, or helpers.

## Rails and persistence

- Authorization applied to the UI but not the resource lookup.
- Model uniqueness validation without a durable unique constraint where races matter.
- Bulk update/delete that skips callbacks or audit effects.
- Side effects triggered before transaction commit.
- N+1 queries, unbounded loads, missing pagination, or accidental materialization.
- Unsafe migrations, backfills, index creation, or rolling-deploy incompatibility.

## Tests

- Expected result calculated with the same faulty algorithm as actual result.
- Tests that assert method calls but not externally observable behavior.
- Excessive mocks, missing invalid/failure cases, weak authorization assertions.
- Flaky timing, order dependence, shared state, or hidden external network calls.
- Bug fix without a regression test or without proving the test failed before the fix.

## Security and privacy

- Broken object-level authorization, tenant escape, mass assignment, unsafe SQL/HTML/shell.
- User-controlled URL or redirect reaching sensitive network destinations.
- Unverified webhook signatures, replay, unsafe uploads/deserialization, secrets in logs.
- Credentials or personal data in exceptions, URLs, generated fixtures, or telemetry.

## Async and distributed behavior

- Non-idempotent retries or duplicate delivery creating duplicate side effects.
- Acknowledgement before durable commit, dropped event, unbounded retry, or poison-message loop.
- Timeout handling that assumes a remote operation did not succeed.
- Race conditions, inconsistent locks, incorrect cache identity/invalidation, or stale state.
- Missing recovery path, metrics, correlation, or safe failure behavior.

## Architecture and maintainability

- Logic placed in a component that does not own the invariant.
- Duplicate business rules that drift independently.
- One-use wrapper, generic framework, interface, dependency, or configuration without a concrete need.
- Hard-to-read nested logic, misleading names, excessive Boolean flags, or dead branches.
- Dead code that is not truly unreachable due to reflection, callbacks, routes, autoloading, or public API usage.

## Operations and compatibility

- Untracked dependency/lockfile changes, secrets exposure, inconsistent CI/runtime assumptions.
- Destructive action without approval, backup/recovery strategy, or dry run.
- Release or migration ordering that breaks older and newer application versions.
- Claimed performance or reliability improvement without workload or observed evidence.
