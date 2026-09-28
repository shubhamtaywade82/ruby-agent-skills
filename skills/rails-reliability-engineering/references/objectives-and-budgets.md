# Reliability objectives, error budgets, and dependency criticality

Reference for the `rails-reliability-engineering` skill. Load it on demand when a change defines or alters SLIs/SLOs, error budget policy, or dependency criticality. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Reliability objectives

Reliability is a property of a user-visible contract.

Define the critical journey first:

`request -> application work -> dependencies -> durable state -> response`

Possible SLIs:

- availability/success rate;
- latency percentile;
- freshness/staleness;
- queue age/processing delay;
- correctness/failed business operations;
- durability/recovery success;
- dependency success where it affects the user journey.

An SLO states the target over a defined window.

An error budget is the allowed failure implied by that target.

Do not treat every technical metric as an SLO. A metric becomes an SLI when it measures an aspect of the service contract.

Avoid arbitrary ultra-high targets. The target must reflect user impact, business criticality, architecture, and operating cost.

Use `patterns/rails/slo-error-budget.md`.

## Error budgets and operational decisions

Use the error budget to change engineering behavior.

When budget consumption is high:

- reduce risky releases;
- prioritize reliability work;
- investigate dominant failure modes;
- avoid hiding failures by widening timeouts/retries;
- confirm whether the SLO or SLI is measuring the right user impact.

Do not turn the error budget into a punitive score. It is a decision mechanism for balancing feature velocity and reliability.

Use burn-rate evidence when alerting on rapid SLO consumption. Avoid alerts on every single error.

## Dependency criticality

Classify dependencies:

- critical: user journey cannot complete correctly without it;
- degradable: reduced functionality is acceptable;
- optional: feature can be omitted;
- asynchronous: failure can be absorbed temporarily.

For each dependency define:

- timeout;
- retryability;
- concurrency limit;
- fallback/degradation;
- circuit behavior;
- observability;
- operator ownership.

Do not classify a dependency as optional merely because the API call is technically not required.

Use `patterns/rails/dependency-failure-boundary.md`.
