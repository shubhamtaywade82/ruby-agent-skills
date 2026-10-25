# Buffering, Ordering, and Backpressure

## Bounded buffering

Every place a burst of inbound events can wait is a buffer, and every buffer needs a bound. The bound is a capacity decision backed by arithmetic, not a constant pulled from a hat:

```
bound >= arrival_rate_peak * downstream_latency_peak
```

If a provider can deliver 5,000 events/second at peak and downstream processing takes 20 ms per event on 4 workers (200 events/second of throughput), then any bound below what the backlog can absorb during the burst converts directly into overflow behavior. Choose the bound, then choose what happens when it is hit.

Ruby's `SizedQueue` is the primitive for bounded hand-off between a callback thread and worker threads:

```ruby
@buffer = SizedQueue.new(10_000)

@client.on_tick do |payload|
  event = normalize(payload) or next
  begin
    @buffer << event              # non-blocking push
  rescue ThreadError
    dropped_oldest = @buffer.shift # drop-oldest policy: bounded by design
    @buffer << event
    count_drop(:overflow, dropped_oldest)
  end
end
```

Three overflow policies, and when each is correct:

| Policy | Correct when | Cost |
|---|---|---|
| drop-oldest | newest data supersedes old (quotes, ticks, last-known state) | silent loss of events that some consumer may have needed |
| reject-new (drop-incoming) | completeness matters more than latency (order fills, account events) | the provider's data is lost unless a backfill path exists |
| block the producer | the provider throttles on slow consume and correctness beats latency | back-pressure reaches the provider; may violate ToS or trigger disconnect |

Blocking the producer inside a callback thread is usually wrong: the provider's read loop stalls, heartbeats go unanswered, and the connection dies of its own backpressure. If you must block, block a dedicated worker pool, not the callback.

Unbounded `Array#push` inside a callback is the anti-pattern that takes production down at market open: memory climbs until the process is killed, and the kill triggers a reconnect that replays the burst into a fresh buffer.

## Backpressure

Backpressure is the propagation of "slow down" from a slow consumer to a fast producer. Inside one process you control it with bounded queues. Across a process boundary (daemon -> Redis -> workers) you control it with:

- bounded list lengths (Redis `LPUSH` + `LLEN` checks or streams with `MAXLEN`);
- explicit shedding: when depth crosses a high watermark, degrade work (skip enrichment, batch coarser, drop-oldest) before crossing a critical watermark that rejects or halts;
- measured worker counts: more workers only helps if the downstream (database pool, provider API budget) has headroom.

A backpressure design is stated as numbers: "buffer 10,000 events; at 8,000 shed enrichment; at 10,000 drop-oldest with metric; workers 4; expected steady drain 5,000/s". Anything vaguer is a hope, not a design.

## Burst handling

Bursts are the normal case, not the exception: market opens, batch notifications, reconnect replays. Handle them by shaping, not by suffering:

- **coalesce** state updates: many ticks for one instrument inside a window collapse into one "latest" write;
- **batch** database writes: buffered events flush as one `insert_all` per interval or count threshold instead of one transaction each;
- **defer** expensive per-event work into jobs so the ingest path stays O(1) per event;
- **sample** metrics: count and histogram, never log per event.

```ruby
class TickBatcher
  FLUSH_COUNT = 500
  FLUSH_INTERVAL = 0.25 # seconds

  def initialize(sink:, timer: Timer)
    @sink = sink
    @timer = timer
    @pending = []
    @mutex = Mutex.new
  end

  def <<(event)
    flush_now = nil
    @mutex.synchronize do
      @pending << event
      flush_now = @pending.length >= FLUSH_COUNT
    end
    flush if flush_now
  end

  def flush
    batch = @mutex.synchronize { @pending.slice!(0..) }
    @sink.write_all(batch) if batch.any?
  end
end
```

The batcher has its own mutex because the callback thread and the timer both touch `@pending`; `FLUSH_COUNT` bounds worst-case latency and `FLUSH_INTERVAL` bounds worst-case visibility for slow feeds.

## Event ordering and duplicates

Ordering claims are contract statements about the provider, verified against evidence:

| Provider statement | Meaning in your code |
|---|---|
| ordered per instrument/connection | you may compute deltas against the previous event |
| ordered per partition/key | parallel consumers must key off the same field or ordering breaks |
| unordered | every consumer must tolerate reordering or reorder by sequence itself |

Never upgrade these statements based on observation ("it looked ordered in staging"). A provider may reorder exactly in the failure paths you did not exercise.

Duplicates arrive from three sources: provider redelivery after an unacknowledged delivery, reconnect replay (receiving a range you already processed), and your own duplicate subscription. All three are handled by the same mechanism: **stable event identity checked at exactly one seam**.

```ruby
class IngestDeduplicator
  def initialize(bound: 65_536)
    @seen = {}                  # token => monotonic stamp
    @bound = bound
    @mutex = Mutex.new
  end

  def seen?(token)
    @mutex.synchronize do
      @seen.key?(token)
    end
  end

  def record(token, now = Process.clock_gettime(Process::CLOCK_MONOTONIC))
    @mutex.synchronize do
      @seen[token] = now
      evict_stale(now) if @seen.length > @bound
    end
  end

  private

  def evict_stale(now)
    @seen.reject! { |_t, stamp| now - stamp > EVICT_AFTER } # e.g. 10 minutes
  end
end
```

The deduplicator is bounded by design and honest about its limits: a duplicate arriving after eviction will be treated as new. When the cost of that is unacceptable, dedupe on durable state (unique index keyed by provider event id) at the database instead of in memory — the in-memory filter is an optimization in front of the durable guarantee, never a substitute for it.

Deduplicate at the normalization seam, exactly once per event, before fan-out to consumers. Duplicating the check in each consumer guarantees eventual drift: one consumer adds a bypass flag, the invariant silently dies.

## Downstream hand-off

The hand-off from ingest to processing is a boundary with a contract:

- **who processes**: dedicated worker threads in the daemon, Active Job workers, or a routed internal bus;
- **what shape**: normalized, validated event objects (never raw provider payloads leaking into business code);
- **what guarantees**: at-least-once with identity dedupe, or at-most-once with drop semantics — stated, not implied;
- **what happens on downstream failure**: event returns to the buffer, goes to a retry queue, or is dropped with a metric.

Business code consuming feed events should be testable without any feed machinery: hand it normalized events and assert behavior. If `MarketFeedHub`-style classes become required dependencies of domain services, the seam has rotted and the tests will show it (slow, order-dependent, flaky).

Keep the direction of dependency strict:

```
provider client -> normalization (validate, stamp, dedupe) -> bounded buffer
              -> workers/jobs -> domain services -> persistence/cache
```

Nothing to the right of the arrow may reach back to the left: domain services never call `@client`, never reconnect, never inspect wire payloads. A "quick read of the raw payload" in business code couples the domain to a provider format and makes provider migrations domain rewrites.
