# Sidekiq Adapter

Reference for the `rails-active-job` skill. Load it on demand when the repository's queue adapter resolves to `:sidekiq`. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`. Active Job is the routing destination for queue work; this reference covers the operational surface that is specific to Sidekiq and not owned by the framework-level Active Job contract.

## Resolve before relying on Sidekiq-specific behavior

1. Resolve the installed `sidekiq` gem version (Sidekiq 7's `redis-client` differs from Sidekiq 6's `connection_pool` + `redis`).
2. Resolve the Active Job queue adapter from `ApplicationJob.queue_adapter` (it should be `:sidekiq`).
3. Resolve the Redis version and topology (single-instance, Sentinel, Cluster).
4. Inspect `config/initializers/sidekiq.rb` for the `Sidekiq.configure_server` / `Sidekiq.configure_client` blocks.
5. Inspect `config/routes.rb` for the `Sidekiq::Web` mount and any auth wrapper.
6. Inspect `app/jobs/` for `sidekiq_options` declarations.

Do not assume Sidekiq 7 semantics when the Gemfile.lock pins 6.x.

## `sidekiq_options` — per-job configuration

`sidekiq_options` configures queue, retry, dead-set retention, backtrace, and locking for a single job class. It is the Sidekiq equivalent of Active Job's `queue_as`, `retry`, and `discard_after` declarations — but the option names and semantics are Sidekiq-specific.

```ruby
class FulfilOrderJob < ApplicationJob
  queue_as :fulfilment
  self.queue_adapter = :sidekiq  # explicit per-job override of the global adapter

  sidekiq_options(
    queue: :fulfilment,           # may also be set via queue_as
    retry: 5,                     # Sidekiq retry count; Active Job's `retry_after` is separate
    dead: 5,                      # jobs that exceed retry are moved to the dead set; this is the retention count
    backtrace: 5,                 # store N lines of backtrace in the dead-set payload
    lock: :until_executed         # sidekiq-unique-jobs extension; not part of Sidekiq core
  )

  sidekiq_retry_in do |count, exception|
    # Sidekiq-specific retry backoff; Active Job's `retry_after` does not run under :sidekiq
    case exception
    when RateLimited
      (count + 1) * 60
    else
      :exponential_backoff
    end
  end
end
```

Document explicitly when `sidekiq_options` is used instead of Active Job's framework-level options. Mixing the two is a contract drift: under `:sidekiq`, `retry_after` and `discard_after` do not run; only Sidekiq's retry and dead-set behavior apply.

## Strict vs priority queue ordering

Sidekiq pulls queues in the order declared in `sidekiq.yml` (or the `:queues` config). Two modes matter:

- **Strict ordering** (`strict: true` or queues listed once each): Sidekiq fully drains `queue_a` before pulling from `queue_b`. Use this when one queue must always take priority.
- **Weighted ordering** (queues listed multiple times, e.g. `[default, default, mailers]`): Sidekiq samples proportionally. Use this when no queue should starve but throughput should favor one.

Solid Queue's `limits_concurrency` (covered in the `concurrency-queues-scheduling` reference) is the per-key concurrency limit; Sidekiq's `strict`/weighted is the per-queue pull ordering. They are not equivalent. Choose per-key concurrency when overlap violates a contract; choose strict queue ordering when a whole queue must take priority.

## Sidekiq Web UI security

`Sidekiq::Web` is a Rack app mounted into the Rails router. It exposes queue state, retries, dead-set, and live job management (delete, retry, kill). It must be authenticated and rate-limited.

```ruby
# config/routes.rb
authenticate ->(user) { user.admin? } do
  mount Sidekiq::Web => "/admin/sidekiq"
end
```

Do not mount `Sidekiq::Web` at a public path without authentication. Beyond the obvious "anyone can kill jobs" risk, the Web UI also exposes argument payloads — which may contain PII, tokens, or signed Global IDs that should not be world-readable.

For IP allowlisting without Devise/Pundit:

