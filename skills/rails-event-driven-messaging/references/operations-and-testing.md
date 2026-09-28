# Observability, capacity, security, rolling deployments, and testing

Reference for the `rails-event-driven-messaging` skill. Load it on demand when a change affects message telemetry, broker capacity, consumer authorization, deployment ordering, or messaging tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Message observability

Trace a message across:

`producer -> broker -> consumer -> handler -> dependency`

Record:

- message ID;
- correlation ID;
- causation ID;
- producer/consumer;
- message type/schema version;
- enqueue/publish timestamp;
- processing start/end;
- attempt;
- outcome;
- queue age/lag where available.

Metrics should distinguish:

- publish rate;
- consume rate;
- success/failure;
- retry rate;
- dead-letter count;
- consumer lag;
- handler latency;
- oldest message age.

Avoid logging entire payloads by default.

Use `patterns/rails/message-observability.md`.

## Capacity and backpressure

Messaging moves work; it does not remove capacity constraints.

Model:

`arrival rate -> queue growth -> consumer throughput -> dependency capacity`

Watch for:

- consumer lag;
- hot partitions;
- queue depth;
- database pool exhaustion;
- downstream throttling;
- memory pressure;
- retry amplification.

Use bounded concurrency and backpressure rather than unbounded consumer parallelism.

Use `patterns/rails/broker-capacity.md`.

## Security

Treat messages as untrusted integration input unless the transport/authentication guarantees are explicitly established.

Verify:

- producer/service identity;
- topic/queue permissions;
- payload authenticity/integrity;
- tenant isolation;
- encryption requirements;
- secret handling;
- replay authorization.

Do not treat correlation IDs or message IDs as secrets.

Do not place credentials or bearer tokens in message payloads.

## Rolling deployments

During a rollout:

- old consumers may read new messages;
- new consumers may read old messages;
- replay may execute after the original deployment;
- dead-letter items may outlive the producer code.

Therefore support old/new schema coexistence and keep handlers compatible until old messages are drained or explicitly migrated.

Never deploy a consumer that cannot safely parse messages still present in the queue/log.

## Testing

Test the message boundary rather than only the service object.

Minimum cases:

- valid envelope;
- invalid schema;
- unknown/new optional field;
- incompatible version;
- duplicate message;
- consumer failure before side effect;
- consumer failure after side effect;
- retry exhaustion;
- dead-letter routing;
- replay;
- out-of-order delivery where relevant;
- hot-key/partition behavior where relevant;
- correlation propagation;
- shutdown/restart recovery.

Use fake transports or broker test harnesses where possible. Do not rely on arbitrary sleeps for delivery timing.
