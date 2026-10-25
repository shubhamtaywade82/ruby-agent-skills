# Subscription State, Caches, and Deterministic Testing

## Subscription registry

Subscriptions are state with a lifecycle: added, replaced, removed, and replayed on reconnect. Keep them in one registry object that is the single source of truth for "what we want to receive":

```ruby
class SubscriptionRegistry
  def initialize
    @wanted = {}
    @mutex = Mutex.new
  end

  def add(key, spec)
    @mutex.synchronize { @wanted[key] = spec }
  end

  def remove(key)
    @mutex.synchronize { @wanted.delete(key) }
  end

  def wanted
    @mutex.synchronize { @wanted.dup }
  end

  def subscribed?(key)
    @mutex.synchronize { @wanted.key?(key) }
  end
end
```

Two registry disciplines prevent the classic reconnect defects:

- **replay replaces**: on reconnect, subscribe exactly `registry.wanted` — compare-and-apply on the new connection rather than appending, so a reconnect cannot duplicate subscriptions;
- **removal is real**: a consumer that stops wanting data removes its key; otherwise the connection keeps receiving (and paying for) events nobody reads.

Per-instrument keys (rather than a single "everything" subscription) enable targeted resubscribe after partial provider failures, and make the "which instrument is stale?" question answerable per key.

## Thread-safe feed state

Feed state is touched from at least three threads: provider callback threads, a supervision/heartbeat thread, and request or worker threads reading "is this fresh?". Synchronize every shared field through one object and keep the critical sections tiny:

```ruby
class FeedState
  def initialize
    @mutex = Mutex.new
    @last_event = {}   # key => [payload, monotonic_stamp]
  end

  def record(key, payload, now = Process.clock_gettime(Process::CLOCK_MONOTONIC))
    @mutex.synchronize { @last_event[key] = [payload, now] }
  end

  def last_event(key)
    @mutex.synchronize { @last_event[key]&.first }
  end

  def age(key, now = Process.clock_gettime(Process::CLOCK_MONOTONIC))
    @mutex.synchronize do
      stamp = @last_event[key]&.last
      stamp ? now - stamp : nil
    end
  end
end
```

Rules:

- one mutex per state object; nested locks across state objects is how feed code deadlocks;
- never hold the mutex while calling the provider, the database, or anything blocking;
- duplicate suppression maps and last-event maps are bounded structures (see the buffering reference's eviction discipline) — unbounded hash maps keyed by instrument/token grow forever on churning feeds;
- prefer `Concurrent::Map` or dedicated thread-local copies only when measurement shows mutex contention; do not preemptively spread synchronization styles.

Ruby memory-model honesty: without synchronization there is no guarantee a worker thread ever sees the latest write from a callback thread, even for a single `Hash` assignment. "It worked in the demo" is not a proof; `Mutex` is cheap next to a heisenbug.

## Cache consistency

A cache in front of a stream is a promise about freshness, so its entries need staleness rules that match the stream, not generic TTL hope:

| Cache purpose | Correct invalidation |
|---|---|
| latest quote/tick | TTL bounded by the consumer's freshness contract, or event-driven write-through on each normalized event |
| derived indicator | invalidated when its input window is gapped or the feed degrades |
| reference/symbol data | version-stamped from the provider, invalidated on symbol-change events |

Write-through on ingest keeps the cache exactly as fresh as the stream:

```ruby
class LatestQuoteCache
  def initialize(cache: Rails.cache, ttl: 5.seconds)
    @cache = cache
    @ttl = ttl
  end

  def record(event)
    @cache.write(quote_key(event["token"]), event, expires_in: @ttl)
  end

  def fetch(token)
    @cache.read(quote_key(token))
  end

  private

  def quote_key(token) = "feeds:quotes:latest:#{token}"
end
```

Reads must handle the miss path deliberately: a cache miss on a live feed means "no current data", which the freshness contract turns into stop/degrade/reject — it must not silently fall back to `nil`-tolerant logic that treats absence as zero.

Never cache a stale value with a longer TTL because "it is better than nothing": a display may tolerate it, but a guard making an action decision cannot. When one cache serves both kinds of consumers, split it before the incident, not after.

## Deterministic fake-client tests

Feed logic is tested with a fake client that reproduces the provider's observable behavior — connect, subscribe, deliver, disconnect, redeliver — without the network:

```ruby
class FakeFeedClient
  attr_reader :connected, :subscriptions

  def initialize
    @connected = false
    @subscriptions = []
    @callbacks = {}
    @log = []
  end

  def connect = (@connected = true)
  def close = (@connected = false)
  def subscribe(key) = (@subscriptions << key)
  def on_tick(&block) = (@callbacks[:tick] = block)
  def on_disconnect(&block) = (@callbacks[:disconnect] = block)

  # Test-side control surface
  def deliver(payload) = @callbacks[:tick]&.call(payload)
  def drop! = @connected.then { @callbacks[:disconnect]&.call }
  def calls = @log
end
```

Test cases every feed consumer needs, all deterministic and millisecond-fast:

1. **first delivery** reaches downstream normalized and stamped;
2. **duplicate delivery** of the same event identity produces one downstream effect;
3. **disconnect** triggers the reconnect path (job scheduled or supervisor notified);
4. **reconnect** replays the subscription registry onto the new connection — assert the exact set, catching both missing and duplicated subscriptions;
5. **burst** beyond the buffer bound exercises the chosen overflow policy and reports the drop metric;
6. **stall** (no delivery for longer than the threshold) flips health to stalled/degraded;
7. **gap** (sequence jumps) records the missing range and triggers the configured recovery decision;
8. **shutdown** drains or abandons within the deadline and is idempotent.

```ruby
class MarketFeedConsumerTest < ActiveSupport::TestCase
  test "reconnect replays the subscription registry without duplication" do
    client = FakeFeedClient.new
    buffer = BoundedBuffer.new(size: 10)
    consumer = MarketFeedConsumer.new(client: client, buffer: buffer)
    consumer.subscribe("NIFTY")
    consumer.start
    client.drop!
    consumer.simulate_reconnect   # or drive ReconnectJob synchronously

    assert_equal ["NIFTY"], client.subscriptions
    assert_equal 1, client.subscriptions.tally["NIFTY"]
  end
end
```

Discipline for fakes:

- the fake models the provider's *contract* (does it redeliver? in order?), documented from provider docs, not from your code's wishes;
- fakes live in `test/` (or are injected), never in `app/` as production-classified code;
- time is injected (a clock object or monotonic stub) so staleness tests never `sleep` in real time — CI stays fast and deterministic;
- at least one test drives the public seam (enqueue a job, flip health) rather than reaching into private state, so refactors keep the suite meaningful.

Live-provider smoke checks, if kept at all, are separately tagged and never gate CI: a flaky network must not decide whether a commit is green.
