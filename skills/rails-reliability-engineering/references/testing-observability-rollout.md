# Resilience testing, observability, and rollout safety

Reference for the `rails-reliability-engineering` skill. Load it on demand when adding resilience tests or fault injection, reliability telemetry, or rollout guards. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Resilience testing

Test realistic failures at the boundary that owns the failure mode.

Examples:

- dependency timeout/outage;
- broker lag;
- database saturation;
- exhausted worker pool;
- cache unavailable;
- malformed dependency response;
- retry storm;
- stale replica;
- process restart during work;
- failed restore/recovery step.

Prefer deterministic fault injection and bounded scenarios.

A resilience test should specify:

`fault -> expected containment -> expected user behavior -> recovery -> verification`

Do not perform uncontrolled destructive experiments against production without an explicit, authorized experiment contract.

Use `patterns/rails/resilience-testing.md`.

## Observability

Reliability requires four classes of evidence:

1. user-impact SLIs;
2. saturation/capacity;
3. dependency/failure signals;
4. recovery state.

Track safe, low-cardinality dimensions such as operation, dependency, status class, queue, tenant class, and region where applicable.

Propagate correlation across synchronous and asynchronous boundaries.

Do not page on a raw exception count without relating it to user impact or a known operational failure mode.

Compose with `rails-observability`.

## Change and rollout safety

Reliability changes can themselves create incidents.

For breakers, bulkheads, load shedding, and fallbacks verify:

- default behavior;
- activation thresholds;
- failure mode;
- rollback/disable path;
- metric visibility;
- configuration validation.

For rolling deployment, maintain old/new compatibility for queued jobs, messages, APIs, and durable state.

Use feature flags or staged rollout where the repository supports them.
