---
name: mailer-delivery-semantics
description: Choose and verify synchronous versus asynchronous Rails email delivery with transaction, retry, duplicate, and queue semantics.
family: rails
---

# Mailer Delivery Semantics

## Problem

Changing deliver_now to deliver_later changes latency, failure timing, queue behavior, and duplicate-delivery semantics.

## Use when

- selecting delivery mode;
- changing queue or retry behavior;
- diagnosing delayed/duplicated mail.

## Do not use when

- email is not part of the execution contract.

## Repository inspection

Inspect Active Job adapter, queue policy, retry/discard rules, transaction boundaries, mail delivery jobs, and existing idempotency conventions.

## Implementation procedure

1. Define whether delivery may be delayed.
2. Define the business event that requires the mail.
3. Verify committed-state timing.
4. Select deliver_now or deliver_later.
5. Define retryable/permanent/unknown outcomes.
6. Define duplicate handling.
7. Verify queue capacity and observability.

## Failure modes

- synchronous provider latency in request path;
- asynchronous delivery before commit;
- duplicate delivery after ambiguous provider failure;
- unbounded retry amplification;
- incorrect queue selection.

## Testing

Assert delivery mode, enqueued job arguments, transaction behavior, failure classification, and duplicate-safe business semantics.

## Review checklist

- [ ] latency contract
- [ ] transaction semantics
- [ ] queue semantics
- [ ] retry classification
- [ ] duplicate/unknown outcome handling
- [ ] tests

## Related skills

rails-action-mailer, rails-active-job, rails-reliability-engineering, rails-distributed-systems
