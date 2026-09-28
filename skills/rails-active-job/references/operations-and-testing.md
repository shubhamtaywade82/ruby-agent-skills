# Callbacks, shutdown, observability, security, and testing

Reference for the `rails-active-job` skill. Load it on demand when a change adds job callbacks, affects worker shutdown, job telemetry, or job security, or needs job tests. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Callbacks

Active Job provides enqueue and perform lifecycle callbacks.

Use callbacks for narrow cross-cutting concerns such as instrumentation.

Avoid putting business workflows inside `before_enqueue`, `after_enqueue`, `before_perform`, or `after_perform` merely because the hook is available.

Keep callback behavior:

- small
- observable
- deterministic
- safe under retries

Remember that bulk enqueue has different callback behavior from individual enqueue.

## Shutdown and graceful termination

Job execution is interruptible.

For long-running jobs:

- make work restartable
- persist progress when useful
- use checkpoints/cursors for large datasets
- keep side effects idempotent
- understand worker TERM/QUIT semantics
- avoid assuming the process will always reach the end of `perform`

Current Active Job supports continuations for resumable multi-step jobs in Rails versions that expose `ActiveJob::Continuable`. Use version-aware guidance before activating this API.

## Observability

At minimum, be able to answer:

- what job ran?
- which arguments/identifier?
- when was it enqueued?
- when did execution begin/end?
- which queue?
- attempt count?
- duration?
- failure exception?
- retry/discard outcome?
- correlation/request ID?
- what downstream dependency was involved?

Never log secrets or sensitive payloads merely for debugging.

Prefer structured events/metrics over parsing free-form log strings.

## Security

Queue payloads are durable data.

Treat arguments as sensitive persistence where applicable.

Do not enqueue:

- passwords
- access tokens
- private credentials
- unnecessary personal data
- entire request/session objects

Authorize again at execution time when permissions may have changed since enqueue.

Do not assume authorization at enqueue time remains valid later.

## Testing

Test jobs at the behavior boundary.

At minimum cover the applicable dimensions:

- enqueued job class and arguments
- queue selection
- scheduling
- perform behavior
- retry/discard semantics
- idempotency
- transaction/enqueue boundary
- concurrency key/limit
- failure reporting
- deserialization behavior
- bulk enqueue behavior when used

Rails provides dedicated job testing support and separate guidance for isolated/contextual job tests.

Prefer deterministic fake/adaptor behavior over sleeping in tests.
