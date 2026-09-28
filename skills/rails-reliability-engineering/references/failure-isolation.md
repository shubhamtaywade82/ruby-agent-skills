# Circuit breakers, bulkheads, load shedding, degradation, retries, and cascading failure

Reference for the `rails-reliability-engineering` skill. Load it on demand when a change adds or alters circuit breakers, bulkheads, admission control, degraded modes, retries, or timeouts. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Circuit breakers

A circuit breaker controls repeated calls to an unhealthy dependency.

Typical states:

`closed -> open -> half-open -> closed/open`

Define:

- failure classification;
- rolling observation window;
- threshold or failure ratio;
- open duration;
- half-open probe policy;
- excluded failures;
- fallback behavior;
- metrics.

Do not count validation/authorization failures as dependency health failures unless they represent actual downstream unavailability.

A circuit breaker is not a timeout, retry policy, cache, or load balancer.

Do not put one global breaker around unrelated dependencies or tenants unless they truly share a failure domain.

Use `patterns/rails/circuit-breaker.md`.

## Bulkheads

A bulkhead isolates resources so one failing workload cannot exhaust shared capacity.

Possible boundaries:

- thread/executor pool;
- job queue;
- database connection pool;
- external client connection pool;
- per-tenant/per-provider concurrency;
- memory/work queue.

Define:

- isolated capacity;
- queue/rejection behavior;
- ownership;
- saturation metrics;
- recovery.

Do not create many tiny pools without evidence; fragmentation can reduce useful capacity.

Use `patterns/rails/bulkhead-isolation.md`.

## Load shedding and admission control

When demand exceeds safe capacity, controlled rejection can preserve critical work.

Prefer:

- explicit rate limits;
- bounded queues;
- concurrency caps;
- priority queues;
- early rejection;
- per-tenant quotas;
- degraded responses.

Define which work is protected and which may be dropped.

A system that accepts unlimited work and fails later is not necessarily more reliable.

Never silently drop durable business operations without a recovery/audit contract.

Use `patterns/rails/load-shedding.md`.

## Graceful degradation

Design a lower-cost behavior before failure occurs.

Examples:

- stale-but-valid cache;
- omit optional enrichment;
- read-only mode;
- reduced result set;
- asynchronous completion;
- fallback provider;
- feature flag disablement.

For every fallback define:

- freshness;
- correctness boundary;
- user-visible semantics;
- security/authorization implications;
- observability;
- exit/recovery condition.

Never return stale or fallback data where the contract requires authoritative current state.

Use `patterns/rails/graceful-degradation.md`.

## Retry and timeout coordination

Retries can amplify an incident.

Model the whole chain:

`caller timeout x attempts x concurrency x downstream fan-out`

Define one coherent retry budget across:

- HTTP client;
- Active Job;
- broker redelivery;
- saga step;
- operator replay.

Use exponential backoff/jitter where appropriate.

Avoid stacking independent retries that turn one dependency failure into a traffic storm.

Coordinate with `rails-api-integration`, `rails-active-job`, and `rails-event-driven-messaging`.

## Cascading failure analysis

For an incident, trace:

`resource saturation -> queueing -> timeout -> retry -> more load -> further saturation`

Look for:

- shared thread pools;
- shared database pools;
- retry synchronization;
- long timeouts;
- unbounded queues;
- dependency fan-out;
- cache stampedes;
- circuit breakers that fail too late;
- load shedding that protects low-priority traffic instead of critical work.

Fix the positive feedback loop, not only the first symptom.
