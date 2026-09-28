# Fan-out, backpressure, capacity, adapters, and failure behavior

Reference for the `rails-action-cable` skill. Load it on demand when a change alters broadcast fan-out, connection counts, adapter topology, or failure handling. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Broadcast fan-out

A broadcast may reach many active subscribers.

Evaluate:

- subscriber count;
- payload size;
- serialization cost;
- frequency;
- per-user versus per-tenant fan-out;
- hot channels;
- Redis/pub/sub bandwidth;
- application server CPU;
- client rendering cost.

Do not broadcast a full object graph to every subscriber.

Prefer coarse-grained state-change messages when clients can refetch authoritative data.

For high-fanout updates, consider:

- per-resource streams;
- per-user streams;
- batched updates;
- client-side coalescing;
- lower update frequency;
- snapshot plus delta model.

## Backpressure and overload

Action Cable does not remove downstream capacity limits.

Review:

- connections per process;
- subscriptions per connection;
- messages per second;
- bytes per second;
- Redis/pub/sub throughput;
- serialization CPU;
- memory per connection;
- browser/client rendering;
- network egress.

Bound high-frequency producers.

Do not add unbounded broadcast loops or per-record broadcast callbacks without measuring fan-out.

A system can fail even when HTTP latency remains healthy because persistent WebSocket connections consume memory and pub/sub bandwidth.

Coordinate with `rails-production-runtime`, `rails-performance`, `ruby-performance`, `ruby-concurrency`, and `rails-reliability-engineering`.

## Realtime capacity model

At minimum estimate:

```text
active_connections
x average subscriptions
x messages/subscription/second
x average payload bytes
```

Also account for:

- connection memory;
- channel object/state;
- Redis/pubsub buffers;
- serializer CPU;
- TLS/network overhead;
- burst rates;
- reconnect storms.

Do not use HTTP request concurrency as a substitute for WebSocket capacity planning.

## Redis and adapter topology

Inspect the subscription adapter and Redis deployment.

Define:

- namespace/key strategy;
- environment isolation;
- connection limits;
- timeout behavior;
- retry policy;
- failure mode;
- memory/eviction policy;
- high-availability topology;
- observability.

Do not share production and non-production pub/sub namespaces.

Do not treat Redis pub/sub as a durable message store.

For critical state, keep authoritative data in the database/event system rather than Redis broadcast history.

## Failure behavior

Define what happens when realtime infrastructure fails.

Possible strategies:

- continue authoritative HTTP/API operation and degrade live updates;
- queue or persist a notification for later retrieval;
- require client reconnect/refetch;
- disable a non-critical realtime feature;
- fail the user action when realtime acknowledgement is part of the business contract.

The correct fallback depends on business semantics.

Do not make a core database transaction fail solely because an optional realtime broadcast is unavailable unless the contract explicitly requires atomic realtime acknowledgement.

Do not silently claim realtime delivery succeeded because the broadcast call returned without raising.
