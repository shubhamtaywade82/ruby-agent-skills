# Concurrency controls, queues, priorities, scheduling, and bulk enqueue

Reference for the `rails-active-job` skill. Load it on demand when a change adds concurrency limits, queues or priorities, recurring/scheduled jobs, or bulk enqueue. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Concurrency controls

Concurrency has two distinct meanings:

1. worker capacity: how many jobs a worker can execute
2. business/resource concurrency: how many jobs for the same key may overlap

Solid Queue provides `limits_concurrency` for the second category. The current documentation supports a key, limit, duration, optional group, and conflict behavior.

Example:

```ruby
class RebuildAccountJob < ApplicationJob
  limits_concurrency(
    to: 1,
    key: ->(account_id) { account_id },
    duration: 5.minutes
  )
end
```

Use a concurrency control when overlap itself violates a contract.

Do not use a concurrency limit as a generic replacement for worker sizing. For high-throughput throttling, queue-level worker capacity can be simpler and cheaper.

Always analyze:

- database connection pool
- external API limits
- lock contention
- CPU/memory
- downstream queue capacity
- number of worker processes
- thread count per process

## Queues and priorities

Queues are capacity/isolation boundaries, not merely labels.

Use separate queues when workloads have materially different:

- latency requirements
- resource usage
- failure characteristics
- external rate limits
- operational ownership

Avoid creating a unique queue for every job without operational justification.

Remember that queue order and numeric priority are backend-dependent. With Solid Queue, queue order has precedence across queues and priority applies within a queue.

## Scheduling and recurring tasks

Scheduled jobs and recurring tasks are different concepts:

```text
scheduled job
→ one future execution

recurring task
→ recurring enqueue schedule
```

Use the backend's durable scheduler/configuration rather than application boot code that manually creates timers.

For recurring jobs, define:

- schedule
- timezone expectations
- idempotency
- overlap policy
- failure/retry semantics
- deployment behavior
- disable/maintenance behavior

Solid Queue uses `config/recurring.yml` for recurring tasks and a scheduler process.

## Bulk enqueue

For large batches, consider `ActiveJob.perform_all_later` instead of issuing individual enqueue calls when the backend supports the desired behavior.

Bulk enqueue reduces queue-store round trips. However, backend-specific constraints can change the trade-off. Solid Queue documents that concurrency-controlled jobs need individual enqueue handling to enforce concurrency limits, reducing the benefit of bulk enqueue in that case.

Do not bulk enqueue millions of jobs without analyzing queue storage, database write pressure, payload size, and worker capacity.