```ruby
# config/initializers/sidekiq.rb
require "ipaddr"

allowed_ips = %w[10.0.0.0/8 192.168.0.0/16].map { |cidr| IPAddr.new(cidr) }

Rails.application.config.middleware.insert_before 0, Rack::IP do |ip|
  allowed_ips.any? { |range| range.include?(ip) }
end
```

For basic auth without Devise:

```ruby
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  ActiveSupport::SecurityUtils.secure_compare(user, ENV.fetch("SIDEKIQ_WEB_USER")) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("SIDEKIQ_WEB_PASS"))
end
```

`secure_compare` prevents timing attacks. Read credentials from `Rails.application.credentials` or environment; never hardcode.

## Redis connection pooling

Sidekiq 7 uses the `redis-client` gem directly. Sidekiq 6 uses `connection_pool` + `redis`. The configuration blocks are not interchangeable.

Sidekiq 7:

```ruby
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL"),
    network_timeout: 5,
    pool_timeout: 5,
    size: 12  # server-side pool size; see calculation below
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch("REDIS_URL"),
    size: 5  # client-side pool size; smaller because it serves one Puma process
  }
end
```

Pool sizing: server-side pool size should be at least `(concurrency * number_of_processes) + 5` to handle retries, scheduled-poll jobs, and the heartbeat thread. The default Sidekiq concurrency is 5; if you raise `concurrency: 25`, raise the server pool accordingly. A too-small pool produces `Redis::CannotConnect` and `WaitTimeout` errors under load.

For Redis Cluster or Sentinel, use the `url:` array form:

```ruby
config.redis = {
  url: ["redis://redis-1:6379", "redis://redis-2:6379"],
  role: :master,
  sentinels: ENV.fetch("REDIS_SENTINELS", "").split(",").map { |s| { host: s, port: 26379 } }
}
```

Do not namespace Redis (`REDIS_NAMESPACE`) unless you control every writer. Namespacing interacts poorly with Sidekiq's scheduling and cron extensions, and adds a per-command prefix cost. Prefer a dedicated Redis database (`/0`, `/1`, …) over a namespace.

## Retry, dead set, and `Sidekiq::RetrySet`

Sidekiq's retry pipeline is independent of Active Job's `retry_after`. Under `:sidekiq`:

1. A job raises → Sidekiq moves it to the retry set with a backoff (default: `(count ** 4) + 15` seconds, capped at `sidekiq_options(retry: 25)` attempts).
2. After `retry:` attempts, the job moves to the dead set (retention: `dead:` jobs, default 10,240).
3. Manual retry: `Sidekiq::RetrySet.new.retry(label)` or `Sidekiq::DeadSet.new.kill(jid)`.

```ruby
# Operational cleanup script — never run on a live production Redis without a maintenance window
Sidekiq::DeadSet.new.each do |job|
  next unless job.klass == "FulfilOrderJob"
  next unless job.retried_at && job.retried_at < 30.days.ago

  job.kill  # moves the dead job to the killed set; it will not run again
end
```

When using Active Job + Sidekiq, the `ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper` is the class Sidekiq actually enqueues. The `sidekiq_options` declared on `FulfilOrderJob` do not apply to `JobWrapper`. To apply Sidekiq-level options to all Active Job-wrapped jobs, configure `Sidekiq.options[:queues]` and `Sidekiq.options[:retry]` globally, or override `JobWrapper` in an initializer.

## Sidekiq Cron vs Solid Queue recurring tasks

`sidekiq-cron` and Sidekiq Enterprise's `sidekiq-ent-cron` schedule jobs on a cron expression. Solid Queue (Rails 8 default) provides `recurring` blocks in `config/solid_queue.yml`. They are not interchangeable.

`sidekiq-cron`:

```yaml
# config/schedule.yml
daily_account_rebuild:
  cron: "0 2 * * *"
  class: "RebuildAccountJob"
  queue: :low
  args: [{ mode: :full }]
```

```ruby
# config/initializers/sidekiq.rb
require "sidekiq/cron"

schedule = YAML.safe_load(File.read("config/schedule.yml"))
schedule.each { |name, config| Sidekiq::Cron::Job.create(name:, cron: config["cron"], class: config["class"], args: config["args"]) }
```

