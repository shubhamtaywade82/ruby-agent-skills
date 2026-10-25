# Freshness and Recovery

## The freshness contract

Freshness is a per-consumer requirement, stated as a number: "this consumer may act on data at most N seconds old". Different consumers of the same feed have different contracts:

| Consumer | Typical contract |
|---|---|
| live order placement | act only on data fresher than 1-2 seconds, else reject |
| position display | show last-known with an explicit "delayed" marker up to 30 seconds |
| indicator computation | tolerate gaps up to one candle, then halt and reconcile |
| end-of-day reporting | freshness irrelevant; completeness is the contract |

Write the contract down next to the consumer, enforce it where the data is used (not where the data arrives), and make violations observable. A freshness contract enforced only in the feed layer cannot protect a consumer that reads through a cache.

## Stale-feed detection

Staleness detection has exactly three inputs worth trusting:

1. **provider event timestamps** (event time): what the provider says about when the event happened;
2. **arrival timestamps** (processing time): when your process received it;
3. **absence of arrival**: no event at all for N seconds on a feed that should have a known minimum rate.

The detector combines them into states:

```
fresh:      last acceptable event within contract
degraded:   last event older than contract, feed still connected
disconnected: connection-level failure observed
stalled:    connected, heartbeats flowing, but no payload events
```

The `stalled` state is the one teams miss: TCP is up, pings flow, and the subscription quietly delivers nothing (upstream outage, silently dropped subscription, or a symbol change). Detect it by rate expectation — if a feed with an expected minimum rate of R events/minute has delivered zero for more than `k / R` minutes, it is stalled.

```ruby
class FeedHealth
  def initialize(min_events_per_minute:, stall_factor: 3.0)
    @min_rate = min_events_per_minute / 60.0
    @stall_factor = stall_factor
    @last_event_at = nil
    @mutex = Mutex.new
  end

  def record_event(now = Process.clock_gettime(Process::CLOCK_MONOTONIC))
    @mutex.synchronize { @last_event_at = now }
  end

  def state(now = Process.clock_gettime(Process::CLOCK_MONOTONIC))
    @mutex.synchronize do
      return :never_received if @last_event_at.nil?
      age = now - @last_event_at
      return :stalled if age > (@stall_factor / @min_rate)
      :live
    end
  end
end
```

Never use `Time.now` for these intervals — wall-clock jumps (NTP corrections, DST in naive local times) produce phantom stalls or phantom freshness. Monotonic clock for intervals; wall clock only for timestamps you store.

## Missing events and gaps

When events carry sequence numbers, offsets, or are countable per period, absence is detectable and must be detected:

- **sequence gaps**: `seq == last_seq + 1` else gap; record `[last_seq+1, seq-1]`;
- **period gaps**: a minute candle absent from an OHLCV stream is a gap, not a zero;
- **resubscription gaps**: anything between disconnect and successful resubscribe + reconciliation.

Gap handling is a decision, made per stream:

1. **backfill** from a historical endpoint for the missing range, then resume;
2. **reconcile** current state from a snapshot/positions endpoint instead of replaying events;
3. **mark degraded** and let the freshness contract reject actions until the gap resolves;
4. **accept** the gap for this consumer and record it.

Choosing "accept" silently for everything is how systems drift: every reconnect loses a little data, nobody notices, and the ledger stops matching the provider at month end.

```ruby
class SequenceGapTracker
  def initialize
    @last_seq = nil
    @gaps = []
  end

  def accept(seq)
    return @last_seq = seq if @last_seq.nil?
    if seq > @last_seq + 1
      @gaps << [@last_seq + 1, seq - 1]
    end
    @last_seq = seq if seq > @last_seq  # tolerate duplicates and replays
  end

  def gaps = @gaps.dup
end
```

## Event time versus processing time

Two timestamps, recorded at the seam, forever separate:

```ruby
{
  "event_time" => Time.at(payload["ts"]).utc,       # provider clock, at the source
  "received_at" => Time.now.utc,                     # your clock, at ingestion
  "ingest_latency_ms" => ((Time.now.to_f - payload["ts"]) * 1000).round
}
```

Rules that keep them useful:

- compute latency at ingestion (`received - event`) and export it as a metric; a feed can be perfectly fresh and pathologically latent, and only this number tells you;
- never overwrite one with the other downstream; consumers choose explicitly which clock governs their decision;
- clock skew between you and the provider is a real number — measure it (compare provider timestamp of a heartbeat against local receipt) before trusting small latencies;
- store timestamps in UTC and convert at display; a feed consumer that mixes local times into event time corrupts every session-based calculation downstream (session calendars belong to the market-data domain, not the ingestion layer).

## Failure semantics

When the feed is unavailable, degraded, or stale, every consumer already has a behavior — the only question is whether it was chosen. Make the choice explicit:

| Semantic | Use when | Implementation shape |
|---|---|---|
| **stop** | acting on wrong data is worse than not acting (order placement, risk calculations) | feature gate reads feed health; reject and surface "unavailable: feed stale" |
| **degrade** | partial function is acceptable (display last-known with a badge, widen spreads, disable automation but keep showing data) | health-aware wrapper supplies last-known plus flag; consumers check the flag |
| **alert** | humans must intervene (manual reconciliation expected) | threshold breach emits an incident signal, not just a log line |
| **reject** | a specific action is forbidden without fresh data (submit order without fresh quote) | guard at the action boundary; rejection is loud, logged, and testable |

The guard lives at the boundary that consumes the data, not inside the feed client:

```ruby
class OrderPlacementGuard
  def initialize(feed_health:, max_age: 2.0)
    @feed_health = feed_health
    @max_age = max_age
  end

  def assert_fresh!(instrument)
    age = @feed_health.age_of_last_event(instrument)
    return if age && age <= @max_age

    raise FeedDataUnavailable,
          "refusing order for #{instrument}: feed age #{age&.round(2)}s exceeds #{@max_age}s"
  end
end
```

Fail-closed is the default for anything with material consequences: when health is unknown, the guard rejects. A guard that allows action because health is "probably fine" is not a guard.

## Recovery after reconnect

Recovery reunites three kinds of state, in order:

1. **connection state**: connected, subscribed (replay the registry);
2. **stream position**: sequence/offset reconciled, gaps recorded, backfill or snapshot chosen;
3. **derived state**: caches, indicators, position views rebuilt or marked stale until reconciled.

Recovery is complete when a consumer reading only derived state can answer "is this current?" truthfully — usually via a `reconciled_at` stamp or a health flag flipped after the last step. Marking a cache "ready" on reconnect (before reconciliation) is the classic bug: consumers act on pre-gap values through a cache that promised freshness.
