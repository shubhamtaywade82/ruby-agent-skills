# Locale isolation and propagation

Reference for the `rails-i18n` skill. Load it on demand when locale state crosses requests, threads, fibers, or background jobs. The operating rules, invariants, and verification steps stay in the skill's `SKILL.md`.

## Request locale isolation

Use request-scoped locale context.

Prefer I18n.with_locale around the request/unit of work instead of mutating I18n.locale without restoration.

Rails explicitly warns that assigning I18n.locale without consistent isolation can leak locale effects into later work on the same thread/process, and recommends I18n.with_locale for scoped changes.

The request lifecycle should look like:

```text
resolve locale
-> validate allowed locale
-> I18n.with_locale(locale)
-> controller/domain/rendering
-> restore prior locale
```

Do not rely on a global mutable locale remaining correct after arbitrary controller/service execution.

## Thread, fiber, and concurrency boundaries

Locale is execution context.

Inspect how the repository uses:

- threads;
- fibers;
- concurrent jobs;
- async Ruby/Rails work;
- request executors.

Never assume locale context automatically crosses an arbitrary concurrency boundary.

When spawning asynchronous work, pass locale explicitly when the work's user-facing output depends on locale.

Test that concurrent units do not cross-contaminate locale.

Compose with ruby-concurrency for custom concurrency and execution-context boundaries.

## Background jobs and locale propagation

A background job may execute after the request that enqueued it is gone.

For user-facing jobs define:

- which locale should be used;
- where the locale is captured;
- whether user/account preference should be re-read at execution time;
- behavior when the user's preference changed after enqueue;
- fallback when the locale is no longer supported.

Prefer reconstructible business identity over serializing unnecessary request state.

Do not assume the controller's I18n locale is still active when the job performs.

Compose with rails-active-job for enqueue, serialization, retry, and execution lifecycle.