Solid Queue:

```yaml
# config/solid_queue.yml"
production:
  dispatchers:
    - recurring_tasks:
        daily_account_rebuild:
          class: "RebuildAccountJob"
          schedule: every day at 2:00am
          args: [{ mode: :full }]
          queue: low
```

When migrating `sidekiq-cron` → Solid Queue recurring, translate `cron: "0 2 * * *"` → `schedule: every day at 2:00am`. Both expressions are deterministic; verify with a dry-run before relying on the schedule.

## Sidekiq sharding

For multi-tenant workloads where one tenant's job volume should not block another, Sidekiq supports per-tenant Redis shards via `Sidekiq::RedisConnectionAdapter` (Sidekiq 7+) or by overriding `sidekiq_redis` per job. The pattern is:

```ruby
class ApplicationJob
  def self.sidekiq_redis(&block)
    if (shard = current_tenant&.redis_url)
      Sidekiq::RedisConnectionAdapter.with(shard:, &block)
    else
      Sidekiq.redis(&block)
    end
  end
end
```

Do not introduce sharding without measuring. The operational complexity (one Redis per tenant, monitoring per shard, failover per shard) is real. Prefer a single Redis with queue isolation (`queue_as :tenant_123`) when throughput allows.

## Sidekiq 7 migration notes

Migrating from Sidekiq 6 to 7 touches three surfaces:

1. **Redis client**: replace `gem "redis", "~> 4"` with `gem "redis-client"` in the Gemfile. The `Sidekiq.configure_server { |c| c.redis = { ... } }` block is largely the same, but `network_timeout` and `pool_timeout` keys replace some legacy options.
2. **Connection pool sizing**: the default `size:` is now 5 (was 5 in 6.x). Recompute as `(concurrency × processes) + 5`.
3. **Capsules** (Sidekiq 7.0+): `Sidekiq.configure_server { |c| c.capsule("default") { |cap| cap.concurrency = 10 } }` replaces per-queue concurrency. This is closer to Solid Queue's `limits_concurrency`.

Migration order matters: bump the `sidekiq` gem first, run the Sidekiq 7 migration script (`sidekiqctl migrate`), verify the queue state, then bump `redis-client`. Do not bump both at once under load.

## Verification

For Sidekiq-specific changes, verify:

1. `bundle exec sidekiq --verbose` boots and connects to Redis without `Redis::CannotConnect`.
2. `Sidekiq::Queue.new.size` returns a sensible number for each declared queue.
3. The Web UI mounts at the intended path and requires authentication (curl the path unauthenticated; expect 401/403).
4. A test job enqueued under `:sidekiq` completes during a request-spec (set `queue_adapter = :test` in the spec helper to avoid network Redis; see the `rspec-job-and-mail-enqueue` pattern in the shared catalog).
5. `Sidekiq::RetrySet.new.size` is bounded; if it is growing, the retry pipeline is failing closed instead of moving jobs to the dead set.
6. `Sidekiq::DeadSet.new.size` is under the configured `dead:` limit.
7. For Sidekiq 7: `Sidekiq.redis { |r| r.call("PING") }` returns `"PONG"` from both server and client configurations.

Never run Sidekiq against production Redis without a maintenance window when changing concurrency, pool size, or capsule configuration.

## Source foundation

- Sidekiq 7 wiki: https://github.com/sidekiq/sidekiq/wiki
- Sidekiq 6 → 7 migration: https://github.com/sidekiq/sidekiq/blob/main/7.0-Upgrade.md
- `redis-client` gem: https://github.com/redis-rb/redis-client
- Sidekiq Enterprise (cron, unique jobs, batches): https://github.com/sidekiq/sidekiq-ent
- `sidekiq-cron` (community): https://github.com/ondrejbartik/sidekiq-cron
- Active Job's Sidekiq adapter: `ActiveJob::QueueAdapters::SidekiqAdapter` in the Rails source

The Sidekiq operational surface is the adapter's own; Active Job is the routing destination.
