# Asynchronous Workflows and Reliability Review

Use when code touches Active Job, queue workers, retries, external APIs, caches, events, distributed operations, or recovery. Compose with the owning Active Job, API integration, messaging, distributed-systems, reliability, database, and observability skills.

## Idempotency and duplicate delivery

A retry can repeat a side effect even if the first attempt succeeded remotely but timed out before the caller observed success. Check whether the effect can happen twice and how the system identifies the operation durably.

```ruby
# Potential duplicate charge if the provider succeeds but the job fails before update!.
PaymentService.charge(amount: order.total, token: order.user.payment_token)
order.update!(status: :paid)
```

An in-memory/status guard alone may not be race-safe under concurrent workers. Examine stable idempotency keys, provider semantics, database state transitions, row locks, deduplication records, and transaction boundaries. Do not recommend one generic mechanism without checking the existing contract.

## Retries and timeouts

- Are transient and permanent failures distinguished?
- Are retries bounded, delayed appropriately, and observable?
- Could a timeout hide a successful side effect?
- Is a retry safe after partial work?
- Can malformed or poison messages loop indefinitely?
- Is the retry budget compatible with provider limits and downstream capacity?

## Transactions and message ordering

Check that durable state and outbox/inbox/deduplication records are committed in the intended order. An acknowledgement before durable commit can lose work; publishing before a transaction commits can expose an event for data that later rolls back. Review ordering keys, replay behavior, schema compatibility, and duplicate event semantics.

## Caching

Review cache identity, tenant/user dimensions, invalidation, staleness assumptions, stampede control, expiration, and behavior when the cache is unavailable. A cache hit must not bypass authorization or leak another tenant's result.

## Observability and recovery

Check whether important failures have enough safe context for diagnosis: correlation identifiers, operation/event ID, actor/tenant context, attempts, status transitions, and bounded error summaries. Never log credentials or sensitive payloads. Verify that recovery/replay avoids repeating non-idempotent side effects.

## Verification

Use deterministic tests with controlled time and scripted external boundaries. Test duplicate delivery, retry after partial success, timeout after a remote effect, permanent failure, concurrent execution, and recovery when relevant. For concurrency or performance claims, distinguish reasoned risk from measured evidence.
