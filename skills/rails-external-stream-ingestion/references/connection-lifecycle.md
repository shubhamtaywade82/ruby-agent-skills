# Connection Lifecycle

## Connection ownership

Every external feed connection has exactly one owner: a named object whose responsibility is the connection's life from `connect` to `close`. The owner is where reconnect decisions, subscription state, and supervision live. Everything else talks to the owner, never to the raw socket.

Ownership questions to answer before writing code:

1. Which object calls `connect`, and from which process?
2. Which object observes disconnects, and what does it do first?
3. Where do reconnect attempts live, and what bounds them?
4. Who owns subscriptions — is the subscription set part of connection state or separate state the connection reads on (re)connect?

Two owners for one connection is the classic defect: a service object that "helpfully" reconnects while a supervisor also reconnects produces two sockets, doubled subscriptions, and interleaved duplicates that look like a provider bug.

In multi-process topologies (Rails server, daemon, workers), decide deliberately whether the connection is per-process or owned by one dedicated process that republishes internally. One shared trading daemon feeding Redis is one feed boundary; four web processes each connecting is four boundaries, four rate-limit pools, and quadruple reconnect storms.

## Startup and supervision

A feed connection inside a supervised long-running process should follow the process's lifecycle, not the request lifecycle. Concretely:

- the consumer starts when the process starts (boot, daemon entry, or supervised supervisor), not lazily on first use unless first-use startup is an explicit decision;
- startup failures surface through the supervisor (raise, exit non-zero, or report unhealthy) instead of being swallowed into a background retry nobody observes;
- the supervisor restarts the consumer on crash with a backoff, and the restart path is the same code path as initial start — not a copy.

For Rails API processes that should not own feeds, the correct startup decision is "do not start here at all"; the connection belongs to the daemon or worker process that the deployment actually supervises. See rails-production-runtime for process topology decisions.

### Example: supervised start

```ruby
# lib/daemons/feed_daemon.rb
class FeedDaemon
  def initialize(consumer:, logger: Rails.logger)
    @consumer = consumer
    @logger = logger
    @stopping = false
  end

  def run
    until @stopping
      begin
        @consumer.start
        @consumer.wait          # blocks until the consumer stops or dies
      rescue => e
        @logger.error("[feed] consumer crashed: #{e.class} #{e.message}")
      end
      break if @stopping
      sleep backoff             # bounded by configuration, not by accident
    end
  end

  def stop
    @stopping = true
    @consumer.stop
  end

  private

  def backoff
    @backoff ||= 1
    @backoff = [@backoff * 2, 60].min
  end
end
```

The backoff resets on a successful `wait` return of non-crash origin; it grows on repeated crashes so a hard-down provider cannot hot-loop the process.

## Heartbeats

Heartbeats answer "is the connection alive", which is a different question from "is data flowing". Three heartbeat contracts exist and they are frequently confused:

1. **Protocol-level keepalives** (WebSocket ping/pong frames). Keep NAT bindings and intermediaries from dropping an idle socket. Usually invisible in application code, but the interval must be shorter than every idle-drop window between the application and the provider.
2. **Application-level heartbeats** (provider sends a periodic message, or expects one). These are real events with real deadlines; missing one means the connection is logically dead even if the TCP socket is open.
3. **Liveness-by-observation** (no heartbeat exists; you define "no event for N seconds means assume dead"). This is a freshness heuristic, not a connection fact — it belongs with the freshness contract, and it can fire on legitimately quiet feeds.

Rules:

- Configure the heartbeat interval against the provider's documented idle-drop window, with margin. If the provider drops idle connections at 60 seconds, a 55-second ping has no room for a GC pause.
- Time heartbeat deadlines with `Timeout`-free mechanisms (a monitor thread checking `last_seen`, or the socket's own read timeout), because a stuck read callback plus `Timeout.timeout` is a corruption recipe.
- Distinguish "heartbeat received" from "payload event received" in metrics; a live connection delivering no data is a subscription or upstream problem, not a connection problem.

## Reconnect and resubscribe

Reconnection is a state-machine step, not a `rescue` clause. A correct reconnect path:

1. observes the disconnect (callback, read error, heartbeat deadline);
2. closes or discards the dead client object — never writes to a socket another thread may also be closing;
3. constructs a fresh client (or resets the existing one to a known state);
4. reconnects with bounded, jittered backoff;
5. **resubscribes every required subscription explicitly** — from persisted or registry state, not from whatever the dead connection happened to hold;
6. reconciles what was missed (sequence, offset, snapshot request, or backfill — see freshness-and-recovery);
7. marks the feed available again and resumes normal processing.

The two most common reconnect defects are both step-5 failures:

- **silent resubscription loss**: the provider accepts the connection but the application forgot to resend subscriptions, so the feed looks connected and empty. Symptom: connection up, zero events, no errors.
- **subscription duplication**: the reconnect path appends to a subscription list that already contained the entries, so the provider delivers each event twice under two subscription ids. Symptom: every event processed exactly twice after the first reconnect.

Both are prevented by making the subscription registry the single source of truth and replaying it idempotently (subscribe-by-key, replacing rather than appending).

### Example: reconnect that replays subscriptions

```ruby
class ReconnectJob < ApplicationJob
  queue_as :feeds

  def perform(consumer_class)
    consumer = consumer_class.constantize.build
    consumer.subscribe_all            # replays the registry, replacing state
    consumer.start
  rescue => e
    Rails.logger.error("[feeds] reconnect failed: #{e.class} #{e.message}")
    retry_job wait: backoff_seconds, attempts: 8
  end
end
```

`subscribe_all` overwrites the client's subscription set from the registry; the registry, not the connection, defines "what we want to receive".

Backoff discipline:

- exponential with a ceiling (for example 1s, 2s, 4s … capped at 60s), plus jitter to prevent synchronized reconnect storms across processes after a provider-wide drop;
- a maximum attempt budget or an escalation path (page, circuit-open) so an unreachable provider becomes an incident rather than an infinite quiet loop;
- reset the backoff after a connection that stayed up meaningfully long, or a permanently flapping connection keeps growing delays forever.

## Shutdown

Shutdown is a first-class path, not an afterthought, because deploy restarts exercise it constantly.

A correct shutdown:

1. stops accepting new events (detach callbacks or stop the read loop);
2. drains bounded buffers within a deadline — events already accepted are either processed or explicitly abandoned with a count logged;
3. unsubscribes or closes cleanly so the provider sees a deliberate close, not an abrupt drop it may alert on;
4. joins or stops worker threads that drain the buffer;
5. is idempotent: double `stop` must not raise or reconnect.

Signals matter for daemons: trap `TERM`/`INT`/`QUIT` and route them to `stop`. In containerized deployments the difference between "drains within 30s" and "hangs forever on a blocked socket" is the difference between rolling deploys and killed pods losing buffered events.

What shutdown must never do:

- block indefinitely on a provider that is already gone (bound every close with a deadline);
- enqueue new reconnect jobs after the stop decision (guard with a `@stopping` flag checked before scheduling);
- leave worker threads waiting on a queue nobody will fill without `close`-ing the queue so `pop` returns.

### Example: bounded drain on shutdown

```ruby
def stop(deadline: 10)
  @stopping = true
  @client.close                 # best-effort, deadline-bounded internally
  drain_deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + deadline
  while @buffer.pending?.positive? &&
        Process.clock_gettime(Process::CLOCK_MONOTONIC) < drain_deadline
    sleep 0.05                  # workers finish in-flight events
  end
  dropped = @buffer.pending?
  @buffer.close
  Rails.logger.info("[feeds] stopped; dropped=#{dropped}") if dropped.positive?
end
```

`dropped` is a count, not a payload: shutdown logs never contain event data.
